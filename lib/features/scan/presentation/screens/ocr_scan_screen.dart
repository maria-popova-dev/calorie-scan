import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../diary/domain/entities/food_entry.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../data/services/ocr_service.dart';
import '../../domain/nutrition_parser.dart';

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  final _picker = ImagePicker();
  final _ocrService = OcrService();

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
    _ocrService.dispose();
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

    try {
      final text = await _ocrService.recognizeText(_imageFile!);
      final parsed = NutritionParser.parse(text);

      setState(() {
        _rawText = text;
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
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _rawText = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Scan failed: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          ),
        );
      }
    }
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

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _pickButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: const Color(0xFF34C759)),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
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
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                _pickButton(
                  icon: LucideIcons.camera,
                  label: 'Camera',
                  onTap: () => _pickAndScan(ImageSource.camera),
                ),
                const SizedBox(width: 12),
                _pickButton(
                  icon: LucideIcons.image,
                  label: 'Gallery',
                  onTap: () => _pickAndScan(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isProcessing) const CircularProgressIndicator(),
            if (_rawText != null) ...[
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _fieldDecoration('Product name'),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _caloriesController,
                      decoration: _fieldDecoration('Calories (kcal, per 100g)'),
                      keyboardType: TextInputType.number,
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _proteinController,
                      decoration: _fieldDecoration('Protein (g)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fatController,
                      decoration: _fieldDecoration('Fat (g)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _carbsController,
                      decoration: _fieldDecoration('Carbs (g)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _save,
                        child: Text(l10n.saveButton),
                      ),
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