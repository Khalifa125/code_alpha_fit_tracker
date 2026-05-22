import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';

class StepsHeroCard extends StatelessWidget {
  const StepsHeroCard({super.key, required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    const stepGoal = 10000;
    final progress = (summary.totalSteps / stepGoal).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 24,
      padding: EdgeInsets.all(20.r),
      tint: FitColors.neonGreen.withValues(alpha: 0.5),
      border: BorderSide(color: FitColors.neonGreen.withValues(alpha: 0.2)),
      shadow: [
        BoxShadow(color: FitColors.neonGreen.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
        BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
      ],
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120.w, height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: FitColors.neonGreen.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)],
                  ),
                ),
                SizedBox(
                  width: 100.w, height: 100.w,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: 1500.ms,
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 10,
                      backgroundColor: FitColors.border.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation(Color.lerp(FitColors.neonGreen, FitColors.green, progress) ?? FitColors.neonGreen),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(summary.totalSteps.toString(), style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  Text('steps', style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp, fontWeight: FontWeight.w500)),
                  Text('/${stepGoal ~/ 1000}k', style: TextStyle(color: FitColors.neonGreen, fontSize: 11.sp, fontWeight: FontWeight.w700)),
                ]),
              ],
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SideStatRow(icon: Icons.local_fire_department_rounded, color: FitColors.orange, label: 'Calories', value: summary.totalCalories.toStringAsFixed(0), unit: 'kcal'),
                SizedBox(height: 16.h),
                _SideStatRow(icon: Icons.directions_walk_rounded, color: FitColors.blue, label: 'Distance', value: (summary.totalSteps * 0.0007).toStringAsFixed(1), unit: 'km'),
                SizedBox(height: 16.h),
                _SideStatRow(icon: Icons.timer_rounded, color: FitColors.neonGreen, label: 'Active', value: '${summary.totalMinutes}', unit: 'min'),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.15, end: 0);
  }
}

class _SideStatRow extends StatelessWidget {
  const _SideStatRow({required this.icon, required this.color, required this.label, required this.value, this.unit = ''});

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, color: color, size: 16.sp),
      ),
      SizedBox(width: 10.w),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Text(value, style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
            if (unit.isNotEmpty) Text(' $unit', style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 10.sp, fontWeight: FontWeight.w500)),
      ]),
    ]);
  }
}
