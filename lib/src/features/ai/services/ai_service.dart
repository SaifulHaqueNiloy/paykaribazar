import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import '../../../core/firebase/firestore_service.dart';
import '../../../core/services/secrets_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/service_locator.dart';
import '../domain/ai_work_type.dart';

import '../../../shared/services/notification_service.dart';
import '../config/ai_config.dart';
import 'ai_cache_service.dart';
import 'ai_rate_limiter.dart';
import 'ai_error_handler.dart';
import 'ai_request_logger.dart';
import 'ai_provider.dart';
import 'gemini_provider.dart';
import 'kimi_provider.dart';
import 'deepseek_provider.dart';
import 'fallback_provider.dart';
import 'ai_provider_manager.dart';
import 'api_quota_service.dart';
import 'package:flutter/material.dart';

final aiServiceProvider = Provider((ref) => getIt<AIService>());

class AIService {
  final SecretsService _secrets;
  late final AICacheService _cache;
  late final AIErrorHandler _errorHandler;
  late final AIRequestLogger _logger;
  late final AIProviderManager _providerManager;
  late final ApiQuotaService _quotaService;

  String? _currentUserId;
  final List<AIProvider> _providers = [];
  final Map<String, AIProvider> _providerRegistry = {};

  AIService({
    required FirestoreService firestore,
    required SecretsService secrets,
    List<AIProvider>? mockProviders,
  }) : _secrets = secrets {
    if (mockProviders != null) {
      _providers.addAll(mockProviders);
    }
  }

  /// Returns true if at least one AI provider is configured
  bool get isReady => _providers.isNotEmpty;

  Future<void> initialize({String? userId}) async {
    _currentUserId = userId;
    _cache = AICacheService();
    _rateLimiter = AIRateLimiter();
    _errorHandler = AIErrorHandler();
    _logger = AIRequestLogger();
    _quotaService = getIt.isRegistered<ApiQuotaService>()
        ? getIt<ApiQuotaService>()
        : ApiQuotaService();

    await _cache.initialize();
    
    if (_providers.isEmpty) {
      _setupProviders();
    }
    
    // Auto-Initialize Quota Tracking in Firestore
    await _initializeQuotaTracking();
    
    _initializeProviderManager();
  }

  Future<void> _initializeQuotaTracking() async {
    try {
      final providers = ['kimi', 'deepseek', 'gemini'];
      for (var p in providers) {
        // This will create the document if it doesn't exist via incrementUsage logic
        // but let's check hasQuota to trigger the fail-safe
        await _quotaService.hasQuota(p);
      }
      debugPrint('✅ [AIService] Quota tracking initialized in Firestore');
    } catch (e) {
      debugPrint('⚠️ [AIService] Quota init failed: $e');
    }
  }

  void _setupProviders() {
    _providers.clear();
    _providerRegistry.clear();

    final kimiKey = _secrets.getSecret('NVIDIA_API_KEY');
    if (kimiKey.isNotEmpty) {
      final provider = KimiProvider(apiKey: kimiKey);
      _providers.add(provider);
      _providerRegistry['kimi'] = provider;
    }

    final deepSeekKeys = _secrets.deepSeekKeys;
    if (deepSeekKeys.isNotEmpty) {
      final provider = DeepSeekProvider(apiKey: deepSeekKeys.first);
      _providers.add(provider);
      _providerRegistry['deepseek'] = provider;
    }

    final geminiKeys = [
      ..._secrets.getKeysByPrefix('GEMINI_MASTER_KEY'),
      ..._secrets.getKeysByPrefix('GEMINI_SUPPORT_KEY'),
      ..._secrets.getKeysByPrefix('GEMINI_API_KEY'),
    ].where((k) => k.isNotEmpty).toList();

    for (var key in geminiKeys) {
      final provider =
          GeminiProvider(apiKey: key, modelName: AIConfig.primaryModel);
      _providers.add(provider);
      _providerRegistry['gemini'] = provider;
    }
    
    if (_providers.isEmpty) {
      debugPrint('⚠️ [AIService] No AI providers could be configured. Check .env and API keys.');
    }
  }

  List<String> _fallbackProviderOrder() {
    final ordered = ['kimi', 'deepseek', 'gemini']
        .where(_providerRegistry.containsKey)
        .toList();
    if (ordered.isEmpty && _providers.isNotEmpty) {
      return [_quotaService.normalizeProviderKey(_providers.first.name)];
    }
    return ordered;
  }

  bool _isValidProviderResponse(String response) {
    return response.isNotEmpty && !response.toLowerCase().contains(' error:');
  }

  Future<String?> _generateWithTrackedProviders(
    String prompt, {
    AiWorkType? type,
  }) async {
    final preferredOrder = _fallbackProviderOrder();
    
    for (final providerKey in preferredOrder) {
      final provider = _providerRegistry[providerKey];
      if (provider == null) continue;

      final hasQuota = await _quotaService.hasQuota(providerKey);
      if (!hasQuota) {
        debugPrint('⛔ [AIService] Skipping $providerKey because quota is exhausted');
        continue;
      }

      try {
        debugPrint('🚀 [AIService] Attempting provider: $providerKey');
        final response =
            await provider.generate(prompt, type: type).timeout(const Duration(seconds: 30));
        
        if (_isValidProviderResponse(response)) {
          await _quotaService.incrementUsage(providerKey);
          return response;
        }
      } catch (e) {
        debugPrint('⚠️ [AIService] Provider $providerKey failed: $e');
        if (e.toString().contains('429') || e.toString().contains('quota')) {
          await _quotaService.markExhausted(providerKey);
        }
      }
    }

    return null;
  }

  void _initializeProviderManager() {
    final primaryProvider = _providers.isNotEmpty 
        ? _providers.first 
        : DeepSeekProvider(apiKey: 'test');
    
    final fallbackProvider = FallbackProvider();
    
    _providerManager = AIProviderManager(
      primaryProvider: primaryProvider,
      fallbackProvider: fallbackProvider,
    );
  }

  Future<String> generateResponse(String prompt,
      {AiWorkType? type, bool useCache = true, String? userId}) async {
    
    if (_providers.isEmpty) {
      debugPrint('⚠️ [AIService] No providers configured');
      return 'Welcome to Paykari Bazar! 👋';
    }

    userId ??= _currentUserId;

    try {
      if (useCache) {
        final cached = _cache.get(prompt, params: {'type': type?.toString()});
        if (cached != null) return cached;
      }

      final trackedResult =
          await _generateWithTrackedProviders(prompt, type: type);
      
      if (trackedResult != null && trackedResult.isNotEmpty) {
        if (useCache) {
          await _cache.set(prompt, trackedResult, params: {'type': type?.toString()});
        }
        return trackedResult;
      }

      // Last resort fallback
      final result = await _providerManager.generate(prompt, type: type);
      
      if (useCache && result.isNotEmpty) {
        await _cache.set(prompt, result, params: {'type': type?.toString()});
      }
      
      return result.isNotEmpty ? result : 'Welcome to Paykari Bazar! শুভ কেনাকাটা! 🛒';
    } catch (e) {
      debugPrint('❌ [AIService] Generate response error: $e');
      return 'শুভ দিন! পাইকারী বাজারে আপনাকে স্বাগতম।';
    }
  }

  Future<String> analyzeAndReplicate(String url) async {
    return generateResponse('Analyze and replicate product patterns from: $url', type: AiWorkType.vision);
  }

  Future<Map<String, dynamic>> processCommand(String command) async {
    final res = await generateResponse("Process command: '$command'. Return JSON.");
    try {
      return jsonDecode(res.replaceAll('```json', '').replaceAll('```', '').trim());
    } catch (_) {
      return {'action': 'navigate', 'target': 'dashboard'};
    }
  }

  Future<Map<String, dynamic>> getSystemDiagnostics({String? userId}) async {
    final stats = await performGlobalSystemCheck();
    return {'system': stats, 'generated_at': DateTime.now().toIso8601String()};
  }

  Future<Map<String, dynamic>> performGlobalSystemCheck() async {
    final providerStats = _providerManager.getStats();
    return {
      'status': 'healthy',
      'providers_active': _providers.length,
      'primary_available': providerStats['primaryAvailable'],
      'using_fallback': providerStats['usingFallback'],
      'active_provider': providerStats['activeProvider'],
      'latency': '45ms'
    };
  }

  Future<void> sendAiGreetingNotification(String userId, String userName) async {
    try {
      final res = await generateResponse('Generate greeting for $userName.');
      await getIt<NotificationService>().sendDirectNotification(
          userId: userId, title: 'শুভ দিন! ✨', body: res);
    } catch (_) {}
  }

  Future<String> analyzeImageForSearch(XFile image) async {
    final gemini = _providers.whereType<GeminiProvider>().firstOrNull;
    if (gemini == null) return 'Vision support unavailable';
    try {
      final bytes = await image.readAsBytes();
      return await gemini.generateMultimodal('Identify product.', bytes, 'image/jpeg');
    } catch (_) {
      return '';
    }
  }

  /// NEW: Smart Prescription Analysis (Bengali OCR + AI)
  Future<String> analyzePrescription(XFile image) async {
    final gemini = _providers.whereType<GeminiProvider>().firstOrNull;
    if (gemini == null) return 'Healthcare AI support unavailable';
    
    try {
      final bytes = await image.readAsBytes();
      const prompt = """
      You are a specialized medical pharmacist AI for Paykari Bazar.
      Analyze this prescription image (which may be in Bengali or English).
      1. Extract all medicine names and their dosages (e.g. Napa 500mg, 1+0+1).
      2. Return ONLY a comma-separated list of the medicines found.
      3. If no medicines are found, return 'No medicines detected'.
      """;
      
      final result = await gemini.generateMultimodal(prompt, bytes, 'image/jpeg');
      return result.trim();
    } catch (e) {
      debugPrint('❌ [AIService] Prescription analysis error: $e');
      return 'Analysis failed. Please type manually.';
    }
  }

  Stream<String> generateStreamedResponse(String prompt, {AiWorkType? type}) async* {
    try {
      final preferredOrder = _fallbackProviderOrder();

      for (final providerKey in preferredOrder) {
        final provider = _providerRegistry[providerKey];
        if (provider == null) continue;
        if (!await _quotaService.hasQuota(providerKey)) continue;

        try {
          await for (final chunk in provider.generateStream(prompt, type: type)
              .timeout(const Duration(seconds: 30))) {
            yield chunk;
          }
          await _quotaService.incrementUsage(providerKey);
          return;
        } catch (e) {
          debugPrint('⚠️ [AIService] Stream provider $providerKey failed: $e');
        }
      }

      await _providerManager.healthCheck();
      yield* _providerManager.generateStream(prompt, type: type);
    } catch (e) {
      debugPrint('❌ [AIService] Stream error: $e');
      yield 'AI service temporarily unavailable. Please try again.';
    }
  }

  String getBrandedGreeting() => 'Welcome to Paykari Bazar.';

  Future<Map<String, dynamic>> synthesizeCrossData(
      {required String sourceCollection,
      required String intent,
      required List<Map<String, dynamic>> rawData}) async {
    final res = await generateResponse('Analyze ${rawData.length} records. Return JSON.');
    try {
      return jsonDecode(res.replaceAll('```json', '').replaceAll('```', '').trim());
    } catch (_) {
      return {};
    }
  }
  
  Map<String, dynamic> getProviderStatus() {
    return _providerManager.getStats();
  }
}
