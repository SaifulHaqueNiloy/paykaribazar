import 'package:get_it/get_it.dart';
import 'secure_auth_service.dart';
import 'encryption_service.dart';
import 'api_security_service.dart';
import 'package:flutter/material.dart';

/// Security services initialization
/// Call this in service_initializer.dart during Phase 1 (Core services)
class SecurityInitializer {
  static final getIt = GetIt.instance;

  /// Initialize all security services
  /// This should be called early during app startup (Phase 1)
  static Future<void> initializeSecurityServices() async {
    try {
      debugPrint('🔐 [SecurityInitializer] Starting security services initialization...');

      // 1. Initialize encryption service first (no async)
      if (!getIt.isRegistered<EncryptionService>()) {
        getIt.registerSingleton<EncryptionService>(EncryptionService());
        debugPrint('✅ [SecurityInitializer] EncryptionService registered');
      } else {
        debugPrint('⚠️ [SecurityInitializer] EncryptionService already registered');
      }

      // 2. Initialize API security service (no async)
      if (!getIt.isRegistered<APISecurityService>()) {
        getIt.registerSingleton<APISecurityService>(APISecurityService());
        debugPrint('✅ [SecurityInitializer] APISecurityService registered');
      } else {
        debugPrint('⚠️ [SecurityInitializer] APISecurityService already registered');
      }

      // 3. Initialize secure auth service and check biometric
      if (!getIt.isRegistered<SecureAuthService>()) {
        debugPrint('🔄 [SecurityInitializer] Creating and initializing SecureAuthService...');
        final secureAuthService = SecureAuthService();
        try {
          await secureAuthService.initialize();
          debugPrint('✅ [SecurityInitializer] SecureAuthService initialized (biometric check complete)');
        } catch (initError) {
          debugPrint('⚠️ [SecurityInitializer] SecureAuthService initialization warning: $initError (non-critical)');
          // Non-critical error - app can continue without biometric
        }
        getIt.registerSingleton<SecureAuthService>(secureAuthService);
        debugPrint('✅ [SecurityInitializer] SecureAuthService registered in GetIt');
      } else {
        debugPrint('⚠️ [SecurityInitializer] SecureAuthService already registered');
      }

      debugPrint('🟢 [SecurityInitializer] All security services initialized successfully');
    } catch (e, stack) {
      debugPrint('🔴 [SecurityInitializer] Security initialization FAILED: $e');
      debugPrint('Stack: $stack');
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
