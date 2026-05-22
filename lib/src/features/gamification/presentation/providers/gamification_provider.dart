import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/gamification/data/models/gamification_models.dart';
import 'package:fit_tracker/src/features/achievements/data/models/achievement_models.dart';
import 'package:fit_tracker/src/core/services/hive_storage_service.dart';

final gamificationProvider = NotifierProvider<GamificationNotifier, GamificationState>(GamificationNotifier.new);

final achievementsProvider = NotifierProvider<AchievementsNotifier, List<Achievement>>(AchievementsNotifier.new);

class GamificationNotifier extends Notifier<GamificationState> {
  @override
  GamificationState build() {
    _loadFromStorage();
    return GamificationState();
  }

  Future<void> _loadFromStorage() async {
    final saved = await HiveStorageService.loadGamificationState();
    if (saved.totalXp > 0 || saved.streak.currentStreak > 0 || saved.workoutsCompleted > 0) {
      state = saved;
    }
  }

  Future<void> _persist() => HiveStorageService.saveGamificationState(state);

  void addXp(int amount) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = state.streak.lastActive;
    final diff = lastActive == null ? 999 : today.difference(DateTime(lastActive.year, lastActive.month, lastActive.day)).inDays;


    StreakData newStreak;
    if (diff == 0) {
      newStreak = state.streak;
    } else if (diff == 1) {
      final next = state.streak.currentStreak + 1;
      newStreak = state.streak.copyWith(
        currentStreak: next,
        longestStreak: next > state.streak.longestStreak ? next : state.streak.longestStreak,
        lastActive: now,
        activeDates: [...state.streak.activeDates, today],
      );
    } else {
      newStreak = StreakData(lastActive: now, currentStreak: 1, longestStreak: state.streak.longestStreak, activeDates: [today]);
    }

    state = state.copyWith(
      totalXp: state.totalXp + amount,
      streak: newStreak,
    );
    _persist();
  }

  void completeWorkout(int calories, int minutes) {
    addXp(50 + (minutes ~/ 10) * 10);
    final challenges = state.challenges.map((c) {
      if (c.type == ChallengeType.completeWorkout && !c.isCompleted) {
        return DailyChallenge(id: c.id, title: c.title, description: c.description, icon: c.icon, xpReward: c.xpReward, type: c.type, target: c.target, isCompleted: true);
      }
      if (c.type == ChallengeType.burnCalories && !c.isCompleted) {
        return DailyChallenge(id: c.id, title: c.title, description: c.description, icon: c.icon, xpReward: c.xpReward, type: c.type, target: c.target, isCompleted: calories >= c.target);
      }
      if (c.type == ChallengeType.exerciseCount && !c.isCompleted) {
        return DailyChallenge(id: c.id, title: c.title, description: c.description, icon: c.icon, xpReward: c.xpReward, type: c.type, target: c.target, isCompleted: minutes >= c.target);
      }
      return c;
    }).toList();

    state = state.copyWith(
      workoutsCompleted: state.workoutsCompleted + 1,
      totalCaloriesBurned: state.totalCaloriesBurned + calories,
      totalMinutesExercised: state.totalMinutesExercised + minutes,
      challenges: challenges,
    );

    _persist();
    for (final c in challenges) {
      if (c.isCompleted) addXp(c.xpReward);
    }
  }

  void generateDailyChallenges() {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month}-${today.day}';
    state = state.copyWith(challenges: _getChallengesForDate(dateStr));
    _persist();
  }

  List<DailyChallenge> _getChallengesForDate(String date) {
    final day = DateTime.now().day;
    return [
      DailyChallenge(
        id: 'challenge_workout_$date',
        title: 'Complete a Workout',
        description: 'Finish any workout to earn bonus XP',
        icon: '🏋️',
        xpReward: 100,
        type: ChallengeType.completeWorkout,
        target: 1,
      ),
      DailyChallenge(
        id: 'challenge_calories_$date',
        title: 'Burn 300 Calories',
        description: 'Reach 300 calories burned in workouts',
        icon: '🔥',
        xpReward: 75,
        type: ChallengeType.burnCalories,
        target: 300,
      ),
      DailyChallenge(
        id: 'challenge_minutes_$date',
        title: 'Exercise ${15 + (day % 3) * 5} min',
        description: 'Stay active for the target duration',
        icon: '⏱️',
        xpReward: 50,
        type: ChallengeType.exerciseCount,
        target: 15 + (day % 3) * 5,
      ),
    ];
  }
}

class AchievementsNotifier extends Notifier<List<Achievement>> {
  @override
  List<Achievement> build() {
    _loadFromStorage();
    return _allAchievements;
  }

  List<Achievement> get _allAchievements => [
    Achievement(id: 'first_workout', title: 'First Steps', description: 'Complete your first workout', icon: '🎯', category: AchievementCategory.workout, targetValue: 1),
    Achievement(id: 'five_workouts', title: 'Getting Started', description: 'Complete 5 workouts', icon: '💪', category: AchievementCategory.workout, targetValue: 5),
    Achievement(id: 'ten_workouts', title: 'Dedicated Athlete', description: 'Complete 10 workouts', icon: '🏆', category: AchievementCategory.workout, targetValue: 10),
    Achievement(id: 'twentyfive_workouts', title: 'Fitness Warrior', description: 'Complete 25 workouts', icon: '⚔️', category: AchievementCategory.workout, targetValue: 25),
    Achievement(id: 'fifty_workouts', title: 'Iron Will', description: 'Complete 50 workouts', icon: '🛡️', category: AchievementCategory.workout, targetValue: 50),
    Achievement(id: 'streak_3', title: 'Consistent', description: 'Maintain a 3-day streak', icon: '📅', category: AchievementCategory.streak, targetValue: 3),
    Achievement(id: 'streak_7', title: 'Week Warrior', description: 'Maintain a 7-day streak', icon: '📆', category: AchievementCategory.streak, targetValue: 7),
    Achievement(id: 'streak_30', title: 'Monthly Master', description: 'Maintain a 30-day streak', icon: '🗓️', category: AchievementCategory.streak, targetValue: 30),
    Achievement(id: 'cal_1000', title: 'Calorie Burner', description: 'Burn 1000 calories total', icon: '🔥', category: AchievementCategory.calories, targetValue: 1000),
    Achievement(id: 'cal_5000', title: 'Calorie Crusher', description: 'Burn 5000 calories total', icon: '💥', category: AchievementCategory.calories, targetValue: 5000),
    Achievement(id: 'cal_10000', title: 'Inferno', description: 'Burn 10000 calories total', icon: '🌋', category: AchievementCategory.calories, targetValue: 10000),
    Achievement(id: 'steps_100k', title: 'Century Walker', description: 'Walk 100,000 steps', icon: '🚶', category: AchievementCategory.steps, targetValue: 100000),
    Achievement(id: 'water_30', title: 'Hydrated', description: 'Log 30 glasses of water', icon: '💧', category: AchievementCategory.water, targetValue: 30),
    Achievement(id: 'sleep_40', title: 'Well Rested', description: 'Log 40 hours of sleep', icon: '😴', category: AchievementCategory.sleep, targetValue: 40),
  ];

  Future<void> _loadFromStorage() async {
    final saved = await HiveStorageService.loadAchievements();
    if (saved.isNotEmpty) {
      state = _allAchievements.map((a) {
        final match = saved.firstWhere((s) => s.id == a.id, orElse: () => a);
        return match.copyWith(
          currentValue: match.currentValue,
          isUnlocked: match.isUnlocked,
          unlockedAt: match.unlockedAt,
        );
      }).toList();
    }
  }

  Future<void> _persist() => HiveStorageService.saveAchievements(state);

  void updateProgress(GamificationState gs) {
    state = state.map((a) {
      int current;
      switch (a.category) {
        case AchievementCategory.workout:
          current = gs.workoutsCompleted;
        case AchievementCategory.streak:
          current = gs.streak.longestStreak;
        case AchievementCategory.calories:
          current = gs.totalCaloriesBurned;
        case AchievementCategory.steps:
          current = 0;
        case AchievementCategory.water:
          current = 0;
        case AchievementCategory.sleep:
          current = 0;
      }
      if (current >= a.targetValue && !a.isUnlocked) {
        return a.copyWith(currentValue: current, isUnlocked: true, unlockedAt: DateTime.now());
      }
      return a.copyWith(currentValue: current);
    }).toList();
    _persist();
  }
}
