import '../entities/food_entry.dart';
import '../repositories/diary_repository.dart';

class UpdateFoodEntry {
  final DiaryRepository repository;

  UpdateFoodEntry(this.repository);

  Future<void> call(FoodEntry entry) {
    return repository.updateEntry(entry);
  }
}