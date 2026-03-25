import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'marketing_tab.dart';
import 'accounts_tab.dart';
import '../../../utils/styles.dart';
import '../../../services/language_provider.dart';
import '../../../utils/app_strings.dart';

class MarketingHubTab extends ConsumerStatefulWidget {
  const MarketingHubTab({super.key});
  @override
  ConsumerState<MarketingHubTab> createState() => _MarketingHubTabState();
}

class _MarketingHubTabState extends ConsumerState<MarketingHubTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              Tab(text: _t('marketing').toUpperCase(), icon: const Icon(Icons.campaign_rounded, size: 18)),
              Tab(text: _t('revenue').toUpperCase(), icon: const Icon(Icons.account_balance_wallet_rounded, size: 18)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MarketingTab(),
          AccountsTab(),
        ],
      ),
    );
  }
}
