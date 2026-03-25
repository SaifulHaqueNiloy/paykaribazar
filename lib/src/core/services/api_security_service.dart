import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

/// Service for securing API requests with HMAC-SHA256 signatures
/// Ensures: Request authenticity, integrity, and non-repudiation
///
/// Implementation:
/// 1. Create signature from endpoint + timestamp + nonce + body
/// 2. Sign with API secret using HMAC-SHA256
/// 3. Add to request headers: X-Signature, X-Timestamp, X-Nonce, X-API-Key
class APISecurityService {
  // API credentials - TODO: Move to environment variables / secure storage
  static const String apiKey = 'paykari_bazar_api_key';
  static const String apiSecret = 'paykari_bazar_api_secret_key_1234567890';

  String? _customApiKey;
  String? _customApiSecret;

  APISecurityService({
    String? apiKey,
    String? apiSecret,
  }) {
    _customApiKey = apiKey;
    _customApiSecret = apiSecret;
  }

  /// Get current API key (custom or default)
  String get _activeApiKey => _customApiKey ?? apiKey;

  /// Get current API secret (custom or default)
  String get _activeApiSecret => _customApiSecret ?? apiSecret;

  /// Generate cryptographically secure nonce
  String _generateNonce() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return '${timestamp}_${random}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Create signature from request elements
  String _createSignature({
    required String endpoint,
    required String timestamp,
    required String nonce,
    required String body,
  }) {
    final payloadString = '$endpoint:$timestamp:$nonce:$body';
    final signature = Hmac(sha256, utf8.encode(_activeApiSecret))
        .convert(utf8.encode(payloadString));
    return signature.toString();
  }

  /// Generate secure headers for API request
  Map<String, String> getSecureHeaders({
    required String endpoint, // e.g., "/api/v1/products"
    String body = '', // Request body (empty for GET)
  }) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final nonce = _generateNonce();

      final signature = _createSignature(
        endpoint: endpoint,
        timestamp: timestamp,
        nonce: nonce,
        body: body,
      );

      final headers = {
        'X-API-Key': _activeApiKey,
        'X-Signature': signature,
        'X-Timestamp': timestamp,
        'X-Nonce': nonce,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      debugPrint(
        '✅ Secure headers generated for $endpoint\n'
        '   Signature: ${signature.substring(0, 16)}...',
      );

      return headers;
    } catch (e) {
      debugPrint('❌ Failed to generate secure headers: $e');
      rethrow;
    }
  }

  /// Verify incoming response signature (server validation)
  /// Use this to verify webhook/callback signatures from API
  bool verifyResponseSignature({
    required String signature,
    required String timestamp,
    required String nonce,
    required String body,
  }) {
    try {
      final expectedSignature = _createSignature(
        endpoint: 'response',
        timestamp: timestamp,
        nonce: nonce,
        body: body,
      );

      final isValid = signature == expectedSignature;
      isValid
          ? debugPrint('✅ Response signature verified')
          : debugPrint('❌ Response signature verification FAILED');

      return isValid;
    } catch (e) {
      debugPrint('❌ Signature verification error: $e');
      return false;
    }
  }

  // ============================================================================
  // DIO INTERCEPTOR FOR AUTOMATIC SIGNING
  // ============================================================================

  /// Create headers for Dio HTTP client with automatic signing
  /// Use in Dio interceptor for all requests
  Map<String, String> getHeadersForDio({
    required String endpoint,
    String method = 'GET',
    String? body,
  }) {
    final headers = getSecureHeaders(
      endpoint: endpoint,
      body: body ?? '',
    );

    // Add standard headers
    headers['User-Agent'] = 'PaykariBazar/1.0.0 (Security-Enhanced)';
    headers['Accept-Language'] = 'en-US,en;q=0.9';

    return headers;
  }

  // ============================================================================
  // SIGNATURE DEBUGGING
  // ============================================================================

  /// Get signature details for debugging (DO NOT USE IN PRODUCTION)
  Map<String, String> getSignatureDebugInfo({
    required String endpoint,
    required String body,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final nonce = _generateNonce();
    final signature = _createSignature(
      endpoint: endpoint,
      timestamp: timestamp,
      nonce: nonce,
      body: body,
    );

    return {
      'endpoint': endpoint,
      'timestamp': timestamp,
      'nonce': nonce,
      'signature': signature,
      'payload': '$endpoint:$timestamp:$nonce:$body',
    };
  }

  /// Update API credentials (for multi-tenant support)
  void updateCredentials({required String apiKey, required String apiSecret}) {
    _customApiKey = apiKey;
    _customApiSecret = apiSecret;
    debugPrint('✅ API credentials updated');
  }

  /// Reset to default credentials
  void resetCredentials() {
    _customApiKey = null;
    _customApiSecret = null;
    debugPrint('✅ API credentials reset to default');
  }

  // ============================================================================
  // RATE LIMITING HEADERS (Recommended)
  // ============================================================================

  /// Get headers with rate-limiting info
  /// This helps the server track API usage patterns
  Map<String, String> getHeadersWithRateLimitInfo({
    required String endpoint,
    required String userId,
    String body = '',
  }) {
    final baseHeaders = getSecureHeaders(endpoint: endpoint, body: body);

    baseHeaders['X-User-ID'] = userId;
    baseHeaders['X-Request-Date'] = DateTime.now().toIso8601String();

    return baseHeaders;
  }

  // ============================================================================
  // PAYMENT REQUEST SIGNING
  // ============================================================================

  /// Sign payment gateway requests (for bKash, Nagad, Rocket etc.)
  Map<String, dynamic> signPaymentRequest({
    required String gatewayName, // 'bkash', 'nagad', 'rocket'
    required String merchantId,
    required String amount,
    required String transactionId,
  }) {
    final payload = '$merchantId:$amount:$transactionId';
    final signature = Hmac(sha256, utf8.encode(_activeApiSecret))
        .convert(utf8.encode(payload));

    return {
      'gateway': gatewayName,
      'merchantId': merchantId,
      'amount': amount,
      'transactionId': transactionId,
      'signature': signature.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================================
  // WEBHOOK VERIFICATION
  // ============================================================================

  /// Verify payment gateway webhook signatures
  bool verifyWebhookSignature({
    required String signature,
    required String webhookBody,
  }) {
    try {
      final expectedSignature = Hmac(sha256, utf8.encode(_activeApiSecret))
          .convert(utf8.encode(webhookBody));

      return signature == expectedSignature.toString();
    } catch (e) {
      debugPrint('❌ Webhook signature verification failed: $e');
      return false;
    }
  }
}
