import 'package:hive/hive.dart';
import '../../domain/entities/water_entry.dart';

part 'water_entry_model.g.dart';

@HiveType(typeId: 2)
class WaterEntryModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double amountMl;
  @HiveField(2)
  final DateTime timestamp;

  WaterEntryModel({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  factory WaterEntryModel.fromEntity(WaterEntry entity) {
    return WaterEntryModel(
      id: entity.id,
      amountMl: entity.amountMl,
      timestamp: entity.timestamp,
    );
  }

  WaterEntry toEntity() {
    return WaterEntry(id: id, amountMl: amountMl, timestamp: timestamp);
  }
}