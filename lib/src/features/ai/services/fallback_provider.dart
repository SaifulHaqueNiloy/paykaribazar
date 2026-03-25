import 'package:flutter/material.dart';
import 'ai_provider.dart';
import '../domain/ai_work_type.dart';

/// Fallback AI Provider - Used when primary AI provider is unavailable
/// Provides basic responses using pattern matching and predefined templates
class FallbackProvider implements AIProvider {
  @override
  String get name => 'Fallback (Offline)';

  @override
  Future<bool> healthCheck() async {
    // Fallback provider is always "healthy" as it works offline
    return true;
  }

  @override
  Future<String> generate(String prompt, {AiWorkType? type}) async {
    try {
      debugPrint('🔄 [FallbackProvider] Using fallback mode for work type: $type');
      
      final promptLower = prompt.toLowerCase();
      
      // Category: pricing
      if (type == AiWorkType.pricing || promptLower.contains('price') || promptLower.contains('discount')) {
        return _generatePricingResponse(prompt);
      }
      
      // Category: productDescription
      if (type == AiWorkType.productDescription || promptLower.contains('describe') || promptLower.contains('description')) {
        return _generateProductDescription(prompt);
      }
      
      // Category: theme
      if (type == AiWorkType.theme || promptLower.contains('theme') || promptLower.contains('design')) {
        return _generateThemeResponse(prompt);
      }
      
      // Category: notification
      if (type == AiWorkType.notification || promptLower.contains('notify') || promptLower.contains('message')) {
        return _generateNotificationResponse(prompt);
      }
      
      // Category: dashboardInsight
      if (type == AiWorkType.dashboardInsight || promptLower.contains('insight') || promptLower.contains('analytics')) {
        return _generateDashboardInsight(prompt);
      }
      
      // Default fallback response
      return _generateGenericResponse(prompt);
    } catch (e) {
      debugPrint('❌ [FallbackProvider] Error: $e');
      return 'System is in offline mode. Please check your internet connection.';
    }
  }

  @override
  Stream<String> generateStream(String prompt, {AiWorkType? type}) async* {
    final response = await generate(prompt, type: type);
    
    // Stream character by character for better UX
    for (int i = 0; i < response.length; i++) {
      yield response.substring(0, i + 1);
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  String _generatePricingResponse(String prompt) {
    if (prompt.toLowerCase().contains('discount')) {
      return 'Recommended Discount Strategy:\n'
          '• Apply 5-10% for bulk orders\n'
          '• Offer seasonal discounts (10-15%)\n'
          '• Implement loyalty-based discounts\n'
          '• Consider flash sales (20-30% limited time)\n'
          'Note: Running in offline mode. Connect for AI-powered pricing optimization.';
    }
    if (prompt.toLowerCase().contains('wholesale')) {
      return 'Wholesale Pricing Guidelines:\n'
          '• Bulk Order (10-50 units): 10-15% discount\n'
          '• Medium Order (50-200 units): 15-25% discount\n'
          '• Large Order (200+ units): 25-35% discount\n'
          'Recommend discussing custom rates separately.\n'
          'Note: Offline suggestions. Connect for real-time pricing analysis.';
    }
    return 'Dynamic pricing recommendations are temporarily unavailable. '
        'Using default pricing model. Connect for AI-powered optimization.';
  }

  String _generateProductDescription(String prompt) {
    if (prompt.toLowerCase().contains('electronics')) {
      return 'Product Description Template:\n'
          'Premium quality electronics product with excellent durability. '
          'Features cutting-edge technology and user-friendly design. '
          'Perfect for daily use or gifting. Available in multiple colors and variants. '
          'Backed by manufacturer warranty and customer support.\n'
          'Note: Template mode active. Connect for AI-generated unique descriptions.';
    }
    if (prompt.toLowerCase().contains('fashion') || prompt.toLowerCase().contains('clothing')) {
      return 'Fashion Product Description:\n'
          'Stylish and comfortable clothing made from premium materials. '
          'Perfect for casual wear or special occasions. '
          'Available in various sizes and colors. '
          'Machine washable and durable. '
          'Latest design trends with excellent fit.\n'
          'Note: Template mode. Connect for personalized AI descriptions.';
    }
    return 'Professional product description: High-quality item with great value. '
        'Perfect for customers. Multiple options available. '
        'Verified and tested. Quality guaranteed. '
        'Note: Using template. Connect for custom AI-written descriptions.';
  }

  String _generateThemeResponse(String prompt) {
    if (prompt.toLowerCase().contains('bright') || prompt.toLowerCase().contains('light')) {
      return 'Light Theme Settings Recommended:\n'
          '• Primary Color: Light Blue (#E3F2FD)\n'
          '• Accent Color: Orange (#FF8C00)\n'
          '• Background: White (#FFFFFF)\n'
          '• Text Color: Dark Gray (#333333)\n'
          'Creates professional and clean interface.\n'
          'Note: Template suggestion. Connect for AI-customized themes.';
    }
    if (prompt.toLowerCase().contains('dark')) {
      return 'Dark Theme Settings:\n'
          '• Primary Color: Dark Blue (#1A237E)\n'
          '• Accent Color: Yellow (#FFC107)\n'
          '• Background: Very Dark Gray (#121212)\n'
          '• Text Color: White (#FFFFFF)\n'
          'Reduces eye strain and looks modern.\n'
          'Note: Template. Connect for AI theme generation.';
    }
    return 'Recommended Theme: Professional appearance with balanced colors. '
        'Ensures good user experience. '
        'Note: Basic template active. Connect for AI-optimized theming.';
  }

  String _generateNotificationResponse(String prompt) {
    if (prompt.toLowerCase().contains('order')) {
      return 'OrderNotification Template:\n'
          '📦 Your order has been confirmed!\n'
          'Order ID: #[ORDER_ID]\n'
          'Total: ৳[AMOUNT]\n'
          'Estimated Delivery: [DATE]\n'
          'Track your order in the app.\n'
          'Note: Template. Connect for AI-personalized messages.';
    }
    if (prompt.toLowerCase().contains('promotion') || prompt.toLowerCase().contains('offer')) {
      return 'Promotional Message Template:\n'
          '🎉 Special Offer Alert!\n'
          'Get [DISCOUNT]% off on [CATEGORY]\n'
          'Limited time offer - Use code: [CODE]\n'
          'Shop now and save more!\n'
          'Note: Template. Connect for AI-generated promotions.';
    }
    return 'Notification Template:\n'
        'Important update for you!\n'
        'Check your account for details.\n'
        'Note: Template mode active. Connect for AI notifications.';
  }

  String _generateDashboardInsight(String prompt) {
    return 'Dashboard Insights (Offline Mode):\n'
        '📊 Sales Performance:\n'
        '• Monitor daily/weekly trends\n'
        '• Track top-selling products\n'
        '• Analyze customer behavior\n\n'
        '👥 Customer Metrics:\n'
        '• Track new vs returning customers\n'
        '• Monitor customer satisfaction\n'
        '• Analyze purchase patterns\n\n'
        'Note: Detailed analytics available when connected to AI engine.';
  }

  String _generateGenericResponse(String prompt) {
    return 'System Response (Offline Mode):\n'
        'AI processing is temporarily unavailable due to connectivity issues.\n\n'
        'Your Request: "$prompt"\n\n'
        'Please ensure you have a stable internet connection for full AI features.\n'
        'Once connected, our AI will provide optimized recommendations.\n\n'
        'Tip: Many features work offline with basic templates and suggestions.';
  }
}
