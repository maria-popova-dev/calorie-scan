import 'package:hive/hive.dart';
import '../../domain/entities/custom_food.dart';
import '../../domain/repositories/custom_food_repository.dart';
import '../models/custom_food_model.dart';

class CustomFoodRepositoryImpl implements CustomFoodRepository {
  final Box<CustomFoodModel> box;

  CustomFoodRepositoryImpl(this.box);

  @override
  Future<void> saveCustomFood(CustomFood food) async {
    final model = CustomFoodModel.fromEntity(food);
    await box.put(model.id, model);
  }

  @override
  Future<List<CustomFood>> searchCustomFoods(String query) async {
    final lowerQuery = query.toLowerCase();
    return box.values
        .where((model) => model.name.toLowerCase().contains(lowerQuery))
        .map((model) => model.toEntity())
        .toList();
  }
}