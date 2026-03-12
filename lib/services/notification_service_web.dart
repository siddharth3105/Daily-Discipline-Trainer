// Web implementation - notifications not fully supported on web
import '../models/models.dart';

Future<void> init() async {
  // Web notifications would use browser Notification API
  // For now, we'll just skip initialization
}

Future<void> scheduleAll(ReminderSettings r) async {
  // Scheduled notifications not supported on web
}

Future<void> showImmediate(String title, String body, {int id = 0}) async {
  // Could use browser Notification API here if needed
  print('Notification: $title - $body');
}
