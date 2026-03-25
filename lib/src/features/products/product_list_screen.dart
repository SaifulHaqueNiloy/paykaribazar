import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/core/firebase/firestore_paginator.dart';
import '../../utils/styles.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const ProductListScreen({super.key, required this.categoryId});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late FirestorePaginator<dynamic> _paginator;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Initialize Paginator for Products
    _paginator = FirestorePaginator<dynamic>(
      collectionPath: 'products',
      pageSize: 15,
      queryBuilder: (query) => query.where('categoryId', isEqualTo: widget.categoryId),
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

    // Listen to scroll for infinite loading
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
        title: Text('Category: ${widget.categoryId}', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _paginator.items.isEmpty && _paginator.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _paginator.fetchFirstPage();
                if (mounted) setState(() {});
              },
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _paginator.items.length + (_paginator.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _paginator.items.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final product = _paginator.items[index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            image: product['imageUrl'] != null 
                ? DecorationImage(
                    image: NetworkImage(product['imageUrl']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: product['imageUrl'] == null 
              ? const Icon(Icons.image_not_supported) 
              : null,
        ),
        title: Text(product['name'] ?? 'No Name', 
          style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ৳${product['price']}', 
              style: const TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.bold)),
            if (product['description'] != null)
              Text(product['description'], 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart, color: AppStyles.primaryColor),
          onPressed: () {
            // Add to cart logic
          },
        ),
      ),
    );
  }
}
