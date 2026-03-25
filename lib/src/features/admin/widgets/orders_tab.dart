import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';
import 'emergency_tab.dart';
import 'orders/order_card.dart';

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key});
  @override
  ConsumerState<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<OrdersTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  String _activeFilter = 'All';
  bool _showOnlyToday = true;

  @override
  bool get wantKeepAlive => true;

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

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildTimeSwitch(isDark),
        TabBar(
          controller: _tabController,
          labelColor: AppStyles.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppStyles.primaryColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(text: _t('regularOrders').toUpperCase()),
            Tab(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emergency_rounded,
                    color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Text(_t('emergency').toUpperCase(),
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w900)),
              ],
            )),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRegularOrders(isDark),
              const EmergencyTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade100,
        border: Border(
            bottom: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _showOnlyToday
                ? _t('todaysOverview').toUpperCase()
                : _t('allTimePerformance').toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.grey.shade500,
                letterSpacing: 1),
          ),
          Container(
            height: 32,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                _timeToggleBtn(_t('today'), _showOnlyToday,
                    () => setState(() => _showOnlyToday = true), isDark),
                _timeToggleBtn(_t('allTime'), !_showOnlyToday,
                    () => setState(() => _showOnlyToday = false), isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeToggleBtn(String l, bool sel, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: sel
              ? (isDark ? AppStyles.primaryColor : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: sel && !isDark
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
              : null,
        ),
        child: Center(
            child: Text(l,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: sel
                        ? (isDark ? Colors.white : AppStyles.primaryColor)
                        : Colors.grey))),
      ),
    );
  }

  Widget _buildRegularOrders(bool isDark) {
    final ordersAsync = ref.watch(ordersProvider);
    final usersAsync = ref.watch(allUsersProvider);

    return ordersAsync.when(
      data: (orders) {
        final now = DateTime.now();
        final List<Map<String, dynamic>> timeFiltered = _showOnlyToday
            ? orders.where((o) {
                final date = (o['createdAt'] as Timestamp?)?.toDate();
                return date != null &&
                    date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year;
              }).toList()
            : orders;

        final regularOrders =
            timeFiltered.where((o) => o['isEmergency'] != true).toList();

        final Map<String, int> counts = {
          'All': regularOrders.length,
          'Pending':
              regularOrders.where((o) => o['status'] == 'Pending').length,
          'Processing':
              regularOrders.where((o) => o['status'] == 'Processing').length,
          'Shipped':
              regularOrders.where((o) => o['status'] == 'Shipped').length,
          'Delivered':
              regularOrders.where((o) => o['status'] == 'Delivered').length,
          'Cancelled':
              regularOrders.where((o) => o['status'] == 'Cancelled').length,
        };

        final filteredOrders = _activeFilter == 'All'
            ? regularOrders
            : regularOrders.where((o) => o['status'] == _activeFilter).toList();

        final staffList = usersAsync.maybeWhen(
          data: (users) => users.where((u) => u['role'] != 'customer').toList(),
          orElse: () => <Map<String, dynamic>>[],
        );

        return Column(
          children: [
            _buildFilterBar(isDark, counts),
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(_t('noItemsFound'),
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) => OrderCard(
                        order: filteredOrders[index],
                        staff: staffList,
                        isDark: isDark,
                      ),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${_t('error')}: $e')),
    );
  }

  Widget _buildFilterBar(bool isDark, Map<String, int> counts) {
    final filters = [
      'All',
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled'
    ];
    return Column(
      children: [
        if (_activeFilter != 'All' && _activeFilter != 'Delivered' && _activeFilter != 'Cancelled')
           const Padding(
             padding: EdgeInsets.only(right: 20, top: 4),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: [
                 Icon(Icons.star, color: Colors.orange, size: 14),
                 SizedBox(width: 4),
                 Text('জরুরী', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 10)),
               ],
             ),
           ),
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final String key = filters[index];
              final isSelected = _activeFilter == key;
              final count = counts[key] ?? 0;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _activeFilter = key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppStyles.primaryColor
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark ? Colors.white10 : Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Text(_t(key),
                            style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : (isDark ? Colors.white10 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(count.toString(),
                              style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

