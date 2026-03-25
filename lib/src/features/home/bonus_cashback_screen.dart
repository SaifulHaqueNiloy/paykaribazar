import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';

class BonusCashbackScreen extends ConsumerWidget {
  const BonusCashbackScreen({super.key});

  String _t(WidgetRef ref, String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(appSettingsProvider).value ?? {};

    return Scaffold(
      backgroundColor:
          isDark ? AppStyles.darkBackgroundColor : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(settings['bonusTitleBn'] ?? _t(ref, 'bonusRewards')),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bonus_faqs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final faqs = snapshot.data!.docs;

          if (faqs.isEmpty) {
            return Center(child: Text(_t(ref, 'noInfoAvailable')));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionLabel(_t(ref, 'bonusCashbackDetails')),
              const SizedBox(height: 8),
              ...faqs.map((doc) {
                final faq = doc.data() as Map<String, dynamic>;
                return _buildDashboardTile(
                  icon: Icons.auto_awesome_rounded,
                  title: faq['question'] ?? '',
                  onTap: () => _showDetailsDialog(
                      context, faq['question'], faq['answer']),
                );
              }),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1)),
      );

  Widget _buildDashboardTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF00695C), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Colors.grey, size: 20),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, String q, String a) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(q,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C))),
        content: SingleChildScrollView(
          child: Text(a,
              style: const TextStyle(
                  fontSize: 14, height: 1.6, color: Colors.black87)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(AppStrings.get('close', 'en'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF00695C))))
        ],
      ),
    );
  }
}
