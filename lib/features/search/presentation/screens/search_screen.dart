import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../custom_foods/domain/entities/custom_food.dart';
import '../../../custom_foods/presentation/providers/custom_food_provider.dart';
import '../../../diary/domain/entities/food_entry.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../scan/data/services/usda_nutrition_service.dart';
import '../../../scan/domain/scale_nutrition.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _usdaService = UsdaNutritionService();
  final _queryController = TextEditingController();

  List<UsdaNutritionResult> _results = [];
  List<CustomFood> _customResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final customFoods = await context.read<CustomFoodProvider>().search(query);
    if (!mounted) return;

    try {
      final results = await _usdaService.searchFoodMultiple(query);
      if (!mounted) return;
      setState(() {
        _customResults = customFoods;
        _results = results;
        _errorMessage = results.isEmpty && customFoods.isEmpty
            ? 'No USDA results. Try an English name, or add as custom food below.'
            : null;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _customResults = customFoods;
        _errorMessage = 'Connection error. Showing your custom foods only.';
        _isSearching = false;
      });
    }
  }

  void _openDetail(UsdaNutritionResult result) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FoodDetailScreen(result: result),
      ),
    );
  }

  Future<void> _reAddCustomFood(CustomFood food) async {
    await context.read<DiaryProvider>().addEntry(
      name: food.name,
      calories: food.calories,
      protein: food.protein,
      fat: food.fat,
      carbs: food.carbs,
      source: FoodEntrySource.manual,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openCreateCustom() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CreateCustomFoodScreen(initialName: _queryController.text.trim()),
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search food')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'e.g. banana, chicken breast',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_isSearching) const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                if (_customResults.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Your foods',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF34C759),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ..._customResults.map((food) => _FoodCard(
                    icon: Icons.star,
                    iconColor: const Color(0xFF34C759),
                    title: food.name,
                    subtitle: '${food.calories.toStringAsFixed(0)} kcal',
                    onTap: () => _reAddCustomFood(food),
                  )),
                  const SizedBox(height: 16),
                ],
                if (_results.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'USDA database',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  ..._results.map((result) => _FoodCard(
                    icon: Icons.restaurant,
                    iconColor: Colors.grey[400]!,
                    title: result.description,
                    subtitle: '${result.calories.toStringAsFixed(0)} kcal / 100g',
                    onTap: () => _openDetail(result),
                  )),
                ],
                if (!_isSearching &&
                    _customResults.isEmpty &&
                    _results.isEmpty &&
                    _queryController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text('Nothing found.', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _openCreateCustom,
                          icon: const Icon(Icons.add),
                          label: const Text('Add as custom food'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FoodCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[300], size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodDetailScreen extends StatefulWidget {
  final UsdaNutritionResult result;

  const _FoodDetailScreen({required this.result});

  @override
  State<_FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<_FoodDetailScreen> {
  final _weightController = TextEditingController(text: '100');

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final weight = double.tryParse(_weightController.text) ?? 100;
    final scaled = ScaleNutrition.call(
      caloriesPer100g: widget.result.calories,
      proteinPer100g: widget.result.protein,
      fatPer100g: widget.result.fat,
      carbsPer100g: widget.result.carbs,
      actualWeightGrams: weight,
    );

    await context.read<DiaryProvider>().addEntry(
      name: widget.result.description,
      calories: scaled.calories,
      protein: scaled.protein,
      fat: scaled.fat,
      carbs: scaled.carbs,
      source: FoodEntrySource.manual,
    );

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weight = double.tryParse(_weightController.text) ?? 100;
    final scaled = ScaleNutrition.call(
      caloriesPer100g: widget.result.calories,
      proteinPer100g: widget.result.protein,
      fatPer100g: widget.result.fat,
      carbsPer100g: widget.result.carbs,
      actualWeightGrams: weight,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.result.description)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Portion weight (g)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text(
              '${scaled.calories.toStringAsFixed(0)} ${l10n.caloriesLabel}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              '${l10n.proteinShort}: ${scaled.protein.toStringAsFixed(1)} · '
                  '${l10n.fatShort}: ${scaled.fat.toStringAsFixed(1)} · '
                  '${l10n.carbsShort}: ${scaled.carbs.toStringAsFixed(1)}',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCustomFoodScreen extends StatefulWidget {
  final String initialName;

  const _CreateCustomFoodScreen({required this.initialName});

  @override
  State<_CreateCustomFoodScreen> createState() => _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState extends State<_CreateCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(text: widget.initialName);
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

    final name = _nameController.text;
    final calories = double.parse(_caloriesController.text);
    final protein = double.parse(_proteinController.text);
    final fat = double.parse(_fatController.text);
    final carbs = double.parse(_carbsController.text);

    await context.read<CustomFoodProvider>().saveCustomFood(
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );

    if (!mounted) return;
    await context.read<DiaryProvider>().addEntry(
      name: name,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      source: FoodEntrySource.manual,
    );

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (double.tryParse(value) == null) return 'Enter a number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Add custom food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}