import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/water_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final water = context.watch<WaterProvider>();
    final settings = context.watch<SettingsProvider>();

    final goal = water.goalMl(
      weightKg: settings.weightKg,
      activityLevel: settings.activityLevel,
    );
    final consumed = water.totalMl;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF5AC8FA).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.droplet,
                  color: Color(0xFF5AC8FA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Water',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} ml',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEDE8),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF5AC8FA)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAddChip(label: '+100ml', amount: 100),
              _QuickAddChip(label: '+250ml', amount: 250),
              _QuickAddChip(label: '+500ml', amount: 500),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  final String label;
  final double amount;

  const _QuickAddChip({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<WaterProvider>().addWater(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5AC8FA).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5AC8FA),
          ),
        ),
      ),
    );
  }
}