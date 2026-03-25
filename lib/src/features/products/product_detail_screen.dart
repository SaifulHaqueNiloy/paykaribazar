import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product_model.dart';
import '../../di/providers.dart';
import '../home/widgets/home_widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? _product;
  List<Map<String, dynamic>> _relatedProducts = [];
  bool _isLoading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = ref.read(productsProvider).value ?? [];
      final map = products.firstWhere((p) => p['id'] == widget.productId);
      _product = Product.fromMap(map, map['id']);

      if (_product != null) {
        _relatedProducts = products
            .where((p) =>
                p['categoryId'] == _product!.categoryId &&
                p['id'] != _product!.id)
            .take(5)
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading product: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_product == null) {
      return const Scaffold(body: Center(child: Text('Product not found')));
    }

    final lang = ref.watch(languageProvider).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(_product!, lang),
                  const Divider(height: 32),
                  _buildPriceSection(_product!),
                  const SizedBox(height: 24),
                  _buildQuantitySelector(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(_product!, lang),
                  const SizedBox(height: 32),
                  const Text('RELATED PRODUCTS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildRelatedList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar(bool isDark) => SliverAppBar(
        expandedHeight: 300,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: CachedNetworkImage(
            imageUrl: _product!.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
      );

  Widget _buildTitleSection(Product p, String lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.getName(lang),
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(p.getCategory(lang),
              style: const TextStyle(
                  color: Colors.teal, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _buildPriceSection(Product p) => Row(
        children: [
          Text('৳${p.price.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal)),
          if (p.hasDiscount) ...[
            const SizedBox(width: 12),
            Text('৳${p.oldPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough)),
          ],
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(p.unit,
                style: const TextStyle(
                    color: Colors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      );

  Widget _buildQuantitySelector() => Row(
        children: [
          const Text('Quantity:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
              onPressed: () =>
                  setState(() => _quantity > 1 ? _quantity-- : null),
              icon: const Icon(Icons.remove_circle_outline)),
          Text('$_quantity',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add_circle_outline)),
        ],
      );

  Widget _buildDescriptionSection(Product p, String lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DESCRIPTION',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(lang == 'en' ? p.description : p.descriptionBn,
              style: const TextStyle(color: Colors.grey, height: 1.5)),
        ],
      );

  Widget _buildRelatedList() => SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _relatedProducts.length,
          itemBuilder: (context, index) =>
              ProductCard(productMap: _relatedProducts[index]),
        ),
      );

  Widget _buildBottomBar() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5))
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            ref.read(cartProvider.notifier).addItem(CartItem(
                  id: _product!.id,
                  name: _product!.name,
                  imageUrl: _product!.imageUrl,
                  price: _product!.price,
                  quantity: _quantity,
                  unit: _product!.unit,
                ));
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Added to cart')));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 50)),
          child: const Text('ADD TO CART',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
}

