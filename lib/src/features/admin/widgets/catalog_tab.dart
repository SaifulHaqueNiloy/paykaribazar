import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/styles.dart';
import 'inventory_tab.dart';
import 'category_tab.dart';
import 'shops_tab.dart';

class CatalogTab extends ConsumerWidget {
  final bool isAdmin;
  const CatalogTab({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryClr = isDark ? AppStyles.darkPrimaryColor : AppStyles.primaryColor;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(
              labelColor: primaryClr,
              unselectedLabelColor: isDark ? AppStyles.darkTextSecondary : Colors.grey,
              indicatorColor: primaryClr,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              tabs: const [
                Tab(text: 'INVENTORY'),
                Tab(text: 'CATEGORIES'),
                Tab(text: 'SHOPS'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                InventoryTab(isAdmin: isAdmin),
                const CategoryTab(),
                const ShopsTab(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
