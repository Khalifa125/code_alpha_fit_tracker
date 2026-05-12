import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker/src/features/water/data/models/water_models.dart';

class WaterService {
  static const _entriesKey = 'water_entries';
  static const _goalKey = 'water_goal';
  static const _remindersKey = 'water_reminders';

  final SharedPreferences _prefs;

  WaterService(this._prefs);

  static Future<WaterService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return WaterService(prefs);
  }

  // Goal
  int getGoal() => _prefs.getInt(_goalKey) ?? 2000;
  Future<void> setGoal(int goal) => _prefs.setInt(_goalKey, goal);

  // Entries
  Future<List<WaterEntry>> getEntriesForDate(DateTime date) async {
    final all = _getAllEntries();
    return all.where((e) =>
      e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day
    ).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<WaterEntry> _getAllEntries() {
    final data = _prefs.getString(_entriesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => WaterEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addEntry(WaterEntry entry) async {
    final all = _getAllEntries();
    all.add(entry);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteEntry(String id) async {
    final all = _getAllEntries();
    all.removeWhere((e) => e.id == id);
    await _prefs.setString(_entriesKey, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  Future<List<WaterEntry>> getWeekEntries() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final all = _getAllEntries();
    return all.where((e) => e.timestamp.isAfter(weekAgo)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Reminders
  List<WaterReminder> getReminders() {
    final data = _prefs.getString(_remindersKey);
    if (data == null) return _defaultReminders();
    final list = jsonDecode(data) as List;
    return list.map((e) => WaterReminder.fromJson(e as Map<String, dynamic>)).toList();
  }

  List<WaterReminder> _defaultReminders() => [
    WaterReminder(id: '1', hour: 8, minute: 0, label: 'Morning'),
    WaterReminder(id: '2', hour: 10, minute: 0, label: 'Mid-morning'),
    WaterReminder(id: '3', hour: 12, minute: 0, label: 'Lunch'),
    WaterReminder(id: '4', hour: 14, minute: 0, label: 'Afternoon'),
    WaterReminder(id: '5', hour: 16, minute: 0, label: 'Evening'),
    WaterReminder(id: '6', hour: 18, minute: 0, label: 'Dinner'),
  ];

  Future<void> saveReminders(List<WaterReminder> reminders) async {
    await _prefs.setString(_remindersKey, jsonEncode(reminders.map((e) => e.toJson()).toList()));
  }

  Future<void> updateReminder(WaterReminder reminder) async {
    final all = getReminders();
    final idx = all.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) all[idx] = reminder;
    await saveReminders(all);
  }
}
