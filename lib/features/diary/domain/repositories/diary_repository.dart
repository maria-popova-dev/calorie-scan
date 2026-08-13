import '../entities/food_entry.dart';

abstract class DiaryRepository {
  Future<void> addEntry(FoodEntry entry);
  Future<List<FoodEntry>> getEntriesForDate(DateTime date);
  Future<void> deleteEntry(String id);
  Future<List<FoodEntry>> getAllUniqueEntries();
  Future<void> updateEntry(FoodEntry entry);
  Future<void> deleteAllEntries();
  Future<List<FoodEntry>> getAllEntries();
}
