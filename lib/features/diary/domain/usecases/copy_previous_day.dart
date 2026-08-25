import 'package:uuid/uuid.dart';
import '../entities/food_entry.dart';
import '../repositories/diary_repository.dart';

class CopyPreviousDay {
  final DiaryRepository repository;

  CopyPreviousDay(this.repository);

  /// Копирует все записи за вчерашний день на сегодня с новым временем.
  /// Возвращает количество скопированных записей.
  Future<int> call() async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayEntries = await repository.getEntriesForDate(yesterday);

    if (yesterdayEntries.isEmpty) return 0;

    final now = DateTime.now();
    for (final entry in yesterdayEntries) {
      final copy = FoodEntry(
        id: const Uuid().v4(),
        name: entry.name,
        calories: entry.calories,
        protein: entry.protein,
        fat: entry.fat,
        carbs: entry.carbs,
        timestamp: now,
        source: entry.source,
        mealType: entry.mealType,
      );
      await repository.addEntry(copy);
    }

    return yesterdayEntries.length;
  }
}
