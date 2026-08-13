import '../../domain/entities/custom_food.dart';

abstract class CustomFoodRepository {
  Future<void> saveCustomFood(CustomFood food);
  Future<List<CustomFood>> searchCustomFoods(String query);
}