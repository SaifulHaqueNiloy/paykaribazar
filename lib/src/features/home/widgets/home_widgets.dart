import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../../models/product_model.dart';

export 'floating_cart_bar.dart';

class BannerSlider extends StatelessWidget {
  final List<String> banners;
  const BannerSlider({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 160,
        child: PageView.builder(
          itemCount: banners.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(banners[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const SectionHeader({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          InkWell(
            onTap: onTap,
            child: const Text('সব দেখুন',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class ProductHorizontalList extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final String emptyMessage;
  const ProductHorizontalList(
      {super.key, required this.products, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(emptyMessage,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      );
    }

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, index) => Container(
          width: 150,
          margin: const EdgeInsets.only(right: 12),
          child: ProductCard(productMap: products[index]),
        ),
      ),
    );
  }
}

class ProductCard extends ConsumerWidget {
  final Product? product;
  final Map<String, dynamic>? productMap;
  
  const ProductCard({super.key, this.product, this.productMap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Product? effectiveProduct = product;
    if (effectiveProduct == null && productMap != null) {
      effectiveProduct = Product.fromMap(productMap!, productMap!['id'] ?? '');
    }
    
    if (effectiveProduct == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/product-details?productId=${effectiveProduct!.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // Card BG from design
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: effectiveProduct.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                  // Overlay icons
                  Positioned(
                    top: 8,
                    left: 8,
                    child:
                        _iconCircle(Icons.share, Colors.white.withValues(alpha: 0.2)),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _iconCircle(
                        Icons.favorite_border, Colors.white.withValues(alpha: 0.2)),
                  ),
                  if (effectiveProduct.hasDiscount)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text('${effectiveProduct.discountPercentage}% OFF',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  // Rating Badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4)),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text('${effectiveProduct.rating}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    effectiveProduct.nameBn.isNotEmpty ? effectiveProduct.nameBn : effectiveProduct.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('৳${effectiveProduct.price.toInt()}',
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13)),
                          if (effectiveProduct.hasDiscount)
                            Text('৳${effectiveProduct.oldPrice.toInt()}',
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 9,
                                    decoration: TextDecoration.lineThrough)),
                        ],
                      ),
                      _actionButton(ref, effectiveProduct),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconCircle(IconData icon, Color bg) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }

  Widget _actionButton(WidgetRef ref, Product product) {
    return InkWell(
      onTap: () {
        ref.read(cartProvider.notifier).addItem(CartItem(
              id: product.id,
              name: product.name,
              imageUrl: product.imageUrl,
              price: product.price,
              unit: product.unit,
            ));
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.shopping_basket_outlined,
            color: Colors.blueAccent, size: 16),
      ),
    );
  }
}

class StaticSearchBar extends StatelessWidget {
  final bool isDark;
  final String Function(String) t;
  const StaticSearchBar({super.key, required this.isDark, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search'),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(t('searchHint'),
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            const Icon(Icons.mic, color: Colors.indigo, size: 20),
            const SizedBox(width: 12),
            const Icon(Icons.camera_alt_outlined,
                color: Colors.indigo, size: 20),
            const SizedBox(width: 12),
            const Icon(Icons.grid_view_rounded, color: Colors.indigo, size: 20),
          ],
        ),
      ),
    );
  }
}

class StickyHeader extends StatelessWidget {
  final bool isDark;
  final String Function(String) t;
  const StickyHeader({super.key, required this.isDark, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      child: StaticSearchBar(isDark: isDark, t: t),
    );
  }
}
