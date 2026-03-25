import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getDoctors() {
    return _firestore.collection(HubPaths.doctors).snapshots().map(
      (snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> addDoctor(Map<String, dynamic> doctorData) async {
    await _firestore.collection(HubPaths.doctors).add(doctorData);
  }
}
