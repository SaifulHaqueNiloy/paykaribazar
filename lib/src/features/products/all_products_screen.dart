import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/core/firebase/firestore_paginator.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/features/home/widgets/home_widgets.dart';
import '../../utils/styles.dart';

enum ProductViewMode { category, shop }

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  late FirestorePaginator<Map<String, dynamic>> _paginator;
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  String? _selectedShopId;
  int _gridColumns = 2;
  ProductViewMode _viewMode = ProductViewMode.category;

  @override
  void initState() {
    super.initState();
    _loadGridPreference();
    _initPaginator();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadGridPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _gridColumns = prefs.getInt('product_grid_cols') ?? 2;
    });
  }

  Future<void> _toggleGrid() async {
    final next = _gridColumns == 2 ? 3 : (_gridColumns == 3 ? 4 : 2);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('product_grid_cols', next);
    setState(() => _gridColumns = next);
  }

  void _initPaginator() {
    _paginator = FirestorePaginator<Map<String, dynamic>>(
      collectionPath: HubPaths.products,
      queryBuilder: (query) {
        if (_viewMode == ProductViewMode.category) {
          return _selectedCategory == null
              ? query
              : query.where('categoryId', isEqualTo: _selectedCategory);
        }
        return _selectedShopId == null ? query : query.where('shopId', isEqualTo: _selectedShopId);
      },
      fromFirestore: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      },
    );

    _paginator.fetchFirstPage().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _switchViewMode(ProductViewMode mode) async {
    if (_viewMode == mode) return;
    setState(() {
      _viewMode = mode;
      _selectedCategory = null;
      _selectedShopId = null;
    });
    _paginator.refresh();
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('পণ্য তালিকা', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          SegmentedButton<ProductViewMode>(
            style: SegmentedButton.styleFrom(
              backgroundColor: isDark ? Colors.white10 : Colors.white,
              selectedBackgroundColor: Colors.white,
              selectedForegroundColor: AppStyles.primaryColor,
            ),
            segments: const [
              ButtonSegment<ProductViewMode>(
                value: ProductViewMode.category,
                label: Text('Category', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.category_outlined, size: 16),
              ),
              ButtonSegment<ProductViewMode>(
                value: ProductViewMode.shop,
                label: Text('Shop', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.storefront_outlined, size: 16),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (selected) => _switchViewMode(selected.first),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(_gridColumns == 2 ? Icons.grid_view_rounded : (_gridColumns == 3 ? Icons.view_comfy_rounded : Icons.view_module_rounded)),
            tooltip: 'Change Grid Layout',
            onPressed: _toggleGrid,
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilter(categoriesAsync, isDark),
          Expanded(
            child: _paginator.items.isEmpty && _paginator.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppStyles.primaryColor))
                : _paginator.items.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppStyles.primaryColor,
                        onRefresh: () async {
                          await _paginator.fetchFirstPage();
                          if (mounted) setState(() {});
                        },
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _gridColumns,
                            childAspectRatio: _gridColumns == 2 ? 0.68 : (_gridColumns == 3 ? 0.6 : 0.55),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _paginator.items.length + (_paginator.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _paginator.items.length) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final productData = _paginator.items[index];
                            return ProductCard(productMap: productData);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter(AsyncValue<List<Map<String, dynamic>>> categoriesAsync, bool isDark) {
    if (_viewMode == ProductViewMode.category) {
      return _buildCategoryFilter(categoriesAsync, isDark);
    }
    return _buildShopFilter(isDark);
  }

  Widget _buildCategoryFilter(AsyncValue<List<Map<String, dynamic>>> categoriesAsync, bool isDark) {
    return categoriesAsync.when(
      data: (categories) => Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final category = isAll ? null : categories[index - 1];
            final id = isAll ? null : category!['id'];
            final name = isAll ? 'সব পণ্য' : category!['name'];
            final isSelected = _selectedCategory == id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(name),
                selected: isSelected,
                onSelected: (selected) async {
                  if (!selected) {
                    setState(() => _selectedCategory = null);
                    _paginator.refresh();
                    _paginator.fetchFirstPage().then((_) {
                      if (mounted) setState(() {});
                    });
                    return;
                  }
                  setState(() => _selectedCategory = id);
                },
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                selectedColor: AppStyles.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide.none,
                showCheckmark: false,
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 50),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildShopFilter(bool isDark) {
    final shopsStream = FirebaseFirestore.instance.collection(HubPaths.stores).snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: shopsStream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: docs.isEmpty
              ? const Center(child: Text('No shops available'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final data = isAll ? null : docs[index - 1].data() as Map<String, dynamic>?;
                    final id = isAll ? null : docs[index - 1].id;
                    final name = isAll ? 'All Shops' : (data?['name'] ?? 'Shop');
                    final isSelected = _selectedShopId == id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(name),
                        selected: isSelected,
                        onSelected: (selected) async {
                          if (!selected) {
                            setState(() => _selectedShopId = null);
                            _paginator.refresh();
                            _paginator.fetchFirstPage().then((_) {
                              if (mounted) setState(() {});
                            });
                            return;
                          }
                          setState(() => _selectedShopId = id);
                        },
                        backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                        selectedColor: AppStyles.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide.none,
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('কোন পণ্য পাওয়া যায়নি', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

