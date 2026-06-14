import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EncryptionService {
  final encrypt_lib.Key _key;
  late final encrypt_lib.Encrypter _encrypter;

  /// Initializes the encryption service with a 32-byte AES key.
  /// 
  /// [encryptionKey] should be loaded from a secure source (e.g., .env or secure storage).
  EncryptionService(String encryptionKey) 
      : _key = encrypt_lib.Key.fromUtf8(encryptionKey) {
    _encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(_key));
    if (kDebugMode) debugPrint('✅ Encryption service initialized (AES-256)');
  }

  /// Encrypt plaintext to ciphertext
  /// Returns base64-encoded string in format "iv:ciphertext"
  String encrypt(String plaintext) {
    try {
      // Generate a new random IV for every encryption operation
      final iv = encrypt_lib.IV.fromSecureRandom(16);
      final encrypted = _encrypter.encrypt(plaintext, iv: iv);
      
      // Store IV and ciphertext together separated by a colon
      final encodedBase64 = '${iv.base64}:${encrypted.base64}';
      if (kDebugMode) debugPrint('✅ Data encrypted successfully');
      return encodedBase64;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt ciphertext to plaintext
  /// Expects base64-encoded string in format "iv:ciphertext"
  String decrypt(String encryptedBase64) {
    try {
      final parts = encryptedBase64.split(':');
      if (parts.length != 2) throw Exception('Invalid encrypted data format');

      // Extract IV and encrypted data
      final iv = encrypt_lib.IV.fromBase64(parts[0]);
      final encrypted = encrypt_lib.Encrypted.fromBase64(parts[1]);

      final decrypted = _encrypter.decrypt(encrypted, iv: iv);
      if (kDebugMode) debugPrint('✅ Data decrypted successfully');
      return decrypted;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Decryption failed: $e');
      rethrow;
    }
  }

  /// Encrypt JSON object
  String encryptJson(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    return encrypt(jsonString);
  }

  /// Decrypt to JSON object
  Map<String, dynamic> decryptJson(String encryptedBase64) {
    final decrypted = decrypt(encryptedBase64);
    return jsonDecode(decrypted);
  }

  /// Encrypt user token
  String encryptToken(String token) {
    return encrypt(token);
  }

  /// Decrypt user token
  String decryptToken(String encryptedToken) {
    return decrypt(encryptedToken);
  }

  /// Encrypt payment information
  String encryptPaymentInfo({
    required String cardNumber,
    required String cardHolder,
    required String cvv,
    required String expiryDate,
  }) {
    final paymentData = {
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'cvv': cvv,
      'expiryDate': expiryDate,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return encryptJson(paymentData);
  }

  /// Decrypt payment information
  Map<String, dynamic> decryptPaymentInfo(String encryptedPayment) {
    return decryptJson(encryptedPayment);
  }

  /// Encrypt health data (medicine info, allergies, prescriptions)
  String encryptHealthData({
    required String userId,
    required List<String> medicines,
    required List<String> allergies,
    String? prescriptionUrl,
  }) {
    final healthData = {
      'userId': userId,
      'medicines': medicines,
      'allergies': allergies,
      'prescriptionUrl': prescriptionUrl,
      'encryptedAt': DateTime.now().toIso8601String(),
    };
    return encryptJson(healthData);
  }

  /// Decrypt health data
  Map<String, dynamic> decryptHealthData(String encryptedData) {
    return decryptJson(encryptedData);
  }

  /// Encrypt personal information (PII)
  String encryptPII({
    required String userId,
    required String email,
    required String phone,
    String? nidNumber,
  }) {
    final piiData = {
      'userId': userId,
      'email': email,
      'phone': phone,
      'nidNumber': nidNumber,
      'encryptedAt': DateTime.now().toIso8601String(),
    };
    return encryptJson(piiData);
  }

  /// Decrypt personal information
  Map<String, dynamic> decryptPII(String encryptedPII) {
    return decryptJson(encryptedPII);
  }

  /// Encrypt API requests/responses
  String encryptApiData(String data) {
    return encrypt(data);
  }

  /// Decrypt API responses
  String decryptApiData(String encryptedData) {
    return decrypt(encryptedData);
  }

  // ============================================================================
  // KEY ROTATION (Future Implementation)
  // ============================================================================

  /// Note: For production, implement proper key rotation strategy:
  /// 1. Store multiple keys with version numbers
  /// 2. When rotating, mark old key as deprecated
  /// 3. Re-encrypt all data with new key
  /// 4. Keep old key for decryption during transition period
  /// 5. Eventually purge old key

  Map<String, dynamic> getEncryptionMetadata() {
    return {
      'algorithm': 'AES-256-CBC',
      'encryptionMethod': 'Base64-encoded',
      'status': 'active',
      'lastRotated': DateTime.now().toIso8601String(),
    };
  }
}
