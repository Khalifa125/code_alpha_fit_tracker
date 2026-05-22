import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/weekly_chart.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/skeleton_widgets.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';

class ActivityTab extends ConsumerWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekAsync = ref.watch(weekActivitiesProvider);
    final summaryAsync = ref.watch(dailySummaryProvider);

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                child: Text('Activity', style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: const _ActivityTabSelector(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: summaryAsync.when(
                  loading: () => const ActivitySkeleton(height: 120),
                  error: (_, __) => const ActivityError(),
                  data: (s) => _ActivityHeroStat(summary: s),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: weekAsync.when(
                  loading: () => const ActivitySkeleton(height: 200),
                  error: (_, __) => const ActivityError(),
                  data: (w) => WeeklyBarChart(activities: w),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 80.h),
                child: summaryAsync.when(
                  loading: () => const ActivitySkeleton(height: 80),
                  error: (_, __) => const ActivityError(),
                  data: (s) => _ActivityStatsRow(summary: s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTabSelector extends StatelessWidget {
  const _ActivityTabSelector();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      for (final label in ['Day', 'Week', 'Month', 'Year'])
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: GlassContainer(
            opacity: label == 'Week' ? 0.9 : isDark ? 0.06 : 0.2,
            radius: 20,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            tint: label == 'Week' ? FitColors.neonGreen : null,
            child: Text(label,
              style: TextStyle(
                color: label == 'Week' ? FitColors.background : (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                fontSize: 12.sp,
                fontWeight: label == 'Week' ? FontWeight.w700 : FontWeight.w400,
              )),
          ),
        ),
    ]);
  }
}

class _ActivityHeroStat extends StatelessWidget {
  const _ActivityHeroStat({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 20,
      padding: EdgeInsets.all(16.r),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${summary.totalSteps.toStringAsFixed(0)} steps',
          style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 32.sp, fontWeight: FontWeight.w800)),
        SizedBox(height: 4.h),
        Row(children: [
          Icon(Icons.arrow_upward_rounded, color: FitColors.neonGreen, size: 14.sp),
          Text('+10% vs last week', style: TextStyle(color: FitColors.neonGreen, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _ActivityStatsRow extends StatelessWidget {
  const _ActivityStatsRow({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 20,
      padding: EdgeInsets.all(16.r),
      child: Row(children: [
        Expanded(child: _ActivityStatCol(label: 'Distance', value: '${(summary.totalSteps * 0.0007).toStringAsFixed(1)} km', color: FitColors.orange)),
        Container(width: 0.5, height: 40.h, color: FitColors.border),
        Expanded(child: _ActivityStatCol(label: 'Calories', value: '${summary.totalCalories.toStringAsFixed(0)} kcal', color: FitColors.neonGreen)),
        Container(width: 0.5, height: 40.h, color: FitColors.border),
        Expanded(child: _ActivityStatCol(label: 'Active Time', value: '${(summary.totalMinutes ~/ 60)}h ${summary.totalMinutes % 60}m', color: FitColors.blue)),
      ]),
    );
  }
}

class _ActivityStatCol extends StatelessWidget {
  const _ActivityStatCol({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.w700)),
    SizedBox(height: 2.h),
    Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
  ]);
}
