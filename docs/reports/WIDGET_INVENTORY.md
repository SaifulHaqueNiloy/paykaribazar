# Paykari Bazar - Complete Widget Inventory

**Generated:** March 26, 2026  
**Total Widgets:** 75 (7 tested, 68 untested)

---

## TESTED WIDGETS (7/75)

### ✅ From `test/widgets/home_widgets_test.dart`
| Widget | Type | File | Status |
|--------|------|------|--------|
| BannerSlider | StatelessWidget | home/widgets/home_widgets.dart | ✅ TESTED |
| SectionHeader | StatelessWidget | home/widgets/home_widgets.dart | ✅ TESTED |
| ProductHorizontalList | StatelessWidget | home/widgets/home_widgets.dart | ✅ TESTED |
| ProductCard | ConsumerWidget | home/widgets/home_widgets.dart | ✅ TESTED |
| StaticSearchBar | StatelessWidget | home/widgets/home_widgets.dart | ✅ TESTED |
| StickyHeader | StatelessWidget | home/widgets/home_widgets.dart | ✅ TESTED |

### ✅ From `test/widgets/flash_sale_timer_test.dart`
| Widget | Type | File | Status |
|--------|------|------|--------|
| FlashSaleTimer | StatefulWidget | home/widgets/flash_sale_timer.dart | ✅ TESTED |

---

## UNTESTED WIDGETS (68/75)

### HOME FEATURE WIDGETS (8 untested)
**Location:** `lib/src/features/home/widgets/`

| # | Widget | Type | File | Notes |
|---|--------|------|------|-------|
| 1 | HomeAppBar | ConsumerWidget | home_app_bar.dart | PreferredSizeWidget, renders top nav bar |
| 2 | GreetingWidget | ConsumerStatefulWidget | greeting_widget.dart | User greeting + animation |
| 3 | FloatingCartBar | ConsumerWidget | floating_cart_bar.dart | Floating action bar (price + cart) |
| 4 | NoticeSlider | ConsumerWidget | notice_slider.dart | Scrollable notices/alerts |
| 5 | LoyaltyStatusCard | ConsumerWidget | loyalty_status_card.dart | Loyalty points display |
| 6 | CategorySidebar | ConsumerStatefulWidget | category_sidebar.dart | Category filter sidebar |
| 7 | CategoryChips | ConsumerWidget | category_chips.dart | Category filter chips |
| 8 | CouponListScreen | ConsumerWidget | coupon_list_screen.dart | Coupon listing/selection |
| 9 | QiblaIndicator | StatefulWidget | qibla_indicator.dart | Islamic compass direction |

### CART FEATURE WIDGETS (1 untested - CRITICAL)
**Location:** `lib/src/features/cart/widgets/`

| # | Widget | Type | File | Notes |
|---|--------|------|------|-------|
| 10 | **CheckoutBottomSheet** | ConsumerStatefulWidget | checkout_bottom_sheet.dart | **CRITICAL** - Payment form, tax calc, address picker, coupon validation |

### PRODUCTS FEATURE WIDGETS (2+ untested)
**Location:** `lib/src/features/products/widgets/`

| # | Widget | Type | File | Notes |
|---|--------|------|------|-------|
| 11 | ProductCard variants | ConsumerWidget | product_widgets.dart | Multiple variants for cart/list views |
| 12+ | Product filters | StatelessWidget | product_widgets.dart | Price range, category, rating filters |

### PROFILE FEATURE WIDGETS (1 untested)
**Location:** `lib/src/features/profile/widgets/`

| # | Widget | Type | File | Notes |
|---|--------|------|------|-------|
| 13 | AddressFormSheet | ConsumerStatefulWidget | address_form_sheet.dart | Address CRUD (add/edit/delete) |

### SHARED/COMMON WIDGETS (2 untested)
**Location:** `lib/src/shared/widgets/`

| # | Widget | Type | File | Notes |
|---|--------|------|------|-------|
| 14 | FloatingCartBar (shared) | ConsumerWidget | floating_cart_bar.dart | Reusable floating action bar |
| 15 | AppImage | Widget | app_image.dart | Cached image loader with validation |

---

## SCREEN PAGES (20 untested - PRIMARY APP FLOW)

### COMMERCE FLOW SCREENS (6 untested)
**Location:** `lib/src/features/products/` and `lib/src/features/orders/`

| # | Screen | Type | File | Purpose |
|---|--------|------|------|---------|
| 16 | ProductDetailScreen | ConsumerStatefulWidget | product_detail_screen.dart | Product view (images, variants, reviews, pricing) |
| 17 | ProductListScreen | ConsumerStatefulWidget | product_list_screen.dart | Category product grid |
| 18 | AllProductsScreen | ConsumerStatefulWidget | all_products_screen.dart | Full catalog (all categories) |
| 19 | MedicineOrderScreen | ConsumerStatefulWidget | medicine_order_screen.dart | Healthcare product ordering |
| 20 | CategoryNavigationScreen | StatelessWidget | category_navigation_screen.dart | Category selection before browsing |
| 21 | SearchScreen | ConsumerStatefulWidget | search_screen.dart | Product search + pagination + filtering |

### ORDER MANAGEMENT SCREENS (3 untested)
**Location:** `lib/src/features/orders/`

| # | Screen | Type | File | Purpose |
|---|--------|------|------|---------|
| 22 | OrdersScreen | ConsumerStatefulWidget | orders_screen.dart | Order history (user's orders) |
| 23 | OrderDetailsScreen | ConsumerWidget | order_details_screen.dart | Single order details + timeline |
| 24 | OrderTrackingScreen | ConsumerStatefulWidget | order_tracking_screen.dart | Real-time delivery tracking (geofencing) |

### USER PROFILE/ACCOUNT SCREENS (7 untested)
**Location:** `lib/src/features/profile/`

| # | Screen | Type | File | Purpose |
|---|--------|------|------|---------|
| 25 | ProfileScreen | ConsumerWidget | profile_screen.dart | User profile view + edit nav |
| 26 | EditProfileScreen | ConsumerStatefulWidget | edit_profile_screen.dart | User data editor (name, phone, photo) |
| 27 | WalletScreen | ConsumerWidget | wallet_screen.dart | User wallet balance + transaction history |
| 28 | BackupScreen | ConsumerStatefulWidget | backup_screen.dart | Backup/restore user data |
| 29 | ApplicationFormScreen | StatefulWidget | application_form_screen.dart | Staff/Reseller application form |
| 30 | HowToUseScreen | StatefulWidget | how_to_use_screen.dart | FAQ + tutorials (onboarding) |
| 31 | InfoScreen | ConsumerWidget | info_screen.dart | User info (legal, terms, settings) |

### MARKET/DISCOVERY SCREENS (4 untested)
**Location:** `lib/src/features/{wishlist, notifications, info, home}`

| # | Screen | Type | File | Purpose |
|---|--------|------|------|---------|
| 32 | WishlistScreen | ConsumerWidget | wishlist_screen.dart | Saved products (favorites) |
| 33 | NotificationScreen | ConsumerWidget | notification_screen.dart | Firebase message history |
| 34 | InfoScreen (info) | ConsumerWidget | info/info_screen.dart | App info + about |
| 35 | RewardsScreen | ConsumerStatefulWidget | home/rewards_screen.dart | Loyalty rewards + redemption |

### NAVIGATION/CORE SCREENS (1 untested)
**Location:** `lib/src/features/`

| # | Screen | Type | File | Purpose |
|---|--------|------|------|---------|
| 36 | HomeScreen | ConsumerStatefulWidget | home/home_screen.dart | **ENTRY POINT** - main app homepage |
| 37 | MainScreen | ConsumerStatefulWidget | main_screen.dart | **ORCHESTRATOR** - bottom nav routing |

### APPLICATION/ROLE SCREENS (5 untested)
**Location:** `lib/src/features/{staff, reseller}`

| # | Screen | Type | File | Purpose |
|---|--------|------|------|---------|
| 38 | StaffApplicationScreen | StatelessWidget | staff/staff_application_screen.dart | Staff job application form |
| 39 | RiderApplicationScreen | StatelessWidget | staff/rider_application_screen.dart | Delivery rider application form |
| 40 | StaffScreen | StatelessWidget | staff/staff_screen.dart | Staff info/dashboard |
| 41 | ResellerApplicationScreen | StatelessWidget | reseller/reseller_application_screen.dart | Reseller signup form |
| 42 | ResellerScreen | StatelessWidget | reseller/reseller_screen.dart | Reseller dashboard |

---

## ADMIN DASHBOARD WIDGETS (45+ untested - SECONDARY CARE)

### CORE ADMIN TABS (8 untested)
**Location:** `lib/src/features/admin/widgets/`

| # | Widget | Type | File | Purpose |
|---|--------|------|------|---------|
| 43 | CatalogTab | ConsumerWidget | catalog_tab.dart | Product browsing (admin view) |
| 44 | CategoryTab | ConsumerStatefulWidget | category_tab.dart | Category CRUD (add/edit/delete/order) |
| 45 | CommerceHubTab | ConsumerStatefulWidget | commerce_hub_tab.dart | Sales dashboard + order overview |
| 46 | OperationsTab | ConsumerStatefulWidget | operations_tab.dart | Operational settings + scheduling |
| 47 | OrdersTab | ConsumerStatefulWidget | orders_tab.dart | Admin order management + fulfillment |
| 48 | ShopsTab | ConsumerStatefulWidget | shops_tab.dart | Multi-shop management |
| 49 | AnalyticsTab | ConsumerStatefulWidget | analytics_tab.dart | Sales analytics + charts |
| 50 | InventoryTab | ConsumerStatefulWidget | inventory_tab.dart | Stock management + SKU tracking |

### ADMIN MANAGEMENT TABS (5 untested)
**Location:** `lib/src/features/admin/widgets/`

| # | Widget | Type | File | Purpose |
|---|--------|------|------|---------|
| 51 | StaffManagementTab | ConsumerWidget | staff_management_tab.dart | Staff list + permissions |
| 52 | TeamsTab | ConsumerStatefulWidget | teams_tab.dart | Team management + group permissions |
| 53 | ChatManagementTab | ConsumerStatefulWidget | chat_management_tab.dart | Message moderation + user support |
| 54 | AccountsTab | ConsumerStatefulWidget | accounts_tab.dart | User accounts + commission tracking |
| 55 | ResellerApplicationsTab | ConsumerStatefulWidget | reseller_applications_tab.dart | Reseller approval queue |

### ADMIN FEATURES/CONFIG (8+ untested)
**Location:** `lib/src/features/admin/widgets/`

| # | Widget | Type | File | Purpose |
|---|--------|------|------|---------|
| 56 | **AiMasterTab** | ConsumerStatefulWidget | ai_master_tab.dart | **1800 LOC** - Sovereign rules, virtual data, UI design lab |
| 57 | AiAuditTab | ConsumerStatefulWidget | ai_audit_tab.dart | AI request audit log + cost tracking |
| 58 | MarketingTab | ConsumerStatefulWidget | marketing_tab.dart | Campaign management + banners |
| 59 | SystemHealthTab | ConsumerWidget | system_health_tab.dart | Server health + API status |
| 60 | NoticeManagementTab | ConsumerStatefulWidget | notice_management_tab.dart | App-wide notices (banners) |
| 61 | LocalizationTab | ConsumerStatefulWidget | localization_tab.dart | Multi-language strings editor |
| 62 | StaffSecurityTab | ConsumerStatefulWidget | staff_security_tab.dart | 2FA + device management |
| 63 | DeviceRequestsTab | ConsumerWidget | device_requests_tab.dart | Device pairing requests (biometric) |

### ADMIN SETTINGS/AUXILIARY (5 untested)
| # | Widget | Type | File | Purpose |
|---|--------|------|------|---------|
| 64 | SettingsTab | ConsumerStatefulWidget | settings_tab.dart | Admin settings (email, notifications, etc) |
| 65 | DatabaseTab | StatefulWidget | database_tab.dart | Direct database viewer/editor |
| 66 | EmergencyTab | ConsumerStatefulWidget | emergency_tab.dart | SOS alerts + emergency contacts |
| 67 | AiNotificationsTab | ConsumerWidget | ai_notifications_tab.dart | Real-time AI event notifications |
| 68 | AccountsCommissionsTab | ConsumerWidget | accounts_commissions_tab.dart | Commission tracking + payouts |

### ADMIN FORM COMPONENTS (3+ untested)
**Location:** `lib/src/features/admin/widgets/`

| # | Widget | Type | File | Purpose |
|---|--------|------|------|---------|
| 69 | ProductFormSheet | ConsumerStatefulWidget | product_form_sheet.dart | Admin product editor (CRUD) |
| 70 | CustomNotificationSheet | ConsumerStatefulWidget | custom_notification_sheet.dart | Broadcast notification composer |
| 71 | CategoryFormSheet | ConsumerStatefulWidget | categories/category_form_sheet.dart | Category editor |
| 72 | DeliveryZoneTab | StatefulWidget | delivery_zone_tab.dart | Geofencing + zone mapping |

### ADMIN SUB-COMPONENTS (2+ untested)
**Location:** `lib/src/features/admin/widgets/{orders, categories}/`

| # | Widget | Type | File | Purpose |
|---|--------|------|------|---------|
| 73 | OrderCard | ConsumerStatefulWidget | orders/order_card.dart | Order card in admin list |
| 74 | CategoryTile | ConsumerWidget | categories/category_tile.dart | Category item in list |
| 75 | InventoryForecastingWidget | ConsumerWidget | inventory_forecasting_widget.dart | AI-powered stock prediction |

---

## WIDGET TESTING PRIORITY MATRIX

```
CRITICAL (Must Test First)
├─ CheckoutBottomSheet ★★★ (payment flow)
├─ ProductDetailScreen ★★★ (customer UX)
├─ HomeScreen ★★★ (entry point)
├─ ProductCard variants ★★★ (100+ instances)
└─ OrdersScreen ★★★ (order history)

HIGH (Feature Stability)
├─ HomeAppBar ★★ (navigation)
├─ CategoryTab (admin) ★★ (50+ categories)
├─ AiMasterTab (admin) ★★ (1800 LOC)
├─ EditProfileScreen ★★ (user data)
└─ OrderTrackingScreen ★★ (real-time)

MEDIUM (Infrastructure)
├─ SearchScreen ★ (pagination)
├─ WishlistScreen ★ (favorites)
├─ NotificationScreen ★ (messages)
└─ Admin forms ★ (CRUD ops)
```

---

## TEST COVERAGE BY FEATURE

| Feature | Screens | Widgets | Tested | % |
|---------|---------|---------|--------|-----|
| **Home** | 2 | 14 | 7 | 50% |
| **Products** | 4 | 2+ | 1 | 25% |
| **Cart** | 0 | 1 | 0 | 0% |
| **Orders** | 3 | 1+ | 0 | 0% |
| **Profile** | 7 | 1 | 0 | 0% |
| **Search** | 1 | 0 | 0 | 0% |
| **Wishlist** | 1 | 0 | 0 | 0% |
| **Admin** | 0 | 45+ | 0 | 0% |
| **Staff/Reseller** | 5 | 0 | 0 | 0% |
| **Shared** | 0 | 2 | 0 | 0% |
| **TOTAL** | **23** | **68+** | **7** | **9.3%** |

---

## Notes

- **ConsumerWidget/ConsumerStatefulWidget:** Require `ProviderScope` wrapper in tests
- **StatefulWidget:** Standard MaterialApp wrapping
- **StatelessWidget:** Simplest to test
- **Forms:** Require TextEditingController mocking
- **Navigation:** Require GoRouter mock or Navigator.of(context)
- **Firebase:** Use existing MockFirebaseFirestore, MockFirebaseAuth from test/helpers/
- **Images:** Use cached_network_image mock or placeholder data
- **Time-based:** Use DateTime.now() manipulation
- **Pagination:** Use cursor-based Firebase queries (cursor mock needed)

---

**For detailed test analysis, see:** [WIDGET_TEST_ANALYSIS.md](WIDGET_TEST_ANALYSIS.md)  
**For implementation plan, see:** [WIDGET_TEST_IMPLEMENTATION_PLAN.md](WIDGET_TEST_IMPLEMENTATION_PLAN.md) (to create)
