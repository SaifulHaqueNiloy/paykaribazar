import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ApiQuotaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Map<String, int> _localCache = {};

  String normalizeProviderKey(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('gemini')) return 'gemini';
    if (value.contains('deepseek')) return 'deepseek';
    if (value.contains('kimi') || value.contains('nvidia')) return 'kimi';
    return value;
  }

  /// Check if specific provider has available quota
  Future<bool> hasQuota(String provider) async {
    try {
      final target = normalizeProviderKey(provider);
      final doc = await _db.collection('api_quota').doc(target).get();
      
      if (!doc.exists) return true; // No limit set yet
      
      final data = doc.data()!;
      final used = data['used_today'] ?? 0;
      final limit = data['daily_limit'] ?? 1000;
      
      return used < limit;
    } catch (e) {
      debugPrint('Quota Check Error: $e');
      return true; // Fail open to not block users
    }
  }

  /// Increment usage after a successful API call
  Future<void> incrementUsage(String provider, {int tokens = 1}) async {
    try {
      final target = normalizeProviderKey(provider);
      final docRef = _db.collection('api_quota').doc(target);
      
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (snapshot.exists) {
          final current = snapshot.data()?['used_today'] ?? 0;
          transaction.update(docRef, {
            'used_today': current + tokens,
            'last_used': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(docRef, {
            'provider': target,
            'used_today': tokens,
            'daily_limit': 1500, // Default for new docs
            'last_reset': FieldValue.serverTimestamp(),
          });
        }
      });
      
      _localCache[target] = (_localCache[target] ?? 0) + tokens;
    } catch (e) {
      debugPrint('Quota tracking error: $e');
    }
  }

  /// Mark a provider as exhausted manually or via error response
  Future<void> markExhausted(String provider) async {
    final target = normalizeProviderKey(provider);
    await _db.collection('api_quota').doc(target).update({
      'status': 'exhausted',
      'exhausted_at': FieldValue.serverTimestamp(),
    });
  }

  /// Reset all quotas (usually run by a midnight cloud function or background task)
  Future<void> resetDailyQuota() async {
    final batch = _db.batch();
    final quotas = await _db.collection('api_quota').get();
    
    for (var doc in quotas.docs) {
      batch.update(doc.reference, {
        'used_today': 0,
        'status': 'active',
        'last_reset': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
    _localCache.clear();
  }
}

// Keep existing data models for UI compatibility
class QuotaData {
  final String provider;
  final String keyId;
  final int dailyLimit;
  int usedToday;
  final List<int> hourlyUsage;
  String status;
  final DateTime lastReset;

  QuotaData({
    required this.provider,
    required this.keyId,
    required this.dailyLimit,
    required this.usedToday,
    required this.hourlyUsage,
    required this.status,
    required this.lastReset,
  });

  /// Check if API key has available quota
  bool get hasAvailableQuota => status != 'exhausted' && usedToday < dailyLimit;

  /// Get remaining calls available today
  int get remaining => dailyLimit - usedToday;

  /// Get usage percentage (0-100)
  double get usagePercentage => (usedToday / dailyLimit * 100).clamp(0, 100);

  factory QuotaData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuotaData(
      provider: data['provider'] ?? '',
      keyId: data['keyId'] ?? data['key_id'] ?? '',
      dailyLimit: data['daily_limit'] ?? data['dailyLimit'] ?? 0,
      usedToday: data['used_today'] ?? data['usedToday'] ?? 0,
      hourlyUsage: List<int>.from(data['hourly_usage'] ?? List.filled(24, 0)),
      status: data['status'] ?? 'active',
      lastReset: (data['last_reset'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
