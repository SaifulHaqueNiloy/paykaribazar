import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/models/order_model.dart' as om;

void main() {
  group('OrderItem Tests', () {
    test('OrderItem creation', () {
      final item = om.OrderItem(
        productId: 'prod123',
        productName: 'Product',
        productNameBn: 'পণ্য',
        price: 100.0,
        quantity: 2,
        subtotal: 200.0,
      );
      expect(item.productId, 'prod123');
      expect(item.price, 100.0);
      expect(item.quantity, 2);
    });

    test('OrderItem serialization', () {
      final item = om.OrderItem(
        productId: 'prod1',
        productName: 'Item',
        productNameBn: 'আইটেম',
        price: 50.0,
        quantity: 1,
        subtotal: 50.0,
      );
      final map = item.toMap();
      final restored = om.OrderItem.fromMap(map);
      expect(restored.productId, item.productId);
      expect(restored.price, item.price);
    });
  });

  group('OrderStatus Tests', () {
    test('OrderStatus display strings', () {
      expect(om.OrderStatus.pending.toDisplayString(), 'Pending');
      expect(om.OrderStatus.delivered.toDisplayString(), 'Delivered');
    });

    test('OrderStatus fromString', () {
      expect(
        om.OrderStatusExtension.fromString('pending'),
        om.OrderStatus.pending,
      );
      expect(
        om.OrderStatusExtension.fromString('unknown'),
        om.OrderStatus.pending,
      );
    });
  });

  group('Order Tests', () {
    test('Order creation', () {
      final now = DateTime.now();
      final order = om.Order(
        id: 'order1',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        createdAt: now,
        updatedAt: now,
      );
      expect(order.id, 'order1');
      expect(order.total, 110.0);
      expect(order.status, om.OrderStatus.pending);
    });

    test('Order serialization', () {
      final now = DateTime.now();
      final original = om.Order(
        id: 'order1',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        createdAt: now,
        updatedAt: now,
      );
      final map = original.toMap();
      final restored = om.Order.fromMap(map);
      expect(restored.id, original.id);
      expect(restored.total, original.total);
    });

    test('Order copyWith', () {
      final now = DateTime.now();
      final order = om.Order(
        id: 'order1',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        createdAt: now,
        updatedAt: now,
      );
      final updated = order.copyWith(status: om.OrderStatus.shipped);
      expect(updated.id, order.id);
      expect(updated.status, om.OrderStatus.shipped);
    });

    test('Order canBeCancelled', () {
      final now = DateTime.now();
      final pending = om.Order(
        id: 'order1',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        createdAt: now,
        updatedAt: now,
      );
      final delivered = pending.copyWith(status: om.OrderStatus.delivered);
      expect(pending.canBeCancelled, isTrue);
      expect(delivered.canBeCancelled, isFalse);
    });

    test('Order isDelivered', () {
      final now = DateTime.now();
      final order = om.Order(
        id: 'order1',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        status: om.OrderStatus.delivered,
        createdAt: now,
        updatedAt: now,
      );
      expect(order.isDelivered, isTrue);
    });

    test('Order getOrderSummary', () {
      final now = DateTime.now();
      final order = om.Order(
        id: 'order123abc',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        createdAt: now,
        updatedAt: now,
      );
      final summary = order.getOrderSummary();
      expect(summary, contains('ORDER123'));
      expect(summary, contains('110'));
    });

    test('Order with Firestore Timestamp', () {
      final now = DateTime.now();
      final ts = Timestamp.fromDate(now);
      final map = {
        'id': 'order1',
        'customerUid': 'cust1',
        'customerName': 'John',
        'customerPhone': '+880123456789',
        'items': [],
        'subtotal': 100.0,
        'deliveryFee': 10.0,
        'discount': 0.0,
        'total': 110.0,
        'address': '123 Main St',
        'paymentMethod': 'COD',
        'status': 'pending',
        'createdAt': ts,
        'updatedAt': ts,
      };
      final order = om.Order.fromMap(map);
      expect(order.createdAt, isNotNull);
      expect(order.updatedAt, isNotNull);
    });

    test('Order with items', () {
      final items = [
        om.OrderItem(
          productId: 'p1',
          productName: 'Item 1',
          productNameBn: 'আইটেম ১',
          price: 50.0,
          quantity: 2,
          subtotal: 100.0,
        ),
      ];
      final now = DateTime.now();
      final order = om.Order(
        id: 'order1',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: items,
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 0.0,
        total: 110.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        createdAt: now,
        updatedAt: now,
      );
      expect(order.items.length, 1);
      expect(order.items[0].productId, 'p1');
    });
  });

  group('Order Calculations', () {
    test('Order math validation', () {
      final now = DateTime.now();
      final order = om.Order(
        id: 'order1',
        customerUid: 'cust1',
        customerName: 'John',
        customerPhone: '+880123456789',
        items: [],
        subtotal: 100.0,
        deliveryFee: 10.0,
        discount: 10.0,
        total: 100.0,
        address: '123 Main St',
        paymentMethod: 'COD',
        createdAt: now,
        updatedAt: now,
      );
      // subtotal - discount + deliveryFee = total
      expect(order.subtotal - order.discount + order.deliveryFee, order.total);
    });
  });
}
