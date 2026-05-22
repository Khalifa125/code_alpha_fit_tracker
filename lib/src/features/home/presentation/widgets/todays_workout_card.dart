import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';

class TodaysWorkoutCard extends StatelessWidget {
  const TodaysWorkoutCard({super.key, required this.summary});

  final DailySummary? summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasWorkoutToday = (summary?.activityCount ?? 0) > 0;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 16,
      padding: EdgeInsets.all(16.r),
      tint: FitColors.neonGreen.withValues(alpha: 0.5),
      border: BorderSide(color: FitColors.neonGreen.withValues(alpha: 0.3)),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: FitColors.neonGreen.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(hasWorkoutToday ? Icons.check : Icons.fitness_center, color: FitColors.neonGreen, size: 24),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hasWorkoutToday ? 'Workout Complete!' : "Today's Workout", style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 2.h),
                Text(hasWorkoutToday ? '${summary!.totalMinutes} min · ${summary!.totalCalories.toStringAsFixed(0)} kcal' : 'Ready to start your training', style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(color: FitColors.neonGreen, borderRadius: BorderRadius.circular(8)),
            child: Text('Start', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05);
  }
}
