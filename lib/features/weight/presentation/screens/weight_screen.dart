import 'package:flutter/material.dart';
import '../widgets/weight_card.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 12),
          child: WeightCard(),
        ),
      ),
    );
  }
}