# Performance & Optimization DNA [SYS-PERF-DNA] - [LOCKED STATUS: ACTIVE]
# পারফরম্যান্স এবং অপ্টিমাইজেশন প্রোটোকল (বিস্তারিত)

পাইকারী বাজার অ্যাপের গতি এবং সাবলীলতা বজায় রাখতে এই অপ্টিমাইজেশন নিয়মগুলো মেনে চলা বাধ্যতামূলক।

## ১. ডেটা ক্যাশিং এবং ইমেজ অপ্টিমাইজেশন [PERF-IMG-01]
- **CachedNetworkImage:** সব নেটওয়ার্ক ইমেজের জন্য অবশ্যই `CachedNetworkImage` ব্যবহার করতে হবে। সরাসরি `Image.network` ব্যবহার করা যাবে না।
- **Image Compression:** ক্লাউডিনারি (Cloudinary) বা এপিআই-তে আপলোড করার আগে ছবি অবশ্যই কম্প্রেস করতে হবে যাতে ব্যান্ডউইথ সাশ্রয় হয়।
- **Placeholder:** ইমেজ লোড হওয়ার সময় অবশ্যই একটি পাবলিক ব্লার-হ্যাশ বা হালকা রঙের প্লেসহোল্ডার দেখাতে হবে।

## ২. ফায়ারস্টোর অপ্টিমাইজেশন [PERF-DB-01]
- **Pagination (পেজিনেশন):** প্রোডাক্ট লিস্ট বা অর্ডার হিস্ট্রির মতো বড় লিস্টগুলোতে অবশ্যই `limit()` এবং `startAfter()` ব্যবহার করে পেজিনেশন করতে হবে। একবারে সব ডেটা রিড করা নিষেধ।
- **Query Optimization:** অপ্রয়োজনীয় ফিল্ড রিড করা এড়াতে শুধুমাত্র প্রয়োজনীয় ডেটা কুয়েরি করতে হবে।
- **Local Persistence:** ফায়ারস্টোর-এর অফলাইন পারসিস্টেন্স এনাবল রাখতে হবে যাতে ইন্টারনেট না থাকলেও আগে লোড হওয়া ডেটা দেখা যায়।

## ৩. উইজেট এবং স্টেট অপ্টিমাইজেশন [PERF-UI-01]
- **Const Constructors:** যেখানে সম্ভব অবশ্যই `const` কনস্ট্রাক্টর ব্যবহার করতে হবে।
- **RepaintBoundary:** জটিল অ্যানিমেশন বা বারবার রি-পেইন্ট হয় এমন উইজেটের ক্ষেত্রে `RepaintBoundary` ব্যবহার করতে হবে।
- **Consumer Selection:** রিভারপড ব্যবহারের সময় পুরো উইজেট রি-বিল্ড না করে শুধুমাত্র প্রয়োজনীয় অংশ রি-বিল্ড করতে `ref.select()` ব্যবহার করা উচিত।

## ৪. মেমোরি ম্যানেজমেন্ট [PERF-MEM-01]
- **Dispose:** স্ক্রিন বা উইজেট ক্লোজ করার সময় সব `TextEditingController`, `ScrollController` এবং `StreamSubscription` অবশ্যই ডিসপোজ করতে হবে।
- **Lazy Loading:** লিস্টভিউ-তে `Lazy Loading` ব্যবহার করতে হবে যাতে শুধুমাত্র স্ক্রিনে থাকা আইটেমগুলো মেমোরিতে থাকে।

## ৫. নেটওয়ার্ক অপ্টিমাইজেশন [PERF-NET-01]
- **API Batching:** একাধিক API কল একসাথে পাঠানো যায় এমন ক্ষেত্রে ব্যাচিং করতে হবে।
- **Request Timeout:** সব নেটওয়ার্ক রিকোয়েস্টে ৩০ সেকেন্ডের টাইমআউট সেট করতে হবে।
- **Retry Logic:** নেটওয়ার্ক ফেইলিউরে এক্সপোনেনশিয়াল ব্যাকঅফ সহ ৩ বার রিট্রাই করতে হবে।
- **Connection Pooling:** HTTP Client রিইউজ করতে হবে নতুন কানেকশন খোলার বদলে।

## ৬. API কল অপ্টিমাইজেশন [PERF-API-01]
- **Field Selection:** Firestore কোয়েরিতে শুধুমাত্র প্রয়োজনীয় ফিল্ড নির্বাচন করতে হবে।
- **Request Debouncing:** সার্চ বা ফিল্টারে ৩০০ms ডিবাউন্স সময় সেট করতে হবে।
- **Cache Headers:** HTTP রেসপন্স ক্যাশ হেডার ব্যবহার করতে হবে।
- **Gzip Compression:** সব API রেসপন্স গ্জিপ কম্প্রেস করা উচিত।

## ७. অ্যানিমেশন পারফরম্যান্স [PERF-ANIM-01]
- **60 FPS Target:** সব অ্যানিমেশন ৬০ FPS-এ রান করার জন্য অপ্টিমাইজ করতে হবে।
- **GPU Acceleration:** জটিল অ্যানিমেশনের জন্য `Transform` উইজেট ব্যবহার করতে হবে।
- **Animation Controllers:** সর্বদা সাবস্ক্রিপশন ডিসপোজ করতে হবে।
- **Vsync:** অ্যানিমেশন ডিবাউন্সিং এর জন্য vsync ব্যবহার করতে হবে।

## ৮. অ্যাপ স্টার্টআপ অপ্টিমাইজেশন [PERF-STARTUP-01]
- **Launch Time:** অ্যাপ ৩ সেকেন্ডের মধ্যে লঞ্চ হতে হবে।
- **Lazy Initialization:** নন-ক্রিটিক্যাল সার্ভিস অ্যাসিঙ্ক্রোনাসভাবে ইনিশিয়ালাইজ করতে হবে।
- **Asset Preloading:** সাধারণ ব্যবহৃত ইমেজ এবং ডেটা প্রি-লোড করতে হবে।
- **Initialization Phases:** 4-Phase DI ইনিশিয়ালাইজেশন ফলো করতে হবে (Core → Firebase → Shared → Features)।

## ৯. ব্যাকগ্রাউন্ড টাস্ক অপ্টিমাইজেশন [PERF-BG-01]
- **WorkManager:** দীর্ঘমেয়াদী টাস্কের জন্য WorkManager ব্যবহার করতে হবে।
- **Battery Optimization:** ব্যাটারি সেভিং মোডে অপারেশন হ্রাস করতে হবে।
- **Periodic Sync:** ৩০ মিনিট ইন্টারভালে ডেটা সিঙ্ক করতে হবে।
- **Foreground Service:** ১০+ মিনিটের টাস্কের জন্য ফোরগ্রাউন্ড সার্ভিস ব্যবহার করতে হবে।

## ১০. স্টোরেজ অপ্টিমাইজেশন [PERF-STORAGE-01]
- **Cache Expiration:** ক্যাশড ইমেজ ৭ দিনের পর অটোমেটিক ডিলিট করতে হবে।
- **Database Optimization:** Hive ডাটাবেস নিয়মিত কমপ্যাক্ট করতে হবে।
- **Local Storage Cleanup:** অ্যাপ এক্সিট করার সময় টেম্পরারি ফাইল ডিলিট করতে হবে।
- **SharedPreferences:** বড় ডেটার জন্য SharedPreferences ব্যবহার করা যাবে না।

---

## ১১. ক্রস-রেফারেন্স (Cross-References)
- [Core DNA](core_dna.md) [SYS-CORE-DNA]
- [Visual DNA](visual_dna.md) [SYS-VISUAL-DNA]
- [Feature DNA](feature_dna.md) [SYS-FEAT-DNA]
- [Database DNA](database_dna.md) [SYS-DB-DNA]
- [Security DNA](security_dna.md) [SYS-SEC-DNA]
- [Integration DNA](integration_dna.md) [SYS-INT-DNA]
- [Operations DNA](operations_dna.md) [SYS-OPS-DNA]
- [Model & State DNA](model_state_dna.md) [SYS-STATE-DNA]
- [UI Feature Map](ui_feature_map.md) [SYS-UI-MAP]

---

## Change Log
- **2025-03-24:** Initial file lock. Performance optimization rules confirmed.
- **2026-03-24:** Comprehensive expansion with Network, API, Animation, Startup, Background, and Storage optimization details. Added [LOCKED STATUS] and Cross-References.
