import 'package:flutter/material.dart';
import '../widgets/water_card.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 12),
          child: WaterCard(),
        ),
      ),
    );
  }
}