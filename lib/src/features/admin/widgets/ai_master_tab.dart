import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/utils/styles.dart';

class AiMasterTab extends ConsumerStatefulWidget {
  const AiMasterTab({super.key});

  @override
  ConsumerState<AiMasterTab> createState() => _AiMasterTabState();
}

class _AiMasterTabState extends ConsumerState<AiMasterTab>
    with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _useReasoning = false; // R1 Mode toggle
  bool _useStreaming = true; // NEW: Streaming toggle
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 6, vsync: this);
  }

  void _sendMessage({String? customText}) async {
    final text = customText ?? _ctrl.text.trim();
    if (text.isEmpty) return;

    if (mounted) {
      setState(() {
        _messages.add({'role': 'admin', 'text': text, 'time': DateTime.now()});
        _isTyping = true;
        if (customText == null) _ctrl.clear();
      });
    }

    try {
      if (text.toLowerCase().contains('http')) {
        _addAiResponse('🌐 Analyzing URL for Product Cloning...');
        final result =
            await ref.read(aiServiceProvider).analyzeAndReplicate(text);
        _updateLastAiMessage(result.isEmpty || result.contains('error')
            ? '❌ Analysis Failed'
            : '✅ Product Cloned: $result');
      } else if (_useStreaming) {
        // [LOCKED DNA]: Real-time Streaming with Kimi-k2.5
        _addAiResponse('...'); // Initial placeholder
        final stream = ref.read(aiServiceProvider).generateStreamedResponse(
            text,
            type: _useReasoning ? AiWorkType.executive : AiWorkType.generic);

        String fullResponse = '';
        await for (final chunk in stream) {
          fullResponse += chunk;
          _updateLastAiMessage(fullResponse);
        }
      } else {
        final response = await ref.read(aiServiceProvider).generateResponse(
            text,
            type: _useReasoning ? AiWorkType.executive : AiWorkType.generic);
        _addAiResponse(response);
      }
    } catch (e) {
      _addAiResponse('❌ নিউরন সংযোগ বিচ্ছিন্ন: $e');
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  void _addAiResponse(String text) {
    if (mounted) {
      setState(() =>
          _messages.add({'role': 'ai', 'text': text, 'time': DateTime.now()}));
    }
  }

  void _updateLastAiMessage(String text) {
    if (mounted && _messages.isNotEmpty && _messages.last['role'] == 'ai') {
      setState(() {
        _messages.last['text'] = text;
      });
    }
  }

  void _testGreeting() async {
    setState(() => _isTyping = true);
    try {
      final greeting = ref.read(aiServiceProvider).getBrandedGreeting();
      _addAiResponse('🎨 AI Greeting জেনারেট করা হয়েছে:\n\n"$greeting"');
    } catch (e) {
      _addAiResponse('❌ Greeting জেনারেশন ব্যর্থ হয়েছে।');
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  void _runSovereignScan() async {
    setState(() => _isTyping = true);
    HapticFeedback.heavyImpact();
    try {
      _addAiResponse('🚀 SOVEREIGN GAP ANALYSIS INITIATED...');
      final report =
          await ref.read(aiAutomationProvider).performGlobalSystemCheck();
      _updateLastAiMessage(
          '✅ SYSTEM SCAN COMPLETE.\nFindings: ${(report['findings'] as List).length} detected.');
    } catch (e) {
      _addAiResponse('❌ SCAN FAILED: $e');
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(150),
        child: _buildOmniHeader(isDark),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildTerminal(isDark),
          _buildQuotaMonitoring(isDark),
          const SovereignRulesLab(),
          _buildAuditPanel(isDark),
          _buildGrowthLab(isDark),
          _buildWorkHistory(isDark),
        ],
      ),
    );
  }

  Widget _buildOmniHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _statusIndicator(true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('OMNIPOTENT SOVEREIGN V6',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 13,
                              color: AppStyles.primaryColor)),
                      Text(
                          'Streaming: ${_useStreaming ? "ON" : "OFF"} | Kimi-k2.5 Active',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _headerAction(Icons.stream_rounded,
                        _useStreaming ? 'STREAM ON' : 'STREAM OFF', () {
                      setState(() => _useStreaming = !_useStreaming);
                      HapticFeedback.lightImpact();
                    }),
                    _headerAction(Icons.psychology_alt_rounded,
                        _useReasoning ? 'R1 ON' : 'V3 ON', () {
                      setState(() => _useReasoning = !_useReasoning);
                      HapticFeedback.mediumImpact();
                    }),
                  ],
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            labelColor: AppStyles.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppStyles.primaryColor,
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            tabs: const [
              Tab(text: 'COMMAND', icon: Icon(Icons.bolt_rounded, size: 18)),
              Tab(text: 'QUOTA', icon: Icon(Icons.speed_rounded, size: 18)),
              Tab(
                  text: 'RULES',
                  icon: Icon(Icons.rule_folder_rounded, size: 18)),
              Tab(
                  text: 'SYSTEM AUDIT',
                  icon: Icon(Icons.security_rounded, size: 18)),
              Tab(
                  text: 'GROWTH LAB',
                  icon: Icon(Icons.analytics_rounded, size: 18)),
              Tab(
                  text: 'HISTORY',
                  icon: Icon(Icons.history_edu_rounded, size: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaMonitoring(bool isDark) {
    final quotaData = ref.watch(apiQuotaStreamProvider);
    return quotaData.when(
      data: (items) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('REAL-TIME NEURAL QUOTA TRACKING',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.blueGrey)),
          const SizedBox(height: 20),
          if (items.isEmpty)
            const Center(child: Text('No API Keys currently tracked.')),
          ...items.map((k) => _quotaKeyCard(k, isDark)),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Quota Stream Failed: $e')),
    );
  }

  Widget _quotaKeyCard(Map<String, dynamic> data, bool isDark) {
    final int used = data['used_today'] ?? 0;
    final int limit = data['daily_limit'] ?? 1500;
    final double percent = (used / limit).clamp(0, 1);
    final bool isExhausted = data['status'] == 'exhausted';
    final String provider = data['provider'] ?? 'deepseek';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isExhausted
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.green.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                  provider == 'gemini'
                      ? Icons.diamond_rounded
                      : Icons.psychology_rounded,
                  color: isExhausted ? Colors.grey : Colors.blueAccent,
                  size: 18),
              const SizedBox(width: 10),
              Text(data['id'].toString().toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 11)),
              const Spacer(),
              _badge(isExhausted ? 'EXHAUSTED' : 'ACTIVE',
                  isExhausted ? Colors.red : Colors.green),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              color: isExhausted ? Colors.grey : Colors.greenAccent,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200]),
          const SizedBox(height: 8),
          Text('Usage: $used / $limit',
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w900, fontSize: 8)),
    );
  }

  Widget _headerAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: AppStyles.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppStyles.primaryColor.withValues(alpha: 0.3))),
        child: Row(
          children: [
            Icon(icon, color: AppStyles.primaryColor, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _statusIndicator(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.greenAccent : Colors.redAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: active
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.red.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2)
        ],
      ),
    );
  }

  Widget _buildTerminal(bool isDark) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyTerminal(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _messageBubble(_messages[index], isDark),
                ),
        ),
        if (_isTyping) _buildThinkingIndicator(),
        _buildInputArea(isDark),
      ],
    );
  }

  Widget _buildEmptyTerminal(bool isDark) {
    return Center(
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal_rounded,
                size: 64, color: isDark ? Colors.white24 : Colors.grey),
            const SizedBox(height: 16),
            const Text('Terminal Ready for Sovereign Command...',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditPanel(bool isDark) {
    final auditLogs = ref.watch(aiAuditLogsProvider);
    return auditLogs.when(
      data: (logs) => logs.isEmpty
          ? const Center(child: Text('No system alerts found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, i) => _auditCard(logs[i], isDark),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Audit Link Failed: $e')),
    );
  }

  Widget _buildGrowthLab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _growthCard(
              'Campaign Recommendation',
              'AI detected frequent combo: Rice + Dal.',
              Icons.auto_awesome_rounded),
          const SizedBox(height: 16),
          _growthCard(
              'Market Gap Analysis',
              'Soyabean Oil stock low in competition.',
              Icons.trending_up_rounded),
          const SizedBox(height: 24),
          _growthCard('Quick Actions', 'Run specialized AI tests.',
              Icons.flash_on_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                      onPressed: _testGreeting,
                      child: const Text('Test Branded Greeting'))),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton(
                      onPressed: _runSovereignScan,
                      child: const Text('Run Sovereign Scan'))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWorkHistory(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ai_work_audit')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return ListTile(
                title: Text(data['type'] ?? 'Op'),
                subtitle: Text(data['request'] ?? ''));
          },
        );
      },
    );
  }

  Widget _auditCard(Map<String, dynamic> log, bool isDark) {
    return Card(
        child: ListTile(
            title: Text(log['title'] ?? 'Alert'),
            subtitle: Text(log['message'] ?? '')));
  }

  Widget _growthCard(String title, String desc, IconData icon) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.purple.shade900,
            borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(desc, style: const TextStyle(color: Colors.white70))
        ]));
  }

  Widget _messageBubble(Map<String, dynamic> m, bool isDark) {
    final isAi = m['role'] == 'ai';
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: isAi ? Colors.blueGrey.shade900 : AppStyles.primaryColor,
            borderRadius: BorderRadius.circular(15)),
        child: Text(m['text']!,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return const Padding(
        padding: EdgeInsets.all(10),
        child: Text('Kimi-k2.5 is thinking...',
            style: TextStyle(fontSize: 10, color: Colors.grey)));
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                  controller: _ctrl,
                  decoration:
                      const InputDecoration(hintText: 'Enter command...'),
                  onSubmitted: (_) => _sendMessage())),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}

class SovereignRulesLab extends ConsumerWidget {
  const SovereignRulesLab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ai_sovereign_rules')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rules = snapshot.data!.docs;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('SOVEREIGN PROTOCOL RULES',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.5,
                            color: Colors.blueGrey)),
                    IconButton(
                        onPressed: () => _showAddRuleSheet(context),
                        icon: const Icon(Icons.add_box_rounded,
                            color: AppStyles.primaryColor)),
                  ],
                ),
              ),
              Expanded(
                child: rules.isEmpty
                    ? _buildNoRules(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: rules.length,
                        itemBuilder: (context, i) =>
                            _ruleTile(rules[i], isDark),
                      ),
              ),
            ],
          );
        });
  }

  Widget _buildNoRules(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rule_folder_rounded,
              size: 64, color: isDark ? Colors.white10 : Colors.grey[200]),
          const SizedBox(height: 16),
          const Text('No Sovereign Rules defined yet.',
              style:
                  TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _ruleTile(DocumentSnapshot doc, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    final bool enabled = data['isEnabled'] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: enabled
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2))),
      child: ListTile(
        leading: Icon(Icons.auto_fix_high_rounded,
            color: enabled ? Colors.green : Colors.grey),
        title: Text(data['name'] ?? 'Untitled Rule',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('Type: ${data['type']} | Freq: ${data['frequency']}',
            style: const TextStyle(fontSize: 11)),
        trailing: Switch(
          value: enabled,
          onChanged: (v) => doc.reference.update({'isEnabled': v}),
          activeThumbColor: Colors.green,
        ),
      ),
    );
  }

  void _showAddRuleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (c) => const AddRuleForm(),
    );
  }
}

class AddRuleForm extends StatefulWidget {
  const AddRuleForm({super.key});
  @override
  State<AddRuleForm> createState() => _AddRuleFormState();
}

class _AddRuleFormState extends State<AddRuleForm> {
  final _name = TextEditingController();
  final _instruct = TextEditingController();
  String _type = 'inventory_audit';
  String _freq = 'daily';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('NEW SOVEREIGN RULE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 24),
          TextField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Rule Name', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _type,
            items: [
              'inventory_audit',
              'abandoned_cart',
              'price_drop_alert',
              'custom_synthesis'
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _type = v!),
            decoration: const InputDecoration(
                labelText: 'Task Type', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _freq,
            items: ['hourly', 'daily', 'weekly']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _freq = v!),
            decoration: const InputDecoration(
                labelText: 'Frequency', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
              controller: _instruct,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Instruction for AI',
                  border: OutlineInputBorder())),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('ai_sovereign_rules').add({
                'name': _name.text,
                'type': _type,
                'frequency': _freq,
                'instruction': _instruct.text,
                'isEnabled': true,
                'createdAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white),
            child: const Text('CREATE PROTOCOL RULE'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class VirtualDataLab extends ConsumerStatefulWidget {
  const VirtualDataLab({super.key});

  @override
  ConsumerState<VirtualDataLab> createState() => _VirtualDataLabState();
}

class _VirtualDataLabState extends ConsumerState<VirtualDataLab>
    with TickerProviderStateMixin {
  late TabController _labTab;
  String _selectedSource = 'users';
  String _intent = 'Cross-reference data to find valuable insights';
  bool _isProcessing = false;
  Map<String, dynamic>? _result;

  final List<String> _collections = [
    'users',
    'products',
    'orders',
    'categories',
    'carts',
    'locations',
    'reseller_applications',
    'donors',
    'doctors',
    'blood_requests',
    'hero_records',
    'bonus_faqs',
    'notices',
    'settings',
    'ai_audit_logs',
    'ai_work_audit',
    'system_alerts',
    'ai_notifications_queue',
    'device_approval_requests',
    'SYSTEM_WIDE_ANALYSIS'
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
        final targets = ['users', 'products', 'orders', 'donors'];
        for (var col in targets) {
          final snap =
              await FirebaseFirestore.instance.collection(col).limit(10).get();
          data.addAll(snap.docs.map((d) => {...d.data(), '_collection': col}));
        }
      } else {
        final snap = await FirebaseFirestore.instance
            .collection(_selectedSource)
            .limit(50)
            .get();
        data.addAll(snap.docs.map((d) => d.data()));
      }

      final result = await ref.read(aiServiceProvider).synthesizeCrossData(
            sourceCollection: _selectedSource,
            intent: _intent,
            rawData: data,
          );

      setState(() => _result = result);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Synthesis Error: $e')));
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
        content: Text(
            'AI is about to architect and save ${_result!['items'].length} new records based on this synthesis. This is a permanent administrative action.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('CANCEL')),
          ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('PROCEED')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      final String targetCol =
          _result!['target_collection'] ?? 'ai_synthesized_data';
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
          content: Text(
              'Successfully committed ${items.length} records to $targetCol'),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Commit Error: $e'), backgroundColor: Colors.red));
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
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(
                text: 'SYNTHESIS',
                icon: Icon(Icons.psychology_rounded, size: 18)),
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
          const Text('OMNIPOTENT DATA SYNTHESIS',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: Colors.blueGrey)),
          const SizedBox(height: 20),
          _buildDropdown('SOURCE COLLECTION', _collections, _selectedSource,
              (v) => setState(() => _selectedSource = v!)),
          const SizedBox(height: 16),
          _buildInput(
              'SYNTHESIS INTENT',
              'e.g. Find users who are both doctors and blood donors',
              (v) => _intent = v),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _runSynthesis,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_fix_high_rounded),
              label: Text(_isProcessing
                  ? 'SYNTHESIZING...'
                  : 'RUN CROSS-DOMAIN SYNTHESIS'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value,
      Function(String?) onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.blueGrey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))))
                .toList(),
            onChanged: onChange,
            isExpanded: true,
          ),
        ),
      ),
    ]);
  }

  Widget _buildInput(String label, String hint, Function(String) onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey)),
      const SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
            filled: true,
            fillColor: Colors.blueGrey.withValues(alpha: 0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)),
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
          border: Border.all(color: Colors.indigo.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.verified_rounded, color: Colors.green, size: 20),
            const SizedBox(width: 10),
            Text(_result!['title'] ?? 'Synthesized Knowledge',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ]),
          const SizedBox(height: 10),
          Text(_result!['description'] ?? '',
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey, height: 1.4)),
          const Divider(height: 30),
          ...items.map((item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                    backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                    child: const Icon(Icons.auto_awesome_rounded,
                        size: 18, color: Colors.indigo)),
                title: Text(item['title'] ?? 'Record',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(item['subtitle'] ?? '',
                    style: const TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 16, color: Colors.grey),
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
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('app_config')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final String currentMood = data['active_mood'] ?? 'default';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('APP VISUAL MOOD CONTROL',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.blueGrey)),
              const SizedBox(height: 20),
              _buildMoodOption(
                  context,
                  'Standard Pro',
                  '0xFF6200EE',
                  'default',
                  currentMood,
                  'The classic Paykari Bazar look.',
                  Icons.auto_awesome_rounded),
              _buildMoodOption(
                  context,
                  'Golden Sunny',
                  '0xFFFFC107',
                  'sunny',
                  currentMood,
                  'Bright and energetic yellow theme.',
                  Icons.wb_sunny_rounded),
              _buildMoodOption(
                  context,
                  'Winter Frost',
                  '0xFFE3F2FD',
                  'winter',
                  currentMood,
                  'Cool blue theme for winter season.',
                  Icons.ac_unit_rounded),
              _buildMoodOption(
                  context,
                  'Festive Red',
                  '0xFFD32F2F',
                  'festive',
                  currentMood,
                  'Celebration mode for Eid or Pujas.',
                  Icons.celebration_rounded),
              _buildMoodOption(
                  context,
                  'Deep Night',
                  '0xFF1A237E',
                  'night',
                  currentMood,
                  'Ultra dark indigo for night owls.',
                  Icons.nightlight_round),
            ],
          );
        });
  }

  Widget _buildMoodOption(BuildContext context, String name, String colorHex,
      String moodKey, String current, String desc, IconData icon) {
    final bool isSelected = current == moodKey;
    final Color themeColor = Color(int.parse(colorHex));

    return GestureDetector(
      onTap: () {
        FirebaseFirestore.instance
            .collection('settings')
            .doc('app_config')
            .set({
          'active_mood': moodKey,
          'primary_color': colorHex,
        }, SetOptions(merge: true));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? themeColor : Colors.grey.withValues(alpha: 0.1),
              width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: themeColor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(desc,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.green),
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
        stream: FirebaseFirestore.instance
            .collection('settings')
            .doc('app_config')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('CUSTOM UI SCALING & COLORS',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      color: Colors.blueGrey)),
              const SizedBox(height: 24),
              _buildSectionTitle('TEXT & SCALING'),
              _buildSlider(context, 'Global Text Scale', 'text_scale',
                  data['text_scale'] ?? 1.0, 0.8, 1.5),
              _buildSlider(context, 'Card Size Scale', 'card_scale',
                  data['card_scale'] ?? 1.0, 0.7, 1.3),
              _buildSlider(context, 'Button Scale', 'button_scale',
                  data['button_scale'] ?? 1.0, 0.8, 1.4),
              const SizedBox(height: 24),
              _buildSectionTitle('COLOR CUSTOMIZATION'),
              _buildColorDropdown(
                  context,
                  'Surface (Card) Color',
                  'surface_color_type',
                  data['surface_color_type'] ?? 'White',
                  ['White', 'Light Grey', 'Deep Slate', 'OLED Black']),
              const SizedBox(height: 16),
              _buildColorDropdown(
                  context,
                  'Text Primary Color',
                  'text_color_type',
                  data['text_color_type'] ?? 'Default',
                  ['Default', 'Royal Blue', 'Deep Purple', 'Soft Grey']),
              const SizedBox(height: 40),
              Center(
                  child: Text('Changes apply globally in real-time.',
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic))),
            ],
          );
        });
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: AppStyles.primaryColor,
                  letterSpacing: 1)),
          const Expanded(child: Divider(indent: 10, endIndent: 10)),
        ]),
      );

  Widget _buildSlider(BuildContext context, String label, String key,
      double value, double min, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${value.toStringAsFixed(1)}x',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppStyles.primaryColor)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppStyles.primaryColor,
          onChanged: (v) {
            FirebaseFirestore.instance
                .collection('settings')
                .doc('app_config')
                .set({key: v}, SetOptions(merge: true));
          },
        ),
      ],
    );
  }

  Widget _buildColorDropdown(BuildContext context, String label, String key,
      String value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold))))
                  .toList(),
              onChanged: (v) {
                FirebaseFirestore.instance
                    .collection('settings')
                    .doc('app_config')
                    .set({key: v}, SetOptions(merge: true));
              },
            ),
          ),
        ),
      ],
    );
  }
}
