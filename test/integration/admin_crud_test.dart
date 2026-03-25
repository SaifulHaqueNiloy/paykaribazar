import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Admin models
class AdminProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final bool active;

  AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.active,
  });

  AdminProduct copyWith({
    String? name,
    String? description,
    double? price,
    int? stock,
    bool? active,
  }) {
    return AdminProduct(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      active: active ?? this.active,
    );
  }
}

class AdminUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
  });

  AdminUser copyWith({
    String? role,
    bool? isActive,
  }) {
    return AdminUser(
      id: id,
      email: email,
      name: name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}

class AdminOrder {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  AdminOrder({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  AdminOrder copyWith({String? status}) {
    return AdminOrder(
      id: id,
      userId: userId,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

// Admin services
class AdminProductService extends StateNotifier<List<AdminProduct>> {
  AdminProductService()
      : super([
          AdminProduct(
            id: '1',
            name: 'Laptop Pro',
            description: 'High-performance laptop',
            price: 1299.99,
            stock: 15,
            active: true,
          ),
          AdminProduct(
            id: '2',
            name: 'Wireless Mouse',
            description: 'Precision mouse',
            price: 49.99,
            stock: 100,
            active: true,
          ),
        ]);

  Future<void> addProduct(AdminProduct product) async {
    state = [...state, product];
  }

  Future<void> updateProduct(String id, AdminProduct updated) async {
    final index = state.indexWhere((p) => p.id == id);
    if (index < 0) throw Exception('Product not found');

    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> deleteProduct(String id) async {
    state = state.where((p) => p.id != id).toList();
  }

  Future<void> toggleProductActive(String id) async {
    final index = state.indexWhere((p) => p.id == id);
    if (index < 0) throw Exception('Product not found');

    final product = state[index];
    state = [
      ...state.sublist(0, index),
      product.copyWith(active: !product.active),
      ...state.sublist(index + 1),
    ];
  }

  AdminProduct? getProductById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

class AdminUserService extends StateNotifier<List<AdminUser>> {
  AdminUserService()
      : super([
          AdminUser(
            id: 'u1',
            email: 'user1@example.com',
            name: 'John Doe',
            role: 'customer',
            isActive: true,
          ),
          AdminUser(
            id: 'u2',
            email: 'admin@example.com',
            name: 'Admin User',
            role: 'admin',
            isActive: true,
          ),
        ]);

  Future<void> updateUserRole(String userId, String newRole) async {
    final index = state.indexWhere((u) => u.id == userId);
    if (index < 0) throw Exception('User not found');

    state = [
      ...state.sublist(0, index),
      state[index].copyWith(role: newRole),
      ...state.sublist(index + 1),
    ];
  }

  Future<void> toggleUserActive(String userId) async {
    final index = state.indexWhere((u) => u.id == userId);
    if (index < 0) throw Exception('User not found');

    final user = state[index];
    state = [
      ...state.sublist(0, index),
      user.copyWith(isActive: !user.isActive),
      ...state.sublist(index + 1),
    ];
  }

  Future<void> deleteUser(String userId) async {
    state = state.where((u) => u.id != userId).toList();
  }

  AdminUser? getUserById(String userId) {
    try {
      return state.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  int getUserCount() => state.length;
}

class AdminOrderService extends StateNotifier<List<AdminOrder>> {
  AdminOrderService()
      : super([
          AdminOrder(
            id: 'o1',
            userId: 'u1',
            totalAmount: 299.99,
            status: 'pending',
            createdAt: DateTime.now(),
          ),
          AdminOrder(
            id: 'o2',
            userId: 'u2',
            totalAmount: 599.99,
            status: 'shipped',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = state.indexWhere((o) => o.id == orderId);
    if (index < 0) throw Exception('Order not found');

    state = [
      ...state.sublist(0, index),
      state[index].copyWith(status: newStatus),
      ...state.sublist(index + 1),
    ];
  }

  Future<void> cancelOrder(String orderId) async {
    final index = state.indexWhere((o) => o.id == orderId);
    if (index < 0) throw Exception('Order not found');

    final order = state[index];
    if (order.status == 'shipped' || order.status == 'delivered') {
      throw Exception('Cannot cancel shipped/delivered orders');
    }

    state = [
      ...state.sublist(0, index),
      order.copyWith(status: 'cancelled'),
      ...state.sublist(index + 1),
    ];
  }

  List<AdminOrder> getOrdersByStatus(String status) {
    return state.where((o) => o.status == status).toList();
  }

  AdminOrder? getOrderById(String orderId) {
    try {
      return state.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }
}

// Providers
final adminProductProvider =
    StateNotifierProvider<AdminProductService, List<AdminProduct>>((ref) {
  return AdminProductService();
});

final adminUserProvider =
    StateNotifierProvider<AdminUserService, List<AdminUser>>((ref) {
  return AdminUserService();
});

final adminOrderProvider =
    StateNotifierProvider<AdminOrderService, List<AdminOrder>>((ref) {
  return AdminOrderService();
});

void main() {
  group('Admin Panel CRUD Tests', () {
    // ========================================================================
    // GROUP 1: Product Management (4 tests)
    // ========================================================================
    group('Admin - Product CRUD', () {
      test('1. Create new product', () async {
        final container = ProviderContainer();
        final prodNotifier = container.read(adminProductProvider.notifier);

        final newProduct = AdminProduct(
          id: '3',
          name: 'USB Hub',
          description: '7-port USB hub',
          price: 34.99,
          stock: 50,
          active: true,
        );

        await prodNotifier.addProduct(newProduct);

        expect(container.read(adminProductProvider).length, 3);
        expect(
          container.read(adminProductProvider).last.name,
          'USB Hub',
        );
      });

      test('2. Update product details', () async {
        final container = ProviderContainer();
        final prodNotifier = container.read(adminProductProvider.notifier);

        final updated = AdminProduct(
          id: '1',
          name: 'Laptop Pro Max',
          description: 'Updated description',
          price: 1499.99,
          stock: 20,
          active: true,
        );

        await prodNotifier.updateProduct('1', updated);

        final product = prodNotifier.getProductById('1');
        expect(product?.name, 'Laptop Pro Max');
        expect(product?.price, 1499.99);
        expect(product?.stock, 20);
      });

      test('3. Delete product', () async {
        final container = ProviderContainer();
        final prodNotifier = container.read(adminProductProvider.notifier);

        expect(container.read(adminProductProvider).length, 2);

        await prodNotifier.deleteProduct('2');

        expect(container.read(adminProductProvider).length, 1);
        expect(prodNotifier.getProductById('2'), isNull);
      });

      test('4. Toggle product active status', () async {
        final container = ProviderContainer();
        final prodNotifier = container.read(adminProductProvider.notifier);

        final product = prodNotifier.getProductById('1');
        expect(product?.active, isTrue);

        await prodNotifier.toggleProductActive('1');

        final updated = prodNotifier.getProductById('1');
        expect(updated?.active, isFalse);

        await prodNotifier.toggleProductActive('1');
        expect(prodNotifier.getProductById('1')?.active, isTrue);
      });
    });

    // ========================================================================
    // GROUP 2: User Management (3 tests)
    // ========================================================================
    group('Admin - User Management', () {
      test('1. Update user role', () async {
        final container = ProviderContainer();
        final userNotifier = container.read(adminUserProvider.notifier);

        await userNotifier.updateUserRole('u1', 'staff');

        final user = userNotifier.getUserById('u1');
        expect(user?.role, 'staff');
      });

      test('2. Toggle user active status', () async {
        final container = ProviderContainer();
        final userNotifier = container.read(adminUserProvider.notifier);

        var user = userNotifier.getUserById('u1');
        expect(user?.isActive, isTrue);

        await userNotifier.toggleUserActive('u1');

        user = userNotifier.getUserById('u1');
        expect(user?.isActive, isFalse);
      });

      test('3. Delete user', () async {
        final container = ProviderContainer();
        final userNotifier = container.read(adminUserProvider.notifier);

        expect(userNotifier.getUserCount(), 2);

        await userNotifier.deleteUser('u1');

        expect(userNotifier.getUserCount(), 1);
        expect(userNotifier.getUserById('u1'), isNull);
      });
    });

    // ========================================================================
    // GROUP 3: Order Management (3 tests)
    // ========================================================================
    group('Admin - Order Management', () {
      test('1. Update order status', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(adminOrderProvider.notifier);

        await orderNotifier.updateOrderStatus('o1', 'confirmed');

        final order = orderNotifier.getOrderById('o1');
        expect(order?.status, 'confirmed');
      });

      test('2. Query orders by status', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(adminOrderProvider.notifier);

        var pending = orderNotifier.getOrdersByStatus('pending');
        expect(pending.length, 1);

        var shipped = orderNotifier.getOrdersByStatus('shipped');
        expect(shipped.length, 1);
      });

      test('3. Cancel order (only pending allowed)', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(adminOrderProvider.notifier);

        // Cancel pending order - should succeed
        await orderNotifier.cancelOrder('o1');
        expect(orderNotifier.getOrderById('o1')?.status, 'cancelled');

        // Try to cancel shipped order - should fail
        expect(
          () => orderNotifier.cancelOrder('o2'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
