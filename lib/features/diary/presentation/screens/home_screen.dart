import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiaryProvider>();
    final total = provider.dailyTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Сегодня')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${total.calories.toStringAsFixed(0)} ккал',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Белки: ${total.protein.toStringAsFixed(1)} г'),
                  Text('Жиры: ${total.fat.toStringAsFixed(1)} г'),
                  Text('Углеводы: ${total.carbs.toStringAsFixed(1)} г'),
                  const SizedBox(height: 24),
                  Text('Записей за сегодня: ${provider.todayEntries.length}'),
                ],
              ),
            ),
    );
  }
}
