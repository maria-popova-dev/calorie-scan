import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UsdaNutritionResult {
  final String description;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const UsdaNutritionResult({
    required this.description,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

class UsdaNutritionService {
  static const _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  static const _caloriesId = 1008;
  static const _proteinId = 1003;
  static const _fatId = 1004;
  static const _carbsId = 1005;

  /// Выполняет GET-запрос с автоматическим повтором при сетевых сбоях.
  /// Пробует до 3 раз с небольшой паузой между попытками.
  Future<http.Response> _getWithRetry(Uri uri, {int maxAttempts = 3}) async {
    Exception? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.get(uri).timeout(
          const Duration(seconds: 10),
        );

        if (response.statusCode == 200) {
          return response;
        }

        // Ошибки клиента (400, 401, 403, 404) — не имеет смысла повторять,
        // проблема не в сети, а в самом запросе
        if (response.statusCode >= 400 && response.statusCode < 500) {
          throw Exception('USDA API error: ${response.statusCode}');
        }

        // Ошибки сервера (500+) — стоит попробовать ещё раз
        lastError = Exception('USDA API error: ${response.statusCode}');
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
      }

      if (attempt < maxAttempts) {
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    throw lastError ?? Exception('USDA API request failed');
  }

  Future<UsdaNutritionResult?> searchFood(String query) async {
    final apiKey = dotenv.env['USDA_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('USDA_API_KEY не найден в .env файле');
    }

    final uri = Uri.parse('$_baseUrl/foods/search').replace(
      queryParameters: {
        'api_key': apiKey,
        'query': query,
        'pageSize': '5',
        'dataType': 'Foundation,SR Legacy,Survey',
      },
    );

    final response = await _getWithRetry(uri);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final foods = data['foods'] as List<dynamic>?;

    if (foods == null || foods.isEmpty) {
      return null;
    }

    final firstFood = foods.first as Map<String, dynamic>;
    final nutrients = firstFood['foodNutrients'] as List<dynamic>? ?? [];

    double findNutrient(int nutrientId) {
      for (final n in nutrients) {
        if (n['nutrientId'] == nutrientId) {
          return (n['value'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return 0.0;
    }

    return UsdaNutritionResult(
      description: firstFood['description'] as String? ?? query,
      calories: findNutrient(_caloriesId),
      protein: findNutrient(_proteinId),
      fat: findNutrient(_fatId),
      carbs: findNutrient(_carbsId),
    );
  }

  Future<List<UsdaNutritionResult>> searchFoodMultiple(String query) async {
    final apiKey = dotenv.env['USDA_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('USDA_API_KEY не найден в .env файле');
    }

    final uri = Uri.parse('$_baseUrl/foods/search').replace(
      queryParameters: {
        'api_key': apiKey,
        'query': query,
        'pageSize': '15',
        'dataType': 'Foundation,SR Legacy,Survey',
      },
    );

    final response = await _getWithRetry(uri);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final foods = data['foods'] as List<dynamic>? ?? [];

    double findNutrient(List<dynamic> nutrients, int nutrientId) {
      for (final n in nutrients) {
        if (n['nutrientId'] == nutrientId) {
          return (n['value'] as num?)?.toDouble() ?? 0.0;
        }
      }
      return 0.0;
    }

    return foods.map((food) {
      final foodMap = food as Map<String, dynamic>;
      final nutrients = foodMap['foodNutrients'] as List<dynamic>? ?? [];
      return UsdaNutritionResult(
        description: foodMap['description'] as String? ?? query,
        calories: findNutrient(nutrients, _caloriesId),
        protein: findNutrient(nutrients, _proteinId),
        fat: findNutrient(nutrients, _fatId),
        carbs: findNutrient(nutrients, _carbsId),
      );
    }).toList();
  }
}