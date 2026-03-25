import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'staff_security_tab.dart';
import 'teams_tab.dart';
import 'reseller_applications_tab.dart';
import '../../../utils/styles.dart';
import '../../../services/language_provider.dart';
import '../../../utils/app_strings.dart';

class HrTeamsTab extends ConsumerStatefulWidget {
  const HrTeamsTab({super.key});
  @override
  ConsumerState<HrTeamsTab> createState() => _HrTeamsTabState();
}

class _HrTeamsTabState extends ConsumerState<HrTeamsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  String _t(String k) => AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppStyles.primaryColor,
          labelColor: AppStyles.primaryColor,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(text: _t('security').toUpperCase()),
            Tab(text: _t('teams').toUpperCase()),
            Tab(text: _t('apps').toUpperCase()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          StaffSecurityTab(),
          TeamsTab(),
          ResellerApplicationsTab(),
        ],
      ),
    );
  }
}
