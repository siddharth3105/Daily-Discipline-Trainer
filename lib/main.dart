import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezones for local notifications
  tz.initializeTimeZones();

  // Force portrait orientation for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D0D),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const DDTApp());
}
