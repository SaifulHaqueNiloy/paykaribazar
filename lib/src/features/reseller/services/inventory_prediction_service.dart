import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../di/service_locator.dart';
import '../../ai/services/ai_service.dart';
import '../../../core/constants/paths.dart';

class InventoryPredictionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AIService _ai = getIt<AIService>();

  /// Analyzes stock levels and sales history to predict restock needs for a reseller
  Future<List<Map<String, dynamic>>> getRestockSuggestions(String resellerId) async {
    try {
      // 1. Fetch Reseller's specific products/inventory
      final productsSnap = await _db.collection(HubPaths.products)
          .where('resellerId', isEqualTo: resellerId)
          .get();

      // 2. Fetch Sales History for these products (Last 14 days)
      final twoWeeksAgo = DateTime.now().subtract(const Duration(days: 14));
      final salesSnap = await _db.collection(HubPaths.orders)
          .where('sellerId', isEqualTo: resellerId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(twoWeeksAgo))
          .get();

      final inventory = productsSnap.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['name'],
        'stock': doc.data()['stockQuantity'] ?? 0,
      }).toList();

      final sales = salesSnap.docs.map((doc) => doc.data()).toList();

      if (inventory.isEmpty) return [];

      // 3. AI Analysis via Multi-AI Router (DNA Routing: Kimi > DeepSeek > Gemini)
      final prompt = """
      You are 'Dokaner Bondhu' AI assistant for Paykari Bazar.
      Analyze this inventory and sales data for a small shopkeeper:
      Inventory: $inventory
      Sales (Last 14 days): ${sales.length} items sold.
      
      Predict which products will run out of stock in the next 7 days.
      Suggest restock quantities for those products.
      Return ONLY a JSON array of objects: 
      [{"productId": "...", "name": "...", "reason": "Bengali reason", "suggestedQty": 10, "urgency": "high/medium"}]
      """;

      final response = await _ai.generateResponse(prompt, useCache: false);
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return List<Map<String, dynamic>>.from(jsonDecode(clean));
    } catch (e) {
      return [];
    }
  }

  /// Generates an automated "One-Click Restock" order draft
  Future<Map<String, dynamic>> generateAutoOrderDraft(List<Map<String, dynamic>> suggestions) async {
    // Logic to prepare a bulk order draft based on AI suggestions
    return {
      'items': suggestions.map((s) => {
        'productId': s['productId'],
        'quantity': s['suggestedQty'],
      }).toList(),
      'totalSuggested': suggestions.length,
    };
  }
}
