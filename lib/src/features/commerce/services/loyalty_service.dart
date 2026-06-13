import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/paths.dart';

class LoyaltyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getPointsEarnedSinceLastSeen(String uid) async {
    final doc = await _db.collection(HubPaths.users).doc(uid).get();
    return doc.data()?['pendingPoints'] ?? 0;
  }

  Future<void> addPoints(String uid, String type, {String? reason}) async {
    int earned = 10;
    String description = '';

    // Fetch dynamic values from database settings
    // বাংলা: ডাটাবেস থেকে পয়েন্টের মান নিয়ে আসা হচ্ছে
    try {
      final settings = await _db.doc(HubPaths.loyaltyDoc).get();
      final data = settings.data();
      
      if (type == 'signupPoints' || type == 'signup') {
        earned = (data?['signupPoints'] ?? data?['signup_bonus'] ?? 100).toInt();
        description = reason ?? 'স্বাগতম বোনাস (Welcome Bonus)';
      } else if (type == 'purchase') {
        earned = (data?['purchasePoints'] ?? 50).toInt();
        description = reason ?? 'কেনাকাটার রিওয়ার্ড (Purchase Reward)';
      } else if (type == 'referral_bonus') {
        earned = (data?['referralPoints'] ?? 50).toInt();
        description = reason ?? 'রেফারেল বোনাস (Referral Bonus)';
      } else if (type == 'login') {
        earned = (data?['loginPoints'] ?? 10).toInt();
        description = reason ?? 'দৈনিক লগইন বোনাস (Daily Login Bonus)';
      }
    } catch (e) {
      debugPrint('Error fetching loyalty settings: $e');
      // Fallback defaults if database fails
      if (type == 'signupPoints' || type == 'signup') earned = 100;
    }

    // USE FIRESTORE TRANSACTION TO PREVENT RACE CONDITIONS (Point #9 from Audit)
    // বাংলা: ট্রানজেকশন ব্যবহার করে একই সময় একাধিক পয়েন্ট যোগ হওয়া বন্ধ করা হয়েছে
    try {
      await _db.runTransaction((transaction) async {
        final userRef = _db.collection(HubPaths.users).doc(uid);
        final userSnap = await transaction.get(userRef);

        if (userSnap.exists) {
          transaction.update(userRef, {
            'points': FieldValue.increment(earned),
            'lastPointUpdate': FieldValue.serverTimestamp(),
          });

          final transRef = userRef.collection('transactions').doc();
          transaction.set(transRef, {
            'title': description,
            'points': earned,
            'type': 'credit',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      debugPrint('Loyalty transaction failed: $e');
    }
  }

  Future<void> removePurchasePoints(String customerUid, String orderId) async {
    int earned = 50;
    try {
      // বাংলা: ডেটাবেজ সেটিংস থেকে ডাইনামিক পয়েন্ট মান লোড করা হচ্ছে
      final settings = await _db.doc(HubPaths.loyaltyDoc).get();
      final data = settings.data();
      earned = (data?['purchasePoints'] ?? 50).toInt();
    } catch (_) {
      // Fallback
    }

    await _db.collection(HubPaths.users).doc(customerUid).update({
      'points': FieldValue.increment(-earned),
    });
    
    try {
      await _db.collection(HubPaths.users).doc(customerUid).collection('transactions').add({
        'title': 'অর্ডার বাতিল বা ফেরত (Order Cancelled/Returned)',
        'points': earned,
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
    final String? referredByUid = user.data()?['referredByUid'];
    if (referredByUid == null || referredByUid.isEmpty) return;

    await _db.runTransaction((tx) async {
      final referrerRef = _db.collection(HubPaths.users).doc(referredByUid);
      final referrerSnap = await tx.get(referrerRef);

      if (!referrerSnap.exists) return;

      final currentPoints = (referrerSnap.data()?['points'] ?? 0) as int;
      final newPoints = currentPoints + 50;
      final claimedCount = (referrerSnap.data()?['referredCount'] ?? 0) as int;

      tx.update(referrerRef, {
        'points': newPoints,
        'referredCount': claimedCount + 1,
        'lastPointUpdate': FieldValue.serverTimestamp(),
      });

      final transactionRef = referrerRef.collection('transactions').doc();
      tx.set(transactionRef, {
        'title': 'রেফারেল বোনাস (Referral Bonus)',
        'points': 50,
        'type': 'credit',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
