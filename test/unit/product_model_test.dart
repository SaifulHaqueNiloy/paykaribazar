import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/src/models/product_model.dart';

void main() {
  group('Product Model Tests', () {
    test('Variant creation and serialization', () {
      final variant = Variant(
        id: 'var1',
        name: 'Red',
        nameBn: 'লাল',
        price: 100.0,
        stock: 50,
      );

      expect(variant.id, equals('var1'));
      expect(variant.name, equals('Red'));
      expect(variant.price, equals(100.0));
      expect(variant.stock, equals(50));
    });

    test('Variant toMap and fromMap', () {
      final original = Variant(
        id: 'var1',
        name: 'Red',
        nameBn: 'লাল',
        price: 100.0,
        stock: 50,
      );

      final map = original.toMap();
      final restored = Variant.fromMap(map);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.price, equals(original.price));
      expect(restored.stock, equals(original.stock));
    });

    test('Product creation with all fields', () {
      final now = DateTime.now();
      final product = Product(
        id: 'prod1',
        sku: 'SKU001',
        name: 'Test Product',
        nameBn: 'পরীক্ষা পণ্য',
        description: 'A test product',
        descriptionBn: 'একটি পরীক্ষামূলক পণ্য',
        price: 500.0,
        oldPrice: 600.0,
        purchasePrice: 300.0,
        stock: 100,
        unit: 'piece',
        unitBn: 'টুকরা',
        imageUrl: 'https://example.com/product.jpg',
        imageUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
        categoryId: 'cat1',
        categoryName: 'Category 1',
        categoryNameBn: 'ক্যাটেগরি ১',
        subCategoryId: 'subcat1',
        subCategoryName: 'Subcategory 1',
        subCategoryNameBn: 'উপ-ক্যাটেগরি ১',
        shopName: 'Test Shop',
        addedBy: 'user1',
        brand: 'Brand A',
        tags: ['tag1', 'tag2'],
        isFeatured: true,
        isHotSelling: true,
        comboProductIds: [],
        variants: [],
        rating: 4.5,
        salesCount: 150,
        createdAt: now,
        updatedAt: now,
        aiOptimized: true,
      );

      expect(product.id, equals('prod1'));
      expect(product.name, equals('Test Product'));
      expect(product.price, equals(500.0));
      expect(product.stock, equals(100));
    });

    test('Product discounted price calculation', () {
      final product = Product(
        id: 'prod1',
        sku: 'SKU001',
        name: 'Test Product',
        nameBn: 'পরীক্ষা পণ্য',
        description: 'A test product',
        descriptionBn: 'একটি পরীক্ষামূলক পণ্য',
        price: 500.0,
        oldPrice: 600.0,
        purchasePrice: 300.0,
        stock: 100,
        unit: 'piece',
        unitBn: 'টুকরা',
        imageUrl: 'https://example.com/product.jpg',
        imageUrls: [],
        categoryId: 'cat1',
        categoryName: 'Category 1',
        categoryNameBn: 'ক্যাটেগরি ১',
        subCategoryId: 'subcat1',
        subCategoryName: 'Subcategory 1',
        subCategoryNameBn: 'উপ-ক্যাটেগরি ১',
        shopName: 'Test Shop',
        addedBy: 'user1',
        brand: 'Brand A',
        tags: [],
        isNewArrival: false,
        comboProductIds: [],
        variants: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Calculate discount percentage
      final discountPercentage =
          ((product.oldPrice - product.price) / product.oldPrice) * 100;
      expect(discountPercentage, closeTo(16.67, 0.1));
    });

    test('Product margin calculation', () {
      final product = Product(
        id: 'prod1',
        sku: 'SKU001',
        name: 'Test Product',
        nameBn: 'পরীক্ষা পণ্য',
        description: 'A test product',
        descriptionBn: 'একটি পরীক্ষামূলক পণ্য',
        price: 500.0,
        purchasePrice: 300.0,
        stock: 100,
        unit: 'piece',
        unitBn: 'টুকরা',
        imageUrl: 'https://example.com/product.jpg',
        imageUrls: [],
        categoryId: 'cat1',
        categoryName: 'Category 1',
        categoryNameBn: 'ক্যাটেগরি ১',
        subCategoryId: 'subcat1',
        subCategoryName: 'Subcategory 1',
        subCategoryNameBn: 'উপ-ক্যাটেগরি ১',
        shopName: 'Test Shop',
        addedBy: 'user1',
        brand: 'Brand A',
        tags: [],
        isNewArrival: false,
        comboProductIds: [],
        variants: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Calculate profit margin
      final margin = product.price - product.purchasePrice;
      final marginPercentage = (margin / product.purchasePrice) * 100;
      expect(marginPercentage, closeTo(66.67, 0.1));
    });

    test('Product with tiered pricing', () {
      final product = Product(
        id: 'prod1',
        sku: 'SKU001',
        name: 'Test Product',
        nameBn: 'পরীক্ষা পণ্য',
        description: 'A test product',
        descriptionBn: 'একটি পরীক্ষামূলক পণ্য',
        price: 100.0,
        purchasePrice: 50.0,
        wholesalePrice: 80.0,
        minWholesaleQty: 10,
        tieredPrices: {
          '10': 80.0,
          '50': 75.0,
          '100': 70.0,
        },
        stock: 500,
        unit: 'piece',
        unitBn: 'টুকরা',
        imageUrl: 'https://example.com/product.jpg',
        imageUrls: [],
        categoryId: 'cat1',
        categoryName: 'Category 1',
        categoryNameBn: 'ক্যাটেগরি ১',
        subCategoryId: 'subcat1',
        subCategoryName: 'Subcategory 1',
        subCategoryNameBn: 'উপ-ক্যাটেগরি ১',
        shopName: 'Test Shop',
        addedBy: 'user1',
        brand: 'Brand A',
        tags: [],
        isNewArrival: false,
        comboProductIds: [],
        variants: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.wholesalePrice, equals(80.0));
      expect(product.minWholesaleQty, equals(10));
      expect(product.tieredPrices['50'], equals(75.0));
    });

    test('Product with variants', () {
      final variants = [
        Variant(
          id: 'var1',
          name: 'Red',
          nameBn: 'লাল',
          price: 100.0,
          stock: 50,
        ),
        Variant(
          id: 'var2',
          name: 'Blue',
          nameBn: 'নীল',
          price: 100.0,
          stock: 75,
        ),
      ];

      final product = Product(
        id: 'prod1',
        sku: 'SKU001',
        name: 'T-Shirt',
        nameBn: 'টি-শার্ট',
        description: 'A colored t-shirt',
        descriptionBn: 'একটি রঙিন টি-শার্ট',
        price: 100.0,
        purchasePrice: 50.0,
        stock: 125,
        unit: 'piece',
        unitBn: 'টুকরা',
        imageUrl: 'https://example.com/product.jpg',
        imageUrls: [],
        categoryId: 'cat1',
        categoryName: 'Clothing',
        categoryNameBn: 'পোশাক',
        subCategoryId: 'subcat1',
        subCategoryName: 'T-Shirts',
        subCategoryNameBn: 'টি-শার্ট',
        shopName: 'Test Shop',
        addedBy: 'user1',
        brand: 'Brand A',
        tags: ['clothing', 'casual'],
        isNewArrival: false,
        comboProductIds: [],
        variants: variants,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.variants.length, equals(2));
      expect(product.variants[0].name, equals('Red'));
      expect(product.variants[1].stock, equals(75));
    });

    test('Product FilterType enum', () {
      expect(ProductFilterType.all.toString(), contains('all'));
      expect(ProductFilterType.category.toString(), contains('category'));
      expect(ProductFilterType.flashSale.toString(), contains('flashSale'));
    });

    test('Product AI fields', () {
      final product = Product(
        id: 'prod1',
        sku: 'SKU001',
        name: 'Test Product',
        nameBn: 'পরীক্ষা পণ্য',
        description: 'A test product',
        descriptionBn: 'একটি পরীক্ষামূলক পণ্য',
        price: 500.0,
        purchasePrice: 300.0,
        stock: 100,
        unit: 'piece',
        unitBn: 'টুকরা',
        imageUrl: 'https://example.com/product.jpg',
        imageUrls: [],
        categoryId: 'cat1',
        categoryName: 'Category 1',
        categoryNameBn: 'ক্যাটেগরি ১',
        subCategoryId: 'subcat1',
        subCategoryName: 'Subcategory 1',
        subCategoryNameBn: 'উপ-ক্যাটেগরি ১',
        shopName: 'Test Shop',
        addedBy: 'user1',
        brand: 'Brand A',
        tags: [],
        isNewArrival: false,
        comboProductIds: [],
        variants: [],
        rating: 4.5,
        salesCount: 100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        aiOptimized: true,
      );

      expect(product.aiOptimized, isTrue);
      expect(product.aiAuditPending, isFalse);
    });
  });
}
