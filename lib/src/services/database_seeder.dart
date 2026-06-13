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
          'content': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #00838F, #00ACC1); padding: 15px; border-radius: 10px; color: white; margin-bottom: 15px;">
    <h3 style="margin: 0;">Our Trusted Partners</h3>
  </div>
  <p>We collaborate with Bangladesh's top manufacturers, agricultural hubs, and international distributors to supply genuine high-quality items at factory wholesale prices.</p>
  <ul>
    <li><b>Agro & Farm Connect:</b> Direct sourcing of fresh vegetables and grains.</li>
    <li><b>Consumer Brands Ltd:</b> Partnered for fast-moving consumer goods (FMCG).</li>
    <li><b>Logistics Express:</b> Our delivery backbone for nationwide transport.</li>
  </ul>
</div>
''',
          'contentBn': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #00838F, #00ACC1); padding: 15px; border-radius: 10px; color: white; margin-bottom: 15px;">
    <h3 style="margin: 0;">আমাদের বিশ্বস্ত অংশীদারগণ</h3>
  </div>
  <p>আমরা সরাসরি ফ্যাক্টরি এবং মূল উৎপাদকদের সাথে কাজ করি যাতে আমাদের গ্রাহকরা সেরা মূল্যে পণ্য পান।</p>
  <ul>
    <li><b>এগ্রো অ্যান্ড ফার্ম কানেক্ট:</b> সরাসরি মাঠ পর্যায় থেকে তাজা শাকসবজি ও শস্য সরবরাহকারী।</li>
    <li><b>কনজুমার ব্র্যান্ডস লিমিটেড:</b> নিত্যপ্রয়োজনীয় মুদি ও কসমেটিক পণ্য সরবরাহকারী পার্টনার।</li>
    <li><b>লজিস্টিকস এক্সপ্রেস:</b> সারা বাংলাদেশে দ্রুত পণ্য পৌঁছানোর অন্যতম সহযোগী।</li>
  </ul>
</div>
''',
        }
      },
      {
        'path': HubPaths.staffList,
        'data': {
          'content': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #37474F, #546E7A); padding: 15px; border-radius: 10px; color: white; margin-bottom: 15px;">
    <h3 style="margin: 0;">Meet Our Core Team</h3>
  </div>
  <p>Our dedicated operations, quality-assurance, customer success, and technology teams are active 24/7 to deliver seamless operations.</p>
  <ul>
    <li><b>Saiful Haq Niloy</b> - Founder & Chief Executive Officer</li>
    <li><b>Operations Division</b> - Managing inventory & quality inspections</li>
    <li><b>Support Stars</b> - Resolving tickets and chats in real time</li>
    <li><b>Rider Force</b> - Swiftly carrying goods safely to your doorstep</li>
  </ul>
</div>
''',
          'contentBn': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #37474F, #546E7A); padding: 15px; border-radius: 10px; color: white; margin-bottom: 15px;">
    <h3 style="margin: 0;">আমাদের মূল দল (Team)</h3>
  </div>
  <p>আপনার প্রতিটি অর্ডার সময়মতো এবং সঠিকভাবে পৌঁছানোর পেছনে কাজ করছে আমাদের দক্ষ টিম।</p>
  <ul>
    <li><b>সাইফুল হক নিলয়</b> - প্রতিষ্ঠাতা এবং প্রধান নির্বাহী কর্মকর্তা</li>
    <li><b>অপারেশন বিভাগ</b> - গুণগত মান নিয়ন্ত্রণ এবং ইনভেন্টরি ম্যানেজমেন্ট।</li>
    <li><b>কাস্টমার সাপোর্ট</b> - ২৪/৭ আপনার সব সমস্যার তাত্ক্ষণিক সমাধান দিতে প্রস্তুত।</li>
    <li><b>ডেলিভারি রাইডার্স</b> - সরাসরি আপনার দোকানে পণ্য পৌঁছে দেওয়ার দায়িত্বে নিয়োজিত।</li>
  </ul>
</div>
''',
        }
      },
      {
        'path': HubPaths.faqs,
        'data': {
          'content': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #1565C0, #1E88E5); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 20px;">Frequently Asked Questions (FAQs)</h2>
  </div>
  
  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">Q: What is the minimum order value?</h4>
    <p style="margin: 0; font-size: 13px;">A: Since this is a wholesale platform, the minimum checkout requirement is BDT 1,000.</p>
  </div>

  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">Q: How do referral points work?</h4>
    <p style="margin: 0; font-size: 13px;">A: Copy your invite code from the Profile tab and share it. When users register and place their first order, you get points that can be redeemed as cash discounts.</p>
  </div>

  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">Q: How long does delivery take?</h4>
    <p style="margin: 0; font-size: 13px;">A: Inside Dhaka: 24 hours. Outside Dhaka: 48-72 hours.</p>
  </div>

  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">Q: Can I apply to be a Reseller?</h4>
    <p style="margin: 0; font-size: 13px;">A: Yes! If you want to resell products and earn margins without stock holdings, apply via the "Personal Hub -> Join & Earn" in the profile tab.</p>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #1565C0, #1E88E5); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 20px;">সাধারণ জিজ্ঞাসা (FAQs)</h2>
  </div>
  
  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">প্রশ্ন: সর্বনিম্ন কত টাকার অর্ডার করতে হবে?</h4>
    <p style="margin: 0; font-size: 13px;">উত্তর: এটি একটি পাইকারি প্লাটফর্ম হওয়ায় সর্বনিম্ন অর্ডারের পরিমাণ ১,০০০ টাকা।</p>
  </div>

  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">প্রশ্ন: রেফারেল পয়েন্ট কিভাবে কাজ করে?</h4>
    <p style="margin: 0; font-size: 13px;">উত্তর: প্রোফাইল ট্যাব থেকে আপনার ইনভাইট কোড কপি করে শেয়ার করুন। নতুন কোনো ইউজার সেই কোড দিয়ে সাইনআপ করে প্রথম অর্ডার সম্পন্ন করলে আপনি ফ্রি ডিসকাউন্ট পয়েন্ট পাবেন।</p>
  </div>

  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">প্রশ্ন: পণ্য পৌঁছাতে কত সময় লাগে?</h4>
    <p style="margin: 0; font-size: 13px;">উত্তর: ঢাকা সিটির ভেতরে ২৪ ঘণ্টা এবং ঢাকার বাইরে ৪৮ থেকে ৭২ ঘণ্টার মধ্যে ডেলিভারি সম্পন্ন হয়।</p>
  </div>

  <div style="background: #f8f9fa; padding: 12px; border-radius: 8px; margin-bottom: 12px; border-left: 4px solid #1E88E5;">
    <h4 style="margin: 0 0 5px 0; color: #1565C0;">প্রশ্ন: আমি কি রিসেলার হিসেবে কাজ করতে পারি?</h4>
    <p style="margin: 0; font-size: 13px;">উত্তর: হ্যাঁ! কোনো ইনভেস্টমেন্ট ছাড়া পণ্য শেয়ার করে লভ্যাংশ আয় করতে প্রোফাইলের "Join & Earn" থেকে রিসেলার হিসেবে আবেদন করুন।</p>
  </div>
</div>
''',
        }
      },
      {
        'path': HubPaths.aboutUs,
        'data': {
          'content': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #E65100, #F57C00); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 20px;">About Paykari Bazar</h2>
    <p style="margin: 5px 0 0 0; font-size: 13px; opacity: 0.9;">Empowering local businesses since 2024</p>
  </div>
  <p><b>Paykari Bazar</b> is Bangladesh's pioneering digital B2B wholesale platform. We connect local retailers directly with factories, farmers, and main suppliers to eliminate unnecessary middle-man costs.</p>
  <p>Our state-of-the-art tech ecosystem simplifies order processing, secures digital escrow payments, and manages quick last-mile logistics. We enable micro-merchants and reseller entrepreneurs to launch and grow their ventures with zero stock investment.</p>
  <p><b>Our Vision:</b> To build a transparent, highly efficient, and integrated supply-chain network serving every corner of Bangladesh.</p>
</div>
''',
          'contentBn': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #E65100, #F57C00); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 20px;">আমাদের সম্পর্কে (About Us)</h2>
    <p style="margin: 5px 0 0 0; font-size: 13px; opacity: 0.9;">২০২৪ থেকে ক্ষুদ্র ও মাঝারি ব্যবসায়ের বিশ্বস্ত ডিজিটাল পার্টনার</p>
  </div>
  <p><b>পাইকারী বাজার</b> হলো বাংলাদেশের প্রথম সারির ডিজিটাল বিটুবি (B2B) পাইকারি প্ল্যাটফর্ম। আমরা দেশের প্রতিটি প্রান্তের খুচরা বিক্রেতা ও ব্যবসায়ীদের সরাসরি কারখানা, খামারি এবং মূল আমদানিকারকদের সাথে যুক্ত করি।</p>
  <p>আমাদের আধুনিক প্রযুক্তি সিস্টেমের মাধ্যমে অতি সহজে পাইকারি কেনাকাটা, নিরাপদ ডিজিটাল পেমেন্ট এবং দ্রুত লজিস্টিকস ডেলিভারি সেবা প্রদান করা হয়। এছাড়া আমরা রিসেলারদের জন্য বিনা পুঁজিতে ব্যবসা শুরু করার অনন্য সুযোগ তৈরি করেছি।</p>
  <p><b>আমাদের লক্ষ্য:</b> সমগ্র বাংলাদেশে একটি স্বচ্ছ, সাশ্রয়ী এবং সম্পূর্ণ নির্ভরযোগ্য পাইকারি বাজার নেটওয়ার্ক গড়ে তোলা।</p>
</div>
''',
        }
      },
      {
        'path': HubPaths.termsConditions,
        'data': {
          'content': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #4E342E, #6D4C41); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 20px;">Terms & Conditions</h2>
  </div>
  <ol>
    <li><b>Wholesale Purchase Agreement:</b> Products listed here are strictly for wholesale and commercial trade. Minimum billing per check-out is BDT 1,000.</li>
    <li><b>Pricing & Quotations:</b> Wholesale rates depend on market availability and factory tariffs. Listed rates are subject to change without prior notice.</li>
    <li><b>Returns Policy:</b> Damaged or mis-shipped goods must be claimed with clear video proof within 48 hours of shipment delivery.</li>
    <li><b>Wallet & Credits:</b> In-app wallet funds are secure, non-transferable, and can be used for orders or refunded as per our standard policy.</li>
  </ol>
</div>
''',
          'contentBn': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #4E342E, #6D4C41); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 20px;">ব্যবহারের শর্তাবলী</h2>
  </div>
  <ol>
    <li><b>পাইকারি কেনাকাটার চুক্তি:</b> এই প্ল্যাটফর্মে সকল পণ্য শুধুমাত্র খুচরা ব্যবসা ও বাণিজ্যিক ব্যবহারের উদ্দেশ্যে পাইকারি মূল্যে বিক্রি হয়। সর্বনিম্ন অর্ডারের পরিমাণ ১,০০০ টাকা।</li>
    <li><b>পণ্য মূল্য ও স্টক:</b> বাজারের কাঁচামাল ও উৎপাদন ব্যয়ের ওপর ভিত্তি করে পণ্যের দাম পরিবর্তিত হতে পারে। যেকোনো দাম পরিবর্তনের অধিকার কর্তৃপক্ষ সংরক্ষণ করে।</li>
    <li><b>রিটার্ন ও রিফান্ড নীতি:</b> কোনো পণ্য ভাঙা বা ভুল ডেলিভারি হলে, তা বুঝে পাওয়ার ৪৮ ঘণ্টার মধ্যে আনবক্সিং ভিডিও প্রমাণ সহ কাস্টমার কেয়ারে ক্লেইম করতে হবে।</li>
    <li><b>ওয়ালেট ও ক্রেডিট পলিসি:</b> আপনার ইন-অ্যাপ ওয়ালেটের টাকা সম্পূর্ণ নিরাপদ। এটি দিয়ে কেনাকাটা করতে পারবেন অথবা নিয়ম অনুযায়ী ক্যাশআউট করতে পারবেন।</li>
  </ol>
</div>
''',
        }
      },
      {
        'path': HubPaths.howToUse,
        'data': {
          'content': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #4A148C, #7B1FA2); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 22px;">How to Use Paykari Bazar</h2>
    <p style="margin: 5px 0 0 0; font-size: 14px; opacity: 0.9;">Master the app features in minutes</p>
  </div>
  
  <div style="border-left: 4px solid #FF6F00; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #FF6F00; margin: 0 0 10px 0;">1. Browse & Add to Cart</h3>
    <p style="margin: 0;">Explore categorized products, search for top wholesale deals, and add items to your cart. Look out for bulk pack discounts!</p>
  </div>

  <div style="border-left: 4px solid #00C853; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #00C853; margin: 0 0 10px 0;">2. Apply Coupons & Redeem Points</h3>
    <p style="margin: 0;">During checkout, write valid promo codes or tap to redeem your referral points to earn immediate discounts.</p>
  </div>

  <div style="border-left: 4px solid #2979FF; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #2979FF; margin: 0 0 10px 0;">3. Smart Payments</h3>
    <p style="margin: 0;">Use Cash on Delivery (COD), Mobile Banking (bKash/Nagad), or your in-app Wallet. Top up your wallet in the Profile tab for single-tap payment convenience.</p>
  </div>

  <div style="border-left: 4px solid #AA00FF; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #AA00FF; margin: 0 0 10px 0;">4. Join & Earn (Reseller / Rider / Staff)</h3>
    <p style="margin: 0;">Apply to become a <b>Reseller</b> to sell items and earn margins, a <b>Rider</b> to deliver products and earn delivery bonuses, or <b>Staff</b> to help manage local operations. Apply easily from the Profile tab!</p>
  </div>
</div>
''',
          'contentBn': '''
<div style="font-family: Arial, sans-serif; line-height: 1.6;">
  <div style="background: linear-gradient(135deg, #4A148C, #7B1FA2); padding: 20px; border-radius: 12px; color: white; margin-bottom: 20px;">
    <h2 style="margin: 0; font-size: 22px;">কিভাবে পাইকারী বাজার ব্যবহার করবেন</h2>
    <p style="margin: 5px 0 0 0; font-size: 14px; opacity: 0.9;">অ্যাপের প্রতিটি ফিচারের সহজ ও বিস্তারিত নির্দেশিকা</p>
  </div>
  
  <div style="border-left: 4px solid #FF6F00; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #FF6F00; margin: 0 0 10px 0;">১. পণ্য খুঁজুন ও কার্টে যুক্ত করুন</h3>
    <p style="margin: 0;">প্রয়োজনীয় ক্যাটাগরি অনুযায়ী পণ্য ব্রাউজ করুন অথবা সরাসরি সার্চ করুন। পণ্যের পাইকারি লট বা প্যাক সাইজ অনুযায়ী কার্টে যুক্ত করুন।</p>
  </div>

  <div style="border-left: 4px solid #00C853; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #00C853; margin: 0 0 10px 0;">২. কুপন ও পয়েন্ট রিডিম</h3>
    <p style="margin: 0;">চেকআউট পেজে গিয়ে আপনার একটিভ প্রমো কোড/কুপন লিখুন অথবা আপনার প্রোফাইলে জমানো রেফারেল পয়েন্ট রিডিম করে বিল কমিয়ে নিন।</p>
  </div>

  <div style="border-left: 4px solid #2979FF; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #2979FF; margin: 0 0 10px 0;">৩. সহজ পেমেন্ট মাধ্যম</h3>
    <p style="margin: 0;">ক্যাশ অন ডেলিভারি (COD), মোবাইল ব্যাংকিং (বিকাশ/নগদ) অথবা ইন-অ্যাপ ওয়ালেটের মাধ্যমে তাত্ক্ষণিক বিল পরিশোধ করুন। সহজে ওয়ালেট রিচার্জ করে এক ক্লিকে অর্ডার করতে পারেন।</p>
  </div>

  <div style="border-left: 4px solid #AA00FF; padding-left: 15px; margin-bottom: 20px;">
    <h3 style="color: #AA00FF; margin: 0 0 10px 0;">৪. যুক্ত হোন ও আয় করুন (রিসেলার / রাইডার / স্টাফ)</h3>
    <p style="margin: 0;">কোনো মূলধন ছাড়া লভ্যাংশ আয় করতে প্রোফাইল ট্যাব থেকে <b>রিসেলার</b>, পণ্য ডেলিভারি দিয়ে আয় করতে <b>রাইডার</b> অথবা আমাদের সাথে সরাসরি যুক্ত হতে <b>স্টাফ</b> হিসেবে আবেদন করুন।</p>
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
