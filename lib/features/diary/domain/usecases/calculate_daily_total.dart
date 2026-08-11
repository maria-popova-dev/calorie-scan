import '../entities/food_entry.dart';

class DailyTotal {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const DailyTotal({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

class CalculateDailyTotal {
  DailyTotal call(List<FoodEntry> entries) {
    double calories = 0;
    double protein = 0;
    double fat = 0;
    double carbs = 0;

    for (final entry in entries) {
      calories += entry.calories;
      protein += entry.protein;
      fat += entry.fat;
      carbs += entry.carbs;
    }

    return DailyTotal(
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );
  }
}
