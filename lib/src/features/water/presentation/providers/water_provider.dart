import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/water/data/models/water_models.dart';
import 'package:fit_tracker/src/features/water/data/services/water_service.dart';

final waterServiceProvider = Provider<WaterService>((ref) {
  throw UnimplementedError('WaterService must be initialized before use');
});

final waterProvider = StateNotifierProvider<WaterNotifier, WaterState>((ref) {
  final service = ref.watch(waterServiceProvider);
  return WaterNotifier(service);
});

class WaterState {
  final List<WaterEntry> entries;
  final int goal;
  final List<WaterReminder> reminders;
  final DateTime selectedDate;
  final bool isLoading;

  WaterState({
    this.entries = const [],
    this.goal = 2000,
    this.reminders = const [],
    DateTime? selectedDate,
    this.isLoading = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  int get totalIntake => entries.fold(0, (sum, e) => sum + e.amount);
  double get progress => (totalIntake / goal).clamp(0.0, 1.0);
  int get remaining => (goal - totalIntake).clamp(0, goal);

  WaterState copyWith({
    List<WaterEntry>? entries,
    int? goal,
    List<WaterReminder>? reminders,
    DateTime? selectedDate,
    bool? isLoading,
  }) => WaterState(
    entries: entries ?? this.entries,
    goal: goal ?? this.goal,
    reminders: reminders ?? this.reminders,
    selectedDate: selectedDate ?? this.selectedDate,
    isLoading: isLoading ?? this.isLoading,
  );
}

class WaterNotifier extends StateNotifier<WaterState> {
  final WaterService _service;

  WaterNotifier(this._service) : super(WaterState(goal: _service.getGoal())) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    final entries = await _service.getEntriesForDate(state.selectedDate);
    final reminders = _service.getReminders();
    state = state.copyWith(
      entries: entries,
      reminders: reminders,
      isLoading: false,
    );
  }

  Future<void> addWater(int amount, {String? note}) async {
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: DateTime.now(),
      note: note,
    );
    await _service.addEntry(entry);
    await _loadData();
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
    await _loadData();
  }

  Future<void> setGoal(int goal) async {
    await _service.setGoal(goal);
    state = state.copyWith(goal: goal);
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    final reminders = state.reminders.map((r) {
      if (r.id == id) {
        return WaterReminder(
        id: r.id,
        hour: r.hour,
        minute: r.minute,
        isEnabled: enabled,
        label: r.label,
      );
      }
      return r;
    }).toList();
    await _service.saveReminders(reminders);
    state = state.copyWith(reminders: reminders);
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await _loadData();
  }
}

final weeklyWaterProvider = FutureProvider<List<WaterEntry>>((ref) async {
  final service = ref.watch(waterServiceProvider);
  return service.getWeekEntries();
});