import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
// GenerativeModel is a final class and cannot be mocked by Mockito directly.
// We remove it from @GenerateMocks to fix the build error.
import 'package:paykari_bazar/src/features/ai/services/gemini_provider.dart';
import 'package:paykari_bazar/src/features/ai/services/kimi_provider.dart';
import 'package:paykari_bazar/src/features/ai/services/deepseek_provider.dart';

@GenerateMocks([Dio])
void main() {
  group('GeminiProvider Tests', () {
    test('GeminiProvider basic properties', () {
      final provider = GeminiProvider(apiKey: 'test_key', modelName: 'test_model');
      expect(provider.name, equals('Gemini'));
    });
  });

  group('KimiProvider Tests', () {
    test('KimiProvider name', () {
      final provider = KimiProvider(apiKey: 'test_key');
      expect(provider.name, equals('Kimi'));
    });
  });

  group('DeepSeekProvider Tests', () {
    test('DeepSeekProvider name', () {
      final provider = DeepSeekProvider(apiKey: 'test_key');
      expect(provider.name, equals('DeepSeek'));
    });
  });
}
