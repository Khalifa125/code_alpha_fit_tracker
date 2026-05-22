import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_details_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class CategoryScreen extends ConsumerWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allPlans = ref.watch(workoutPlansProvider);
    final categoryWorkouts = allPlans.where((p) => p.category == category || category == 'For You').toList();

    final totalMins = categoryWorkouts.fold(0, (int sum, p) => sum + p.durationMins);
    final totalCal = categoryWorkouts.fold(0, (int sum, p) => sum + p.calories);

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
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
                        color: isDark ? FitColors.cardDark : FitColors.cardLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category == 'For You' ? 'Recommended' : category,
                        style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 22.sp, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${categoryWorkouts.length} workouts • $totalMins min • ~$totalCal kcal',
                        style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp),
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
                          Icon(Icons.fitness_center_rounded, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 64.sp),
                          SizedBox(height: 16.h),
                          Text('No workouts found', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 16.sp)),
                          SizedBox(height: 8.h),
                          Text('Try a different category', style: TextStyle(color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 12.sp)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      cacheExtent: 500,
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      itemCount: categoryWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = categoryWorkouts[index];
                        return _WorkoutCard(
                          key: ValueKey(workout.id),
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

  const _WorkoutCard({super.key, required this.workout, required this.onTap});

  Color get _levelColor => switch (workout.level) {
    'Beginner' => FitColors.neonGreen,
    'Intermediate' => FitColors.orange,
    'Advanced' => FitColors.pink,
    _ => FitColors.cyan,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? FitColors.cardDark : FitColors.cardLight,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: FitColors.neonGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(child: Text(workout.emoji, style: TextStyle(fontSize: 28.sp))),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(workout.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 13.sp),
                      SizedBox(width: 3.w),
                      Text('${workout.durationMins} min', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                      SizedBox(width: 10.w),
                      Icon(Icons.local_fire_department_rounded, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 13.sp),
                      SizedBox(width: 3.w),
                      Text('~${workout.calories} kcal', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                      SizedBox(width: 10.w),
                      Icon(Icons.fitness_center, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 13.sp),
                      SizedBox(width: 3.w),
                      Text('${workout.exercises.length} ex', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _levelColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(workout.level, style: TextStyle(color: _levelColor, fontSize: 9.sp, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(width: 6.w),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 10.sp, color: FitColors.amber),
                          SizedBox(width: 2.w),
                          Text('${workout.rating}', style: TextStyle(color: FitColors.amber, fontSize: 9.sp, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  if (workout.targetMuscles.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    MuscleGroupIndicator(muscles: workout.targetMuscles),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 22.sp),
          ],
        ),
      ),
    );
  }
}
