// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/dashboard/widgets/progress_ring.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';

final caloriesConsumedProvider = Provider<double>((ref) => 1200);
final caloriesGoalProvider = Provider<double>((ref) => 2000);
final stepCountProvider = Provider<int>((ref) => 5000);

class ModernDashboard extends ConsumerWidget {
  const ModernDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waterState = ref.watch(waterProvider);
    final caloriesConsumed = ref.watch(caloriesConsumedProvider);
    final caloriesGoal = ref.watch(caloriesGoalProvider);
    final steps = ref.watch(stepCountProvider);
    final waterIntake = waterState.totalIntake.toDouble();
    final waterGoal = waterState.goal.toDouble();

    final calorieProgress = (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0);
    final waterProgress = (waterIntake / waterGoal).clamp(0.0, 1.0);
    final stepsProgress = (steps / 10000).clamp(0.0, 1.0);

    return Container(
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
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()} 👋',
                      style: TextStyle(
                        color: isDark ? FitColors.textPrimary : FitColors.textPrimaryLight,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    SizedBox(height: 4.h),
                    Text(
                      'Ready for your workout today?',
                      style: TextStyle(
                        color: isDark ? FitColors.textSecondary : FitColors.textSecondaryLight,
                        fontSize: 14.sp,
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                    SizedBox(height: 24.h),

                    GlassContainer(
                      opacity: isDark ? 0.06 : 0.2,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      radius: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AnimatedProgressRing(
                            progress: calorieProgress,
                            size: 90.w,
                            strokeWidth: 8,
                            gradientColors: FitColors.caloriesGradient,
                            backgroundColor: FitColors.calories.withValues(alpha: 0.15),
                            label: '${(calorieProgress * 100).toInt()}%',
                            value: '${caloriesConsumed.toInt()}',
                            valueStyle: TextStyle(
                              color: isDark ? FitColors.textPrimary : FitColors.textPrimaryLight,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(
                              color: FitColors.calories,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

                          AnimatedProgressRing(
                            progress: waterProgress,
                            size: 90.w,
                            strokeWidth: 8,
                            gradientColors: FitColors.waterGradient,
                            backgroundColor: FitColors.water.withValues(alpha: 0.15),
                            label: '${(waterProgress * 100).toInt()}%',
                            value: '${waterIntake.toInt()} ml',
                            valueStyle: TextStyle(
                              color: isDark ? FitColors.textPrimary : FitColors.textPrimaryLight,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(
                              color: FitColors.water,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),

                          AnimatedProgressRing(
                            progress: stepsProgress,
                            size: 90.w,
                            strokeWidth: 8,
                            gradientColors: FitColors.stepsGradient,
                            backgroundColor: FitColors.steps.withValues(alpha: 0.15),
                            label: '${(stepsProgress * 100).toInt()}%',
                            value: '${steps.toInt()}',
                            valueStyle: TextStyle(
                              color: isDark ? FitColors.textPrimary : FitColors.textPrimaryLight,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            labelStyle: TextStyle(
                              color: FitColors.steps,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ).animate().scale(delay: 400.ms, duration: 600.ms, curve: Curves.easeOutBack),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      'Quick Stats',
                      style: TextStyle(
                        color: isDark ? FitColors.textPrimary : FitColors.textPrimaryLight,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            opacity: isDark ? 0.06 : 0.2,
                            radius: 16,
                            padding: const EdgeInsets.all(16),
                            child: _StatContent(
                              title: 'Calories',
                              value: '${caloriesConsumed.toInt()}',
                              subtitle: '/ ${caloriesGoal.toInt()} kcal',
                              icon: Icons.local_fire_department,
                              color: FitColors.calories,
                              delayMs: 400,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GlassCard(
                            opacity: isDark ? 0.06 : 0.2,
                            radius: 16,
                            padding: const EdgeInsets.all(16),
                            child: _StatContent(
                              title: 'Steps',
                              value: '${steps.toInt()}',
                              subtitle: '/ 10,000',
                              icon: Icons.directions_walk,
                              color: FitColors.steps,
                              delayMs: 500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            opacity: isDark ? 0.06 : 0.2,
                            radius: 16,
                            padding: const EdgeInsets.all(16),
                            child: _StatContent(
                              title: 'Water',
                              value: '${waterIntake.toInt()} ml',
                              subtitle: '/ ${waterGoal.toInt()} ml',
                              icon: Icons.water_drop,
                              color: FitColors.water,
                              delayMs: 600,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: GlassCard(
                            opacity: isDark ? 0.06 : 0.2,
                            radius: 16,
                            padding: const EdgeInsets.all(16),
                            child: _StatContent(
                              title: 'Streak',
                              value: '5 days',
                              subtitle: 'Personal best!',
                              icon: Icons.local_fire_department,
                              color: FitColors.streak,
                              delayMs: 700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatContent extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final int delayMs;

  const _StatContent({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            if (subtitle != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle!,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? FitColors.textPrimary : FitColors.textPrimaryLight,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? FitColors.textSecondary : FitColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),
      ],
    ).animate(delay: Duration(milliseconds: delayMs))
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.15);
  }
}
