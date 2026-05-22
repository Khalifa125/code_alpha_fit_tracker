import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';

class GoalsCard extends StatelessWidget {
  const GoalsCard({super.key, required this.summary, required this.profile});

  final DailySummary summary;
  final FitnessProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 20,
      padding: EdgeInsets.all(16.r),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Today's Goals", style: TextStyle(color: FitColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w700)),
          if (summary.activityCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: FitColors.neonGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${summary.activityCount} workout${summary.activityCount > 1 ? 's' : ''}',
                style: TextStyle(color: FitColors.neonGreen, fontSize: 10.sp, fontWeight: FontWeight.w600),
              ),
            ),
        ]),
        SizedBox(height: 16.h),
        _GoalRow(icon: Icons.directions_walk_rounded, label: 'Steps', current: summary.totalSteps.toDouble(), goal: (profile?.goalSteps ?? 10000).toDouble(), color: FitColors.neonGreen, unit: 'steps'),
        SizedBox(height: 12.h),
        _GoalRow(icon: Icons.fitness_center_rounded, label: 'Workout', current: summary.totalMinutes.toDouble(), goal: (profile?.goalMinutes ?? 45).toDouble(), color: FitColors.orange, unit: 'min'),
        SizedBox(height: 12.h),
        _GoalRow(icon: Icons.local_fire_department_rounded, label: 'Calories', current: summary.totalCalories, goal: profile?.goalCalories ?? 2000, color: FitColors.blue, unit: 'kcal'),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.icon, required this.label, required this.current, required this.goal, required this.color, required this.unit});

  final IconData icon;
  final String label;
  final double current;
  final double goal;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final pct = (progress * 100).toInt();

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp)),
        ]),
        Row(children: [
          Text('${current.toStringAsFixed(0)}/${goal.toStringAsFixed(0)} $unit', style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
          SizedBox(width: 6.w),
          Text('$pct%', style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w700)),
        ]),
      ]),
      SizedBox(height: 6.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: 800.ms,
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => LinearProgressIndicator(
            value: v,
            backgroundColor: FitColors.border,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 7.h,
          ),
        ),
      ),
    ]);
  }
}
