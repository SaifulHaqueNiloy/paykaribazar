import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../utils/styles.dart';
import '../../../../models/product_model.dart';
import '../../../../di/providers.dart';
import '../../../../utils/app_strings.dart';
import '../product_form_sheet.dart';

class InventoryItemTile extends ConsumerWidget {
  final Product product;
  final bool isAdmin;
  final bool isDark;
  final bool isSelected;
  final bool isSelectionMode;

  const InventoryItemTile({
    super.key,
    required this.product,
    required this.isAdmin,
    required this.isDark,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  String _t(WidgetRef ref, String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAlert = product.stock <= 10;
    final bool isReseller = product.shopName != 'Main Store';
    final lang = ref.watch(languageProvider).languageCode;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: isSelected
                  ? AppStyles.primaryColor
                  : (isAlert
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.transparent),
              width: isSelected ? 2 : 1)),
      color: isSelected
          ? AppStyles.primaryColor.withValues(alpha: 0.05)
          : Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (c, u, e) => const Icon(Icons.inventory_2)),
              ),
            ),
            if (isSelectionMode)
              Positioned(
                  top: 0,
                  left: 0,
                  child: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: AppStyles.primaryColor,
                      size: 20)),
          ],
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(lang == 'en' ? product.name : product.nameBn,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis)),
            if (isReseller) _badge(product.shopName, Colors.blue),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                '৳${product.price.toInt()} • ${_t(ref, 'stock')}: ${product.stock}',
                style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54)),
            const SizedBox(height: 8),
            Row(children: [
              _statusIndicator('BN', product.nameBn.isNotEmpty),
              _statusIndicator(
                  'BG',
                  product.imageUrls.isNotEmpty &&
                      product.imageUrl.contains('transparent')),
              _statusIndicator('SEO', product.tags.isNotEmpty),
              _statusIndicator('DESC', product.description.isNotEmpty),
            ]),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.blue),
                onPressed: () => _showForm(context, product)),
            IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, ref)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text(_t(ref, 'deleteProductQuery')),
              content: Text("${_t(ref, 'areYouSure')} '${product.name}'?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(_t(ref, 'cancel').toUpperCase())),
                TextButton(
                    onPressed: () async {
                      await ref
                          .read(firestoreService)
                          .deleteProduct(product.id);
                      if (context.mounted) Navigator.pop(c);
                    },
                    child: Text(_t(ref, 'delete').toUpperCase(),
                        style: const TextStyle(color: Colors.red))),
              ],
            ));
  }

  Widget _statusIndicator(String label, bool isDone) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: isDone
                ? Colors.green.withValues(alpha: 0.1)
                : (isDark ? Colors.white10 : Colors.grey[100]),
            borderRadius: BorderRadius.circular(4)),
        child: Text(label,
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isDone
                    ? Colors.green
                    : (isDark ? Colors.white24 : Colors.grey))),
      );

  Widget _badge(String t, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(t,
          style:
              TextStyle(color: c, fontSize: 8, fontWeight: FontWeight.bold)));

  void _showForm(BuildContext context, Product p) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => ProductFormSheet(product: p));
}

