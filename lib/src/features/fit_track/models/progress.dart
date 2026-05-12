class ProgressStats {
  final int totalWorkouts;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final List<DateTime> workoutDates;

  ProgressStats({
    this.totalWorkouts = 0,
    this.totalMinutes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.workoutDates = const [],
  });

  Map<String, dynamic> toJson() => {
    'totalWorkouts': totalWorkouts,
    'totalMinutes': totalMinutes,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'workoutDates': workoutDates.map((d) => d.toIso8601String()).toList(),
  };

  factory ProgressStats.fromJson(Map<String, dynamic> json) => ProgressStats(
    totalWorkouts: json['totalWorkouts'] as int? ?? 0,
    totalMinutes: json['totalMinutes'] as int? ?? 0,
    currentStreak: json['currentStreak'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    workoutDates: (json['workoutDates'] as List?)
        ?.map((d) => DateTime.parse(d as String))
        .toList() ?? [],
  );

  ProgressStats copyWith({
    int? totalWorkouts,
    int? totalMinutes,
    int? currentStreak,
    int? longestStreak,
    List<DateTime>? workoutDates,
  }) => ProgressStats(
    totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    workoutDates: workoutDates ?? this.workoutDates,
  );
}

class WeeklyActivity {
  final DateTime weekStart;
  final List<int> dailyMinutes;

  WeeklyActivity({
    required this.weekStart,
    required this.dailyMinutes,
  });

  int get totalMinutes => dailyMinutes.fold(0, (a, b) => a + b);
  int get workoutDays => dailyMinutes.where((m) => m > 0).length;
}
