import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/usecases/add_water_entry.dart';
import '../../domain/usecases/get_today_water_entries.dart';
import '../../domain/usecases/delete_water_entry.dart';
import '../../domain/usecases/calculate_water_goal.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class WaterProvider extends ChangeNotifier {
  final AddWaterEntry addWaterEntryUseCase;
  final GetTodayWaterEntries getTodayWaterEntriesUseCase;
  final DeleteWaterEntry deleteWaterEntryUseCase;
  final CalculateWaterGoal calculateWaterGoalUseCase;
  final Box settingsBox;

  static const _manualGoalKey = 'water_goal_manual_ml';

  WaterProvider({
    required this.addWaterEntryUseCase,
    required this.getTodayWaterEntriesUseCase,
    required this.deleteWaterEntryUseCase,
    required this.calculateWaterGoalUseCase,
    required this.settingsBox,
  });

  List<WaterEntry> _todayEntries = [];
  List<WaterEntry> get todayEntries => _todayEntries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get totalMl => _todayEntries.fold(0.0, (sum, e) => sum + e.amountMl);

  double goalMl({
    required double weightKg,
    required ActivityLevel activityLevel,
  }) {
    final manual = (settingsBox.get(_manualGoalKey) as num?)?.toDouble();
    if (manual != null) return manual;

    double bonus;
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        bonus = 0;
        break;
      case ActivityLevel.light:
        bonus = 200;
        break;
      case ActivityLevel.moderate:
        bonus = 350;
        break;
      case ActivityLevel.active:
        bonus = 500;
        break;
    }
    return calculateWaterGoalUseCase(weightKg: weightKg, activityBonusMl: bonus);
  }

  Future<void> setManualGoal(double? goal) async {
    if (goal == null) {
      await settingsBox.delete(_manualGoalKey);
    } else {
      await settingsBox.put(_manualGoalKey, goal);
    }
    notifyListeners();
  }

  Future<void> loadTodayEntries() async {
    _isLoading = true;
    notifyListeners();
    _todayEntries = await getTodayWaterEntriesUseCase();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWater(double amountMl) async {
    final entry = WaterEntry(
      id: const Uuid().v4(),
      amountMl: amountMl,
      timestamp: DateTime.now(),
    );
    await addWaterEntryUseCase(entry);
    await loadTodayEntries();
  }

  Future<void> deleteEntry(String id) async {
    await deleteWaterEntryUseCase(id);
    await loadTodayEntries();
  }
}