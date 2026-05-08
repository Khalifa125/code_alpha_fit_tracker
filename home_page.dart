// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/add_activity_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/history_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_plans_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/bmi_screen.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';

// ─── FitTrack Design Tokens ────────────────────────────────────────────────

class FitColors {
  static const background  = Color(0xFF0D1117);
  static const surface     = Color(0xFF161B22);
  static const card        = Color(0xFF1C2333);
  static const cardHover   = Color(0xFF21293A);
  static const border      = Color(0xFF30363D);
  static const neonGreen   = Color(0xFF22C55E);
  static const neonGreenDim= Color(0xFF16A34A);
  static const cyan        = Color(0xFF22C55E); // aliased to green per design
  static const orange      = Color(0xFFFF6B35);
  static const blue        = Color(0xFF3B82F6);
  static const purple      = Color(0xFF8B5CF6);
  static const amber       = Color(0xFFF59E0B);
  static const pink        = Color(0xFFEC4899);
  static const textPrimary = Color(0xFFF0F6FC);
  static const textSecondary = Color(0xFF8B949E);
  static const textMuted   = Color(0xFF484F58);
  static const green       = Color(0xFF22C55E);
}

// ─── Main Shell ────────────────────────────────────────────────────────────

class FitTrackShell extends ConsumerStatefulWidget {
  const FitTrackShell({super.key});

  @override
  ConsumerState<FitTrackShell> createState() => _FitTrackShellState();
}

class _FitTrackShellState extends ConsumerState<FitTrackShell> {
  int _selectedIndex = 0;

  static const _screens = [
    _HomeTab(),
    _WorkoutTab(),
    _ActivityTab(),
    _NutritionTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _FitBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─── Bottom Navigation ─────────────────────────────────────────────────────

class _FitBottomNav extends StatelessWidget {
  const _FitBottomNav({required this.selectedIndex, required this.onTap});
  final int selectedIndex;
  final void Function(int) onTap;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.fitness_center_rounded, 'Workout'),
    (Icons.bar_chart_rounded, 'Activity'),
    (Icons.restaurant_menu_rounded, 'Nutrition'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: FitColors.surface,
        border: Border(top: BorderSide(color: FitColors.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60.h,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final (icon, label) = e.value;
              final selected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: 200.ms,
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: selected ? FitColors.neonGreen.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          icon,
                          size: 22.sp,
                          color: selected ? FitColors.neonGreen : FitColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: selected ? FitColors.neonGreen : FitColors.textMuted,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── HOME TAB ──────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);
    final weekAsync    = ref.watch(weekActivitiesProvider);
    final todayAsync   = ref.watch(todayActivitiesProvider);
    final profileAsync = ref.watch(fitnessProfileProvider);

    void invalidateAll() {
      ref.invalidate(dailySummaryProvider);
      ref.invalidate(todayActivitiesProvider);
      ref.invalidate(weekActivitiesProvider);
      ref.invalidate(fitnessProfileProvider);
      ref.invalidate(weightEntriesProvider);
    }

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: FitColors.neonGreen,
          backgroundColor: FitColors.card,
          onRefresh: () async => invalidateAll(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: _HomeHeader(),
                ),
              ),

              // Steps Circle + Side Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: summaryAsync.when(
                    loading: () => _StepsSkeletonCard(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (s) => _StepsHeroCard(summary: s),
                  ),
                ),
              ),

              // Today's Goals
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: profileAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (profile) => summaryAsync.maybeWhen(
                      data: (s) => _GoalsCard(summary: s, profile: profile),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

              // Weekly Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                  child: weekAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (w) => _WeeklyBarChart(activities: w),
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                  child: _SectionHeader(
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
                    _QuickActionTile(
                      icon: Icons.fitness_center_rounded,
                      label: 'Workouts',
                      color: FitColors.purple,
                      onTap: () => Navigator.push<void>(context,
                        MaterialPageRoute<void>(builder: (_) => const WorkoutPlansScreen())),
                    ),
                    SizedBox(width: 12.w),
                    _QuickActionTile(
                      icon: Icons.monitor_weight_rounded,
                      label: 'BMI',
                      color: FitColors.neonGreen,
                      onTap: () => Navigator.push<void>(context,
                        MaterialPageRoute<void>(builder: (_) => const BmiScreen()))
                          .then((_) => invalidateAll()),
                    ),
                    SizedBox(width: 12.w),
                    _QuickActionTile(
                      icon: Icons.history_rounded,
                      label: 'History',
                      color: FitColors.orange,
                      onTap: () => Navigator.push<void>(context,
                        MaterialPageRoute<void>(builder: (_) => const HistoryScreen()))
                          .then((_) => invalidateAll()),
                    ),
                  ]),
                ),
              ),

              // Today's Activities
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                  child: const _SectionHeader(title: "Today's Activities"),
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
                          child: _FitEmptyCard(
                            emoji: '🏃',
                            message: 'No activities logged today.\nTap + to add your first workout!',
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => ActivityTile(
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
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(builder: (_) => const AddActivityScreen()),
        ).then((_) => invalidateAll()),
        backgroundColor: FitColors.neonGreen,
        foregroundColor: FitColors.background,
        icon: const Icon(Icons.add_rounded),
        label: Text('Log Activity',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp)),
        elevation: 4,
      ),
    );
  }
}

// ─── Home Header ───────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Hi, Alex 👋',
            style: TextStyle(
              color: FitColors.textPrimary,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            "Let's crush your goals today",
            style: TextStyle(
              color: FitColors.textSecondary,
              fontSize: 13.sp,
            ),
          ),
        ]),
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: FitColors.neonGreen, width: 2),
            color: FitColors.card,
          ),
          child: Icon(Icons.person_rounded, color: FitColors.neonGreen, size: 22.sp),
        ),
      ],
    );
  }
}

// ─── Steps Hero Card ───────────────────────────────────────────────────────

class _StepsHeroCard extends StatelessWidget {
  const _StepsHeroCard({required this.summary});
  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    const stepGoal = 10000;
    final progress = (summary.totalSteps / stepGoal).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: FitColors.border),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 110.w,
            height: 110.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110.w,
                  height: 110.w,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: 1200.ms,
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 10,
                      backgroundColor: FitColors.border,
                      valueColor: const AlwaysStoppedAnimation(FitColors.neonGreen),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    summary.totalSteps.toString(),
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Steps',
                    style: TextStyle(
                      color: FitColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    '/${stepGoal ~/ 1000}k',
                    style: TextStyle(
                      color: FitColors.neonGreen,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SideStatRow(
                  icon: Icons.local_fire_department_rounded,
                  color: FitColors.orange,
                  label: 'Calories',
                  value: '${summary.totalCalories.toStringAsFixed(0)} kcal',
                ),
                SizedBox(height: 16.h),
                _SideStatRow(
                  icon: Icons.directions_walk_rounded,
                  color: FitColors.blue,
                  label: 'Distance',
                  value: '${(summary.totalSteps * 0.0007).toStringAsFixed(1)} km',
                ),
                SizedBox(height: 16.h),
                _SideStatRow(
                  icon: Icons.timer_rounded,
                  color: FitColors.neonGreen,
                  label: 'Active Time',
                  value: '${summary.totalMinutes} min',
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}

class _SideStatRow extends StatelessWidget {
  const _SideStatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 14.sp),
      ),
      SizedBox(width: 8.w),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
          style: TextStyle(color: FitColors.textPrimary, fontSize: 13.sp, fontWeight: FontWeight.w700)),
        Text(label,
          style: TextStyle(color: FitColors.textSecondary, fontSize: 10.sp)),
      ]),
    ]);
  }
}

// ─── Goals Card ────────────────────────────────────────────────────────────

class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.summary, required this.profile});
  final DailySummary summary;
  final FitnessProfileModel? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: FitColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Today's Goals",
            style: TextStyle(color: FitColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w700)),
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
        _GoalRow(
          icon: Icons.directions_walk_rounded,
          label: 'Steps',
          current: summary.totalSteps.toDouble(),
          goal: (profile?.goalSteps ?? 10000).toDouble(),
          color: FitColors.neonGreen,
          unit: 'steps',
        ),
        SizedBox(height: 12.h),
        _GoalRow(
          icon: Icons.fitness_center_rounded,
          label: 'Workout',
          current: summary.totalMinutes.toDouble(),
          goal: (profile?.goalMinutes ?? 45).toDouble(),
          color: FitColors.orange,
          unit: 'min',
        ),
        SizedBox(height: 12.h),
        _GoalRow(
          icon: Icons.local_fire_department_rounded,
          label: 'Calories',
          current: summary.totalCalories,
          goal: profile?.goalCalories ?? 2000,
          color: FitColors.blue,
          unit: 'kcal',
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.icon,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.unit,
  });
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
          Text(label,
            style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp)),
        ]),
        Row(children: [
          Text('${current.toStringAsFixed(0)}/${goal.toStringAsFixed(0)} $unit',
            style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
          SizedBox(width: 6.w),
          Text('$pct%',
            style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w700)),
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

// ─── Weekly Bar Chart ──────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.activities});
  final List<ActivityModel> activities;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final labels = List.generate(7, (i) =>
        DateFormat('E').format(now.subtract(Duration(days: 6 - i))));
    final calories = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return activities.where((a) =>
        a.date.year == day.year &&
        a.date.month == day.month &&
        a.date.day == day.day
      ).fold<double>(0, (s, a) => s + a.caloriesBurned);
    });

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: FitColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Activity',
            style: TextStyle(color: FitColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w700)),
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
            maxY: (calories.reduce((a, b) => a > b ? a : b) + 100).clamp(200, double.infinity),
            barGroups: List.generate(7, (i) => BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(
                toY: calories[i],
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
                    labels[v.toInt()],
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

// ─── Quick Action Tile ─────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 6.h),
          Text(label,
            style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

// ─── Section Header ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
        style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!,
            style: TextStyle(color: FitColors.neonGreen, fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ),
    ],
  );
}

// ─── Empty Card ────────────────────────────────────────────────────────────

class _FitEmptyCard extends StatelessWidget {
  const _FitEmptyCard({required this.emoji, required this.message});
  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 32.h),
    decoration: BoxDecoration(
      color: FitColors.card,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: FitColors.border),
    ),
    child: Column(children: [
      Text(emoji, style: TextStyle(fontSize: 36.sp)),
      SizedBox(height: 10.h),
      Text(message,
        textAlign: TextAlign.center,
        style: TextStyle(color: FitColors.textSecondary, fontSize: 13.sp, height: 1.5)),
    ]),
  );
}

// ─── Skeleton ──────────────────────────────────────────────────────────────

class _StepsSkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 130.h,
    decoration: BoxDecoration(
      color: FitColors.card,
      borderRadius: BorderRadius.circular(20.r),
    ),
  ).animate(onPlay: (c) => c.repeat())
    .shimmer(duration: 1200.ms, color: FitColors.border);
}

// ─── WORKOUT TAB ───────────────────────────────────────────────────────────

class _WorkoutTab extends StatelessWidget {
  const _WorkoutTab();

  @override
  Widget build(BuildContext context) {
    return const WorkoutPlansScreen();
  }
}

// ─── ACTIVITY TAB ──────────────────────────────────────────────────────────

class _ActivityTab extends ConsumerWidget {
  const _ActivityTab();

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
                child: Text('Activity',
                  style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              ),
            ),

            // Tab selector
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: _ActivityTabSelector(),
              ),
            ),

            // Big step count
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: summaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (s) => _ActivityHeroStat(summary: s),
                ),
              ),
            ),

            // Bar chart
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                child: weekAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (w) => _WeeklyBarChart(activities: w),
                ),
              ),
            ),

            // Stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 80.h),
                child: summaryAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final label in ['Day', 'Week', 'Month', 'Year'])
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: label == 'Week' ? FitColors.neonGreen : FitColors.card,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: label == 'Week' ? FitColors.neonGreen : FitColors.border),
            ),
            child: Text(label,
              style: TextStyle(
                color: label == 'Week' ? FitColors.background : FitColors.textSecondary,
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
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: FitColors.card,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: FitColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${summary.totalSteps.toStringAsFixed(0)} steps',
        style: TextStyle(color: FitColors.textPrimary, fontSize: 32.sp, fontWeight: FontWeight.w800)),
      SizedBox(height: 4.h),
      Row(children: [
        Icon(Icons.arrow_upward_rounded, color: FitColors.neonGreen, size: 14.sp),
        Text('+10% vs last week',
          style: TextStyle(color: FitColors.neonGreen, fontSize: 12.sp, fontWeight: FontWeight.w600)),
      ]),
    ]),
  );
}

class _ActivityStatsRow extends StatelessWidget {
  const _ActivityStatsRow({required this.summary});
  final DailySummary summary;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16.r),
    decoration: BoxDecoration(
      color: FitColors.card,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: FitColors.border),
    ),
    child: Row(children: [
      Expanded(child: _ActivityStatCol(
        label: 'Distance',
        value: '${(summary.totalSteps * 0.0007).toStringAsFixed(1)} km',
        color: FitColors.orange,
      )),
      Container(width: 0.5, height: 40.h, color: FitColors.border),
      Expanded(child: _ActivityStatCol(
        label: 'Calories',
        value: '${summary.totalCalories.toStringAsFixed(0)} kcal',
        color: FitColors.neonGreen,
      )),
      Container(width: 0.5, height: 40.h, color: FitColors.border),
      Expanded(child: _ActivityStatCol(
        label: 'Active Time',
        value: '${(summary.totalMinutes ~/ 60)}h ${summary.totalMinutes % 60}m',
        color: FitColors.blue,
      )),
    ]),
  );
}

class _ActivityStatCol extends StatelessWidget {
  const _ActivityStatCol({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value,
      style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.w700)),
    SizedBox(height: 2.h),
    Text(label,
      style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
  ]);
}

// ─── NUTRITION TAB ─────────────────────────────────────────────────────────

class _NutritionTab extends StatelessWidget {
  const _NutritionTab();

  static const _meals = [
    ('Breakfast', 'Oatmeal with fruits', 450, Icons.wb_sunny_rounded, FitColors.amber),
    ('Lunch',     'Grilled chicken salad', 550, Icons.lunch_dining_rounded, FitColors.neonGreen),
    ('Dinner',    'Salmon with vegetables', 450, Icons.restaurant_rounded, FitColors.blue),
    ('Snacks',    'Greek yogurt', 150, Icons.cookie_rounded, FitColors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    const totalCals = 1600;
    const budget = 2000;
    const remaining = budget - totalCals;

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Nutrition',
                style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              Icon(Icons.tune_rounded, color: FitColors.textSecondary, size: 22.sp),
            ]),
            SizedBox(height: 20.h),

            // Date nav
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chevron_left_rounded, color: FitColors.textSecondary, size: 22.sp),
              SizedBox(width: 8.w),
              Text('May 18, 2024',
                style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right_rounded, color: FitColors.textSecondary, size: 22.sp),
            ]),
            SizedBox(height: 20.h),

            // Calorie circle
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: FitColors.card,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: FitColors.border),
              ),
              child: Column(children: [
                Text('Calorie Budget',
                  style: TextStyle(color: FitColors.textSecondary, fontSize: 13.sp)),
                SizedBox(height: 4.h),
                Text('$budget kcal',
                  style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 16.h),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: const CircularProgressIndicator(
                          value: totalCals / budget,
                          strokeWidth: 10,
                          backgroundColor: FitColors.border,
                          valueColor: AlwaysStoppedAnimation(FitColors.neonGreen),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('$remaining',
                          style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w800)),
                        Text('Left',
                          style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
                      ]),
                    ]),
                  ),
                ]),
                SizedBox(height: 20.h),

                // Macros
                const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _MacroBar(label: 'Carbs', grams: '162g', pct: 45, color: FitColors.blue),
                  _MacroBar(label: 'Protein', grams: '91g', pct: 26, color: FitColors.neonGreen),
                  _MacroBar(label: 'Fat', grams: '67g', pct: 30, color: FitColors.orange),
                ]),
              ]),
            ),
            SizedBox(height: 20.h),

            Text('Meals',
              style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h),

            ...List.generate(_meals.length, (i) {
              final (type, desc, cals, icon, color) = _meals[i];
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: FitColors.card,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: FitColors.border),
                ),
                child: Row(children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: color, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(type,
                      style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    Text(desc,
                      style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
                  ])),
                  Text('$cals kcal',
                    style: TextStyle(color: FitColors.orange, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                ]),
              ).animate(delay: (i * 60).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({required this.label, required this.grams, required this.pct, required this.color});
  final String label;
  final String grams;
  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
    SizedBox(height: 4.h),
    Text(grams, style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.w700)),
    SizedBox(height: 4.h),
    SizedBox(
      width: 6.w,
      height: 50.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.r),
        child: RotatedBox(
          quarterTurns: 3,
          child: LinearProgressIndicator(
            value: pct / 100,
            backgroundColor: FitColors.border,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ),
    ),
    SizedBox(height: 4.h),
    Text('$pct%', style: TextStyle(color: FitColors.textMuted, fontSize: 10.sp)),
  ]);
}

// ─── PROFILE TAB ───────────────────────────────────────────────────────────

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab();

  static const _menuItems = [
    (Icons.flag_rounded,     'My Goals',       FitColors.neonGreen),
    (Icons.straighten_rounded, 'My Measurements', FitColors.blue),
    (Icons.emoji_events_rounded, 'Achievements',  FitColors.amber),
    (Icons.history_rounded,  'Activity History', FitColors.orange),
    (Icons.settings_rounded, 'Settings',       FitColors.purple),
    (Icons.help_outline_rounded, 'Help & Support', FitColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(fitnessProfileProvider);

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Profile',
                style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              Icon(Icons.settings_rounded, color: FitColors.textSecondary, size: 22.sp),
            ]),
            SizedBox(height: 24.h),

            // Avatar
            Center(child: Column(children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: FitColors.neonGreen, width: 2.5),
                  color: FitColors.card,
                ),
                child: Icon(Icons.person_rounded, color: FitColors.neonGreen, size: 40.sp),
              ),
              SizedBox(height: 12.h),
              Text('Alex Johnson',
                style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text('Level 12',
                style: TextStyle(color: FitColors.neonGreen, fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ])),
            SizedBox(height: 20.h),

            // Stats
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: FitColors.card,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: FitColors.border),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                const _ProfileStat(label: 'Workouts', value: '48', color: FitColors.neonGreen),
                Container(width: 0.5, height: 36.h, color: FitColors.border),
                const _ProfileStat(label: 'Days Active', value: '32', color: FitColors.blue),
                Container(width: 0.5, height: 36.h, color: FitColors.border),
                const _ProfileStat(label: 'Goals Achieved', value: '12', color: FitColors.orange),
              ]),
            ),
            SizedBox(height: 20.h),

            // BMI info from profile
            profileAsync.maybeWhen(
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return Container(
                  margin: EdgeInsets.only(bottom: 20.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: FitColors.card,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: FitColors.border),
                  ),
                  child: Row(children: [
                    Expanded(child: _ProfileStat(label: 'Height', value: '${profile.heightCm.toInt()} cm', color: FitColors.purple)),
                    Container(width: 0.5, height: 36.h, color: FitColors.border),
                    Expanded(child: _ProfileStat(label: 'Weight', value: '${profile.weightKg.toInt()} kg', color: FitColors.pink)),
                    Container(width: 0.5, height: 36.h, color: FitColors.border),
                    Expanded(child: _ProfileStat(label: 'BMI', value: profile.bmi.toStringAsFixed(1), color: FitColors.neonGreen)),
                  ]),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),

            // Menu
            ...List.generate(_menuItems.length, (i) {
              final (icon, label, color) = _menuItems[i];
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: FitColors.card,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: FitColors.border),
                ),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(icon, color: color, size: 18.sp),
                  ),
                  title: Text(label,
                    style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right_rounded, color: FitColors.textMuted, size: 18.sp),
                  onTap: () {
                    if (label == 'Activity History') {
                      Navigator.push<void>(context,
                        MaterialPageRoute<void>(builder: (_) => const HistoryScreen()));
                    } else if (label == 'My Measurements') {
                      Navigator.push<void>(context,
                        MaterialPageRoute<void>(builder: (_) => const BmiScreen()));
                    }
                  },
                ),
              ).animate(delay: (i * 40).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 16.sp, fontWeight: FontWeight.w800)),
    SizedBox(height: 2.h),
    Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 10.sp)),
  ]);
}

// ─── Backward-compat alias ─────────────────────────────────────────────────

class HomePage extends FitTrackShell {
  const HomePage({super.key});
}
