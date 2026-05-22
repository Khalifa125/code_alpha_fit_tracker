class XpLevel {
  final int level;
  final int currentXp;
  final int xpToNext;

  const XpLevel({required this.level, required this.currentXp, required this.xpToNext});

  double get progress => currentXp / xpToNext;
  int get totalXp => _totalXpForLevel(level) + currentXp;

  static int _totalXpForLevel(int lvl) {
    int total = 0;
    for (int i = 1; i < lvl; i++) {
      total += _xpForLevel(i);
    }
    return total;
  }

  static int _xpForLevel(int lvl) => 100 + (lvl - 1) * 50;

  static XpLevel fromTotalXp(int totalXp) {
    int level = 1;
    int remaining = totalXp;
    while (remaining >= _xpForLevel(level)) {
      remaining -= _xpForLevel(level);
      level++;
    }
    return XpLevel(level: level, currentXp: remaining, xpToNext: _xpForLevel(level));
  }
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final ChallengeType type;
  final int target;
  bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.type,
    required this.target,
    this.isCompleted = false,
  });
}

enum ChallengeType {
  completeWorkout,
  burnCalories,
  drinkWater,
  walkSteps,
  exerciseCount,
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActive;
  final List<DateTime> activeDates;

  const StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActive,
    this.activeDates = const [],
  });

  StreakData copyWith({int? currentStreak, int? longestStreak, DateTime? lastActive, List<DateTime>? activeDates}) =>
      StreakData(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastActive: lastActive ?? this.lastActive,
        activeDates: activeDates ?? this.activeDates,
      );
}

class GamificationState {
  final int totalXp;
  final StreakData streak;
  final List<DailyChallenge> challenges;
  final int workoutsCompleted;
  final int totalCaloriesBurned;
  final int totalMinutesExercised;

  GamificationState({
    this.totalXp = 0,
    StreakData? streak,
    this.challenges = const [],
    this.workoutsCompleted = 0,
    this.totalCaloriesBurned = 0,
    this.totalMinutesExercised = 0,
  }) : streak = streak ?? const StreakData();

  GamificationState copyWith({
    int? totalXp,
    StreakData? streak,
    List<DailyChallenge>? challenges,
    int? workoutsCompleted,
    int? totalCaloriesBurned,
    int? totalMinutesExercised,
  }) => GamificationState(
    totalXp: totalXp ?? this.totalXp,
    streak: streak ?? this.streak,
    challenges: challenges ?? this.challenges,
    workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
    totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
    totalMinutesExercised: totalMinutesExercised ?? this.totalMinutesExercised,
  );
}
