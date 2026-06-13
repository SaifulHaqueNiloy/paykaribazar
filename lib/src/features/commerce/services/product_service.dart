import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';
import '../../../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProducts() {
    return _firestore.collection(HubPaths.products).snapshots().map(
      (snap) => snap.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList());
  }

  /// DNA ENFORCED: Paginated fetching to optimize performance and reduce Firestore reads
  /// বাংলা: ডাটাবেস রিড কমাতে এবং পারফরম্যান্স বাড়াতে প্যাগিনেশন ব্যবহার করা হয়েছে
  Future<QuerySnapshot<Map<String, dynamic>>> getProductsPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 10,
    String? categoryId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(HubPaths.products)
        .orderBy('createdAt', descending: true);

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.limit(limit).get();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _firestore.collection(HubPaths.products).doc(id).get();
    if (doc.exists) {
      return Product.fromMap(doc.data()!, doc.id);
    }
    return null;
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
