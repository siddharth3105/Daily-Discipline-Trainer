import 'dart:convert';
import 'package:http/http.dart' as http;

/// Google Gemini AI Service - Free AI from Google
/// Free tier: 60 requests per minute
/// Get your free API key at: https://makersuite.google.com/app/apikey
class GeminiAiService {
  static const _apiKey = 'AIzaSyBXpWViulTUVe-kjApVpZTjfQieZlTwpAs';
  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  
  // Using Gemini 1.5 Flash (free and fast)
  static const _model = 'gemini-1.5-flash';

  /// Generate workout plan with Gemini AI
  static Future<String> generateWorkoutPlan({
    required String goal,
    required String level,
    required int daysPerWeek,
  }) async {
    final prompt = '''
Create a detailed $daysPerWeek-day workout plan for someone with:
- Goal: $goal
- Fitness Level: $level

Include:
1. Weekly schedule with specific exercises
2. Sets, reps, and rest times
3. Progressive overload strategy
4. Safety tips

Format as a clear, structured plan.
''';

    return _generateContent(prompt);
  }

  /// Generate diet plan with Gemini AI
  static Future<String> generateDietPlan({
    required String goal,
    required int calories,
    required String restrictions,
  }) async {
    final prompt = '''
Create a detailed daily diet plan for:
- Goal: $goal
- Target Calories: $calories
- Dietary Restrictions: $restrictions

Include:
1. 5-6 meals with timing
2. Specific foods and portions
3. Macro breakdown
4. Meal prep tips

Format as a clear, structured plan.
''';

    return _generateContent(prompt);
  }

  /// Get personalized fitness coaching
  static Future<String> getCoachingAdvice(String question) async {
    final prompt = '''
As a professional fitness coach and nutritionist, answer this question:

$question

Provide evidence-based, practical advice that's safe and effective.
''';

    return _generateContent(prompt);
  }

  /// Analyze food from description
  static Future<FoodAnalysis> analyzeFoodDescription(String description) async {
    final prompt = '''
Analyze this food description and estimate nutrition:

"$description"

Provide in JSON format:
{
  "foodName": "string",
  "estimatedCalories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "confidence": "high/medium/low",
  "notes": "string"
}
''';

    try {
      final content = await _generateContent(prompt);
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final json = jsonDecode(jsonMatch.group(0)!);
        return FoodAnalysis.fromJson(json);
      }
      throw Exception('Failed to parse food analysis');
    } catch (e) {
      throw Exception('Error analyzing food: $e');
    }
  }

  /// Generate motivational message
  static Future<String> getMotivationalMessage({
    required String userGoal,
    required int currentStreak,
  }) async {
    final prompt = '''
Generate a motivational message for a fitness app user:
- Goal: $userGoal
- Current Streak: $currentStreak days

Make it inspiring, personal, and encouraging. Keep it under 100 words.
''';

    return _generateContent(prompt);
  }

  /// Suggest exercise alternatives
  static Future<List<String>> suggestExerciseAlternatives(
    String exerciseName,
    String reason,
  ) async {
    final prompt = '''
Suggest 5 alternative exercises for "$exerciseName" because: $reason

List them as:
1. Exercise name - brief description
2. Exercise name - brief description
...
''';

    final content = await _generateContent(prompt);
    final lines = content.split('\n')
        .where((line) => line.trim().isNotEmpty && RegExp(r'^\d+\.').hasMatch(line))
        .toList();
    return lines;
  }

  /// Core method to generate content
  static Future<String> _generateContent(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          },
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      }
      throw Exception('Failed to generate content: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error generating content: $e');
    }
  }

  /// Analyze workout performance
  static Future<WorkoutFeedback> analyzeWorkoutPerformance({
    required String exerciseName,
    required int setsCompleted,
    required int targetSets,
    required String difficulty,
  }) async {
    final prompt = '''
Analyze this workout performance:
- Exercise: $exerciseName
- Completed: $setsCompleted/$targetSets sets
- Difficulty: $difficulty

Provide feedback in JSON:
{
  "performance": "excellent/good/needs_improvement",
  "feedback": "string",
  "nextSteps": "string",
  "adjustments": "string"
}
''';

    try {
      final content = await _generateContent(prompt);
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch != null) {
        final json = jsonDecode(jsonMatch.group(0)!);
        return WorkoutFeedback.fromJson(json);
      }
      throw Exception('Failed to parse feedback');
    } catch (e) {
      throw Exception('Error analyzing performance: $e');
    }
  }
}

// Data models
class FoodAnalysis {
  final String foodName;
  final int estimatedCalories;
  final double protein;
  final double carbs;
  final double fat;
  final String confidence;
  final String notes;

  FoodAnalysis({
    required this.foodName,
    required this.estimatedCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.notes,
  });

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) {
    return FoodAnalysis(
      foodName: json['foodName'] ?? '',
      estimatedCalories: json['estimatedCalories'] ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      confidence: json['confidence'] ?? 'medium',
      notes: json['notes'] ?? '',
    );
  }
}

class WorkoutFeedback {
  final String performance;
  final String feedback;
  final String nextSteps;
  final String adjustments;

  WorkoutFeedback({
    required this.performance,
    required this.feedback,
    required this.nextSteps,
    required this.adjustments,
  });

  factory WorkoutFeedback.fromJson(Map<String, dynamic> json) {
    return WorkoutFeedback(
      performance: json['performance'] ?? '',
      feedback: json['feedback'] ?? '',
      nextSteps: json['nextSteps'] ?? '',
      adjustments: json['adjustments'] ?? '',
    );
  }
}
