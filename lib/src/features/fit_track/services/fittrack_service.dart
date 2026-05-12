import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_tracker/src/features/fit_track/models/user_profile.dart';
import 'package:fit_tracker/src/features/fit_track/models/progress.dart';

class FitTrackService {
  static const _userKey = 'fittrack_user';
  static const _progressKey = 'fittrack_progress';
  static const _onboardingKey = 'fittrack_onboarding';
  static const _streakKey = 'fittrack_streak';
  static const _lastWorkoutKey = 'fittrack_last_workout';

  final SharedPreferences _prefs;

  FitTrackService(this._prefs);

  static Future<FitTrackService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return FitTrackService(prefs);
  }

  // User Management
  Future<void> saveUser(UserProfile user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  UserProfile? getUser() {
    final data = _prefs.getString(_userKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  Future<void> deleteUser() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_onboardingKey);
    await _prefs.remove(_progressKey);
    await _prefs.remove(_streakKey);
    await _prefs.remove(_lastWorkoutKey);
  }

  bool isLoggedIn() => getUser() != null;

  bool isOnboarded() => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboarded() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  // Progress Tracking
  Future<void> saveProgress(ProgressStats progress) async {
    await _prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  ProgressStats getProgress() {
    final data = _prefs.getString(_progressKey);
    if (data == null) return ProgressStats();
    return ProgressStats.fromJson(jsonDecode(data));
  }

  Future<void> recordWorkout(int durationMinutes) async {
    final progress = getProgress();
    final now = DateTime.now();
    
    // Update streak
    final lastWorkoutDate = _prefs.getString(_lastWorkoutKey);
    int currentStreak = progress.currentStreak;
    int longestStreak = progress.longestStreak;
    
    if (lastWorkoutDate != null) {
      final lastDate = DateTime.parse(lastWorkoutDate);
      final daysDiff = now.difference(lastDate).inDays;
      
      if (daysDiff == 1) {
        currentStreak++;
      } else if (daysDiff > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }
    
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    
    await _prefs.setString(_lastWorkoutKey, now.toIso8601String());
    
    final updatedProgress = progress.copyWith(
      totalWorkouts: progress.totalWorkouts + 1,
      totalMinutes: progress.totalMinutes + durationMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      workoutDates: [...progress.workoutDates, now],
    );
    
    await saveProgress(updatedProgress);
  }

  int getCurrentStreak() {
    final lastWorkoutDate = _prefs.getString(_lastWorkoutKey);
    if (lastWorkoutDate == null) return 0;
    
    final lastDate = DateTime.parse(lastWorkoutDate);
    final daysDiff = DateTime.now().difference(lastDate).inDays;
    
    if (daysDiff > 1) return 0;
    
    return getProgress().currentStreak;
  }

  // Quick Workout - generate based on available minutes
  bool hasCompletedOnboarding() => isOnboarded();
}
