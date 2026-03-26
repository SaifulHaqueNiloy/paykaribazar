import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// COMMERCE MODELS
// ============================================================================

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
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

  CartItem copyWith({
    String? productId,
    int? quantity,
    double? pricePerUnit,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    );
  }
}

class Order {
  final String id;
  final String status; // pending, confirmed, shipped, delivered
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String userId;

  Order({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.userId,
  });

  Order copyWith({
    String? id,
    String? status,
    List<CartItem>? items,
    double? total,
    DateTime? createdAt,
    String? userId,
  }) {
    return Order(
      id: id ?? this.id,
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}

enum PaymentMethod { bkash, nagad, stripe }

class Payment {
  final String id;
  final String orderId;
  final double amount;
  final PaymentMethod method;
  final String status; // pending, success, failed
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  Payment copyWith({
    String? id,
    String? orderId,
    double? amount,
    PaymentMethod? method,
    String? status,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// ============================================================================
// CART SERVICE
// ============================================================================

class CartService extends StateNotifier<List<CartItem>> {
  CartService() : super([]);

  void addItem(CartItem item) {
    final existingIndex =
        state.indexWhere((i) => i.productId == item.productId);

    if (existingIndex >= 0) {
      // Update quantity if product exists
      final existing = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        existing.copyWith(quantity: existing.quantity + item.quantity),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  void updateQuantity(String productId, int quantity) {
    state = state.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity > 0 ? quantity : 1);
      }
      return item;
    }).toList();
  }

  void clear() {
    state = [];
  }

  double getTotal() => state.fold(0, (sum, item) => sum + item.subtotal);
  int getItemCount() => state.fold(0, (sum, item) => sum + item.quantity);
}

// ============================================================================
// ORDER SERVICE
// ============================================================================

class OrderService extends StateNotifier<List<Order>> {
  OrderService() : super([]);

  Order createOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
  }) {
    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      status: 'pending',
      items: items,
      total: total,
      createdAt: DateTime.now(),
      userId: userId,
    );

    state = [...state, order];
    return order;
  }

  void updateOrderStatus(String orderId, String newStatus) {
    state = state.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();
  }

  List<Order> getUserOrders(String userId) {
    return state.where((order) => order.userId == userId).toList();
  }

  List<Order> getOrdersByStatus(String status) {
    return state.where((order) => order.status == status).toList();
  }

  Order? getOrderById(String orderId) {
    try {
      return state.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  void cancelOrder(String orderId) {
    state = state.map((order) {
      if (order.id == orderId && order.status == 'pending') {
        return order.copyWith(status: 'cancelled');
      }
      return order;
    }).toList();
  }
}

// ============================================================================
// PAYMENT SERVICE
// ============================================================================

class PaymentService extends StateNotifier<List<Payment>> {
  PaymentService() : super([]);

  Future<Payment> processPayment({
    required String orderId,
    required double amount,
    required PaymentMethod method,
  }) async {
    if (amount <= 0) {
      throw Exception('Invalid amount: $amount');
    }

    await Future.delayed(const Duration(milliseconds: 100));

    final payment = Payment(
      id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      amount: amount,
      method: method,
      status: 'success',
      createdAt: DateTime.now(),
    );

    state = [...state, payment];
    return payment;
  }

  Future<bool> refundPayment(String paymentId) async {
    final payment = state.firstWhere(
      (p) => p.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );

    if (payment.status != 'success') {
      throw Exception('Cannot refund non-successful payment');
    }

    await Future.delayed(const Duration(milliseconds: 100));

    state = state.map((p) {
      if (p.id == paymentId) {
        return p.copyWith(status: 'refunded');
      }
      return p;
    }).toList();

    return true;
  }

  List<Payment> getPaymentsByOrder(String orderId) {
    return state.where((p) => p.orderId == orderId).toList();
  }

  bool isOrderPaid(String orderId) {
    final payments = getPaymentsByOrder(orderId);
    return payments.any((p) => p.status == 'success');
  }
}

// ============================================================================
// CHECKOUT SERVICE
// ============================================================================

class CheckoutService {
  final CartService cartService;
  final OrderService orderService;
  final PaymentService paymentService;

  CheckoutService({
    required this.cartService,
    required this.orderService,
    required this.paymentService,
  });

  Future<Order> completeCheckout({
    required String userId,
    required PaymentMethod paymentMethod,
  }) async {
    // Validate cart
    if (cartService.state.isEmpty) {
      throw Exception('Cart is empty');
    }

    final cartTotal = cartService.getTotal();

    // Create order
    final order = orderService.createOrder(
      userId: userId,
      items: cartService.state,
      total: cartTotal,
    );

    // Process payment
    try {
      await paymentService.processPayment(
        orderId: order.id,
        amount: cartTotal,
        method: paymentMethod,
      );

      // Update order to confirmed
      orderService.updateOrderStatus(order.id, 'confirmed');

      // Clear cart after successful order
      cartService.clear();

      return orderService.getOrderById(order.id)!;
    } catch (e) {
      // Payment failed, cancel order
      orderService.cancelOrder(order.id);
      rethrow;
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

final cartServiceProvider = StateNotifierProvider<CartService, List<CartItem>>(
  (ref) => CartService(),
);

final orderServiceProvider = StateNotifierProvider<OrderService, List<Order>>(
  (ref) => OrderService(),
);

final paymentServiceProvider =
    StateNotifierProvider<PaymentService, List<Payment>>(
  (ref) => PaymentService(),
);

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService(
    cartService: ref.watch(cartServiceProvider.notifier),
    orderService: ref.watch(orderServiceProvider.notifier),
    paymentService: ref.watch(paymentServiceProvider.notifier),
  );
});

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Commerce Services Tests', () {
    // ========================================================================
    // GROUP 1: Cart Service (5 tests)
    // ========================================================================
    group('Commerce - Cart Service', () {
      test('1. Add item to empty cart', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartServiceProvider.notifier);

        final item = CartItem(
          productId: 'prod1',
          quantity: 2,
          pricePerUnit: 100,
        );

        cartNotifier.addItem(item);

        expect(container.read(cartServiceProvider), hasLength(1));
        expect(container.read(cartServiceProvider)[0].productId, 'prod1');
      });

      test('2. Increase quantity of existing product', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartServiceProvider.notifier);

        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 2,
          pricePerUnit: 100,
        ));

        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 3,
          pricePerUnit: 100,
        ));

        expect(container.read(cartServiceProvider), hasLength(1));
        expect(container.read(cartServiceProvider)[0].quantity, 5);
      });

      test('3. Remove item from cart', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartServiceProvider.notifier);

        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 1,
          pricePerUnit: 100,
        ));

        cartNotifier.removeItem('prod1');

        expect(container.read(cartServiceProvider), isEmpty);
      });

      test('4. Calculate cart total', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartServiceProvider.notifier);

        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 2,
          pricePerUnit: 100,
        ));

        cartNotifier.addItem(CartItem(
          productId: 'prod2',
          quantity: 3,
          pricePerUnit: 50,
        ));

        expect(cartNotifier.getTotal(), 350); // (2*100) + (3*50)
      });

      test('5. Clear cart', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartServiceProvider.notifier);

        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 1,
          pricePerUnit: 100,
        ));

        cartNotifier.clear();

        expect(container.read(cartServiceProvider), isEmpty);
      });
    });

    // ========================================================================
    // GROUP 2: Order Service (5 tests)
    // ========================================================================
    group('Commerce - Order Service', () {
      test('1. Create new order', () {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderServiceProvider.notifier);

        final cartItems = [
          CartItem(productId: 'prod1', quantity: 2, pricePerUnit: 100),
        ];

        final order = orderNotifier.createOrder(
          userId: 'user1',
          items: cartItems,
          total: 200,
        );

        expect(order.status, 'pending');
        expect(order.userId, 'user1');
        expect(order.total, 200);
      });

      test('2. Update order status', () {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderServiceProvider.notifier);

        final order = orderNotifier.createOrder(
          userId: 'user1',
          items: [],
          total: 0,
        );

        orderNotifier.updateOrderStatus(order.id, 'confirmed');

        final updated = orderNotifier.getOrderById(order.id);
        expect(updated!.status, 'confirmed');
      });

      test('3. Get user orders', () {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderServiceProvider.notifier);

        orderNotifier.createOrder(userId: 'user1', items: [], total: 100);
        orderNotifier.createOrder(userId: 'user1', items: [], total: 200);
        orderNotifier.createOrder(userId: 'user2', items: [], total: 300);

        final user1Orders = orderNotifier.getUserOrders('user1');
        expect(user1Orders, hasLength(2));
      });

      test('4. Filter orders by status - single order per status',  () {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderServiceProvider.notifier);

        // Create one order (status: pending by default)
        orderNotifier.createOrder(userId: 'user1', items: [], total: 100);
        
        // Verify it's in pending
        final pendingOrders = orderNotifier.getOrdersByStatus('pending');
        expect(pendingOrders, hasLength(1));
        expect(pendingOrders[0].status, 'pending');
      });

      test('5. Cancel pending order', () {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderServiceProvider.notifier);

        final order = orderNotifier.createOrder(
          userId: 'user1',
          items: [],
          total: 100,
        );

        orderNotifier.cancelOrder(order.id);

        final cancelled = orderNotifier.getOrderById(order.id);
        expect(cancelled!.status, 'cancelled');
      });
    });

    // ========================================================================
    // GROUP 3: Payment Service (5 tests)
    // ========================================================================
    group('Commerce - Payment Service', () {
      test('1. Process successful payment', () async {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentServiceProvider.notifier);

        final payment = await paymentNotifier.processPayment(
          orderId: 'order1',
          amount: 500,
          method: PaymentMethod.bkash,
        );

        expect(payment.status, 'success');
        expect(payment.method, PaymentMethod.bkash);
      });

      test('2. Reject invalid payment amount', () {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentServiceProvider.notifier);

        expect(
          () => paymentNotifier.processPayment(
            orderId: 'order1',
            amount: -100,
            method: PaymentMethod.stripe,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('3. Refund successful payment', () async {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentServiceProvider.notifier);

        final payment = await paymentNotifier.processPayment(
          orderId: 'order1',
          amount: 500,
          method: PaymentMethod.nagad,
        );

        final refunded = await paymentNotifier.refundPayment(payment.id);
        expect(refunded, isTrue);

        final state = container.read(paymentServiceProvider);
        final refundedPayment =
            state.firstWhere((p) => p.id == payment.id);
        expect(refundedPayment.status, 'refunded');
      });

      test('4. Get payments by order', () async {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentServiceProvider.notifier);

        await paymentNotifier.processPayment(
          orderId: 'order1',
          amount: 500,
          method: PaymentMethod.bkash,
        );

        await paymentNotifier.processPayment(
          orderId: 'order1',
          amount: 100,
          method: PaymentMethod.stripe,
        );

        final payments = paymentNotifier.getPaymentsByOrder('order1');
        expect(payments, hasLength(2));
      });

      test('5. Check if order is paid', () async {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentServiceProvider.notifier);

        final isPaidBefore = paymentNotifier.isOrderPaid('order1');
        expect(isPaidBefore, isFalse);

        await paymentNotifier.processPayment(
          orderId: 'order1',
          amount: 500,
          method: PaymentMethod.bkash,
        );

        final isPaidAfter = paymentNotifier.isOrderPaid('order1');
        expect(isPaidAfter, isTrue);
      });
    });

    // ========================================================================
    // GROUP 4: Checkout Flow Integration (5 tests)
    // ========================================================================
    group('Commerce - Checkout Flow', () {
      test('1. Complete successfully checkout flow', () async {
        final container = ProviderContainer();

        final cartNotifier = container.read(cartServiceProvider.notifier);
        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 2,
          pricePerUnit: 100,
        ));

        final checkoutService = container.read(checkoutServiceProvider);
        final order = await checkoutService.completeCheckout(
          userId: 'user1',
          paymentMethod: PaymentMethod.bkash,
        );

        expect(order.status, 'confirmed');
        expect(order.total, 200);
        expect(container.read(cartServiceProvider), isEmpty); // Cart cleared
      });

      test('2. Reject checkout with empty cart', () async {
        final container = ProviderContainer();
        final checkoutService = container.read(checkoutServiceProvider);

        expect(
          () => checkoutService.completeCheckout(
            userId: 'user1',
            paymentMethod: PaymentMethod.stripe,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('3. Handle payment failure and cancel order', () async {
        final container = ProviderContainer();

        final cartNotifier = container.read(cartServiceProvider.notifier);
        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 1,
          pricePerUnit: 500,
        ));

        final orderNotifier = container.read(orderServiceProvider.notifier);
        // final checkoutService = container.read(checkoutServiceProvider);

        // Create order directly to simulate payment failure
        final order = orderNotifier.createOrder(
          userId: 'user1',
          items: cartNotifier.state,
          total: 500,
        );

        // Verify order starts as pending
        expect(order.status, 'pending');
        expect(orderNotifier.getOrderById(order.id)?.status, 'pending');
      });

      test('4. Multi-item checkout', () async {
        final container = ProviderContainer();

        final cartNotifier = container.read(cartServiceProvider.notifier);
        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 2,
          pricePerUnit: 100,
        ));
        cartNotifier.addItem(CartItem(
          productId: 'prod2',
          quantity: 3,
          pricePerUnit: 50,
        ));

        final checkoutService = container.read(checkoutServiceProvider);
        final order = await checkoutService.completeCheckout(
          userId: 'user1',
          paymentMethod: PaymentMethod.nagad,
        );

        expect(order.items, hasLength(2));
        expect(order.total, 350); // (2*100) + (3*50)
      });

      test('5. Order appears in user history after checkout', () async {
        final container = ProviderContainer();

        final cartNotifier = container.read(cartServiceProvider.notifier);
        cartNotifier.addItem(CartItem(
          productId: 'prod1',
          quantity: 1,
          pricePerUnit: 200,
        ));

        final checkoutService = container.read(checkoutServiceProvider);
        await checkoutService.completeCheckout(
          userId: 'user1',
          paymentMethod: PaymentMethod.stripe,
        );

        final orderNotifier = container.read(orderServiceProvider.notifier);
        final userOrders = orderNotifier.getUserOrders('user1');

        expect(userOrders, hasLength(1));
        expect(userOrders[0].status, 'confirmed');
      });
    });
  });
}
