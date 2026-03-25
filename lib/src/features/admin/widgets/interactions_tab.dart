import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/styles.dart';
import '../../../services/language_provider.dart';
import '../../../utils/app_strings.dart';
import 'chat_management_tab.dart';
import 'feedback_tab.dart';
import 'custom_notification_sheet.dart';
import 'ai_notifications_tab.dart';

class InteractionsTab extends ConsumerStatefulWidget {
  const InteractionsTab({super.key});

  @override
  ConsumerState<InteractionsTab> createState() => _InteractionsTabState();
}

class _InteractionsTabState extends ConsumerState<InteractionsTab> with SingleTickerProviderStateMixin {
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
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppStyles.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              tabs: [
                Tab(text: _t('customerChats').toUpperCase()),
                Tab(text: _t('userFeedbacks').toUpperCase()),
                const Tab(text: 'AI QUEUE'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ChatManagementTab(),
                FeedbackTab(),
                AiNotificationsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context, 
          isScrollControlled: true, 
          backgroundColor: Colors.transparent,
          builder: (context) => const CustomNotificationSheet(),
        ),
        backgroundColor: AppStyles.primaryColor,
        icon: const Icon(Icons.notification_add_rounded, color: Colors.white),
        label: const Text('CREATE NOTIFICATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}
