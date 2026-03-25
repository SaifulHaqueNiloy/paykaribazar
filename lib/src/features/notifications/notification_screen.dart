import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../di/providers.dart';
import '../../utils/styles.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please login to view notifications')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('নোটিফিকেশন (Notifications)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => _markAllAsRead(user.uid),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(HubPaths.notifications)
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final docId = notifications[index].id;
              return _buildNotificationTile(context, docId, data, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('আপনার কোনো নোটিফিকেশন নেই', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, String docId, Map<String, dynamic> data, bool isDark) {
    final bool isRead = data['status'] == 'read' || data['status'] == 'delivered';
    final timestamp = data['createdAt'] as Timestamp?;
    final timeStr = timestamp != null ? DateFormat('dd MMM, hh:mm a').format(timestamp.toDate()) : '';
    final type = data['data']?['type'] ?? 'general';

    return GestureDetector(
      onTap: () => _handleTap(context, docId, data),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? (isRead ? const Color(0xFF1E293B) : const Color(0xFF334155)) : (isRead ? Colors.white : Colors.indigo.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(15),
          border: isRead ? null : Border.all(color: AppStyles.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(type),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'Notice',
                          style: TextStyle(fontWeight: isRead ? FontWeight.bold : FontWeight.w900, fontSize: 14),
                        ),
                      ),
                      Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['body'] ?? '',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'order':
        iconData = Icons.shopping_bag_rounded;
        color = Colors.blue;
        break;
      case 'chat':
        iconData = Icons.chat_rounded;
        color = Colors.green;
        break;
      case 'blood':
        iconData = Icons.bloodtype_rounded;
        color = Colors.red;
        break;
      case 'promo':
        iconData = Icons.card_giftcard_rounded;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.notifications_rounded;
        color = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  void _handleTap(BuildContext context, String docId, Map<String, dynamic> data) {
    FirebaseFirestore.instance.collection(HubPaths.notifications).doc(docId).update({'status': 'read'});
    // Logic for navigation based on notification type can be added here
  }

  void _markAllAsRead(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final snap = await FirebaseFirestore.instance
        .collection(HubPaths.notifications)
        .where('userId', isEqualTo: uid)
        .where('status', isNotEqualTo: 'read')
        .get();

    for (var doc in snap.docs) {
      batch.update(doc.reference, {'status': 'read'});
    }
    await batch.commit();
  }
}
