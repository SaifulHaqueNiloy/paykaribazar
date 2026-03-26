import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/utils/styles.dart';

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(appConfigProvider);
    final rulesAsync = ref.watch(businessRulesProvider);
    final featureFlagsAsync = ref.watch(featureFlagsProvider);
    final quotaAsync = ref.watch(apiQuotaStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: configAsync.when(
        data: (config) => rulesAsync.when(
          data: (rules) => featureFlagsAsync.when(
            data: (flags) => quotaAsync.when(
              data: (quotas) =>
                  _buildContent(config, rules, flags, quotas, isDark),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error quotas: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error flags: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error rules: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error config: $e')),
      ),
    );
  }

  Widget _buildContent(
    Map<String, dynamic> config,
    Map<String, dynamic> rules,
    Map<String, dynamic> flags,
    List<Map<String, dynamic>> quotas,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('APP CONFIGURATION'),
        _buildExpand('System Status', Icons.settings_suggest_rounded, Column(
          children: [
            _buildAutoTile('Maintenance Mode', 'Block all customer access',
                config['maintenanceMode'] ?? false, 'maintenanceMode'),
            _buildAutoTile('Force Update', 'Force users to latest version',
                config['forceUpdate'] ?? false, 'forceUpdate'),
          ],
        )),
        
        _buildSectionHeader('BUSINESS RULES'),
        _buildExpand('Commerce Controls', Icons.shopping_bag_rounded, Column(
          children: [
            _buildInputTile(
                'Free Delivery Above',
                'Threshold for free shipping',
                rules['free_delivery_threshold']?.toString() ?? '1000',
                (v) => _updateRule(
                    'free_delivery_threshold', double.tryParse(v) ?? 1000),
                isDark),
            _buildInputTile(
                'Base Delivery Fee',
                'Standard delivery fallback cost',
                rules['delivery_fee_base']?.toString() ?? '50',
                (v) => _updateRule('delivery_fee_base', double.tryParse(v) ?? 50),
                isDark),
            _buildInputTile(
                'Minimum Order Value',
                'Minimum cart subtotal before checkout',
                rules['min_order_value']?.toString() ?? '1000',
                (v) => _updateRule('min_order_value', double.tryParse(v) ?? 1000),
                isDark),
          ],
        )),

        _buildSectionHeader('DESIGN & UI SCALARS'),
        _buildExpand('Global Aesthetics', Icons.palette_rounded, Column(
          children: [
            _buildDropdownTile(
                'Text Scale',
                'Overall text size multiplier',
                config['text_scale']?.toString() ?? '1.0',
                ['0.8', '0.9', '1.0', '1.1', '1.2'],
                (v) => _updateConfig('text_scale', double.parse(v!)),
                isDark),
            _buildDropdownTile(
                'Button Scale',
                'Primary buttons size',
                config['button_scale']?.toString() ?? '1.0',
                ['0.8', '1.0', '1.2'],
                (v) => _updateConfig('button_scale', double.parse(v!)),
                isDark),
          ],
        )),

        _buildSectionHeader('AI & API LIMITS'),
        _buildExpand('Quota Management', Icons.speed_rounded, Column(
          children: quotas.isEmpty
              ? [const ListTile(title: Text('No API Keys currently tracked.'))]
              : quotas.map((q) => _buildApiQuotaTile(q, isDark)).toList(),
        )),

        _buildSectionHeader('MAINTENANCE'),
        _buildExpand('System Optimization', Icons.build_rounded, Column(
          children: [
            ListTile(
              title: const Text('One-Click Optimizer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: const Text('Clear Cache & Perform System Audit',
                  style: TextStyle(fontSize: 10)),
              trailing: ElevatedButton(
                onPressed: _isLoading ? null : _runOneClickOptimizer,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: _isLoading
                    ? const SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('RUN',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        )),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildApiQuotaTile(Map<String, dynamic> quota, bool isDark) {
    final id = (quota['id'] ?? quota['provider'] ?? 'AI').toString();
    final limit = (quota['daily_limit'] ?? 1500).toString();
    final used = (quota['used_today'] ?? 0).toString();

    return ListTile(
      title: Text(id.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      subtitle: Text('Used: $used / Limit: $limit', style: const TextStyle(fontSize: 10)),
      trailing: IconButton(
        icon: const Icon(Icons.edit, size: 18),
        onPressed: () => _editQuota(id, int.parse(limit)),
      ),
    );
  }

  void _editQuota(String id, int currentLimit) {
    final ctrl = TextEditingController(text: currentLimit.toString());
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Update Limit for $id'),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily Limit')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final newLimit = int.tryParse(ctrl.text) ?? currentLimit;
              await _updateApiQuotaEntry(id, {'daily_limit': newLimit});
              if (mounted) Navigator.pop(c);
            },
            child: const Text('SAVE'),
          )
        ],
      )
    );
  }

  Future<void> _updateApiQuotaEntry(String entryId, Map<String, dynamic> patch) async {
    // FIXED: Using the shared settings/api_quota document where keys list is stored
    final docRef = FirebaseFirestore.instance.doc('settings/api_quota');
    final snap = await docRef.get();
    if (!snap.exists) return;

    final List keys = List.from(snap.data()?['keys'] ?? []);
    bool updated = false;

    for (int i = 0; i < keys.length; i++) {
      final entry = Map<String, dynamic>.from(keys[i]);
      if (entry['id'] == entryId || entry['provider'] == entryId) {
        entry.addAll(patch);
        keys[i] = entry;
        updated = true;
        break;
      }
    }

    if (updated) {
      await docRef.update({'keys': keys});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quota updated successfully!')));
    }
  }

  Future<void> _runOneClickOptimizer() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(aiAutomationProvider).performGlobalSystemCheck();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('System Integrity Check & Optimization Complete!'),
            backgroundColor: Colors.teal));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
              letterSpacing: 1.5)),
    );
  }

  Widget _buildDropdownTile(String title, String sub, String current,
      List<String> options, Function(String?) onChanged, bool isDark) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 10)),
      trailing: DropdownButton<String>(
        value: options.contains(current) ? current : options.first,
        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        underline: const SizedBox(),
        items: options
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAutoTile(String title, String sub, bool current, String key) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 10)),
      trailing: Switch(
        value: current,
        onChanged: (v) => _updateConfig(key, v),
        activeThumbColor: AppStyles.primaryColor,
      ),
    );
  }

  Widget _buildInputTile(String title, String sub, String current,
      Function(String) onSave, bool isDark) {
    return ListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 10)),
      trailing: SizedBox(
        width: 84,
        child: TextField(
          controller: TextEditingController(text: current),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onSubmitted: onSave,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            fillColor: isDark ? Colors.white10 : Colors.grey[100],
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Future<void> _updateConfig(String key, dynamic value) async {
    await FirebaseFirestore.instance.doc(HubPaths.configDoc).set({key: value}, SetOptions(merge: true));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Setting updated!'), duration: Duration(seconds: 1)));
  }

  Future<void> _updateRule(String key, dynamic value) async {
    await FirebaseFirestore.instance.doc('settings/business_rules').set(
      {key: value},
      SetOptions(merge: true),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Business rule updated!'),
      backgroundColor: Colors.teal,
      duration: Duration(seconds: 1),
    ));
    }
  }

  Widget _buildExpand(String title, IconData icon, Widget children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      child: ExpansionTile(
        leading: Icon(icon, color: AppStyles.primaryColor, size: 20),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1)),
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: children)
        ],
      ),
    );
  }
}
