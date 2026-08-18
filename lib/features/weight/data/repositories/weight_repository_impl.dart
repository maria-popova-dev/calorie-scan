import 'package:hive/hive.dart';
import '../../domain/entities/weight_entry.dart';
import '../../domain/repositories/weight_repository.dart';
import '../models/weight_entry_model.dart';

class WeightRepositoryImpl implements WeightRepository {
  final Box<WeightEntryModel> box;

  WeightRepositoryImpl(this.box);

  @override
  Future<void> addEntry(WeightEntry entry) async {
    final model = WeightEntryModel.fromEntity(entry);
    await box.put(model.id, model);
  }

  @override
  Future<List<WeightEntry>> getAllEntries() async {
    final sorted = box.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteEntry(String id) async {
    await box.delete(id);
  }
}