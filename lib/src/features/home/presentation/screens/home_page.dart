// ignore_for_file: deprecated_member_use, unused_element, prefer_const_declarations, unused_local_variable, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/add_activity_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/history_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_plans_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/bmi_screen.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/signin_screen.dart';
import 'package:fit_tracker/src/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';
import 'package:fit_tracker/src/features/water/presentation/screens/water_tracking_screen.dart';
import 'package:fit_tracker/src/features/sleep/presentation/providers/sleep_provider.dart';
import 'package:fit_tracker/src/features/sleep/presentation/screens/sleep_tracking_screen.dart';
import 'package:fit_tracker/src/features/heart_rate/presentation/screens/heart_rate_screen.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';


// ─── Main Shell ────────────────────────────────────────────────────────────
// NOTE: FitTrackShell is now used inside MainShell (ShellRoute)
// which already has the Scaffold + bottom nav
// So FitTrackShell just returns IndexedStack without Scaffold

class FitTrackShell extends ConsumerStatefulWidget {
  final Widget? child;
  
  const FitTrackShell({super.key, this.child});

  @override
  ConsumerState<FitTrackShell> createState() => _FitTrackShellState();
}

class _FitTrackShellState extends ConsumerState<FitTrackShell> {
  final int _selectedIndex = 0;

  static const _screens = [
    _HomeTab(),
    _WorkoutTab(),
    _ActivityTab(),
    _NutritionTab(),
    _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    // No Scaffold here - parent MainShell provides it
    return SafeArea(
      child: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: FitColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: FitColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: FitColors.neonGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          height: 46.h,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final (icon, label) = e.value;
              final selected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: selected 
                          ? FitColors.neonGreen.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: 200.ms,
                          child: Icon(
                            icon,
                            key: ValueKey('$i-$selected'),
                            size: 20.sp,
                            color: selected ? FitThemeColors.of(context).textPrimary : FitColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AnimatedDefaultTextStyle(
                          duration: 200.ms,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: selected ? FitThemeColors.of(context).textPrimary : FitColors.textMuted,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          child: Text(label),
                        ),
                      ],
                    ),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitColors.neonGreen.withValues(alpha: 0.03),
              isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
              isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
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
                    child: _HomeHeader(),
                  ),
                ),

                // KPI Row (matching mockup style)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    child: summaryAsync.when(
                      loading: () => _KPISkeletonRow(),
                      error: (_, __) => _KPISkeletonRow(),
                      data: (s) => GlassContainer(
                        opacity: isDark ? 0.06 : 0.2,
                        padding: EdgeInsets.all(16.r),
                        radius: 20,
                        child: _KPISummaryRow(
                          summary: s,
                          waterState: ref.watch(waterProvider),
                          sleepState: ref.watch(sleepProvider),
                        ),
                      ),
                    ),
                  ),
                ),

                // Today's Workout Card (matching mockup style)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    child: _TodaysWorkoutCard(summary: summaryAsync.value),
                  ),
                ),

                // Weekly Chart
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
                        child: _WeeklyBarChart(activities: w),
                      ),
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
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.fitness_center_rounded,
                          label: 'Workouts',
                          color: FitColors.purple,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const WorkoutPlansScreen())),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickActionTile(
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
                        child: _QuickActionTile(
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
                        child: _QuickActionTile(
                          icon: Icons.nightlight_rounded,
                          label: 'Sleep',
                          color: FitColors.purple,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const SleepTrackingScreen())),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickActionTile(
                          icon: Icons.favorite_rounded,
                          label: 'Heart',
                          color: FitColors.red,
                          onTap: () => Navigator.push<void>(context,
                            MaterialPageRoute<void>(builder: (_) => const HeartRateScreen())),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickActionTile(
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
          ),
          ),
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

// ─── Home Header ───────────────────────────────────────────────────────────

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? 'Athlete';
    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}';
    final streak = 0; // Streak will be shown in FitTrack module

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${_getGreeting()}, $userName',
                style: TextStyle(
                  color: FitColors.textPrimary,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: FitColors.neonGreen,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (streak > 0) ...[
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: FitColors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: FitColors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, color: FitColors.orange, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            '$streak',
                            style: TextStyle(
                              color: FitColors.orange,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ]),
            GestureDetector(
              onTap: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      FitColors.neonGreen.withValues(alpha: 0.8),
                      FitColors.neonGreen.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: FitColors.neonGreen.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FitColors.neonGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 24.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "Let's crush your goals today",
          style: TextStyle(
            color: FitColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _weekday(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  String _month(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 24,
      padding: EdgeInsets.all(20.r),
      tint: FitColors.neonGreen.withValues(alpha: 0.5),
      border: BorderSide(color: FitColors.neonGreen.withValues(alpha: 0.2)),
      shadow: [
        BoxShadow(
          color: FitColors.neonGreen.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        children: [
          // Circular progress with glow
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: FitColors.neonGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100.w,
                  height: 100.w,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: 1500.ms,
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 10,
                      backgroundColor: FitColors.border.withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation(
                        Color.lerp(FitColors.neonGreen, FitColors.green, progress) ?? FitColors.neonGreen,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    summary.totalSteps.toString(),
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'steps',
                    style: TextStyle(
                      color: FitColors.textSecondary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '/${stepGoal ~/ 1000}k',
                    style: TextStyle(
                      color: FitColors.neonGreen,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          SizedBox(width: 24.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SideStatRow(
                  icon: Icons.local_fire_department_rounded,
                  color: FitColors.orange,
                  label: 'Calories',
                  value: summary.totalCalories.toStringAsFixed(0),
                  unit: 'kcal',
                ),
                SizedBox(height: 16.h),
                _SideStatRow(
                  icon: Icons.directions_walk_rounded,
                  color: FitColors.blue,
                  label: 'Distance',
                  value: (summary.totalSteps * 0.0007).toStringAsFixed(1),
                  unit: 'km',
                ),
                SizedBox(height: 16.h),
                _SideStatRow(
                  icon: Icons.timer_rounded,
                  color: FitColors.neonGreen,
                  label: 'Active',
                  value: '${summary.totalMinutes}',
                  unit: 'min',
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.15, end: 0);
  }
}

class _SideStatRow extends StatelessWidget {
  const _SideStatRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.unit = '',
  });
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
            Text(value,
              style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
            if (unit.isNotEmpty)
              Text(' $unit',
                style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 2.h),
        Text(label,
          style: TextStyle(color: FitColors.textSecondary, fontSize: 10.sp, fontWeight: FontWeight.w500)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 20,
      padding: EdgeInsets.all(16.r),
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

class _WeeklyBarChart extends StatefulWidget {
  const _WeeklyBarChart({required this.activities});
  final List<ActivityModel> activities;

  @override
  State<_WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<_WeeklyBarChart> {
  late List<String> _labels;
  late List<double> _calories;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  @override
  void didUpdateWidget(_WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activities != widget.activities) _compute();
  }

  void _compute() {
    final now = DateTime.now();
    _labels = List.generate(7, (i) =>
        DateFormat('E').format(now.subtract(Duration(days: 6 - i))));
    _calories = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return widget.activities.where((a) =>
        a.date.year == day.year &&
        a.date.month == day.month &&
        a.date.day == day.day
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

// ─── Quick Action Tile ─────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: GlassContainer(
      radius: 16,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      tint: color,
      border: BorderSide(color: color.withValues(alpha: 0.15)),
      shadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 16,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(children: [
        Text(emoji, style: TextStyle(fontSize: 36.sp)),
        SizedBox(height: 10.h),
        Text(message,
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp, height: 1.5)),
      ]),
    );
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────────

class _StepsSkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 24,
      padding: EdgeInsets.all(20.r),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 14, width: 140.w, decoration: BoxDecoration(color: FitColors.border, borderRadius: BorderRadius.circular(4))),
        SizedBox(height: 16.h),
        Row(children: [
          Container(width: 80.w, height: 80.w, decoration: BoxDecoration(shape: BoxShape.circle, color: FitColors.border)),
          SizedBox(width: 20.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 12, width: 100.w, decoration: BoxDecoration(color: FitColors.border, borderRadius: BorderRadius.circular(4))),
            SizedBox(height: 8.h),
            Container(height: 10, width: 60.w, decoration: BoxDecoration(color: FitColors.border, borderRadius: BorderRadius.circular(4))),
          ]),
        ]),
      ]),
    );
  }
}

// ─── KPI Row (matching mockup) ───────────────────────────────────────────────

class _KPISummaryRow extends StatelessWidget {
  const _KPISummaryRow({required this.summary, required this.waterState, required this.sleepState});
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

class _KPISkeletonRow extends StatelessWidget {
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

// ─── Today's Workout Card (matching mockup) ──────────────────────────────────

class _TodaysWorkoutCard extends StatelessWidget {
  const _TodaysWorkoutCard({required this.summary});
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
                Text(hasWorkoutToday ? 'Workout Complete!' : 'Today\'s Workout', style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 2.h),
                Text(hasWorkoutToday ? '${summary!.totalMinutes} min · ${summary!.totalCalories.toStringAsFixed(0)} kcal' : 'Ready to start your training', style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: FitColors.neonGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Start', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.05);
  }
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
          Text('+10% vs last week',
            style: TextStyle(color: FitColors.neonGreen, fontSize: 12.sp, fontWeight: FontWeight.w600)),
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

class _NutritionTab extends ConsumerWidget {
  const _NutritionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nutritionState = ref.watch(nutritionProvider);
    final totalCals = nutritionState.totalCalories;
    final budget = nutritionState.calorieGoal;
    final remaining = nutritionState.remaining;
    final entries = nutritionState.entries;

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Nutrition',
                style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () {
                  ref.read(nutritionProvider.notifier).setCalorieGoal(2000);
                },
                child: Icon(Icons.tune_rounded, color: FitColors.textSecondary, size: 22.sp),
              ),
            ]),
            SizedBox(height: 20.h),

            // Date nav
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chevron_left_rounded, color: FitColors.textSecondary, size: 22.sp),
              SizedBox(width: 8.w),
              Text(DateFormat('MMM dd, yyyy').format(DateTime.now()),
                style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right_rounded, color: FitColors.textSecondary, size: 22.sp),
            ]),
            SizedBox(height: 20.h),

            // Calorie circle
            GlassContainer(
              opacity: isDark ? 0.06 : 0.2,
              radius: 20,
              padding: EdgeInsets.all(20.r),
              child: Column(children: [
                Text('Calorie Budget',
                  style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp)),
                SizedBox(height: 4.h),
                Text('$budget kcal',
                  style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 16.h),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 100.w,
                        height: 100.w,
                        child: CircularProgressIndicator(
                          value: totalCals / budget,
                          strokeWidth: 10,
                          backgroundColor: FitColors.border,
                          valueColor: const AlwaysStoppedAnimation(FitColors.neonGreen),
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
                Builder(builder: (context) {
                  final state = ref.watch(nutritionProvider);
                  return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _MacroBar(label: 'Carbs', grams: '${state.totalCarbs.toStringAsFixed(0)}g', pct: 45, color: FitColors.blue),
                    _MacroBar(label: 'Protein', grams: '${state.totalProtein.toStringAsFixed(0)}g', pct: 26, color: FitColors.neonGreen),
                    _MacroBar(label: 'Fat', grams: '${state.totalFat.toStringAsFixed(0)}g', pct: 30, color: FitColors.orange),
                  ]);
                }),
              ]),
            ),
            SizedBox(height: 20.h),

            Text('Meals',
              style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h),

            Builder(builder: (context) {
              final state = ref.watch(nutritionProvider);
              if (state.entries.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(20.r),
                  child: Column(children: [
                    Icon(Icons.restaurant_menu_rounded, color: FitColors.textMuted, size: 48.sp),
                    SizedBox(height: 12.h),
                    Text('No meals logged today',
                      style: TextStyle(color: FitColors.textSecondary, fontSize: 14.sp)),
                    SizedBox(height: 8.h),
                    Text('Tap + to add food',
                      style: TextStyle(color: FitColors.neonGreen, fontSize: 12.sp)),
                  ]),
                );
              }
              return Column(children: state.entries.map((entry) {
                final icon = entry.mealType == 'Breakfast' ? Icons.wb_sunny_rounded
                    : entry.mealType == 'Lunch' ? Icons.lunch_dining_rounded
                    : entry.mealType == 'Dinner' ? Icons.restaurant_rounded
                    : Icons.cookie_rounded;
                final color = entry.mealType == 'Breakfast' ? FitColors.amber
                    : entry.mealType == 'Lunch' ? FitColors.neonGreen
                    : entry.mealType == 'Dinner' ? FitColors.blue
                    : FitColors.purple;
                return GlassContainer(
                  opacity: isDark ? 0.06 : 0.2,
                  radius: 16,
                  padding: EdgeInsets.all(14.r),
                  margin: EdgeInsets.only(bottom: 10.h),
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
                      Text(entry.name,
                        style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      Text('${entry.mealType} - ${entry.grams.toStringAsFixed(0)}g',
                      style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
])),
                  Container(
                    padding: EdgeInsets.all(8.r),
                    child: Text('${entry.calories.toStringAsFixed(0)} kcal',
                      style: TextStyle(color: FitColors.orange, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  ),
                ]),
              );
            }).toList());
            }),
            SizedBox(height: 80.h),
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
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? 'Athlete';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userEmail = authState.user?.email ?? '';

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Profile',
                style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.push<void>(context,
                  MaterialPageRoute<void>(builder: (_) => ProfileScreen())),
                child: Icon(Icons.settings_rounded, color: FitColors.textSecondary, size: 22.sp),
              ),
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
              Text(userName,
                style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text(userEmail,
                style: TextStyle(color: FitColors.neonGreen, fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ])),
            SizedBox(height: 20.h),

            // Stats
            GlassContainer(
              opacity: isDark ? 0.06 : 0.2,
              radius: 20,
              padding: EdgeInsets.all(16.r),
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
                return GlassContainer(
                  opacity: isDark ? 0.06 : 0.2,
                  radius: 20,
                  padding: EdgeInsets.all(16.r),
                  margin: EdgeInsets.only(bottom: 20.h),
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
              return GlassContainer(
                opacity: isDark ? 0.06 : 0.2,
                radius: 14,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.only(bottom: 8.h),
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
            
            // Sign In / Sign Out button
            SizedBox(height: 20.h),
            if (!authState.isLoggedIn)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Sign In / Sign Up', style: TextStyle(color: FitColors.background, fontWeight: FontWeight.w700)),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: FitColors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Sign Out', style: TextStyle(color: FitColors.red, fontWeight: FontWeight.w700)),
                ),
              ),
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
