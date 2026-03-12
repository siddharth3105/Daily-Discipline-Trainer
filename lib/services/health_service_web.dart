// Web implementation - health features not available on web
import '../models/models.dart';

Future<bool> isAvailable() async => false;

Future<bool> requestAuthorization() async => false;

Future<HealthData> getTodayData() async => HealthData();

Future<List<Map<String, dynamic>>> getHeartRateHistory(DateTime start, DateTime end) async => [];

Future<int> getStepsForDate(DateTime date) async => 0;

Future<void> logWorkout({required DateTime start, required DateTime end, required int caloriesBurned}) async {}
