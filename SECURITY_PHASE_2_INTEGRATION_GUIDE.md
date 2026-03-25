# 🔐 Security Phase 2: Integration Guide

**Status:** ✅ SERVICES READY | ⏳ INTEGRATION IN PROGRESS  
**Date:** March 24, 2026  
**Objective:** Complete integration of biometric authentication into login and payment flows

---

## 🎯 What's Implemented

### ✅ Services (Phase 1 - Complete)
- **SecureAuthService** - Biometric authentication + secure storage
- **EncryptionService** - AES-256 encryption for sensitive data
- **APISecurityService** - HMAC-SHA256 request signing

### ✅ Screens (Phase 2 - Partial)
- **LoginScreen** - Biometric login button added (needs completion)
- **CheckoutBottomSheet** - Payment biometric verification integrated
- **Firebase Security Rules** - Role-based access control deployed

---

## 📋 Integration Checklist

### 1️⃣ LoginScreen - Biometric Login

**File:** [lib/src/features/auth/login_screen.dart](../lib/src/features/auth/login_screen.dart)

**Current State:**
- ✅ Biometric availability check (`_initBiometric()`)
- ✅ Biometric button in UI (shows only if available)
- ✅ `_handleBiometricLogin()` method partially implemented

**TODO:**

```dart
// INCOMPLETE: _handleBiometricLogin() needs token-based flow

// FIX: Complete biometric login flow
Future<void> _handleBiometricLogin() async {
  try {
    setState(() => _isLoading = true);
    
    final secureAuth = SecurityInitializer.secureAuth;
    
    // Step 1: Biometric verification
    final authenticated = await secureAuth.authenticateForSensitiveOperation(
      localizedReason: _t('loginWithBiometric'),
    );
    
    if (!authenticated) {
      throw Exception(_t('biometricAuthFailed'));
    }
    
    // Step 2: Retrieve stored credentials
    final username = _idCtrl.text.trim();
    if (username.isEmpty) {
      throw Exception(_t('enterUsernameFirst'));
    }
    
    // Step 3: Retrieve stored encrypted password (if saved)
    final storedPassword = await secureAuth.getSecureData('login_password_$username');
    
    if (storedPassword == null) {
      // ℹ️ First login: need manual password entry
      throw Exception(_t('biometricNeedsPasswordSetup'));
    }
    
    // Step 4: Auto-login with stored credentials
    final userCred = await ref.read(authServiceProvider).signIn(
      username,
      storedPassword,
    );
    
    if (userCred?.user?.uid != null) {
      // ✅ Store token securely for future biometric login
      await secureAuth.storeSecureToken(
        'access_token',
        userCred!.user!.uid,
      );
      
      // ✅ Save credentials for next biometric login
      await secureAuth.storeSecureData(
        'login_password_$username',
        storedPassword,
      );
      
      if (mounted) {
        ref.read(navProvider.notifier).setIndex(4);
        context.go('/');
      }
    }
  } catch (e) {
    if (mounted) ErrorHandler.handleError(e.toString());
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

**Testing:**
```bash
# On device/emulator with biometric support
flutter run
# Tap "Login with Fingerprint" button
# Verify biometric prompt appears
# Verify auto-login after successful auth
```

---

### 2️⃣ CheckoutBottomSheet - Payment Verification

**File:** [lib/src/features/commerce/checkout_bottom_sheet.dart](../lib/src/features/commerce/checkout_bottom_sheet.dart)

**Current State:**
- ✅ Biometric verification integrated
- ✅ Encryption of order data
- ✅ Security headers generated

**Status:** ✅ COMPLETE - No changes needed

Verification:
```bash
# Run the app, add items to cart, proceed to checkout
# Should see biometric prompt for payment
# Should see "Order placed securely ✅" message
```

---

### 3️⃣ Additional Screens Needing Biometric Integration

#### 3A. Sensitive Operations (if applicable)
- **Settings Screen** - Biometric for changing password
- **Address Management** - Biometric to add/edit addresses
- **Payment Methods** - Biometric to view saved cards

#### 3B. Example: Settings Screen with Biometric

```dart
// lib/src/features/settings/settings_screen.dart

Future<void> _changePassword() async {
  final secureAuth = SecurityInitializer.secureAuth;
  
  // Require biometric for sensitive operation
  final authenticated = await secureAuth.authenticateForSensitiveOperation(
    localizedReason: 'Verify to change password',
  );
  
  if (!authenticated) return;
  
  // Show password change dialog
  // ...
}
```

---

## 🔑 Secure Credential Storage

### Setup: First Time Login

```dart
// User enters username + password manually
final userCred = await auth.signIn(username, password);

// Save for future biometric login
final secureAuth = SecurityInitializer.secureAuth;
await secureAuth.storeSecureData(
  'login_password_$username', // Key
  password,                     // Value
);

// Also store Firebase token
await secureAuth.storeSecureToken('access_token', userCred.user.uid);
```

### Subsequent Logins: Biometric-Enabled

```dart
// Biometric succeeds → Auto-login
final storedPassword = await secureAuth.getSecureData('login_password_$username');
final userCred = await auth.signIn(username, storedPassword);
// User logged in ✅
```

---

## 🛡️ Security Best Practices

### ✅ DO's

1. **Always authenticate for login**
   ```dart
   await secureAuth.authenticateForSensitiveOperation();
   ```

2. **Store tokens securely**
   ```dart
   await secureAuth.storeSecureToken('key', 'sensitive_value');
   ```

3. **Encrypt payment info**
   ```dart
   final encrypted = encryption.encryptPaymentInfo(cardData);
   ```

4. **Sign API requests**
   ```dart
   final headers = apiSecurity.getSecureHeaders();
   ```

### ❌ DON'Ts

1. **Never store plaintext passwords in SharedPreferences**
   ```dart
   // ❌ WRONG
   prefs.setString('password', password);
   
   // ✅ CORRECT
   secureAuth.storeSecureData('password', password);
   ```

2. **Never trust client-side only**
   ```dart
   // ❌ WRONG - Rely only on app encryption
   
   // ✅ CORRECT - Always validate on server
   verifyWebhookSignature(signature, payload);
   ```

3. **Never commit sensitive keys**
   ```yaml
   # ❌ WRONG
   encryptionKey: 'hardcoded_key_123'
   
   # ✅ CORRECT
   encryptionKey: ${{ secrets.ENCRYPTION_KEY }}
   ```

4. **Never skip biometric for high-value ops**
   ```dart
   // ❌ WRONG
   void placeOrder() {
     // No auth check
   }
   
   // ✅ CORRECT
   await secureAuth.authenticateForPayment();
   ```

---

## 🧪 Testing Security Integration

### Unit Tests

```dart
// test/security_phase_2_test.dart

void main() {
  group('Phase 2 Integration Tests', () {
    test('Biometric login stores credentials securely', () async {
      // 1. Mock biometric
      // 2. Login with biometric
      // 3. Verify credentials stored in secure storage
      // 4. Verify plaintext not in SharedPreferences
    });

    test('Payment verification requires biometric', () async {
      // 1. Mock cart with items
      // 2. Attempt checkout without biometric
      // 3. Verify order fails
      // 4. Complete with biometric
      // 5. Verify order succeeds
    });

    test('Encrypted data cannot be read without key', () async {
      // 1. Encrypt payment info
      // 2. Save to SharedPreferences
      // 3. Try to read raw value
      // 4. Verify it's gibberish (encrypted)
      // 5. Decrypt and verify
    });
  });
}
```

### Integration Tests

```bash
# Run on real device
flutter test integration_test/security_phase_2_test.dart

# Or with specific emulator
flutter test -d emulator-5554 integration_test/security_phase_2_test.dart
```

---

## 📊 Deployment Checklist

### Before Going Live

- [ ] Test on at least 2 Android devices (one with biometric, one without)
- [ ] Test on at least 1 iOS device (if applicable)
- [ ] Verify fallback to manual password entry works
- [ ] Confirm security rules deployed to Firebase
- [ ] Test payment flow end-to-end
- [ ] Verify error messages are user-friendly
- [ ] Check encryption keys are in environment variables
- [ ] Review security rules with team

### Post-Deployment

- [ ] Monitor error logs for security issues
- [ ] Check Firebase security events
- [ ] Verify no plaintext credentials in logs
- [ ] Track user feedback on biometric flow
- [ ] Plan Phase 3 enhancements

---

## 🔄 Phase 2 → Phase 3 Roadmap

### Planned (Weeks 3-4)

**Key Rotation Mechanism**
```dart
// Automatic key rotation every 90 days
class KeyRotationService {
  Future<void> rotateKeys() async {
    // Generate new keys
    // Re-encrypt existing data with new keys
    // Archive old keys
  }
}
```

**Advanced Rate Limiting**
```dart
// DDoS protection
class AdvancedRateLimiter {
  Future<bool> isAllowed(String userId) async {
    // Check request history
    // Implement exponential backoff
    // Alert on suspicious patterns
  }
}
```

**Session Management**
```dart
// Multi-device logout
class SessionManager {
  Future<void> logoutAllDevices(String userId) async {
    // Invalidate all tokens for user
    // Notify user of logout
  }
}
```

---

## 📚 References

- [SecureAuthService](../lib/src/core/services/secure_auth_service.dart) - Full implementation
- [EncryptionService](../lib/src/core/services/encryption_service.dart) - Encryption methods
- [APISecurityService](../lib/src/core/services/api_security_service.dart) - Request signing
- [SECURITY_IMPLEMENTATION_GUIDE.md](../SECURITY_IMPLEMENTATION_GUIDE.md) - Detailed guide

---

## ❓ FAQ

**Q: What if user doesn't have biometric?**  
A: Falls back to regular login. Biometric button only shows if available.

**Q: Can I skip biometric for payments?**  
A: No - it's mandatory for security. Show friendly error if biometric not available.

**Q: How long are credentials stored?**  
A: Until user logs out or clears app data. Biometric tokens expire on app reinstall.

**Q: What if user forgets password?**  
A: They can use "Forgot Password" to reset. Then re-enable biometric on next login.

---

**Last Updated:** March 24, 2026  
**Maintainer:** Security Team  
**Next Review:** April 7, 2026
