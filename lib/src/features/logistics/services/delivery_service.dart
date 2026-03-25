import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/paths.dart';

/// Delivery Service - Managing real-time tracking and delivery updates
class DeliveryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DeliveryService();

  Future<void> initialize() async {
    // Initialization logic if any
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDeliveryUpdates(String orderId) {
    return _db.collection(HubPaths.orders).doc(orderId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRiderOrders(String riderId) {
    return _db.collection(HubPaths.orders).where('riderUid', isEqualTo: riderId).snapshots();
  }

  Future<void> updateRiderLocation(String orderId, LatLng position) async {
    await _db.collection(HubPaths.orders).doc(orderId).update({
      'riderLocation': GeoPoint(position.latitude, position.longitude),
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection(HubPaths.orders).doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
