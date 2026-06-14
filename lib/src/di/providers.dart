import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/paths.dart';
import 'service_locator.dart';
import 'dart:async';
import '../core/services/cache_service.dart';
import 'package:flutter/foundation.dart';
import '../services/role_simulator_provider.dart';

// --- MODELS & TYPES ---
export '../core/constants/paths.dart';
export '../features/commerce/domain/cart_model.dart' show CartState, CartItem;
export '../features/ai/domain/ai_work_type.dart';
export '../shared/services/update_service.dart' show UpdateStatus;
export '../features/commerce/providers/cart_provider.dart'
    show
        businessRulesProvider,
        cartProvider,
        cartSubtotalProvider,
        cartMinimumOrderValueProvider,
        cartShortfallProvider,
        cartDeliveryFeeProvider,
        cartDiscountProvider,
        cartPointsDiscountProvider,
        cartTotalProvider,
        CartNotifier,
        CartState;
export '../services/language_provider.dart' show languageProvider;
export '../services/nav_provider.dart' show navProvider;
export '../services/theme_provider.dart' show themeProvider;
export '../core/exceptions/app_exceptions.dart';

// --- SERVICE CLASSES ---
import '../core/firebase/firestore_service.dart';
import '../core/firebase/firebase_billing_monitor.dart';
import '../core/services/health_check_service.dart';
import '../core/services/secrets_service.dart';
import '../shared/services/notification_service.dart';
import '../shared/services/location_service.dart';
import '../shared/services/update_service.dart';
import '../features/auth/services/auth_service.dart';
import '../features/ai/services/ai_service.dart';
import '../features/ai/services/ai_automation_service.dart';
import '../features/ai/services/api_quota_service.dart';
import '../features/commerce/services/loyalty_service.dart';
import '../features/logistics/services/delivery_service.dart';
import '../services/fleet_service.dart';
import '../features/ai/services/forecasting_service.dart';
import '../services/sync_service.dart';
import '../services/notice_service.dart';
import '../services/auto_translation_service.dart';
import '../services/chat_service.dart';
import '../features/qibla/services/compass_service.dart';
import '../features/ota/services/ota_service.dart';
import '../services/backup_service.dart';

// --- PROVIDERS ---
final firestoreService = Provider((ref) => getIt<FirestoreService>());
final firestoreServiceProvider = firestoreService;
final authServiceProvider = Provider((ref) => getIt<AuthService>());
final authProvider = authServiceProvider;
final aiServiceProvider = Provider((ref) => getIt<AIService>());
final loyaltyServiceProvider = Provider((ref) => getIt<LoyaltyService>());
final notificationServiceProvider = Provider((ref) => getIt<NotificationService>());
final locationServiceProvider = Provider((ref) => getIt<LocationService>());
final deliveryServiceProvider = Provider((ref) => getIt<DeliveryService>());
final fleetServiceProvider = Provider((ref) => getIt<FleetService>());
final forecastingServiceProvider = Provider((ref) => getIt<ForecastingService>());
final apiQuotaServiceProvider = Provider((ref) => getIt<ApiQuotaService>());
final billingMonitorProvider =
    Provider((ref) => getIt<FirebaseBillingMonitor>());
import '../services/user_media_service.dart';

final secretsServiceProvider = Provider((ref) => getIt<SecretsService>());
final aiAutomationProvider = Provider((ref) => getIt<AiAutomationService>());
final updateServiceProvider = Provider((ref) => getIt<UpdateService>());
final syncServiceProvider = Provider((ref) => getIt<SyncService>());
final noticeServiceProvider = Provider((ref) => getIt<NoticeService>());
final autoTranslationProvider = Provider((ref) => getIt<AutoTranslationService>());
final chatServiceProvider = Provider((ref) => getIt<ChatService>());
final compassServiceProvider = Provider((ref) => getIt<CompassService>());
final otaServiceProvider = Provider((ref) => OTAService());
final userMediaServiceProvider = Provider((ref) => getIt<UserMediaService>());
final backupServiceProvider = Provider((ref) {
  final secrets = ref.watch(secretsServiceProvider);
  final masterKey = secrets.getSecret('backup_master_key', fallback: 'paykari_bazar_secure_master_key_!');
  return BackupService(masterKey.padRight(32).substring(0, 32));
});


// --- WISHLIST ---
final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<String>>((ref) => WishlistNotifier());
class WishlistNotifier extends StateNotifier<List<String>> {
  WishlistNotifier() : super([]);
  void toggle(String id) {
    if (state.contains(id)) {
      state = state.where((i) => i != id).toList();
    } else {
      state = [...state, id];
    }
  }
}

final authStateProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

/// বর্তমানে যে ইউজার আইডিটি একটিভ আছে (সিমুলেশন সহ)
/// এটি ব্যবহার করলে রিড এবং রাইট উভয়ই সিমুলেটেড ইউজারের ওপর কাজ করবে
final activeUserIdProvider = Provider<String?>((ref) {
  // Logic check: If user is logged out, simulation MUST be null
  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
    if (next.value == null) {
      ref.read(simulatedUserUidProvider.notifier).state = null;
    }
  });

  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) {
    return null;
  }

  final simulatedUid = ref.watch(simulatedUserUidProvider);
  if (simulatedUid != null) return simulatedUid;
  return authUser.uid;
});

final currentUserDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  // Guard simulation and data fetching with actual auth state
  // বাংলা: অথ স্টেট পরিবর্তন হলে সিমুলেশন বা ডেটা ফেচিং গার্ড করা হয়েছে
  final uid = ref.watch(activeUserIdProvider);
  if (uid == null) return Stream.value(null);

  // Support Role Simulation for Admins
  // বাংলা: অ্যাডমিনদের জন্য ইউজার সিমুলেশন সাপোর্ট
  return FirebaseFirestore.instance
      .collection(HubPaths.users)
      .doc(uid)
      .snapshots()
      .map((snap) => snap.data());
});

final actualUserDataProvider = currentUserDataProvider;

final authUserDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance.collection(HubPaths.users).doc(user.uid).snapshots().map((snap) => snap.data());
});

final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // Guarded to prevent PERMISSION_DENIED console logs when logged out or during auto-logout redirection
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(<Map<String, dynamic>>[]);
  final userData = ref.watch(currentUserDataProvider).value;
  final role = userData?['role'] ?? 'customer';
  if (role != 'admin' && role != 'staff') return Stream.value(<Map<String, dynamic>>[]);
  return FirebaseFirestore.instance.collection(HubPaths.users).snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final productsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final cacheService = getIt<CacheService>();
  final controller = StreamController<List<Map<String, dynamic>>>();

  // Load from cache initially as fallback
  cacheService.get<List<dynamic>>('products_cache').then((cached) {
    if (cached != null && !controller.isClosed) {
      final products = cached.map((p) => Map<String, dynamic>.from(p)).toList();
      controller.add(products);
    }
  });

  // Listen to Firestore
  final sub = FirebaseFirestore.instance.collection(HubPaths.products).snapshots().listen(
    (snap) {
      final products = snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      if (products.isNotEmpty) {
        cacheService.set(key: 'products_cache', value: products);
      }
      if (!controller.isClosed) {
        controller.add(products);
      }
    },
    onError: (error) async {
      if (kDebugMode) debugPrint('Firestore products stream error, checking cache fallback: $error');
      final cached = await cacheService.get<List<dynamic>>('products_cache');
      if (cached != null && !controller.isClosed) {
        final products = cached.map((p) => Map<String, dynamic>.from(p)).toList();
        controller.add(products);
      } else if (!controller.isClosed) {
        controller.addError(error);
      }
    },
  );

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});

final categoriesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection(HubPaths.categories).snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final storesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection(HubPaths.stores).orderBy('order').snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final ordersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // Guarded to prevent PERMISSION_DENIED console logs when logged out or during auto-logout redirection
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(<Map<String, dynamic>>[]);
  final userData = ref.watch(currentUserDataProvider).value;
  final role = userData?['role'] ?? 'customer';
  if (role != 'admin' && role != 'staff') return Stream.value(<Map<String, dynamic>>[]);
  return FirebaseFirestore.instance.collection(HubPaths.orders).orderBy('createdAt', descending: true).snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final locationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection(HubPaths.locations).snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final visibleLocationsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref.watch(locationsProvider).whenData((locs) {
    // Treat missing 'isVisible' as true (Visible by default)
    // বাংলা: 'isVisible' ফিল্ড না থাকলে সেটাকে ট্রু (দৃশ্যমান) হিসেবে ধরা হবে
    return locs.where((l) {
      final isVisible = l['isVisible'];
      return isVisible == true || isVisible == null;
    }).toList();
  });
});

// --- ADMIN & MISC ---
final allCommissionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final snap = await FirebaseFirestore.instance.collection('commissions').get();
  return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
});

final groupedAiAuditProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final snap = await FirebaseFirestore.instance.collection('ai_audit_logs').get();
  final docs = snap.docs.map((doc) => doc.data()).toList();
  return {'total': docs.length, 'logs': docs, 'stats': {'success': docs.where((d) => d['status'] == 'success').length, 'failed': docs.where((d) => d['status'] == 'failed').length}};
});

final aiAuditLogsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // Guarded to prevent PERMISSION_DENIED console logs when logged out or during auto-logout redirection
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(<Map<String, dynamic>>[]);
  final userData = ref.watch(currentUserDataProvider).value;
  final role = userData?['role'] ?? 'customer';
  if (role != 'admin') return Stream.value(<Map<String, dynamic>>[]);
  return FirebaseFirestore.instance.collection('ai_audit_logs').orderBy('timestamp', descending: true).snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final apiQuotaStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('settings').doc('api_quota').snapshots().map((snap) {
    final data = snap.data();
    if (data == null || data['keys'] == null) return <Map<String, dynamic>>[];
    return (data['keys'] as List).map((k) => Map<String, dynamic>.from(k)).toList();
  });
});

final featureFlagsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance
      .doc('_system/admin/featureFlags/all')
      .snapshots()
      .map((snap) => snap.data() ?? {});
});

final apiQuotaSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final quotas = ref.watch(apiQuotaStreamProvider).value ?? const [];
  if (quotas.isEmpty) {
    return {
      'totalKeys': 0,
      'activeKeys': 0,
      'exhaustedKeys': 0,
      'totalUsage': 0,
      'totalLimit': 0,
      'usagePercent': 0.0,
    };
  }

  int totalUsage = 0;
  int totalLimit = 0;
  int activeKeys = 0;
  int exhaustedKeys = 0;

  for (final quota in quotas) {
    final used = (quota['used_today'] ?? quota['currentUsage'] ?? 0) as num;
    final limit = (quota['daily_limit'] ?? quota['limit'] ?? 0) as num;
    totalUsage += used.toInt();
    totalLimit += limit.toInt();
    if ((quota['status'] ?? 'active') == 'exhausted') {
      exhaustedKeys += 1;
    } else {
      activeKeys += 1;
    }
  }

  return {
    'totalKeys': quotas.length,
    'activeKeys': activeKeys,
    'exhaustedKeys': exhaustedKeys,
    'totalUsage': totalUsage,
    'totalLimit': totalLimit,
    'usagePercent': totalLimit == 0 ? 0.0 : (totalUsage / totalLimit) * 100,
  };
});

final firebaseBillingMetricsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final monitor = ref.watch(billingMonitorProvider);
  return monitor.getCurrentMetrics();
});

final firebaseUsageMetricsProvider = FutureProvider<UsageMetricsPage>((ref) async {
  final monitor = ref.watch(billingMonitorProvider);
  return monitor.getUsageMetrics(pageSize: 10);
});

final remoteLocalizationProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final snap = await FirebaseFirestore.instance.collection('localization').doc('strings').get();
  return snap.data() ?? {};
});

final appConfigProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance.doc(HubPaths.configDoc).snapshots().map((snap) => snap.data() ?? {});
});

final appSettingsProvider = appConfigProvider;

final loyaltySettingsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance.doc(HubPaths.loyaltyDoc).snapshots().map((snap) => snap.data() ?? {});
});

final healthCheckProvider = FutureProvider<Map<String, dynamic>>((ref) => getIt<HealthCheckService>().checkSystemHealth());

final aiStatusProvider = FutureProvider<Map<String, String>>((ref) async {
  final health = await getIt<HealthCheckService>().checkSystemHealth();
  final aiHealth = await getIt<AIService>().performGlobalSystemCheck();
  return {
    'NEURAL': aiHealth['status']?.toString().toUpperCase() ?? 'OFFLINE',
    'GATEWAY': health['firebaseLive'] == true ? 'ONLINE' : 'OFFLINE',
    'LOAD': aiHealth['neural_load'] ?? '0%',
    'LATENCY': aiHealth['latency'] ?? '0ms',
  };
});

final monthlyTopBuyersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection(HubPaths.users).orderBy('points', descending: true).limit(10).snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final heroRecordsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('hero_records').orderBy('timestamp', descending: true).snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final promoProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('promos').snapshots().map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});
