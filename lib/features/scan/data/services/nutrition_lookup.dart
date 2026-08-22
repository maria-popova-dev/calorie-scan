class NutritionEstimate {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final bool isApproximate;

  const NutritionEstimate({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.isApproximate = false,
  });
}

class NutritionLookup {
  // Примерные значения на порцию (100г), для демо-версии.
  static const Map<String, NutritionEstimate> _table = {
    // Уже было
    'pizza': NutritionEstimate(calories: 266, protein: 11, fat: 10, carbs: 33),
    'banana': NutritionEstimate(calories: 89, protein: 1.1, fat: 0.3, carbs: 23),
    'apple': NutritionEstimate(calories: 52, protein: 0.3, fat: 0.2, carbs: 14),
    'salad': NutritionEstimate(calories: 33, protein: 2, fat: 0.5, carbs: 6),
    'bread': NutritionEstimate(calories: 265, protein: 9, fat: 3.2, carbs: 49),
    'rice': NutritionEstimate(calories: 130, protein: 2.7, fat: 0.3, carbs: 28),
    'chicken': NutritionEstimate(calories: 239, protein: 27, fat: 14, carbs: 0),
    'pasta': NutritionEstimate(calories: 131, protein: 5, fat: 1.1, carbs: 25),
    'egg': NutritionEstimate(calories: 155, protein: 13, fat: 11, carbs: 1.1),
    'orange': NutritionEstimate(calories: 47, protein: 0.9, fat: 0.1, carbs: 12),
    'donut': NutritionEstimate(calories: 452, protein: 4.9, fat: 25, carbs: 51),
    'doughnut': NutritionEstimate(calories: 452, protein: 4.9, fat: 25, carbs: 51),
    'pastry': NutritionEstimate(calories: 400, protein: 5, fat: 20, carbs: 48),
    'cake': NutritionEstimate(calories: 350, protein: 4, fat: 15, carbs: 50),
    'cookie': NutritionEstimate(calories: 480, protein: 5.5, fat: 22, carbs: 65),
    'sandwich': NutritionEstimate(calories: 250, protein: 10, fat: 9, carbs: 30),
    'burger': NutritionEstimate(calories: 295, protein: 17, fat: 14, carbs: 24),
    'sushi': NutritionEstimate(calories: 145, protein: 6, fat: 0.5, carbs: 30),
    'soup': NutritionEstimate(calories: 50, protein: 3, fat: 1.5, carbs: 7),
    'fries': NutritionEstimate(calories: 312, protein: 3.4, fat: 15, carbs: 41),

    // Фрукты
    'strawberry': NutritionEstimate(calories: 32, protein: 0.7, fat: 0.3, carbs: 7.7),
    'grape': NutritionEstimate(calories: 69, protein: 0.7, fat: 0.2, carbs: 18),
    'watermelon': NutritionEstimate(calories: 30, protein: 0.6, fat: 0.2, carbs: 8),
    'mango': NutritionEstimate(calories: 60, protein: 0.8, fat: 0.4, carbs: 15),
    'pineapple': NutritionEstimate(calories: 50, protein: 0.5, fat: 0.1, carbs: 13),
    'lemon': NutritionEstimate(calories: 29, protein: 1.1, fat: 0.3, carbs: 9),
    'peach': NutritionEstimate(calories: 39, protein: 0.9, fat: 0.3, carbs: 10),
    'pear': NutritionEstimate(calories: 57, protein: 0.4, fat: 0.1, carbs: 15),
    'avocado': NutritionEstimate(calories: 160, protein: 2, fat: 15, carbs: 9),
    'kiwi': NutritionEstimate(calories: 61, protein: 1.1, fat: 0.5, carbs: 15),

    // Овощи
    'carrot': NutritionEstimate(calories: 41, protein: 0.9, fat: 0.2, carbs: 10),
    'tomato': NutritionEstimate(calories: 18, protein: 0.9, fat: 0.2, carbs: 3.9),
    'potato': NutritionEstimate(calories: 77, protein: 2, fat: 0.1, carbs: 17),
    'broccoli': NutritionEstimate(calories: 34, protein: 2.8, fat: 0.4, carbs: 7),
    'cucumber': NutritionEstimate(calories: 15, protein: 0.7, fat: 0.1, carbs: 3.6),
    'onion': NutritionEstimate(calories: 40, protein: 1.1, fat: 0.1, carbs: 9),
    'corn': NutritionEstimate(calories: 86, protein: 3.2, fat: 1.2, carbs: 19),
    'mushroom': NutritionEstimate(calories: 22, protein: 3.1, fat: 0.3, carbs: 3.3),
    'pepper': NutritionEstimate(calories: 31, protein: 1, fat: 0.3, carbs: 6),

    // Мясо и белок
    'beef': NutritionEstimate(calories: 250, protein: 26, fat: 15, carbs: 0),
    'pork': NutritionEstimate(calories: 242, protein: 27, fat: 14, carbs: 0),
    'fish': NutritionEstimate(calories: 206, protein: 22, fat: 12, carbs: 0),
    'salmon': NutritionEstimate(calories: 208, protein: 20, fat: 13, carbs: 0),
    'shrimp': NutritionEstimate(calories: 99, protein: 24, fat: 0.3, carbs: 0.2),
    'bacon': NutritionEstimate(calories: 541, protein: 37, fat: 42, carbs: 1.4),
    'sausage': NutritionEstimate(calories: 301, protein: 12, fat: 27, carbs: 2),
    'steak': NutritionEstimate(calories: 271, protein: 25, fat: 19, carbs: 0),

    // Молочные продукты
    'cheese': NutritionEstimate(calories: 402, protein: 25, fat: 33, carbs: 1.3),
    'milk': NutritionEstimate(calories: 61, protein: 3.2, fat: 3.3, carbs: 4.8),
    'yogurt': NutritionEstimate(calories: 59, protein: 10, fat: 0.4, carbs: 3.6),
    'butter': NutritionEstimate(calories: 717, protein: 0.9, fat: 81, carbs: 0.1),
    'icecream': NutritionEstimate(calories: 207, protein: 3.5, fat: 11, carbs: 24),
    'ice cream': NutritionEstimate(calories: 207, protein: 3.5, fat: 11, carbs: 24),

    // Напитки
    'coffee': NutritionEstimate(calories: 2, protein: 0.3, fat: 0, carbs: 0),
    'tea': NutritionEstimate(calories: 1, protein: 0, fat: 0, carbs: 0.3),
    'juice': NutritionEstimate(calories: 45, protein: 0.5, fat: 0.1, carbs: 11),
    'wine': NutritionEstimate(calories: 83, protein: 0.1, fat: 0, carbs: 2.6),
    'beer': NutritionEstimate(calories: 43, protein: 0.5, fat: 0, carbs: 3.6),

    // Прочее
    'chocolate': NutritionEstimate(calories: 546, protein: 4.9, fat: 31, carbs: 61),
    'honey': NutritionEstimate(calories: 304, protein: 0.3, fat: 0, carbs: 82),
    'nuts': NutritionEstimate(calories: 607, protein: 20, fat: 54, carbs: 20),
    'popcorn': NutritionEstimate(calories: 375, protein: 11, fat: 4.3, carbs: 74),
    'noodle': NutritionEstimate(calories: 138, protein: 4.5, fat: 2.1, carbs: 25),
    'taco': NutritionEstimate(calories: 226, protein: 9, fat: 12, carbs: 20),
    'pancake': NutritionEstimate(calories: 227, protein: 6, fat: 8, carbs: 33),
    'waffle': NutritionEstimate(calories: 291, protein: 7.9, fat: 14, carbs: 34),
    'muffin': NutritionEstimate(calories: 377, protein: 6.5, fat: 15, carbs: 55),
    'bagel': NutritionEstimate(calories: 257, protein: 10, fat: 1.5, carbs: 50),
  };

  // Запасной вариант для общих категорий — грубая усреднённая оценка.
  static const Map<String, NutritionEstimate> _fallbackTable = {
    'food': NutritionEstimate(
        calories: 200, protein: 8, fat: 8, carbs: 25, isApproximate: true),
    'meal': NutritionEstimate(
        calories: 250, protein: 10, fat: 10, carbs: 28, isApproximate: true),
    'dish': NutritionEstimate(
        calories: 220, protein: 9, fat: 9, carbs: 26, isApproximate: true),
    'cuisine': NutritionEstimate(
        calories: 220, protein: 9, fat: 9, carbs: 26, isApproximate: true),
    'snack': NutritionEstimate(
        calories: 180, protein: 4, fat: 9, carbs: 22, isApproximate: true),
    'dessert': NutritionEstimate(
        calories: 320, protein: 4, fat: 15, carbs: 42, isApproximate: true),
    'fruit': NutritionEstimate(
        calories: 55, protein: 0.7, fat: 0.3, carbs: 14, isApproximate: true),
    'vegetable': NutritionEstimate(
        calories: 35, protein: 1.5, fat: 0.2, carbs: 7, isApproximate: true),
    'meat': NutritionEstimate(
        calories: 250, protein: 25, fat: 16, carbs: 0, isApproximate: true),
    'seafood': NutritionEstimate(
        calories: 150, protein: 20, fat: 6, carbs: 1, isApproximate: true),
    'baked goods': NutritionEstimate(
        calories: 350, protein: 6, fat: 14, carbs: 48, isApproximate: true),
    'beverage': NutritionEstimate(
        calories: 40, protein: 0.3, fat: 0, carbs: 10, isApproximate: true),
  };

  static NutritionEstimate? lookup(String label) {
    final key = label.toLowerCase();
    return _table[key] ?? _fallbackTable[key];
  }
}