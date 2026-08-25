import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/calorie_calculator.dart';
import '../providers/settings_provider.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  final bool embedded;

  const CalorieCalculatorScreen({super.key, this.embedded = false});

  @override
  State<CalorieCalculatorScreen> createState() => _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  late Gender _gender;
  late int _age;
  late double _heightCm;
  late double _weightKg;
  late ActivityLevel _activityLevel;
  late WeightGoal _weightGoal;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _gender = settings.gender;
    _age = settings.age;
    _heightCm = settings.heightCm;
    _weightKg = settings.weightKg;
    _activityLevel = settings.activityLevel;
    _weightGoal = settings.weightGoal;
  }

  double get _calculatedGoal => CalorieCalculator.calculate(
    gender: _gender,
    age: _age,
    heightCm: _heightCm,
    weightKg: _weightKg,
    activityLevel: _activityLevel,
    weightGoal: _weightGoal,
  );

  Future<void> _persist() async {
    final settings = context.read<SettingsProvider>();
    await settings.saveCalculatorInputs(
      gender: _gender,
      age: _age,
      heightCm: _heightCm,
      weightKg: _weightKg,
      activityLevel: _activityLevel,
      weightGoal: _weightGoal,
    );
    await settings.setDailyCalorieGoal(_calculatedGoal);
  }

  Future<void> _save() async {
    await _persist();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
        SegmentedButton<Gender>(
          segments: const [
            ButtonSegment(value: Gender.male, label: Text('Male')),
            ButtonSegment(value: Gender.female, label: Text('Female')),
          ],
          selected: {_gender},
          onSelectionChanged: (selected) {
            setState(() => _gender = selected.first);
            if (widget.embedded) _persist();
          },
        ),
        const SizedBox(height: 20),
        Text('Age: $_age', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _age.toDouble(),
          min: 14,
          max: 90,
          divisions: 76,
          label: '$_age',
          onChanged: (value) {
            setState(() => _age = value.round());
            if (widget.embedded) _persist();
          },
        ),
        const SizedBox(height: 12),
        Text('Height: ${_heightCm.toStringAsFixed(0)} cm',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _heightCm,
          min: 120,
          max: 220,
          divisions: 100,
          label: '${_heightCm.toStringAsFixed(0)} cm',
          onChanged: (value) {
            setState(() => _heightCm = value);
            if (widget.embedded) _persist();
          },
        ),
        const SizedBox(height: 12),
        Text('Weight: ${_weightKg.toStringAsFixed(0)} kg',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _weightKg,
          min: 30,
          max: 200,
          divisions: 170,
          label: '${_weightKg.toStringAsFixed(0)} kg',
          onChanged: (value) {
            setState(() => _weightKg = value);
            if (widget.embedded) _persist();
          },
        ),
        const SizedBox(height: 20),
        const Text('Activity level', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<ActivityLevel>(
          segments: const [
            ButtonSegment(value: ActivityLevel.sedentary, label: Text('Low')),
            ButtonSegment(value: ActivityLevel.light, label: Text('Light')),
            ButtonSegment(value: ActivityLevel.moderate, label: Text('Moderate')),
            ButtonSegment(value: ActivityLevel.active, label: Text('High')),
          ],
          selected: {_activityLevel},
          onSelectionChanged: (selected) {
            setState(() => _activityLevel = selected.first);
            if (widget.embedded) _persist();
          },
        ),
        const SizedBox(height: 20),
        const Text('Goal', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<WeightGoal>(
          segments: const [
            ButtonSegment(value: WeightGoal.lose, label: Text('Lose')),
            ButtonSegment(value: WeightGoal.maintain, label: Text('Maintain')),
            ButtonSegment(value: WeightGoal.gain, label: Text('Gain')),
          ],
          selected: {_weightGoal},
          onSelectionChanged: (selected) {
            setState(() => _weightGoal = selected.first);
            if (widget.embedded) _persist();
          },
        ),
        const SizedBox(height: 32),
        Center(
          child: Column(
            children: [
              Text(
                '${_calculatedGoal.toStringAsFixed(0)} kcal/day',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text('Your calculated goal', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        if (!widget.embedded) ...[
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Use this goal'),
          ),
        ],
      ],
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calculate my goal')),
      body: content,
    );
  }
}