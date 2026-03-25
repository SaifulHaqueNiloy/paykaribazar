class ProductModel {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final String? category;
  final int stock;
  final String? sku; // Added for compatibility with tests

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.category,
    this.stock = 0,
    this.sku,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'],
      imageUrl: map['imageUrl'],
      category: map['category'],
      stock: map['stock'] ?? 0,
      sku: map['sku'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'sku': sku,
    };
  }
}
