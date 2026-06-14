import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/paths.dart';
import '../di/service_locator.dart';
import '../core/services/cache_service.dart';
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
        if (kDebugMode) debugPrint('Daily Login Bonus Error: $e');
      }
      await _cleanupOldData(user.uid);
      
      // DNA ENFORCED: Cache Locations locally for offline support
      await _cacheLocationsLocally();

      if (kDebugMode) debugPrint('Data Sync Completed');
    } catch (e) {
      if (kDebugMode) debugPrint('Sync Error: $e');
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
      if (kDebugMode) debugPrint('Notification cleanup error: $e');
    }
  }

  dynamic _sanitizeForJson(dynamic item) {
    if (item is Timestamp) {
      return item.toDate().toIso8601String();
    } else if (item is Map) {
      return item.map((k, v) => MapEntry(k.toString(), _sanitizeForJson(v)));
    } else if (item is List) {
      return item.map((e) => _sanitizeForJson(e)).toList();
    }
    return item;
  }

  Future<void> _cacheLocationsLocally() async {
    try {
      final snap = await _firestore.collection(HubPaths.locations).get();
      final locList = snap.docs.map((d) => d.data()).toList();
      final sanitizedList = _sanitizeForJson(locList);

      // Use CacheService to avoid redundant Hive initialization and box naming mismatch
      await getIt<CacheService>().set(
        key: 'cached_locations',
        value: sanitizedList,
        ttl: const Duration(days: 7),
      );
      
      if (kDebugMode) debugPrint('✅ Cached ${locList.length} locations locally');
    } catch (e) {
      if (kDebugMode) debugPrint('Location caching error: $e');
    }
  }
}
