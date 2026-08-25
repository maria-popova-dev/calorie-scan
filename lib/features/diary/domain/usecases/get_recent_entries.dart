import '../entities/food_entry.dart';
import '../repositories/diary_repository.dart';

class GetRecentEntries {
  final DiaryRepository repository;

  GetRecentEntries(this.repository);

  Future<List<FoodEntry>> call({int limit = 5}) async {
    final all = await repository.getAllUniqueEntries();
    return all.take(limit).toList();
  }
}