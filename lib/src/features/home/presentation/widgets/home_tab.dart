import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/add_activity_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_plans_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/bmi_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/history_screen.dart';
import 'package:fit_tracker/src/features/water/presentation/screens/water_tracking_screen.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';
import 'package:fit_tracker/src/features/sleep/presentation/screens/sleep_tracking_screen.dart';
import 'package:fit_tracker/src/features/sleep/presentation/providers/sleep_provider.dart';
import 'package:fit_tracker/src/features/heart_rate/presentation/screens/heart_rate_screen.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/home_header.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/kpi_row.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/todays_workout_card.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/weekly_chart.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/quick_action_tile.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);
    final weekAsync = ref.watch(weekActivitiesProvider);
    final todayAsync = ref.watch(todayActivitiesProvider);
    void invalidateAll() {
      ref.invalidate(dailySummaryProvider);
      ref.invalidate(todayActivitiesProvider);
      ref.invalidate(weekActivitiesProvider);
      ref.invalidate(fitnessProfileProvider);
      ref.invalidate(weightEntriesProvider);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitColors.neonGreen.withValues(alpha: 0.03),
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: FitColors.neonGreen,
            backgroundColor: FitColors.card,
            onRefresh: () async => invalidateAll(),
            child: RepaintBoundary(child: CustomScrollView(
              cacheExtent: 500,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: const HomeHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    child: summaryAsync.when(
                      loading: () => const KPISkeletonRow(),
                      error: (_, __) => const KPISkeletonRow(),
                      data: (s) => GlassContainer(
                        opacity: isDark ? 0.06 : 0.2,
                        padding: EdgeInsets.all(16.r),
                        radius: 20,
                        child: KPISummaryRow(
                          summary: s,
                          waterState: ref.watch(waterProvider),
                          sleepState: ref.watch(sleepProvider),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: TodaysWorkoutCard(summary: summaryAsync.valueOrNull),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: weekAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (w) => GlassContainer(
                        opacity: isDark ? 0.06 : 0.2,
                        padding: EdgeInsets.all(16.r),
                        radius: 20,
                        child: WeeklyBarChart(activities: w),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: SectionHeader(
                      title: 'Quick Actions',
                      action: 'See All',
                      onAction: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const WorkoutPlansScreen()),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: Row(children: [
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.fitness_center_rounded,
                          label: 'Workouts',
                          color: FitColors.purple,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const WorkoutPlansScreen())),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.monitor_weight_rounded,
                          label: 'BMI',
                          color: FitColors.neonGreen,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const BmiScreen()))
                              .then((_) => invalidateAll()),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.water_drop_rounded,
                          label: 'Water',
                          color: FitColors.blue,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const WaterTrackingScreen())),
                        ),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: Row(children: [
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.nightlight_rounded,
                          label: 'Sleep',
                          color: FitColors.purple,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const SleepTrackingScreen())),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.favorite_rounded,
                          label: 'Heart',
                          color: FitColors.red,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const HeartRateScreen())),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: QuickActionTile(
                          icon: Icons.history_rounded,
                          label: 'History',
                          color: FitColors.orange,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const HistoryScreen()))
                            .then((_) => invalidateAll()),
                        ),
                      ),
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: const SectionHeader(title: "Today's Activities"),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                  sliver: todayAsync.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator(
                        color: FitColors.neonGreen, strokeWidth: 2)),
                    ),
                    error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    data: (activities) => activities.isEmpty
                        ? const SliverToBoxAdapter(
                            child: FitEmptyCard(
                              emoji: '🏃',
                              message: 'No activities logged today.\nTap + to add your first workout!',
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => ActivityTile(
                                key: ValueKey(activities[i].id),
                                activity: activities[i],
                                onDelete: () async {
                                  await ref.read(fitnessRepoProvider).deleteActivity(activities[i].id);
                                  invalidateAll();
                                },
                              ),
                              childCount: activities.length,
                            ),
                          ),
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const AddActivityScreen()),
        ).then((_) => invalidateAll()),
        backgroundColor: FitColors.neonGreen,
        foregroundColor: Colors.white,
        elevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        icon: const Icon(Icons.add_rounded),
        label: Text('Log Activity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
      ),
    );
  }
}
