import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../notifications/data/services/notification_service.dart';
import '../providers/settings_provider.dart';
import 'calorie_calculator_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _goalController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _goalController = TextEditingController(
      text: settings.dailyCalorieGoal.toStringAsFixed(0),
    );
    _nameController = TextEditingController(text: settings.userName);
  }

  @override
  void dispose() {
    _goalController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_goalController.text);
    if (value == null || value <= 0) return;

    final settings = context.read<SettingsProvider>();
    await settings.setDailyCalorieGoal(value);
    await settings.setUserName(_nameController.text.trim());

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _toggleMealReminder(SettingsProvider settings, bool enabled) async {
    await settings.setMealReminder(enabled: enabled);
    final notifications = NotificationService();
    if (enabled) {
      await notifications.requestPermissions();
      await notifications.scheduleDailyReminder(
        id: 1,
        hour: settings.mealReminderHour,
        minute: 0,
        title: 'Time to log your meal',
        body: 'Don\'t forget to track what you ate today',
      );
    } else {
      await notifications.cancelReminder(1);
    }
  }

  Future<void> _toggleWaterReminder(SettingsProvider settings, bool enabled) async {
    await settings.setWaterReminder(enabled: enabled);
    final notifications = NotificationService();
    if (enabled) {
      await notifications.requestPermissions();
      await notifications.scheduleDailyReminder(
        id: 2,
        hour: settings.waterReminderHour,
        minute: 0,
        title: 'Stay hydrated!',
        body: 'Time to log your water intake',
      );
    } else {
      await notifications.cancelReminder(2);
    }
  }

  Future<void> _pickMealReminderTime(SettingsProvider settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.mealReminderHour, minute: 0),
    );
    if (picked != null) {
      await settings.setMealReminder(enabled: true, hour: picked.hour);
      await NotificationService().scheduleDailyReminder(
        id: 1,
        hour: picked.hour,
        minute: 0,
        title: 'Time to log your meal',
        body: 'Don\'t forget to track what you ate today',
      );
    }
  }

  Future<void> _pickWaterReminderTime(SettingsProvider settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.waterReminderHour, minute: 0),
    );
    if (picked != null) {
      await settings.setWaterReminder(enabled: true, hour: picked.hour);
      await NotificationService().scheduleDailyReminder(
        id: 2,
        hour: picked.hour,
        minute: 0,
        title: 'Stay hydrated!',
        body: 'Time to log your water intake',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            maxLength: 15,
            decoration: InputDecoration(
              labelText: 'First name',
              filled: true,
              fillColor: Colors.white,
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Daily calorie goal',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalorieCalculatorScreen()),
              );
              if (result == null && context.mounted) {
                final settings = context.read<SettingsProvider>();
                _goalController.text = settings.dailyCalorieGoal.toStringAsFixed(0);
              }
            },
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calculate my goal instead'),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Meal reminder', style: TextStyle(fontSize: 14)),
                    subtitle: GestureDetector(
                      onTap: settings.mealReminderEnabled
                          ? () => _pickMealReminderTime(settings)
                          : null,
                      child: Text(
                        'Daily at ${settings.mealReminderHour.toString().padLeft(2, '0')}:00 ${settings.mealReminderEnabled ? '(tap to change)' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    value: settings.mealReminderEnabled,
                    activeThumbColor: const Color(0xFF34C759),
                    onChanged: (value) => _toggleMealReminder(settings, value),
                  ),
                ),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Water reminder', style: TextStyle(fontSize: 14)),
                    subtitle: GestureDetector(
                      onTap: settings.waterReminderEnabled
                          ? () => _pickWaterReminderTime(settings)
                          : null,
                      child: Text(
                        'Daily at ${settings.waterReminderHour.toString().padLeft(2, '0')}:00 ${settings.waterReminderEnabled ? '(tap to change)' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    value: settings.waterReminderEnabled,
                    activeThumbColor: const Color(0xFF34C759),
                    onChanged: (value) => _toggleWaterReminder(settings, value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Danger zone',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFF3B30)),
                ),
                const SizedBox(height: 4),
                Text(
                  'This will delete everything logged today. Your saved custom foods stay in place for reuse.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF3B30),
                      side: const BorderSide(color: Color(0xFFFF3B30)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear today\'s entries?'),
                          content: const Text(
                            'This will delete everything logged today. Your saved custom foods stay in place for reuse. This cannot be undone.',
                          ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}