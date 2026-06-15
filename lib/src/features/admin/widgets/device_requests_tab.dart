import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../utils/styles.dart';

class DeviceRequestsTab extends ConsumerWidget {
  const DeviceRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('device_approval_requests')
          .where('status', isEqualTo: 'Pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phonelink_lock_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('No pending device requests', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;
            return _buildRequestCard(context, doc.id, data, isDark);
          },
        );
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, String requestId, Map<String, dynamic> data, bool isDark) {
    final String name = data['userName'] ?? 'Unknown Staff';
    final String role = data['role'] ?? 'Staff';
    final String deviceName = data['deviceName'] ?? 'Device';
    final String deviceId = data['deviceId'] ?? 'ID Not Found';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                child: const Icon(Icons.person_rounded, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    Text(role.toUpperCase(), style: const TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                  ],
                ),
              ),
              if (timestamp != null)
                Text(DateFormat('hh:mm a').format(timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.important_devices_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Device ID: $deviceId', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontFamily: 'monospace')),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleAction(requestId, deviceId, data['uid'], false),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('REJECT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleAction(requestId, deviceId, data['uid'], true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('APPROVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _handleAction(String requestId, String deviceId, String uid, bool isApproved) async {
    final firestore = FirebaseFirestore.instance;
    
    if (isApproved) {
      // Add device to user's approved list
      await firestore.collection('users').doc(uid).update({
        'approvedDevices': FieldValue.arrayUnion([deviceId])
      });
    }

    // Delete the request
    await firestore.collection('device_approval_requests').doc(requestId).delete();
  }
}

