import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Edge case models and services
class Paymentgateway {
  final String id;
  final String name;
  bool isAvailable;

  Paymentgateway({
    required this.id,
    required this.name,
    required this.isAvailable,
  });
}

class NetworkService extends StateNotifier<bool> {
  NetworkService() : super(true);

  Future<dynamic> makeRequest(String endpoint) async {
    if (!state) {
      throw Exception('Network timeout');
    }
    return {'status': 'success'};
  }

  void simulateNetworkDown() {
    state = false;
  }

  void restoreNetwork() {
    state = true;
  }
}

class ValidationService {
  String? validateEmail(String email) {
    if (email.isEmpty) return 'Email required';
    if (!email.contains('@')) return 'Invalid email';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Password required';
    if (password.length < 6) return 'Password too short';
    return null;
  }

  String? validateAmount(double amount) {
    if (amount <= 0) return 'Amount must be positive';
    if (amount > 1000000) return 'Amount exceeds limit';
    return null;
  }

  String? validateCart(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return 'Cart is empty';
    if (items.length > 100) return 'Too many items';
    return null;
  }
}

class ConcurrencyService extends StateNotifier<int> {
  ConcurrencyService() : super(0);
  final List<String> processedOrders = [];

  Future<String> createOrderConcurrently(String orderId) async {
    state++;
    try {
      // Simulate concurrent processing
      await Future.delayed(const Duration(milliseconds: 10));
      if (processedOrders.contains(orderId)) {
        throw Exception('Duplicate order detected');
      }
      processedOrders.add(orderId);
      return orderId;
    } finally {
      state--;
    }
  }

  bool hasConflicts() => state > 1;
  int getProcessedCount() => processedOrders.length;
}

class CacheService extends StateNotifier<Map<String, dynamic>> {
  CacheService() : super({});

  Future<dynamic> get(String key) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return state[key];
  }

  Future<void> set(String key, dynamic value) async {
    state = {...state, key: value};
  }

  Future<void> clear() async {
    state = {};
  }

  bool hasExpired(String key) {
    // Mock expiration logic
    return !state.containsKey(key);
  }
}

class RateLimiterService extends StateNotifier<int> {
  final int maxRequests = 60;
  final Duration window = const Duration(minutes: 1);

  RateLimiterService() : super(0);

  bool canMakeRequest() {
    if (state >= maxRequests) {
      return false;
    }
    state++;
    return true;
  }

  void resetCounter() {
    state = 0;
  }

  int getRemainingRequests() => maxRequests - state;
}

class FallbackService extends StateNotifier<List<String>> {
  FallbackService() : super(['provider1', 'provider2', 'provider3']);

  Future<String> callWithFallback(String query) async {
    for (final provider in state) {
      try {
        if (provider == 'provider1') {
          throw Exception('Provider1 failed');
        }
        if (provider == 'provider2') {
          // Success
          return 'Response from $provider';
        }
      } catch (e) {
        continue;
      }
    }
    throw Exception('All providers failed');
  }

  void rotateProviders() {
    final temp = state.first;
    state = [...state.sublist(1), temp];
  }
}

// Providers
final networkProvider = StateNotifierProvider<NetworkService, bool>((ref) {
  return NetworkService();
});

final concurrencyProvider =
    StateNotifierProvider<ConcurrencyService, int>((ref) {
  return ConcurrencyService();
});

final cacheProvider = StateNotifierProvider<CacheService, Map<String, dynamic>>(
    (ref) {
  return CacheService();
});

final rateLimiterProvider =
    StateNotifierProvider<RateLimiterService, int>((ref) {
  return RateLimiterService();
});

final fallbackProvider = StateNotifierProvider<FallbackService, List<String>>(
    (ref) {
  return FallbackService();
});

void main() {
  group('Edge Cases & Error Handling Tests', () {
    // ========================================================================
    // GROUP 1: Network Error Handling (2 tests)
    // ========================================================================
    group('Edge Cases - Network Errors', () {
      test('1. Network timeout handling', () async {
        final container = ProviderContainer();
        final networkNotifier = container.read(networkProvider.notifier);

        // Normal operation
        final result = await networkNotifier.makeRequest('/api/products');
        expect(result['status'], 'success');

        // Simulate network down
        networkNotifier.simulateNetworkDown();
        expect(
          () => networkNotifier.makeRequest('/api/products'),
          throwsA(isA<Exception>()),
        );

        // Restore network
        networkNotifier.restoreNetwork();
        final resultAfterRestore =
            await networkNotifier.makeRequest('/api/products');
        expect(resultAfterRestore['status'], 'success');
      });

      test('2. Retry mechanism on failure', () async {
        final container = ProviderContainer();
        final networkNotifier = container.read(networkProvider.notifier);
        int retryCount = 0;

        Future<dynamic> makeRequestWithRetry(String endpoint) async {
          for (int i = 0; i < 3; i++) {
            try {
              return await networkNotifier.makeRequest(endpoint);
            } catch (e) {
              retryCount++;
              if (i == 1) {
                // Restore on second attempt
                networkNotifier.restoreNetwork();
              }
            }
          }
          throw Exception('All retries failed');
        }

        networkNotifier.simulateNetworkDown();
        final result = await makeRequestWithRetry('/api/data');
        expect(result['status'], 'success');
        expect(retryCount, 2);
      });
    });

    // ========================================================================
    // GROUP 2: Input Validation (3 tests)
    // ========================================================================
    group('Edge Cases - Input Validation', () {
      test('1. Empty cart checkout blocked', () {
        final validation = ValidationService();

        final emptyCart = <Map<String, dynamic>>[];
        final error = validation.validateCart(emptyCart);

        expect(error, 'Cart is empty');
      });

      test('2. Invalid email rejected', () {
        final validation = ValidationService();

        expect(validation.validateEmail(''), 'Email required');
        expect(validation.validateEmail('notanemail'), 'Invalid email');
        expect(validation.validateEmail('valid@email.com'), isNull);
      });

      test('3. Invalid amount rejected', () {
        final validation = ValidationService();

        expect(validation.validateAmount(0), 'Amount must be positive');
        expect(validation.validateAmount(-100), 'Amount must be positive');
        expect(validation.validateAmount(2000000),
            'Amount exceeds limit');
        expect(validation.validateAmount(99.99), isNull);
      });
    });

    // ========================================================================
    // GROUP 3: Concurrent Operations (2 tests)
    // ========================================================================
    group('Edge Cases - Concurrency', () {
      test('1. Concurrent order placement detected', () async {
        final container = ProviderContainer();
        final concurrencyNotifier =
            container.read(concurrencyProvider.notifier);

        final order1Future =
            concurrencyNotifier.createOrderConcurrently('order1');
        final order2Future =
            concurrencyNotifier.createOrderConcurrently('order2');

        final results = await Future.wait([order1Future, order2Future]);
        expect(results.length, 2);
        expect(concurrencyNotifier.getProcessedCount(), 2);
      });

      test('2. Duplicate order rejected', () async {
        final container = ProviderContainer();
        final concurrencyNotifier =
            container.read(concurrencyProvider.notifier);

        await concurrencyNotifier.createOrderConcurrently('order_dup');

        expect(
          () => concurrencyNotifier.createOrderConcurrently('order_dup'),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ========================================================================
    // GROUP 4: Cache & Rate Limiting (2 tests)
    // ========================================================================
    group('Edge Cases - Cache & Rate Limiting', () {
      test('1. Rate limit enforcement', () {
        final container = ProviderContainer();
        final rateLimiterNotifier =
            container.read(rateLimiterProvider.notifier);

        // Make requests up to limit
        for (int i = 0; i < 60; i++) {
          expect(rateLimiterNotifier.canMakeRequest(), isTrue);
        }

        // Next request should fail
        expect(rateLimiterNotifier.canMakeRequest(), isFalse);
        expect(rateLimiterNotifier.getRemainingRequests(), 0);

        // Reset and verify
        rateLimiterNotifier.resetCounter();
        expect(rateLimiterNotifier.canMakeRequest(), isTrue);
      });

      test('2. Cache expiration handling', () async {
        final container = ProviderContainer();
        final cacheNotifier = container.read(cacheProvider.notifier);

        // Set cache
        await cacheNotifier.set('key1', 'value1');
        var cached = await cacheNotifier.get('key1');
        expect(cached, 'value1');

        // Clear cache
        await cacheNotifier.clear();
        cached = await cacheNotifier.get('key1');
        expect(cached, isNull);

        // Verify expiration check
        expect(cacheNotifier.hasExpired('key1'), isTrue);
      });
    });

    // ========================================================================
    // GROUP 5: Provider Fallback (1 test)
    // ========================================================================
    group('Edge Cases - Provider Fallback', () {
      test('1. Fallback chain on provider failure', () async {
        final container = ProviderContainer();
        final fallbackNotifier = container.read(fallbackProvider.notifier);

        // Provider1 fails, Provider2 succeeds
        final result = await fallbackNotifier.callWithFallback('query');
        expect(result, 'Response from provider2');

        // Verify provider rotation
        fallbackNotifier.rotateProviders();
        final rotated = container.read(fallbackProvider);
        expect(rotated[0], 'provider2');
      });
    });
  });
}
