import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/diary_provider.dart';
import '../widgets/calorie_ring.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _warningShownThisSession = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<DiaryProvider>();
    final settings = context.watch<SettingsProvider>();
    final total = provider.dailyTotal;

    final isOverGoal = total.calories > settings.dailyCalorieGoal;

    if (isOverGoal && !_warningShownThisSession) {
      _warningShownThisSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You\'ve exceeded your daily goal of ${settings.dailyCalorieGoal.toStringAsFixed(0)} kcal',
              ),
              backgroundColor: const Color(0xFFFF3B30),
            ),
          );
        }
      });
    } else if (!isOverGoal) {
      _warningShownThisSession = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            CalorieRing(
              consumed: total.calories,
              goal: settings.dailyCalorieGoal,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MacroStat(
                    label: l10n.proteinLabel,
                    value: total.protein,
                  ),
                  _MacroStat(
                    label: l10n.fatLabel,
                    value: total.fat,
                  ),
                  _MacroStat(
                    label: l10n.carbsLabel,
                    value: total.carbs,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.entriesToday(provider.todayEntries.length),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  final String label;
  final double value;

  const _MacroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(0),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}