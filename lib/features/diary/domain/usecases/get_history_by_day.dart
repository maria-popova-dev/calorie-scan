import '../entities/food_entry.dart';
import '../repositories/diary_repository.dart';

class DayHistory {
  final DateTime date;
  final List<FoodEntry> entries;
  final double totalCalories;

  const DayHistory({
    required this.date,
    required this.entries,
    required this.totalCalories,
  });
}

class GetHistoryByDay {
  final DiaryRepository repository;

  GetHistoryByDay(this.repository);

  Future<List<DayHistory>> call() async {
    final all = await repository.getAllEntries();

    // Группируем записи по дате (без времени)
    final Map<DateTime, List<FoodEntry>> grouped = {};
    for (final entry in all) {
      final dayKey = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      grouped.putIfAbsent(dayKey, () => []).add(entry);
    }

    final result = grouped.entries.map((mapEntry) {
      final totalCalories = mapEntry.value.fold<double>(
        0,
            (sum, e) => sum + e.calories,
      );
      return DayHistory(
        date: mapEntry.key,
        entries: mapEntry.value,
        totalCalories: totalCalories,
      );
    }).toList();

    // Сортируем от новых дней к старым
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }
}