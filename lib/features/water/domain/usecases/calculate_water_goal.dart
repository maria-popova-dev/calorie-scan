class CalculateWaterGoal {
  double call({required double weightKg, double activityBonusMl = 0}) {
    return (weightKg * 30) + activityBonusMl;
  }
}