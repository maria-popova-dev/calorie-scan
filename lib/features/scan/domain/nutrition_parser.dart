class ParsedNutrition {
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;

  const ParsedNutrition({
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
  });

  bool get hasAnyData =>
      calories != null || protein != null || fat != null || carbs != null;
}

class NutritionParser {
  static ParsedNutrition parse(String rawText) {
    final calories = _extractNumber(rawText, [
      r'calor(?:ies)?',
      r'энерг',
      r'ккал',
      r'kcal',
    ]);
    final protein = _extractNumber(rawText, [
      r'protein',
      r'белк',
      r'белок',
    ]);
    final fat = _extractNumber(rawText, [
      r'total fat',
      r'fat',
      r'жир',
    ]);
    final carbs = _extractNumber(rawText, [
      r'total carbohydrate',
      r'carbohydrate',
      r'carbs',
      r'углевод',
    ]);

    return ParsedNutrition(
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );
  }

  static double? _extractNumber(String text, List<String> keywords) {
    for (final keyword in keywords) {
      final pattern = RegExp(
        '$keyword[^\\d]{0,10}(\\d+[.,]?\\d*)',
        caseSensitive: false,
      );
      final match = pattern.firstMatch(text);
      if (match != null) {
        final numberStr = match.group(1)?.replaceAll(',', '.');
        final value = double.tryParse(numberStr ?? '');
        if (value != null) return value;
      }
    }
    return null;
  }
}