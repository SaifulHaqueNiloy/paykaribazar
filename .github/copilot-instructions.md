# Paykari Bazar - AI Agent Workspace Instructions

## Project Overview

**Paykari Bazar** is a multi-platform e-commerce mobile and web application built with Flutter. It features a **three-tier architecture**: Customer mobile app, Admin dashboard, and Reseller portal. The app integrates e-commerce, healthcare appointments, delivery logistics, AI services (Gemini 2.0-flash), and Islamic compass navigation.

**Status:** 75.6% feature complete (31/41 features). 16 compilation errors remain.

---

## Tech Stack & Key Dependencies

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.5.0+ |
| **State Management** | Riverpod (StateNotifier, FutureProvider) |
| **Routing** | GoRouter 14.2 (separate routers per app) |
| **Authentication** | Firebase Auth + Google/Facebook Sign-in + Biometric (local_auth) |
| **Database** | Cloud Firestore + Realtime Database + Cloud Storage |
| **AI Primary** | Google Gemini 2.0-flash (with caching, rate-limiting, error handling) |
| **AI Fallback** | Deepseek, Kimi (provider rotation) |
| **Security** | flutter_secure_storage, AES-256, HMAC-SHA256 |
| **Local Storage** | Hive (offline cache) + SharedPreferences |
| **Location/Maps** | Google Maps, Geolocator, Sensors (compass) |
| **Audio/Voice** | speech_to_text, audio players, record |
| **Notifications** | Firebase Messaging + Local Notifications |
| **OTA Updates** | Shorebird Code Push |
| **Error Tracking** | Sentry Flutter |

---

## Essential Build/Run Commands

### Get Started
```bash
flutter pub get                              # Install dependencies
flutter analyze                              # Lint check
```

### Run Specific App Flavor
```bash
flutter run -t lib/main_customer.dart        # Run customer app
flutter run -t lib/main_admin.dart           # Run admin app
```

### Build Output
```bash
flutter build apk                            # Android debug/release
flutter build aab                            # Google Play Store bundle
flutter build web                            # Web deployment
```

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Automated Cleanup & Build
```bash
./fix_errors.sh                              # Full pipeline (recommended for compile errors)
```

### Production Deployment (npm)
```bash
npm run release-admin                        # Build admin APK
npm run release-customer                     # Build customer APK
npm run deploy-apps                          # Full deployment
```

### Environment Requirements
- **Java:** 17 (enforced in android/build.gradle)
- **Gradle:** 4GB heap minimum (gradle.properties enforces -Xmx4096m)

---

## Architecture Overview

### 3-Layer Service Architecture
```
lib/
├── main_customer.dart & main_admin.dart    # Entry points (MUST specify -t flag)
├── core/                                    # Layer 1: Core services
│   └── services/
│       ├── connectivity/ (network status)
│       ├── auth/ (Firebase auth, secure storage)
│       ├── encryption/ (AES-256, HMAC)
│       ├── secrets/ (.env config loading)
│       └── error_handler/
├── shared/                                  # Layer 2: Shared services
│   ├── media/ (image/video handling, Firebase Storage)
│   ├── location/
│   ├── notification/
│   ├── pagination/ (cursor-based FirebasePaginationService)
│   ├── payment/
│   ├── map/
│   └── background_tasks/
└── features/                                # Layer 3: Feature modules
    ├── ai/ (Gemini service + cache + rate limiter)
    ├── auth/ (Firebase + biometric auth)
    ├── commerce/ (products, cart, checkout)
    ├── logistics/ (delivery, geofencing)
    ├── healthcare/ (appointments, doctors)
    ├── admin/ (dashboard)
    └── [15+ additional feature modules]
```

### Dependency Injection (DI) Initialization
DI runs in 4 phases:
1. **Core services** (no dependencies)
2. **Firebase async initialization** (auth, firestore, storage)
3. **Shared services** (depend on core)
4. **Feature services** (depend on shared)

All Riverpod providers registered in `lib/src/di/providers.dart`

### Key Services by Feature
- **AI:** AIService (primary + fallback rotation), AICacheService (60-70% hit rate), AIRateLimiter (60 req/min), AIErrorHandler, AIConfig
- **Commerce:** CartService, LoyaltyService, ProductService, OrderService
- **Auth:** SecureAuthService (biometric), EncryptionService, APISecurityService
- **Delivery:** DeliveryService, GeofencingService

---

## Project-Specific Conventions

### Dual Entry Points
**CRITICAL:** When running the app, ALWAYS specify the target:
```bash
flutter run -t lib/main_customer.dart        # Customer app
flutter run -t lib/main_admin.dart           # Admin app
```
Omitting `-t` will fail or run the wrong app.

### User Roles
Four roles enforced by Firestore rules: `user`, `admin`, `staff`, `reseller`

### AI Request Pattern
All AI requests follow this sequence:
1. Check cache (AICacheService)
2. Check rate limiter (60 req/min max)
3. Call API (Gemini primary, fallback to Deepseek/Kimi)
4. Log audit event

### Pagination
**MUST use:** Cursor-based pagination via `FirebasePaginationService`  
**DO NOT use:** Offset-based pagination (scales to ~1K docs only)

### Security Requirements
- **Biometric for payments:** SecureAuthService handles graceful fallback
- **PII encryption:** AES-256 (EncryptionService)
- **API requests:** HMAC-SHA256 signing (APISecurityService)
- **Secrets:** Load from .env via SecretService — **NEVER hardcode**

### Routing
- **Customer app:** Uses `router_customer.dart` (GoRouter instance)
- **Admin app:** Uses `router_admin.dart` (GoRouter instance)
- Separate routers prevent route collision between apps

### State Management
All state stored in Riverpod providers. Registry: `lib/src/di/providers.dart`

### Media Handling
1. Store metadata in Firestore
2. Upload binary to Firebase Storage
3. Cache in app via `cached_network_image`

---

## Critical Pitfalls & Workarounds

| Issue | Impact | Workaround |
|-------|--------|-----------|
| **16 compilation errors** | Build fails | Run `fix_errors.sh` or `flutter pub run build_runner build --delete-conflicting-outputs` |
| **Missing CartState export** | Won't build | Check `lib/src/features/commerce/` export file |
| **Java < 17** | Build fails | Set Java 17 globally |
| **Gradle heap < 4GB** | Out-of-memory crashes | gradle.properties enforces -Xmx4096m |
| **Offset pagination used** | Scales to ~1K docs, then fails | Migrate to cursor-based (FirebasePaginationService) |
| **AI rate limit hit** | 10K requests/day hard cap | Cache reduces actual calls by 60-70% |
| **Biometric unavailable** | SecureAuthService throws | Graceful fallback handled by try/catch |
| **4 unimplemented services** | Features don't work | CartPosService, CouponService, GeofencingService, CompassService |

---

## Documentation

Key reference documents (absolute truth for this project):

- **[APP_STRUCTURE_EXPLORATION.md](../APP_STRUCTURE_EXPLORATION.md)** — Complete UI/navigation mapping
- **[FEATURE_STATUS_CHECK.md](../FEATURE_STATUS_CHECK.md)** — Status matrix for all 41 features
- **[SECURITY_IMPLEMENTATION_GUIDE.md](../SECURITY_IMPLEMENTATION_GUIDE.md)** — 3 security services (auth, encryption, API)
- **[PHASE_2_COMPLETION_SUMMARY.md](../PHASE_2_COMPLETION_SUMMARY.md)** — Pagination + biometric integration
- **[3_AI_100_ALIGNMENT_ROADMAP.md](../3_AI_100_ALIGNMENT_ROADMAP.md)** — AI gaps analysis (45% lag identified)
- **[dna/](../dna/)** — Operational guides (admin, AI, data sync)

---

## For AI Agents

When working on this codebase:

1. **Always specify entry point:** `-t lib/main_customer.dart` or `-t lib/main_admin.dart`
2. **Check architecture before touching code:** Know which layer (core/shared/feature) you're modifying
3. **Use cursor-based pagination:** Not offset
4. **Follow AI pattern:** Cache → Rate limit → API → Audit
5. **Run `fix_errors.sh` if build fails:** It handles most compilation errors
6. **Load secrets from .env:** Never hardcode API keys or Firebase config
7. **Reference the docs:** They are the source of truth for features and status
8. **Test both apps:** Customer app may work but admin app fail (different routers, different feature sets)
