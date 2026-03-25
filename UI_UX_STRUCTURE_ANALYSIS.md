# Paykari Bazar Flutter Project - Complete UI/UX Structure Analysis

## Project Overview
- **Framework**: Flutter with Go Router
- **State Management**: Flutter Riverpod
- **Architecture**: Feature-based modular architecture
- **Internationalization**: Multi-language support (Bengali & English)
- **Theme**: Light & Dark mode support

---

## TABLE OF CONTENTS
1. [Customer App Structure](#customer-app-structure)
2. [Admin App Structure](#admin-app-structure)
3. [Navigation Architecture](#navigation-architecture)
4. [Shared Components](#shared-components)
5. [Authentication Screens](#authentication-screens)
6. [Common Layout Patterns](#common-layout-patterns)

---

# CUSTOMER APP STRUCTURE

## App Entry Point: `lib/main_customer.dart`
- **Router**: `lib/src/utils/router_customer.dart`
- **Main Screen**: `MainScreen` (lib/src/features/main_screen.dart)
- **Navigation**: Bottom Navigation Bar with 5 tabs

### Bottom Navigation Structure (MainScreen)
```
┌─────────────────────────────────────────────────────────────┐
│  STATUS BAR                                                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [IndexedStack - 5 Views]                                   │
│  - Index 0: HomeScreen                                      │
│  - Index 1: EmergencyDetailsScreen                          │
│  - Index 2: AllProductsScreen                               │
│  - Index 3: RewardsScreen                                   │
│  - Index 4: ProfileScreen                                   │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│ ┌─ HOME ─┬─ EMERGENCY ─┬─ PRODUCTS ─┬─ REWARDS ─┬─ PROFILE ┐│
│ └────────┴─────────────┴────────────┴───────────┴──────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## CUSTOMER APP SCREENS

### 1. HOME SCREEN (lib/src/features/home/home_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar [sticky after 200 offset]   │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView]                       │
│  ├─ Greeting Widget                 │
│  │  └─ User welcome message          │
│  │  └─ Loyalty points display        │
│  │                                   │
│  ├─ Notice Slider/Carousel            │
│  │  └─ Promotional banners            │
│  │  └─ Flash sales                    │
│  │                                   │
│  ├─ Category Sidebar (horizontal)    │
│  │  └─ Category chips/tiles           │
│  │                                   │
│  ├─ Flash Sale Timer Widget          │
│  │  └─ Countdown timer                │
│  │  └─ Flash sale products            │
│  │                                   │
│  ├─ Home Widgets Collection          │
│  │  └─ Featured products              │
│  │  └─ Best sellers                   │
│  │  └─ Recommended products           │
│  │  └─ New arrivals                   │
│  │                                   │
│  ├─ Loyalty Status Card              │
│  │  └─ Current tier display           │
│  │  └─ Progress bar                   │
│  │  └─ Loyalty benefits               │
│  │                                   │
│  ├─ Qibla Indicator (if applicable)  │
│  │  └─ Prayer direction               │
│  │                                   │
│  └─ Reward Popup (30sec interval)    │
│     └─ Points earned notification     │
│                                     │
├─────────────────────────────────────┤
│  [Floating Cart Bar] (overlay)       │
│  ├─ Cart count badge                 │
│  └─ Quick checkout CTA               │
└─────────────────────────────────────┘
```

**Key Widgets/Components:**
- **GreetingWidget**: User name, language toggle
- **NoticeSlider**: Carousel with promotional content
- **CategorySidebar**: Horizontal scrollable category list
- **FlashSaleTimer**: Countdown timer + grid of products
- **HomeWidgets**: ProductCard components wrapped in GridView
- **LoyaltyStatusCard**: Tier info with progress indicator
- **QiblaIndicator**: Prayer direction compass
- **FloatingCartBar**: Fixed overlay with cart badge
- **RewardPopup**: Dialog showing loyalty points earned

**Navigation Links:**
- Home widgets tap → `/product-details?productId={id}`
- View more categories → `/categories/{id}?name={name}`
- Flash sale → Product detail or category navigation

---

### 2. EMERGENCY SCREEN (lib/src/features/orders/emergency_details_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Emergency"                │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView]                       │
│                                     │
│  ├─ Emergency Alert Banner          │
│  │  ├─ Emergency icon                │
│  │  ├─ "Report Emergency" CTA        │
│  │  └─ Color-coded status            │
│  │                                   │
│  ├─ Emergency Contact Form          │
│  │  ├─ Name field                    │
│  │  ├─ Phone field                   │
│  │  ├─ Location selector             │
│  │  ├─ Description textarea          │
│  │  └─ "SUBMIT EMERGENCY" button     │
│  │                                   │
│  ├─ Emergency History List          │
│  │  └─ Cards showing past emergencies│
│  │     ├─ Timestamp                  │
│  │     ├─ Status badge               │
│  │     └─ Quick action buttons        │
│  │                                   │
│  └─ Emergency Resources             │
│     ├─ Important phone numbers       │
│     └─ Guidance                      │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Emergency Form with TextField components
- Status badge (Pending/In Progress/Resolved)
- EmergencyCard showing timestamp and status
- Emergency resources list

---

### 3. ALL PRODUCTS SCREEN (lib/src/features/products/all_products_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Products"                 │
├─────────────────────────────────────┤
│                                     │
│  [Sticky Filter Section]            │
│  ├─ Category filter chips (horizontal)
│  ├─ Price range slider              │
│  ├─ Sort dropdown                   │
│  └─ View toggle (Grid/List)         │
│                                     │
│  [Products Grid]                    │
│  └─ GridView 2 columns              │
│     ├─ ProductCard                  │
│     │  ├─ Image                      │
│     │  ├─ Product name               │
│     │  ├─ Rating stars               │
│     │  ├─ Price                      │
│     │  ├─ Stock status               │
│     │  └─ "Add to Cart" button       │
│     └─ [repeat]                     │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Filter chips with multiselect
- Price range slider widget
- Sort dropdown menu
- ProductCard (reusable)
- GridView with loading shimmer effects

---

### 4. REWARDS SCREEN (lib/src/features/home/rewards_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Rewards & Points"         │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView]                       │
│                                     │
│  ├─ Points Summary Card             │
│  │  ├─ Current balance (large)      │
│  │  ├─ Tier level badge             │
│  │  ├─ Progress to next tier        │
│  │  └─ Last month earning           │
│  │                                   │
│  ├─ "Redeem Points" Button          │
│  │  └─ Links to redemption options  │
│  │                                   │
│  ├─ Available Rewards List          │
│  │  ├─ Reward cards                 │
│  │  │  ├─ Reward image/icon         │
│  │  │  ├─ Points cost               │
│  │  │  ├─ Description               │
│  │  │  └─ "Redeem" CTA              │
│  │  └─ [repeat]                     │
│  │                                   │
│  ├─ Points History Timeline         │
│  │  ├─ Transaction list             │
│  │  │  ├─ Type (Earned/Redeemed)    │
│  │  │  ├─ Points amount             │
│  │  │  ├─ Date/time                 │
│  │  │  └─ Description               │
│  │  └─ [repeat]                     │
│  │                                   │
│  └─ "Invite Friends" CTA            │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Points summary card with tier badge
- Rewards redemption cards
- Timeline/list of point transactions
- Share invite functionality

---

### 5. PROFILE SCREEN (lib/src/features/profile/profile_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  [Header Section]                   │
│  ├─ Profile picture (circular)      │
│  ├─ User name & phone               │
│  ├─ Loyalty tier badge              │
│  └─ Edit profile CTA                │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView]                       │
│                                     │
│  ├─ Unified Top Card               │
│  │  ├─ Total orders count           │
│  │  ├─ Loyalty points               │
│  │  └─ Current mode indicator       │
│  │                                   │
│  ├─ Personal Hub Section            │
│  │  ├─ Grid 4 items per row:        │
│  │  │  ├─ 📦 Orders                │
│  │  │  ├─ ❤️ Wishlist              │
│  │  │  ├─ 💳 Wallet                │
│  │  │  └─ 👤 Edit Profile          │
│  │  │                               │
│  │                                   │
│  ├─ "Join & Earn" Section (if customer role)
│  │  ├─ Grid items:                  │
│  │  │  ├─ 🏪 Become Reseller       │
│  │  │  ├─ 🚚 Become Rider          │
│  │  │  ├─ 👨‍💼 Become Staff         │
│  │  │  └─ 🔗 Refer Friends         │
│  │  │                               │
│  │                                   │
│  ├─ Account Management              │
│  │  ├─ Backup & Restore             │
│  │  ├─ App Settings                 │
│  │  ├─ Help & Support               │
│  │  └─ About App                    │
│  │                                   │
│  ├─ Danger Zone                     │
│  │  ├─ Switch Account               │
│  │  └─ Logout button (red)          │
│  │                                   │
│  └─ Version footer                  │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Profile header with picture, name, tier badge
- Unified top card (4-column layout)
- Grid layout for action items (4 items dynamic)
- Nested section cards
- Logout button at bottom

---

### 6. PRODUCT DETAIL SCREEN (lib/src/features/products/product_detail_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  [SliverAppBar - expandedHeight: 300px]
│  ├─ Collapsible image              │
│  ├─ Back button (top-left)         │
│  └─ Wishlist button (top-right)    │
├─────────────────────────────────────┤
│                                     │
│  [SliverToBoxAdapter]               │
│  ├─ Padding(all: 16)               │
│  │                                  │
│  ├─ Title Section                  │
│  │  ├─ Product name (EN/BN)       │
│  │  ├─ Rating stars with count     │
│  │  └─ Stock/availability badge    │
│  │                                  │
│  ├─ Divider                         │
│  │                                  │
│  ├─ Price Section                  │
│  │  ├─ Current price (large, bold) │
│  │  ├─ Original price (strikethrough)
│  │  ├─ Discount percentage         │
│  │  └─ Stock info                  │
│  │                                  │
│  ├─ Quantity Selector              │
│  │  ├─ "-" button                  │
│  │  ├─ [current qty display]       │
│  │  └─ "+" button                  │
│  │                                  │
│  ├─ Description Section            │
│  │  ├─ "About This Product"        │
│  │  ├─ Product description text    │
│  │  └─ "See more" expandable       │
│  │                                  │
│  ├─ Specifications (if available)  │
│  │  └─ Key-value pairs list        │
│  │                                  │
│  ├─ Related Products               │
│  │  ├─ "RELATED PRODUCTS" heading  │
│  │  └─ Horizontal scrollable list  │
│  │     └─ ProductCard items        │
│  │                                  │
│  └─ Bottom spacing (100px)         │
│                                     │
├─────────────────────────────────────┤
│  [BottomSheet]                      │
│  ├─ "Add to Cart" button (primary) │
│  ├─ "Buy Now" button               │
│  └─ Favorite toggle button         │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- SliverAppBar with expandable image
- Title with rating and stock badge
- Price display with discount
- Quantity selector (+/-)
- Description with "See More"
- Related products carousel
- Fixed bottom sheet with CTA buttons

**Navigation:**
- Related product tap → `/product-details?productId={id}`
- Back → Previous route

---

### 7. CART SCREEN (lib/src/features/cart/cart_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "My Cart"                  │
├─────────────────────────────────────┤
│                                     │
│  IF EMPTY:                          │
│  ├─ Empty Cart Illustration         │
│  ├─ "Your cart is empty" message   │
│  └─ "SHOP NOW" CTA button          │
│                                     │
│  IF NOT EMPTY:                      │
│  ┌─────────────────────────────────┐│
│  │ [ScrollView - Cart Items List]  ││
│  │                                 ││
│  │  FOR EACH ITEM:                 ││
│  │  ┌─────────────────────────────┐││
│  │  │ ┌─────┐                      │││
│  │  │ │Image│  Product name        │││
│  │  │ └─────┘  Price per item      │││
│  │  │          - [qty] +           │││
│  │  │          Remove button        │││
│  │  │          [/]                  │││
│  │  └─────────────────────────────┘││
│  │                                 ││
│  │  [repeat for all items]         ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  [Order Summary - Bottom]           │
│  ├─ ────────────────────────→       │
│  ├─ Subtotal:      ৳xxxx           │
│  ├─ Delivery Fee:  ৳xxxx           │
│  ├─ Discount:     -৳xxxx           │
│  ├─ ────────────────────────→       │
│  ├─ TOTAL:         ৳xxxx (bold)    │
│  │                                  │
│  ├─ Delivery Location Selector      │
│  ├─ Promo Code Input                │
│  └─ "PROCEED TO CHECKOUT" button    │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Empty state with CTA
- Cart item cards with remove button
- Quantity +/- buttons per item
- Order summary section
- Delivery location selector
- Promo code input field
- Checkout button

**Navigation:**
- Edit product qty → Updates cart state
- Proceed to checkout → Checkout flow
- Continue shopping → `/products/{category}`

---

### 8. SEARCH SCREEN (lib/src/features/search/search_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar:                            │
│  ├─ [TextField] Search input        │
│  ├─ Autofocus if no initial query   │
│  └─ Clear button (if text present)  │
├─────────────────────────────────────┤
│                                     │
│  IF EMPTY SEARCH & NO ACTION:       │
│  ├─ "Type to search products"       │
│                                     │
│  IF RESULTS NOT FOUND:              │
│  ├─ "No products found"             │
│  ├─ Suggestion to try different    │
│  │ keywords                         │
│                                     │
│  IF RESULTS FOUND:                  │
│  ├─ [GridView 2 columns]            │
│  │  ├─ ProductCard                  │
│  │  │  ├─ Image                     │
│  │  │  ├─ Name                      │
│  │  │  ├─ Rating                    │
│  │  │  ├─ Price                     │
│  │  │  └─ Add to cart               │
│  │  └─ [repeat]                     │
│  │                                  │
│  └─ Infinite scroll pagination      │
│                                     │
│  SEARCH FILTERS:                    │
│  ├─ Product name search             │
│  ├─ Bengali name search             │
│  ├─ Description search              │
│  ├─ Tags search                     │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- Real-time search filtering
- Multi-field search (name, description, tags)
- Grid display with ProductCard
- Supports action parameter for deep linking

**Navigation:**
- Product tap → `/product-details?productId={id}`

---

### 9. WISHLIST SCREEN (lib/src/features/wishlist/wishlist_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "পছন্দের তালিকা (Wishlist)" │
├─────────────────────────────────────┤
│                                     │
│  IF EMPTY:                          │
│  ├─ Empty wishlist illustration    │
│  └─ Add items prompt               │
│                                     │
│  IF NOT EMPTY:                      │
│  ├─ [GridView 2 columns]            │
│  │  ├─ ProductCard (same as home)  │
│  │  │  ├─ Wishlist toggle (filled) │
│  │  │  └─ Price & details          │
│  │  └─ [repeat]                   │
│  │                                  │
│  └─ Pagination                      │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- ProductCard with wishlist heart icon (filled/outlined)
- Grid layout 2 columns
- Empty state messaging

**Navigation:**
- Product tap → `/product-details?productId={id}`
- Heart icon → Toggle wishlist (updates state)

---

### 10. ORDERS SCREEN (lib/src/features/orders/orders_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "My Orders"                │
├─────────────────────────────────────┤
│                                     │
│  [Sticky Filter Bar]                │
│  ├─ Choice Chips (horizontal)      │
│  │  ├─ All                          │
│  │  ├─ Pending                      │
│  │  ├─ Processing                   │
│  │  ├─ Delivered                    │
│  │  └─ Cancelled                    │
│  └─ Scrollable horizontal list      │
│                                     │
│  [Orders List]                      │
│  │  FOR EACH ORDER:                 │
│  │  ┌─────────────────────────────┐ │
│  │  │ Order #ID                   │ │
│  │  │ ────────────────────────    │ │
│  │  │ Status: [badge]             │ │
│  │  │ Date: YYYY-MM-DD HH:MM      │ │
│  │  │ Total: ৳xxx.xx              │ │
│  │  │                             │ │
│  │  │ Items: [product listing]    │ │
│  │  │ - Product 1 x qty           │ │
│  │  │ - Product 2 x qty           │ │
│  │  │                             │ │
│  │  │ TRACK ORDER  /  DETAILS     │ │
│  │  └─────────────────────────────┘ │
│  │  [repeat]                        │
│  │                                  │
│  └─ Pagination/infinite scroll      │
│                                     │
│  IF NO ORDERS:                      │
│  ├─ No orders found message        │
│  └─ "Shop now" CTA                 │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Filter chips (All, Pending, Processing, Delivered, Cancelled)
- Order cards showing:
  - Order ID/number
  - Status badge (color-coded)
  - Total price
  - Item list
  - Action buttons (Track, Details)

**Navigation:**
- Track order → `/order-tracking?orderId={id}&riderUid={uid}`
- Details → `OrderDetailsScreen`
- Product tap → Product detail

---

### 11. ORDER DETAILS SCREEN (lib/src/features/orders/order_details_screen.dart)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Order Details #ID"        │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView]                       │
│                                     │
│  ├─ Status Banner                  │
│  │  ├─ Status icon                 │
│  │  ├─ Status color (green/blue/red)│
│  │  └─ "Status: [Pending|Processing│
│  │     |Delivered|Cancelled]"       │
│  │                                  │
│  ├─ Order Items Section             │
│  │  ├─ "ITEMS" heading              │
│  │  ├─ ────────                     │
│  │  │                               │
│  │  │  FOR EACH ITEM:               │
│  │  │  ├─ [Product Image]           │
│  │  │  ├─ Product Name              │
│  │  │  ├─ Qty: x                    │
│  │  │  ├─ Price: ৳xxx               │
│  │  │  │                            │
│  │  │  [repeat]                     │
│  │  │                               │
│  │  └─ ────────                     │
│  │                                  │
│  ├─ Order Summary                   │
│  │  ├─ Subtotal:     ৳xxxx         │
│  │  ├─ Delivery Fee: ৳xxxx         │
│  │  ├─ Tax/Discount: ৳xxxx         │
│  │  └─ TOTAL:        ৳xxxx (bold)  │
│  │                                  │
│  ├─ Shipping Address                │
│  │  ├─ "SHIPPING ADDRESS" heading  │
│  │  ├─ ────────                    │
│  │  ├─ Name: [customer name]       │
│  │  ├─ Phone: [phone number]       │
│  │  └─ Address: [full address]     │
│  │                                  │
│  ├─ Payment Information             │
│  │  ├─ Method: [Cash/Card/Mobile]  │
│  │  └─ Status: [Paid/Pending]      │
│  │                                  │
│  └─ Actions (if applicable)         │
│     ├─ Cancel Order button (red)   │
│     ├─ Return Item(s) button       │
│     └─ Download Invoice button     │
│                                     │
└─────────────────────────────────────┘
```

**Key Components:**
- Status banner (color-coded)
- Order items list with images and prices
- Order summary breakdown
- Shipping address display
- Payment method and status
- Action buttons based on order status

---

### 12. ORDER TRACKING SCREEN (lib/src/features/orders/order_tracking_screen.dart)

**Route Parameters:**
- `orderId`: Order identifier
- `riderUid`: Rider's Firebase UID (optional)

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Track Your Order"         │
├─────────────────────────────────────┤
│                                     │
│  [MapWidget or LocationDisplay]     │
│  ├─ Google Maps integration (if    │
│  │ rider location is available)     │
│  ├─ Live rider location             │
│  ├─ Delivery location marker        │
│  └─ Route polyline                  │
│                                     │
│  ├─ [Rider Info Card]               │
│  │  ├─ Rider photo                  │
│  │  ├─ Rider name & rating          │
│  │  ├─ Vehicle type                 │
│  │  └─ "CALL RIDER" button          │
│  │                                  │
│  ├─ Order Status Timeline           │
│  │  ├─ ● [CONFIRMED]  ✓            │
│  │  │  Date/Time                    │
│  │  │                               │
│  │  ├─ ● [PACKED]  ✓                │
│  │  │  Date/Time                    │
│  │  │                               │
│  │  ├─ ● [SHIPPED]  ✓               │
│  │  │  Date/Time                    │
│  │  │  Rider: [name]                │
│  │  │                               │
│  │  └─ ○ [DELIVERED]  ⏳            │
│  │     Estimated: Date/Time         │
│  │                                  │
│  └─ Estimated Delivery              │
│     Time display & eta              │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Google Maps with live location tracking
- Rider information card
- Order status timeline (linear progress)
- Estimated delivery time
- Call rider button

**Navigation:**
- Back → Orders list

---

### 13. CATEGORY NAVIGATION SCREEN (lib/src/features/products/category_navigation_screen.dart)

**Route Parameters:**
- `categoryId`: Category identifier
- `categoryName`: Display name

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: [categoryName]             │
│  ├─ Search icon                     │
│  └─ Filter icon                     │
├─────────────────────────────────────┤
│                                     │
│  [Filter Row - Sticky]              │
│  ├─ Sort dropdown                   │
│  ├─ Price range slider              │
│  ├─ More filters button             │
│  └─ Clear filters button            │
│                                     │
│  [Products Grid]                    │
│  ├─ GridView 2 columns              │
│  │  ├─ ProductCard                  │
│  │  └─ [repeat]                     │
│  │                                  │
│  └─ Pagination                      │
│                                     │
│  IF NO PRODUCTS:                    │
│  ├─ No products in category         │
│  └─ Try other categories CTA        │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- Subcategory navigation
- Product filtering by price, ratings, etc.
- Sorting options
- Product grid display

**Navigation:**
- Product tap → `/product-details?productId={id}`
- Filter → Refine results

---

### 14. PRODUCT LIST SCREEN (lib/src/features/products/product_list_screen.dart)

**Route Parameters:**
- `category`: Category identifier

Similar to Category Navigation Screen but accessed from direct route.

---

### 15. MEDICINE ORDER SCREEN (lib/src/features/products/medicine_order_screen.dart)

**Route:** `/medicine-order`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Order Medicine"           │
├─────────────────────────────────────┤
│                                     │
│  [Form] - Medicine Order Form       │
│  ├─ Prescription Upload             │
│  │  ├─ Camera capture button        │
│  │  ├─ Gallery import button        │
│  │  └─ Preview image                │
│  │                                  │
│  ├─ Medicine Selection              │
│  │  ├─ Search field                 │
│  │  ├─ Browse available medicines   │
│  │  └─ Selected medicines list      │
│  │     - Medicine name              │
│  │     - Qty: [input]               │
│  │     - Remove button              │
│  │                                  │
│  ├─ Delivery Address                │
│  │  ├─ Select address dropdown      │
│  │  └─ New address option           │
│  │                                  │
│  ├─ Notes                           │
│  │  └─ [TextArea] for special notes│
│  │                                  │
│  ├─ ────────────────────────        │
│  ├─ TOTAL: ৳xxx                    │
│  │                                  │
│  └─ "PLACE ORDER" button (primary)  │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- Prescription image upload
- Medicine search and selection
- Quantity specification
- Delivery address selector
- Special notes/instructions

---

### 16. WALLET SCREEN (lib/src/features/profile/wallet_screen.dart)

**Route:** `/wallet`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "My Wallet"                │
├─────────────────────────────────────┤
│                                     │
│  [Wallet Balance Card]              │
│  ├─ ╔═══════════════════════╗      │
│  │ ║ AVAILABLE BALANCE     ║      │
│  │ ║    ৳ 5,234.50          ║      │
│  │ ║ ═════════════════════ ║      │
│  │ ║ Card: 4242 **** **** ║      │
│  │ ║ Valid: 12/26          ║      │
│  │ ╚═══════════════════════╝      │
│  │                                  │
│  ├─ Quick Actions                   │
│  │  ├─ "ADD MONEY" button           │
│  │  ├─ "TRANSFER" button            │
│  │  ├─ "HISTORY" button             │
│  │  └─ "SETTINGS" button            │
│  │                                  │
│  ├─ Connected Payment Methods       │
│  │  ├─ Card 1                       │
│  │  │  ├─ Card number (masked)     │
│  │  │  ├─ Bank name                │
│  │  │  ├─ Expiry date              │
│  │  │  └─ Remove option            │
│  │  └─ [repeat]                    │
│  │                                  │
│  ├─ Transaction History             │
│  │  │  FOR EACH TXN:                │
│  │  │  ├─ Icon [type]               │
│  │  │  ├─ Description               │
│  │  │  ├─ Date/Time                 │
│  │  │  ├─ Amount (+/-)              │
│  │  │  └─ Status badge              │
│  │  │  [repeat]                     │
│  │  │                               │
│  │  └─ "View All" link              │
│  │                                  │
│  └─ Add New Payment Method Button   │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Wallet balance card (credit card style)
- Payment methods list
- Transaction history with icons
- Add money/transfer options

---

### 17. BACKUP SCREEN (lib/src/features/profile/backup_screen.dart)

**Route:** `/backup`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Backup & Restore"         │
├─────────────────────────────────────┤
│                                     │
│  [Tabs]                             │
│  ├─ BACKUP                          │
│  └─ RESTORE                         │
│                                     │
│  [BACKUP TAB]                       │
│  ├─ Last Backup: DD/MM/YYYY HH:MM  │
│  │  Size: xxx MB                    │
│  │                                  │
│  ├─ What will be backed up?         │
│  │  ├─ ✓ Order history              │
│  │  ├─ ✓ Wishlist items             │
│  │  ├─ ✓ Addresses                  │
│  │  ├─ ✓ Payment methods            │
│  │  ├─ ✓ User preferences           │
│  │  └─ ✓ Loyalty points             │
│  │                                  │
│  ├─ "BACK UP NOW" button (primary)  │
│  │  └─ Shows progress during backup │
│  │                                  │
│  └─ Auto-backup Schedule            │
│     ├─ Toggle: ON/OFF               │
│     └─ Frequency: Daily/Weekly/...  │
│                                     │
│  [RESTORE TAB]                      │
│  ├─ Available Backups List          │
│  │  ├─ Backup date                  │
│  │  ├─ Size & item count            │
│  │  ├─ Preview button               │
│  │  └─ "RESTORE" button             │
│  │  [repeat]                        │
│  │                                   │
│  └─ Restore Confirmation           │
│     ├─ Warning: Will overwrite     │
│     └─ Current data                 │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- Backup/restore tabs
- Backup history list
- Auto-backup configuration
- Progress indicators
- Data preview before restore

---

### 18. EDIT PROFILE SCREEN (lib/src/features/profile/edit_profile_screen.dart)

**Route:** `/edit-profile`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Edit Profile"             │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView]                       │
│                                     │
│  ├─ Profile Picture Section         │
│  │  ├─ [CircularAvatar]             │
│  │  ├─ "CHANGE PHOTO" button        │
│  │  │  ├─ Take photo                │
│  │  │  └─ Choose from gallery       │
│  │  └─ "REMOVE PHOTO" button        │
│  │                                  │
│  ├─ Basic Information               │
│  │  ├─ Name [TextField]             │
│  │  ├─ Email [TextField]            │
│  │  ├─ Phone [TextField]            │
│  │  ├─ Date of Birth [DatePicker]  │
│  │  └─ Gender [Dropdown]            │
│  │                                  │
│  ├─ Address Information             │
│  │  ├─ Country [Dropdown]           │
│  │  ├─ City [TextField]             │
│  │  ├─ Area [Dropdown]              │
│  │  └─ Area code [TextField]        │
│  │                                  │
│  ├─ Additional Information          │
│  │  ├─ Bio [TextArea]               │
│  │  ├─ Language Preference [Multi]  │
│  │  └─ Notification Toggle          │
│  │                                  │
│  ├─ Privacy & Security              │
│  │  ├─ Privacy setting [Dropdown]   │
│  │  ├─ Two-factor auth [Toggle]     │
│  │  └─ Activity log link            │
│  │                                  │
│  ├─ "SAVE CHANGES" button (primary) │
│  │  └─ Shows success toast          │
│  │                                  │
│  └─ "DISCARD" button (secondary)    │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Image picker with camera/gallery options
- Text fields for name, email, phone
- Date picker for DOB
- Dropdown selectors for country, city, gender
- Toggle switches for notifications
- Save/Discard buttons

---

### 19. APPLICATION FORM SCREEN (lib/src/features/profile/application_form_screen.dart)

**Route:** `/apply?role={reseller|rider|staff}`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Apply as [Role]"          │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView]                       │
│                                     │
│  ├─ Role Header                     │
│  │  ├─ Role icon                    │
│  │  ├─ Role name (EN/BN)            │
│  │  ├─ Requirements summary         │
│  │  └─ Expected benefits            │
│  │                                  │
│  ├─ Personal Details                │
│  │  ├─ Name [TextField]             │
│  │  ├─ Phone [TextField]            │
│  │  ├─ Email [TextField]            │
│  │  ├─ DOB [DatePicker]             │
│  │  └─ Gender [Dropdown]            │
│  │                                  │
│  ├─ Business/Professional Details   │
│  │  ├─ Shop name (if reseller)      │
│  │  ├─ Area of operation [Multi]    │
│  │  ├─ Years of experience          │
│  │  ├─ Vehicle type (if rider)      │
│  │  └─ License number               │
│  │                                  │
│  ├─ Document Upload                 │
│  │  ├─ ID proof                     │
│  │  ├─ Address proof                │
│  │  ├─ License (if applicable)      │
│  │  └─ Bank account documents       │
│  │                                  │
│  ├─ Bank & Payment Details          │
│  │  ├─ Bank name [Dropdown]         │
│  │  ├─ Account number [TextField]   │
│  │  ├─ Routing number [TextField]   │
│  │  └─ Account holder name          │
│  │                                  │
│  ├─ Terms & Conditions              │
│  │  ├─ Checkbox agreement           │
│  │  └─ Link to terms                │
│  │                                  │
│  ├─ "SUBMIT APPLICATION" button     │
│  │  └─ Shows progress during submit │
│  │                                  │
│  └─ "CANCEL" button (secondary)     │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- Role-based form sections
- Document upload with preview
- Bank details form
- Terms acceptance checkbox
- Form validation

**Parameters:**
- `role`: "reseller" | "rider" | "staff"

---

### 20. NOTIFICATIONS SCREEN (lib/src/features/notifications/notification_screen.dart)

**Route:** `/notifications`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Notifications"            │
│  ├─ Mark all as read button         │
│  └─ Settings icon                   │
├─────────────────────────────────────┤
│                                     │
│  [Filter Chips - Horizontal]        │
│  ├─ All                             │
│  ├─ Orders                          │
│  ├─ Promotions                      │
│  ├─ Updates                         │
│  └─ System                          │
│                                     │
│  [Notifications List]               │
│  │                                  │
│  │  FOR EACH NOTIFICATION:          │
│  │  ┌─────────────────────────────┐ │
│  │  │ ┌───┐                        │ │
│  │  │ │icon│  Title                │ │
│  │  │ └───┘  Subtitle/Description  │ │
│  │  │        Time ago               │ │
│  │  │        [Mark as read]         │ │
│  │  │        [Delete]              │ │
│  │  │                             │ │
│  │  │ [Unread badge if not read]  │ │
│  │  └─────────────────────────────┘ │
│  │                                  │
│  │  [repeat]                        │
│  │                                  │
│  └─ Pagination/infinite scroll      │
│                                     │
│  IF NO NOTIFICATIONS:               │
│  ├─ Empty illustration             │
│  └─ "All caught up!" message       │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Filter chips
- Notification cards with icons
- Mark as read/delete actions
- Unread badge indicator
- Time-ago display

**Navigation:**
- Notification tap → Jump to relevant screen (order, promotion, etc.)

---

### 21. CHAT SCREENS (lib/src/features/chat/)

#### 21a. CHAT SCREEN (lib/src/features/chat/chat_screen.dart)

**Route:** `/chat`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Chat with Support"        │
├─────────────────────────────────────┤
│                                     │
│  [Messages List]                    │
│  ├─ ScrollView                      │
│  │  FOR EACH MESSAGE:               │
│  │                                  │
│  │  [FROM SUPPORT STAFF]:           │
│  │  ├─ Left-aligned bubble          │
│  │  ├─ Staff avatar (top-left)      │
│  │  ├─ Message text                 │
│  │  ├─ Timestamp (bottom-right)     │
│  │  └─ Status indicator             │
│  │                                  │
│  │  [FROM USER]:                    │
│  │  ├─ Right-aligned bubble         │
│  │  ├─ Message text (blue bg)       │
│  │  ├─ Timestamp (bottom-left)      │
│  │  └─ Delivery status icon         │
│  │                                  │
│  │  [repeat]                        │
│  │                                  │
│  └─ Auto-scroll to latest           │
│                                     │
│  [Moderation Warning]               │
│  ├─ If sensitive info detected:     │
│  │  - Phone numbers                 │
│  │  - Emails                        │
│  │  - Spam links                    │
│  └─ Warning snackbar                │
│                                     │
├─────────────────────────────────────┤
│  [Input Area - Fixed]               │
│  ├─ [TextField] Message input       │
│  ├─ Emoji picker button             │
│  ├─ Attachment button (greyed)      │
│  └─ Send button (enabled if text)   │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- Real-time messaging from Firestore
- Chat moderation (blocks sensitive info)
- Message delivery status
- Typing indicator
- Auto-scroll to latest
- Emoji support

---

#### 21b. PRIVATE CHAT SCREEN (lib/src/features/chat/private_chat_screen.dart)

**Route:** `/private-chat?chatId={id}&name={name}&isStaff={bool}&receiverId={id}`

**Layout Structure:** (Similar to Chat Screen but for one-on-one)
```
┌─────────────────────────────────────┐
│  AppBar: [Receiver Name]            │
│  ├─ Online/Offline status dot       │
│  ├─ Call icon button                │
│  └─ Info/details button             │
├─────────────────────────────────────┤
│                                     │
│  [Messages List]                    │
│  ├─ Same structure as Chat Screen   │
│  └─ Plus: Typing indicator          │
│                                     │
├─────────────────────────────────────┤
│  [Input Area]                       │
│  ├─ [TextField] Message input       │
│  ├─ Media picker (if isStaff=false) │
│  │  ├─ Image picker                 │
│  │  └─ File picker                  │
│  └─ Send button                     │
│                                     │
└─────────────────────────────────────┘
```

**Route Parameters:**
- `chatId`: Firestore chat document ID
- `name`: Receiver's display name
- `isStaff`: Boolean indicating staff chat
- `receiverId`: Receiver's UID

---

#### 21c. CHAT HISTORY LIST SCREEN (lib/src/features/chat/chat_history_list_screen.dart)

**Route:** `/chat-history`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "Chat History"             │
│  ├─ Search icon                     │
│  └─ Sort icon                       │
├─────────────────────────────────────┤
│                                     │
│  [Search Bar]                       │
│  └─ [TextField] Search chats        │
│                                     │
│  [Chat List]                        │
│  │  FOR EACH CHAT:                  │
│  │  ┌─────────────────────────────┐ │
│  │  │ [Avatar]                    │ │
│  │  │ User name          [Unread] │ │
│  │  │ Last message...    HH:MM    │ │
│  │  │ [Swipe for delete]          │ │
│  │  └─────────────────────────────┘ │
│  │                                  │
│  │  [repeat]                        │
│  │                                  │
│  └─ Pagination                      │
│                                     │
│  IF NO CHATS:                       │
│  ├─ No conversations illustration   │
│  └─ Start chat prompt               │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Chat list with last message preview
- Unread badge counter
- Swipe-to-delete functionality
- Search and sort options

**Navigation:**
- Chat tap → `/private-chat?chatId={id}&name={name}`

---

### 22. HOW TO USE SCREEN (lib/src/features/profile/how_to_use_screen.dart)

**Route:** `/how-to-use`

**Layout Structure:**
```
┌─────────────────────────────────────┐
│  AppBar: "How to Use"               │
│  ├─ Search icon                     │
│  └─ Language toggle                 │
├─────────────────────────────────────┤
│                                     │
│  [Tutorial/Guide Content]           │
│  ├─ Tab or Accordion sections:      │
│  │  ├─ Getting Started              │
│  │  ├─ Shopping Guide               │
│  │  ├─ Orders & Tracking            │
│  │  ├─ Wallet & Payments            │
│  │  ├─ Loyalty & Rewards            │
│  │  ├─ Support & Refunds            │
│  │  └─ FAQs                         │
│  │                                  │
│  ├─ Expandable section content:     │
│  │  ├─ Step 1: ...                  │
│  │  │  ├─ Description text          │
│  │  │  ├─ Screenshots/images        │
│  │  │  └─ Video embed (if any)      │
│  │  ├─ Step 2: ...                  │
│  │  └─ [repeat]                     │
│  │                                  │
│  ├─ Video tutorials section         │
│  │  └─ YouTube video embeds         │
│  │                                  │
│  └─ "Contact Support" button        │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- Expandable FAQ/guide sections
- Multi-language support
- Video embed support
- Search functionality
- Visual guides with images

---

---

# ADMIN APP STRUCTURE

## App Entry Point: `lib/main_admin.dart`
- **Router**: `lib/src/utils/router_admin.dart`
- **Main Screen**: `AdminScreen` (lib/src/features/admin/admin_screen.dart)
- **Routing Logic**:
  - Role == "reseller" → ResellerScreen
  - Role == "admin" | "staff" → AdminScreen

### Top-Level Tab Structure (AdminScreen)
```
┌─────────────────────────────────────────────────────────────┐
│  AppBar                                                      │
│  ├─ Title: "ADMIN PANEL v[version]"                        │
│  └─ "VIEW STORE" button (switch to customer mode)          │
├─────────────────────────────────────────────────────────────┤
│  [Main TabBar] - 5 Tabs:                                    │
│  ├─ 📊 DASHBOARD                                           │
│  ├─ 🛍️ COMMERCE                                            │
│  ├─ 👥 PEOPLE                                              │
│  ├─ ⚡ INTELLIGENCE                                         │
│  └─ ⚙️ SYSTEM                                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  [TabBarView - Active Tab Content]                          │
│  └─ One of the hubs below                                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## ADMIN APP HUBS & TABS

### HUB 1: DASHBOARD HUB (2 nested tabs)

#### 1.1 OVERVIEW TAB
**Location:** Dashboard → Overview

**Layout:**
```
┌─────────────────────────────────────┐
│  [Inventory Forecasting Widget]     │
│  ├─ Title: "AI Stock Forecast"      │
│  ├─ Current inventory status        │
│  ├─ Low stock alerts                │
│  ├─ Restock recommendations         │
│  └─ Forecast graph                  │
│                                     │
├─────────────────────────────────────┤
│  [Quick Action Grid]                │
│  │  ┌─────────┬─────────┐           │
│  │  │ 📦      │ 📋      │           │
│  │  │ View    │ View    │           │
│  │  │ Stock   │ Orders  │           │
│  │  └─────────┴─────────┘           │
│  │                                  │
│  │  ┌─────────┬─────────┐           │
│  │  │ 👥      │ 🎯      │           │
│  │  │ Users   │ Targets │           │
│  │  └─────────┴─────────┘           │
│  │                                  │
│  └─ 4+ quick action cards           │
│                                     │
└─────────────────────────────────────┘
```

**Key Components:**
- Inventory forecasting with AI insights
- Quick stat cards
- Action buttons for common tasks
- Real-time data feeds

---

#### 1.2 ANALYTICS TAB
**Location:** Dashboard → Analytics

**Layout:**
```
┌─────────────────────────────────────┐
│  [AI Insight Card]                  │
│  ├─ 🧠 Psychology icon              │
│  ├─ "AI INSIGHT" label              │
│  ├─ Forecast message (auto-loaded)  │
│  ├─ Loading spinner (while loading) │
│  └─ Optional refresh button         │
│                                     │
├─────────────────────────────────────┤
│  [Statistics Grid]                  │
│  ├─ 4-column stat cards:            │
│  │  ├─ Total Sales                  │
│  │  ├─ Total Orders                 │
│  │  ├─ Total Customers              │
│  │  └─ Revenue                      │
│  │                                  │
│  └─ Color-coded with trends         │
│                                     │
├─────────────────────────────────────┤
│  [Sales Overview Section]           │
│  ├─ "SALES OVERVIEW" heading        │
│  │                                  │
│  ├─ [Line Chart / Bar Chart]        │
│  │  ├─ Timeline selector            │
│  │  │  (Daily/Weekly/Monthly)       │
│  │  ├─ Data visualization           │
│  │  └─ Interactive tooltips         │
│  │                                  │
│  └─ Legend & export options         │
│                                     │
└─────────────────────────────────────┘
```

**Key Features:**
- AI-powered forecasting
- Real-time analytics dashboard
- Sales charts and graphs
- Time-period filters
- Data export capabilities

---

### HUB 2: COMMERCE HUB (3 nested tabs)

#### 2.1 ORDERS TAB
**Location:** Commerce → Orders

**Layout:**
```
┌─────────────────────────────────────┐
│  [Time Filter Toggle]               │
│  ├─ Toggle: Show Today / All Time   │
│  └─ Auto-filter based on selection  │
│                                     │
│  [Order Status TabBar] - 2 tabs:    │
│  ├─ 📦 REGULAR ORDERS               │
│  └─ 🚨 EMERGENCY (Red accent)       │
│                                     │
│  [Active Tab Content]               │
│  │                                  │
│  ├─ [Filter Chips]                  │
│  │  ├─ All                          │
│  │  ├─ Pending                      │
│  │  ├─ Processing                   │
│  │  ├─ Delivered                    │
│  │  └─ Cancelled                    │
│  │                                  │
│  ├─ [Orders List]                   │
│  │  for(Order in filteredOrders):   │
│  │  ┌────────────────────────────┐  │
│  │  │ OrderCard                  │  │
│  │  │ ├─ Order ID                │  │
│  │  │ ├─ Customer name           │  │
│  │  │ ├─ Status [badge]          │  │
│  │  │ ├─ Total amount            │  │
│  │  │ ├─ Item count              │  │
│  │  │ ├─ Order time              │  │
│  │  │ │                           │  │
│  │  │ └─ Actions:                │  │
│  │  │    ├─ DETAILS button       │  │
│  │  │    ├─ UPDATE STATUS        │  │
│  │  │    └─ PRINT INVOICE        │  │
│  │  │                            │  │
│  │  └─ [repeat]                 │  │
│  │                               │  │
│  └─ Pagination/Infinite scroll     │  │
│                                     │
└─────────────────────────────────────┘
```

**Order Card Components:**
- Order ID and customer info
- Status badge (color-coded)
- Order summary (items, total, time)
- Quick action buttons
- Expandable details

**Nested Tab: EMERGENCY ORDERS**
```
Similar layout but for emergency orders:
├─ Emergency marker (red)
├─ Priority flag
├─ Urgent status badge
└─ Quick response buttons
```

---

#### 2.2 CATALOG TAB
**Location:** Commerce → Catalog

**Layout:**
```
┌─────────────────────────────────────┐
│  [Nested TabBar] - 3 tabs:          │
│  ├─ 📦 INVENTORY                    │
│  ├─ 📂 CATEGORIES                   │
│  └─ 🏪 SHOPS                        │
│                                     │
│  [Active Tab Content]               │
│                                     │
├─────────────────────────────────────┤
│  INVENTORY TAB:                     │
│  ├─ [Add Product Button]            │
│  ├─ [Search / Filter Bar]           │
│  │                                  │
│  ├─ [Products Table/Grid]           │
│  │  for(Product in products):       │
│  │  ├─ Product image thumbnail      │
│  │  ├─ Product name                 │
│  │  ├─ SKU / ID                     │
│  │  ├─ Current stock                │
│  │  ├─ Price                        │
│  │  ├─ Status (Active/Draft)        │
│  │  │                               │
│  │  └─ Actions:                     │
│  │     ├─ EDIT button               │
│  │     ├─ DELETE button             │
│  │     ├─ DUPLICATE button          │
│  │     └─ VIEW button               │
│  │                                  │
│  ├─ Bulk actions (checkboxes)       │
│  │  ├─ Select all                   │
│  │  ├─ Bulk edit                    │
│  │  └─ Bulk delete                  │
│  │                                  │
│  └─ Pagination                      │
│                                     │
│  CATEGORIES TAB:                    │
│  ├─ [Add Category Button]           │
│  ├─ [Category Tree View]            │
│  │  ├─ Main categories              │
│  │  ├─ Subcategories                │
│  │  └─ [Edit/Delete per category]   │
│  │                                  │
│  └─ Category management form        │
│                                     │
│  SHOPS TAB:                         │
│  ├─ [Add Shop Button]               │
│  ├─ [Shops Grid/List]               │
│  │  for(Shop in shops):             │
│  │  ├─ Shop logo                    │
│  │  ├─ Shop name                    │
│  │  ├─ Owner name                   │
│  │  ├─ Location                     │
│  │  ├─ Status badge                 │
│  │  └─ [EDIT/DELETE/VIEW]           │
│  │                                  │
│  └─ Pagination                      │
│                                     │
└─────────────────────────────────────┘
```

**Key Widgets:**
- Product/Category/Shop management tables
- Inline editing forms
- Bulk action toolbars
- Status badges
- Search and filter functionality

**Product Form Sheet (ProductFormSheet):**
```
┌─────────────────────────────────────┐
│  [Modal/BottomSheet Header]         │
│  ├─ "Add Product" / "Edit Product"  │
│  └─ X Close button                  │
├─────────────────────────────────────┤
│                                     │
│  [ScrollView - Form Fields]         │
│  ├─ Product name [EN/BN]            │
│  ├─ Description [EN/BN]             │
│  ├─ Category dropdown               │
│  ├─ Price [input]                   │
│  ├─ Discount % [input]              │
│  ├─ Stock quantity [input]          │
│  ├─ SKU [input]                     │
│  ├─ Images upload (multi)           │
│  │  ├─ Drag-drop area               │
│  │  ├─ File picker                  │
│  │  └─ Image preview grid           │
│  │                                  │
│  ├─ Specifications [Dynamic fields] │
│  │  ├─ "Add spec" button            │
│  │  └─ Key-value inputs             │
│  │                                  │
│  ├─ Tags [Multi-select chips]       │
│  ├─ Status (Active/Draft)           │
│  │                                  │
│  └─ [SAVE] [CANCEL] buttons         │
│                                     │
└─────────────────────────────────────┘
```

---

#### 2.3 LOGISTICS TAB
**Location:** Commerce → Logistics

**Layout:**
```
┌─────────────────────────────────────┐
│  [Logistics Overview Stats]         │
│  ├─ Active deliveries               │
│  ├─ Pending shipments                │
│  ├─ Completed today                 │
│  └─ Rider availability              │
│                                     │
├─────────────────────────────────────┤
│  [Delivery Zones Section]           │
│  ├─ "DELIVERY ZONES" heading        │
│  │                                  │
│  ├─ [Zone Cards Grid]               │
│  │  for(Zone in zones):             │
│  │  ├─ Zone name                    │
│  │  ├─ Area coverage                │
│  │  ├─ Active riders count          │
│  │  ├─ Avg delivery time            │
│  │  └─ [MANAGE/EDIT]                │
│  │                                  │
│  └─ [Add Zone Button]               │
│                                     │
├─────────────────────────────────────┤
│  [Active Deliveries List]           │
│  ├─ [Map View (embedded)]           │
│  │  ├─ Rider locations (pins)       │
│  │  ├─ Delivery route polylines     │
│  │  └─ Zone boundaries              │
│  │                                  │
│  └─ [List View]                     │
│     for(Delivery in active):        │
│     ├─ Order ID                     │
│     ├─ Rider name & vehicle         │
│     ├─ Current location             │
│     ├─ Destination                  │
│     ├─ ETA                          │
│     └─ Status [IN_TRANSIT/...]      │
│                                     │
└─────────────────────────────────────┘
```

**Delivery Zone Tab (nested):**
```
Manages delivery zones/areas:
├─ Zone list with coverage info
├─ Add/edit delivery fees per zone
├─ Assign riders to zones
└─ Set delivery time estimates
```

---

### HUB 3: PEOPLE HUB (4 nested tabs)

#### 3.1 TEAMS TAB
**Location:** People → Teams

**Layout:**
```
┌─────────────────────────────────────┐
│  [Teams Management Section]         │
│  ├─ "TEAMS" heading                 │
│  ├─ [Add Team Button]               │
│  │                                  │
│  ├─ [Teams List]                    │
│  │  for(Team in teams):             │
│  │  ├─ Team name                    │
│  │  ├─ Member count                 │
│  │  ├─ Department                   │
│  │  ├─ Team lead                    │
│  │  └─ [MANAGE/VIEW MEMBERS]        │
│  │                                  │
│  └─ Pagination                      │
│                                     │
├─────────────────────────────────────┤
│  [Team Members Section]             │
│  ├─ Selected team members           │
│  │                                  │
│  ├─ for(Member in teamMembers):     │
│  │  ├─ Member avatar               │
│  │  ├─ Member name                  │
│  │  ├─ Role/Position                │
│  │  ├─ Email                        │
│  │  ├─ Status (Active/Inactive)     │
│  │  └─ [EDIT/REMOVE]               │
│  │                                  │
│  └─ [Add Member Button]             │
│                                     │
└─────────────────────────────────────┘
```

---

#### 3.2 ACCOUNTS TAB
**Location:** People → Accounts

**Layout:**
```
┌─────────────────────────────────────┐
│  [Accounts Management]              │
│  ├─ [Search bar]                    │
│  ├─ [Filter options]                │
│  │  ├─ By role (Admin/Staff/...)    │
│  │  ├─ By status (Active/Inactive)  │
│  │  └─ By department                │
│  │                                  │
│  ├─ [Staff/Admin Accounts List]     │
│  │  for(Account in accounts):       │
│  │  ├─ Account avatar/icon          │
│  │  ├─ Name & email                 │
│  │  ├─ Role badge                   │
│  │  ├─ Joined date                  │
│  │  ├─ Last active                  │
│  │  ├─ Status (Online/Offline)      │
│  │  │                               │
│  │  └─ [Actions]:                   │
│  │     ├─ VIEW PROFILE              │
│  │     ├─ EDIT ROLE                 │
│  │     ├─ RESET PASSWORD            │
│  │     ├─ SUSPEND/DEACTIVATE        │
│  │     └─ DELETE                    │
│  │                                  │
│  ├─ Bulk actions                  │
│  │  ├─ Select multiple accounts     │
│  │  └─ Bulk update roles            │
│  │                                  │
│  └─ Pagination                      │
│                                     │
├─────────────────────────────────────┤
│  [Commissions/Payroll Section]      │
│  ├─ Accounts & Commissions tab      │
│  │                                  │
│  ├─ for(Person in staff):           │
│  │  ├─ Name                         │
│  │  ├─ Role                         │
│  │  ├─ Sales/Orders handled         │
│  │  ├─ Commission %                 │
│  │  ├─ Total earned                 │
│  │  ├─ Paid to date                 │
│  │  ├─ Outstanding                  │
│  │  │                               │
│  │  └─ [PAY NOW / HISTORY]          │
│  │                                  │
│  └─ Payroll summary                 │
│                                     │
└─────────────────────────────────────┘
```

**Nested Tabs:**
- **Security Tab**: Staff login attempts, 2FA status, etc.
- **Accounts & Commissions Tab**: Payment history, commission tracking

---

#### 3.3 RESELLERS TAB
**Location:** People → Resellers

**Layout:**
```
┌─────────────────────────────────────┐
│  [Reseller Applications]            │
│  ├─ [Filter Tabs]                   │
│  │  ├─ Pending                      │
│  │  ├─ Approved                     │
│  │  └─ Rejected                     │
│  │                                  │
│  ├─ [Applications List]             │
│  │  for(App in resellerApps):       │
│  │  ├─ Applicant name               │
│  │  ├─ Shop name                    │
│  │  ├─ Applied date                 │
│  │  ├─ Status badge                 │
│  │  ├─ Location                     │
│  │  │                               │
│  │  └─ [Actions]:                   │
│  │     ├─ VIEW APPLICATION          │
│  │     ├─ APPROVE (green)           │
│  │     ├─ REJECT (red)              │
│  │     └─ REQUEST MORE INFO         │
│  │                                  │
│  └─ Pagination                      │
│                                     │
├─────────────────────────────────────┤
│  [Application Detail Modal]         │
│  ├─ Applicant info                  │
│  ├─ Business details                │
│  ├─ Document verification           │
│  ├─ Requirements checklist          │
│  ├─ Approval options                │
│  └─ Notes field                     │
│                                     │
└─────────────────────────────────────┘
```

---

#### 3.4 CHATS / INTERACTIONS TAB
**Location:** People → Chats

**Layout:**
```
┌─────────────────────────────────────┐
│  [Chat Management]                  │
│  ├─ [Filter / Search]               │
│  │  ├─ User/customer search         │
│  │  ├─ Chat type filter             │
│  │  └─ Date range filter            │
│  │                                  │
│  ├─ [Chat Conversations List]       │
│  │  for(Chat in chats):             │
│  │  ├─ User avatar                  │
│  │  ├─ User name / topic            │
│  │  ├─ Last message preview         │
│  │  ├─ Unread count badge           │
│  │  ├─ Timestamp                    │
│  │  ├─ Response time (avg)          │
│  │  │                               │
│  │  └─ [Actions]:                   │
│  │     ├─ VIEW CHAT                 │
│  │     ├─ ASSIGN TO STAFF           │
│  │     ├─ MARK RESOLVED             │
│  │     └─ DELETE                    │
│  │                                  │
│  └─ Pagination                      │
│                                     │
├─────────────────────────────────────┤
│  [Chat Viewer Modal]                │
│  ├─ Full message thread             │
│  ├─ Admin reply capability          │
│  ├─ Notes for staff                 │
│  └─ Chat history timeline           │
│                                     │
└─────────────────────────────────────┘
```

---

### HUB 4: INTELLIGENCE HUB (4 nested tabs)

#### 4.1 AI MASTER TAB
**Location:** Intelligence → AI Master

**Layout:**
```
┌─────────────────────────────────────┐
│  [AI Configuration Panel]           │
│  ├─ AI Quota display                │
│  │  ├─ Daily quota: XXX/5000        │
│  │  ├─ Usage this month: XXX        │
│  │  └─ Reset date: YYYY-MM-DD       │
│  │                                  │
│  ├─ [AI Model Selection]            │
│  │  ├─ Model dropdown               │
│  │     (GPT-4, Claude, etc.)        │
│  │  ├─ Temperature slider           │
│  │  ├─ Max tokens input             │
│  │  └─ Preview settings             │
│  │                                  │
│  ├─ [AI Notification Control]       │
│  │  ├─ AI Notifications tab         │
│  │  ├─ Alert preferences            │
│  │  ├─ Digest frequency             │
│  │  └─ Notification toggles         │
│  │                                  │
│  ├─ [Audit log]                     │
│  │  ├─ AI Audit tab                 │
│  │  ├─ AI usage history             │
│  │  ├─ Timestamp, action, result    │
│  │  └─ Export logs                  │
│  │                                  │
│  └─ Virtual Data Lab                │
│     ├─ Testing/sandbox area         │
│     ├─ Try AI prompts               │
│     ├─ See real-time results        │
│     └─ Debug AI responses           │
│                                     │
└─────────────────────────────────────┘
```

**Components:**
- **AI Model Selection**: Choose AI provider/model
- **Quota Display**: Track usage
- **Settings Panel**: Configure behavior
- **Virtual Lab**: Test AI in sandbox

---

#### 4.2 DATABASE TAB
**Location:** Intelligence → Database

**Layout:**
```
┌─────────────────────────────────────┐
│  [Database Management]              │
│  ├─ Database overview               │
│  │  ├─ Total documents              │
│  │  ├─ Storage used                 │
│  │  ├─ Sync status                  │
│  │  └─ Last backup                  │
│  │                                  │
│  ├─ [Collection Browser]            │
│  │  └─ Grouped by collection type:  │
│  │     ├─ users                     │
│  │     ├─ products                  │
│  │     ├─ orders                    │
│  │     ├─ chats                     │
│  │     └─ ...more                   │
│  │                                  │
│  ├─ [Data Query Tool]               │
│  │  ├─ Collection selector          │
│  │  ├─ Filter builder               │
│  │  ├─ Sort options                 │
│  │  └─ Query runner button          │
│  │                                  │
│  ├─ [Database Stats]                │
│  │  ├─ Read operations today        │
│  │  ├─ Write operations today       │
│  │  ├─ Delete operations today      │
│  │  └─ Bytes transferred            │
│  │                                  │
│  └─ [Backup/Restore]                │
│     ├─ Last backup date             │
│     ├─ Create backup button         │
│     └─ Restore from backup          │
│                                     │
└─────────────────────────────────────┘
```

---

#### 4.3 SYSTEM HEALTH TAB
**Location:** Intelligence → AI Health

**Layout:**
```
┌─────────────────────────────────────┐
│  [System Health Dashboard]          │
│  ├─ Overall system status (%)       │
│  ├─ Green/yellow/red indicator      │
│  │                                  │
│  ├─ [Health Metrics Cards]          │
│  │  ├─ API response time (avg)      │
│  │  ├─ Error rate (%)               │
│  │  ├─ Uptime (24h)                 │
│  │  ├─ Active connections           │
│  │  └─ Queue depth                  │
│  │                                  │
│  ├─ [Health Timeline Graph]         │
│  │  ├─ 24-hour view                 │
│  │  ├─ Line chart of health %       │
│  │  ├─ Events marked on timeline    │
│  │  └─ Hover for details            │
│  │                                  │
│  ├─ [Recent Issues]                 │
│  │  ├─ Issue list (if any)          │
│  │  ├─ Severity badges              │
│  │  ├─ Auto-recovery status         │
│  │  └─ Manual action needed?        │
│  │                                  │
│  └─ [Automated Responses]           │
│     ├─ Recent AI-triggered actions  │
│     └─ Auto-recovery logs           │
│                                     │
└─────────────────────────────────────┘
```

---

#### 4.4 VIRTUAL LAB TAB
**Location:** Intelligence → Virtual Lab

**Layout:**
```
┌─────────────────────────────────────┐
│  [Virtual Data Lab - Sandbox]       │
│  ├─ "AI Testing Sandbox"            │
│  ├─ Safe environment for testing    │
│  │                                  │
│  ├─ [AI Prompt Input]               │
│  │  ├─ [Large textarea]             │
│  │  ├─ Example prompts dropdown     │
│  │  ├─ Template buttons             │
│  │  └─ Character count              │
│  │                                  │
│  ├─ [Advanced Options]              │
│  │  ├─ Model selection              │
│  │  ├─ Temperature control          │
│  │  ├─ Max tokens setting           │
│  │  └─ Timeout setting              │
│  │                                  │
│  ├─ [Run/Execute Button]            │
│  │  └─ Shows loading state          │
│  │                                  │
│  ├─ [Response Output]               │
│  │  ├─ Raw AI response text         │
│  │  ├─ Timing info (latency)        │
│  │  ├─ Token usage breakdown        │
│  │  ├─ Copy button                  │
│  │  └─ Export button                │
│  │                                  │
│  └─ [History Panel]                 │
│     ├─ Previous queries             │
│     ├─ Saved favorite prompts       │
│     └─ Quick load from history      │
│                                     │
└─────────────────────────────────────┘
```

---

### HUB 5: SYSTEM HUB (3 nested tabs)

#### 5.1 SETTINGS TAB
**Location:** System → Settings

**Layout:**
```
┌─────────────────────────────────────┐
│  [System Settings]                  │
│  ├─ [Settings Sections - Accordion] │
│  │                                  │
│  ├─ 1. GENERAL SETTINGS             │
│  │  ├─ App name [input]             │
│  │  ├─ Support email [input]        │
│  │  ├─ Support phone [input]        │
│  │  ├─ Business address [input]     │
│  │  ├─ Business hours [time range]  │
│  │  └─ Save button                  │
│  │                                  │
│  ├─ 2. PAYMENT SETTINGS             │
│  │  ├─ Currency selector            │
│  │  ├─ Payment gateway config       │
│  │  ├─ Tax rate settings            │
│  │  ├─ Shipping fee config          │
│  │  └─ Save button                  │
│  │                                  │
│  ├─ 3. EMAIL & NOTIFICATIONS        │
│  │  ├─ Email notifications toggle   │
│  │  ├─ SMS alerts toggle            │
│  │  ├─ Push notifications toggle    │
│  │  ├─ Notification frequency       │
│  │  └─ Save button                  │
│  │                                  │
│  ├─ 4. SECURITY                     │
│  │  ├─ 2FA enforcement toggle       │
│  │  ├─ Password policy settings     │
│  │  ├─ Session timeout [input]      │
│  │  ├─ IP whitelist [textarea]      │
│  │  └─ Save button                  │
│  │                                  │
│  ├─ 5. MAINTENANCE                  │
│  │  ├─ Maintenance mode toggle      │
│  │  ├─ Maintenance message [input]  │
│  │  ├─ Clear cache button           │
│  │  ├─ Sync database button         │
│  │  └─ Restart services button      │
│  │                                  │
│  └─ 6. BACKUP & RECOVERY            │
│     ├─ Auto-backup frequency        │
│     ├─ Retention days [input]       │
│     ├─ Manual backup button         │
│     └─ View backup history          │
│                                     │
└─────────────────────────────────────┘
```

---

#### 5.2 LOCALIZATION TAB
**Location:** System → Lang (Localization)

**Layout:**
```
┌─────────────────────────────────────┐
│  [Language & Localization]          │
│  ├─ [Language Selection]            │
│  │  ├─ Primary language dropdown    │
│  │  ├─ Secondary language dropdown  │
│  │  └─ Supported languages list     │
│  │                                  │
│  ├─ [String Translations Editor]    │
│  │  ├─ Language tabs (EN, BN, etc.) │
│  │  ├─ Search translations          │
│  │  │                               │
│  │  ├─ for(String in strings):      │
│  │  │  ├─ Key (ID)                  │
│  │  │  ├─ EN translation [editable] │
│  │  │  ├─ BN translation [editable] │
│  │  │  ├─ [Save]  [Delete]          │
│  │  │  └─ [repeat]                  │
│  │  │                               │
│  │  └─ Pagination                   │
│  │                                  │
│  ├─ [Add New String]                │
│  │  ├─ String key [input]           │
│  │  ├─ EN value [input]             │
│  │  ├─ BN value [input]             │
│  │  └─ Save button                  │
│  │                                  │
│  ├─ [Bulk Import/Export]            │
│  │  ├─ Export translations (JSON)   │
│  │  ├─ Import translations (JSON)   │
│  │  └─ Download template            │
│  │                                  │
│  └─ [Regional Settings]             │
│     ├─ Currency format              │
│     ├─ Date format                  │
│     ├─ Time format                  │
│     └─ Number format                │
│                                     │
└─────────────────────────────────────┘
```

---

#### 5.3 FLEET TAB
**Location:** System → Fleet

**Layout:**
```
┌─────────────────────────────────────┐
│  [Fleet Status & Monitoring]        │
│  ├─ "Fleet Status & Shorebird"      │
│  │  Monitoring                      │
│  │                                  │
│  ├─ [Shorebird Update Status]       │
│  │  ├─ Last build version           │
│  │  ├─ Available update (if any)    │
│  │  ├─ Build date                   │
│  │  ├─ Patch status                 │
│  │  └─ Deploy button (if available) │
│  │                                  │
│  ├─ [Fleet Devices]                 │
│  │  ├─ Total devices                │
│  │  ├─ Online devices               │
│  │  ├─ Offline devices              │
│  │  ├─ Needs update count           │
│  │  │                               │
│  │  └─ Device list:                 │
│  │     for(Device in fleet):        │
│  │     ├─ Device name               │
│  │     ├─ Platform (iOS/Android)    │
│  │     ├─ Current version           │
│  │     ├─ Status (Online/Offline)   │
│  │     ├─ Last heartbeat            │
│  │     └─ [FORCE UPDATE / DETAILS]  │
│  │                                  │
│  ├─ [Deployment Logs]               │
│  │  ├─ Recent deployments list      │
│  │  ├─ Timestamp                    │
│  │  ├─ Version deployed             │
│  │  ├─ Success/failure status       │
│  │  └─ View logs link               │
│  │                                  │
│  └─ [Update Configuration]          │
│     ├─ Auto-update toggle           │
│     ├─ Update schedule              │
│     └─ Rollback option              │
│                                     │
└─────────────────────────────────────┘
```

---

### ADDITIONAL ADMIN FEATURES

#### Market/Marketing Tab
- **Marketing Hub Tab**: Promotions, campaigns, coupons
- **Marketing Tab**: Campaign management, analytics
- **Notice Management**: System notices, banners
- **Feedback Tab**: Customer feedback/reviews

#### Operations Tab
- **Operations Tab**: Business operations
- **Device Requests Tab**: Device lifecycle management
- **Staff Management Tab**: Staff permissions, roles
- **Staff Security Tab**: Staff security audit logs

---

---

# NAVIGATION ARCHITECTURE

## CUSTOMER APP ROUTING (`router_customer.dart`)

```
/                              → MainScreen (BottomNavBar)
/login                         → LoginScreen
/signup                        → SignupScreen
/forgot-password              → ForgotPasswordScreen
/product-details?productId=X  → ProductDetailScreen
/categories/:id?name=X        → CategoryNavigationScreen
/products/:category           → ProductListScreen
/search?q=X&action=X          → SearchScreen
/cart                         → CartScreen
/orders                       → OrdersScreen
/order-tracking?orderId=X&riderUid=X → OrderTrackingScreen
/wishlist                     → WishlistScreen
/chat                         → ChatScreen
/chat-history                 → ChatHistoryListScreen
/private-chat?chatId=X&name=X&isStaff=&receiverId=X → PrivateChatScreen
/wallet                       → WalletScreen
/backup                       → BackupScreen
/edit-profile                 → EditProfileScreen
/apply?role=reseller|rider|staff → ApplicationFormScreen
/notifications                → NotificationScreen
/medicine-order              → MedicineOrderScreen
/emergency                    → EmergencyDetailsScreen
/how-to-use                  → HowToUseScreen
/admin                        → Redirect to / (blocked for customers)
/staff                        → Redirect to / (blocked for customers)
```

**Authentication Guard:**
- Not logged in + Not on auth page → Redirect to `/login`
- Logged in + On auth page → Redirect to `/`
- Role validation: Admin/Staff redirected from customer router

---

## ADMIN APP ROUTING (`router_admin.dart`)

```
/                    → Route based on role:
                       - role="reseller" → ResellerScreen
                       - role="admin"|"staff" → AdminScreen(isAdmin=true)

/login              → LoginScreen
/chat               → ChatScreen
/notifications      → NotificationScreen
/how-to-use        → HowToUseScreen
```

**Authentication Guard:**
- Not logged in + Not on /login → Redirect to `/login`
- Logged in + On /login → Redirect to `/`
- Role validation: Only admin/staff/reseller allowed
  - role="customer" → Auto sign out + Redirect to `/login`

---

# SHARED COMPONENTS

## Reusable Widgets

### 1. ProductCard
**Location:** `lib/src/features/home/widgets/home_widgets.dart`
**Used In:** Product grids, search results, wishlist, related products
**Structure:**
```
┌─────────────────────┐
│   [Product Image]   │
│   ┌───────────────┐ │
│   │  ♥ (wishlist)│ │
│   └───────────────┘ │
├─────────────────────┤
│ Product Name (EN) │
│ Product Name (BN) │
│ ★★★★☆ (4.5)      │
│ ৳ 450 | ৳ 500 -10% │
│ In Stock          │
├─────────────────────┤
│ [ADD TO CART Btn]   │
└─────────────────────┘
```

**Props:**
- `product: Product` - Product model
- Tap handlers for add to cart, wishlist toggle

---

### 2. OrderCard (Admin)
**Location:** `lib/src/features/admin/widgets/orders/order_card.dart`
**Used In:** Admin Orders tab
**Structure:**
- Order ID, customer name, status badge
- Items count, total amount
- Timestamp
- Action buttons (Details, Update Status, Print)

---

### 3. Notification Widgets
**Location:** `lib/src/shared/widgets/`
- NotificationCard
- Success/Error/Warning toasts
- SnackBar wrappers

---

### 4. AppBar Variations
- **HomeAppBar**: Home-specific with search, filters
- **SimpleAppBar**: Standard back + title
- **SliverAppBar**: For collapsible header on product detail

---

### 5. Form Widgets
- **AddressSelector**: Dropdown for delivery address
- **ImagePicker**: For profile images, documents
- **DateTimePickerFields**: For DOB, dates
- **CurrencyInput**: For price fields

---

### 6. Modals & Dialogs
- **ProductFormSheet**: Add/edit products (admin)
- **AddressConfirmDialog**: Confirm delivery address
- **PaymentMethodSelectionDialog**: Choose payment
- **RewardPopup**: Show earned points

---

### 7. Loading & Skeleton States
- **ShimmerEffect**: Skeleton loaders
- **LoadingOverlay**: Full-screen loading indicator
- **ProgressIndicator**: Custom styled progress

---

### 8. Status Badges
- Order status (Pending, Processing, Delivered, Cancelled)
- Product status (In Stock, Low Stock, Out of Stock)
- User role (Admin, Staff, Reseller, Customer)
- Payment status (Paid, Pending, Failed)

---

# COMMON LAYOUT PATTERNS

## Pattern 1: Sticky Header + Scrollable Content
**Used In:** Home, Product Details, Orders
```
┌──────────────────────┐
│ [Sticky AppBar]      │
├──────────────────────┤
│ [Scrollable Content] │
│ - Padding: 16       │
│ - Content sections  │
│ - Spacing: 24-32px  │
└──────────────────────┘
```

---

## Pattern 2: Tab Navigation
**Used In:** Admin hubs, Order types, Chat types
```
Main TabBar (scrollable if >4 tabs)
├─ Tab 1
├─ Tab 2
└─ ...
  ↓
TabBarView
├─ Content 1
├─ Content 2
└─ ...
```

---

## Pattern 3: Filter + List
**Used In:** Orders, Products, Search
```
┌─────────────────────┐
│ [Filter Chips/Bar]  │ ← Sticky
├─────────────────────┤
│ [GridView/ListView] │ ← Scrollable
│ - Cards/Tiles       │
│ - with images       │
│ - with actions      │
└─────────────────────┘
```

---

## Pattern 4: Form Layout
**Used In:** Profile edit, Application form, Settings
```
┌─────────────────────┐
│ [AppBar with title] │
├─────────────────────┤
│ [ScrollView]        │
│ - Form fields       │
│ - Grouped sections  │
│ - 16px spacing      │
├─────────────────────┤
│ [Action buttons]    │
│ - Save (primary)    │
│ - Cancel (secondary)│
└─────────────────────┘
```

---

## Pattern 5: Card-Based Layout
**Used In:** Profile quick actions, Dashboard stats
```
4 columns (responsive):
┌────────┬────────┬────────┬────────┐
│ Card 1 │ Card 2 │ Card 3 │ Card 4 │
└────────┴────────┴────────┴────────┘
2 columns (smaller):
┌────────┬────────┐
│ Card 1 │ Card 2 │
├────────┼────────┤
│ Card 3 │ Card 4 │
└────────┴────────┘
```

---

## Pattern 6: Bottom Sheet
**Used In:** Product detail, Add product, Filters
```
┌──────────────────────────┐
│ [Header - draggable]     │
├──────────────────────────┤
│ [Content - scrollable]   │
│                          │
│                          │
├──────────────────────────┤
│ [Action buttons]         │
└──────────────────────────┘
```

---

## Pattern 7: Map Integration
**Used In:** Order tracking, Delivery zones
```
┌──────────────────────┐
│ [Google Maps Widget] │
│ - Markers            │
│ - Polylines          │
│ - User location      │
└──────────────────────┘
[Below map: Info card]
```

---

# COLOR & STYLING

## Theme System
- **Primary Color**: AppStyles.primaryColor
- **Accent Color**: AppStyles.accentColor
- **Dark Background**: AppStyles.darkBackgroundColor
- **Light Background**: AppStyles.backgroundColor
- **Text Colors**: Dark mode aware

---

## Typography
- **Headings**: FontWeight.w900, fontSize 20-24
- **Subheadings**: FontWeight.bold, fontSize 16-18
- **Body**: FontWeight.normal, fontSize 14
- **Small**: fontSize 12, color: gray

---

## Spacing Standards
- **Padding**: 16, 20, 24px
- **Margins**: 12, 16, 24, 32px
- **Gap between sections**: 24-32px
- **Gap between items**: 12-16px

---

## Border Radius
- **Cards**: 12-15px
- **Buttons**: 12-20px
- **Circular**: Full circle (50%)
- **Subtle**: 8px

---

---

# SUMMARY TABLE

| App | Screen | File | Route | Key Features |
|-----|--------|------|-------|-----|
| **CUSTOMER** | | | | |
| | Home | home_screen.dart | / | Carousel, categories, flash sale, loyalty |
| | Emergency | emergency_details_screen.dart | /emergency | Emergency form, status tracking |
| | All Products | all_products_screen.dart | (MainScreen) | Grid, filters, search |
| | Rewards | rewards_screen.dart | (MainScreen) | Points display, redemption |
| | Profile | profile_screen.dart | (MainScreen) | User info, action grid, logout |
| | Product Details | product_detail_screen.dart | /product-details | Images, specs, related, add to cart |
| | Cart | cart_screen.dart | /cart | Items list, summary, checkout |
| | Search | search_screen.dart | /search | Real-time search, grid display |
| | Wishlist | wishlist_screen.dart | /wishlist | Grid of favorites, remove |
| | Orders | orders_screen.dart | /orders | Filter chips, order cards |
| | Order Details | order_details_screen.dart | (embedded) | Status, items, address, summary |
| | Order Tracking | order_tracking_screen.dart | /order-tracking | Map, rider info, timeline |
| | Category Nav | category_navigation_screen.dart | /categories/:id | Subcategories, product grid |
| | Product List | product_list_screen.dart | /products/:cat | Same as category nav |
| | Medicine Order | medicine_order_screen.dart | /medicine-order | Prescription, medicine select |
| | Wallet | wallet_screen.dart | /wallet | Balance, transactions, add money |
| | Backup | backup_screen.dart | /backup | Backup/restore management |
| | Edit Profile | edit_profile_screen.dart | /edit-profile | Form with avatar, address |
| | Apply (Role) | application_form_screen.dart | /apply | Role-specific form, documents |
| | Notifications | notification_screen.dart | /notifications | Filter chips, notification list |
| | Chat | chat_screen.dart | /chat | Support chat, moderation |
| | Private Chat | private_chat_screen.dart | /private-chat | One-on-one messaging |
| | Chat History | chat_history_list_screen.dart | /chat-history | Chat list, search |
| | How to Use | how_to_use_screen.dart | /how-to-use | Guide sections, FAQs, videos |
| | Login | login_screen.dart | /login | Email/phone, password, social |
| | Signup | signup_screen.dart | /signup | Registration form |
| | Forgot Password | forgot_password_screen.dart | /forgot-password | Email/phone recovery |
| **ADMIN** | | | | |
| | Admin Main | admin_screen.dart | / | 5 main tabs + nested tabs |
| | - Dashboard | (Overview) | Dashboard/Overview | Inventory forecast, stats |
| | - Dashboard | (Analytics) | Dashboard/Analytics | AI insights, charts, sales |
| | - Commerce | (Orders) | Commerce/Orders | Order list, emergency tab |
| | - Commerce | (Catalog) | Commerce/Catalog | Inventory, categories, shops |
| | - Commerce | (Logistics) | Commerce/Logistics | Zones, delivery tracking, map |
| | - People | (Teams) | People/Teams | Teams, members management |
| | - People | (Accounts) | People/Accounts | Staff accounts, commissions |
| | - People | (Resellers) | People/Resellers | Reseller applications |
| | - People | (Chats) | People/Chats | Chat management, interactions |
| | - Intelligence | (AI Master) | Intelligence/AI Master | AI config, quota, settings |
| | - Intelligence | (Database) | Intelligence/Database | Collections, data query |
| | - Intelligence | (AI Health) | Intelligence/AI Health | System health metrics |
| | - Intelligence | (Virtual Lab) | Intelligence/Virtual Lab | AI testing sandbox |
| | - System | (Settings) | System/Settings | General, payment, security |
| | - System | (Lang) | System/Lang | Translations, localization |
| | - System | (Fleet) | System/Fleet | Shorebird, device status |
| | Reseller | reseller_screen.dart | / (if reseller) | Placeholder screen |


---

**Document Generated:** 2026-03-24
**Last Updated:** Current analysis
**Scope:** Both customer and admin apps, all screens and navigation
