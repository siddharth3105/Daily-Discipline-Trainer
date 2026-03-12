// Stub implementation
import '../models/models.dart';

Future<void> init() async => throw UnsupportedError('Notifications not available on this platform');

Future<void> scheduleAll(ReminderSettings r) async => 
    throw UnsupportedError('Notifications not available on this platform');

Future<void> showImmediate(String title, String body, {int id = 0}) async =>
    throw UnsupportedError('Notifications not available on this platform');
