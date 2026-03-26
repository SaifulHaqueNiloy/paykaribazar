import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fleet_model.dart';

// Shorebird is only available on mobile platforms
// Avoid direct import to prevent compile errors on desktop/web
// During mobile builds, uncomment the import below and update getShorebirdStatus()
// import 'package:shorebird_code_push/shorebird_code_push.dart';

class FleetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Live rider tracking
  Stream<List<Rider>> getActiveRiders() {
    return _db.collection('riders')
      .where('isOnline', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map((d) => Rider.fromFirestore(d)).toList());
  }
  
  // Vehicle status
  Stream<FleetStatus> getFleetStatus() {
    return _db.collection('fleet_stats').doc('current').snapshots()
      .map((s) => FleetStatus.fromFirestore(s));
  }
  
  /// Get Shorebird patch status
  /// On mobile platforms, this can call the actual Shorebird SDK
  /// On desktop/web, it falls back to Firestore
  Future<ShorebirdStatus> getShorebirdStatus() async {
    try {
      // Platform check - Shorebird only works on mobile
      // Skip Shorebird SDK calls on desktop/web platforms
      if (!kIsWeb) {
        // Potentially on mobile - Shorebird SDK could be called here
        // Uncomment when on mobile:
        // final shorebird = ShorebirdCodePush();
        // final isAvailable = await shorebird.isAvailable();
        // if (isAvailable) {
        //   final currentPatch = await shorebird.currentPatchNumber();
        //   final hasUpdate = await shorebird.checkForUpdate();
        //   return ShorebirdStatus(...);
        // }
      }
      
      // Fallback: Get status from Firestore (works everywhere)
      final doc = await _db.collection('settings').doc('shorebird').get();
      if (doc.exists) {
        final data = doc.data()!;
        return ShorebirdStatus(
          currentVersion: data['currentVersion'] ?? '1.0.0',
          patchInstalled: data['patchInstalled'] ?? false,
          lastPatchTime: (data['lastPatchTime'] as Timestamp?)?.toDate(),
          shorebirdAvailable: data['shorebirdAvailable'] ?? true,
        );
      }
    } catch (e) {
      debugPrint('[FleetService] Status check failed: $e');
    }
    
    // Final fallback - stub data
    return ShorebirdStatus(
      currentVersion: '1.0.0',
      patchInstalled: false,
    );
  }
}

