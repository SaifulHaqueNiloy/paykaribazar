import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/paths.dart';
import '../../../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> placeOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String address,
    required String paymentMethod,
    required String customerName,
    required String customerPhone,
    double deliveryFee = 0.0,
    double discount = 0.0,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final orderData = {
      'customerUid': user.uid,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items,
      'total': total,
      'subtotal': total + discount - deliveryFee,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'riderUid': null,
      'isEmergency': false,
    };

    final docRef = await _firestore.collection(HubPaths.orders).add(orderData);
    
    // Update order ID in the document
    await docRef.update({'id': docRef.id});
    
    return docRef.id;
  }

  Stream<List<Map<String, dynamic>>> getCustomerOrders(String uid) {
    return _firestore.collection(HubPaths.orders)
        .where('customerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(HubPaths.orders).doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create an order from an Order model (type-safe version)
  Future<String> createOrder(Order order) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final orderData = order.toMap();
    orderData.remove('id'); // Firestore will generate ID
    orderData['createdAt'] = FieldValue.serverTimestamp();
    orderData['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection(HubPaths.orders).add(orderData);
    
    // Update order ID in the document
    await docRef.update({'id': docRef.id});
    
    return docRef.id;
  }

  /// Fetch a single order by ID as Order model
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(HubPaths.orders).doc(orderId).get();
      if (doc.exists) {
        return Order.fromMap({'id': doc.id, ...doc.data() as Map<String, dynamic>});
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  /// Fetch all customer orders as Order models (streaming)
  Stream<List<Order>> getCustomerOrdersAsModels(String uid) {
    return _firestore.collection(HubPaths.orders)
        .where('customerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Order.fromMap({'id': doc.id, ...doc.data()}))
            .toList());
  }

  /// Update order status using Order model
  Future<void> updateOrder(Order order) async {
    await _firestore.collection(HubPaths.orders).doc(order.id).update({
      ...order.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId, String? reason) async {
    await _firestore.collection(HubPaths.orders).doc(orderId).update({
      'status': OrderStatus.cancelled.toDisplayString(),
      'cancellationReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetch all pending orders (for admin/rider)
  Stream<List<Order>> getPendingOrders() {
    return _firestore.collection(HubPaths.orders)
        .where('status', isEqualTo: OrderStatus.pending.toDisplayString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Order.fromMap({'id': doc.id, ...doc.data()}))
            .toList());
  }

  /// Assign order to a rider
  Future<void> assignToRider(String orderId, String riderUid) async {
    await _firestore.collection(HubPaths.orders).doc(orderId).update({
      'riderUid': riderUid,
      'status': OrderStatus.confirmed.toDisplayString(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
