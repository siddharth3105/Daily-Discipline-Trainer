import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static String _dateKey(String d) => d;
  static String todayKey() { final n=DateTime.now(); return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}'; }

  Future<UserStats> loadStats() async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_stats_v4'); return j==null?UserStats():UserStats.fromJson(jsonDecode(j)); }
  Future<void> saveStats(UserStats s) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_stats_v4',jsonEncode(s.toJson())); }

  Future<UserProfile> loadProfile() async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_profile_v2'); return j==null?UserProfile():UserProfile.fromJson(jsonDecode(j)); }
  Future<void> saveProfile(UserProfile profile) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_profile_v2',jsonEncode(profile.toJson())); }

  Future<List<String>> loadUnlockedBadges() async { final p=await SharedPreferences.getInstance(); return p.getStringList('ddt_badges_v2')??[]; }
  Future<void> saveUnlockedBadges(List<String> b) async { final p=await SharedPreferences.getInstance(); await p.setStringList('ddt_badges_v2',b); }

  Future<Map<String,bool>> loadWeekHistory() async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_week_history'); if(j==null) return {}; return Map<String,dynamic>.from(jsonDecode(j)).map((k,v)=>MapEntry(k,v as bool)); }
  Future<void> saveWeekHistory(Map<String,bool> h) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_week_history',jsonEncode(h)); }

  Future<Map<String,bool>> loadChecked(String date) async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_checked_$date'); if(j==null) return {}; return Map<String,dynamic>.from(jsonDecode(j)).map((k,v)=>MapEntry(k,v as bool)); }
  Future<void> saveChecked(String date, Map<String,bool> c) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_checked_$date',jsonEncode(c)); }

  Future<bool> loadDayDone(String date) async { final p=await SharedPreferences.getInstance(); return p.getBool('ddt_daydone_$date')??false; }
  Future<void> saveDayDone(String date, bool done) async { final p=await SharedPreferences.getInstance(); await p.setBool('ddt_daydone_$date',done); }

  Future<List<FoodEntry>> loadFoodLog(String date) async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_food_$date'); if(j==null) return []; return (jsonDecode(j)as List).map((e)=>FoodEntry.fromJson(e)).toList(); }
  Future<void> saveFoodLog(String date, List<FoodEntry> e) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_food_$date',jsonEncode(e.map((x)=>x.toJson()).toList())); }

  Future<int> loadWater(String date) async { final p=await SharedPreferences.getInstance(); return p.getInt('ddt_water_$date')??0; }
  Future<void> saveWater(String date, int g) async { final p=await SharedPreferences.getInstance(); await p.setInt('ddt_water_$date',g); }

  Future<ReminderSettings> loadReminders() async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_reminders_v1'); return j==null?const ReminderSettings():ReminderSettings.fromJson(jsonDecode(j)); }
  Future<void> saveReminders(ReminderSettings r) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_reminders_v1',jsonEncode(r.toJson())); }

  Future<List<BodyStatEntry>> loadBodyStats() async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_bodystats_v1'); if(j==null) return []; return (jsonDecode(j)as List).map((e)=>BodyStatEntry.fromJson(e)).toList(); }
  Future<void> saveBodyStats(List<BodyStatEntry> entries) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_bodystats_v1',jsonEncode(entries.map((e)=>e.toJson()).toList())); }

  Future<List<CustomWorkout>> loadCustomWorkouts() async { final p=await SharedPreferences.getInstance(); final j=p.getString('ddt_custom_workouts'); if(j==null) return []; return (jsonDecode(j)as List).map((e)=>CustomWorkout.fromJson(e)).toList(); }
  Future<void> saveCustomWorkouts(List<CustomWorkout> w) async { final p=await SharedPreferences.getInstance(); await p.setString('ddt_custom_workouts',jsonEncode(w.map((x)=>x.toJson()).toList())); }
}
