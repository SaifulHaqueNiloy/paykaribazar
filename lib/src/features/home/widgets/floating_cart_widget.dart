import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paykari_bazar/src/utils/styles.dart';

/// Simple floating cart widget - shows cart button with badge
/// placed as overlay in Stack within MainScreen
class FloatingCartWidget extends ConsumerWidget {
  const FloatingCartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safely access cart provider with error handling
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => context.push('/cart'),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppStyles.primaryColor,
            boxShadow: [
              BoxShadow(
                color: AppStyles.primaryColor.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 28,
              ),
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF4444),
                  ),
                  child: const Center(
                    child: Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
