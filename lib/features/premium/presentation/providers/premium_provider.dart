import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class PremiumProvider extends ChangeNotifier {
  final Box settingsBox;
  static const _isPremiumKey = 'is_premium';
  static const _tempPremiumUntilKey = 'temp_premium_until';
  static const maxFreeCustomFoods = 5;
  PremiumProvider(this.settingsBox);

  bool get _hasPermanentPremium => (settingsBox.get(_isPremiumKey) as bool?) ?? false;

  DateTime? get _tempPremiumUntil {
    final millis = settingsBox.get(_tempPremiumUntilKey) as int?;
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  bool get isPremium {
    if (_hasPermanentPremium) return true;
    final until = _tempPremiumUntil;
    return until != null && until.isAfter(DateTime.now());
  }

  Duration? get tempPremiumRemaining {
    final until = _tempPremiumUntil;
    if (until == null || _hasPermanentPremium) return null;
    final remaining = until.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  Future<void> grantTempPremium(Duration duration) async {
    final current = _tempPremiumUntil;
    final base = (current != null && current.isAfter(DateTime.now())) ? current : DateTime.now();
    await settingsBox.put(_tempPremiumUntilKey, base.add(duration).millisecondsSinceEpoch);
    notifyListeners();
  }
  // Временный переключатель для тестирования UX до подключения реальной оплаты
  Future<void> setPremiumForTesting(bool value) async {
    await settingsBox.put(_isPremiumKey, value);
    notifyListeners();
  }
}