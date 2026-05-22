
import 'dart:async';

class PedometerService {
  final _stepCountController = StreamController<int>.broadcast();
  final _pedestrianStatusController = StreamController<String>.broadcast();

  Stream<int> get stepStream => _stepCountController.stream;
  Stream<String> get pedestrianStream => _pedestrianStatusController.stream;

  Future<void> init() async {
    // Pedometer functionality available on physical devices only
    // Placeholder - actual implementation requires platform channels
  }

  void resetSteps() {
  }

  void dispose() {
    _stepCountController.close();
    _pedestrianStatusController.close();
  }
}
