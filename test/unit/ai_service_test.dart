import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/features/ai/services/ai_service.dart';
import 'package:paykari_bazar/src/features/ai/services/ai_provider.dart';
import 'package:paykari_bazar/src/core/firebase/firestore_service.dart';
import 'package:paykari_bazar/src/core/services/secrets_service.dart';
import 'package:paykari_bazar/src/features/ai/domain/ai_work_type.dart';

class MockFirestoreService extends Mock implements FirestoreService {}
class MockSecretsService extends Mock implements SecretsService {}
class MockAIProvider extends Mock implements AIProvider {}

void main() {
  late AIService aiService;
  late MockFirestoreService mockFirestore;
  late MockSecretsService mockSecrets;
  late MockAIProvider mockKimi;
  late MockAIProvider mockDeepSeek;
  late MockAIProvider mockGemini;

  setUpAll(() {
    registerFallbackValue(AiWorkType.generic);
  });

  setUp(() {
    mockFirestore = MockFirestoreService();
    mockSecrets = MockSecretsService();
    mockKimi = MockAIProvider();
    mockDeepSeek = MockAIProvider();
    mockGemini = MockAIProvider();

    when(() => mockKimi.name).thenReturn('Kimi');
    when(() => mockDeepSeek.name).thenReturn('DeepSeek');
    when(() => mockGemini.name).thenReturn('Gemini');

    aiService = AIService(
      firestore: mockFirestore,
      secrets: mockSecrets,
      mockProviders: [mockKimi, mockDeepSeek, mockGemini],
    );
  });

  group('AIService Unit Tests (Sovereign Routing)', () {
    test('Router Logic: Uses Kimi as Primary when healthy', () async {
      when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);
      when(() => mockKimi.generate(any(), type: any(named: 'type')))
          .thenAnswer((_) async => 'Response from Kimi');

      final result = await aiService.generateResponse('Hello AI', useCache: false);

      expect(result, equals('Response from Kimi'));
      verify(() => mockKimi.generate(any(), type: any(named: 'type'))).called(1);
      verifyNever(() => mockDeepSeek.generate(any(), type: any(named: 'type')));
    });

    test('Router Logic: Falls back to DeepSeek when Kimi is unhealthy', () async {
      when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
      when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);
      when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
          .thenAnswer((_) async => 'Response from DeepSeek');

      final result = await aiService.generateResponse('Hello AI', useCache: false);

      expect(result, equals('Response from DeepSeek'));
      verify(() => mockKimi.healthCheck()).called(1);
      verify(() => mockDeepSeek.generate(any(), type: any(named: 'type'))).called(1);
    });
  });
}
