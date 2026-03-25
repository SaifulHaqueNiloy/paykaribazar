import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for logging AI requests and tracking metrics
class AIRequestLogger {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _logsCollection = 'ai_request_logs';

  /// Log AI request
  Future<void> logRequest({
    required String operation,
    required String prompt,
    String? model,
    String? userId,
    Map<String, dynamic>? parameters,
    bool usedCache = false,
  }) async {
    try {
      await _db.collection(_logsCollection).add({
        'timestamp': FieldValue.serverTimestamp(),
        'operation': operation,
        'model': model,
        'user_id': userId,
        'prompt_length': prompt.length,
        'used_cache': usedCache,
        'parameters': parameters,
        'status': 'sent',
      });
    } catch (e) {
      // Log request error handled silently
    }
  }

  /// Log AI response
  Future<void> logResponse({
    required String operation,
    required String response,
    required Duration duration,
    int? tokens,
    double? cost,
    String? userId,
    String? status = 'success',
  }) async {
    try {
      await _db.collection(_logsCollection).add({
        'timestamp': FieldValue.serverTimestamp(),
        'operation': operation,
        'user_id': userId,
        'response_length': response.length,
        'duration_ms': duration.inMilliseconds,
        'tokens_used': tokens,
        'estimated_cost': cost,
        'status': status,
        'type': 'response',
      });
    } catch (e) {
      // Log response error handled silently
    }
  }

  /// Get request statistics
  Future<Map<String, dynamic>> getRequestStats({int hours = 24}) async {
    try {
      final startTime = DateTime.now().subtract(Duration(hours: hours));

      final snapshot = await _db
          .collection(_logsCollection)
          .where('timestamp', isGreaterThanOrEqualTo: startTime)
          .get();

      int totalRequests = 0;
      int cachedRequests = 0;
      int successfulRequests = 0;
      double totalDuration = 0;
      int totalTokens = 0;
      double totalCost = 0;
      final operationCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        totalRequests++;

        if ((data['used_cache'] as bool?) ?? false) {
          cachedRequests++;
        }

        if ((data['status'] as String?) == 'success') {
          successfulRequests++;
        }

        final duration = data['duration_ms'] as int?;
        if (duration != null) {
          totalDuration += duration;
        }

        final tokens = data['tokens_used'] as int?;
        if (tokens != null) {
          totalTokens += tokens;
        }

        final cost = data['estimated_cost'] as double?;
        if (cost != null) {
          totalCost += cost;
        }

        final op = data['operation'] as String?;
        if (op != null) {
          operationCounts[op] = (operationCounts[op] ?? 0) + 1;
        }
      }

      return {
        'time_period_hours': hours,
        'total_requests': totalRequests,
        'cached_requests': cachedRequests,
        'cache_hit_rate': totalRequests > 0
            ? (cachedRequests / totalRequests * 100).toStringAsFixed(2)
            : '0',
        'successful_requests': successfulRequests,
        'average_duration_ms': totalRequests > 0
            ? (totalDuration / totalRequests).toStringAsFixed(2)
            : '0',
        'total_tokens': totalTokens,
        'total_cost': totalCost.toStringAsFixed(6),
        'operations': operationCounts,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'error': 'Failed to get request stats: $e'};
    }
  }

  /// Get user-specific statistics
  Future<Map<String, dynamic>> getUserStats(String userId,
      {int days = 7}) async {
    try {
      final startTime = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _db
          .collection(_logsCollection)
          .where('user_id', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: startTime)
          .get();

      int totalRequests = 0;
      int cachedRequests = 0;
      double totalCost = 0;
      final operationCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        totalRequests++;

        if ((data['used_cache'] as bool?) ?? false) {
          cachedRequests++;
        }

        final cost = data['estimated_cost'] as double?;
        if (cost != null) {
          totalCost += cost;
        }

        final op = data['operation'] as String?;
        if (op != null) {
          operationCounts[op] = (operationCounts[op] ?? 0) + 1;
        }
      }

      return {
        'user_id': userId,
        'time_period_days': days,
        'total_requests': totalRequests,
        'cached_requests': cachedRequests,
        'total_cost': totalCost.toStringAsFixed(6),
        'operations': operationCounts,
      };
    } catch (e) {
      return {'error': 'Failed to get user stats: $e'};
    }
  }

  /// Delete old logs (cleanup)
  Future<int> deleteLogsOlderThan(int days) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _db
          .collection(_logsCollection)
          .where('timestamp', isLessThan: cutoffTime)
          .get();

      int deletedCount = 0;

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }
}
