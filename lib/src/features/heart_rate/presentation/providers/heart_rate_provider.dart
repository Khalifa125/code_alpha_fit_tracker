import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/heart_rate/data/models/heart_rate_models.dart';
import 'package:fit_tracker/src/features/heart_rate/data/services/heart_rate_service.dart';

final heartRateServiceProvider = Provider<HeartRateService>((ref) {
  throw UnimplementedError('HeartRateService must be initialized before use');
});

final heartRateProvider = NotifierProvider<HeartRateNotifier, HeartRateState>(() => HeartRateNotifier());

class HeartRateState {
  final List<HeartRateEntry> entries;
  final DateTime selectedDate;
  final bool isLoading;
  final HeartRateStats? stats;

  HeartRateState({
    this.entries = const [],
    DateTime? selectedDate,
    this.isLoading = false,
    this.stats,
  }) : selectedDate = selectedDate ?? DateTime.now();

  int? get latestBpm => entries.isNotEmpty ? entries.first.bpm : null;

  HeartRateState copyWith({
    List<HeartRateEntry>? entries,
    DateTime? selectedDate,
    bool? isLoading,
    HeartRateStats? stats,
  }) => HeartRateState(
    entries: entries ?? this.entries,
    selectedDate: selectedDate ?? this.selectedDate,
    isLoading: isLoading ?? this.isLoading,
    stats: stats ?? this.stats,
  );
}

class HeartRateNotifier extends Notifier<HeartRateState> {
  @override
  HeartRateState build() {
    final service = ref.watch(heartRateServiceProvider);
    _loadData(service);
    return HeartRateState();
  }

  Future<void> _loadData(HeartRateService service) async {
    state = state.copyWith(isLoading: true);
    final entries = await service.getEntriesForDate(state.selectedDate);
    final stats = await service.getStatsForDate(state.selectedDate);
    state = state.copyWith(entries: entries, stats: stats, isLoading: false);
  }

  Future<void> addHeartRate(int bpm, {String? activity, String? note}) async {
    final entry = HeartRateEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bpm: bpm,
      timestamp: DateTime.now(),
      activity: activity,
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

final weeklyHeartRateProvider = FutureProvider<List<HeartRateEntry>>((ref) async {
  final service = ref.watch(heartRateServiceProvider);
  return service.getWeekEntries();
});