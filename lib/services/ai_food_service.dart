import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AiFoodService {
  // Replace with your Anthropic API key
  static const _apiKey = 'YOUR_ANTHROPIC_API_KEY';
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';

  static Future<ScannedFood> analyzeFood(File imageFile) async {
    // Read image and encode to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    // Detect media type from extension
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mediaType = ext == 'png' ? 'image/png' : 
                      ext == 'gif' ? 'image/gif' :
                      ext == 'webp' ? 'image/webp' : 'image/jpeg';

    final requestBody = {
      'model': 'claude-sonnet-4-20250514',
      'max_tokens': 1000,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mediaType,
                'data': base64Image,
              },
            },
            {
              'type': 'text',
              'text': '''You are a nutrition expert AI. Analyze this food image and return ONLY a valid JSON object (no markdown, no extra text) with these exact fields:
{
  "name": "food name (be specific, include quantity estimate e.g. '2 eggs scrambled')",
  "serving": "estimated serving size e.g. '200g' or '1 cup'",
  "calories": number,
  "protein": number (grams),
  "carbs": number (grams),
  "fat": number (grams),
  "fiber": number (grams),
  "sugar": number (grams),
  "sodium": number (mg),
  "healthScore": number 1-10,
  "healthLabel": "e.g. High Protein / High Carb / Balanced / Junk Food",
  "vitamins": ["top 3 vitamins/minerals present"],
  "tip": "one short nutrition tip about this food",
  "warnings": ["any health warnings, empty array if none"],
  "category": "one of: protein/carbs/fats/dairy/fruits/vegetables/junk/drink/other"
}
Estimate based on typical serving size visible. If no food is detected, return {"error": "No food detected in image"}.''',
            },
          ],
        },
      ],
    };

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final content = data['content'] as List;
    final text = content
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('');

    // Clean and parse JSON
    final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final parsed = jsonDecode(clean) as Map<String, dynamic>;

    if (parsed.containsKey('error')) {
      throw Exception(parsed['error']);
    }

    return ScannedFood.fromJson(parsed);
  }
}
