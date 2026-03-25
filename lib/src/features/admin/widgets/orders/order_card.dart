import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart'; // MASTER HUB
import '../../../../utils/styles.dart';
import '../../../../utils/invoice_helper.dart';
import '../../../../utils/app_strings.dart';
import '../../../orders/order_tracking_screen.dart';

class OrderCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  final List<Map<String, dynamic>> staff;
  final bool isDark;

  const OrderCard({
    super.key,
    required this.order,
    required this.staff,
    required this.isDark,
  });

  @override
  ConsumerState<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<OrderCard> {
  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final status = widget.order['status']?.toString() ?? 'Pending';
    final items = widget.order['items'] as List? ?? [];
    final statusColor = AppStyles.getStatusColor(status);
    final bool isEmergency = widget.order['isEmergency'] ?? false;
    final String type = widget.order['orderType']?.toString() ?? 'regular';
    final bool isBlood = type == 'blood';
    final String area = widget.order['deliveryArea']?.toString() ?? 'N/A';
    final String customerName =
        widget.order['customerName']?.toString() ?? _t('guest');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: widget.isDark ? AppStyles.darkSurfaceColor : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: (isEmergency)
                  ? Colors.red
                  : (widget.isDark ? Colors.white10 : Colors.grey.shade200),
              width: (isEmergency) ? 2 : 1)),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
                child: Text(customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14))),
            if (isEmergency)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(6)),
                child: Text(isBlood ? 'BLOOD' : 'EMERGENCY',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Text(
            isBlood
                ? 'Urgent Blood Help • $status'
                : "৳${widget.order['totalAmount']} • $status • $area",
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        leading: CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(
                isBlood
                    ? Icons.bloodtype_rounded
                    : AppStyles.getStatusIcon(status),
                color: isBlood ? Colors.red : statusColor,
                size: 20)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildActionHeader(
                  context, widget.order, isBlood, isEmergency, status),
              _infoRow(
                  Icons.phone_rounded,
                  'Phone',
                  (widget.order['customerPhone'] ?? widget.order['phone'])
                      ?.toString()),
              if (isBlood) ...[
                const Divider(height: 24),
                _infoRow(
                    Icons.water_drop_rounded,
                    'Blood Group',
                    (widget.order['bloodGroup'] ?? widget.order['group'])
                        ?.toString(),
                    c: Colors.red),
                _infoRow(
                    Icons.inventory_2_rounded,
                    'Bags Needed',
                    (widget.order['bagsNeeded'] ?? widget.order['bags'])
                        ?.toString()),
                _infoRow(
                    Icons.local_hospital_rounded,
                    'Hospital/Location',
                    (widget.order['hospitalArea'] ?? widget.order['location'])
                        ?.toString()),
                _infoRow(
                    Icons.notes_rounded,
                    'Note',
                    (widget.order['notes'] ?? widget.order['note'])
                        ?.toString()),
              ] else ...[
                _infoRow(Icons.location_on_rounded, 'Address',
                    widget.order['deliveryAddress']?.toString()),
                const Divider(height: 24),
                ...items.map((it) => _itemRow(it)),
              ],
              const Divider(height: 24),
              _buildManagementSection(context, ref, status, isEmergency),
            ]),
          )
        ],
      ),
    );
  }

  Widget _buildActionHeader(BuildContext context, Map<String, dynamic> order,
      bool isBlood, bool isEmergency, String status) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(_t('actions').toUpperCase(),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
      Row(children: [
        IconButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OrderTrackingScreen(orderId: order['id']))),
          icon: const Icon(Icons.map_rounded, size: 18, color: Colors.blue),
          tooltip: 'Track Live',
        ),
        if (isEmergency && status == 'Pending')
          TextButton.icon(
              onPressed: () => _resendEmergencyAlert(order),
              icon: const Icon(Icons.record_voice_over_rounded,
                  size: 14, color: Colors.red),
              label: const Text('RESEND ALERT',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red))),
        if (!isBlood)
          TextButton.icon(
              onPressed: () => InvoiceHelper.generateAndPrintInvoice(order),
              icon: const Icon(Icons.print_rounded, size: 14),
              label: Text(_t('downloadInvoice').toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold)))
      ])
    ]);
  }

  Future<void> _resendEmergencyAlert(Map<String, dynamic> order) async {
    final String type = order['orderType'] ?? 'medicine';
    if (type == 'blood') {
      await ref.read(notificationServiceProvider).sendBloodRequestAlert(
          requestId: order['id'],
          group: order['group'],
          location: order['location'],
          bags: order['bags'] ?? 1);
    } else {
      await ref.read(notificationServiceProvider).broadcastNotification(
          '🆘 EMERGENCY ORDER',
          'New urgent medicine order from ${order['customerName']}',
          relatedId: order['id']);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Notification Broadcasted Again!'),
          backgroundColor: Colors.green));
    }
  }

  Widget _infoRow(IconData icon, String label, String? val, {Color? c}) {
    return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(children: [
          Icon(icon, size: 14, color: c ?? AppStyles.primaryColor),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[700])),
          Expanded(
              child: Text(val ?? 'N/A',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)))
        ]));
  }

  Widget _itemRow(dynamic it) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Text("${it['quantity']}x ",
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          Expanded(
              child: Text(it['productName']?.toString() ?? 'Item',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          Text("৳${(it['price'] ?? 0) * (it['quantity'] ?? 1)}",
              style: const TextStyle(fontWeight: FontWeight.bold))
        ]));
  }

  Widget _buildManagementSection(
      BuildContext context, WidgetRef ref, String status, bool isEmergency) {
    const availableStatuses = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled'
    ];
    final String? assignedName =
        (widget.order['assignedStaffName'] ?? widget.order['assignedHeroName'])
            ?.toString();

    return Column(children: [
      _dropdownRow(
          '${_t('assignTo')}:',
          Row(
            children: [
              if (assignedName != null)
                Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(assignedName,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo))),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded,
                    color: Colors.blue, size: 20),
                onPressed: () => _showAssignDialog(context, isEmergency),
              ),
            ],
          )),
      _dropdownRow(
          '${_t('status')}:',
          DropdownButton<String>(
            value: availableStatuses.contains(status) ? status : 'Pending',
            underline: const SizedBox(),
            dropdownColor:
                widget.isDark ? AppStyles.darkSurfaceColor : Colors.white,
            items: availableStatuses
                .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s,
                        style: TextStyle(
                            color: AppStyles.getStatusColor(s),
                            fontWeight: FontWeight.w900,
                            fontSize: 13))))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                _handleStatusChange(v);
              }
            },
          )),
    ]);
  }

  void _showAssignDialog(BuildContext context, bool isEmergency) {
    String search = '';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEmergency
              ? _t('assignStaffOrCustomer')
              : _t('assignStaffOnly')),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                      hintText: _t('searchHint'),
                      prefixIcon: const Icon(Icons.search)),
                  onChanged: (v) =>
                      setDialogState(() => search = v.toLowerCase()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final allUsers = snapshot.data!.docs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] ?? '').toString().toLowerCase();
                        final phone = (data['phone'] ?? '').toString();
                        final role = (data['role'] ?? 'customer').toString();

                        final bool matchesSearch =
                            name.contains(search) || phone.contains(search);
                        if (isEmergency) return matchesSearch;
                        return matchesSearch &&
                            (role == 'staff' ||
                                role == 'admin' ||
                                role == 'logistic');
                      }).toList();

                      return ListView.builder(
                        itemCount: allUsers.length,
                        itemBuilder: (c, i) {
                          final u = allUsers[i].data() as Map<String, dynamic>;
                          final role = (u['role'] ?? 'customer').toString();
                          final name = (u['name'] ?? _t('noName')).toString();
                          return ListTile(
                            leading: CircleAvatar(
                                child: Text(role.isNotEmpty
                                    ? role[0].toUpperCase()
                                    : 'U')),
                            title: Text(name),
                            subtitle: Text("${u['phone']} ($role)"),
                            onTap: () async {
                              final updateData = {
                                'assignedTo': allUsers[i].id,
                                'assignedStaffName':
                                    role != 'customer' ? name : null,
                                'assignedHeroId':
                                    role == 'customer' ? allUsers[i].id : null,
                                'assignedHeroName':
                                    role == 'customer' ? name : null,
                                'status': 'Processing'
                              };
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(widget.order['id'].toString())
                                  .update(updateData);
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleStatusChange(String newStatus) async {
    final String orderId = widget.order['id'].toString();
    final String customerUid = widget.order['customerUid'].toString();
    final String customerName =
        (widget.order['customerName'] ?? 'Customer').toString();
    final double totalAmount = (widget.order['totalAmount'] ?? 0.0).toDouble();
    final bool isEmergency = widget.order['isEmergency'] ?? false;

    if (newStatus == 'Cancelled') {
      await ref
          .read(loyaltyServiceProvider)
          .removePurchasePoints(customerUid, orderId);
    }

    if (newStatus == 'Delivered') {
      await ref
          .read(loyaltyServiceProvider)
          .updateTopBuyerStats(customerUid, customerName, totalAmount);

      if (isEmergency) {
        await ref.read(notificationServiceProvider).deactivateAlerts(orderId);
      }
    }
    await ref
        .read(firestoreServiceProvider)
        .updateOrderStatus(orderId, newStatus);
  }

  Widget _dropdownRow(String label, Widget child) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        child
      ]);
}
