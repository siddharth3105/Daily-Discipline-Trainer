import 'package:flutter/material.dart';

class AppColors {
  static const bg        = Color(0xFF050505);
  static const card      = Color(0xFF111111);
  static const card2     = Color(0xFF181818);
  static const border    = Color(0xFF2A2A2A);
  static const textPrim  = Color(0xFFFFFFFF);
  static const textSub   = Color(0xFF9A9A9A);
  static const textDim   = Color(0xFF555555);
  static const hiit      = Color(0xFFFF3B30);
  static const bodyweight= Color(0xFF007AFF);
  static const strength  = Color(0xFFFF9500);
  static const flex      = Color(0xFF30D158);
  static const height    = Color(0xFFBF5AF2);
  static const gold      = Color(0xFFFFCC00);
  static const success   = Color(0xFF30D158);
  static const danger    = Color(0xFFFF3B30);
  static const water     = Color(0xFF007AFF);
  static const border2   = Color(0xFF1A1A1A);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(primary: hiit, secondary: flex, background: bg, surface: card),
    fontFamily: 'SF Pro Display',
    appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: textPrim, elevation: 0, centerTitle: false,
      titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: textPrim, letterSpacing: 1)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: card2,
      hintStyle: const TextStyle(color: textDim),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: hiit, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    switchTheme: SwitchThemeData(thumbColor: MaterialStateProperty.resolveWith((s) => s.contains(MaterialState.selected) ? hiit : textDim), trackColor: MaterialStateProperty.resolveWith((s) => s.contains(MaterialState.selected) ? hiit.withOpacity(0.35) : border)),
    sliderTheme: SliderThemeData(activeTrackColor: hiit, inactiveTrackColor: border, thumbColor: hiit, overlayColor: hiit.withOpacity(0.15)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0xFF0D0D0D), selectedItemColor: hiit, unselectedItemColor: textDim, selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w700), unselectedLabelStyle: TextStyle(fontSize: 10)),
  );
}
