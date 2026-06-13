import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/core/constants/paths.dart';
import 'package:paykari_bazar/src/features/home/widgets/home_widgets.dart';
import '../../utils/styles.dart';

enum GroupMode { shop, category }

class ProductGroupedScreen extends ConsumerStatefulWidget {
  const ProductGroupedScreen({super.key});

  @override
  ConsumerState<ProductGroupedScreen> createState() => _ProductGroupedScreenState();
}

class _ProductGroupedScreenState extends ConsumerState<ProductGroupedScreen> {
  GroupMode _mode = GroupMode.shop;
  bool _isLoading = true;
  List<QueryDocumentSnapshot> _docs = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance.collection(HubPaths.products).get();
      if (mounted) {
        setState(() {
          _docs = snapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('Products', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          SegmentedButton<GroupMode>(
            style: SegmentedButton.styleFrom(
              backgroundColor: isDark ? Colors.white10 : Colors.white,
              selectedBackgroundColor: Colors.white,
              selectedForegroundColor: AppStyles.primaryColor,
            ),
            segments: const [
              ButtonSegment<GroupMode>(
                value: GroupMode.shop,
                label: Text('Shop', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.storefront_outlined, size: 16),
              ),
              ButtonSegment<GroupMode>(
                value: GroupMode.category,
                label: Text('Category', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.category_outlined, size: 16),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selected) => setState(() => _mode = selected.first),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppStyles.primaryColor,
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppStyles.primaryColor))
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _docs.isEmpty
                    ? const Center(child: Text('No products found'))
                    : _mode == GroupMode.shop
                        ? _ShopGroupedList(docs: _docs, isDark: isDark)
                        : _CategoryGroupedList(docs: _docs, isDark: isDark),
      ),
    );
  }
}

class _ShopGroupedList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final bool isDark;

  const _ShopGroupedList({required this.docs, required this.isDark});

  Map<String, List<Map<String, dynamic>>> _groupByShop() {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final shopId = data['shopId']?.toString() ?? 'unknown';
      map.putIfAbsent(shopId, () => []).add(data);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByShop();
    final shopIds = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: shopIds.length,
      itemBuilder: (context, index) {
        final shopId = shopIds[index];
        final products = grouped[shopId]!;
        return _ShopTile(
          shopId: shopId,
          products: products,
          isDark: isDark,
        );
      },
    );
  }
}

class _ShopTile extends StatefulWidget {
  final String shopId;
  final List<Map<String, dynamic>> products;
  final bool isDark;

  const _ShopTile({required this.shopId, required this.products, required this.isDark});

  @override
  State<_ShopTile> createState() => _ShopTileState();
}

class _ShopTileState extends State<_ShopTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.shopId == 'unknown' ? 'Unknown Shop' : widget.shopId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${widget.products.length} products'),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.products.length,
                itemBuilder: (context, i) => ProductCard(productMap: widget.products[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryGroupedList extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;
  final bool isDark;

  const _CategoryGroupedList({required this.docs, required this.isDark});

  Future<Map<String, List<Map<String, dynamic>>>> _groupByCategory() async {
    final map = <String, List<Map<String, dynamic>>>{};
    final categoryIds = <String>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final catId = data['categoryId']?.toString() ?? 'uncategorized';
      categoryIds.add(catId);
      map.putIfAbsent(catId, () => []).add(data);
    }

    final names = <String, String>{};
    for (final id in categoryIds) {
      try {
        final snap = await FirebaseFirestore.instance.doc('hub/data/categories/$id').get();
        if (snap.exists) {
          final data = snap.data() as Map<String, dynamic>;
          names[id] = data['name']?.toString() ?? id;
        } else {
          names[id] = id;
        }
      } catch (_) {
        names[id] = id;
      }
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => (names[a] ?? a).compareTo(names[b] ?? b));

    final sorted = <String, List<Map<String, dynamic>>>{};
    for (final k in sortedKeys) {
      sorted[names[k] ?? k] = map[k]!;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: _groupByCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final grouped = snapshot.data!;
        final categories = grouped.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categoryName = categories[index];
            final products = grouped[categoryName]!;
            return _CategoryTile(
              categoryName: categoryName,
              products: products,
              isDark: isDark,
            );
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> products;
  final bool isDark;

  const _CategoryTile({required this.categoryName, required this.products, required this.isDark});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${widget.products.length} products'),
            trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: widget.products.length,
                itemBuilder: (context, i) => ProductCard(productMap: widget.products[i]),
              ),
            ),
        ],
      ),
    );
  }
}
