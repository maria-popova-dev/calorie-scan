import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/food_entry.dart';
import '../providers/diary_provider.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await context.read<DiaryProvider>().addEntry(
      name: _nameController.text,
      calories: double.parse(_caloriesController.text),
      protein: double.parse(_proteinController.text),
      fat: double.parse(_fatController.text),
      carbs: double.parse(_carbsController.text),
      source: FoodEntrySource.manual,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String? validateRequired(String? value) {
      if (value == null || value.trim().isEmpty) {
        return l10n.requiredField;
      }
      return null;
    }

    String? validateNumber(String? value) {
      if (value == null || value.trim().isEmpty) {
        return l10n.requiredField;
      }
      if (double.tryParse(value) == null) {
        return l10n.enterNumber;
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addProductTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.nameLabel),
                validator: validateRequired,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(labelText: l10n.caloriesLabel),
                keyboardType: TextInputType.number,
                validator: validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proteinController,
                decoration: InputDecoration(labelText: l10n.proteinLabel),
                keyboardType: TextInputType.number,
                validator: validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fatController,
                decoration: InputDecoration(labelText: l10n.fatLabel),
                keyboardType: TextInputType.number,
                validator: validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carbsController,
                decoration: InputDecoration(labelText: l10n.carbsLabel),
                keyboardType: TextInputType.number,
                validator: validateNumber,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}