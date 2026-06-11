import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/features/commerce/services/order_service.dart';
import 'package:paykari_bazar/src/models/order_model.dart';

class MockOrderService extends Mock implements OrderService {}

void main() {
  group('OrderService Tests', () {
    late MockOrderService orderService;

    setUp(() {
      orderService = MockOrderService();
    });

    test('Place new order with deliveryFee and discount', () async {
      when(() => orderService.placeOrder(
        items: any<List<Map<String, dynamic>>>(named: 'items'),
        total: any<double>(named: 'total'),
        address: any<String>(named: 'address'),
        paymentMethod: any<String>(named: 'paymentMethod'),
        customerName: any<String>(named: 'customerName'),
        customerPhone: any<String>(named: 'customerPhone'),
        deliveryFee: any<double>(named: 'deliveryFee'),
        discount: any<double>(named: 'discount'),
      )).thenAnswer((_) async => 'order456');

      final result = await orderService.placeOrder(
        items: [],
        total: 1100.0,
        address: '456 Avenue',
        paymentMethod: 'card',
        customerName: 'Jane Doe',
        customerPhone: '01711111111',
        deliveryFee: 60.0,
        discount: 20.0,
      );

      expect(result, 'order456');
    });

    test('Get customer orders stream', () async {
      final orders = [
        {
          'id': 'order1',
          'customerUid': 'user1',
          'customerName': 'Test',
          'customerPhone': '01700000000',
          'items': <Map<String, dynamic>>[],
          'subtotal': 100.0,
          'deliveryFee': 10.0,
          'discount': 0.0,
          'total': 110.0,
          'address': 'Addr',
          'paymentMethod': 'COD',
        },
      ];
      when(() => orderService.getCustomerOrders('user1'))
          .thenAnswer((_) => Stream.value(orders));

      final stream = orderService.getCustomerOrders('user1');
      final result = await stream.first;
      expect(result.length, 1);
      expect(result.first['id'], 'order1');
    });

    test('Create order from model', () async {
      final order = Order(
        id: 'order-model-1',
        customerUid: 'user1',
        customerName: 'Test',
        customerPhone: '01700000000',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: 'Addr',
        paymentMethod: 'COD',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      when(() => orderService.createOrder(any<Order>()))
          .thenAnswer((_) async => 'order-model-1');

      final result = await orderService.createOrder(order);
      expect(result, 'order-model-1');
    });

    test('Update order', () async {
      final order = Order(
        id: 'order-update-1',
        customerUid: 'user1',
        customerName: 'Test',
        customerPhone: '01700000000',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: 'Addr',
        paymentMethod: 'COD',
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      when(() => orderService.updateOrder(any<Order>()))
          .thenAnswer((_) async => Future.value());

      await orderService.updateOrder(order);
      verify(() => orderService.updateOrder(any<Order>())).called(1);
    });

    test('Assign order to rider', () async {
      when(() => orderService.assignToRider('order123', 'rider1'))
          .thenAnswer((_) async => Future.value());

      await orderService.assignToRider('order123', 'rider1');
      verify(() => orderService.assignToRider('order123', 'rider1')).called(1);
    });

    test('Cancel order with null reason', () async {
      when(() => orderService.cancelOrder('order123', any<String?>()))
          .thenAnswer((_) async => Future.value());

      await orderService.cancelOrder('order123', null);
      verify(() => orderService.cancelOrder('order123', null)).called(1);
    });

    test('Get order by ID', () async {
      final mockOrder = Order(
        id: 'order123',
        customerUid: 'user1',
        customerName: 'Test User',
        customerPhone: '01700000000',
        items: [],
        subtotal: 1000.0,
        deliveryFee: 50.0,
        discount: 0.0,
        total: 1050.0,
        address: '123 Street',
        paymentMethod: 'card',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => orderService.getOrderById('order123'))
          .thenAnswer((_) async => mockOrder);
      
      final result = await orderService.getOrderById('order123');
      expect(result?.id, 'order123');
      expect(result?.status, OrderStatus.pending);
    });

    test('Update order status', () async {
      when(() => orderService.updateOrderStatus('order123', 'shipped'))
          .thenAnswer((_) async => Future.value());
      
      await orderService.updateOrderStatus('order123', 'shipped');
      verify(() => orderService.updateOrderStatus('order123', 'shipped')).called(1);
    });

    test('Cancel order', () async {
      when(() => orderService.cancelOrder('order123', any<String?>()))
          .thenAnswer((_) async => Future.value());
      
      await orderService.cancelOrder('order123', 'Change of mind');
      verify(() => orderService.cancelOrder('order123', 'Change of mind')).called(1);
    });
  });
}
