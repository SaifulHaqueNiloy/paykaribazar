import 'package:shared_preferences/shared_preferences.dart';
import 'service_locator.dart';

// Core Services
import '../core/services/secrets_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/permission_service.dart';
import '../core/services/error_reporter_service.dart';
import '../core/services/health_check_service.dart';
import '../core/services/security_initializer.dart'; // Security initialization
import '../core/admin/dynamic_feature_control.dart'; // Dynamic UI/Feature Control

// Firebase Services
import '../core/firebase/firebase_core_service.dart';
import '../core/firebase/firebase_billing_monitor.dart';
import '../core/firebase/firestore_service.dart';
import '../core/firebase/firebase_auth_service.dart';
import '../core/firebase/firebase_messaging_service.dart';

// Shared & Feature Services
import '../shared/services/notification_service.dart';
import '../shared/services/location_service.dart';
import '../shared/services/media_service.dart';
import '../shared/services/map_service.dart';
import '../shared/services/update_service.dart';
import '../shared/services/background_task_service.dart';
import '../shared/services/payment_service.dart';
import '../features/auth/services/auth_service.dart';
import '../features/ai/services/ai_service.dart';
import '../features/ai/services/ai_audit_service.dart';
import '../features/ai/services/api_quota_service.dart';
import '../features/ai/services/forecasting_service.dart';
import '../features/commerce/services/cart_service.dart';
import '../features/commerce/services/cart_pos_service.dart';
import '../features/commerce/services/order_service.dart';
import '../features/commerce/services/product_service.dart';
import '../features/wishlist/services/wishlist_service.dart';
import '../features/logistics/services/delivery_service.dart';
import '../features/logistics/services/geofencing_service.dart';
import '../features/qibla/services/compass_service.dart';
import '../services/chat_service.dart';
import '../services/sync_service.dart';
import '../services/notice_service.dart';
import '../services/auto_translation_service.dart';
import '../services/fleet_service.dart';
import '../features/ota/services/ota_service.dart';

class ServiceInitializer {
  static Future<void> initialize() async {
    // Phase 1: Core
    final sharedPrefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<StorageService>(
        () => SharedPrefsService(sharedPrefs));

    getIt.registerLazySingleton<SecretsService>(() => SecretsService({}));
    getIt.registerLazySingleton<ConnectivityService>(
        () => ConnectivityService());
    getIt.registerLazySingleton<PermissionService>(() => PermissionService());
    getIt.registerLazySingleton<ErrorReporterService>(
        () => ErrorReporterService());
    getIt.registerLazySingleton<HealthCheckService>(() => HealthCheckService());
    
    // ⭐ CRITICAL: Initialize security services (encryption, biometric auth, API security)
    // This must be called before auth service is used!
    await SecurityInitializer.initializeSecurityServices();

    // Phase 2: Firebase
    final firebaseCore = FirebaseCoreService();
    await firebaseCore.initialize();
    getIt.registerLazySingleton<FirebaseCoreService>(() => firebaseCore);
    getIt.registerLazySingleton<FirestoreService>(() => FirestoreService());
    getIt.registerLazySingleton<FirebaseAuthService>(
        () => FirebaseAuthService());
    getIt.registerLazySingleton<FirebaseMessagingService>(
        () => FirebaseMessagingService());
    
    // Firebase Billing Monitor (tracks usage and costs)
    final billingMonitor = FirebaseBillingMonitor();
    await billingMonitor.initialize();
    getIt.registerLazySingleton<FirebaseBillingMonitor>(() => billingMonitor);
    
    // Dynamic Feature Control (admin controls for customer app)
    final featureControl = DynamicFeatureControl();
    await featureControl.initialize();
    getIt.registerLazySingleton<DynamicFeatureControl>(() => featureControl);

    // Phase 3: Shared
    final notificationService = NotificationService();
    await notificationService.init();
    getIt.registerLazySingleton<NotificationService>(() => notificationService);

    getIt.registerLazySingleton<LocationService>(() => LocationService());
    getIt.registerLazySingleton<MediaService>(
        () => MediaService(getIt<SecretsService>()));
    getIt.registerLazySingleton<MapService>(() => MapService());
    getIt.registerLazySingleton<UpdateService>(() => UpdateService());
    getIt.registerLazySingleton<BackgroundTaskService>(
        () => BackgroundTaskService());
    getIt.registerLazySingleton<PaymentService>(() => PaymentServiceImpl());
    getIt.registerLazySingleton<FleetService>(() => FleetService());
    
    // Initialize OTA Service
    final otaService = OTAService();
    await otaService.initialize();

    // Phase 4: Feature Services
    getIt.registerLazySingleton<AuthService>(() => AuthService(
          storage: getIt<StorageService>(),
          firestore: getIt<FirestoreService>(),
        ));
    getIt.registerLazySingleton<AIService>(() => AIService(
          firestore: getIt<FirestoreService>(),
          secrets: getIt<SecretsService>(),
        ));
    getIt.registerLazySingleton<AIAuditService>(() => AIAuditService());
    getIt.registerLazySingleton<ApiQuotaService>(() => ApiQuotaService());
    getIt.registerLazySingleton<ForecastingService>(() => ForecastingService());
    getIt.registerLazySingleton<CartService>(() => CartService());
    getIt.registerLazySingleton<CartPosService>(() => CartPosService());
    getIt.registerLazySingleton<OrderService>(() => OrderService());
    getIt.registerLazySingleton<ProductService>(() => ProductService());
    getIt.registerLazySingleton<WishlistService>(() => WishlistService());
    getIt.registerLazySingleton<DeliveryService>(() => DeliveryService());
    getIt.registerLazySingleton<GeofencingService>(() => GeofencingService());
    getIt.registerLazySingleton<CompassService>(
        () => CompassService(getIt<LocationService>()));

    // Additional Services
    getIt.registerLazySingleton<ChatService>(() => ChatService());
    getIt.registerLazySingleton<SyncService>(() => SyncService());
    getIt.registerLazySingleton<NoticeService>(() => NoticeService());
    getIt.registerLazySingleton<AutoTranslationService>(
        () => AutoTranslationService());
    
    // ⭐ SecureAuthService already initialized in Phase 1 via SecurityInitializer
    // No need for duplicate initialization - this was causing GetIt registration issues
  }
}
