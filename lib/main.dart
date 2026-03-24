import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init timezone data for notification scheduling
  tz.initializeTimeZones();

  // Lock to portrait - landscape mode breaks some animations
  // TODO: support landscape for tablets later
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Custom status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D0D), // matches app bg
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const DDTApp());
}
