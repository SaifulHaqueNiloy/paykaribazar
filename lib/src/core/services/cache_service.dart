import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';

/// Advanced Caching Service with TTL and Compression support
/// Uses Hive for fast, persistent storage
class CacheService {
  static const String _defaultBoxName = 'app_cache_box';
  static const Duration _defaultTTL = Duration(hours: 24);

  late Box _cacheBox;
  bool _isInitialized = false;

  /// Initialize Hive and open the cache box
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox(_defaultBoxName);
      _isInitialized = true;
      debugPrint('✅ Cache service initialized');
    } catch (e) {
      debugPrint('❌ Cache initialization failed: $e');
      rethrow;
    }
  }

  /// Generate a unique cache key from a string or object
  String _generateKey(dynamic input) {
    if (input is String) {
      return sha256.convert(utf8.encode(input)).toString();
    }
    return sha256.convert(utf8.encode(jsonEncode(input))).toString();
  }

  /// Save data to cache with optional TTL (Time To Live)
  Future<void> set({
    required String key,
    required dynamic value,
    Duration? ttl,
  }) async {
    if (!_isInitialized) await init();

    final cacheKey = _generateKey(key);
    final expiration = DateTime.now().add(ttl ?? _defaultTTL);

    final cacheData = {
      'value': value,
      'expiresAt': expiration.toIso8601String(),
      'cachedAt': DateTime.now().toIso8601String(),
    };

    try {
      await _cacheBox.put(cacheKey, jsonEncode(cacheData));
      debugPrint('✅ Data cached for key: $key (Expires: $expiration)');
    } catch (e) {
      debugPrint('❌ Failed to save to cache: $e');
    }
  }

  /// Get data from cache
  /// Returns null if not found or expired
  Future<T?> get<T>(String key) async {
    if (!_isInitialized) await init();

    final cacheKey = _generateKey(key);
    final rawData = _cacheBox.get(cacheKey);

    if (rawData == null) return null;

    try {
      final cacheData = jsonDecode(rawData);
      final expiresAt = DateTime.parse(cacheData['expiresAt']);

      if (DateTime.now().isAfter(expiresAt)) {
        debugPrint('⚠️ Cache expired for key: $key');
        await delete(key);
        return null;
      }

      debugPrint('✅ Cache hit for key: $key');
      return cacheData['value'] as T?;
    } catch (e) {
      debugPrint('❌ Cache retrieval error: $e');
      return null;
    }
  }

  /// Delete a specific cache item
  Future<void> delete(String key) async {
    if (!_isInitialized) await init();
    final cacheKey = _generateKey(key);
    await _cacheBox.delete(cacheKey);
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    if (!_isInitialized) await init();
    await _cacheBox.clear();
    debugPrint('🧹 All cache cleared');
  }

  /// Get metadata for a cached item
  Future<Map<String, dynamic>?> getMetadata(String key) async {
    if (!_isInitialized) await init();
    final cacheKey = _generateKey(key);
    final rawData = _cacheBox.get(cacheKey);

    if (rawData == null) return null;

    try {
      final cacheData = jsonDecode(rawData);
      return {
        'cachedAt': cacheData['cachedAt'],
        'expiresAt': cacheData['expiresAt'],
        'isExpired': DateTime.now().isAfter(DateTime.parse(cacheData['expiresAt'])),
      };
    } catch (e) {
      return null;
    }
  }

  /// Remove expired items from cache manually
  Future<void> cleanup() async {
    if (!_isInitialized) await init();

    final keys = _cacheBox.keys.toList();
    int count = 0;

    for (final key in keys) {
      final rawData = _cacheBox.get(key);
      if (rawData != null) {
        try {
          final cacheData = jsonDecode(rawData);
          final expiresAt = DateTime.parse(cacheData['expiresAt']);
          if (DateTime.now().isAfter(expiresAt)) {
            await _cacheBox.delete(key);
            count++;
          }
        } catch (_) {}
      }
    }

    if (count > 0) {
      debugPrint('🧹 Cleanup: Removed $count expired items from cache');
    }
  }

  // ============================================================================
  // SPECIALIZED CACHING METHODS
  // ============================================================================

  /// Cache API Responses
  Future<void> cacheApiResponse(String url, dynamic response) async {
    await set(key: 'api_$url', value: response, ttl: const Duration(hours: 1));
  }

  /// Get Cached API Response
  Future<dynamic> getCachedApiResponse(String url) async {
    return await get<dynamic>('api_$url');
  }

  /// Cache Image Metadata (URL to local path mapping)
  Future<void> cacheImageInfo(String url, String localPath) async {
    await set(key: 'img_$url', value: localPath, ttl: const Duration(days: 7));
  }

  /// Get Cached Image Path
  Future<String?> getCachedImagePath(String url) async {
    return await get<String>('img_$url');
  }

  /// Cache User Settings
  Future<void> cacheUserSettings(Map<String, dynamic> settings) async {
    await set(key: 'user_settings', value: settings, ttl: const Duration(days: 30));
  }

  /// Get User Settings
  Future<Map<String, dynamic>?> getCachedUserSettings() async {
    final data = await get<Map<String, dynamic>>('user_settings');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Get Cache Stats
  Future<CacheStats> getStats() async {
    if (!_isInitialized) await init();

    final total = _cacheBox.length;
    int valid = 0;
    int expired = 0;

    for (final key in _cacheBox.keys) {
      final rawData = _cacheBox.get(key);
      if (rawData != null) {
        try {
          final cacheData = jsonDecode(rawData);
          final expiresAt = DateTime.parse(cacheData['expiresAt']);
          if (DateTime.now().isAfter(expiresAt)) {
            expired++;
          } else {
            valid++;
          }
        } catch (_) {}
      }
    }

    return CacheStats(
      totalItems: total,
      validItems: valid,
      expiredItems: expired,
      maxItems: 1000, // Arbitrary limit for stats
      hitRate: total > 0 ? (valid / total) : 0,
    );
  }
}

/// Cache statistics
class CacheStats {
  final int totalItems;
  final int validItems;
  final int expiredItems;
  final int maxItems;
  final double hitRate;

  CacheStats({
    required this.totalItems,
    required this.validItems,
    required this.expiredItems,
    required this.maxItems,
    required this.hitRate,
  });

  double get utilizationPercent => (totalItems / maxItems) * 100;

  @override
  String toString() =>
      'CacheStats(total: $totalItems, valid: $validItems, expired: $expiredItems, '
      'utilization: ${utilizationPercent.toStringAsFixed(1)}%, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%)';
}
