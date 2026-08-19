import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/weight_provider.dart';

class WeightCard extends StatelessWidget {
  final int? daysFilter;
  const WeightCard({super.key, this.daysFilter});

  @override
  Widget build(BuildContext context) {
    final weight = context.watch<WeightProvider>();
    final fullHistory = weight.history;
    final history = daysFilter == null
        ? fullHistory
        : fullHistory.where((e) {
      final cutoff = DateTime.now().subtract(Duration(days: daysFilter!));
      return e.timestamp.isAfter(cutoff);
    }).toList();
    final latest = weight.latest;

    double? delta;
    if (history.length >= 2) {
      delta = history.last.weightKg - history[history.length - 2].weightKg;
    }

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
                  color: const Color(0xFFAF52DE).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.scale,
                  color: Color(0xFFAF52DE),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      latest == null
                          ? 'No entries yet'
                          : '${latest.weightKg.toStringAsFixed(1)} kg',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (delta <= 0 ? const Color(0xFF34C759) : const Color(0xFFFF9500))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: delta <= 0 ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showAddWeightDialog(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFAF52DE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.plus, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          if (history.length >= 2) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: _WeightChart(history: history),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            suffixText: 'kg',
            hintText: '70.0',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.replaceAll(',', '.'));
              if (value != null && value > 0) {
                dialogContext.read<WeightProvider>().addWeight(value);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List history;

  const _WeightChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final recent = history.length > 30
        ? history.sublist(history.length - 30)
        : history;

    final spots = <FlSpot>[
      for (var i = 0; i < recent.length; i++)
        FlSpot(i.toDouble(), recent[i].weightKg as double),
    ];

    final values = recent.map((e) => e.weightKg as double).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) - 1;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFFAF52DE),
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFAF52DE).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}