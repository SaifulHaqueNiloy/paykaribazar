# core DNA [SYS-CORE-DNA] - [LOCKED STATUS: ACTIVE]
# কোর টেকনিক্যাল ডিএনএ (মাস্টার সংস্করণ - ১০০% ডেটা)

## ১. এনভায়রনমেন্ট এবং বুট লজিক [CORE-ENV]
- **SDK:** Flutter v3.24.0+, Kotlin 2.1.0, Gradle 8.14, JVM 17.
- **Initialization:** ৪-ধাপের এসিঙ্ক্রোনাস বুটিং লজিক (Phase 1-4)।
- **Multi-App Logic:** `main_customer.dart` এবং `main_admin.dart` আলাদা এন্ট্রি পয়েন্ট হিসেবে কাজ করবে কিন্তু একই কোর এবং শেয়ারড লেয়ার ব্যবহার করবে।

## ২. আর্কিটেকচার এবং সেন্ট্রালাইজড স্ট্রাকচার [CORE-ARCH-DNA]
- **Centralized Exports:** `lib/src/core/exports.dart` ফাইলটি প্রজেক্টের মেইন ব্যারেল ফাইল হিসেবে কাজ করবে। সব কমন ফ্লাটার এবং ইন্টারনাল কোর ইম্পোর্ট এখানে থাকবে।
- **Centralized Providers:** সব রিভারপড প্রোভাইডার (Services, Data Streams, Logic) `lib/src/core/providers.dart` ফাইলে থাকবে। ডুপ্লিকেট প্রোভাইডার ডিক্লেয়ারেশন নিষিদ্ধ।
- **Base Layer:** সব স্ক্রিন অবশ্যই `BaseScreen` এবং ভিউমডেল অবশ্যই `BaseViewModel` এক্সটেন্ড করবে যাতে লোডিং এবং এরর হ্যান্ডলিং ইউনিফাইড থাকে।
- **Common Mixins:** ইউআই লজিক (যেমন SnackBar, Formatting) `CommonMethods` মিক্সিনের মাধ্যমে শেয়ার করতে হবে।

## ৩. ব্যাকগ্রাউন্ড এক্সেকিউশন এবং আইসোলেটস [CORE-BG-DNA]
অ্যাপের ব্যাকগ্রাউন্ড প্রসেসগুলো নিচের নিয়ম মেনে পরিচালিত হবে:
- **WorkManager:** অ্যান্ড্রয়েডের ব্যাকগ্রাউন্ড জবের জন্য `WorkManager` ব্যবহার করা হবে (যেমন: পিরিওডিক ডাটা সিঙ্ক এবং নোটিফিকেশন হ্যান্ডলিং)।
- **Dart Isolates:** ভারী ডেটা প্রসেসিং, এআই ইমেজ অ্যানালাইসিস বা বড় লিস্ট ফিল্টারিংয়ের জন্য অবশ্যই ডার্ট `Isolates` ব্যবহার করতে হবে যাতে মেইন ইউআই থ্রেড (Main UI Thread) কোনোভাবেই জ্যাম না হয়।
- **Service Continuity:** অ্যাপ বন্ধ থাকলেও এফসিএম (FCM) ব্যাকগ্রাউন্ড মেসেজ হ্যান্ডলারের মাধ্যমে ডাটা আপডেট বা নোটিফিকেশন প্রসেস করতে হবে।

## ৪. রেজিলিয়েন্স এবং এরর হ্যান্ডলিং [CORE-SAFE]
- **Visual Safety Net:** মেইন অ্যাপ লেভেলে একটি কাস্টম বেঙ্গলি `ErrorWidget` এনফোর্সড থাকবে।
- **Critical Fail:** Phase 1 ফেইল করলে অ্যাপ `CriticalErrorDialog` দেখিয়ে বন্ধ হয়ে যাবে।
- **Connectivity:** ইন্টারনেট চলে গেলে ব্যাকগ্রাউন্ডের সব সিঙ্ক সার্ভিস অটো-পজ হবে।

## 🚨 **STRUCTURAL ISSUES REQUIRING IMMEDIATE FIXES [CORE-ISSUES]**

### Missing Widget Exports
- **CRITICAL:** `ProductCard` widget referenced in 3+ screens but source file missing
- **Location Expected:** `lib/src/features/products/widgets/product_widgets.dart`
- **Action:** Create file with `ProductCard`, `ProductBottomAction` exports
- **Impact:** 3 screens cannot render (all_products_screen, search_screen, wishlist_screen, product_detail_screen)

### Missing Provider Exports (Violates CORE-ARCH-DNA)
- **CartState** not exported from `cart_provider.dart` → violates Centralized Providers rule
- **locationsProvider** undefined in DI layer → needs implementation
- **actualUserDataProvider** undefined → needs implementation  
- **Action:** Add to `lib/src/di/providers.dart` centralized location
- **Impact:** 2 files affected (core/providers.dart, di/providers.dart)

### Missing Service Methods
- **AiAutomationService.checkAndRun()** - Referenced in background_task_service.dart but not implemented
- **Product.fromMap()** signature mismatch - Expects 2 args, being called with 1 in category_tab.dart
- **Action:** Implement missing methods or fix call signatures
- **Impact:** Admin inventory management broken

### File Import Path Corrections
- `medicine_order_screen.dart` imports `../../../utils/styles.dart` → verify correct path
- `order_details_screen.dart` missing → create with proper navigation signature
- **Action:** Verify import paths exist and fix mismatch

## Change Log
- **2025-03-24:** Initial file lock. All existing technical environment and bootstrap logic confirmed. No lines can be removed from this point forward.
- **2025-03-25:** Architecture Update. Enforced Centralized Exports, Providers, and Base Layer (BaseScreen/BaseViewModel) for better project maintainability.
- **2025-03-24:** Code Cleanup Sprint Complete - Removed 21+ unused imports, variables, methods, and dead code. Compilation errors reduced 113 → 16 (85% fixed). **STATUS: 16 structural issues identified for systematic fixing.**
