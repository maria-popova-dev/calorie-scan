import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../providers/diary_provider.dart';
import '../widgets/calorie_ring.dart';
import 'history_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../water/presentation/widgets/water_card.dart';
import '../../../weight/presentation/widgets/weight_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _warningShownThisSession = false;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate() {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              backgroundColor: const Color(0xFFFF3B30),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              elevation: 4,
            ),
          );
        }
      });
    } else if (!isOverGoal) {
      _warningShownThisSession = false;
    }

    final name = settings.userName;

    return Scaffold(
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500],
                            ),
                          ),
                          if (name.isNotEmpty)
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            _formattedDate(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      offset: const Offset(0, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'history',
                          child: Row(
                            children: [
                              Icon(LucideIcons.history, size: 18),
                              SizedBox(width: 12),
                              Text('History'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(LucideIcons.settings, size: 18),
                              SizedBox(width: 12),
                              Text('Settings'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'history') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HistoryScreen()),
                          );
                        } else if (value == 'settings') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 56),
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
                    _MacroStat(label: l10n.proteinLabel, value: total.protein),
                    _MacroStat(label: l10n.fatLabel, value: total.fat),
                    _MacroStat(label: l10n.carbsLabel, value: total.carbs),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const WaterCard(),
              const SizedBox(height: 16),
              const WeightCard(),
              const SizedBox(height: 24),
              Text(
                l10n.entriesToday(provider.todayEntries.length),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 100),
            ],
          ),
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