# 🔐 Security Implementation Guide

**Status:** ✅ Phase 1 Complete - 3 Security Services Implemented  
**Date:** March 24, 2026  
**Files Created:** 4 new services + Firestore rules

---

## 📋 What's Been Implemented

### 1. **SecureAuthService** ✅
- **File:** `lib/src/core/services/secure_auth_service.dart`
- **Features:**
  - Biometric authentication (fingerprint, face)
  - Secure token storage (encrypted SharedPreferences)
  - Sensitive data encryption
  - API key secure storage
  - Payment credentials management

### 2. **EncryptionService** ✅
- **File:** `lib/src/core/services/encryption_service.dart`
- **Features:**
  - AES-256-CBC encryption
  - Specialized methods for:
    - User tokens
    - Payment information
    - Health data (medicine, allergies)
    - Personal information (PII)
    - API requests/responses

### 3. **APISecurityService** ✅
- **File:** `lib/src/core/services/api_security_service.dart`
- **Features:**
  - HMAC-SHA256 request signing
  - Automatic nonce generation
  - Timestamp validation
  - Payment request signing
  - Webhook verification

### 4. **Firebase Security Rules** ✅
- **File:** `firestore.rules`
- **Features:**
  - User data isolation (only own data accessible)
  - Role-based access (admin, seller, buyer)
  - Product visibility rules
  - Order access control
  - Payment data protection
  - Chat permission management

---

## 🚀 How to Use These Services

### **1. Initialize in App Startup**

In your `main.dart` or `service_initializer.dart`:

```dart
import 'package:paykari_bazar/src/core/services/security_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... other initializations ...
  
  // Initialize security services (EARLY - Phase 1)
  await SecurityInitializer.initializeSecurityServices();
  
  runApp(const MyApp());
}
```

### **2. Use Secure Authentication**

```dart
import 'package:paykari_bazar/src/core/services/security_initializer.dart';

void loginWithBiometric() async {
  final secureAuth = SecurityInitializer.secureAuth;
  
  // Check if biometric is available
  final available = await secureAuth.isBiometricAvailable();
  if (!available) {
    print('Biometric not available');
    return;
  }
  
  // Authenticate user
  final authenticated = await secureAuth.authenticateForPayment(
    localizedReason: 'Verify your identity to login',
  );
  
  if (authenticated) {
    // Proceed with login
    print('✅ User authenticated');
    // Store token securely
    await secureAuth.storeSecureToken('access_token', firebaseToken);
  }
}
```

### **3. Use Encryption for Sensitive Data**

```dart
import 'package:paykari_bazar/src/core/services/security_initializer.dart';

void storeUserToken(String token) {
  final encryption = SecurityInitializer.encryption;
  
  // Encrypt token
  final encryptedToken = encryption.encryptToken(token);
  
  // Store in secure storage
  final secureAuth = SecurityInitializer.secureAuth;
  await secureAuth.storeSecureToken('encrypted_token', encryptedToken);
}

void retrieveUserToken() {
  final secureAuth = SecurityInitializer.secureAuth;
  final encryption = SecurityInitializer.encryption;
  
  // Get encrypted token
  final encryptedToken = await secureAuth.getSecureToken('encrypted_token');
  
  if (encryptedToken != null) {
    // Decrypt token
    final token = encryption.decryptToken(encryptedToken);
    print('Token: $token');
  }
}
```

### **4. Use API Security Headers**

```dart
import 'package:dio/dio.dart';
import 'package:paykari_bazar/src/core/services/security_initializer.dart';

class SecureApiClient {
  final Dio _dio = Dio();

  SecureApiClient() {
    // Add security interceptor
    _dio.interceptors.add(SecurityInterceptor());
  }

  Future<T> get<T>(String endpoint) async {
    final apiSecurity = SecurityInitializer.apiSecurity;
    
    final headers = apiSecurity.getSecureHeaders(endpoint: endpoint);
    final response = await _dio.get(
      endpoint,
      options: Options(headers: headers),
    );
    
    return response.data;
  }

  Future<T> post<T>(String endpoint, Map<String, dynamic> body) async {
    final apiSecurity = SecurityInitializer.apiSecurity;
    
    final bodyJson = jsonEncode(body);
    final headers = apiSecurity.getSecureHeaders(
      endpoint: endpoint,
      body: bodyJson,
    );
    
    final response = await _dio.post(
      endpoint,
      data: body,
      options: Options(headers: headers),
    );
    
    return response.data;
  }
}
```

### **5. Encrypt Payment Information**

```dart
import 'package:paykari_bazar/src/core/services/security_initializer.dart';

void savePaymentMethod({
  required String cardNumber,
  required String cardHolder,
  required String cvv,
  required String expiryDate,
}) {
  final encryption = SecurityInitializer.encryption;
  final secureAuth = SecurityInitializer.secureAuth;
  
  // Encrypt payment details
  final encrypted = encryption.encryptPaymentInfo(
    cardNumber: cardNumber,
    cardHolder: cardHolder,
    cvv: cvv,
    expiryDate: expiryDate,
  );
  
  // Store securely
  await secureAuth.storeSecureData('payment_method', encrypted);
}

void retrievePaymentMethod() async {
  final encryption = SecurityInitializer.encryption;
  final secureAuth = SecurityInitializer.secureAuth;
  
  final encryptedPayment = await secureAuth.getSecureData('payment_method');
  
  if (encryptedPayment != null) {
    final paymentInfo = encryption.decryptPaymentInfo(encryptedPayment);
    print('Card: ${paymentInfo['cardNumber']}');
  }
}
```

### **6. Biometric-Protected Payment**

```dart
Future<void> processPayment(double amount) async {
  final secureAuth = SecurityInitializer.secureAuth;
  
  // Step 1: Authenticate with biometric
  final authenticated = await secureAuth.authenticateForPayment(
    localizedReason: 'Verify payment of ৳$amount',
  );
  
  if (!authenticated) {
    print('Payment cancelled by user');
    return;
  }
  
  // Step 2: Retrieve encrypted payment method
  final paymentMethod = await secureAuth.getSecureData('payment_method');
  if (paymentMethod == null) {
    print('No payment method saved');
    return;
  }
  
  // Step 3: Proceed with payment
  print('✅ Payment authorized');
}
```

---

## 🔧 Integration Checklist

### Login Screen
- [ ] Add biometric login button
- [ ] Store access token securely
- [ ] Encrypt stored credentials

### Payment Screen
- [ ] Require biometric for payment
- [ ] Encrypt card information
- [ ] Sign payment requests
- [ ] Verify webhook signatures

### Cart Screen
- [ ] Encrypt sensitive order data
- [ ] Require biometric on checkout

### User Profile
- [ ] View only in authenticated session
- [ ] Require biometric for password change
- [ ] Encrypt stored personal data

---

## 📊 Security Status

| Feature | Status | Priority |
|---------|--------|----------|
| Biometric Auth | ✅ Ready | High |
| Secure Storage | ✅ Ready | High |
| Data Encryption | ✅ Ready | High |
| API Signing | ✅ Ready | High |
| Firebase Rules | ✅ Ready | High |
| Unit Tests | ⏳ Next | Medium |
| Widget Tests | ⏳ Next | Medium |
| Integration Tests | ⏳ Next | Medium |

---

## 🚨 Important Notes

### Key Management
⚠️ **CRITICAL:** The encryption keys are currently hardcoded. For production:
1. Use Firebase Remote Config for key management
2. Rotate keys monthly
3. Never commit keys to Git
4. Use environment variables
5. Consider Firebase Cloud KMS

### API Credentials
⚠️ **CRITICAL:** API keys should come from:
1. Backend (never client-side)
2. Firebase Cloud Functions
3. Environment variables
4. Secrets manager (GitHub, GitLab, etc.)

### Testing
- Do NOT use real payment credentials in tests
- Mock sensitive operations
- Test with Firebase emulator for security rules

---

## 📝 Next Steps (Sprint 1 Week 2)

1. **Update LoginScreen** - Add biometric option
2. **Update PaymentScreen** - Add biometric verification
3. **Create Security Tests** - Unit and widget tests
4. **Deploy Firebase Rules** - Via Firebase Console
5. **Audit Existing Screens** - Check for plaintext data storage

---

## 📚 Related Files

- Security Rules: `firestore.rules`
- Services:
  - `lib/src/core/services/secure_auth_service.dart`
  - `lib/src/core/services/encryption_service.dart`
  - `lib/src/core/services/api_security_service.dart`
- Initialization: `lib/src/core/services/security_initializer.dart`

---

**Implemented by:** Security Enhancement Sprint 1  
**Review Date:** March 31, 2026
