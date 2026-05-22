import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fit_track/providers/workout_provider.dart';
import 'package:fit_tracker/src/features/fit_track/screens/workout_session_screen.dart';

Future<void> showWorkoutPreferencesSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _WorkoutPreferencesSheet(),
  );
}

class _WorkoutPreferencesSheet extends ConsumerStatefulWidget {
  const _WorkoutPreferencesSheet();

  @override
  ConsumerState<_WorkoutPreferencesSheet> createState() => _WorkoutPreferencesSheetState();
}

class _WorkoutPreferencesSheetState extends ConsumerState<_WorkoutPreferencesSheet> {
  String _goal = 'stayActive';
  String _fitnessLevel = 'intermediate';
  double _duration = 30;
  bool _generating = false;

  static const _goals = [
    _Option('stayActive', 'Stay Active', Icons.directions_run_rounded, FitColors.neonGreen),
    _Option('loseWeight', 'Lose Weight', Icons.monitor_weight_rounded, FitColors.orange),
    _Option('buildMuscle', 'Build Muscle', Icons.fitness_center_rounded, FitColors.pink),
  ];

  static const _levels = [
    _Option('beginner', 'Beginner', Icons.grass_rounded, FitColors.neonGreen),
    _Option('intermediate', 'Intermediate', Icons.trending_up_rounded, FitColors.amber),
    _Option('advanced', 'Advanced', Icons.bolt_rounded, FitColors.pink),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(24.r),
        radius: 24,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w, height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text('Generate Workout', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 20.sp, fontWeight: FontWeight.w700,
              )).animate().fadeIn().slideX(begin: -0.05),
              SizedBox(height: 4.h),
              Text('Tell us your preferences and we\'ll build the perfect session.',
                style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 12.sp)),
              SizedBox(height: 20.h),

              // Goal selector
              Text('Your Goal', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Row(children: _goals.map((g) => Expanded(child: _OptionChip(
                option: g, selected: _goal == g.value, isDark: isDark,
                onTap: () => setState(() => _goal = g.value),
              ))).toList(),),
              SizedBox(height: 16.h),

              // Fitness level selector
              Text('Fitness Level', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Row(children: _levels.map((l) => Expanded(child: _OptionChip(
                option: l, selected: _fitnessLevel == l.value, isDark: isDark,
                onTap: () => setState(() => _fitnessLevel = l.value),
              ))).toList(),),
              SizedBox(height: 16.h),

              // Duration slider
              Text('Duration: ${_duration.toInt()} min', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: FitColors.neonGreen,
                  inactiveTrackColor: (isDark ? FitColors.borderDark : FitColors.borderLight).withValues(alpha: 0.3),
                  thumbColor: FitColors.neonGreen,
                  overlayColor: FitColors.neonGreen.withValues(alpha: 0.12),
                  trackHeight: 4.h,
                ),
                child: Slider(
                  value: _duration,
                  min: 10,
                  max: 90,
                  divisions: 8,
                  label: '${_duration.toInt()} min',
                  onChanged: (v) => setState(() => _duration = v),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('10 min', style: TextStyle(color: (isDark ? FitColors.textMutedDark : FitColors.textMutedLight).withValues(alpha: 0.6), fontSize: 9.sp)),
                Text('90 min', style: TextStyle(color: (isDark ? FitColors.textMutedDark : FitColors.textMutedLight).withValues(alpha: 0.6), fontSize: 9.sp)),
              ]),
              SizedBox(height: 20.h),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generating ? null : _onGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    foregroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    disabledBackgroundColor: FitColors.neonGreen.withValues(alpha: 0.4),
                  ),
                  child: _generating
                    ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Generate Workout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  void _onGenerate() {
    setState(() => _generating = true);
    HapticFeedback.heavyImpact();

    final notifier = ref.read(workoutProvider.notifier);
    notifier.generateWorkout(
      goal: _goal,
      fitnessLevel: _fitnessLevel,
      availableMinutes: _duration.toInt(),
    );

    final state = ref.read(workoutProvider);
    if (state.currentWorkout != null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutSessionScreen(workout: state.currentWorkout!),
        ),
      );
    }
  }
}

class _Option {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _Option(this.value, this.label, this.icon, this.color);
}

class _OptionChip extends StatelessWidget {
  final _Option option;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionChip({required this.option, required this.selected, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: selected
            ? option.color.withValues(alpha: 0.12)
            : (isDark ? FitColors.cardDark : FitColors.cardLight),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
              ? option.color.withValues(alpha: 0.5)
              : (isDark ? FitColors.borderDark : FitColors.borderLight),
          ),
        ),
        child: Column(
          children: [
            Icon(option.icon, color: selected ? option.color : (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), size: 20.sp),
            SizedBox(height: 4.h),
            Text(option.label, style: TextStyle(
              color: selected ? option.color : (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
              fontSize: 10.sp, fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}
