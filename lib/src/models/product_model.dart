import 'package:cloud_firestore/cloud_firestore.dart';

// DNA VERIFIED VERSION 11 - ADDED MISSING GETTERS
class Variant {
  final String id;
  final String name;
  final String nameBn;
  final double price;
  final int stock;

  Variant({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.price,
    required this.stock,
  });

  factory Variant.fromMap(Map<String, dynamic> map) {
    return Variant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameBn: map['nameBn'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameBn': nameBn,
      'price': price,
      'stock': stock,
    };
  }
}

enum ProductFilterType { all, category, flashSale, newArrivals, offers, featured }

class Product {
  final String id;
  final String sku;
  final String name;
  final String nameBn;
  final String description;
  final String descriptionBn;
  final double price;
  final double oldPrice;
  final double purchasePrice;
  final double? wholesalePrice;
  final int? minWholesaleQty;
  final Map<String, double> tieredPrices;
  final int stock;
  final String unit;
  final String unitBn;
  final String imageUrl; 
  final List<String> imageUrls;
  final String? marketingBannerUrl; 
  final String categoryId;
  final String categoryName;
  final String categoryNameBn;
  final String subCategoryId;
  final String subCategoryName;
  final String subCategoryNameBn;
  final String shopName;
  final String addedBy; 
  final String brand;
  final List<String> tags;
  final bool isFlashSale;
  final bool isCombo;
  final bool isNewArrival;
  final bool isFeatured;
  final bool isHotSelling; // ADDED
  final bool isComboPack; // ADDED
  final List<String> comboProductIds;
  final List<Variant> variants;
  final double rating;
  final int salesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // AI DNA FIELDS
  final bool aiOptimized;
  final bool aiAuditPending;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.nameBn,
    required this.description,
    required this.descriptionBn,
    required this.price,
    this.oldPrice = 0,
    this.purchasePrice = 0,
    this.wholesalePrice,
    this.minWholesaleQty,
    this.tieredPrices = const {},
    required this.stock,
    required this.unit,
    required this.unitBn,
    required this.imageUrl,
    this.imageUrls = const [],
    this.marketingBannerUrl,
    required this.categoryId,
    required this.categoryName,
    this.categoryNameBn = '',
    this.subCategoryId = '',
    this.subCategoryName = '',
    this.subCategoryNameBn = '',
    this.shopName = 'General',
    this.addedBy = '',
    this.brand = '',
    this.tags = const [],
    this.isFlashSale = false,
    this.isCombo = false,
    this.isNewArrival = true,
    this.isFeatured = false,
    this.isHotSelling = false, // ADDED
    this.isComboPack = false, // ADDED
    this.comboProductIds = const [],
    this.variants = const [],
    this.rating = 0.0,
    this.salesCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.aiOptimized = false,
    this.aiAuditPending = false,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    final List<String> imgs = List<String>.from(map['imageUrls'] ?? []);
    final String primaryImg = map['imageUrl'] ?? (imgs.isNotEmpty ? imgs.first : '');
    
    final Map<String, double> tiered = {};
    if (map['tieredPrices'] != null) {
      (map['tieredPrices'] as Map).forEach((k, v) {
        tiered[k.toString()] = (v as num).toDouble();
      });
    }

    return Product(
      id: id,
      sku: map['sku'] ?? '',
      name: map['name'] ?? '',
      nameBn: map['nameBn'] ?? '',
      description: map['description'] ?? '',
      descriptionBn: map['descriptionBn'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      oldPrice: (map['oldPrice'] ?? 0.0).toDouble(),
      purchasePrice: (map['purchasePrice'] ?? 0.0).toDouble(),
      wholesalePrice: map['wholesalePrice'] != null ? (map['wholesalePrice'] as num).toDouble() : null,
      minWholesaleQty: map['minWholesaleQty'] != null ? (map['minWholesaleQty'] as num).toInt() : null,
      tieredPrices: tiered,
      stock: (map['stock'] ?? 0).toInt(),
      unit: map['unit'] ?? 'pcs',
      unitBn: map['unitBn'] ?? 'পিস',
      imageUrl: primaryImg,
      imageUrls: imgs,
      marketingBannerUrl: map['marketingBannerUrl'],
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      categoryNameBn: map['categoryNameBn'] ?? '',
      subCategoryId: map['subCategoryId'] ?? '',
      subCategoryName: map['subCategoryName'] ?? '',
      subCategoryNameBn: map['subCategoryNameBn'] ?? '',
      shopName: map['shopName'] ?? 'General',
      addedBy: map['addedBy'] ?? '',
      brand: map['brand'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isFlashSale: map['isFlashSale'] ?? false,
      isCombo: map['isCombo'] ?? false,
      isNewArrival: map['isNewArrival'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      isHotSelling: map['isHotSelling'] ?? false, // ADDED
      isComboPack: map['isComboPack'] ?? false, // ADDED
      comboProductIds: List<String>.from(map['comboProductIds'] ?? []),
      variants: (map['variants'] as List? ?? []).map((v) => Variant.fromMap(Map<String, dynamic>.from(v))).toList(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      salesCount: (map['salesCount'] ?? 0).toInt(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      aiOptimized: map['aiOptimized'] ?? false,
      aiAuditPending: map['aiAuditPending'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'nameBn': nameBn,
      'description': description,
      'descriptionBn': descriptionBn,
      'price': price,
      'oldPrice': oldPrice,
      'purchasePrice': purchasePrice,
      'wholesalePrice': wholesalePrice,
      'minWholesaleQty': minWholesaleQty,
      'tieredPrices': tieredPrices,
      'stock': stock,
      'unit': unit,
      'unitBn': unitBn,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'marketingBannerUrl': marketingBannerUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryNameBn': categoryNameBn,
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'subCategoryNameBn': subCategoryNameBn,
      'shopName': shopName,
      'addedBy': addedBy,
      'brand': brand,
      'tags': tags,
      'isFlashSale': isFlashSale,
      'isCombo': isCombo,
      'isNewArrival': isNewArrival,
      'isFeatured': isFeatured,
      'isHotSelling': isHotSelling, // ADDED
      'isComboPack': isComboPack, // ADDED
      'comboProductIds': comboProductIds,
      'variants': variants.map((v) => v.toMap()).toList(),
      'rating': rating,
      'salesCount': salesCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'aiOptimized': aiOptimized,
      'aiAuditPending': aiAuditPending,
    };
  }

  double getPriceForQuantity(int qty) {
    if (tieredPrices.isEmpty) return price;
    double selectedPrice = price;
    tieredPrices.forEach((range, tPrice) {
      if (range.contains('-')) {
        final parts = range.split('-');
        final start = int.tryParse(parts[0]) ?? 0;
        final end = int.tryParse(parts[1]) ?? 999999;
        if (qty >= start && qty <= end) selectedPrice = tPrice;
      } else if (range.endsWith('+')) {
        final start = int.tryParse(range.replaceAll('+', '')) ?? 0;
        if (qty >= start) selectedPrice = tPrice;
      }
    });
    return selectedPrice;
  }

  bool get hasDiscount => oldPrice > price;
  int get discountPercentage {
    if (!hasDiscount || oldPrice <= 0) return 0;
    return (((oldPrice - price) / oldPrice) * 100).round();
  }

  String getName(String lang) => lang == 'bn' ? nameBn : name;

  // RESTORED METHODS
  String getCategory(String lang) => (lang == 'bn' && categoryNameBn.isNotEmpty) ? categoryNameBn : categoryName;

  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase().trim();
    if (name.toLowerCase().contains(q)) return true;
    if (nameBn.contains(q)) return true;
    if (sku.toLowerCase().contains(q)) return true;
    if (categoryName.toLowerCase().contains(q)) return true;
    return false;
  }
}
