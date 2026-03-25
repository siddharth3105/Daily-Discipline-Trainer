import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget to display exercise GIF from direct URLs
/// Shows real human performing the exercise with proper form
class ExerciseGifWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final gifUrl = ExerciseGifMapping.getGifUrl(exerciseName);
    
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
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
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
            Icon(Icons.fitness_center,
                size: 64, color: borderColor.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              exerciseName,
              style: const TextStyle(color: AppColors.textDim, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Mapping of exercise names to direct GIF URLs
class ExerciseGifMapping {
  static const Map<String, String> exerciseGifs = {
    // HIIT Cardio - Using v2.exercisedb.io direct GIF URLs
    'Jumping Jacks': 'https://v2.exercisedb.io/image/3224',
    'Burpee': 'https://v2.exercisedb.io/image/0648',
    'Mountain Climbers': 'https://v2.exercisedb.io/image/0028',
    
    // Bodyweight
    'Push-Up': 'https://v2.exercisedb.io/image/0662',
    'Pull-Up': 'https://v2.exercisedb.io/image/0651',
    'Plank': 'https://v2.exercisedb.io/image/0639',
    
    // Strength
    'Barbell Squat': 'https://v2.exercisedb.io/image/0043',
    'Deadlift': 'https://v2.exercisedb.io/image/0032',
    'Bench Press': 'https://v2.exercisedb.io/image/0025',
    'Overhead Press': 'https://v2.exercisedb.io/image/0355',
    
    // Flexibility
    'Hip Flexor Stretch': 'https://v2.exercisedb.io/image/1420',
    'Cat-Cow Stretch': 'https://v2.exercisedb.io/image/3293',
    
    // Height & Spine
    'Hanging Decompression': 'https://v2.exercisedb.io/image/0494',
    'Cobra Pose': 'https://v2.exercisedb.io/image/3294',
  };

  /// Get direct GIF URL for an exercise name
  static String getGifUrl(String exerciseName) {
    return exerciseGifs[exerciseName] ?? '';
  }

  /// Check if exercise has a GIF available
  static bool hasGif(String exerciseName) {
    return exerciseGifs.containsKey(exerciseName);
  }
}
