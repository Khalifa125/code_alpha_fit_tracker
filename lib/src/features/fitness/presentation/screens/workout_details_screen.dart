import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/workout_player_screen.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final WorkoutPlan workout;

  const WorkoutDetailsScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Workout', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
            centerTitle: true,
            expandedHeight: 220.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      FitColors.neonGreen.withValues(alpha: 0.3),
                      if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(workout.emoji, style: TextStyle(fontSize: 80.sp)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + meta
                  Text(workout.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 28.sp, fontWeight: FontWeight.w800))
                    .animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(workout.category, style: TextStyle(color: FitColors.neonGreen, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      SizedBox(width: 10.w),
                      Text('${workout.exercises.length} exercises', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 12.sp)),
                    ],
                  ).animate().fadeIn(delay: 100.ms),
                  SizedBox(height: 16.h),

                  // Rating & completions
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14.sp, color: FitColors.amber),
                      SizedBox(width: 3.w),
                      Text(workout.rating.toString(), style: TextStyle(color: FitColors.amber, fontSize: 12.sp, fontWeight: FontWeight.w700)),
                      SizedBox(width: 4.w),
                      Text('/ 5.0', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                      SizedBox(width: 16.w),
                      Icon(Icons.people_rounded, size: 14.sp, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                      SizedBox(width: 3.w),
                      Text('${_formatNumber(workout.completions)} completions', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                    ],
                  ).animate().fadeIn(delay: 150.ms),
                  SizedBox(height: 20.h),

                  // Info stats
                  Row(
                    children: [
                      _InfoCard(icon: Icons.timer_outlined, label: 'Duration', value: '${workout.durationMins} min'),
                      SizedBox(width: 10.w),
                      _InfoCard(icon: Icons.local_fire_department_rounded, label: 'Calories', value: '~${workout.calories}'),
                      SizedBox(width: 10.w),
                      _InfoCard(icon: Icons.repeat_rounded, label: 'Sets', value: '${workout.totalSets}'),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  SizedBox(height: 20.h),

                  // Difficulty + Equipment
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: isDark ? FitColors.cardDark : FitColors.cardLight,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Difficulty', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                              SizedBox(height: 6.h),
                              DifficultyIndicator(level: workout.level),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: isDark ? FitColors.cardDark : FitColors.cardLight,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Intensity', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                              SizedBox(height: 6.h),
                              Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.w,
                                    decoration: BoxDecoration(
                                      color: workout.intensity == 'Low' ? FitColors.neonGreen : workout.intensity == 'Moderate' ? FitColors.orange : FitColors.pink,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(workout.intensity, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 250.ms),
                  SizedBox(height: 10.h),

                  // Equipment
                  if (workout.equipment.isNotEmpty && workout.equipment.any((e) => e.isNotEmpty)) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isDark ? FitColors.cardDark : FitColors.cardLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Equipment', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                          SizedBox(height: 8.h),
                          EquipmentList(equipment: workout.equipment),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    SizedBox(height: 16.h),
                  ],

                  // Target Muscles
                  if (workout.targetMuscles.isNotEmpty) ...[
                    Text('Target Muscles', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isDark ? FitColors.cardDark : FitColors.cardLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MuscleGroupIndicator(muscles: workout.targetMuscles, maxDisplay: 6),
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            children: workout.targetMuscles.map((m) => Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: FitColors.neonGreen.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: Text(m, style: TextStyle(color: FitColors.neonGreen, fontSize: 9.sp, fontWeight: FontWeight.w600)),
                            )).toList(),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 350.ms),
                    SizedBox(height: 16.h),
                  ],

                  // Description
                  Text('About this workout', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8.h),
                  Text(workout.description, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp, height: 1.6))
                    .animate().fadeIn(delay: 300.ms),
                  SizedBox(height: 16.h),

                  // Benefits
                  if (workout.benefits.isNotEmpty) ...[
                    Text('Benefits', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                    SizedBox(height: 8.h),
                    ...workout.benefits.map((b) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 4.h, right: 8.w),
                            width: 14.w,
                            height: 14.w,
                            decoration: BoxDecoration(
                              color: FitColors.neonGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Icon(Icons.check_rounded, color: FitColors.neonGreen, size: 10.sp),
                          ),
                          Expanded(
                            child: Text(b, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 12.sp)),
                          ),
                        ],
                      ),
                    )),
                    SizedBox(height: 16.h),
                  ],

                  // Weekly frequency
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: FitColors.blue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: FitColors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, color: FitColors.blue, size: 20.sp),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text('Recommended ${workout.weeklyFrequency}× per week for best results', style: TextStyle(color: FitColors.blue, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  SizedBox(height: 20.h),

                  // Exercises
                  Text('Exercises (${workout.exercises.length})', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12.h),
                  ...workout.exercises.asMap().entries.map((e) {
                    final index = e.key;
                    final ex = e.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: isDark ? FitColors.cardDark : FitColors.cardLight,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: FitColors.neonGreen.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Center(child: Text('${index + 1}', style: TextStyle(color: FitColors.neonGreen, fontWeight: FontWeight.w800, fontSize: 13.sp))),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ex.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                    Row(
                                      children: [
                                        Text(ex.muscle, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                                        if (ex.equipment.isNotEmpty) ...[
                                          SizedBox(width: 8.w),
                                          Icon(Icons.fitness_center, size: 9.sp, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                                          SizedBox(width: 2.w),
                                          Text(ex.equipment, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 9.sp)),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${ex.sets} × ${ex.reps}', style: TextStyle(color: FitColors.neonGreen, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                                  Text('Rest: ${ex.rest}', style: TextStyle(color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 9.sp)),
                                ],
                              ),
                            ],
                          ),
                          if (ex.tips.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: FitColors.amber.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: FitColors.amber.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.lightbulb_outline_rounded, size: 12.sp, color: FitColors.amber),
                                  SizedBox(width: 6.w),
                                  Expanded(
                                    child: Text(ex.tips, style: TextStyle(color: FitColors.amber, fontSize: 10.sp, height: 1.4)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate(delay: (500 + index * 50).ms).fadeIn().slideX(begin: 0.05, end: 0);
                  }),
                  SizedBox(height: 24.h),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WorkoutPlayerScreen(plan: workout)),
                      ),
                      icon: Icon(Icons.play_arrow_rounded, size: 20.sp),
                      label: Text('Start Workout', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FitColors.neonGreen,
                        foregroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isDark ? FitColors.cardDark : FitColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: FitColors.neonGreen, size: 20.sp),
            SizedBox(height: 8.h),
            Text(value, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontWeight: FontWeight.w700, fontSize: 14.sp)),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }
}
