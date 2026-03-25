import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/paths.dart';

class BusinessConfigService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton pattern
  static final BusinessConfigService _instance = BusinessConfigService._internal();
  factory BusinessConfigService() => _instance;
  BusinessConfigService._internal();

  /// Collection for business rules
  static const String _rulesDoc = 'settings/business_rules';

  /// Default values for safety
  static const Map<String, dynamic> defaults = {
    'wholesale_tiers': {
      '10': 5.0,
      '20': 10.0,
      '50': 15.0,
      '100': 20.0,
    },
    'delivery_fee_base': 50.0,
    'free_delivery_threshold': 1000.0,
    'min_order_value': 1000.0,
    'low_stock_threshold': 5,
  };

  static Map<String, dynamic> mergeWithDefaults(Map<String, dynamic>? raw) {
    return {
      ...defaults,
      ...?raw,
    };
  }

  static double getDoubleRule(
    String key, {
    Map<String, dynamic>? rules,
  }) {
    final dynamic value = mergeWithDefaults(rules)[key];
    return value is num ? value.toDouble() : (defaults[key] as num).toDouble();
  }

  static int getIntRule(
    String key, {
    Map<String, dynamic>? rules,
  }) {
    final dynamic value = mergeWithDefaults(rules)[key];
    return value is num ? value.toInt() : (defaults[key] as num).toInt();
  }

  static Map<String, double> getWholesaleTiers({Map<String, dynamic>? rules}) {
    final dynamic raw = mergeWithDefaults(rules)['wholesale_tiers'];
    if (raw is! Map) {
      return Map<String, double>.from(defaults['wholesale_tiers']! as Map);
    }

    final Map<String, double> normalized = {};
    raw.forEach((key, value) {
      if (value is num) {
        normalized[key.toString()] = value.toDouble();
      }
    });

    return normalized.isEmpty
        ? Map<String, double>.from(defaults['wholesale_tiers']! as Map)
        : normalized;
  }

  /// Fetches all business rules as a stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> get rulesStream {
    return _db.doc(_rulesDoc).snapshots() as Stream<DocumentSnapshot<Map<String, dynamic>>>;
  }

  /// Gets a specific rule value with a fallback
  Future<T> getRule<T>(String key) async {
    try {
      final doc = await _db.doc(_rulesDoc).get();
      final merged = mergeWithDefaults(doc.data());
      if (merged.containsKey(key)) {
        return merged[key] as T;
      }
    } catch (e) {
      print('Error fetching business rule $key: $e');
    }
    return defaults[key] as T;
  }

  /// Updates business rules (Admin use only)
  Future<void> updateRule(String key, dynamic value) async {
    await _db.doc(_rulesDoc).set({key: value}, SetOptions(merge: true));
  }

  /// Initializes default rules in Firestore if they don't exist
  Future<void> ensureDefaults() async {
    final doc = await _db.doc(_rulesDoc).get();
    if (!doc.exists) {
      await _db.doc(_rulesDoc).set(defaults);
    }
  }
}
