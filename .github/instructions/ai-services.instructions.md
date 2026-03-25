---
description: "Use when implementing AI features in Paykari Bazar. Covers Gemini service integration, request caching (AICacheService), rate limiting (AIRateLimiter), provider fallback rotation (Deepseek/Kimi), error handling, and audit logging."
name: "AI Services Implementation"
applyTo: "lib/src/features/ai/**"
---

# AI Services Implementation Guide

When implementing or modifying AI features in Paykari Bazar, follow this pattern strictly.

## AI Request Sequence

All AI API requests MUST follow this 4-step sequence:

1. **Check Cache** → `AICacheService.get(query)` (60-70% hit rate target)
2. **Check Rate Limiter** → `AIRateLimiter.checkLimit()` (max 60 req/min, 10K/day hard cap)
3. **Call API** → Try Gemini 2.0-flash first, fallback to Deepseek/Kimi if failed
4. **Log Audit** → `AIAuditService.log(request, response, provider, latency)`

## Implementation Template

```dart
// Inject dependencies
final aiService = ref.watch(aiServiceProvider);
final cacheService = ref.watch(aiCacheServiceProvider);
final rateLimiter = ref.watch(aiRateLimiterProvider);
final auditService = ref.watch(aiAuditServiceProvider);

// Step 1: Check cache
final cacheKey = 'query_hash_${query.hashCode}';
final cached = await cacheService.get(cacheKey);
if (cached != null) {
  await auditService.log(
    request: query,
    response: cached,
    provider: 'cache',
    latency: Duration.zero,
  );
  return cached;
}

// Step 2: Check rate limit
if (!rateLimiter.canMakeRequest()) {
  throw AIRateLimitExceededException('Rate limit exceeded');
}

// Step 3: Call API with fallback
DateTime startTime = DateTime.now();
String finalProvider = '';
String? response;
try {
  response = await aiService.callPrimary(query); // Gemini
  finalProvider = 'gemini';
} catch (e) {
  try {
    response = await aiService.callFallback(query); // Deepseek or Kimi
    finalProvider = 'fallback';
  } catch (e2) {
    throw AIServiceException('All providers failed: $e2');
  }
}

// Step 4: Log audit + cache result
Duration latency = DateTime.now().difference(startTime);
await cacheService.set(cacheKey, response);
await auditService.log(
  request: query,
  response: response,
  provider: finalProvider,
  latency: latency,
);

return response;
```

## Configuration & Constants

- **Cache TTL:** 24 hours (configurable via `AIConfig.cacheTtl`)
- **Rate Limit:** 60 requests/minute, 10K requests/day absolute max
- **Timeout:** 30 seconds per API call (fallback after 15s if slow)
- **Retry:** Exponential backoff (2s, 4s, 8s) for transient failures

Access via `AIConfig`:
```dart
final cacheSize = AIConfig.cacheMaxSizeMb;      // Default: 50MB
final ttl = AIConfig.cacheTtl;                  // Default: 24h
final rateLimit = AIConfig.requestsPerMinute;   // Default: 60
```

## Error Handling

- **Cache miss:** Normal operation, proceed to rate check
- **Rate limit hit:** Throw `AIRateLimitExceededException` (user sees: "Try again later")
- **Provider failure:** Auto-fallback to next provider (log failure)
- **All providers down:** Throw `AIServiceException` (user sees: "Service unavailable")
- **Timeout:** After 30s total, fail (log partial response if any)

Never show raw API errors to users. Always wrap in `AIServiceException` with user-friendly message.

## Audit Logging

Every request must be logged for monitoring and debugging:

```dart
await auditService.log(
  request: originalQuery,           // Original user input
  response: aiResponse,              // Full response from provider
  provider: 'gemini' | 'fallback',  // Which provider was used
  latency: Duration,                 // Total duration
  userId: currentUser.id,            // For per-user quotas
  timestamp: DateTime.now(),
);
```

## Provider Rotation Strategy

1. **Primary (Gemini 2.0-flash):** 95% of traffic, best quality + cheapest
2. **Fallback 1 (Deepseek):** If Gemini times out or quota exceeded
3. **Fallback 2 (Kimi):** Last resort if Deepseek also fails

Each provider has its own API key loaded from `.env` (never hardcode):
```dart
final geminiKey = SecretService.get('GEMINI_API_KEY');
final deepseekKey = SecretService.get('DEEPSEEK_API_KEY');
final kimiKey = SecretService.get('KIMI_API_KEY');
```

## Testing AI Features

- **Mock cache hits**: Test cache retrieval paths separately
- **Mock rate limiter**: Test quota exceeded scenarios
- **Mock API responses**: Use provider fixtures (success + timeout + error cases)
- **Audit logs**: Verify all requests are logged with correct metadata

Example test:
```dart
test('AI request uses cache when available', () async {
  when(cacheService.get(any)).thenAnswer((_) async => 'cached_response');
  
  final result = await aiService.chat('hello');
  
  expect(result, 'cached_response');
  verify(aiService.callPrimary(any)).called(0); // API not called
  verify(auditService.log(...)).called(1);       // But audit logged
});
```

## Performance Targets

- **Cache hit latency:** <10ms (p95)
- **Rate limit check:** <5ms
- **API call latency:** <5s median, <15s p95
- **Audit logging:** async, non-blocking

Monitor via Sentry dashboard under `ai.latencies.*` metrics.
