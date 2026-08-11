class FoodEntry {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final DateTime timestamp;
  final FoodEntrySource source;

  const FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.timestamp,
    required this.source,
  });
}

enum FoodEntrySource {
  manual,
  ocrLabel,
  photoRecognition,
}
