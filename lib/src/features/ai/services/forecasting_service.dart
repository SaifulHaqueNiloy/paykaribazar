import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/service_locator.dart';
import 'ai_service.dart';

class ForecastingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AIService _ai = getIt<AIService>();

  ForecastingService();

  /// Predicts which products need restocking based on sales velocity
  Future<String> predictRestockNeed() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final salesSnap = await _db.collection('orders')
          .where('createdAt', isGreaterThan: thirtyDaysAgo)
          .get();

      final productsSnap = await _db.collection('products').get();
      
      final salesData = salesSnap.docs.map((d) => d.data()).toList();
      final inventoryData = productsSnap.docs.map((d) => {
        'id': d.id,
        'name': d.data()['name'],
        'stock': d.data()['stockQuantity'] ?? 0,
      }).toList();

      final prompt = '''
      Analyze e-commerce data and predict restock needs.
      Sales (30d): ${salesData.length} orders.
      Inventory: $inventoryData
      ''';

      return await _ai.generateResponse(prompt);
    } catch (e) {
      return 'ফোরকাস্টিং ডেটা প্রসেস করতে সমস্যা হচ্ছে।';
    }
  }
}

final forecastingServiceProvider = Provider((ref) => ForecastingService());
