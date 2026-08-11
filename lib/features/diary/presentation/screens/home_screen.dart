import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/diary_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<DiaryProvider>();
    final total = provider.dailyTotal;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${total.calories.toStringAsFixed(0)} ${l10n.caloriesLabel}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('${l10n.proteinLabel}: ${total.protein.toStringAsFixed(1)}'),
            Text('${l10n.fatLabel}: ${total.fat.toStringAsFixed(1)}'),
            Text('${l10n.carbsLabel}: ${total.carbs.toStringAsFixed(1)}'),
            const SizedBox(height: 24),
            Text(l10n.entriesToday(provider.todayEntries.length)),
          ],
        ),
      ),
    );
  }
}