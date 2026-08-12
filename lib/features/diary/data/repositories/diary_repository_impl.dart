import 'package:hive/hive.dart';
import '../../domain/entities/food_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../models/food_entry_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final Box<FoodEntryModel> box;

  DiaryRepositoryImpl(this.box);

  @override
  Future<void> addEntry(FoodEntry entry) async {
    final model = FoodEntryModel.fromEntity(entry);
    await box.put(model.id, model);
  }

  @override
  Future<void> updateEntry(FoodEntry entry) async {
    final model = FoodEntryModel.fromEntity(entry);
    await box.put(model.id, model);
  }

  @override
  Future<List<FoodEntry>> getEntriesForDate(DateTime date) async {
    return box.values
        .where((model) => _isSameDay(model.timestamp, date))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    await box.delete(id);
  }
  @override
  Future<List<FoodEntry>> getAllUniqueEntries() async {
    final seen = <String>{};
    final unique = <FoodEntry>[];

    final sorted = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    for (final model in sorted) {
      final entry = model.toEntity();
      final key = entry.name.toLowerCase();
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(entry);
      }
    }

    return unique;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
