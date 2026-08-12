import '../repositories/diary_repository.dart';

class DeleteFoodEntry {
  final DiaryRepository repository;

  DeleteFoodEntry(this.repository);

  Future<void> call(String id) {
    return repository.deleteEntry(id);
  }
}