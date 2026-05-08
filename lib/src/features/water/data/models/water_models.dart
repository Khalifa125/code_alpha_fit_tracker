class WaterEntry {
  final String id;
  final int amount; // in ml
  final DateTime timestamp;
  final String? note;

  WaterEntry({
    required this.id,
    required this.amount,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
  };

  factory WaterEntry.fromJson(Map<String, dynamic> json) => WaterEntry(
    id: json['id'] as String,
    amount: json['amount'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
    note: json['note'] as String?,
  );
}

class WaterDailySummary {
  final DateTime date;
  final List<WaterEntry> entries;
  final int goal;

  WaterDailySummary({
    required this.date,
    required this.entries,
    required this.goal,
  });

  int get totalIntake => entries.fold(0, (sum, e) => sum + e.amount);
  double get progress => (totalIntake / goal).clamp(0.0, 1.0);
  int get remaining => (goal - totalIntake).clamp(0, goal);
}

class WaterReminder {
  final String id;
  final int hour;
  final int minute;
  final bool isEnabled;
  final String? label;

  WaterReminder({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.label,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'hour': hour,
    'minute': minute,
    'isEnabled': isEnabled,
    'label': label,
  };

  factory WaterReminder.fromJson(Map<String, dynamic> json) => WaterReminder(
    id: json['id'] as String,
    hour: json['hour'] as int,
    minute: json['minute'] as int,
    isEnabled: json['isEnabled'] as bool? ?? true,
    label: json['label'] as String?,
  );
}