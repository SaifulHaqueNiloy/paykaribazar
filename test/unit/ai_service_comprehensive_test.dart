/// test/unit/ai_service_comprehensive_test.dart
/// AIProvider interface tests
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/src/features/ai/services/ai_provider.dart';
import 'package:paykari_bazar/src/features/ai/domain/ai_work_type.dart';

// Simple test implementation
class TestAIProvider implements AIProvider {
  @override
  String get name => 'TestProvider';
  
  @override
  Future<bool> healthCheck() async => true;
  
  @override
  Future<String> generate(String prompt, {AiWorkType? type}) async {
    return 'Test response for: $prompt';
  }
  
  @override
  Stream<String> generateStream(String prompt, {AiWorkType? type}) async* {
    yield 'Test';
    yield ' response';
  }
}

void main() {
  group('AIProvider Interface Tests', () {
    late TestAIProvider provider;

    setUp(() {
      provider = TestAIProvider();
    });

    test('Provider name is accessible', () {
      expect(provider.name, equals('TestProvider'));
    });

    test('Health check returns true', () async {
      final isHealthy = await provider.healthCheck();
      expect(isHealthy, isTrue);
    });

    test('Generate method returns non-empty response', () async {
      final result = await provider.generate('Test prompt');
      expect(result, isNotEmpty);
      expect(result, contains('Test response'));
    });

    test('Generate with pricing work type', () async {
      final result = await provider.generate(
        'What is the price?',
        type: AiWorkType.pricing,
      );
      expect(result, contains('Test response'));
    });

    test('GenerateStream yields responses', () async {
      final chunks = <String>[];
      await for (final chunk in provider.generateStream('Test')) {
        chunks.add(chunk);
      }
      expect(chunks, isNotEmpty);
      expect(chunks.join(), contains('Test'));
    });

    test('Multiple generate calls work independently', () async {
      final result1 = await provider.generate('prompt1');
      final result2 = await provider.generate('prompt2');
      
      expect(result1, contains('prompt1'));
      expect(result2, contains('prompt2'));
    });

    test('GenerateStream works with different prompts', () async {
      final stream1 = provider.generateStream('test1', type: AiWorkType.text);
      final stream2 = provider.generateStream('test2', type: AiWorkType.pricing);
      
      final chunks1 = <String>[];
      final chunks2 = <String>[];
      
      await for (final chunk in stream1) {
        chunks1.add(chunk);
      }
      
      await for (final chunk in stream2) {
        chunks2.add(chunk);
      }
      
      expect(chunks1, isNotEmpty);
      expect(chunks2, isNotEmpty);
    });

    test('Provider supports all AiWorkType values', () async {
      const workTypes = AiWorkType.values;
      
      for (final workType in workTypes) {
        final result = await provider.generate('Test', type: workType);
        expect(result, isNotEmpty);
      }
    });

    test('Generate responses are consistent in structure', () async {
      final result = await provider.generate('Any prompt');
      
      expect(result, isA<String>());
      expect(result.length, greaterThan(0));
    });

    test('HealthCheck can be called multiple times', () async {
      final check1 = await provider.healthCheck();
      final check2 = await provider.healthCheck();
      
      expect(check1, equals(check2));
      expect(check1, isTrue);
    });
  });
}
