import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/paths.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SyncService();

  /// Main sync entry point called at app startup
  Future<void> syncData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Sync User Presence/Last Seen
      await _updateUserPresence(user.uid);

      // 2. Clear expired notifications or temp data
      await _cleanupOldData(user.uid);

      debugPrint('Data Sync Completed for user: ${user.uid}');
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
    // Example: Delete notifications older than 30 days
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final oldNotifs = await _firestore.collection(HubPaths.notifications)
        .where('userId', isEqualTo: uid)
        .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    if (oldNotifs.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in oldNotifs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
