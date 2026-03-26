import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/ai_config.dart';

/// Service for managing rate limiting and quota
class AIRateLimiter {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final Map<String, List<DateTime>> _localRequestTimes = {};

  /// Check if request is allowed
  Future<bool> canMakeRequest(String userId) async {
    try {
      // Local rate limiting first (fast)
      if (!_canMakeLocalRequest(userId)) {
        return false;
      }

      // Check daily quota in Firestore
      return await _checkDailyQuota(userId);
    } catch (e) {
      // Fail open - allow request if quota check fails
      return true;
    }
  }

  /// Local rate limiting (in-memory)
  bool _canMakeLocalRequest(String userId) {
    final now = DateTime.now();
    final windowStart = now.subtract(AIConfig.rateLimitWindow);

    // Initialize or clean old entries
    _localRequestTimes[userId] ??= [];
    _localRequestTimes[userId]!
        .removeWhere((time) => time.isBefore(windowStart));

    // Check limit
    if (_localRequestTimes[userId]!.length >= AIConfig.requestsPerMinute) {
      return false;
    }

    _localRequestTimes[userId]!.add(now);
    return true;
  }

  /// Check daily quota in Firestore
  Future<bool> _checkDailyQuota(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final statsRef = _db.collection('ai_stats').doc('daily_$today');
      final doc = await statsRef.get();

      final data = doc.data() ?? {};
      final usedCount = (data['requests'] as int?) ?? 0;

      return usedCount < AIConfig.dailyQuotaLimit;
    } catch (e) {
      return true; // Fail open
    }
  }

  /// Record successful request
  Future<void> recordRequest(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final statsRef = _db.collection('ai_stats').doc('daily_$today');

      await statsRef.set(
        {
          'requests': FieldValue.increment(1),
          'date': today,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // User-level tracking
      await _db.collection('users').doc(userId).update({
        'ai_requests_today': FieldValue.increment(1),
        'last_ai_request': FieldValue.serverTimestamp(),
      }).catchError((_) => null); // Fail silently if user doc doesn't exist
    } catch (e) {
      // Request recording error handled silently
    }
  }

  /// Get remaining quota for user
  Future<int> getRemainingQuota(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final statsRef = _db.collection('ai_stats').doc('daily_$today');
      final doc = await statsRef.get();

      final data = doc.data() ?? {};
      final usedCount = (data['requests'] as int?) ?? 0;

      return (AIConfig.dailyQuotaLimit - usedCount)
          .clamp(0, AIConfig.dailyQuotaLimit);
    } catch (e) {
      debugPrint('Error getting remaining quota: $e');
      return AIConfig.dailyQuotaLimit; // Return max if error
    }
  }

  /// Get retry delay with exponential backoff
  Duration getRetryDelay(int attemptNumber) {
    return AIConfig.initialRetryDelay *
        (AIConfig.retryBackoffMultiplier).toInt().pow(attemptNumber);
  }

  /// Reset local rate limiter
  void reset() {
    _localRequestTimes.clear();
  }

  /// Get current rate limit status
  Map<String, dynamic> getStatus(String userId) {
    final requests = _localRequestTimes[userId]?.length ?? 0;
    return {
      'local_requests_this_minute': requests,
      'limit_per_minute': AIConfig.requestsPerMinute,
      'usage_percent':
          (requests / AIConfig.requestsPerMinute * 100).toStringAsFixed(2),
      'is_limited': requests >= AIConfig.requestsPerMinute,
    };
  }
}

extension on int {
  int pow(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}
