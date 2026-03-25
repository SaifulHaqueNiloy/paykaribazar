import 'package:flutter/foundation.dart';
import '../../di/service_locator.dart';
import '../../core/firebase/firestore_service.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/ai/services/ai_service.dart';
import '../../shared/services/notification_service.dart';
import '../../shared/services/location_service.dart';

/// Validates that all required services are registered in the Service Locator (GetIt)
class ServiceValidator {
  static void validate() {
    debugPrint('--- VALIDATING CORE SERVICES ---');
    
    _check<FirestoreService>('FirestoreService');
    _check<AuthService>('AuthService');
    _check<AIService>('AIService');
    _check<NotificationService>('NotificationService');
    _check<LocationService>('LocationService');

    debugPrint('--- SERVICE VALIDATION COMPLETE ---');
  }

  static void _check<T extends Object>(String name) {
    try {
      if (!getIt.isRegistered<T>()) {
        debugPrint('❌ CRITICAL: $name is NOT registered!');
      } else {
        debugPrint('✅ $name is registered.');
      }
    } catch (e) {
      debugPrint('❌ ERROR validating $name: $e');
    }
  }
}
