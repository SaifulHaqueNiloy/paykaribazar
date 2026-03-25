# Integration DNA [SYS-INT-DNA] - [LOCKED STATUS: ACTIVE]
# থার্ড-পার্টি ইন্টিগ্রেশন এবং এপিআই প্রোটোকল (মাস্টার সংস্করণ)

এই নথিতে অ্যাপের সব এক্সটার্নাল সার্ভিস এবং এপিআই ব্যবহারের নিয়ম বিস্তারিতভাবে দেওয়া হয়েছে।

## ১. ফায়ারবেস ইন্টিগ্রেশন [INT-FIREBASE]

### ক) Firestore ডাটাবেস [INT-FB-FIRESTORE]
- **Firestore Operations:** সব অপারেশন অবশ্যই `HubPaths` ব্যবহার করে সার্ভিস লেভেলের মাধ্যমে হতে হবে।
- **Collection Structure:**
  ```
  users/{uid}/profile
  products/{productId}/details  
  orders/{orderId}/items
  inventory/{skuId}/stock
  chats/{chatId}/messages
  ```
- **Offline Persistence:** অফলাইন মোড এর জন্য `enablePersistence()` এনাবল করা বাধ্যতামূলক।
- **Real-time Listeners:** StreamProvider ব্যবহার করে রিয়েল-টাইম ডেটা স্ট্রিমিং।
- **Batch Writes:** একাধিক ডকুমেন্ট আপডেটে `WriteBatch` ব্যবহার করা বাধ্যতামূলক।

### খ) Firebase Authentication [INT-FB-AUTH]
- **Auth Methods:** Email/Password, Google Sign-In, Facebook Sign-In, Phone OTP।
- **Session Management:** `FirebaseAuthService` মাধ্যমে সেশন ম্যানেজ এবং টোকেন রিফ্রেশ।
- **Custom Claims:** রোল-বেসড এক্সেস কন্ট্রোল (Customer, Rider, Reseller, Admin, Staff)।
- **Security Rules:** প্রতিটি কালেকশনের জন্য ফায়ারবেস সিকিউরিটি রুলস ডিফাইন করা বাধ্যতামূলক।

### গ) Firebase Cloud Messaging (FCM) [INT-FB-FCM]
- **Push Notifications:**
  - অর্ডার স্ট্যাটাস (নিশ্চিতকরণ → শিপমেন্ট → ডেলিভারি)
  - রাইডার লোকেশন আপডেট (ডেলিভারি সময়)
  - চ্যাট মেসেজ (নতুন বার্তা)
  - লয়্যালটি পয়েন্ট (রিডিম/আর্ন অ্যালার্ট)
  - লো স্টক (অ্যাডমিন কে)
- **Background Processing:** ব্যাকগ্রাউন্ডে বার্তা হ্যান্ডলিং বাধ্যতামূলক।
- **Topic Subscriptions:** ইউজার রোল অনুযায়ী টপিক ম্যানেজমেন্ট।

### ঘ) Firebase Storage [INT-FB-STORAGE]
- **File Organization:** users/{uid}/profile_pic, products/{id}/images, prescriptions/{userId}/{timestamp}।
- **Upload Validation:** ফাইল টাইপ, সাইজ (মেধা: ৫MB), মিমটাইপ ভ্যালিডেশন।
- **Upload Progress:** বড় ফাইলের জন্য প্রগ্রেস ট্র্যাকিং ইমপ্লিমেন্ট করতে হবে।

## ২. মিডিয়া এবং স্টোরেজ (Cloudinary) [INT-MEDIA]

### ক) ইমেজ আপলোড এবং অপ্টিমাইজেশন [INT-MED-UPLOAD]
- **Pre-Upload Compression:** JPEG, PNG, WebP ফরম্যাট, ৭৫% কোয়ালিটি, Max ৫ MB (প্রোডাক্ট)।
- **Responsive URLs:**
  ```
  Thumbnail (100x100): ?w=100&h=100&c=fill&q=80
  Small (300x300):     ?w=300&h=300&c=fill&q=80
  Full (1280x720):     ?w=1280&h=720&c=fill&q=85
  ```
- **Dynamic Transformation:** ডিভাইস স্ক্রিন সাইজ অনুযায়ী ইমেজ সার্ভ করা।

### খ) সিক্রেট ম্যানেজমেন্ট [INT-MED-SECRETS]
- **Credentials:** ক্লাউডিনারি API কী এবং সিক্রেট `SecretsService` থেকে রিড করা বাধ্যতামূলক।
- **.env File:** কখনোই রিপোজিটরিতে কমিট করা যাবে না (`.gitignore` এ যোগ করা)।

## ৩. এআই প্রোভাইডার এবং রাউটিং [INT-AI]

### ক) মডেল সিলেকশন [INT-AI-MODEL]
- **Primary Model:** Gemini 2.0 (বাধ্যতামূলক), Fallback: Gemini 1.5 Pro।
- **Forbidden:** Gemini 1.5 Flash (কখনো ব্যবহার করা যাবে না)।
- **Configuration:** ৩০ সেকেন্ড টাইমআউট, 0.7 টেম্পারেচার, ২০৪৮ টোকেন লিমিট।

### খ) মাল্টি-মডেল রাউটিং [INT-AI-ROUTING]
**Priority Order:**
1. NVIDIA (Kimi-k2.5) - ক্রিয়েটিভ কন্টেন্ট, প্রোডাক্ট অডিট
2. DeepSeek - লজিক্যাল প্রসেসিং, ডেটা অর্গানাইজেশন
3. Gemini 2.0 - ইমেজ রিকগনিশন, ভিশন টাস্ক

### গ) এআই অপ্টিমাইজেশন [INT-AI-OPTIMIZE]
- **Caching:** ৬০-৭০% API কল হ্রাস, MD5-based keys, ১ ঘন্টা cache duration।
- **Rate Limiting:** ৬০ req/min (প্রতি ব্যবহারকারী), ১০,০০০ daily quota, exponential backoff।
- **Error Handling:** ৩x automatic retry, user-friendly messages, comprehensive logging।
- **Isolates:** ভারী প্রসেসিং আলাদা `Isolate` থ্রেডে চালানো বাধ্যতামূলক।

## ४. গুগল ম্যাপস এবং জিওলোকেশন [INT-MAPS]

### ক) ম্যাপস ইন্টিগ্রেশন [INT-MAPS-CONFIG]
**Provider Configuration:**
- **API Keys:** (`GoogleMapsApiKey.dart`) সার্ভার + ক্লায়েন্ট সাইড উভয় চাবি।
- **Maps Platform:** Android/iOS maps rendering, Web maps embedding।
- **Zoom Levels:**
  - City view: ৯ (দোকান/ফার্মেসি দেখায়)
  - District view: ১১ (এলাকা পর্যায়)
  - Street view: ১৫ (নির্ভুল ডেলিভারি লোকেশন)

### খ) জিওলোকেশন এবং ট্র্যাকিং [INT-MAPS-GEO]
**Real-time Tracking:**
- **Update Frequency:** ৫ সেকেন্ড ইন্টারভাল (background WorkManager)।
- **Accuracy Threshold:** ৫০ মিটার (কম accurately গণনা করা হয় না)।
- **Battery Mode:** কম পাওয়ার মোডে ৩ মিনিট ইন্টারভাল।
- **Offline Caching:** শেষ known location + timestamp সংরক্ষণ করা।

**Data Structure (Location Model):**
```dart
class LocationData {
  double latitude;
  double longitude;
  double accuracy;
  DateTime timestamp;
  String? address;      // Reverse geocoding cache
  String? hubPath;      // Nearest hub reference
}
```

### গ) জিওফেন্সিং [INT-MAPS-GEOFENCE]
- **Hub Radius:** ৫ কিমি (ডেলিভারি সার্ভিস এরিয়া)।
- **Events:** Entry/Exit callbacks WorkManager দিয়ে চালানো।
- **Triggers:** 
  - ডেলিভারি এরিয়া প্রবেশ: অর্ডার নোটিফিকেশন।
  - অনুমোদিত ডেলিভারি রুট বের: নোটিফিকেশন অগ্নি করা।

### ঘ) দূরত্ব ক্যালকুলেশন এবং ফি [INT-MAPS-DISTANCE]
**Distance API:**
- **Matrix API:** বহুবিন্দু দূরত্ব এক্সপ্লোর (২৫টি গন্তব্য)।
- **Caching:** GitHub Cache 24 ঘন্টা (key: `route_{hubId}_{timestamp}`)।
- **Fallback:** Same-city ডেলিভারি = ৫ কিমি গড়।

**Fee Calculation Formula:**
```
base_fee = 50 টাকা
distance_fee = distance_km * 10 টাকা
time_multiplier = 1 + (hours_to_deliver / 24)  // রাতের বেলা ২০% বেশি
total_fee = (base_fee + distance_fee) * time_multiplier
```

### ঙ) ম্যাপস অপ্টিমাইজেশন [INT-MAPS-OPTIMIZE]
- **Memory:** Bitmap caching (মার্কার আইকন পূর্ব-লোড)।
- **Network:** Polyline decoding (কম টোকেন খরচ)।
- **UI:** ম্যাপ rendering async Isolate এ (60 FPS লক্ষ্য)।

## ৫. পেমেন্ট গেটওয়ে (bKash/Nagad) [INT-PAY]

### ক) পেমেন্ট ফ্লো [INT-PAY-FLOW]
- **Checkout:** পেমেন্ট রিকোয়েস্ট অবশ্যই সিকিউর সার্ভার-টু-সার্ভার কলের মাধ্যমে হতে হবে।
- **Status:** পেমেন্ট কনফার্মেশনের পর ডাটাবেস আপডেট এবং ইনভয়েস জেনারেশন অটোমেটিক হতে হবে।
- **Log:** প্রতিটি ট্রানজ্যাকশন আইডির জন্য আলাদা লগ মেনটেইন করতে হবে।
- **Supported Methods:** bKash (প্রাথমিক), Nagad (ফলব্যাক), কার্ড, ক্যাশ অন ডেলিভারি।

### খ) ট্রানজ্যাকশন লগিং [INT-PAY-LOG]
```
{
  'transactionId': 'TXN-123456',
  'orderId': 'ORDER123',
  'amount': 500.00,
  'method': 'bKash',
  'status': 'COMPLETED',
  'timestamp': DateTime.now(),
}
```

---

## ৬. ব্যাকগ্রাউন্ড প্রসেসিং [INT-BG]

### ক) WorkManager ইন্টিগ্রেশন [INT-BG-WM]
- **Data Sync Task:** ৩০ মিনিট ইন্টারভালে কার্ট এবং উইশলিস্ট সিঙ্ক।
- **Background Isolate:** ভারী অপারেশন আলাদা থ্রেডে চালানো বাধ্যতামূলক।
- **Task Queue:** ব্যাকেন্ড রেসপন্স না পেলে স্থানীয় কিউতে সংরক্ষণ।

### খ) Firebase Background Functions [INT-BG-FUNCTIONS]
- **Scheduled Functions:** রিপোর্ট জেনারেশন (দৈনিক রাত ১২টা)।
- **Trigger Functions:** অর্ডার স্থিতি পরিবর্তনে, স্টক আপডেটে।

---

## ৭. নোটিফিকেশন [INT-NOTIFY]

### ক) ফায়ারবেস ক্লাউড মেসেজিং (FCM) [INT-NOTIFY-FCM]
- **অর্ডার আপডেট:** নিশ্চিতকরণ, শিপমেন্ট, ডেলিভারি স্ট্যাটাস।
- **চ্যাট বার্তা:** নতুন মেসেজ নোটিফিকেশন প্রতি ২ সেকেন্ডে চেক।
- **লয়্যালটি পয়েন্ট:** পয়েন্ট অর্জন বা রিডিম করার সময় নোটিফাই।
- **অ্যালার্ট:** লো স্টক অ্যালার্ট (অ্যাডমিন), জরুরী অর্ডার (স্টাফ)।

### খ) লোকাল নোটিফিকেশন [INT-NOTIFY-LOCAL]
- **Scheduled Notifications:** শপিং রিমাইন্ডার, অফার ঘোষণা।
- **Channel Organization:** চ্যাট (উচ্চ অগ্রাধিকার), অর্ডার (মাঝারি), অফার (নিম্ন)।

---

## ৮. অ্যানালিটিক্স এবং মনিটরিং [INT-ANALYTICS]

### ক) Firebase Analytics [INT-ANALYTICS-FB]
- **Key Events:** login, purchase, view_product, add_to_cart, search, checkout।
- **User Properties:** user_type (customer/rider/reseller), loyalty_tier, device_type।
- **Custom Events:** emergency_reported, medicine_ordered, loyalty_redeemed।

### খ) Sentry ইন্টিগ্রেশন [INT-ANALYTICS-SENTRY]
- **Error Tracking:** ক্রিটিক্যাল এরর ক্যাপচার এবং স্ট্যাক ট্রেস রিপোর্টিং।
- **Performance Monitoring:** API লেটেন্সি, ইউআই ফ্রেম রেট, মেমোরি ব্যবহার।
- **Release Tracking:** প্রতি বিল্ড রিলিজ ট্র্যাকিং এবং রিগ্রেশন ডিটেকশন।

---

## ৯. ক্রস-রেফারেন্স (Cross-References)
- [Core DNA](core_dna.md) [SYS-CORE-DNA]
- [Visual DNA](visual_dna.md) [SYS-VISUAL-DNA]
- [Feature DNA](feature_dna.md) [SYS-FEAT-DNA]
- [Database DNA](database_dna.md) [SYS-DB-DNA]
- [Security DNA](security_dna.md) [SYS-SEC-DNA]
- [Operations DNA](operations_dna.md) [SYS-OPS-DNA]
- [Model & State DNA](model_state_dna.md) [SYS-STATE-DNA]
- [Performance DNA](performance_dna.md) [SYS-PERF-DNA]
- [UI Feature Map](ui_feature_map.md) [SYS-UI-MAP]

---

## Change Log
- **2025-03-24:** Initial Integration DNA created with basic Firebase, Cloudinary, AI, Maps, and Payment integration rules.
- **2026-03-24:** MAJOR EXPANSION with comprehensive Firebase details (Firestore collections, Auth methods, FCM, Storage), Cloudinary transformations, Multi-model AI routing with caching/rate limiting, Google Maps integration with Geofencing, Payment flow diagrams, WorkManager background processing, FCM/Local notifications, Analytics tracking, Sentry error monitoring, and comprehensive API implementation patterns. Added [LOCKED STATUS] and Cross-References.
