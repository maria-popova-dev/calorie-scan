import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../diary/domain/entities/food_entry.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../data/services/cloud_vision_service.dart';
import '../../domain/nutrition_parser.dart';

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  final _picker = ImagePicker();
  final _ocrService = CloudVisionService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  File? _imageFile;
  bool _isProcessing = false;
  String? _rawText;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _isProcessing = true;
    });

    final text = await _ocrService.recognizeText(_imageFile!);
    final parsed = NutritionParser.parse(text);

    setState(() {
      _rawText = text;
      print('=== OCR raw text ===\n$text\n=== END ===');
      _isProcessing = false;
      if (parsed.calories != null) {
        _caloriesController.text = parsed.calories!.toStringAsFixed(0);
      }
      if (parsed.protein != null) {
        _proteinController.text = parsed.protein!.toStringAsFixed(1);
      }
      if (parsed.fat != null) {
        _fatController.text = parsed.fat!.toStringAsFixed(1);
      }
      if (parsed.carbs != null) {
        _carbsController.text = parsed.carbs!.toStringAsFixed(1);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<DiaryProvider>().addEntry(
      name: _nameController.text,
      calories: double.parse(_caloriesController.text),
      protein: double.tryParse(_proteinController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      source: FoodEntrySource.ocrLabel,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan label')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickAndScan(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _pickAndScan(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isProcessing) const CircularProgressIndicator(),
            if (_rawText != null) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Product name'),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(labelText: 'Calories (kcal, per 100g)'),
                      keyboardType: TextInputType.number,
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _proteinController,
                      decoration: const InputDecoration(labelText: 'Protein (g)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fatController,
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carbsController,
                      decoration: const InputDecoration(labelText: 'Carbs (g)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _save,
                      child: Text(l10n.saveButton),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}