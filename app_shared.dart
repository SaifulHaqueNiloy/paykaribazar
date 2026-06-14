import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared initialization logic for both Customer and Admin apps.
class AppLauncher {
  static Future<void> launch(Widget rootWidget) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Place shared initialization here:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // await LocalStorage.init();

    runApp(
      ProviderScope(
        child: rootWidget,
      ),
    );
  }
}

/// Shared Theme data to keep branding consistent
class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF008080), // Primary Teal
        brightness: Brightness.light,
      );
}