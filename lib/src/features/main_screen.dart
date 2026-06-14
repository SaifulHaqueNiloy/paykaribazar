import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/features/home/home_screen.dart';
import 'package:paykari_bazar/src/features/home/widgets/premium_floating_cart.dart';
import 'package:paykari_bazar/src/features/orders/emergency_details_screen.dart';
import 'package:paykari_bazar/src/features/products/grouped_products_screen.dart';
import 'package:paykari_bazar/src/features/home/rewards_screen.dart';
import 'package:paykari_bazar/src/features/profile/profile_screen.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/services/role_simulator_provider.dart';
import 'package:paykari_bazar/src/utils/app_strings.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider).languageCode;
    final idx = ref.watch(navProvider);
    final simulatedId = ref.watch(simulatedUserUidProvider);
    String t(String key) => AppStrings.get(key, lang);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (idx != 0) {
            ref.read(navProvider.notifier).setIndex(0);
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              if (simulatedId != null)
                Container(
                  color: Colors.red.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'সিমুলেশন মোড সক্রিয় (UID: ${simulatedId.substring(0, 8)}...)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => ref.read(simulatedUserUidProvider.notifier).state = null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade900,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Exit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: idx.clamp(0, 4),
                      children: const [
                        HomeScreen(),
                        EmergencyDetailsScreen(),
                        ProductGroupedScreen(),
                        RewardsScreen(),
                        ProfileScreen(),
                      ],
                    ),
                    // Floating cart with Qibla integrated
                    const PremiumFloatingCart(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx.clamp(0, 4),
          onDestinationSelected: (index) =>
              ref.read(navProvider.notifier).setIndex(index),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home), label: t('home')),
            NavigationDestination(
                icon: const Icon(Icons.emergency), label: t('emergencyService')),
            NavigationDestination(
                icon: const Icon(Icons.grid_view), label: t('products')),
            NavigationDestination(
                icon: const Icon(Icons.card_giftcard), label: t('rewards')),
            NavigationDestination(
                icon: const Icon(Icons.person), label: t('profile')),
          ],
        ),
      ),
    );
  }
}
