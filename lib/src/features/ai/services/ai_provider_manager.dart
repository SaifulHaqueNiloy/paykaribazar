import 'package:flutter/material.dart';
import 'ai_provider.dart';
import '../domain/ai_work_type.dart';

/// Manages AI providers with automatic failover
/// Tries primary provider first, falls back to secondary if primary fails
class AIProviderManager {
  final AIProvider _primaryProvider;
  final AIProvider _fallbackProvider;
  
  late bool _primaryAvailable;
  late bool _useFallback;

  AIProviderManager({
    required AIProvider primaryProvider,
    required AIProvider fallbackProvider,
  })  : _primaryProvider = primaryProvider,
        _fallbackProvider = fallbackProvider {
    _primaryAvailable = true;
    _useFallback = false;
  }

  /// Get current active provider name
  String get activeProviderName => _useFallback 
      ? '${_fallbackProvider.name} (Fallback)' 
      : _primaryProvider.name;

  /// Get primary provider status
  bool get isPrimaryAvailable => _primaryAvailable;

  /// Check if currently using fallback
  bool get isUsingFallback => _useFallback;

  /// Perform health check on all providers
  Future<void> healthCheck() async {
    try {
      debugPrint('🏥 [AIProviderManager] Running health check on all providers...');
      
      _primaryAvailable = await _primaryProvider.healthCheck();
      final fallbackAvailable = await _fallbackProvider.healthCheck();
      
      if (_primaryAvailable) {
        _useFallback = false;
        debugPrint('✅ [AIProviderManager] Primary provider (${_primaryProvider.name}) is healthy');
      } else if (fallbackAvailable) {
        _useFallback = true;
        debugPrint('⚠️ [AIProviderManager] Primary provider down, switching to ${_fallbackProvider.name}');
      } else {
        debugPrint('❌ [AIProviderManager] All providers are down!');
      }
    } catch (e) {
      debugPrint('❌ [AIProviderManager] Health check error: $e');
      _primaryAvailable = false;
      _useFallback = true;
    }
  }

  /// Generate response with automatic failover
  Future<String> generate(String prompt, {AiWorkType? type}) async {
    try {
      // Try primary provider first
      if (!_useFallback && _primaryAvailable) {
        try {
          debugPrint('🚀 [AIProviderManager] Using primary provider: ${_primaryProvider.name}');
          final response = await _primaryProvider
              .generate(prompt, type: type)
              .timeout(const Duration(seconds: 30));
          
          if (response.isNotEmpty && !response.contains('Error')) {
            debugPrint('✅ [AIProviderManager] Primary provider succeeded');
            return response;
          }
        } catch (primaryError) {
          debugPrint('⚠️ [AIProviderManager] Primary provider failed: $primaryError');
          debugPrint('🔄 [AIProviderManager] Switching to fallback provider...');
          _primaryAvailable = false;
          _useFallback = true;
        }
      }

      // Use fallback provider
      debugPrint('🔄 [AIProviderManager] Using fallback provider: ${_fallbackProvider.name}');
      final response = await _fallbackProvider
          .generate(prompt, type: type)
          .timeout(const Duration(seconds: 10));
      
      debugPrint('✅ [AIProviderManager] Fallback provider succeeded');
      return response;
    } catch (e) {
      debugPrint('❌ [AIProviderManager] Both providers failed: $e');
      return 'AI service temporarily unavailable. Please try again later. Error: ${e.toString()}';
    }
  }

  /// Generate stream response with automatic failover
  Stream<String> generateStream(String prompt, {AiWorkType? type}) async* {
    try {
      // Try primary provider first
      if (!_useFallback && _primaryAvailable) {
        try {
          debugPrint('🚀 [AIProviderManager] Streaming from primary: ${_primaryProvider.name}');
          yield* _primaryProvider.generateStream(prompt, type: type)
              .timeout(const Duration(seconds: 30));
          debugPrint('✅ [AIProviderManager] Primary stream succeeded');
          return;
        } catch (primaryError) {
          debugPrint('⚠️ [AIProviderManager] Primary stream failed: $primaryError');
          debugPrint('🔄 [AIProviderManager] Switching to fallback stream...');
          _primaryAvailable = false;
          _useFallback = true;
        }
      }

      // Use fallback provider
      debugPrint('🚀 [AIProviderManager] Streaming from fallback: ${_fallbackProvider.name}');
      yield* _fallbackProvider.generateStream(prompt, type: type)
          .timeout(const Duration(seconds: 10));
      debugPrint('✅ [AIProviderManager] Fallback stream succeeded');
    } catch (e) {
      debugPrint('❌ [AIProviderManager] Stream failed: $e');
      yield 'AI service temporarily unavailable. Please try again later.';
    }
  }

  /// Reset provider status and retry with primary
  Future<void> resetProviders() async {
    debugPrint('🔄 [AIProviderManager] Resetting provider status...');
    _primaryAvailable = true;
    _useFallback = false;
    await healthCheck();
  }

  /// Get provider statistics
  Map<String, dynamic> getStats() {
    return {
      'primaryProvider': _primaryProvider.name,
      'fallbackProvider': _fallbackProvider.name,
      'activeProvider': activeProviderName,
      'primaryAvailable': _primaryAvailable,
      'usingFallback': _useFallback,
    };
  }
}
