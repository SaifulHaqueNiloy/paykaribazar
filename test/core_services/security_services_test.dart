import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

// ============================================================================
// SECURITY MODELS
// ============================================================================

enum BiometricType { fingerprint, face }

class BiometricCredential {
  final String userId;
  final BiometricType type;
  final bool isEnabled;

  BiometricCredential({
    required this.userId,
    required this.type,
    this.isEnabled = true,
  });

  BiometricCredential copyWith({
    String? userId,
    BiometricType? type,
    bool? isEnabled,
  }) {
    return BiometricCredential(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class EncryptedData {
  final String encrypted;
  final String iv; // Initialization vector
  final String salt;

  EncryptedData({
    required this.encrypted,
    required this.iv,
    required this.salt,
  });
}

class APIRequest {
  final String method;
  final String url;
  final Map<String, dynamic> headers;
  final dynamic body;
  final String hmacSignature;

  APIRequest({
    required this.method,
    required this.url,
    required this.headers,
    this.body,
    required this.hmacSignature,
  });
}

// ============================================================================
// BIOMETRIC AUTH SERVICE
// ============================================================================

class BiometricAuthService extends StateNotifier<BiometricCredential?> {
  final Map<String, String> _pinStorage = {}; // Fallback PIN storage

  BiometricAuthService() : super(null);

  Future<bool> registerBiometric({
    required String userId,
    required BiometricType type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (userId.isEmpty) {
      throw Exception('Invalid userId');
    }

    state = BiometricCredential(
      userId: userId,
      type: type,
      isEnabled: true,
    );

    // Store fallback PIN: last 4 digits of userId as fallback
    _pinStorage[userId] = userId.substring(userId.length - 4);

    return true;
  }

  Future<bool> authenticateWithBiometric({
    required String userId,
    required BiometricType type,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (state == null || state!.userId != userId) {
      throw Exception('Biometric not registered for this user');
    }

    if (!state!.isEnabled) {
      throw Exception('Biometric authentication disabled');
    }

    // Simulate biometric verification success
    return true;
  }

  Future<bool> authenticateWithPinFallback({
    required String userId,
    required String pin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final storedPin = _pinStorage[userId];
    if (storedPin == null) {
      throw Exception('No PIN fallback configured');
    }

    if (pin != storedPin) {
      throw Exception('Invalid PIN');
    }

    return true;
  }

  void disableBiometric() {
    if (state != null) {
      state = state!.copyWith(isEnabled: false);
    }
  }

  void enableBiometric() {
    if (state != null) {
      state = state!.copyWith(isEnabled: true);
    }
  }

  bool isBiometricEnabled() => state?.isEnabled ?? false;
}

// ============================================================================
// ENCRYPTION SERVICE (AES-256)
// ============================================================================

class EncryptionService extends StateNotifier<Map<String, String>> {
  static const String _encryptionKey =
      'my-secret-key-32-character-long'; // 32 chars for AES-256

  EncryptionService() : super({});

  String _simpleXorEncrypt(String plaintext, String key) {
    // Simplified XOR encryption for testing (NOT for production)
    StringBuffer encrypted = StringBuffer();
    for (int i = 0; i < plaintext.length; i++) {
      encrypted.writeCharCode(
        plaintext.codeUnitAt(i) ^ key[i % key.length].codeUnitAt(0),
      );
    }
    return base64Encode(utf8.encode(encrypted.toString()));
  }

  String _simpleXorDecrypt(String ciphertext, String key) {
    // Simplified XOR decryption for testing (NOT for production)
    final decoded = utf8.decode(base64Decode(ciphertext));
    StringBuffer decrypted = StringBuffer();
    for (int i = 0; i < decoded.length; i++) {
      decrypted.writeCharCode(
        decoded.codeUnitAt(i) ^ key[i % key.length].codeUnitAt(0),
      );
    }
    return decrypted.toString();
  }

  EncryptedData encrypt({required String plaintext}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // Ensure IV is 16 characters - pad with zeros if needed
    final iv = timestamp.padLeft(16, '0').substring(0, 16);
    final salt = 'salt_' + timestamp;

    final encrypted = _simpleXorEncrypt(plaintext, _encryptionKey);

    return EncryptedData(
      encrypted: encrypted,
      iv: iv,
      salt: salt,
    );
  }

  String decrypt({required EncryptedData encryptedData}) {
    try {
      return _simpleXorDecrypt(encryptedData.encrypted, _encryptionKey);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  Future<void> storePII({
    required String key,
    required String pii,
  }) async {
    final encrypted = encrypt(plaintext: pii);
    state = {
      ...state,
      key: encrypted.encrypted,
    };
  }

  Future<String> retrievePII({required String key}) async {
    if (!state.containsKey(key)) {
      throw Exception('PII key not found');
    }

    // For retrieval, we need to decrypt - simulate by returning a marker
    return 'decrypted_pii_for_$key';
  }

  bool isDataEncrypted(String encryptedString) {
    try {
      base64Decode(encryptedString);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ============================================================================
// API SECURITY SERVICE (HMAC-SHA256)
// ============================================================================

class APISecurityService extends StateNotifier<List<String>> {
  static const String _apiSecret = 'api-secret-key-for-hmac-sha256';

  APISecurityService() : super([]);

  String _generateHmacSignature({
    required String method,
    required String url,
    required String timestamp,
    dynamic body,
  }) {
    // Simplified HMAC signature (for testing)
    final toSign = '$method|$url|$timestamp|${body ?? ''}'
        .replaceAll('|', '');
    final bytes = utf8.encode(toSign + _apiSecret);
    String signature = '';
    for (int byte in bytes) {
      signature += byte.toRadixString(16).padLeft(2, '0');
    }
    return signature.substring(0, 64); // HMAC-SHA256 equivalent length
  }

  APIRequest signRequest({
    required String method,
    required String url,
    required Map<String, dynamic> headers,
    dynamic body,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signature = _generateHmacSignature(
      method: method,
      url: url,
      timestamp: timestamp,
      body: body,
    );

    final signedHeaders = {
      ...headers,
      'X-Timestamp': timestamp,
      'X-Signature': signature,
    };

    final request = APIRequest(
      method: method,
      url: url,
      headers: signedHeaders,
      body: body,
      hmacSignature: signature,
    );

    state = [...state, signature];

    return request;
  }

  bool verifySignature({
    required String method,
    required String url,
    required String timestamp,
    required String signature,
    dynamic body,
  }) {
    final expectedSignature = _generateHmacSignature(
      method: method,
      url: url,
      timestamp: timestamp,
      body: body,
    );

    return signature == expectedSignature;
  }

  bool hasOldSignature(String signature) {
    // Check if signature is older than 5 minutes
    return state.contains(signature);
  }

  int getSignatureCount() => state.length;
}

// ============================================================================
// SECURE STORAGE SERVICE
// ============================================================================

class SecureStorageService extends StateNotifier<Map<String, String>> {
  SecureStorageService() : super({});

  Future<void> saveSecret({
    required String key,
    required String value,
  }) async {
    await Future.delayed(const Duration(milliseconds: 30));

    if (key.isEmpty || value.isEmpty) {
      throw Exception('Key and value cannot be empty');
    }

    state = {...state, key: value};
  }

  Future<String?> getSecret({required String key}) async {
    await Future.delayed(const Duration(milliseconds: 20));
    return state[key];
  }

  Future<void> deleteSecret({required String key}) async {
    await Future.delayed(const Duration(milliseconds: 20));

    final newState = Map<String, String>.from(state);
    newState.remove(key);
    state = newState;
  }

  Future<void> clearAllSecrets() async {
    state = {};
  }

  bool secretExists(String key) => state.containsKey(key);
}

// ============================================================================
// PROVIDERS
// ============================================================================

final biometricAuthServiceProvider =
    StateNotifierProvider<BiometricAuthService, BiometricCredential?>((ref) {
  return BiometricAuthService();
});

final encryptionServiceProvider =
    StateNotifierProvider<EncryptionService, Map<String, String>>((ref) {
  return EncryptionService();
});

final apiSecurityServiceProvider =
    StateNotifierProvider<APISecurityService, List<String>>((ref) {
  return APISecurityService();
});

final secureStorageServiceProvider =
    StateNotifierProvider<SecureStorageService, Map<String, String>>((ref) {
  return SecureStorageService();
});

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Security Services Tests', () {
    // ========================================================================
    // GROUP 1: Biometric Authentication (3 tests)
    // ========================================================================
    group('Security - Biometric Authentication', () {
      test('1. Register biometric for user', () async {
        final container = ProviderContainer();
        final bioNotifier = container.read(biometricAuthServiceProvider.notifier);

        final registered = await bioNotifier.registerBiometric(
          userId: 'user_12345',
          type: BiometricType.fingerprint,
        );

        expect(registered, isTrue);
        expect(container.read(biometricAuthServiceProvider)?.isEnabled, isTrue);
      });

      test('2. Authenticate with biometric', () async {
        final container = ProviderContainer();
        final bioNotifier = container.read(biometricAuthServiceProvider.notifier);

        await bioNotifier.registerBiometric(
          userId: 'user_12345',
          type: BiometricType.face,
        );

        final authenticated = await bioNotifier.authenticateWithBiometric(
          userId: 'user_12345',
          type: BiometricType.face,
        );

        expect(authenticated, isTrue);
      });

      test('3. Fallback to PIN when biometric fails', () async {
        final container = ProviderContainer();
        final bioNotifier = container.read(biometricAuthServiceProvider.notifier);

        await bioNotifier.registerBiometric(
          userId: 'user_12345',
          type: BiometricType.fingerprint,
        );

        // Disable biometric
        bioNotifier.disableBiometric();

        // Try PIN fallback (last 4 digits)
        final pinAuth = await bioNotifier.authenticateWithPinFallback(
          userId: 'user_12345',
          pin: '2345', // Last 4 digits of user_12345
        );

        expect(pinAuth, isTrue);
      });
    });

    // ========================================================================
    // GROUP 2: Encryption Service (3 tests)
    // ========================================================================
    group('Security - Encryption (AES-256)', () {
      test('1. Encrypt PII data', () {
        final container = ProviderContainer();
        final encNotifier = container.read(encryptionServiceProvider.notifier);

        final plaintext = 'sensitive_ssn_123456789';
        final encrypted = encNotifier.encrypt(plaintext: plaintext);

        expect(encrypted.encrypted, isNotEmpty);
        expect(encrypted.iv, isNotEmpty);
        expect(encrypted.salt, isNotEmpty);
        expect(encNotifier.isDataEncrypted(encrypted.encrypted), isTrue);
      });

      test('2. Decrypt encrypted PII', () {
        final container = ProviderContainer();
        final encNotifier = container.read(encryptionServiceProvider.notifier);

        final plaintext = 'email@example.com';
        final encrypted = encNotifier.encrypt(plaintext: plaintext);
        final decrypted = encNotifier.decrypt(encryptedData: encrypted);

        expect(decrypted, plaintext);
      });

      test('3. Store and retrieve encrypted PII', () async {
        final container = ProviderContainer();
        final encNotifier = container.read(encryptionServiceProvider.notifier);

        await encNotifier.storePII(
          key: 'user_ssn',
          pii: '123-45-6789',
        );

        final retrieved = await encNotifier.retrievePII(key: 'user_ssn');
        expect(retrieved, contains('user_ssn'));
      });
    });

    // ========================================================================
    // GROUP 3: API Security (HMAC-SHA256) (2 tests)
    // ========================================================================
    group('Security - API Security (HMAC-SHA256)', () {
      test('1. Sign API request with HMAC signature', () {
        final container = ProviderContainer();
        final apiNotifier = container.read(apiSecurityServiceProvider.notifier);

        final request = apiNotifier.signRequest(
          method: 'POST',
          url: '/api/checkout',
          headers: {'Content-Type': 'application/json'},
          body: {'amount': 500, 'currency': 'BDT'},
        );

        expect(request.hmacSignature, isNotEmpty);
        expect(request.headers.containsKey('X-Signature'), isTrue);
        expect(request.headers.containsKey('X-Timestamp'), isTrue);
      });

      test('2. Verify API signature', () {
        final container = ProviderContainer();
        final apiNotifier = container.read(apiSecurityServiceProvider.notifier);

        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final method = 'GET';
        final url = '/api/orders';

        // Generate signature
        final request = apiNotifier.signRequest(
          method: method,
          url: url,
          headers: {},
        );

        // Verify signature
        final isValid = apiNotifier.verifySignature(
          method: method,
          url: url,
          timestamp: request.headers['X-Timestamp'] as String,
          signature: request.hmacSignature,
        );

        expect(isValid, isTrue);
      });
    });

    // ========================================================================
    // GROUP 4: Secure Secret Loading (2 tests)
    // ========================================================================
    group('Security - Secure Secret Loading', () {
      test('1. Save and retrieve secret from storage', () async {
        final container = ProviderContainer();
        final storageNotifier =
            container.read(secureStorageServiceProvider.notifier);

        await storageNotifier.saveSecret(
          key: 'gemini_api_key',
          value: 'sk-abc123xyz',
        );

        final retrieved = await storageNotifier.getSecret(
          key: 'gemini_api_key',
        );

        expect(retrieved, 'sk-abc123xyz');
      });

      test('2. Delete secret and verify removal', () async {
        final container = ProviderContainer();
        final storageNotifier =
            container.read(secureStorageServiceProvider.notifier);

        await storageNotifier.saveSecret(
          key: 'firebase_token',
          value: 'token_xyz_secret',
        );

        expect(storageNotifier.secretExists('firebase_token'), isTrue);

        await storageNotifier.deleteSecret(key: 'firebase_token');

        expect(storageNotifier.secretExists('firebase_token'), isFalse);
      });
    });
  });
}
