import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker/src/features/sleep/data/models/sleep_models.dart';

class SleepService {
  static const _entriesKey = 'sleep_entries';

  final SharedPreferences _prefs;

  SleepService(this._prefs);

  static Future<SleepService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SleepService(prefs);
  }

  List<SleepEntry> _getAllEntries() {
    final data = _prefs.getString(_entriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => SleepEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<SleepEntry>> getEntriesForDate(DateTime date) async {
    final all = _getAllEntries();
    return all.where((e) =>
      e.startTime.year == date.year &&
      e.startTime.month == date.month &&
      e.startTime.day == date.day
    ).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  Future<void> addEntry(SleepEntry entry) async {
    final all = _getAllEntries();
    all.add(entry);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> updateEntry(SleepEntry entry) async {
    final all = _getAllEntries();
    final idx = all.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      all[idx] = entry;
      await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
    }
  }

  Future<void> deleteEntry(String id) async {
    final all = _getAllEntries();
    all.removeWhere((e) => e.id == id);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<List<SleepEntry>> getWeekEntries() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final all = _getAllEntries();
    return all.where((e) => e.startTime.isAfter(weekAgo)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Future<List<SleepEntry>> getMonthEntries() async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final all = _getAllEntries();
    return all.where((e) => e.startTime.isAfter(monthAgo)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}
