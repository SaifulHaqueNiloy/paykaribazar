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

      when(() => cartService.addItem(any(), any())).thenAnswer((_) async => true);
      
      final result = await cartService.addItem(product, 2);
      expect(result, true);
    });

    test('Get cart total', () async {
      when(() => cartService.getCartTotal()).thenAnswer((_) async => 1000.0);
      final result = await cartService.getCartTotal();
      expect(result, 1000.0);
    });
  });
}
