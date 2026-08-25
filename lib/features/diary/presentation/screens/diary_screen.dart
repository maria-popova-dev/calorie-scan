import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/food_entry.dart';
import '../providers/diary_provider.dart';
import 'edit_entry_screen.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  static const _mealOrder = [
    MealType.breakfast,
    MealType.lunch,
    MealType.dinner,
    MealType.snack,
  ];

  String _mealLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  IconData _mealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.dinner:
        return Icons.dinner_dining_outlined;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<DiaryProvider>();
    final entries = provider.todayEntries;

    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.diaryTitle)),
        body: Center(
          child: Text(
            l10n.noEntriesToday,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    // Группируем записи по типу приёма пищи
    final Map<MealType, List<FoodEntry>> grouped = {};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaryTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          for (final mealType in _mealOrder)
            if (grouped[mealType] != null) ...[
              _MealSectionHeader(
                icon: _mealIcon(mealType),
                label: _mealLabel(mealType),
                totalCalories: grouped[mealType]!
                    .fold<double>(0, (sum, e) => sum + e.calories),
              ),
              const SizedBox(height: 8),
              ...grouped[mealType]!.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context.read<DiaryProvider>().deleteEntry(entry.id);
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditEntryScreen(entry: entry)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.proteinShort}: ${entry.protein.toStringAsFixed(1)} · ${l10n.fatShort}: ${entry.fat.toStringAsFixed(1)} · ${l10n.carbsShort}: ${entry.carbs.toStringAsFixed(1)}',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${entry.calories.toStringAsFixed(0)} ${l10n.caloriesLabel}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF34C759),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _MealSectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final double totalCalories;

  const _MealSectionHeader({
    required this.icon,
    required this.label,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF34C759)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          '${totalCalories.toStringAsFixed(0)} kcal',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }
}