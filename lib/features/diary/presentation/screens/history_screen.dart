import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../../domain/usecases/get_history_by_day.dart';
import '../providers/diary_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<DayHistory>? _history;

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await context.read<DiaryProvider>().getHistory();
    if (mounted) {
      setState(() => _history = history);
    }
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium feature'),
        content: const Text(
          'Viewing history older than 7 days requires Premium. Upgrade to see your full history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _dayLabel(DateTime date) {
    if (_isToday(date)) return 'Today';
    return '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _history == null
          ? const Center(child: CircularProgressIndicator())
          : _history!.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.calendar, size: 40, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No history yet', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          if (!premium.isPremium)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF9F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.sparkles, size: 18, color: Color(0xFF34C759)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Free plan shows the last 7 days. Upgrade for full history.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ..._history!.map((day) {
            final isLocked = !premium.isPremium && day.date.isBefore(sevenDaysAgo);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: isLocked ? _showPremiumDialog : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isLocked
                              ? Colors.grey[100]
                              : const Color(0xFFEFF9F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isLocked ? LucideIcons.lock : LucideIcons.calendar,
                          size: 18,
                          color: isLocked ? Colors.grey[400] : const Color(0xFF34C759),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dayLabel(day.date),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isLocked ? 'Unlock with Premium' : '${day.entries.length} entries',
                              style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      if (!isLocked)
                        Text(
                          '${day.totalCalories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF34C759),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}