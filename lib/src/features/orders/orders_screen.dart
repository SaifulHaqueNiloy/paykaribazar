import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/core/firebase/firestore_paginator.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';
import 'order_details_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _activeFilter = 'All';
  late FirestorePaginator<dynamic> _paginator;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initPaginator();
    _scrollController.addListener(_onScroll);
  }

  void _initPaginator() {
    final authState = ref.read(authStateProvider);
    final uid = authState.value?.uid;

    _paginator = FirestorePaginator<dynamic>(
      collectionPath: 'orders',
      pageSize: 10,
      queryBuilder: (query) {
        var q = query.where('buyerId', isEqualTo: uid);
        if (_activeFilter != 'All') {
          q = q.where('status', isEqualTo: _activeFilter);
        }
        return q;
      },
      fromFirestore: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      },
    );

    // Initial load
    _paginator.fetchFirstPage().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_paginator.isLoading && _paginator.hasMore) {
        _paginator.fetchNextPage().then((_) {
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text(_t('myOrders'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterChips(isDark),
          Expanded(
            child: _paginator.items.isEmpty && _paginator.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await _paginator.fetchFirstPage();
                      if (mounted) setState(() {});
                    },
                    child: _paginator.items.isEmpty
                        ? Center(child: Text(_t('noOrdersFound')))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _paginator.items.length +
                                (_paginator.hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _paginator.items.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return _buildOrderTile(_paginator.items[index], isDark);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    final filters = ['All', 'Pending', 'Processing', 'Delivered', 'Cancelled'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = _activeFilter == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (v) {
                if (v) {
                  setState(() {
                    _activeFilter = filters[index];
                    _initPaginator(); // Re-initialize with new filter
                  });
                }
              },
              selectedColor: AppStyles.primaryColor,
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order, bool isDark) {
    final status = order['status']?.toString() ?? 'Pending';
    final total = (order['total'] as num? ?? 0.0).toDouble();
    final id = order['id']?.toString() ?? '';
    final createdAtStr = order['createdAt']?.toString();
    
    DateTime? orderDate;
    if (order['createdAt'] is Timestamp) {
      orderDate = (order['createdAt'] as Timestamp).toDate();
    } else if (createdAtStr != null) {
      orderDate = DateTime.tryParse(createdAtStr);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (c) => OrderDetailsScreen(orderId: id))),
        title: Text('Order #$id',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(
            orderDate != null
                ? 'Placed on ${orderDate.toString().split('.')[0]}'
                : 'Date N/A',
            style: const TextStyle(fontSize: 11)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('৳${total.toInt()}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppStyles.primaryColor)),
            Text(status,
                style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
