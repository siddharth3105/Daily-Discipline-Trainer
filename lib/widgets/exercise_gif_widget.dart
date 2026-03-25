import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_colors.dart';

/// Widget to display exercise GIF from ExerciseDB API
/// Shows real human performing the exercise with proper form
class ExerciseGifWidget extends StatefulWidget {
  final String exerciseName;
  final Color borderColor;
  final double height;

  const ExerciseGifWidget({
    super.key,
    required this.exerciseName,
    this.borderColor = AppColors.hiit,
    this.height = 300,
  });

  @override
  State<ExerciseGifWidget> createState() => _ExerciseGifWidgetState();
}

class _ExerciseGifWidgetState extends State<ExerciseGifWidget> {
  String? _gifUrl;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadGifUrl();
  }

  Future<void> _loadGifUrl() async {
    final id = ExerciseGifMapping.exerciseIds[widget.exerciseName];
    if (id == null) {
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://exercisedb.p.rapidapi.com/exercises/exercise/$id'),
        headers: {
          'X-RapidAPI-Key': ExerciseGifMapping.apiKey,
          'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _gifUrl = data['gifUrl'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: widget.borderColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: widget.borderColor),
                    const SizedBox(height: 12),
                    const Text(
                      'Loading exercise animation...',
                      style: TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                  ],
                ),
              )
            : _error || _gifUrl == null
                ? _buildFallback()
                : Image.network(
                    _gifUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: widget.borderColor,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallback();
                    },
                  ),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center,
              size: 64, color: widget.borderColor.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            widget.exerciseName,
            style: const TextStyle(color: AppColors.textDim, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Mapping of exercise names to ExerciseDB IDs for quick lookup
class ExerciseGifMapping {
  // ExerciseDB API key (same as in exercise_api_service.dart)
  static const apiKey = 'bbd5cf9addmsh3ae5014bd592fe1p198addjsnc1d5f325edaa';
  
  static const Map<String, String> exerciseIds = {
    // HIIT Cardio
    'Jumping Jacks': '3224',
    'Burpee': '0648',
    'Mountain Climbers': '0028',
    
    // Bodyweight
    'Push-Up': '0662',
    'Pull-Up': '0651',
    'Plank': '0639',
    
    // Strength
    'Barbell Squat': '0043',
    'Deadlift': '0032',
    'Bench Press': '0025',
    'Overhead Press': '0355',
    
    // Flexibility
    'Hip Flexor Stretch': '1420',
    'Cat-Cow Stretch': '3293',
    
    // Height & Spine
    'Hanging Decompression': '0494',
    'Cobra Pose': '3294',
  };

  /// Check if exercise has a GIF available
  static bool hasGif(String exerciseName) {
    return exerciseIds.containsKey(exerciseName);
  }
}
