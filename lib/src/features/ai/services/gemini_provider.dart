import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ai_provider.dart';
import '../domain/ai_work_type.dart';

class GeminiProvider implements AIProvider {
  final String apiKey;
  final String modelName;
  late final GenerativeModel _model;

  GeminiProvider({required this.apiKey, required this.modelName}) {
    _model = GenerativeModel(model: modelName, apiKey: apiKey);
  }

  @override
  String get name => 'Gemini';

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await _model.generateContent([Content.text('health check')]);
      return response.text != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> generate(String prompt, {AiWorkType? type}) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'No response generated.';
  }

  /// Multimodal generation for vision tasks
  Future<String> generateMultimodal(String prompt, Uint8List imageBytes, String mimeType) async {
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart(mimeType, imageBytes),
      ])
    ];
    final response = await _model.generateContent(content);
    return response.text ?? '';
  }

  @override
  Stream<String> generateStream(String prompt, {AiWorkType? type}) async* {
    final stream = _model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in stream) {
      if (chunk.text != null) yield chunk.text!;
    }
  }
}
