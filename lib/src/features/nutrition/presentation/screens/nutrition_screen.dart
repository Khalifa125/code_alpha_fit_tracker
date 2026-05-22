import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/water/presentation/screens/water_tracking_screen.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';
import 'package:fit_tracker/src/features/nutrition/presentation/providers/nutrition_provider.dart';
import 'package:fit_tracker/src/core/services/nutrition_api_service.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateTime _selectedDate = DateTime.now();

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String get _dateLabel {
    final now = DateTime.now();
    if (_isSameDay(_selectedDate, now)) return 'Today';
    if (_isSameDay(_selectedDate, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('MMM d').format(_selectedDate);
  }

  List<double> get _weeklyCalories {
    final now = DateTime.now();
    final entries = ref.read(nutritionProvider).entries;
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayEntries = entries.where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day);
      return dayEntries.fold<double>(0, (sum, e) => sum + e.calories);
    });
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
  }

  void _onAddFood(String mealName) {
    HapticFeedback.lightImpact();
    _showAddFoodSheet(mealName);
  }

  void _showAddFoodSheet(String mealName) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: GlassContainer(
          opacity: Theme.of(ctx).brightness == Brightness.dark ? 0.06 : 0.2,
          padding: EdgeInsets.all(20.r),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Food - $mealName', style: TextStyle(
                color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18.sp, fontWeight: FontWeight.w700,
              )),
              SizedBox(height: 16.h),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Food name', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
              SizedBox(height: 12.h),
              TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calories', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
              SizedBox(height: 12.h),
              Row(children: [
                Expanded(child: TextField(controller: proteinCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein (g)', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight))),
                SizedBox(width: 12.w),
                Expanded(child: TextField(controller: carbsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs (g)', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight))),
                SizedBox(width: 12.w),
                Expanded(child: TextField(controller: fatCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fat (g)', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight))),
              ]),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final cal = double.tryParse(calCtrl.text) ?? 0;
                    final p = double.tryParse(proteinCtrl.text) ?? 0;
                    final c = double.tryParse(carbsCtrl.text) ?? 0;
                    final f = double.tryParse(fatCtrl.text) ?? 0;
                    ref.read(nutritionProvider.notifier).addEntry(NutritionEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.isEmpty ? 'Unknown' : nameCtrl.text,
                      calories: cal,
                      protein: p,
                      carbs: c,
                      fat: f,
                      grams: 0,
                      mealType: mealName,
                      date: _selectedDate,
                    ));
                    HapticFeedback.heavyImpact();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Add Food', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  void _onScanBarcode() {
    HapticFeedback.mediumImpact();
    final barcodeCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: GlassContainer(
          opacity: Theme.of(ctx).brightness == Brightness.dark ? 0.06 : 0.2,
          padding: EdgeInsets.all(20.r),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, color: FitColors.neonGreen, size: 64.sp),
              SizedBox(height: 16.h),
              Text('Enter Barcode', style: TextStyle(
                color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18.sp, fontWeight: FontWeight.w700,
              )),
              SizedBox(height: 8.h),
              Text('Type or paste the barcode number', style: TextStyle(
                color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
              )),
              SizedBox(height: 16.h),
              TextField(
                controller: barcodeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 5901234123457',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code),
                  fillColor: (Theme.of(ctx).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight).withValues(alpha: 0.5),
                  filled: true,
                ),
                style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final barcode = barcodeCtrl.text.trim();
                    if (barcode.isEmpty) return;
                    HapticFeedback.heavyImpact();

                    final food = await openFoodFactsApi.getByBarcode(barcode);
                    if (food != null) {
                      final grams = food.servingSize ?? 100;
                      final scale = grams / 100.0;
                      ref.read(nutritionProvider.notifier).addEntry(NutritionEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: food.name,
                        calories: food.calories * scale,
                        protein: food.protein * scale,
                        carbs: food.carbs * scale,
                        fat: food.fat * scale,
                        grams: grams,
                        mealType: 'Snacks',
                        date: _selectedDate,
                      ));
                    } else {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Product not found. Try adding manually.')),
                        );
                      }
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Look Up', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMacroGoalSheet() {
    final state = ref.read(nutritionProvider);
    final pCtrl = TextEditingController(text: state.proteinGoal.toString());
    final cCtrl = TextEditingController(text: state.carbsGoal.toString());
    final fCtrl = TextEditingController(text: state.fatGoal.toString());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: GlassContainer(
          opacity: Theme.of(ctx).brightness == Brightness.dark ? 0.06 : 0.2,
          padding: EdgeInsets.all(20.r),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Macro Goals', style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 16.h),
              TextField(controller: pCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein (g)', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
              SizedBox(height: 12.h),
              TextField(controller: cCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs (g)', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
              SizedBox(height: 12.h),
              TextField(controller: fCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fat (g)', border: OutlineInputBorder()), style: TextStyle(color: Theme.of(ctx).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final notifier = ref.read(nutritionProvider.notifier);
                    notifier.setProteinGoal(int.tryParse(pCtrl.text) ?? state.proteinGoal);
                    notifier.setCarbsGoal(int.tryParse(cCtrl.text) ?? state.carbsGoal);
                    notifier.setFatGoal(int.tryParse(fCtrl.text) ?? state.fatGoal);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Goals', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nutritionState = ref.watch(nutritionProvider);
    final dateEntries = nutritionState.entriesForDate(_selectedDate);
    final consumedCalories = dateEntries.fold<double>(0, (sum, e) => sum + e.calories).toInt();
    final goalCalories = nutritionState.calorieGoal.toInt();
    final protein = dateEntries.fold<double>(0, (sum, e) => sum + e.protein);
    final carbs = dateEntries.fold<double>(0, (sum, e) => sum + e.carbs);
    final fat = dateEntries.fold<double>(0, (sum, e) => sum + e.fat);
    final proteinGoal = nutritionState.proteinGoal;
    final carbsGoal = nutritionState.carbsGoal;
    final fatGoal = nutritionState.fatGoal;

    final meals = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
    final mealIcons = {
      'Breakfast': Icons.wb_sunny_outlined,
      'Lunch': Icons.wb_twilight,
      'Dinner': Icons.nightlight_outlined,
      'Snacks': Icons.cookie_outlined,
    };

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
                      Row(children: [
                        GestureDetector(onTap: () => _changeDate(-1), child: Container(padding: EdgeInsets.all(6.r), decoration: BoxDecoration(color: isDark ? FitColors.cardDark : FitColors.cardLight, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight)), child: Icon(Icons.chevron_left, size: 16, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight))),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () => _changeDate(0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(color: _isSameDay(_selectedDate, DateTime.now()) ? FitColors.neonGreen.withValues(alpha: 0.12) : (isDark ? FitColors.cardDark : FitColors.cardLight), borderRadius: BorderRadius.circular(8.r), border: Border.all(color: _isSameDay(_selectedDate, DateTime.now()) ? FitColors.neonGreen.withValues(alpha: 0.4) : (isDark ? FitColors.borderDark : FitColors.borderLight))),
                            child: Text(_dateLabel, style: TextStyle(color: _isSameDay(_selectedDate, DateTime.now()) ? FitColors.neonGreen : (isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight), fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(onTap: () => _changeDate(1), child: Container(padding: EdgeInsets.all(6.r), decoration: BoxDecoration(color: isDark ? FitColors.cardDark : FitColors.cardLight, borderRadius: BorderRadius.circular(8.r), border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight)), child: Icon(Icons.chevron_right, size: 16, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight))),
                      ]),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1),
                  SizedBox(height: 16.h),

                  // Calorie ring + weekly chart side by side
                  GlassContainer(
                    opacity: isDark ? 0.06 : 0.2,
                    padding: EdgeInsets.all(20.r),
                    radius: 16,
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      children: [
                        _CalorieRingChart(consumed: consumedCalories, goal: goalCalories),
                        Divider(color: (isDark ? FitColors.borderDark : FitColors.borderLight).withValues(alpha: 0.3), height: 24.h),
                        _WeeklyChart(values: _weeklyCalories, isDark: isDark),
                      ],
                    ),
                  ),

                  // Macros row (tappable to edit goals)
                  GestureDetector(
                    onTap: _showMacroGoalSheet,
                    child: _MacrosRow(protein: protein, carbs: carbs, fat: fat, proteinGoal: proteinGoal, carbsGoal: carbsGoal, fatGoal: fatGoal),
                  ),
                  SizedBox(height: 24.h),

                  // Meal sections
                  ...meals.map((meal) => _MealSectionCard(
                    name: meal,
                    icon: mealIcons[meal]!,
                    foodEntries: dateEntries.where((f) => f.mealType == meal).toList(),
                    onAddFood: () => _onAddFood(meal),
                    onScan: _onScanBarcode,
                  )),
                  SizedBox(height: 16.h),

                  // Water widget
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WaterTrackingScreen())),
                    child: const _WaterMiniWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<double> values;
  final bool isDark;

  const _WeeklyChart({required this.values, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This Week', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontWeight: FontWeight.w600, fontSize: 12)),
        SizedBox(height: 12.h),
        SizedBox(
          height: 100.h,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: values.reduce((a, b) => a > b ? a : b) * 1.3,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) => Text(days[v.toInt() % 7],
                    style: TextStyle(color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight, fontSize: 9),
                  ),
                )),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: values.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value, color: FitColors.neonGreen, width: 8.w, borderRadius: BorderRadius.circular(4.r))])).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalorieRingChart extends StatelessWidget {
  final int consumed;
  final int goal;

  const _CalorieRingChart({required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 54,
                  sections: [
                    PieChartSectionData(value: consumed.toDouble(), color: FitColors.neonGreen, radius: 20),
                    PieChartSectionData(value: (goal - consumed).toDouble().clamp(1, goal.toDouble()), color: FitColors.surfaceDark, radius: 20),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$consumed', style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                    fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5,
                  )),
                  Text('of $goal kcal', style: TextStyle(
                    color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
                    fontSize: 11,
                  )),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CalorieStat(label: 'Eaten', value: '$consumed', color: FitColors.neonGreen),
            _CalorieStat(label: 'Left', value: '${goal - consumed}', color: FitColors.orange),
            _CalorieStat(label: 'Goal', value: '$goal', color: FitColors.blue),
          ],
        ),
      ],
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
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(
          color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
          fontSize: 10,
        )),
      ],
    );
  }
}

class _MacrosRow extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;

  const _MacrosRow({required this.protein, required this.carbs, required this.fat, this.proteinGoal = 150, this.carbsGoal = 250, this.fatGoal = 65});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroCard(name: 'Protein', value: '${protein.toInt()}g', color: FitColors.blue, progress: proteinGoal > 0 ? protein / proteinGoal : 0)),
        SizedBox(width: 12.w),
        Expanded(child: _MacroCard(name: 'Carbs', value: '${carbs.toInt()}g', color: FitColors.amber, progress: carbsGoal > 0 ? carbs / carbsGoal : 0)),
        SizedBox(width: 12.w),
        Expanded(child: _MacroCard(name: 'Fat', value: '${fat.toInt()}g', color: FitColors.pink, progress: fatGoal > 0 ? fat / fatGoal : 0)),
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
  final List<NutritionEntry> foodEntries;
  final VoidCallback onAddFood;
  final VoidCallback onScan;

  const _MealSectionCard({
    required this.name,
    required this.icon,
    required this.foodEntries,
    required this.onAddFood,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mealCalories = foodEntries.fold(0, (sum, f) => sum + f.calories.toInt());
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
                child: Text('$mealCalories kcal', style: const TextStyle(
                  color: FitColors.calories,
                  fontSize: 11, fontWeight: FontWeight.w600,
                )),
              ),
            ],
          ),
          if (foodEntries.isNotEmpty) ...[
            SizedBox(height: 8.h),
            ...foodEntries.map((f) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 4, color: FitColors.neonGreen),
                  SizedBox(width: 6.w),
                  Text(f.name, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11)),
                  const Spacer(),
                  Text('${f.calories.toInt()} cal', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10)),
                ],
              ),
            )),
          ],
          SizedBox(height: 10.h),
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
    ).animate().fadeIn();
  }
}

class _WaterMiniWidget extends ConsumerWidget {
  const _WaterMiniWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waterState = ref.watch(waterProvider);
    final waterMl = waterState.totalIntake;
    final waterGoal = waterState.goal;
    return GlassContainer(
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
                Text('${waterGoal > 0 ? (waterMl / waterGoal * 100).toInt() : 0}% of daily goal', style: TextStyle(
                  color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                  fontSize: 12,
                )),
                SizedBox(height: 4.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: waterGoal > 0 ? (waterMl / waterGoal).clamp(0.0, 1.0) : 0.0,
                    backgroundColor: isDark ? FitColors.surfaceDark : FitColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(FitColors.blue),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          Text('${(waterMl / 1000).toStringAsFixed(1)}L', style: const TextStyle(
            color: FitColors.blue, fontSize: 18, fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }
}
