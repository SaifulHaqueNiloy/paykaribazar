import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/ai_config.dart';

/// Service for caching AI responses to reduce API calls
class AICacheService {
  static const String _cacheName = 'ai_response_cache';
  late final Box<String> _cacheBox;

  Future<void> initialize() async {
    try {
      if (!Hive.isBoxOpen(_cacheName)) {
        _cacheBox = await Hive.openBox<String>(_cacheName);
      } else {
        _cacheBox = Hive.box<String>(_cacheName);
      }
      _cleanupExpiredCache();
    } catch (e) {
      // Silently fail if cache initialization fails
    }
  }

  /// Generate cache key from prompt and parameters
  String _generateCacheKey(String prompt, {Map<String, dynamic>? params}) {
    final combined = '$prompt${jsonEncode(params ?? {})}';
    return md5.convert(utf8.encode(combined)).toString();
  }

  /// Get cached response if exists and not expired
  String? get(String prompt, {Map<String, dynamic>? params}) {
    try {
      if (!_cacheBox.isOpen) return null;

      final key = _generateCacheKey(prompt, params: params);
      final cached = _cacheBox.get(key);

      if (cached == null) return null;

      try {
        final data = jsonDecode(cached);
        final timestamp = DateTime.parse(data['timestamp']);
        final difference = DateTime.now().difference(timestamp);

        if (difference > AIConfig.cacheDuration) {
          _cacheBox.delete(key);
          return null;
        }

        return data['response'];
      } catch (e) {
        _cacheBox.delete(key);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Cache a response
  Future<void> set(String prompt, String response,
      {Map<String, dynamic>? params}) async {
    try {
      if (!_cacheBox.isOpen) return;

      if (_cacheBox.length >= AIConfig.maxCacheSize) {
        await _pruneOldestEntries();
      }

      final key = _generateCacheKey(prompt, params: params);
      final data = {
        'response': response,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _cacheBox.put(key, jsonEncode(data));
    } catch (e) {
      // Silently fail if set operation fails
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    try {
      if (_cacheBox.isOpen) {
        await _cacheBox.clear();
      }
    } catch (e) {
      // Silently fail if clear operation fails
    }
  }

  /// Cleanup expired entries
  Future<void> _cleanupExpiredCache() async {
    try {
      if (!_cacheBox.isOpen) return;

      final keysToDelete = <String>[];

      for (final key in _cacheBox.keys) {
        final cached = _cacheBox.get(key);
        if (cached == null) continue;

        try {
          final data = jsonDecode(cached);
          final timestamp = DateTime.parse(data['timestamp']);
          final difference = DateTime.now().difference(timestamp);

          if (difference > AIConfig.cacheDuration) {
            keysToDelete.add(key);
          }
        } catch (e) {
          keysToDelete.add(key);
        }
      }

      for (final key in keysToDelete) {
        await _cacheBox.delete(key);
      }
    } catch (e) {
      // Silently fail if cleanup fails
    }
  }

  /// Remove oldest entries when cache is full
  Future<void> _pruneOldestEntries() async {
    try {
      if (!_cacheBox.isOpen) {
        return;
      }

      final entries = <String, DateTime>{};

      for (final key in _cacheBox.keys) {
        final cached = _cacheBox.get(key);
        if (cached == null) continue;

        try {
          final data = jsonDecode(cached);
          final timestamp = DateTime.parse(data['timestamp']);
          entries[key] = timestamp;
        } catch (e) {
          // Skip malformed entries
        }
      }

      // Sort by timestamp and remove oldest 20%
      final sortedKeys = entries.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      final toRemove = (sortedKeys.length * 0.2).toInt();
      for (int i = 0; i < toRemove && i < sortedKeys.length; i++) {
        await _cacheBox.delete(sortedKeys[i].key);
      }
    } catch (e) {
      // Silently fail if pruning fails
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    try {
      if (!_cacheBox.isOpen) {
        return {'cached_entries': 0, 'status': 'unavailable'};
      }

      return {
        'cached_entries': _cacheBox.length,
        'max_entries': AIConfig.maxCacheSize,
        'usage_percent':
            (_cacheBox.length / AIConfig.maxCacheSize * 100).toStringAsFixed(2),
        'status': 'active',
      };
    } catch (e) {
      return {'cached_entries': 0, 'status': 'error', 'error': '$e'};
    }
  }
}
