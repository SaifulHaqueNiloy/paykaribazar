import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  test('NVIDIA API Key Validation', () async {
    // Load .env manually for the test
    final file = File('.env');
    final lines = await file.readAsLines();
    String? apiKey;
    for (var line in lines) {
      if (line.startsWith('NVIDIA_API_KEY=')) {
        apiKey = line.split('=')[1].trim();
        break;
      }
    }

    expect(apiKey, isNotNull, reason: 'NVIDIA_API_KEY not found in .env');

    final response = await http.post(
      Uri.parse('https://integrate.api.nvidia.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'moonshotai/kimi-k2.5',
        'messages': [{'role': 'user', 'content': 'hi'}],
        'max_tokens': 10,
      }),
    );

    expect(response.statusCode, 200, reason: 'API Key is invalid or inactive. Response: ${response.body}');
  });
}
