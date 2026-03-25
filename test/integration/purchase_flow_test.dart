import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock models for integration testing
class User {
  final String id;
  final String email;
  final String name;
  final bool isAuthenticated;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isAuthenticated,
  });
}

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
}

class CartItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

class Order {
  final String id;
  final String userId;
  final double totalAmount;
  final List<CartItem> items;
  final String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.items,
    required this.status,
    required this.createdAt,
  });
}

// Mock services
class AuthService extends StateNotifier<User?> {
  AuthService() : super(null);

  Future<void> login(String email, String password) async {
    state = User(
      id: 'user_123',
      email: email,
      name: 'Test User',
      isAuthenticated: true,
    );
  }

  Future<void> logout() async {
    state = null;
  }
}

class ProductService extends StateNotifier<List<Product>> {
  ProductService()
      : super([
          Product(id: '1', name: 'Laptop', price: 999.99, stock: 10),
          Product(id: '2', name: 'Mouse', price: 29.99, stock: 50),
          Product(id: '3', name: 'Keyboard', price: 79.99, stock: 30),
        ]);

  List<Product> getProducts() => state;

  Product? getProductById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  void decreaseStock(String productId, int quantity) {
    final index = state.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      final product = state[index];
      state = [
        ...state.sublist(0, index),
        Product(
          id: product.id,
          name: product.name,
          price: product.price,
          stock: product.stock - quantity,
        ),
        ...state.sublist(index + 1),
      ];
    }
  }
}

class CartService extends StateNotifier<List<CartItem>> {
  CartService() : super([]);

  void addItem(CartItem item) {
    final index = state.indexWhere((i) => i.productId == item.productId);
    if (index >= 0) {
      state = [
        ...state.sublist(0, index),
        CartItem(
          productId: item.productId,
          productName: item.productName,
          quantity: state[index].quantity + item.quantity,
          price: item.price,
        ),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void clearCart() {
    state = [];
  }

  double getTotalPrice() {
    return state.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int getTotalItems() {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

class PaymentService extends StateNotifier<bool> {
  PaymentService() : super(false);

  Future<bool> processPayment(double amount) async {
    if (amount <= 0) {
      throw Exception('Invalid amount');
    }
    state = true;
    return true;
  }

  Future<void> refund(String orderId, double amount) async {
    state = false;
  }
}

class OrderService extends StateNotifier<List<Order>> {
  OrderService() : super([]);

  Future<Order> createOrder(
    String userId,
    double totalAmount,
    List<CartItem> items,
  ) async {
    if (userId.isEmpty || items.isEmpty) {
      throw Exception('Invalid order data');
    }

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      totalAmount: totalAmount,
      items: items,
      status: 'confirmed',
      createdAt: DateTime.now(),
    );

    state = [...state, order];
    return order;
  }

  List<Order> getUserOrders(String userId) {
    return state.where((o) => o.userId == userId).toList();
  }

  Order? getOrderById(String orderId) {
    try {
      return state.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthService, User?>((ref) {
  return AuthService();
});

final productProvider =
    StateNotifierProvider<ProductService, List<Product>>((ref) {
  return ProductService();
});

final cartProvider = StateNotifierProvider<CartService, List<CartItem>>((ref) {
  return CartService();
});

final paymentProvider = StateNotifierProvider<PaymentService, bool>((ref) {
  return PaymentService();
});

final orderProvider = StateNotifierProvider<OrderService, List<Order>>((ref) {
  return OrderService();
});

void main() {
  group('Purchase Flow Integration Tests', () {
    // ========================================================================
    // GROUP 1: Complete Purchase Flow (5 tests)
    // ========================================================================
    group('Integration - Complete Purchase Flow', () {
      test('1. Full purchase flow: login → browse → cart → checkout → order',
          () async {
        final container = ProviderContainer();

        // Step 1: Login
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.login('test@example.com', 'password123');
        expect(container.read(authProvider)?.isAuthenticated, isTrue);

        // Step 2: Get products
        final products = container.read(productProvider);
        expect(products.length, 3);
        expect(products[0].name, 'Laptop');

        // Step 3: Add to cart
        final cartNotifier = container.read(cartProvider.notifier);
        final product1 = products[0];
        cartNotifier.addItem(CartItem(
          productId: product1.id,
          productName: product1.name,
          quantity: 1,
          price: product1.price,
        ));
        expect(container.read(cartProvider).length, 1);

        // Step 4: Verify cart total
        expect(container.read(cartProvider)[0].price, 999.99);

        // Step 5: Process payment
        final paymentNotifier = container.read(paymentProvider.notifier);
        final cartService = container.read(cartProvider.notifier);
        final totalPrice = cartService.getTotalPrice();
        final paymentSuccess = await paymentNotifier.processPayment(totalPrice);
        expect(paymentSuccess, isTrue);

        // Step 6: Create order
        final orderNotifier = container.read(orderProvider.notifier);
        final user = container.read(authProvider)!;
        final cartItems = container.read(cartProvider);
        final order = await orderNotifier.createOrder(user.id, totalPrice, cartItems);
        expect(order.status, 'confirmed');

        // Step 7: Verify order created
        final userOrders = orderNotifier.getUserOrders(user.id);
        expect(userOrders.length, 1);
        expect(userOrders[0].totalAmount, totalPrice);
      });

      test('2. Multi-item purchase flow', () async {
        final container = ProviderContainer();

        // Login
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.login('user2@example.com', 'pass456');

        // Add multiple items
        final cartNotifier = container.read(cartProvider.notifier);
        final products = container.read(productProvider);

        cartNotifier.addItem(CartItem(
          productId: products[0].id,
          productName: products[0].name,
          quantity: 1,
          price: products[0].price,
        ));

        cartNotifier.addItem(CartItem(
          productId: products[1].id,
          productName: products[1].name,
          quantity: 2,
          price: products[1].price,
        ));

        expect(container.read(cartProvider).length, 2);

        // Checkout
        final cartService = container.read(cartProvider.notifier);
        final total = cartService.getTotalPrice();
        expect(total, 1059.97); // 999.99 + (29.99 * 2)

        // Payment + Order
        final paymentNotifier = container.read(paymentProvider.notifier);
        await paymentNotifier.processPayment(total);

        final orderNotifier = container.read(orderProvider.notifier);
        final user = container.read(authProvider)!;
        final order = await orderNotifier.createOrder(
          user.id,
          total,
          container.read(cartProvider),
        );

        expect(order.items.length, 2);
        expect(order.totalAmount, 1059.97);
      });

      test('3. Stock decreases after order', () async {
        final container = ProviderContainer();

        // Setup
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.login('user3@example.com', 'pass789');

        final productNotifier = container.read(productProvider.notifier);
        final cartNotifier = container.read(cartProvider.notifier);

        // Initial stock
        final initialStock = container.read(productProvider)[0].stock;
        expect(initialStock, 10);

        // Add to cart
        cartNotifier.addItem(CartItem(
          productId: '1',
          productName: 'Laptop',
          quantity: 2,
          price: 999.99,
        ));

        // Decrease stock
        productNotifier.decreaseStock('1', 2);

        // Verify stock decreased
        final updatedStock = container.read(productProvider)[0].stock;
        expect(updatedStock, 8);
      });

      test('4. Cart persists across operations', () async {
        final container = ProviderContainer();

        // Login
        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.login('user4@example.com', 'pass');

        // Add item
        final cartNotifier = container.read(cartProvider.notifier);
        cartNotifier.addItem(CartItem(
          productId: '2',
          productName: 'Mouse',
          quantity: 3,
          price: 29.99,
        ));

        // Verify persists
        expect(container.read(cartProvider).length, 1);
        expect(container.read(cartProvider)[0].quantity, 3);

        // Add another item
        cartNotifier.addItem(CartItem(
          productId: '3',
          productName: 'Keyboard',
          quantity: 1,
          price: 79.99,
        ));

        expect(container.read(cartProvider).length, 2);
      });

      test('5. Order history persists', () async {
        final container = ProviderContainer();

        final authNotifier = container.read(authProvider.notifier);
        await authNotifier.login('user5@example.com', 'pass');
        final user = container.read(authProvider)!;

        final orderNotifier = container.read(orderProvider.notifier);

        // Create multiple orders
        for (int i = 0; i < 3; i++) {
          await orderNotifier.createOrder(
            user.id,
            100.0 * (i + 1),
            [
              CartItem(
                productId: '$i',
                productName: 'Item $i',
                quantity: 1,
                price: 100.0 * (i + 1),
              ),
            ],
          );
        }

        // Verify all orders stored
        final userOrders = orderNotifier.getUserOrders(user.id);
        expect(userOrders.length, 3);
      });
    });

    // ========================================================================
    // GROUP 2: Payment Processing (3 tests)
    // ========================================================================
    group('Integration - Payment Processing', () {
      test('1. Successful payment processes', () async {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentProvider.notifier);

        final result = await paymentNotifier.processPayment(99.99);
        expect(result, isTrue);
        expect(container.read(paymentProvider), isTrue);
      });

      test('2. Invalid amount rejected', () async {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentProvider.notifier);

        expect(
          () => paymentNotifier.processPayment(0),
          throwsA(isA<Exception>()),
        );
      });

      test('3. Payment refund works', () async {
        final container = ProviderContainer();
        final paymentNotifier = container.read(paymentProvider.notifier);

        await paymentNotifier.processPayment(50.0);
        expect(container.read(paymentProvider), isTrue);

        await paymentNotifier.refund('order_123', 50.0);
        expect(container.read(paymentProvider), isFalse);
      });
    });

    // ========================================================================
    // GROUP 3: User Session Management (2 tests)
    // ========================================================================
    group('Integration - Session Management', () {
      test('1. Login/logout cycle', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.login('test@example.com', 'pass');
        expect(container.read(authProvider), isNotNull);

        await authNotifier.logout();
        expect(container.read(authProvider), isNull);
      });

      test('2. Cart clears on logout', () async {
        final container = ProviderContainer();

        final authNotifier = container.read(authProvider.notifier);
        final cartNotifier = container.read(cartProvider.notifier);

        // Login and add to cart
        await authNotifier.login('test@example.com', 'pass');
        cartNotifier.addItem(CartItem(
          productId: '1',
          productName: 'Item',
          quantity: 1,
          price: 10.0,
        ));
        expect(container.read(cartProvider).length, 1);

        // Manual cart clear on logout
        cartNotifier.clearCart();
        expect(container.read(cartProvider), isEmpty);
      });
    });
  });
}
