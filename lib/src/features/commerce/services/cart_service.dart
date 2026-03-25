import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/paths.dart';
import '../../../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CartService();

  Future<void> initialize() async {
    // Initial setup if needed
  }

  /// Add item to cart (local stub or direct to cloud if desired)
  Future<bool> addItem(Product product, int quantity) async {
    // Implementation for local or remote cart
    return true; 
  }

  /// Get total of items in cart
  Future<double> getCartTotal() async {
    return 0.0;
  }

  /// Syncs local cart to Firestore for persistence across devices
  Future<void> syncCartToCloud(List<Map<String, dynamic>> items) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection(HubPaths.users).doc(user.uid).update({
      'cart': items,
      'cartLastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches saved cart from cloud
  Future<List<Map<String, dynamic>>?> fetchSavedCart() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection(HubPaths.users).doc(user.uid).get();
    if (doc.exists && doc.data()!.containsKey('cart')) {
      return List<Map<String, dynamic>>.from(doc.data()!['cart']);
    }
    return null;
  }

  /// Clears cloud cart after successful order
  Future<void> clearCloudCart() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection(HubPaths.users).doc(user.uid).update({
      'cart': [],
    });
  }
}
