import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  final Box settingsBox;

  static const _goalKey = 'daily_calorie_goal';
  static const _defaultGoal = 2000.0;

  SettingsProvider(this.settingsBox);

  double get dailyCalorieGoal =>
      (settingsBox.get(_goalKey) as num?)?.toDouble() ?? _defaultGoal;

  Future<void> setDailyCalorieGoal(double goal) async {
    await settingsBox.put(_goalKey, goal);
    notifyListeners();
  }
}