import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cart_service.dart';
import '../../../di/service_locator.dart';
import '../../../di/providers.dart';
import '../../../services/business_config_service.dart';

export '../domain/cart_model.dart' show CartState;

final cartServiceProvider = Provider((ref) => getIt<CartService>());

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final service = ref.watch(cartServiceProvider);
  return CartNotifier(service);
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).totalAmount;
});

/// DNA ENFORCED: Fetches user's current location details for fee calculation
final userLocationDetailsProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(actualUserDataProvider).value;
  if (user == null) return null;

  final String? districtId = user['districtId'];
  final String? upazilaId = user['upazilaId'];
  final String? stationId = user['stationId'];

  // Hierarchy: Station -> Upazila -> District
  final targets =
      [stationId, upazilaId, districtId].where((id) => id != null).toList();

  for (final id in targets) {
    final doc = await FirebaseFirestore.instance
        .collection(HubPaths.locations)
        .doc(id)
        .get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && (data['baseCharge'] ?? 0) > 0) {
        return data;
      }
    }
  }
  return null;
});

/// Business Rules Provider (Reads from Firestore settings/business_rules)
final businessRulesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance
      .doc('settings/business_rules')
      .snapshots()
      .map((snap) => BusinessConfigService.mergeWithDefaults(snap.data()));
});

final cartMinimumOrderValueProvider = Provider<double>((ref) {
  final rules =
      ref.watch(businessRulesProvider).value ?? BusinessConfigService.defaults;
  return BusinessConfigService.getDoubleRule(
    'min_order_value',
    rules: rules,
  );
});

final cartShortfallProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final minimumOrder = ref.watch(cartMinimumOrderValueProvider);
  final remaining = minimumOrder - subtotal;
  return remaining > 0 ? remaining : 0;
});

final cartDeliveryFeeProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal == 0) return 0;

  final rules =
      ref.watch(businessRulesProvider).value ?? BusinessConfigService.defaults;
  final double freeThreshold = BusinessConfigService.getDoubleRule(
    'free_delivery_threshold',
    rules: rules,
  );

  if (subtotal >= freeThreshold) return 0;

  final locationAsync = ref.watch(userLocationDetailsProvider);
  final double defaultFee = BusinessConfigService.getDoubleRule(
    'delivery_fee_base',
    rules: rules,
  );

  return locationAsync.when(
    data: (locData) {
      if (locData == null) return defaultFee; 

      final double baseCharge = (locData['baseCharge'] ?? defaultFee).toDouble();
      final double maxCharge = (locData['maxCharge'] ?? 200.0).toDouble();
      final double extraWeightCharge =
          (locData['extraWeightCharge'] ?? 0.0).toDouble();
      final double maxBaseWeight = (locData['maxBaseWeight'] ?? 2.0).toDouble();

      // Calculate Weight Logic
      final items = ref.watch(cartProvider).items;
      double totalWeight = 0;
      for (var item in items) {
        // Assume default weight of 0.5kg if not specified
        totalWeight += (item.quantity * 0.5);
      }

      double finalFee = baseCharge;
      if (totalWeight > maxBaseWeight && extraWeightCharge > 0) {
        final double extraWeight = totalWeight - maxBaseWeight;
        finalFee += (extraWeight * extraWeightCharge);
      }

      return (finalFee.clamp(0.0, maxCharge) as num).toDouble();
    },
    loading: () => 0.0,
    error: (_, __) => defaultFee,
  );
});

final cartDiscountProvider = Provider<double>((ref) {
  final appliedCoupon = ref.watch(cartProvider).appliedCouponMap;
  if (appliedCoupon == null) return 0.0;

  final subtotal = ref.watch(cartSubtotalProvider);
  final type = appliedCoupon['type'] ?? 'fixed';
  final discountVal = (appliedCoupon['discount'] ?? 0.0).toDouble();

  if (type == 'percentage') {
    final maxDiscount = (appliedCoupon['maxDiscount'] ?? 999999.0).toDouble();
    final double calc = subtotal * (discountVal / 100);
    return calc > maxDiscount ? maxDiscount : calc;
  }
  return discountVal;
});

final cartPointsDiscountProvider = Provider<double>((ref) {
  return 0.0;
});

final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final delivery = ref.watch(cartDeliveryFeeProvider);
  final discount = ref.watch(cartDiscountProvider);
  final points = ref.watch(cartPointsDiscountProvider);
  return subtotal + delivery - discount - points;
});

class CartNotifier extends StateNotifier<CartState> {
  final CartService _service;

  CartNotifier(this._service) : super(CartState()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    state = state.copyWith(isLoading: true);
    final cloudItems = await _service.fetchSavedCart();
    if (cloudItems != null) {
      final items = cloudItems
          .map((m) => CartItem(
                id: m['id'],
                name: m['name'],
                imageUrl: m['imageUrl'],
                price: (m['price'] ?? 0.0).toDouble(),
                quantity: m['quantity'] ?? 1,
                unit: m['unit'] ?? 'pcs',
              ))
          .toList();
      state = state.copyWith(items: items, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void _sync() {
    final list = state.items
        .map((i) => {
              'id': i.id,
              'name': i.name,
              'imageUrl': i.imageUrl,
              'price': i.price,
              'quantity': i.quantity,
              'unit': i.unit,
            })
        .toList();
    _service.syncCartToCloud(list);
  }

  void addItem(CartItem item) {
    final index = state.items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      final updatedItems = [...state.items];
      updatedItems[index].quantity += 1;
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
    _sync();
  }

  void removeItem(String id) {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final updatedItems = [...state.items];
      if (updatedItems[index].quantity > 1) {
        updatedItems[index].quantity -= 1;
        state = state.copyWith(items: updatedItems);
      } else {
        state = state.copyWith(
            items: state.items.where((i) => i.id != id).toList());
      }
      _sync();
    }
  }

  void updateQuantity(String id, int quantity) {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index != -1 && quantity > 0) {
      final updatedItems = [...state.items];
      updatedItems[index].quantity = quantity;
      state = state.copyWith(items: updatedItems);
      _sync();
    }
  }

  Future<String> applyCouponMap(
      Map<String, dynamic>? coupon, Map<String, dynamic>? userData) async {
    if (coupon == null) {
      state = state.copyWith();
      return 'REMOVED';
    }

    final minOrder = (coupon['minOrder'] ?? 0.0).toDouble();
    if (state.totalAmount < minOrder) {
      return 'Min order ৳$minOrder required';
    }

    state = state.copyWith(appliedCouponMap: coupon);
    return 'SUCCESS';
  }

  void clearCart() {
    state = state.copyWith(items: []);
    _service.clearCloudCart();
  }
}
