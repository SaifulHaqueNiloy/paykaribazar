import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late CompassService _compassService;
  StreamSubscription? _compassSub;
  double _currentHeading = 0;
  double _smoothRotation = 0;
  final double _alpha = 0.12; 

  // Alignment: 0 = Right, 1 = Left
  int _alignment = 0; 

  @override
  void initState() {
    super.initState();
    _startQiblaTracking();
  }

  void _startQiblaTracking() async {
    final locationService = LocationService();
    _compassService = CompassService(locationService);
    
    try {
      await _compassService.initialize();
    } catch (_) {}

    _compassSub = _compassService.getRealTimeQiblaDirection().listen((data) {
      if (!mounted) return;
      
      final double targetHeading = data['currentHeading'] ?? 0;
      final double qiblaBearing = data['qiblaBearing'] ?? 292.5;

      final double diff = (targetHeading - _currentHeading + 180) % 360 - 180;
      _currentHeading = (_currentHeading + _alpha * diff + 360) % 360;

      final double relative = (qiblaBearing - _currentHeading + 360) % 360;

      setState(() {
        _smoothRotation = relative;
      });
    });
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      bottom: 110,
      right: _alignment == 0 ? 10 : null,
      left: _alignment == 1 ? 10 : null,
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _alignment = _alignment == 0 ? 1 : 0;
          });
          HapticFeedback.heavyImpact();
        },
        onTap: () => context.push('/cart'),
        child: _buildUltimateCircularCart(cart, total, isDark),
      ),
    );
  }

  Widget _buildUltimateCircularCart(dynamic cart, double total, bool isDark) {
    return SizedBox(
      width: 150, // Increased for gap
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // MAIN CIRCULAR BODY
          Container(
            width: 100, // Round cart size
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark 
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [Colors.white, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppStyles.primaryColor.withValues(alpha: 0.3), 
                width: 4
              ),
              boxShadow: [
                BoxShadow(
                  color: AppStyles.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_rounded, size: 24, color: AppStyles.primaryColor),
                const SizedBox(height: 2),
                // Item Count - BIGGER TEXT
                Text(
                  '${cart.items.length}',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppStyles.primaryColor,
                    height: 1.0,
                  ),
                ),
                // Value - BIGGER TEXT
                Text(
                  '৳${total.toInt()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // THE ROTATING QIBLA INDICATOR (With Gap)
          // DNA ENFORCED: Wrap in RepaintBoundary to avoid rebuilding whole widget tree on rotation
          // বাংলা: ব্যাটারি সেভ করতে এবং রেন্ডারিং অপ্টিমাইজ করতে রিপেইন্ট বাউন্ডারি যোগ করা হয়েছে
          RepaintBoundary(
            child: Transform.rotate(
              angle: -_smoothRotation * (pi / 180),
              child: SizedBox(
                width: 145, // Larger orbit to create gap
                height: 145,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppStyles.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 1)],
                          ),
                          child: const Text('🕋', style: TextStyle(fontSize: 20)),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded, color: AppStyles.primaryColor, size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // HOLD TO MOVE LABEL
          Positioned(
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'HOLD TO MOVE',
                style: TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
