import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/features/commerce/services/cart_service.dart';
import 'package:paykari_bazar/src/models/product_model.dart';

class MockCartService extends Mock implements CartService {}

void main() {
  group('CartService Tests', () {
    late MockCartService cartService;

    setUp(() {
      cartService = MockCartService();
    });

    test('Add item to cart', () async {
      final product = Product(
        id: '1',
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

      when(() => cartService.addItem(any<Product>(), any<int>()))
          .thenAnswer((_) async => true);

      final result = await cartService.addItem(product, 2);
      expect(result, isTrue);
    });

    test('Get cart total', () async {
      when(() => cartService.getCartTotal()).thenAnswer((_) async => 1000.0);
      final result = await cartService.getCartTotal();
      expect(result, 1000.0);
    });

    test('Sync cart to cloud', () async {
      final items = [
        {'productId': '1', 'quantity': 2},
      ];
      when(() => cartService.syncCartToCloud(any<List<Map<String, dynamic>>>()))
          .thenAnswer((_) async => Future.value());

      await cartService.syncCartToCloud(items);
      verify(() => cartService.syncCartToCloud(any<List<Map<String, dynamic>>>())).called(1);
    });

    test('Fetch saved cart returns data', () async {
      final items = [
        {'productId': '1', 'quantity': 2},
      ];
      when(() => cartService.fetchSavedCart()).thenAnswer((_) async => items);

      final result = await cartService.fetchSavedCart();
      expect(result, isNotNull);
      expect(result!.length, 1);
    });

    test('Fetch saved cart returns null when no cart', () async {
      when(() => cartService.fetchSavedCart()).thenAnswer((_) async => null);

      final result = await cartService.fetchSavedCart();
      expect(result, isNull);
    });

    test('Clear cloud cart', () async {
      when(() => cartService.clearCloudCart()).thenAnswer((_) async => Future.value());

      await cartService.clearCloudCart();
      verify(() => cartService.clearCloudCart()).called(1);
    });
  });
}
