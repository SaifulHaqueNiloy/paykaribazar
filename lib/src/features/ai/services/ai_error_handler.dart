import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/ai_config.dart';

/// AI Error Handler with logging and recovery strategies
class AIErrorHandler {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Classify and handle AI errors
  AIErrorCode classifyError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('quota') || errorMessage.contains('rate limit')) {
      return AIErrorCode.quotaExceeded;
    } else if (errorMessage.contains('timeout')) {
      return AIErrorCode.timeout;
    } else if (errorMessage.contains('invalid') ||
        errorMessage.contains('bad request')) {
      return AIErrorCode.invalidRequest;
    } else if (errorMessage.contains('500') ||
        errorMessage.contains('server error')) {
      return AIErrorCode.serverError;
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('connection')) {
      return AIErrorCode.networkError;
    } else if (errorMessage.contains('json') ||
        errorMessage.contains('parse')) {
      return AIErrorCode.malformedResponse;
    } else {
      return AIErrorCode.unknown;
    }
  }

  /// Should we retry based on error type
  bool isRetryable(AIErrorCode errorCode) {
    switch (errorCode) {
      case AIErrorCode.quotaExceeded:
      case AIErrorCode.rateLimited:
      case AIErrorCode.rateLimitReached:
        return false; // Don't retry quota or rate limit errors
      case AIErrorCode.timeout:
      case AIErrorCode.networkError:
      case AIErrorCode.serverError:
        return true;
      case AIErrorCode.invalidRequest:
      case AIErrorCode.malformedResponse:
      case AIErrorCode.modelError:
      case AIErrorCode.invalidPrompt:
        return false;
      case AIErrorCode.unknown:
        return true;
    }
  }

  /// Get user-friendly error message
  String getErrorMessage(AIErrorCode code, {bool isBangla = false}) {
    switch (code) {
      case AIErrorCode.quotaExceeded:
        return isBangla
            ? 'দৈনিক সীমা অতিক্রম করেছি। পরে আবার চেষ্টা করুন।'
            : 'Daily limit exceeded. Try again later.';
      case AIErrorCode.rateLimited:
      case AIErrorCode.rateLimitReached:
        return isBangla
            ? 'অনেক দ্রুত অনুরোধ পাঠাচ্ছেন। একটু অপেক্ষা করুন।'
            : 'Too many requests. Please wait.';
      case AIErrorCode.timeout:
        return isBangla
            ? 'অনুরোধ সময় শেষ হয়েছে। পুনরায় চেষ্টা করুন।'
            : 'Request timed out. Trying again.';
      case AIErrorCode.networkError:
        return isBangla
            ? 'নেটওয়ার্ক সংযোগ সমস্যা। ইন্টারনেট চেক করুন।'
            : 'Network error. Check your connection.';
      case AIErrorCode.invalidRequest:
      case AIErrorCode.invalidPrompt:
        return isBangla ? 'অনুরোধ বৈধ নয়।' : 'Invalid request.';
      case AIErrorCode.serverError:
      case AIErrorCode.modelError:
        return isBangla
            ? 'সার্ভার ত্রুটি। পরে চেষ্টা করুন।'
            : 'Server error. Try again later.';
      case AIErrorCode.malformedResponse:
        return isBangla ? 'সাড়া সঠিক নয়।' : 'Invalid response format.';
      case AIErrorCode.unknown:
        return isBangla ? 'অজানা ত্রুটি ঘটেছে।' : 'An unknown error occurred.';
    }
  }

  /// Log error to Firestore
  Future<void> logError(
    String operation,
    dynamic error,
    AIErrorCode code, {
    String? userId,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _db.collection('ai_error_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'operation': operation,
        'error_code': code.toString(),
        'error_message': error.toString(),
        'user_id': userId,
        'context': context,
        'stack_trace':
            StackTrace.current.toString().split('\n').take(10).join('\n'),
      });

      // Also log to Sentry for critical errors
      if (code == AIErrorCode.quotaExceeded ||
          code == AIErrorCode.serverError) {
        await Sentry.captureException(
          error,
          stackTrace: StackTrace.current,
          hint: Hint.withMap({
            'operation': operation,
            'error_code': code.toString(),
            'context': context,
          }),
        );
      }
    } catch (e) {
      print('Failed to log error: $e');
    }
  }

  /// Get error statistics
  Future<Map<String, dynamic>> getErrorStats({int days = 7}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _db
          .collection('ai_error_logs')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .get();

      final errorCounts = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final errorCode = data['error_code'] as String?;
        if (errorCode != null) {
          errorCounts[errorCode] = (errorCounts[errorCode] ?? 0) + 1;
        }
      }

      return {
        'total_errors': snapshot.docs.length,
        'errors_by_type': errorCounts,
        'time_period_days': days,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'error': 'Failed to get error stats: $e'};
    }
  }

  /// Should use fallback model
  bool shouldUseFallback(AIErrorCode errorCode) {
    return errorCode == AIErrorCode.serverError ||
        errorCode == AIErrorCode.unknown ||
        errorCode == AIErrorCode.modelError;
  }
}

/// Recovery strategy helper
class AIRecoveryStrategy {
  /// Get recovery action for error
  String getRecoveryAction(AIErrorCode code) {
    switch (code) {
      case AIErrorCode.quotaExceeded:
        return 'wait'; // User should wait
      case AIErrorCode.rateLimited:
      case AIErrorCode.rateLimitReached:
        return 'backoff'; // Exponential backoff
      case AIErrorCode.timeout:
        return 'retry'; // Retry with same params
      case AIErrorCode.networkError:
        return 'retry'; // Retry when connection restored
      case AIErrorCode.invalidRequest:
      case AIErrorCode.invalidPrompt:
      case AIErrorCode.malformedResponse:
        return 'fail'; // Don't retry
      case AIErrorCode.serverError:
      case AIErrorCode.modelError:
        return 'fallback'; // Use fallback model
      case AIErrorCode.unknown:
        return 'retry'; // Retry once
    }
  }

  /// Get wait time before retry
  Duration getWaitTime(AIErrorCode code, int attemptNumber) {
    switch (code) {
      case AIErrorCode.quotaExceeded:
        return const Duration(hours: 1); // Wait 1 hour
      case AIErrorCode.rateLimited:
      case AIErrorCode.rateLimitReached:
        return Duration(seconds: 30 * (attemptNumber + 1)); // 30s, 60s, 90s
      case AIErrorCode.timeout:
      case AIErrorCode.networkError:
      case AIErrorCode.serverError:
        return Duration(milliseconds: 500 * (2 ^ attemptNumber)); // Exponential
      default:
        return Duration.zero;
    }
  }
}
