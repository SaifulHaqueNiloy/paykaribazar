import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart'; // MASTER HUB IMPORT
import '../../../models/user_model.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';

class CheckoutBottomSheet extends ConsumerStatefulWidget {
  const CheckoutBottomSheet({super.key});
  @override
  ConsumerState<CheckoutBottomSheet> createState() =>
      _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends ConsumerState<CheckoutBottomSheet> {
  bool _loading = false;
  final _phoneCtrl = TextEditingController();
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userValue = ref.read(currentUserDataProvider).value;
      if (userValue != null) {
        _phoneCtrl.text = (userValue['phone'] ?? '').toString();
        final userModel = UserModel.fromMap(userValue);
        if (userModel.addresses.isNotEmpty) {
          final initialAddr =
              userModel.defaultAddress ?? userModel.addresses.first;
          setState(() {
            _selectedAddressId = initialAddr.id;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  void _openEditProfile() {
    context.pop();
    context.push('/edit-profile');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userValue = ref.watch(currentUserDataProvider).value;
    final userModel = userValue != null ? UserModel.fromMap(userValue) : null;
    final cartNotifier = ref.watch(cartProvider.notifier);

    final subtotal = ref.watch(cartSubtotalProvider);
    final deliveryFee = ref.watch(cartDeliveryFeeProvider);
    final discount = ref.watch(cartDiscountProvider);
    final pointsDiscount = ref.watch(cartPointsDiscountProvider);
    final total = ref.watch(cartTotalProvider);
    final minOrderValue = ref.watch(cartMinimumOrderValueProvider);
    final orderShortfall = ref.watch(cartShortfallProvider);

    final isAddressMissing = userModel == null || userModel.addresses.isEmpty;
    final isBelowMinimumOrder = orderShortfall > 0;

    AddressModel? selectedAddress;
    if (userModel != null && _selectedAddressId != null) {
      try {
        selectedAddress =
            userModel.addresses.firstWhere((a) => a.id == _selectedAddressId);
      } catch (_) {
        selectedAddress =
            userModel.addresses.isNotEmpty ? userModel.addresses.first : null;
      }
    }

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 16),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 20),
        if (isAddressMissing) ...[
          _buildAddressCompletionPrompt(),
        ] else ...[
          DropdownButtonFormField<String>(
            initialValue: _selectedAddressId,
            items: userModel.addresses
                .map((addr) => DropdownMenuItem(
                    value: addr.id,
                    child: Text(addr.name,
                        style: const TextStyle(fontWeight: FontWeight.bold))))
                .toList(),
            decoration: AppStyles.inputDecoration('Delivery To', isDark,
                prefix: const Icon(Icons.location_on_rounded,
                    size: 18, color: AppStyles.primaryColor)),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedAddressId = v);
              }
            },
            hint: const Text('Select Address'),
          ),
          const SizedBox(height: 12),
          TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: AppStyles.inputDecoration(_t('contactPhone'), isDark,
                  prefix: const Icon(Icons.phone_iphone_rounded,
                      size: 18, color: AppStyles.primaryColor))),
          const SizedBox(height: 24),
          _summary(
              subtotal,
              deliveryFee,
              isDark,
              discount,
              pointsDiscount,
              total,
              minOrderValue,
              orderShortfall),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: (selectedAddress == null || _loading || isBelowMinimumOrder)
                ? null
                : () => _placeOrder(cartNotifier, ref.read(cartProvider),
                    userModel, selectedAddress!),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 8,
                shadowColor: AppStyles.primaryColor.withValues(alpha: 0.4)),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(_t('confirmOrder').toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const SizedBox(height: 20),
        ],
      ]),
    );
  }

  Widget _buildAddressCompletionPrompt() {
    return Column(children: [
      const Icon(Icons.home_work_outlined, size: 60, color: Colors.orange),
      const SizedBox(height: 16),
      const Text('Add a Delivery Address',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      const SizedBox(height: 8),
      const Text(
          'Please add at least one address (Home or Office) to proceed with your order.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13)),
      const SizedBox(height: 24),
      ElevatedButton(
          onPressed: _openEditProfile,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          child: const Text('GO TO SETTINGS',
              style: TextStyle(fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _summary(double sub, double del, bool d, double discount,
      double ptsDiscount, double total, double minOrderValue, double orderShortfall) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppStyles.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppStyles.primaryColor.withValues(alpha: 0.1))),
      child: Column(children: [
        _row(_t('subtotal'), '৳${sub.toInt()}'),
        if (discount > 0)
          _row('Coupon Discount', '- ৳${discount.toInt()}', c: Colors.green),
        if (ptsDiscount > 0)
          _row('Points Discount', '- ৳${ptsDiscount.toInt()}',
              c: Colors.orange),
        _row(_t('deliveryFee'), '+ ৳${del.toInt()}'),
        if (orderShortfall > 0)
          _row(
            'Minimum Order',
            'Need ৳${orderShortfall.toInt()} more',
            c: Colors.orange,
          ),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
        _row(_t('totalPayable'), '৳${total.toInt()}', b: true),
        if (orderShortfall > 0) ...[
          const SizedBox(height: 10),
          Text(
            'Minimum order is ৳${minOrderValue.toInt()}. Add a bit more to place this order.',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ]),
    );
  }

  Widget _row(String l, String v, {bool b = false, Color? c}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l,
            style: TextStyle(
                fontWeight: b ? FontWeight.w900 : FontWeight.bold,
                fontSize: b ? 16 : 13)),
        Text(v,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: b ? 18 : 14,
                color: c ?? (b ? AppStyles.primaryColor : null)))
      ]));

  Future<void> _placeOrder(
      CartNotifier c, CartState state, UserModel u, AddressModel addr) async {
    setState(() => _loading = true);

    final double subtotal = ref.read(cartSubtotalProvider);
    final double deliveryFee = ref.read(cartDeliveryFeeProvider);
    final double discount = ref.read(cartDiscountProvider);
    final double pointsDiscount = ref.read(cartPointsDiscountProvider);
    final double finalTotal = ref.read(cartTotalProvider);
    final double orderShortfall = ref.read(cartShortfallProvider);

    if (orderShortfall > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Add ৳${orderShortfall.toInt()} more to meet the minimum order.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      setState(() => _loading = false);
      return;
    }

    try {
      final items = state.items
          .map((i) => {
                'productId': i.id,
                'productName': i.name,
                'price': i.price,
                'quantity': i.quantity,
                'imageUrl': i.imageUrl
              })
          .toList();

      final orderData = {
        'customerUid': u.id,
        'customerName': u.name,
        'customerPhone': _phoneCtrl.text.trim(),
        'deliveryAddress': addr.fullAddress,
        'deliveryArea': addr.area,
        'deliveryAreaId': addr.areaId,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'discount': discount,
        'pointsDiscount': pointsDiscount,
        'totalAmount': finalTotal,
        'status': 'Pending',
        'items': items,
        'isEmergency': false,
        'orderType': 'regular',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await ref.read(firestoreServiceProvider).placeOrder(orderData);

      await ref
          .read(loyaltyServiceProvider)
          .handleReferralPurchase(u.id, subtotal);

      c.clearCart();

      if (mounted) {
        Navigator.pop(context);
        context.push('/orders');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
