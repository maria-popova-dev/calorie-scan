import 'package:hive/hive.dart';
import '../../domain/entities/food_entry.dart';

part 'food_entry_model.g.dart';

@HiveType(typeId: 0)
class FoodEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double calories;

  @HiveField(3)
  final double protein;

  @HiveField(4)
  final double fat;

  @HiveField(5)
  final double carbs;

  @HiveField(6)
  final DateTime timestamp;

  @HiveField(7)
  final int sourceIndex;

  FoodEntryModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.timestamp,
    required this.sourceIndex,
  });

  factory FoodEntryModel.fromEntity(FoodEntry entity) {
    return FoodEntryModel(
      id: entity.id,
      name: entity.name,
      calories: entity.calories,
      protein: entity.protein,
      fat: entity.fat,
      carbs: entity.carbs,
      timestamp: entity.timestamp,
      sourceIndex: entity.source.index,
    );
  }

  FoodEntry toEntity() {
    return FoodEntry(
      id: id,
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      timestamp: timestamp,
      source: FoodEntrySource.values[sourceIndex],
    );
  }
}
