import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/nutrition/presentation/providers/nutrition_provider.dart';

class NutritionTab extends ConsumerWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nutritionState = ref.watch(nutritionProvider);
    final totalCals = nutritionState.totalCalories;
    final budget = nutritionState.calorieGoal;
    final remaining = nutritionState.remaining;

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Nutrition', style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              Icon(Icons.tune_rounded, color: FitColors.textSecondary, size: 22.sp),
            ]),
            SizedBox(height: 20.h),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chevron_left_rounded, color: FitColors.textSecondary, size: 22.sp),
              SizedBox(width: 8.w),
              Text(DateFormat('MMM dd, yyyy').format(DateTime.now()), style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right_rounded, color: FitColors.textSecondary, size: 22.sp),
            ]),
            SizedBox(height: 20.h),
            GlassContainer(
              opacity: isDark ? 0.06 : 0.2,
              radius: 20,
              padding: EdgeInsets.all(20.r),
              child: Column(children: [
                Text('Calorie Budget', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp)),
                SizedBox(height: 4.h),
                Text('$budget kcal', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 16.h),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 100.w, height: 100.w,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        width: 100.w, height: 100.w,
                        child: CircularProgressIndicator(
                          value: totalCals / budget,
                          strokeWidth: 10,
                          backgroundColor: FitColors.border,
                          valueColor: const AlwaysStoppedAnimation(FitColors.neonGreen),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('$remaining', style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w800)),
                        Text('Left', style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
                      ]),
                    ]),
                  ),
                ]),
                SizedBox(height: 20.h),
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
            Text('Meals', style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 12.h),
            Builder(builder: (context) {
              final state = ref.watch(nutritionProvider);
              if (state.entries.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(20.r),
                  child: Column(children: [
                    Icon(Icons.restaurant_menu_rounded, color: FitColors.textMuted, size: 48.sp),
                    SizedBox(height: 12.h),
                    Text('No meals logged today', style: TextStyle(color: FitColors.textSecondary, fontSize: 14.sp)),
                    SizedBox(height: 8.h),
                    Text('Tap + to add food', style: TextStyle(color: FitColors.neonGreen, fontSize: 12.sp)),
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
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
                      child: Icon(icon, color: color, size: 20.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(entry.name, style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      Text('${entry.mealType} - ${entry.grams.toStringAsFixed(0)}g', style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
                    ])),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      child: Text('${entry.calories.toStringAsFixed(0)} kcal', style: TextStyle(color: FitColors.orange, fontSize: 13.sp, fontWeight: FontWeight.w700)),
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
      width: 6.w, height: 50.h,
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
