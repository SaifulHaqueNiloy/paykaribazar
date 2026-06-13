import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/paths.dart';
import '../di/service_locator.dart';
import '../features/commerce/services/loyalty_service.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SyncService();

  Future<void> syncData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _updateUserPresence(user.uid);
      try {
        await getIt<LoyaltyService>().handleDailyLoginBonus(user.uid);
      } catch (e) {
        debugPrint('Daily Login Bonus Error: $e');
      }
      await _cleanupOldData(user.uid);
      
      // DNA ENFORCED: Cache Locations locally for offline support
      await _cacheLocationsLocally();

      debugPrint('Data Sync Completed');
    } catch (e) {
      debugPrint('Sync Error: $e');
    }
  }

  Future<void> _updateUserPresence(String uid) async {
    await _firestore.collection(HubPaths.users).doc(uid).update({
      'lastSeen': FieldValue.serverTimestamp(),
      'isOnline': true,
    });
  }

  Future<void> _cleanupOldData(String uid) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final allUserNotifs = await _firestore.collection(HubPaths.notifications)
          .where('userId', isEqualTo: uid)
          .get();

      if (allUserNotifs.docs.isNotEmpty) {
        final oldDocs = allUserNotifs.docs.where((doc) {
          final createdAt = doc.data()['createdAt'];
          if (createdAt is Timestamp) {
            return createdAt.toDate().isBefore(thirtyDaysAgo);
          }
          return false;
        }).toList();

        if (oldDocs.isNotEmpty) {
          final batch = _firestore.batch();
          for (var doc in oldDocs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
        }
      }
    } catch (e) {
      debugPrint('Notification cleanup error: $e');
    }
  }

  Future<void> _cacheLocationsLocally() async {
    try {
      final snap = await _firestore.collection(HubPaths.locations).get();
      await Hive.initFlutter();
      final box = await Hive.openBox('app_cache');
      final locList = snap.docs.map((d) => d.data()).toList();
      await box.put('cached_locations', locList);
      debugPrint('✅ Cached ${locList.length} locations locally');
    } catch (e) {
      debugPrint('Location caching error: $e');
    }
  }
}
