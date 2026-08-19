import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../premium/presentation/providers/premium_provider.dart';
import '../widgets/weight_card.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  int _selectedDays = 7;

  static const _periods = [
    {'label': '7D', 'days': 7, 'free': true},
    {'label': '30D', 'days': 30, 'free': false},
    {'label': '90D', 'days': 90, 'free': false},
    {'label': 'All', 'days': -1, 'free': false},
  ];

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium feature'),
        content: const Text(
          'Viewing trends beyond 7 days requires Premium. Upgrade to see your full history.',
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

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Weight')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),
              if (!premium.isPremium)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          'Free plan shows 7-day trend. Upgrade for full history.',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _periods.map((p) {
                  final isLocked = !premium.isPremium && p['free'] != true;
                  final isSelected = _selectedDays == p['days'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: isLocked
                          ? _showPremiumDialog
                          : () => setState(() => _selectedDays = p['days'] as int),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFAF52DE) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLocked)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(LucideIcons.lock, size: 11, color: Colors.grey[400]),
                              ),
                            Text(
                              p['label'] as String,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isLocked ? Colors.grey[400] : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              WeightCard(daysFilter: _selectedDays == -1 ? null : _selectedDays),
            ],
          ),
        ),
      ),
    );
  }
}