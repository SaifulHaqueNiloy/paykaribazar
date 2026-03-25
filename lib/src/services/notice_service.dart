import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    return NoticeModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NoticeModel>> getNotices() {
    return _firestore
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => NoticeModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addNotice(String title, String message, [String? imageUrl]) async {
    await _firestore.collection('notices').add({
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNotice(String id) async {
    await _firestore.collection('notices').doc(id).delete();
  }
}
