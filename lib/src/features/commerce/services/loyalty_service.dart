import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';

class LoyaltyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getPointsEarnedSinceLastSeen(String uid) async {
    final doc = await _db.collection(HubPaths.users).doc(uid).get();
    return doc.data()?['pendingPoints'] ?? 0;
  }

  Future<void> addPoints(String uid, String type, {String? reason}) async {
    int earned = 0;
    String description = '';
    
    if (type == 'signupPoints' || type == 'signup') {
      earned = 100;
      description = reason ?? 'স্বাগতম বোনাস (Welcome Bonus)';
    } else if (type == 'purchase') {
      earned = 50;
      description = reason ?? 'কেনাকাটার রিওয়ার্ড (Purchase Reward)';
    } else if (type == 'referral_bonus') {
      earned = 50;
      description = reason ?? 'রেফারেল বোনাস (Referral Bonus)';
    } else if (type == 'login') {
      earned = 10;
      description = reason ?? 'দৈনিক লগইন বোনাস (Daily Login Bonus)';
    } else {
      earned = 10;
      description = reason ?? 'বোনাস পয়েন্ট (Bonus Points)';
    }

    await _db.collection(HubPaths.users).doc(uid).update({
      'points': FieldValue.increment(earned),
      'lastPointUpdate': FieldValue.serverTimestamp(),
    });

    try {
      await _db.collection(HubPaths.users).doc(uid).collection('transactions').add({
        'title': description,
        'points': earned,
        'type': 'credit',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Fail silently if subcollection write fails
    }
  }

  Future<void> removePurchasePoints(String customerUid, String orderId) async {
    await _db.collection(HubPaths.users).doc(customerUid).update({
      'points': FieldValue.increment(-50),
    });
    
    try {
      await _db.collection(HubPaths.users).doc(customerUid).collection('transactions').add({
        'title': 'অর্ডার বাতিল বা ফেরত (Order Cancelled/Returned)',
        'points': 50,
        'type': 'debit',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> handleDailyLoginBonus(String uid) async {
    final userDoc = await _db.collection(HubPaths.users).doc(uid).get();
    if (!userDoc.exists) return;
    
    final lastLoginStamp = userDoc.data()?['lastLoginBonus'];
    final now = DateTime.now();
    
    bool giveBonus = false;
    if (lastLoginStamp == null) {
      giveBonus = true;
    } else {
      final lastLogin = (lastLoginStamp as Timestamp).toDate();
      if (lastLogin.day != now.day || lastLogin.month != now.month || lastLogin.year != now.year) {
        giveBonus = true;
      }
    }
    
    if (giveBonus) {
      await _db.collection(HubPaths.users).doc(uid).update({
        'lastLoginBonus': FieldValue.serverTimestamp(),
      });
      await addPoints(uid, 'login', reason: 'দৈনিক লগইন বোনাস (Daily Login Bonus)');
    }
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
    final user = await _db.collection(HubPaths.users).doc(uid).get();
    final String? referredBy = user.data()?['referredBy'];
    if (referredBy != null) {
      await addPoints(referredBy, 'referral_bonus');
    }
  }
}
