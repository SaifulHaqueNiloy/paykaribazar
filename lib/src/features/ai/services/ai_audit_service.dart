import 'package:cloud_firestore/cloud_firestore.dart';

class AIAuditService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getAuditLogs() {
    return _db.collection('ai_audit_logs')
        .orderBy('timestamp', descending: true)
        .limit(1000)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> updateAuditStatus(String logId, String status) async {
    await _db.collection('ai_audit_logs').doc(logId).update({
      'status': status,
      'processedAt': FieldValue.serverTimestamp(),
    });
  }

  // Pure logic for grouping can be moved here if needed for non-UI use
}
