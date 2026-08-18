import '../entities/water_entry.dart';
import '../repositories/water_repository.dart';

class GetTodayWaterEntries {
  final WaterRepository repository;
  GetTodayWaterEntries(this.repository);

  Future<List<WaterEntry>> call() {
    return repository.getEntriesForDate(DateTime.now());
  }
}