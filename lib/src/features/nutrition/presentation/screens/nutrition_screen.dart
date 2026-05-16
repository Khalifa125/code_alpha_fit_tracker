// ignore_for_file: deprecated_member_use, inference_failure_on_function_invocation, inference_failure_on_function_return_type

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final int consumedCalories = 1250;
  final int goalCalories = 2000;
  final double protein = 85;
  final double carbs = 150;
  final double fat = 45;

  final List<Map<String, dynamic>> _meals = [
    {'name': 'Breakfast', 'icon': Icons.wb_sunny_outlined, 'calories': 350},
    {'name': 'Lunch', 'icon': Icons.wb_twilight, 'calories': 450},
    {'name': 'Dinner', 'icon': Icons.nightlight_outlined, 'calories': 350},
    {'name': 'Snacks', 'icon': Icons.cookie_outlined, 'calories': 100},
  ];

  void _onAddFood(String mealName) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add food to $mealName'), backgroundColor: FitColors.cardDark),
    );
  }

  void _onScanBarcode() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => _BarcodeScannerSheet(onScan: (barcode) {
        HapticFeedback.heavyImpact();
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scanned: $barcode'), backgroundColor: FitColors.neonGreen),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: Scaffold(
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
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Nutrition', style: TextStyle(
                        color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                        fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.5,
                      )),
                      GlassContainer(
                        opacity: isDark ? 0.06 : 0.2,
                        radius: 8,
                        padding: EdgeInsets.all(8.w),
                        child: const Icon(Icons.add, color: FitColors.neonGreen, size: 18),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1),
                  SizedBox(height: 16.h),
                  SizedBox(height: 24.h),

                  GlassContainer(
                    opacity: isDark ? 0.06 : 0.2,
                    padding: EdgeInsets.all(20.r),
                    radius: 16,
                    margin: EdgeInsets.only(bottom: 24.h),
                    child: _CalorieRingChart(consumed: consumedCalories, goal: goalCalories),
                  ),

                  _MacrosRow(protein: protein, carbs: carbs, fat: fat),
                  SizedBox(height: 24.h),

                  ..._meals.asMap().entries.map((e) => _MealSectionCard(
                    name: e.value['name'] as String,
                    icon: e.value['icon'] as IconData,
                    calories: e.value['calories'] as int,
                    index: e.key,
                    onAddFood: () => _onAddFood(e.value['name'] as String),
                    onScan: _onScanBarcode,
                  )),
                  SizedBox(height: 16.h),
                  _WaterMiniWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalorieRingChart extends StatelessWidget {
  final int consumed;
  final int goal;

  const _CalorieRingChart({required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          SizedBox(
            height: 180.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 60,
                    sections: [
                      PieChartSectionData(value: consumed.toDouble(), color: FitColors.neonGreen, radius: 22),
                      PieChartSectionData(value: (goal - consumed).toDouble().clamp(1, goal.toDouble()), color: FitColors.surfaceDark, radius: 22),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$consumed', style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                      fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5,
                    )),
                    Text('of $goal kcal', style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
                      fontSize: 12,
                    )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CalorieStat(label: 'Eaten', value: '$consumed', color: FitColors.neonGreen),
              _CalorieStat(label: 'Left', value: '${goal - consumed}', color: FitColors.orange),
              _CalorieStat(label: 'Goal', value: '$goal', color: FitColors.blue),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}

class _CalorieStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _CalorieStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(
          color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
          fontSize: 11,
        )),
      ],
    );
  }
}

class _MacrosRow extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;

  const _MacrosRow({required this.protein, required this.carbs, required this.fat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroCard(name: 'Protein', value: '${protein.toInt()}g', color: FitColors.blue, progress: protein / 150)),
        SizedBox(width: 12.w),
        Expanded(child: _MacroCard(name: 'Carbs', value: '${carbs.toInt()}g', color: FitColors.amber, progress: carbs / 250)),
        SizedBox(width: 12.w),
        Expanded(child: _MacroCard(name: 'Fat', value: '${fat.toInt()}g', color: FitColors.pink, progress: fat / 65)),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String name;
  final String value;
  final Color color;
  final double progress;

  const _MacroCard({required this.name, required this.value, required this.color, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(12.r),
      radius: 12,
      child: Column(
        children: [
          Text(name, style: TextStyle(
            color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
            fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3,
          )),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(
            color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            fontSize: 16, fontWeight: FontWeight.w700,
          )),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark ? FitColors.surfaceDark : FitColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSectionCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final int calories;
  final int index;
  final VoidCallback onAddFood;
  final VoidCallback onScan;

  const _MealSectionCard({
    required this.name,
    required this.icon,
    required this.calories,
    required this.index,
    required this.onAddFood,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(14.r),
      radius: 12,
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: FitColors.neonGreen, size: 18),
              SizedBox(width: 8.w),
              Text(name, style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 13, fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: FitColors.calories.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('$calories kcal', style: const TextStyle(
                  color: FitColors.calories,
                  fontSize: 11, fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAddFood,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Food'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FitColors.neonGreen,
                    side: BorderSide(color: FitColors.neonGreen.withValues(alpha: 0.5)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              OutlinedButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text('Scan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                  side: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 + index * 50).ms);
  }
}

class _WaterMiniWidget extends StatefulWidget {
  @override
  State<_WaterMiniWidget> createState() => _WaterMiniWidgetState();
}

class _WaterMiniWidgetState extends State<_WaterMiniWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: GlassContainer(
          opacity: isDark ? 0.06 : 0.2,
          padding: EdgeInsets.all(16.r),
          radius: 16,
          tint: FitColors.blue,
          child: Row(
            children: [
              Icon(Icons.water_drop, color: FitColors.blue, size: 32.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Water Intake', style: TextStyle(
                      color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                      fontSize: 16, fontWeight: FontWeight.bold,
                    )),
                    Text('Tap to track water', style: TextStyle(
                      color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                      fontSize: 12,
                    )),
                  ],
                ),
              ),
              const Text('1.2L', style: TextStyle(
                color: FitColors.blue, fontSize: 20, fontWeight: FontWeight.bold,
              )),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _BarcodeScannerSheet extends StatefulWidget {
  final Function(String) onScan;

  const _BarcodeScannerSheet({required this.onScan});

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(24.r),
      radius: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_scanner, color: FitColors.neonGreen, size: 64.sp),
          SizedBox(height: 16.h),
          Text('Barcode Scanner', style: TextStyle(
            color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            fontSize: 20, fontWeight: FontWeight.bold,
          )),
          SizedBox(height: 8.h),
          Text('Scan product barcode to get nutrition info', style: TextStyle(
            color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
          ), textAlign: TextAlign.center),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => widget.onScan('123456789'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FitColors.neonGreen,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open Camera', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
