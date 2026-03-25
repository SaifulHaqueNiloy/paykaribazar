import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Firebase Billing & Quota Monitor
/// Tracks usage metrics, costs, and quota status for all Firebase services
class FirebaseBillingMonitor {
  static final _instance = FirebaseBillingMonitor._();
  factory FirebaseBillingMonitor() => _instance;
  FirebaseBillingMonitor._();

  final _firestore = FirebaseFirestore.instance;
  final getIt = GetIt.instance;

  static const String _billingCollectionPath = '_system/billing/metrics';
  static const String _quotaCollectionPath = '_system/billing/quotas';
  static const String _usageCollectionPath = '_system/billing/usage';

  /// Billing metrics for tracking
  final Map<String, dynamic> _currentMetrics = {
    'firestoreReads': 0,
    'firestoreWrites': 0,
    'firestoreDeletes': 0,
    'storageOperations': 0,
    'authOperations': 0,
    'estimatedCostUSD': 0.0,
    'lastUpdated': DateTime.now(),
  };

  /// API quotas for monitoring
  final Map<String, APIQuota> _apiQuotas = {};

  /// Initialize billing monitor
  Future<void> initialize() async {
    try {
      debugPrint('💰 [FirebaseBillingMonitor] Initializing...');
      
      // Load previous metrics
      await _loadMetrics();
      
      // Initialize API quota tracking
      await _initializeAPIQuotas();
      
      debugPrint('✅ [FirebaseBillingMonitor] Initialized successfully');
    } catch (e) {
      debugPrint('❌ [FirebaseBillingMonitor] Initialization failed: $e');
      rethrow;
    }
  }

  /// Load metrics from Firestore
  Future<void> _loadMetrics() async {
    try {
      final doc = await _firestore.collection(_billingCollectionPath).doc('current').get();
      if (doc.exists) {
        _currentMetrics.addAll(doc.data() ?? {});
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Failed to load metrics: $e');
    }
  }

  /// Initialize API quota tracking
  Future<void> _initializeAPIQuotas() async {
    try {
      final quotaDocs = await _firestore.collection(_quotaCollectionPath).get();
      for (var doc in quotaDocs.docs) {
        final data = doc.data();
        _apiQuotas[doc.id] = APIQuota.fromMap({...data, 'id': doc.id});
      }
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Failed to initialize quotas: $e');
    }
  }

  /// Record a Firestore read operation
  Future<void> recordFirestoreRead({
    required String collection,
    required int documentCount,
  }) async {
    try {
      _currentMetrics['firestoreReads'] = (_currentMetrics['firestoreReads'] ?? 0) + documentCount;
      _currentMetrics['lastUpdated'] = DateTime.now();
      
      await _recordUsage(UsageRecord(
        type: 'firestore_read',
        quantity: documentCount,
        timestamp: DateTime.now(),
        details: {'collection': collection},
      ));
      
      _updateEstimatedCost();
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Error recording read: $e');
    }
  }

  /// Record a Firestore write operation
  Future<void> recordFirestoreWrite({
    required String collection,
    required int documentCount,
  }) async {
    try {
      _currentMetrics['firestoreWrites'] = (_currentMetrics['firestoreWrites'] ?? 0) + documentCount;
      _currentMetrics['lastUpdated'] = DateTime.now();
      
      await _recordUsage(UsageRecord(
        type: 'firestore_write',
        quantity: documentCount,
        timestamp: DateTime.now(),
        details: {'collection': collection},
      ));
      
      _updateEstimatedCost();
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Error recording write: $e');
    }
  }

  /// Record a Firestore delete operation
  Future<void> recordFirestoreDelete({
    required String collection,
    required int documentCount,
  }) async {
    try {
      _currentMetrics['firestoreDeletes'] = (_currentMetrics['firestoreDeletes'] ?? 0) + documentCount;
      _currentMetrics['lastUpdated'] = DateTime.now();
      
      await _recordUsage(UsageRecord(
        type: 'firestore_delete',
        quantity: documentCount,
        timestamp: DateTime.now(),
        details: {'collection': collection},
      ));
      
      _updateEstimatedCost();
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Error recording delete: $e');
    }
  }

  /// Record storage operation
  Future<void> recordStorageOperation({
    required String operationType, // 'upload', 'download', 'delete'
    required int sizeBytes,
  }) async {
    try {
      _currentMetrics['storageOperations'] = (_currentMetrics['storageOperations'] ?? 0) + 1;
      _currentMetrics['lastUpdated'] = DateTime.now();
      
      await _recordUsage(UsageRecord(
        type: 'storage_$operationType',
        quantity: 1,
        timestamp: DateTime.now(),
        details: {'sizeBytes': sizeBytes},
      ));
      
      _updateEstimatedCost();
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Error recording storage: $e');
    }
  }

  /// Record authentication operation
  Future<void> recordAuthOperation({
    required String operationType, // 'signin', 'signup', 'refresh_token'
    String? details,
  }) async {
    try {
      _currentMetrics['authOperations'] = (_currentMetrics['authOperations'] ?? 0) + 1;
      _currentMetrics['lastUpdated'] = DateTime.now();
      
      await _recordUsage(UsageRecord(
        type: 'auth_$operationType',
        quantity: 1,
        timestamp: DateTime.now(),
        details: {'details': details},
      ));
      
      _updateEstimatedCost();
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Error recording auth: $e');
    }
  }

  /// Record usage event
  Future<void> _recordUsage(UsageRecord record) async {
    try {
      await _firestore
          .collection(_usageCollectionPath)
          .add(record.toMap());
    } catch (e) {
      debugPrint('⚠️ [FirebaseBillingMonitor] Error recording usage: $e');
    }
  }

  /// Update estimated cost based on current usage
  void _updateEstimatedCost() {
    double estimatedCost = 0.0;
    
    // Firestore pricing (as of 2024)
    final reads = _currentMetrics['firestoreReads'] as int? ?? 0;
    final writes = _currentMetrics['firestoreWrites'] as int? ?? 0;
    final deletes = _currentMetrics['firestoreDeletes'] as int? ?? 0;
    
    estimatedCost += (reads * 0.06) / 100000; // $0.06 per 100K reads
    estimatedCost += (writes * 0.18) / 100000; // $0.18 per 100K writes
    estimatedCost += (deletes * 0.02) / 100000; // $0.02 per 100K deletes
    
    _currentMetrics['estimatedCostUSD'] = estimatedCost;
  }

  /// Get current metrics
  Map<String, dynamic> getCurrentMetrics() => Map.from(_currentMetrics);

  /// Get quota status for API
  APIQuota? getQuotaStatus(String apiName) => _apiQuotas[apiName];

  /// Check if quota is exceeded for API
  bool isQuotaExceeded(String apiName) {
    final quota = _apiQuotas[apiName];
    if (quota == null) return false;
    return quota.currentUsage >= quota.limit;
  }

  /// Check if quota is nearing limit (> 80%)
  bool isQuotaNearing(String apiName) {
    final quota = _apiQuotas[apiName];
    if (quota == null) return false;
    return (quota.currentUsage / quota.limit) > 0.8;
  }

  /// Get all quotas
  Map<String, APIQuota> getAllQuotas() => Map.from(_apiQuotas);

  /// Get usage metrics with pagination
  Future<UsageMetricsPage> getUsageMetrics({
    int pageSize = 50,
    DocumentSnapshot? lastDocument,
    String? filterType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _firestore.collection(_usageCollectionPath).orderBy('timestamp', descending: true);

      // Apply filters
      if (filterType != null) {
        query = query.where('type', isEqualTo: filterType);
      }
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate);
      }

      // Apply pagination
      query = query.limit(pageSize + 1); // +1 to check if there are more docs
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final hasMore = snapshot.docs.length > pageSize;
      final docs = snapshot.docs.take(pageSize).toList();

      return UsageMetricsPage(
        records: docs.map((doc) => UsageRecord.fromMap({...doc.data(), 'id': doc.id})).toList(),
        hasMore: hasMore,
        lastDocument: docs.isNotEmpty ? docs.last : null,
        totalCount: docs.length,
      );
    } catch (e) {
      debugPrint('❌ [FirebaseBillingMonitor] Error fetching usage metrics: $e');
      rethrow;
    }
  }

  /// Save metrics to Firestore
  Future<void> persistMetrics() async {
    try {
      await _firestore
          .collection(_billingCollectionPath)
          .doc('current')
          .set(_currentMetrics, SetOptions(merge: true));
      debugPrint('✅ [FirebaseBillingMonitor] Metrics persisted');
    } catch (e) {
      debugPrint('❌ [FirebaseBillingMonitor] Error persisting metrics: $e');
    }
  }

  /// Reset daily metrics
  Future<void> resetDailyMetrics() async {
    try {
      _currentMetrics.clear();
      _currentMetrics.addAll({
        'firestoreReads': 0,
        'firestoreWrites': 0,
        'firestoreDeletes': 0,
        'storageOperations': 0,
        'authOperations': 0,
        'estimatedCostUSD': 0.0,
        'lastUpdated': DateTime.now(),
      });
      await persistMetrics();
      debugPrint('✅ [FirebaseBillingMonitor] Daily metrics reset');
    } catch (e) {
      debugPrint('❌ [FirebaseBillingMonitor] Error resetting metrics: $e');
    }
  }
}

/// API Quota model
class APIQuota {
  final String id;
  final String apiName;
  final int limit;
  final int currentUsage;
  final DateTime? resetDate;
  final bool alertOnExceeded;

  APIQuota({
    required this.id,
    required this.apiName,
    required this.limit,
    required this.currentUsage,
    this.resetDate,
    this.alertOnExceeded = true,
  });

  bool get isExceeded => currentUsage >= limit;
  bool get isNearing => (currentUsage / limit) > 0.8;
  double get percentageUsed => (currentUsage / limit) * 100;

  factory APIQuota.fromMap(Map<String, dynamic> data) {
    return APIQuota(
      id: data['id'] ?? '',
      apiName: data['apiName'] ?? '',
      limit: data['limit'] ?? 0,
      currentUsage: data['currentUsage'] ?? 0,
      resetDate: data['resetDate'] != null ? DateTime.parse(data['resetDate'] as String) : null,
      alertOnExceeded: data['alertOnExceeded'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apiName': apiName,
      'limit': limit,
      'currentUsage': currentUsage,
      'resetDate': resetDate?.toIso8601String(),
      'alertOnExceeded': alertOnExceeded,
    };
  }
}

/// Usage record model
class UsageRecord {
  final String? id;
  final String type;
  final int quantity;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  UsageRecord({
    this.id,
    required this.type,
    required this.quantity,
    required this.timestamp,
    required this.details,
  });

  factory UsageRecord.fromMap(Map<String, dynamic> data) {
    return UsageRecord(
      id: data['id'],
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? 0,
      timestamp: data['timestamp'] != null 
          ? DateTime.parse(data['timestamp'] as String)
          : DateTime.now(),
      details: Map.from(data['details'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'quantity': quantity,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}

/// Paginated usage metrics response
class UsageMetricsPage {
  final List<UsageRecord> records;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final int totalCount;

  UsageMetricsPage({
    required this.records,
    required this.hasMore,
    this.lastDocument,
    required this.totalCount,
  });
}
