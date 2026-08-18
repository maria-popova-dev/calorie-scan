import '../repositories/weight_repository.dart';

class DeleteWeightEntry {
  final WeightRepository repository;
  DeleteWeightEntry(this.repository);

  Future<void> call(String id) {
    return repository.deleteEntry(id);
  }
}