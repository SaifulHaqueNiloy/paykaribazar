import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details #$orderId'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ordersAsync.when(
        data: (orders) {
          final order =
              orders.firstWhere((o) => o['id'] == orderId, orElse: () => {});
          if (order.isEmpty) {
            return const Center(child: Text('Order not found'));
          }

          final status = order['status'] ?? 'Pending';
          final items = (order['items'] as List? ?? []);
          final total = (order['total'] as num? ?? 0.0).toDouble();
          final address = order['address'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(status),
                const SizedBox(height: 24),
                const Text('ITEMS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const Divider(),
                ...items.map((item) => _buildOrderItem(item)),
                const Divider(),
                _buildTotalRow('Subtotal', '৳${total.toInt()}'),
                _buildTotalRow('Delivery Fee', '৳0'),
                _buildTotalRow('Total', '৳${total.toInt()}', isBold: true),
                const SizedBox(height: 24),
                if (address != null) ...[
                  const Text('SHIPPING ADDRESS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const Divider(),
                  Text(address['name'] ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(address['phone'] ?? 'N/A'),
                  Text(address['addressLine'] ?? 'N/A'),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatusBanner(String status) => Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _getStatusColor(status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: _getStatusColor(status)),
            const SizedBox(width: 12),
            Text('Status: $status',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status))),
          ],
        ),
      );

  Widget _buildOrderItem(dynamic item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Qty: ${item['quantity']} | Price: ৳${item['price']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Text('৳${(item['price'] * item['quantity']).toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
            Text(value,
                style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    fontSize: isBold ? 18 : 14,
                    color: isBold ? Colors.teal : null)),
          ],
        ),
      );

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
