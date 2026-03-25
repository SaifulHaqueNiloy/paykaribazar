import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/styles.dart';

class AiNotificationsTab extends ConsumerWidget {
  const AiNotificationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 24));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ai_notifications_queue')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(cutoff))
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_motion_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                const Text('No AI notifications awaiting approval', style: TextStyle(color: Colors.grey)),
                const Text('All items expire after 24 hours', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? now;
            final expiry = createdAt.add(const Duration(hours: 24));
            final hoursLeft = expiry.difference(now).inHours;
            final minsLeft = expiry.difference(now).inMinutes % 60;
            final status = data['status'] ?? 'pending_approval';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: status == 'approved' ? Colors.green.withValues(alpha: 0.3) : AppStyles.primaryColor.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'approved' ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status.toUpperCase().replaceAll('_', ' '),
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Expires in: ${hoursLeft}h ${minsLeft}m',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(data['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(data['body'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text("Target User: ${data['userId'] ?? 'Unknown'}", style: const TextStyle(fontSize: 9, color: Colors.blueGrey)),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status == 'pending_approval') ...[
                          TextButton.icon(
                            onPressed: () => _showEditDialog(context, doc.id, data),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text('EDIT'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _approveAndSend(doc.id, data),
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('APPROVE & SEND'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          ),
                        ] else 
                          const Text('SENT SUCCESSFULLY', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => doc.reference.delete(),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveAndSend(String docId, Map<String, dynamic> data) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // 1. Move to active notifications collection
    final notifRef = db.collection('notifications').doc();
    batch.set(notifRef, {
      'userId': data['userId'],
      'title': data['title'],
      'body': data['body'],
      'type': data['type'],
      'status': 'pending', // Will be picked up by NotificationService listener
      'createdAt': FieldValue.serverTimestamp(),
      'priority': 'high',
    });

    // 2. Mark as approved in queue
    batch.update(db.collection('ai_notifications_queue').doc(docId), {
      'status': 'approved',
      'sentAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    final titleCtrl = TextEditingController(text: data['title']);
    final bodyCtrl = TextEditingController(text: data['body']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit AI Content'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: bodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Body Message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('ai_notifications_queue').doc(docId).update({
                'title': titleCtrl.text.trim(),
                'body': bodyCtrl.text.trim(),
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
