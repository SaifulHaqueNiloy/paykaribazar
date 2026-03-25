import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';
import '../../../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _firestore.collection(HubPaths.products).snapshots().map(
      (snap) => snap.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<Product>> searchProducts(String query) {
    // Basic implementation, usually filtered in UI or via Algolia/Elasticsearch for scale
    return getProducts().map((products) => 
      products.where((p) => p.matchesSearch(query)).toList());
  }

  Stream<List<Product>> filterByCategory(String categoryId) {
    return _firestore.collection(HubPaths.products)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    await _firestore.collection(HubPaths.products).doc(productId).update({
      'stock': newStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
