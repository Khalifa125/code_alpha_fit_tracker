import 'package:flutter/material.dart';

class HeartRateEntry {
  final String id;
  final int bpm;
  final DateTime timestamp;
  final String? activity; // resting, walking, running, workout
  final String? note;

  HeartRateEntry({
    required this.id,
    required this.bpm,
    required this.timestamp,
    this.activity,
    this.note,
  });

  String get zone {
    if (bpm < 60) return 'Low';
    if (bpm < 80) return 'Resting';
    if (bpm < 100) return 'Light';
    if (bpm < 130) return 'Moderate';
    if (bpm < 160) return 'Hard';
    return 'Max';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'bpm': bpm,
    'timestamp': timestamp.toIso8601String(),
    'activity': activity,
    'note': note,
  };

  factory HeartRateEntry.fromJson(Map<String, dynamic> json) => HeartRateEntry(
    id: json['id'] as String,
    bpm: json['bpm'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
    activity: json['activity'] as String?,
    note: json['note'] as String?,
  );
}

class HeartRateStats {
  final int min;
  final int max;
  final double avg;
  final int count;

  HeartRateStats({
    required this.min,
    required this.max,
    required this.avg,
    required this.count,
  });

  factory HeartRateStats.empty() => HeartRateStats(min: 0, max: 0, avg: 0, count: 0);
}

class HeartRateZone {
  final String name;
  final int minBpm;
  final int maxBpm;
  final Color color;
  final String description;

  HeartRateZone({
    required this.name,
    required this.minBpm,
    required this.maxBpm,
    required this.color,
    required this.description,
  });

  static List<HeartRateZone> get zones => [
    HeartRateZone(name: 'Rest', minBpm: 0, maxBpm: 60, color: const Color(0xFF6B7280), description: 'Very low'),
    HeartRateZone(name: 'Resting', minBpm: 60, maxBpm: 80, color: const Color(0xFF22C55E), description: 'Normal'),
    HeartRateZone(name: 'Light', minBpm: 80, maxBpm: 100, color: const Color(0xFF3B82F6), description: 'Easy'),
    HeartRateZone(name: 'Moderate', minBpm: 100, maxBpm: 130, color: const Color(0xFFF59E0B), description: 'Fat burn'),
    HeartRateZone(name: 'Hard', minBpm: 130, maxBpm: 160, color: const Color(0xFFEF4444), description: 'Aerobic'),
    HeartRateZone(name: 'Max', minBpm: 160, maxBpm: 220, color: const Color(0xFFDC2626), description: 'Peak'),
  ];
}