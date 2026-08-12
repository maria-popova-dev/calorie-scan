import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/food_entry.dart';
import '../../domain/usecases/add_food_entry.dart';
import '../../domain/usecases/get_today_entries.dart';
import '../../domain/usecases/calculate_daily_total.dart';
import '../../domain/usecases/get_custom_foods.dart';

class DiaryProvider extends ChangeNotifier {
  final AddFoodEntry addFoodEntryUseCase;
  final GetTodayEntries getTodayEntriesUseCase;
  final CalculateDailyTotal calculateDailyTotalUseCase;
  final GetCustomFoods getCustomFoodsUseCase;

  DiaryProvider({
    required this.addFoodEntryUseCase,
    required this.getTodayEntriesUseCase,
    required this.calculateDailyTotalUseCase,
    required this.getCustomFoodsUseCase,
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
    );

    await addFoodEntryUseCase(entry);
    await loadTodayEntries();
  }
  Future<List<FoodEntry>> searchCustomFoods(String query) {
    return getCustomFoodsUseCase(query);
  }
}
