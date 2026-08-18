import '../entities/water_entry.dart';

abstract class WaterRepository {
  Future<void> addEntry(WaterEntry entry);
  Future<List<WaterEntry>> getEntriesForDate(DateTime date);
  Future<void> deleteEntry(String id);
}