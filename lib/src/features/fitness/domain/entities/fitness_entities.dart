import 'package:equatable/equatable.dart';

// ─── Activity ──────────────────────────────────────────────────────────────

class Activity extends Equatable {
  const Activity({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.steps,
    required this.date,
    this.notes = '',
  });

  final String id;
  final String type;
  final int durationMinutes;
  final double caloriesBurned;
  final int steps;
  final DateTime date;
  final String notes;

  @override
  List<Object?> get props =>
      [id, type, durationMinutes, caloriesBurned, steps, date, notes];
}

// ─── Weight Entry ──────────────────────────────────────────────────────────

class WeightEntry extends Equatable {
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.date,
  });

  final String id;
  final double weightKg;
  final DateTime date;

  @override
  List<Object?> get props => [id, weightKg, date];
}

// ─── User Profile ──────────────────────────────────────────────────────────

class FitnessProfile extends Equatable {
  const FitnessProfile({
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.gender,
    this.goalCalories = 500,
    this.goalSteps = 10000,
    this.goalMinutes = 60,
  });

  final double heightCm;
  final double weightKg;
  final int age;
  final String gender; // 'male' | 'female'
  final double goalCalories;
  final int goalSteps;
  final int goalMinutes;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  FitnessProfile copyWith({
    double? heightCm,
    double? weightKg,
    int? age,
    String? gender,
    double? goalCalories,
    int? goalSteps,
    int? goalMinutes,
  }) =>
      FitnessProfile(
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        goalCalories: goalCalories ?? this.goalCalories,
        goalSteps: goalSteps ?? this.goalSteps,
        goalMinutes: goalMinutes ?? this.goalMinutes,
      );

  @override
  List<Object?> get props =>
      [heightCm, weightKg, age, gender, goalCalories, goalSteps, goalMinutes];
}

// ─── Workout Plan ──────────────────────────────────────────────────────────

class WorkoutExercise extends Equatable {
  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.muscle,
    this.tips = '',
    this.equipment = '',
    this.difficulty = 'Beginner',
    this.caloriesBurnRate = 0,
    this.imageUrl = '',
    this.isWarmup = false,
    this.animationHint = '',
  });

  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String muscle;
  final String tips;
  final String equipment;
  final String difficulty;
  final double caloriesBurnRate;
  final String imageUrl;
  final bool isWarmup;
  final String animationHint;

  @override
  List<Object?> get props => [name, sets, reps, rest, muscle, tips, equipment, difficulty, isWarmup];
}

class WorkoutPlan extends Equatable {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.category,
    required this.durationMins,
    required this.calories,
    required this.exercises,
    required this.emoji,
    this.equipment = const [],
    this.targetMuscles = const [],
    this.benefits = const [],
    this.rating = 4.5,
    this.completions = 0,
    this.weeklyFrequency = 3,
    this.tags = const [],
    this.equipmentLevel = 'none',
    this.suitableFor = const [],
  });

  final String id;
  final String name;
  final String description;
  final String level;
  final String category;
  final int durationMins;
  final int calories;
  final List<WorkoutExercise> exercises;
  final String emoji;
  final List<String> equipment;
  final List<String> targetMuscles;
  final List<String> benefits;
  final double rating;
  final int completions;
  final int weeklyFrequency;
  final List<String> tags;
  final String equipmentLevel; // 'none' | 'minimal' | 'full'
  final List<String> suitableFor;

  int get totalSets => exercises.fold(0, (sum, e) => sum + (int.tryParse(e.sets) ?? 0));
  int get averageRestSeconds {
    if (exercises.isEmpty) return 30;
    final total = exercises.fold(0, (int sum, e) {
      final restNum = int.tryParse(e.rest.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
      return sum + restNum;
    });
    return total ~/ exercises.length;
  }

  String get intensity => switch (level) {
    'Beginner' => 'Low',
    'Intermediate' => 'Moderate',
    'Advanced' => 'High',
    _ => 'Moderate',
  };

  @override
  List<Object?> get props => [id, name, level, category];
}
