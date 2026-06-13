import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/paths.dart';

class DatabaseSeeder {
  static Future<void> seedAll() async {
    await seedLocations();
    await seedAiQuota();
    await seedStaticInfo();
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

  static Future<void> seedStaticInfo() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final List<Map<String, dynamic>> items = [
      {
        'path': HubPaths.partners,
        'data': {
          'content': '<h3>Our Partners</h3><p>We work with trusted brands to bring you the best wholesale products.</p>',
          'contentBn': '<h3>আমাদের পার্টনার</h3><p>আমরা আপনাদের কাছে সেরা পাইকারি পণ্য পৌঁছে দিতে বিশ্বস্ত ব্র্যান্ডগুলোর সাথে কাজ করছি।</p>',
        }
      },
      {
        'path': HubPaths.staffList,
        'data': {
          'content': '<h3>Our Staff</h3><p>Meet our support staff, account managers, and logistics team.</p>',
          'contentBn': '<h3>আমাদের স্টাফবৃন্দ</h3><p>আমাদের ডেডিকেটেড কাস্টমার সাপোর্ট, অ্যাকাউন্টস ম্যানেজার এবং লজিস্টিকস টিমের তালিকা নিচে দেওয়া হলো।</p>',
        }
      },
      {
        'path': HubPaths.faqs,
        'data': {
          'content': '<h3>FAQs</h3><p>Find answers to common questions about orders, payments, and delivery.</p>',
          'contentBn': '<h3>সাধারণ জিজ্ঞাসা (FAQs)</h3><p>পণ্য অর্ডার, পেমেন্ট পদ্ধতি এবং ডেলিভারি সংক্রান্ত সাধারণ জিজ্ঞাসাগুলোর উত্তর এখানে পাবেন।</p>',
        }
      },
      {
        'path': HubPaths.aboutUs,
        'data': {
          'content': '<h3>About Us</h3><p>Paykari Bazar is the leading wholesale e-commerce platform in Bangladesh.</p>',
          'contentBn': '<h3>আমাদের সম্পর্কে</h3><p>পাইকারী বাজার হলো বাংলাদেশের অন্যতম বৃহত্তম এবং বিশ্বস্ত পাইকারি অনলাইন মার্কেটপ্লেস।</p>',
        }
      },
      {
        'path': HubPaths.termsConditions,
        'data': {
          'content': '<h3>Terms & Conditions</h3><p>Read our wholesale policies and trade terms before ordering.</p>',
          'contentBn': '<h3>শর্তাবলী</h3><p>পাইকারী বাজার ব্যবহারের পূর্বে অনুগ্রহ করে আমাদের ব্যবসায়ের নীতিমালা ও নিয়মাবলি দেখে নিন।</p>',
        }
      },
      {
        'path': HubPaths.howToUse,
        'data': {
          'content': '<h3>How to Use</h3><p>Follow our tutorial to easily start buying, managing, and tracking wholesale orders.</p>',
          'contentBn': '<h3>কিভাবে ব্যবহার করবেন</h3><p>খুব সহজে পাইকারী বাজারে কেনাকাটা করা, অর্ডার ট্র্যাক করা এবং পেমেন্ট করার ধাপগুলো নিচে দেখানো হলো।</p>',
        }
      }
    ];

    for (var item in items) {
      batch.set(firestore.doc(item['path']), item['data'], SetOptions(merge: true));
    }
    await batch.commit();
  }
}
