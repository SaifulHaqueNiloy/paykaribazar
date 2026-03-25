import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String status;
  final String userId;
  final double totalAmount;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String? paymentMethod;
  final String? shippingAddress;

  OrderModel({
    required this.id,
    required this.status,
    required this.userId,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.paymentMethod,
    this.shippingAddress,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      status: map['status'] ?? 'pending',
      userId: map['userId'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      items: (map['items'] as List? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: map['paymentMethod'],
      shippingAddress: map['shippingAddress'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'userId': userId,
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
    };
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

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}
