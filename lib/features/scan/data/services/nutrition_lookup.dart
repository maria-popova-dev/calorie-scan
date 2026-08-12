class NutritionEstimate {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final bool isApproximate;

  const NutritionEstimate({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.isApproximate = false,
  });
}

class NutritionLookup {
  // Примерные значения на порцию (100г), для демо-версии.
  static const Map<String, NutritionEstimate> _table = {
    'pizza': NutritionEstimate(calories: 266, protein: 11, fat: 10, carbs: 33),
    'banana': NutritionEstimate(calories: 89, protein: 1.1, fat: 0.3, carbs: 23),
    'apple': NutritionEstimate(calories: 52, protein: 0.3, fat: 0.2, carbs: 14),
    'salad': NutritionEstimate(calories: 33, protein: 2, fat: 0.5, carbs: 6),
    'bread': NutritionEstimate(calories: 265, protein: 9, fat: 3.2, carbs: 49),
    'rice': NutritionEstimate(calories: 130, protein: 2.7, fat: 0.3, carbs: 28),
    'chicken': NutritionEstimate(calories: 239, protein: 27, fat: 14, carbs: 0),
    'pasta': NutritionEstimate(calories: 131, protein: 5, fat: 1.1, carbs: 25),
    'egg': NutritionEstimate(calories: 155, protein: 13, fat: 11, carbs: 1.1),
    'orange': NutritionEstimate(calories: 47, protein: 0.9, fat: 0.1, carbs: 12),
    'donut': NutritionEstimate(calories: 452, protein: 4.9, fat: 25, carbs: 51),
    'doughnut': NutritionEstimate(calories: 452, protein: 4.9, fat: 25, carbs: 51),
    'pastry': NutritionEstimate(calories: 400, protein: 5, fat: 20, carbs: 48),
    'cake': NutritionEstimate(calories: 350, protein: 4, fat: 15, carbs: 50),
    'cookie': NutritionEstimate(calories: 480, protein: 5.5, fat: 22, carbs: 65),
    'sandwich': NutritionEstimate(calories: 250, protein: 10, fat: 9, carbs: 30),
    'burger': NutritionEstimate(calories: 295, protein: 17, fat: 14, carbs: 24),
    'sushi': NutritionEstimate(calories: 145, protein: 6, fat: 0.5, carbs: 30),
    'soup': NutritionEstimate(calories: 50, protein: 3, fat: 1.5, carbs: 7),
    'fries': NutritionEstimate(calories: 312, protein: 3.4, fat: 15, carbs: 41),
  };

  // Запасной вариант для общих категорий — грубая усреднённая оценка.
  static const Map<String, NutritionEstimate> _fallbackTable = {
    'food': NutritionEstimate(
        calories: 200, protein: 8, fat: 8, carbs: 25, isApproximate: true),
    'meal': NutritionEstimate(
        calories: 250, protein: 10, fat: 10, carbs: 28, isApproximate: true),
    'dish': NutritionEstimate(
        calories: 220, protein: 9, fat: 9, carbs: 26, isApproximate: true),
    'cuisine': NutritionEstimate(
        calories: 220, protein: 9, fat: 9, carbs: 26, isApproximate: true),
    'snack': NutritionEstimate(
        calories: 180, protein: 4, fat: 9, carbs: 22, isApproximate: true),
    'dessert': NutritionEstimate(
        calories: 320, protein: 4, fat: 15, carbs: 42, isApproximate: true),
  };

  static NutritionEstimate? lookup(String label) {
    final key = label.toLowerCase();
    return _table[key] ?? _fallbackTable[key];
  }
}