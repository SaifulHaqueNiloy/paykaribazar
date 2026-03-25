import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Service Imports
import '../../di/providers.dart';
import '../../utils/app_strings.dart';
import '../../utils/styles.dart';
import '../../utils/version_utils.dart'; // DNA ENFORCED

// Widget Imports
import 'widgets/analytics_tab.dart';
import 'widgets/system_health_tab.dart';
import 'widgets/inventory_forecasting_widget.dart';
import 'widgets/orders_tab.dart';
import 'widgets/catalog_tab.dart';
import 'widgets/logistics_tab.dart';
import 'widgets/hr_teams_tab.dart';
import 'widgets/accounts_tab.dart';
import 'widgets/reseller_applications_tab.dart';
import 'widgets/interactions_tab.dart';
import 'widgets/ai_master_tab.dart';
import 'widgets/database_tab.dart';
import 'widgets/settings_tab.dart';
import 'widgets/localization_tab.dart';
import 'widgets/fleet_tab.dart';

class AdminScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  const AdminScreen({super.key, this.isAdmin = false});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with TickerProviderStateMixin {
  String _version = '1.0.0';
  late TabController _mainTabCtrl;

  @override
  void initState() {
    super.initState();
    _mainTabCtrl = TabController(length: 5, vsync: this);
    _initVersion();
  }

  @override
  void dispose() {
    _mainTabCtrl.dispose();
    super.dispose();
  }

  Future<void> _initVersion() async {
    final displayVersion = await VersionUtils.getDisplayVersion();
    if (mounted) {
      setState(() => _version = displayVersion);
    }
  }

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_t('adminPanel').toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                Text('v$_version',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            _buildViewStoreBtn(),
          ],
        ),
        bottom: TabBar(
          controller: _mainTabCtrl,
          isScrollable: true,
          indicatorColor: AppStyles.accentColor,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          tabs: const [
            Tab(
                text: 'DASHBOARD',
                icon: Icon(Icons.dashboard_rounded, size: 20)),
            Tab(
                text: 'COMMERCE',
                icon: Icon(Icons.shopping_bag_rounded, size: 20)),
            Tab(text: 'PEOPLE', icon: Icon(Icons.groups_rounded, size: 20)),
            Tab(text: 'INTELLIGENCE', icon: Icon(Icons.bolt_rounded, size: 20)),
            Tab(
                text: 'SYSTEM',
                icon: Icon(Icons.settings_suggest_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _mainTabCtrl,
        children: [
          _buildDashboardHub(),
          _buildCommerceHub(),
          _buildPeopleHub(),
          _buildIntelligenceHub(),
          _buildSystemHub(),
        ],
      ),
    );
  }

  Widget _buildViewStoreBtn() {
    return TextButton.icon(
      onPressed: () async {
        final uid = ref.read(authProvider).currentUser?.uid;
        if (uid != null) {
          // DNA ENFORCED: Switch mode to shopping to allow MainScreen to morph to Customer Panel
          await ref
              .read(firestoreService)
              .updateProfile(uid, {'currentMode': 'shopping'});
        }
        if (mounted) context.go('/');
      },
      icon: const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
      label: Text(_t('viewStore').toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
      style: TextButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(horizontal: 12)),
    );
  }

  // --- NESTED HUB BUILDERS ---

  Widget _buildDashboardHub() {
    return _nestedTabController(2, [
      const Tab(text: 'OVERVIEW'),
      const Tab(text: 'ANALYTICS'),
    ], [
      SingleChildScrollView(
        child: Column(children: [
          const InventoryForecastingWidget(),
          _buildQuickActionGrid()
        ]),
      ),
      const AnalyticsTab(),
    ]);
  }

  Widget _buildCommerceHub() {
    return _nestedTabController(3, [
      const Tab(text: 'ORDERS'),
      const Tab(text: 'CATALOG'),
      const Tab(text: 'LOGISTICS'),
    ], [
      const OrdersTab(),
      CatalogTab(isAdmin: widget.isAdmin),
      const LogisticsTab(),
    ]);
  }

  Widget _buildPeopleHub() {
    return _nestedTabController(4, [
      const Tab(text: 'TEAMS'),
      const Tab(text: 'ACCOUNTS'),
      const Tab(text: 'RESELLERS'),
      const Tab(text: 'CHATS'),
    ], [
      const HrTeamsTab(),
      const AccountsTab(),
      const ResellerApplicationsTab(),
      const InteractionsTab(),
    ]);
  }

  Widget _buildIntelligenceHub() {
    return _nestedTabController(4, [
      const Tab(text: 'AI MASTER'),
      const Tab(text: 'DATABASE'),
      const Tab(text: 'AI HEALTH'),
      const Tab(text: 'VIRTUAL LAB'),
    ], [
      const AiMasterTab(),
      _buildGroupedDatabaseHub(),
      const SystemHealthTab(),
      const VirtualDataLab(),
    ]);
  }

  Widget _buildSystemHub() {
    return _nestedTabController(3, [
      const Tab(text: 'SETTINGS'),
      const Tab(text: 'LANG'),
      const Tab(text: 'FLEET'),
    ], [
      const SettingsTab(),
      const LocalizationTab(),
      const FleetTab(),
    ]);
  }

  // Helper for Nested Tab UI
  Widget _nestedTabController(int len, List<Widget> tabs, List<Widget> views) {
    return DefaultTabController(
      length: len,
      child: Column(
        children: [
          Container(
            color: Colors.white.withValues(alpha: 0.05),
            child: TabBar(
              indicatorColor: AppStyles.primaryColor,
              labelColor: AppStyles.primaryColor,
              unselectedLabelColor: Colors.grey,
              labelStyle:
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              tabs: tabs,
            ),
          ),
          Expanded(child: TabBarView(children: views)),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.5,
        children: [
          _actionCard('Orders Manager', Icons.shopping_bag_rounded,
              Colors.orange, () => _mainTabCtrl.animateTo(1)),
          _actionCard('Catalog Manager', Icons.inventory_2_rounded, Colors.blue,
              () {
            _mainTabCtrl.animateTo(1);
          }),
          _actionCard('AI Master Console', Icons.bolt_rounded, Colors.purple,
              () => _mainTabCtrl.animateTo(3)),
          _actionCard('User Support', Icons.support_agent_rounded, Colors.green,
              () => _mainTabCtrl.animateTo(2)),
        ],
      ),
    );
  }

  Widget _actionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withValues(alpha: 0.2))),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedDatabaseHub() {
    final Map<String, List<String>> groups = {
      'COMMERCE': [
        HubPaths.orders,
        HubPaths.products,
        HubPaths.categories,
        HubPaths.locations
      ],
      'USERS': [HubPaths.users, 'notices'],
      'EMERGENCY': [HubPaths.donors, HubPaths.doctors, HubPaths.helplines],
      'SYSTEM': ['settings', 'ai_audit_logs', HubPaths.privateChats],
    };

    return _nestedTabController(
        groups.length,
        groups.keys.map((g) => Tab(text: g)).toList(),
        groups.values
            .map((collections) => _nestedTabController(
                collections.length,
                collections
                    .map((c) => Tab(text: c.split('/').last.toUpperCase()))
                    .toList(),
                collections
                    .map((c) => DatabaseTab(collectionName: c))
                    .toList()))
            .toList());
  }
}

class VirtualDataLab extends ConsumerStatefulWidget {
  const VirtualDataLab({super.key});

  @override
  ConsumerState<VirtualDataLab> createState() => _VirtualDataLabState();
}

class _VirtualDataLabState extends ConsumerState<VirtualDataLab> with TickerProviderStateMixin {
  late TabController _labTab;
  String _selectedSource = 'users';
  String _intent = 'Cross-reference data to find valuable insights';
  bool _isProcessing = false;
  Map<String, dynamic>? _result;

  final List<String> _collections = [
    'users', 'products', 'orders', 'categories', 'carts', 'locations', 
    'reseller_applications', 'donors', 'doctors', 'blood_requests',
    'hero_records', 'bonus_faqs', 'notices', 'settings', 'ai_audit_logs',
    'ai_work_audit', 'system_alerts', 'ai_notifications_queue', 
    'device_approval_requests', 'SYSTEM_WIDE_ANALYSIS'
  ];

  @override
  void initState() {
    super.initState();
    _labTab = TabController(length: 3, vsync: this);
  }

  void _runSynthesis() async {
    setState(() => _isProcessing = true);
    try {
      final List<Map<String, dynamic>> data = [];
      
      if (_selectedSource == 'SYSTEM_WIDE_ANALYSIS') {
        // Sample core collections for deep synthesis
        final targets = ['users', 'products', 'orders', 'donors'];
        for (var col in targets) {
          final snap = await FirebaseFirestore.instance.collection(col).limit(10).get();
          data.addAll(snap.docs.map((d) => {...d.data(), '_collection': col}));
        }
      } else {
        final snap = await FirebaseFirestore.instance.collection(_selectedSource).limit(50).get();
        data.addAll(snap.docs.map((d) => d.data()));
      }

      final result = await ref.read(aiServiceProvider).synthesizeCrossData(
        sourceCollection: _selectedSource,
        intent: _intent,
        rawData: data,
      );

      setState(() => _result = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Synthesis Error: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _commitToProduction() async {
    if (_result == null || _result!['items'] == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Commit to Production?'),
        content: Text('AI is about to architect and save ${_result!['items'].length} new records based on this synthesis. This is a permanent administrative action.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('PROCEED')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final String targetCol = _result!['target_collection'] ?? 'ai_synthesized_data';
      final List items = _result!['items'] as List;

      final batch = FirebaseFirestore.instance.batch();
      for (var item in items) {
        final docRef = FirebaseFirestore.instance.collection(targetCol).doc();
        batch.set(docRef, {
          ...Map<String, dynamic>.from(item),
          'synthesizedAt': FieldValue.serverTimestamp(),
          'synthesisIntent': _intent,
          'sourceCollection': _selectedSource,
        });
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Successfully committed ${items.length} records to $targetCol'),
        backgroundColor: Colors.green
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Commit Error: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        TabBar(
          controller: _labTab,
          indicatorColor: Colors.indigo,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: 'SYNTHESIS', icon: Icon(Icons.psychology_rounded, size: 18)),
            Tab(text: 'MOOD', icon: Icon(Icons.palette_rounded, size: 18)),
            Tab(text: 'CUSTOM UI', icon: Icon(Icons.tune_rounded, size: 18)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _labTab,
            children: [
              _buildSynthesisTab(isDark),
              const DesignControlTab(),
              const CustomUiLabTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSynthesisTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OMNIPOTENT DATA SYNTHESIS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.blueGrey)),
          const SizedBox(height: 20),
          _buildDropdown('SOURCE COLLECTION', _collections, _selectedSource, (v) => setState(() => _selectedSource = v!)),
          const SizedBox(height: 16),
          _buildInput('SYNTHESIS INTENT', 'e.g. Find users who are both doctors and blood donors', (v) => _intent = v),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _runSynthesis,
              icon: _isProcessing 
                ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_fix_high_rounded),
              label: Text(_isProcessing ? 'SYNTHESIZING...' : 'RUN CROSS-DOMAIN SYNTHESIS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 30),
            _buildResultView(isDark),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _commitToProduction,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('COMMIT SYNTHESIS TO PRODUCTION'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))).toList(),
            onChanged: onChange,
            isExpanded: true,
          ),
        ),
      ),
    ]);
  }

  Widget _buildInput(String label, String hint, Function(String) onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12),
          filled: true,
          fillColor: Colors.blueGrey.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
        ),
        onChanged: onChange,
      ),
    ]);
  }

  Widget _buildResultView(bool isDark) {
    final items = _result!['items'] as List? ?? [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.verified_rounded, color: Colors.green, size: 20),
            const SizedBox(width: 10),
            Text(_result!['title'] ?? 'Synthesized Knowledge', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ]),
          const SizedBox(height: 10),
          Text(_result!['description'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
          const Divider(height: 30),
          ...items.map((item) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.withValues(alpha: 0.1),
              child: const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.indigo)
            ),
            title: Text(item['title'] ?? 'Record', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text(item['subtitle'] ?? '', style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
          )),
        ],
      ),
    );
  }
}

class DesignControlTab extends ConsumerWidget {
  const DesignControlTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final String currentMood = data['active_mood'] ?? 'default';

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('APP VISUAL MOOD CONTROL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.blueGrey)),
            const SizedBox(height: 20),
            _buildMoodOption(context, 'Standard Pro', '0xFF6200EE', 'default', currentMood, 'The classic Paykari Bazar look.', Icons.auto_awesome_rounded),
            _buildMoodOption(context, 'Golden Sunny', '0xFFFFC107', 'sunny', currentMood, 'Bright and energetic yellow theme.', Icons.wb_sunny_rounded),
            _buildMoodOption(context, 'Winter Frost', '0xFFE3F2FD', 'winter', currentMood, 'Cool blue theme for winter season.', Icons.ac_unit_rounded),
            _buildMoodOption(context, 'Festive Red', '0xFFD32F2F', 'festive', currentMood, 'Celebration mode for Eid or Pujas.', Icons.celebration_rounded),
            _buildMoodOption(context, 'Deep Night', '0xFF1A237E', 'night', currentMood, 'Ultra dark indigo for night owls.', Icons.nightlight_round),
          ],
        );
      }
    );
  }

  Widget _buildMoodOption(BuildContext context, String name, String colorHex, String moodKey, String current, String desc, IconData icon) {
    final bool isSelected = current == moodKey;
    final Color themeColor = Color(int.parse(colorHex));

    return GestureDetector(
      onTap: () {
        FirebaseFirestore.instance.collection('settings').doc('app_config').set({
          'active_mood': moodKey,
          'primary_color': colorHex,
        }, SetOptions(merge: true));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? themeColor : Colors.grey.withValues(alpha: 0.1), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

class CustomUiLabTab extends ConsumerWidget {
  const CustomUiLabTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('settings').doc('app_config').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('CUSTOM UI SCALING & COLORS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.blueGrey)),
            const SizedBox(height: 24),
            _buildSectionTitle('TEXT & SCALING'),
            _buildSlider(context, 'Global Text Scale', 'text_scale', data['text_scale'] ?? 1.0, 0.8, 1.5),
            _buildSlider(context, 'Card Size Scale', 'card_scale', data['card_scale'] ?? 1.0, 0.7, 1.3),
            _buildSlider(context, 'Button Scale', 'button_scale', data['button_scale'] ?? 1.0, 0.8, 1.4),
            const SizedBox(height: 24),
            _buildSectionTitle('COLOR CUSTOMIZATION'),
            _buildColorDropdown(context, 'Surface (Card) Color', 'surface_color_type', data['surface_color_type'] ?? 'White', ['White', 'Light Grey', 'Deep Slate', 'OLED Black']),
            const SizedBox(height: 16),
            _buildColorDropdown(context, 'Text Primary Color', 'text_color_type', data['text_color_type'] ?? 'Default', ['Default', 'Royal Blue', 'Deep Purple', 'Soft Grey']),
            const SizedBox(height: 40),
            Center(child: Text('Changes apply globally in real-time.', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic))),
          ],
        );
      }
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppStyles.primaryColor, letterSpacing: 1)),
      const Expanded(child: Divider(indent: 10, endIndent: 10)),
    ]),
  );

  Widget _buildSlider(BuildContext context, String label, String key, double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${value.toStringAsFixed(1)}x', style: const TextStyle(fontWeight: FontWeight.w900, color: AppStyles.primaryColor)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppStyles.primaryColor,
          onChanged: (v) {
            FirebaseFirestore.instance.collection('settings').doc('app_config').set({key: v}, SetOptions(merge: true));
          },
        ),
      ],
    );
  }

  Widget _buildColorDropdown(BuildContext context, String label, String key, String value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.blueGrey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
              onChanged: (v) {
                FirebaseFirestore.instance.collection('settings').doc('app_config').set({key: v}, SetOptions(merge: true));
              },
            ),
          ),
        ),
      ],
    );
  }
}
