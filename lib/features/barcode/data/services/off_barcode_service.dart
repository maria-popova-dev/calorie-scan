import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeProductResult {
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const BarcodeProductResult({
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

class OffBarcodeService {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  Future<BarcodeProductResult?> lookupBarcode(String barcode) async {
    final uri = Uri.parse('$_baseUrl/$barcode.json');

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'CalorieScan - Flutter - Version 1.0',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Open Food Facts API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 1) {
      return null;
    }

    final product = data['product'] as Map<String, dynamic>?;
    if (product == null) return null;

    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    final name = product['product_name'] as String? ?? 'Unknown product';

    double readNutrient(String key) {
      final value = nutriments[key];
      if (value == null) return 0.0;
      return (value as num).toDouble();
    }

    return BarcodeProductResult(
      name: name,
      calories: readNutrient('energy-kcal_100g'),
      protein: readNutrient('proteins_100g'),
      fat: readNutrient('fat_100g'),
      carbs: readNutrient('carbohydrates_100g'),
    );
  }
}
