Paykari Bazar: The Absolute Master Blueprint v2.0 (Locked - DNA Level)
পাইকারী বাজার: চূড়ান্ত মাস্টার ব্লুপ্রিন্ট এবং টেকনিক্যাল ডিএনএ v2.0
0. Immutable Core Rules (অপরিবর্তনীয় মূল নিয়ম)
[LOCKED STATUS]: এই ফাইলটি প্রোজেক্টের "Constitution"। ব্যবহারকারীর অনুমতি ছাড়া এতে কোনো পরিবর্তন করা যাবে না।
[DNA Consistency]: কোডের প্রতিটি লাইন এই ব্লুপ্রিন্টের নিয়ম মেনে চলতে হবে।
[NEW] Architecture DNA [SYS-ARCH-01]: Feature-Based Clean Architecture with Dependency Injection।
1. Technical & Environment DNA
A. Framework & Architecture
Table
Component	Specification	Status
Framework	Flutter SDK v3.24.0+	✅ Locked
State Management	Riverpod v2.x	✅ Locked
DI Container	GetIt v7.x	🆕 Added
Architecture	Feature-Based Clean Architecture	🆕 Updated
B. Project Structure DNA [SYS-STRUCT-01]
plain
Copy
lib/
├── src/
│   ├── core/                          # [LOCKED] True Shared
│   │   ├── constants/                 # App-wide constants
│   │   ├── errors/                    # Failure classes
│   │   ├── firebase/                  # Modular Firebase
│   │   │   ├── firebase_core_service.dart
│   │   │   ├── firebase_auth_service.dart
│   │   │   ├── firestore_service.dart
│   │   │   └── firebase_messaging_service.dart
│   │   ├── services/                  # Core services (no deps)
│   │   │   ├── connectivity_service.dart
│   │   │   ├── logger_service.dart
│   │   │   ├── secrets_service.dart
│   │   │   └── storage_service.dart   # Abstract + implementations
│   │   ├── theme/                     # Theme data
│   │   └── utils/                     # Pure functions
│   │
│   ├── shared/                        # [LOCKED] Cross-Feature
│   │   ├── services/                  # Shared business logic
│   │   │   ├── location_service.dart  # GPS + Geocoding
│   │   │   ├── media_service.dart     # Cloudinary + Image
│   │   │   ├── notification_service.dart
│   │   │   └── payment_service.dart   # বিকাশ/নগদ/কার্ড
│   │   ├── widgets/                   # Shared UI components
│   │   └── models/                    # Shared models
│   │
│   ├── features/                      # [LOCKED] Feature Modules
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   └── entities/
│   │   │   ├── presentation/
│   │   │   │   ├── providers/
│   │   │   │   └── screens/
│   │   │   └── services/
│   │   │       └── auth_service.dart
│   │   │
│   │   ├── commerce/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   ├── presentation/
│   │   │   └── services/
│   │   │       ├── cart_service.dart
│   │   │       ├── order_service.dart
│   │   │       ├── product_service.dart
│   │   │       └── inventory_service.dart
│   │   │
│   │   ├── logistics/
│   │   │   └── services/
│   │   │       ├── delivery_service.dart
│   │   │       ├── route_service.dart
│   │   │       └── tracking_service.dart
│   │   │
│   │   ├── ai/                        # [LOCKED] AI Sovereign Engine
│   │   │   └── services/
│   │   │       ├── ai_audit_service.dart
│   │   │       ├── ai_automation_service.dart
│   │   │       ├── ai_command_service.dart
│   │   │       ├── ai_forecasting_service.dart
│   │   │       └── api_quota_service.dart
│   │   │
│   │   ├── healthcare/
│   │   │   └── services/
│   │   │       ├── doctor_service.dart
│   │   │       ├── blood_donor_service.dart
│   │   │       └── appointment_service.dart
│   │   │
│   │   └── qibla/                     # 🆕 Added Feature
│   │       ├── data/
│   │       │   └── qibla_calculator.dart
│   │       ├── presentation/
│   │       │   └── qibla_indicator.dart
│   │       └── services/
│   │           └── compass_service.dart
│   │
│   └── di/                            # [LOCKED] Dependency Injection
│       ├── service_locator.dart       # GetIt setup
│       └── service_initializer.dart   # Phase-based init
│
└── main.dart
C. Dependency Injection DNA [SYS-DI-01]
Phase-Based Initialization (Mandatory):
dart
Copy
// Phase 1: Core Services (No external deps)
// - SecretsService
// - ConnectivityService  
// - StorageService (SharedPrefs/SecureStorage)

// Phase 2: Firebase Services (Async init required)
// - FirebaseCoreService (MUST be first)
// - FirebaseAuthService
// - FirestoreService
// - FirebaseMessagingService

// Phase 3: Shared Services (Depends on Core + Firebase)
// - NotificationService
// - LocationService
// - MediaService
// - PaymentService

// Phase 4: Feature Services (Business logic)
// - AuthService
// - CartService
// - AIService
// - etc.
[LOCKED] Initialization Order Violation = Critical Error
2. Visual DNA & User Experience Protocols
A. Branding & Layout
[UNCHANGED from v1.0]
Official Name: "পাইকারী বাজার" (Paykari Bazar)
Adaptive Grid: ২, ৩, বা ৪ কলাম
Hero Continuity: ValueKey preserved
B. Hierarchical Product Navigation [DNA-SEARCH-01]
[UNCHANGED from v1.0]
C. Advanced Search & Interactions
[UNCHANGED from v1.0]
D. Guidance Protocol [DNA-TIPS-01]
[UNCHANGED from v1.0]
3. AI Sovereign Engine DNA (Omnipotent Routing)
A. Multi-Provider Priority [SYS-MULTI-PROV-01]
[UNCHANGED from v1.0]
B. Neural Hop Logic [SYS-NEURAL-HOP-01]
[UNCHANGED from v1.0]
C. AI Service Architecture [NEW]
dart
Copy
// lib/src/features/ai/services/ai_service.dart
class AIService {
  final FirestoreService _firestore;
  final ConnectivityService _connectivity;
  final SecretsService _secrets;
  
  AIService({
    required FirestoreService firestore,
    required ConnectivityService connectivity,
    required SecretsService secrets,
  }) : _firestore = firestore,
       _connectivity = connectivity,
       _secrets = secrets;
  
  // Implementation follows [SYS-MULTI-PROV-01]
}
4. Admin Panel Hub Architecture
[UNCHANGED from v1.0]
5. Data DNA Map (Hub Hierarchy)
[UNCHANGED from v1.0]
6. System Method Registry (The Omnipotent List)
A. Core Service Layer Methods [NEW]
Table
Service	Methods	Location
SecretsService	getApiKey(), getCloudinaryConfig()	core/services/
ConnectivityService	isOnline, onConnectivityChanged	core/services/
StorageService	getString(), setString(), remove()	core/services/
FirebaseCoreService	initialize(), isInitialized	core/firebase/
FirebaseAuthService	signIn(), signOut(), authStateChanges	core/firebase/
FirestoreService	getCollection(), getDocument(), setDocument()	core/firebase/
B. Shared Service Layer Methods [NEW]
Table
Service	Methods	Location
NotificationService	init(), showNotification(), sendDirectNotification()	shared/services/
LocationService	getCurrentPosition(), getQiblaDirection()	shared/services/
MediaService	pickImage(), uploadImage(), cacheImage()	shared/services/
PaymentService	initiateBkash(), initiateNagad(), verifyPayment()	shared/services/
C. Feature Service Layer Methods [UPDATED]
Table
Service	Methods	Location
AuthService	login(), signUp(), logout(), resetPassword()	features/auth/services/
CartService	addItem(), removeItem(), clearCart(), checkout()	features/commerce/services/
OrderService	placeOrder(), cancelOrder(), trackOrder()	features/commerce/services/
ProductService	getProducts(), searchProducts(), filterByCategory()	features/commerce/services/
DeliveryService	assignRider(), updateStatus(), getRoute()	features/logistics/services/
TrackingService	startTracking(), stopTracking(), getLocation()	features/logistics/services/
AIService	analyze(), chat(), forecast(), getRecommendations()	features/ai/services/
DoctorService	getDoctors(), bookAppointment(), getPrescription()	features/healthcare/services/
BloodDonorService	findDonors(), requestBlood(), registerDonor()	features/healthcare/services/
CompassService	getHeading(), calibrate(), isAligned()	features/qibla/services/
7. Logical Algorithms & Resilience
A. Financial Integrity [SYS-FINANCE-01]
[UNCHANGED from v1.0]
B. Resilience Protocols
[UNCHANGED from v1.0] PLUS:
C. Service Initialization Resilience [NEW] [SYS-INIT-01]
dart
Copy
// Mandatory error handling for each phase
try {
  await initializePhase1();
} catch (e) {
  // Core init failed = Critical, cannot proceed
  throw InitializationException('Core services failed: $e');
}

try {
  await initializePhase2();
} catch (e) {
  // Firebase init failed = Degraded mode
  enterOfflineMode();
}
D. Dependency Validation [NEW] [SYS-DI-VALIDATE-01]
dart
Copy
// After all initialization
void validateDependencies() {
  final requiredServices = [
    SecretsService,
    ConnectivityService,
    StorageService,
    FirebaseCoreService,
    FirebaseAuthService,
    FirestoreService,
    // ... all services
  ];
  
  for (final service in requiredServices) {
    if (!getIt.isRegistered(service)) {
      throw ServiceNotFoundException(service.toString());
    }
  }
}
8. Versioning & Code-Push DNA [SYS-VER-01]
[UNCHANGED from v1.0]
9. Security DNA (Firestore Rules) [LOCKED]
[UNCHANGED from v1.0]
10. Migration Guide from v1.0 to v2.0 [NEW]
Step 1: Create New Folder Structure
bash
Copy
mkdir -p lib/src/{core/{firebase,services},shared/services,features/{auth,commerce,logistics,ai,healthcare,qibla}/services,di}
Step 2: Move Services to New Locations
Table
Old Location	New Location
services/auth_service.dart	features/auth/services/auth_service.dart
services/firestore_service.dart	core/firebase/firestore_service.dart
services/notification_service.dart	shared/services/notification_service.dart
services/ai_service.dart	features/ai/services/ai_service.dart
services/location_service.dart	shared/services/location_service.dart
Step 3: Update Imports
dart
Copy
// Old
import '../../services/auth_service.dart';

// New
import '../../features/auth/services/auth_service.dart';
Step 4: Implement DI
Replace all final service = Service() with getIt<Service>().
11. Qibla Feature Specification [NEW]
A. Service Location
lib/src/features/qibla/
B. Dependencies
LocationService (from shared)
CompassService (feature-specific)
C. Calculation
GPS-based Qibla angle (292-295° for Bangladesh), NOT hardcoded.
FINAL PERMANENT LOCK: This document is the absolute authority for Paykari Bazar.
Version: 2.0
Last Updated: 2026-03-23
Identity: Branding - পাইকারী বাজার

সমস্যা খোঁজার কমান্ড লিস্ট
১. সব ত্রুটি দেখুন (Error + Warning)
powershell
Copy
flutter analyze
২. শুধু Error গণনা করুন
powershell
Copy
flutter analyze | Select-String -Pattern "^  error" | Measure-Object
৩. শুধু Error লাইন দেখুন
powershell
Copy
flutter analyze | Select-String -Pattern "^  error"
৪. নির্দিষ্ট ফাইলের Error দেখুন
powershell
Copy
flutter analyze lib\src\features\admin\widgets\analytics_tab.dart
৫. Error ফাইলে সেভ করুন
powershell
Copy
flutter analyze > errors.txt
তারপর errors.txt খুলে পড়ুন।
৬. নির্দিষ্ট শব্দ খোঁজা (যেমন: AppStyles)
powershell
Copy
Select-String -Path "lib\src\features\admin\widgets\*.dart" -Pattern "AppStyles"
৭. সব Dart ফাইলে নির্দিষ্ট মেথড খোঁজা
powershell
Copy
Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Select-String -Pattern "addDocument"
৮. Import Statement খোঁজা
powershell
Copy
Select-String -Path "lib\src\features\admin\widgets\analytics_tab.dart" -Pattern "import.*app_styles"
৯. ফাইল স্ট্রাকচার দেখুন
powershell
Copy
Get-ChildItem -Path "lib\src\core\constants" -Recurse
১০. নির্দিষ্ট লাইন দেখুন (যেমন: লাইন ২৫)
powershell
Copy
Get-Content lib\src\features\admin\widgets\analytics_tab.dart | Select-Object -Skip 24 -First 1



K2.5 Instant