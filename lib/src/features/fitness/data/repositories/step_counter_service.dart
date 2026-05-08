import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer_2/pedometer_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterService {
  StreamSubscription<int>? _stepCountSubscription;
  
  final _stepCountController = StreamController<int>.broadcast();

  Stream<int> get stepCountStream => _stepCountController.stream;

  int _initialStepCount = 0;
  int _currentSteps = 0;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      final pedometer = Pedometer();
      _stepCountSubscription = pedometer.stepCountStream().listen(
        (int steps) {
          if (_initialStepCount == 0) {
            _initialStepCount = steps;
          }
          _currentSteps = steps - _initialStepCount;
          _stepCountController.add(_currentSteps);
          _saveTodaySteps(_currentSteps);
        },
        onError: (error) {
          _stepCountController.addError(error);
        },
      );
      
      // Load today's steps from local storage
      await _loadTodaySteps();
      _isInitialized = true;
    } catch (e) {
      // Pedometer not available on this device
    }
  }

  int get currentSteps => _currentSteps;

  Future<void> _loadTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final storedDate = prefs.getString('steps_date');
    final storedSteps = prefs.getInt('steps_today');
    
    if (storedDate == today && storedSteps != null) {
      _currentSteps = storedSteps;
      _initialStepCount = storedSteps;
    }
  }

  Future<void> _saveTodaySteps(int steps) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString('steps_date', today);
    await prefs.setInt('steps_today', steps);
  }

  void resetSteps() {
    _initialStepCount = _currentSteps;
    _stepCountController.add(0);
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _stepCountController.close();
  }
}

final stepCounterServiceProvider = Provider<StepCounterService>((ref) {
  final service = StepCounterService();
  ref.onDispose(() => service.dispose());
  return service;
});

final stepCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(stepCounterServiceProvider);
  service.init();
  return service.stepCountStream;
});

// Provider for today's total steps (combines activity logged steps + pedometer)
final todayStepsProvider = FutureProvider<int>((ref) async {
  final pedometerSteps = await ref.watch(stepCountProvider.future).catchError((_) => 0);
  return pedometerSteps;
});