import 'package:dio/dio.dart';
import 'ai_provider.dart';
import '../domain/ai_work_type.dart';

class KimiProvider implements AIProvider {
  final String apiKey;
  final Dio _dio = Dio();

  KimiProvider({required this.apiKey});

  @override
  String get name => 'NVIDIA NIM';

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.post(
        'https://integrate.api.nvidia.com/v1/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': 'meta/llama-3.1-70b-instruct',
          'messages': [{'role': 'user', 'content': 'hi'}],
          'max_tokens': 1,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generate(String prompt, {AiWorkType? type}) async {
    try {
      final response = await _dio.post(
        'https://integrate.api.nvidia.com/v1/chat/completions',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: {
          'model': 'meta/llama-3.1-70b-instruct',
          'messages': [{'role': 'user', 'content': prompt}],
        },
      );
      return response.data['choices'][0]['message']['content'] ?? '';
    } catch (e) {
      return 'AI Error: ${e.toString()}';
    }
  }

  @override
  Stream<String> generateStream(String prompt, {AiWorkType? type}) async* {
    yield await generate(prompt, type: type);
  }
}
