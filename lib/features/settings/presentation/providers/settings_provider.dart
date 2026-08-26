import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

enum Gender { male, female }

enum ActivityLevel { sedentary, light, moderate, active }

enum WeightGoal { lose, maintain, gain }

class SettingsProvider extends ChangeNotifier {
  final Box settingsBox;

  static const _goalKey = 'daily_calorie_goal';
  static const _defaultGoal = 2000.0;
  static const _nameKey = 'user_name';

  static const _onboardingCompleteKey = 'onboarding_complete';

  bool get hasCompletedOnboarding =>
      (settingsBox.get(_onboardingCompleteKey) as bool?) ?? false;

  Future<void> setOnboardingComplete() async {
    await settingsBox.put(_onboardingCompleteKey, true);
    notifyListeners();
  }

  static const _genderKey = 'gender';
  static const _ageKey = 'age';
  static const _heightKey = 'height_cm';
  static const _weightKey = 'weight_kg';
  static const _activityKey = 'activity_level';
  static const _weightGoalKey = 'weight_goal';
  static const _mealReminderEnabledKey = 'meal_reminder_enabled';
  static const _mealReminderHourKey = 'meal_reminder_hour';
  static const _waterReminderEnabledKey = 'water_reminder_enabled';
  static const _waterReminderHourKey = 'water_reminder_hour';

  bool get mealReminderEnabled =>
      (settingsBox.get(_mealReminderEnabledKey) as bool?) ?? false;

  int get mealReminderHour =>
      (settingsBox.get(_mealReminderHourKey) as int?) ?? 19;

  bool get waterReminderEnabled =>
      (settingsBox.get(_waterReminderEnabledKey) as bool?) ?? false;

  int get waterReminderHour =>
      (settingsBox.get(_waterReminderHourKey) as int?) ?? 14;

  Future<void> setMealReminder({required bool enabled, int? hour}) async {
    await settingsBox.put(_mealReminderEnabledKey, enabled);
    if (hour != null) await settingsBox.put(_mealReminderHourKey, hour);
    notifyListeners();
  }

  Future<void> setWaterReminder({required bool enabled, int? hour}) async {
    await settingsBox.put(_waterReminderEnabledKey, enabled);
    if (hour != null) await settingsBox.put(_waterReminderHourKey, hour);
    notifyListeners();
  }

  SettingsProvider(this.settingsBox);

  double get dailyCalorieGoal =>
      (settingsBox.get(_goalKey) as num?)?.toDouble() ?? _defaultGoal;

  Future<void> setDailyCalorieGoal(double goal) async {
    await settingsBox.put(_goalKey, goal);
    notifyListeners();
  }

  // Целевое распределение БЖУ: 30% белки, 30% жиры, 40% углеводы.
  // Белки и углеводы — 4 ккал/г, жиры — 9 ккал/г.
  double get proteinGoalGrams => (dailyCalorieGoal * 0.30) / 4;
  double get fatGoalGrams => (dailyCalorieGoal * 0.30) / 9;
  double get carbsGoalGrams => (dailyCalorieGoal * 0.40) / 4;

  String get userName => (settingsBox.get(_nameKey) as String?) ?? '';

  Future<void> setUserName(String name) async {
    await settingsBox.put(_nameKey, name);
    notifyListeners();
  }

  Gender get gender =>
      Gender.values[(settingsBox.get(_genderKey) as int?) ?? 0];

  int get age => (settingsBox.get(_ageKey) as int?) ?? 25;

  double get heightCm =>
      (settingsBox.get(_heightKey) as num?)?.toDouble() ?? 170;

  double get weightKg =>
      (settingsBox.get(_weightKey) as num?)?.toDouble() ?? 70;

  ActivityLevel get activityLevel =>
      ActivityLevel.values[(settingsBox.get(_activityKey) as int?) ?? 1];

  WeightGoal get weightGoal =>
      WeightGoal.values[(settingsBox.get(_weightGoalKey) as int?) ?? 1];

  Future<void> saveCalculatorInputs({
    required Gender gender,
    required int age,
    required double heightCm,
    required double weightKg,
    required ActivityLevel activityLevel,
    required WeightGoal weightGoal,
  }) async {
    await settingsBox.put(_genderKey, gender.index);
    await settingsBox.put(_ageKey, age);
    await settingsBox.put(_heightKey, heightCm);
    await settingsBox.put(_weightKey, weightKg);
    await settingsBox.put(_activityKey, activityLevel.index);
    await settingsBox.put(_weightGoalKey, weightGoal.index);
    notifyListeners();
  }
}