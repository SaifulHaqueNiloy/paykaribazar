import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/service_locator.dart';
import 'ai_service.dart';

class VoiceCommerceService {
  final AIService _ai = getIt<AIService>();

  /// Interprets a natural language command in Bengali or English
  /// and returns a structured action for the app to execute.
  Future<Map<String, dynamic>> interpretCommand(String transcript) async {
    final prompt = """
    You are 'Voice Bazar' assistant for Paykari Bazar app.
    Interpret this user command: "$transcript"
    
    Supported Actions:
    1. ADD_TO_CART: {"action": "ADD_TO_CART", "product": "name", "qty": 1}
    2. REMOVE_FROM_CART: {"action": "REMOVE_FROM_CART", "product": "name"}
    3. SEARCH: {"action": "SEARCH", "query": "product name"}
    4. CHECKOUT: {"action": "CHECKOUT"}
    5. TRACK_ORDER: {"action": "TRACK_ORDER"}
    6. NAVIGATE: {"action": "NAVIGATE", "target": "home/profile/cart/wishlist"}
    
    Return ONLY a JSON object. If unknown, return {"action": "UNKNOWN", "message": "Bengali error message"}.
    Command context: E-commerce shopping.
    """;

    try {
      final response = await _ai.generateResponse(prompt, useCache: false);
      final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(clean);
    } catch (e) {
      return {"action": "UNKNOWN", "message": "দুঃখিত, আমি বুঝতে পারিনি। আবার বলুন।"};
    }
  }

  /// Executes the interpreted action using app providers
  Future<void> executeAction(BuildContext context, WidgetRef ref, Map<String, dynamic> data) async {
    final action = data['action'];
    
    switch (action) {
      case 'SEARCH':
        final query = data['query'] ?? '';
        // Navigate to search screen with query
        break;
      case 'ADD_TO_CART':
        final productName = data['product'] ?? '';
        // Logic to find product and add to cart
        _showFeedback(context, '$productName কার্টে যোগ করা হয়েছে।');
        break;
      case 'CHECKOUT':
        // Show checkout bottom sheet
        break;
      case 'NAVIGATE':
        final target = data['target'] ?? 'home';
        // Navigate
        break;
      default:
        _showFeedback(context, data['message'] ?? 'আমি দুঃখিত, কাজটি করতে পারছি না।');
    }
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'HindSiliguri')),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
