import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_details_screen.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class WorkoutPlansScreen extends ConsumerWidget {
  const WorkoutPlansScreen({super.key});

  static const _filters = [
    _FilterChip('All', Icons.explore_rounded),
    _FilterChip('Beginner', Icons.grass_rounded),
    _FilterChip('Intermediate', Icons.trending_up_rounded),
    _FilterChip('Advanced', Icons.emoji_events_rounded),
    _FilterChip('Strength', Icons.fitness_center_rounded),
    _FilterChip('HIIT', Icons.bolt_rounded),
    _FilterChip('Cardio', Icons.directions_run_rounded),
    _FilterChip('Flexibility', Icons.self_improvement_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(filteredWorkoutPlansProvider);
    final filter = ref.watch(workoutFilterProvider);
    final allPlans = ref.watch(workoutPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Workouts', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 24.sp, fontWeight: FontWeight.w800)),
                    Text('${plans.length} plans • ${allPlans.fold(0, (sum, p) => sum + p.exercises.length)} exercises', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: FitColors.neonGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_rounded, color: FitColors.neonGreen, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(filter, style: TextStyle(color: FitColors.neonGreen, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter chips
          SizedBox(
            height: 42.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = f.label == filter;
                return GestureDetector(
                  onTap: () => ref.read(workoutFilterProvider.notifier).setFilter(f.label),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: selected ? FitColors.neonGreen.withValues(alpha: 0.12) : (isDark ? FitColors.cardDark : FitColors.cardLight),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: selected ? FitColors.neonGreen : (isDark ? FitColors.borderDark : FitColors.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(f.icon, size: 14.sp, color: selected ? FitColors.neonGreen : (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight)),
                        SizedBox(width: 5.w),
                        Text(f.label, style: TextStyle(
                          color: selected ? FitColors.neonGreen : (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                          fontSize: 12.sp,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),

          // Plans list
          Expanded(
            child: plans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center_rounded, size: 64.sp, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.4)),
                        SizedBox(height: 12.h),
                        Text('No plans match this filter', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 14.sp)),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () => ref.read(workoutFilterProvider.notifier).setFilter('All'),
                          child: const Text('Show all plans', style: TextStyle(color: FitColors.neonGreen)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 80.h),
                    itemCount: plans.length,
                    itemBuilder: (_, i) {
                      final plan = plans[i];
                      return _WorkoutPlanCard(plan: plan)
                        .animate(delay: (i * 50).ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.08, end: 0);
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}

class _FilterChip {
  final String label;
  final IconData icon;
  const _FilterChip(this.label, this.icon);
}

class _WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan plan;

  const _WorkoutPlanCard({required this.plan});

  Color get _levelColor => switch (plan.level) {
    'Beginner'     => FitColors.neonGreen,
    'Intermediate' => FitColors.orange,
    'Advanced'     => FitColors.pink,
    _              => FitColors.cyan,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push<void>(context,
        MaterialPageRoute<void>(builder: (_) => WorkoutDetailsScreen(workout: plan))),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? FitColors.cardDark : FitColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: _levelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(plan.emoji, style: TextStyle(fontSize: 24.sp)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 11.sp, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                      SizedBox(width: 3.w),
                      Text('${plan.durationMins} min', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                      SizedBox(width: 10.w),
                      Icon(Icons.local_fire_department_rounded, size: 11.sp, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                      SizedBox(width: 3.w),
                      Text('~${plan.calories} kcal', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                      SizedBox(width: 10.w),
                      Icon(Icons.fitness_center, size: 11.sp, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                      SizedBox(width: 3.w),
                      Text('${plan.exercises.length} ex', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      _Badge(text: plan.level, color: _levelColor),
                      SizedBox(width: 5.w),
                      _Badge(text: plan.category, color: FitColors.blue),
                      SizedBox(width: 5.w),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 10.sp, color: FitColors.amber),
                          SizedBox(width: 2.w),
                          Text('${plan.rating}', style: TextStyle(color: FitColors.amber, fontSize: 9.sp, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  if (plan.equipment.isNotEmpty && plan.equipmentLevel != 'none') ...[
                    SizedBox(height: 6.h),
                    EquipmentList(equipment: plan.equipment),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(5.r),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 9.sp, fontWeight: FontWeight.w700)),
  );
}
