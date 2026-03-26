import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:paykari_bazar/src/features/ai/services/ai_provider.dart';
import 'package:paykari_bazar/src/features/ai/services/ai_provider_manager.dart';

// Mock AI Provider
class MockAIProvider extends Mock implements AIProvider {
  @override
  String get name => 'Mock Provider';
}

// Mock Primary Provider
class MockPrimaryProvider extends Mock implements AIProvider {
  @override
  String get name => 'Primary Provider';
}

// Mock Fallback Provider
class MockFallbackProvider extends Mock implements AIProvider {
  @override
  String get name => 'Fallback Provider';
}

void main() {
  group('AI Provider Fallback Tests', () {
    late MockPrimaryProvider primaryProvider;
    late MockFallbackProvider fallbackProvider;
    late AIProviderManager providerManager;

    setUp(() {
      primaryProvider = MockPrimaryProvider();
      fallbackProvider = MockFallbackProvider();
      providerManager = AIProviderManager(
        primaryProvider: primaryProvider,
        fallbackProvider: fallbackProvider,
      );
    });

    test('Use primary provider when available', () async {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => true);
      when(primaryProvider.generate('test prompt'))
          .thenAnswer((_) async => 'Primary response');

      // Act
      await providerManager.healthCheck();
      final result = await providerManager.generate('test prompt');

      // Assert
      expect(result, 'Primary response');
      expect(providerManager.isPrimaryAvailable, true);
      expect(providerManager.isUsingFallback, false);
      verify(primaryProvider.generate('test prompt')).called(1);
    });

    test('Switch to fallback when primary fails', () async {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => false);
      when(fallbackProvider.healthCheck()).thenAnswer((_) async => true);
      when(fallbackProvider.generate('test prompt'))
          .thenAnswer((_) async => 'Fallback response');

      // Act
      await providerManager.healthCheck();
      final result = await providerManager.generate('test prompt');

      // Assert
      expect(result, contains('Fallback response'));
      expect(providerManager.isPrimaryAvailable, false);
      expect(providerManager.isUsingFallback, true);
    });

    test('Handle timeout and fallback', () async {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => true);
      when(primaryProvider.generate('test prompt'))
          .thenThrow(Exception('Timeout'));
      when(fallbackProvider.healthCheck()).thenAnswer((_) async => true);
      when(fallbackProvider.generate('test prompt'))
          .thenAnswer((_) async => 'Fallback response');

      // Act
      await providerManager.healthCheck();
      final result = await providerManager.generate('test prompt');

      // Assert
      expect(result, contains('Fallback response'));
      expect(providerManager.isUsingFallback, true);
    });

    test('Get active provider name', () async {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => true);

      // Act
      await providerManager.healthCheck();

      // Assert
      expect(providerManager.activeProviderName, contains('Primary Provider'));
    });

    test('Get fallback provider name when primary down', () async {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => false);
      when(fallbackProvider.healthCheck()).thenAnswer((_) async => true);

      // Act
      await providerManager.healthCheck();

      // Assert
      expect(providerManager.activeProviderName, contains('Fallback Provider'));
    });

    test('Stream generation with fallback', () async* {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => true);
      when(primaryProvider.generateStream('test'))
          .thenAnswer((_) async* {
        yield 'Primary ';
        yield 'response';
      });

      // Act
      await providerManager.healthCheck();
      final stream = providerManager.generateStream('test');
      final results = <String>[];
      await for (final result in stream) {
        results.add(result);
      }

      // Assert
      expect(results, isNotEmpty);
    });

    test('Get provider statistics', () async {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => true);

      // Act
      await providerManager.healthCheck();
      final stats = providerManager.getStats();

      // Assert
      expect(stats['primaryProvider'], 'Primary Provider');
      expect(stats['fallbackProvider'], 'Fallback Provider');
      expect(stats['primaryAvailable'], true);
      expect(stats['usingFallback'], false);
    });

    test('Reset providers to retry', () async {
      // Arrange
      when(primaryProvider.healthCheck()).thenAnswer((_) async => true);
      when(primaryProvider.generate('test'))
          .thenAnswer((_) async => 'Primary response');

      // Act
      await providerManager.resetProviders();
      final result = await providerManager.generate('test');

      // Assert
      expect(result, 'Primary response');
      expect(providerManager.isUsingFallback, false);
    });
  });
}
