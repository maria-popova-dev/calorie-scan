import 'package:hive/hive.dart';
import '../../domain/entities/weight_entry.dart';

part 'weight_entry_model.g.dart';

@HiveType(typeId: 3)
class WeightEntryModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double weightKg;
  @HiveField(2)
  final DateTime timestamp;

  WeightEntryModel({
    required this.id,
    required this.weightKg,
    required this.timestamp,
  });

  factory WeightEntryModel.fromEntity(WeightEntry entity) {
    return WeightEntryModel(
      id: entity.id,
      weightKg: entity.weightKg,
      timestamp: entity.timestamp,
    );
  }

  WeightEntry toEntity() {
    return WeightEntry(id: id, weightKg: weightKg, timestamp: timestamp);
  }
}