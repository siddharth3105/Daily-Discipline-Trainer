import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget to display exercise GIF from ExerciseDB API
/// Shows real human performing the exercise with proper form
class ExerciseGifWidget extends StatelessWidget {
  final String gifUrl;
  final Color borderColor;
  final double height;
  final String? fallbackText;

  const ExerciseGifWidget({
    super.key,
    required this.gifUrl,
    this.borderColor = AppColors.hiit,
    this.height = 300,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    if (gifUrl.isEmpty) {
      return _buildFallback();
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: borderColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          gifUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    color: borderColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Loading exercise animation...',
                    style: TextStyle(color: AppColors.textDim, fontSize: 12),
                  ),
                ],
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
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: borderColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: borderColor.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              fallbackText ?? 'Exercise animation',
              style: const TextStyle(color: AppColors.textDim, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mapping of exercise names to ExerciseDB IDs for quick lookup
class ExerciseGifMapping {
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

  /// Get ExerciseDB GIF URL for an exercise name
  static String getGifUrl(String exerciseName) {
    final id = exerciseIds[exerciseName];
    if (id == null) return '';
    return 'https://v2.exercisedb.io/image/$id';
  }

  /// Check if exercise has a GIF available
  static bool hasGif(String exerciseName) {
    return exerciseIds.containsKey(exerciseName);
  }
}
