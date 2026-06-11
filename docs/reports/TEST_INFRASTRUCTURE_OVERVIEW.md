# Test Infrastructure Overview - Paykari Bazar

**Generated:** March 26, 2026  
**Coverage:** 54 test files across unit, integration, and widget testing  
**Status:** Comprehensive test structure in place with modular utilities

---

## 1. Test Files Organization & Structure

### Directory Layout
```
test/
├── helpers/                          # Shared test utilities
│   ├── test_setup.dart              # Test initialization & base classes
│   └── mock_providers.dart          # Firebase & service mocks
├── fixtures/                         # Test data & fixtures
│   └── test_data.dart               # Reusable test constants & objects
├── services/                         # Service-level unit tests (11 tests)
├── unit/                            # Core units & models (8 tests)
├── providers/                       # Riverpod provider tests (6 tests)
├── widgets/                         # Widget tests (9 tests)
├── core_services/                   # Core infrastructure tests (4 tests)
├── additional/                      # End-to-end & comprehensive tests (3 tests)
├── integration/                     # Integration tests (3 tests)
├── widget_test.dart                # Entry-point smoke test
├── fallback_provider_test.dart      # AI provider fallback testing
├── security_services_test.dart      # Security service tests
├── unit_services_test.dart          # Unit service integration
├── nvidia_test.dart                 # GPU/performance test
├── order_model_test.dart            # Order model tests
└── product_model_test.dart          # Product model tests

integration_test/
└── checkout_flow_test.dart          # E2E checkout flow testing
```

### Test File Distribution (54 files total)

| Category | Count | Files |
|----------|-------|-------|
| **Service Tests** | 11 | `ai_service_test.dart`, `cache_service_test.dart`, `cart_service_test.dart`, `checkout_flow_service_test.dart`, `firebase_pagination_service_test.dart`, `order_service_test.dart`, `product_service_test.dart`, `ai_providers_test.dart`, `ai_provider_fallback_test.dart` |
| **Unit Tests** | 8 | `ai_service_test.dart`, `core_services_test.dart`, `encryption_test.dart`, `firestore_service_test.dart`, `models_test.dart`, `models_test_day4.dart`, `quota_service_test.dart` |
| **Widget Tests** | 9 | `flash_sale_timer_test.dart`, `product_detail_screen_test.dart`, `login_screen_test.dart`, `home_screen_test.dart`, `home_widgets_test.dart`, `basic_widgets_test.dart`, `consumer_widgets_test.dart`, `additional_widgets_test.dart`, `widget_test.dart` |
| **Provider Tests** | 6 | `pagination_providers_test.dart`, `product_provider_test.dart`, `order_provider_test.dart`, `cart_provider_test.dart`, `auth_provider_test.dart`, `additional_providers_test.dart` |
| **Core Services** | 4 | `ai_commerce_security_integration_test.dart`, `commerce_services_test.dart`, `security_services_test.dart`, `ai_service_test.dart` |
| **Integration Tests** | 3 | `purchase_flow_test.dart`, `edge_cases_test.dart`, `admin_crud_test.dart` |
| **E2E Tests** | 1 | `e2e_workflow_test.dart` |
| **Specialty Tests** | 2 | `fallback_provider_test.dart`, `nvidia_test.dart` |
| **Model Tests** | 2 | `order_model_test.dart`, `product_model_test.dart` |
| **Generated Mocks** | 2 | `unit_services_test.mocks.dart`, `ai_service_test.mocks.dart` |

---

## 2. Test Utilities & Helpers Infrastructure

### 2.1 Core Test Setup (`test/helpers/test_setup.dart`)

**Purpose:** Centralized initialization and base classes for all tests

```dart
Key Components:
├── setupHiveForTesting()              // Initialize Hive for testing
├── tearDownHiveForTesting()           // Clean up Hive after tests
├── createTestProviderContainer()      // Create Riverpod containers
├── BaseTest                           // Abstract base class for unit tests
│   ├── container: ProviderContainer   // Riverpod container
│   ├── providerOverrides: List<Override>
│   ├── setUp()                        // Custom setup hook
│   ├── tearDown()                     // Custom teardown hook
│   └── read<T>(provider)              // Helper to read provider values
├── BaseFirebaseTest extends BaseTest  // Firebase-specific setup
├── BaseSnapshotTest extends BaseTest  // Async/snapshot testing utilities
│   ├── pumpAsync()                    // Wait for async operations
│   ├── expectLoading()                // Verify AsyncLoading state
│   ├── expectError()                  // Verify AsyncError state
│   └── expectData<T>()                // Verify AsyncData state
├── setupFallbackValue<T>()            // Register mocktail fallback values
└── Fixture.create<T>()                // Generic fixture factory
```

**Usage Pattern:**
```dart
class MyServiceTest extends BaseFirebaseTest {
  @override
  List<Override> get providerOverrides => [
    // Provide mock overrides
  ];

  void setUp() {
    super.setUp();
    // Custom setup
  }
}
```

### 2.2 Mock Providers (`test/helpers/mock_providers.dart`)

**Purpose:** Reusable Firebase and service mocks across all tests

**Mock Classes:** ~25 mocks organized by domain

```dart
Firebase Mocks:
├── MockFirebaseFirestore
├── MockCollectionReference
├── MockDocumentReference
├── MockDocumentSnapshot        // With custom id() and data() overrides
├── MockQuerySnapshot           // With size and docs properties
├── MockQuery
├── MockFirebaseAuth
├── MockUser                    // With uid, email, emailVerified
├── MockUserCredential
├── MockFirebaseDatabase
├── MockDatabaseReference
└── MockDatabaseEvent

Service Mocks:
├── MockAuthService
├── MockProductService
├── MockCartService
├── MockOrderService
├── MockPaginationService
├── MockAICacheService
├── MockAIRateLimiter
└── MockAIHealthMonitor
```

**Key Features:**
- Custom implementations for `MockDocumentSnapshot` that implement `id()` and `data()` getters
- Fallback value registration to prevent "No fallback value found" errors
- Structured by service domain (Firebase, Commerce, AI, etc.)

### 2.3 Test Fixtures (`test/fixtures/test_data.dart`)

**Purpose:** Centralized test data constants and fixture objects

**Organized Fixtures:**

```dart
USER FIXTURES
├── testUserId = 'test-user-123'
├── testUserEmail = 'testuser@example.com'
├── testUserPhone = '+1234567890'
├── testUserName = 'Test User'
└── testUserMap (complete user document)

PRODUCT FIXTURES
├── testProductId = 'prod-123'
├── testProductName = 'Test Product'
├── testProductPrice = 99.99
├── testProductStock = 100
├── testProductMap (complete product document)
└── testProductList [3 products with variations]

ORDER FIXTURES
├── testOrderId = 'order-123'
├── testOrderStatus = 'pending'
├── testOrderTotal = 199.98
└── testOrderMap (complete order with items)

AI FIXTURES
├── testAiQuery = 'What is Flutter?'
├── testAiResponse = 'Flutter is a cross-platform...'
├── testAiCacheKey = 'query_hash_12345'
└── testAiAuditMap (audit log entry)

CART FIXTURES
├── testCartItemMap (single cart item)
└── testCartMap (complete cart with multiple items)

COUPON FIXTURES
├── testCouponCode = 'TEST20'
├── testCouponDiscount = 20.0
└── testCouponMap (complete coupon document)
```

**Benefits:**
- Single source of truth for test data
- Consistent across all tests
- Easy to update fixtures globally
- Reduces test data boilerplate

---

## 3. Testing Framework Setup

### 3.1 Test Dependencies (from `pubspec.yaml`)

```yaml
dev_dependencies:
  flutter_test:              # Flutter testing framework
    sdk: flutter
  integration_test:          # E2E integration testing
    sdk: flutter
  flutter_lints: ^4.0.0      # Code analysis
  mockito: ^5.4.4            # Mock generation via annotations
  mocktail: ^1.0.4           # Null-safe mocking
  flutter_launcher_icons: ^0.13.1
  hive_generator: ^2.0.1     # Hive adapter generation
  build_runner: ^2.4.9       # Code generation runner
  cloud_firestore_platform_interface: any
```

### 3.2 Test Framework Architecture

**Pattern 1: Widget Testing with WidgetTester**
```dart
testWidgets('test name', (WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: TestApp()));
  expect(find.byType(Widget), findsOneWidget);
});
```

**Pattern 2: Unit Testing with Mocks**
```dart
group('Feature Group', () {
  late MockService mockService;
  
  setUp(() {
    mockService = MockService();
    when(() => mockService.method()).thenAnswer((_) async => value);
  });
  
  test('should do something', () async {
    expect(result, equals(expected));
  });
});
```

**Pattern 3: Provider Testing**
```dart
test('provider returns correct value', () {
  final container = createTestProviderContainer();
  final value = container.read(myProvider);
  expect(value, equals(expected));
});
```

**Pattern 4: Integration Testing**
```dart
testWidgets('complete flow', (WidgetTester tester) async {
  // Setup
  await tester.pumpWidget(const App());
  
  // Interact
  await tester.tap(find.byType(Button));
  await tester.pumpAndSettle();
  
  // Verify
  expect(find.byText('Result'), findsOneWidget);
});
```

### 3.3 Test Group Organization

**Naming Convention:**
```
group('ComponentName Tests', () {
  group('Feature Area - Specific Behavior', () {
    test('test description', () { ... });
  });
});
```

**Example from tests:**
- `'ProductsPaginationNotifier Tests'`
- `'Product Detail - Information Display'`
- `'Provider Fallback Chain'`
- `'FirebasePaginationService Tests'`

---

## 4. Performance Measurement Patterns

### 4.1 Current Performance Measurement Usage

Located in production code (not primarily in tests):

**File:** `lib/src/services/background_task_service.dart` (Lines 55-120)

```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final stopwatch = Stopwatch()..start();  // ⭐ Performance measurement
    
    try {
      // Task execution
      final bool result = await _routeTask(container, task, inputData);
      debugPrint('Task $task completed in ${stopwatch.elapsedMilliseconds}ms with result: $result');
      return result;
    } finally {
      stopwatch.stop();
      container.dispose();
    }
  });
}
```

**Pattern Used:**
- `Stopwatch()..start()` to begin measurement
- `stopwatch.elapsedMilliseconds` to get elapsed time
- `stopwatch.stop()` to finalize
- Logged via `debugPrint()`

### 4.2 AI Performance Metrics Tracking

**File:** `lib/src/features/ai/services/ai_request_logger.dart`

```dart
/// Service for logging AI requests and tracking metrics

Located in: lib/src/features/ai/services/ai_request_logger.dart
- Logs AI requests with latency tracking
- Records: query, response, provider, latency, tokens used
- Audit trail for compliance
```

### 4.3 AI Health Monitoring

**File:** `lib/src/features/ai/services/ai_system_health_monitor.dart` (Lines 1-100+)

```dart
class AISystemHealthMonitor {
  /// Real-time health monitoring service for AI systems
  
  Key Methods:
  ├── getCurrentHealth()      // Get current system health metrics
  ├── getHealthTrends()       // Historical health trend analysis
  ├── getAlerts()             // Get active alerts
  ├── monitorCachePerformance() // Track cache hit rates & latency
  ├── monitorRateLimiter()    // Track request rate & limits
  └── monitorErrorRates()     // Track provider failure rates
  
  Tracked Metrics:
  ├── Cache hit rate (target: 60-70%)
  ├── Request latency (ms)
  ├── Error rates by provider
  ├── Rate limit status
  └── Daily quota usage
```

### 4.4 Cache Service Statistics

**File:** `test/services/cache_service_test.dart` (Lines 60-80)

```dart
group('Statistics', () {
  test('getStats returns correct metrics', () async {
    await cache.set(key: 's1', value: 'v1');
    await cache.set(key: 's2', value: 'v2');

    final stats = await cache.getStats();
    
    expect(stats.totalItems, equals(2));
    expect(stats.validItems, equals(2));
  });
});

// Cache statistics available:
// - totalItems: count of all cached items
// - validItems: count of non-expired items
// - hitRate: cache hit percent
// - size: memory usage
```

### 4.5 AI Test Configuration Models

**File:** `test/core_services/ai_service_test.dart` (Lines 1-60)

```dart
class AIConfig {
  static const int cacheMaxSizeMb = 50;
  static const Duration cacheTtl = Duration(hours: 24);
  static const int requestsPerMinute = 60;
  static const int dailyLimit = 10000;
  static const Duration timeout = Duration(seconds: 30);
}

class AIResponse {
  final String content;
  final AIProvider provider;
  final Duration latency;      // ⭐ Latency tracking
  final DateTime timestamp;
}
```

---

## 5. Test Coverage by Feature Domain

### 5.1 Commerce/E-Commerce Tests
- **Product Service** (`test/services/product_service_test.dart`)
- **Cart Service** (`test/services/cart_service_test.dart`)
- **Order Service** (`test/services/order_service_test.dart`)
- **Checkout Flow** (`test/services/checkout_flow_service_test.dart`, `integration_test/checkout_flow_test.dart`)
- **Pagination** (`test/services/firebase_pagination_service_test.dart`, `test/providers/pagination_providers_test.dart`)

### 5.2 AI Service Tests
- **Core AI Service** (`test/services/ai_service_test.dart`, `test/unit/ai_service_test.dart`, `test/core_services/ai_service_test.dart`)
- **AI Providers** (`test/services/ai_providers_test.dart`, `test/services/ai_provider_fallback_test.dart`)
- **Comprehensive AI** (`test/unit/ai_service_comprehensive_test.dart`)
- **Integration** (`test/core_services/ai_commerce_security_integration_test.dart`)

### 5.3 Security Tests
- **Encryption** (`test/unit/encryption_test.dart`)
- **Security Services** (`test/security_services_test.dart`, `test/core_services/security_services_test.dart`)
- **Integration** (`test/core_services/ai_commerce_security_integration_test.dart`)

### 5.4 Unit & Model Tests
- **Models** (`test/unit/models_test.dart`, `test/unit/models_test_day4.dart`)
- **Firestore Service** (`test/unit/firestore_service_test.dart`)
- **Cache Service** (`test/services/cache_service_test.dart`)
- **Quota Service** (`test/unit/quota_service_test.dart`)
- **Core Services** (`test/unit/core_services_test.dart`)

### 5.5 Widget Tests
- **Product Detail** (`test/widgets/product_detail_screen_test.dart`)
- **Login Screen** (`test/widgets/login_screen_test.dart`)
- **Home Screen** (`test/widgets/home_screen_test.dart`)
- **Flash Sale Timer** (`test/widgets/flash_sale_timer_test.dart`)
- **Consumer Widgets** (`test/widgets/consumer_widgets_test.dart`)
- **Basic Widgets** (`test/widgets/basic_widgets_test.dart`)

### 5.6 Provider Tests
- **Pagination** (`test/providers/pagination_providers_test.dart`)
- **Products** (`test/providers/product_provider_test.dart`)
- **Orders** (`test/providers/order_provider_test.dart`)
- **Cart** (`test/providers/cart_provider_test.dart`)
- **Auth** (`test/providers/auth_provider_test.dart`)

### 5.7 Integration & E2E Tests
- **Purchase Flow** (`test/integration/purchase_flow_test.dart`)
- **Edge Cases** (`test/integration/edge_cases_test.dart`)
- **Admin CRUD** (`test/integration/admin_crud_test.dart`)
- **End-to-End Workflow** (`test/additional/e2e_workflow_test.dart`)

---

## 6. Key Testing Patterns & Best Practices

### 6.1 Mock Registration Pattern

```dart
// At the top of test file
@GenerateMocks([FirestoreService, SecretsService, AIProvider])
void main() {
  // Mockito generates _test.mocks.dart with mock implementations
}

// Or with mocktail (null-safe)
void main() {
  setUpAll(() {
    registerFallbackValue(AiWorkType.generic);
  });
  
  setUp(() {
    mockService = MockService();
    when(() => mockService.method()).thenAnswer((_) async => value);
  });
}
```

### 6.2 Provider Override Pattern

```dart
class TestClass extends BaseTest {
  @override
  List<Override> get providerOverrides => [
    productServiceProvider.overrideWithValue(mockProductService),
    paginationServiceProvider.overrideWithValue(mockPaginationService),
  ];
}
```

### 6.3 Fixture-Based Testing Pattern

```dart
import 'package:test/src/fixtures/test_data.dart';

test('should process test data', () {
  final product = testProductMap;
  final cart = testCartMap;
  final order = testOrderMap;
  
  // Test using fixtures...
});
```

### 6.4 Time-Based Testing Pattern

```dart
test('expired items return null', () async {
  await cache.set(
    key: 'expire_key',
    value: 'value1',
    ttl: const Duration(seconds: 1)  // Time-to-live
  );

  final val = await cache.get<String>('expire_key');
  expect(val, equals('value1'));

  await Future.delayed(const Duration(seconds: 2));
  
  final expiredVal = await cache.get<String>('expire_key');
  expect(expiredVal, isNull);
});
```

### 6.5 Async Testing Pattern

```dart
test('async operation', () async {
  final result = await someAsyncFunction();
  expect(result, equals(expected));
});

testWidgets('async widget operations', (tester) async {
  await tester.pumpWidget(app);
  await tester.tap(find.byType(Button));
  await tester.pumpAndSettle();  // Wait for animations
  expect(find.byText('Result'), findsOneWidget);
});
```

---

## 7. Test Execution & Code Generation

### 7.1 Build Runner for Mock Generation

```bash
# Generate mocks from @GenerateMocks annotations
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean
```

**Generated Files:**
- `unit_services_test.mocks.dart` - Generated mocks for unit services
- `ai_service_test.mocks.dart` - Generated mocks for AI service
- (Pattern: `*_test.mocks.dart` for each annotated test file)

### 7.2 Test Execution

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/cache_service_test.dart

# Run tests with coverage
flutter test --coverage
# Creates: coverage/lcov.info

# Widget tests only
flutter test --name="Widget"

# Unit tests only  
flutter test test/unit/

# Integration tests
flutter test integration_test/checkout_flow_test.dart
```

---

## 8. Existing Performance Tracking & Benchmarking

### 8.1 Production Performance Monitoring

| Component | Metric | Location | Status |
|-----------|--------|----------|--------|
| Background Tasks | Task Duration (ms) | `background_task_service.dart` | ✅ Implemented |
| AI Requests | Latency (ms) | `ai_request_logger.dart` | ✅ Implemented |
| AI System | Health Metrics | `ai_system_health_monitor.dart` | ✅ Implemented |
| Cache Service | Hit Rate % | `cache_service.dart` | ✅ Implemented |
| Rate Limiter | RPM Status | `ai_service.dart` | ✅ Implemented |

### 8.2 Test-Level Performance Tracking

**Time-Based Tests:**
- Cache expiration tests with `Duration`-based TTL
- Widget animation testing with `pumpAndSettle()`
- Async operation timing with `await Future.delayed()`

**No Dedicated Benchmarking Harness:**
- No `benchmark_test.dart` files found
- No performance regression detection
- No CI/CD performance assertions
- Timing measurements are ad-hoc, not systematic

### 8.3 Metrics Currently Tracked (in production)

```
AI System Metrics:
├── Cache hit rate (target: 60-70%)
├── Request latency (milliseconds)
├── Tokens used per request
├── Error rate by provider
├── Rate limit compliance
├── Response time tier (fast/normal/slow)
└── Daily quota usage

Background Task Metrics:
├── Task execution time (ms)
├── Task success/failure status
└── Result payload

Cache Metrics:
├── Total items
├── Valid items (non-expired)
├── Hit rate percentage
└── Memory usage (MB)
```

---

## 9. Testing Utilities Summary Table

| Utility | Location | Purpose | Key Methods/Classes |
|---------|----------|---------|-------------------|
| **Test Setup** | `test/helpers/test_setup.dart` | Initialization & base classes | `BaseTest`, `BaseFirebaseTest`, `BaseSnapshotTest` |
| **Mock Providers** | `test/helpers/mock_providers.dart` | Firebase & service mocks | `MockFirebaseFirestore`, `MockUser`, `MockAuthService` |
| **Test Fixtures** | `test/fixtures/test_data.dart` | Test data constants | `testProductMap`, `testUserMap`, `testOrderMap` |
| **Widget Support** | `flutter_test` | Widget testing framework | `testWidgets()`, `WidgetTester`, `find` |
| **Unit Testing** | `flutter_test` | Test framework | `test()`, `group()`, `expect()` |
| **Mocking** | `mocktail` | Null-safe mocking | `Mock` class, `when()`, `verify()` |
| **Mock Generation** | `mockito` + `build_runner` | Auto-generate mocks | `@GenerateMocks()`, generator |
| **Riverpod Testing** | `flutter_riverpod` + custom | Provider state testing | `ProviderContainer`, `read()` |
| **Integration** | `integration_test` | E2E testing | E2E workflow tests |
| **State Testing** | `flutter_riverpod` | Async state verification | `AsyncLoading`, `AsyncData`, `AsyncError` |

---

## 10. Gap Analysis & Recommendations

### 10.1 Current Gaps

| Gap | Impact | Recommendation |
|-----|--------|-----------------|
| No systematic benchmarking harness | Can't track performance regression | Create `benchmark_test.dart` with standardized metrics |
| Performance tests not integrated into CI/CD | Regressions not caught automatically | Add performance assertions to GitHub Actions |
| No performance comparison between providers | Can't validate AI fallback strategy | Add latency comparison tests for AI providers |
| Limited memory profiling | Memory leaks hard to detect | Add memory measurement utilities to `test_setup.dart` |
| No load testing framework | Scalability unknown | Create load test harness for cache/pagination |
| Sparse performance decorations in tests | Hard to identify slow tests | Add `@Timeout()` annotations to flaky tests |

### 10.2 Test Infrastructure Completeness

- ✅ **Unit Testing:** Fully implemented with base classes and fixtures
- ✅ **Widget Testing:** 9 comprehensive widget test files
- ✅ **Integration Testing:** 3 integration test files + 1 E2E workflow
- ✅ **Mocking:** Complete Firebase and service mock suite
- ✅ **Fixtures:** Reusable test data across all tests
- ✅ **Provider Testing:** Riverpod container testing pattern
- ⚠️ **Performance Testing:** Only ad-hoc, not systematic
- ⚠️ **Load Testing:** Not implemented
- ⚠️ **Regression Detection:** Not in CI/CD pipeline

---

## 11. Quick Reference: Test Commands

```bash
# Setup & dependencies
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test                                    # All tests
flutter test test/services/                    # Service tests only
flutter test --name="Cache"                    # Pattern matching
flutter test --coverage                        # Generate coverage report
flutter test integration_test/                 # E2E tests only

# Watch mode
flutter pub run build_runner watch              # Regenerate on file change
flutter test --watch                           # Re-run on file change

# Analysis
flutter analyze                                 # Lint
flutter pub outdated                           # Check dependencies
```

---

## 12. File Manifest

### Test Utility Files (3)
- [test/helpers/test_setup.dart](test/helpers/test_setup.dart) - Base classes & initialization
- [test/helpers/mock_providers.dart](test/helpers/mock_providers.dart) - ~25 mock implementations
- [test/fixtures/test_data.dart](test/fixtures/test_data.dart) - Test data constants

### Test Files (54)
**See Section 1 for detailed breakdown by category**

### Generated Files
- `test/unit_services_test.mocks.dart` - Generated mocks
- `test/services/ai_service_test.mocks.dart` - Generated mocks
- `test/services/ai_providers_test.mocks.dart` - Generated mocks
- `test/unit/firestore_service_test.mocks.dart` - Generated mocks
- `test/unit/quota_service_test.mocks.dart` - Generated mocks

### Configuration Files
- `pubspec.yaml` - Dev dependencies (mockito, mocktail, flutter_test, etc.)
- `analysis_options.yaml` - Lint rules
- `flutter_launcher_icons.yaml` - Icon generation (test-related)

---

## Appendix: Core Services Performance Monitoring

### Production Performance Instrumentations Found

1. **Background Task Service**
   - Location: `lib/src/services/background_task_service.dart:61-78`
   - Metric: Task execution time in milliseconds
   - Method: `Stopwatch()..start()` / `elapsed Milliseconds`

2. **AI Request Logger**
   - Location: `lib/src/features/ai/services/ai_request_logger.dart`
   - Metrics: latency (ms), tokens used, provider type
   - Frequency: Per request

3. **AI System Health Monitor**
   - Location: `lib/src/features/ai/services/ai_system_health_monitor.dart`
   - Metrics: cache hit rate, error rate, response times, quota usage
   - Frequency: Real-time streams

4. **Cache Service Statistics**
   - Location: `lib/src/core/services/cache_service.dart`
   - Metrics: total items, valid items, hit rate, memory usage
   - Method: `getStats()` returns CacheStats object

5. **AI Rate Limiter Tracking**
   - Location: `lib/src/features/ai/services/ai_service.dart`
   - Metrics: requests per minute, daily limit status
   - Configuration: 60 req/min, 10K daily max

---

**End of Document**
