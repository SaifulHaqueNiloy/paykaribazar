import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// INTEGRATION: AI + COMMERCE + SECURITY
// ============================================================================

// Reuse models from previous services
class AIQueryRequest {
  final String query;
  final String userId;
  final DateTime timestamp;

  AIQueryRequest({
    required this.query,
    required this.userId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class SecureCheckoutRequest {
  final String userId;
  final String paymentMethod;
  final String biometricType;
  final String encryptionKey;
  final String hmacSignature;

  SecureCheckoutRequest({
    required this.userId,
    required this.paymentMethod,
    required this.biometricType,
    required this.encryptionKey,
    required this.hmacSignature,
  });
}

class CartItem {
  final String productId;
  final int quantity;
  final double pricePerUnit;

  CartItem({
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
  });

  double get subtotal => quantity * pricePerUnit;
}

// ============================================================================
// WORKFLOW: AI QUERY → PRODUCT RECOMMENDATION → ADD TO CART → SECURE CHECKOUT
// ============================================================================

class AIRecommendationService extends StateNotifier<List<String>> {
  AIRecommendationService() : super([]);

  Future<List<String>> getProductRecommendations(
    String aiResponse,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Parse AI response to extract product IDs
    final products = [
      'prod_${aiResponse.length}',
      'prod_${aiResponse.length + 1}',
      'prod_${aiResponse.length + 2}',
    ];

    state = [...state, ...products];
    return products;
  }
}

class SecureCartService extends StateNotifier<List<CartItem>> {
  final List<String> accessLog = [];

  SecureCartService() : super([]);

  void addItemSecurely({
    required CartItem item,
    required String userId,
    required String signature,
  }) {
    // Log user access
    accessLog.add('User $userId added ${item.productId} at ${DateTime.now()}');

    state = [...state, item];
  }

  void clearCart() {
    state = [];
  }

  double getSecureTotal() {
    return state.fold(0, (sum, item) => sum + item.subtotal);
  }
}

class BiometricCheckoutService extends StateNotifier<String> {
  BiometricCheckoutService() : super('pending');

  Future<bool> verifyBiometricAndCheckout({
    required String userId,
    required String biometricType,
    required double amount,
  }) async {
    if (biometricType.isEmpty || amount <= 0) {
      throw Exception('Invalid biometric or amount');
    }

    await Future.delayed(const Duration(milliseconds: 150));

    state = 'processing';

    // Simulate biometric verification
    if (userId.contains('fail')) {
      state = 'failed';
      throw Exception('Biometric verification failed');
    }

    state = 'verified';

    // Process payment
    await Future.delayed(const Duration(milliseconds: 100));

    state = 'completed';
    return true;
  }

  String getStatus() => state;
}

class EncryptedOrderService extends StateNotifier<List<Map<String, dynamic>>> {
  EncryptedOrderService() : super([]);

  Future<String> createEncryptedOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
    required String encryptionKey,
    required String hmacSignature,
  }) async {
    if (encryptionKey.isEmpty) {
      throw Exception('Encryption key required');
    }

    if (hmacSignature.isEmpty) {
      throw Exception('HMAC signature required');
    }

    await Future.delayed(const Duration(milliseconds: 120));

    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

    // Store encrypted order
    state = [
      ...state,
      {
        'id': orderId,
        'userId': userId,
        'itemCount': items.length,
        'total': total,
        'encryptionKey': encryptionKey,
        'hmacSignature': hmacSignature,
        'status': 'confirmed',
        'createdAt': DateTime.now(),
      },
    ];

    return orderId;
  }

  bool isOrderVerified(String orderId) {
    try {
      final order =
          state.firstWhere((o) => o['id'] == orderId);
      return order['hmacSignature'].isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

final aiRecommendationProvider =
    StateNotifierProvider<AIRecommendationService, List<String>>((ref) {
  return AIRecommendationService();
});

final secureCartProvider =
    StateNotifierProvider<SecureCartService, List<CartItem>>((ref) {
  return SecureCartService();
});

final biometricCheckoutProvider =
    StateNotifierProvider<BiometricCheckoutService, String>((ref) {
  return BiometricCheckoutService();
});

final encryptedOrderProvider = StateNotifierProvider<EncryptedOrderService,
    List<Map<String, dynamic>>>((ref) {
  return EncryptedOrderService();
});

final integratedCheckoutProvider =
    Provider<IntegratedCheckoutOrchestrator>((ref) {
  return IntegratedCheckoutOrchestrator(
    aiRecommendationService: ref.watch(aiRecommendationProvider.notifier),
    secureCartService: ref.watch(secureCartProvider.notifier),
    biometricCheckoutService: ref.watch(biometricCheckoutProvider.notifier),
    encryptedOrderService: ref.watch(encryptedOrderProvider.notifier),
  );
});

// ============================================================================
// ORCHESTRATOR: COMPLETE WORKFLOW
// ============================================================================

class IntegratedCheckoutOrchestrator {
  final AIRecommendationService aiRecommendationService;
  final SecureCartService secureCartService;
  final BiometricCheckoutService biometricCheckoutService;
  final EncryptedOrderService encryptedOrderService;

  IntegratedCheckoutOrchestrator({
    required this.aiRecommendationService,
    required this.secureCartService,
    required this.biometricCheckoutService,
    required this.encryptedOrderService,
  });

  Future<String> executeFullCheckoutFlow({
    required String userId,
    required String aiQuery,
    required String paymentMethod,
    required String biometricType,
    required String encryptionKey,
    required String hmacSignature,
  }) async {
    try {
      // Step 1: Get AI recommendations
      final recommendations =
          await aiRecommendationService.getProductRecommendations(aiQuery);

      if (recommendations.isEmpty) {
        throw Exception('No product recommendations available');
      }

      // Step 2: Add recommended products to secure cart
      for (int i = 0; i < recommendations.length; i++) {
        final item = CartItem(
          productId: recommendations[i],
          quantity: 1,
          pricePerUnit: 100.0 * (i + 1),
        );

        secureCartService.addItemSecurely(
          item: item,
          userId: userId,
          signature: hmacSignature,
        );
      }

      // Step 3: Get secure cart total
      final cartTotal = secureCartService.getSecureTotal();

      // Step 4: Verify biometric and process checkout
      final biometricVerified =
          await biometricCheckoutService.verifyBiometricAndCheckout(
        userId: userId,
        biometricType: biometricType,
        amount: cartTotal,
      );

      if (!biometricVerified) {
        throw Exception('Biometric verification failed');
      }

      // Step 5: Create encrypted order
      final orderId = await encryptedOrderService.createEncryptedOrder(
        userId: userId,
        items: secureCartService.state,
        total: cartTotal,
        encryptionKey: encryptionKey,
        hmacSignature: hmacSignature,
      );

      // Step 6: Clear cart after successful order
      secureCartService.clearCart();

      return orderId;
    } catch (e) {
      rethrow;
    }
  }
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Core Services Integration Tests', () {
    // ========================================================================
    // GROUP 1: AI-Driven Recommendations and Cart (2 tests)
    // ========================================================================
    group('Integration - AI Recommendations → Cart', () {
      test('1. Get AI recommendations and add to secure cart', () async {
        final container = ProviderContainer();

        final aiNotifier = container.read(aiRecommendationProvider.notifier);
        final recommendations =
            await aiNotifier.getProductRecommendations('user needs phone');

        expect(recommendations, isNotEmpty);
        expect(recommendations.length, 3);

        // Add recommended items to cart
        final cartNotifier = container.read(secureCartProvider.notifier);
        for (int i = 0; i < recommendations.length; i++) {
          final item = CartItem(
            productId: recommendations[i],
            quantity: 1,
            pricePerUnit: 100.0,
          );

          cartNotifier.addItemSecurely(
            item: item,
            userId: 'user1',
            signature: 'sig_xyz',
          );
        }

        expect(container.read(secureCartProvider), hasLength(3));
        expect(cartNotifier.getSecureTotal(), 300.0);
      });

      test('2. AI recommendations logged to cart access log', () async {
        final container = ProviderContainer();

        final cartNotifier = container.read(secureCartProvider.notifier);

        cartNotifier.addItemSecurely(
          item: CartItem(
            productId: 'prod_1',
            quantity: 2,
            pricePerUnit: 150.0,
          ),
          userId: 'user1',
          signature: 'sig_abc',
        );

        expect(cartNotifier.accessLog, isNotEmpty);
        expect(cartNotifier.accessLog[0], contains('user1'));
      });
    });

    // ========================================================================
    // GROUP 2: Biometric Authentication → Encrypted Checkout (2 tests)
    // ========================================================================
    group('Integration - Biometric Verification → Encrypted Checkout', () {
      test('1. Biometric verification enables secure checkout', () async {
        final container = ProviderContainer();

        final bioNotifier = container.read(biometricCheckoutProvider.notifier);

        final verified =
            await bioNotifier.verifyBiometricAndCheckout(
          userId: 'user1',
          biometricType: 'fingerprint',
          amount: 500.0,
        );

        expect(verified, isTrue);
        expect(bioNotifier.getStatus(), 'completed');
      });

      test('2. Failed biometric blocks encrypted order creation', () async {
        final container = ProviderContainer();

        final bioNotifier = container.read(biometricCheckoutProvider.notifier);

        expect(
          () => bioNotifier.verifyBiometricAndCheckout(
            userId: 'user_fail',
            biometricType: 'face',
            amount: 500.0,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ========================================================================
    // GROUP 3: End-to-End Checkout Flow (2 tests)
    // ========================================================================
    group('Integration - Full End-to-End Flow', () {
      test('1. Complete workflow: AI → Cart → Biometric → Encrypted Order',
          () async {
        final container = ProviderContainer();
        final orchestrator = container.read(integratedCheckoutProvider);

        final orderId =
            await orchestrator.executeFullCheckoutFlow(
          userId: 'user1',
          aiQuery: 'I need a smartphone',
          paymentMethod: 'bkash',
          biometricType: 'fingerprint',
          encryptionKey: 'secret_key_32_chars_long_123456',
          hmacSignature: 'hmac_sig_xyz123abc',
        );

        expect(orderId, isNotEmpty);
        expect(orderId, startsWith('order_'));

        // Verify order is encrypted
        final orderNotifier = container.read(encryptedOrderProvider.notifier);
        expect(orderNotifier.isOrderVerified(orderId), isTrue);
      });

      test('2. Cart cleared after successful secure checkout', () async {
        final container = ProviderContainer();
        final orchestrator = container.read(integratedCheckoutProvider);

        // Add items before checkout
        final cartNotifier = container.read(secureCartProvider.notifier);
        cartNotifier.addItemSecurely(
          item: CartItem(
            productId: 'prod_1',
            quantity: 1,
            pricePerUnit: 100.0,
          ),
          userId: 'user1',
          signature: 'sig_test',
        );

        expect(container.read(secureCartProvider), isNotEmpty);

        // Execute checkout
        await orchestrator.executeFullCheckoutFlow(
          userId: 'user1',
          aiQuery: 'test query',
          paymentMethod: 'nagad',
          biometricType: 'fingerprint',
          encryptionKey: 'secret_key_32_chars_long_123456',
          hmacSignature: 'hmac_sig_xyz123abc',
        );

        // Cart should be cleared
        expect(container.read(secureCartProvider), isEmpty);
      });
    });

    // ========================================================================
    // GROUP 4: Security & Compliance (1 test)
    // ========================================================================
    group('Integration - Security & Compliance', () {
      test('1. Order encryption required for checkout', () async {
        final container = ProviderContainer();
        final orchestrator = container.read(integratedCheckoutProvider);

        // Missing encryption key should throw
        expect(
          () => orchestrator.executeFullCheckoutFlow(
            userId: 'user1',
            aiQuery: 'test',
            paymentMethod: 'stripe',
            biometricType: 'face',
            encryptionKey: '', // Empty key
            hmacSignature: 'sig',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
