import '../entities/food_entry.dart';
import '../repositories/diary_repository.dart';

class GetTodayEntries {
  final DiaryRepository repository;

  GetTodayEntries(this.repository);

  Future<List<FoodEntry>> call() async {
    final entries = await repository.getEntriesForDate(DateTime.now());
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return entries;
  }
}
