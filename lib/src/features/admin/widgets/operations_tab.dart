import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'logistics_tab.dart';
import 'marketing_tab.dart';
import 'accounts_tab.dart';
import '../../../utils/styles.dart';

class OperationsTab extends ConsumerStatefulWidget {
  const OperationsTab({super.key});
  @override
  ConsumerState<OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends ConsumerState<OperationsTab> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppStyles.primaryColor,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.white70 : Colors.black87,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            tabs: const [
              Tab(text: 'LOGISTICS', icon: Icon(Icons.local_shipping_rounded, size: 18)),
              Tab(text: 'MARKETING', icon: Icon(Icons.campaign_rounded, size: 18)),
              Tab(text: 'ACCOUNTS', icon: Icon(Icons.account_balance_wallet_rounded, size: 18)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LogisticsTab(),
          MarketingTab(),
          AccountsTab(),
        ],
      ),
    );
  }
}
