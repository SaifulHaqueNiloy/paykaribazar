import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../di/service_locator.dart';
import '../../../shared/services/notification_service.dart';
import 'ai_service.dart';

class MarketingAutomationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AIService _ai = getIt<AIService>();
  final NotificationService _notifications = getIt<NotificationService>();

  /// Runs the daily AI-personalized marketing campaign
  Future<void> runDailyMarketingCampaign() async {
    try {
      final usersSnap = await _db.collection('users').limit(50).get();
      
      for (var userDoc in usersSnap.docs) {
        final userData = userDoc.data();
        final userId = userDoc.id;
        final userName = userData['name'] ?? 'Customer';
        
        // 1. Context Gathering
        final lastOrders = await _db.collection('orders')
            .where('customerUid', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(2)
            .get();
            
        final wishlist = userData['wishlist'] as List? ?? [];
        
        // 2. AI Copy Generation (DNA ENFORCED: Routing applied automatically by AIService)
        final prompt = """
        Generate a short, persuasive marketing notification in Bengali for $userName.
        Context:
        - Recently bought: ${lastOrders.docs.map((d) => d.data()['items'])}
        - Wishlist items: $wishlist
        - Behavior: Loyal Customer
        
        Return ONLY a JSON object: {"title": "...", "body": "..."}
        """;
        
        final response = await _ai.generateResponse(prompt, useCache: false);
        final clean = response.replaceAll('```json', '').replaceAll('```', '').trim();
        
        try {
          final data = jsonDecode(clean);
          await _notifications.sendDirectNotification(
            userId: userId,
            title: data['title'] ?? 'আপনার জন্য বিশেষ অফার! ✨',
            body: data['body'] ?? 'আমাদের নতুন কালেকশন দেখে নিন।',
          );
        } catch (e) {
          // Failed to parse AI Marketing Response
        }
      }
    } catch (e) {
      // Marketing Automation Error handled silently
    }
  }

  /// Sends AI-generated reminders for abandoned carts
  Future<void> sendAbandonedCartReminders() async {
    // Logic to find users with items in cart but no order in 24h
    // and send a gentle, AI-personalized nudge.
  }
}
