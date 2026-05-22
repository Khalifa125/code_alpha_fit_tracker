import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/category_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_plans_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_details_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/workout_preferences_sheet.dart';
import 'package:fit_tracker/src/features/heart_rate/presentation/providers/heart_rate_provider.dart';

class FitnessScreen extends ConsumerStatefulWidget {
  const FitnessScreen({super.key});

  @override
  ConsumerState<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends ConsumerState<FitnessScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _onCategoryTap(String category) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(category: category)));
  }

  void _seeAllWorkouts() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutPlansScreen()));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final plans = ref.watch(workoutPlansProvider);
    final summaryAsync = ref.watch(dailySummaryProvider);

    final todayPlan = plans.isNotEmpty ? plans.first : null;

    return RepaintBoundary(
      child: Scaffold(
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  GlassContainer(
                    opacity: isDark ? 0.06 : 0.2,
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    radius: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fitness', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                            SizedBox(height: 2.h),
                            summaryAsync.when(data: (s) => Text('${s.activityCount} activities today', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11, letterSpacing: 0.3)), loading: () => const SizedBox(), error: (_, __) => const SizedBox()),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _seeAllWorkouts,
                              child: GlassContainer(
                                opacity: isDark ? 0.06 : 0.2,
                                radius: 10,
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                                tint: FitColors.neonGreen,
                                child: Row(
                                  children: [
                                    Icon(Icons.explore_rounded, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, size: 14),
                                    SizedBox(width: 4.w),
                                    Text('Plans', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1),
                  SizedBox(height: 16.h),

                  // Today's suggested workout
                  if (todayPlan != null) ...[
                    Text('Today\'s Pick', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    SizedBox(height: 10.h),
                    _TodayWorkoutCard(plan: todayPlan, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: todayPlan)))),
                    SizedBox(height: 16.h),
                  ],

                  // Health metrics card
                  _HealthMetricsCard(
                    steps: summaryAsync.when(data: (s) => s.totalSteps, loading: () => 0, error: (_, __) => 0),
                    calories: summaryAsync.when(data: (s) => s.totalCalories, loading: () => 0.0, error: (_, __) => 0.0),
                    hrBpm: ref.watch(heartRateProvider).latestBpm,
                  ),
                  SizedBox(height: 16.h),

                  // Generate personalized workout
                  GestureDetector(
                    onTap: () => showWorkoutPreferencesSheet(context),
                    child: Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [FitColors.neonGreen.withValues(alpha: 0.1), FitColors.blue.withValues(alpha: 0.05)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: FitColors.neonGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w, height: 40.w,
                            decoration: BoxDecoration(
                              color: FitColors.neonGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: FitColors.neonGreen, size: 20),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Generate Workout', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                                Text('AI-powered based on your goals', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight, size: 20.sp),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),
                  SizedBox(height: 16.h),

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(child: _QuickStatCard(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Calories',
                        value: summaryAsync.when(data: (s) => s.totalCalories.toStringAsFixed(0), loading: () => '--', error: (_, __) => '0'),
                        unit: 'kcal',
                        color: FitColors.orange,
                      )),
                      SizedBox(width: 10.w),
                      Expanded(child: _QuickStatCard(
                        icon: Icons.directions_walk_rounded,
                        label: 'Steps',
                        value: summaryAsync.when(data: (s) => '${s.totalSteps}', loading: () => '--', error: (_, __) => '0'),
                        unit: 'steps',
                        color: FitColors.blue,
                      )),
                      SizedBox(width: 10.w),
                      Expanded(child: _QuickStatCard(
                        icon: Icons.timer_outlined,
                        label: 'Minutes',
                        value: summaryAsync.when(data: (s) => '${s.totalMinutes}', loading: () => '--', error: (_, __) => '0'),
                        unit: 'active',
                        color: FitColors.neonGreen,
                      )),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                  SizedBox(height: 16.h),

                  // Categories in a more pro layout
                  Text('Categories', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 72.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 10.w),
                      itemBuilder: (_, i) {
                        final cat = _categories[i];
                        return _CategoryPill(
                          icon: cat.icon,
                          name: cat.name,
                          color: cat.color,
                          onTap: () => _onCategoryTap(cat.route),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Popular plans section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Popular Plans', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                      GestureDetector(
                        onTap: _seeAllWorkouts,
                        child: const Text('See all', style: TextStyle(color: FitColors.neonGreen, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 190.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: plans.take(5).length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (_, i) {
                        final plan = plans[i];
                        return _FeaturedPlanCard(plan: plan, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailsScreen(workout: plan))));
                      },
                    ),
                  ),

                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _categories = [
    _CatData(Icons.fitness_center_rounded, 'Strength', FitColors.neonGreen, 'Strength'),
    _CatData(Icons.directions_run_rounded, 'Cardio', FitColors.orange, 'Cardio'),
    _CatData(Icons.bolt_rounded, 'HIIT', FitColors.amber, 'HIIT'),
    _CatData(Icons.self_improvement_rounded, 'Yoga', FitColors.purple, 'Flexibility'),
    _CatData(Icons.accessibility_new_rounded, 'Core', FitColors.pink, 'Strength'),
    _CatData(Icons.flight_takeoff_rounded, 'Full Body', FitColors.cyan, 'Strength'),
  ];
}

class _CatData {
  final IconData icon;
  final String name;
  final Color color;
  final String route;
  const _CatData(this.icon, this.name, this.color, this.route);
}

class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final VoidCallback onTap;

  const _CategoryPill({required this.icon, required this.name, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 15.sp),
            ),
            SizedBox(width: 8.w),
            Text(name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 12.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _QuickStatCard({required this.icon, required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? FitColors.cardDark : FitColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 16.sp, fontWeight: FontWeight.w800)),
          Text(unit, style: TextStyle(color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7), fontSize: 8.sp)),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onTap;

  const _TodayWorkoutCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              if (isDark) FitColors.cardDark else FitColors.cardLight,
              FitColors.neonGreen.withValues(alpha: isDark ? 0.04 : 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: FitColors.neonGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: FitColors.neonGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text('Suggested', style: TextStyle(color: FitColors.neonGreen, fontSize: 8.sp, fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: FitColors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text('~${plan.calories} kcal', style: TextStyle(color: FitColors.orange, fontSize: 8.sp, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(plan.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4.h),
                  Text('${plan.durationMins} min  •  ${plan.level}  •  ${plan.exercises.length} exercises', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12.sp, color: FitColors.amber),
                      SizedBox(width: 3.w),
                      Text(plan.rating.toString(), style: TextStyle(color: FitColors.amber, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                      SizedBox(width: 10.w),
                      Icon(Icons.people_rounded, size: 12.sp, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                      SizedBox(width: 3.w),
                      Text(_formatNumber(plan.completions), style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(plan.emoji, style: TextStyle(fontSize: 48.sp)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.08, end: 0);
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _FeaturedPlanCard extends StatelessWidget {
  final WorkoutPlan plan;
  final VoidCallback onTap;

  const _FeaturedPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levelColor = switch (plan.level) {
      'Beginner' => FitColors.neonGreen,
      'Intermediate' => FitColors.orange,
      'Advanced' => FitColors.pink,
      _ => FitColors.cyan,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? FitColors.cardDark : FitColors.cardLight,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(child: Text(plan.emoji, style: TextStyle(fontSize: 20.sp))),
                ),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 12.sp, color: FitColors.amber),
                    SizedBox(width: 2.w),
                    Text('${plan.rating}', style: TextStyle(color: FitColors.amber, fontSize: 9.sp, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(plan.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 12.sp, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4.h),
            Text('${plan.durationMins} min', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
            SizedBox(height: 6.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(plan.level, style: TextStyle(color: levelColor, fontSize: 8.sp, fontWeight: FontWeight.w700)),
                ),
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: FitColors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(plan.category, style: TextStyle(color: FitColors.blue, fontSize: 8.sp, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            EquipmentList(equipment: plan.equipment),
          ],
        ),
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100)).slideY(begin: 0.08, end: 0);
  }
}

class _HealthMetricsCard extends StatelessWidget {
  final int steps;
  final double calories;
  final int? hrBpm;

  const _HealthMetricsCard({required this.steps, required this.calories, this.hrBpm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(16.r),
      radius: 16,
      tint: FitColors.teal,
      child: Row(
        children: [
          Expanded(child: _MetricTile(icon: Icons.favorite, label: 'Heart', value: hrBpm != null ? '$hrBpm' : '--', unit: 'BPM', color: FitColors.red)),
          Container(width: 1, height: 40.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
          Expanded(child: _MetricTile(icon: Icons.directions_walk_rounded, label: 'Steps', value: _formatNum(steps), unit: 'steps', color: FitColors.blue)),
          Container(width: 1, height: 40.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
          Expanded(child: _MetricTile(icon: Icons.local_fire_department_rounded, label: 'Calories', value: calories.toStringAsFixed(0), unit: 'kcal', color: FitColors.orange)),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }

  String _formatNum(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _MetricTile({required this.icon, required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.w800)),
        Text(unit, style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 8.sp)),
      ],
    );
  }
}
