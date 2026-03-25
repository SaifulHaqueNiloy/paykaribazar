import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/app_strings.dart';
import '../../../di/providers.dart';

class GreetingWidget extends ConsumerStatefulWidget {
  const GreetingWidget({super.key});

  @override
  ConsumerState<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends ConsumerState<GreetingWidget> {
  @override
  void initState() {
    super.initState();
    _checkAndSendAiGreeting();
  }

  void _checkAndSendAiGreeting() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // We only want to send this once per session or day. 
    // For simplicity, let's just trigger it if it's the first time mounting in this session.
    // In a real app, you might use SharedPreferences to check last sent date.
    
    final ai = ref.read(aiServiceProvider);
    await ai.sendAiGreetingNotification(user.uid, user.displayName ?? 'Customer');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final locale = ref.watch(languageProvider);
    final name = user?.displayName ?? AppStrings.get('guest', locale.languageCode);

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
  }
}
