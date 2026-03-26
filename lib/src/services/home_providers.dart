import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../models/product_model.dart';

final homeBannerIndexProvider = StateProvider<int>((ref) => 0);
final isSearchActiveProvider = StateProvider<bool>((ref) => false);

final homeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productsList = ref.watch(productsProvider);
  
  // Handle the AsyncValue
  final productsMap = await productsList.when(
    data: (data) async => data,
    loading: () async => [],
    error: (err, stack) async => [],
  );
  
  return productsMap.map((m) => Product.fromMap(m, m['id'] ?? '')).toList();
});

final flashDealsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(homeProductsProvider.future);
  return products.where((p) => p.isFlashSale).toList();
});

final newArrivalsProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(homeProductsProvider.future);
  return products.where((p) => p.isNewArrival).toList();
});

final hotSellingProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(homeProductsProvider.future);
  return products.where((p) => p.isHotSelling).toList();
});

final comboPacksProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(homeProductsProvider.future);
  return products.where((p) => p.isComboPack).toList();
});

final justForYouProvider = FutureProvider<List<Product>>((ref) async {
  final products = await ref.watch(homeProductsProvider.future);
  // For now, just return a shuffle or slice as "Just For You"
  return products.take(10).toList();
});
