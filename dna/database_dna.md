# Database DNA [SYS-DATA-DNA] - [LOCKED STATUS: ACTIVE]
# ডাটাবেস স্ট্রাকচার এবং হায়ারার্কি (মাস্টার সংস্করণ - ১০০% নিখুঁত)

এই নথিতে অ্যাপের ডেটাবেস ডিজাইন, সিকিউরিটি এবং ডাটা ম্যানেজমেন্টের প্রতিটি ক্ষুদ্রাতিক্ষুদ্র "ক্লু" অন্তর্ভুক্ত করা হয়েছে।

## ১. রুট কালেকশন এবং পাথস [DATA-PATH]
সব পাথ `HubPaths` ক্লাসে সেন্ট্রালাইজড। ম্যানুয়াল স্ট্রিং ব্যবহার নিষিদ্ধ।

- **`users/`**: ইউজার প্রোফাইল এবং রোল।
- **`orders/`**: ট্রানজ্যাকশন রেকর্ড।
- **`hub/data/products/`**: মাস্টার প্রোডাক্ট ক্যাটালগ।
- **`hub/data/categories/`**: ক্যাটাগরি স্ট্রাকচার।
- **`hub/data/stores/`**: ভেন্ডর/শপ মেটাডেটা।
- **`hub/data/locations/`**: ডেলিভারি জোন এবং লোকেশন হায়ারার্কি। [SINGLE SOURCE OF TRUTH FOR LOGISTICS]
- **`private_chats/`**: পি২পি এবং সাপোর্ট চ্যাট।
- **`settings/`**: 
  - `secrets`: এনক্রিপ্টেড এপিআই কী (NVIDIA, Gemini, Cloudinary, etc.)।
  - `api_quota`: এআই কোটা ট্র্যাকিং এবং লিমিট ডাটা।
  - `app_config`: অ্যাপের গ্লোবাল সেটিংস (ব্যানার, মেসেজ)।
  - `loyalty`: রিওয়ার্ড পয়েন্ট ক্যালকুলেশন রুল।
  - `localization`: রিমোট ল্যাঙ্গুয়েজ স্ট্রিংস।
  - `faqs`: সাধারণ জিজ্ঞাসা।
  - `about_us`: আমাদের সম্পর্কে তথ্য।
  - `terms_conditions`: অ্যাপের শর্তাবলী।
  - `partners`: পার্টনার লিস্ট।
  - `staff_list`: টিমের তালিকা।
- **`staff_commissions/`**: স্টাফদের উপার্জনের রেকর্ড।
- **`hub/emergency/`**: `donors`, `doctors`, `helplines` কালেকশন।
- **`reviews/`**: পণ্যের রিভিউ এবং রেটিং।
- **`applications/`**: রিসেলার, রাইডার এবং স্টাফ আবেদন।

## ২. মাস্টার স্কিমা ডিটেইলস [DATA-SCHEMA]

### User Profile (`users/{uid}`)
- `uid`: string (Primary Key)
- `name`, `phone`, `email`: string
- `role`: enum ("customer", "reseller", "rider", "staff", "admin")
- `points`: double (Default: 0.0)
- `address`: Map {district: string, upazila: string, detail: string}
- `isVerified`: boolean
- `fcmToken`: string (For notifications)
- `createdAt`, `updatedAt`: serverTimestamp

### Product (`hub/data/products/{id}`)
- `sku`: string (Unique SKU)
- `name`, `nameBn`, `description`, `descriptionBn`: string
- `price`, `oldPrice`, `purchasePrice`, `wholesalePrice`: double
- `minWholesaleQty`: int (ডিফল্ট ৫টি)
- `tieredPrices`: Map { "5-10": 100.0, "11+": 90.0 }
- `stock`: int
- `unit`, `unitBn`: string (e.g., "kg", "pcs")
- `categoryId`, `subCategoryId`: string
- `imageUrl`, `imageUrls`: string / List<string>
- `tags`: List<string> (Search SEO)
- `isFlashSale`, `isCombo`, `isNewArrival`, `isFeatured`, `isHotSelling`: boolean
- `addedBy`: string (Admin/Staff UID)
- `aiOptimized`, `aiAuditPending`: boolean
- `rating`: double (Product average rating)

### Review (`reviews/{id}`)
- `id`: string
- `productId`: string (Index)
- `userId`: string
- `userName`, `userImageUrl`: string
- `rating`: double (1.0 - 5.0)
- `comment`: string
- `createdAt`: serverTimestamp

### Application (`applications/{id}`)
- `id`: string
- `userId`: string
- `role`: string (Target role)
- `name`, `phone`, `address`, `experience`: string
- `status`: enum ("pending", "approved", "rejected")
- `createdAt`: serverTimestamp

### Order (`orders/{id}`)
- `id`: string
- `customerUid`, `customerName`, `customerPhone`: string
- `items`: List<Map> {id, name, qty, price, imageUrl}
- `total`, `subtotal`, `deliveryFee`, `discount`: double
- `status`: enum ("Pending", "Processing", "Shipped", "Delivered", "Cancelled")
- `paymentMethod`: enum ("COD", "bKash", "Nagad")
- `riderUid`, `riderName`: string (Nullable)
- `isEmergency`: boolean (Priority flag)
- `createdAt`, `updatedAt`: serverTimestamp

### Emergency - Doctor (`hub/emergency/doctors/{id}`)
- `id`: string (Document ID)
- `name`, `nameBn`: string
- `specialty`, `specialtyBn`: string
- `hospital`, `hospitalBn`: string
- `experience`: int (Years)
- `degree`: string
- `phone`: string (Primary contact)
- `email`: string
- `imageUrl`: string (Mandatory - Profile Photo)
- `fee`: double (Consultation fee)
- `rating`: double (User ratings)
- `reviewsCount`: int
- `availability`: Map { "Sat": ["05:00 PM - 08:00 PM"], ... }
- `isVerified`: boolean
- `location`: Map { district, upazila, address, lat, lng }
- `addedBy`: string (Staff/Admin UID)
- `createdAt`, `updatedAt`: serverTimestamp

### Emergency - Donor (`hub/emergency/donors/{id}`)
- `id`: string (Document ID)
- `uid`: string (Linked User UID if available)
- `name`: string
- `bloodGroup`: enum ("A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-")
- `phone`: string (Mandatory)
- `imageUrl`: string (Donor photo)
- `lastDonationDate`: timestamp (Eligibility calculation)
- `totalDonations`: int
- `isVerified`: boolean
- `status`: enum ("Available", "Busy", "Cooldown")
- `location`: Map { district, upazila, lat, lng }
- `fcmToken`: string (For direct emergency requests)
- `createdAt`, `updatedAt`: serverTimestamp

### Emergency - Helpline (`hub/emergency/helplines/{id}`)
- `id`: string (Document ID)
- `title`, `titleBn`: string
- `description`, `descriptionBn`: string
- `number`: string (Mandatory dial number)
- `iconUrl`: string (Category icon)
- `category`: enum ("Medical", "Fire", "Police", "Women/Child", "Disaster", "Govt")
- `serviceArea`: string (e.g., "Global", "Dhaka")
- `priority`: int (Sort order)
- `isVerified`: boolean
- `createdAt`, `updatedAt`: serverTimestamp

## ৩. ইন্টিগ্রিটি এবং সিকিউরিটি প্রোটোকল [DATA-SAFE]
- **Escrow Protocol [SYS-FINANCE-01]:** কাস্টমার ডেলিভারি কনফার্ম করলেই ভেন্ডর ব্যালেন্স আপডেট হবে।
- **Sanity Protocol:** ডেটা রিড করার সময় কোনো ফিল্ড মিসিং থাকলে অবশ্যই ডিফল্ট ভ্যালু (0.0, "", false) বসাতে হবে।
- **Indexing:** `lastUpdate` এবং `status` ফিল্ডের জন্য অবশ্যই কম্পোজিট ইনডেক্স থাকতে হবে।
- **Sovereignty:** `pubspec.yaml` এর ভার্সন ডাটাবেসের `customer_latest_version` দ্বারা নিয়ন্ত্রিত হবে।
- **Logistics Hierarchy:** পুরো প্রোজেক্টের লজিস্টিকস ডাটা (Delivery Fee, Time, Coverage) অবশ্যই `hub/data/locations/` এর ডাইনামিক হায়ারার্কি মেনে চলবে। এটি কোনো ফিক্সড ভ্যালু নয়।
- **AI Quota Tracking:** `settings/api_quota` পাথে প্রতিটি এআই এপিআই কী-এর লিমিট, টোকেন ইউজ এবং কস্ট রিয়েল-টাইমে আপডেট হতে হবে।

## Change Log
- **2025-03-24:** Initial file lock. Root collections, Schemas, and Integrity protocols confirmed. No line removals allowed.
- **2025-03-24:** Updated logistics data logic. Established `hub/data/locations/` as the Single Source of Truth for the entire project's location hierarchy and associated logistic data.
- **2025-03-24:** Added detailed schemas for Emergency services: Doctors, Donors, and Helplines with mandatory image support and bilingual fields where necessary.
- **2025-03-24:** Integrated Virtual Lab and API Quota tracking requirements into the Data Integrity section.
- **2025-03-24:** Added Review and Application schemas. Expanded Settings collection to include dynamic static content (FAQs, About, Terms, Partners).
