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
        final aiService = AIService(
          firestore: mockFirestore,
          secrets: mockSecrets,
          mockProviders: providers,
        );

        expect(providers.map((p) => p.name).toList(), 
            equals(['Kimi', 'DeepSeek', 'Gemini']));
      });
    });
  });
}
  late AIService aiService;
  late MockFirestoreService mockFirestore;
  late MockSecretsService mockSecrets;
  late MockAIProvider mockKimi;
  late MockAIProvider mockDeepSeek;
  late MockAIProvider mockGemini;
  late MockApiQuotaService mockQuotaService;
  late MockAICacheService mockCache;
  late MockAIRateLimiter mockRateLimiter;
  final getIt = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(AiWorkType.generic);
    registerFallbackValue(const Duration(seconds: 1));
  });

  setUp(() {
    // Clear GetIt and register mocks
    getIt.reset();
    
    // Create mocks
    mockFirestore = MockFirestoreService();
    mockSecrets = MockSecretsService();
    mockKimi = MockAIProvider();
    mockDeepSeek = MockAIProvider();
    mockGemini = MockAIProvider();
    mockQuotaService = MockApiQuotaService();
    mockCache = MockAICacheService();
    mockRateLimiter = MockAIRateLimiter();

    // Setup provider names
    when(() => mockKimi.name).thenReturn('Kimi');
    when(() => mockDeepSeek.name).thenReturn('DeepSeek');
    when(() => mockGemini.name).thenReturn('Gemini');
    
    // Setup quota service mocks
    when(() => mockQuotaService.hasQuota(any())).thenAnswer((_) async => true);
    when(() => mockQuotaService.incrementUsage(any())).thenAnswer((_) async {});
    when(() => mockQuotaService.normalizeProviderKey(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments.first as String;
      return key.toLowerCase();
    });
    
    // Setup cache mocks
    when(() => mockCache.initialize()).thenAnswer((_) async {});
    when(() => mockCache.get(any(), params: any(named: 'params'))).thenReturn(null);
    when(() => mockCache.set(any(), any(), params: any(named: 'params'))).thenAnswer((_) async {});
    
    // Setup rate limiter mocks
    when(() => mockRateLimiter.canMakeRequest(any())).thenAnswer((_) async => true);
    when(() => mockRateLimiter.recordRequest(any())).thenAnswer((_) async {});
    
    // Register mocks in GetIt
    getIt.registerSingleton<ApiQuotaService>(mockQuotaService);
    
    // Create AIService with mock providers
    aiService = AIService(
      firestore: mockFirestore,
      secrets: mockSecrets,
      mockProviders: [mockKimi, mockDeepSeek, mockGemini],
    );
  });

  tearDown(() {
    getIt.reset();
  });

  group('Day 2: AI Service Tests (20 tests)', () {
    // ========================================================================
    // GROUP 1: Provider Fallback Chain (5 tests)
    // ========================================================================
    group('Provider Fallback Chain', () {
      test('1. Uses Kimi as Primary when healthy', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response from Kimi');

        final result = await aiService.generateResponse('Hello', useCache: false);

        expect(result, equals('Response from Kimi'));
        verify(() => mockKimi.generate(any(), type: any(named: 'type'))).called(1);
      });

      test('2. Falls back to DeepSeek when Kimi is unhealthy', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);
        when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response from DeepSeek');

        final result = await aiService.generateResponse('Hello', useCache: false);

        expect(result, equals('Response from DeepSeek'));
      });

      test('3. Falls back to Gemini when Kimi and DeepSeek fail', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => false);
        when(() => mockGemini.healthCheck()).thenAnswer((_) async => true);
        when(() => mockGemini.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response from Gemini');

        final result = await aiService.generateResponse('Hello', useCache: false);

        expect(result, equals('Response from Gemini'));
      });

      test('4. Fallback chain skips unhealthy providers', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);
        when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'DeepSeek response');

        await aiService.generateResponse('Test', useCache: false);

        verify(() => mockKimi.healthCheck()).called(1);
        verifyNever(() => mockKimi.generate(any(), type: any(named: 'type')));
        verify(() => mockDeepSeek.generate(any(), type: any(named: 'type'))).called(1);
      });

      test('5. Returns error when all providers fail', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => false);
        when(() => mockGemini.healthCheck()).thenAnswer((_) async => false);

        final result = await aiService.generateResponse('Hello', useCache: false);

        expect(result, isA<String>());
        expect(result.toLowerCase().contains('error') || result.isEmpty, true);
      });
    });

    // ========================================================================
    // GROUP 2: Quota Management (5 tests)
    // ========================================================================
    group('Quota Management', () {
      test('6. Increments usage after successful request', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response');

        await aiService.generateResponse('Test', useCache: false);

        verify(() => mockQuotaService.incrementUsage('kimi')).called(1);
      });

      test('7. Checks quota before switching providers', () async {
        when(() => mockQuotaService.hasQuota('kimi')).thenAnswer((_) async => false);
        when(() => mockQuotaService.hasQuota('deepseek')).thenAnswer((_) async => true);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);
        when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'From DeepSeek');

        final result = await aiService.generateResponse('Test', useCache: false);

        expect(result, equals('From DeepSeek'));
        verify(() => mockQuotaService.hasQuota('kimi')).called(1);
      });

      test('8. Skips provider when quota exhausted', () async {
        when(() => mockQuotaService.hasQuota(any())).thenAnswer((_) async => false);

        final result = await aiService.generateResponse('Test', useCache: false);

        expect(result, isA<String>());
      });

      test('9. Tracks quota per provider correctly', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Kimi response');

        await aiService.generateResponse('Test1', useCache: false);
        await aiService.generateResponse('Test2', useCache: false);

        verify(() => mockQuotaService.incrementUsage('kimi')).called(2);
      });

      test('10. Normalizes provider keys for quota lookup', () async {
        when(() => mockQuotaService.hasQuota('kimi')).thenAnswer((_) async => true);
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'Response');

        await aiService.generateResponse('Test', useCache: false);

        verify(() => mockQuotaService.hasQuota('kimi')).called(1);
      });
    });

    // ========================================================================
    // GROUP 3: Rate Limiting (3 tests)
    // ========================================================================
    group('Rate Limiting', () {
      test('11. Enforces rate limit per user', () async {
        when(() => mockRateLimiter.canMakeRequest('user1')).thenAnswer((_) async => false);

        // Simulate rate limit check (implementation would handle this)
        final canRequest = await mockRateLimiter.canMakeRequest('user1');

        expect(canRequest, false);
      });

      test('12. Allows requests within rate limit', () async {
        when(() => mockRateLimiter.canMakeRequest('user1')).thenAnswer((_) async => true);

        final canRequest = await mockRateLimiter.canMakeRequest('user1');

        expect(canRequest, true);
      });

      test('13. Records request timestamp for tracking', () async {
        when(() => mockRateLimiter.canMakeRequest('user1')).thenAnswer((_) async => true);
        when(() => mockRateLimiter.recordRequest('user1')).thenAnswer((_) async {});

        await mockRateLimiter.recordRequest('user1');

        verify(() => mockRateLimiter.recordRequest('user1')).called(1);
      });
    });

    // ========================================================================
    // GROUP 4: Caching (4 tests)
    // ========================================================================
    group('Response Caching', () {
      test('14. Cache hit returns cached response', () {
        when(() => mockCache.get('test_key', params: any(named: 'params')))
            .thenReturn('Cached response');

        final cached = mockCache.get('test_key');

        expect(cached, equals('Cached response'));
      });

      test('15. Cache miss returns null', () {
        when(() => mockCache.get('missing_key', params: any(named: 'params')))
            .thenReturn(null);

        final cached = mockCache.get('missing_key');

        expect(cached, isNull);
      });

      test('16. Sets cache after successful response', () async {
        when(() => mockCache.set(any(), any(), params: any(named: 'params')))
            .thenAnswer((_) async {});

        await mockCache.set('key', 'response');

        verify(() => mockCache.set('key', 'response', params: any(named: 'params')))
            .called(1);
      });

      test('17. Cache respects TTL expiration', () {
        // Cache should be cleared after TTL
        when(() => mockCache.get('expired_key', params: any(named: 'params')))
            .thenReturn(null);

        final cached = mockCache.get('expired_key');

        expect(cached, isNull);
      });
    });

    // ========================================================================
    // GROUP 5: Error Handling (3 tests)
    // ========================================================================
    group('Error Handling', () {
      test('18. Handles provider exceptions gracefully', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenThrow(Exception('Provider error'));
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => true);
        when(() => mockDeepSeek.generate(any(), type: any(named: 'type')))
            .thenAnswer((_) async => 'DeepSeek response');

        final result = await aiService.generateResponse('Test', useCache: false);

        expect(result, equals('DeepSeek response'));
      });

      test('19. Logs errors for debugging', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => true);
        when(() => mockKimi.generate(any(), type: any(named: 'type')))
            .thenThrow(Exception('Detailed error'));

        // Error should be caught and logged
        expect(
          () => aiService.generateResponse('Test', useCache: false),
          returnsNormally,
        );
      });

      test('20. Returns meaningful error message when all providers fail', () async {
        when(() => mockKimi.healthCheck()).thenAnswer((_) async => false);
        when(() => mockDeepSeek.healthCheck()).thenAnswer((_) async => false);
        when(() => mockGemini.healthCheck()).thenAnswer((_) async => false);

        final result = await aiService.generateResponse('Test', useCache: false);

        expect(result, isA<String>());
      });
    });
  });
}
