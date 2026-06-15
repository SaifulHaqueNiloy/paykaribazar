// ignore_for_file: avoid_print, prefer_const_declarations, unused_local_variable
import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();

  // 1. Test NVIDIA (Moonshot / NVIDIA)
  final nvidiaKey = '';
  print('\n--- Testing NVIDIA API Key ---');
  try {
    final url = Uri.parse('https://integrate.api.nvidia.com/v1/chat/completions');
    final request = await client.postUrl(url);
    request.headers.set('Authorization', 'Bearer $nvidiaKey');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({
      'model': 'meta/llama3-8b-instruct',
      'messages': [{'role': 'user', 'content': 'Hello'}],
      'max_tokens': 5,
    }));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      print('✅ NVIDIA Key is ACTIVE!');
    } else {
      print('❌ NVIDIA Key is INACTIVE! (Status: ${response.statusCode}, Response: $body)');
    }
  } catch (e) {
    print('❌ NVIDIA Key Error: $e');
  }

  // Also test it on moonshot cn endpoint just in case
  print('\n--- Testing NVIDIA Key on Moonshot CN Endpoint ---');
  try {
    final url = Uri.parse('https://api.moonshot.cn/v1/chat/completions');
    final request = await client.postUrl(url);
    request.headers.set('Authorization', 'Bearer $nvidiaKey');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({
      'model': 'moonshot-v1-8k',
      'messages': [{'role': 'user', 'content': 'hi'}],
      'max_tokens': 1,
    }));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      print('✅ NVIDIA Key works on Moonshot!');
    } else {
      print('❌ NVIDIA Key fails on Moonshot (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('❌ Moonshot CN Error: $e');
  }

  // 2. Test DeepSeek Keys
  final deepseekKeys = [
    '',
    '',
  ];
  print('\n--- Testing DeepSeek Keys ---');
  for (final key in deepseekKeys) {
    try {
      final url = Uri.parse('https://api.deepseek.com/chat/completions');
      final request = await client.postUrl(url);
      request.headers.set('Authorization', 'Bearer $key');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({
        'model': 'deepseek-chat',
        'messages': [{'role': 'user', 'content': 'hi'}],
        'max_tokens': 1,
      }));
      final response = await request.close();
      if (response.statusCode == 200) {
        print('✅ DeepSeek Key ($key) is ACTIVE!');
      } else {
        print('❌ DeepSeek Key ($key) is INACTIVE! (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ DeepSeek Key ($key) Error: $e');
    }
  }

  // 3. Test Groq Keys
  final groqKeys = [
    '',
    '',
  ];
  print('\n--- Testing Groq Keys ---');
  for (final key in groqKeys) {
    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final request = await client.postUrl(url);
      request.headers.set('Authorization', 'Bearer $key');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({
        'model': 'llama3-8b-8192',
        'messages': [{'role': 'user', 'content': 'hi'}],
        'max_tokens': 1,
      }));
      final response = await request.close();
      if (response.statusCode == 200) {
        print('✅ Groq Key ($key) is ACTIVE!');
      } else {
        print('❌ Groq Key ($key) is INACTIVE! (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ Groq Key ($key) Error: $e');
    }
  }

  client.close();
}
