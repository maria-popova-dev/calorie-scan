import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/custom_food.dart';
import '../../domain/repositories/custom_food_repository.dart';

class CustomFoodProvider extends ChangeNotifier {
  final CustomFoodRepository repository;

  CustomFoodProvider(this.repository);

  Future<void> saveCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double fat,
    required double carbs,
  }) async {
    final food = CustomFood(
      id: const Uuid().v4(),
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );

    await repository.saveCustomFood(food);
  }

  Future<List<CustomFood>> search(String query) {
    return repository.searchCustomFoods(query);
  }
  Future<int> count() async {
    final all = await repository.searchCustomFoods('');
    return all.length;
  }
}