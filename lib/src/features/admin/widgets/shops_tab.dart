import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';

class ShopsTab extends ConsumerStatefulWidget {
  const ShopsTab({super.key});
  @override
  ConsumerState<ShopsTab> createState() => _ShopsTabState();
}

class _ShopsTabState extends ConsumerState<ShopsTab> {
  final Map<String, IconData> _icons = {
    'egg': Icons.egg_rounded,
    'medical': Icons.medical_services_rounded,
    'pharmacy': Icons.local_pharmacy_rounded,
    'restaurant': Icons.restaurant_rounded,
    'grocery': Icons.shopping_basket_rounded,
    'mall': Icons.local_mall_rounded,
    'cart': Icons.shopping_cart_rounded,
    'store': Icons.storefront_rounded,
    'electric': Icons.electrical_services_rounded,
    'hardware': Icons.home_repair_service_rounded,
  };

  String _t(String key) =>
      AppStrings.get(key, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final storesAsync = ref.watch(storesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_t('storeManagement'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: _showReorder,
              icon: const Icon(Icons.reorder_rounded, color: Colors.indigo),
              tooltip: _t('rearrangeShops'))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(storesProvider.future),
        child: storesAsync.when(
          data: (stores) => stores.isEmpty
              ? _buildEmpty(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stores.length,
                  itemBuilder: (c, i) => _buildCard(stores[i], isDark)),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showDialog(isDark),
          backgroundColor: AppStyles.primaryColor,
          icon: const Icon(Icons.add_business_rounded, color: Colors.white),
          label: Text(_t('addNewShop'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildCard(Map<String, dynamic> s, bool isDark) {
    final color = _parseColor(s['color']);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(_icons[s['icon']] ?? Icons.storefront_rounded,
                color: color)),
        title: Text(s['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(s['nameBn'] ?? '',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.blue),
              onPressed: () => _showDialog(isDark, store: s)),
          IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: Colors.redAccent),
              onPressed: () => _delete(s['id'])),
        ]),
      ),
    );
  }

  void _showDialog(bool isDark, {Map<String, dynamic>? store}) {
    final name = TextEditingController(text: store?['name']),
        nameBn = TextEditingController(text: store?['nameBn']),
        color = TextEditingController(text: store?['color'] ?? '#4F46E5');
    String selectedIcon = store?['icon'] ?? 'store';

    showDialog(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  title: Text(
                      store == null
                          ? _t('launchNewShop')
                          : _t('editShopDetails'),
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: name,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: AppStyles.inputDecoration(
                            _t('shopNameEn'), isDark)),
                    const SizedBox(height: 12),
                    TextField(
                        controller: nameBn,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration: AppStyles.inputDecoration(
                            _t('shopNameBn'), isDark)),
                    const SizedBox(height: 20),
                    _title(_t('selectShopIcon')),
                    const SizedBox(height: 10),
                    Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _icons.keys.map((k) {
                          final sel = selectedIcon == k;
                          return GestureDetector(
                              onTap: () => setState(() => selectedIcon = k),
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: sel
                                          ? AppStyles.primaryColor
                                          : (isDark
                                              ? Colors.white10
                                              : Colors.grey[100]),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Icon(_icons[k],
                                      color: sel ? Colors.white : Colors.grey,
                                      size: 24)));
                        }).toList()),
                    const SizedBox(height: 20),
                    TextField(
                        controller: color,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black),
                        decoration:
                            AppStyles.inputDecoration(_t('colorHex'), isDark)),
                  ])),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: Text(_t('cancel').toUpperCase())),
                    ElevatedButton(
                        onPressed: () async {
                          final data = {
                            'name': name.text,
                            'nameBn': nameBn.text,
                            'icon': selectedIcon,
                            'color': color.text
                          };
                          if (store == null) {
                            await ref.read(firestoreServiceProvider).addStore(data);
                          } else {
                            await ref
                                .read(firestoreServiceProvider)
                                .updateStore(store['id'], data);
                          }
                          if (!c.mounted) return;
                          Navigator.pop(c);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.primaryColor,
                            foregroundColor: Colors.white),
                        child: Text(_t('saveShop').toUpperCase())),
                  ],
                )));
  }

  void _showReorder() {
    final stores =
        List<Map<String, dynamic>>.from(ref.read(storesProvider).value ?? []);
    showDialog(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(_t('rearrangeShops')),
                  content: SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: ReorderableListView(
                          onReorder: (o, n) {
                            setState(() {
                              if (n > o) n -= 1;
                              stores.insert(n, stores.removeAt(o));
                            });
                          },
                          children: stores
                              .map((s) => ListTile(
                                  key: ValueKey(s['id']),
                                  leading:
                                      const Icon(Icons.drag_handle_rounded),
                                  title: Text(s['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  trailing: Icon(
                                      _icons[s['icon']] ?? Icons.store,
                                      size: 20)))
                              .toList())),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: Text(_t('cancel').toUpperCase())),
                    ElevatedButton(
                        onPressed: () async {
                          for (int i = 0; i < stores.length; i++) {
                            await ref
                                .read(firestoreServiceProvider)
                                .updateStoreOrder(stores[i]['id'], i);
                          }
                          if (!c.mounted) return;
                          Navigator.pop(c);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white),
                        child: Text(_t('saveOrder').toUpperCase())),
                  ],
                )));
  }

  Future<void> _delete(String id) async {
    final conf = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Close Shop?'),
                content: const Text('Are you sure you want to close this shop?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('NO')),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(c, true),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('YES'))
                ]));
    if (conf == true) await ref.read(firestoreServiceProvider).deleteStore(id);
  }

  Color _parseColor(String? s) {
    try {
      return Color(int.parse((s ?? '#4F46E5').replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  Widget _buildEmpty(bool d) => const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.store_outlined, size: 60, color: Colors.grey),
        SizedBox(height: 16),
        Text('No active shops found.',
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold))
      ]));
  Widget _title(String t) => Text(t,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey));
}
