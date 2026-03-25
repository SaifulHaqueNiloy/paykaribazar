---
description: "Use when implementing authentication, encryption, or API security in Paykari Bazar. Covers SecureAuthService (biometric), EncryptionService (AES-256), APISecurityService (HMAC-SHA256), and secure secret loading from .env."
name: "Security Implementation"
applyTo: "lib/src/core/services/auth/**,lib/src/core/services/encryption/**,lib/src/shared/services/**"
---

# Security Implementation Guide

Paykari Bazar implements three security layers. Follow each pattern to maintain compliance with project standards.

## Layer 1: Authentication (SecureAuthService)

### Biometric Auth with Graceful Fallback

All payment and sensitive operations require biometric verification. Use this pattern:

```dart
final authService = ref.watch(secureAuthServiceProvider);

try {
  // Attempt biometric authentication
  final isAuthenticated = await authService.authenticateWithBiometric(
    reason: 'Verify payment of \$${amount}',
    allowDeviceCredential: true, // PIN fallback if no biometric
  );
  
  if (!isAuthenticated) {
    throw SecurityException('Biometric authentication failed');
  }
  
  // Proceed with sensitive operation
  await processPayment(amount);
} on BiometricException catch (e) {
  // Graceful fallback: offer PIN entry or password
  final manualAuth = await showPinEntryDialog();
  if (manualAuth) {
    await processPayment(amount);
  }
} on SecurityException catch (e) {
  // Log and show user-friendly error
  await auditService.logSecurityEvent('auth_failed', reason: e.message);
  rethrow;
}
```

### Login Pattern

```dart
// Firebase Auth + local biometric enrollment
final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Enroll biometric for future sessions
if (await authService.canEnrollBiometric()) {
  await authService.enrollBiometric(
    userId: user.uid,
    email: user.email ?? '',
  );
}
```

**Key Rules:**
- Never ask for payment password in plaintext
- Biometric must be available before every payment
- Fallback to PIN (numeric only, not full password)
- Log all auth failures for fraud detection

---

## Layer 2: Data Encryption (EncryptionService)

### AES-256 Encryption for PII

All personally identifiable information (PII) must be encrypted at rest. Use `EncryptionService`:

```dart
final encryptionService = ref.watch(encryptionServiceProvider);

// Encrypt sensitive fields
final sensitiveData = {
  'ssn': userSSN,
  'bankAccount': bankAccountNumber,
  'phone': userPhone,
};

final encrypted = await encryptionService.encryptAES256(
  data: jsonEncode(sensitiveData),
  keyId: 'user_${userId}', // Per-user key
);

// Store encrypted version in Firestore
await firestore.collection('users').doc(userId).update({
  'pii': encrypted,
  'piiEncryptedAt': FieldValue.serverTimestamp(),
});
```

### Decryption Pattern

```dart
// Retrieve and decrypt
final doc = await firestore.collection('users').doc(userId).get();
final encrypted = doc['pii'] as String;

final decrypted = await encryptionService.decryptAES256(
  ciphertext: encrypted,
  keyId: 'user_${userId}',
);

final sensitiveData = jsonDecode(decrypted) as Map<String, dynamic>;
final ssn = sensitiveData['ssn'] as String; // Now usable
```

**Key Rules:**
- Encrypt before storing to Firestore/disk
- Use per-user key IDs when possible (better security isolation)
- Never log or display decrypted PII
- Rotate keys quarterly via `encryptionService.rotateKeys()`

---

## Layer 3: API Security (APISecurityService)

### HMAC-SHA256 Signing for Requests

All backend API requests must be signed with HMAC-SHA256 to prevent tampering:

```dart
final apiSecurityService = ref.watch(apiSecurityServiceProvider);

// Create request with signature
final endpoint = '/api/v1/orders';
final method = 'POST';
final body = jsonEncode({
  'productId': '12345',
  'quantity': 2,
});

final signature = await apiSecurityService.signRequest(
  method: method,
  endpoint: endpoint,
  body: body,
  timestamp: DateTime.now(),
);

// Send with headers
final response = await http.post(
  Uri.parse('https://api.paykari.com$endpoint'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'X-Signature': signature,
    'X-Timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
  },
  body: body,
);

// Verify response signature
final verified = await apiSecurityService.verifySignature(
  response.body,
  signature: response.headers['x-signature'] ?? '',
);

if (!verified) {
  throw SecurityException('Response signature verification failed');
}
```

**Key Rules:**
- Include timestamp in signature to prevent replay attacks
- Server must verify timestamp is within ±5 minutes
- Sign: `method + endpoint + body + timestamp`
- Never modify signed request after signing
- Both client and server must use same secret from `.env`

---

## Secure Secret Management

### Loading Secrets from .env

Never hardcode API keys, Firebase config, or encryption keys. Use `SecretService`:

```dart
final secretService = ref.watch(secretServiceProvider);

// Loaded automatically from .env on app startup
final geminiKey = secretService.get('GEMINI_API_KEY');
final firebaseProjectId = secretService.get('FIREBASE_PROJECT_ID');
final hmacSecret = secretService.get('HMAC_SECRET_KEY');

if (geminiKey == null) {
  throw Exception('GEMINI_API_KEY not found in .env');
}
```

### .env File Template

Create `.env` in project root (add to `.gitignore`):

```
# Firebase
FIREBASE_PROJECT_ID=paykari-bazar
FIREBASE_API_KEY=AIzaSyD...
FIREBASE_APP_ID=1:123456:android:abcd...

# AI Providers
GEMINI_API_KEY=AIzaSyD...
DEEPSEEK_API_KEY=sk-...
KIMI_API_KEY=sk-...

# Security
HMAC_SECRET_KEY=your-256-bit-hex-key
AES_ENCRYPTION_KEY=your-256-bit-hex-key

# Other
GOOGLE_MAPS_API_KEY=AIzaSyD...
```

Never commit `.env` to version control. Store secrets in GitHub Secrets for CI/CD.

---

## Role-Based Access Control (RBAC)

### Firestore Security Rules

Roles are enforced at the database level. Roles: `user`, `admin`, `staff`, `reseller`

```javascript
// lib/core/services/auth/firestore.rules

match /users/{userId} {
  allow read: if request.auth.uid == userId;
  allow write: if request.auth.uid == userId;
}

match /admin/dashboard/{doc=**} {
  allow read, write: if request.auth.token.role == 'admin';
}

match /orders/{orderId} {
  allow read: if 
    request.auth.uid == resource.data.userId ||
    request.auth.token.role in ['admin', 'staff'];
  allow write: if request.auth.token.role in ['admin', 'staff'];
}
```

### Custom Claims in Firebase Auth

Set role on token via Cloud Function:

```dart
// Flutter: Verify role from custom claims
final idTokenResult = await user.getIdTokenResult(true);
final role = idTokenResult.claims?['role'] as String? ?? 'user';

if (role != 'admin') {
  throw UnauthorizedException('Admin role required');
}
```

---

## Security Checklist

- [ ] All PII fields encrypted with AES-256
- [ ] Payment operations require biometric auth
- [ ] API requests signed with HMAC-SHA256
- [ ] Secrets loaded from `.env`, never hardcoded
- [ ] Firestore rules enforce role-based access
- [ ] No plaintext passwords in logs or UI
- [ ] Biometric fallback handling implemented
- [ ] Audit logging for all auth/payment events
- [ ] `.env` file in `.gitignore`
- [ ] Secrets rotated quarterly

---

## Testing Security Features

```dart
test('Biometric auth fails gracefully', () async {
  when(authService.authenticateWithBiometric(...))
      .thenThrow(BiometricException('Sensor unavailable'));
  
  expect(
    () => authService.validatePayment(100),
    throwsA(isA<BiometricException>()),
  );
});

test('PII is encrypted before storage', () async {
  await encryptionService.encryptAES256(
    data: 'sensitive_data',
    keyId: 'test_key',
  );
  
  verify(firestore.collection('users').doc(any).update(
    argThat((update) => (update as Map).containsKey('pii')),
  )).called(1);
});

test('API requests are HMAC-signed', () async {
  final signature = await apiSecurityService.signRequest(...);
  expect(signature, isNotEmpty);
  expect(signature.length, greaterThan(20)); // HMAC-SHA256 hex
});
```
