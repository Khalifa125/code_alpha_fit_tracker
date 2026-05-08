// ignore_for_file: invalid_use_of_visible_for_testing_member, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';

import 'fitness_widgets.dart';

class WorkoutPlansScreen extends ConsumerWidget {
  const WorkoutPlansScreen({super.key});

  static const _filters = ['All', 'Beginner', 'Intermediate', 'Advanced', 'Strength', 'HIIT', 'Cardio', 'Flexibility'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(filteredWorkoutPlansProvider);
    final filter = ref.watch(workoutFilterProvider);

    // Today's plan
    final todayPlan = plans.isNotEmpty ? plans.first : null;

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Workouts',
                  style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
                Icon(Icons.search_rounded, color: FitColors.textSecondary, size: 22.sp),
              ],
            ),
          ),

          // Category chips (For You / Strength / Cardio / Yoga)
          SizedBox(
            height: 36.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: ['For You', 'Strength', 'Cardio', 'Yoga'].length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final labels = ['For You', 'Strength', 'Cardio', 'Yoga'];
                final selected = i == 0;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: selected ? FitColors.neonGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected ? FitColors.neonGreen : FitColors.border,
                    ),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      color: selected ? FitColors.background : FitColors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),

          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 80.h),
              children: [
                // Today's Plan banner
                if (todayPlan != null) ...[
                  Text("Today's Plan",
                    style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 12.h),
                  _TodayPlanBanner(plan: todayPlan),
                  SizedBox(height: 24.h),
                ],

                // Categories grid
                Text('Categories',
                  style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 12.h),
                Row(children: [
                  _CategoryCard(label: 'Strength', color: FitColors.orange, emoji: '🏋️'),
                  SizedBox(width: 10.w),
                  _CategoryCard(label: 'Cardio', color: FitColors.blue, emoji: '🏃'),
                ]),
                SizedBox(height: 10.h),
                Row(children: [
                  _CategoryCard(label: 'Yoga', color: FitColors.neonGreen, emoji: '🧘'),
                  SizedBox(width: 10.w),
                  _CategoryCard(label: 'HIIT', color: FitColors.orange, emoji: '⚡'),
                ]),
                SizedBox(height: 24.h),

                // Filter chips
                SizedBox(
                  height: 36.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) {
                      final f = _filters[i];
                      final selected = f == filter;
                      return GestureDetector(
                        onTap: () => ref.read(workoutFilterProvider.notifier).state = f,
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                          decoration: BoxDecoration(
                            color: selected ? FitColors.neonGreen.withValues(alpha: 0.12) : FitColors.card,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: selected ? FitColors.neonGreen : FitColors.border,
                            ),
                          ),
                          child: Text(f, style: TextStyle(
                            color: selected ? FitColors.neonGreen : FitColors.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          )),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12.h),

                // Plans list
                ...plans.asMap().entries.map((e) {
                  return _WorkoutPlanCard(plan: e.value)
                    .animate(delay: (e.key * 50).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.08, end: 0);
                }),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Today's Plan Banner ───────────────────────────────────────────────────

class _TodayPlanBanner extends StatelessWidget {
  const _TodayPlanBanner({required this.plan});
  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push<void>(context,
      MaterialPageRoute<void>(builder: (_) => _WorkoutDetailScreen(plan: plan))),
    child: Container(
      height: 140.h,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: FitColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [FitColors.card, FitColors.neonGreen.withValues(alpha: 0.06)],
        ),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(plan.name,
              style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w800)),
            SizedBox(height: 6.h),
            Text('${plan.durationMins} min  •  ${plan.level}',
              style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp)),
            SizedBox(height: 12.h),
            SizedBox(
              height: 40.h,
              child: ElevatedButton(
                onPressed: () => Navigator.push<void>(context,
                  MaterialPageRoute<void>(builder: (_) => _WorkoutDetailScreen(plan: plan))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.neonGreen,
                  foregroundColor: FitColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0,
                ),
                child: Text('Start Workout',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp)),
              ),
            ),
          ]),
        ),
        SizedBox(width: 12.w),
        Text(plan.emoji, style: TextStyle(fontSize: 60.sp)),
      ]),
    ),
  );
}

// ─── Category Card ─────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.label, required this.color, required this.emoji});
  final String label;
  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            right: 10.w,
            child: Text(emoji, style: TextStyle(fontSize: 40.sp)),
          ),
          Padding(
            padding: EdgeInsets.only(left: 14.w),
            child: Text(label,
              style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ),
  );
}

// ─── Workout Plan Card ─────────────────────────────────────────────────────

class _WorkoutPlanCard extends StatelessWidget {
  const _WorkoutPlanCard({required this.plan});
  final WorkoutPlan plan;

  Color get _levelColor => switch (plan.level) {
    'Beginner'     => FitColors.neonGreen,
    'Intermediate' => FitColors.orange,
    'Advanced'     => FitColors.pink,
    _              => FitColors.cyan,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push<void>(context,
      MaterialPageRoute<void>(builder: (_) => _WorkoutDetailScreen(plan: plan))),
    child: Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: FitColors.border),
      ),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: _levelColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(plan.emoji, style: TextStyle(fontSize: 24.sp)),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(plan.name,
            style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text('${plan.durationMins} min  •  ${plan.exercises.length} exercises',
            style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
          SizedBox(height: 6.h),
          Row(children: [
            _Badge(text: plan.level, color: _levelColor),
            SizedBox(width: 5.w),
            _Badge(text: plan.category, color: FitColors.blue),
          ]),
        ])),
        Icon(Icons.chevron_right_rounded, color: FitColors.textMuted, size: 18.sp),
      ]),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

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

// ─── Workout Detail Screen ─────────────────────────────────────────────────

class _WorkoutDetailScreen extends StatelessWidget {
  const _WorkoutDetailScreen({required this.plan});
  final WorkoutPlan plan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitColors.background,
      appBar: AppBar(
        backgroundColor: FitColors.background,
        title: Text(plan.name,
          style: TextStyle(color: FitColors.textPrimary, fontSize: 17.sp, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: FitColors.textPrimary),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // Header card
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: FitColors.card,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: FitColors.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(plan.emoji, style: TextStyle(fontSize: 44.sp)),
                SizedBox(width: 14.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(plan.name,
                    style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4.h),
                  Text(plan.description,
                    style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp, height: 1.4)),
                ])),
              ]),
              SizedBox(height: 16.h),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _DetailStat(label: 'Duration', value: '${plan.durationMins} min', color: FitColors.neonGreen),
                _DetailStat(label: 'Calories', value: '~${plan.calories}', color: FitColors.orange),
                _DetailStat(label: 'Level', value: plan.level, color: FitColors.blue),
                _DetailStat(label: 'Exercises', value: '${plan.exercises.length}', color: FitColors.purple),
              ]),
            ]),
          ),
          SizedBox(height: 20.h),

          Text('Exercises',
            style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 12.h),

          ...plan.exercises.asMap().entries.map((e) {
            final i = e.key;
            final ex = e.value;
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: FitColors.card,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: FitColors.border),
              ),
              child: Row(children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: FitColors.neonGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(child: Text(
                    '${i + 1}',
                    style: TextStyle(color: FitColors.neonGreen, fontWeight: FontWeight.w800, fontSize: 13.sp),
                  )),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ex.name,
                    style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  Text(ex.muscle,
                    style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${ex.sets} × ${ex.reps}',
                    style: TextStyle(color: FitColors.neonGreen, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                  Text('Rest: ${ex.rest}',
                    style: TextStyle(color: FitColors.textMuted, fontSize: 10.sp)),
                ]),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right_rounded, color: FitColors.textMuted, size: 16.sp),
              ]),
            ).animate(delay: (i * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.08, end: 0);
          }),

          SizedBox(height: 20.h),

          // Start workout button
          SizedBox(
            height: 54.h,
            child: ElevatedButton(
              onPressed: () => Navigator.push<void>(context,
                MaterialPageRoute<void>(builder: (_) => _WorkoutPlayerScreen(plan: plan))),
              style: ElevatedButton.styleFrom(
                backgroundColor: FitColors.neonGreen,
                foregroundColor: FitColors.background,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 0,
              ),
              child: Text('Start Workout',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 14.sp, fontWeight: FontWeight.w800)),
    SizedBox(height: 2.h),
    Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 10.sp)),
  ]);
}

// ─── Workout Player Screen ─────────────────────────────────────────────────

class _WorkoutPlayerScreen extends StatefulWidget {
  const _WorkoutPlayerScreen({required this.plan});
  final WorkoutPlan plan;

  @override
  State<_WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<_WorkoutPlayerScreen> {
  int _currentExercise = 0;
  int _reps = 10;
  bool _isPlaying = true;
  final int _restSeconds = 30;

  WorkoutExercise get _ex => widget.plan.exercises[_currentExercise];

  void _next() {
    if (_currentExercise < widget.plan.exercises.length - 1) {
      setState(() => _currentExercise++);
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (_currentExercise > 0) setState(() => _currentExercise--);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.plan.exercises.length;

    return Scaffold(
      backgroundColor: FitColors.background,
      appBar: AppBar(
        backgroundColor: FitColors.background,
        title: Text(
          '${_ex.name}  ${_currentExercise + 1} / $total',
          style: TextStyle(color: FitColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: FitColors.textPrimary),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(children: [
          // Exercise image placeholder
          Expanded(
            flex: 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: FitColors.card,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: FitColors.border),
              ),
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(widget.plan.emoji, style: TextStyle(fontSize: 80.sp)),
                  SizedBox(height: 12.h),
                  Text(_ex.name,
                    style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
                  SizedBox(height: 4.h),
                  Text(_ex.muscle,
                    style: TextStyle(color: FitColors.textSecondary, fontSize: 13.sp)),
                ]),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Reps counter
          Expanded(
            flex: 2,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Reps',
                style: TextStyle(color: FitColors.textSecondary, fontSize: 14.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 4.h),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                GestureDetector(
                  onTap: () => setState(() { if (_reps > 1) _reps--; }),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: FitColors.card,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: FitColors.border),
                    ),
                    child: Icon(Icons.remove_rounded, color: FitColors.textPrimary, size: 20.sp),
                  ),
                ),
                SizedBox(width: 24.w),
                Text('$_reps',
                  style: TextStyle(
                    color: FitColors.textPrimary,
                    fontSize: 64.sp,
                    fontWeight: FontWeight.w900,
                  )),
                SizedBox(width: 24.w),
                GestureDetector(
                  onTap: () => setState(() => _reps++),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: FitColors.neonGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: FitColors.neonGreen.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.add_rounded, color: FitColors.neonGreen, size: 20.sp),
                  ),
                ),
              ]),
              SizedBox(height: 8.h),
              Text('Rest Time: 00:${_restSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(color: FitColors.textSecondary, fontSize: 14.sp)),
            ]),
          ),

          // Controls
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _ControlBtn(
              icon: Icons.skip_previous_rounded,
              onTap: _prev,
              color: FitColors.textSecondary,
            ),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FitColors.neonGreen,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: FitColors.background,
                  size: 30.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            _ControlBtn(
              icon: Icons.skip_next_rounded,
              onTap: _next,
              color: FitColors.textSecondary,
            ),
          ]),
          SizedBox(height: 20.h),
        ]),
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  const _ControlBtn({required this.icon, required this.onTap, required this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: FitColors.card,
        border: Border.all(color: FitColors.border),
      ),
      child: Icon(icon, color: color, size: 22.sp),
    ),
  );
}
