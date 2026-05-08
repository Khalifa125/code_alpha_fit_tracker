// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

// ─── Color Palette (re-exported for use in other files) ───────────────────


// ─── Stat Card ─────────────────────────────────────────────────────────────

class FitStatCard extends StatelessWidget {
  const FitStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: FitColors.card,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              color: FitColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            unit,
            style: TextStyle(color: FitColors.textSecondary, fontSize: 9.sp),
          ),
        ]),
      ),
    )
      .animate(delay: delay)
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.15, end: 0);
  }
}

// ─── Goal Progress Bar ─────────────────────────────────────────────────────

class FitProgressBar extends StatelessWidget {
  const FitProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    required this.unit,
  });

  final String label;
  final double current;
  final double goal;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final pct = (progress * 100).toInt();

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
          style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp)),
        Row(children: [
          Text(current.toStringAsFixed(0),
            style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          Text(' / ${goal.toStringAsFixed(0)} $unit',
            style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
          SizedBox(width: 6.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text('$pct%',
              style: TextStyle(color: color, fontSize: 9.sp, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
      SizedBox(height: 6.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: 800.ms,
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => LinearProgressIndicator(
            value: v,
            backgroundColor: FitColors.border,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 7.h,
          ),
        ),
      ),
    ]);
  }
}

// ─── Activity Tile ─────────────────────────────────────────────────────────

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
    this.onDelete,
    this.showDate = false,
  });

  final Activity activity;
  final VoidCallback? onDelete;
  final bool showDate;

  static IconData iconForType(String type) {
    return switch (type.toLowerCase()) {
      'running'  => Icons.directions_run_rounded,
      'cycling'  => Icons.directions_bike_rounded,
      'swimming' => Icons.pool_rounded,
      'walking'  => Icons.directions_walk_rounded,
      'gym'      => Icons.fitness_center_rounded,
      'yoga'     => Icons.self_improvement_rounded,
      'hiit'     => Icons.flash_on_rounded,
      _          => Icons.sports_rounded,
    };
  }

  static Color colorForType(String type) {
    return switch (type.toLowerCase()) {
      'running'  => FitColors.orange,
      'cycling'  => FitColors.purple,
      'swimming' => FitColors.blue,
      'walking'  => FitColors.neonGreen,
      'gym'      => FitColors.pink,
      'yoga'     => FitColors.neonGreen,
      'hiit'     => FitColors.amber,
      _          => FitColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForType(activity.type);

    final tile = Container(
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(iconForType(activity.type), color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              activity.type,
              style: TextStyle(color: FitColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              '${activity.durationMinutes} min  •  ${activity.steps} steps',
              style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp),
            ),
            if (activity.notes.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                activity.notes,
                style: TextStyle(color: FitColors.textMuted, fontSize: 10.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${activity.caloriesBurned.toStringAsFixed(0)} kcal',
            style: TextStyle(color: FitColors.orange, fontWeight: FontWeight.w800, fontSize: 13.sp),
          ),
          if (showDate)
            Text(
              '${activity.date.day}/${activity.date.month}',
              style: TextStyle(color: FitColors.textMuted, fontSize: 10.sp),
            ),
        ]),
      ]),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: Key(activity.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete!(),
      background: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
      ),
      child: tile,
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────

class FitSectionHeader extends StatelessWidget {
  const FitSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
        style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!,
            style: TextStyle(color: FitColors.neonGreen, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ),
    ],
  );
}

// ─── Empty State ───────────────────────────────────────────────────────────

class FitEmptyState extends StatelessWidget {
  const FitEmptyState({super.key, required this.message, required this.emoji});

  final String message;
  final String emoji;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 32.h),
    decoration: BoxDecoration(
      color: FitColors.card,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: FitColors.border),
    ),
    child: Column(children: [
      Text(emoji, style: TextStyle(fontSize: 36.sp)),
      SizedBox(height: 10.h),
      Text(message,
        textAlign: TextAlign.center,
        style: TextStyle(color: FitColors.textSecondary, fontSize: 13.sp, height: 1.5)),
    ]),
  );
}

// ─── Workout Plan Card (used in WorkoutPlansScreen) ────────────────────────

class WorkoutPlanCardWidget extends StatelessWidget {
  const WorkoutPlanCardWidget({super.key, required this.plan, this.onTap});
  final WorkoutPlan plan;
  final VoidCallback? onTap;

  Color get _levelColor => switch (plan.level) {
    'Beginner'     => FitColors.neonGreen,
    'Intermediate' => FitColors.orange,
    'Advanced'     => FitColors.pink,
    _              => FitColors.cyan,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: FitColors.border),
      ),
      child: Row(children: [
        Text(plan.emoji, style: TextStyle(fontSize: 36.sp)),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(plan.name,
            style: TextStyle(color: FitColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Row(children: [
            _FitBadge(text: plan.level, color: _levelColor),
            SizedBox(width: 6.w),
            _FitBadge(text: plan.category, color: FitColors.blue),
          ]),
          SizedBox(height: 6.h),
          Row(children: [
            Icon(Icons.timer_rounded, color: FitColors.textMuted, size: 12.sp),
            SizedBox(width: 3.w),
            Text('${plan.durationMins} min',
              style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
            SizedBox(width: 10.w),
            Icon(Icons.local_fire_department_rounded, color: FitColors.textMuted, size: 12.sp),
            SizedBox(width: 3.w),
            Text('~${plan.calories} kcal',
              style: TextStyle(color: FitColors.textSecondary, fontSize: 11.sp)),
          ]),
        ])),
        Icon(Icons.chevron_right_rounded, color: FitColors.textMuted, size: 18.sp),
      ]),
    ),
  );
}

class _FitBadge extends StatelessWidget {
  const _FitBadge({required this.text, required this.color});
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
