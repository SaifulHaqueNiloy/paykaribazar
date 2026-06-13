import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/utils/styles.dart';
import 'package:paykari_bazar/src/di/service_locator.dart';
import 'package:paykari_bazar/src/features/qibla/services/compass_service.dart';

class SimpleFloatingCart extends ConsumerWidget {
  const SimpleFloatingCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final cartState = ref.watch(cartProvider);
      
      if (cartState.items.isEmpty) {
        return const SizedBox.shrink();
      }

      final itemCount = cartState.items.length;
      final totalPrice = cartState.items.fold<num>(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Shopping Bag Button
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
                    color: AppStyles.primaryColor.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: StreamBuilder<Map<String, dynamic>>(
                stream: getIt<CompassService>().getRealTimeQiblaDirection(),
                builder: (context, snapshot) {
                  double angleRad = 0.0;
                  if (snapshot.hasData && snapshot.data != null && !snapshot.data!.containsKey('error')) {
                    final double relativeAngle = (snapshot.data!['relativeAngle'] as num).toDouble();
                    angleRad = relativeAngle * (pi / 180);
                  } else {
                    angleRad = 0.0;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      // Compass / Clock Hand
                      Transform.rotate(
                        angle: angleRad,
                        child: CustomPaint(
                          size: const Size(50, 50),
                          painter: CompassClockHandPainter(),
                        ),
                      ),
                      // Item Count Badge
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
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Checkout Button
          GestureDetector(
            onTap: () => context.push('/cart'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'চেকআউট (${itemCount == 1 ? "1 item" : "$itemCount items"} • ৳${totalPrice.toStringAsFixed(0)})',
                    style: const TextStyle(
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
    } catch (e) {
      debugPrint('SimpleFloatingCart error: $e');
      return const SizedBox.shrink();
    }
  }
}

class CompassClockHandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppStyles.accentColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    
    final path = Path()
      ..moveTo(center.dx - 2, center.dy)
      ..lineTo(center.dx + 2, center.dy)
      ..lineTo(center.dx + 1, center.dy - 20)
      ..lineTo(center.dx, center.dy - 23)
      ..lineTo(center.dx - 1, center.dy - 20)
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawCircle(center, 4, paint..color = Colors.white);
    canvas.drawCircle(center, 2, paint..color = AppStyles.accentColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
