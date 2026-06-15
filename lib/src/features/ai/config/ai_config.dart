
/// Configuration constants for the AI system
class AIConfig {
  // Model Selection (DNA ENFORCED: Use ONLY 2.0+ but fallback to 1.5 due to free-tier quota constraints)
  static const String primaryModel = 'gemini-1.5-flash-latest';
  static const String fallbackModel = 'gemini-pro-latest';

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
