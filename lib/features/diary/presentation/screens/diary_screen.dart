import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/diary_provider.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<DiaryProvider>();
    final entries = provider.todayEntries;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diaryTitle)),
      body: entries.isEmpty
          ? Center(child: Text(l10n.noEntriesToday))
          : ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return ListTile(
            title: Text(entry.name),
            subtitle: Text(
              '${l10n.proteinShort}: ${entry.protein.toStringAsFixed(1)} · ${l10n.fatShort}: ${entry.fat.toStringAsFixed(1)} · ${l10n.carbsShort}: ${entry.carbs.toStringAsFixed(1)}',
            ),
            trailing: Text('${entry.calories.toStringAsFixed(0)} ${l10n.caloriesLabel}'),
          );
        },
      ),
    );
  }
}