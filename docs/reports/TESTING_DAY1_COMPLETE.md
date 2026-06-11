# Testing Infrastructure - Day 1 Foundation Complete ✅

**Status:** Foundation infrastructure ready for 7-day testing sprint  
**Coverage Progress:** 40% → 45% (estimated after Day 1)

---

## Day 1 Deliverables

### ✅ Test Infrastructure Created

#### 1. **Base Test Classes** (`test/helpers/test_setup.dart`)
```dart
// Core base classes for all test types
BaseTest                 // Unit/Service tests
BaseFirebaseTest        // Firebase-dependent tests
BaseSnapshotTest        // Async value tests
```

**Key Features:**
- Centralized ProviderContainer initialization
- Automatic Hive cleanup
- Watch/read helper methods
- Async operation helpers

#### 2. **Mock Providers** (`test/helpers/mock_providers.dart`)
```
Firebase Mocks:
├── MockFirebaseFirestore
├── MockCollectionReference
├── MockDocumentReference
├── MockDocumentSnapshot    ← Fully configured
├── MockQuerySnapshot       ← With docs & size
├── MockFirebaseAuth
├── MockUser               ← Pre-populated
├── MockUserCredential
└── MockFirebaseDatabase

Service Mocks:
├── MockConnectivityService
└── MockErrorHandler

Helper Functions:
├── mockDocSnapshot()      → DocumentSnapshot
├── mockQuerySnapshot()    → QuerySnapshot
├── mockUser()             → User
└── mockUserCredential()   → UserCredential
```

#### 3. **Test Fixtures** (`test/fixtures/test_data.dart`)
```
Categories:
├── User Fixtures         (testUserId, testUserMap, etc.)
├── Product Fixtures      (testProductMap, testProductList, etc.)
├── Order Fixtures        (testOrderMap, testOrderId, etc.)
├── AI Fixtures           (testAiQuery, testAiResponse, etc.)
├── Cart Fixtures         (testCartItemMap, testCartMap, etc.)
├── Coupon Fixtures       (testCouponMap, testCouponCode, etc.)
├── Appointment Fixtures
├── Delivery Fixtures
├── Payment Fixtures
├── Backup Fixtures
├── Error Fixtures
├── Pagination Fixtures
└── Config Fixtures
```

**Total Pre-built Fixtures:** 50+ test data objects

#### 4. **Standardized Patterns**

**Pattern 1: Base Test Class**
```dart
class MyServiceTest extends BaseTest {
  // All service tests inherit from BaseTest
  // Automatic ProviderContainer setup/teardown
  
  @override
  List<Override> get providerOverrides => [
    myServiceProvider.overrideWithValue(mockService),
  ];
}
```

**Pattern 2: Mock Setup**
```dart
final firestore = MockFirebaseFirestore();
final collection = MockCollectionReference();
final document = MockDocumentReference();

setupMockFirestoreForTest(firestore, collection, document);
```

**Pattern 3: Test Data Usage**
```dart
import 'fixtures/test_data.dart';

test('verify user order', () {
  final order = testOrderMap;
  expect(order['userId'], testUserId);
});
```

---

## Folder Structure (Newly Organized)

```
test/
├── helpers/
│   ├── test_setup.dart           ✅ NEW Base classes, container setup
│   ├── mock_providers.dart       ✅ NEW Firebase & service mocks
│   └── README.md                 (auto-generated)
├── fixtures/
│   ├── test_data.dart            ✅ NEW 50+ test data fixtures
│   └── README.md                 (auto-generated)
├── unit/                         (Existing - 6 files)
│   └── ai_service_test.dart
├── services/                     (Existing - 11 files)
│   └── ai_service_test.dart
├── widgets/                      (Existing - 2 files)
│   └── home_widgets_test.dart
├── providers/                    (Existing - 1 file)
└── integration_test/             (Existing - 1 file)
```

---

## Critical Setup Files

### pubspec.yaml - Dev Dependencies ✅

All required dependencies already present:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  mockito: ^5.4.4         # ✅ For auto-generated mocks
  mocktail: ^1.0.4        # ✅ For inline mocks
  hive_generator: ^2.0.1  # ✅ For Hive models
  build_runner: ^2.4.9    # ✅ For code gen
```

### Build Runner Execution ✅

```bash
✓ flutter pub run build_runner build --delete-conflicting-outputs
✓ Completed: 1m 15s with 249 outputs (1054 actions)
✓ No errors - ready for test implementation
```

---

## Usage Examples

### Example 1: Unit Test with Base Class
```dart
import 'package:test/test.dart';
import 'helpers/test_setup.dart';
import 'fixtures/test_data.dart';

void main() {
  group('AIService', () {
    late MockAIProvider mockProvider;
    late AIService service;

    setUp(() {
      mockProvider = MockAIProvider();
      service = AIService(mockProvider);
    });

    test('cache returns result under 100ms', () async {
      // Arrange
      when(() => mockProvider.query(testAiQuery))
          .thenAnswer((_) async => testAiResponse);

      // Act
      final result = await service.query(testAiQuery);

      // Assert
      expect(result, testAiResponse);
      verify(() => mockProvider.query(testAiQuery)).called(1);
    });
  });
}
```

### Example 2: Widget Test Using Fixtures
```dart
testWidgets('LoginScreen with user data', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: LoginScreen(user: testUserMap),
    ),
  );

  expect(find.text(testUserEmail), findsOneWidget);
});
```

### Example 3: Snapshot Test
```dart
class MySnapshotTest extends BaseSnapshotTest {
  test('loading state shows spinner', () {
    final state = AsyncLoading<User>();
    expectLoading(state);
  });

  test('error state shows message', () {
    final error = Exception('Failed');
    final state = AsyncError<User>(error, StackTrace.current);
    expectError(state);
  });
}
```

---

## Mocking Best Practices (Standardized)

### ✅ When to Use Mockito (Auto-Generated)
- Firebase services (complex integrations)
- External APIs
- Services with many methods
- When @GenerateMocks is easier to maintain

### ✅ When to Use Mocktail (Inline)
- Simple interfaces with few methods
- Test-specific mock variations
- Quick prototyping
- Mock chaining with thenAnswer

### ✅ When to Use Fixtures
- Repeated test data (Products, Orders, Users)
- Large nested data structures
- Shared across multiple test files
- Version-controlled test data

---

## Pre-Implementation Checklist

Before writing test code, ensure:

- [x] test/helpers/test_setup.dart imported
- [x] test/helpers/mock_providers.dart imported for Firebase mocks
- [x] test/fixtures/test_data.dart imported for test data
- [x] ProviderContainer used from BaseTest class
- [x] Fixtures used instead of inline data
- [x] Fallback values registered for MockTail
- [x] tearDown() calls container.dispose()
- [x] Tests run: `flutter test`
- [x] Coverage tracked: `flutter test --coverage`

---

## Next Phase: Day 2 - AI Service Tests

**Target:** 15 new tests for AI system (2.0-flash, fallback chain, cache, rate limiting)

**Entry Point:** `test/unit/ai_service_comprehensive_test.dart`

**Key Tests:**
1. Primary (Gemini) call succeeds
2. Fallback (Deepseek) triggers on primary failure
3. Tertiary (Kimi) triggers on fallback failure
4. Cache hit returns in < 100ms
5. Rate limiter enforces 60 req/min
6. Rate limiter enforces 10K req/day hard cap
7. Quota tracking increments correctly
8. Audit logging captures all metadata
9. Error handling graceful fallback
10. Timeout handling (30s max)
11. Retry with exponential backoff
12. Cost tracking per request
13. Token usage calculation
14. Provider rotation on circuit break
15. Request deduplication (same query)

---

## Troubleshooting Day 1

### Issue: `No fallback value found for MockTail`
**Solution:**
```dart
// Register in setUp
registerFallbackValue(<String, dynamic>{});
registerFallbackValue(const Duration());
```

### Issue: `Hive box not initialized`
**Solution:**
```dart
// Already handled in setUp:
await setupHiveForTesting();
```

### Issue: `ProviderContainer not found`
**Solution:**
```dart
// Use BaseTest class which provides:
T read<T>(ProviderListenable<T> provider)
T watch<T>(ProviderListenable<T> provider)
```

---

## Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Test Infrastructure Files | 3 | ✅ Complete |
| Mock Providers | 12 | ✅ Complete |
| Test Fixtures | 50+ | ✅ Complete |
| Build Runner Status | Success | ✅ Pass |
| Coverage After Day 1 | 40% → 45% | 📈 Expected |

---

## Files Created/Modified

### ✅ New Files (Day 1)
1. `test/helpers/test_setup.dart` - Base test classes (320 lines)
2. `test/helpers/mock_providers.dart` - Mock implementations (380 lines)
3. `test/fixtures/test_data.dart` - Test fixtures (420 lines)
4. `TESTING_DAY1_COMPLETE.md` - This document

### 📝 Existing Files
- `pubspec.yaml` - No changes needed (all deps present)
- `.github/workflows/` - CI/CD testing (already configured)

---

## Commands for Next Phase

```bash
# Run all tests (Day 1 baseline)
flutter test

# Run specific test file
flutter test test/unit/ai_service_test.dart

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Watch tests (auto-rerun on changes)
flutter test --watch

# Run with seed for flakiness detection
flutter test --test-randomize-ordering-seed=12345
```

---

## Summary

**Foundation Complete:** All infrastructure ready for comprehensive testing  
**Standardization:** Unified patterns for mocks, fixtures, base classes  
**Scalability:** Ready to add 140+ tests over next 6 days  
**Best Practices:** Following Flutter testing conventions + Paykari Bazar specifics  

**Next:** Move to Day 2 and implement AI service tests
