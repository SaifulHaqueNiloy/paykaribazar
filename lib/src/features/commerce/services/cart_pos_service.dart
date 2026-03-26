import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';
import '../../../services/business_config_service.dart';

class CartPosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BusinessConfigService _config = BusinessConfigService();

  CartPosService();

  Future<void> initialize() async {
    // Initialization logic if needed
  }

  /// Creates bulk order for wholesale/reseller operations
  Future<String> createBulkOrder({
    required String resellerId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentTerms, // 'cash', 'credit_30', 'credit_60'
  }) async {
    try {
      final orderData = {
        'resellerUid': resellerId,
        'items': items,
        'totalAmount': totalAmount,
        'orderType': 'bulk',
        'paymentTerms': paymentTerms,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isEmergency': false,
      };

      final docRef =
          await _db.collection('${HubPaths.orders}_bulk').add(orderData);

      // Update order ID in document
      await docRef.update({'id': docRef.id});

      // Log bulk order analytics
      await _db.collection('analytics').doc('bulk_orders').set({
        resellerId: {
          'totalBulkOrders': FieldValue.increment(1),
          'totalBulkValue': FieldValue.increment(totalAmount),
          'lastBulkOrderAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Applies wholesale discount based on quantity
  Future<Map<String, dynamic>> calculateWholesaleDiscount({
    required List<Map<String, dynamic>> items,
  }) async {
    double totalQuantity = 0;
    double totalPrice = 0;

    for (var item in items) {
      totalQuantity += (item['quantity'] as int?) ?? 0;
      totalPrice += ((item['price'] as num?) ?? 0).toDouble() *
          ((item['quantity'] as int?) ?? 1);
    }

    // Dynamic wholesale discounts from Firestore
    final Map<String, double> tiers =
        BusinessConfigService.getWholesaleTiers(
      rules: {
        'wholesale_tiers':
            await _config.getRule<Map<String, dynamic>>('wholesale_tiers'),
      },
    );
    
    double discountPercent = 0.0;
    
    // Sort keys to ensure we check from highest to lowest quantity
    final sortedKeys = tiers.keys.map(int.parse).toList()
      ..sort((a, b) => b.compareTo(a));
    
    for (var qtyThreshold in sortedKeys) {
      if (totalQuantity >= qtyThreshold) {
        discountPercent = tiers[qtyThreshold.toString()] ?? 0.0;
        break;
      }
    }

    final double discountAmount = (totalPrice * discountPercent) / 100;

    return {
      'totalQuantity': totalQuantity,
      'originalPrice': totalPrice,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'finalPrice': totalPrice - discountAmount,
    };
  }

  /// Gets POS-specific inventory view for quick reordering
  Future<List<Map<String, dynamic>>> getPOSInventory({
    required String shopId,
  }) async {
    try {
      final snap = await _db
          .collection(HubPaths.products)
          .where('shopId', isEqualTo: shopId)
          .where('stock', isGreaterThan: 0)
          .get();

      return snap.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'sku': doc['sku'],
                'price': doc['price'],
                'wholesalePrice': doc['wholesalePrice'],
                'stock': doc['stock'],
                'imageUrl': doc['imageUrl'],
              })
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Creates quick order from template/favorites
  Future<String> createQuickOrder({
    required String resellerId,
    required String templateId,
  }) async {
    try {
      final template = await _db
          .collection('${HubPaths.users}_templates')
          .doc(templateId)
          .get();

      if (!template.exists) {
        throw Exception('Template not found');
      }

      final items = template['items'] ?? [];
      final totalAmount = template['totalAmount'] ?? 0.0;

      return await createBulkOrder(
        resellerId: resellerId,
        items: List<Map<String, dynamic>>.from(items),
        totalAmount: totalAmount,
        paymentTerms: template['paymentTerms'] ?? 'cash',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Saves order as template for reuse
  Future<String> saveOrderAsTemplate({
    required String resellerId,
    required String orderName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentTerms,
  }) async {
    try {
      final docRef = await _db
          .collection('${HubPaths.users}_templates')
          .add({
            'resellerId': resellerId,
            'orderName': orderName,
            'items': items,
            'totalAmount': totalAmount,
            'paymentTerms': paymentTerms,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Gets order templates for reseller
  Stream<List<Map<String, dynamic>>> getOrderTemplates(String resellerId) {
    return _db
        .collection('${HubPaths.users}_templates')
        .where('resellerId', isEqualTo: resellerId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Updates bulk order status
  Future<void> updateBulkOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _db.collection('${HubPaths.orders}_bulk').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Gets bulk order history for analytics
  Stream<List<Map<String, dynamic>>> getBulkOrderHistory(String resellerId) {
    return _db
        .collection('${HubPaths.orders}_bulk')
        .where('resellerUid', isEqualTo: resellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
