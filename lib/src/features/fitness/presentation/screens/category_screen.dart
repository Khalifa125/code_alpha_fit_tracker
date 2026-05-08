import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_details_screen.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class CategoryScreen extends ConsumerWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPlans = ref.watch(workoutPlansProvider);
    final categoryWorkouts = allPlans.where((p) => p.category == category || category == 'For You').toList();

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: FitColors.card,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: FitColors.border),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: FitColors.textPrimary, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: TextStyle(
                          color: FitColors.textPrimary,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${categoryWorkouts.length} workouts',
                        style: TextStyle(
                          color: FitColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Workouts List
            Expanded(
              child: categoryWorkouts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center_rounded, color: FitColors.textMuted, size: 64.sp),
                          SizedBox(height: 16.h),
                          Text(
                            'No workouts found',
                            style: TextStyle(color: FitColors.textSecondary, fontSize: 16.sp),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      itemCount: categoryWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = categoryWorkouts[index];
                        return _WorkoutCard(
                          workout: workout,
                          onTap: () => Navigator.push<void>(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => WorkoutDetailsScreen(workout: workout),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                        ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.05, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutPlan workout;
  final VoidCallback onTap;

  const _WorkoutCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: FitColors.card,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: FitColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: FitColors.neonGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                _getIconForCategory(workout.category),
                color: FitColors.neonGreen,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: FitColors.textMuted, size: 14.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '${workout.durationMins} min',
                        style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(workout.level).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          workout.level,
                          style: TextStyle(
                            color: _getDifficultyColor(workout.level),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(Icons.chevron_right_rounded, color: FitColors.textMuted, size: 24.sp),
          ],
        ),
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

  Color _getDifficultyColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return FitColors.neonGreen;
      case 'intermediate':
        return FitColors.orange;
      case 'advanced':
        return FitColors.red;
      default:
        return FitColors.neonGreen;
    }
  }
}