# Model & State Management DNA [SYS-STATE-DNA] - [LOCKED STATUS: ACTIVE]
# মডেল এবং স্টেট ম্যানেজমেন্ট প্রোটোকল (বিস্তারিত)

পাইকারী বাজার অ্যাপের ডেটা ফ্লো এবং স্টেট ম্যানেজমেন্টের স্বচ্ছতা বজায় রাখতে এই নিয়মগুলো কঠোরভাবে পালন করতে হবে।

## ১. ডেটা মডেল ডিএনএ [STATE-MODEL-01]
প্রতিটি ডেটা মডেল (যেমন: Product, Order, User) অবশ্যই নিচের স্ট্যান্ডার্ড মেনে তৈরি করতে হবে:
- **Immutability:** সব মডেল ফিল্ড অবশ্যই `final` হতে হবে। ডেটা পরিবর্তনের জন্য `copyWith` মেথড ব্যবহার করতে হবে।
- **Factory Methods:** প্রতিটি মডেলে ফায়ারস্টোর থেকে ডেটা নেওয়ার জন্য `fromMap` এবং ডেটা সেভ করার জন্য `toMap` মেথড থাকতে হবে।
- **Type Safety:** ডাইনামিক ম্যাপ থেকে ডেটা নেওয়ার সময় টাইপ কাস্টিং (যেমন: `.toDouble()`, `.toInt()`) এবং ডিফল্ট ভ্যালু (Null Safety) নিশ্চিত করতে হবে।

## ২. রিভারপড স্টেট ম্যানেজমেন্ট [STATE-RIVERPOD-01]
- **Provider Types:** ডাটা স্ট্রিমিংয়ের জন্য `StreamProvider`, এসিঙ্ক্রোনাস ডেটার জন্য `FutureProvider` এবং কমপ্লেক্স স্টেট পরিবর্তনের জন্য `StateNotifierProvider` (বা আধুনিক `NotifierProvider`) ব্যবহার করতে হবে।
- **Scoped Providers:** সম্ভব হলে গ্লোবাল প্রোভাইডারের পরিবর্তে নির্দিষ্ট ফিচারের জন্য লোকাল প্রোভাইডার ব্যবহার করতে হবে।
- **Reactivity:** ইউআই-তে ডেটা দেখানোর সময় `ref.watch()` এবং কোনো অ্যাকশন (যেমন: বাটন ক্লিক) ট্রিগার করার সময় `ref.read()` ব্যবহার করতে হবে।

## ৩. সার্ভিস এবং রিপোজিটরি প্যাটার্ন [STATE-PATTERN-01]
- **Separation of Concerns:** ইউআই সরাসরি ফায়ারস্টোরে কোয়েরি করবে না। সব ডেটা অপারেশন অবশ্যই একটি **Service** ক্লাসের মাধ্যমে হতে হবে।
- **Dependency Injection:** সার্ভিসগুলো অবশ্যই GetIt-এর মাধ্যমে রেজিস্টার এবং ইনজেক্ট করতে হবে।
- **Error Handling:** সার্ভিসের প্রতিটি মেথড অবশ্যই এরর হ্যান্ডেল করবে এবং ইউআই-তে মিনিংফুল এরর মেসেজ পাঠাবে।

## ৪. লোডিং এবং এরর স্টেট [STATE-UI-01]
- **AsyncValue:** রিভারপড-এর `AsyncValue` ব্যবহার করে প্রতিটি ডাটা লোডিংয়ের জন্য ৩টি স্টেট (Data, Loading, Error) হ্যান্ডেল করা বাধ্যতামূলক।
- **Consistent UI:** পুরো অ্যাপে লোডিং এবং এরর মেসেজের জন্য একই ধরনের উইজেট ব্যবহার করতে হবে।

## ৫. ফিচার-স্পেসিফিক স্টেট ফ্লো [STATE-FEATURE-01]

### ক) কমার্স ডোমেইন (Commerce)
**State Flow:** Home → Products → ProductDetail → Cart → Checkout → Order
```
Key Providers:
├─ productsProvider (FutureProvider) 
│  └─ FutureProvider<List<Product>>
├─ productDetailProvider (FutureProvider)
│  └─ FutureProvider<Product> [family: productId]
├─ cartProvider (StateNotifierProvider)
│  └─ StateNotifierProvider<CartItemList>
├─ cartTotalProvider (Provider)
│  └─ Provider<CartTotal> [uses ref.select(cartProvider)]
├─ ordersProvider (StreamProvider)
│  └─ StreamProvider<List<Order>> [Real-time from Firestore]
└─ orderDetailProvider (FutureProvider)
   └─ FutureProvider<Order> [family: orderId]

Data Models:
├─ Product {id, name, nameEn, price, originalPrice, categoryId, images, stock, ...}
├─ CartItem {productId, quantity, addedAt, updatedAt}
├─ Order {id, userId, items: List<OrderItem>, total, status, createdAt, ...}
└─ OrderItem {productId, quantity, priceAtPurchase}
```

### খ) অ্যাডমিন ড্যাশবোর্ড (Admin Dashboard)
**State Flow:** Dashboard → Orders → Inventory → Analytics → Users
```
Key Providers:
├─ adminOverviewProvider (FutureProvider)
│  └─ FutureProvider<DashboardStats>
├─ adminAnalyticsProvider (FutureProvider)
│  └─ FutureProvider<AIInsight> [Calls AIService]
├─ ordersManagementProvider (StreamProvider)
│  └─ StreamProvider<List<AdminOrder>> [Real-time, filtered by time]
├─ inventoryProvider (StateNotifierProvider)
│  └─ StateNotifierProvider<InventoryList>
├─ categoriesProvider (FutureProvider)
│  └─ FutureProvider<List<Category>>
├─ usersProvider (FutureProvider)
│  └─ FutureProvider<List<User>> [pagination]
└─ resellerAppProvider (StreamProvider)
   └─ StreamProvider<List<ResellerApplication>>

Data Models:
├─ DashboardStats {totalSales, totalOrders, totalUsers, revenue, activeDeliveries}
├─ InventoryItem {productId, currentStock, lowStockThreshold, reorderPoint}
├─ ResellerApplication {id, userId, shopName, commissionRate, status, createdAt}
├─ AIInsight {id, forecast, recommendation, confidence, generatedAt}
└─ AdminOrder {order fields + managementStatus, notes, assignedStaff}
```

### গ) ইউজার প্রোফাইল (User Profile)
**State Flow:** ProfileScreen → EditProfile → Settings → Backup
```
Key Providers:
├─ currentUserProvider (StreamProvider)
│  └─ StreamProvider<User> [Real-time from Firestore]
├─ userProfileProvider (FutureProvider)
│  └─ FutureProvider<UserProfile>
├─ loyaltyPointsProvider (StreamProvider)
│  └─ StreamProvider<LoyaltyAccount>
├─ walletProvider (StreamProvider)
│  └─ StreamProvider<WalletBalance>
├─ wallletTransactionsProvider (StreamProvider)
│  └─ StreamProvider<List<WalletTransaction>>
├─ addressesProvider (FutureProvider)
│  └─ FutureProvider<List<Address>>
└─ preferencesProvider (StateNotifierProvider)
   └─ StateNotifierProvider<UserPreferences>

Data Models:
├─ User {uid, name, email, phone, profilePic, role, joiningDate, ...}
├─ UserProfile {user: User, loyaltyTier, totalOrders, totalSpent, ...}
├─ Address {id, label, fullAddress, latitude, longitude, isDefault}
├─ WalletTransaction {id, type: credit|debit, amount, date, description}
└─ UserPreferences {language, theme: light|dark, currency, notificationEnabled}
```

### ঘ) লজিস্টিকস (Logistics)
**State Flow:** OrderTracking → RiderDashboard → Delivery
```
Key Providers:
├─ orderTrackingProvider (StreamProvider)
│  └─ StreamProvider<OrderTracking>
├─ riderCurrentOrderProvider (StreamProvider)
│  └─ StreamProvider<Order> [Rider's active order]
├─ deliveryZonesProvider (FutureProvider)
│  └─ FutureProvider<List<DeliveryZone>>
└─ riderLocationProvider (StreamProvider)
   └─ StreamProvider<Location> [Live GPS tracking]

Data Models:
├─ OrderTracking {orderId, status, rider, location, eta, timeline}
├─ DeliveryZone {id, name, polygon, baseFee, deliveryTime}
└─ Location {latitude, longitude, accuracy, timestamp}
```

## ৬. প্রোভাইডার অর্গানাইজেশন [STATE-PROVIDER-01]
```
File Structure (lib/src/di/):
├─ providers.dart
│  └─ Main barrel file - exports all providers
├─ commerce_providers.dart
│  ├─ Product providers
│  ├─ Cart providers
│  └─ Order providers
├─ admin_providers.dart
│  ├─ Dashboard providers
│  ├─ Order management providers
│  └─ Inventory providers
├─ user_providers.dart
│  ├─ Authentication providers
│  ├─ Profile providers
│  ├─ Loyalty providers
│  └─ Wallet providers
├─ logistics_providers.dart
│  ├─ Tracking providers
│  └─ Rider providers
└─ shared_providers.dart
   ├─ Theme/Language providers
   └─ App state providers

Naming Convention:
├─ {entity}Provider → FutureProvider (static/cached data)
├─ {entity}StreamProvider → StreamProvider (real-time)
├─ {entity}StateProvider → StateNotifierProvider (mutable state)
├─ {entity}FamilyProvider(id) → Family providers (parameterized)
├─ {entity}SelectedProvider → Provider.select() (optimization)
└─ {entityList}StreamProvider → StreamProvider<List> (collections)
```

## ৭. মডেল সম্পর্ক [STATE-MODEL-REL-01]
```
Entity Relationships:

User (1) ──────→ (Many) Order
  └─has: loyaltyAccount, addresses, wallet

Product (1) ──────→ (Many) CartItem
  └─has: category, images, specifications

Order (1) ──────→ (Many) OrderItem
  ├─references: User, DeliveryZone
  └─has: OrderTracking

Inventory (1) ──────→ (1) Product
  ├─tracks: stock level
  ├─triggers: LowStockAlert
  └─manages: reorderPoint

DeliveryZone (1) ──────→ (Many) Order
  └─contains: polygons, fees

Category (1) ──────→ (Many) Product
  └─has: subcategories
```

## ৮. ডেটা সিঙ্ক্রোনাইজেশন [STATE-SYNC-01]
- **Offline-First Architecture:** Hive ডাটাবেসে লোকাল কপি রাখতে হবে।
- **Conflict Resolution:** যদি অনলাইন এবং অফলাইন ডেটা ডিফার করে, `lastModified` টাইমস্ট্যাম্প বেসড মার্জ হবে।
- **Periodic Sync:** 
  - অ্যাপ ওপেন হলে ফোরগ্রাউন্ড সিঙ্ক
  - প্রতি ৩০ মিনিটে ব্যাকগ্রাউন্ড সিঙ্ক
  - অফলাইন মোড থেকে অনলাইন যাওয়ার সময় সিঙ্ক
- **Background Sync:** অ্যাপ ক্লোজ হলেও Work Manager দ্বারা সিঙ্ক।
- **Sync Priority:** Critical (User, Cart) > High (Orders) > Medium (Inventory) > Low (Analytics)।

## ৯. রিয়েল-টাইম আপডেট [STATE-REALTIME-01]
```
Real-time Triggers:

1. Order Status Changes
   └─ Trigger: Firestore document update
   └─ Action: Immediate notification + UI update
   └─ Affected: OrderTracking, OrderDetail screens

2. Inventory Changes
   └─ Trigger: Product stock update
   └─ Action: Low stock alert, notification
   └─ Affected: ProductCard, AdminInventory screens

3. Rider Location Updates
   └─ Trigger: GPS data every 5 seconds
   └─ Action: Map update, ETA recalculation
   └─ Affected: OrderTracking screen

4. Chat Messages
   └─ Trigger: Firestore collection listener
   └─ Action: Message bubble animation
   └─ Affected: PrivateChat, ChatHistory screens
   └─ Latency Target: < 2 seconds

5. Loyalty Points Credit
   └─ Trigger: Order completion, promotion
   └─ Action: Points added, notification, badge update
   └─ Affected: Profile, RewardsScreen

6. Admin Notifications
   └─ Trigger: New order, application, alert
   └─ Action: Dashboard badge, notification
   └─ Affected: AdminDashboard screens
```

## ১০. স্টেট রিসেট এবং ক্লিনআপ [STATE-CLEANUP-01]
- **On Logout:** সব ইউজার-স্পেসিফিক প্রোভাইডার রিসেট করতে হবে।
- **On App Quit:** লোকাল ডাটাবেস সিঙ্ক করতে হবে।
- **On Error:** ব্যাকআপ ডেটা লোড করে রিসেট করতে হবে।
- **Family Providers:** পুরনো ফ্যামিলি ইনস্ট্যান্স পেরিওডিক্যালি ক্লিয়ার করতে হবে।

---

## ১১. ক্রস-রেফারেন্স (Cross-References)
- [Core DNA](core_dna.md) [SYS-CORE-DNA]
- [Visual DNA](visual_dna.md) [SYS-VISUAL-DNA]
- [Feature DNA](feature_dna.md) [SYS-FEAT-DNA]
- [Database DNA](database_dna.md) [SYS-DB-DNA]
- [Security DNA](security_dna.md) [SYS-SEC-DNA]
- [Integration DNA](integration_dna.md) [SYS-INT-DNA]
- [Operations DNA](operations_dna.md) [SYS-OPS-DNA]
- [Performance DNA](performance_dna.md) [SYS-PERF-DNA]
- [UI Feature Map](ui_feature_map.md) [SYS-UI-MAP]

---

## Change Log
- **2025-03-24:** Initial file lock. State management patterns confirmed.
- **2026-03-24:** Comprehensive expansion with feature-specific flows, provider organization, relationships, sync, and real-time updates. Added [LOCKED STATUS] and Cross-References.
