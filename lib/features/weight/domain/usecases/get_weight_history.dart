import '../entities/weight_entry.dart';
import '../repositories/weight_repository.dart';

class GetWeightHistory {
  final WeightRepository repository;
  GetWeightHistory(this.repository);

  Future<List<WeightEntry>> call() {
    return repository.getAllEntries();
  }
}