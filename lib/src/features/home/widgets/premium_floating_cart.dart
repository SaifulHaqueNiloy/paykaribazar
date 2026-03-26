import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paykari_bazar/src/features/commerce/providers/cart_provider.dart';
import 'package:paykari_bazar/src/features/qibla/services/compass_service.dart';
import 'package:paykari_bazar/src/utils/styles.dart';
import '../../../shared/services/location_service.dart';

class PremiumFloatingCart extends ConsumerStatefulWidget {
  const PremiumFloatingCart({super.key});

  @override
  ConsumerState<PremiumFloatingCart> createState() =>
      _PremiumFloatingCartState();
}

class _PremiumFloatingCartState extends ConsumerState<PremiumFloatingCart>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  double _qiblaBearing = 0;
  late CompassService _compassService;
  
  // Position tracking
  late Offset _position;
  final Offset _bottomCenterPosition = const Offset(0, 80);
  final Offset _topRightPosition = const Offset(-20, 100);

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Start at bottom center
    _position = _bottomCenterPosition;
    _initializeCompass();
  }

  Future<void> _initializeCompass() async {
    try {
      final locationService = LocationService();
      _compassService = CompassService(locationService);
      await _compassService.initialize();
      _updateQiblaDirection();
      // Update every 3 seconds
      Future.delayed(const Duration(seconds: 3), _updateQiblaDirection);
    } catch (e) {
      debugPrint('Compass initialization error: $e');
    }
  }

  Future<void> _updateQiblaDirection() async {
    try {
      final bearing = await _compassService.getQiblaBearing();
      if (mounted) {
        setState(() => _qiblaBearing = bearing);
        // Animate to new bearing
        _rotationController.forward(from: 0.0);
      }
      // Schedule next update
      if (mounted) {
        Future.delayed(const Duration(seconds: 10), _updateQiblaDirection);
      }
    } catch (e) {
      debugPrint('Qibla bearing error: $e');
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final cart = ref.watch(cartProvider);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        if (cart.items.isEmpty) return const SizedBox.shrink();

        return Positioned(
          bottom: _position.dy == _bottomCenterPosition.dy ? 80 : null,
          top: _position.dy == _topRightPosition.dy ? 100 : null,
          right: _position.dy == _topRightPosition.dy ? 16 : null,
          left: _position.dy == _bottomCenterPosition.dy ? 0 : null,
          child: GestureDetector(
            onLongPress: () => _showPositionOptions(context),
            onTap: () => context.push('/cart'),
            child: Draggable<String>(
              data: 'floatingCart',
              feedback: _buildCartWidget(isDark, cart, 0.8),
              childWhenDragging: const SizedBox.shrink(),
              onDraggableCanceled: (velocity, offset) {
                _snapToNearestPosition(context, offset);
              },
              child: _buildCartWidget(isDark, cart, 1.0),
            ),
          ),
        );
      },
    );
  }

  void _showPositionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Move Cart To:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Bottom Center'),
              subtitle: const Text('Easy thumb reach'),
              onTap: () {
                setState(() => _position = _bottomCenterPosition);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Top Right Corner'),
              subtitle: const Text('Dashboard view'),
              onTap: () {
                setState(() => _position = _topRightPosition);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _snapToNearestPosition(BuildContext context, Offset offset) {
    final screenSize = MediaQuery.of(context).size;
    final centerY = screenSize.height / 2;

    // Snap to nearest position
    if (offset.dy < centerY) {
      setState(() => _position = _topRightPosition);
    } else {
      setState(() => _position = _bottomCenterPosition);
    }
  }

  Widget _buildCartWidget(bool isDark, dynamic cart, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppStyles.primaryColor.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // SHOPPING BAG ICON & DESIGN
            Positioned(
              left: 12,
              top: 8,
              child: _buildShoppingBag(isDark),
            ),

            // CART DETAILS (right side)
            Positioned(
              right: 16,
              top: 12,
              bottom: 12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Paykari Bazar + Total Amount
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Paykari ',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '৳${cart.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppStyles.primaryColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Product Count
                  Text(
                    '${cart.items.length} Items in bag',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // QIBLA COMPASS (rotating hand overlay on bag)
            Positioned(
              left: 45,
              top: 18,
              child: _buildQiblaCompass(),
            ),

            // CHECKOUT ARROW + DRAG INDICATOR
            Positioned(
              right: 16,
              bottom: 12,
              child: const Tooltip(
                message: 'Tap to checkout | Long press to move',
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: AppStyles.primaryColor,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingBag(bool isDark) {
    return SizedBox(
      width: 65,
      height: 65,
      child: CustomPaint(
        painter: ShoppingBagPainter(
          bagColor: AppStyles.primaryColor,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildQiblaCompass() {
    return RotationTransition(
      turns: AlwaysStoppedAnimation(_qiblaBearing / 360),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Compass circle background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.9),
                border: Border.all(
                  color: AppStyles.accentColor,
                  width: 1.5,
                ),
              ),
            ),
            // Cardinal directions (N, S, E, W)
            Positioned(
              top: 2,
              child: Text(
                'N',
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.accentColor,
                ),
              ),
            ),
            // Qibla hand (needle pointing to Mecca)
            CustomPaint(
              size: const Size(36, 36),
              painter: QiblaHandPainter(),
            ),
            // Center dot
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppStyles.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for shopping bag shape
class ShoppingBagPainter extends CustomPainter {
  final Color bagColor;
  final bool isDark;

  ShoppingBagPainter({required this.bagColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bagColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = bagColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final width = size.width;
    final height = size.height;

    // Bag body (rounded rectangle)
    final bagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width * 0.1, height * 0.25, width * 0.8, height * 0.65),
      const Radius.circular(8),
    );
    canvas.drawRRect(bagRect, paint);

    // Bag handles (two arcs)
    final leftHandleRect = Rect.fromLTRB(
      width * 0.15,
      height * 0.15,
      width * 0.35,
      height * 0.35,
    );
    canvas.drawArc(leftHandleRect, -pi, pi, false, strokePaint);

    final rightHandleRect = Rect.fromLTRB(
      width * 0.65,
      height * 0.15,
      width * 0.85,
      height * 0.35,
    );
    canvas.drawArc(rightHandleRect, 0, pi, false, strokePaint);
  }

  @override
  bool shouldRepaint(ShoppingBagPainter oldDelegate) => false;
}

// Custom painter for Qibla direction hand
class QiblaHandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE91E63)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final handLength = size.width * 0.35;

    // Draw needle pointing upward (to Mecca/Qibla)
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - handLength),
      paint..strokeWidth = 2.5,
    );

    // Arrow tip
    final arrowSize = 3.0;
    final tipPoint = Offset(center.dx, center.dy - handLength);

    canvas.drawPath(
      Path()
        ..moveTo(tipPoint.dx - arrowSize, tipPoint.dy + arrowSize)
        ..lineTo(tipPoint.dx, tipPoint.dy)
        ..lineTo(tipPoint.dx + arrowSize, tipPoint.dy + arrowSize),
      paint..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(QiblaHandPainter oldDelegate) => false;
}
