// ignore_for_file: use_decorated_box, unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class WorkoutDetailsScreen extends ConsumerWidget {
  final WorkoutPlan workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: FitColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: FitColors.background,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: FitColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Workout', style: TextStyle(color: FitColors.textPrimary)),
            centerTitle: true,
            expandedHeight: 200.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      FitColors.neonGreen.withOpacity(0.3),
                      FitColors.background,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIconForCategory(workout.category),
                    size: 80.sp,
                    color: FitColors.neonGreen,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    workout.name,
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                  SizedBox(height: 8.h),
                  Text(
                    workout.category,
                    style: TextStyle(
                      color: FitColors.neonGreen,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  SizedBox(height: 24.h),

                  // Info Cards
                  Row(
                    children: [
                      _InfoCard(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value: '${workout.durationMins} min',
                      ),
                      SizedBox(width: 12.w),
                      _InfoCard(
                        icon: Icons.bar_chart_rounded,
                        label: 'Difficulty',
                        value: workout.level,
                      ),
                      SizedBox(width: 12.w),
                      _InfoCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Calories',
                        value: '~${workout.durationMins * 8}',
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  SizedBox(height: 24.h),

                  // Description
                  Text(
                    'About this workout',
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    workout.description,
                    style: TextStyle(
                      color: FitColors.textSecondary,
                      fontSize: 14.sp,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  SizedBox(height: 24.h),

                  // Exercises
                  Text(
                    'Exercises',
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...workout.exercises.asMap().entries.map((e) {
                    final index = e.key;
                    final exercise = e.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: FitColors.card,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: FitColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: FitColors.neonGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: FitColors.neonGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: TextStyle(
                                    color: FitColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${exercise.sets} sets × ${exercise.reps} reps',
                                  style: TextStyle(
                                    color: FitColors.textSecondary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: FitColors.textMuted),
                        ],
                      ),
                    ).animate(delay: (400 + index * 50).ms).fadeIn().slideX(begin: 0.05, end: 0);
                  }),
                  SizedBox(height: 32.h),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Starting ${workout.name}...'),
                            backgroundColor: FitColors.neonGreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FitColors.neonGreen,
                        foregroundColor: FitColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Start Workout',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center_rounded;
      case 'cardio':
        return Icons.directions_run_rounded;
      case 'yoga':
        return Icons.self_improvement_rounded;
      case 'hiit':
        return Icons.flash_on_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: FitColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: FitColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: FitColors.neonGreen, size: 20.sp),
            SizedBox(height: 8.h),
            Text(value, style: TextStyle(color: FitColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.sp)),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }
}