import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../di/providers.dart';
import '../../utils/styles.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('আমার ওয়ালেট (My Wallet)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: userAsync.when(
        data: (data) {
          final points = data?['points'] ?? 0;
          final uid = data?['id']?.toString() ?? FirebaseAuth.instance.currentUser?.uid ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildBalanceCard(points, isDark),
                const SizedBox(height: 24),
                _buildActionRow(),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('লেনদেনের ইতিহাস', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                _buildTransactionList(uid, isDark),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBalanceCard(int points, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.indigo.shade800]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Text('মোট ব্যালেন্স (পয়েন্ট)', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('$points', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('≈ ৳${(points / 10).toStringAsFixed(2)}', style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        _walletAction('পয়েন্ট রিডিম', Icons.redeem_rounded, Colors.orange),
        const SizedBox(width: 12),
        _walletAction('পয়েন্ট ট্রান্সফার', Icons.send_rounded, Colors.blue),
      ],
    );
  }

  Widget _walletAction(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(String uid, bool isDark) {
    if (uid.isEmpty) return const SizedBox.shrink();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(HubPaths.users)
          .doc(uid)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 12)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('কোনো লেনদেনের ইতিহাস পাওয়া যায়নি।', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String title = data['title'] ?? 'পয়েন্ট অ্যাড';
            final int pointsVal = (data['points'] ?? 0).toInt();
            final String type = data['type'] ?? 'credit';
            final Timestamp? timeStamp = data['createdAt'] as Timestamp?;
            final String timeStr = timeStamp != null 
                ? '${timeStamp.toDate().day}/${timeStamp.toDate().month}/${timeStamp.toDate().year}'
                : '';

            final bool isCredit = type == 'credit';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: (isCredit ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? Colors.green : Colors.red, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (timeStr.isNotEmpty)
                            Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '${isCredit ? "+" : "-"}$pointsVal',
                    style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

