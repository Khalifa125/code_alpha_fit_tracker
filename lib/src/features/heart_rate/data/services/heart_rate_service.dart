import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker/src/features/heart_rate/data/models/heart_rate_models.dart';

class HeartRateService {
  static const _entriesKey = 'heart_rate_entries';

  final SharedPreferences _prefs;

  HeartRateService(this._prefs);

  static Future<HeartRateService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return HeartRateService(prefs);
  }

  List<HeartRateEntry> _getAllEntries() {
    final data = _prefs.getString(_entriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => HeartRateEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<HeartRateEntry>> getEntriesForDate(DateTime date) async {
    final all = _getAllEntries();
    return all.where((e) =>
      e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day
    ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addEntry(HeartRateEntry entry) async {
    final all = _getAllEntries();
    all.add(entry);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteEntry(String id) async {
    final all = _getAllEntries();
    all.removeWhere((e) => e.id == id);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<HeartRateStats> getStatsForDate(DateTime date) async {
    final entries = await getEntriesForDate(date);
    if (entries.isEmpty) return HeartRateStats.empty();
    
    final bpmList = entries.map((e) => e.bpm).toList();
    return HeartRateStats(
      min: bpmList.reduce((a, b) => a < b ? a : b),
      max: bpmList.reduce((a, b) => a > b ? a : b),
      avg: bpmList.reduce((a, b) => a + b) / bpmList.length,
      count: bpmList.length,
    );
  }

  Future<List<HeartRateEntry>> getWeekEntries() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final all = _getAllEntries();
    return all.where((e) => e.timestamp.isAfter(weekAgo)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
