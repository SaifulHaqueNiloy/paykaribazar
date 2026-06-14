import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'secure_auth_service.dart';
import 'encryption_service.dart';
import 'api_security_service.dart';

/// Security services initialization
/// Call this in service_initializer.dart during Phase 1 (Core services)
class SecurityInitializer {
  static final getIt = GetIt.instance;

  /// Initialize all security services
  /// This should be called early during app startup (Phase 1)
  static Future<void> initializeSecurityServices() async {
    try {
      if (kDebugMode) debugPrint('🔐 [SecurityInitializer] Starting security services initialization...');

      // 1. Initialize encryption service — key from .env
      if (!getIt.isRegistered<EncryptionService>()) {
        final encKey = dotenv.env['ENCRYPTION_KEY'] ?? 'MySecureAES256KeyFor32BytLength!';
        getIt.registerSingleton<EncryptionService>(EncryptionService(encKey));
        if (kDebugMode) debugPrint('✅ [SecurityInitializer] EncryptionService registered');
      }

      // 2. Initialize API security service — credentials from .env
      if (!getIt.isRegistered<APISecurityService>()) {
        final apiKey = dotenv.env['API_KEY'] ?? 'paykari_bazar_api_key';
        final apiSecret = dotenv.env['API_SECRET'] ?? 'paykari_bazar_api_secret_key_1234567890';
        getIt.registerSingleton<APISecurityService>(
          APISecurityService(apiKey: apiKey, apiSecret: apiSecret),
        );
        if (kDebugMode) debugPrint('✅ [SecurityInitializer] APISecurityService registered');
      }

      // 3. Initialize secure auth service and check biometric
      if (!getIt.isRegistered<SecureAuthService>()) {
        if (kDebugMode) debugPrint('🔄 [SecurityInitializer] Creating and initializing SecureAuthService...');
        final secureAuthService = SecureAuthService();
        try {
          await secureAuthService.initialize();
          if (kDebugMode) debugPrint('✅ [SecurityInitializer] SecureAuthService initialized (biometric check complete)');
        } catch (initError) {
          if (kDebugMode) debugPrint('⚠️ [SecurityInitializer] SecureAuthService initialization warning: $initError (non-critical)');
          // Non-critical error - app can continue without biometric
        }
        getIt.registerSingleton<SecureAuthService>(secureAuthService);
        if (kDebugMode) debugPrint('✅ [SecurityInitializer] SecureAuthService registered in GetIt');
      }

      if (kDebugMode) debugPrint('🟢 [SecurityInitializer] All security services initialized successfully');
    } catch (e, stack) {
      if (kDebugMode) debugPrint('🔴 [SecurityInitializer] Security initialization FAILED: $e');
      if (kDebugMode) debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Get instances of security services
  /// These methods safely access GetIt with proper error messages
  static SecureAuthService get secureAuth {
    try {
      return getIt<SecureAuthService>();
    } catch (e) {
      debugPrint('❌ [SecurityInitializer.secureAuth] GetIt lookup failed: $e');
      throw Exception('SecureAuthService not registered in GetIt. Please ensure ServiceInitializer.initialize() was called. Error: $e');
    }
  }

  static EncryptionService get encryption {
    try {
      return getIt<EncryptionService>();
    } catch (e) {
      throw Exception('EncryptionService not registered in GetIt. Error: $e');
    }
  }

  static APISecurityService get apiSecurity {
    try {
      return getIt<APISecurityService>();
    } catch (e) {
      throw Exception('APISecurityService not registered in GetIt. Error: $e');
    }
  }

  /// Verify all services are properly registered
  static bool areAllServicesRegistered() {
    return getIt.isRegistered<SecureAuthService>() &&
        getIt.isRegistered<EncryptionService>() &&
        getIt.isRegistered<APISecurityService>();
  }
}
