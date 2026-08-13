import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class PremiumProvider extends ChangeNotifier {
  final Box settingsBox;

  static const _isPremiumKey = 'is_premium';
  static const maxFreeCustomFoods = 5;

  PremiumProvider(this.settingsBox);

  bool get isPremium => (settingsBox.get(_isPremiumKey) as bool?) ?? false;

  // Временный переключатель для тестирования UX до подключения реальной оплаты
  Future<void> setPremiumForTesting(bool value) async {
    await settingsBox.put(_isPremiumKey, value);
    notifyListeners();
  }
}