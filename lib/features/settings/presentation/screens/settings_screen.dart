import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _goalController = TextEditingController(
      text: settings.dailyCalorieGoal.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_goalController.text);
    if (value == null || value <= 0) return;

    await context.read<SettingsProvider>().setDailyCalorieGoal(value);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily calorie goal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear today\'s entries?'),
                    content: const Text('This will delete everything logged today. Your saved custom foods stay in place for reuse. This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await context.read<DiaryProvider>().deleteAllEntries();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All entries cleared')),
                    );
                  }
                }
              },
              child: const Text('Clear today\'s entries'),
            ),
          ],
        ),
      ),
    );
  }
}