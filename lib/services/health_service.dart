import '../models/models.dart';

// Conditional imports for platform-specific health functionality
import 'health_service_stub.dart'
    if (dart.library.io) 'health_service_mobile.dart'
    if (dart.library.html) 'health_service_web.dart' as health_impl;

class HealthService {
  static Future<bool> isAvailable() => health_impl.isAvailable();
  static Future<bool> requestAuthorization() => health_impl.requestAuthorization();
  static Future<HealthData> getTodayData() => health_impl.getTodayData();
  static Future<List<Map<String, dynamic>>> getHeartRateHistory(DateTime start, DateTime end) => 
      health_impl.getHeartRateHistory(start, end);
  static Future<int> getStepsForDate(DateTime date) => health_impl.getStepsForDate(date);
  static Future<void> logWorkout({required DateTime start, required DateTime end, required int caloriesBurned}) =>
      health_impl.logWorkout(start: start, end: end, caloriesBurned: caloriesBurned);
}
