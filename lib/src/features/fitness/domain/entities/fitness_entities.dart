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
  });

  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String muscle;

  @override
  List<Object?> get props => [name, sets, reps, rest, muscle];
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
  });

  final String id;
  final String name;
  final String description;
  final String level; // beginner / intermediate / advanced
  final String category; // strength / cardio / hiit / flexibility
  final int durationMins;
  final int calories;
  final List<WorkoutExercise> exercises;
  final String emoji;

  @override
  List<Object?> get props => [id, name, level, category];
}
