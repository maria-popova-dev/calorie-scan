import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudVisionService {
  Future<String> recognizeText(File imageFile) async {
    final apiKey = dotenv.env['GOOGLE_VISION_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GOOGLE_VISION_API_KEY не найден в .env файле');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final uri = Uri.parse(
      'https://vision.googleapis.com/v1/images:annotate?key=$apiKey',
    );

    final body = jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'TEXT_DETECTION'},
          ],
        },
      ],
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Cloud Vision API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final responses = data['responses'] as List<dynamic>?;

    if (responses == null || responses.isEmpty) {
      return '';
    }

    final firstResponse = responses.first as Map<String, dynamic>;
    final textAnnotations = firstResponse['textAnnotations'] as List<dynamic>?;

    if (textAnnotations == null || textAnnotations.isEmpty) {
      return '';
    }

    // Первый элемент содержит весь распознанный текст целиком
    return textAnnotations.first['description'] as String? ?? '';
  }
}