import 'package:hive/hive.dart';
import '../../domain/entities/water_entry.dart';
import '../../domain/repositories/water_repository.dart';
import '../models/water_entry_model.dart';

class WaterRepositoryImpl implements WaterRepository {
  final Box<WaterEntryModel> box;

  WaterRepositoryImpl(this.box);

  @override
  Future<void> addEntry(WaterEntry entry) async {
    final model = WaterEntryModel.fromEntity(entry);
    await box.put(model.id, model);
  }

  @override
  Future<List<WaterEntry>> getEntriesForDate(DateTime date) async {
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