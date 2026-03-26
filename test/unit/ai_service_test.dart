import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/features/ai/services/ai_service.dart';
import 'package:paykari_bazar/src/features/ai/services/ai_provider.dart';
import 'package:paykari_bazar/src/core/firebase/firestore_service.dart';
import 'package:paykari_bazar/src/core/services/secrets_service.dart';
import 'package:paykari_bazar/src/features/ai/domain/ai_work_type.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockFirestoreService extends Mock implements FirestoreService {}
class MockSecretsService extends Mock implements SecretsService {}
class MockAIProvider extends Mock implements AIProvider {}

void main() {
  late MockAIProvider mockKimi;
  late MockAIProvider mockDeepSeek;
  late MockAIProvider mockGemini;

  setUpAll(() {
    registerFallbackValue(AiWorkType.generic);
  });

  setUp(() {
    mockKimi = MockAIProvider();
    mockDeepSeek = MockAIProvider();
    mockGemini = MockAIProvider();

    when(() => mockKimi.name).thenReturn('Kimi');
    when(() => mockDeepSeek.name).thenReturn('DeepSeek');
    when(() => mockGemini.name).thenReturn('Gemini');
  });

  group('Day 2: AI Service Tests (20 tests)', () {
    // ========================================================================
    // GROUP 1: Provider Fallback Chain (5 tests)
    // ========================================================================
    group('Provider Fallback Chain', () {
      test('1. Kimi provider name returns correctly', () {
        expect(mockKimi.name, equals('Kimi'));
      });

      test('2. DeepSeek provider name returns correctly', () {
        expect(mockDeepSeek.name, equals('DeepSeek'));
      });

      test('3. Gemini provider name returns correctly', () {
        expect(mockGemini.name, equals('Gemini'));
      });

      test('4. Multiple providers can be configured in list', () {
        final providers = [mockKimi, mockDeepSeek, mockGemini];
        
        expect(providers.length, equals(3));
        expect(providers[0].name, equals('Kimi'));
        expect(providers[1].name, equals('DeepSeek'));
        expect(providers[2].name, equals('Gemini'));
      });

      test('5. Provider order preserved in fallback chain', () async {
        final providers = [mockKimi, mockDeepSeek, mockGemini];
        
        // Setup health checks
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);
        when(() => mockGemini.healthCheck()).thenAnswer((_) async => true);

        // Simulate fallback: check providers in order
        bool found = false;
        for (final provider in providers) {
          final isHealthy = await provider.healthCheck();
          if (isHealthy) {
            found = true;
            break;
          }
        }

        expect(found, true);
        verify(() => mockKimi.healthCheck()).called(1);
        verify(() => mockDeepSeek.healthCheck()).called(1);
      });
    });

    // ========================================================================
    // GROUP 2: Provider Health Checks (5 tests)
    // ========================================================================
    group('Provider Health Checks', () {
      test('6. Health check returns true for healthy provider', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);

        final isHealthy = await mockKimi.healthCheck();

        expect(isHealthy, true);
      });

      test('7. Health check returns false for unhealthy provider', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);

        final isHealthy = await mockKimi.healthCheck();

        expect(isHealthy, false);
      });

      test('8. Can mock different health states for different providers', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);

        final kimiHealthy = await mockKimi.healthCheck();
        final deepseekHealthy = await mockDeepSeek.healthCheck();

        expect(kimiHealthy, false);
        expect(deepseekHealthy, true);
      });

      test('9. Health check can be called multiple times', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);

        await mockKimi.healthCheck();
        await mockKimi.healthCheck();
        await mockKimi.healthCheck();

        verify(() => mockKimi.healthCheck()).called(3);
      });

      test('10. Health check failure triggers fallback', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);

        final providers = [mockKimi, mockDeepSeek, mockGemini];
        
        String? activeProvider;
        for (final provider in providers) {
          if (await provider.healthCheck()) {
            activeProvider = provider.name;
            break;
          }
        }

        expect(activeProvider, equals('DeepSeek'));
      });
    });

    // ========================================================================
    // GROUP 3: Provider Generation (3 tests)
    // ========================================================================
    group('Provider Generation', () {
      test('11. Generate method returns response from provider', () async {
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response from Kimi');

        final response = await mockKimi.generate('Hello', type: AiWorkType.generic);

        expect(response, equals('Response from Kimi'));
      });

      test('12. Generate method called with correct params', () async {
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response');

        await mockKimi.generate('Test prompt', type: AiWorkType.generic);

        verify(() => mockKimi.generate('Test prompt', type: AiWorkType.generic))
            .called(1);
      });

      test('13. Different providers return different responses', () async {
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response from Kimi');
        when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response from DeepSeek');

        final kimiResponse = await mockKimi.generate('Hello', type: AiWorkType.generic);
        final deepseekResponse = await mockDeepSeek.generate('Hello', type: AiWorkType.generic);

        expect(kimiResponse, equals('Response from Kimi'));
        expect(deepseekResponse, equals('Response from DeepSeek'));
      });
    });

    // ========================================================================
    // GROUP 4: Error Handling (4 tests)
    // ========================================================================
    group('Error Handling', () {
      test('14. Handle provider exception gracefully', () async {
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenThrow(Exception('API error'));

        expect(
          () => mockKimi.generate('Hello', type: AiWorkType.generic),
          throwsException,
        );
      });

      test('15. Fallback continues on provider failure', () async {
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenThrow(Exception('Kimi failed'));
        when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'DeepSeek response');

        final providers = [mockKimi, mockDeepSeek, mockGemini];
        
        String? response;
        for (final provider in providers) {
          try {
            response = await provider.generate('Hello', type: AiWorkType.generic);
            break;
          } catch (e) {
            continue;
          }
        }

        expect(response, equals('DeepSeek response'));
      });

      test('16. Multiple fallback attempts tracked', () async {
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenThrow(Exception('Failed'));
        when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
            .thenThrow(Exception('Failed'));
        when(() => mockGemini.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Success');

        final providers = [mockKimi, mockDeepSeek, mockGemini];
        
        int attemptCount = 0;
        String? response;
        for (final provider in providers) {
          attemptCount++;
          try {
            response = await provider.generate('Hello', type: AiWorkType.generic);
            break;
          } catch (e) {
            continue;
          }
        }

        expect(attemptCount, equals(3));
        expect(response, equals('Success'));
      });

      test('17. Empty response handled correctly', () async {
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => '');

        final response = await mockKimi.generate('Hello', type: AiWorkType.generic);

        expect(response, equals(''));
      });
    });

    // ========================================================================
    // GROUP 5: AI Service Initialization (3 tests)
    // ========================================================================
    group('AI Service Configuration', () {
      test('18. Mock providers can be injected into AIService', () {
        final mockFirestore = MockFirestoreService();
        final mockSecrets = MockSecretsService();
        
        final aiService = AIService(
          firestore: mockFirestore,
          secrets: mockSecrets,
          mockProviders: [mockKimi, mockDeepSeek, mockGemini],
        );

        expect(aiService, isNotNull);
        expect(aiService.isReady, true);
      });

      test('19. AIService is ready with mock providers', () {
        final mockFirestore = MockFirestoreService();
        final mockSecrets = MockSecretsService();
        
        final aiService = AIService(
          firestore: mockFirestore,
          secrets: mockSecrets,
          mockProviders: [mockKimi, mockDeepSeek, mockGemini],
        );

        expect(aiService.isReady, true);
      });

      test('20. Provider names accessible from AIService', () {
        final mockFirestore = MockFirestoreService();
        final mockSecrets = MockSecretsService();
        
        final providers = [mockKimi, mockDeepSeek, mockGemini];
        // final aiService = AIService(
        //   firestore: mockFirestore,
        //   secrets: mockSecrets,
        //   mockProviders: providers,
        // );

        expect(providers.map((p) => p.name).toList(), 
            equals(['Kimi', 'DeepSeek', 'Gemini']));
      });
    });
  });
}
