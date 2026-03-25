import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock Order and related models
enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class Order {
  final String id;
  final String userId;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final List<OrderItem> items;
  final String shippingAddress;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.deliveredAt,
    required this.items,
    required this.shippingAddress,
  });

  Order copyWith({
    OrderStatus? status,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id,
      userId: userId,
      totalAmount: totalAmount,
      status: status ?? this.status,
      createdAt: createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      items: items,
      shippingAddress: shippingAddress,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

// Mock Order State Notifier
class OrderStateNotifier extends StateNotifier<List<Order>> {
  OrderStateNotifier() : super([]);

  Future<void> createOrder(
    String userId,
    double totalAmount,
    List<OrderItem> items,
    String shippingAddress,
  ) async {
    if (userId.isEmpty || totalAmount <= 0 || items.isEmpty) {
      throw Exception('Invalid order data');
    }

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      totalAmount: totalAmount,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      items: items,
      shippingAddress: shippingAddress,
    );

    state = [...state, order];
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final index = state.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      throw Exception('Order not found');
    }

    final updatedOrder = state[index].copyWith(status: newStatus);
    state = [
      ...state.sublist(0, index),
      updatedOrder,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> markOrderDelivered(String orderId) async {
    final index = state.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      throw Exception('Order not found');
    }

    final updatedOrder = state[index].copyWith(
      status: OrderStatus.delivered,
      deliveredAt: DateTime.now(),
    );
    state = [
      ...state.sublist(0, index),
      updatedOrder,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> cancelOrder(String orderId) async {
    final index = state.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      throw Exception('Order not found');
    }

    if (state[index].status != OrderStatus.pending) {
      throw Exception('Can only cancel pending orders');
    }

    final updatedOrder = state[index].copyWith(status: OrderStatus.cancelled);
    state = [
      ...state.sublist(0, index),
      updatedOrder,
      ...state.sublist(index + 1),
    ];
  }

  Order? getOrderById(String orderId) {
    try {
      return state.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  List<Order> getUserOrders(String userId) {
    return state.where((order) => order.userId == userId).toList();
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return state.where((order) => order.status == status).toList();
  }
}

// Mock providers
final orderProvider = StateNotifierProvider<OrderStateNotifier, List<Order>>((ref) {
  return OrderStateNotifier();
});

final userOrdersProvider = FutureProvider.family<List<Order>, String>((ref, userId) async {
  final orders = ref.watch(orderProvider);
  return orders.where((order) => order.userId == userId).toList();
});

final orderCountProvider = Provider<int>((ref) {
  final orders = ref.watch(orderProvider);
  return orders.length;
});

void main() {
  group('Order Provider Tests', () {
    // ========================================================================
    // GROUP 1: Create Order (3 tests)
    // ========================================================================
    group('Order - Create Order', () {
      test('1. Create order successfully', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [
          OrderItem(
            productId: '1',
            productName: 'Laptop',
            quantity: 1,
            price: 999.99,
          ),
        ];

        await orderNotifier.createOrder(
          'user1',
          999.99,
          items,
          '123 Main St',
        );

        expect(container.read(orderCountProvider), 1);
        expect(container.read(orderProvider).first.status, OrderStatus.pending);
      });

      test('2. Create order with multiple items', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [
          OrderItem(productId: '1', productName: 'Item1', quantity: 2, price: 50.0),
          OrderItem(productId: '2', productName: 'Item2', quantity: 3, price: 75.0),
        ];

        await orderNotifier.createOrder('user1', 375.0, items, 'Address');

        expect(container.read(orderProvider).first.items.length, 2);
        expect(container.read(orderProvider).first.totalAmount, 375.0);
      });

      test('3. Create order fails with invalid data', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        expect(
          () => orderNotifier.createOrder('', 0, [], ''),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ========================================================================
    // GROUP 2: Order Status (4 tests)
    // ========================================================================
    group('Order - Status Management', () {
      test('1. Update order status', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [OrderItem(productId: '1', productName: 'Item', quantity: 1, price: 100.0)];
        await orderNotifier.createOrder('user1', 100.0, items, 'Address');

        final orderId = container.read(orderProvider).first.id;
        await orderNotifier.updateOrderStatus(orderId, OrderStatus.confirmed);

        expect(container.read(orderProvider).first.status, OrderStatus.confirmed);
      });

      test('2. Mark order as delivered', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [OrderItem(productId: '1', productName: 'Item', quantity: 1, price: 100.0)];
        await orderNotifier.createOrder('user1', 100.0, items, 'Address');

        final orderId = container.read(orderProvider).first.id;
        await orderNotifier.markOrderDelivered(orderId);

        expect(container.read(orderProvider).first.status, OrderStatus.delivered);
        expect(container.read(orderProvider).first.deliveredAt, isNotNull);
      });

      test('3. Cancel pending order', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [OrderItem(productId: '1', productName: 'Item', quantity: 1, price: 100.0)];
        await orderNotifier.createOrder('user1', 100.0, items, 'Address');

        final orderId = container.read(orderProvider).first.id;
        await orderNotifier.cancelOrder(orderId);

        expect(container.read(orderProvider).first.status, OrderStatus.cancelled);
      });

      test('4. Cannot cancel non-pending order', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [OrderItem(productId: '1', productName: 'Item', quantity: 1, price: 100.0)];
        await orderNotifier.createOrder('user1', 100.0, items, 'Address');

        final orderId = container.read(orderProvider).first.id;
        await orderNotifier.updateOrderStatus(orderId, OrderStatus.shipped);

        expect(
          () => orderNotifier.cancelOrder(orderId),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ========================================================================
    // GROUP 3: Query Orders (3 tests)
    // ========================================================================
    group('Order - Query Orders', () {
      test('1. Get order by ID', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [OrderItem(productId: '1', productName: 'Item', quantity: 1, price: 100.0)];
        await orderNotifier.createOrder('user1', 100.0, items, 'Address');

        final orderId = container.read(orderProvider).first.id;
        final order = orderNotifier.getOrderById(orderId);

        expect(order, isNotNull);
        expect(order?.id, orderId);
      });

      test('2. Get user orders', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [OrderItem(productId: '1', productName: 'Item', quantity: 1, price: 100.0)];

        await orderNotifier.createOrder('user1', 100.0, items, 'Address1');
        await orderNotifier.createOrder('user1', 200.0, items, 'Address2');
        await orderNotifier.createOrder('user2', 150.0, items, 'Address3');

        final user1Orders = orderNotifier.getUserOrders('user1');
        final user2Orders = orderNotifier.getUserOrders('user2');

        expect(user1Orders.length, 2);
        expect(user2Orders.length, 1);
      });

      test('3. Get orders by status', () async {
        final container = ProviderContainer();
        final orderNotifier = container.read(orderProvider.notifier);

        final items = [OrderItem(productId: '1', productName: 'Item', quantity: 1, price: 100.0)];

        await orderNotifier.createOrder('user1', 100.0, items, 'Address');
        await orderNotifier.createOrder('user1', 200.0, items, 'Address');

        final orderId1 = container.read(orderProvider)[0].id;
        await orderNotifier.updateOrderStatus(orderId1, OrderStatus.confirmed);

        final pendingOrders = orderNotifier.getOrdersByStatus(OrderStatus.pending);
        final confirmedOrders = orderNotifier.getOrdersByStatus(OrderStatus.confirmed);

        expect(pendingOrders.length, 1);
        expect(confirmedOrders.length, 1);
      });
    });
  });
}
