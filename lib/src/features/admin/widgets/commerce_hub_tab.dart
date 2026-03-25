import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'orders_tab.dart';
import 'catalog_tab.dart';
import 'logistics_tab.dart';
import '../../../utils/styles.dart';
import '../../../services/language_provider.dart';
import '../../../utils/app_strings.dart';

class CommerceHubTab extends ConsumerStatefulWidget {
  const CommerceHubTab({super.key});
  @override
  ConsumerState<CommerceHubTab> createState() => _CommerceHubTabState();
}

class _CommerceHubTabState extends ConsumerState<CommerceHubTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _t(String k) => AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppStyles.primaryColor,
            labelColor: AppStyles.primaryColor,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            tabs: [
              Tab(text: _t('order').toUpperCase(), icon: const Icon(Icons.shopping_basket_rounded, size: 18)),
              Tab(text: _t('catalog').toUpperCase(), icon: const Icon(Icons.inventory_2_rounded, size: 18)),
              Tab(text: _t('logistics').toUpperCase(), icon: const Icon(Icons.local_shipping_rounded, size: 18)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OrdersTab(),
          CatalogTab(isAdmin: true),
          LogisticsTab(),
        ],
      ),
    );
  }
}
