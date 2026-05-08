import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/sleep/data/models/sleep_models.dart';
import 'package:fit_tracker/src/features/sleep/data/services/sleep_service.dart';

final sleepServiceProvider = Provider<SleepService>((ref) {
  throw UnimplementedError('SleepService must be initialized before use');
});

final sleepProvider = StateNotifierProvider<SleepNotifier, SleepState>((ref) {
  final service = ref.watch(sleepServiceProvider);
  return SleepNotifier(service);
});

class SleepState {
  final List<SleepEntry> entries;
  final DateTime selectedDate;
  final bool isLoading;

  SleepState({
    this.entries = const [],
    DateTime? selectedDate,
    this.isLoading = false,
  }) : selectedDate = selectedDate ?? DateTime.now();

  int get totalHours => entries.fold(0, (sum, e) => sum + e.hours);
  int get totalMinutes => entries.fold(0, (sum, e) => sum + e.minutes);
  double get avgQuality {
    final rated = entries.where((e) => e.quality != null).toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0, (sum, e) => sum + (e.quality ?? 0)) / rated.length;
  }

  SleepState copyWith({
    List<SleepEntry>? entries,
    DateTime? selectedDate,
    bool? isLoading,
  }) => SleepState(
    entries: entries ?? this.entries,
    selectedDate: selectedDate ?? this.selectedDate,
    isLoading: isLoading ?? this.isLoading,
  );
}

class SleepNotifier extends StateNotifier<SleepState> {
  final SleepService _service;

  SleepNotifier(this._service) : super(SleepState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    final entries = await _service.getEntriesForDate(state.selectedDate);
    state = state.copyWith(entries: entries, isLoading: false);
  }

  Future<void> addSleep({
    required DateTime startTime,
    required DateTime endTime,
    int? quality,
    String? note,
  }) async {
    final entry = SleepEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: startTime,
      endTime: endTime,
      quality: quality,
      note: note,
    );
    await _service.addEntry(entry);
    await _loadData();
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
    await _loadData();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await _loadData();
  }
}

final weeklySleepProvider = FutureProvider<SleepWeeklySummary>((ref) async {
  final service = ref.watch(sleepServiceProvider);
  final entries = await service.getWeekEntries();
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  return SleepWeeklySummary(weekStart: weekStart, entries: entries);
});

final monthlySleepProvider = FutureProvider<List<SleepEntry>>((ref) async {
  final service = ref.watch(sleepServiceProvider);
  return service.getMonthEntries();
});