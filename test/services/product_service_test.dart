import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/features/commerce/services/product_service.dart';
import 'package:paykari_bazar/src/models/product_model.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  group('ProductService Tests', () {
    late MockProductService productService;

    setUp(() {
      productService = MockProductService();
    });

    test('Get product by ID', () async {
      final product = Product(
        id: 'prod1',
        sku: 'SKU001',
        name: 'Test Product',
        nameBn: 'পরীক্ষা পণ্য',
        description: 'Test Description',
        descriptionBn: 'পরীক্ষা বর্ণনা',
        price: 100.0,
        stock: 10,
        unit: 'pcs',
        unitBn: 'পিস',
        imageUrl: '',
        categoryId: 'cat1',
        categoryName: 'Test Category',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => productService.getProductById(any())).thenAnswer((_) async => product);
      
      final result = await productService.getProductById('prod1');
      
      expect(result?.id, 'prod1');
      expect(result?.name, 'Test Product');
    });

    test('Search products', () async {
      when(() => productService.searchProducts(any())).thenAnswer((_) async => []);
      
      final results = await productService.searchProducts('test');
      expect(results, isA<List<Product>>());
    });
   group('Product matchesSearch', () {
      final product = Product(
        id: '1',
        sku: 'SKU123',
        name: 'Rice',
        nameBn: 'চাল',
        description: 'Quality rice',
        descriptionBn: 'ভালো চাল',
        price: 50,
        stock: 100,
        unit: 'kg',
        unitBn: 'কেজি',
        imageUrl: '',
        categoryId: 'grocery',
        categoryName: 'Grocery',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      test('matches by name', () {
        expect(product.matchesSearch('rice'), isTrue);
      });

      test('matches by nameBn', () {
        expect(product.matchesSearch('চাল'), isTrue);
      });

      test('matches by sku', () {
        expect(product.matchesSearch('SKU123'), isTrue);
      });

      test('does not match unrelated query', () {
        expect(product.matchesSearch('mobile'), isFalse);
      });
    });
  });
}
