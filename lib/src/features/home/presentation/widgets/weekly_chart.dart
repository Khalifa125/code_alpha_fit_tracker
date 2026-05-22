import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key, required this.activities});

  final List<ActivityModel> activities;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  late List<String> _labels;
  late List<double> _calories;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  @override
  void didUpdateWidget(WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activities != widget.activities) _compute();
  }

  void _compute() {
    final now = DateTime.now();
    _labels = List.generate(7, (i) => DateFormat('E').format(now.subtract(Duration(days: 6 - i))));
    _calories = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return widget.activities.where((a) =>
        a.date.year == day.year && a.date.month == day.month && a.date.day == day.day
      ).fold<double>(0, (s, a) => s + a.caloriesBurned);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 20,
      padding: EdgeInsets.all(16.r),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Activity', style: TextStyle(color: FitColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w700)),
          Row(children: [
            const _PeriodChip(label: 'Week', selected: true),
            SizedBox(width: 6.w),
            const _PeriodChip(label: 'Month', selected: false),
          ]),
        ]),
        SizedBox(height: 16.h),
        SizedBox(
          height: 140.h,
          child: BarChart(BarChartData(
            maxY: (_calories.reduce((a, b) => a > b ? a : b) + 100).clamp(200, double.infinity),
            barGroups: List.generate(7, (i) => BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(
                toY: _calories[i],
                width: 20.w,
                color: i == 6 ? FitColors.neonGreen : FitColors.neonGreen.withValues(alpha: 0.25),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
              )],
            )),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => const FlLine(color: FitColors.border, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    _labels[v.toInt()],
                    style: TextStyle(
                      color: v.toInt() == 6 ? FitColors.neonGreen : FitColors.textMuted,
                      fontSize: 10.sp,
                      fontWeight: v.toInt() == 6 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              )),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => FitColors.surface,
                getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                  '${rod.toY.toStringAsFixed(0)} kcal',
                  TextStyle(color: FitColors.textPrimary, fontSize: 11.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )),
        ),
      ]),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms);
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: selected ? FitColors.neonGreen.withValues(alpha: 0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(6.r),
      border: selected ? Border.all(color: FitColors.neonGreen.withValues(alpha: 0.4)) : null,
    ),
    child: Text(
      label,
      style: TextStyle(
        color: selected ? FitColors.neonGreen : FitColors.textSecondary,
        fontSize: 11.sp,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    ),
  );
}
