import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// FatSecret Platform API - Premier Free tier: 5,000 requests/day
/// Get your free API key at: https://platform.fatsecret.com/api/
/// Free for startups/students/non-profits with attribution
class NutritionApiService {
  static const _consumerKey = '57183ce090554fb18a20192a00eae7cc';
  static const _consumerSecret = '656f22f0f9ac49af9c6fee6c8353cd13';
  static const _baseUrl = 'https://platform.fatsecret.com/rest/server.api';

  // Generate OAuth 1.0 signature for FatSecret API
  static String _generateSignature(Map<String, String> params, String method) {
    final sortedParams = params.keys.toList()..sort();
    final paramString = sortedParams
        .map((key) => '$key=${Uri.encodeComponent(params[key]!)}')
        .join('&');
    
    final baseString = '$method&${Uri.encodeComponent(_baseUrl)}&${Uri.encodeComponent(paramString)}';
    final signingKey = '${Uri.encodeComponent(_consumerSecret)}&';
    
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final digest = hmac.convert(utf8.encode(baseString));
    return base64Encode(digest.bytes);
  }

  // Make authenticated request to FatSecret API
  static Future<Map<String, dynamic>> _makeRequest(Map<String, String> params) async {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();
    
    final oauthParams = {
      ...params,
      'oauth_consumer_key': _consumerKey,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp,
      'oauth_nonce': nonce,
      'oauth_version': '1.0',
      'format': 'json',
    };

    final signature = _generateSignature(oauthParams, 'GET');
    oauthParams['oauth_signature'] = signature;

    final uri = Uri.parse(_baseUrl).replace(queryParameters: oauthParams);
    
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('API error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  /// Search for food items
  static Future<List<FoodSearchResult>> searchFood(String query) async {
    try {
      final data = await _makeRequest({
        'method': 'foods.search',
        'search_expression': query,
        'max_results': '20',
      });

      final foods = data['foods']?['food'];
      if (foods == null) return [];

      final foodList = foods is List ? foods : [foods];
      return foodList.map((item) => FoodSearchResult.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error searching food: $e');
    }
  }

  /// Get detailed nutrition for a specific food
  static Future<NutritionData> getFoodDetails(String foodId) async {
    try {
      final data = await _makeRequest({
        'method': 'food.get.v2',
        'food_id': foodId,
      });

      final food = data['food'];
      if (food == null) throw Exception('Food not found');

      return NutritionData.fromJson(food);
    } catch (e) {
      throw Exception('Error getting food details: $e');
    }
  }

  /// Search by barcode (Premium Free feature)
  static Future<NutritionData?> searchByBarcode(String barcode) async {
    try {
      final data = await _makeRequest({
        'method': 'food.find_id_for_barcode',
        'barcode': barcode,
      });

      final foodId = data['food_id']?['value'];
      if (foodId == null) return null;

      return await getFoodDetails(foodId);
    } catch (e) {
      throw Exception('Error searching barcode: $e');
    }
  }

  /// Get autocomplete suggestions
  static Future<List<String>> getAutocompleteSuggestions(String query) async {
    try {
      final data = await _makeRequest({
        'method': 'foods.autocomplete',
        'expression': query,
      });

      final suggestions = data['suggestions']?['suggestion'];
      if (suggestions == null) return [];

      final suggestionList = suggestions is List ? suggestions : [suggestions];
      return suggestionList.cast<String>();
    } catch (e) {
      return [];
    }
  }
}

class FoodSearchResult {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String type; // 'Generic' or 'Brand'

  FoodSearchResult({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.type,
  });

  factory FoodSearchResult.fromJson(Map<String, dynamic> json) {
    return FoodSearchResult(
      id: json['food_id']?.toString() ?? '',
      name: json['food_name'] ?? '',
      brand: json['brand_name'] ?? '',
      description: json['food_description'] ?? '',
      type: json['food_type'] ?? 'Generic',
    );
  }
}

class NutritionData {
  final String id;
  final String name;
  final String brand;
  final String servingUnit;
  final double servingQty;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double cholesterol;
  final double saturatedFat;
  final double polyunsaturatedFat;
  final double monounsaturatedFat;
  final double transFat;
  final double potassium;
  final double calcium;
  final double iron;
  final double vitaminA;
  final double vitaminC;

  NutritionData({
    required this.id,
    required this.name,
    required this.brand,
    required this.servingUnit,
    required this.servingQty,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.cholesterol,
    required this.saturatedFat,
    required this.polyunsaturatedFat,
    required this.monounsaturatedFat,
    required this.transFat,
    required this.potassium,
    required this.calcium,
    required this.iron,
    required this.vitaminA,
    required this.vitaminC,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    final servings = json['servings']?['serving'];
    final serving = servings is List ? servings[0] : servings;
    
    return NutritionData(
      id: json['food_id']?.toString() ?? '',
      name: json['food_name'] ?? '',
      brand: json['brand_name'] ?? '',
      servingUnit: serving?['serving_description'] ?? 'serving',
      servingQty: 1.0,
      calories: int.tryParse(serving?['calories']?.toString() ?? '0') ?? 0,
      protein: double.tryParse(serving?['protein']?.toString() ?? '0') ?? 0.0,
      carbs: double.tryParse(serving?['carbohydrate']?.toString() ?? '0') ?? 0.0,
      fat: double.tryParse(serving?['fat']?.toString() ?? '0') ?? 0.0,
      fiber: double.tryParse(serving?['fiber']?.toString() ?? '0') ?? 0.0,
      sugar: double.tryParse(serving?['sugar']?.toString() ?? '0') ?? 0.0,
      sodium: double.tryParse(serving?['sodium']?.toString() ?? '0') ?? 0.0,
      cholesterol: double.tryParse(serving?['cholesterol']?.toString() ?? '0') ?? 0.0,
      saturatedFat: double.tryParse(serving?['saturated_fat']?.toString() ?? '0') ?? 0.0,
      polyunsaturatedFat: double.tryParse(serving?['polyunsaturated_fat']?.toString() ?? '0') ?? 0.0,
      monounsaturatedFat: double.tryParse(serving?['monounsaturated_fat']?.toString() ?? '0') ?? 0.0,
      transFat: double.tryParse(serving?['trans_fat']?.toString() ?? '0') ?? 0.0,
      potassium: double.tryParse(serving?['potassium']?.toString() ?? '0') ?? 0.0,
      calcium: double.tryParse(serving?['calcium']?.toString() ?? '0') ?? 0.0,
      iron: double.tryParse(serving?['iron']?.toString() ?? '0') ?? 0.0,
      vitaminA: double.tryParse(serving?['vitamin_a']?.toString() ?? '0') ?? 0.0,
      vitaminC: double.tryParse(serving?['vitamin_c']?.toString() ?? '0') ?? 0.0,
    );
  }
}
