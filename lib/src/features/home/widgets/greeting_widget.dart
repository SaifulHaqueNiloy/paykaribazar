import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/app_strings.dart';
import '../../../di/providers.dart';

class GreetingWidget extends ConsumerWidget {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
