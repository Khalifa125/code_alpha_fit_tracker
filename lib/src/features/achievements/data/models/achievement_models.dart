class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int targetValue;
  final int currentValue;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  Achievement copyWith({
    int? currentValue,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) => Achievement(
    id: id,
    title: title,
    description: description,
    icon: icon,
    category: category,
    targetValue: targetValue,
    currentValue: currentValue ?? this.currentValue,
    unlockedAt: unlockedAt ?? this.unlockedAt,
    isUnlocked: isUnlocked ?? this.isUnlocked,
  );
}

enum AchievementCategory {
  steps,
  workout,
  calories,
  streak,
  water,
  sleep,
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final DateTime? earnedAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.earnedAt,
  });

  bool get isEarned => earnedAt != null;
}

class UserStats {
  final int totalSteps;
  final int totalWorkouts;
  final int totalCalories;
  final int currentStreak;
  final int longestStreak;
  final int totalWater;
  final int totalSleepHours;

  UserStats({
    this.totalSteps = 0,
    this.totalWorkouts = 0,
    this.totalCalories = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWater = 0,
    this.totalSleepHours = 0,
  });

  UserStats copyWith({
    int? totalSteps,
    int? totalWorkouts,
    int? totalCalories,
    int? currentStreak,
    int? longestStreak,
    int? totalWater,
    int? totalSleepHours,
  }) => UserStats(
    totalSteps: totalSteps ?? this.totalSteps,
    totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    totalCalories: totalCalories ?? this.totalCalories,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    totalWater: totalWater ?? this.totalWater,
    totalSleepHours: totalSleepHours ?? this.totalSleepHours,
  );
}