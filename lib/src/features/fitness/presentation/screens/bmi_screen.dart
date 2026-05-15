// ignore_for_file: deprecated_member_use, prefer_const_constructors, unnecessary_import, unused_import, unused_element_parameter

import 'package:fit_tracker/src/imports/core_imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker/src/features/fitness/data/models/fitness_models.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';

class BmiScreen extends ConsumerStatefulWidget {
  const BmiScreen({super.key});

  @override
  ConsumerState<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends ConsumerState<BmiScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'male';
  bool _saving = false;
  final _bmiNotifier = ValueNotifier<double?>(null);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _heightCtrl.addListener(_updateBmi);
    _weightCtrl.addListener(_updateBmi);
  }

  void _updateBmi() {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    double? bmi;
    if (h != null && w != null && h > 0) {
      bmi = w / ((h / 100) * (h / 100));
    }
    _bmiNotifier.value = bmi;
  }

  Future<void> _loadProfile() async {
    final profile = await ref.read(fitnessRepoProvider).getProfile();
    if (profile != null && mounted) {
      _heightCtrl.text = profile.heightCm.toString();
      _weightCtrl.text = profile.weightKg.toString();
      _ageCtrl.text = profile.age.toString();
      setState(() => _gender = profile.gender);
    }
  }

  Future<void> _saveProfile() async {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    final a = int.tryParse(_ageCtrl.text);
    if (h == null || w == null || a == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(fitnessRepoProvider);
    await repo.saveProfile(FitnessProfileModel(heightCm: h, weightKg: w, age: a, gender: _gender));
    await repo.saveWeight(w);
    ref.invalidate(fitnessProfileProvider);
    ref.invalidate(weightEntriesProvider);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved! ✅'), backgroundColor: Color(0xFF00E676)),
      );
    }
  }

  @override
  void dispose() {
    _heightCtrl.removeListener(_updateBmi);
    _weightCtrl.removeListener(_updateBmi);
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    _bmiNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weightsAsync = ref.watch(weightEntriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        title: Text('BMI & Weight', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RepaintBoundary(child: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Input Card
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your Measurements', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 16.h),

              // Gender
              Row(children: [
                Text('Gender:', style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 13.sp)),
                SizedBox(width: 12.w),
                _GenderBtn(label: 'Male', icon: Icons.male_rounded, selected: _gender == 'male', onTap: () => setState(() => _gender = 'male')),
                SizedBox(width: 8.w),
                _GenderBtn(label: 'Female', icon: Icons.female_rounded, selected: _gender == 'female', onTap: () => setState(() => _gender = 'female')),
              ]),
              SizedBox(height: 14.h),

              Row(children: [
                Expanded(child: _SmallInput(controller: _heightCtrl, label: 'Height (cm)', hint: '175')),
                SizedBox(width: 10.w),
                Expanded(child: _SmallInput(controller: _weightCtrl, label: 'Weight (kg)', hint: '70')),
                SizedBox(width: 10.w),
                Expanded(child: _SmallInput(controller: _ageCtrl, label: 'Age', hint: '25')),
              ]),
              SizedBox(height: 16.h),

              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.cyan,
                    foregroundColor: const Color(0xFF0A0E1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Color(0xFF0A0E1A), strokeWidth: 2)
                      : Text('Save & Log Weight', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.sp)),
                ),
              ),
            ]),
          ),
          SizedBox(height: 20.h),

          // BMI Result
          ValueListenableBuilder<double?>(
            valueListenable: _bmiNotifier,
            builder: (_, bmi, __) {
              if (bmi == null) return const SizedBox.shrink();
              return Column(children: [
                _BmiResult(bmi: bmi).animate().fadeIn(duration: NumExtension(400).ms).scale(begin: const Offset(0.95, 0.95)),
                SizedBox(height: 20.h),
              ]);
            },
          ),

          // Weight History Chart
          weightsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (weights) {
              if (weights.length < 2) return const SizedBox.shrink();
              return _WeightChart(weights: weights.take(14).toList().reversed.toList());
            },
          ),
        ],
      )),
    );
  }
}

class _BmiResult extends StatelessWidget {
  const _BmiResult({required this.bmi});
  final double bmi;

  String get _category {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _color {
    if (bmi < 18.5) return const Color(0xFF00B0FF);
    if (bmi < 25.0) return FitColors.green;
    if (bmi < 30.0) return FitColors.orange;
    return Colors.redAccent;
  }

  String get _emoji {
    if (bmi < 18.5) return '🪶';
    if (bmi < 25.0) return '✅';
    if (bmi < 30.0) return '⚠️';
    return '🔴';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Column(children: [
        Text('$_emoji Your BMI', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 12.h),
        Text(bmi.toStringAsFixed(1), style: TextStyle(color: _color, fontSize: 48.sp, fontWeight: FontWeight.w900)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8.r)),
          child: Text(_category, style: TextStyle(color: _color, fontSize: 14.sp, fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: 16.h),
        // BMI Scale
        _BmiScale(bmi: bmi),
      ]),
    );
  }
}

class _BmiScale extends StatelessWidget {
  const _BmiScale({required this.bmi});
  final double bmi;

  @override
  Widget build(BuildContext context) {
    final position = ((bmi - 10) / (40 - 10)).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: Container(
            height: 12.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF00B0FF), Color(0xFF00E676), Color(0xFFFF6B35), Colors.redAccent]),
            ),
          ),
        ),
        Positioned(
          left: position * (MediaQuery.of(context).size.width - 64.w) - 6.w,
          top: -2.h,
          child: Container(
            width: 16.w, height: 16.w,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0A0E1A), width: 2)),
          ),
        ),
      ]),
      SizedBox(height: 6.h),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('18.5', style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 10.sp)),
        Text('25.0', style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 10.sp)),
        Text('30.0', style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 10.sp)),
      ]),
    ]);
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.weights});
  final List<WeightModel> weights;

  @override
  Widget build(BuildContext context) {
    final spots = weights.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weightKg)).toList();
    final minY = weights.map((w) => w.weightKg).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = weights.map((w) => w.weightKg).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight), borderRadius: BorderRadius.circular(16.r), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Weight History', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 20.h),
        SizedBox(
          height: 140.h,
          child: LineChart(LineChartData(
            minY: minY, maxY: maxY,
            lineBarsData: [LineChartBarData(
              spots: spots,
              color: FitColors.green,
              barWidth: 2.5,
              isCurved: true,
              dotData: FlDotData(getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(radius: 3, color: FitColors.green, strokeWidth: 0)),
              belowBarData: BarAreaData(show: true, color: FitColors.green.withValues(alpha: 0.08)),
            )],
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight), strokeWidth: 1)),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36.w, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 10.sp)))),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= weights.length) return const SizedBox.shrink();
                  return Text(DateFormat('d/M').format(weights[idx].date), style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 9.sp));
                },
              )),
            ),
            borderData: FlBorderData(show: false),
          )),
        ),
      ]),
    ).animate().fadeIn(duration: NumExtension(500).ms);
  }
}

class _GenderBtn extends StatelessWidget {
  const _GenderBtn({required this.label, required this.icon, required this.selected, required this.onTap});
  final String label; final IconData icon; final bool selected; final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: NumExtension(200).ms,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: selected ? FitColors.cyan.withValues(alpha: 0.12) : (Theme.of(context).brightness == Brightness.dark ? FitColors.surfaceDark : FitColors.surfaceLight),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: selected ? FitColors.cyan : (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight)),
      ),
      child: Row(children: [
        Icon(icon, color: selected ? FitColors.cyan : (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), size: 16.sp),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(color: selected ? FitColors.cyan : (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 12.sp, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ]),
    ),
  );
}

class _SmallInput extends StatelessWidget {
  const _SmallInput({super.key, required this.controller, required this.label, required this.hint});
  final TextEditingController controller; final String label; final String hint;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 11.sp, fontWeight: FontWeight.w500)),
    SizedBox(height: 6.h),
    TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.4), fontSize: 13.sp),
        filled: true, fillColor: const Color(0xFF0A0E1A),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: FitColors.cyan, width: 1.5)),
      ),
    ),
  ]);
}
