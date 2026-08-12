import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../diary/domain/entities/food_entry.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../data/services/image_label_service.dart';
import '../../data/services/nutrition_lookup.dart';
import '../../data/services/usda_nutrition_service.dart';
import '../../domain/scale_nutrition.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const _genericLabels = {
    'food', 'cuisine', 'tableware', 'meal', 'dish', 'skin',
    'eyelash', 'saucer', 'flower', 'plate', 'recipe', 'ingredient',
    'vegetable', 'fruit',
  };
  final _picker = ImagePicker();
  final _labelService = ImageLabelService();
  final _usdaService = UsdaNutritionService();

  File? _imageFile;
  bool _isProcessing = false;
  String? _foodDescription;

  // Нутриенты на 100г (из USDA или локальной таблицы)
  double? _caloriesPer100g;
  double? _proteinPer100g;
  double? _fatPer100g;
  double? _carbsPer100g;

  final _weightController = TextEditingController(text: '150');

  @override
  void dispose() {
    _labelService.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _isProcessing = true;
      _foodDescription = null;
      _caloriesPer100g = null;
    });

    final labels = await _labelService.labelImage(_imageFile!);
    print('=== ML Kit labels: $labels ===');

    // Пытаемся найти данные через USDA API для каждого лейбла по очереди
    for (final label in labels) {
      if (_genericLabels.contains(label.toLowerCase())) continue;
      try {
        final result = await _usdaService.searchFood(label);
        print('=== USDA search "$label" -> ${result?.description} (${result?.calories} kcal) ===');
        if (result != null) {
          setState(() {
            _foodDescription = result.description;
            _caloriesPer100g = result.calories;
            _proteinPer100g = result.protein;
            _fatPer100g = result.fat;
            _carbsPer100g = result.carbs;
            _isProcessing = false;
          });
          return;
        }
      } catch (_) {
        // USDA недоступен — пробуем следующий лейбл или fallback ниже
      }
    }

    // Fallback — локальная таблица, если USDA ничего не нашёл
// Сначала ищем конкретное совпадение (не approximate)
    for (final label in labels) {
      if (_genericLabels.contains(label.toLowerCase())) continue;
      final estimate = NutritionLookup.lookup(label);
      if (estimate != null) {
        setState(() {
          _foodDescription = label;
          _caloriesPer100g = estimate.calories;
          _proteinPer100g = estimate.protein;
          _fatPer100g = estimate.fat;
          _carbsPer100g = estimate.carbs;
          _isProcessing = false;
        });
        return;
      }
    }
    // Если совсем ничего конкретного не нашли — берём общую категорию
    for (final label in labels) {
      final estimate = NutritionLookup.lookup(label);
      if (estimate != null) {
        setState(() {
          _foodDescription = label;
          _caloriesPer100g = estimate.calories;
          _proteinPer100g = estimate.protein;
          _fatPer100g = estimate.fat;
          _carbsPer100g = estimate.carbs;
          _isProcessing = false;
        });
        return;
      }
    }

    setState(() => _isProcessing = false);
  }
  Future<void> _saveEntry() async {
    if (_caloriesPer100g == null) return;

    final weight = double.tryParse(_weightController.text) ?? 100;

    final scaled = ScaleNutrition.call(
      caloriesPer100g: _caloriesPer100g!,
      proteinPer100g: _proteinPer100g!,
      fatPer100g: _fatPer100g!,
      carbsPer100g: _carbsPer100g!,
      actualWeightGrams: weight,
    );

    await context.read<DiaryProvider>().addEntry(
      name: _foodDescription!,
      calories: scaled.calories,
      protein: scaled.protein,
      fat: scaled.fat,
      carbs: scaled.carbs,
      source: FoodEntrySource.photoRecognition,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final weight = double.tryParse(_weightController.text) ?? 100;
    final scaled = _caloriesPer100g != null
        ? ScaleNutrition.call(
      caloriesPer100g: _caloriesPer100g!,
      proteinPer100g: _proteinPer100g!,
      fatPer100g: _fatPer100g!,
      carbsPer100g: _carbsPer100g!,
      actualWeightGrams: weight,
    )
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan food')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 250, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickAndAnalyze(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _pickAndAnalyze(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isProcessing) const CircularProgressIndicator(),
            if (!_isProcessing && _imageFile != null && _caloriesPer100g == null)
              const Text('Nothing recognized. Try another photo.'),
            if (scaled != null) ...[
              Text(
                _foodDescription!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Portion weight (g)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Text(
                '${scaled.calories.toStringAsFixed(0)} ${l10n.caloriesLabel}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                '${l10n.proteinShort}: ${scaled.protein.toStringAsFixed(1)} · '
                    '${l10n.fatShort}: ${scaled.fat.toStringAsFixed(1)} · '
                    '${l10n.carbsShort}: ${scaled.carbs.toStringAsFixed(1)}',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saveEntry,
                child: Text(l10n.saveButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}