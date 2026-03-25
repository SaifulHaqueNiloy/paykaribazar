import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../../utils/styles.dart';

class CategorySidebar extends ConsumerStatefulWidget {
  const CategorySidebar({super.key});

  @override
  ConsumerState<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends ConsumerState<CategorySidebar> {
  String? _expandedShop;

  @override
  Widget build(BuildContext context) {
    final isEn = ref.watch(languageProvider).languageCode == 'en';
    final storesAsync = ref.watch(storesProvider);
    final catsAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          _buildSidebarHeader(context, isDark, isEn),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Cleaned up sidebar - only keeping shop categories
                _buildSectionHeader(
                    isEn ? 'BROWSE BY SHOP' : 'শপ অনুযায়ী দেখুন'),

                storesAsync.when(
                  data: (stores) {
                    if (stores.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: stores
                          .map((store) => _buildShopAccordion(
                                label: isEn
                                    ? (store['name'] ?? 'Shop')
                                    : (store['nameBn'] ??
                                        store['name'] ??
                                        'দোকান'),
                                value: store['name'] ?? '',
                                icon: _getIconData(store['icon']),
                                color: _parseColor(store['color']),
                                isDark: isDark,
                                catsAsync: catsAsync,
                                isEn: isEn,
                              ))
                          .toList(),
                    );
                  },
                  loading: () => const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),
                const Divider(indent: 20, endIndent: 20),

                // Keep minimal essential links
                _buildMenuItem(Icons.favorite_border_rounded,
                    isEn ? 'Favourites' : 'পছন্দের তালিকা', Colors.red, () {
                  Navigator.pop(context);
                  context.push('/wishlist');
                }),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'egg':
        return Icons.egg_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  Widget _buildSectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(title,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.2)),
      );

  Widget _buildShopAccordion({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required AsyncValue<List<Map<String, dynamic>>> catsAsync,
    required bool isEn,
  }) {
    final bool isExpanded = _expandedShop == value;
    return Column(children: [
      ListTile(
        onTap: () => setState(() => _expandedShop = isExpanded ? null : value),
        leading: Icon(icon, color: isExpanded ? color : Colors.grey, size: 20),
        title: Text(label,
            style: TextStyle(
                fontWeight: isExpanded ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14,
                color: isExpanded ? color : null)),
        trailing: Icon(
            isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: isExpanded ? color : Colors.grey),
      ),
      if (isExpanded)
        catsAsync.when(
          data: (allCats) {
            final shopCats = allCats
                .where((c) => c['parentId'] == null && c['shopName'] == value)
                .toList();
            return Column(
                children: shopCats.map((cat) {
              final name = isEn
                  ? (cat['name'] ?? '')
                  : (cat['nameBn'] ?? cat['name'] ?? '');
              return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ListTile(
                      dense: true,
                      title: Text(name, style: const TextStyle(fontSize: 13)),
                      trailing:
                          const Icon(Icons.chevron_right_rounded, size: 14),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/products/category/${cat['name']}');
                      }));
            }).toList());
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox(),
        ),
    ]);
  }

  Widget _buildSidebarHeader(BuildContext context, bool isDark, bool isEn) =>
      Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        decoration: BoxDecoration(
            color:
                isDark ? AppStyles.darkSurfaceColor : AppStyles.primaryColor),
        child: const Row(children: [
          Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Text('Paykari Bazar',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18))
        ]),
      );

  Widget _buildMenuItem(
          IconData icon, String title, Color color, VoidCallback onTap) =>
      ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color, size: 20),
          title: Text(title,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          dense: true);
}
