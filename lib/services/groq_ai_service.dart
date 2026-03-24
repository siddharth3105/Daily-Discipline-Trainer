import 'dart:convert';
import 'package:http/http.dart' as http;

/// Groq AI Service - Ultra-fast AI inference
/// Free tier: 14,400 requests per day
/// Get your free API key at: https://console.groq.com/
class GroqAiService {
  static const _apiKey = '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';
  static const _baseUrl = 'https://api.groq.com/openai/v1';
  
  // Available models (all free):
  // - llama-3.3-70b-versatile (best for general tasks)
  // - llama-3.1-8b-instant (fastest)
  // - mixtral-8x7b-32768 (good for long context)
  
  /// Generate personalized workout plan using AI
  static Future<WorkoutPlanSuggestion> generateWorkoutPlan({
    required String goal,
    required String fitnessLevel,
    required String equipment,
    int daysPerWeek = 5,
  }) async {
    final prompt = '''
You are a professional fitness trainer. Create a detailed workout plan with the following requirements:

Goal: $goal
Fitness Level: $fitnessLevel
Available Equipment: $equipment
Days per Week: $daysPerWeek

Provide a structured workout plan in JSON format with:
{
  "planName": "string",
  "description": "string",
  "weeklySchedule": [
    {
      "day": "Monday",
      "focus": "string",
      "exercises": [
        {
          "name": "string",
          "sets": number,
          "reps": "string",
          "rest": number,
          "notes": "string"
        }
      ]
    }
  ],
  "tips": ["string"]
}

Make it practical, safe, and effective.
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final planJson = jsonDecode(jsonMatch.group(0)!);
          return WorkoutPlanSuggestion.fromJson(planJson);
        }
        throw Exception('Failed to parse workout plan');
      }
      throw Exception('Failed to generate workout plan: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error generating workout plan: $e');
    }
  }

  /// Generate personalized diet plan using AI
  static Future<DietPlanSuggestion> generateDietPlan({
    required String goal,
    required int targetCalories,
    required String dietaryRestrictions,
    int mealsPerDay = 5,
  }) async {
    final prompt = '''
You are a professional nutritionist. Create a detailed diet plan with:

Goal: $goal
Target Calories: $targetCalories per day
Dietary Restrictions: $dietaryRestrictions
Meals per Day: $mealsPerDay

Provide a structured diet plan in JSON format with:
{
  "planName": "string",
  "description": "string",
  "dailyCalories": number,
  "meals": [
    {
      "time": "string",
      "name": "string",
      "foods": "string",
      "calories": number,
      "protein": number,
      "carbs": number,
      "fat": number
    }
  ],
  "tips": ["string"]
}

Make it balanced, practical, and delicious.
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final planJson = jsonDecode(jsonMatch.group(0)!);
          return DietPlanSuggestion.fromJson(planJson);
        }
        throw Exception('Failed to parse diet plan');
      }
      throw Exception('Failed to generate diet plan: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error generating diet plan: $e');
    }
  }

  /// Get AI fitness advice
  static Future<String> getFitnessAdvice(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant', // Fastest model
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional fitness trainer and nutritionist. Provide helpful, safe, and evidence-based advice.'
            },
            {'role': 'user', 'content': question}
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      throw Exception('Failed to get advice: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting advice: $e');
    }
  }

  /// Analyze exercise form from description
  static Future<FormAnalysis> analyzeForm(String exerciseName, String userDescription) async {
    final prompt = '''
Analyze this exercise form description and provide feedback:

Exercise: $exerciseName
User's Description: $userDescription

Provide analysis in JSON format:
{
  "score": number (0-10),
  "feedback": "string",
  "corrections": ["string"],
  "goodPoints": ["string"]
}
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 500,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final analysisJson = jsonDecode(jsonMatch.group(0)!);
          return FormAnalysis.fromJson(analysisJson);
        }
        throw Exception('Failed to parse analysis');
      }
      throw Exception('Failed to analyze form: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error analyzing form: $e');
    }
  }
}

// Data models
class WorkoutPlanSuggestion {
  final String planName;
  final String description;
  final List<DayWorkout> weeklySchedule;
  final List<String> tips;

  WorkoutPlanSuggestion({
    required this.planName,
    required this.description,
    required this.weeklySchedule,
    required this.tips,
  });

  factory WorkoutPlanSuggestion.fromJson(Map<String, dynamic> json) {
    return WorkoutPlanSuggestion(
      planName: json['planName'] ?? '',
      description: json['description'] ?? '',
      weeklySchedule: (json['weeklySchedule'] as List?)
          ?.map((e) => DayWorkout.fromJson(e))
          .toList() ?? [],
      tips: List<String>.from(json['tips'] ?? []),
    );
  }
}

class DayWorkout {
  final String day;
  final String focus;
  final List<ExerciseDetail> exercises;

  DayWorkout({required this.day, required this.focus, required this.exercises});

  factory DayWorkout.fromJson(Map<String, dynamic> json) {
    return DayWorkout(
      day: json['day'] ?? '',
      focus: json['focus'] ?? '',
      exercises: (json['exercises'] as List?)
          ?.map((e) => ExerciseDetail.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ExerciseDetail {
  final String name;
  final int sets;
  final String reps;
  final int rest;
  final String notes;

  ExerciseDetail({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.notes,
  });

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    return ExerciseDetail(
      name: json['name'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? '10',
      rest: json['rest'] ?? 60,
      notes: json['notes'] ?? '',
    );
  }
}

class DietPlanSuggestion {
  final String planName;
  final String description;
  final int dailyCalories;
  final List<MealDetail> meals;
  final List<String> tips;

  DietPlanSuggestion({
    required this.planName,
    required this.description,
    required this.dailyCalories,
    required this.meals,
    required this.tips,
  });

  factory DietPlanSuggestion.fromJson(Map<String, dynamic> json) {
    return DietPlanSuggestion(
      planName: json['planName'] ?? '',
      description: json['description'] ?? '',
      dailyCalories: json['dailyCalories'] ?? 2000,
      meals: (json['meals'] as List?)
          ?.map((e) => MealDetail.fromJson(e))
          .toList() ?? [],
      tips: List<String>.from(json['tips'] ?? []),
    );
  }
}

class MealDetail {
  final String time;
  final String name;
  final String foods;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  MealDetail({
    required this.time,
    required this.name,
    required this.foods,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    return MealDetail(
      time: json['time'] ?? '',
      name: json['name'] ?? '',
      foods: json['foods'] ?? '',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FormAnalysis {
  final int score;
  final String feedback;
  final List<String> corrections;
  final List<String> goodPoints;

  FormAnalysis({
    required this.score,
    required this.feedback,
    required this.corrections,
    required this.goodPoints,
  });

  factory FormAnalysis.fromJson(Map<String, dynamic> json) {
    return FormAnalysis(
      score: json['score'] ?? 0,
      feedback: json['feedback'] ?? '',
      corrections: List<String>.from(json['corrections'] ?? []),
      goodPoints: List<String>.from(json['goodPoints'] ?? []),
    );
  }
}
