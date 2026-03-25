import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  static Map<String, dynamic> _runtimeConfig = const {};

  // --- Static Defaults ---
  static const defaultPrimary = Color(0xFF008080); // Teal per DNA
  static const defaultSecondary = Color(0xFF03DAC6);
  static const defaultAccent = Color(0xFFFFC107); // Amber per DNA
  static const defaultBackground = Color(0xFFF0F2F5);
  static const defaultSurface = Colors.white;

  // --- Legacy / Constants ---
  static const primaryColor = Color(0xFF008080);
  static const darkPrimaryColor = Color(0xFF00CBCB);
  static const darkBackgroundColor = Color(0xFF0F172A);
  static const darkSurfaceColor = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textPrimary = Color(0xFF1E293B);
  static const backgroundColor = Color(0xFFF0F2F5);
  static const successColor = Colors.green;
  static const infoColor = Colors.blue;
  static const errorColor = Colors.red;
  static const accentColor = Color(0xFFFFC107);
  static const darkTextSecondary = Color(0xFF94A3B8);

  static void syncDynamicConfig(Map<String, dynamic>? config) {
    _runtimeConfig = Map<String, dynamic>.from(config ?? const {});
  }

  static Map<String, dynamic> _effectiveConfig(Map<String, dynamic>? config) {
    return {
      ..._runtimeConfig,
      ...?config,
    };
  }

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: shadowOpacity()),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // [DNA UPDATE]: Unified Bengali Support Font
  static String get bengaliFont => GoogleFonts.hindSiliguri().fontFamily!;

  // --- Design Scalars (Dynamic) ---
  static double _getScale(Map<String, dynamic>? config, String key, double fallback) {
    final effective = _effectiveConfig(config);
    if (effective[key] == null) return fallback;
    return (effective[key] as num).toDouble();
  }

  static Color _getColor(Map<String, dynamic>? config, String key, Color fallback) {
    final effective = _effectiveConfig(config);
    if (effective[key] == null) return fallback;
    try {
      final value = effective[key].toString();
      if (value.startsWith('0x')) return Color(int.parse(value));
      if (value.startsWith('#')) return Color(int.parse(value.replaceFirst('#', '0xFF')));
      return Color(int.parse('0xFF$value'));
    } catch (_) {
      return fallback;
    }
  }

  // --- Dynamic Properties ---
  static Color primary(Map<String, dynamic>? config) => _getColor(config, 'primary_color', defaultPrimary);
  static Color secondary(Map<String, dynamic>? config) => _getColor(config, 'secondary_color', defaultSecondary);
  static Color accent(Map<String, dynamic>? config) => _getColor(config, 'accent_color', defaultAccent);
  
  static Color surfaceColor(bool isDark) => isDark ? darkSurfaceColor : defaultSurface;

  static double textScale(Map<String, dynamic>? config) => _getScale(config, 'text_scale', 1.0);
  static double buttonScale(Map<String, dynamic>? config) => _getScale(config, 'button_scale', 1.0);
  static double cardScale(Map<String, dynamic>? config) => _getScale(config, 'card_scale', 1.0);
  static double globalPadding([Map<String, dynamic>? config]) =>
      _getScale(config, 'global_padding', 16.0);
  static double shadowOpacity([Map<String, dynamic>? config]) =>
      (_getScale(config, 'shadow_opacity', 0.05).clamp(0.0, 1.0) as num)
          .toDouble();
  static EdgeInsets screenPadding([Map<String, dynamic>? config]) =>
      EdgeInsets.all(globalPadding(config));

  static List<BoxShadow> softShadowWithConfig([Map<String, dynamic>? config]) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: shadowOpacity(config)),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  // --- Dynamic Text Styles ---
  static TextStyle bodyStyle(Map<String, dynamic>? config, {bool isDark = false, bool bold = false}) {
    final scale = textScale(config);
    return TextStyle(
      fontFamily: bengaliFont,
      fontSize: 14 * scale,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: isDark ? Colors.white : const Color(0xFF1E293B),
    );
  }

  static TextStyle titleStyle(Map<String, dynamic>? config, {bool isDark = false}) {
    final scale = textScale(config);
    return TextStyle(
      fontFamily: bengaliFont,
      fontSize: 18 * scale,
      fontWeight: FontWeight.w900,
      color: isDark ? Colors.white : const Color(0xFF1E293B),
    );
  }

  static TextStyle priceStyle(BuildContext context, {double size = 16}) {
    return TextStyle(
      fontFamily: bengaliFont,
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).primaryColor,
    );
  }

  // --- Dynamic Decorations ---
  static BoxDecoration cardDecoration(dynamic config, [bool? isDark]) {
    Map<String, dynamic>? configMap;
    bool dark = false;

    if (config is Map<String, dynamic>) {
      configMap = config;
      dark = isDark ?? false;
    } else if (config is bool) {
      dark = config;
    }

    final scale = cardScale(configMap);
    return BoxDecoration(
      color: dark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(20 * scale),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: shadowOpacity(configMap)),
          blurRadius: 10 * scale,
          offset: Offset(0, 4 * scale),
        ),
      ],
    );
  }

  static PrimaryGradient get primaryGradient => PrimaryGradient();

  static ButtonStyle primaryButtonStyle(Map<String, dynamic>? config) {
    final scale = buttonScale(config);
    return ElevatedButton.styleFrom(
      backgroundColor: primary(config),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
      textStyle: TextStyle(
        fontFamily: bengaliFont,
        fontSize: 14 * textScale(config), 
        fontWeight: FontWeight.bold
      ),
    );
  }

  // --- SMART INPUT SYSTEM ---
  static InputDecoration inputDecoration(String label, bool isDark, {Widget? prefix, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      contentPadding: EdgeInsets.symmetric(horizontal: globalPadding(), vertical: 14),
      labelStyle: TextStyle(fontFamily: bengaliFont, color: isDark ? Colors.white70 : Colors.black54, fontSize: 13, fontWeight: FontWeight.w500),
      hintStyle: TextStyle(fontFamily: bengaliFont, color: isDark ? Colors.white38 : Colors.black26, fontSize: 12),
      floatingLabelStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
    );
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.indigo;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'returned': return Colors.grey;
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.timer_outlined;
      case 'processing': return Icons.sync_rounded;
      case 'shipped': return Icons.local_shipping_outlined;
      case 'delivered': return Icons.check_circle_outline_rounded;
      case 'cancelled': return Icons.cancel_outlined;
      case 'returned': return Icons.keyboard_return_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  static IconData getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('phone') || name.contains('mobile')) return Icons.smartphone_rounded;
    if (name.contains('laptop') || name.contains('computer')) return Icons.laptop_mac_rounded;
    if (name.contains('fashion') || name.contains('cloth')) return Icons.checkroom_rounded;
    if (name.contains('food') || name.contains('grocery')) return Icons.local_grocery_store_rounded;
    if (name.contains('home') || name.contains('furniture')) return Icons.home_repair_service_rounded;
    if (name.contains('beauty') || name.contains('health')) return Icons.face_retouching_natural_rounded;
    if (name.contains('toy') || name.contains('kid')) return Icons.toys_rounded;
    if (name.contains('sport')) return Icons.sports_basketball_rounded;
    return Icons.category_rounded;
  }

  // --- Theme Generators ---
  static ThemeData getLightTheme(TextTheme baseTextTheme, {Map<String, dynamic>? config}) {
    final effectiveConfig = _effectiveConfig(config);
    syncDynamicConfig(effectiveConfig);
    final p = primary(config);
    final scale = textScale(config);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: p,
      fontFamily: GoogleFonts.hindSiliguri().fontFamily,
      scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      textTheme: GoogleFonts.hindSiliguriTextTheme(baseTextTheme).apply(
        fontSizeFactor: scale,
        bodyColor: const Color(0xFF1E293B),
        displayColor: const Color(0xFF1E293B),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle(config)),
    );
  }

  static ThemeData getDarkTheme(TextTheme baseTextTheme, {Map<String, dynamic>? config}) {
    final effectiveConfig = _effectiveConfig(config);
    syncDynamicConfig(effectiveConfig);
    final p = _getColor(config, 'primary_color_dark', primary(config).withValues(alpha: 0.7));
    final scale = textScale(config);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: p,
      fontFamily: GoogleFonts.hindSiliguri().fontFamily,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: GoogleFonts.hindSiliguriTextTheme(baseTextTheme).apply(
        fontSizeFactor: scale,
        bodyColor: const Color(0xFFF1F5F9),
        displayColor: const Color(0xFFF1F5F9),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  static const String googleMapDarkStyle = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]''';
}

class PrimaryGradient extends LinearGradient {
  PrimaryGradient([Map<String, dynamic>? config]) : super(
    colors: [
      AppStyles.primary(config),
      AppStyles.primary(config).withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient call([Map<String, dynamic>? config]) => PrimaryGradient(config);
}
