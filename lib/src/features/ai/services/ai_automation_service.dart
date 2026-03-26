import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../di/service_locator.dart';
import 'ai_service.dart';
import 'api_quota_service.dart';
import '../../../core/constants/paths.dart';

class AiAutomationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AIService _ai = getIt<AIService>();
  final ApiQuotaService _quota = getIt<ApiQuotaService>();

  /// Runs background caching using leftover quota
  Future<void> runNightlyAIOptimization() async {
    try {
      // 1. Check if we have enough leftover quota (e.g., > 30%)
      final providers = ['kimi', 'deepseek', 'gemini'];
      bool hasSpareQuota = false;
      for (var p in providers) {
        if (await _quota.hasQuota(p)) {
          hasSpareQuota = true;
          break;
        }
      }

      if (!hasSpareQuota) return;

      // 2. Identify products without AI descriptions or tags
      final productsSnap = await _db.collection(HubPaths.products)
          .where('ai_processed', isEqualTo: false)
          .limit(10)
          .get();

      for (var doc in productsSnap.docs) {
        final data = doc.data();
        final prompt = "Generate SEO tags and a professional Bengali description for: ${data['name']}";
        
        // This will automatically update the AICacheService
        await _ai.generateResponse(prompt);
        
        await doc.reference.update({'ai_processed': true});
      }
      // AI Background Caching Task Completed
    } catch (e) {
      // AI Caching Error handled silently
    }
  }

  /// Perform a system-wide health check for AI services
  Future<Map<String, dynamic>> performGlobalSystemCheck() async {
    return await _ai.performGlobalSystemCheck();
  }

  /// Main entry point for scheduled automation tasks
  Future<void> checkAndRun() async {
    final check = await performGlobalSystemCheck();
    if (check['status'] == 'healthy') {
      await _db.collection('ai_audit_logs').add({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
        'message': 'Automated system check completed successfully.',
        'details': check,
      });
      
      // Also run nightly optimization if conditions met
      await runNightlyAIOptimization();
    }
  }

  /// Stream of AI audit logs
  Stream<List<Map<String, dynamic>>> getAuditLogs() {
    return _db.collection('ai_audit_logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
