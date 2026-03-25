
/// Configuration constants for the AI system
class AIConfig {
  // Model Selection (DNA ENFORCED: Use ONLY 2.0+)
  static const String primaryModel = 'gemini-2.0-flash';
  static const String fallbackModel = 'gemini-2.0-pro-exp-02-05';

  // Caching Settings
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 500;

  // Rate Limiting
  static const int requestsPerMinute = 60;
  static const int dailyQuotaLimit = 10000;
  static const Duration rateLimitWindow = Duration(minutes: 1);

  // Retry Logic
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(milliseconds: 500);
  static const double retryBackoffMultiplier = 2.0;

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration streamTimeout = Duration(minutes: 2);
}

/// Result wrapper for AI operations
class AIResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  AIResult.success(this.data) : error = null, isSuccess = true;
  AIResult.error(this.error) : data = null, isSuccess = false;
}

/// Error codes for AI operations
enum AIErrorCode {
  quotaExceeded,
  rateLimitReached,
  networkError,
  modelError,
  invalidPrompt,
  timeout,
  unknown,
  invalidRequest,
  serverError,
  malformedResponse,
  rateLimited
}
