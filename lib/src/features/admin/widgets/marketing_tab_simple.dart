import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/styles.dart';

class MarketingTab extends ConsumerStatefulWidget {
  const MarketingTab({super.key});

  @override
  ConsumerState<MarketingTab> createState() => _MarketingTabState();
}

class _MarketingTabState extends ConsumerState<MarketingTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            isScrollable: true,
            labelColor:
                isDark ? AppStyles.darkPrimaryColor : AppStyles.primaryColor,
            indicatorColor:
                isDark ? AppStyles.darkPrimaryColor : AppStyles.primaryColor,
            tabs: const [
              Tab(text: 'LOYALTY'),
              Tab(text: 'COUPONS'),
              Tab(text: 'BANNERS'),
              Tab(text: 'NOTICES'),
              Tab(text: 'MEGA DRAW'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLoyaltyManager(isDark),
            _buildCouponManager(isDark),
            _buildBannerManager(isDark),
            _buildNoticeManager(isDark),
            _buildMegaDrawManager(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyManager(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loyalty Settings',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Configure loyalty points and rewards here',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildCouponManager(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coupon Management',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Manage promotional coupons and discount codes',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBannerManager(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Banner Management',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Upload and manage marketing banners',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildNoticeManager(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notice Board', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Post important notices and announcements',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMegaDrawManager(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mega Draw Management',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('Configure and manage mega draw winners',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
