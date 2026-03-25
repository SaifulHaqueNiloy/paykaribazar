import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fleet_model.dart';

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
  
  // Shorebird patch status
  Future<ShorebirdStatus> getShorebirdStatus() async {
    try {
      final doc = await _db.collection('settings').doc('shorebird').get();
      if (doc.exists) {
        final data = doc.data()!;
        return ShorebirdStatus(
          currentVersion: data['currentVersion'] ?? '1.0.0',
          patchInstalled: data['patchInstalled'] ?? false,
          lastPatchTime: (data['lastPatchTime'] as Timestamp?)?.toDate(),
        );
      }
    } catch (e) {
      // Fallback
    }
    return ShorebirdStatus(
      currentVersion: '1.0.0',
      patchInstalled: false,
    );
  }
}
