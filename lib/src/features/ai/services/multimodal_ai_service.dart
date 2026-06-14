import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';
import '../../../core/services/secrets_service.dart';

/// Service for Multi-Modal AI operations (Image + Text)
/// Uses Gemini 2.0 Flash to analyze Cloudinary images and generate content
class MultimodalAIService {
  final SecretsService _secrets;

  MultimodalAIService({
    required SecretsService secrets,
  }) : _secrets = secrets;

  /// Generate a professional product description in Bengali and English from a Cloudinary URL or direct bytes
  Future<Map<String, dynamic>> generateProductDetailsFromImage({
    required String imageUrl,
    Uint8List? imageBytes,
    String? category,
    List<String>? keywords,
    String? existingTitleEn,
    String? existingTitleBn,
    String? existingDescEn,
    String? existingDescBn,
  }) async {
    try {
      debugPrint('🎨 Analyzing image: $imageUrl');

      final Uint8List finalBytes;
      if (imageBytes != null) {
        finalBytes = imageBytes;
      } else {
        // Step 1: Fetch image bytes from URL
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode != 200) {
          throw Exception('Failed to fetch image from URL: $imageUrl (Status: ${response.statusCode})');
        }
        finalBytes = response.bodyBytes;
      }

      // Step 2: Prepare Gemini 2.0 Flash Model
      // Note: We use the helper from AIService to get rotated keys
      var apiKey = _secrets.getSecret('GEMINI_API_KEY'); 
      if (apiKey.isEmpty) {
        final keys = [
          ..._secrets.getKeysByPrefix('GEMINI_MASTER_KEY'),
          ..._secrets.getKeysByPrefix('GEMINI_SUPPORT_KEY'),
          ..._secrets.getKeysByPrefix('GEMINI_API_KEY'),
        ].where((k) => k.isNotEmpty).toList();
        if (keys.isNotEmpty) {
          apiKey = keys.first;
        }
      }
      debugPrint('🔑 Multimodal API Key: ${apiKey.isEmpty ? "EMPTY" : apiKey.substring(0, 8)}... Length: ${apiKey.length}');
      final model = GenerativeModel(
        model: AIConfig.primaryModel, 
        apiKey: apiKey,
      );

      // Step 3: Create Multi-modal prompt
      final prompt = '''
        Analyze this product image carefully for a Bangladeshi e-commerce platform "Paykari Bazar".
        Category: ${category ?? 'General'}
        Additional Keywords: ${keywords?.join(', ') ?? 'None'}

        Context of existing fields (if provided):
        ${existingTitleEn != null && existingTitleEn.isNotEmpty ? '- Existing Title (English): $existingTitleEn' : ''}
        ${existingTitleBn != null && existingTitleBn.isNotEmpty ? '- Existing Title (Bengali): $existingTitleBn' : ''}
        ${existingDescEn != null && existingDescEn.isNotEmpty ? '- Existing Description (English): $existingDescEn' : ''}
        ${existingDescBn != null && existingDescBn.isNotEmpty ? '- Existing Description (Bengali): $existingDescBn' : ''}

        Please provide the following in a strict JSON format:
        {
          "title_bn": "আকর্ষণীয় বাংলা শিরোনাম",
          "title_en": "Catchy English Title",
          "description_bn": "বিস্তারিত বাংলা বিবরণ (অন্তত ৩-৪ বাক্য)",
          "description_en": "Detailed English description",
          "features": ["Feature 1", "Feature 2", "Feature 3"],
          "suggested_price_range": "৳XXX - ৳XXX",
          "seo_tags": ["tag1", "tag2", "tag3"],
          "confidence_score": 0.95
        }

        Make the descriptions compelling for wholesale and retail buyers in Bangladesh.
      ''';

      // Step 4: Generate Content
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', finalBytes),
        ])
      ];

      final aiResponse = await model.generateContent(content);
      final responseText = aiResponse.text;

      if (responseText == null) {
        throw Exception('AI returned empty response');
      }

      // Step 5: Parse JSON response
      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final Map<String, dynamic> result = jsonDecode(cleanJson);
      
      debugPrint('✅ Product details generated successfully from image');
      return result;

    } catch (e) {
      debugPrint('❌ Multimodal AI Error: $e');
      return {
        'error': e.toString(),
        'title_bn': 'প্রোডাক্ট ডেসক্রিপশন জেনারেট করা সম্ভব হয়নি',
        'description_bn': 'অনুগ্রহ করে ম্যানুয়ালি তথ্য প্রদান করুন।',
      };
    }
  }

  /// Suggest tags for a product based on its image
  Future<List<String>> suggestTagsFromImage(String imageUrl) async {
    final details = await generateProductDetailsFromImage(imageUrl: imageUrl);
    if (details.containsKey('seo_tags')) {
      return List<String>.from(details['seo_tags']);
    }
    return [];
  }
}
