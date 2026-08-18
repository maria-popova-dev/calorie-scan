import '../repositories/water_repository.dart';

class DeleteWaterEntry {
  final WaterRepository repository;
  DeleteWaterEntry(this.repository);

  Future<void> call(String id) {
    return repository.deleteEntry(id);
  }
}