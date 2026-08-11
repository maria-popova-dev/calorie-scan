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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
