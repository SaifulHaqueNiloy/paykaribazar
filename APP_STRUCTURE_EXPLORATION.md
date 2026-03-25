# Paykari Bazar App Structure Exploration Report

**Scope:** Complete mapping of Customer App, Admin App, Reseller Dashboard, and shared infrastructure
**Generated:** March 24, 2026

---

## 1. APP ENTRY POINTS & CONFIGURATION

### Main Entry Points
- **Customer App:** `lib/main_customer.dart`
  - Uses router: `router_customer.dart`
  - Entry navigation: `/` → MainScreen
  - Auth redirect: `/login` (if not logged in)
  - Background tasks: Workmanager for backup service

- **Admin App:** `lib/main_admin.dart`
  - Uses router: `router_admin.dart`
  - Entry navigation: `/` → AdminScreen or ResellerScreen (based on role)
  - Auth redirect: `/login` (if not logged in)
  - Role-based access: Only admin/staff/reseller allowed

- **Configuration:** 
  - Firebase initialization
  - Sentry error tracking
  - Riverpod state management
  - Localizations support (English & Bengali)
  - Theme management (light/dark)

---

## 2. CUSTOMER APP - SCREENS & NAVIGATION

### Main Screen Architecture (Bottom Navigation)
**File:** `lib/src/features/main_screen.dart`

**Navigation Bar (5 Tabs):**
1. **Home** (index: 0) → HomeScreen
2. **Emergency** (index: 1) → EmergencyDetailsScreen
3. **Products** (index: 2) → AllProductsScreen
4. **Rewards** (index: 3) → RewardsScreen
5. **Profile** (index: 4) → ProfileScreen

**State Management:** `navProvider` (StateNotifier for current index)

### Customer App Screens

#### Authentication & Account
- `login_screen.dart` - Phone/Email login with remember me
  - TextFields: ID (email/phone), Password
  - Features: Credential persistence, role validation
  
- `signup_screen.dart` - New user registration
  - TextFields: Name, Phone, Email (optional), Password, Referral code, Blood contact
  - Dropdowns: District, Upazila, Blood group
  - Features: Blood donor registration, loyalty points on signup
  
- `forgot_password_screen.dart` - Password recovery
  
- `forgot_password_dialog.dart` - Dialog-based reset

#### Home & Discovery
- `home_screen.dart` - Main dashboard
  - Components: Greeting widget, Notice slider, Category sidebar, Product lists
  - Features: Reward notification popup, scroll-based sticky header
  - Widgets:
    - GreetingWidget - User greeting
    - NoticeSlider - Notice/banner carousel
    - CategorySidebar - Category navigation
    - CouponListScreen - Available coupons
    - FlashSaleTimer - Limited-time deals
    - LoyaltyStatusCard - Points display
    - QiblaIndicator - Prayer compass
    - FloatingCartBar - Floating cart button

- `bonus_cashback_screen.dart` - Cashback info
- `rewards_screen.dart` - Loyalty rewards display

#### Products & Browsing
- `product_list_screen.dart` - Category-filtered products
- `all_products_screen.dart` - All products grid
- `product_detail_screen.dart` - Single product details
- `category_navigation_screen.dart` - Category-based filtering
- `medicine_order_screen.dart` - Pharmacy ordering
  - Form fields: Phone, Address, Medicine list
  - Type: DropdownButtonFormField for quantity

#### Shopping & Checkout
- `cart_screen.dart` - Shopping cart view
  - States: Subtotal, Delivery fee, Discount, Points discount, Total
  - Bottom sheet: CheckoutBottomSheet
  - Features: Cart items list, order summary

- **Checkout BottomSheet:** `lib/src/features/cart/widgets/checkout_bottom_sheet.dart`
  - Payment method selection
  - Delivery address
  - Coupon application
  - Place order action

- **Commerce Module:** `lib/src/features/commerce/checkout_bottom_sheet.dart`
  - Alternative checkout implementation

#### Orders & Delivery
- `orders_screen.dart` - User's orders
  - Features: Status filtering (All, Pending, Delivered, Cancelled)
  - Displays: Order date, items, status, total
  
- `order_details_screen.dart` - Order full view
- `order_tracking_screen.dart` - Real-time rider tracking
  - Parameters: orderId, riderUid
  - Features: Live location, ETA, rider contact

- `emergency_details_screen.dart` - Emergency service access
  - Form fields: Medicine, Hospital, Bags needed
  - Features: Quick emergency dispatch

#### Wishlist & Comparison
- `wishlist_screen.dart` - Saved favorite products
- State: `wishlistProvider` (List<String> of product IDs)

#### Search & Filter
- `search_screen.dart` - Full-text product search
  - Parameters: query, action
  - Features: Search history, category filter

#### Communication
- `chat_screen.dart` - Live support chat
  - Features: Message moderation, sensitive info detection
  - Content filtering: Phone numbers, emails, spam links
  
- `private_chat_screen.dart` - One-on-one chat
  - Parameters: chatId, name, isStaff, receiverId
  - Features: Staff support routing

- `chat_history_list_screen.dart` - Chat history

#### User Profile & Settings
- `profile_screen.dart` - User dashboard
  - Display: User info, avatar, role badge, points balance
  - Actions: Orders, Wishlist, Wallet, Edit profile, Settings
  - Role-specific options: Reseller, Rider, Staff actions

- `edit_profile_screen.dart` - Update user info
  - Fields: Name, Phone, Email
  - Controllers: _nameCtrl, _phoneCtrl, _emailCtrl

- `info_screen.dart` - Dynamic FAQ/Info pages
  - Supports: HTML content, Bilingual (Bengali/English)
  - Fetches: Content from Firestore path

- `how_to_use_screen.dart` - App usage guide
- `wallet_screen.dart` - Wallet & transactions
- `backup_screen.dart` - Data backup management

- `application_form_screen.dart` - Role applications
  - Form: Name, Phone, Address, Experience
  - Parameters linked to role (reseller, rider, staff)
  - Global form key validation

#### Location & Navigation
- Staff screens: `rider_application_screen.dart`, `staff_application_screen.dart`
- Reseller/Logistics: `reseller_application_screen.dart`
- Notifications: `notification_screen.dart`

### Customer Router Configuration
**File:** `src/utils/router_customer.dart`

**Routes:**
```
/ → MainScreen (home)
/login → LoginScreen
/signup → SignupScreen
/forgot-password → ForgotPasswordScreen
/medicine-order → MedicineOrderScreen
/emergency → EmergencyDetailsScreen
/orders → OrdersScreen
/wishlist → WishlistScreen
/cart → CartScreen
/chat → ChatScreen
/chat-history → ChatHistoryListScreen
/wallet → WalletScreen
/backup → BackupScreen
/edit-profile → EditProfileScreen
/notifications → NotificationScreen
/how-to-use → HowToUseScreen
/apply?role={reseller|rider|staff} → ApplicationFormScreen
/search?q={query}&action={action} → SearchScreen
/private-chat?chatId={id}&name={name}&isStaff={bool}&receiverId={id}
/order-tracking?orderId={id}&riderUid={uid}
/categories/:id?name={name} → CategoryNavigationScreen
/products/:category → ProductListScreen
/product-details?productId={id} → ProductDetailScreen
```

**Authentication Flow:**
- Redirect to `/login` if not logged in and accessing protected routes
- Redirect to `/` if logged in and accessing auth pages
- Role validation: customer, admin, reseller

---

## 3. ADMIN APP - SCREENS & FEATURES

### Main Admin Screen
**File:** `lib/src/features/admin/admin_screen.dart`

**Architecture:** Nested TabBar system with 5 main tabs

**Main Tabs (TabController length: 5):**
1. **DASHBOARD** - Overview & analytics
2. **COMMERCE** - Orders, catalog, logistics
3. **PEOPLE** - Teams, accounts, resellers, support
4. **INTELLIGENCE** - AI systems, database, health checks
5. **SYSTEM** - Settings, localization, fleet monitoring

### Admin Tabs Details

#### 1. DASHBOARD Hub (Nested Tabs: 2)
**Sub-tabs:**
- **OVERVIEW**
  - Widget: InventoryForecastingWidget
  - Quick Action Grid:
    - Orders Manager
    - Catalog Manager
    - AI Master Console
    - User Support

- **ANALYTICS**
  - Widget: AnalyticsTab
  - Features: Charts, metrics display

#### 2. COMMERCE Hub (Nested Tabs: 3)
**Sub-tabs:**
- **ORDERS**
  - Widget: OrdersTab
  - Components:
    - Time filter (Today/All-time)
    - Nested tabs: Regular Orders, Emergency Orders
    - Order cards with status filtering
    - Emergency tab: EmergencyTab widget

- **CATALOG**
  - Widget: CatalogTab (with isAdmin flag)
  - Features: Product management, category CRUD

- **LOGISTICS**
  - Widget: LogisticsTab
  - Features: Delivery zone management, rider assignments

#### 3. PEOPLE Hub (Nested Tabs: 4)
**Sub-tabs:**
- **TEAMS**
  - Widget: HrTeamsTab
  - Features: Staff management, team structure

- **ACCOUNTS**
  - Widget: AccountsTab
  - Sub-components:
    - AccountsCommissionsTab
    - Commissions tracking

- **RESELLERS**
  - Widget: ResellerApplicationsTab
  - Features: Approve/reject reseller applications

- **CHATS**
  - Widget: InteractionsTab
  - Features: Chat management, moderation

#### 4. INTELLIGENCE Hub (Nested Tabs: 4)
**Sub-tabs:**
- **AI MASTER**
  - Widget: AiMasterTab
  - Features: AI model management, automation control

- **DATABASE**
  - Widget: _buildGroupedDatabaseHub()
  - Features: Database schema, backups, seeding

- **AI HEALTH**
  - Widget: SystemHealthTab
  - Components:
    - System status monitoring
    - Health check metrics
    - Sub-tabs: AiHealthTab, AiAuditTab, AiNotificationsTab

- **VIRTUAL LAB**
  - Widget: VirtualDataLab
  - Features: Testing environment, data simulation

#### 5. SYSTEM Hub (Nested Tabs: 3)
**Sub-tabs:**
- **SETTINGS**
  - Widget: SettingsTab
  - Features: General app configuration
  - Sub-components:
    - OperationsTab
    - DeviceRequestsTab
    - StaffSecurityTab
    - StaffManagementTab
    - FeedbackTab
    - MarketingHubTab

- **LANG** (Localization)
  - Widget: LocalizationTab
  - Features: String translations, language management
  - Remote source: Firestore `localization/strings`

- **FLEET**
  - Status: Fleet & Shorebird monitoring
  - Features: Deployment tracking

### Additional Admin Widgets

**Inventory & Product Management:**
- `inventory_forecasting_widget.dart` - Demand prediction
- `inventory_tab.dart` - Stock management
- `inventory_item_tile.dart` - Item display
- `csv_import_sheet.dart` - Bulk import

**Category Management:**
- `category_tab.dart` - Category list
- `category_form_sheet.dart` - Category CRUD
- `category_tile.dart` - Category display

**Marketing:**
- `marketing_tab.dart` - Campaign management
- `marketing_hub_tab.dart` - Marketing dashboard
- `marketing_tab_simple.dart` - Simplified view
- `notice_management_tab.dart` - Notice/banner management

**Modals:**
- `custom_notification_sheet.dart` - Send notifications
- `product_form_sheet.dart` - Product editor

**Database & Audit:**
- `database_tab.dart` - Database inspector
- `ai_master_tab.dart` - AI management
- `ai_audit_tab.dart` - Audit logs
- `ai_notifications_tab.dart` - AI alerts

**Other Tabs:**
- `shops_tab.dart` - Store management
- `teams_tab.dart` - Team structure
- `delivery_zone_tab.dart` - Delivery zones
- `device_requests_tab.dart` - Device approvals
- `commerce_hub_tab.dart` - Commerce overview
- `chat_management_tab.dart` - Chat moderation/support
- `analytics_tab.dart` - Analytics dashboard
- `system_health_tab.dart` - System status
- `feedback_tab.dart` - User feedback review

### Admin Router Configuration
**File:** `src/utils/router_admin.dart`

**Routes:**
```
/ → AdminScreen (if admin) or ResellerScreen (if reseller)
/login → LoginScreen
/chat → ChatScreen
/notifications → NotificationScreen
/how-to-use → HowToUseScreen
```

**Role-based Access:**
- Admin/Staff allowed
- Reseller redirected to ResellerScreen
- Customer users logged out

### Reseller Dashboard
**File:** `lib/src/features/reseller/reseller_screen.dart`

- Currently minimal implementation
- Future: Reseller-specific sales dashboard, order management

---

## 4. SHARED NAVIGATION & ROUTING STRUCTURE

### Router Configuration Files
1. **`router_customer.dart`** - Customer app routes
   - 19 main routes
   - Dynamic parameters: productId, categoryId, orderId, riderUid, chatId
   - Query string parsing for filters and metadata

2. **`router_admin.dart`** - Admin app routes
   - 4 main routes
   - Role-based initial destination
   - Automatic logout for invalid roles

### Global Navigation State
**File:** `src/services/nav_provider.dart`

```dart
navProvider - StateNotifier<int>
```
- Tracks current bottom navigation index (0-4)
- Used by MainScreen for IndexedStack switching
- Persists across navigation

### Deep Link Support
- Dynamic parameters passed via `state.uri.queryParameters`
- Path parameters via `state.pathParameters`
- Examples:
  - `/categories/:id?name=Electronics`
  - `/product-details?productId=abc123`
  - `/private-chat?chatId=xyz&receiverId=123`

---

## 5. BOTTOM NAVIGATION & TAB STRUCTURES

### Customer App - Bottom Navigation
**Component:** NavigationBar (Material 3)

| Index | Label | Icon | Screen |
|-------|-------|------|--------|
| 0 | Home | Icons.home | HomeScreen |
| 1 | Emergency | Icons.emergency | EmergencyDetailsScreen |
| 2 | Products | Icons.grid_view | AllProductsScreen |
| 3 | Rewards | Icons.card_giftcard | RewardsScreen |
| 4 | Profile | Icons.person | ProfileScreen |

### Admin App - Tab Systems

**Level 1: Main Tabs (5)**
- Dashboard, Commerce, People, Intelligence, System

**Level 2: Nested Tabs (2-4 per main tab)**
- Each main tab has a DefaultTabController with dynamic tab count
- Horizontal tabs with scroll support for long tab lists

**Tab Styling:**
- Primary color indicators
- Icon + text labels
- Custom font weights and sizes
- Scrollable for overflow

---

## 6. DIALOG & MODAL COMPONENTS

### Dialog Components
1. **ForgotPasswordDialog** (`auth/forgot_password_dialog.dart`)
   - Modal password reset
   - Email/phone input
   - Verification code handling

2. **_RateLimitDialog** (AI admin dashboard)
   - Configuration : Limit settings

3. **_CacheConfigDialog** (AI admin dashboard)
   - Cache strategy configuration

4. **_ModelConfigDialog** (AI admin dashboard)
   - AI model parameter settings

5. **RewardPopup** (home_screen.dart)
   - Trigger: Points earned
   - Display: Badge animation, points value, dismissible

### Bottom Sheets
1. **CheckoutBottomSheet** (`cart/widgets/checkout_bottom_sheet.dart`)
   - Height: ~70% screen
   - Components:
     - Shipping address selector
     - Payment method selector
     - Coupon code input
     - Order summary
     - Place order button
   - State: Order processing status

2. **CheckoutBottomSheet** (`commerce/checkout_bottom_sheet.dart`)
   - Alternative implementation
   - Components: Similar to cart version

3. **AddressFormSheet** (`profile/widgets/address_form_sheet.dart`)
   - Address CRUD
   - Input: address details
   - Controller: _details (TextEditingController)

4. **ProductFormSheet** (`admin/widgets/product_form_sheet.dart`)
   - Product editor
   - Admin only
   - Multi-field form

5. **CategoryFormSheet** (`admin/widgets/categories/category_form_sheet.dart`)
   - Category CRUD
   - Admin only

6. **CSVImportSheet** (`admin/widgets/inventory/csv_import_sheet.dart`)
   - Bulk inventory import
   - File picker integration

7. **CustomNotificationSheet** (`admin/widgets/custom_notification_sheet.dart`)
   - Send admin notifications
   - Target user selection
   - Message composition

---

## 7. FORM SCREENS & INPUT WIDGETS

### Form Screens

#### ApplicationFormScreen
- **Path:** `profile/application_form_screen.dart`
- **Purpose:** Apply for roles (reseller, rider, staff, donor)
- **Form Key:** `_formKey: GlobalKey<FormState>()`
- **Fields:**
  - Name (TextFormField) → _nameCtrl
  - Phone (TextFormField) → _phoneCtrl
  - Address (TextFormField) → _addressCtrl
  - Experience (TextFormField) → _expCtrl
- **Validation:** Custom validators for each field
- **Submit:** Form submission with success callback

#### MedicineOrderScreen
- **Path:** `products/medicine_order_screen.dart`
- **Purpose:** Pharmacy prescription ordering
- **Form Key:** `_formKey: GlobalKey<FormState>()`
- **Fields:**
  - Phone (TextFormField) → _phoneController
  - Address (TextFormField) → _addressController
  - Medicine list (TextFormField) → _medicineListController
  - Quantity (DropdownButtonFormField) - hardcoded options
- **Features:** Image upload for prescription

#### EmergencyDetailsScreen
- **Path:** `orders/emergency_details_screen.dart`
- **Purpose:** Emergency/special service request
- **Controllers:**
  - _medicineController (TextEditingController)
  - _hospitalController (TextEditingController)
  - _bagsController (TextEditingController)
- **Input Type:** TextFormField with validation

#### EditProfileScreen
- **Path:** `profile/edit_profile_screen.dart`
- **Purpose:** User information update
- **Controllers:**
  - _nameCtrl (TextEditingController)
  - _phoneCtrl (TextEditingController)
  - _emailCtrl (TextEditingController)

#### SearchScreen
- **Path:** `search/search_screen.dart`
- **Purpose:** Product search with filters
- **Controller:** _controller (TextEditingController)
- **Initial Query:** From route parameter
- **Features:** Filter by category, sort options

##### Input Widget Patterns

**TextFormField Usage:**
- Icon prefix/suffix
- Validation callbacks
- Input type specification (TextInputType.phone, email, etc.)
- Max lines configuration
- Hint text

**Custom Field Builder:**
- Reusable _buildField() method
- Parameters: label, controller, icon, inputType, maxLines
- Styling: Consistent app theme

---

## 8. AUTHENTICATION & LOGIN FLOWS

### LoginScreen Flow
**File:** `auth/login_screen.dart`

**Flow:**
1. User enters ID (phone/email) and password
2. Optional: Toggle between phone/email login
3. Optional: Remember credentials checkbox
4. Firebase Auth signIn via AuthService
5. Redirect to home on success / Show error on failure

**Persistence:**
- SharedPreferences for credential storage
- _loadSavedCredentials() on init
- _saveCredentials() on successful login

**Fields:**
- ID controller: _idCtrl (TextEditingController)
- Password controller: _passCtrl (TextEditingController)
- Toggle states: _isPhoneLogin, _rememberMe, _obscurePassword

**Features:**
- Password visibility toggle
- Admin/Customer app detection
- Validation: Non-empty required

### SignupScreen Flow
**File:** `auth/signup_screen.dart`

**Flow:**
1. User enters: Name, Phone, Email (optional), Password, Referral code
2. Select: District, Upazila, Blood group
3. Option: Register as blood donor
4. Firebase Auth via AuthService
5. Additional profile setup in Firestore
6. Loyalty points awarded

**Multi-step Fields:**
- Text inputs: _nameCtrl, _phoneCtrl, _emailCtrl, _passCtrl, _refCtrl, _bloodPhoneCtrl
- Dropdowns: _selectedDistrict, _selectedUpazila, _selectedBloodGroup
- Checkbox: _isBloodDonor
- Blood groups: A+, A-, B+, B-, O+, O-, AB+, AB-

**Post-signup Actions:**
- Update profile with geo location (district, upazila)
- Register blood donor record if applicable
- Award welcome bonus points via loyaltyService
- Redirect to home

### ForgotPasswordScreen / Dialog
**File:** `auth/forgot_password_screen.dart`, `forgot_password_dialog.dart`

**Flow:**
1. Enter email/phone
2. Receive verification code
3. Enter new password
4. Confirm and update

---

## 9. MAIN COMPONENTS & KEY WIDGETS

### Shared Components

#### Home Screen Widgets
**File:** `home/widgets/`

1. **GreetingWidget** - User greeting with time-based message
2. **NoticeSlider** - Notice/banner carousel (PageView)
3. **HomeWidgets:**
   - BannerSlider - Image carousel
   - SectionHeader - Section title with "View All" link
   - ProductHorizontalList - Scrollable product list
   - ProductGridView - Grid display

4. **CategorySidebar** - Category navigation menu
5. **CouponListScreen** - Available coupon codes
6. **FlashSaleTimer** - Countdown timer for sales
7. **LoyaltyStatusCard** - Points and loyalty display
8. **QiblaIndicator** - Islamic compass (prayer direction)
9. **FloatingCartBar** - Floating cart button

#### Product & Cart Components
**File:** `products/widgets/product_widgets.dart`

- Product cards with images, price, rating
- Add to cart/wishlist buttons
- Quantity picker

**File:** `cart/widgets/checkout_bottom_sheet.dart`

- Cart item list
- Price breakdown
- Payment method selector

#### Profile Components
**File:** `profile/widgets/address_form_sheet.dart`

- AddressFormSheet - Add/edit delivery address
- Address forms with details input

#### Admin Components

**Inventory:**
- InventoryItemTile - Stock display
- CSVImportSheet - Bulk upload
- InventoryForecastingWidget - AI predictions

**Categories:**
- CategoryTile - Category display
- CategoryFormSheet - Category editor

**Orders:**
- OrderCard - Order summary display

#### Chat Components
**File:** `chat_screen.dart`, `private_chat_screen.dart`

- Message bubbles
- Timestamp display
- Send button
- Message history scroll

---

## 10. STATE MANAGEMENT & PROVIDERS

### Riverpod Providers
**File:** `di/providers.dart`

#### Navigation & UI
```dart
navProvider // Current bottom nav index
languageProvider // Language (English/Bengali)
themeProvider // Dark/Light mode
```

#### Firebase & Data Streams
```dart
authStateProvider // FirebaseAuth state
currentUserDataProvider // Current user data stream
actualUserDataProvider // Alias for currentUserData
allUsersProvider // All users stream
productsProvider // All products stream
categoriesProvider // Categories stream
storesProvider // Stores stream (ordered)
ordersProvider // Orders stream (desc by date)
locationsProvider // Locations stream
promoProvider // Promotions stream
```

#### Business Logic
```dart
cartProvider // Shopping cart state
cartSubtotalProvider // Cart calculations
cartDeliveryFeeProvider
cartDiscountProvider
cartPointsDiscountProvider
cartTotalProvider
wishlistProvider // Wishlist IDs
```

#### Services (Singleton)
```dart
firestoreService / firestoreServiceProvider
authServiceProvider / authProvider
aiServiceProvider
loyaltyServiceProvider
notificationServiceProvider
locationServiceProvider
deliveryServiceProvider
forecastingServiceProvider
apiQuotaServiceProvider
aiAutomationProvider
updateServiceProvider
syncServiceProvider
noticeServiceProvider
autoTranslationProvider
chatServiceProvider
healthCheckProvider
aiStatusProvider
monthlyTopBuyersProvider
heroRecordsProvider
```

#### Admin-specific
```dart
allCommissionsProvider // Commissions list
groupedAiAuditProvider // AI audit analytics
aiAuditLogsProvider // Audit log stream
apiQuotaStreamProvider // API quota tracking
appConfigProvider / appSettingsProvider // App config
loyaltySettingsProvider // Loyalty settings
remoteLocalizationProvider // Translation strings
```

---

## 11. MODELS & DATA STRUCTURES

### Core Models
**File:** `models/`

1. **ProductModel** - Product entity
2. **UserModel** - User profile
3. **MasterModels** - Core entity definitions
4. **BackupModel** - Backup data structure
5. **BloodDonorModel** - Blood donor registry
6. **DoctorModel** - Healthcare provider
7. **ReviewModel** - Product reviews

### Cart Model
**File:** `features/commerce/domain/cart_model.dart`

```dart
CartModel {
  items: List<CartItem>
}
CartItem {
  productId, quantity, price
}
```

### Stream Models
Data fetched as `Map<String, dynamic>` from Firestore with `id` field

---

## 12. KEY SERVICES & UTILITIES

### Service Classes
**Location:** `services/`, `core/firebase/`, `features/*/services/`

**Core Services:**
- **FirestoreService** - Database operations
- **AuthService** - Authentication
- **LocationService** - Geolocation
- **NotificationService** - Push notifications
- **UpdateService** - App version checking
- **HealthCheckService** - System diagnostics

**Business Services:**
- **LoyaltyService** - Points, rewards
- **DeliveryService** - Logistics
- **AIService** - AI model interactions
- **ApiQuotaService** - Rate limiting
- **AiAutomationService** - Automation workflows

**Background/Sync:**
- **BackupService** - Data backup (background task)
- **SyncService** - Data synchronization
- **NoticeService** - Notice management
- **AutoTranslationService** - Language translation
- **ChatService** - Messaging

### Utility Files
**File:** `utils/`

- **router_customer.dart** - Customer routing
- **router_admin.dart** - Admin routing
- **styles.dart** - App theme (colors, typography)
- **app_strings.dart** - Localizable strings
- **error_handler.dart** - Error display
- **version_utils.dart** - Version management
- **globals.dart** - Global state (navigatorKey)
- **update_dialog.dart** - App update prompts
- **touch_glow_overlay.dart** - UI effects

---

## 13. AUTHENTICATION FLOWS - DETAILED

### Customer Login Path
```
LoginScreen
  ↓ (UI input)
AuthService.signIn(email/phone, password)
  ↓ (Firebase Auth)
currentUserDataProvider (stream update)
  ↓ (Redirect logic)
MainScreen or re-show LoginScreen
```

### Customer Signup Path
```
SignupScreen
  ↓ (UI input + selections)
AuthService.signUp(name, phone, email, password)
  ↓ (Create Firebase account)
FirestoreService.updateProfile(uid, {district, upazila, bloodGroup, isBloodDonor})
  ↓ (Store metadata)
LoyaltyService.addPoints(uid, 'signupPoints')
  ↓ (Award bonus)
FirestoreService.registerAsDonor() [if donor]
  ↓ (Optional)
MainScreen
```

### Admin Login Path
```
LoginScreen (from admin app)
  ↓ (UI input)
AuthService.signIn(email/phone, password)
  ↓ (Firebase Auth)
roleValidation: role must be 'admin' or 'staff'
  ↓ (Check actualUserDataProvider)
AdminScreen (if admin) or ResellerScreen (if reseller)
  ↓
Auto-logout if customer role
```

---

## 14. DIRECTORY STRUCTURE SUMMARY

```
lib/
├── main_customer.dart (Entry point)
├── main_admin.dart (Entry point)
├── firebase_options.dart
│
├── src/
│   ├── core/
│   │   ├── base/
│   │   ├── constants/
│   │   ├── di/
│   │   ├── exceptions/
│   │   ├── firebase/
│   │   └── services/
│   │
│   ├── di/
│   │   ├── providers.dart (State management hub)
│   │   ├── service_initializer.dart
│   │   └── service_locator.dart
│   │
│   ├── data/
│   │   └── dummy_products.dart
│   │
│   ├── models/
│   │   ├── product_model.dart
│   │   ├── user_model.dart
│   │   └── *.dart
│   │
│   ├── services/
│   │   ├── nav_provider.dart
│   │   ├── language_provider.dart
│   │   ├── theme_provider.dart
│   │   ├── backup_service.dart
│   │   ├── chat_service.dart
│   │   └── *.dart
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── app_image.dart
│   │   │   └── floating_cart_bar.dart
│   │   └── services/
│   │
│   ├── utils/
│   │   ├── router_customer.dart
│   │   ├── router_admin.dart
│   │   ├── styles.dart
│   │   ├── app_strings.dart
│   │   └── *.dart
│   │
│   └── features/
│       ├── main_screen.dart
│       │
│       ├── admin/
│       │   ├── admin_screen.dart
│       │   ├── admin_utils.dart
│       │   ├── rider_tracker_screen.dart
│       │   └── widgets/ (40+ admin tabs/components)
│       │
│       ├── auth/
│       │   ├── login_screen.dart
│       │   ├── signup_screen.dart
│       │   ├── forgot_password_screen.dart
│       │   ├── forgot_password_dialog.dart
│       │   ├── providers/
│       │   └── services/
│       │
│       ├── home/
│       │   ├── home_screen.dart
│       │   ├── rewards_screen.dart
│       │   ├── bonus_cashback_screen.dart
│       │   └── widgets/ (9 widgets)
│       │
│       ├── products/
│       │   ├── product_list_screen.dart
│       │   ├── product_detail_screen.dart
│       │   ├── all_products_screen.dart
│       │   ├── medicine_order_screen.dart
│       │   ├── category_navigation_screen.dart
│       │   └── widgets/
│       │
│       ├── cart/
│       │   ├── cart_screen.dart
│       │   └── widgets/
│       │       └── checkout_bottom_sheet.dart
│       │
│       ├── orders/
│       │   ├── orders_screen.dart
│       │   ├── order_details_screen.dart
│       │   ├── order_tracking_screen.dart
│       │   └── emergency_details_screen.dart
│       │
│       ├── profile/
│       │   ├── profile_screen.dart
│       │   ├── edit_profile_screen.dart
│       │   ├── application_form_screen.dart
│       │   ├── wallet_screen.dart
│       │   ├── backup_screen.dart
│       │   ├── how_to_use_screen.dart
│       │   ├── info_screen.dart
│       │   └── widgets/
│       │
│       ├── chat/
│       │   ├── chat_screen.dart
│       │   ├── private_chat_screen.dart
│       │   └── chat_history_list_screen.dart
│       │
│       ├── wishlist/
│       │   ├── wishlist_screen.dart
│       │   └── services/
│       │
│       ├── search/
│       │   └── search_screen.dart
│       │
│       ├── notifications/
│       │   └── notification_screen.dart
│       │
│       ├── reseller/
│       │   ├── reseller_screen.dart
│       │   └── reseller_application_screen.dart
│       │
│       ├── staff/
│       │   ├── staff_screen.dart
│       │   ├── staff_team_screen.dart
│       │   ├── staff_application_screen.dart
│       │   └── rider_application_screen.dart
│       │
│       ├── delivery/
│       │   └── delivery_dashboard_screen.dart
│       │
│       ├── shop/
│       │   └── all_products_screen.dart
│       │
│       ├── commerce/
│       │   ├── checkout_bottom_sheet.dart
│       │   ├── domain/
│       │   ├── providers/
│       │   └── services/
│       │
│       ├── logistics/
│       │   ├── logistics_domain.dart
│       │   └── services/
│       │
│       ├── qibla/
│       │   └── services/
│       │
│       ├── healthcare/
│       │   └── services/
│       │
│       ├── ai/
│       │   ├── config/
│       │   ├── domain/
│       │   ├── presentation/
│       │   └── services/
│       │
│       └── archived_redundant/
│
└── core/ (shared core logic)
```

---

## 15. NAVIGATION SUMMARY TABLE

| Screen | File | Type | Navigation |
|--------|------|------|-----------|
| Home | home_screen.dart | Bottom nav (0) | / |
| Emergency | emergency_details_screen.dart | Bottom nav (1) | /emergency |
| Products | all_products_screen.dart | Bottom nav (2) | /products |
| Rewards | rewards_screen.dart | Bottom nav (3) | /rewards |
| Profile | profile_screen.dart | Bottom nav (4) | / |
| Login | login_screen.dart | Auth | /login |
| Signup | signup_screen.dart | Auth | /signup |
| Cart | cart_screen.dart | Modal | /cart |
| Wishlist | wishlist_screen.dart | Modal | /wishlist |
| Orders | orders_screen.dart | Modal | /orders |
| Chat | chat_screen.dart | Modal | /chat |
| Search | search_screen.dart | Modal | /search |
| Admin | admin_screen.dart | Tabbed | / (admin app) |
| Reseller | reseller_screen.dart | Dashboard | / (reseller role) |

---

## 16. KEY INSIGHTS & PATTERNS

### Architecture Patterns
1. **Nested Tab System**: Admin screen uses multiple TabControllers for hierarchical navigation
2. **IndexedStack**: MainScreen uses IndexedStack for efficient bottom nav switching
3. **Stream-based Data**: Most data fetched via Riverpod StreamProviders from Firestore
4. **Service Locator**: Uses GetIt for singleton service injection
5. **Role-based Rendering**: Same sections render differently based on user role

### State Management
- **Riverpod**: Primary state management library
- **StateNotifier**: For mutable state (cart, navigation)
- **StreamProvider**: For Firestore real-time data
- **FutureProvider**: For one-time async operations
- **watch()**: For reactive UI updates

### UI Component Patterns
- **Bottom Sheets**: For secondary actions (checkout, address entry)
- **Dialogs**: For auth & critical confirmations
- **TabBars**: For categorized content
- **IndexedStack**: For efficient screen switching
- **PageView**: For carousel displays (banners, stories)

### Authentication & Authorization
- Firebase Auth with email/phone + password
- Role-based access control (customer, admin, staff, reseller, rider)
- Persistent credentials with SharedPreferences
- Automatic logout for invalid roles
- Deep linking support for external routes

### Localization
- English and Bengali support
- AppStrings.get(key, languageCode)
- HTML content support for dynamic text
- Remote string management via Firestore

---

## 17. CRITICAL FEATURES NOTED

### Customer App Special Features
- **Blood Donor Registry**: Optional signup feature
- **Points/Loyalty System**: Earned on signup, purchases, referrals
- **AI-powered Search**: Product discovery
- **Geolocated Delivery**: District/Upazila selection during signup
- **Emergency Services**: One-click emergency ordering
- **Live Order Tracking**: Real-time rider location
- **Wallet/Backup**: Data persistence features
- **Prayer Compass**: Qibla direction indicator
- **Chat Moderation**: Sensitive info detection

### Admin App Advanced Features
- **Inventory Forecasting**: AI-driven predictions
- **AI Master Console**: Model management & automation
- **Database Inspector**: Live Firestore monitoring
- **Multi-level Analytics**: Dashboard, charts, metrics
- **CSV Import/Export**: Bulk operations
- **Nested Tab Navigation**: Complex UI hierarchy
- **System Health Dashboard**: Real-time monitoring
- **Virtual Lab**: Testing environment
- **Fleet Shorebird Monitoring**: Deployment tracking

---

## CONCLUSION

Paykari Bazar is a comprehensive e-commerce platform with:
- **Dual App Architecture**: Separated but interconnected customer and admin applications
- **Complex Admin Dashboard**: 5 main hubs with 25+ nested management tabs
- **Role-based Access**: 5+ user roles with specialized screens
- **Real-time Sync**: Firestore-driven state management
- **Multilingual Support**: Bengali/English with remote localization
- **Advanced Features**: AI, loyalty, delivery tracking, emergency services
- **Modern UI Patterns**: Material 3, nested navigation, stream-based rendering

The architecture supports scalability, maintainability, and feature-rich functionality across customer, admin, reseller, and delivery partner tiers.

---

**Generated by:** App Structure Analyzer  
**Analysis Scope:** Complete lib/ directory traversal  
**Screens Catalogued:** 50+ customer/delivery screens, 15+ admin section tabs  
**Routes Mapped:** 23 customer routes, 4 admin routes  
**Components Identified:** 50+ widgets/components, 8+ dialog types
