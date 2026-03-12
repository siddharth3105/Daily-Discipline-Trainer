import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/app_data.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/health_service.dart';

class AppProvider extends ChangeNotifier {
  final _storage = StorageService();

  // ── Core State
  UserStats _stats = UserStats();
  UserProfile _profile = UserProfile();
  Map<String, bool> _checked = {};
  bool _dayDone = false;
  Map<String, bool> _weekHistory = {};
  List<FoodEntry> _foodLog = [];
  int _water = 0;
  List<String> _unlockedBadges = [];
  ReminderSettings _reminders = const ReminderSettings();
  List<BodyStatEntry> _bodyStats = [];
  List<CustomWorkout> _customWorkouts = [];
  HealthData _healthData = HealthData();
  bool _loaded = false;
  String? _newBadgeId;
  bool _healthAuthorized = false;

  // ── Points
  static const ptsExercise = 15;
  static const ptsSession  = 30;
  static const ptsFullDay  = 50;
  static const ptsFood     = 10;
  static const ptsWater    = 20;

  // ── Getters
  UserStats get stats              => _stats;
  UserProfile get profile          => _profile;
  Map<String, bool> get checked    => _checked;
  bool get dayDone                 => _dayDone;
  Map<String, bool> get weekHistory => _weekHistory;
  List<FoodEntry> get foodLog      => _foodLog;
  int get water                    => _water;
  List<String> get unlockedBadges  => _unlockedBadges;
  ReminderSettings get reminders   => _reminders;
  List<BodyStatEntry> get bodyStats => _bodyStats;
  List<CustomWorkout> get customWorkouts => _customWorkouts;
  HealthData get healthData        => _healthData;
  bool get loaded                  => _loaded;
  bool get healthAuthorized        => _healthAuthorized;
  String? get newBadgeId           => _newBadgeId;

  String get todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }

  int get todayDayIndex => (DateTime.now().weekday + 6) % 7;
  String get todayCat => weekSchedule[todayDayIndex];

  List<String> get weekDates {
    final today = DateTime.now();
    final todayIdx = todayDayIndex;
    return List.generate(7, (i) {
      final d = today.subtract(Duration(days: todayIdx - i));
      return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
    });
  }

  int totalCalToday() => _foodLog.fold(0, (a, e) => a + e.calories);
  double totalProteinToday() => _foodLog.fold(0, (a, e) => a + e.protein);
  double totalCarbsToday()   => _foodLog.fold(0, (a, e) => a + e.carbs);
  double totalFatToday()     => _foodLog.fold(0, (a, e) => a + e.fat);

  // ── Load all
  Future<void> loadAll() async {
    _stats          = await _storage.loadStats();
    _profile        = await _storage.loadProfile();
    _checked        = await _storage.loadChecked(todayKey);
    _dayDone        = await _storage.loadDayDone(todayKey);
    _weekHistory    = await _storage.loadWeekHistory();
    _foodLog        = await _storage.loadFoodLog(todayKey);
    _water          = await _storage.loadWater(todayKey);
    _unlockedBadges = await _storage.loadUnlockedBadges();
    _reminders      = await _storage.loadReminders();
    _bodyStats      = await _storage.loadBodyStats();
    _customWorkouts = await _storage.loadCustomWorkouts();
    _loaded = true;
    notifyListeners();

    // Schedule notifications
    await NotificationService.init();
    await NotificationService.scheduleAll(_reminders);

    // Load health data in background
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    _healthAuthorized = await HealthService.isAvailable();
    if (_healthAuthorized) {
      _healthData = await HealthService.getTodayData();
      notifyListeners();
    }
  }

  // ── Connect smartwatch / health platform
  Future<bool> connectHealthPlatform() async {
    final ok = await HealthService.requestAuthorization();
    _healthAuthorized = ok;
    if (ok) {
      _healthData = await HealthService.getTodayData();
      notifyListeners();
    }
    return ok;
  }

  Future<void> refreshHealthData() async {
    _healthData = await HealthService.getTodayData();
    notifyListeners();
  }

  // ── Profile
  Future<void> saveProfile(UserProfile p) async {
    _profile = p;
    await _storage.saveProfile(p);
    notifyListeners();
  }

  // ── Reminders
  Future<void> updateReminders(ReminderSettings r) async {
    _reminders = r;
    await _storage.saveReminders(r);
    await NotificationService.scheduleAll(r);
    notifyListeners();
  }

  // ── Toggle exercise
  Future<void> toggleExercise(String catKey, String name) async {
    final k = '$catKey|$name';
    final was = _checked[k] ?? false;
    _checked[k] = !was;
    if (!was) {
      _stats = _stats.copyWith(totalExercises: _stats.totalExercises + 1);
      _addPoints(ptsExercise);
      final cat = exerciseCategories.firstWhere((c) => c.key == catKey);
      if (cat.exercises.every((n) => _checked['${catKey}|$n'] == true)) {
        _addPoints(ptsSession);
      }
    }
    await _storage.saveChecked(todayKey, _checked);
    await _storage.saveStats(_stats);
    _checkBadges();
    notifyListeners();
  }

  // ── Complete day
  Future<void> completeDay() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
    final consecutive = _stats.lastCheckin == yKey || _stats.lastCheckin == todayKey;
    final newStreak = _stats.lastCheckin == todayKey
        ? _stats.streak
        : consecutive ? _stats.streak + 1 : 1;

    _stats = _stats.copyWith(
      streak: newStreak,
      lastCheckin: todayKey,
      completedSessions: _stats.completedSessions + 1,
    );
    _addPoints(ptsFullDay);
    _dayDone = true;
    _weekHistory[todayKey] = true;

    await _storage.saveDayDone(todayKey, true);
    await _storage.saveWeekHistory(_weekHistory);
    await _storage.saveStats(_stats);

    // Log workout to health platform (Apple Health / Health Connect)
    if (_healthAuthorized) {
      final now = DateTime.now();
      await HealthService.logWorkout(
        start: now.subtract(const Duration(hours: 1)),
        end: now,
        caloriesBurned: 250,
      );
    }

    _checkBadges();
    notifyListeners();
  }

  // ── Food
  Future<void> addFood(FoodEntry e) async {
    _foodLog.add(e);
    _stats = _stats.copyWith(dietDays: _stats.dietDays + 1);
    _addPoints(ptsFood);
    await _storage.saveFoodLog(todayKey, _foodLog);
    await _storage.saveStats(_stats);
    _checkBadges();
    notifyListeners();
  }

  Future<void> removeFood(String id) async {
    _foodLog.removeWhere((e) => e.id == id);
    await _storage.saveFoodLog(todayKey, _foodLog);
    notifyListeners();
  }

  // ── Water
  Future<void> setWater(int glasses) async {
    _water = glasses;
    if (glasses >= 8) _addPoints(ptsWater);
    _stats = _stats.copyWith(maxWater: glasses > _stats.maxWater ? glasses : _stats.maxWater);
    await _storage.saveWater(todayKey, glasses);
    await _storage.saveStats(_stats);
    _checkBadges();
    notifyListeners();
  }

  // ── Body stats
  Future<void> addBodyStat(BodyStatEntry entry) async {
    // Remove existing entry for same date
    _bodyStats.removeWhere((e) => e.date == entry.date);
    _bodyStats.add(entry);
    _bodyStats.sort((a, b) => a.date.compareTo(b.date));
    await _storage.saveBodyStats(_bodyStats);
    notifyListeners();
  }

  // ── Custom workouts
  Future<void> addCustomWorkout(CustomWorkout w) async {
    _customWorkouts.add(w);
    await _storage.saveCustomWorkouts(_customWorkouts);
    notifyListeners();
  }

  Future<void> removeCustomWorkout(String id) async {
    _customWorkouts.removeWhere((w) => w.id == id);
    await _storage.saveCustomWorkouts(_customWorkouts);
    notifyListeners();
  }

  // ── Points
  void _addPoints(int pts) {
    final earned = (pts * _stats.multiplier).round();
    _stats = _stats.copyWith(
      totalPoints: _stats.totalPoints + earned,
      pointsToday: _stats.pointsToday + earned,
    );
  }

  // ── Badges
  void _checkBadges() {
    for (final badge in allBadges) {
      if (!_unlockedBadges.contains(badge.id) && badge.check(_stats)) {
        _unlockedBadges.add(badge.id);
        _newBadgeId = badge.id;
        _storage.saveUnlockedBadges(_unlockedBadges);
        NotificationService.showImmediate(
          '🏅 Badge Unlocked: ${badge.name}!',
          badge.desc,
          id: 60 + _unlockedBadges.length,
        );
      }
    }
  }

  void clearNewBadge() { _newBadgeId = null; notifyListeners(); }
}
