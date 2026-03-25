import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/di/providers.dart'; // MASTER HUB
import 'package:paykari_bazar/src/core/services/security_initializer.dart';
import '../../utils/styles.dart';

class CheckoutBottomSheet extends ConsumerStatefulWidget {
  const CheckoutBottomSheet({super.key});
  @override
  ConsumerState<CheckoutBottomSheet> createState() =>
      _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends ConsumerState<CheckoutBottomSheet> {
  bool _isProcessing = false;

  Future<void> _handleConfirmOrder() async {
    final authState = ref.watch(authStateProvider);
    final uid = authState.value?.uid;
    final total = ref.watch(cartTotalProvider);
    final cartState = ref.watch(cartProvider);

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to place order')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // ⭐ SECURITY: Step 1 - Biometric Verification for high-value operations
      final secureAuth = SecurityInitializer.secureAuth;
      final isAuthenticated = await secureAuth.authenticateForSensitiveOperation(
        localizedReason: 'Confirm payment of ৳${total.toInt()}',
      );

      if (!isAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification failed. Order not placed.')),
          );
        }
        return;
      }

      // ⭐ SECURITY: Step 2 - Sign API Request (Simulation)
      final apiSecurity = SecurityInitializer.apiSecurity;
      final encryption = SecurityInitializer.encryption;

      final orderData = {
        'customerUid': uid,
        'items': cartState.items
            .map((i) => {
                  'id': i.id,
                  'name': i.name,
                  'qty': i.quantity,
                  'price': i.price,
                })
            .toList(),
        'total': total,
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
        'security_token': encryption.encrypt(uid), // Encrypt sensitive field
      };

      // Get secure headers for the "API call"
      final headers = apiSecurity.getSecureHeaders(
        endpoint: '/api/orders/place',
        body: orderData.toString(),
      );
      debugPrint('✅ Secure Headers generated: ${headers['X-Signature']}');

      // Place order logic
      await ref.read(firestoreServiceProvider).placeOrder(orderData);

      // Clear cart after order
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed securely! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final total = ref.watch(cartTotalProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Checkout Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('৳${subtotal.toInt()}'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('৳${total.toInt()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppStyles.primaryColor)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isProcessing ? null : _handleConfirmOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: _isProcessing
                ? const CircularProgressIndicator(color: Colors.white)
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 20),
                      SizedBox(width: 10),
                      Text('CONFIRM SECURE ORDER',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Protected by biometric encryption',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
