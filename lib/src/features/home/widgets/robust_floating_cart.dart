import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/utils/styles.dart';

class RobustFloatingCart extends ConsumerWidget {
  const RobustFloatingCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      // Safely watch cart provider with error handling
      final cartAsyncValue = ref.watch(cartProvider);

      return cartAsyncValue.maybeWhen(
        data: (cartState) {
          if (cartState.items.isEmpty) {
            return const SizedBox.shrink();
          }

          final itemCount = cartState.items.length;
          final totalPrice = cartState.items.fold<num>(
            0,
            (sum, item) => sum + (item.price * item.quantity),
          );

          return _buildCartUI(context, itemCount, totalPrice);
        },
        error: (err, stack) {
          // Silently hide cart on error
          debugPrint('Floating cart error: $err');
          return const SizedBox.shrink();
        },
        loading: () => const SizedBox.shrink(),
        orElse: () => const SizedBox.shrink(),
      );
    } catch (e) {
      debugPrint('Floating cart exception: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildCartUI(BuildContext context, int itemCount, num totalPrice) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Price card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppStyles.primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppStyles.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemCount == 1 ? '1 item' : '$itemCount items',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '৳${totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Shopping bag button
          GestureDetector(
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
                  // Badge
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
                      child: Center(
                        child: Text(
                          itemCount > 99 ? '99+' : itemCount.toString(),
                          style: const TextStyle(
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

          const SizedBox(height: 12),

          // Checkout button
          GestureDetector(
            onTap: () => context.push('/cart'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'চেকআউট',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
