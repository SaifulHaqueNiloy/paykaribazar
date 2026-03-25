import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_service.dart';
import '../../../shared/services/media_service.dart';

class AiCommandService {
  final AIService _ai;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AiCommandService({
    required AIService ai,
    required MediaService media,
  }) : _ai = ai;

  Future<String> execute(String command) async {
    final action = await _ai.processCommand(command);

    try {
      switch (action['action']) {
        case 'change_theme_mood':
          return await _applyThemeMood(action['mood']);
        case 'change_theme_color':
          return await _updateThemeColor(action['color_hex']);
        case 'toggle_feature':
          return await _toggleFeature(action['feature_key'], action['state']);
        case 'update_product_price':
          return await _bulkUpdatePrice(action);
        case 'send_notification':
          return await _sendGlobalNotification(action);
        case 'update_secrets':
          return await _updateSecrets(action);
        default:
          return "Action '${action['action']}' recognized but logic not yet implemented.";
      }
    } catch (e) {
      return 'Execution error: $e';
    }
  }

  Future<String> _applyThemeMood(String mood) async {
    final Map<String, String> palette = {
      'sunny': '0xFFFFC107',
      'rainy': '0xFF455A64',
      'cloudy': '0xFF90A4AE',
      'winter': '0xFFE3F2FD',
      'festive': '0xFFD32F2F',
      'night': '0xFF1A237E',
    };
    final color = palette[mood] ?? '0xFF6200EE';
    await _db.collection('settings').doc('app_config').set(
        {'primary_color': color, 'active_mood': mood}, SetOptions(merge: true));
    return "App theme set to '$mood'.";
  }

  Future<String> _updateThemeColor(String hex) async {
    await _db
        .collection('settings')
        .doc('app_config')
        .set({'primary_color': hex}, SetOptions(merge: true));
    return 'Theme color updated.';
  }

  Future<String> _toggleFeature(String key, bool state) async {
    await _db.collection('settings').doc('app_config').update({key: state});
    return "Feature '$key' is now ${state ? 'ENABLED' : 'DISABLED'}.";
  }

  Future<String> _bulkUpdatePrice(Map<String, dynamic> data) async {
    final int discount = data['discount_percent'] ?? 0;
    final String cat = data['category'] ?? 'all';

    Query query = _db.collection('products');
    if (cat != 'all') query = query.where('categoryName', isEqualTo: cat);

    final snap = await query.get();
    final batch = _db.batch();
    for (var doc in snap.docs) {
      final oldPrice = (doc['price'] ?? 0).toDouble();
      final newPrice = oldPrice * (1 - (discount / 100));
      batch.update(doc.reference, {'price': newPrice, 'oldPrice': oldPrice});
    }
    await batch.commit();
    return "Applied $discount% discount to ${snap.size} products in '$cat'.";
  }

  Future<String> _sendGlobalNotification(Map<String, dynamic> data) async {
    final String target = data['target'] ?? 'all';
    final String title = data['title'] ?? 'Notice from Admin';
    final String body = data['body'] ?? '';

    await _db.collection('ai_notifications_queue').add({
      'title': title,
      'body': body,
      'target': target,
      'status': 'pending_approval',
      'type': 'global_ai_broadcast',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return 'Notification queued for approval.';
  }

  Future<String> _updateSecrets(Map<String, dynamic> data) async {
    final key = data['key'];
    final value = data['value'];
    if (key == null || value == null) return 'Missing key or value.';
    await _db
        .collection('settings')
        .doc('secrets')
        .set({key: value}, SetOptions(merge: true));
    return "Secret '$key' updated.";
  }
}
