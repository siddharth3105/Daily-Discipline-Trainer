import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AiFoodService {
  // AI Provider: 'claude' or 'gemini'
  static String _provider = 'gemini'; // Default to free Gemini
  
  // API Keys
  static const _claudeApiKey = 'YOUR_ANTHROPIC_API_KEY';
  static const _geminiApiKey = 'AIzaSyBXpWViulTUVe-kjApVpZTjfQieZlTwpAs';
  
  static const _claudeUrl = 'https://api.anthropic.com/v1/messages';
  static const _geminiUrl = 'https://generativelanguage.googleapis.com/v1beta';

  /// Set AI provider ('claude' or 'gemini')
  static void setProvider(String provider) {
    _provider = provider;
  }

  /// Get current provider
  static String getProvider() => _provider;

  static Future<ScannedFood> analyzeFood(File imageFile) async {
    return _provider == 'gemini' 
        ? _analyzeWithGemini(imageFile)
        : _analyzeWithClaude(imageFile);
  }

  static Future<ScannedFood> _analyzeWithClaude(File imageFile) async {
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
      Uri.parse(_claudeUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _claudeApiKey,
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

  static Future<ScannedFood> _analyzeWithGemini(File imageFile) async {
    // Read image and encode to base64
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    // Detect media type
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 
                     ext == 'gif' ? 'image/gif' :
                     ext == 'webp' ? 'image/webp' : 'image/jpeg';

    final prompt = '''Analyze this food image and return ONLY a valid JSON object with these exact fields:
{
  "name": "food name (be specific, include quantity estimate)",
  "serving": "estimated serving size",
  "calories": number,
  "protein": number (grams),
  "carbs": number (grams),
  "fat": number (grams),
  "fiber": number (grams),
  "sugar": number (grams),
  "sodium": number (mg),
  "healthScore": number 1-10,
  "healthLabel": "e.g. High Protein / Balanced / Junk Food",
  "vitamins": ["top 3 vitamins/minerals"],
  "tip": "one short nutrition tip",
  "warnings": ["health warnings or empty array"],
  "category": "protein/carbs/fats/dairy/fruits/vegetables/junk/drink/other"
}
If no food detected, return {"error": "No food detected"}.''';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 1024,
      },
    };

    final response = await http.post(
      Uri.parse('$_geminiUrl/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final text = data['candidates'][0]['content']['parts'][0]['text'];

    // Clean and parse JSON
    final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final parsed = jsonDecode(clean) as Map<String, dynamic>;

    if (parsed.containsKey('error')) {
      throw Exception(parsed['error']);
    }

    return ScannedFood.fromJson(parsed);
  }
}
