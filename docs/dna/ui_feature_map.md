# UI & UX Feature Map [SYS-UI-MAP] - [LOCKED STATUS: ACTIVE]
# প্রতিটি ফিচার, পেজ এবং কম্পোনেন্টের বিস্তারিত ডিজাইন প্রোটোকল (মাস্টার সংস্করণ)

এই নথিতে অ্যাপের প্রতিটি স্ক্রিন, বাটন, কার্ড এবং তাদের ডিজাইন ডিএনএ বিস্তারিতভাবে দেওয়া হয়েছে।

---

## ১. কমার্স ডোমেইন (Commerce) [UI-COMM]

### ক. হোম স্ক্রিন (Home Screen)
- **ডিজাইন:** টপবার (সার্চ + ভয়েস), ৩-কলাম অ্যাডাপ্টিভ গ্রিড ক্যাটাগরি, অটো-স্লাইডিং ব্যানার।
- **কার্ড:** `CategoryCard` (Circular), `ProductCard` (Square)।
- **বাটন:** 'সব দেখুন' (Text Button), 'সার্চ' (Icon Button)।

### খ. প্রোডাক্ট ডিটেইল (Product Detail)
- **ডিজাইন:** হিরো ইমেজ স্লাইডার, চটজলদি চ্যাট বাটন (Seller Chat)।
- **বাটন:** `PrimaryButton` (এখনই কিনুন), `SecondaryButton` (ব্যাগে যোগ করুন)।
- **লজিক:** পাইকারী বা প্যাকেজ মূল্য (Bulk Pricing) টেবিল প্রদর্শন।

### গ. কার্ট এবং চেকআউট (Cart & Checkout)
- **ডিজাইন:** আইটেম লিস্ট উইথ কোয়ান্টিটি এডিটর।
- **বাটন:** `SubmitButton` (অর্ডার নিশ্চিত করুন)।
- **পেমেন্ট কার্ড:** বিকাশ, নগদ এবং ক্যাশ-অন-ডেলিভারি (selectable cards)।

---

## ২. ইমার্জেন্সি এবং হেলথকেয়ার (Emergency) [UI-EMER]

### ক. মেডিসিন অর্ডার এবং ব্লাড এইড
- **কার্ড:** `PrescriptionCard` (Upload zone), `DonorCard` (Name, Group, Distance)।
- **বাটন:** `EmergencyButton` (রক্ত প্রয়োজন - Red Pulse), `CallButton` (সরাসরি কল)।

---

## ৩. চ্যাট এবং সাপোর্ট (Interactions) [UI-CHAT]

### ক. মেসেজ হিস্ট্রি এবং চ্যাট রুম
- **কার্ড:** `ChatUserCard` (Profile, Last Msg, Time)।
- **ডিজাইন:** বাবল চ্যাট ইন্টারফেস (User: Blue, Others: White)।
- **বাটন:** `AiReplyChip` (এআই অটো-রিপ্লাই শর্টকাট)।

---

## ৪. অ্যাডমিন এবং স্টাফ হাব (Admin/Staff) [UI-ADMIN]

### ক. ড্যাশবোর্ড এবং ইনভেন্টরি
- **কার্ড:** `StatCard` (Total Sales, Users, Orders - Colored Backgrounds)।
- **ট্যাব:** ড্যাশবোর্ড, অর্ডার ম্যানেজমেন্ট, ইনভেন্টরি, ইউজার রোল, এআই কন্ট্রোল।
- **বাটন:** `ActionButton` (Approve/Reject - Green/Red Chips)।

---

## ৫. রাইডার এবং লজিস্টিকস (Logistics) [UI-LOG]

### ক. রাইডার ড্যাশবোর্ড
- **কার্ড:** `TaskCard` (Order ID, Address, Status, Navigate Button)।
- **ফিচার:** সিগনেচার প্যাড এবং ওটিপি ভেরিফিকেশন পপ-আপ।

---

## ৬. কমন কম্পোনেন্ট ডিজাইন (Common Widgets) [UI-COMP]

### ক. প্রোডাক্ট কার্ড (Product Card) - [LOCKED]
- **Corner:** 16px Rounded।
- **Shadow:** Elevation 1-2।
- **Elements:** Discount Tag, Hero Image, Title (BN/EN), Current Price (Bold), Old Price (Strike), '+' Cart Button।

### খ. বাটন ডিজাইন ডিএনএ (Buttons DNA)
- **Primary:** Deep Purple, White Text, 12px Radius, Bold।
- **Secondary:** Outline Purple, Icon Support।
- **Emergency:** Blood Red, Pulse Animation।
- **Tooltip:** প্রতিটি বাটনে লং-প্রেসে ছোট বাংলা গাইডেন্স মেসেজ।

### গ. ইনপুট ফিল্ড (Forms)
- **ডিজাইন:** Gray-f5f5f5 background, No border, 12px Radius।
- **ফিচার:** ভয়েস ইনপুট আইকন এবং পাসওয়ার্ড টগল আইকন।

---

## ৭. পেজ ট্রানজিশন এবং অ্যানিমেশন [UI-ANIM]
- **Hero:** সব প্রোডাক্ট ইমেজ ট্রানজিশনের জন্য `Hero` উইজেট বাধ্যতামূলক।
- **Page:** স্লাইড এবং ফেড ট্রানজিশন ব্যবহার করতে হবে।
- **Loading:** ব্র্যান্ডেড সার্কুলার প্রগ্রেস ইন্ডিকেটর বা শিমার ইফেক্ট।

---

## ৮. ক্রস-রেফারেন্স (Cross-References)
- [Core DNA](core_dna.md) [SYS-CORE-DNA]
- [Visual DNA](visual_dna.md) [SYS-VISUAL-DNA]
- [Feature DNA](feature_dna.md) [SYS-FEAT-DNA]
- [Database DNA](database_dna.md) [SYS-DB-DNA]
- [Security DNA](security_dna.md) [SYS-SEC-DNA]
- [Integration DNA](integration_dna.md) [SYS-INT-DNA]
- [Operations DNA](operations_dna.md) [SYS-OPS-DNA]
- [Model & State DNA](model_state_dna.md) [SYS-STATE-DNA]
- [Performance DNA](performance_dna.md) [SYS-PERF-DNA]

---

## Change Log
- **2025-03-24:** Initial UI & UX Feature Map created.
- **2026-03-24:** Added [LOCKED STATUS], Cross-References, and updated Change Log.
