# Operations & Maintenance DNA [SYS-OPS-DNA] - [LOCKED STATUS: ACTIVE]
# অপারেশন এবং রক্ষণাবেক্ষণ প্রোটোকল (১০০% নিখুঁত মাস্টার সংস্করণ)

## ১. অপরিবর্তনীয় ফাইল প্রোটোকল [OPS-IMMUTABLE]
নিচের ৫টি ফাইল কখনোই এডিট বা ডিলিট করা যাবে না। যেকোনো পরিবর্তনের আগে এগুলো অবশ্যই পড়তে হবে: [STRICT]
1. `PROJECT_MASTER_BLUEPRINT.md`
2. `CORE_FEATURES_RULES.md`
3. `BACKUP_RULES.md`
4. `CORE_FEATURES_musthave.md`
5. `README.md`

## ২. ভার্সন কন্ট্রোল এবং গিট [OPS-GIT]
- **Branching:** `main` (Production), `dev` (Integration), `feature/*` (Specific tasks)।
- **Commit Message:** ফিচারের নাম এবং কাজের সংক্ষিপ্ত বিবরণ থাকতে হবে।

## ৩. অ্যাপ আপডেট (Shorebird & Store) [OPS-UPDATE]
- **Instant Patch:** ছোট বাগ বা ইউআই ফিক্সের জন্য `shorebird patch android -t lib/main_customer.dart`।
- **Major Release:** প্লাগইন বা আর্কিটেকচার পরিবর্তন হলে নতুন APK/Bundle তৈরি করে স্টোরে আপলোড করতে হবে।

## ৪. ব্যাকআপ এবং ডিজাস্টার রিকভারি [OPS-RECOVERY]
- **DB Backup:** প্রতি সপ্তাহে ফায়ারস্টোর ডেটা এক্সপোর্ট করতে হবে।
- **Logic Sync:** মাস্টার ব্লুপ্রিন্ট এবং DNA ফাইলের অফলাইন ব্যাকআপ রাখা বাধ্যতামূলক।

## ৫. মনিটরিং এবং হেলথ অডিট [OPS-AUDIT]
- **Daily Health Check:** প্রতিদিন রাত ১২টায় `HealthCheckService` রান হবে।
- **AI Audit:** প্রতি ১ ঘণ্টা পর পর এআই অটো-অডিট সিস্টেমের প্যারামিটার চেক করবে।
- **Error Logs:** সব ক্রিটিক্যাল ফেইলুর `ErrorReporterService`-এ লগ হবে।

---

## ৬. ক্রস-রেফারেন্স (Cross-References)
- [Core DNA](core_dna.md) [SYS-CORE-DNA]
- [Visual DNA](visual_dna.md) [SYS-VISUAL-DNA]
- [Feature DNA](feature_dna.md) [SYS-FEAT-DNA]
- [Database DNA](database_dna.md) [SYS-DB-DNA]
- [Security DNA](security_dna.md) [SYS-SEC-DNA]
- [Integration DNA](integration_dna.md) [SYS-INT-DNA]
- [Model & State DNA](model_state_dna.md) [SYS-STATE-DNA]
- [Performance DNA](performance_dna.md) [SYS-PERF-DNA]
- [UI Feature Map](ui_feature_map.md) [SYS-UI-MAP]

---

## Change Log
- **2025-03-24:** Initial Operations DNA created.
- **2026-03-24:** Added [LOCKED STATUS], Cross-References section, and Change Log.
- **2026-03-25:** Feature Completeness Milestone - Version 100% Complete
  - ✅ Implemented 4 missing services: CouponService, CartPosService, GeofencingService, CompassService
  - ✅ All 28 features now active and tested
  - ✅ Feature completeness: 86% → 100%
  - ✅ Deployment recommended for App Store/Play Store
  - See: [FEATURE_COMPLETENESS_100_UPDATE.md](FEATURE_COMPLETENESS_100_UPDATE.md)
