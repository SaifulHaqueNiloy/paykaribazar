import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../utils/styles.dart';
import '../../../di/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AiAuditTab extends ConsumerStatefulWidget {
  const AiAuditTab({super.key});

  @override
  ConsumerState<AiAuditTab> createState() => _AiAuditTabState();
}

class _AiAuditTabState extends ConsumerState<AiAuditTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final _db = FirebaseFirestore.instance;

  final Map<String, bool> _expandedGroups = {
    'translation': true,
    'content': true,
    'seo': true,
    'category': true,
    'new_content': true,
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auditDataAsync = ref.watch(groupedAiAuditProvider);

    return auditDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) {
        final stats = data['stats'];
        final groups = data['groups'];

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(groupedAiAuditProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildLiveStatsGraph(stats, isDark),
              const SizedBox(height: 20),
              _buildSearchBar(isDark),
              const SizedBox(height: 20),
              _buildGroupHeader('TRANSLATIONS', Icons.translate,
                  groups['translation'], 'translation', isDark),
              _buildGroupHeader('CONTENT UPDATES', Icons.description,
                  groups['content'], 'content', isDark),
              _buildGroupHeader(
                  'SEO & TAGS', Icons.search, groups['seo'], 'seo', isDark),
              _buildGroupHeader('CATEGORIZATION', Icons.category,
                  groups['category'], 'category', isDark),
              _buildGroupHeader('NEW PRODUCTS', Icons.new_releases,
                  groups['new_content'], 'new_content', isDark),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveStatsGraph(Map<String, dynamic> stats, bool isDark) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('AI AUDIT REAL-TIME DATA',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.2)),
              Text('Total Logs: ${stats['total']}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 35,
                      sections: [
                        PieChartSectionData(
                            value: (stats['translation_total'] ?? 0).toDouble(),
                            color: Colors.green,
                            radius: 18,
                            showTitle: false),
                        PieChartSectionData(
                            value: (stats['content_total'] ?? 0).toDouble(),
                            color: Colors.orange,
                            radius: 18,
                            showTitle: false),
                        PieChartSectionData(
                            value: (stats['seo_total'] ?? 0).toDouble(),
                            color: Colors.blue,
                            radius: 18,
                            showTitle: false),
                        PieChartSectionData(
                            value: (stats['category_total'] ?? 0).toDouble(),
                            color: Colors.purple,
                            radius: 18,
                            showTitle: false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statLabel(
                          'Translations',
                          (stats['translation_pending'] ?? 0).toInt(),
                          (stats['translation_total'] ?? 0).toInt(),
                          Colors.green),
                      _statLabel('Descriptions', (stats['content_pending'] ?? 0).toInt(),
                          (stats['content_total'] ?? 0).toInt(), Colors.orange),
                      _statLabel('SEO & Tags', (stats['seo_pending'] ?? 0).toInt(),
                          (stats['seo_total'] ?? 0).toInt(), Colors.blue),
                      _statLabel('Categories', (stats['category_pending'] ?? 0).toInt(),
                          (stats['category_total'] ?? 0).toInt(), Colors.purple),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PENDING REVIEW',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.redAccent)),
                          Text('${stats['pending']}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.redAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statLabel(String label, int pending, int total, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold))),
          Text('$pending P / $total',
              style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return TextField(
      onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
      decoration: AppStyles.inputDecoration('Search by product name...', isDark,
          prefix: const Icon(Icons.search)),
    );
  }

  Widget _buildGroupHeader(String title, IconData icon,
      List<Map<String, dynamic>>? logs, String key, bool isDark) {
    if (logs == null || logs.isEmpty) return const SizedBox.shrink();
    final isExpanded = _expandedGroups[key] ?? true;

    return Column(
      children: [
        ListTile(
          onTap: () => setState(() => _expandedGroups[key] = !isExpanded),
          leading: Icon(icon, color: AppStyles.primaryColor, size: 18),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.2)),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
              size: 18),
        ),
        if (isExpanded)
          ...logs.map((log) {
            final titleText = (log['title'] ?? '').toString().toLowerCase();
            if (_searchQuery.isNotEmpty && !titleText.contains(_searchQuery)) {
              return const SizedBox.shrink();
            }
            return _buildAuditCard(log, isDark);
          }),
      ],
    );
  }

  Widget _buildAuditCard(Map<String, dynamic> data, bool isDark) {
    final String logId = data['id'];
    final String status = data['status'] ?? 'pending';
    final bool isApproved = status == 'approved';
    final oldValues =
        (data['oldValues'] as Map?)?.cast<String, dynamic>() ?? {};
    final newValues =
        (data['newValues'] as Map?)?.cast<String, dynamic>() ?? {};

    final String? aiImageUrl = newValues['imageUrl'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: isDark ? Colors.white10 : Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: (isApproved ? Colors.green : Colors.orange)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(isApproved ? Icons.check_circle : Icons.pending,
                    color: isApproved ? Colors.green : Colors.orange, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(data['title'] ?? 'AI Suggestion',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 13))),
              Text(status.toUpperCase(),
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isApproved ? Colors.green : Colors.orange)),
            ]),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1)),

            if (aiImageUrl != null)
              Container(
                height: 140,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                      image: NetworkImage(aiImageUrl), fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6)
                        ]),
                  ),
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.bottomLeft,
                  child: const Text('AI SUGGESTED IMAGE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
              ),

            ...newValues.entries
                .where((e) => e.key != 'imageUrl' && e.key != 'imageUrls')
                .map((e) => _buildChangeRow(e.key, oldValues[e.key], e.value)),

            const SizedBox(height: 16),
            if (!isApproved)
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                        onPressed: () => _handleReject(logId),
                        child: const Text('REJECT',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                        onPressed: () => _handleApprove(logId, data),
                        child: const Text('APPROVE',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)))),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeRow(String key, dynamic oldVal, dynamic newVal) {
    if (newVal == null || newVal == oldVal) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key.toUpperCase(),
              style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
                child: Text(oldVal?.toString() ?? '(Empty)',
                    style: const TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey))),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child:
                    Icon(Icons.arrow_right_alt, size: 14, color: Colors.blue)),
            Expanded(
                child: Text(newVal?.toString() ?? '',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w700))),
          ]),
        ],
      ),
    );
  }

  void _handleApprove(String id, Map<String, dynamic> data) async {
    try {
      final targetId = data['targetId'];
      final col = data['collection'] ?? 'products';
      final newVals = Map<String, dynamic>.from(data['newValues'] ?? {});

      await _db.collection(col).doc(targetId).update({
        ...newVals,
        'aiOptimized': true,
        'aiAuditPending': false,
        'lastAiUpdate': FieldValue.serverTimestamp(),
      });

      await _db
          .collection('ai_audit_logs')
          .doc(id)
          .update({'status': 'approved'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Update Approved Successfully!')));
      }
    } catch (e) {
      debugPrint('Approval Error: $e');
    }
  }

  void _handleReject(String id) async {
    await _db
        .collection('ai_audit_logs')
        .doc(id)
        .update({'status': 'rejected'});
    await _db.collection('products').doc(id).update({'aiAuditPending': false});
  }
}
