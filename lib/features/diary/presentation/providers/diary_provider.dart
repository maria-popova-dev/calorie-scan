import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/food_entry.dart';
import '../../domain/usecases/add_food_entry.dart';
import '../../domain/usecases/get_today_entries.dart';
import '../../domain/usecases/calculate_daily_total.dart';
import '../../domain/usecases/get_custom_foods.dart';
import '../../domain/usecases/delete_food_entry.dart';
import '../../domain/usecases/update_food_entry.dart';
import '../../domain/usecases/delete_all_entries.dart';
import '../../domain/usecases/get_history_by_day.dart';
import '../../domain/usecases/get_recent_entries.dart';
import '../../domain/usecases/copy_previous_day.dart';

class DiaryProvider extends ChangeNotifier {
  final AddFoodEntry addFoodEntryUseCase;
  final GetTodayEntries getTodayEntriesUseCase;
  final CalculateDailyTotal calculateDailyTotalUseCase;
  final GetCustomFoods getCustomFoodsUseCase;
  final DeleteFoodEntry deleteFoodEntryUseCase;
  final UpdateFoodEntry updateFoodEntryUseCase;
  final DeleteAllEntries deleteAllEntriesUseCase;
  final GetHistoryByDay getHistoryByDayUseCase;
  final GetRecentEntries getRecentEntriesUseCase;
  final CopyPreviousDay copyPreviousDayUseCase;

  DiaryProvider({
    required this.addFoodEntryUseCase,
    required this.getTodayEntriesUseCase,
    required this.calculateDailyTotalUseCase,
    required this.getCustomFoodsUseCase,
    required this.deleteFoodEntryUseCase,
    required this.updateFoodEntryUseCase,
    required this.deleteAllEntriesUseCase,
    required this.getHistoryByDayUseCase,
    required this.getRecentEntriesUseCase,
    required this.copyPreviousDayUseCase,
  });

  List<FoodEntry> _todayEntries = [];
  List<FoodEntry> get todayEntries => _todayEntries;

  DailyTotal get dailyTotal => calculateDailyTotalUseCase(_todayEntries);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadTodayEntries() async {
    _isLoading = true;
    notifyListeners();

    _todayEntries = await getTodayEntriesUseCase();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry({
    required String name,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
    required FoodEntrySource source,
    MealType? mealType,
  }) async {
    final entry = FoodEntry(
      id: const Uuid().v4(),
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      timestamp: DateTime.now(),
      source: source,
      mealType: mealType ?? _suggestMealTypeByTime(),
    );

    await addFoodEntryUseCase(entry);
    await loadTodayEntries();
  }

  MealType _suggestMealTypeByTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 16) return MealType.lunch;
    if (hour < 21) return MealType.dinner;
    return MealType.snack;
  }
  Future<List<FoodEntry>> searchCustomFoods(String query) {
    return getCustomFoodsUseCase(query);
  }
  Future<void> deleteEntry(String id) async {
    await deleteFoodEntryUseCase(id);
    await loadTodayEntries();
  }
  Future<void> updateEntry(FoodEntry entry) async {
    await updateFoodEntryUseCase(entry);
    await loadTodayEntries();
  }
  Future<void> deleteAllEntries() async {
    await deleteAllEntriesUseCase();
    await loadTodayEntries();
  }
  Future<List<DayHistory>> getHistory() {
    return getHistoryByDayUseCase();
  }
  Future<List<FoodEntry>> getRecentEntries() {
    return getRecentEntriesUseCase();
  }
  Future<int> copyPreviousDay() async {
    final count = await copyPreviousDayUseCase();
    if (count > 0) {
      await loadTodayEntries();
    }
    return count;
  }
}
