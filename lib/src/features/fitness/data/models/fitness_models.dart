import 'dart:convert';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// ─── Activity Model ────────────────────────────────────────────────────────

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.type,
    required super.durationMinutes,
    required super.caloriesBurned,
    required super.steps,
    required super.date,
    super.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'steps': steps,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory ActivityModel.fromJson(Map<String, dynamic> j) => ActivityModel(
        id: j['id'] as String,
        type: j['type'] as String,
        durationMinutes: j['durationMinutes'] as int,
        caloriesBurned: (j['caloriesBurned'] as num).toDouble(),
        steps: j['steps'] as int,
        date: DateTime.parse(j['date'] as String),
        notes: j['notes'] as String? ?? '',
      );

  factory ActivityModel.fromEntity(Activity a) => ActivityModel(
        id: a.id,
        type: a.type,
        durationMinutes: a.durationMinutes,
        caloriesBurned: a.caloriesBurned,
        steps: a.steps,
        date: a.date,
        notes: a.notes,
      );
}

// ─── Weight Model ──────────────────────────────────────────────────────────

class WeightModel extends WeightEntry {
  const WeightModel({
    required super.id,
    required super.weightKg,
    required super.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'weightKg': weightKg,
        'date': date.toIso8601String(),
      };

  factory WeightModel.fromJson(Map<String, dynamic> j) => WeightModel(
        id: j['id'] as String,
        weightKg: (j['weightKg'] as num).toDouble(),
        date: DateTime.parse(j['date'] as String),
      );
}

// ─── FitnessProfile Model ─────────────────────────────────────────────────

class FitnessProfileModel extends FitnessProfile {
  const FitnessProfileModel({
    required super.heightCm,
    required super.weightKg,
    required super.age,
    required super.gender,
    super.goalCalories,
    super.goalSteps,
    super.goalMinutes,
  });

  Map<String, dynamic> toJson() => {
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'gender': gender,
        'goalCalories': goalCalories,
        'goalSteps': goalSteps,
        'goalMinutes': goalMinutes,
      };

  factory FitnessProfileModel.fromJson(Map<String, dynamic> j) =>
      FitnessProfileModel(
        heightCm: (j['heightCm'] as num).toDouble(),
        weightKg: (j['weightKg'] as num).toDouble(),
        age: j['age'] as int,
        gender: j['gender'] as String,
        goalCalories: (j['goalCalories'] as num?)?.toDouble() ?? 500,
        goalSteps: j['goalSteps'] as int? ?? 10000,
        goalMinutes: j['goalMinutes'] as int? ?? 60,
      );
}

// ─── Local Storage Repository ─────────────────────────────────────────────

class FitnessLocalRepository {
  static const _activitiesKey = 'fitness_activities';
  static const _weightsKey = 'fitness_weights';
  static const _profileKey = 'fitness_profile';
  final _uuid = const Uuid();

  // ── Activities ────────────────────────────────────────────────────────────

  Future<List<ActivityModel>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    late final raw = prefs.getString(_activitiesKey);
    if (raw == null) {
      return [];
    }
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveActivity(ActivityModel activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getActivities();
    activities.add(activity);
    await prefs.setString(
      _activitiesKey,
      json.encode(activities.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> deleteActivity(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final activities = await getActivities();
    activities.removeWhere((a) => a.id == id);
    await prefs.setString(
      _activitiesKey,
      json.encode(activities.map((a) => a.toJson()).toList()),
    );
  }

  Future<List<ActivityModel>> getTodayActivities() async {
    final all = await getActivities();
    final now = DateTime.now();
    return all
        .where((a) =>
            a.date.year == now.year &&
            a.date.month == now.month &&
            a.date.day == now.day)
        .toList();
  }

  Future<List<ActivityModel>> getWeekActivities() async {
    final all = await getActivities();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return all.where((a) => a.date.isAfter(weekAgo)).toList();
  }

  String generateId() => _uuid.v4();

  // ── Weight ────────────────────────────────────────────────────────────────

  Future<List<WeightModel>> getWeightEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_weightsKey);
    if (raw == null) return [];
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => WeightModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveWeight(double weightKg) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getWeightEntries();
    entries.add(WeightModel(
      id: _uuid.v4(),
      weightKg: weightKg,
      date: DateTime.now(),
    ));
    await prefs.setString(
      _weightsKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteWeightEntry(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getWeightEntries();
    entries.removeWhere((e) => e.id == id);
    await prefs.setString(
      _weightsKey,
      json.encode(entries.map((e) => e.toJson()).toList()),
    );
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<FitnessProfileModel?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    return FitnessProfileModel.fromJson(
        json.decode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(FitnessProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(profile.toJson()));
  }
}
