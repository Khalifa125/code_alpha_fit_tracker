import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fit_tracker/src/features/gamification/data/models/gamification_models.dart';
import 'package:fit_tracker/src/features/achievements/data/models/achievement_models.dart';
import 'package:fit_tracker/src/features/nutrition/presentation/providers/nutrition_provider.dart';

class HiveStorageService {
  static const _progressBox = 'progress';

  static Box<dynamic> get _progress => Hive.box(_progressBox);
  static Box<dynamic> get _nutrition => Hive.box('nutrition');

  static Future<GamificationState> loadGamificationState() async {
    final data = _progress.get('gamification_state') as String?;
    if (data == null) return GamificationState();
    return _gamificationStateFromJson(data);
  }

  static Future<void> saveGamificationState(GamificationState state) async {
    await _progress.put('gamification_state', _gamificationStateToJson(state));
  }

  static Future<List<Achievement>> loadAchievements() async {
    final data = _progress.get('achievements') as String?;
    if (data == null) return [];
    return _achievementsFromJson(data);
  }

  static Future<void> saveAchievements(List<Achievement> achievements) async {
    await _progress.put('achievements', _achievementsToJson(achievements));
  }

  static Future<List<NutritionEntry>> loadNutritionEntries() async {
    final data = _nutrition.get('entries') as String?;
    if (data == null) return [];
    return _nutritionEntriesFromJson(data);
  }

  static Future<void> saveNutritionEntries(List<NutritionEntry> entries) async {
    await _nutrition.put('entries', _nutritionEntriesToJson(entries));
  }

  static Future<double> loadCalorieGoal() async {
    return (_nutrition.get('calorie_goal') as num?)?.toDouble() ?? 2000;
  }

  static Future<void> saveCalorieGoal(double goal) async {
    await _nutrition.put('calorie_goal', goal);
  }

  static Future<int?> loadMacroGoal(String key) async {
    return _nutrition.get(key) as int?;
  }

  static Future<void> saveMacroGoal(String key, int value) async {
    await _nutrition.put(key, value);
  }

  static String _gamificationStateToJson(GamificationState s) {
    return jsonEncode({
      'totalXp': s.totalXp,
      'workoutsCompleted': s.workoutsCompleted,
      'totalCaloriesBurned': s.totalCaloriesBurned,
      'totalMinutesExercised': s.totalMinutesExercised,
      'streak': {
        'currentStreak': s.streak.currentStreak,
        'longestStreak': s.streak.longestStreak,
        'lastActive': s.streak.lastActive?.toIso8601String(),
        'activeDates': s.streak.activeDates.map((d) => d.toIso8601String()).toList(),
      },
      'challenges': s.challenges.map((c) => {
        'id': c.id,
        'title': c.title,
        'description': c.description,
        'icon': c.icon,
        'xpReward': c.xpReward,
        'type': c.type.name,
        'target': c.target,
        'isCompleted': c.isCompleted,
      }).toList(),
    });
  }

  static GamificationState _gamificationStateFromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    final streakMap = map['streak'] as Map<String, dynamic>?;
    final streak = StreakData(
      currentStreak: streakMap?['currentStreak'] as int? ?? 0,
      longestStreak: streakMap?['longestStreak'] as int? ?? 0,
      lastActive: streakMap?['lastActive'] != null ? DateTime.parse(streakMap!['lastActive'] as String) : null,
      activeDates: (streakMap?['activeDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ?? [],
    );

    final challenges = (map['challenges'] as List<dynamic>?)
        ?.map((c) => DailyChallenge(
              id: c['id'] as String,
              title: c['title'] as String,
              description: c['description'] as String,
              icon: c['icon'] as String,
              xpReward: c['xpReward'] as int,
              type: ChallengeType.values.firstWhere((t) => t.name == c['type']),
              target: c['target'] as int,
              isCompleted: c['isCompleted'] as bool? ?? false,
            ))
        .toList() ?? [];

    return GamificationState(
      totalXp: map['totalXp'] as int? ?? 0,
      streak: streak,
      challenges: challenges,
      workoutsCompleted: map['workoutsCompleted'] as int? ?? 0,
      totalCaloriesBurned: map['totalCaloriesBurned'] as int? ?? 0,
      totalMinutesExercised: map['totalMinutesExercised'] as int? ?? 0,
    );
  }

  static String _achievementsToJson(List<Achievement> achievements) {
    return jsonEncode(achievements.map((a) {
      return <String, dynamic>{
        'id': a.id,
        'title': a.title,
        'description': a.description,
        'icon': a.icon,
        'category': a.category.name,
        'targetValue': a.targetValue,
        'currentValue': a.currentValue,
        'isUnlocked': a.isUnlocked,
        'unlockedAt': a.unlockedAt?.toIso8601String(),
      };
    }).toList());
  }

  static List<Achievement> _achievementsFromJson(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((item) {
      final m = item as Map<String, dynamic>;
      return Achievement(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        description: m['description'] as String? ?? '',
        icon: m['icon'] as String? ?? '',
        category: AchievementCategory.values.firstWhere(
          (c) => c.name == (m['category'] as String? ?? ''),
          orElse: () => AchievementCategory.workout,
        ),
        targetValue: m['targetValue'] as int? ?? 0,
        currentValue: m['currentValue'] as int? ?? 0,
        isUnlocked: m['isUnlocked'] as bool? ?? false,
        unlockedAt: m['unlockedAt'] != null ? DateTime.parse(m['unlockedAt'] as String) : null,
      );
    }).toList();
  }

  static String _nutritionEntriesToJson(List<NutritionEntry> entries) {
    return jsonEncode(entries.map((e) {
      return <String, dynamic>{
        'id': e.id,
        'name': e.name,
        'calories': e.calories,
        'carbs': e.carbs,
        'protein': e.protein,
        'fat': e.fat,
        'grams': e.grams,
        'mealType': e.mealType,
        'date': e.date.toIso8601String(),
      };
    }).toList());
  }

  static List<NutritionEntry> _nutritionEntriesFromJson(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((item) {
      final m = item as Map<String, dynamic>;
      return NutritionEntry(
        id: m['id'] as String,
        name: m['name'] as String,
        calories: (m['calories'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
        protein: (m['protein'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
        grams: (m['grams'] as num).toDouble(),
        mealType: m['mealType'] as String,
        date: DateTime.parse(m['date'] as String),
      );
    }).toList();
  }
}
