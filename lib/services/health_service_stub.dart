// Stub implementation
import '../models/models.dart';

Future<bool> isAvailable() async => throw UnsupportedError('Health service not available on this platform');

Future<bool> requestAuthorization() async => throw UnsupportedError('Health service not available on this platform');

Future<HealthData> getTodayData() async => throw UnsupportedError('Health service not available on this platform');

Future<List<Map<String, dynamic>>> getHeartRateHistory(DateTime start, DateTime end) async => 
    throw UnsupportedError('Health service not available on this platform');

Future<int> getStepsForDate(DateTime date) async => throw UnsupportedError('Health service not available on this platform');

Future<void> logWorkout({required DateTime start, required DateTime end, required int caloriesBurned}) async =>
    throw UnsupportedError('Health service not available on this platform');
