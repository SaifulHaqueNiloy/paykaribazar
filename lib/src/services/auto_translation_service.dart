import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AutoTranslationService {
  final String _apiKey;

  AutoTranslationService({String? apiKey})
      : _apiKey = apiKey ?? const String.fromEnvironment('AI_API_KEY');

  Future<String> translate(String text, {String to = 'bn'}) async {
    if (text.isEmpty || text.length < 2) return text;
    if (_apiKey.isEmpty) {
      debugPrint('AutoTranslation: No API key available');
      return text;
    }

    try {
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey');
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Translate to Bengali (Bangla) only. Return ONLY the translated text, no explanation: $text'}
            ]
          }
        ],
        'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 512}
      });

      final response = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content']?['parts'] as List?;
          if (content != null && content.isNotEmpty) {
            final translated = content[0]['text']?.toString().trim();
            if (translated != null && translated.isNotEmpty && translated != text) {
              debugPrint('AutoTranslation: "$text" → "$translated"');
              return translated;
            }
          }
        }
      } else {
        debugPrint('AutoTranslation: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('AutoTranslation error: $e');
    }
    return text;
  }
}
