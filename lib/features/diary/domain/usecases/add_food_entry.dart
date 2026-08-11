import '../entities/food_entry.dart';
import '../repositories/diary_repository.dart';

class AddFoodEntry {
  final DiaryRepository repository;

  AddFoodEntry(this.repository);

  Future<void> call(FoodEntry entry) {
    return repository.addEntry(entry);
  }
}
