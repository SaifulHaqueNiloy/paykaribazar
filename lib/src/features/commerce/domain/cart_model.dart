import '../../../models/user_model.dart';

class CartItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double oldPrice;
  int quantity;
  final String unit;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.oldPrice = 0.0,
    this.quantity = 1,
    this.unit = 'pcs',
  });

  double get subtotal => price * quantity;
}

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;
  final String? appliedCoupon;
  final Map<String, dynamic>? appliedCouponMap;
  final AddressModel? selectedAddress;

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.appliedCoupon,
    this.appliedCouponMap,
    this.selectedAddress,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
    String? appliedCoupon,
    Map<String, dynamic>? appliedCouponMap,
    AddressModel? selectedAddress,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      appliedCouponMap: appliedCouponMap ?? this.appliedCouponMap,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  double get totalAmount => items.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.length;
}
