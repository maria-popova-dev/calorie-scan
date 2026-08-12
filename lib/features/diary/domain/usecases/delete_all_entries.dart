import '../repositories/diary_repository.dart';

class DeleteAllEntries {
  final DiaryRepository repository;

  DeleteAllEntries(this.repository);

  Future<void> call() {
    return repository.deleteAllEntries();
  }
}