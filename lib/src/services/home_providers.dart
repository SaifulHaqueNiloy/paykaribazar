import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../models/product_model.dart';

final homeBannerIndexProvider = StateProvider<int>((ref) => 0);
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

final homeProductsProvider = Provider<List<Product>>((ref) {
  final productsMap = ref.watch(productsProvider).value ?? [];
  return productsMap.map((m) => Product.fromMap(m, m['id'] ?? '')).toList();
});

final flashDealsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(homeProductsProvider);
  return products.where((p) => p.isFlashSale).toList();
});

final newArrivalsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(homeProductsProvider);
  return products.where((p) => p.isNewArrival).toList();
});

final hotSellingProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(homeProductsProvider);
  return products.where((p) => p.isHotSelling).toList();
});

final comboPacksProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(homeProductsProvider);
  return products.where((p) => p.isComboPack).toList();
});

final justForYouProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(homeProductsProvider);
  // For now, just return a shuffle or slice as "Just For You"
  return products.take(10).toList();
});
