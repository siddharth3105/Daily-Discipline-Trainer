import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseApiService {
  // ExerciseDB API - Free tier: 100 requests/day
  // Get your free API key at: https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb
  static const _apiKey = 'bbd5cf9addmsh3ae5014bd592fe1p198addjsnc1d5f325edaa';
  static const _baseUrl = 'https://exercisedb.p.rapidapi.com';

  // Get exercises by body part
  static Future<List<ExerciseData>> getExercisesByBodyPart(String bodyPart) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/bodyPart/$bodyPart'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.take(20).map((e) => ExerciseData.fromJson(e)).toList();
      }
      throw Exception('Failed to load exercises');
    } catch (e) {
      throw Exception('Error fetching exercises: $e');
    }
  }

  // Get exercise by ID
  static Future<ExerciseData> getExerciseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/exercise/$id'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ExerciseData.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to load exercise');
    } catch (e) {
      throw Exception('Error fetching exercise: $e');
    }
  }

  // Search exercises by name
  static Future<List<ExerciseData>> searchExercises(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/name/$query'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.take(20).map((e) => ExerciseData.fromJson(e)).toList();
      }
      throw Exception('Failed to search exercises');
    } catch (e) {
      throw Exception('Error searching exercises: $e');
    }
  }

  // Get list of body parts
  static Future<List<String>> getBodyPartsList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/bodyPartList'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      }
      throw Exception('Failed to load body parts');
    } catch (e) {
      throw Exception('Error fetching body parts: $e');
    }
  }

  // Get list of equipment
  static Future<List<String>> getEquipmentList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/equipmentList'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      }
      throw Exception('Failed to load equipment');
    } catch (e) {
      throw Exception('Error fetching equipment: $e');
    }
  }
}

class ExerciseData {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String gifUrl;
  final String target;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  ExerciseData({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.gifUrl,
    required this.target,
    required this.secondaryMuscles,
    required this.instructions,
  });

  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    return ExerciseData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      equipment: json['equipment'] ?? '',
      gifUrl: json['gifUrl'] ?? '',
      target: json['target'] ?? '',
      secondaryMuscles: json['secondaryMuscles'] != null 
          ? List<String>.from(json['secondaryMuscles']) 
          : [],
      instructions: json['instructions'] != null 
          ? List<String>.from(json['instructions']) 
          : [],
    );
  }
}
