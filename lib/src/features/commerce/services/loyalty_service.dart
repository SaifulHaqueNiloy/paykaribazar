import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';

class LoyaltyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getPointsEarnedSinceLastSeen(String uid) async {
    final doc = await _db.collection(HubPaths.users).doc(uid).get();
    return doc.data()?['pendingPoints'] ?? 0;
  }

  Future<void> addPoints(String uid, String type, {String? reason}) async {
    final int points = (type == 'purchase') ? 10 : 2; // Default logic
    await _db.collection(HubPaths.users).doc(uid).update({
      'loyaltyPoints': FieldValue.increment(points),
      'lastPointUpdate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removePurchasePoints(String customerUid, String orderId) async {
    await _db.collection(HubPaths.users).doc(customerUid).update({
      'loyaltyPoints': FieldValue.increment(-10),
    });
  }

  Future<void> updateTopBuyerStats(String customerUid, String customerName, double totalAmount) async {
    await _db.collection('analytics').doc('top_buyers').set({
      customerUid: {
        'name': customerName,
        'totalSpent': FieldValue.increment(totalAmount),
        'lastPurchase': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  Future<void> updateHeroStats(String heroId, String heroName, int heroPoints, String type) async {
    await _db.collection('analytics').doc('heroes').set({
      heroId: {
        'name': heroName,
        'points': FieldValue.increment(heroPoints),
        'type': type,
      }
    }, SetOptions(merge: true));
  }

  Future<void> handleReferralPurchase(String uid, double subtotal) async {
    // Referral logic: give points to the inviter
    final user = await _db.collection(HubPaths.users).doc(uid).get();
    final String? referredBy = user.data()?['referredBy'];
    if (referredBy != null) {
      await addPoints(referredBy, 'referral_bonus');
    }
  }
}
