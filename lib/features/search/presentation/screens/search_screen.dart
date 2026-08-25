import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../custom_foods/domain/entities/custom_food.dart';
import '../../../custom_foods/presentation/providers/custom_food_provider.dart';
import '../../../diary/domain/entities/food_entry.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../../scan/data/services/usda_nutrition_service.dart';
import '../../../scan/domain/scale_nutrition.dart';
import '../../../ads/data/services/rewarded_ad_service.dart';

InputDecoration _softFieldDecoration(String label) {
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

Widget _roundedButton({
  required VoidCallback? onPressed,
  required Widget child,
}) {
  return SizedBox(
    height: 52,
    child: FilledButton(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: child,
    ),
  );
}

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
  List<FoodEntry> _recentEntries = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final recent = await context.read<DiaryProvider>().getRecentEntries();
    if (mounted) {
      setState(() => _recentEntries = recent);
    }
  }

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

  Future<void> _reAddRecentEntry(FoodEntry entry) async {
    await context.read<DiaryProvider>().addEntry(
      name: entry.name,
      calories: entry.calories,
      protein: entry.protein,
      fat: entry.fat,
      carbs: entry.carbs,
      source: entry.source,
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
          if (_isSearching)
            const Padding(
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
    if (_queryController.text.isEmpty && _recentEntries.isNotEmpty) ...[
    Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
    'Recent',
    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600], fontSize: 13),
    ),
    ),
    ..._recentEntries.map((entry) => _FoodCard(
    icon: Icons.history,
    iconColor: Colors.grey[400]!,
    title: entry.name,
    subtitle: '${entry.calories.toStringAsFixed(0)} kcal',
    onTap: () => _reAddRecentEntry(entry),
    )),
    const SizedBox(height: 16),
    ],
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
              decoration: _softFieldDecoration('Portion weight (g)'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    '${scaled.calories.toStringAsFixed(0)} ${l10n.caloriesLabel}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.proteinShort}: ${scaled.protein.toStringAsFixed(1)} · '
                        '${l10n.fatShort}: ${scaled.fat.toStringAsFixed(1)} · '
                        '${l10n.carbsShort}: ${scaled.carbs.toStringAsFixed(1)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _roundedButton(onPressed: _save, child: Text(l10n.saveButton)),
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

    final premium = context.read<PremiumProvider>();
    if (!premium.isPremium) {
      final currentCount = await context.read<CustomFoodProvider>().search('');
      if (currentCount.length >= PremiumProvider.maxFreeCustomFoods) {
        if (context.mounted) {
          _showPremiumDialog();
        }
        return;
      }
    }

    if (!mounted) return;
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
  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom foods limit reached'),
        content: const Text(
          'You\'ve reached the free limit of custom foods. Watch a short ad to unlock full Premium access for 24 hours — unlimited custom foods, full history, and more.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final service = RewardedAdService();
              await service.loadAndShow(
                onReward: () {
                  if (mounted) {
                    context.read<PremiumProvider>().grantTempPremium(
                      const Duration(hours: 24),
                    );
                  }
                },
              );
            },
            child: const Text('Watch ad for 24h Premium'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
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
                decoration: _softFieldDecoration('Name'),
                validator: _validateRequired,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                decoration: _softFieldDecoration('Calories (kcal)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proteinController,
                decoration: _softFieldDecoration('Protein (g)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fatController,
                decoration: _softFieldDecoration('Fat (g)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carbsController,
                decoration: _softFieldDecoration('Carbs (g)'),
                keyboardType: TextInputType.number,
                validator: _validateNumber,
              ),
              const SizedBox(height: 24),
              _roundedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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