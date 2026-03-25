import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/ai_system_health_monitor.dart';
import '../services/ai_configuration_manager.dart';

/// Admin Dashboard for AI System Monitoring
class AIAdminDashboard extends ConsumerWidget {
  final String? userId;

  const AIAdminDashboard({this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🤖 AI System Admin Dashboard'),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: '📊 Dashboard'),
              Tab(text: '📈 Metrics'),
              Tab(text: '⚙️ Config'),
              Tab(text: '🚨 Alerts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DashboardTab(userId: userId),
            _MetricsTab(userId: userId),
            _ConfigurationTab(userId: userId),
            _AlertsTab(userId: userId),
          ],
        ),
      ),
    );
  }
}

/// Main Dashboard Tab
class _DashboardTab extends ConsumerWidget {
  final String? userId;

  const _DashboardTab({this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(currentHealthProvider);
    final trendsAsync = ref.watch(healthTrendsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(currentHealthProvider);
        ref.invalidate(healthTrendsProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current Health Card
            healthAsync.when(
              data: (health) => _HealthCard(health: health),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => DashboardErrorWidget(error: err, stackTrace: st),
            ),
            const SizedBox(height: 16),

            // Trends Card
            trendsAsync.when(
              data: (trends) => _TrendsCard(trends: trends),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => DashboardErrorWidget(error: err, stackTrace: st),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    onPressed: () {
                      ref.invalidate(currentHealthProvider);
                      ref.invalidate(healthTrendsProvider);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export'),
                    onPressed: () => _showExportDialog(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Diagnostics'),
        content: const Text('Export system diagnostics data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement export logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diagnostics exported')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

/// Health Status Card
class _HealthCard extends StatelessWidget {
  final AISystemHealth health;

  const _HealthCard({required this.health});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'System Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${health.statusEmoji} ${health.systemStatus.toUpperCase()}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HealthMetricRow(
              title: 'Daily Quota',
              value: '${health.remainingQuota} / ${health.dailyQuotaLimit}',
              percentage: health.quotaRemainingPercent,
              color: _getProgressColor(health.quotaRemainingPercent),
            ),
            const SizedBox(height: 12),
            _HealthMetricRow(
              title: 'Cache Hit Rate',
              value: '${health.cacheHitRate.toStringAsFixed(1)}%',
              percentage: health.cacheHitRate,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _HealthMetricRow(
              title: 'Requests/Min',
              value: '${health.requestsPerMinute} / 60',
              percentage: (health.requestsPerMinute / 60) * 100,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Avg Response Time'),
                Text('${health.averageResponseTimeMs.toStringAsFixed(0)}ms'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Errors (24h)'),
                Badge(
                  label: Text('${health.totalErrors24h}'),
                  backgroundColor:
                      health.totalErrors24h > 50 ? Colors.red : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Requests'),
                Text('${health.totalRequests}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percent) {
    if (percent > 50) return Colors.green;
    if (percent > 20) return Colors.orange;
    return Colors.red;
  }
}

/// Health Metric Row Widget
class _HealthMetricRow extends StatelessWidget {
  final String title;
  final String value;
  final double percentage;
  final Color color;

  const _HealthMetricRow({
    required this.title,
    required this.value,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

/// Trends Card
class _TrendsCard extends StatelessWidget {
  final AIHealthTrends trends;

  const _TrendsCard({required this.trends});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '24-Hour Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _TrendRow(
              label: 'Avg Cache Hit Rate',
              value: '${trends.averageCacheHitRate.toStringAsFixed(1)}%',
            ),
            _TrendRow(
              label: 'Peak Requests/Min',
              value: '${trends.peakRequestsPerMinute}',
            ),
            _TrendRow(
              label: 'Avg Response Time',
              value: '${trends.averageResponseTime.toStringAsFixed(0)}ms',
            ),
            _TrendRow(
              label: 'Total Errors',
              value: '${trends.totalErrorsInPeriod}',
            ),
            _TrendRow(
              label: 'Uptime',
              value: '${trends.uptimePercent.toStringAsFixed(1)}%',
            ),
            _TrendRow(
              label: 'Avg Quota Usage',
              value: '${trends.quotaUsagePercent.toStringAsFixed(1)}%',
            ),
          ],
        ),
      ),
    );
  }
}

/// Trend Row Widget
class _TrendRow extends StatelessWidget {
  final String label;
  final String value;

  const _TrendRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Metrics Tab
class _MetricsTab extends ConsumerWidget {
  final String? userId;

  const _MetricsTab({this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(currentHealthProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(currentHealthProvider),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          healthAsync.when(
            data: (health) => Column(
              children: [
                _MetricCard(
                  title: 'Cache Performance',
                  metrics: [
                    MetricItem(
                      label: 'Hit Rate',
                      value: '${health.cacheHitRate.toStringAsFixed(1)}%',
                      icon: Icons.check_circle,
                    ),
                    MetricItem(
                      label: 'Total Requests',
                      value: '${health.totalRequests}',
                      icon: Icons.request_page,
                    ),
                    MetricItem(
                      label: 'Cached',
                      value: '${health.cachedRequests}',
                      icon: Icons.storage,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MetricCard(
                  title: 'Performance',
                  metrics: [
                    MetricItem(
                      label: 'Avg Response',
                      value:
                          '${health.averageResponseTimeMs.toStringAsFixed(0)}ms',
                      icon: Icons.speed,
                    ),
                    MetricItem(
                      label: 'Neural Load',
                      value: '${health.neuraiLoad.toStringAsFixed(0)}%',
                      icon: Icons.memory,
                    ),
                    MetricItem(
                      label: 'Check Duration',
                      value: '${health.durationMs}ms',
                      icon: Icons.timer,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _MetricCard(
                  title: 'Quota Usage',
                  metrics: [
                    MetricItem(
                      label: 'Used',
                      value:
                          '${health.dailyQuotaLimit - health.remainingQuota}',
                      icon: Icons.trending_up,
                    ),
                    MetricItem(
                      label: 'Remaining',
                      value: '${health.remainingQuota}',
                      icon: Icons.trending_down,
                    ),
                    MetricItem(
                      label: 'Usage %',
                      value: '${health.quotaUsagePercent.toStringAsFixed(1)}%',
                      icon: Icons.pie_chart,
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => DashboardErrorWidget(error: err, stackTrace: st),
          ),
        ],
      ),
    );
  }
}

/// Metric Card Widget
class _MetricCard extends StatelessWidget {
  final String title;
  final List<MetricItem> metrics;

  const _MetricCard({required this.title, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: metrics.map((m) => _MetricItemWidget(item: m)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Metric Item Widget
class _MetricItemWidget extends StatelessWidget {
  final MetricItem item;

  const _MetricItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 24, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            item.value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Metric Item Model
class MetricItem {
  final String label;
  final String value;
  final IconData icon;

  MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

/// Configuration Tab
class _ConfigurationTab extends ConsumerWidget {
  final String? userId;

  const _ConfigurationTab({this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate Limiting',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showRateLimitDialog(context, ref),
                    child: const Text('Adjust Rate Limits'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cache Configuration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showCacheConfigDialog(context, ref),
                    child: const Text('Adjust Cache Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Model Configuration',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showModelConfigDialog(context, ref),
                    child: const Text('Switch Models'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _showResetDialog(context, ref),
                      child: const Text('Reset to Defaults'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRateLimitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _RateLimitDialog(ref: ref),
    );
  }

  void _showCacheConfigDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CacheConfigDialog(ref: ref),
    );
  }

  void _showModelConfigDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _ModelConfigDialog(ref: ref),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Configuration?'),
        content: const Text('This will reset all configurations to defaults.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final manager = AIConfigurationManager();
              await manager.resetToDefaults();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Configuration reset to defaults')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// Rate Limit Configuration Dialog
class _RateLimitDialog extends StatefulWidget {
  final WidgetRef ref;

  const _RateLimitDialog({required this.ref});

  @override
  State<_RateLimitDialog> createState() => _RateLimitDialogState();
}

class _RateLimitDialogState extends State<_RateLimitDialog> {
  late TextEditingController _requestsPerMinController;
  late TextEditingController _dailyQuotaController;

  @override
  void initState() {
    super.initState();
    _requestsPerMinController = TextEditingController(text: '60');
    _dailyQuotaController = TextEditingController(text: '10000');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adjust Rate Limits'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _requestsPerMinController,
            decoration: const InputDecoration(
              labelText: 'Requests Per Minute',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dailyQuotaController,
            decoration: const InputDecoration(
              labelText: 'Daily Quota Limit',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final manager = AIConfigurationManager();
            await manager.updateRateLimit(
              requestsPerMinute: int.parse(_requestsPerMinController.text),
              dailyQuotaLimit: int.parse(_dailyQuotaController.text),
            );
            if (context.mounted) Navigator.pop(context);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rate limits updated')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _requestsPerMinController.dispose();
    _dailyQuotaController.dispose();
    super.dispose();
  }
}

/// Cache Configuration Dialog
class _CacheConfigDialog extends StatefulWidget {
  final WidgetRef ref;

  const _CacheConfigDialog({required this.ref});

  @override
  State<_CacheConfigDialog> createState() => _CacheConfigDialogState();
}

class _CacheConfigDialogState extends State<_CacheConfigDialog> {
  late TextEditingController _maxEntriesController;
  late TextEditingController _durationHoursController;

  @override
  void initState() {
    super.initState();
    _maxEntriesController = TextEditingController(text: '500');
    _durationHoursController = TextEditingController(text: '1');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cache Configuration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _maxEntriesController,
            decoration: const InputDecoration(
              labelText: 'Max Cache Entries',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _durationHoursController,
            decoration: const InputDecoration(
              labelText: 'Cache Duration (Hours)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final manager = AIConfigurationManager();
            await manager.updateCacheConfig(
              maxEntries: int.parse(_maxEntriesController.text),
              cacheDurationHours: int.parse(_durationHoursController.text),
            );
            if (context.mounted) Navigator.pop(context);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache configuration updated')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _maxEntriesController.dispose();
    _durationHoursController.dispose();
    super.dispose();
  }
}

/// Model Configuration Dialog
class _ModelConfigDialog extends StatefulWidget {
  final WidgetRef ref;

  const _ModelConfigDialog({required this.ref});

  @override
  State<_ModelConfigDialog> createState() => _ModelConfigDialogState();
}

class _ModelConfigDialogState extends State<_ModelConfigDialog> {
  late String _primaryModel;
  late String _fallbackModel;

  @override
  void initState() {
    super.initState();
    _primaryModel = 'gemini-2.0-flash';
    _fallbackModel = 'gemini-1.5-pro';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Model Configuration'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: _primaryModel,
            items: const [
              DropdownMenuItem(
                  value: 'gemini-2.0-flash', child: Text('Gemini 2.0 Flash')),
              DropdownMenuItem(
                  value: 'gemini-1.5-pro', child: Text('Gemini 1.5 Pro')),
            ],
            onChanged: (value) =>
                setState(() => _primaryModel = value ?? 'gemini-2.0-flash'),
            isExpanded: true,
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _fallbackModel,
            items: const [
              DropdownMenuItem(
                  value: 'gemini-1.5-pro', child: Text('Gemini 1.5 Pro')),
              DropdownMenuItem(
                  value: 'gemini-2.0-flash', child: Text('Gemini 2.0 Flash')),
            ],
            onChanged: (value) =>
                setState(() => _fallbackModel = value ?? 'gemini-1.5-pro'),
            isExpanded: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final manager = AIConfigurationManager();
            await manager.updateModelConfig(
              primaryModel: _primaryModel,
              fallbackModel: _fallbackModel,
            );
            if (context.mounted) Navigator.pop(context);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Model configuration updated')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Alerts Tab
class _AlertsTab extends ConsumerWidget {
  final String? userId;

  const _AlertsTab({this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(healthAlertsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(healthAlertsProvider),
      child: alertsAsync.when(
        data: (alerts) => alerts.isEmpty
            ? const Center(child: Text('No alerts at this time ✅'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                itemBuilder: (context, index) =>
                    _AlertCard(alert: alerts[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Alert Card Widget
class _AlertCard extends StatelessWidget {
  final AIHealthAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(left: BorderSide(color: alert.severityColor, width: 4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.severityLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: alert.severityColor,
                    ),
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(alert.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(alert.message),
          ],
        ),
      ),
    );
  }
}

/// Error Widget
class DashboardErrorWidget extends StatelessWidget {
  final dynamic error;
  final StackTrace stackTrace;

  const DashboardErrorWidget({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }
}
