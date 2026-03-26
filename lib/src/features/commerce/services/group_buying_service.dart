import 'package:cloud_firestore/cloud_firestore.dart';
import '../../ai/services/ai_service.dart';
import '../../../di/service_locator.dart';

class GroupBuyingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AIService _ai = getIt<AIService>();

  /// Creates or joins a group buying session for a specific product and area
  Future<void> joinOrCreateGroup({
    required String productId,
    required String userId,
    required String userName,
    required String stationId,
  }) async {
    final groupQuery = await _db.collection('group_buys')
        .where('productId', isEqualTo: productId)
        .where('stationId', isEqualTo: stationId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (groupQuery.docs.isEmpty) {
      // Create new group
      await _db.collection('group_buys').add({
        'productId': productId,
        'stationId': stationId,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'expiryAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
        'members': [
          {'uid': userId, 'name': userName}
        ],
        'currentDiscount': 2.0, // Starting discount
      });
    } else {
      // Join existing group
      final doc = groupQuery.docs.first;
      final members = List.from(doc['members']);
      
      if (members.any((m) => m['uid'] == userId)) return; // Already in group

      members.add({'uid': userId, 'name': userName});
      
      // AI Logic to calculate new discount based on group size
      final newDiscount = await _calculateAiDiscount(members.length);

      await doc.reference.update({
        'members': members,
        'currentDiscount': newDiscount,
      });
    }
  }

  Future<double> _calculateAiDiscount(int memberCount) async {
    final prompt = 'Calculate a fair group discount percentage for $memberCount buyers in the same area. Logistics savings are shared. Return only a number.';
    final res = await _ai.generateResponse(prompt);
    return double.tryParse(res.replaceAll(RegExp(r'[^0-9.]'), '')) ?? (memberCount * 1.5).clamp(2.0, 15.0);
  }

  Stream<List<Map<String, dynamic>>> getActiveGroups(String stationId) {
    return _db.collection('group_buys')
        .where('stationId', isEqualTo: stationId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
