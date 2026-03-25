import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../models/fleet_model.dart';

class FleetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _shorebirdCodePush = ShorebirdCodePush();

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
    final isPatchInstalled = await _shorebirdCodePush.isNewPatchInstalled();
    final currentPatch = await _shorebirdCodePush.currentPatchNumber();
    
    return ShorebirdStatus(
      currentVersion: currentPatch?.toString() ?? '1.0.0',
      patchInstalled: isPatchInstalled,
      lastPatchTime: DateTime.now(), // Shorebird doesn't provide exact time easily
    );
  }
}
