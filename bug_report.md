# 🐛 Paykari Bazar — সম্পূর্ণ সমস্যার তালিকা

> **তৈরির তারিখ:** ১৫ জুন, ২০২৬  
> **প্রজেক্ট:** Paykari Bazar (Flutter)  
> **বিশ্লেষণের পদ্ধতি:** Dart Analyzer + Manual Code Review + Firestore Rules Review

---

## 🔴 CRITICAL (মারাত্মক সমস্যা)

### ১. `.env` ফাইলে সরাসরি API Key থাকা কিন্তু Git-এ পুশ হওয়ার ঝুঁকি
**ফাইল:** [.env](file:///c:/Users/n/paykari_bazar/.env)  
**সমস্যা:** `.env` ফাইলে একাধিক real API Key আছে (Gemini, Cloudinary, NVIDIA, Groq, DeepSeek, Telegram Bot Token, Sentry DSN, Google Maps API)। যদিও `.gitignore`-এ `.env` যুক্ত আছে, কিন্তু `pubspec.yaml`-এ assets-এ `.env` যুক্ত করা হয়েছে — মানে এটি APK-এর ভেতরে যাচ্ছে এবং যেকেউ APK decompile করে এই সব API Key বের করতে পারবে।  
```yaml
# pubspec.yaml L123
assets:
  - .env  # ⚠️ APK-এ যাচ্ছে — সিকিউরিটি ঝুঁকি!
```
**সমাধান:** Firebase Remote Config বা Flutter Secure Storage ব্যবহার করুন।

---

### ২. Firestore-এ সবার পড়ার অনুমতি — Users Collection
**ফাইল:** [firestore.rules](file:///c:/Users/n/paykari_bazar/firestore.rules#L35-L37)  
**সমস্যা:** যেকোনো লগইন করা ইউজার সব ইউজারের ডাটা পড়তে পারছে।
```
match /users/{userId} {
  allow read: if isAuth(); // ⚠️ যে কেউ অন্যের ডাটা পড়তে পারছে!
```
**সমাধান:** `allow read: if isOwner(userId) || isAdmin();`

---

### ৩. Promos Collection-এ যেকেউ লিখতে পারছে
**ফাইল:** [firestore.rules](file:///c:/Users/n/paykari_bazar/firestore.rules#L155-L158)  
**সমস্যা:** `allow write: if isAdmin() || isAuth();` — যে কোনো লগইন করা ইউজার প্রমো ডাটা পরিবর্তন করতে পারছে।  
**সমাধান:** `allow write: if isAdmin();`

---

### ৪. Products Collection-এ যেকেউ লিখতে পারছে
**ফাইল:** [firestore.rules](file:///c:/Users/n/paykari_bazar/firestore.rules#L65-L68)  
**সমস্যা:** `allow write: if isAdmin() || isReseller() || isAuth();` — সব authenticated ইউজার পণ্য যোগ/পরিবর্তন করতে পারছে।  
**সমাধান:** `allow write: if isAdmin() || isReseller();`

---

### ৫. Restore বাটনে ভুল ফাংশন কল
**ফাইল:** [backup_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/profile/backup_screen.dart#L90)  
**সমস্যা:** "রিস্টোর" বাটনে `performFullBackup()` কল হচ্ছে — রিস্টোরের বদলে আরেকটি ব্যাকআপ তৈরি হচ্ছে!
```dart
// L90 - এটা BUG!
await backupService.performFullBackup(user.uid); // ❌ restore করার কথা ছিল
```
**সমাধান:** সঠিক `performRestore()` মেথড ইমপ্লিমেন্ট ও কল করুন।

---

## 🟠 HIGH (গুরুত্বপূর্ণ সমস্যা)

### ৬. `collection` প্যাকেজ pubspec.yaml-এ নেই কিন্তু ব্যবহার হচ্ছে
**ফাইল:** [product_detail_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/products/product_detail_screen.dart#L5)  
**Dart Analyzer সতর্কতা:** `depend_on_referenced_packages`
```dart
import 'package:collection/collection.dart'; // ❌ pubspec.yaml-এ নেই
```
**সমাধান:** `pubspec.yaml`-এ `collection: ^1.18.0` যোগ করুন।

---

### ৭. Unused Import — `firebase_app_check`
**ফাইল:** [main_admin.dart](file:///c:/Users/n/paykari_bazar/lib/main_admin.dart#L10), [main_customer.dart](file:///c:/Users/n/paykari_bazar/lib/main_customer.dart#L14)  
**Dart Analyzer সতর্কতা:** `unused_import`  
```dart
import 'package:firebase_app_check/firebase_app_check.dart'; // ❌ অব্যবহৃত
```
**সমাধান:** Import লাইন মুছে দিন অথবা FirebaseAppCheck ব্যবহার করুন।

---

### ৮. Unused Import — `backup_service`
**ফাইল:** [backup_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/profile/backup_screen.dart#L10)  
**Dart Analyzer সতর্কতা:** `unused_import`
```dart
import '../../services/backup_service.dart'; // ❌ অব্যবহৃত
```
**সমাধান:** Import মুছুন অথবা সঠিকভাবে ব্যবহার করুন।

---

### ৯. Unused Variable — `res` in signup_screen.dart
**ফাইল:** [signup_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/auth/signup_screen.dart#L62)  
**Dart Analyzer সতর্কতা:** `unused_local_variable`
```dart
final res = await ref.read(authServiceProvider).signUp(...); // 'res' কখনো ব্যবহার হয় না
```

---

### ১০. Notifications Screen বাস্তবায়িত নয় (Placeholder)
**ফাইল:** [home_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/home/home_screen.dart#L247-L251)  
**সমস্যা:** নোটিফিকেশন বাটনে SnackBar দেখানো হচ্ছে — কোনো আসল স্ক্রিন নেই।
```dart
// 💡 Issue 15: Placeholder until NotificationsScreen is implemented
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('কোনো নতুন নোটিফিকেশন নেই')),
);
```

---

### ১১. `home_providers.dart` — Duplicate/Unused Providers
**ফাইল:** [home_providers.dart](file:///c:/Users/n/paykari_bazar/lib/src/services/home_providers.dart)  
**সমস্যা:** `flashDealsProvider`, `newArrivalsProvider`, `hotSellingProvider` ইত্যাদি providers আছে, কিন্তু `home_screen.dart` সেগুলো ব্যবহার করছে না — সরাসরি `productsProvider` থেকে filter করছে। এই providers অব্যবহৃত।

---

### ১২. Phone Number Normalization Bug
**ফাইল:** [auth_service.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/auth/services/auth_service.dart#L30-L44)  
**সমস্যা:** `+880` এর ক্ষেত্রে `substring(3)` ব্যবহার হচ্ছে কিন্তু `+880` স্ট্রিং-এর দৈর্ঘ্য ৪, তাই `substring(3)` শুধু `0` বাদ দেয়, সঠিকভাবে `880` বাদ দেয় না।
```dart
if (cleaned.startsWith('+880')) {
  cleaned = cleaned.substring(3); // ❌ হওয়া উচিত substring(4)
}
```

---

### ১৩. Product Detail Screen-এ Data Loading Race Condition
**ফাইল:** [product_detail_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/products/product_detail_screen.dart#L35)  
**সমস্যা:** `initState` এ `ref.read(productsProvider).value` ব্যবহার হচ্ছে। যদি provider তখনো loading থাকে, `value` null হবে এবং পণ্য দেখাবে না।
```dart
final products = ref.read(productsProvider).value ?? []; // ❌ loading অবস্থায় খালি
```

---

## 🟡 MEDIUM (মাঝারি সমস্যা)

### ১৪. Unnecessary Imports
**Dart Analyzer সতর্কতা:** `unnecessary_import`  
নিচের ফাইলগুলোতে `flutter/material.dart` আছে, কিন্তু `flutter/foundation.dart` থেকেই সব পাওয়া যাচ্ছে:
- [main_admin.dart](file:///c:/Users/n/paykari_bazar/lib/main_admin.dart#L11)
- [api_security_service.dart](file:///c:/Users/n/paykari_bazar/lib/src/core/services/api_security_service.dart#L5)
- [encryption_service.dart](file:///c:/Users/n/paykari_bazar/lib/src/core/services/encryption_service.dart#L4)
- [auth_service.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/auth/services/auth_service.dart#L6)
- [backup_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/profile/backup_screen.dart#L5)

---

### ১৫. `curly_braces_in_flow_control_structures` সতর্কতা
**ফাইল:** [api_security_service.dart](file:///c:/Users/n/paykari_bazar/lib/src/core/services/api_security_service.dart#L78)  
**সমস্যা:** `if` statement-এ curly braces নেই।
```dart
if (kDebugMode) debugPrint(...); // ❌ ব্রেস ছাড়া
```

---

### ১৬. `prefer_final_locals` সতর্কতা
**ফাইল:** [customer_simulator_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/profile/customer_simulator_screen.dart#L179)  
**সমস্যা:** Local variable `final` দিয়ে declare করা হয়নি।

---

### ১৭. `product_detail_screen.dart` — "RELATED PRODUCTS" এবং অন্য টেক্সট Hardcoded ইংরেজিতে
**ফাইল:** [product_detail_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/products/product_detail_screen.dart#L87)  
**সমস্যা:** UI টেক্সট `AppStrings` ব্যবহার করছে না।
```dart
const Text('RELATED PRODUCTS', ...) // ❌ বাংলা নেই
const Text('DESCRIPTION', ...)      // ❌ বাংলা নেই
const Text('Quantity:', ...)        // ❌ বাংলা নেই
const Text('Added to cart')         // ❌ বাংলা নেই
const Text('OUT OF STOCK')          // ❌ বাংলা নেই
const Text('ADD TO CART')           // ❌ বাংলা নেই
```

---

### ১৮. Navigation Bar Labels ইংরেজিতে (Localization নেই)
**ফাইল:** [main_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/main_screen.dart#L93-L102)  
**সমস্যা:** Bottom Navigation Bar-এর labels সরাসরি ইংরেজিতে।
```dart
NavigationDestination(label: 'Home')      // ❌ 'হোম' হওয়া উচিত
NavigationDestination(label: 'Emergency') // ❌ বাংলা নেই
NavigationDestination(label: 'Products')  // ❌ বাংলা নেই
NavigationDestination(label: 'Rewards')   // ❌ বাংলা নেই
NavigationDestination(label: 'Profile')   // ❌ বাংলা নেই
```

---

### ১৯. `withOpacity()` Deprecated পদ্ধতির ব্যবহার
**ফাইল:** [home_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/home/home_screen.dart#L164-L174) এবং অন্যান্য অনেক ফাইল  
**সমস্যা:** Flutter 3.27+ থেকে `withOpacity()` deprecated।
```dart
color.withOpacity(0.12) // ❌ deprecated
// ✅ হওয়া উচিত:
color.withValues(alpha: 0.12)
```

---

### ২০. isNewArrival Default Value ভুল
**ফাইল:** [product_model.dart](file:///c:/Users/n/paykari_bazar/lib/src/models/product_model.dart#L124)  
**সমস্যা:** নতুন Product তৈরির সময় `isNewArrival` ডিফল্ট `true` — মানে সব পণ্যই "নতুন পণ্য" হয়ে যাচ্ছে।
```dart
this.isNewArrival = true, // ❌ ডিফল্ট false হওয়া উচিত
```

---

### ২১. `toMap()` এ `aiDescriptionBnEnriched` ফিল্ড নেই
**ফাইল:** [product_model.dart](file:///c:/Users/n/paykari_bazar/lib/src/models/product_model.dart#L199-L246)  
**সমস্যা:** `fromMap()` তে `aiDescriptionBnEnriched` পড়া হয়, কিন্তু `toMap()` তে সেটি লেখা হয় না — ডাটা হারাবে।

---

### ২২. `_CustomerAppState` এ async `_checkUpdate()` সঠিকভাবে await করা হয়নি
**ফাইল:** [main_customer.dart](file:///c:/Users/n/paykari_bazar/lib/main_customer.dart#L186)  
**সমস্যা:** `Future.delayed` এর ভেতরে `_checkUpdate()` কল, কিন্তু `void` ফাংশনকে `async` করা হয়েছে — error হলে সাইলেন্ট ফেল।
```dart
Future.delayed(const Duration(seconds: 3), () => _checkUpdate()); 
// _checkUpdate() একটি async void — unawaited future
```

---

### ২৩. Sandbox "Nuke" Feature শুধু UI কাজ করে, আসল কাজ করে না
**ফাইল:** [customer_simulator_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/profile/customer_simulator_screen.dart#L53-L56)  
**সমস্যা:** কনফার্মেশনের পরে শুধু SnackBar দেখায়, আসলে কোনো ডাটা ডিলিট হয় না।
```dart
if (confirmed == true && mounted) {
  // Logic to trigger sandbox cleanup... (comment only)
  ScaffoldMessenger.of(context).showSnackBar(...); // শুধু message
}
```

---

## 🟢 LOW (ছোট সমস্যা)

### ২৪. `pubspec.yaml` এ `crypto` প্যাকেজের Version Pinned (^ ছাড়া)
**ফাইল:** [pubspec.yaml](file:///c:/Users/n/paykari_bazar/pubspec.yaml#L73)  
**সমস্যা:** `crypto: 3.0.7` — caret (`^`) নেই, তাই patch update পাবে না।
```yaml
crypto: 3.0.7 # ❌ হওয়া উচিত: crypto: ^3.0.7
```

---

### ২৫. Root Directory-তে অপ্রয়োজনীয় Test Output ফাইল
**ফাইল:** Root directory-তে `fail_details.txt`, `fail_list.txt`, `failed_tests.txt`, `test_output.txt`, `test_result.txt`, `stdout.txt`, `stderr.txt`, `ai_test_result.txt`, `enc_test.txt`  
**সমস্যা:** এগুলো temporary debug ফাইল, প্রজেক্টের রুটে রাখা উচিত না। `.gitignore`-এও যোগ করা উচিত।

---

### ২৬. Root Directory-তে `.hive` ও `.lock` ফাইল
**ফাইল:** `ai_response_cache.hive`, `ai_response_cache.lock`, `app_cache_box.hive`  
**সমস্যা:** Cache ফাইল প্রজেক্টের রুটে।

---

### ২৭. `isAdmin()` ফাংশনে Expensive Firestore Read
**ফাইল:** [firestore.rules](file:///c:/Users/n/paykari_bazar/firestore.rules#L9-L14)  
**সমস্যা:** প্রতিটি request-এ `isAdmin()` দুটো Firestore read করছে (admins collection + users collection)। এটি পারফরম্যান্স কমায় এবং Firestore cost বাড়ায়।

---

### ২৮. `home_screen.dart` এ `_t()` ব্যবহার করে `ref.watch()` — Build মেথডের বাইরে
**ফাইল:** [home_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/home/home_screen.dart#L112-L115)  
**সমস্যা:** `_t()` মেথডে `ref.watch()` আছে। এই মেথড `_buildSectionShortcuts()` ইত্যাদি থেকে কল হয়, যা build method থেকে আসলে ঠিক আছে, কিন্তু `_checkAndShowRewards()` বা অন্য non-build context থেকে কল হলে ক্র্যাশ করতে পারে।

---

### ২৯. `product_detail_screen.dart` — `_product` null-safety সমস্যা
**ফাইল:** [product_detail_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/products/product_detail_screen.dart#L108)  
**সমস্যা:** `_buildSliverAppBar` এ `_product!` force-unwrap করা হচ্ছে, কিন্তু build-এর শুরুতে null check করা থাকলেও এই মেথডগুলো সরাসরি `_product!` ব্যবহার করে।

---

### ৩০. Signup Screen-এ Password Validation নেই
**ফাইল:** [signup_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/auth/signup_screen.dart#L51-L58)  
**সমস্যা:** শুধু empty check আছে, password minimum length বা strength check নেই।
```dart
// শুধু empty check:
if (_passCtrl.text.isEmpty)
// ✅ এটাও থাকা উচিত:
// if (_passCtrl.text.length < 8)
```

---

### ৩১. `main_screen.dart` এ IndexedStack সবসময় সব Screen লোড রাখছে
**ফাইল:** [main_screen.dart](file:///c:/Users/n/paykari_bazar/lib/src/features/main_screen.dart#L71-L79)  
**সমস্যা:** `IndexedStack` সব ৫টি স্ক্রিন একসাথে widget tree-তে রাখে — `EmergencyDetailsScreen` (39KB!) সবসময় active। Memory ব্যবহার বেশি।

---

## 📋 সারসংক্ষেপ

| মাত্রা | সংখ্যা |
|--------|--------|
| 🔴 Critical | ৫ টি |
| 🟠 High | ৮ টি |
| 🟡 Medium | ৯ টি |
| 🟢 Low | ৯ টি |
| **মোট** | **৩১ টি** |

---

## ✅ সম্পূর্ণ করা হয়েছে

| # | সমস্যা | স্থান | স্ট্যাটাস |
|---|--------|-------|----------|
| 1 | `.env` ইনপুট এপিকে `pubspec.yaml` থেকে রিমুভ করা হয়েছে | `pubspec.yaml` | ✅ FIXED |
| 2 | Firestore `users` ক্যালেকশন Permission সঠিক করা হয়েছে — `allow read: if isOwner(userId) || isAdmin()` | `firestore.rules:36` | ✅ FIXED |
| 3 | `promos` ক্যালেকশন write শুধুমাত্র অ্যাডমিনের জন্য — `allow write: if isAdmin()` | `firestore.rules:157` | ✅ FIXED |
| 4 | `products` ক্যালেকশন write từ `isAuth()` সরিয়ে দেওয়া হয়েছে — `allow write: if isAdmin() || isReseller()` | `firestore.rules:67` | ✅ FIXED |
| 5 | Restore বাটন ভুল `performFullBackup()` কল করছে — এখন `restoreFromBackup()` correct file URL নিয়ে কল করছে | `backup_screen.dart:90-92` | ✅ FIXED |
| 6 | `collection` প্যাকেজ যোগ করা হয়েছে `pubspec.yaml`-এ | `pubspec.yaml:74` | ✅ FIXED |
| 7 | Phone normalization bug — `+880` হলে `substring(4)` ব্যবহার করা হয়েছে | `auth_service.dart:33` | ✅ FIXED |
| 8 | `main_admin.dart` ও `main_customer.dart` থেকে অব্যবহৃত `firebase_app_check` import সরানো হয়েছে | `main_admin.dart:10`, `main_customer.dart:14` | ✅ FIXED |
| 9 | `isNewArrival` ডিফল্ট `false` করা হয়েছে | `product_model.dart:124` | ✅ FIXED |
| 10 | `toMap()` এ `aiDescriptionBnEnriched` ফিল্ড যোগ করা হয়েছে | `product_model.dart:245` | ✅ FIXED |
| 11 | নোটিফিকেশন বাটনে `/notifications` স্ক্রিনে নেভিগেট করা হচ্ছে | `home_screen.dart:246` | ✅ FIXED |
| 12 | `product_detail_screen.dart`-এর হার্ডকোডেড ইংরেজি টেক্সট `AppStrings`-এ রুট bridging করা হয়েছে (প্র`src/utils/app_strings.dart`-এ নতুন keys যোগ করা হয়েছে: `similarProducts`, `quantity`, `addedToCart`, `outOfStock`, `addToCart`, `descriptionTitle`) | `product_detail_screen.dart`, `app_strings.dart` | ✅ FIXED |
| 13 | `main_screen.dart` Bottom Navigation Bar লেবেল `languageProvider` থেকেrips | `main_screen.dart:22-26, 94-101` | ✅ FIXED |
| 14 | `main_customer.dart`-এ `Future.delayed(..., () => _checkUpdate())` সরিয়ে `_checkUpdate()` directly call করা হয়েছে | `main_customer.dart:169-172` | ✅ FIXED |
| 15 | `signup_screen.dart`-এ পাসওয়ার্ড লেন্থ >= 8 চেক যোগ করা হয়েছে | `signup_screen.dart:52-53` | ✅ FIXED |
| 16 | `product_detail_screen.dart`-এ `_product!` force-unwrap ਸਮੱਸ্যা হাল করে躍 data fetch form \\u0027build()\\u0027-এ সরাসরি provider ব্যবহার করা হয়েছে | `product_detail_screen.dart:27-42` | ✅ FIXED |
| 17 | `firestore.rules`-এ `isAdmin()` optimization হয়েছে, কিন্তু সম্পূর্ণ rewrite needed; marking partial | `firestore.rules:9-14` | ⚠️ PARTIAL |
| 18 | `withOpacity()` → `withValues()` edited ফাইলগুলোতে sarejachurilla; 300+ occurrences across codebase全党 | Multiple files | 🔄 IN PROGRESS |
| 19 | `test/widget_test.dart` ডুপ্লিকেট ফাইল রিমুভ করা হয়েছে | `test/widget_test.dart` | ✅ FIXED |
| 20 | `analysis_options.yaml` এ unawaited_futures এবং missing_required_param কে error করা হয়েছে | `analysis_options.yaml` | ✅ FIXED |
| 21 | `AiAutomationService`-এ `checkAndRun()` এবং structured logging ইমপ্লিমেন্ট করা হয়েছে | `ai_automation_service.dart` | ✅ FIXED |
| 22 | `providers.dart` এ `currentUserDataProvider` এবং `actualUserDataProvider` এর ডুপ্লিকেট ডাটা ফেচিং ও সিমুলেশন বাগ ফিক্স করা হয়েছে | `providers.dart` | ✅ FIXED |

---

## 🔍 Duplicate / Empty / Stub Files Detected

| # | ফাইলের পাথ | আকার |ধരন | বিবরণ |
|---|-----------|-------|------|--------|
| 1 | `lib/src/features/delivery/delivery_dashboard_screen.dart` | 79 bytes | Stub | শুধুমাত্র একটি কমেন্ট — `DEPRECATED: Duplicate of lib/src/features/delivery/delivery_dashboard.dart` |
| 2 | `lib/src/features/staff/staff_team_screen.dart` | 77 bytes | Stub | শুধুমাত্র একটি কমেন্ট — `DEPRECATED: Duplicate of lib/src/features/profile/staff_team_screen.dart` |
| 3 | `lib/src/features/products/widgets/product_widgets.dart` | 94 bytes | Re-export stub | `export 'package:paykari_bazar/src/features/home/widgets/home_widgets.dart' show ProductCard;` |
| 4 | `lib/src/core/extensions.dart` | 99 bytes | Re-export stub | `export 'extensions/map_extensions.dart';` + comment |
| 5 | `paykari_bazar/lib/main.dart` | 83 bytes | Redirect stub | `export 'main_customer.dart';` |
| 6 | `paykari_bazar_admin/lib/main.dart` | 77 bytes | Redirect stub | `export 'main_admin.dart';` |
| 7 | `paykari_bazar_admin/lib/main_admin.dart` | 59 bytes | Stub | শুধুমাত্র `// DEPRECATED: Moved to paykari_bazar/lib/main_admin.dart` |
| 8 | `paykari_bazar/test/widget_test.dart` | 66 bytes | Stub | শুধুমাত্র `// Deprecated: Use logic-based tests in coupon_service_test.dart` |
| 9 | `test/widget_test.dart` | 391 bytes | Duplicate | `test/widgets/widget_test.dart`-এর exact duplicate |
| 10 | `test/widgets/widget_test.dart` | 391 bytes | Duplicate | `test/widget_test.dart`-এর exact duplicate |

---

### পরামর্শ (Recommendation)

- স্টাব/ডুপ্লিকেট ফাইলগুলো (`delivery_dashboard_screen.dart`, `staff_team_screen.dart`, `main.dart` redirects, `extensions.dart`, `product_widgets.dart`, `main_admin.dart` stub) সরিয়ে ফেলুন অথবা বrardercase-এ **archive** ফোল্ডারে নิน।
- `test/widget_test.dart` ও `test/widgets/widget_test.dart` একই কনটেন্ট — একটি বর্জন করুন।
- ডুপ্লিকেটগুলোగła `git rm` করে commit করুন।

---
