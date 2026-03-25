import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'dart:convert';
import 'package:flutter/material.dart';

/// Service for AES-256 encryption/decryption of sensitive data
/// Uses: User tokens, payment information, personal health data
class EncryptionService {
  // 32-byte key for AES-256 (exactly 32 characters for UTF-8 encoding)
  final _key = encrypt_lib.Key.fromUtf8('MySecureAES256KeyFor32BytLength!');
  final _iv = encrypt_lib.IV.fromUtf8('MySecureIVFor16!');
  late final encrypt_lib.Encrypter _encrypter;

  EncryptionService() {
    _encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(_key));
    debugPrint('✅ Encryption service initialized (AES-256)');
  }

  /// Encrypt plaintext to ciphertext
  /// Returns base64-encoded encrypted data
  String encrypt(String plaintext) {
    try {
      final encrypted = _encrypter.encrypt(plaintext, iv: _iv);
      final encodedBase64 = encrypted.base64;
      debugPrint('✅ Data encrypted successfully');
      return encodedBase64;
    } catch (e) {
      debugPrint('❌ Encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt ciphertext to plaintext
  /// Expects base64-encoded encrypted data
  String decrypt(String encryptedBase64) {
    try {
      final encrypted = encrypt_lib.Encrypted.fromBase64(encryptedBase64);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      debugPrint('✅ Data decrypted successfully');
      return decrypted;
    } catch (e) {
      debugPrint('❌ Decryption failed: $e');
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
