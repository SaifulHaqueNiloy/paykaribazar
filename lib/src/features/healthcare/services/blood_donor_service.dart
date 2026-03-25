import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';

class BloodDonorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getDonors() {
    return _firestore.collection(HubPaths.donors).snapshots().map(
      (snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> registerDonor(Map<String, dynamic> donorData) async {
    await _firestore.collection(HubPaths.donors).add(donorData);
  }

  Future<void> requestBlood(Map<String, dynamic> requestData) async {
    // In a real app, this might send notifications to nearby donors
    await _firestore.collection('blood_requests').add({
      ...requestData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
