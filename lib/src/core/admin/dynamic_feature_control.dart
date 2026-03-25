import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Dynamic Feature Control System
/// Allows admins to enable/disable features and control UI elements in customer app
class DynamicFeatureControl {
  static final _instance = DynamicFeatureControl._();
  factory DynamicFeatureControl() => _instance;
  DynamicFeatureControl._();

  final _firestore = FirebaseFirestore.instance;
  final getIt = GetIt.instance;

  static const String _featureFlagsPath = '_system/admin/featureFlags';
  static const String _uiControlsPath = '_system/admin/uiControls';
  static const String _brandingPath = '_system/admin/branding';

  /// Cached feature flags
  final Map<String, FeatureFlag> _featureFlags = {};

  /// Cached UI controls
  final Map<String, UIControl> _uiControls = {};

  /// Cached branding
  BrandingConfig? _branding;

  /// Feature flag change listeners
  final Map<String, Function(FeatureFlag)> _flagListeners = {};

  /// Initialize feature control system
  Future<void> initialize() async {
    try {
      debugPrint('🎛️ [DynamicFeatureControl] Initializing...');

      // Load default configurations
      await _loadFeatureFlags();
      await _loadUIControls();
      await _loadBrandingConfig();

      // Subscribe to real-time updates
      _subscribeToFeatureFlagUpdates();
      _subscribeToUIControlUpdates();
      _subscribeToBrandingUpdates();

      debugPrint('✅ [DynamicFeatureControl] Initialized successfully');
    } catch (e) {
      debugPrint('❌ [DynamicFeatureControl] Initialization failed: $e');
      rethrow;
    }
  }

  /// Load all feature flags from Firestore
  Future<void> _loadFeatureFlags() async {
    try {
      final doc = await _firestore.collection(_featureFlagsPath).doc('all').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        data.forEach((key, value) {
          if (value is Map) {
            _featureFlags[key] = FeatureFlag.fromMap({...Map<String, dynamic>.from(value), 'id': key});
          }
        });
      }
      debugPrint('✅ [DynamicFeatureControl] Loaded ${_featureFlags.length} feature flags');
    } catch (e) {
      debugPrint('⚠️ [DynamicFeatureControl] Error loading feature flags: $e');
    }
  }

  /// Load UI controls from Firestore
  Future<void> _loadUIControls() async {
    try {
      final doc = await _firestore.collection(_uiControlsPath).doc('all').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        data.forEach((key, value) {
          if (value is Map) {
            _uiControls[key] = UIControl.fromMap({...Map<String, dynamic>.from(value), 'id': key});
          }
        });
      }
      debugPrint('✅ [DynamicFeatureControl] Loaded ${_uiControls.length} UI controls');
    } catch (e) {
      debugPrint('⚠️ [DynamicFeatureControl] Error loading UI controls: $e');
    }
  }

  /// Load branding configuration
  Future<void> _loadBrandingConfig() async {
    try {
      final doc = await _firestore.collection(_brandingPath).doc('current').get();
      if (doc.exists) {
        _branding = BrandingConfig.fromMap({...doc.data() ?? {}});
        debugPrint('✅ [DynamicFeatureControl] Loaded branding config');
      } else {
        _branding = BrandingConfig.defaultConfig();
      }
    } catch (e) {
      debugPrint('⚠️ [DynamicFeatureControl] Error loading branding: $e');
    }
  }

  /// Subscribe to real-time feature flag updates
  void _subscribeToFeatureFlagUpdates() {
    try {
      _firestore.collection(_featureFlagsPath).doc('all').snapshots().listen((doc) {
        if (doc.exists) {
          final data = doc.data() ?? {};
          data.forEach((key, value) {
            if (value is Map) {
              final flag = FeatureFlag.fromMap({...Map<String, dynamic>.from(value), 'id': key});
              _featureFlags[key] = flag;
              _flagListeners[key]?.call(flag);
            }
          });
        }
      });
    } catch (e) {
      debugPrint('⚠️ [DynamicFeatureControl] Error subscribing to flag updates: $e');
    }
  }

  /// Subscribe to real-time UI control updates
  void _subscribeToUIControlUpdates() {
    try {
      _firestore.collection(_uiControlsPath).doc('all').snapshots().listen((doc) {
        if (doc.exists) {
          final data = doc.data() ?? {};
          data.forEach((key, value) {
            if (value is Map) {
              _uiControls[key] = UIControl.fromMap({...Map<String, dynamic>.from(value), 'id': key});
            }
          });
        }
      });
    } catch (e) {
      debugPrint('⚠️ [DynamicFeatureControl] Error subscribing to UI updates: $e');
    }
  }

  /// Subscribe to real-time branding updates
  void _subscribeToBrandingUpdates() {
    try {
      _firestore.collection(_brandingPath).doc('current').snapshots().listen((doc) {
        if (doc.exists) {
          _branding = BrandingConfig.fromMap({...doc.data() ?? {}});
        }
      });
    } catch (e) {
      debugPrint('⚠️ [DynamicFeatureControl] Error subscribing to branding updates: $e');
    }
  }

  // ============= FEATURE FLAG METHODS =============

  /// Check if feature is enabled
  bool isFeatureEnabled(String featureId) {
    final flag = _featureFlags[featureId];
    return flag?.enabled ?? false;
  }

  /// Get feature flag details
  FeatureFlag? getFeatureFlag(String featureId) {
    return _featureFlags[featureId];
  }

  /// Enable feature
  Future<void> enableFeature(String featureId, {String? reason}) async {
    try {
      await _firestore.collection(_featureFlagsPath).doc('all').set({
        featureId: {
          'enabled': true,
          'enabledAt': DateTime.now().toIso8601String(),
          'lastModifiedBy': 'admin',
          'reason': reason,
        }
      }, SetOptions(merge: true));
      debugPrint('✅ Feature "$featureId" enabled');
    } catch (e) {
      debugPrint('❌ Error enabling feature: $e');
      rethrow;
    }
  }

  /// Disable feature
  Future<void> disableFeature(String featureId, {String? reason}) async {
    try {
      await _firestore.collection(_featureFlagsPath).doc('all').set({
        featureId: {
          'enabled': false,
          'disabledAt': DateTime.now().toIso8601String(),
          'lastModifiedBy': 'admin',
          'reason': reason,
        }
      }, SetOptions(merge: true));
      debugPrint('✅ Feature "$featureId" disabled');
    } catch (e) {
      debugPrint('❌ Error disabling feature: $e');
      rethrow;
    }
  }

  /// Listen to feature flag changes
  void onFeatureFlagChanged(String featureId, Function(FeatureFlag) callback) {
    _flagListeners[featureId] = callback;
  }

  /// Get all feature flags
  Map<String, FeatureFlag> getAllFeatureFlags() {
    return Map.from(_featureFlags);
  }

  // ============= UI CONTROL METHODS =============

  /// Check if UI element is visible
  bool isUIElementVisible(String elementId) {
    final control = _uiControls[elementId];
    return control?.visible ?? true;
  }

  /// Get UI control details
  UIControl? getUIControl(String elementId) {
    return _uiControls[elementId];
  }

  /// Show UI element
  Future<void> showUIElement(String elementId) async {
    try {
      await _firestore.collection(_uiControlsPath).doc('all').set({
        elementId: {
          'visible': true,
          'lastModified': DateTime.now().toIso8601String(),
        }
      }, SetOptions(merge: true));
      debugPrint('✅ UI element "$elementId" shown');
    } catch (e) {
      debugPrint('❌ Error showing UI element: $e');
      rethrow;
    }
  }

  /// Hide UI element
  Future<void> hideUIElement(String elementId) async {
    try {
      await _firestore.collection(_uiControlsPath).doc('all').set({
        elementId: {
          'visible': false,
          'lastModified': DateTime.now().toIso8601String(),
        }
      }, SetOptions(merge: true));
      debugPrint('✅ UI element "$elementId" hidden');
    } catch (e) {
      debugPrint('❌ Error hiding UI element: $e');
      rethrow;
    }
  }

  /// Update UI element style/colors
  Future<void> updateUIElementStyle(String elementId, UIStyle style) async {
    try {
      await _firestore.collection(_uiControlsPath).doc('all').set({
        elementId: {
          'style': style.toMap(),
          'lastModified': DateTime.now().toIso8601String(),
        }
      }, SetOptions(merge: true));
      debugPrint('✅ UI element "$elementId" style updated');
    } catch (e) {
      debugPrint('❌ Error updating UI element style: $e');
      rethrow;
    }
  }

  /// Get all UI controls
  Map<String, UIControl> getAllUIControls() {
    return Map.from(_uiControls);
  }

  // ============= BRANDING METHODS =============

  /// Get current branding config
  BrandingConfig? getBrandingConfig() {
    return _branding;
  }

  /// Update branding colors
  Future<void> updateBrandingColors({
    required String primaryColor,
    required String secondaryColor,
    required String accentColor,
  }) async {
    try {
      final branding = _branding ?? BrandingConfig.defaultConfig();
      branding.primaryColor = primaryColor;
      branding.secondaryColor = secondaryColor;
      branding.accentColor = accentColor;

      await _firestore.collection(_brandingPath).doc('current').set(
        branding.toMap(),
        SetOptions(merge: true),
      );
      debugPrint('✅ Branding colors updated');
    } catch (e) {
      debugPrint('❌ Error updating branding: $e');
      rethrow;
    }
  }

  /// Update branding texts
  Future<void> updateBrandingTexts({
    required String appName,
    required String appTagline,
    required String contactEmail,
    required String contactPhone,
  }) async {
    try {
      final branding = _branding ?? BrandingConfig.defaultConfig();
      branding.appName = appName;
      branding.appTagline = appTagline;
      branding.contactEmail = contactEmail;
      branding.contactPhone = contactPhone;

      await _firestore.collection(_brandingPath).doc('current').set(
        branding.toMap(),
        SetOptions(merge: true),
      );
      debugPrint('✅ Branding texts updated');
    } catch (e) {
      debugPrint('❌ Error updating branding texts: $e');
      rethrow;
    }
  }

  /// Upload branding logo
  Future<void> updateBrandingLogo(String logoUrl) async {
    try {
      final branding = _branding ?? BrandingConfig.defaultConfig();
      branding.logoUrl = logoUrl;

      await _firestore.collection(_brandingPath).doc('current').set(
        branding.toMap(),
        SetOptions(merge: true),
      );
      debugPrint('✅ Branding logo updated');
    } catch (e) {
      debugPrint('❌ Error updating branding logo: $e');
      rethrow;
    }
  }

  /// Batch update feature flags (for bulk operations)
  Future<void> batchUpdateFeatureFlags(Map<String, bool> updates) async {
    try {
      final Map<String, dynamic> batchData = {};
      updates.forEach((featureId, enabled) {
        batchData[featureId] = {
          'enabled': enabled,
          'lastModified': DateTime.now().toIso8601String(),
        };
      });

      await _firestore.collection(_featureFlagsPath).doc('all').set(
        batchData,
        SetOptions(merge: true),
      );
      debugPrint('✅ Batch updated ${updates.length} feature flags');
    } catch (e) {
      debugPrint('❌ Error batch updating features: $e');
      rethrow;
    }
  }
}

/// Feature Flag Model
class FeatureFlag {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final DateTime? enabledAt;
  final DateTime? disabledAt;
  final String? reason;
  final String? lastModifiedBy;

  FeatureFlag({
    required this.id,
    required this.name,
    required this.description,
    required this.enabled,
    this.enabledAt,
    this.disabledAt,
    this.reason,
    this.lastModifiedBy,
  });

  factory FeatureFlag.fromMap(Map<String, dynamic> data) {
    return FeatureFlag(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      enabled: data['enabled'] ?? false,
      enabledAt: data['enabledAt'] != null ? DateTime.parse(data['enabledAt'] as String) : null,
      disabledAt: data['disabledAt'] != null ? DateTime.parse(data['disabledAt'] as String) : null,
      reason: data['reason'],
      lastModifiedBy: data['lastModifiedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'enabled': enabled,
      'enabledAt': enabledAt?.toIso8601String(),
      'disabledAt': disabledAt?.toIso8601String(),
      'reason': reason,
      'lastModifiedBy': lastModifiedBy,
    };
  }
}

/// UI Control Model
class UIControl {
  final String id;
  final String name;
  final bool visible;
  final UIStyle? style;
  final DateTime? lastModified;

  UIControl({
    required this.id,
    required this.name,
    required this.visible,
    this.style,
    this.lastModified,
  });

  factory UIControl.fromMap(Map<String, dynamic> data) {
    return UIControl(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      visible: data['visible'] ?? true,
      style: data['style'] != null ? UIStyle.fromMap(data['style'] as Map<String, dynamic>) : null,
      lastModified: data['lastModified'] != null ? DateTime.parse(data['lastModified'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'visible': visible,
      'style': style?.toMap(),
      'lastModified': lastModified?.toIso8601String(),
    };
  }
}

/// UI Style Model (for dynamic theming)
class UIStyle {
  String? backgroundColor;
  String? textColor;
  String? fontFamily;
  double? fontSize;
  double? borderRadius;

  UIStyle({
    this.backgroundColor,
    this.textColor,
    this.fontFamily,
    this.fontSize,
    this.borderRadius,
  });

  factory UIStyle.fromMap(Map<String, dynamic> data) {
    return UIStyle(
      backgroundColor: data['backgroundColor'],
      textColor: data['textColor'],
      fontFamily: data['fontFamily'],
      fontSize: (data['fontSize'] as num?)?.toDouble(),
      borderRadius: (data['borderRadius'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'borderRadius': borderRadius,
    };
  }
}

/// Branding Configuration Model
class BrandingConfig {
  String appName;
  String appTagline;
  String? logoUrl;
  String primaryColor;
  String secondaryColor;
  String accentColor;
  String contactEmail;
  String contactPhone;
  DateTime? lastModified;

  BrandingConfig({
    required this.appName,
    required this.appTagline,
    this.logoUrl,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.contactEmail,
    required this.contactPhone,
    this.lastModified,
  });

  factory BrandingConfig.defaultConfig() {
    return BrandingConfig(
      appName: 'Paykari Bazar',
      appTagline: 'Your One-Stop Marketplace',
      primaryColor: '#FF6B35',
      secondaryColor: '#004E89',
      accentColor: '#F7B801',
      contactEmail: 'support@paykaribazar.com',
      contactPhone: '+880-17-0000-0000',
    );
  }

  factory BrandingConfig.fromMap(Map<String, dynamic> data) {
    return BrandingConfig(
      appName: data['appName'] ?? 'Paykari Bazar',
      appTagline: data['appTagline'] ?? 'Your One-Stop Marketplace',
      logoUrl: data['logoUrl'],
      primaryColor: data['primaryColor'] ?? '#FF6B35',
      secondaryColor: data['secondaryColor'] ?? '#004E89',
      accentColor: data['accentColor'] ?? '#F7B801',
      contactEmail: data['contactEmail'] ?? 'support@paykaribazar.com',
      contactPhone: data['contactPhone'] ?? '+880-17-0000-0000',
      lastModified: data['lastModified'] != null ? DateTime.parse(data['lastModified'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'appTagline': appTagline,
      'logoUrl': logoUrl,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'lastModified': lastModified?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
