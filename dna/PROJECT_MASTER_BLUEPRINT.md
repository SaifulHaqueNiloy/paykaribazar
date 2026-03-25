# Paykari Bazar: The Absolute Master Blueprint (Locked - DNA Level)
# পাইকারী বাজার: চূড়ান্ত মাস্টার ব্লুপ্রিন্ট এবং টেকনিক্যাল ডিএনএ (১০০০% নিখুঁত)

---

## 0. Immutable Core Rules (অপরিবর্তনীয় মূল নিয়ম)
- **LOCKED STATUS:** এই ফাইলটি প্রোজেক্টের "Constitution"। ব্যবহারকারীর অনুমতি ছাড়া এতে কোনো পরিবর্তন করা যাবে না।
- **Architecture Integrity:** প্রোজেক্টে অবশ্যই ৩-লেয়ার আর্কিটেকচার (Core, Shared, Feature) এবং ৪-ফেজ DI ইনিশিয়ালাইজেশন বজায় রাখতে হবে।
- **Service Sovereignty:** প্রতিটি সার্ভিস অবশ্যই তার নির্দিষ্ট ফোল্ডারে (v2.0 Structure) থাকতে হবে।

---

## 1. Technical & Architecture DNA
### A. Framework & Core
- **Framework:** Flutter SDK v3.24.0+
- **State Management:** Riverpod (UI) + **GetIt (DI Engine)**.
- **DI Engine:** ৪-ধাপের এসিঙ্ক্রোনাস বুটিং লজিক (`lib/src/di/service_initializer.dart`).

### B. Dependency Injection Phases [LOCKED]
1. **Phase 1 (Core):** No dependencies. (Secrets, Connectivity, Storage, Permission, HealthCheck).
2. **Phase 2 (Firebase):** Async init required. (FirebaseCore, Firestore, AuthCore, Messaging).
3. **Phase 3 (Shared):** Cross-feature logic. (Media, Location, Notification, Map, Update).
4. **Phase 4 (Features):** Domain specific logic. (Auth, AI, Commerce, Logistics, Qibla).

---

## 2. Feature & Service Consolidation (The Clean Map)
### A. Core Layer (`lib/src/core/`)
- **Services:** `StorageService`, `ConnectivityService`, `PermissionService`, `ErrorReporterService`, `HealthCheckService`.
- **Firebase:** `FirebaseCoreService`, `FirestoreService`, `FirebaseAuthService`, `FirebaseMessagingService`.

### B. Shared Layer (`lib/src/shared/`)
- **Services:** `MediaService` (Image/Cloudinary), `LocationService` (GPS), `NotificationService` (Local/FCM), `MapService`, `UpdateService`, `BackgroundTaskService`.

### C. Feature Layer (Consolidated 7 Domains)
- **1. Commerce Domain:** `CartService`, `CartPosService`, `LoyaltyService`, `CouponService`. (Covers: Products, Orders, Shop).
- **2. Logistics Domain:** `DeliveryService`, `GeofencingService`. (Covers: Tracking, Rider Location).
- **3. Identity Domain:** `AuthService`. (Covers: User Profile, Reseller/Partner roles).
- **4. Intelligence Domain:** `AIService`, `AIAuditService`, `AIAutomationService`, `ApiQuotaService`, `ForecastingService`, `AiCommandService`. (Covers: Search).
- **5. Interaction Domain:** `NotificationService`. (Covers: Chat, Support).
- **6. Admin Domain:** Back-office management, Staff roles, Analytics.
- **7. Specialized Domain:** `CompassService` (Qibla). (Covers: Info, Home).

---

## 3. Visual DNA & User Experience Protocols
- **Official Name:** "পাইকারী বাজার" (Paykari Bazar).
- **Branding:** Teal & White theme with Adaptive Grid (2, 3, 4 columns).
- **Guidance:** প্রতিটি বাটনে বাংলায় `Tooltip` থাকা বাধ্যতামূলক।
- **Error UI:** সব এরর ডায়ালগ বক্সে (AlertDialog) দেখাতে হবে।
- **Visual Safety Net:** Custom Bengali `ErrorWidget` enforced at main level.

---

## 4. AI Sovereign Engine (Omnipotent Routing)
- **Priority:** NVIDIA (Kimi-k2.5) > DeepSeek > Gemini.
- **Resilience:** একটি মডেল ফেইল করলে অটোমেটিক অন্যটিতে সুইচ করা।
- **Automation:** প্রতি ১ ঘণ্টা পর পর এআই অটো-অডিট এবং সিস্টেম হেলথ চেক।

---

## 5. Financial & Data DNA [SYS-FINANCE-01]
- **Escrow Protocol:** কাস্টমার ডেলিভারি নিশ্চিত করলেই ভেন্ডর টাকা পাবে।
- **Data Hub:** Firestore এর `users`, `hub/data/products`, এবং `orders` এর ডাটা স্ট্রাকচার।
- **Sanity Protocol:** কোনো ডাটা মিসিং থাকলে (Null) অবশ্যই হার্ডকোডেড ডিফল্ট ভ্যালু (0.0) ব্যবহার করতে হবে।

---

## 6. Security & Versioning
- **Validation:** `ServiceInitializer` অ্যাপ বুটিং এর সময় সব সার্ভিস রেজিস্ট্রেশন চেক করে।
- **Sovereignty:** `pubspec.yaml` এর ভার্সন ডাটাবেসের `customer_latest_version` দ্বারা নিয়ন্ত্রিত।
- **Maintenance DNA:** Consolidated feature domains enforced to prevent folder clutter.

---

**FINAL PERMANENT LOCK:** This version is fully synchronized with FUTURE_PLAN_BLUEPRINT.md v2.0.
**Identity:** Branding - **পাইকারী বাজার**.
**Status:** CONSOLIDATED & LOCKED.
