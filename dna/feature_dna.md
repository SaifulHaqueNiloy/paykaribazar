# Feature DNA [SYS-FEATURE-DNA] - [LOCKED STATUS: ACTIVE]
# ফিচার ডোমেইন এবং এআই অর্কেস্ট্রেশন (মাস্টার সংস্করণ - ১০০% নিখুঁত)

এই ফাইলে এআই এবং ব্যাকগ্রাউন্ড প্রসেসের প্রতিটি "ক্লু" এবং লজিক বিস্তারিতভাবে দেওয়া হলো।

## ১. আওয়ার মাস্টার এআই (Our Master AI Orchestration) [AI-MASTER-DNA]
এআই ইঞ্জিনটি সিস্টেমের মস্তিস্ক হিসেবে কাজ করে এবং এটি মাল্টি-মডেল রাউটিং মেনে চলে।

### ১.১ মাস্টার এআই-এর কাজের ক্ষেত্র (Master AI's Work Area)
মাস্টার এআই শুধুমাত্র একটি চ্যাটবট নয়, এটি পুরো ইকোসিস্টেম নিয়ন্ত্রণ করে:
- **UI/UX Optimization:** ইউজারের আচরণ বিশ্লেষণ করে হোম স্ক্রিনের অ্যাডাপ্টিভ গ্রিড (2, 3, or 4 columns) সাজেস্ট করা।
- **Product Auditing:** ইনভেন্টরিতে থাকা পণ্যের স্টক লেভেল, বর্ণনা (SEO) এবং ক্যাটাগরি স্বয়ংক্রিয়ভাবে অডিট করা।
- **Moderation:** চ্যাট এবং ফিডব্যাক সেকশনে ফোন নম্বর, ইমেইল বা নিষিদ্ধ লিংক ডিটেকশন ও ফিল্টারিং।
- **Logistics Intelligence:** রাইডারদের জন্য ট্রাফিক ও দূরত্ব বিবেচনা করে সবচাইতে দ্রুত ডেলিভারি রুট ম্যাপ তৈরি।
- **Financial Guardian:** এসক্রো (Escrow) পেমেন্ট রিলিজ করার আগে ডেলিভারি কনফার্মেশন এবং ফ্রড চেক করা।

### ১.২ কাজের প্রক্রিয়া (Process of Work)
এআই লজিকটি "Decision-First" মডেলে কাজ করে:
- **Trigger Phase:** কোনো ইভেন্ট (অর্ডার, মেসেজ বা টাইম-ইন্টারভাল) ঘটলে এআই সক্রিয় হয়।
- **Routing Phase (Omnipotent Routing):** 
  1. **NVIDIA (Kimi-k2.5):** ক্রিয়েটিভ কন্টেন্ট এবং প্রোডাক্ট অডিটের জন্য।
  2. **DeepSeek:** লজিক্যাল প্রসেসিং এবং ব্যাক-এন্ড ডেটা অর্গানাইজেশনের জন্য (Base Integration Ready)।
  3. **Gemini 2.0:** ইমেজ রিকগনিশন এবং ভিশন-ভিত্তিক টাস্কের জন্য।
- **Neural Hop:** যদি প্রাইমারি মডেল ৩-৫ সেকেন্ডে রেসপন্স না দেয়, তবে সিস্টেম অটোমেটিক পরবর্তী মডেলে হপ (Hop) করবে।
- **Key Rotation (Gemini):** .env ফাইলে থাকা সকল Gemini API Key (Master, Support, General) অটোমেটিক রোটেশন পদ্ধতিতে ব্যবহার হবে। কোনো কী-র কোটা শেষ হলে সিস্টেম স্বয়ংক্রিয়ভাবে পরবর্তী কী ব্যবহার করবে।
- **Verification Phase:** এআই-এর জেনারেট করা আউটপুট সিস্টেম রুলসের সাথে ম্যাচ করে কি না তা চেক করা।

### ১.৩ তথ্য সংগ্রহ (Data Collection)
এআই নিচের উৎসগুলো থেকে রিয়েল-টাইম ডাটা সংগ্রহ করে:
- **Firestore Snapshots:** প্রোডাক্ট ক্যাটালগ, ইউজার বিহেভিয়ার এবং অর্ডার হিস্ট্রি।
- **System Health Logs:** কানেক্টিভিটি এবং এপিআই কোটার বর্তমান অবস্থা।
- **External API Feeds:** ম্যাপ ডাটা এবং কারেন্সি কনভার্সন (যদি প্রয়োজন হয়)।
- **Behavioral Data:** ইউজার কোন পণ্যে বেশি সময় দিচ্ছে বা কোন ক্যাটাগরি বেশি সার্চ করছে।

### ১.৪ কার্যকরকরণ ও বাস্তবায়ন (Execution)
সংগৃহীত তথ্য এবং প্রক্রিয়াকরণ শেষে এআই নিচের মাধ্যমে বাস্তবায়ন করে:
- **Background Isolates:** ভারী প্রসেসিং যেমন ইমেজ অডিট বা এসইও জেনারেশন আলাদা ডার্ট আইসোলেটে চলে।
- **Automated Triggers:** নির্দিষ্ট শর্তে পুশ নোটিফিকেশন পাঠানো বা স্ট্যাটাস আপডেট করা (যেমন: স্টক আউট অ্যালার্ট)।
- **UI Reflection:** ইউজারের ড্যাশবোর্ডে ডাইনামিক টিপস এবং স্মার্ট সাজেশন্স প্রদর্শন।
- **Audit Logs:** প্রতিটি এআই অ্যাকশন `AiAutomationService`-এর মাধ্যমে ডাটাবেসে লগ হিসেবে সেভ হয়।
- **Fast Caching:** `crypto` প্যাকেজ ব্যবহার করে হাই-স্পিড ক্যাশিং সিস্টেম যা এআই রেসপন্স টাইম এবং এপিআই খরচ কমিয়ে আনে।

## ২. ব্যাকগ্রাউন্ড প্রসেস ডিএনএ [BG-PROCESS-DNA]
অ্যাপের পারফরম্যান্স বজায় রাখতে ভারী কাজগুলো ব্যাকগ্রাউন্ডে পরিচালিত হবে:
- **Isolates:** ভারী ডেটা প্রসেসিং অবশ্যই ডার্ট `Isolate`-এ চলবে যাতে মেইন ইউআই (UI) থ্রেড কোনোভাবেই জ্যাম না হয়।
- **WorkManager:** অ্যান্ড্রয়েডের ব্যাকগ্রাউন্ড জবের জন্য `WorkManager` ব্যবহার করা হবে।
- **পিরিওডিক সিঙ্ক:** প্রতি ৩০ মিনিট পর পর ইউজারের কার্ট এবং উইশলিস্ট ক্লাউডের সাথে সিঙ্ক হবে।
- **লাইভ ট্র্যাকিং:** রাইডার মোডে থাকলে ৫ সেকেন্ড পর পর লোকেশন আপডেট ব্যাকগ্রাউন্ডে চলবে এবং কাস্টমারকে নোটিফাই করবে।

## ৩. ডোমেইন ভিত্তিক সার্ভিস মেথড [FEAT-METHODS]
- **Wholesale Price Logic:** `qty >= 5` হলে আইটেম অটোমেটিক পাইকারী মূল্যে কনভার্ট হবে।
- **Qibla Calculation:** জিপিএস ভিত্তিক কিবলা অ্যাঙ্গেল (২৯২-২৯৫°) ক্যালকুলেশন।
- **Search DNA:** সার্চ বারে বাংলা, ইংরেজি এবং ফোনেটিক (Banglish) ম্যাপিং লজিক বাধ্যতামূলক।

## Change Log
- **2025-03-24:** Initial file lock. Master AI Orchestration, Work Areas, Data Collection, and Execution logic strictly confirmed. No line removals allowed.
- **2025-03-25:** AI System Upgrade. Added Gemini Key Rotation logic, Fast Caching using `crypto` package, and DeepSeek base integration for enhanced stability.
- **2026-03-25:** Feature Completeness Reached 100% - Implemented 4 Missing Services:
  - **CouponService:** Full coupon validation, discount calculation (percentage/fixed), multi-use tracking, max discount capping
  - **CartPosService:** Bulk order management, tiered wholesale pricing (5-100+ qty), quick order templates, POS inventory views
  - **GeofencingService:** Delivery zone detection, Haversine distance calculation, real-time zone monitoring, dynamic delivery fee/ETA lookup
  - **CompassService:** Qibla bearing calculation, real-time compass integration via sensors, prayer time placeholder, distance to Mecca
