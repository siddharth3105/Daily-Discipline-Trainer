class Exercise {
  final String name, category, animationType, muscle, tip;
  final int calories, sets;
  final String reps;
  final List<String> steps, mistakes;
  const Exercise({required this.name, required this.category, required this.calories, required this.sets, required this.reps, required this.animationType, required this.muscle, required this.tip, required this.steps, required this.mistakes});
}

class FoodEntry {
  final String id, name;
  final int calories;
  final double protein, carbs, fat, fiber, sugar, sodium;
  final DateTime timestamp;
  final bool fromScanner;
  FoodEntry({required this.id, required this.name, required this.calories, required this.protein, required this.carbs, required this.fat, this.fiber=0, this.sugar=0, this.sodium=0, DateTime? timestamp, this.fromScanner=false}) : timestamp = timestamp ?? DateTime.now();
  Map<String, dynamic> toJson() => {'id':id,'name':name,'calories':calories,'protein':protein,'carbs':carbs,'fat':fat,'fiber':fiber,'sugar':sugar,'sodium':sodium,'timestamp':timestamp.toIso8601String(),'fromScanner':fromScanner};
  factory FoodEntry.fromJson(Map<String, dynamic> j) => FoodEntry(id:j['id'],name:j['name'],calories:j['calories'],protein:(j['protein']as num).toDouble(),carbs:(j['carbs']as num).toDouble(),fat:(j['fat']as num).toDouble(),fiber:(j['fiber']as num? ?? 0).toDouble(),sugar:(j['sugar']as num? ?? 0).toDouble(),sodium:(j['sodium']as num? ?? 0).toDouble(),timestamp:DateTime.parse(j['timestamp']),fromScanner:j['fromScanner']??false);
}

class ScannedFood {
  final String name, serving, healthLabel, tip, category;
  final int calories, healthScore;
  final double protein, carbs, fat, fiber, sugar, sodium;
  final List<String> vitamins, warnings;
  ScannedFood({required this.name, required this.serving, required this.calories, required this.protein, required this.carbs, required this.fat, required this.fiber, required this.sugar, required this.sodium, required this.healthScore, required this.healthLabel, required this.vitamins, required this.tip, required this.warnings, required this.category});
  factory ScannedFood.fromJson(Map<String, dynamic> j) => ScannedFood(name:j['name']??'Unknown',serving:j['serving']??'1 serving',calories:(j['calories']as num?? 0).toInt(),protein:(j['protein']as num?? 0).toDouble(),carbs:(j['carbs']as num?? 0).toDouble(),fat:(j['fat']as num?? 0).toDouble(),fiber:(j['fiber']as num?? 0).toDouble(),sugar:(j['sugar']as num?? 0).toDouble(),sodium:(j['sodium']as num?? 0).toDouble(),healthScore:(j['healthScore']as num?? 5).toInt(),healthLabel:j['healthLabel']??'Balanced',vitamins:List<String>.from(j['vitamins']??[]),tip:j['tip']??'',warnings:List<String>.from(j['warnings']??[]),category:j['category']??'other');
}

class UserStats {
  int streak, totalPoints, pointsToday, totalExercises, completedSessions, dietDays, maxWater;
  String lastCheckin;
  UserStats({this.streak=0, this.totalPoints=0, this.pointsToday=0, this.lastCheckin='', this.totalExercises=0, this.completedSessions=0, this.dietDays=0, this.maxWater=0});
  double get multiplier => streak>=30?2.0:streak>=7?1.5:1.0;
  Map<String, dynamic> toJson() => {'streak':streak,'totalPoints':totalPoints,'pointsToday':pointsToday,'lastCheckin':lastCheckin,'totalExercises':totalExercises,'completedSessions':completedSessions,'dietDays':dietDays,'maxWater':maxWater};
  factory UserStats.fromJson(Map<String, dynamic> j) => UserStats(streak:j['streak']??0,totalPoints:j['totalPoints']??0,pointsToday:j['pointsToday']??0,lastCheckin:j['lastCheckin']??'',totalExercises:j['totalExercises']??0,completedSessions:j['completedSessions']??0,dietDays:j['dietDays']??0,maxWater:j['maxWater']??0);
  UserStats copyWith({int? streak, int? totalPoints, int? pointsToday, String? lastCheckin, int? totalExercises, int? completedSessions, int? dietDays, int? maxWater}) => UserStats(streak:streak??this.streak,totalPoints:totalPoints??this.totalPoints,pointsToday:pointsToday??this.pointsToday,lastCheckin:lastCheckin??this.lastCheckin,totalExercises:totalExercises??this.totalExercises,completedSessions:completedSessions??this.completedSessions,dietDays:dietDays??this.dietDays,maxWater:maxWater??this.maxWater);
}

class BadgeModel {
  final String id, icon, name, desc;
  final bool Function(UserStats) check;
  const BadgeModel({required this.id, required this.icon, required this.name, required this.desc, required this.check});
}

class MealItem {
  final String time, name, foods;
  final int cal, protein, carbs, fat;
  const MealItem({required this.time, required this.name, required this.foods, required this.cal, required this.protein, required this.carbs, required this.fat});
}

class DietPlan {
  final String label;
  final int goalCalories;
  final List<MealItem> meals;
  final List<String> tips;
  const DietPlan({required this.label, required this.goalCalories, required this.meals, required this.tips});
}

class UserProfile {
  final String name, gender, goal, activityLevel;
  final int age;
  final double heightCm, weightKg;
  final bool onboardingDone;
  UserProfile({this.name='', this.age=25, this.gender='male', this.heightCm=170, this.weightKg=70, this.goal='muscle', this.activityLevel='moderate', this.onboardingDone=false});
  double get bmi => weightKg / ((heightCm/100) * (heightCm/100));
  String get bmiLabel { if(bmi<18.5) return 'Underweight'; if(bmi<25) return 'Normal'; if(bmi<30) return 'Overweight'; return 'Obese'; }
  int get tdee { double bmr = gender=='female' ? 10*weightKg+6.25*heightCm-5*age-161 : 10*weightKg+6.25*heightCm-5*age+5; const m = {'sedentary':1.2,'light':1.375,'moderate':1.55,'active':1.725,'very_active':1.9}; return (bmr*(m[activityLevel]??1.55)).round(); }
  int get targetCalories { switch(goal) { case 'muscle': return tdee+300; case 'lean': return tdee-400; default: return tdee; } }
  Map<String, dynamic> toJson() => {'name':name,'age':age,'gender':gender,'heightCm':heightCm,'weightKg':weightKg,'goal':goal,'activityLevel':activityLevel,'onboardingDone':onboardingDone};
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(name:j['name']??'',age:j['age']??25,gender:j['gender']??'male',heightCm:(j['heightCm']as num?? 170).toDouble(),weightKg:(j['weightKg']as num?? 70).toDouble(),goal:j['goal']??'muscle',activityLevel:j['activityLevel']??'moderate',onboardingDone:j['onboardingDone']??false);
  UserProfile copyWith({String? name, int? age, String? gender, double? heightCm, double? weightKg, String? goal, String? activityLevel, bool? onboardingDone}) => UserProfile(name:name??this.name,age:age??this.age,gender:gender??this.gender,heightCm:heightCm??this.heightCm,weightKg:weightKg??this.weightKg,goal:goal??this.goal,activityLevel:activityLevel??this.activityLevel,onboardingDone:onboardingDone??this.onboardingDone);
}

class BodyStatEntry {
  final String date;
  final double weight;
  final double? bodyFat, chest, waist, hips, arms, thighs;
  BodyStatEntry({required this.date, required this.weight, this.bodyFat, this.chest, this.waist, this.hips, this.arms, this.thighs});
  Map<String, dynamic> toJson() => {'date':date,'weight':weight,'bodyFat':bodyFat,'chest':chest,'waist':waist,'hips':hips,'arms':arms,'thighs':thighs};
  factory BodyStatEntry.fromJson(Map<String, dynamic> j) => BodyStatEntry(date:j['date'],weight:(j['weight']as num).toDouble(),bodyFat:j['bodyFat']!=null?(j['bodyFat']as num).toDouble():null,chest:j['chest']!=null?(j['chest']as num).toDouble():null,waist:j['waist']!=null?(j['waist']as num).toDouble():null,hips:j['hips']!=null?(j['hips']as num).toDouble():null,arms:j['arms']!=null?(j['arms']as num).toDouble():null,thighs:j['thighs']!=null?(j['thighs']as num).toDouble():null);
}

class ReminderSettings {
  final bool workoutEnabled, waterEnabled, mealEnabled, streakEnabled, motivationEnabled;
  final int workoutHour, workoutMinute, waterIntervalHours, motivationHour, motivationMinute;
  const ReminderSettings({this.workoutEnabled=true,this.workoutHour=7,this.workoutMinute=0,this.waterEnabled=true,this.waterIntervalHours=2,this.mealEnabled=true,this.streakEnabled=true,this.motivationEnabled=true,this.motivationHour=6,this.motivationMinute=30});
  Map<String, dynamic> toJson() => {'workoutEnabled':workoutEnabled,'workoutHour':workoutHour,'workoutMinute':workoutMinute,'waterEnabled':waterEnabled,'waterIntervalHours':waterIntervalHours,'mealEnabled':mealEnabled,'streakEnabled':streakEnabled,'motivationEnabled':motivationEnabled,'motivationHour':motivationHour,'motivationMinute':motivationMinute};
  factory ReminderSettings.fromJson(Map<String, dynamic> j) => ReminderSettings(workoutEnabled:j['workoutEnabled']??true,workoutHour:j['workoutHour']??7,workoutMinute:j['workoutMinute']??0,waterEnabled:j['waterEnabled']??true,waterIntervalHours:j['waterIntervalHours']??2,mealEnabled:j['mealEnabled']??true,streakEnabled:j['streakEnabled']??true,motivationEnabled:j['motivationEnabled']??true,motivationHour:j['motivationHour']??6,motivationMinute:j['motivationMinute']??30);
  ReminderSettings copyWith({bool? workoutEnabled, int? workoutHour, int? workoutMinute, bool? waterEnabled, int? waterIntervalHours, bool? mealEnabled, bool? streakEnabled, bool? motivationEnabled, int? motivationHour, int? motivationMinute}) => ReminderSettings(workoutEnabled:workoutEnabled??this.workoutEnabled,workoutHour:workoutHour??this.workoutHour,workoutMinute:workoutMinute??this.workoutMinute,waterEnabled:waterEnabled??this.waterEnabled,waterIntervalHours:waterIntervalHours??this.waterIntervalHours,mealEnabled:mealEnabled??this.mealEnabled,streakEnabled:streakEnabled??this.streakEnabled,motivationEnabled:motivationEnabled??this.motivationEnabled,motivationHour:motivationHour??this.motivationHour,motivationMinute:motivationMinute??this.motivationMinute);
}

class HealthData {
  final int steps;
  final double heartRate, caloriesBurned, sleepHours, activeMinutes;
  final bool watchConnected;
  final String watchSource;
  final DateTime lastSync;
  HealthData({this.steps=0,this.heartRate=0,this.caloriesBurned=0,this.sleepHours=0,this.activeMinutes=0,this.watchConnected=false,this.watchSource='',DateTime? lastSync}) : lastSync = lastSync ?? DateTime.now();
  bool get stepGoalReached => steps >= 10000;
  int get stepPercent => ((steps/10000)*100).clamp(0,100).toInt();
}

class CustomExercise {
  final String name, muscleGroup, notes;
  final int sets, reps, restSeconds, calPerSet;
  CustomExercise({required this.name, required this.muscleGroup, required this.sets, required this.reps, required this.restSeconds, required this.calPerSet, this.notes=''});
  Map<String, dynamic> toJson() => {'name':name,'muscleGroup':muscleGroup,'notes':notes,'sets':sets,'reps':reps,'restSeconds':restSeconds,'calPerSet':calPerSet};
  factory CustomExercise.fromJson(Map<String, dynamic> j) => CustomExercise(name:j['name'],muscleGroup:j['muscleGroup'],notes:j['notes']??'',sets:j['sets'],reps:j['reps'],restSeconds:j['restSeconds'],calPerSet:j['calPerSet']);
}

class CustomWorkout {
  final String id, name, description;
  final List<CustomExercise> exercises;
  final DateTime createdAt;
  CustomWorkout({required this.id, required this.name, required this.description, required this.exercises, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();
  int get totalCalories => exercises.fold(0,(a,e)=>a+e.sets*e.calPerSet);
  Map<String, dynamic> toJson() => {'id':id,'name':name,'description':description,'exercises':exercises.map((e)=>e.toJson()).toList(),'createdAt':createdAt.toIso8601String()};
  factory CustomWorkout.fromJson(Map<String, dynamic> j) => CustomWorkout(id:j['id'],name:j['name'],description:j['description'],exercises:(j['exercises']as List).map((e)=>CustomExercise.fromJson(e)).toList(),createdAt:DateTime.parse(j['createdAt']));
}

class CustomMealItem {
  final String name, time, foods;
  final int calories;
  final double protein, carbs, fat;
  CustomMealItem({required this.name, required this.time, required this.foods, required this.calories, required this.protein, required this.carbs, required this.fat});
  Map<String, dynamic> toJson() => {'name':name,'time':time,'foods':foods,'calories':calories,'protein':protein,'carbs':carbs,'fat':fat};
  factory CustomMealItem.fromJson(Map<String, dynamic> j) => CustomMealItem(name:j['name'],time:j['time'],foods:j['foods'],calories:j['calories'],protein:(j['protein']as num).toDouble(),carbs:(j['carbs']as num).toDouble(),fat:(j['fat']as num).toDouble());
}

class CustomDietPlan {
  final String id, name, description;
  final int goalCalories;
  final List<CustomMealItem> meals;
  final DateTime createdAt;
  CustomDietPlan({required this.id, required this.name, required this.description, required this.goalCalories, required this.meals, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();
  int get totalCalories => meals.fold(0,(a,m)=>a+m.calories);
  Map<String, dynamic> toJson() => {'id':id,'name':name,'description':description,'goalCalories':goalCalories,'meals':meals.map((m)=>m.toJson()).toList(),'createdAt':createdAt.toIso8601String()};
  factory CustomDietPlan.fromJson(Map<String, dynamic> j) => CustomDietPlan(id:j['id'],name:j['name'],description:j['description'],goalCalories:j['goalCalories'],meals:(j['meals']as List).map((m)=>CustomMealItem.fromJson(m)).toList(),createdAt:DateTime.parse(j['createdAt']));
}

class WeeklySchedule {
  final String id, name;
  final Map<int, String> workoutSchedule; // day index (0-6) -> workout id or category key
  final String dietPlanId; // custom diet plan id or 'muscle'/'fatloss'/'height'
  final bool isCustom;
  final DateTime createdAt;
  WeeklySchedule({required this.id, required this.name, required this.workoutSchedule, required this.dietPlanId, this.isCustom=true, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();
  Map<String, dynamic> toJson() => {'id':id,'name':name,'workoutSchedule':workoutSchedule.map((k,v)=>(MapEntry(k.toString(),v))),'dietPlanId':dietPlanId,'isCustom':isCustom,'createdAt':createdAt.toIso8601String()};
  factory WeeklySchedule.fromJson(Map<String, dynamic> j) => WeeklySchedule(id:j['id'],name:j['name'],workoutSchedule:(j['workoutSchedule']as Map<String,dynamic>).map((k,v)=>MapEntry(int.parse(k),v as String)),dietPlanId:j['dietPlanId'],isCustom:j['isCustom']??true,createdAt:DateTime.parse(j['createdAt']));
}
