import 'package:hive/hive.dart';
import '../../domain/entities/custom_food.dart';

part 'custom_food_model.g.dart';

@HiveType(typeId: 1)
class CustomFoodModel extends HiveObject {
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

  CustomFoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory CustomFoodModel.fromEntity(CustomFood entity) {
    return CustomFoodModel(
      id: entity.id,
      name: entity.name,
      calories: entity.calories,
      protein: entity.protein,
      fat: entity.fat,
      carbs: entity.carbs,
    );
  }

  CustomFood toEntity() {
    return CustomFood(
      id: id,
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );
  }
}