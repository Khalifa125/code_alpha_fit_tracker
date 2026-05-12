// ignore_for_file: deprecated_member_use, unused_import, prefer_const_constructors, inference_failure_on_function_invocation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_plans_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/bmi_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/history_screen.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/profile_screen.dart'
    as app_profile;
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart'
    as app_auth;
import 'package:fit_tracker/src/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:fit_tracker/src/features/water/presentation/screens/water_tracking_screen.dart';
import 'package:fit_tracker/src/features/sleep/presentation/screens/sleep_tracking_screen.dart';
import 'package:fit_tracker/src/features/heart_rate/presentation/screens/heart_rate_screen.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/fit_track/providers/workout_provider.dart';
import 'package:fit_tracker/src/features/fit_track/providers/auth_provider.dart'
    as fit_track;
import 'package:fit_tracker/src/features/fit_track/screens/workout_session_screen.dart';
import 'package:fit_tracker/src/features/fit_track/screens/profile_screen.dart'
    as fit_track_profile;

class FitTrackHomePage extends ConsumerWidget {
  const FitTrackHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(fit_track.authProvider);
    final userName = authState.user?.name ?? 'Athlete';
    final streak = ref.watch(progressProvider).currentStreak;
    final totalWorkouts = ref.watch(progressProvider).totalWorkouts;
    final workout = ref.watch(workoutProvider).currentWorkout;

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: FitColors.neonGreen,
          backgroundColor: FitColors.card,
          onRefresh: () async {
            ref.invalidate(progressProvider);
          },
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $userName 👋',
                        style: TextStyle(
                          color: FitColors.textPrimary,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Let's crush your goals today",
                        style: TextStyle(
                          color: FitColors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  // Profile & Streak
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const fit_track_profile.ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: FitColors.cardDark,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: FitColors.textPrimary,
                            size: 24.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              FitColors.orange.withValues(alpha: 0.2),
                              FitColors.amber.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: FitColors.orange.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_fire_department,
                                color: FitColors.orange, size: 20.sp),
                            SizedBox(width: 6.w),
                            Text(
                              '$streak day${streak != 1 ? 's' : ''}',
                              style: TextStyle(
                                color: FitColors.orange,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: -0.1),
                ],
              ),

              SizedBox(height: 24.h),

              // Stats Row
              Row(
                children: [
                  _StatCard(
                    icon: Icons.fitness_center,
                    label: 'Workouts',
                    value: '$totalWorkouts',
                    color: FitColors.neonGreen,
                  ),
                  SizedBox(width: 12.w),
                  _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '$streak',
                    color: FitColors.orange,
                  ),
                  SizedBox(width: 12.w),
                  _StatCard(
                    icon: Icons.timer,
                    label: 'Minutes',
                    value: '${ref.watch(progressProvider).totalMinutes}',
                    color: FitColors.blue,
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              SizedBox(height: 24.h),

              // Today's Workout Card
              if (workout != null)
                _TodayWorkoutCard(workout: workout)
              else
                _NoWorkoutCard(),

              SizedBox(height: 24.h),

              // Quick Workout Button
              _QuickWorkoutButton(),

              SizedBox(height: 24.h),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: FitColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),

              Row(
                children: [
                  Expanded(
                      child: _QuickActionTile(
                    icon: Icons.water_drop,
                    label: 'Water',
                    color: FitColors.blue,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WaterTrackingScreen())),
                  )),
                  SizedBox(width: 12.w),
                  Expanded(
                      child: _QuickActionTile(
                    icon: Icons.nightlight,
                    label: 'Sleep',
                    color: FitColors.purple,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SleepTrackingScreen())),
                  )),
                  SizedBox(width: 12.w),
                  Expanded(
                      child: _QuickActionTile(
                    icon: Icons.favorite,
                    label: 'Heart',
                    color: FitColors.red,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HeartRateScreen())),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(height: 8.h),
              Text(value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  )),
              Text(label,
                  style: TextStyle(
                    color: FitColors.textSecondary,
                    fontSize: 10.sp,
                  )),
            ],
          ),
        ),
      );
}

class _TodayWorkoutCard extends StatelessWidget {
  final dynamic workout;

  const _TodayWorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FitColors.neonGreen.withValues(alpha: 0.2),
                FitColors.neonGreen.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            border:
                Border.all(color: FitColors.neonGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Workout",
                    style: TextStyle(
                      color: FitColors.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: FitColors.neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      workout.difficulty,
                      style: TextStyle(
                        color: FitColors.neonGreen,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                workout.title,
                style: TextStyle(
                  color: FitColors.textPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.timer,
                      color: FitColors.textSecondary, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text('${workout.durationMinutes} min',
                      style: TextStyle(
                          color: FitColors.textSecondary, fontSize: 12.sp)),
                  SizedBox(width: 16.w),
                  Icon(Icons.fitness_center,
                      color: FitColors.textSecondary, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text('${workout.exercises.length} exercises',
                      style: TextStyle(
                          color: FitColors.textSecondary, fontSize: 12.sp)),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutSessionScreen(workout: workout),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
}

class _NoWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: FitColors.card,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: FitColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.fitness_center, color: FitColors.textMuted, size: 48.sp),
            SizedBox(height: 12.h),
            Text(
              'No workout today',
              style: TextStyle(
                color: FitColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Generate your daily workout!',
              style: TextStyle(
                color: FitColors.textSecondary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms);
}

class _QuickWorkoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
        onTap: () {
          ref.read(workoutProvider.notifier).generateQuickWorkout(10);
        },
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: FitColors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: FitColors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: FitColors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.bolt, color: FitColors.orange, size: 24.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'I have 10 minutes',
                      style: TextStyle(
                        color: FitColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Generate a quick workout',
                      style: TextStyle(
                        color: FitColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: FitColors.orange, size: 16.sp),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 300.ms);
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}
