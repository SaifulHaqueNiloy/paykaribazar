# Visual DNA [SYS-VISUAL-DNA] - [LOCKED STATUS: ACTIVE]
# ভিজ্যুয়াল ডিজাইন এবং ইউজার এক্সপেরিয়েন্স প্রোটোকল (বিস্তারিত)

## ১. ব্র্যান্ডিং এবং কালার প্যালেট [VIS-BRAND]
- **অফিসিয়াল নাম:** "পাইকারী বাজার" (Paykari Bazar)।
- **থিম:** Teal & White theme (নীলাভ সবুজ এবং সাদা)।
- **রং:** Primary Teal `#008080`, Accent Amber `#FFC107`, Dark BG `#0F172A`, Light BG `#F0F2F5`.
- **টাইপোগ্রাফি:** Poppins (EN) & Hind Siliguri (BN).

## ২. গ্রিড এবং লেআউট রুলস [VIS-LAYOUT]
- **অ্যাডাপ্টিভ গ্রিড (Adaptive Grid):** ইউজার নিজের পছন্দ অনুযায়ী **২, ৩, অথবা ৪ কলামের** গ্রিড লেআউট বেছে নিতে পারবেন। (Toggle between 2, 3, or 4 columns). [MASTER RULE]
- **রেডিয়াস:** ১৬ পিক্সেল (16px) - কার্ড/কন্টেইনার; ১২ পিক্সেল (12px) - বাটন/ইনপুট।
- **প্যাডিং:** সাইড প্যাডিং ১৬ পিক্সেল (16px).

## ৩. ইন্টারঅ্যাকশন এবং কম্পোনেন্ট ডিজাইন [VIS-COMP]
- **প্রোডাক্ট কার্ড:** ডিসকাউন্ট ট্যাগ, হিরো ইমেজ, বোল্ড প্রাইস, এবং '+' কার্ট বাটন।
- **ফ্লোটিং কার্ট (Floating Cart):** স্ক্রিনের নিচে ডান পাশে ভাসমান বাবল যা `Items | Price` ফরম্যাটে তথ্য দেখাবে (উদা: 3 Items | ৳1,250).
- **টুলটিপ (Tooltip):** প্রতিটি ইন্টারঅ্যাক্টিভ বাটনে অবশ্যই বাংলায় `Tooltip` থাকতে হবে। [MANDATORY]
- **এরর ইউআই:** সব এরর অবশ্যই ডায়ালগ বক্সে (AlertDialog) দেখাতে হবে। [MANDATORY]

## ৪. এআই ইঞ্জিন পলিসি [AI-POLICY]
- **Gemini Rule:** প্রোজেক্টের ইন্টারনাল এআই ফিচারের জন্য শুধুমাত্র **Gemini Version 2.0 এবং তার উপরের ভার্সন** ব্যবহার করা যাবে। Gemini 1.5 Pro বা Flash নিষিদ্ধ। [STRICT]
- **NVIDIA Integration:** রাউটিং প্রায়োরিটি হবে: NVIDIA (Kimi-k2.5) > DeepSeek > Gemini 2.0.

---

## ৫. কাস্টমার অ্যাপ - সম্পূর্ণ পেজ স্ট্রাকচার [CUSTOMER-PAGES]

### নেভিগেশন স্ট্রাকচার - Bottom Navigation (5 Tabs)
```
TAB 0: HOME         → HomeScreen
TAB 1: EMERGENCY    → EmergencyDetailsScreen  
TAB 2: PRODUCTS     → AllProductsScreen
TAB 3: REWARDS      → RewardsScreen
TAB 4: PROFILE      → ProfileScreen
```

### পেজ ১: হোম স্ক্রিন (HOME PAGE)
**Route:** `/` | **File:** `lib/src/features/home/home_screen.dart`

**লেআউট উপাদান (Top to Bottom):**
```
┌─────────────────────────────────────────┐
│ [AppBar - Sticky After 200px Offset]    │
│ └─ Search icon | Notification badge     │
├─────────────────────────────────────────┤
│ [ScrollView]                             │
│                                         │
│ 1. GREETING WIDGET (Top)                │
│    ├─ Welcome message (EN/BN)          │
│    ├─ Loyalty points badge            │
│    └─ Language toggle                  │
│                                         │
│ 2. NOTICE CAROUSEL                     │
│    ├─ Promotional banners              │
│    ├─ Auto-scroll (5 sec interval)     │
│    └─ PageView indicators (dots)       │
│                                         │
│ 3. CATEGORY SIDEBAR (Horizontal)       │
│    ├─ Scrollable category chips        │
│    ├─ icon + category name             │
│    └─ Active indicator                 │
│                                         │
│ 4. FLASH SALE TIMER WIDGET             │
│    ├─ Countdown timer (HH:MM:SS)       │
│    ├─ "Flash Sale Ends In:" label      │
│    ├─ Products GridView (2 col)        │
│    │   ProductCard x N                 │
│    └─ "View More" link                 │
│                                         │
│ 5. HOME WIDGETS SECTIONS                │
│    ├─ "Featured" GridView              │
│    ├─ "Best Sellers" GridView          │
│    ├─ "Recommended" GridView           │
│    ├─ "New Arrivals" GridView          │
│    └─ Each: 2-4 column adaptive grid   │
│                                         │
│ 6. LOYALTY STATUS CARD                 │
│    ├─ Current tier (Gold/Silver/etc)   │
│    ├─ Progress bar (visual fill %)     │
│    ├─ Benefits list                    │
│    └─ "Upgrade Tips"                   │
│                                         │
│ 7. QIBLA INDICATOR                     │
│    ├─ Prayer direction compass         │
│    └─ Current bearing display          │
│                                         │
│ 8. REWARD POPUP (30 sec intervals)     │
│    ├─ Float overlay dialog             │
│    ├─ Points earned animation          │
│    └─ Dismiss button                   │
│                                         │
└─────────────────────────────────────────┘

[FLOATING OVERLAY]
├─ Cart count badge (top-right)
├─ Floating action bubble
└─ "n Items | ৳xxxx" display
```

**ProductCard উপাদান (প্রতিটি কার্ড):**
```
┌─────────────────┐
│ [Image Thumb]   │  Discount badge: "-xx%"
│                 │  Wishlist icon (top-right)
├─────────────────┤
│ Product Name    │
│ (2 lines max)   │
├─────────────────┤
│ ⭐⭐⭐⭐⭐ (5)    │
├─────────────────┤
│ Price: ৳xxx     │  Original: ৳yyy (strikethrough)
│ Bold, Large     │
├─────────────────┤
│ Stock badge     │  "In Stock" | "Out"
│ green/red       │
├─────────────────┤
│ [+ Add to Cart] │  Button at bottom
│ Teal bg, white  │
└─────────────────┘
```

---

### পেজ ২: প্রোডাক্ট ডিটেইল স্ক্রিন (PRODUCT DETAILS)
**Route:** `/product-details?productId={id}` | **File:** `lib/src/features/products/product_detail_screen.dart`

**লেআউট উপাদান:**
```
┌─────────────────────────────────────────┐
│ [SliverAppBar - Expandable (300px)]     │
│ ├─ Product image (full width)           │
│ ├─ Image gallery (horizontal dots)      │
│ └─ Back button (top-left) + Wishlist    │
│    (top-right)                          │
├─────────────────────────────────────────┤
│ [Content Area]                          │
│                                         │
│ 1. TITLE SECTION                        │
│    ├─ Product name (EN/BN)             │
│    ├─ Rating: ⭐⭐⭐⭐⭐ (n reviews)   │
│    └─ Stock badge (green/red)          │
│                                         │
│ 2. PRICE SECTION                        │
│    ├─ Current: ৳xxx (Bold, Large, Teal)
│    ├─ Original: ৳yyy (Strikethrough)   │
│    ├─ Discount: -xx% (Red badge)       │
│    └─ Stock info: "25 left"            │
│                                         │
│ 3. QUANTITY SELECTOR                    │
│    ├─ [-] Button (gray if qty=1)      │
│    ├─ [  Current Qty  ] Display        │
│    └─ [+] Button (active)              │
│                                         │
│ 4. DESCRIPTION SECTION                  │
│    ├─ "About This Product" heading     │
│    ├─ Description text                 │
│    └─ "Read More" expandable link      │
│                                         │
│ 5. SPECIFICATIONS                       │
│    ├─ Key-value pairs list             │
│    ├─ Material: Cotton                 │
│    ├─ Color: Blue                      │
│    └─ [repeat]                         │
│                                         │
│ 6. RELATED PRODUCTS                    │
│    ├─ "RELATED PRODUCTS" section       │
│    ├─ Horizontal scrollable carousel   │
│    └─ ProductCard items                │
│                                         │
└─────────────────────────────────────────┘

[FIXED BOTTOM SHEET]
┌─────────────────────────────────────────┐
│ [Add to Cart]  Button (Primary - Teal)  │
│ [Buy Now]      Button (Secondary)       │
│ ❤️ Favorite    Toggle Button            │
└─────────────────────────────────────────┘
```

---

### পেজ ৩: কার্ট স্ক্রিন (SHOPPING CART)
**Route:** `/cart` | **File:** `lib/src/features/cart/cart_screen.dart`

**লেআউট উপাদান:**
```
┌─────────────────────────────────────────┐
│ AppBar: "My Cart"                       │
├─────────────────────────────────────────┤
│                                         │
│ IF EMPTY:                               │
│ ├─ Empty illustration                  │
│ ├─ "Your cart is empty"                │
│ └─ [SHOP NOW] CTA                      │
│                                         │
│ IF FILLED:                              │
│ ┌──────────────────────────────────┐   │
│ │ [Scrollable Items List]          │   │
│ │                                  │   │
│ │ FOR EACH ITEM:                   │   │
│ │ ┌────────────────────────────┐   │   │
│ │ │ [30x30 Image] Product Name │   │   │
│ │ │              ৳xxx per unit   │   │   │
│ │ │              [-] qty [+]     │   │   │
│ │ │              [Remove] [/]    │   │   │
│ │ └────────────────────────────┘   │   │
│ │                                  │   │
│ │ [repeat for all items]           │   │
│ │                                  │   │
│ └──────────────────────────────────┘   │
│                                         │
│ [ORDER SUMMARY CARD] (Bottom)          │
│ ├─ Subtotal:       ৳xxxx              │
│ ├─ Delivery Fee:   ৳xxxx              │
│ ├─ Discount:      -৳xxxx              │
│ ├─ ─────────────────────────          │
│ ├─ TOTAL:         ৳xxxx (BOLD)        │
│ │                                     │
│ ├─ [Delivery Location Selector]       │
│ ├─ [Promo Code Input Field]           │
│ │  "Enter promo code" placeholder      │
│ │                                     │
│ └─ [PROCEED TO CHECKOUT] (Primary)    │
│                                         │
└─────────────────────────────────────────┘
```

---

### পেজ ৪: প্রোফাইল স্ক্রিন (PROFILE)
**Route:** (Tab 4 - Default) | **File:** `lib/src/features/profile/profile_screen.dart`

**লেআউট উপাদান:**
```
┌─────────────────────────────────────────┐
│ [Profile Header]                        │
│ ├─ Circular profile picture (120x120)  │
│ ├─ Username & Phone number             │
│ ├─ Loyalty tier badge (Teal)           │
│ └─ [Edit Profile] button               │
├─────────────────────────────────────────┤
│ [ScrollView]                            │
│                                         │
│ 1. UNIFIED TOP CARD                    │
│    ├─ Total Orders: n                  │
│    ├─ Loyalty Points: nnn              │
│    └─ Current Role: [Customer/Admin]   │
│                                         │
│ 2. PERSONAL HUB (4-Column Grid)        │
│    ├─ 📦 Orders                         │
│    ├─ ❤️ Wishlist                      │
│    ├─ 💳 Wallet                        │
│    └─ 👤 Edit Profile                  │
│                                         │
│ 3. "JOIN & EARN" SECTION                │
│    ├─ 🏪 Become Reseller               │
│    ├─ 🚚 Become Rider                  │
│    ├─ 👨‍💼 Become Staff                 │
│    └─ 🔗 Refer Friends                 │
│                                         │
│ 4. ACCOUNT MANAGEMENT                  │
│    ├─ 🔐 Backup & Restore              │
│    ├─ ⚙️ App Settings                   │
│    ├─ ❓ Help & Support                │
│    └─ ℹ️ About App                      │
│                                         │
│ 5. DANGER ZONE                         │
│    ├─ [Switch Account] button          │
│    └─ [LOGOUT] button (Red bg)         │
│                                         │
│ Version: v1.0.0+1                      │
└─────────────────────────────────────────┘
```

---

### পেজ ৫: অর্ডার্স স্ক্রিন (ORDERS LIST)
**Route:** `/orders` | **File:** `lib/src/features/orders/orders_screen.dart`

**লেআউট উপাদান:**
```
┌─────────────────────────────────────────┐
│ AppBar: "My Orders"                     │
├─────────────────────────────────────────┤
│                                         │
│ [Filter Chips - Sticky - Horizontal]   │
│ ├─ All | Pending | Processing |        │
│ ├─ Delivered | Cancelled               │
│ └─ Active chip: Teal bg                │
│                                         │
│ [Orders List]                           │
│                                         │
│ FOR EACH ORDER:                         │
│ ┌───────────────────────────────────┐  │
│ │ Order #ABC123                     │  │
│ │ ───────────────────────────       │  │
│ │ Status: [Badge - Green/Blue/Red]  │  │
│ │ Date: YYYY-MM-DD HH:MM            │  │
│ │ Total: ৳xxx.xx                    │  │
│ │                                   │  │
│ │ Items: [Product 1 x2] [Product 2 x1]
│ │                                   │  │
│ │ [TRACK ORDER]  [DETAILS]          │  │
│ └───────────────────────────────────┘  │
│                                         │
│ [repeat for each order]                 │
│                                         │
│ [Pagination Footer]                     │
│                                         │
│ IF EMPTY:                               │
│ ├─ "No orders found"                   │
│ └─ [Shop Now] CTA                      │
│                                         │
└─────────────────────────────────────────┘
```

---

### পেজ ৬: সার্চ স্ক্রিন (SEARCH)
**Route:** `/search?q={query}` | **File:** `lib/src/features/search/search_screen.dart`

**লেআউট উপাদান:**
```
┌─────────────────────────────────────────┐
│ AppBar:                                 │
│ ├─ [TextField] Search input (autofocus)│
│ ├─ Clear icon (if text present)        │
│ └─ Cancel button                       │
├─────────────────────────────────────────┤
│                                         │
│ IF EMPTY:                               │
│ ├─ "Type to search products"           │
│ └─ Recent searches list                │
│                                         │
│ IF NO RESULTS:                          │
│ ├─ "No products found"                 │
│ └─ Suggestion: Try different keywords  │
│                                         │
│ IF RESULTS FOUND:                       │
│ ├─ GridView (2 columns)                │
│ │  ├─ ProductCard                      │
│ │  │  └─ [repeat]                      │
│ │                                      │
│ └─ Infinite scroll pagination          │
│                                         │
│ Feature: Real-time search              │
│ - Product name search                  │
│ - Bengali name search                  │
│ - Description search                   │
│ - Category tags search                 │
│                                         │
└─────────────────────────────────────────┘
```

---

### পেজ ৭: উইশলিস্ট স্ক্রিন (FAVORITES)
**Route:** `/wishlist` | **File:** `lib/src/features/wishlist/wishlist_screen.dart`

**লেআউট উপাদান:**
```
┌─────────────────────────────────────────┐
│ AppBar: "পছন্দের তালিকা (Wishlist)"     │
├─────────────────────────────────────────┤
│                                         │
│ IF EMPTY:                               │
│ ├─ Empty illustration                  │
│ ├─ "No items in wishlist yet"         │
│ └─ [Continue Shopping] CTA             │
│                                         │
│ IF FILLED:                              │
│ ├─ GridView (2 columns)                │
│ │  ├─ ProductCard (With filled ❤️)    │
│ │  │  └─ [repeat]                      │
│ │                                      │
│ └─ Pagination                          │
│                                         │
│ Feature: Toggle to add/remove from     │
│ cart directly from wishlist            │
│                                         │
└─────────────────────────────────────────┘
```

---

## ৬. এডমিন অ্যাপ - সম্পূর্ণ ড্যাশবোর্ড স্ট্রাকচার [ADMIN-PAGES]

### মূল ট্যাব স্ট্রাকচার (TopLevel - 5 Tabs)
```
TAB 0: 📊 DASHBOARD   → DashboardHub
TAB 1: 🛍️ COMMERCE    → CommerceHub (3 sub-tabs)
TAB 2: 👥 PEOPLE      → PeopleHub (4 sub-tabs)
TAB 3: ⚡ INTELLIGENCE → IntelligenceHub (4 sub-tabs)
TAB 4: ⚙️ SYSTEM       → SystemHub (3 sub-tabs)
```

### এডমিন হাব ১: ড্যাশবোর্ড হাব (2 Sub-tabs)

#### 1.1 OVERVIEW TAB
**লেআউট:**
```
┌─────────────────────────────────────────┐
│ [Inventory Forecasting Widget]          │
│ ├─ Title: "🧠 AI Stock Forecast"       │
│ ├─ Current inventory status            │
│ ├─ Low stock alerts (Red badges)       │
│ ├─ Restock recommendations             │
│ └─ Forecast line graph                 │
│                                         │
│ [Quick Action Grid (4 Cards)]          │
│ ├─ 📦 View Stock    │ 📋 View Orders   │
│ ├─ 👥 View Users   │ 🎯 View Targets  │
│ │                                      │
│ └─ Each: Icon + Label + Click count    │
│                                         │
│ [Real-time Stats]                       │
│ ├─ Active Orders: n                    │
│ ├─ Pending Tasks: n                    │
│ └─ System Health: % (Green/Yellow/Red) │
│                                         │
└─────────────────────────────────────────┘
```

#### 1.2 ANALYTICS TAB
**লেআউট:**
```
┌─────────────────────────────────────────┐
│ [AI Insight Card] (Top Priority)        │
│ ├─ 🧠 Psychology icon                  │
│ ├─ Label: "AI INSIGHT"                 │
│ ├─ Loading spinner (while loading)     │
│ ├─ Insight text (auto-loaded from DB)  │
│ └─ [Refresh] button                    │
│                                         │
│ [Statistics Grid (4-Column)]           │
│ ├─ Total Sales: ৳xxxxxx                │
│ ├─ Total Orders: nnn                   │
│ ├─ Total Customers: nnn                │
│ └─ Revenue: ৳xxxxx                     │
│   (Each with % trend badge)            │
│                                         │
│ [Sales Overview - Chart Section]       │
│ ├─ "SALES OVERVIEW" heading            │
│ ├─ Time Filter:                        │
│ │  [Daily] [Weekly] [Monthly]          │
│ ├─ Line Chart / Bar Chart              │
│ │  ├─ Interactive tooltips             │
│ │  └─ Responsive sizing                │
│ ├─ Legend                              │
│ └─ Export CSV button                   │
│                                         │
└─────────────────────────────────────────┘
```

---

### এডমিন হাব ২: কমার্স হাব (3 Sub-tabs)

#### 2.1 ORDERS TAB
**লেআউট:**
```
┌─────────────────────────────────────────┐
│ [Filter Toggle - Top]                   │
│ ├─ [Show Today] or [All Time]          │
│ └─ Auto-filter on toggle               │
│                                         │
│ [Status TabBar (2 Tabs)]                │
│ ├─ 📦 Regular Orders (default)         │
│ └─ 🚨 Emergency (Red badge)            │
│                                         │
│ [Filter Chips - Horizontal]             │
│ ├─ All | Pending | Processing |        │
│ ├─ Delivered | Cancelled               │
│ └─ Active: Teal background             │
│                                         │
│ [Orders List]                           │
│                                         │
│ FOR EACH ORDER:                         │
│ ┌───────────────────────────────────┐  │
│ │ Order #ID                         │  │
│ │ Customer: [Name]                  │  │
│ │ Status: [Color Badge]             │  │
│ │ Items: n | Total: ৳xxx            │  │
│ │ Time: YYYY-MM-DD HH:MM            │  │
│ │                                   │  │
│ │ [DETAILS] [UPDATE STATUS]         │  │
│ │   [PRINT INVOICE]                 │  │
│ └───────────────────────────────────┘  │
│                                         │
│ [Pagination Footer]                     │
│ "Showing 1-10 of 100"                   │
│                                         │
└─────────────────────────────────────────┘
```

#### 2.2 CATALOG TAB (3 Sub-tabs)
```
┌─────────────────────────────────────────┐
│ [Nested TabBar]                         │
│ ├─ 📦 INVENTORY (primary)              │
│ ├─ 📂 CATEGORIES                        │
│ └─ 🏪 SHOPS                            │
│                                         │
│ [INVENTORY TAB]                         │
│ ├─ [+ Add Product] button (Top)        │
│ ├─ [Search bar] [Filter dropdown]      │
│ │                                      │
│ ├─ Products Table:                      │
│ │  ┌─────────────────────────────┐    │
│ │  │ [✓] │Img│Name│SKU│Stock│Price│   │
│ │  ├─────────────────────────────┤    │
│ │  │ [ ] │[I] │Prod1│SKU1│ 45 │৳xxx │ │
│ │  │     │    │      │    │     │    │
│ │  │     │    │[EDIT] [DELETE]  │    │
│ │  │                             │    │
│ │  │ [repeat rows]               │    │
│ │  └─────────────────────────────┘    │
│ │                                      │
│ ├─ Bulk Actions:                        │
│ │  [Select All] [Bulk Edit]            │
│ │  [Bulk Delete] [Bulk Status]         │
│ │                                      │
│ └─ Pagination                          │
│                                         │
│ [CATEGORIES TAB]                        │
│ ├─ [+ Add Category] button             │
│ ├─ Category Tree:                       │
│ │  └─ Main Category                    │
│ │     ├─ Subcategory 1 [Edit][Delete] │
│ │     └─ Subcategory 2 [Edit][Delete] │
│ │                                      │
│ └─ Category Edit Form (Modal)          │
│                                         │
│ [SHOPS TAB]                             │
│ ├─ [+ Add Shop] button                 │
│ ├─ Shops Grid (3 columns):             │
│ │  FOR EACH SHOP:                      │
│ │  ┌───────────────────────┐          │
│ │  │ [Shop Logo]           │          │
│ │  │ Shop Name             │          │
│ │  │ Owner: [Name]         │          │
│ │  │ Location: [City]      │          │
│ │  │ Status: [Badge]       │          │
│ │  │ [EDIT] [DELETE] [VIEW] │          │
│ │  └───────────────────────┘          │
│ │                                      │
│ └─ Pagination                          │
│                                         │
└─────────────────────────────────────────┘
```

---

#### 2.3 LOGISTICS TAB
```
┌─────────────────────────────────────────┐
│ [Logistics Overview Stats]              │
│ ├─ Active Deliveries: n                │
│ ├─ Pending Shipments: n                │
│ ├─ Avg Delivery Time: n mins           │
│ └─ Success Rate: xx%                   │
│                                         │
│ [Map View - Live Tracking]              │
│ ├─ Google Maps integration             │
│ ├─ Rider location pins                 │
│ ├─ Delivery zones                      │
│ └─ Polygon overlay (color-coded)       │
│                                         │
│ [Deliveries List]                       │
│ ├─ Rider info card                     │
│ ├─ Current delivery location           │
│ ├─ Estimated arrival                   │
│ └─ Status updates                      │
│                                         │
└─────────────────────────────────────────┘
```

---

### এডমিন হাব ৩: পিপল হাব (4 Sub-tabs)

#### 3.1 TEAMS TAB
```
┌─────────────────────────────────────────┐
│ [Staff Members List]                    │
│ ├─ [+ Add Team Member] button          │
│ ├─ [Search] [Filter by role]           │
│ │                                      │
│ ├─ Team Member Cards:                   │
│ │  FOR EACH MEMBER:                    │
│ │  ┌────────────────────────────┐     │
│ │  │ [Avatar] Name              │     │
│ │  │ Roll: Admin/Manager/Staff  │     │
│ │  │ Email: email@example.com   │     │
│ │  │ Status: Active/Inactive    │     │
│ │  │ Join Date: MM/DD/YYYY      │     │
│ │  │                            │     │
│ │  │ [EDIT] [REMOVE] [VIEW LOG] │     │
│ │  └────────────────────────────┘     │
│ │                                      │
│ └─ Pagination                          │
│                                         │
└─────────────────────────────────────────┘
```

#### 3.2 ACCOUNTS TAB
```
┌─────────────────────────────────────────┐
│ [Customer Accounts Management]          │
│ ├─ [Search] [Filter - Active/Inactive] │
│ ├─ [Suspend Account] [Delete Account]  │
│ │                                      │
│ ├─ Accounts Table:                      │
│ │  User│UID │Email│Phone│Status│Joined │
│ │  [repeat rows]                       │
│ │                                      │
│ ├─ Account Detail Modal:                │
│ │  ├─ Profile info                     │
│ │  ├─ Order history                    │
│ │  ├─ Payment methods                  │
│ │  ├─ Loyalty points                   │
│ │  └─ Account actions                  │
│ │                                      │
│ └─ Pagination                          │
│                                         │
└─────────────────────────────────────────┘
```

#### 3.3 RESELLERS TAB
```
┌─────────────────────────────────────────┐
│ [Reseller Applications & Management]    │
│ ├─ Pending Applications: n              │
│ ├─ Active Resellers: n                 │
│ └─ Suspended: n                         │
│                                         │
│ [Filter Tabs]                           │
│ ├─ Pending | Approved | Rejected        │
│                                         │
│ ├─ Reseller Cards:                      │
│ │  FOR EACH:                            │
│ │  ├─ Name / Shop name                 │
│ │  ├─ Commission rate                  │
│ │  ├─ Status badge                     │
│ │  ├─ Sales performance                │
│ │  └─ [APPROVE] [REJECT] [DETAILS]     │
│ │                                      │
│ └─ Pagination                          │
│                                         │
└─────────────────────────────────────────┘
```

---

### এডমিন হাব ৪: ইন্টেলিজেন্স হাব (4 Sub-tabs)

#### 4.1 AI MASTER TAB
```
┌─────────────────────────────────────────┐
│ [AI Configuration Panel]                │
│ ├─ Model Selection: [Gemini 2.0]       │
│ ├─ Fallback: [Gemini 1.5 Pro]         │
│ ├─ Route: [NVIDIA > DeepSeek > Gemini] │
│ │                                      │
│ ├─ Rate Limit Config:                   │
│ │  ├─ Per-minute: [60]  req/min        │
│ │  ├─ Daily quota: [10,000] req/day    │
│ │  └─ [SAVE CONFIG]                    │
│ │                                      │
│ ├─ Cache Settings:                      │
│ │  ├─ Duration: [60] minutes           │
│ │  ├─ Max entries: [500]               │
│ │  └─ Cache usage: xx%                 │
│ │                                      │
│ └─ [Clear Cache] button                │
│                                         │
└─────────────────────────────────────────┘
```

#### 4.2 DATABASE TAB
```
┌─────────────────────────────────────────┐
│ [Query Builder Interface]               │
│ ├─ [SQL Query Editor] (Code area)      │
│ ├─ [Execute Query] button              │
│ │                                      │
│ ├─ Results Table:                       │
│ │  ├─ Column headers (dynamic)         │
│ │  ├─ Row data (paginated)             │
│ │  ├─ Sort by column                   │
│ │  └─ Export CSV option                │
│ │                                      │
│ ├─ Query History:                       │
│ │  └─ Recent queries list              │
│ │                                      │
│ └─ Presets:                             │
│    ├─ "Top 10 Products"                │
│    ├─ "Revenue by Category"            │
│    └─ [Custom Query]                   │
│                                         │
└─────────────────────────────────────────┘
```

#### 4.3 AI HEALTH TAB
```
┌─────────────────────────────────────────┐
│ [System Health Monitoring]              │
│ ├─ API Status: ✅ Healthy              │
│ ├─ Response Time: 234ms (Green)        │
│ ├─ Error Rate: 0.1% (Green)            │
│ ├─ Quota Usage: 45% (Yellow)           │
│ └─ Cache Hit Rate: 67%                 │
│                                         │
│ [Performance Charts]                    │
│ ├─ Response time trend (line chart)    │
│ ├─ Error rate trend (line chart)       │
│ └─ Quota usage trend (area chart)      │
│                                         │
│ [Error Logs]                            │
│ ├─ Recent errors (last 24h)            │
│ ├─ Error type distribution             │
│ └─ Top error patterns                  │
│                                         │
└─────────────────────────────────────────┘
```

---

### এডমিন হাব ৫: সিস্টেম হাব (3 Sub-tabs)

#### 5.1 SETTINGS TAB
```
┌─────────────────────────────────────────┐
│ [App Configuration Settings]            │
│ ├─ App Name: [TextField]               │
│ ├─ Version: [TextField]                │
│ ├─ Maintenance Mode: [Toggle] OFF/ON   │
│ │                                      │
│ ├─ Email Settings:                      │
│ │  ├─ SMTP Host: [TextField]           │
│ │  ├─ SMTP Port: [TextField]           │
│ │  └─ [Test Email] button              │
│ │                                      │
│ ├─ Payment Provider Config:             │
│ │  ├─ Provider: [Dropdown]             │
│ │  ├─ API Key: [Password Field]        │
│ │  └─ [Save]                          │
│ │                                      │
│ └─ [SAVE SETTINGS] (Primary Button)    │
│                                         │
└─────────────────────────────────────────┘
```

#### 5.2 LOCALIZATION TAB
```
┌─────────────────────────────────────────┐
│ [Language Editor]                       │
│ ├─ [Add Language] button                │
│ │                                      │
│ ├─ Language List:                       │
│ │  ├─ English [EDIT] [DELETE]          │
│ │  ├─ Bengali (বাংলা) [EDIT] [DELETE]  │
│ │  └─ [repeat]                         │
│ │                                      │
│ ├─ Translation Editor Modal:            │
│ │  ├─ Language: Bengali                │
│ │  ├─ Key: "login.signin_button"       │
│ │  ├─ Value: [Text Editor]             │
│ │  │  └─ "সাইন ইন করুন"               │
│ │  └─ [Save Translation]               │
│ │                                      │
│ └─ Import/Export JSON button           │
│                                         │
└─────────────────────────────────────────┘
```

---

## ৭. ক্রস-রেফারেন্স (Cross-References)
- [Core DNA](core_dna.md) [SYS-CORE-DNA]
- [Integration DNA](integration_dna.md) [SYS-INT-DNA]
- [Feature DNA](feature_dna.md) [SYS-FEAT-DNA]
- [Database DNA](database_dna.md) [SYS-DB-DNA]
- [Security DNA](security_dna.md) [SYS-SEC-DNA]
- [Operations DNA](operations_dna.md) [SYS-OPS-DNA]
- [Model & State DNA](model_state_dna.md) [SYS-STATE-DNA]
- [Performance DNA](performance_dna.md) [SYS-PERF-DNA]

---

## Change Log
- **2025-03-24:** Initial file lock. Teal & White theme, Adaptive Grid (2,3,4), and Gemini 2.0+ rules strictly confirmed. No line removals allowed.
- **2026-03-24:** Comprehensive UI/UX update with complete customer app (22 pages) and admin app (50+ screens/tabs) including every card, button, and feature position details. Added [LOCKED STATUS] and Cross-References.
