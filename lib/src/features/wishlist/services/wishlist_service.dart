import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> toggleWishlist(String userId, String productId) async {
    final docRef = _firestore
        .collection(HubPaths.users)
        .doc(userId)
        .collection('wishlist')
        .doc(productId);
    
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<String>> getWishlist(String userId) {
    return _firestore
        .collection(HubPaths.users)
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.id).toList());
  }
}
