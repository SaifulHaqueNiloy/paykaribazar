# 🚀 Paykari Bazar — Long-Run Pro Tips

> এই গাইডটি `paykari_bazar` প্রজেক্টের জন্য বিশেষভাবে তৈরি।
> Architecture, Firebase, Riverpod, Testing, Security, CI/CD — সব কিছু কভার করে।

---

## 📦 1. Firestore — কোয়েরি ও ডেটা স্ট্র্যাটেজি

### ✅ Compound Index তৈরি করো
Firestore-এ একাধিক `where()` + `orderBy()` ব্যবহার করলে **Composite Index** লাগে।
`flutter run` করলে console-এ সরাসরি index-create লিংক দেয় — সেটা মিস করো না।

```dart
// ❌ Index ছাড়া crash করবে
_firestore.collection('orders')
  .where('status', isEqualTo: 'pending')
  .orderBy('createdAt', descending: true);

// ✅ firestore.indexes.json-এ index যোগ করো
```

### ✅ Pagination — `startAfterDocument` ব্যবহার করো
```dart
// প্রতিটি list screen-এ এটা follow করো
Query query = _firestore.collection('products')
  .orderBy('createdAt', descending: true)
  .limit(20);

// পরের page-এর জন্য
if (lastDocument != null) {
  query = query.startAfterDocument(lastDocument!);
}
```

### ✅ Firestore Read কমাও — `select()` দিয়ে Projection
```dart
// ❌ পুরো document পড়া — বেশি bandwidth খরচ
_firestore.collection('products').get();

// ✅ শুধু দরকারী field পড়া
_firestore.collection('products')
  .select(['name', 'price', 'stock'])
  .get();
```

### ✅ Subcollection vs Flat Collection
- **Subcollection** ব্যবহার করো related data-র জন্য (যেমন `orders/{id}/items`)
- কিন্তু **Collection Group Query** দরকার হলে flat রাখাই ভালো
- Deep nesting (3+ level) **এড়িয়ে চলো** — query করা কঠিন হয়

### ✅ `DocumentSnapshot` Cache করো
```dart
// Riverpod-এ StreamProvider দিয়ে real-time cache পাওয়া যায়
final productProvider = StreamProvider.family<Product, String>((ref, id) {
  return FirebaseFirestore.instance
    .doc('products/$id')
    .snapshots()
    .map((snap) => Product.fromJson(snap.data()!));
});
```

### ⚠️ Security Rules ঠিকঠাক রাখো
```
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin-only collections
    match /staff/{doc} {
      allow read, write: if request.auth.token.role == 'admin';
    }
    // User নিজের data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## 🎯 2. Riverpod — State Management Best Practices

### ✅ `ref.watch` vs `ref.read` — সঠিক জায়গায় ব্যবহার করো
```dart
// ✅ build() method-এ watch — reactive
final user = ref.watch(userProvider);

// ✅ Event handler-এ read — একবার পড়ো
onPressed: () => ref.read(cartProvider.notifier).addItem(item),

// ❌ build()-এ read — rebuild হবে না, bug হবে
final user = ref.read(userProvider); // ভুল!
```

### ✅ `select()` দিয়ে Unnecessary Rebuild এড়াও
```dart
// ❌ পুরো user object watch করলে যেকোনো change-এ rebuild হবে
final user = ref.watch(userProvider);
Text(user.name);

// ✅ শুধু name watch করো
final name = ref.watch(userProvider.select((u) => u.name));
Text(name);
```

### ✅ `AsyncNotifier` ব্যবহার করো `StateNotifier` এর বদলে
```dart
// ✅ Modern Riverpod pattern
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return await ref.read(productRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(productRepositoryProvider).getAll()
    );
  }
}

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);
```

### ✅ Provider Dependency Tree পরিষ্কার রাখো
```dart
// ❌ Circular dependency — avoid করো
final aProvider = Provider((ref) => ref.watch(bProvider));
final bProvider = Provider((ref) => ref.watch(aProvider)); // Circular!

// ✅ একমুখী dependency
final repositoryProvider = Provider((ref) => ProductRepository(ref.watch(firestoreProvider)));
final productProvider = AsyncNotifierProvider(...); // uses repositoryProvider
```

### ✅ `keepAlive` ঠিকমতো ব্যবহার করো
```dart
// ব্যবহারকারী screen ছেড়ে গেলেও data রাখতে চাইলে
@Riverpod(keepAlive: true)
Future<List<Category>> categories(CategoriesRef ref) async {
  return await ref.read(categoryRepoProvider).getAll();
}
```

---

## 🧪 3. Testing — Sealed Class ও Mock সমাধান

### ⚠️ Firestore Sealed Class সমস্যা
`DocumentSnapshot` ও `Query` sealed class — সরাসরি mock করা যায় না।
এর সমাধান হলো **Repository Pattern** আরও tight করা:

```dart
// ✅ Interface তৈরি করো — Firestore সরাসরি expose করো না
abstract class IProductRepository {
  Future<List<Product>> getProducts();
  Stream<Product> watchProduct(String id);
}

// Test-এ এই interface mock করো, Firestore নয়
class MockProductRepository extends Mock implements IProductRepository {}
```

### ✅ Placeholder Test এড়িয়ে চলো
`expect(true, isTrue)` বা `expect(true, equals(true))` এর মতো জেনেরিক অ্যাসারশন ব্যবহার না করে, প্রতিটি টেস্টে সুনির্দিষ্টভাবে কী পরীক্ষা করা হচ্ছে তা নিশ্চিত করো। এতে টেস্টগুলো অর্থপূর্ণ হয় এবং প্রকৃত বাগ ধরতে সাহায্য করে।

```dart
// ❌ ভুল: কোনো ভ্যালিডেশন নেই
test('login works', () {
  expect(true, isTrue);
});

// ✅ সঠিক: সুনির্দিষ্ট স্টেট ভ্যালিডেট করা হচ্ছে
test('login works and updates state', () {
  final container = ProviderContainer();
  final authNotifier = container.read(authProvider.notifier);
  authNotifier.login('test@example.com', 'password');
  expect(container.read(authProvider), isA<AuthState.authenticated>());
});
```

### ✅ Mocking-এর জটিলতা ও সমাধান
মক (Mock) কনফিগারেশন, মডেল সিরিয়ালাইজেশন, এনক্রিপশন বা ফায়ারবেস মকের আচরণে সমস্যা হতে পারে। নিশ্চিত করো যে মক অবজেক্টগুলো বাস্তব ডেটা বা আচরণের কাছাকাছি কাজ করে। `MockTail` ব্যবহার করলে `when().thenReturn()` বা `when().thenAnswer()` সঠিকভাবে সেট করো।

### ✅ `fake_cloud_firestore` ব্যবহার করো Integration Test-এ
```yaml
# pubspec.yaml dev_dependencies
fake_cloud_firestore: ^3.0.0
```
```dart
final fakeFirestore = FakeFirebaseFirestore();
// Real Firestore ছাড়াই test করা যাবে
```

### ✅ Widget Test-এ `ProviderScope` Override করো
```dart
testWidgets('shows product list', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productsProvider.overrideWith(() => MockProductsNotifier()),
      ],
      child: const MaterialApp(home: ProductListScreen()),
    ),
  );
  expect(find.text('Mock Product'), findsOneWidget);
});
```

### ✅ Golden Test যোগ করো গুরুত্বপূর্ণ UI-এর জন্য
```dart
testWidgets('product card golden', (tester) async {
  await tester.pumpWidget(...);
  await expectLater(
    find.byType(ProductCard),
    matchesGoldenFile('goldens/product_card.png'),
  );
});
```

---

## ⚡ 4. Performance Optimization

### ✅ `const` Constructor সর্বত্র ব্যবহার করো
```dart
// ✅ Flutter rebuild এড়ায়
const Text('Hello'),
const SizedBox(height: 16),
const Icon(Icons.star),
```

### ✅ ListView-এ `itemExtent` দাও যদি item height fix থাকে
```dart
// ✅ Scroll performance অনেক ভালো হয়
ListView.builder(
  itemExtent: 80.0, // fixed height হলে
  itemCount: products.length,
  itemBuilder: (_, i) => ProductTile(products[i]),
)
```

### ✅ Image Optimization
```dart
// ✅ CachedNetworkImage ব্যবহার করো
CachedNetworkImage(
  imageUrl: product.imageUrl,
  memCacheWidth: 300, // memory cache size limit
  placeholder: (_, __) => const ShimmerWidget(),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
)
```

### ✅ `RepaintBoundary` দাও Heavy Widget-এ
```dart
RepaintBoundary(
  child: AnimatedChartWidget(), // animation isolate করা হলো
)
```

### ✅ Firestore Listener Dispose করো
```dart
// Riverpod StreamProvider automatically dispose করে
// কিন্তু manual listener থাকলে:
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### ✅ Font Loading অপ্টিমাইজ করো
Google Fonts প্যাকেজ ব্যবহার করা সহজ হলেও, পারফরম্যান্স এবং অফলাইন ব্যবহারের জন্য কাস্টম ফন্ট অ্যাসেট হিসেবে যোগ করা ভালো। এতে অ্যাপের স্টার্টআপ টাইম কমে এবং ফন্ট লোডিং-এর জন্য নেটওয়ার্ক রিকোয়েস্ট এড়ানো যায়।

```yaml
# pubspec.yaml-এ
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
```

### ✅ Animation Library-এর বিকল্প ভাবো
Lottie ফাইলগুলো চমৎকার হলেও, অনেক সময় Rive-এর মতো বিকল্পগুলো আরও অপ্টিমাইজড এবং ইন্টারঅ্যাক্টিভ অ্যানিমেশন অফার করে, যা ফাইলের আকার কমাতে এবং পারফরম্যান্স বাড়াতে সাহায্য করতে পারে।


## 🔒 5. Security Best Practices

### ✅ API Key Environment Variable-এ রাখো
```bash
# .env file (git-এ add করো না!)
GEMINI_API_KEY=your_key_here
CLOUDINARY_SECRET=your_secret
```
```dart
// flutter_dotenv ব্যবহার করো
final apiKey = dotenv.env['GEMINI_API_KEY']!;
```

### ✅ Firebase App Check Enable রাখো (ইতিমধ্যে করা আছে ✅)
Production-এ `AndroidProvider.playIntegrity` এবং iOS-এ `AppleProvider.deviceCheck` ব্যবহার করো।

### ✅ Admin Role Server-Side Verify করো
```dart
// ❌ Client-side role check — unsafe
if (user.role == 'admin') { ... }

// ✅ Firebase Custom Claims ব্যবহার করো
// Cloud Function থেকে set করো:
// admin.auth().setCustomUserClaims(uid, { role: 'admin' })

// Flutter-এ verify:
final idTokenResult = await user.getIdTokenResult();
if (idTokenResult.claims?['role'] == 'admin') { ... }
```

### ✅ Sensitive Data Secure Storage-এ রাখো
```dart
// ✅ flutter_secure_storage ব্যবহার করো (ইতিমধ্যে আছে)
await _secureStorage.write(key: 'refresh_token', value: token);
```

### ✅ Input Sanitization
```dart
// ❌ Direct user input Firestore-এ দিও না
_firestore.collection('products').where('name', isEqualTo: userInput);

// ✅ Trim ও validate করো
final sanitized = userInput.trim().toLowerCase();
if (sanitized.length > 100) throw ValidationException('Too long');
```

---

## 🏗️ 6. Architecture — দীর্ঘমেয়াদী পরিষ্কার থাকার উপায়

### ✅ Feature-First Folder Structure মেনে চলো
```
lib/src/features/
  orders/
    data/          # Repository implementations
    domain/        # Models, interfaces
    presentation/  # Screens, widgets, providers
```

### ✅ `barrel export` ফাইল ব্যবহার করো
```dart
// features/orders/orders.dart
export 'data/order_repository.dart';
export 'domain/order_model.dart';
export 'presentation/orders_screen.dart';
```

### ✅ Business Logic Widget-এ রেখো না
```dart
// ❌ Widget-এ business logic
class OrderCard extends StatelessWidget {
  void _calculateDiscount() { /* ভুল */ }
}

// ✅ Notifier বা use case-এ রাখো
class OrderNotifier extends AsyncNotifier<Order> {
  void applyDiscount(double percent) { ... }
}
```

### ✅ Error Handling Centralized করো
```dart
// ✅ Global error type তৈরি করো
sealed class AppError {
  const AppError();
}
class NetworkError extends AppError { final String message; }
class AuthError extends AppError { }
class NotFoundError extends AppError { }

// Provider-এ handle করো
state = AsyncError(NetworkError('No internet'), StackTrace.current);
```

---

## 🤖 7. AI Feature — Quota ও Reliability

### ✅ AI Call-এ Retry + Exponential Backoff যোগ করো
```dart
Future<T> withRetry<T>(Future<T> Function() fn, {int maxAttempts = 3}) async {
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: 2 * attempt)); // backoff
    }
  }
  throw Exception('Max retries exceeded');
}
```

### ✅ AI Quota Track করো Firestore-এ
```dart
// প্রতি user-এর daily AI usage track করো
Future<bool> checkAiQuota(String userId) async {
  final doc = await _firestore
    .collection('ai_usage')
    .doc('${userId}_${DateTime.now().toIso8601String().substring(0, 10)}')
    .get();
  
  final count = doc.data()?['count'] ?? 0;
  return count < 50; // daily limit
}
```

### ✅ AI Response Cache করো
```dart
// একই prompt-এর জন্য বারবার API call না করে cache করো
final cache = <String, String>{};
Future<String> getAiResponse(String prompt) async {
  if (cache.containsKey(prompt)) return cache[prompt]!;
  final response = await _geminiService.generate(prompt);
  cache[prompt] = response;
  return response;
}
```

---

## 🔄 8. CI/CD — Shorebird + GitHub Actions

### ✅ GitHub Actions Workflow তৈরি করো
```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  analyze_and_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter analyze --no-fatal-warnings
      - run: flutter test
```

### ✅ Shorebird Patch শুধু Production-এ করো
```bash
# Bug fix patch — store review ছাড়াই deploy
shorebird patch android --release-version=1.0.0

# নতুন feature → সব সময় নতুন release
shorebird release android
```

### ✅ Flavor ব্যবহার করো dev/staging/prod আলাদা রাখতে
```bash
# Development
flutter run --flavor development -t lib/main_dev.dart

# Production
flutter run --flavor production -t lib/main_prod.dart
```

---

## 🧹 9. Code Quality — দৈনিক অভ্যাস

### ✅ `flutter analyze` প্রতিটি commit-এর আগে
```bash
flutter analyze --no-fatal-warnings
# 0 error, 0 warning হলেই commit করো
```

### ✅ `dart fix --apply` regularly চালাও
```bash
dart fix --apply
# Automated deprecation fixes
```

### ✅ `flutter pub outdated` মাসে একবার চেক করো
```bash
flutter pub outdated
flutter pub upgrade --major-versions # সতর্কতার সাথে
```

### ✅ Dead Code নিয়মিত মুছো
- Unused import → `dart fix` দিয়ে auto-remove
- Unused method → IDE-তে "Find Usages" দিয়ে চেক করো
- Commented-out code → মুছে দাও, git history-তে আছে

### ✅ TODO/FIXME Track করো
```bash
# সব TODO খোঁজো
grep -r "TODO\|FIXME\|HACK" lib/ --include="*.dart"
```

---

## 📊 10. Monitoring ও Analytics

### ✅ Firebase Crashlytics Enable করো
```dart
// main.dart-এ
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

### ✅ Firebase Performance Monitoring যোগ করো
```dart
final trace = FirebasePerformance.instance.newTrace('load_products');
await trace.start();
final products = await _repo.getProducts();
await trace.stop();
```

### ✅ Custom Event Log করো
```dart
// গুরুত্বপূর্ণ business event track করো
await FirebaseAnalytics.instance.logEvent(
  name: 'order_placed',
  parameters: {
    'total_amount': order.total,
    'item_count': order.items.length,
    'payment_method': order.paymentMethod,
  },
);
```

---

## 🗃️ 11. Database Schema — ভবিষ্যত-প্রস্তুত ডিজাইন

### ✅ Version Field রাখো প্রতিটি Document-এ
```dart
// Migration সহজ হবে
class Product {
  final int schemaVersion; // default: 1
  // ...
}

// Firestore-এ
{
  "name": "Rice",
  "price": 100,
  "_v": 1  // schema version
}
```

### ✅ Soft Delete ব্যবহার করো
```dart
// ❌ Hard delete — data recovery নেই
await _firestore.doc('products/$id').delete();

// ✅ Soft delete
await _firestore.doc('products/$id').update({
  'deletedAt': FieldValue.serverTimestamp(),
  'isDeleted': true,
});
```

### ✅ `createdAt` ও `updatedAt` সব document-এ রাখো
```dart
await _firestore.collection('products').add({
  ...product.toJson(),
  'createdAt': FieldValue.serverTimestamp(),
  'updatedAt': FieldValue.serverTimestamp(),
});

// Update-এ
await _firestore.doc('products/$id').update({
  ...changes,
  'updatedAt': FieldValue.serverTimestamp(),
});
```

---

## 🧹 12. Project Debt — Cleanup Strategy (Immediate Action)

### ✅ Analyzer Issues (231 Total) সমাধান করো
বর্তমানে প্রজেক্টে ২৩১টি লিঙ্কিং ইস্যু আছে। এর মধ্যে সবচেয়ে বেশি হলো `use_build_context_synchronously` এবং `unused_local_variable`। 

```dart
// ❌ ভুল (Async গ্যাপে context ব্যবহার)
onPressed: () async {
  await service.doSomething();
  Navigator.pop(context); // dangerous!
}

// ✅ সঠিক (Mounted চেক করো)
onPressed: () async {
  await service.doSomething();
  if (!context.mounted) return;
  Navigator.pop(context);
}
```

### ✅ Redundant Packages ছাঁটাই করো
`pubspec.yaml`-এ `dio` এবং `http` দুটোই আছে। `all_dependencies.md` অনুযায়ী একটি বেছে নেওয়া উচিত। বড় প্রজেক্টের জন্য **Dio** রাখা এবং `http` রিমুভ করা শ্রেয়।

### ✅ Deprecated/Stub ফাইলগুলো ডিলিট করো
`duplicate_empty_files_report.md` অনুযায়ী নিচের ফাইলগুলো দ্রুত ডিলিট করা উচিত কারণ এগুলো ডুপ্লিকেট:
- `lib/src/features/delivery/delivery_dashboard_screen.dart`
- `lib/src/features/staff/staff_team_screen.dart`
- `test/widget_test.dart` (test/widgets/widget_test.dart-এর সাথে ডুপ্লিকেট)

---

## 🎨 13. UI & Theming — Standardization

### ✅ `ThemeExtension` ব্যবহার করো Custom Color-এর জন্য
Material 3-এর বাইরেও অনেক সময় প্রজেক্টের নিজস্ব ব্র্যান্ড কালার লাগে। `ThemeData` পলিউশন এড়াতে `ThemeExtension` সেরা।

```dart
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brandGold;
  final Color successGreen;

  const AppColors({required this.brandGold, required this.successGreen});

  @override
  AppColors copyWith({Color? brandGold, Color? successGreen}) {
    return AppColors(
      brandGold: brandGold ?? this.brandGold,
      successGreen: successGreen ?? this.successGreen,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      brandGold: Color.lerp(brandGold, other.brandGold, t)!,
      successGreen: Color.lerp(successGreen, other.successGreen, t)!,
    );
  }
}
```

---

## 🚦 14. Advanced Riverpod UI Patterns

### ✅ `ref.listen` দিয়ে Snackbar/Dialog দেখাও
`AsyncValue` এর state change অনুযায়ী UI-তে feedback দেওয়ার জন্য `build` এর ভেতর `ref.listen` ব্যবহার করো।

```dart
ref.listen<AsyncValue<void>>(
  loginProvider,
  (previous, next) {
    next.whenOrNull(
      error: (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      },
    );
  },
);
```

---

## 🛣️ 15. Navigation — GoRouter Best Practices

### ✅ Global Redirect (Auth Guard) ব্যবহার করো
ব্যবহারকারী লগইন না থাকলে সরাসরি `/login`-এ পাঠিয়ে দেওয়ার logic Router লেভেলে রাখো।

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';
      return null;
    },
    // routes...
  );
});
```

---

## 🌐 16. Localization (i18n)

### ✅ Hardcoded String এড়িয়ে চলো
`intl` প্যাকেজ ব্যবহার করে সব string `app_en.arb` ও `app_bn.arb` ফাইলে রাখো। এতে ভবিষ্যতে মাল্টি-ল্যাঙ্গুয়েজ সাপোর্ট যোগ করা সহজ হবে।
```dart
// ✅ ব্যবহার
Text(AppLocalizations.of(context)!.helloWorld)
```

---

## 🚦 12. Font Loading ও Animation

### ✅ Font Loading অপ্টিমাইজ করো
Google Fonts প্যাকেজ ব্যবহার করা সহজ হলেও, পারফরম্যান্স এবং অফলাইন ব্যবহারের জন্য কাস্টম ফন্ট অ্যাসেট হিসেবে যোগ করা ভালো। এতে অ্যাপের স্টার্টআপ টাইম কমে এবং ফন্ট লোডিং-এর জন্য নেটওয়ার্ক রিকোয়েস্ট এড়ানো যায়।

```yaml
# pubspec.yaml-এ
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
```

### ✅ Animation Library-এর বিকল্প ভাবো
Lottie ফাইলগুলো চমৎকার হলেও, অনেক সময় Rive-এর মতো বিকল্পগুলো আরও অপ্টিমাইজড এবং ইন্টারঅ্যাক্টিভ অ্যানিমেশন অফার করে, যা ফাইলের আকার কমাতে এবং পারফরম্যান্স বাড়াতে সাহায্য করতে পারে।

---

## ️ 17. Dependency Injection Consolidation

### ✅ GetIt সরিয়ে Riverpod-এ মাইগ্রেট করো
প্রজেক্টে `get_it` এবং `riverpod` দুটোই আছে। ডুপ্লিকেট DI সিস্টেম কোডবেসকে জটিল করে। সব সার্ভিসকে Riverpod Provider-এ রূপান্তর করো।

---

## 🎯 18. Quick Reference — Priority Order

| Priority | টিপস | Impact |
|----------|------|--------|
| 🔴 Critical | Firestore Security Rules | Security |
| 🔴 Critical | Firebase Crashlytics | Stability |
| 🟠 High | Riverpod `select()` | Performance |
| 🟠 High | Cleanup Analyzer Errors | Maintainability |
| 🟠 High | Remove Redundant Packages | Build Size |
| 🟡 Medium | AI Retry + Quota | Reliability |
| 🟡 Medium | GitHub Actions CI | Quality |
| 🟢 Nice-to-have | Golden Tests | UI Confidence |
| 🟢 Nice-to-have | Soft Delete | Data Safety |
| 🟢 Nice-to-have | Custom Font Assets | Startup/Load |
| 🟢 Nice-to-have | Optimized Animations | Performance |

---

> 💡 **মনে রাখো**: এই টিপসগুলো একসাথে implement করতে হবে না।
> Priority অনুযায়ী একটু একটু করে করো। প্রতিটি improvement project-কে আরও শক্তিশালী করবে।
