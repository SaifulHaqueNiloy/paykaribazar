import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/styles.dart';

class LocalizationTab extends ConsumerStatefulWidget {
  const LocalizationTab({super.key});
  @override
  ConsumerState<LocalizationTab> createState() => _LocalizationTabState();
}

class _LocalizationTabState extends ConsumerState<LocalizationTab> {
  String _searchQuery = '';
  bool _isUploading = false;

  // Expansion state for unconfirmed section
  final Set<String> _expandedGroups = {};

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  // Advanced Grouping Logic based on Page/Feature
  String _getFeatureGroupName(String key) {
    final k = key.toLowerCase();

    if (k.contains('login') ||
        k.contains('signup') ||
        k.contains('phone') ||
        k.contains('email') ||
        k.contains('password') ||
        k.contains('account')) {
      return 'AUTH (LOGIN/SIGNUP)';
    }
    if (k.contains('product') ||
        k.contains('category') ||
        k.contains('shop') ||
        k.contains('search') ||
        k.contains('flash') ||
        k.contains('brand')) {
      return 'PRODUCTS & SHOPPING';
    }
    if (k.contains('order') ||
        k.contains('cart') ||
        k.contains('checkout') ||
        k.contains('bag') ||
        k.contains('bill') ||
        k.contains('invoice')) {
      return 'ORDERS & CART';
    }
    if (k.contains('emergency') ||
        k.contains('blood') ||
        k.contains('doctor') ||
        k.contains('donor') ||
        k.contains('pharmacy') ||
        k.contains('patient')) {
      return 'EMERGENCY & HEALTH';
    }
    if (k.contains('reward') ||
        k.contains('point') ||
        k.contains('pts') ||
        k.contains('coupon') ||
        k.contains('voucher') ||
        k.contains('draw') ||
        k.contains('winner')) {
      return 'REWARDS & COUPONS';
    }
    if (k.contains('profile') ||
        k.contains('edit') ||
        k.contains('address') ||
        k.contains('wallet') ||
        k.contains('setting') ||
        k.contains('language')) {
      return 'PROFILE & SETTINGS';
    }
    if (k.contains('rider') ||
        k.contains('staff') ||
        k.contains('delivery') ||
        k.contains('task') ||
        k.contains('commission')) {
      return 'STAFF & LOGISTICS';
    }
    if (k.contains('error') ||
        k.contains('failed') ||
        k.contains('success') ||
        k.contains('please') ||
        k.contains('alert') ||
        k.contains('loading')) {
      return 'SYSTEM MESSAGES';
    }

    return 'GENERAL UI';
  }

  Future<void> _uploadInitialData() async {
    setState(() => _isUploading = true);
    try {
      final data = AppStrings.initialData;
      await ref.read(firestoreService).updateLocalization(data);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_t('updateSuccess'))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remoteStringsAsync = ref.watch(remoteLocalizationProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildActionHeader(isDark),
          _buildSearchBar(isDark),
          Expanded(
            child: remoteStringsAsync.when(
              data: (strings) {
                if (strings.isEmpty) return _buildEmptyState();

                final filteredKeys = strings.keys.where((k) {
                  final data = strings[k] as Map;
                  final en = (data['en'] ?? '').toString().toLowerCase();
                  final bn = (data['bn'] ?? '').toString().toLowerCase();
                  return k.toLowerCase().contains(_searchQuery) ||
                      en.contains(_searchQuery) ||
                      bn.contains(_searchQuery);
                }).toList();

                final Map<String, List<String>> groupedStrings = {};
                for (var k in filteredKeys) {
                  final group = _getFeatureGroupName(k);
                  groupedStrings.putIfAbsent(group, () => []).add(k);
                }

                final List<String> sortedGroups = groupedStrings.keys.toList()
                  ..sort();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedGroups.length,
                  itemBuilder: (context, index) {
                    final groupName = sortedGroups[index];
                    final keys = groupedStrings[groupName]!;
                    return _buildGroupedSection(
                      title: groupName,
                      keys: keys,
                      allStrings: strings,
                      isDark: isDark,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedSection(
      {required String title,
      required List<String> keys,
      required Map<String, dynamic> allStrings,
      required bool isDark}) {
    final isExpanded = _expandedGroups.contains(title);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => isExpanded
                ? _expandedGroups.remove(title)
                : _expandedGroups.add(title)),
            dense: true,
            leading: Icon(
                isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
                size: 18,
                color: AppStyles.primaryColor),
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1,
                    color: AppStyles.primaryColor)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(keys.length.toString(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(width: 8),
                Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Colors.grey),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: keys
                    .map((k) => _buildStringCard(k, allStrings[k], isDark))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_t('manageTranslations').toUpperCase(),
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
          if (_isUploading)
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(
              onPressed: _uploadInitialData,
              icon:
                  const Icon(Icons.sync_rounded, color: AppStyles.primaryColor),
              tooltip: 'Sync All from File',
            )
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: _t('searchHint'),
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: isDark ? AppStyles.darkSurfaceColor : Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(),
        ),
      ),
    );
  }

  Widget _buildStringCard(String key, dynamic dataMap, bool isDark) {
    final Map data = dataMap as Map;
    final bool isConfirmed = data['isConfirmed'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(key,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            color: Colors.blueGrey),
                        overflow: TextOverflow.ellipsis)),
                if (!isConfirmed)
                  _smallBtn(Icons.check_circle_outline, _t('confirm'),
                      Colors.green, () => _update(key, {'isConfirmed': true})),
              ],
            ),
            const Divider(height: 16),
            _editRow(
                key, 'en', data['en'] ?? '', Icons.language_rounded, 'English'),
            const SizedBox(height: 8),
            _editRow(
                key, 'bn', data['bn'] ?? '', Icons.translate_rounded, 'বাংলা'),
          ],
        ),
      ),
    );
  }

  Widget _editRow(String key, String langCode, String currentVal, IconData icon,
      String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(currentVal,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        IconButton(
          icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.indigo),
          onPressed: () => _showEditDialog(key, langCode, currentVal, label),
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
        )
      ],
    );
  }

  void _showEditDialog(
      String key, String langCode, String currentVal, String label) {
    final ctrl = TextEditingController(text: currentVal);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("${_t('editTranslation')} ($label)",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Enter text here...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(_t('cancel').toUpperCase())),
          ElevatedButton(
            onPressed: () {
              _update(key, {langCode: ctrl.text.trim(), 'isConfirmed': true});
              Navigator.pop(c);
            },
            child: Text(_t('save').toUpperCase()),
          )
        ],
      ),
    );
  }

  Widget _smallBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.bold, color: color)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.translate_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No translations in DB yet.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _uploadInitialData,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('UPLOAD INITIAL DATA'),
          )
        ],
      ),
    );
  }

  void _update(String key, Map<String, dynamic> updates) {
    ref.read(firestoreService).updateLocalization({key: updates});
  }
}

