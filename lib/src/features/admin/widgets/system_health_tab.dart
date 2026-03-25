import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/core/firebase/firebase_billing_monitor.dart';
import 'package:paykari_bazar/src/utils/styles.dart';

class SystemHealthTab extends ConsumerWidget {
  const SystemHealthTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiStatusAsync = ref.watch(aiStatusProvider);
    final healthAsync = ref.watch(healthCheckProvider);
    final billingMetricsAsync = ref.watch(firebaseBillingMetricsProvider);
    final usageMetricsAsync = ref.watch(firebaseUsageMetricsProvider);
    final quotaSummary = ref.watch(apiQuotaSummaryProvider);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('SYSTEM & NEURAL DIAGNOSTICS',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.blueGrey)),
          const SizedBox(height: 20),
          
          // Basic System Health
          healthAsync.when(
            data: (health) => Column(
              children: [
                _buildStatusCard(
                  'Core System Status', 
                  health['status'] ?? 'Unknown', 
                  health['status'] == 'Healthy' ? Colors.green : Colors.orange,
                  Icons.settings_suggest_rounded
                ),
                _buildStatusCard(
                  'Firebase Gateway', 
                  health['firebaseLive'] == true ? 'LIVE' : 'OFFLINE',
                  health['firebaseLive'] == true ? Colors.green : Colors.red,
                  Icons.cloud_done_rounded
                ),
                _buildStatusCard(
                  'Network Integrity', 
                  health['isOnline'] == true ? 'CONNECTED' : 'DISCONNECTED',
                  health['isOnline'] == true ? Colors.green : Colors.red,
                  Icons.wifi_rounded
                ),
              ],
            ),
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (e, _) => Text('Health Check Error: $e'),
          ),

          const SizedBox(height: 20),
          const Text('AI NEURAL METRICS',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.blueGrey)),
          const SizedBox(height: 20),

          // AI Specific Metrics
          aiStatusAsync.when(
            data: (ai) => Column(
              children: [
                _buildStatusCard(
                  'Neural Engine', 
                  ai['NEURAL'] ?? 'OFFLINE', 
                  ai['NEURAL'] == 'HEALTHY' ? Colors.blue : Colors.red,
                  Icons.psychology_rounded
                ),
                _buildStatusCard(
                  'Active API Keys', 
                  ai['KEYS'] ?? '0', 
                  Colors.purple,
                  Icons.vpn_key_rounded
                ),
                _buildStatusCard(
                  'Neural Load', 
                  ai['LOAD'] ?? '0%', 
                  Colors.orange,
                  Icons.speed_rounded
                ),
                _buildStatusCard(
                  'Engine Latency', 
                  ai['LATENCY'] ?? '0ms', 
                  Colors.cyan,
                  Icons.timer_rounded
                ),
              ],
            ),
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Text('AI Status Error: $e'),
          ),

          const SizedBox(height: 20),
          const Text('FIREBASE BILLING & QUOTA',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.blueGrey)),
          const SizedBox(height: 20),

          billingMetricsAsync.when(
            data: (metrics) => Column(
              children: [
                _buildStatusCard(
                  'Estimated Firebase Cost',
                  '\$${((metrics['estimatedCostUSD'] ?? 0.0) as num).toStringAsFixed(4)}',
                  Colors.teal,
                  Icons.attach_money_rounded,
                ),
                _buildStatusCard(
                  'Firestore Reads',
                  '${metrics['firestoreReads'] ?? 0}',
                  Colors.indigo,
                  Icons.menu_book_rounded,
                ),
                _buildStatusCard(
                  'Firestore Writes',
                  '${metrics['firestoreWrites'] ?? 0}',
                  Colors.deepOrange,
                  Icons.edit_rounded,
                ),
                _buildStatusCard(
                  'Storage Operations',
                  '${metrics['storageOperations'] ?? 0}',
                  Colors.cyan,
                  Icons.cloud_upload_rounded,
                ),
              ],
            ),
            loading: () => const Center(child: LinearProgressIndicator()),
            error: (e, _) => Text('Billing Metrics Error: $e'),
          ),

          _buildQuotaSummaryCard(quotaSummary),

          usageMetricsAsync.when(
            data: (page) => _buildRecentUsageCard(page),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Usage Activity Error: $e'),
          ),

          const SizedBox(height: 30),
          _buildMaintenanceInfo(),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withValues(alpha: 0.1))
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), 
            borderRadius: BorderRadius.circular(8)
          ),
          child: Text(
            value, 
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppStyles.primaryColor.withValues(alpha: 0.1))
      ),
      child: const Column(
        children: [
          Icon(Icons.info_outline_rounded, color: AppStyles.primaryColor),
          SizedBox(height: 10),
          Text(
            'The system performs a full self-diagnostic every 24 hours. AI models are automatically rotated to maintain optimal performance and quota availability.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaSummaryCard(Map<String, dynamic> summary) {
    final usagePercent = (summary['usagePercent'] as num?)?.toDouble() ?? 0.0;
    final progress = ((usagePercent / 100).clamp(0.0, 1.0) as num).toDouble();
    final color = usagePercent >= 90
        ? Colors.red
        : usagePercent >= 75
            ? Colors.orange
            : Colors.green;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: color.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed_rounded, color: color, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'API QUOTA OVERVIEW',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                Text(
                  '${usagePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metricPill('Keys', '${summary['totalKeys'] ?? 0}'),
                _metricPill('Active', '${summary['activeKeys'] ?? 0}'),
                _metricPill('Exhausted', '${summary['exhaustedKeys'] ?? 0}'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Usage: ${summary['totalUsage'] ?? 0} / ${summary['totalLimit'] ?? 0}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsageCard(UsageMetricsPage page) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RECENT BILLING ACTIVITY',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            if (page.records.isEmpty)
              const Text(
                'No billing activity recorded yet.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ...page.records.take(5).map(
              (record) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppStyles.primaryColor.withValues(alpha: 0.08),
                  child: const Icon(
                    Icons.bolt_rounded,
                    size: 16,
                    color: AppStyles.primaryColor,
                  ),
                ),
                title: Text(
                  record.type.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Qty: ${record.quantity} • ${record.timestamp.toLocal()}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

