import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/fit_track/models/workout.dart';
import 'package:fit_tracker/src/features/fit_track/models/progress.dart';
import 'package:fit_tracker/src/features/fit_track/services/fittrack_service.dart';
import 'package:fit_tracker/src/features/fit_track/services/workout_generator.dart';
import 'package:fit_tracker/src/features/fit_track/providers/auth_provider.dart';

final progressProvider = NotifierProvider<ProgressNotifier, ProgressStats>(() => ProgressNotifier());

class ProgressNotifier extends Notifier<ProgressStats> {
  @override
  ProgressStats build() {
    final service = ref.read(fitTrackServiceProvider);
    return service.getProgress();
  }

  void refresh() {
    final service = ref.read(fitTrackServiceProvider);
    state = service.getProgress();
  }

  int getCurrentStreak() {
    final service = ref.read(fitTrackServiceProvider);
    return service.getCurrentStreak();
  }

  Future<void> recordWorkout(int durationMinutes) async {
    final service = ref.read(fitTrackServiceProvider);
    await service.recordWorkout(durationMinutes);
    state = service.getProgress();
  }
}

final workoutProvider = NotifierProvider<WorkoutNotifier, WorkoutState>(() => WorkoutNotifier());

class WorkoutState {
  final Workout? currentWorkout;
  final WorkoutSession? session;
  final bool isLoading;
  final String? error;

  WorkoutState({
    this.currentWorkout,
    this.session,
    this.isLoading = false,
    this.error,
  });

  WorkoutState copyWith({
    Workout? currentWorkout,
    WorkoutSession? session,
    bool? isLoading,
    String? error,
  }) => WorkoutState(
    currentWorkout: currentWorkout ?? this.currentWorkout,
    session: session ?? this.session,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

class WorkoutNotifier extends Notifier<WorkoutState> {
  Timer? _timer;
  
  @override
  WorkoutState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return WorkoutState();
  }

  void generateWorkout({
    required String goal,
    required String fitnessLevel,
    required int availableMinutes,
  }) {
    state = state.copyWith(isLoading: true);
    
    final workout = WorkoutGenerator.generateWorkout(
      goal: goal,
      fitnessLevel: fitnessLevel,
      availableMinutes: availableMinutes,
    );
    
    state = state.copyWith(
      currentWorkout: workout,
      isLoading: false,
    );
  }

  void generateQuickWorkout(int minutes) {
    state = state.copyWith(isLoading: true);
    
    final workout = WorkoutGenerator.generateQuickWorkout(minutes);
    
    state = state.copyWith(
      currentWorkout: workout,
      isLoading: false,
    );
  }

  void startWorkout() {
    if (state.currentWorkout == null) return;
    
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workout: state.currentWorkout!,
      startedAt: DateTime.now(),
    );
    
    state = state.copyWith(session: session);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.session == null || state.session!.isPaused || state.session!.isCompleted) return;
      
      final currentExercise = state.session!.currentExercise;
      if (currentExercise == null) return;
      
      final exerciseElapsed = state.session!.elapsedSeconds + 1;
      
      if (exerciseElapsed >= currentExercise.durationSeconds) {
        nextExercise();
      } else {
        state = state.copyWith(
          session: state.session!.copyWith(elapsedSeconds: exerciseElapsed),
        );
      }
    });
  }

  void pauseWorkout() {
    _timer?.cancel();
    state = state.copyWith(
      session: state.session?.copyWith(isPaused: true),
    );
  }

  void resumeWorkout() {
    state = state.copyWith(
      session: state.session?.copyWith(isPaused: false),
    );
    _startTimer();
  }

  void nextExercise() {
    if (state.session == null) return;
    
    final nextIndex = state.session!.currentExerciseIndex + 1;
    
    if (nextIndex >= state.session!.workout.exercises.length) {
      _timer?.cancel();
      state = state.copyWith(
        session: state.session!.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        ),
      );
    } else {
      state = state.copyWith(
        session: state.session!.copyWith(
          currentExerciseIndex: nextIndex,
          elapsedSeconds: 0,
        ),
      );
    }
  }

  void skipExercise() {
    nextExercise();
  }

  void resetWorkout() {
    _timer?.cancel();
    state = WorkoutState();
  }
}