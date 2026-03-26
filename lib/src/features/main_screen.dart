import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/features/home/home_screen.dart';
import 'package:paykari_bazar/src/features/home/widgets/robust_floating_cart.dart';
import 'package:paykari_bazar/src/features/orders/emergency_details_screen.dart';
import 'package:paykari_bazar/src/features/products/all_products_screen.dart';
import 'package:paykari_bazar/src/features/home/rewards_screen.dart';
import 'package:paykari_bazar/src/features/profile/profile_screen.dart';
import 'package:paykari_bazar/src/di/providers.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final idx = ref.watch(navProvider);

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
          child: Stack(
            children: [
              IndexedStack(
                index: idx.clamp(0, 4),
                children: const [
                  HomeScreen(),
                  EmergencyDetailsScreen(),
                  AllProductsScreen(),
                  RewardsScreen(),
                  ProfileScreen(),
                ],
              ),
              // Floating cart with error handling
              const RobustFloatingCart(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: idx.clamp(0, 4),
          onDestinationSelected: (index) =>
              ref.read(navProvider.notifier).setIndex(index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.emergency), label: 'Emergency'),
            NavigationDestination(
                icon: Icon(Icons.grid_view), label: 'Products'),
            NavigationDestination(
                icon: Icon(Icons.card_giftcard), label: 'Rewards'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
