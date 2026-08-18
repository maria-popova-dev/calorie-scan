import '../entities/weight_entry.dart';

abstract class WeightRepository {
  Future<void> addEntry(WeightEntry entry);
  Future<List<WeightEntry>> getAllEntries();
  Future<void> deleteEntry(String id);
}