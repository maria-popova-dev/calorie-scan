import '../entities/food_entry.dart';
import '../repositories/diary_repository.dart';

class GetCustomFoods {
  final DiaryRepository repository;

  GetCustomFoods(this.repository);

  Future<List<FoodEntry>> call(String query) async {
    if (query.trim().isEmpty) return [];

    final all = await repository.getAllUniqueEntries();
    final lowerQuery = query.toLowerCase();

    return all.where((entry) => entry.name.toLowerCase().contains(lowerQuery)).toList();
  }
}