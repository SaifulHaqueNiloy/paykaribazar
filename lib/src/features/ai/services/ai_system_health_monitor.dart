import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_service.dart';
import '../config/ai_config.dart';

/// Real-time health monitoring service for AI systems
class AISystemHealthMonitor {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AIService _aiService;

  AISystemHealthMonitor({required AIService aiService})
      : _aiService = aiService;

  /// Get current system health snapshot
  Future<AISystemHealth> getCurrentHealth({String? userId}) async {
    try {
      final diagnostics = await _aiService.getSystemDiagnostics(userId: userId);

      return AISystemHealth(
        timestamp: DateTime.now(),
        cacheHitRate: _extractDouble(
          diagnostics['system']['cache']['usage_percent'] ?? '0',
        ),
        remainingQuota:
            (diagnostics['system']['quota']['remaining'] as int?) ?? 0,
        dailyQuotaLimit: AIConfig.dailyQuotaLimit,
        requestsPerMinute: (diagnostics['system']['rate_limit']
                ['local_requests_this_minute'] as int?) ??
            0,
        averageResponseTimeMs: _extractDouble(
          diagnostics['system']['requests']['average_duration_ms'] ?? '0',
        ),
        totalRequests:
            (diagnostics['system']['requests']['total'] as int?) ?? 0,
        cachedRequests:
            (diagnostics['system']['requests']['cached'] as int?) ?? 0,
        totalErrors24h:
            (diagnostics['system']['errors']['total_24h'] as int?) ?? 0,
        systemStatus: (diagnostics['system']['status'] as String?) ?? 'unknown',
        neuraiLoad:
            _extractDouble(diagnostics['system']['neural_load'] ?? '0%'),
        durationMs: (diagnostics['system']['duration_ms'] as int?) ?? 0,
      );
    } catch (e) {
      return AISystemHealth(
        timestamp: DateTime.now(),
        cacheHitRate: 0,
        remainingQuota: 0,
        dailyQuotaLimit: AIConfig.dailyQuotaLimit,
        requestsPerMinute: 0,
        averageResponseTimeMs: 0,
        totalRequests: 0,
        cachedRequests: 0,
        totalErrors24h: 0,
        systemStatus: 'error',
        neuraiLoad: 0,
        durationMs: 0,
        error: e.toString(),
      );
    }
  }

  /// Stream real-time health metrics
  Stream<AISystemHealth> streamHealth(
      {String? userId,
      Duration updateInterval = const Duration(seconds: 10)}) async* {
    while (true) {
      final health = await getCurrentHealth(userId: userId);
      yield health;
      await Future.delayed(updateInterval);
    }
  }

  /// Get health history from last N hours
  Future<List<AISystemHealth>> getHealthHistory({int hours = 24}) async {
    try {
      final startTime = DateTime.now().subtract(Duration(hours: hours));

      final snapshot = await _db
          .collection('ai_health_logs')
          .where('timestamp', isGreaterThanOrEqualTo: startTime)
          .orderBy('timestamp', descending: true)
          .limit(1000)
          .get();

      return snapshot.docs
          .map((doc) => AISystemHealth.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Log health snapshot to Firestore for historical tracking
  Future<void> logHealthSnapshot(AISystemHealth health) async {
    try {
      await _db.collection('ai_health_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'cache_hit_rate': health.cacheHitRate,
        'remaining_quota': health.remainingQuota,
        'requests_per_minute': health.requestsPerMinute,
        'average_response_time_ms': health.averageResponseTimeMs,
        'total_requests': health.totalRequests,
        'cached_requests': health.cachedRequests,
        'total_errors_24h': health.totalErrors24h,
        'system_status': health.systemStatus,
        'neural_load': health.neuraiLoad,
      });
    } catch (e) {
      // Silently fail
    }
  }

  /// Get health trends
  Future<AIHealthTrends> getHealthTrends({int hours = 24}) async {
    try {
      final history = await getHealthHistory(hours: hours);

      if (history.isEmpty) {
        return AIHealthTrends(
          averageCacheHitRate: 0,
          peakRequestsPerMinute: 0,
          averageResponseTime: 0,
          totalErrorsInPeriod: 0,
          uptimePercent: 100,
          quotaUsagePercent: 0,
        );
      }

      double totalCacheHitRate = 0;
      int maxRequestsPerMinute = 0;
      double totalResponseTime = 0;
      int totalErrors = 0;
      int healthyReadings = 0;
      int quotaUsedTotal = 0;

      for (final health in history) {
        totalCacheHitRate += health.cacheHitRate;
        maxRequestsPerMinute = maxRequestsPerMinute > health.requestsPerMinute
            ? maxRequestsPerMinute
            : health.requestsPerMinute;
        totalResponseTime += health.averageResponseTimeMs;
        totalErrors += health.totalErrors24h;
        if (health.systemStatus == 'healthy') {
          healthyReadings++;
        }
        quotaUsedTotal += (AIConfig.dailyQuotaLimit - health.remainingQuota);
      }

      return AIHealthTrends(
        averageCacheHitRate: totalCacheHitRate / history.length,
        peakRequestsPerMinute: maxRequestsPerMinute,
        averageResponseTime: totalResponseTime / history.length,
        totalErrorsInPeriod: totalErrors,
        uptimePercent: (healthyReadings / history.length) * 100,
        quotaUsagePercent:
            (quotaUsedTotal / history.length / AIConfig.dailyQuotaLimit) * 100,
      );
    } catch (e) {
      return AIHealthTrends(
        averageCacheHitRate: 0,
        peakRequestsPerMinute: 0,
        averageResponseTime: 0,
        totalErrorsInPeriod: 0,
        uptimePercent: 0,
        quotaUsagePercent: 0,
      );
    }
  }

  /// Get alerts based on current health
  List<AIHealthAlert> getAlerts(AISystemHealth health) {
    final alerts = <AIHealthAlert>[];

    // Quota alerts
    final quotaUsagePercent =
        ((AIConfig.dailyQuotaLimit - health.remainingQuota) /
                AIConfig.dailyQuotaLimit) *
            100;

    if (quotaUsagePercent >= 90) {
      alerts.add(AIHealthAlert(
        severity: AlertSeverity.critical,
        title: 'Critical: 90% Daily Quota Used',
        message: 'Only ${health.remainingQuota} requests remaining today',
        timestamp: DateTime.now(),
      ));
    } else if (quotaUsagePercent >= 80) {
      alerts.add(AIHealthAlert(
        severity: AlertSeverity.warning,
        title: 'Warning: 80% Daily Quota Used',
        message: '${health.remainingQuota} requests remaining today',
        timestamp: DateTime.now(),
      ));
    }

    // Rate limit alerts
    if (health.requestsPerMinute >= AIConfig.requestsPerMinute) {
      alerts.add(AIHealthAlert(
        severity: AlertSeverity.warning,
        title: 'Rate Limit Reached',
        message:
            'Per-minute rate limit (${AIConfig.requestsPerMinute}) reached',
        timestamp: DateTime.now(),
      ));
    }

    // Response time alerts
    if (health.averageResponseTimeMs > 5000) {
      alerts.add(AIHealthAlert(
        severity: AlertSeverity.warning,
        title: 'Slow Response Times',
        message:
            'Average response time: ${health.averageResponseTimeMs.toStringAsFixed(0)}ms',
        timestamp: DateTime.now(),
      ));
    }

    // Error rate alerts
    if (health.totalErrors24h > 50) {
      alerts.add(AIHealthAlert(
        severity: AlertSeverity.warning,
        title: 'High Error Rate',
        message: '${health.totalErrors24h} errors in last 24 hours',
        timestamp: DateTime.now(),
      ));
    }

    // System status alerts
    if (health.systemStatus != 'healthy') {
      alerts.add(AIHealthAlert(
        severity: AlertSeverity.critical,
        title: 'System Status: ${health.systemStatus.toUpperCase()}',
        message: 'System is not operating normally',
        timestamp: DateTime.now(),
      ));
    }

    return alerts;
  }

  double _extractDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll('%', '').trim();
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }
}

/// Current system health snapshot
class AISystemHealth {
  final DateTime timestamp;
  final double cacheHitRate;
  final int remainingQuota;
  final int dailyQuotaLimit;
  final int requestsPerMinute;
  final double averageResponseTimeMs;
  final int totalRequests;
  final int cachedRequests;
  final int totalErrors24h;
  final String systemStatus;
  final double neuraiLoad;
  final int durationMs;
  final String? error;

  AISystemHealth({
    required this.timestamp,
    required this.cacheHitRate,
    required this.remainingQuota,
    required this.dailyQuotaLimit,
    required this.requestsPerMinute,
    required this.averageResponseTimeMs,
    required this.totalRequests,
    required this.cachedRequests,
    required this.totalErrors24h,
    required this.systemStatus,
    required this.neuraiLoad,
    required this.durationMs,
    this.error,
  });

  factory AISystemHealth.fromFirestore(Map<String, dynamic> data) {
    return AISystemHealth(
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cacheHitRate: (data['cache_hit_rate'] as num?)?.toDouble() ?? 0,
      remainingQuota: (data['remaining_quota'] as int?) ?? 0,
      dailyQuotaLimit: AIConfig.dailyQuotaLimit,
      requestsPerMinute: (data['requests_per_minute'] as int?) ?? 0,
      averageResponseTimeMs:
          (data['average_response_time_ms'] as num?)?.toDouble() ?? 0,
      totalRequests: (data['total_requests'] as int?) ?? 0,
      cachedRequests: (data['cached_requests'] as int?) ?? 0,
      totalErrors24h: (data['total_errors_24h'] as int?) ?? 0,
      systemStatus: (data['system_status'] as String?) ?? 'unknown',
      neuraiLoad: (data['neural_load'] as num?)?.toDouble() ?? 0,
      durationMs: 0,
    );
  }

  double get quotaUsagePercent =>
      ((dailyQuotaLimit - remainingQuota) / dailyQuotaLimit) * 100;

  double get quotaRemainingPercent => 100 - quotaUsagePercent;

  bool get isHealthy => systemStatus == 'healthy' && quotaRemainingPercent > 10;

  String get statusEmoji {
    if (quotaRemainingPercent < 10) return '🔴';
    if (quotaRemainingPercent < 20) return '🟡';
    if (systemStatus != 'healthy') return '🟠';
    return '🟢';
  }
}

/// Health trend analytics
class AIHealthTrends {
  final double averageCacheHitRate;
  final int peakRequestsPerMinute;
  final double averageResponseTime;
  final int totalErrorsInPeriod;
  final double uptimePercent;
  final double quotaUsagePercent;

  AIHealthTrends({
    required this.averageCacheHitRate,
    required this.peakRequestsPerMinute,
    required this.averageResponseTime,
    required this.totalErrorsInPeriod,
    required this.uptimePercent,
    required this.quotaUsagePercent,
  });
}

/// Health alert
enum AlertSeverity { info, warning, critical }

class AIHealthAlert {
  final AlertSeverity severity;
  final String title;
  final String message;
  final DateTime timestamp;

  AIHealthAlert({
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.info:
        return 'ℹ️ Info';
      case AlertSeverity.warning:
        return '⚠️ Warning';
      case AlertSeverity.critical:
        return '🚨 Critical';
    }
  }

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.info:
        return const Color(0xFF2196F3);
      case AlertSeverity.warning:
        return const Color(0xFFFFC107);
      case AlertSeverity.critical:
        return const Color(0xFFF44336);
    }
  }
}

// Riverpod providers
final aiHealthMonitorProvider = Provider((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AISystemHealthMonitor(aiService: aiService);
});

final currentHealthProvider = FutureProvider((ref) async {
  final monitor = ref.watch(aiHealthMonitorProvider);
  return monitor.getCurrentHealth();
});

final healthTrendsProvider = FutureProvider((ref) async {
  final monitor = ref.watch(aiHealthMonitorProvider);
  return monitor.getHealthTrends();
});

final healthAlertsProvider = FutureProvider((ref) async {
  final monitor = ref.watch(aiHealthMonitorProvider);
  final health = await monitor.getCurrentHealth();
  return monitor.getAlerts(health);
});
