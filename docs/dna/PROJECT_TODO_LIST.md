# 📋 Paykari Bazar - Project TODO List (Audit Based)
**Generated**: March 24, 2026
**Based on**: 2026 Flutter/Firebase Best Practices Audit

---

## 🔴 অত্যন্ত জরুরি (Critical)
- [x] **Firestore Security Rules**: প্রতিটি কালেকশনের জন্য আলাদা এবং কড়া রুলস লেখা। (Updated Orders & Users)
- [x] **Firebase App Check**: Play Integrity/DeviceCheck চালু করা। (Code Integrated)
- [ ] **Role Management (RBAC)**: Custom Claims ব্যবহার করে অ্যাডমিন এবং রাইডার রোল সিকিউর করা। (Cloud Functions Required)

## 🟡 উচ্চ গুরুত্ব (High Priority)
- [x] **Pagination (Lazy Loading)**: পণ্য লিস্টে (Products) প্যাগিনেশন যোগ করা। (ProductService Updated)
- [ ] **Background Isolates**: বড় ডাটা পার্সিংয়ের জন্য `compute()` ব্যবহার করা।
- [x] **State Optimization**: Riverpod `select()` ব্যবহার করে অপ্রয়োজনীয় রিবিল্ড কমানো।
- [x] **Const Constructors**: পুরো প্রজেক্টে `const` ব্যবহারের হার বাড়ানো।

## 🟢 মাঝারি গুরুত্ব (Medium Priority)
- [x] **Offline Location Caching**: Hive ব্যবহার করে জেলা/উপজেলা ডাটা লোকাল মেমরিতে সেভ করা।
- [ ] **Emergency Offline Support**: জরুরি নম্বরগুলো অফলাইনেও দেখার ব্যবস্থা করা।
- [ ] **WebP Image Support**: সার্ভার থেকে WebP ফরম্যাটে ছবি এনফোর্স করা।

## 🔵 কম গুরুত্ব (Low Priority)
- [ ] **CI/CD Verification**: GitHub Actions ঠিকমতো কাজ করছে কি না নিশ্চিত করা।
- [ ] **App Size Optimization**: `split-debug-info` ব্যবহার করে APK সাইজ কমানো। (Gradle Optimization Started)
- [ ] **Asset Cleanup**: অব্যবহৃত ছবি ও ফন্ট রিমুভ করা।

---
## ✅ আজ যা সম্পন্ন হয়েছে (Completed Today)
- [x] **Pagination**: ProductService now supports fetching data in chunks.
- [x] **App Check**: Security layer activated for Firebase APIs.
- [x] **Offline Cache**: District/Upazila info is now stored in Hive for offline access.
- [x] **Security Rules**: Added strict field validation for Order collection.
- [x] **Image Optimization**: Added `memCacheWidth/Height` to prevent RAM issues.
- [x] **Loyalty Race Condition**: Firestore Transaction implemented for points.
- [x] **Sensor Optimization**: RepaintBoundary added to Floating Cart.
- [x] **Localization Sync**: Theme and Lang preferences now persistent.
