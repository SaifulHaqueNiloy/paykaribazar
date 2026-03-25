import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../di/providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_styles.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> {
  bool _isAiBusy = false;

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  Future<void> _runAiForecast() async {
    setState(() => _isAiBusy = true);
    try {
      final String result = await ref.read(forecastingServiceProvider).predictRestockNeed();
      // Update the database with the new forecast
      await FirebaseFirestore.instance.collection('analytics').doc('daily_stats').set({
        'ai_insight': result,
        'last_ai_update': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to generate new forecast.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('analytics').doc('daily_stats').snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final forecastMsg = data['ai_insight'] as String? ?? 'No insight available. Tap to analyze.';
        
        return RefreshIndicator(
          onRefresh: _runAiForecast,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAiInsightCard(isDark, forecastMsg),
                const SizedBox(height: 20),
                _buildStatGrid(data),
                const SizedBox(height: 20),
                Text(
                  _t('sales_overview'),
                  style: AppStyles.headingStyle.copyWith(color: isDark ? Colors.white : Colors.black87, fontSize: 20),
                ),
                const SizedBox(height: 12),
                _buildSalesChart(isDark, data['weekly_sales'] as List? ?? []),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildAiInsightCard(bool isDark, String message) {
    return GestureDetector(
      onTap: _isAiBusy ? null : _runAiForecast,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.teal.withValues(alpha: 0.1) : Colors.teal.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'AI INSIGHT',
                  style: AppStyles.subheadingStyle.copyWith(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isAiBusy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
                  )
                else
                  const Icon(Icons.refresh, size: 16, color: Colors.teal),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppStyles.bodyStyle.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGrid(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Revenue', '৳${data['revenue'] ?? '0'}', Icons.payments, Colors.green),
        _buildStatCard('Orders', '${data['orders_count'] ?? '0'}', Icons.shopping_bag, Colors.blue),
        _buildStatCard('Active Users', '${data['active_users'] ?? '0'}', Icons.people, Colors.orange),
        _buildStatCard('Conversion', '${data['conversion_rate'] ?? '0'}%', Icons.trending_up, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: AppStyles.subheadingStyle.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: AppStyles.bodyStyle.copyWith(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSalesChart(bool isDark, List weeklySales) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, right: 20, left: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: weeklySales.isEmpty 
        ? const Center(child: Text('No sales data yet'))
        : LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(weeklySales.length, (i) => FlSpot(i.toDouble(), (weeklySales[i] as num).toDouble())),
                  isCurved: true,
                  color: AppStyles.primaryColor,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppStyles.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

