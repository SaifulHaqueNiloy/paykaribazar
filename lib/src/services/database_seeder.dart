import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/paths.dart';

class DatabaseSeeder {
  static Future<void> seedAll() async {
    await seedLocations();
    await seedAiQuota();
  }

  static Future<void> seedAiQuota() async {
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('settings').doc('api_quota');

    final List<Map<String, dynamic>> keys = [
      {
        'id': 'Kimi-k2.5-Primary',
        'provider': 'nvidia',
        'used_today': 0,
        'daily_limit': 5000,
        'status': 'active',
        'last_used': FieldValue.serverTimestamp(),
      },
      {
        'id': 'DeepSeek-V3-Executive',
        'provider': 'deepseek',
        'used_today': 0,
        'daily_limit': 2000,
        'status': 'active',
        'last_used': FieldValue.serverTimestamp(),
      },
      {
        'id': 'Gemini-2.0-Flash-Fallback',
        'provider': 'gemini',
        'used_today': 0,
        'daily_limit': 1500,
        'status': 'active',
        'last_used': FieldValue.serverTimestamp(),
      }
    ];

    await docRef.set({'keys': keys}, SetOptions(merge: true));
  }

  static Future<void> seedLocations() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final List<Map<String, dynamic>> districts = [
      {'id': 'dhaka', 'name': 'Dhaka', 'type': 'district', 'isVisible': true},
      {'id': 'chattogram', 'name': 'Chattogram', 'type': 'district', 'isVisible': true},
      {'id': 'sylhet', 'name': 'Sylhet', 'type': 'district', 'isVisible': true},
    ];

    final List<Map<String, dynamic>> upazilas = [
      {'id': 'dhanmondi', 'name': 'Dhanmondi', 'type': 'upazila', 'parentId': 'dhaka', 'isVisible': true},
      {'id': 'mirpur', 'name': 'Mirpur', 'type': 'upazila', 'parentId': 'dhaka', 'isVisible': true},
      {'id': 'panchlaish', 'name': 'Panchlaish', 'type': 'upazila', 'parentId': 'chattogram', 'isVisible': true},
    ];

    for (var d in districts) {
      batch.set(firestore.collection(HubPaths.locations).doc(d['id']), d);
    }
    for (var u in upazilas) {
      batch.set(firestore.collection(HubPaths.locations).doc(u['id']), u);
    }

    await batch.commit();
  }
}
