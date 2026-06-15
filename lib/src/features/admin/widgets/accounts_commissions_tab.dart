import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../di/providers.dart';

class AccountsCommissionsTab extends ConsumerWidget {
  const AccountsCommissionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commsAsync = ref.watch(allCommissionsProvider);

    return commsAsync.when(
      data: (comms) {
        if (comms.isEmpty) {
          return const Center(child: Text('No commission records found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: comms.length,
          itemBuilder: (context, index) {
            final c = comms[index];
            final bool isPaid = c['isPaid'] ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPaid
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  child: Icon(isPaid ? Icons.check_circle : Icons.pending,
                      color: isPaid ? Colors.green : Colors.orange),
                ),
                title: Text(c['riderName'] ?? 'Rider',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "৳${c['amount']} • Order: #${c['orderId'].toString().substring(0, 5)}\nDate: ${DateFormat('dd MMM').format((c['timestamp'] as dynamic).toDate())}"),
                trailing: isPaid
                    ? const Text('PAID',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10))
                    : ElevatedButton(
                        onPressed: () => ref
                            .read(firestoreService)
                            .markCommissionPaid(c['id']),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12)),
                        child: const Text('PAY NOW',
                            style: TextStyle(fontSize: 10)),
                      ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
