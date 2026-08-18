import '../entities/water_entry.dart';
import '../repositories/water_repository.dart';

class AddWaterEntry {
  final WaterRepository repository;
  AddWaterEntry(this.repository);

  Future<void> call(WaterEntry entry) {
    return repository.addEntry(entry);
  }
}