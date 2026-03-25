import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';
import '../../../models/product_model.dart';
import 'product_form_sheet.dart';
import 'inventory/csv_import_sheet.dart';

class InventoryTab extends ConsumerStatefulWidget {
  final bool isAdmin;
  const InventoryTab({super.key, required this.isAdmin});
  @override
  ConsumerState<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<InventoryTab> {
  String _searchQuery = '';
  String _activeFilter = 'All';
  bool _isQuickEditMode = false;

  final Map<String, int> _pendingStockUpdates = {};

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  Future<void> _saveBatchUpdates() async {
    if (_pendingStockUpdates.isEmpty) return;

    setState(() => _isQuickEditMode = false);

    final updates = _pendingStockUpdates.entries
        .map((e) => {
              'id': e.key,
              'data': {'stock': e.value},
            })
        .toList();

    await ref
        .read(firestoreServiceProvider)
        .performBatchUpdate(updates, HubPaths.products);
    _pendingStockUpdates.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory Updated Successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productsAsync = ref.watch(productsProvider);

    return Column(
      children: [
        _buildInventoryDashboard(productsAsync, isDark),
        _buildTopActionArea(isDark),
        _buildFilterChips(isDark),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: _buildProductsList(productsAsync, isDark),
          ),
        ),
        if (_isQuickEditMode) _buildQuickEditFooter(),
      ],
    );
  }

  Widget _buildQuickEditFooter() => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: AppStyles.primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PENDING UPDATES: ${_pendingStockUpdates.length}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                await _saveBatchUpdates();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppStyles.primaryColor),
              child: const Text('SAVE ALL CHANGES'),
            )
          ],
        ),
      );

  Widget _buildInventoryDashboard(
      AsyncValue<List<Map<String, dynamic>>> productsAsync, bool isDark) {
    return productsAsync.maybeWhen(
        data: (prods) {
          final lowStock = prods
              .where((p) =>
                  (p['stock'] as int? ?? 0) > 0 &&
                  (p['stock'] as int? ?? 0) <= 5)
              .length;
          final outOfStock =
              prods.where((p) => (p['stock'] as int? ?? 0) == 0).length;

          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.indigo.shade800, Colors.blue.shade900]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8))
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('TOTAL', prods.length.toString(),
                    Icons.inventory_2_rounded),
                _buildStatItem(
                    'LOW', lowStock.toString(), Icons.warning_amber_rounded,
                    color: Colors.orangeAccent),
                _buildStatItem(
                    'OUT', outOfStock.toString(), Icons.error_outline_rounded,
                    color: Colors.redAccent),
              ],
            ),
          );
        },
        orElse: () => const SizedBox.shrink());
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color color = Colors.white}) {
    return Column(children: [
      Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
    ]);
  }

  Widget _buildTopActionArea(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: AppStyles.inputDecoration(_t('search'), isDark,
                  prefix: const Icon(Icons.search_rounded)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CsvImportSheet()),
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'CSV Import',
            style: IconButton.styleFrom(backgroundColor: Colors.teal),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () =>
                setState(() => _isQuickEditMode = !_isQuickEditMode),
            icon: Icon(
                _isQuickEditMode ? Icons.close_rounded : Icons.bolt_rounded),
            tooltip: 'Quick Edit',
            style: IconButton.styleFrom(
                backgroundColor: _isQuickEditMode ? Colors.red : Colors.orange),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () => _showProductSheet(context),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Product',
            style:
                IconButton.styleFrom(backgroundColor: AppStyles.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = ['All', 'Combos', 'Low Stock', 'Out of Stock'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = _activeFilter == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index],
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold)),
              selected: isSelected,
              onSelected: (v) => setState(() => _activeFilter = filters[index]),
              selectedColor: AppStyles.primaryColor,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppStyles.textSecondary),
              showCheckmark: false,
              elevation: 0,
              backgroundColor:
                  isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsList(
      AsyncValue<List<Map<String, dynamic>>> productsAsync, bool isDark) {
    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const Center(child: Text('No items found.'));

        var filtered = products;
        if (_searchQuery.isNotEmpty) {
          filtered = filtered
              .where((p) =>
                  (p['name']?.toString().toLowerCase().contains(_searchQuery) ??
                      false) ||
                  (p['nameBn']?.toString().contains(_searchQuery) ?? false))
              .toList();
        }
        if (_activeFilter == 'Combos') {
          filtered =
              filtered.where((p) => (p['isCombo'] as bool? ?? false)).toList();
        } else if (_activeFilter == 'Low Stock') {
          filtered = filtered
              .where((p) =>
                  (p['stock'] as int? ?? 0) > 0 &&
                  (p['stock'] as int? ?? 0) <= 5)
              .toList();
        } else if (_activeFilter == 'Out of Stock') {
          filtered =
              filtered.where((p) => (p['stock'] as int? ?? 0) == 0).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _buildProductTile(filtered[index], isDark),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildProductTile(Map<String, dynamic> p, bool isDark) {
    final lang = ref.watch(languageProvider).languageCode;
    final String pid = p['id'] as String? ?? '';
    final int currentStock =
        _pendingStockUpdates[pid] ?? (p['stock'] as int? ?? 0);
    final bool isLow = currentStock > 0 && currentStock <= 5;
    final bool isOut = currentStock == 0;
    
    final String imageUrl = p['imageUrl']?.toString() ?? '';
    final String name = p['name']?.toString() ?? '';
    final String nameBn = p['nameBn']?.toString() ?? '';
    final double price = (p['price'] as num? ?? 0.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isOut
                ? Colors.red.withValues(alpha: 0.3)
                : (isLow
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Colors.transparent)),
        boxShadow: AppStyles.softShadow,
      ),
      child: Row(
        children: [
          Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : const Icon(Icons.image))),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(lang == 'en' ? name : nameBn,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('৳${price.toInt()}',
                  style: const TextStyle(
                      color: AppStyles.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ]),
          ),
          if (_isQuickEditMode) ...[
            IconButton(
                onPressed: () => setState(() => _pendingStockUpdates[pid] =
                    (currentStock - 1).clamp(0, 9999)),
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red, size: 20)),
            Container(
                width: 40,
                alignment: Alignment.center,
                child: Text('$currentStock',
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(
                onPressed: () => setState(
                    () => _pendingStockUpdates[pid] = currentStock + 1),
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.green, size: 20)),
          ] else ...[
            IconButton(
                onPressed: () => _showProductSheet(context, productMap: p),
                icon: const Icon(Icons.edit_note_rounded, color: Colors.blue)),
            IconButton(
                onPressed: () => _confirmDelete(p),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red)),
          ],
        ],
      ),
    );
  }

  void _showProductSheet(BuildContext context, {Map<String, dynamic>? productMap}) {
    Product? product;
    if (productMap != null) {
      product = Product.fromMap(productMap, productMap['id'] ?? '');
    }
    
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ProductFormSheet(product: product));
  }

  void _confirmDelete(Map<String, dynamic> p) {
    final String name = p['name']?.toString() ?? 'Product';
    final String id = p['id']?.toString() ?? '';

    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text('Delete Item?'),
              content: Text("Are you sure you want to delete '$name'?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: const Text('CANCEL')),
                ElevatedButton(
                    onPressed: () async {
                      if (id.isNotEmpty) {
                        await ref
                            .read(firestoreServiceProvider)
                            .deleteProduct(id);
                      }
                      if (!c.mounted) return;
                      Navigator.pop(c);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('DELETE')),
              ],
            ));
  }
}
