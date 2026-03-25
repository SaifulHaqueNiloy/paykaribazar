import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants/paths.dart';
import '../di/service_locator.dart';

// --- MODELS & TYPES ---
export 'constants/paths.dart';
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

// --- SERVICE CLASSES ---
import 'firebase/firestore_service.dart';
import 'firebase/firebase_billing_monitor.dart';
import 'services/health_check_service.dart';
import 'services/secrets_service.dart';
import '../shared/services/notification_service.dart';
import '../shared/services/location_service.dart';
import '../shared/services/update_service.dart';
import '../features/auth/services/auth_service.dart';
import '../features/ai/services/ai_service.dart';
import '../features/ai/services/ai_automation_service.dart';
import '../features/ai/services/api_quota_service.dart';
import '../features/commerce/services/loyalty_service.dart';
import '../features/logistics/services/delivery_service.dart';
import '../features/ai/services/forecasting_service.dart';
import '../services/sync_service.dart';
import '../services/notice_service.dart';
import '../services/auto_translation_service.dart';
import '../services/chat_service.dart';

// --- PROVIDERS ---
final firestoreService = Provider((ref) => getIt<FirestoreService>());
final firestoreServiceProvider = firestoreService;
final authServiceProvider = Provider((ref) => getIt<AuthService>());
final authProvider = authServiceProvider;
final aiServiceProvider = Provider((ref) => getIt<AIService>());
final loyaltyServiceProvider = Provider((ref) => getIt<LoyaltyService>());
final notificationServiceProvider =
    Provider((ref) => getIt<NotificationService>());
final locationServiceProvider = Provider((ref) => getIt<LocationService>());
final deliveryServiceProvider = Provider((ref) => getIt<DeliveryService>());
final forecastingServiceProvider =
    Provider((ref) => getIt<ForecastingService>());
final apiQuotaServiceProvider = Provider((ref) => getIt<ApiQuotaService>());
final billingMonitorProvider =
    Provider((ref) => getIt<FirebaseBillingMonitor>());
final secretsServiceProvider = Provider((ref) => getIt<SecretsService>());
final aiAutomationProvider = Provider((ref) => getIt<AiAutomationService>());
final updateServiceProvider = Provider((ref) => getIt<UpdateService>());
final syncServiceProvider = Provider((ref) => getIt<SyncService>());
final noticeServiceProvider = Provider((ref) => getIt<NoticeService>());
final autoTranslationProvider =
    Provider((ref) => getIt<AutoTranslationService>());
final chatServiceProvider = Provider((ref) => getIt<ChatService>());

// --- WISHLIST ---
final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<String>>(
    (ref) => WishlistNotifier());

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

// --- DATA STREAMS ---
final authStateProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

final currentUserDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection(HubPaths.users)
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.data());
});

final actualUserDataProvider = currentUserDataProvider;

final allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection(HubPaths.users).snapshots().map(
      (snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final productsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(HubPaths.products)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final categoriesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(HubPaths.categories)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final storesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(HubPaths.stores)
      .orderBy('order')
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final ordersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(HubPaths.orders)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final locationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(HubPaths.locations)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final visibleLocationsProvider =
    Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ref
      .watch(locationsProvider)
      .whenData((locs) => locs.where((l) => l['isVisible'] == true).toList());
});

// --- ADMIN & MISC ---
final allCommissionsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final snap = await FirebaseFirestore.instance.collection('commissions').get();
  return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
});

final groupedAiAuditProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final snap =
      await FirebaseFirestore.instance.collection('ai_audit_logs').get();
  final docs = snap.docs.map((doc) => doc.data()).toList();
  return {
    'total': docs.length,
    'logs': docs,
    'stats': {
      'success': docs.where((d) => d['status'] == 'success').length,
      'failed': docs.where((d) => d['status'] == 'failed').length
    }
  };
});

final aiAuditLogsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('ai_audit_logs')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final apiQuotaStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('api_quota')
      .snapshots()
      .map((snap) {
    final data = snap.data();
    if (data == null || data['keys'] == null) return <Map<String, dynamic>>[];
    return (data['keys'] as List)
        .map((k) => Map<String, dynamic>.from(k))
        .toList();
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

final firebaseBillingMetricsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final monitor = ref.watch(billingMonitorProvider);
  return monitor.getCurrentMetrics();
});

final firebaseUsageMetricsProvider =
    FutureProvider<UsageMetricsPage>((ref) async {
  final monitor = ref.watch(billingMonitorProvider);
  return monitor.getUsageMetrics(pageSize: 10);
});

final remoteLocalizationProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection('localization')
      .doc('strings')
      .get();
  return snap.data() ?? {};
});

final appConfigProvider = StreamProvider<Map<String, dynamic>>((ref) {
  const path = HubPaths.configDoc;
  return FirebaseFirestore.instance
      .doc(path)
      .snapshots()
      .map((snap) => snap.data() ?? {});
});

final appSettingsProvider = appConfigProvider;

final loyaltySettingsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance
      .doc(HubPaths.loyaltyDoc)
      .snapshots()
      .map((snap) => snap.data() ?? {});
});

final healthCheckProvider = FutureProvider<Map<String, dynamic>>(
    (ref) => getIt<HealthCheckService>().checkSystemHealth());

final aiStatusProvider = FutureProvider<Map<String, String>>((ref) async {
  final health = await getIt<HealthCheckService>().checkSystemHealth();
  final aiHealth = await getIt<AIService>().performGlobalSystemCheck();
  return {
    'NEURAL': aiHealth['status']?.toString().toUpperCase() ?? 'OFFLINE',
    'GATEWAY': health['connectivity'] == true ? 'ONLINE' : 'OFFLINE',
    'LOAD': aiHealth['neural_load'] ?? '0%',
    'LATENCY': aiHealth['latency'] ?? '0ms'
  };
});

final monthlyTopBuyersProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(HubPaths.users)
      .orderBy('points', descending: true)
      .limit(10)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final heroRecordsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('hero_records')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});

final promoProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('promos').snapshots().map(
      (snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
});
