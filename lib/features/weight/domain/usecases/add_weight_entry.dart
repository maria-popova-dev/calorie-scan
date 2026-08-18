import '../entities/weight_entry.dart';
import '../repositories/weight_repository.dart';

class AddWeightEntry {
  final WeightRepository repository;
  AddWeightEntry(this.repository);

  Future<void> call(WeightEntry entry) {
    return repository.addEntry(entry);
  }
}