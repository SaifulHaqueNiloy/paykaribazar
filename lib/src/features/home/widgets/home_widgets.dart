import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../../models/product_model.dart';
import '../../../utils/styles.dart';

export 'floating_cart_bar.dart';

class BannerSlider extends StatefulWidget {
  final List<String> banners;
  const BannerSlider({super.key, required this.banners});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160.0,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.banners.map((url) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.banners.asMap().entries.map((entry) {
            return Container(
              width: _current == entry.key ? 12.0 : 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: AppStyles.primaryColor.withValues(
                  alpha: _current == entry.key ? 1.0 : 0.2,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('সব দেখুন',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold)),
            ),
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
      height: 320, // Increased for DNA Card
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, index) => Container(
          width: 180,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/product-details?productId=${effectiveProduct!.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppStyles.softShadow,
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack (DNA: Wishlist icon top-right, Discount badge left)
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: effectiveProduct.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[900]),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                  ),
                  // Wishlist Icon (DNA Requirement)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _iconCircle(Icons.favorite_border, Colors.black26),
                  ),
                  // Discount Badge
                  if (effectiveProduct.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                        child: Text('-${effectiveProduct.discountPercentage}%',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  // Stock Badge (DNA Requirement)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: effectiveProduct.stock > 0 ? Colors.green.withValues(alpha: 0.8) : Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(effectiveProduct.stock > 0 ? 'IN STOCK' : 'OUT',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name (DNA: 2 lines max)
                  Text(
                    effectiveProduct.nameBn.isNotEmpty ? effectiveProduct.nameBn : effectiveProduct.name,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating (DNA: Stars + count)
                  Row(
                    children: [
                      ...List.generate(5, (i) => const Icon(Icons.star_rounded, color: Colors.amber, size: 12)),
                      const SizedBox(width: 4),
                      const Text('(5)', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Pricing (DNA: Price Bold Large, Original Strikethrough)
                  Row(
                    children: [
                      Text('৳${effectiveProduct.price.toInt()}',
                          style: const TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(width: 8),
                      if (effectiveProduct.hasDiscount)
                        Text('৳${effectiveProduct.oldPrice.toInt()}',
                            style: const TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.lineThrough)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Add to Cart Button (DNA: Teal bg, bottom aligned)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(cartProvider.notifier).addItem(CartItem(
                          id: effectiveProduct!.id,
                          name: effectiveProduct.name,
                          imageUrl: effectiveProduct.imageUrl,
                          price: effectiveProduct.price,
                          unit: effectiveProduct.unit,
                        ));
                      },
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                      label: const Text('ADD TO CART', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                    ),
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
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 16),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(t('searchHint'),
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ),
            const Icon(Icons.mic_none_rounded, color: AppStyles.primaryColor, size: 20),
            const SizedBox(width: 12),
            const Icon(Icons.camera_alt_outlined, color: AppStyles.primaryColor, size: 20),
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
      color: AppStyles.darkBackgroundColor.withValues(alpha: 0.95),
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
      child: StaticSearchBar(isDark: isDark, t: t),
    );
  }
}


