// Mobile implementation (iOS/Android)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/models.dart';

final _plugin = FlutterLocalNotificationsPlugin();
bool _initialized = false;

Future<void> init() async {
  if (_initialized) return;
  tz.initializeTimeZones();

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  await _plugin.initialize(
    const InitializationSettings(android: android, iOS: ios),
  );

  // Request permissions
  await _plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  await _plugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  _initialized = true;
}

// Notification channels
const _workoutChannel = AndroidNotificationDetails(
  'workout_reminders', 'Workout Reminders',
  channelDescription: 'Daily workout reminder notifications',
  importance: Importance.high, priority: Priority.high,
);

const _waterChannel = AndroidNotificationDetails(
  'water_reminders', 'Water Reminders',
  channelDescription: 'Hydration reminder notifications',
  importance: Importance.defaultImportance, priority: Priority.defaultPriority,
);

const _mealChannel = AndroidNotificationDetails(
  'meal_reminders', 'Meal Reminders',
  channelDescription: 'Meal time reminder notifications',
  importance: Importance.defaultImportance, priority: Priority.defaultPriority,
);

const _motivationChannel = AndroidNotificationDetails(
  'motivation', 'Motivation',
  channelDescription: 'Daily motivation notifications',
  importance: Importance.defaultImportance, priority: Priority.defaultPriority,
);

const _streakChannel = AndroidNotificationDetails(
  'streak_protection', 'Streak Protection',
  channelDescription: 'Streak protection reminder notifications',
  importance: Importance.high, priority: Priority.high,
);

Future<void> scheduleAll(ReminderSettings r) async {
  await _plugin.cancelAll();

  if (r.workoutEnabled) {
    await _plugin.zonedSchedule(
      1,
      '💪 Time to Train!',
      'Your daily workout is waiting. Let\'s build that discipline!',
      _nextInstanceOfTime(r.workoutHour, r.workoutMinute),
      NotificationDetails(android: _workoutChannel, iOS: const DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  if (r.waterEnabled) {
    for (int i = 0; i < 8; i++) {
      final hour = 6 + (i * r.waterIntervalHours);
      if (hour >= 22) break;
      await _plugin.zonedSchedule(
        10 + i,
        '💧 Hydration Check',
        'Time to drink water! Stay hydrated for peak performance.',
        _nextInstanceOfTime(hour, 0),
        NotificationDetails(android: _waterChannel, iOS: const DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  if (r.mealEnabled) {
    final mealTimes = [(7, 0, 'Breakfast'), (10, 30, 'Mid-Morning Snack'), (13, 0, 'Lunch'),
                       (16, 0, 'Pre-Workout'), (19, 30, 'Dinner'), (22, 0, 'Night Protein')];
    for (int i = 0; i < mealTimes.length; i++) {
      final (h, m, name) = mealTimes[i];
      await _plugin.zonedSchedule(
        20 + i,
        '🍽 Meal Time: $name',
        'Fuel your body right. Check your meal plan!',
        _nextInstanceOfTime(h, m),
        NotificationDetails(android: _mealChannel, iOS: const DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  if (r.motivationEnabled) {
    await _plugin.zonedSchedule(
      30,
      '🌅 Good Morning, Champion!',
      'Today is another opportunity to become stronger. Let\'s go!',
      _nextInstanceOfTime(r.motivationHour, r.motivationMinute),
      NotificationDetails(android: _motivationChannel, iOS: const DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  if (r.streakEnabled) {
    await _plugin.zonedSchedule(
      40,
      '⚠️ Streak Protection Alert',
      'You haven\'t trained today! Don\'t break your streak!',
      _nextInstanceOfTime(21, 0),
      NotificationDetails(android: _streakChannel, iOS: const DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

Future<void> showImmediate(String title, String body, {int id = 0}) async {
  await _plugin.show(
    id,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails('general', 'General', importance: Importance.high, priority: Priority.high),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}
