import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/dashboard/widgets/progress_ring.dart';
import 'package:fit_tracker/src/features/dashboard/widgets/stat_cards.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';
import 'package:fit_tracker/src/features/steps/providers/step_provider.dart';

class ModernDashboard extends ConsumerWidget {
  const ModernDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caloriesConsumed = ref.watch(caloriesConsumedProvider);
    final caloriesGoal = ref.watch(caloriesGoalProvider);
    final steps = ref.watch(stepCountProvider);
    final waterIntake = ref.watch(waterIntakeProvider);
    final waterGoal = ref.watch(waterGoalProvider);

    final calorieProgress = (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0);
    final waterProgress = (waterIntake / waterGoal).clamp(0.0, 1.0);
    final stepsProgress = (steps / 10000).clamp(0.0, 1.0);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Good ${_getGreeting()} 👋',
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  SizedBox(height: 4.h),
                  Text(
                    'Ready for your workout today?',
                    style: TextStyle(
                      color: FitColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  
                  SizedBox(height: 24.h),
                  
                  // Progress Rings Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AnimatedProgressRing(
                        progress: calorieProgress,
                        size: 100.w,
                        strokeWidth: 8,
                        gradientColors: FitColors.caloriesGradient,
                        backgroundColor: FitColors.calories.withOpacity(0.15),
                        label: '${(calorieProgress * 100).toInt()}%',
                        value: '${caloriesConsumed.toInt()}/${caloriesGoal.toInt()}',
                        valueStyle: TextStyle(
                          color: FitColors.textPrimary,
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
                        size: 100.w,
                        strokeWidth: 8,
                        gradientColors: FitColors.waterGradient,
                        backgroundColor: FitColors.water.withOpacity(0.15),
                        label: '${(waterProgress * 100).toInt()}%',
                        value: '${waterIntake.toInt()}/${waterGoal.toInt()} ml',
                        valueStyle: TextStyle(
                          color: FitColors.textPrimary,
                          fontSize: 14.sp,
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
                        size: 100.w,
                        strokeWidth: 8,
                        gradientColors: FitColors.stepsGradient,
                        backgroundColor: FitColors.steps.withOpacity(0.15),
                        label: '${(stepsProgress * 100).toInt()}%',
                        value: '${steps.toInt()}',
                        valueStyle: TextStyle(
                          color: FitColors.textPrimary,
                          fontSize: 14.sp,
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
                  
                  SizedBox(height: 24.h),
                  
                  // Quick Stats
                  Text(
                    'Quick Stats',
                    style: TextStyle(
                      color: FitColors.textPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  SizedBox(height: 12.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedStatCard(
                          title: 'Calories',
                          value: '${caloriesConsumed.toInt()}',
                          subtitle: '/ ${caloriesGoal.toInt()} kcal',
                          icon: Icons.local_fire_department,
                          color: FitColors.calories,
                          gradientColors: FitColors.caloriesGradient,
                          delayMs: 400,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AnimatedStatCard(
                          title: 'Steps',
                          value: '${steps.toInt()}',
                          subtitle: '/ 10,000',
                          icon: Icons.directions_walk,
                          color: FitColors.steps,
                          gradientColors: FitColors.stepsGradient,
                          delayMs: 500,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedStatCard(
                          title: 'Water',
                          value: '${waterIntake.toInt()} ml',
                          subtitle: '/ ${waterGoal.toInt()} ml',
                          icon: Icons.water_drop,
                          color: FitColors.water,
                          gradientColors: FitColors.waterGradient,
                          delayMs: 600,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AnimatedStatCard(
                          title: 'Streak',
                          value: '5 days',
                          subtitle: 'Personal best!',
                          icon: Icons.local_fire_department,
                          color: FitColors.streak,
                          gradientColors: FitColors.streakGradient,
                          delayMs: 700,
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
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
