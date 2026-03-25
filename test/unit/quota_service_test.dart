import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/features/ai/services/api_quota_service.dart';

@GenerateMocks([FirebaseFirestore, CollectionReference, DocumentReference, DocumentSnapshot, QuerySnapshot, QueryDocumentSnapshot, WriteBatch])
import 'quota_service_test.mocks.dart';

void main() {
  late ApiQuotaService quotaService;
  late MockFirebaseFirestore mockDb;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDoc;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;

  setUp(() {
    mockDb = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDoc = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();
    
    // We can't easily mock the internal instance since it's hardcoded in ApiQuotaService.
    // In a real project, we should inject Firestore via constructor for testability.
    // For now, we'll test the non-firebase logic.
    quotaService = ApiQuotaService();
  });

  group('ApiQuotaService Unit Tests', () {
    test('Provider Key Normalization', () {
      expect(quotaService.normalizeProviderKey('Gemini-2.0'), equals('gemini'));
      expect(quotaService.normalizeProviderKey('Kimi-k2.5'), equals('kimi'));
      expect(quotaService.normalizeProviderKey('DeepSeek-V3'), equals('deepseek'));
      expect(quotaService.normalizeProviderKey('NVIDIA'), equals('kimi'));
    });

    test('QuotaData Model Logic', () {
      final now = DateTime.now();
      final quota = QuotaData(
        provider: 'gemini',
        keyId: 'key_1',
        dailyLimit: 1000,
        usedToday: 450,
        hourlyUsage: List.filled(24, 0),
        status: 'active',
        lastReset: now,
      );

      expect(quota.hasAvailableQuota, isTrue);
      expect(quota.remaining, equals(550));
      expect(quota.usagePercentage, equals(45.0));
    });

    test('Exhausted status blocks quota', () {
      final quota = QuotaData(
        provider: 'kimi',
        keyId: 'key_1',
        dailyLimit: 1000,
        usedToday: 100, // Limit not reached but status is manual
        hourlyUsage: List.filled(24, 0),
        status: 'exhausted',
        lastReset: DateTime.now(),
      );

      expect(quota.hasAvailableQuota, isFalse);
    });
  });
}
