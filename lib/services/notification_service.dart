import '../models/models.dart';

// Conditional imports for platform-specific notification functionality
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart' as notif_impl;

class NotificationService {
  static Future<void> init() => notif_impl.init();
  static Future<void> scheduleAll(ReminderSettings r) => notif_impl.scheduleAll(r);
  static Future<void> showImmediate(String title, String body, {int id = 0}) => 
      notif_impl.showImmediate(title, body, id: id);
}
