import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';
import '../../../models/product_model.dart';
import 'categories/category_form_sheet.dart';
import 'categories/category_tile.dart';

class CategoryTab extends ConsumerStatefulWidget {
  const CategoryTab({super.key});

  @override
  ConsumerState<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends ConsumerState<CategoryTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final storesAsync = ref.watch(storesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildHeader(isDark),
        Expanded(
          child: categoriesAsync.when(
            data: (categories) => productsAsync.when(
              data: (products) => storesAsync.when(
                data: (stores) => _buildVisualCategoryTree(
                    categories, products, stores, isDark),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${_t('error')}: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${_t('error')}: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${_t('error')}: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_t('categoryManagement').toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1)),
              IconButton(
                  onPressed: _showReorderDialog,
                  icon: const Icon(Icons.reorder_rounded,
                      color: AppStyles.primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: AppStyles.inputDecoration(
                _t('searchCategories'), isDark,
                prefix: const Icon(Icons.search_rounded)),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showCategoryForm(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('CREATE NEW ROOT CATEGORY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualCategoryTree(
      List<Map<String, dynamic>> allCats,
      List<Map<String, dynamic>> prodsMap,
      List<Map<String, dynamic>> stores,
      bool isDark) {
    final rootCats = allCats
        .where((c) =>
            c['parentId'] == null &&
            c['name'].toString().toLowerCase().contains(_searchQuery))
        .toList();
        
    // Convert Map list to Product list safely
    final List<Product> productList = prodsMap.map((m) => Product.fromMap(m, m['id'] ?? '')).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: rootCats.length,
      itemBuilder: (context, index) {
        final cat = rootCats[index];
        return CategoryTile(
            category: cat,
            allCategories: allCats,
            products: productList,
            isDark: isDark);
      },
    );
  }

  void _showCategoryForm(
      {String? initialParentId, Map<String, dynamic>? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryFormSheet(
          initialParentId: initialParentId, category: category),
    );
  }

  void _showReorderDialog() {
    final categories = ref.read(categoriesProvider).value ?? [];
    final List<Map<String, dynamic>> temp =
        List.from(categories.where((c) => c['parentId'] == null));
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                  title: Text(_t('reorderMainCategories')),
                  content: SizedBox(
                      width: double.maxFinite,
                      height: 400,
                      child: ReorderableListView(
                          onReorder: (oldIdx, newIdx) {
                            setState(() {
                              if (newIdx > oldIdx) newIdx -= 1;
                              final item = temp.removeAt(oldIdx);
                              temp.insert(newIdx, item);
                            });
                          },
                          children: temp
                              .map((item) => ListTile(
                                  key: ValueKey(item['id']),
                                  leading: const Icon(Icons.drag_handle),
                                  title: Text(item['name'] ?? '')))
                              .toList())),
                  actions: [
                    ElevatedButton(
                        onPressed: () async {
                          for (int i = 0; i < temp.length; i++) {
                            await ref
                                .read(firestoreService)
                                .updateCategoryOrder(temp[i]['id']?.toString() ?? '', i);
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Text(_t('save')))
                  ],
                )));
  }
}
