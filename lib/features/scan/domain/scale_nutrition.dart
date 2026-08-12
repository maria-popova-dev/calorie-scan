class ScaleNutrition {
  /// Пересчитывает нутриенты с базовых 100г на реальный вес порции.
  static ({double calories, double protein, double fat, double carbs}) call({
    required double caloriesPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
    required double actualWeightGrams,
  }) {
    final ratio = actualWeightGrams / 100;
    return (
    calories: caloriesPer100g * ratio,
    protein: proteinPer100g * ratio,
    fat: fatPer100g * ratio,
    carbs: carbsPer100g * ratio,
    );
  }
}