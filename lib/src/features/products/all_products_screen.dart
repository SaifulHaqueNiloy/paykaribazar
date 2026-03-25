import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/core/firebase/firestore_paginator.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../utils/styles.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  late FirestorePaginator<Map<String, dynamic>> _paginator;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _paginator = FirestorePaginator<Map<String, dynamic>>(
      collectionPath: HubPaths.products, // FIXED: Path from HubPaths
      pageSize: 20,
      orderByField: 'createdAt',
      descending: true,
      fromFirestore: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      },
    );

    _paginator.fetchFirstPage().then((_) {
      if (mounted) setState(() {});
    });

    _scrollController.addListener(_onScroll);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _paginator.items.isEmpty && _paginator.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paginator.items.isEmpty
              ? const Center(child: Text('No products available.'))
              : RefreshIndicator(
                  onRefresh: () async {
                    await _paginator.fetchFirstPage();
                    if (mounted) setState(() {});
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _paginator.items.length + (_paginator.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _paginator.items.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final product = _paginator.items[index];
                      return _buildProductItem(product);
                    },
                  ),
                ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: product['imageUrl'] != null && (product['imageUrl'] as String).isNotEmpty
                  ? Image.network(product['imageUrl'], fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, size: 50),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'No Name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${product['price'] ?? 0}',
                  style: const TextStyle(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
