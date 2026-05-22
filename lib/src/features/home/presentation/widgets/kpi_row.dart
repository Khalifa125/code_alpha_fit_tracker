import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';
import 'package:fit_tracker/src/features/sleep/presentation/providers/sleep_provider.dart';

class KPISummaryRow extends StatelessWidget {
  const KPISummaryRow({
    super.key,
    required this.summary,
    required this.waterState,
    required this.sleepState,
  });

  final DailySummary summary;
  final WaterState waterState;
  final SleepState sleepState;

  @override
  Widget build(BuildContext context) {
    final totalMins = sleepState.totalHours * 60 + sleepState.totalMinutes;
    final sleepHours = totalMins > 0 ? (totalMins / 60).toStringAsFixed(1) : '-';
    final waterLiters = (waterState.totalIntake / 1000).toStringAsFixed(1);

    return Row(
      children: [
        _KPICard(icon: Icons.bolt, label: 'Activity', value: '${summary.totalMinutes}', unit: 'min', color: FitColors.amber),
        SizedBox(width: 8.w),
        _KPICard(icon: Icons.local_fire_department, label: 'Calories', value: summary.totalCalories.toStringAsFixed(0), unit: 'kcal', color: FitColors.orange),
        SizedBox(width: 8.w),
        _KPICard(icon: Icons.nightlight_round, label: 'Sleep', value: sleepHours, unit: 'hrs', color: FitColors.purple),
        SizedBox(width: 8.w),
        _KPICard(icon: Icons.water_drop, label: 'Water', value: waterLiters, unit: 'L', color: FitColors.blue),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _KPICard extends StatelessWidget {
  const _KPICard({required this.icon, required this.label, required this.value, required this.unit, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GlassCard(
        opacity: isDark ? 0.06 : 0.2,
        radius: 12,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(height: 4.h),
            Text(value, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 13.sp, fontWeight: FontWeight.w700)),
            Text(unit, style: TextStyle(color: color, fontSize: 9.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 8.sp)),
          ],
        ),
      ),
    );
  }
}

class KPISkeletonRow extends StatelessWidget {
  const KPISkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: List.generate(4, (i) => Expanded(
        child: SizedBox(
          height: 82.h,
          child: GlassContainer(
            opacity: isDark ? 0.06 : 0.2,
            radius: 12,
            margin: EdgeInsets.only(right: i < 3 ? 8.w : 0),
          ),
        ).animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1200.ms, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.1)),
      )),
    );
  }
}
