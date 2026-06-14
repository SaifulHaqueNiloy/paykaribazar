import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/app_strings.dart';
import '../../../di/providers.dart';
import '../../profile/cloud_storage_screen.dart';

class GreetingWidget extends ConsumerStatefulWidget {
  const GreetingWidget({super.key});

  @override
  ConsumerState<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends ConsumerState<GreetingWidget> {
  static bool _hasSentAiGreeting = false;
  static bool _hasRunInitialBackup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSendAiGreeting();
      _triggerInitialBackup();
    });
  }

  void _checkAndSendAiGreeting() async {
    if (_hasSentAiGreeting) return;
    
    final userData = ref.read(currentUserDataProvider).value;
    if (userData == null) return;
    
    final String? uid = userData['id'] ?? userData['uid'];
    if (uid == null) return;

    _hasSentAiGreeting = true;

    try {
      final ai = ref.read(aiServiceProvider);
      await ai.sendAiGreetingNotification(uid, userData['name'] ?? 'Customer');
    } catch (e) {
      debugPrint('❌ AI Greeting Notification failed: $e');
    }
  }

  void _triggerInitialBackup() async {
    if (_hasRunInitialBackup) return;

    final userData = ref.read(currentUserDataProvider).value;
    if (userData == null) return;

    final String? uid = userData['id'] ?? userData['uid'];
    if (uid == null) return;

    _hasRunInitialBackup = true;

    try {
      final isEnabled = ref.read(autoBackupEnabledProvider);
      if (isEnabled) {
        await ref.read(userMediaServiceProvider).runAutomaticBackup(uid);
      }
    } catch (e) {
      debugPrint('❌ Auto backup startup trigger failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final locale = ref.watch(languageProvider);

    return userAsync.when(
      data: (data) {
        final name = data?['name'] as String? ??
                     data?['displayName'] as String? ??
                     AppStrings.get('guest', locale.languageCode);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.get('hello', locale.languageCode)}, $name!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                AppStrings.get('welcomeMsg', locale.languageCode),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Hello!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
