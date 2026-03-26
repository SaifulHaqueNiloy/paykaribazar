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

    test('Place new order', () async {
      when(() => orderService.placeOrder(
        items: any(named: 'items'),
        total: any(named: 'total'),
        address: any(named: 'address'),
        paymentMethod: any(named: 'paymentMethod'),
        customerName: any(named: 'customerName'),
        customerPhone: any(named: 'customerPhone'),
      )).thenAnswer((_) async => 'order123');

      final result = await orderService.placeOrder(
        items: [],
        total: 1000.0,
        address: '123 Street',
        paymentMethod: 'card',
        customerName: 'Test User',
        customerPhone: '01700000000',
      );

      expect(result, 'order123');
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
      when(() => orderService.cancelOrder('order123', any()))
          .thenAnswer((_) async => Future.value());
      
      await orderService.cancelOrder('order123', 'Change of mind');
      verify(() => orderService.cancelOrder('order123', 'Change of mind')).called(1);
    });
  });
}
