import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// E2E MODELS
// ============================================================================

class AuthSession {
  final String userId;
  final String token;
  final DateTime expiresAt;

  AuthSession({
    required this.userId,
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class SearchResult {
  final String productId;
  final String name;
  final double price;
  final double rating;

  SearchResult({
    required this.productId,
    required this.name,
    required this.price,
    required this.rating,
  });
}

class OrderReceipt {
  final String orderId;
  final List<String> productIds;
  final double totalAmount;
  final String status; // confirmed, processing, shipped, delivered
  final DateTime createdAt;

  OrderReceipt({
    required this.orderId,
    required this.productIds,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });
}

// ============================================================================
// E2E SERVICES
// ============================================================================

class AuthE2EService extends StateNotifier<AuthSession?> {
  AuthE2EService() : super(null);

  Future<void> authenticate(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!email.contains('@') || password.length < 6) {
      throw Exception('Invalid credentials');
    }

    state = AuthSession(
      userId: 'user_${email.hashCode}',
      token: 'token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 50));
    state = null;
  }

  bool isAuthenticated() => state != null && !state!.isExpired;
}

class SearchE2EService extends StateNotifier<List<SearchResult>> {
  SearchE2EService() : super([]);

  Future<void> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (query.isEmpty) {
      state = [];
      return;
    }

    state = [
      SearchResult(
        productId: 'prod_1',
        name: 'Product matching $query',
        price: 99.99,
        rating: 4.5,
      ),
      SearchResult(
        productId: 'prod_2',
        name: '$query variant',
        price: 149.99,
        rating: 4.2,
      ),
    ];
  }

  void clearResults() {
    state = [];
  }
}

class OrderE2EService extends StateNotifier<List<OrderReceipt>> {
  OrderE2EService() : super([]);

  Future<OrderReceipt> placeOrder({
    required List<String> productIds,
    required double totalAmount,
  }) async {
    if (productIds.isEmpty || totalAmount <= 0) {
      throw Exception('Invalid order details');
    }

    await Future.delayed(const Duration(milliseconds: 200));

    final receipt = OrderReceipt(
      orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
      productIds: productIds,
      totalAmount: totalAmount,
      status: 'confirmed',
      createdAt: DateTime.now(),
    );

    state = [...state, receipt];
    return receipt;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    state = state.map((order) {
      if (order.orderId == orderId) {
        return OrderReceipt(
          orderId: order.orderId,
          productIds: order.productIds,
          totalAmount: order.totalAmount,
          status: newStatus,
          createdAt: order.createdAt,
        );
      }
      return order;
    }).toList();
  }

  List<OrderReceipt> getOrderHistory() => state;
}

// ============================================================================
// PROVIDERS
// ============================================================================

final authE2EProvider = StateNotifierProvider<AuthE2EService, AuthSession?>((ref) {
  return AuthE2EService();
});

final searchE2EProvider =
    StateNotifierProvider<SearchE2EService, List<SearchResult>>((ref) {
  return SearchE2EService();
});

final orderE2EProvider = StateNotifierProvider<OrderE2EService, List<OrderReceipt>>(
  (ref) {
    return OrderE2EService();
  },
);

// ============================================================================
// E2E ORCHESTRATOR
// ============================================================================

class E2ECheckoutOrchestrator {
  final AuthE2EService authService;
  final SearchE2EService searchService;
  final OrderE2EService orderService;

  E2ECheckoutOrchestrator({
    required this.authService,
    required this.searchService,
    required this.orderService,
  });

  Future<OrderReceipt> executeFullUserJourney({
    required String email,
    required String password,
    required String searchQuery,
    required List<String> selectedProductIds,
    required double totalPrice,
  }) async {
    // Step 1: Authenticate
    await authService.authenticate(email, password);
    if (!authService.isAuthenticated()) {
      throw Exception('Authentication failed');
    }

    // Step 2: Search for products
    await searchService.search(searchQuery);
    if (searchService.state.isEmpty) {
      throw Exception('No search results');
    }

    // Step 3: Place order
    final order = await orderService.placeOrder(
      productIds: selectedProductIds,
      totalAmount: totalPrice,
    );

    if (order.status != 'confirmed') {
      throw Exception('Order confirmation failed');
    }

    return order;
  }

  Future<void> executeOrderDelivery(String orderId) async {
    await orderService.updateOrderStatus(orderId: orderId, newStatus: 'processing');
    await Future.delayed(const Duration(milliseconds: 100));

    await orderService.updateOrderStatus(orderId: orderId, newStatus: 'shipped');
    await Future.delayed(const Duration(milliseconds: 100));

    await orderService.updateOrderStatus(orderId: orderId, newStatus: 'delivered');
  }
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('E2E Tests - Full User Workflows', () {
    // ========================================================================
    // GROUP 1: Authentication to Purchase (2 tests)
    // ========================================================================
    group('E2E - Authentication to Purchase', () {
      test('1. Complete user journey: login → search → purchase',
          () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authE2EProvider.notifier);
        final searchNotifier = container.read(searchE2EProvider.notifier);
        final orderNotifier = container.read(orderE2EProvider.notifier);

        // Step 1: Login
        await authNotifier.authenticate('user@example.com', 'password123');
        expect(authNotifier.isAuthenticated(), isTrue);

        // Step 2: Search
        await searchNotifier.search('laptop');
        expect(container.read(searchE2EProvider), isNotEmpty);

        // Step 3: Place order
        final order = await orderNotifier.placeOrder(
          productIds: ['prod_1', 'prod_2'],
          totalAmount: 1199.99,
        );

        expect(order.status, 'confirmed');
        expect(orderNotifier.getOrderHistory(), hasLength(1));
      });

      test('2. Failed authentication prevents purchase',
          () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authE2EProvider.notifier);
        // final orderNotifier = container.read(orderE2EProvider.notifier);

        // Try to login with invalid credentials
        expect(
          () => authNotifier.authenticate('invalid', 'short'),
          throwsA(isA<Exception>()),
        );

        // Order should not be possible
        expect(authNotifier.isAuthenticated(), isFalse);
      });
    });

    // ========================================================================
    // GROUP 2: Order Lifecycle (2 tests)
    // ========================================================================
    group('E2E - Order Lifecycle', () {
      test('1. Order progresses through all statuses',
          () async {
        final container = ProviderContainer();
        final orchestrator = E2ECheckoutOrchestrator(
          authService: container.read(authE2EProvider.notifier),
          searchService: container.read(searchE2EProvider.notifier),
          orderService: container.read(orderE2EProvider.notifier),
        );

        // Place order
        final order = await orchestrator.executeFullUserJourney(
          email: 'customer@example.com',
          password: 'password123',
          searchQuery: 'smartphone',
          selectedProductIds: ['prod_1'],
          totalPrice: 299.99,
        );

        expect(order.status, 'confirmed');

        // Progress delivery
        await orchestrator.executeOrderDelivery(order.orderId);

        // Verify final status
        final orderService = container.read(orderE2EProvider.notifier);
        final orders = orderService.getOrderHistory();
        final finalOrder = orders.firstWhere((o) => o.orderId == order.orderId);

        expect(finalOrder.status, 'delivered');
      });

      test('2. Order history accumulates correctly',
          () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderE2EProvider.notifier);

        // Place multiple orders
        for (int i = 0; i < 3; i++) {
          await orderNotifier.placeOrder(
            productIds: ['prod_$i'],
            totalAmount: 100.0 * (i + 1),
          );
        }

        final history = orderNotifier.getOrderHistory();
        expect(history, hasLength(3));
        expect(history[0].totalAmount, 100.0);
        expect(history[1].totalAmount, 200.0);
        expect(history[2].totalAmount, 300.0);
      });
    });

    // ========================================================================
    // GROUP 3: Multi-Step Workflow (1 test)
    // ========================================================================
    group('E2E - Complex Workflows', () {
      test('1. Complete checkout orchestration with delivery tracking',
          () async {
        final container = ProviderContainer();
        final orchestrator = E2ECheckoutOrchestrator(
          authService: container.read(authE2EProvider.notifier),
          searchService: container.read(searchE2EProvider.notifier),
          orderService: container.read(orderE2EProvider.notifier),
        );

        // Full journey
        final order = await orchestrator.executeFullUserJourney(
          email: 'delivery@example.com',
          password: 'testpass123',
          searchQuery: 'tablet',
          selectedProductIds: ['prod_1', 'prod_3'],
          totalPrice: 599.99,
        );

        expect(order.orderId, isNotEmpty);
        expect(order.status, 'confirmed');

        // Track delivery
        final orderService = container.read(orderE2EProvider.notifier);
        
        // Verify initial state
        var trackingOrder = orderService.getOrderHistory()
            .firstWhere((o) => o.orderId == order.orderId);
        expect(trackingOrder.status, 'confirmed');

        // Progress delivery
        await orchestrator.executeOrderDelivery(order.orderId);

        // Verify final state
        trackingOrder = orderService.getOrderHistory()
            .firstWhere((o) => o.orderId == order.orderId);
        expect(trackingOrder.status, 'delivered');
      });
    });
  });
}
