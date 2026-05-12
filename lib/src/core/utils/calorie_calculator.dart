class CalorieCalculator {
  static const Map<String, double> _mets = {
    'Running': 9.8,
    'Walking': 3.5,
    'Cycling': 7.5,
    'Swimming': 8.0,
    'Gym': 5.0,
    'Yoga': 2.5,
    'HIIT': 12.0,
    'Stretching': 2.3,
    'Dance': 6.0,
    'Basketball': 8.0,
    'Soccer': 10.0,
    'Tennis': 7.3,
  };

  static double caloriesFromSteps(int steps, {double weightKg = 70}) {
    return steps * 0.04 * (weightKg / 70);
  }

  static double caloriesFromActivity({
    required String type,
    required int durationMinutes,
    required double weightKg,
  }) {
    final met = _mets[type] ?? 5.0;
    return met * weightKg * (durationMinutes / 60);
  }

  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  static double calculateTDEE({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }

    const activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    return bmr * (activityMultipliers[activityLevel] ?? 1.2);
  }
}
