import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../diary/domain/entities/food_entry.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../scan/domain/scale_nutrition.dart';
import '../../data/services/off_barcode_service.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _service = OffBarcodeService();
  final _weightController = TextEditingController(text: '100');

  bool _isLoading = false;
  bool _hasScanned = false;
  BarcodeProductResult? _result;
  String? _errorMessage;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_hasScanned || _isLoading) return;

    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() {
      _hasScanned = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.lookupBarcode(barcode);
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
        _errorMessage = result == null ? 'Product not found for this barcode.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lookup failed. Check your connection.';
      });
    }
  }

  void _scanAgain() {
    setState(() {
      _hasScanned = false;
      _result = null;
      _errorMessage = null;
    });
  }

  Future<void> _save() async {
    final result = _result;
    if (result == null) return;

    final weight = double.tryParse(_weightController.text) ?? 100;
    final scaled = ScaleNutrition.call(
      caloriesPer100g: result.calories,
      proteinPer100g: result.protein,
      fatPer100g: result.fat,
      carbsPer100g: result.carbs,
      actualWeightGrams: weight,
    );

    await context.read<DiaryProvider>().addEntry(
          name: result.name,
          calories: scaled.calories,
          protein: scaled.protein,
          fat: scaled.fat,
          carbs: scaled.carbs,
          source: FoodEntrySource.manual,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      body: Column(
        children: [
          if (!_hasScanned)
            Expanded(
              child: MobileScanner(onDetect: _onDetect),
            ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _scanAgain,
                        child: const Text('Scan again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_result != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _result!.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Portion weight (g)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _scanAgain,
                      child: const Text('Scan another product'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
