class SleepEntry {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int? quality; // 1-5 rating
  final String? note;

  SleepEntry({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.quality,
    this.note,
  });

  Duration get duration => endTime.difference(startTime);
  int get hours => duration.inHours;
  int get minutes => duration.inMinutes % 60;

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'quality': quality,
    'note': note,
  };

  factory SleepEntry.fromJson(Map<String, dynamic> json) => SleepEntry(
    id: json['id'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    quality: json['quality'] as int?,
    note: json['note'] as String?,
  );
}

class SleepWeeklySummary {
  final DateTime weekStart;
  final List<SleepEntry> entries;

  SleepWeeklySummary({required this.weekStart, required this.entries});

  double get avgHours {
    if (entries.isEmpty) return 0;
    return entries.fold(0, (sum, e) => sum + e.duration.inMinutes) / entries.length / 60;
  }

  double get avgQuality {
    final rated = entries.where((e) => e.quality != null).toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0, (sum, e) => sum + (e.quality ?? 0)) / rated.length;
  }

  Map<int, int> get hoursByDay {
    final map = <int, int>{};
    for (var i = 0; i < 7; i++) {
      map[i] = 0;
    }
    for (final entry in entries) {
      final day = entry.startTime.weekday - 1;
      map[day] = (map[day] ?? 0) + entry.hours;
    }
    return map;
  }
}
