// ignore_for_file: prefer_int_literals

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/data/repositories/workout_plans_data.dart';
import 'package:fit_tracker/src/features/fitness/data/repositories/step_counter_service.dart';

// ─── Repository Provider ──────────────────────────────────────────────────

final fitnessRepoProvider = Provider<FitnessLocalRepository>(
  (_) => FitnessLocalRepository(),
);

// ─── Today's Activities ───────────────────────────────────────────────────

final todayActivitiesProvider =
    FutureProvider.autoDispose<List<ActivityModel>>((ref) async {
  return ref.read(fitnessRepoProvider).getTodayActivities();
});

// ─── All Activities ───────────────────────────────────────────────────────

final allActivitiesProvider =
    FutureProvider.autoDispose<List<ActivityModel>>((ref) async {
  return ref.read(fitnessRepoProvider).getActivities();
});

// ─── Week Activities ──────────────────────────────────────────────────────

final weekActivitiesProvider =
    FutureProvider.autoDispose<List<ActivityModel>>((ref) async {
  return ref.read(fitnessRepoProvider).getWeekActivities();
});

// ─── Weight Entries ───────────────────────────────────────────────────────

final weightEntriesProvider =
    FutureProvider.autoDispose<List<WeightModel>>((ref) async {
  return ref.read(fitnessRepoProvider).getWeightEntries();
});

// ─── Fitness Profile ──────────────────────────────────────────────────────

final fitnessProfileProvider =
    FutureProvider.autoDispose<FitnessProfileModel?>((ref) async {
  return ref.read(fitnessRepoProvider).getProfile();
});

// ─── Workout Plans ────────────────────────────────────────────────────────

final workoutPlansProvider = Provider<List<WorkoutPlan>>(
  (_) => WorkoutPlansData.plans,
);

final workoutFilterProvider = NotifierProvider<WorkoutFilterNotifier, String>(() => WorkoutFilterNotifier());

class WorkoutFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  
  void setFilter(String filter) {
    state = filter;
  }
}

final filteredWorkoutPlansProvider = Provider<List<WorkoutPlan>>((ref) {
  final plans = ref.watch(workoutPlansProvider);
  final filter = ref.watch(workoutFilterProvider);
  if (filter == 'All') return plans;
  return plans
      .where((p) => p.category == filter || p.level == filter)
      .toList();
});

// ─── Daily Summary Computed ───────────────────────────────────────────────

class DailySummary {
  final double totalCalories;
  final int totalSteps;
  final int totalMinutes;
  final int activityCount;
  final bool hasPedometer;

  const DailySummary({
    required this.totalCalories,
    required this.totalSteps,
    required this.totalMinutes,
    required this.activityCount,
    this.hasPedometer = false,
  });
}

final dailySummaryProvider =
    FutureProvider.autoDispose<DailySummary>((ref) async {
  final activities = await ref.read(fitnessRepoProvider).getTodayActivities();
  final activitySteps = activities.fold(0, (sum, a) => sum + a.steps);
  
  // Try to get pedometer steps
  int pedometerSteps = 0;
  bool hasPedometer = false;
  
  try {
    final stepService = ref.read(stepCounterServiceProvider);
    await stepService.init();
    pedometerSteps = stepService.currentSteps;
    hasPedometer = pedometerSteps > 0;
  } catch (_) {
    // Pedometer not available
  }
  
  // Use pedometer steps if available, otherwise use activity steps
  final totalSteps = hasPedometer ? pedometerSteps : activitySteps;
  
  return DailySummary(
    totalCalories: activities.fold(0.0, (sum, a) => sum + a.caloriesBurned),
    totalSteps: totalSteps,
    totalMinutes: activities.fold(0, (sum, a) => sum + a.durationMinutes),
    activityCount: activities.length,
    hasPedometer: hasPedometer,
  );
});

// ─── Real-time Step Counter ───────────────────────────────────────────────

final realTimeStepsProvider = StreamProvider<int>((ref) {
  final service = ref.watch(stepCounterServiceProvider);
  service.init();
  return service.stepCountStream;
});
