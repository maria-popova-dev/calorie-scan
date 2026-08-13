import '../presentation/providers/settings_provider.dart';

class CalorieCalculator {
  static double calculate({
    required Gender gender,
    required int age,
    required double heightCm,
    required double weightKg,
    required ActivityLevel activityLevel,
    required WeightGoal weightGoal,
  }) {
    // Формула Миффлина-Сан Жеора
    double bmr = 10 * weightKg + 6.25 * heightCm - 5 * age;
    bmr += gender == Gender.male ? 5 : -161;

    final activityMultiplier = switch (activityLevel) {
      ActivityLevel.sedentary => 1.2,
      ActivityLevel.light => 1.375,
      ActivityLevel.moderate => 1.55,
      ActivityLevel.active => 1.725,
    };

    final tdee = bmr * activityMultiplier;

    return switch (weightGoal) {
      WeightGoal.lose => tdee - 500,
      WeightGoal.maintain => tdee,
      WeightGoal.gain => tdee + 500,
    };
  }
}