// Trigger build: Secret updated
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'src/di/service_initializer.dart';
import 'src/di/service_locator.dart';
import 'src/di/providers.dart';
import 'src/services/database_seeder.dart';
import 'src/services/backup_service.dart';
import 'src/shared/services/update_service.dart';
import 'src/utils/router_customer.dart';
import 'src/utils/styles.dart';
import 'src/utils/globals.dart';
import 'src/utils/update_dialog.dart';
import 'src/utils/touch_glow_overlay.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
      }
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) await BackupService.performBackgroundBackup(uid);
    } catch (e) {
      if (kDebugMode) debugPrint('Background Task Error: $e');
    }
    return Future.value(true);
  });
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    final container = ProviderContainer();

    // Visual Safety Net
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: Container(
            color: AppStyles.backgroundColor,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt_rounded,
                    color: AppStyles.primaryColor, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'দুঃখিত! একটি সমস্যা হয়েছে।',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'আমাদের এআই ইঞ্জিন সমস্যাটি সমাধানের চেষ্টা করছে। অনুগ্রহ করে কিছুক্ষণ পর আবার চেষ্টা করুন।',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(details.exception.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ),
      );
    };

    // Load Environment Variables
    try {
      await dotenv.load();
    } catch (e) {
      if (kDebugMode) debugPrint('Dotenv Load Error: $e');
    }

    // Initialize all services
    await ServiceInitializer.initialize();

    // Auto seed/sync locations if database is empty or has no districts
    try {
      final snap = await FirebaseFirestore.instance.collection(HubPaths.locations)
          .where('type', isEqualTo: 'district')
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        await DatabaseSeeder.seedAll();
        if (kDebugMode) debugPrint('✅ Auto-seeded all default database collections at startup');
      }

      // Auto-seed mock products if empty
      final prodSnap = await FirebaseFirestore.instance.collection(HubPaths.products).limit(1).get();
      if (prodSnap.docs.isEmpty) {
        await DatabaseSeeder.seedProducts();
        if (kDebugMode) debugPrint('✅ Auto-seeded mock products at startup');
      }

      // Auto-seed mock banners if empty
      final promoSnap = await FirebaseFirestore.instance.collection('promos').limit(1).get();
      if (promoSnap.docs.isEmpty) {
        await DatabaseSeeder.seedPromos();
        if (kDebugMode) debugPrint('✅ Auto-seeded mock banners at startup');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Auto-seed check skipped/failed: $e');
    }

    // Initialize Workmanager
    try {
      await Workmanager().initialize(callbackDispatcher,
          isInDebugMode: dotenv.env['DEBUG'] == 'true');
    } catch (e) {
      if (kDebugMode) debugPrint('Workmanager Init Error: $e');
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Sentry initialization — DSN from .env only, no hardcoded fallback
    final dsn = (dotenv.env['SENTRY_DSN'] ?? '').trim();

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        // Tip #3: Use 0.2 in production to reduce cost (1.0 = 100% traces)
        options.tracesSampleRate = 0.2;
      },
      appRunner: () => runApp(
        UncontrolledProviderScope(container: container, child: const CustomerApp()),
      ),
    );
  }, (error, stack) {
    if (kDebugMode) debugPrint('Fatal Global Error: $error');
    Sentry.captureException(error, stackTrace: stack);
  });
}

class CustomerApp extends ConsumerStatefulWidget {
  const CustomerApp({super.key});
  @override
  ConsumerState<CustomerApp> createState() => _CustomerAppState();
}

class _CustomerAppState extends ConsumerState<CustomerApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      // Issue #6: Properly schedule sync without unawaited Future
      Future.delayed(const Duration(minutes: 2), () {
        if (mounted) {
          ref.read(syncServiceProvider).syncData();
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Init Error: $e');
    }

    if (mounted) {
      setState(() => _isInitialized = true);
      Future.delayed(const Duration(seconds: 3), () => _checkUpdate());
    }
  }

  void _checkUpdate() async {
    if (!mounted) return;
    final upd = getIt<UpdateService>();
    final status = await upd.checkForAppUpdate();

    if (status != UpdateStatus.upToDate && mounted) {
      showDialog(
        context: navigatorKey.currentContext ?? context,
        barrierDismissible: status != UpdateStatus.forceUpdate,
        builder: (c) => UpdateDialog(
          message:
              'A new version is available. Please update for the best experience.',
          isForceUpdate: status == UpdateStatus.forceUpdate,
          onUpdate: () => upd.launchUpdateUrl(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig =
        ref.watch(appConfigProvider).value ?? const <String, dynamic>{};
    AppStyles.syncDynamicConfig(appConfig);

    if (!_isInitialized) {
      return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                      color: AppStyles.primaryColor))));
    }

    return MaterialApp.router(
      title: 'পাইকারী বাজার',
      debugShowCheckedModeBanner: false,
      routerConfig: customerRouter,
      theme: AppStyles.getLightTheme(
        GoogleFonts.plusJakartaSansTextTheme(),
        config: appConfig,
      ),
      darkTheme: AppStyles.getDarkTheme(
        GoogleFonts.plusJakartaSansTextTheme(),
        config: appConfig,
      ),
      themeMode: ref.watch(themeProvider) ? ThemeMode.dark : ThemeMode.light,
      locale: ref.watch(languageProvider),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [Locale('en', ''), Locale('bn', '')],
      builder: (context, child) => TouchGlowOverlay(child: child!),
    );
  }
}
