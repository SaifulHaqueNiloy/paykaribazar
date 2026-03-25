import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single order item (product in an order)
class OrderItem {
  final String productId;
  final String productName;
  final String productNameBn;
  final double price;
  final int quantity;
  final double subtotal;
  final String? variantId;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productNameBn,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.variantId,
    this.imageUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productNameBn: map['productNameBn'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 1).toInt(),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      variantId: map['variantId'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productNameBn': productNameBn,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'variantId': variantId,
      'imageUrl': imageUrl,
    };
  }
}

/// Order Status enum
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
  returned,
  failed,
}

extension OrderStatusExtension on OrderStatus {
  String toDisplayString() {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
      case OrderStatus.failed:
        return 'Failed';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      case 'failed':
        return OrderStatus.failed;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Represents a customer order
class Order {
  final String id;
  final String customerUid;
  final String customerName;
  final String customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String address;
  final String paymentMethod;
  final OrderStatus status;
  final String? riderUid;
  final bool isEmergency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? trackingId;
  final String? cancellationReason;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.customerUid,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.address,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    this.riderUid,
    this.isEmergency = false,
    required this.createdAt,
    required this.updatedAt,
    this.trackingId,
    this.cancellationReason,
    this.deliveredAt,
  });

  /// Factory constructor to create Order from Firestore document
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      customerUid: map['customerUid'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      discount: (map['discount'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      status: OrderStatusExtension.fromString(map['status'] ?? 'pending'),
      riderUid: map['riderUid'],
      isEmergency: map['isEmergency'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      trackingId: map['trackingId'],
      cancellationReason: map['cancellationReason'],
      deliveredAt:
          (map['deliveredAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert Order to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerUid': customerUid,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': status.toDisplayString(),
      'riderUid': riderUid,
      'isEmergency': isEmergency,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'trackingId': trackingId,
      'cancellationReason': cancellationReason,
      'deliveredAt': deliveredAt,
    };
  }

  /// Create a copy of Order with some fields updated
  Order copyWith({
    String? id,
    String? customerUid,
    String? customerName,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    double? discount,
    double? total,
    String? address,
    String? paymentMethod,
    OrderStatus? status,
    String? riderUid,
    bool? isEmergency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingId,
    String? cancellationReason,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerUid: customerUid ?? this.customerUid,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      riderUid: riderUid ?? this.riderUid,
      isEmergency: isEmergency ?? this.isEmergency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackingId: trackingId ?? this.trackingId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  /// Get order summary as string
  String getOrderSummary() {
    return 'Order #${id.substring(0, 8).toUpperCase()} - \$${total.toStringAsFixed(2)} - ${status.toDisplayString()}';
  }

  /// Calculate days since order was placed
  int get daysSinceCreated {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Check if order can be cancelled
  bool get canBeCancelled =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  /// Check if order is delivered
  bool get isDelivered => status == OrderStatus.delivered;
}
