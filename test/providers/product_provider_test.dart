import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock Product Model
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double rating;
  final int reviewCount;
  final String category;
  final bool inStock;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.inStock,
    required this.images,
  });
}

// Mock Product State Notifier
class ProductStateNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final List<Product> _allProducts = [
    Product(
      id: '1',
      name: 'Laptop',
      description: 'High-performance laptop',
      price: 999.99,
      rating: 4.5,
      reviewCount: 128,
      category: 'Electronics',
      inStock: true,
      images: ['laptop.jpg'],
    ),
    Product(
      id: '2',
      name: 'Mouse',
      description: 'Wireless mouse',
      price: 29.99,
      rating: 4.2,
      reviewCount: 256,
      category: 'Electronics',
      inStock: true,
      images: ['mouse.jpg'],
    ),
    Product(
      id: '3',
      name: 'Keyboard',
      description: 'Mechanical keyboard',
      price: 79.99,
      rating: 4.8,
      reviewCount: 512,
      category: 'Electronics',
      inStock: true,
      images: ['keyboard.jpg'],
    ),
    Product(
      id: '4',
      name: 'Book',
      description: 'Flutter guide',
      price: 39.99,
      rating: 4.0,
      reviewCount: 64,
      category: 'Books',
      inStock: false,
      images: ['book.jpg'],
    ),
  ];

  ProductStateNotifier() : super(const AsyncValue.loading());

  Future<void> fetchProducts() async {
    state = AsyncValue.data(_allProducts);
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(_allProducts);
    } else {
      final filtered = _allProducts
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      state = AsyncValue.data(filtered);
    }
  }

  Future<void> filterByCategory(String category) async {
    if (category.isEmpty) {
      state = AsyncValue.data(_allProducts);
    } else {
      final filtered = _allProducts.where((p) => p.category == category).toList();
      state = AsyncValue.data(filtered);
    }
  }

  Future<void> filterByPrice({required double minPrice, required double maxPrice}) async {
    final filtered =
        _allProducts.where((p) => p.price >= minPrice && p.price <= maxPrice).toList();
    state = AsyncValue.data(filtered);
  }

  Product? getProductById(String id) {
    try {
      return _allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Mock providers
final productProvider = StateNotifierProvider<ProductStateNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductStateNotifier();
});

final productSearchProvider = StateProvider<String>((ref) => '');

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final products = ref.watch(productProvider);
  final searchQuery = ref.watch(productSearchProvider);

  if (searchQuery.isEmpty) {
    return products;
  }

  return products.when(
    data: (data) {
      final filtered =
          data.where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      return AsyncValue.data(filtered);
    },
    error: (err, st) => AsyncValue.error(err, st),
    loading: () => const AsyncValue.loading(),
  );
});

void main() {
  group('Product Provider Tests', () {
    // ========================================================================
    // GROUP 1: Fetch Products (3 tests)
    // ========================================================================
    group('Product - Fetch Products', () {
      test('1. Initial state is loading', () {
        final container = ProviderContainer();

        expect(container.read(productProvider).isLoading, isTrue);
      });

      test('2. Fetch products successfully', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.fetchProducts();

        expect(container.read(productProvider).isLoading, isFalse);
        expect(
          container.read(productProvider).when(
                data: (data) => data.length,
                error: (_, __) => 0,
                loading: () => 0,
              ),
          4,
        );
      });

      test('3. Fetched products have correct data', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.fetchProducts();

        container.read(productProvider).whenData((products) {
          expect(products.first.name, 'Laptop');
          expect(products.first.price, 999.99);
          expect(products.first.inStock, isTrue);
        });
      });
    });

    // ========================================================================
    // GROUP 2: Search Products (4 tests)
    // ========================================================================
    group('Product - Search', () {
      test('1. Search returns matching products', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.searchProducts('Mouse');

        final result = container.read(productProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );

        expect(result.length, 1);
        expect(result.first.name, 'Mouse');
      });

      test('2. Search is case insensitive', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.searchProducts('LAPTOP');

        final result = container.read(productProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );

        expect(result.length, 1);
        expect(result.first.name, 'Laptop');
      });

      test('3. Empty search returns all products', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.searchProducts('');

        final result = container.read(productProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );

        expect(result.length, 4);
      });

      test('4. Search for non-existent product', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.searchProducts('NonExistent');

        final result = container.read(productProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );

        expect(result.length, 0);
      });
    });

    // ========================================================================
    // GROUP 3: Filter Products (3 tests)
    // ========================================================================
    group('Product - Filter', () {
      test('1. Filter by category', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.filterByCategory('Electronics');

        final result = container.read(productProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );

        expect(result.length, 3);
        expect(result.every((p) => p.category == 'Electronics'), isTrue);
      });

      test('2. Filter by price range', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.filterByPrice(minPrice: 30.0, maxPrice: 100.0);

        final result = container.read(productProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );

        expect(result.length, 2); // Keyboard (79.99) and Book (39.99)
        expect(result.every((p) => p.price >= 30.0 && p.price <= 100.0), isTrue);
      });

      test('3. Filter by empty category returns all', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        await productNotifier.filterByCategory('');

        final result = container.read(productProvider).when(
          data: (data) => data,
          error: (_, __) => [],
          loading: () => [],
        );

        expect(result.length, 4);
      });
    });

    // ========================================================================
    // GROUP 4: Product Details (4 tests)
    // ========================================================================
    group('Product - Details', () {
      test('1. Get product by valid ID', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        final product = productNotifier.getProductById('1');

        expect(product, isNotNull);
        expect(product?.name, 'Laptop');
        expect(product?.price, 999.99);
      });

      test('2. Get product by invalid ID returns null', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        final product = productNotifier.getProductById('999');

        expect(product, isNull);
      });

      test('3. Product stock status correct', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        final inStockProduct = productNotifier.getProductById('1');
        final outOfStockProduct = productNotifier.getProductById('4');

        expect(inStockProduct?.inStock, isTrue);
        expect(outOfStockProduct?.inStock, isFalse);
      });

      test('4. Product rating and reviews', () async {
        final container = ProviderContainer();
        final productNotifier = container.read(productProvider.notifier);

        final product = productNotifier.getProductById('3');

        expect(product?.rating, 4.8);
        expect(product?.reviewCount, 512);
      });
    });
  });
}
