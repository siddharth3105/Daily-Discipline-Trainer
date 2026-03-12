// Mobile implementation (iOS/Android)
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/models.dart';

final _health = HealthFactory();
bool _authorized = false;

const _types = [
  HealthDataType.STEPS,
  HealthDataType.HEART_RATE,
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.WORKOUT,
  HealthDataType.WEIGHT,
  HealthDataType.HEIGHT,
];

Future<bool> requestAuthorization() async {
  try {
    await Permission.activityRecognition.request();
    final perms = _types.map((_) => HealthDataAccess.READ_WRITE).toList();
    _authorized = await _health.requestAuthorization(_types, permissions: perms);
    return _authorized;
  } catch (e) {
    return false;
  }
}

Future<bool> isAvailable() async {
  try {
    return await _health.isHealthDataAvailable();
  } catch (_) {
    return false;
  }
}

Future<HealthData> getTodayData() async {
  if (!_authorized) {
    final ok = await requestAuthorization();
    if (!ok) return HealthData();
  }

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  try {
    final data = await _health.getHealthDataFromTypes(
      startTime: startOfDay,
      endTime: now,
      types: _types,
    );

    int steps = 0;
    double heartRate = 0, heartRateCount = 0;
    double caloriesBurned = 0;
    double sleepHours = 0;
    double activeMinutes = 0;
    String source = '';

    for (final point in data) {
      final val = point.value;
      switch (point.type) {
        case HealthDataType.STEPS:
          if (val is NumericHealthValue) {
            steps += val.numericValue.toInt();
            if (source.isEmpty) {
              source = point.sourceName.toLowerCase().contains('watch')
                  ? 'Apple Watch' : point.sourceName.toLowerCase().contains('wear')
                  ? 'Wear OS' : point.sourceName;
            }
          }
          break;
        case HealthDataType.HEART_RATE:
          if (val is NumericHealthValue) {
            heartRate += val.numericValue;
            heartRateCount++;
          }
          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          if (val is NumericHealthValue) caloriesBurned += val.numericValue;
          break;
        case HealthDataType.SLEEP_ASLEEP:
          if (val is NumericHealthValue) sleepHours += val.numericValue / 60;
          break;
        case HealthDataType.WORKOUT:
          if (val is WorkoutHealthValue) {
            activeMinutes += val.totalEnergyBurned ?? 0;
          }
          break;
        default: break;
      }
    }

    final avgHR = heartRateCount > 0 ? heartRate / heartRateCount : 0.0;

    return HealthData(
      steps: steps,
      heartRate: avgHR,
      caloriesBurned: caloriesBurned,
      sleepHours: sleepHours,
      activeMinutes: activeMinutes,
      watchConnected: steps > 0 || heartRate > 0,
      watchSource: source.isNotEmpty ? source : 'Health App',
      lastSync: now,
    );
  } catch (e) {
    return HealthData();
  }
}

Future<List<Map<String, dynamic>>> getHeartRateHistory(DateTime start, DateTime end) async {
  if (!_authorized) return [];
  try {
    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: [HealthDataType.HEART_RATE],
    );
    return data.where((d) => d.value is NumericHealthValue).map((d) => {
      'time': d.dateFrom,
      'value': (d.value as NumericHealthValue).numericValue,
    }).toList();
  } catch (_) {
    return [];
  }
}

Future<int> getStepsForDate(DateTime date) async {
  if (!_authorized) return 0;
  try {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final data = await _health.getHealthDataFromTypes(
      startTime: start, endTime: end, types: [HealthDataType.STEPS],
    );
    int steps = 0;
    for (final d in data) {
      if (d.value is NumericHealthValue) steps += (d.value as NumericHealthValue).numericValue.toInt();
    }
    return steps;
  } catch (_) {
    return 0;
  }
}

Future<void> logWorkout({required DateTime start, required DateTime end, required int caloriesBurned}) async {
  if (!_authorized) return;
  try {
    await _health.writeHealthData(
      value: caloriesBurned.toDouble(),
      type: HealthDataType.ACTIVE_ENERGY_BURNED,
      startTime: start,
      endTime: end,
    );
  } catch (_) {}
}
