import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/gamification/data/models/gamification_models.dart';
import 'package:fit_tracker/src/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fit_tracker/src/shared/widgets/exercise_animation.dart';

class _ExerciseResult {
  final String name;
  final int setsCompleted;
  final int targetSets;

  _ExerciseResult({required this.name, required this.setsCompleted, required this.targetSets});
  bool get completed => setsCompleted >= targetSets;
  double get completionRatio => (setsCompleted / targetSets).clamp(0.0, 1.0);
}

class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  final WorkoutPlan plan;

  const WorkoutPlayerScreen({super.key, required this.plan});

  @override
  ConsumerState<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends ConsumerState<WorkoutPlayerScreen> with WidgetsBindingObserver {
  int _currentExercise = 0;
  int _reps = 10;
  bool _isPlaying = false;
  bool _isResting = false;
  int _restSeconds = 30;
  int? _activeTimerSeconds;
  Timer? _timer;
  final List<_ExerciseResult> _exerciseResults = [];
  int _currentSetsDone = 0;
  WorkoutExercise get _ex => widget.plan.exercises[_currentExercise];
  int get _total => widget.plan.exercises.length;
  int get _targetSets => int.tryParse(_ex.sets) ?? 3;
  int get _targetReps => int.tryParse(_ex.reps) ?? 10;
  double get _progress => (_currentExercise + (_isResting ? 0.5 : _currentSetsDone / (_targetSets.clamp(1, 10)))) / _total;
  int get _adjustedRest {
    final base = int.tryParse(_ex.rest.replaceAll(RegExp(r'[^0-9]'), '')) ?? 30;
    final diff = _ex.difficulty.toLowerCase();
    final mult = diff == 'beginner' ? 1.5 : diff == 'advanced' ? 0.7 : 1.0;
    return (base * mult).round().clamp(15, 120);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _pauseWorkout();
  }

  void _startExercise() {
    _isResting = false;
    _isPlaying = true;
    _activeTimerSeconds = null;
    _currentSetsDone = 1;
    _startTimer(60, _autoRest);
    HapticFeedback.mediumImpact();
  }

  void _completeSet() {
    if (_currentSetsDone < _targetSets) {
      setState(() => _currentSetsDone++);
      HapticFeedback.heavyImpact();
      _autoRest();
    } else {
      _markExerciseDone();
      _nextExercise();
    }
  }

  void _markExerciseDone() {
    _exerciseResults.add(_ExerciseResult(name: _ex.name, setsCompleted: _currentSetsDone, targetSets: _targetSets));
  }

  void _pauseWorkout() {
    _timer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _resumeWorkout() {
    if (_isResting) {
      _startTimer(_restSeconds, _onRestComplete);
    } else {
      _isPlaying = true;
      if (_activeTimerSeconds != null && _activeTimerSeconds! > 0) {
        _startTimer(_activeTimerSeconds!, _autoRest);
      }
    }
  }

  void _onRestComplete() {
    setState(() {
      _isResting = false;
      _isPlaying = false;
    });
    HapticFeedback.heavyImpact();
  }

  void _autoRest() {
    _timer?.cancel();
    final restSeconds = _adjustedRest;
    setState(() {
      _isPlaying = false;
      _isResting = true;
      _restSeconds = restSeconds;
    });
    _startTimer(restSeconds, _onRestComplete);
    HapticFeedback.heavyImpact();
  }

  void _skipRest() {
    _timer?.cancel();
    _onRestComplete();
  }

  void _nextExercise() {
    if (_currentExercise < _total - 1) {
      setState(() {
        _currentExercise++;
        _isResting = false;
        _reps = 10;
        _activeTimerSeconds = null;
        _currentSetsDone = 0;
      });
    } else {
      _finishWorkout();
    }
  }

  void _prevExercise() {
    if (_currentExercise > 0) {
      _timer?.cancel();
      setState(() {
        _currentExercise--;
        _isResting = false;
        _reps = 10;
        _activeTimerSeconds = null;
        _isPlaying = false;
        _currentSetsDone = 0;
      });
    }
  }

  void _finishWorkout() {
    _timer?.cancel();
    _markExerciseDone();
    HapticFeedback.heavyImpact();
    ref.read(gamificationProvider.notifier).completeWorkout(widget.plan.calories, widget.plan.durationMins);
    final xpLevel = XpLevel.fromTotalXp(ref.read(gamificationProvider).totalXp);
    final completedEx = _exerciseResults.where((r) => r.completed).length;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎉', style: TextStyle(fontSize: 48.sp)),
            SizedBox(height: 12.h),
            Text('Workout Complete!', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Theme.of(context).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight)),
            SizedBox(height: 8.h),
            Text('${widget.plan.name}  •  $completedEx/${_exerciseResults.length} exercises', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp)),
            SizedBox(height: 16.h),
            ..._exerciseResults.map((r) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                children: [
                  Icon(r.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: r.completed ? FitColors.neonGreen : (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), size: 16),
                  SizedBox(width: 8.w),
                  Text(r.name, style: TextStyle(color: r.completed ? FitColors.neonGreen : (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 12.sp)),
                  const Spacer(),
                  Text('${r.setsCompleted}/${r.targetSets} sets', style: TextStyle(color: r.completed ? FitColors.neonGreen : (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 11.sp)),
                ],
              ),
            )),
            SizedBox(height: 12.h),
            Text('~${widget.plan.calories} kcal burned', style: TextStyle(color: FitColors.neonGreen, fontSize: 14.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, color: FitColors.amber, size: 16),
                SizedBox(width: 4.w),
                Text('Level ${xpLevel.level}  •  +${50 + (widget.plan.durationMins ~/ 10) * 10} XP', style: TextStyle(color: FitColors.amber, fontSize: 12.sp, fontWeight: FontWeight.w700)),
              ],
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.neonGreen,
                  foregroundColor: Theme.of(context).brightness == Brightness.dark ? FitColors.backgroundDark : FitColors.backgroundLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startTimer(int seconds, VoidCallback onComplete) {
    _timer?.cancel();
    setState(() {
      if (!_isResting) _activeTimerSeconds = seconds;
      _isPlaying = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds <= 1) {
        t.cancel();
        onComplete();
      } else {
        seconds--;
        if (mounted) {
          setState(() {
            if (_isResting) { _restSeconds = seconds; }
            else { _activeTimerSeconds = seconds; }
          });
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
        title: Text('${_ex.name}  ${_currentExercise + 1} / $_total', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 15.sp, fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () { _timer?.cancel(); Navigator.pop(context); },
        ),
      ),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: _progress, end: _progress),
              duration: 300.ms,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor: (isDark ? FitColors.borderDark : FitColors.borderLight).withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(FitColors.neonGreen),
                minHeight: 4.h,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: isDark ? FitColors.cardDark : FitColors.cardLight,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ExerciseAnimation(
                            exerciseType: _ex.muscle,
                            emoji: widget.plan.emoji,
                            size: 72.sp,
                          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                          SizedBox(height: 12.h),
                          Text(_ex.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 20.sp, fontWeight: FontWeight.w700), textAlign: TextAlign.center)
                              .animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                          SizedBox(height: 6.h),
                          Text(_ex.muscle, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp))
                              .animate().fadeIn(delay: 150.ms),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSetDot(isDark: isDark, filled: true),
                              ...List.generate(_targetSets - 1, (i) => _buildSetDot(isDark: isDark, filled: i < _currentSetsDone)),
                              SizedBox(width: 8.w),
                              Text('$_targetSets × $_targetReps', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                            ],
                          ).animate().fadeIn(delay: 200.ms),
                          if (_ex.difficulty.isNotEmpty) ...[
                            SizedBox(height: 6.h),
                            _buildDifficultyChip().animate().fadeIn(delay: 250.ms),
                          ],
                          if (_ex.equipment.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(_ex.equipment, style: TextStyle(color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 10.sp))
                                .animate().fadeIn(delay: 300.ms),
                          ],
                          if (_ex.tips.isNotEmpty) ...[
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: FitColors.amber.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline_rounded, size: 12.sp, color: FitColors.amber),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Text(_ex.tips, style: TextStyle(color: FitColors.amber, fontSize: 10.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 350.ms),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    flex: 2,
                    child: _isResting ? _buildRestTimer(isDark) : _buildRepsCounter(isDark),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _ControlBtn(icon: Icons.skip_previous_rounded, onTap: _prevExercise, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
                    SizedBox(width: 16.w),
                    _buildMainButton(isDark).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
                    SizedBox(width: 16.w),
                    _ControlBtn(icon: Icons.skip_next_rounded, onTap: _isResting ? _skipRest : _autoRest, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                  ]),
                  SizedBox(height: 12.h),
                  Text('${_currentExercise + 1} / $_total  •  ${_ex.sets} × ${_ex.reps}', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 12.sp)).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetDot({required bool isDark, required bool filled}) {
    return Container(
      width: 10.w,
      height: 10.w,
      margin: EdgeInsets.only(right: 4.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? FitColors.neonGreen : (isDark ? FitColors.surfaceDark : FitColors.surfaceLight),
        border: Border.all(color: filled ? FitColors.neonGreen : (isDark ? FitColors.borderDark : FitColors.borderLight)),
      ),
    );
  }

  Widget _buildDifficultyChip() {
    final color = _ex.difficulty.toLowerCase() == 'beginner' ? FitColors.neonGreen
        : _ex.difficulty.toLowerCase() == 'intermediate' ? FitColors.orange
        : FitColors.pink;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(_ex.difficulty, style: TextStyle(color: color, fontSize: 9.sp, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMainButton(bool isDark) {
    if (_isResting) {
      return GestureDetector(
        onTap: _skipRest,
        child: Container(
          width: 64.w, height: 64.w,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: FitColors.orange),
          child: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 30),
        ),
      );
    }
    if (!_isPlaying) {
      return GestureDetector(
        onTap: _currentSetsDone > 0 ? _resumeWorkout : _startExercise,
        child: Container(
          width: 64.w, height: 64.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _currentSetsDone > 0 ? FitColors.blue : FitColors.neonGreen),
          child: Icon(
            _currentSetsDone > 0 ? Icons.play_arrow_rounded : Icons.fitness_center_rounded,
            color: isDark ? FitColors.backgroundDark : FitColors.backgroundLight, size: 30.sp,
          ),
        ),
      );
    }
    if (_currentSetsDone < _targetSets && _activeTimerSeconds == null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1200),
        builder: (_, value, __) => GestureDetector(
          onTap: _completeSet,
          child: Container(
            width: (64 + 2 * math.sin(value * math.pi * 2)).w,
            height: (64 + 2 * math.sin(value * math.pi * 2)).w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FitColors.neonGreen,
              boxShadow: [
                BoxShadow(
                  color: FitColors.neonGreen.withValues(alpha: 0.3 * (0.5 + 0.5 * math.sin(value * math.pi * 2))),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.check_rounded, color: isDark ? FitColors.backgroundDark : FitColors.backgroundLight, size: 30.sp),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _pauseWorkout,
      child: Container(
        width: 64.w, height: 64.w,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: FitColors.neonGreen),
        child: const Icon(Icons.pause_rounded, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildRestTimer(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Rest Time', style: TextStyle(color: FitColors.orange, fontSize: 14.sp, fontWeight: FontWeight.w600)).animate().fadeIn().shimmer(duration: 1500.ms, color: FitColors.orange.withValues(alpha: 0.3)),
        SizedBox(height: 4.h),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (_, value, __) => Transform.scale(
            scale: 1 + 0.03 * math.sin(value * math.pi * 2),
            child: Text(_formatTime(_restSeconds), style: TextStyle(color: FitColors.orange, fontSize: 56.sp, fontWeight: FontWeight.w900, height: 1)),
          ),
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(2.r),
          child: LinearProgressIndicator(
            value: 1 - (_restSeconds / 30.0),
            backgroundColor: (isDark ? FitColors.surfaceDark : FitColors.surfaceLight).withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation(FitColors.orange),
            minHeight: 3.h,
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: _skipRest,
          child: Text('Skip', style: TextStyle(color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 12.sp, decoration: TextDecoration.underline)),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildRepsCounter(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _activeTimerSeconds != null ? _formatTime(_activeTimerSeconds!) : 'Set $_currentSetsDone / ${_ex.sets}',
          style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 36.sp, fontWeight: FontWeight.w900, height: 1),
        ),
        SizedBox(height: 8.h),
        if (_activeTimerSeconds == null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() { if (_reps > 1) _reps--; HapticFeedback.lightImpact(); }),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: isDark ? FitColors.cardDark : FitColors.cardLight,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                  ),
                  child: Icon(Icons.remove_rounded, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, size: 18.sp),
                ),
              ),
              SizedBox(width: 20.w),
              Column(
                children: [
                  Text('$_reps', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 28.sp, fontWeight: FontWeight.w800)),
                  Text('reps', style: TextStyle(color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 10.sp)),
                ],
              ),
              SizedBox(width: 20.w),
              GestureDetector(
                onTap: () => setState(() => _reps++),
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: FitColors.neonGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: FitColors.neonGreen.withValues(alpha: 0.4)),
                  ),
                  child: Icon(Icons.add_rounded, color: FitColors.neonGreen, size: 18.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
                          Text('Rest $_adjustedRest s', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
        ],
        if (_activeTimerSeconds != null) ...[
          Text('seconds remaining', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
        ],
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ControlBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? FitColors.cardDark : FitColors.cardLight,
          border: Border.all(color: isDark ? FitColors.borderDark : FitColors.borderLight),
        ),
        child: Icon(icon, color: color, size: 22.sp),
      ),
    );
  }
}
