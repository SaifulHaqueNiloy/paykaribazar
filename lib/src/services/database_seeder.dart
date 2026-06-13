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
        // Changed to Timestamp.now() because Firestore doesn't support FieldValue.serverTimestamp() inside lists/arrays
        'last_used': Timestamp.now(),
      },
      {
        'id': 'DeepSeek-V3-Executive',
        'provider': 'deepseek',
        'used_today': 0,
        'daily_limit': 2000,
        'status': 'active',
        'last_used': Timestamp.now(),
      },
      {
        'id': 'Gemini-2.0-Flash-Fallback',
        'provider': 'gemini',
        'used_today': 0,
        'daily_limit': 1500,
        'status': 'active',
        'last_used': Timestamp.now(),
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
          'content': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #00838F, #00ACC1); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(0, 131, 143, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">Our Trusted Partners</h3>
  </div>
  <p style="font-size: 14px; margin-bottom: 15px;">We collaborate with Bangladesh's top manufacturers, agricultural hubs, and international distributors to supply genuine high-quality items at factory wholesale prices.</p>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #00838F; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #00838F; font-size: 14px;">Agro & Farm Connect</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Direct sourcing of fresh vegetables and grains from organic local growers.</p>
  </div>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #00ACC1; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #00ACC1; font-size: 14px;">Consumer Brands Ltd</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Partnered for fast-moving consumer goods (FMCG) and household necessities.</p>
  </div>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #20B2AA; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #20B2AA; font-size: 14px;">Logistics Express</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Our delivery backbone ensuring secure and fast nationwide transport.</p>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #00838F, #00ACC1); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(0, 131, 143, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">আমাদের বিশ্বস্ত অংশীদারগণ</h3>
  </div>
  <p style="font-size: 14px; margin-bottom: 15px;">আমরা সরাসরি দেশের সেরা ফ্যাক্টরি, মূল উৎপাদক এবং আমদানিকারকদের সাথে কাজ করি যাতে আমাদের গ্রাহকরা সরাসরি পাইকারি মূল্যে আসল পণ্য পান।</p>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #00838F; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #00838F; font-size: 14px;">এগ্রো অ্যান্ড ফার্ম কানেক্ট</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">সরাসরি মাঠ পর্যায় থেকে রাসায়নিকমুক্ত তাজা শাকসবজি ও শস্য সরবরাহকারী।</p>
  </div>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #00ACC1; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #00ACC1; font-size: 14px;">কনজুমার ব্র্যান্ডস লিমিটেড</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">নিত্যপ্রয়োজনীয় মুদি ও বিশ্বমানের প্রসাধন সামগ্রী সরবরাহকারী পার্টনার।</p>
  </div>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #20B2AA; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #20B2AA; font-size: 14px;">লজিস্টিকস এক্সপ্রেস</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">আমাদের দেশের প্রতিটি কোণায় দ্রুত ও নিরাপদ পণ্য ডেলিভারি সেবাদাতা অংশীদার।</p>
  </div>
</div>
''',
        }
      },
      {
        'path': HubPaths.staffList,
        'data': {
          'content': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #37474F, #546E7A); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(55, 71, 79, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">Meet Our Core Team</h3>
  </div>
  <p style="font-size: 14px; margin-bottom: 15px;">Our dedicated operations, quality-assurance, customer success, and technology teams are active 24/7 to deliver seamless operations.</p>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #37474F; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #37474F; font-size: 14px;">Saiful Haq Niloy</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Founder & Chief Executive Officer</p>
  </div>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #546E7A; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #546E7A; font-size: 14px;">Operations Division</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Responsible for inventory sorting, sorting quality and packaging control.</p>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #37474F, #546E7A); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(55, 71, 79, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">আমাদের টিম (Meet Our Team)</h3>
  </div>
  <p style="font-size: 14px; margin-bottom: 15px;">পাইকারী বাজারকে প্রতিদিন সুন্দরভাবে পরিচালনা করতে আমাদের ব্যাক-অফিস ও ফিল্ড টিম নিরলস কাজ করছে।</p>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #37474F; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #37474F; font-size: 14px;">সাইফুল হক নিলয়</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">প্রতিষ্ঠাতা এবং প্রধান নির্বাহী কর্মকর্তা</p>
  </div>
  <div style="background: #F4F6F7; padding: 15px; border-radius: 12px; border-left: 5px solid #546E7A; margin-bottom: 12px;">
    <h4 style="margin: 0 0 5px 0; color: #546E7A; font-size: 14px;">অপারেশন ও কিউসি বিভাগ</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">পণ্যের মান নিয়ন্ত্রণ, শর্টিং এবং প্যাকিং তদারকিতে নিয়োজিত টিম।</p>
  </div>
</div>
''',
        }
      },
      {
        'path': HubPaths.faqs,
        'data': {
          'content': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #1565C0, #1E88E5); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(21, 101, 192, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">Frequently Asked Questions (FAQs)</h3>
  </div>
  
  <div style="background: #F8F9FA; padding: 16px; border-radius: 12px; margin-bottom: 15px; border-left: 5px solid #1E88E5; box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
    <h4 style="margin: 0 0 8px 0; color: #1565C0; font-size: 14px;">Q: What is the minimum order value?</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">A: Since this is a wholesale platform, the minimum checkout requirement is BDT 1,000.</p>
  </div>

  <div style="background: #F8F9FA; padding: 16px; border-radius: 12px; margin-bottom: 15px; border-left: 5px solid #1E88E5; box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
    <h4 style="margin: 0 0 8px 0; color: #1565C0; font-size: 14px;">Q: How do referral points work?</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">A: Copy your invite code from the Profile tab and share it. When users register and place their first order, you get points that can be redeemed as cash discounts.</p>
  </div>

  <div style="background: #F8F9FA; padding: 16px; border-radius: 12px; margin-bottom: 15px; border-left: 5px solid #1E88E5; box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
    <h4 style="margin: 0 0 8px 0; color: #1565C0; font-size: 14px;">Q: How long does delivery take?</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">A: Inside Dhaka: 24 hours. Outside Dhaka: 48-72 hours.</p>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #1565C0, #1E88E5); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(21, 101, 192, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">সাধারণ জিজ্ঞাসা (FAQs)</h3>
  </div>
  
  <div style="background: #F8F9FA; padding: 16px; border-radius: 12px; margin-bottom: 15px; border-left: 5px solid #1E88E5; box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
    <h4 style="margin: 0 0 8px 0; color: #1565C0; font-size: 14px;">প্রশ্ন: সর্বনিম্ন কত টাকার অর্ডার করতে হবে?</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">উত্তর: এটি একটি পাইকারি প্লাটফর্ম হওয়ায় সর্বনিম্ন অর্ডারের পরিমাণ ১,০০০ টাকা।</p>
  </div>

  <div style="background: #F8F9FA; padding: 16px; border-radius: 12px; margin-bottom: 15px; border-left: 5px solid #1E88E5; box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
    <h4 style="margin: 0 0 8px 0; color: #1565C0; font-size: 14px;">প্রশ্ন: রেফারেল পয়েন্ট কিভাবে কাজ করে?</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">উত্তর: প্রোফাইল ট্যাব থেকে আপনার ইনভাইট কোড কপি করে শেয়ার করুন। নতুন কোনো ইউজার সেই কোড দিয়ে সাইনআপ করে প্রথম অর্ডার সম্পন্ন করলে আপনি ফ্রি ডিসকাউন্ট পয়েন্ট পাবেন।</p>
  </div>

  <div style="background: #F8F9FA; padding: 16px; border-radius: 12px; margin-bottom: 15px; border-left: 5px solid #1E88E5; box-shadow: 0 2px 8px rgba(0,0,0,0.02);">
    <h4 style="margin: 0 0 8px 0; color: #1565C0; font-size: 14px;">প্রশ্ন: পণ্য পৌঁছাতে কত সময় লাগে?</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">উত্তর: ঢাকা সিটির ভেতরে ২৪ ঘণ্টা এবং ঢাকার বাইরে ৪৮ থেকে ৭২ ঘণ্টার মধ্যে ডেলিভারি সম্পন্ন হয়।</p>
  </div>
</div>
''',
        }
      },
      {
        'path': HubPaths.aboutUs,
        'data': {
          'content': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #E65100, #F57C00); padding: 25px 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(230, 81, 0, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">About Paykari Bazar</h3>
    <p style="margin: 5px 0 0 0; font-size: 12px; opacity: 0.9;">Empowering local businesses since 2024</p>
  </div>
  <p style="font-size: 14px;"><b>Paykari Bazar</b> is Bangladesh's pioneering digital B2B wholesale platform. We connect local retailers directly with factories, farmers, and main suppliers to eliminate unnecessary middle-man costs.</p>
  <p style="font-size: 14px;">Our state-of-the-art tech ecosystem simplifies order processing, secures digital escrow payments, and manages quick last-mile logistics. We enable micro-merchants and reseller entrepreneurs to launch and grow their ventures with zero stock investment.</p>
  <div style="background: #FFF8F3; padding: 15px; border-radius: 12px; border: 1px solid #FFE0B2; margin-top: 15px;">
    <h4 style="margin: 0 0 5px 0; color: #E65100; font-size: 14px;">Our Vision</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">To build a transparent, highly efficient, and integrated supply-chain network serving every corner of Bangladesh.</p>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #E65100, #F57C00); padding: 25px 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(230, 81, 0, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">আমাদের সম্পর্কে (About Us)</h3>
    <p style="margin: 5px 0 0 0; font-size: 12px; opacity: 0.9;">২০২৪ থেকে খুচরা বিক্রেতা ও ক্ষুদ্র উদ্যোগের ডিজিটাল প্ল্যাটফর্ম</p>
  </div>
  <p style="font-size: 14px;"><b>পাইকারী বাজার</b> হলো বাংলাদেশের প্রথম সারির ডিজিটাল বিটুবি (B2B) পাইকারি প্ল্যাটফর্ম। আমরা দেশের প্রতিটি প্রান্তের খুচরা বিক্রেতা ও ব্যবসায়ীদের সরাসরি কারখানা, খামারি এবং মূল আমদানিকারকদের সাথে যুক্ত করি।</p>
  <p style="font-size: 14px;">আমাদের আধুনিক প্রযুক্তি সিস্টেমের মাধ্যমে অতি সহজে পাইকারি কেনাকাটা, নিরাপদ ডিজিটাল পেমেন্ট এবং দ্রুত লজিস্টিকস ডেলিভারি সেবা প্রদান করা হয়। এছাড়া আমরা রিসেলারদের জন্য বিনা পুঁজিতে ব্যবসা শুরু করার অনন্য সুযোগ তৈরি করেছি।</p>
  <div style="background: #FFF8F3; padding: 15px; border-radius: 12px; border: 1px solid #FFE0B2; margin-top: 15px;">
    <h4 style="margin: 0 0 5px 0; color: #E65100; font-size: 14px;">আমাদের মূল লক্ষ্য</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">সমগ্র বাংলাদেশে একটি স্বচ্ছ, সাশ্রয়ী এবং সম্পূর্ণ নির্ভরযোগ্য পাইকারি বাজার নেটওয়ার্ক গড়ে তোলা।</p>
  </div>
</div>
''',
        }
      },
      {
        'path': HubPaths.termsConditions,
        'data': {
          'content': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #4E342E, #6D4C41); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(78, 52, 46, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">Terms & Conditions</h3>
  </div>
  <div style="margin-bottom: 15px; padding-bottom: 12px; border-bottom: 1px solid #E5E8E8;">
    <h4 style="margin: 0 0 5px 0; color: #4E342E; font-size: 14px;">1. Wholesale Purchase Agreement</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Products listed here are strictly for wholesale and commercial trade. Minimum billing per check-out is BDT 1,000.</p>
  </div>
  <div style="margin-bottom: 15px; padding-bottom: 12px; border-bottom: 1px solid #E5E8E8;">
    <h4 style="margin: 0 0 5px 0; color: #4E342E; font-size: 14px;">2. Pricing & Quotations</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Wholesale rates depend on market availability and factory tariffs. Listed rates are subject to change without prior notice.</p>
  </div>
  <div style="margin-bottom: 15px; padding-bottom: 12px; border-bottom: 1px solid #E5E8E8;">
    <h4 style="margin: 0 0 5px 0; color: #4E342E; font-size: 14px;">3. Returns Policy</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">Damaged or mis-shipped goods must be claimed with clear video proof within 48 hours of shipment delivery.</p>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #4E342E, #6D4C41); padding: 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(78, 52, 46, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">ব্যবহারের শর্তাবলী (Terms & Conditions)</h3>
  </div>
  <div style="margin-bottom: 15px; padding-bottom: 12px; border-bottom: 1px solid #E5E8E8;">
    <h4 style="margin: 0 0 5px 0; color: #4E342E; font-size: 14px;">১. পাইকারি কেনাকাটার চুক্তি</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">এই প্ল্যাটফর্মে সকল পণ্য শুধুমাত্র বাণিজ্যিক ব্যবহারের উদ্দেশ্যে পাইকারি মূল্যে বিক্রি হয়। সর্বনিম্ন অর্ডারের পরিমাণ ১,০০০ টাকা।</p>
  </div>
  <div style="margin-bottom: 15px; padding-bottom: 12px; border-bottom: 1px solid #E5E8E8;">
    <h4 style="margin: 0 0 5px 0; color: #4E342E; font-size: 14px;">২. পণ্য মূল্য ও স্টক</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">বাজারের কাঁচামাল ও উৎপাদন ব্যয়ের ওপর ভিত্তি করে পণ্যের দাম পরিবর্তিত হতে পারে। যেকোনো দাম পরিবর্তনের অধিকার কর্তৃপক্ষ সংরক্ষণ করে।</p>
  </div>
  <div style="margin-bottom: 15px; padding-bottom: 12px; border-bottom: 1px solid #E5E8E8;">
    <h4 style="margin: 0 0 5px 0; color: #4E342E; font-size: 14px;">৩. রিটার্ন ও রিফান্ড নীতি</h4>
    <p style="margin: 0; font-size: 13px; color: #566573;">কোনো পণ্য ভাঙা বা ভুল ডেলিভারি হলে, তা বুঝে পাওয়ার ৪৮ ঘণ্টার মধ্যে আনবক্সিং ভিডিও প্রমাণ সহ কাস্টমার কেয়ারে ক্লেইম করতে হবে।</p>
  </div>
</div>
''',
        }
      },
      {
        'path': HubPaths.howToUse,
        'data': {
          'content': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #4A148C, #7B1FA2); padding: 25px 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(74, 20, 140, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">How to Use Paykari Bazar</h3>
    <p style="margin: 5px 0 0 0; font-size: 12px; opacity: 0.9;">Master the app features in minutes</p>
  </div>
  
  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #FF6F00;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #FF6F00; font-size: 14px;">1. Browse & Add to Cart</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">Explore categorized products, search for top wholesale deals, and add items to your cart. Look out for bulk pack discounts!</p>
    </div>
  </div>

  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #00C853;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #00C853; font-size: 14px;">2. Apply Coupons & Redeem Points</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">During checkout, write valid promo codes or tap to redeem your referral points to earn immediate discounts.</p>
    </div>
  </div>

  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #2979FF;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #2979FF; font-size: 14px;">3. Smart Payments</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">Use Cash on Delivery (COD), Mobile Banking (bKash/Nagad), or your in-app Wallet. Top up your wallet in the Profile tab for single-tap payment convenience.</p>
    </div>
  </div>

  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #AA00FF;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #AA00FF; font-size: 14px;">4. Join & Earn (Reseller / Rider / Staff)</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">Apply to become a <b>Reseller</b> to sell items and earn margins, a <b>Rider</b> to deliver products and earn delivery bonuses, or <b>Staff</b> to help manage local operations. Apply easily from the Profile tab!</p>
    </div>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: 'Helvetica Neue', Arial, sans-serif; line-height: 1.7; color: #2C3E50;">
  <div style="background: linear-gradient(135deg, #4A148C, #7B1FA2); padding: 25px 20px; border-radius: 14px; color: white; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(74, 20, 140, 0.15);">
    <h3 style="margin: 0; font-size: 18px; font-weight: 750;">কিভাবে পাইকারী বাজার ব্যবহার করবেন</h3>
    <p style="margin: 5px 0 0 0; font-size: 12px; opacity: 0.9;">অ্যাপের প্রতিটি ফিচারের সহজ ও বিস্তারিত নির্দেশিকা</p>
  </div>
  
  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #FF6F00;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #FF6F00; font-size: 14px;">১. পণ্য খুঁজুন ও কার্টে যুক্ত করুন</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">প্রয়োজনীয় ক্যাটাগরি অনুযায়ী পণ্য ব্রাউজ করুন অথবা সরাসরি সার্চ করুন। পণ্যের পাইকারি লট বা প্যাক সাইজ অনুযায়ী কার্টে যুক্ত করুন।</p>
    </div>
  </div>

  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #00C853;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #00C853; font-size: 14px;">২. কুপন ও পয়েন্ট রিডিম</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">চেকআউট পেজে গিয়ে আপনার একটিভ প্রমো কোড/কুপন লিখুন অথবা আপনার প্রোফাইলে জমানো রেফারেল পয়েন্ট রিডিম করে বিল কমিয়ে নিন।</p>
    </div>
  </div>

  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #2979FF;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #2979FF; font-size: 14px;">৩. সহজ পেমেন্ট মাধ্যম</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">ক্যাশ অন ডেলিভারি (COD), মোবাইল ব্যাংকিং (বিকাশ/নগদ) অথবা ইন-অ্যাপ ওয়ালেটের মাধ্যমে তাত্ক্ষণিক বিল পরিশোধ করুন। সহজে ওয়ালেট রিচার্জ করে এক ক্লিকে অর্ডার করতে পারেন।</p>
    </div>
  </div>

  <div style="display: flex; margin-bottom: 15px; background: #F8F9FA; padding: 15px; border-radius: 12px; border-left: 5px solid #AA00FF;">
    <div style="flex: 1;">
      <h4 style="margin: 0 0 5px 0; color: #AA00FF; font-size: 14px;">৪. যুক্ত হোন ও আয় করুন (রিসেলার / রাইডার / স্টাফ)</h4>
      <p style="margin: 0; font-size: 13px; color: #566573;">কোনো মূলধন ছাড়া লভ্যাংশ আয় করতে প্রোফাইল ট্যাব থেকে <b>রিসেলার</b>, পণ্য ডেলিভারি দিয়ে আয় করতে <b>রাইডার</b> অথবা আমাদের সাথে সরাসরি যুক্ত হতে <b>স্টাফ</b> হিসেবে আবেদন করুন।</p>
    </div>
  </div>
</div>
''',
        }
      }
    ];

    for (var item in items) {
      batch.set(firestore.doc(item['path']), item['data'], SetOptions(merge: true));
    }
    await batch.commit();
  }
}
