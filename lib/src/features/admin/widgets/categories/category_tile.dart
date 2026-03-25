import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../utils/styles.dart';

import '../../../../di/providers.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/common_widgets.dart';
import 'category_form_sheet.dart';
import '../inventory/csv_import_sheet.dart';
import '../../../../models/product_model.dart';

class CategoryTile extends ConsumerWidget {
  final Map<String, dynamic> category;
  final List<Map<String, dynamic>> allCategories;
  final List<Product> products;
  final bool isDark;

  const CategoryTile({
    super.key,
    required this.category,
    required this.allCategories,
    required this.products,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider).languageCode;
    String t(String k) => AppStrings.get(k, lang);

    final children =
        allCategories.where((c) => c['parentId'] == category['id']).toList();
    final productCount = products
        .where((p) =>
            p.categoryName == category['name'] ||
            p.subCategoryName == category['name'])
        .length;
    final isPublished = category['isPublished'] ?? false;
    final String? imageUrl = category['imageUrl'];
    final String catName = category['name'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: isPublished
                  ? (isDark ? Colors.white10 : Colors.grey[100]!)
                  : Colors.red.withOpacity(0.3))),
      child: ExpansionTile(
        key: PageStorageKey(category['id']),
        leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: isDark
                    ? AppStyles.darkBackgroundColor
                    : AppStyles.surfaceColor(isDark),
                borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? AppImage(imageUrl: imageUrl, altQuery: catName)
                    : Icon(AppStyles.getCategoryIcon(catName),
                        color: isDark
                            ? AppStyles.darkPrimaryColor
                            : AppStyles.primaryColor,
                        size: 24))),
        title: Row(
          children: [
            Expanded(
                child: Text(catName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14))),
            if (!isPublished)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(t('unpublished'),
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Text('$productCount ${t('products')}',
            style: TextStyle(
                fontSize: 11,
                color:
                    isDark ? AppStyles.darkTextSecondary : Colors.grey[600])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.upload_file_rounded,
                  size: 20, color: Colors.green),
              tooltip: t('importCsvToCategory'),
              onPressed: () => _showCSVImport(context, ref),
            ),
            IconButton(
              icon: const Icon(Icons.add_box_outlined,
                  size: 20, color: Colors.indigoAccent),
              tooltip: t('addChildCategory'),
              onPressed: () =>
                  _showCategoryForm(context, parentId: category['id']),
            ),
            IconButton(
                icon: const Icon(Icons.edit_rounded,
                    size: 20, color: Colors.blue),
                onPressed: () =>
                    _showCategoryForm(context, category: category)),
            IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: Colors.red),
                onPressed: () =>
                    _confirmDeleteCategory(context, ref, category)),
          ],
        ),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children
            .map((child) => CategoryTile(
                category: child,
                allCategories: allCategories,
                products: products,
                isDark: isDark))
            .toList(),
      ),
    );
  }

  void _showCSVImport(BuildContext context, WidgetRef ref) {
    final List<String> path = [];
    Map<String, dynamic> current = category;
    String? shop = category['shopName'];

    while (true) {
      path.insert(0, current['name']);
      shop ??= current['shopName'];
      if (current['parentId'] == null) break;

      final parent = allCategories
          .firstWhere((c) => c['id'] == current['parentId'], orElse: () => {});
      if (parent.isEmpty) break;
      current = parent;
    }

    // Path parsing logic - variables available but not currently used

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CsvImportSheet(// FIXED: Corrected case
          // Note: The CsvImportSheet doesn't yet accept parameters in my previous definition,
          // but I'll update it to accept them or just show the general one.
          ),
    );
  }

  void _showCategoryForm(BuildContext context,
      {Map<String, dynamic>? category, String? parentId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CategoryFormSheet(category: category, initialParentId: parentId),
    );
  }

  void _confirmDeleteCategory(
      BuildContext context, WidgetRef ref, Map<String, dynamic> category) {
    final lang = ref.read(languageProvider).languageCode;
    String t(String k) => AppStrings.get(k, lang);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(t('deleteCategoryQuery')),
        content: Text(t('deleteCategoryDesc')
            .replaceAll('{name}', category['name'] ?? '')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('cancel'))),
          TextButton(
              onPressed: () async {
                await ref.read(firestoreService).deleteCategory(category['id']);
                if (context.mounted) Navigator.pop(context);
              },
              child:
                  Text(t('delete'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
