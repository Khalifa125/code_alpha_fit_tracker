// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/fit_track/models/workout.dart';
import 'package:fit_tracker/src/features/fit_track/providers/workout_provider.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isPaused = false;
  bool _isCompleted = false;

  Exercise get currentExercise => widget.workout.exercises[_currentExerciseIndex];
  int get totalExercises => widget.workout.exercises.length;
  bool get isLastExercise => _currentExerciseIndex == totalExercises - 1;

  @override
  void initState() {
    super.initState();
    _startExerciseTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExerciseTimer() {
    _secondsRemaining = currentExercise.durationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _completeExercise();
          }
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _completeExercise() {
    _timer?.cancel();
    if (isLastExercise) {
      _finishWorkout();
    } else {
      setState(() {
        _currentExerciseIndex++;
      });
      _startExerciseTimer();
    }
  }

  void _skipExercise() {
    _timer?.cancel();
    if (isLastExercise) {
      _finishWorkout();
    } else {
      setState(() {
        _currentExerciseIndex++;
      });
      _startExerciseTimer();
    }
  }

  void _finishWorkout() {
    _timer?.cancel();
    setState(() {
      _isCompleted = true;
    });
    ref.read(progressProvider.notifier).recordWorkout(widget.workout.durationMinutes);
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletedScreen();
    }
    return _buildExerciseScreen();
  }

  Widget _buildExerciseScreen() {
    final progress = (_currentExerciseIndex + 1) / totalExercises;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Exercise ${_currentExerciseIndex + 1} of $totalExercises',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation(Color(0xFF22C55E)),
            minHeight: 4,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    currentExercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentExercise.muscleGroup,
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'seconds remaining',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _togglePause,
                        icon: Icon(
                          _isPaused ? Icons.play_arrow : Icons.pause,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 32),
                      ElevatedButton(
                        onPressed: _skipExercise,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: Text(
                          isLastExercise ? 'Finish' : 'Skip',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Color(0xFF22C55E),
              ),
              const SizedBox(height: 32),
              const Text(
                'Workout Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You completed ${widget.workout.title}',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.workout.durationMinutes} minutes',
                style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
