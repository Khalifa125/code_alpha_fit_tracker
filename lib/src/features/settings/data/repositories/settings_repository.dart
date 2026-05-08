// ignore_for_file: unused_field

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker/src/features/settings/presentation/screens/settings_screen.dart';

class SettingsRepository {
  static const _notificationKey = 'notification_settings';
  static const _workoutRemindersKey = 'workout_reminders';
  static const _dailyGoalsKey = 'daily_goals';
  static const _motivationKey = 'motivation_notifications';
  static const _intervalKey = 'reminder_interval';

  Future<NotificationSettings> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      workoutReminders: prefs.getBool(_workoutRemindersKey) ?? true,
      dailyGoals: prefs.getBool(_dailyGoalsKey) ?? true,
      motivationNotifications: prefs.getBool(_motivationKey) ?? true,
      reminderIntervalHours: prefs.getInt(_intervalKey) ?? 4,
    );
  }

  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_workoutRemindersKey, settings.workoutReminders);
    await prefs.setBool(_dailyGoalsKey, settings.dailyGoals);
    await prefs.setBool(_motivationKey, settings.motivationNotifications);
    await prefs.setInt(_intervalKey, settings.reminderIntervalHours);
  }
}