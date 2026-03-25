import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/ai_config.dart';

/// Service for adjusting AI system configuration at runtime
class AIConfigurationManager {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _configDoc = 'settings/ai_config';

  /// Get current override configuration
  Future<AIConfigOverrides> getCurrentOverrides() async {
    try {
      final doc = await _db.doc(_configDoc).get();
      if (doc.exists) {
        return AIConfigOverrides.fromFirestore(doc.data()!);
      }
      return AIConfigOverrides.defaults();
    } catch (e) {
      return AIConfigOverrides.defaults();
    }
  }

  /// Update rate limits
  Future<void> updateRateLimit({
    required int requestsPerMinute,
    required int dailyQuotaLimit,
  }) async {
    try {
      await _db.doc(_configDoc).set({
        'rate_limit': {
          'requests_per_minute': requestsPerMinute,
          'daily_quota_limit': dailyQuotaLimit,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update rate limit: $e');
    }
  }

  /// Update cache settings
  Future<void> updateCacheConfig({
    required int maxEntries,
    required int cacheDurationHours,
  }) async {
    try {
      await _db.doc(_configDoc).set({
        'cache': {
          'max_entries': maxEntries,
          'duration_hours': cacheDurationHours,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update cache config: $e');
    }
  }

  /// Update retry settings
  Future<void> updateRetryConfig({
    required int maxRetries,
    required int initialDelayMs,
    required double backoffMultiplier,
  }) async {
    try {
      await _db.doc(_configDoc).set({
        'retry': {
          'max_retries': maxRetries,
          'initial_delay_ms': initialDelayMs,
          'backoff_multiplier': backoffMultiplier,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update retry config: $e');
    }
  }

  /// Update timeout settings
  Future<void> updateTimeoutConfig({
    required int requestTimeoutSeconds,
    required int streamTimeoutSeconds,
  }) async {
    try {
      await _db.doc(_configDoc).set({
        'timeout': {
          'request_timeout_seconds': requestTimeoutSeconds,
          'stream_timeout_seconds': streamTimeoutSeconds,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update timeout config: $e');
    }
  }

  /// Update model settings
  Future<void> updateModelConfig({
    required String primaryModel,
    required String fallbackModel,
  }) async {
    try {
      await _db.doc(_configDoc).set({
        'model': {
          'primary': primaryModel,
          'fallback': fallbackModel,
        },
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update model config: $e');
    }
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    try {
      await _db.doc(_configDoc).delete();
    } catch (e) {
      throw Exception('Failed to reset config: $e');
    }
  }

  /// Get configuration change history
  Future<List<ConfigChangeRecord>> getConfigChangeHistory(
      {int limit = 50}) async {
    try {
      final snapshot = await _db
          .collection('ai_config_history')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ConfigChangeRecord.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Log configuration change
  Future<void> logConfigChange({
    required String changeType,
    required Map<String, dynamic> oldValues,
    required Map<String, dynamic> newValues,
    required String changedBy,
    String? reason,
  }) async {
    try {
      await _db.collection('ai_config_history').add({
        'timestamp': FieldValue.serverTimestamp(),
        'change_type': changeType,
        'old_values': oldValues,
        'new_values': newValues,
        'changed_by': changedBy,
        'reason': reason,
      });
    } catch (e) {
      // Silently fail
    }
  }
}

/// Configuration overrides from Firestore
class AIConfigOverrides {
  final int? requestsPerMinute;
  final int? dailyQuotaLimit;
  final int? maxCacheEntries;
  final int? cacheDurationHours;
  final int? maxRetries;
  final int? initialRetryDelayMs;
  final double? backoffMultiplier;
  final int? requestTimeoutSeconds;
  final int? streamTimeoutSeconds;
  final String? primaryModel;
  final String? fallbackModel;
  final DateTime? updatedAt;

  AIConfigOverrides({
    this.requestsPerMinute,
    this.dailyQuotaLimit,
    this.maxCacheEntries,
    this.cacheDurationHours,
    this.maxRetries,
    this.initialRetryDelayMs,
    this.backoffMultiplier,
    this.requestTimeoutSeconds,
    this.streamTimeoutSeconds,
    this.primaryModel,
    this.fallbackModel,
    this.updatedAt,
  });

  factory AIConfigOverrides.defaults() {
    return AIConfigOverrides();
  }

  factory AIConfigOverrides.fromFirestore(Map<String, dynamic> data) {
    return AIConfigOverrides(
      requestsPerMinute: (data['rate_limit']?['requests_per_minute'] as int?),
      dailyQuotaLimit: (data['rate_limit']?['daily_quota_limit'] as int?),
      maxCacheEntries: (data['cache']?['max_entries'] as int?),
      cacheDurationHours: (data['cache']?['duration_hours'] as int?),
      maxRetries: (data['retry']?['max_retries'] as int?),
      initialRetryDelayMs: (data['retry']?['initial_delay_ms'] as int?),
      backoffMultiplier:
          (data['retry']?['backoff_multiplier'] as num?)?.toDouble(),
      requestTimeoutSeconds:
          (data['timeout']?['request_timeout_seconds'] as int?),
      streamTimeoutSeconds:
          (data['timeout']?['stream_timeout_seconds'] as int?),
      primaryModel: (data['model']?['primary'] as String?),
      fallbackModel: (data['model']?['fallback'] as String?),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  // Apply overrides to get effective configuration
  AIEffectiveConfig getEffectiveConfig() {
    return AIEffectiveConfig(
      requestsPerMinute: requestsPerMinute ?? AIConfig.requestsPerMinute,
      dailyQuotaLimit: dailyQuotaLimit ?? AIConfig.dailyQuotaLimit,
      maxCacheEntries: maxCacheEntries ?? AIConfig.maxCacheSize,
      cacheDurationHours: cacheDurationHours ?? AIConfig.cacheDuration.inHours,
      maxRetries: maxRetries ?? AIConfig.maxRetries,
      initialRetryDelayMs:
          initialRetryDelayMs ?? AIConfig.initialRetryDelay.inMilliseconds,
      backoffMultiplier: backoffMultiplier ?? AIConfig.retryBackoffMultiplier,
      requestTimeoutSeconds:
          requestTimeoutSeconds ?? AIConfig.requestTimeout.inSeconds,
      streamTimeoutSeconds:
          streamTimeoutSeconds ?? AIConfig.streamTimeout.inSeconds,
      primaryModel: primaryModel ?? AIConfig.primaryModel,
      fallbackModel: fallbackModel ?? AIConfig.fallbackModel,
    );
  }
}

/// Effective configuration (overrides applied)
class AIEffectiveConfig {
  final int requestsPerMinute;
  final int dailyQuotaLimit;
  final int maxCacheEntries;
  final int cacheDurationHours;
  final int maxRetries;
  final int initialRetryDelayMs;
  final double backoffMultiplier;
  final int requestTimeoutSeconds;
  final int streamTimeoutSeconds;
  final String primaryModel;
  final String fallbackModel;

  AIEffectiveConfig({
    required this.requestsPerMinute,
    required this.dailyQuotaLimit,
    required this.maxCacheEntries,
    required this.cacheDurationHours,
    required this.maxRetries,
    required this.initialRetryDelayMs,
    required this.backoffMultiplier,
    required this.requestTimeoutSeconds,
    required this.streamTimeoutSeconds,
    required this.primaryModel,
    required this.fallbackModel,
  });
}

/// Configuration change record
class ConfigChangeRecord {
  final DateTime timestamp;
  final String changeType;
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;
  final String changedBy;
  final String? reason;

  ConfigChangeRecord({
    required this.timestamp,
    required this.changeType,
    required this.oldValues,
    required this.newValues,
    required this.changedBy,
    this.reason,
  });

  factory ConfigChangeRecord.fromFirestore(Map<String, dynamic> data) {
    return ConfigChangeRecord(
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      changeType: (data['change_type'] as String?) ?? 'unknown',
      oldValues: (data['old_values'] as Map<String, dynamic>?) ?? {},
      newValues: (data['new_values'] as Map<String, dynamic>?) ?? {},
      changedBy: (data['changed_by'] as String?) ?? 'unknown',
      reason: data['reason'] as String?,
    );
  }

  String get summary {
    return '$changeType - Changed by $changedBy at ${timestamp.toLocal()}';
  }
}
