// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/fitness/domain/entities/fitness_entities.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

// ─── Muscle Group Indicator ─────────────────────────────────────────────────

class MuscleGroupIndicator extends StatelessWidget {
  const MuscleGroupIndicator({
    super.key,
    required this.muscles,
    this.maxDisplay = 4,
  });

  final List<String> muscles;
  final int maxDisplay;

  static const _muscleIcons = {
    'Chest': Icons.fitness_center,
    'Back': Icons.arrow_back,
    'Legs': Icons.directions_walk,
    'Core': Icons.straighten,
    'Shoulders': Icons.accessibility_new,
    'Arms': Icons.pan_tool,
    'Full Body': Icons.accessibility,
    'Cardio': Icons.favorite,
    'Glutes': Icons.flight_takeoff,
    'Quadriceps': Icons.sports_kabaddi,
    'Hamstrings': Icons.sports_handball,
    'Calves': Icons.arrow_upward,
    'Obliques': Icons.tune,
    'Hips': Icons.camera_alt,
    'Neck': Icons.face,
    'Chest & Shoulders': Icons.self_improvement,
  };

  @override
  Widget build(BuildContext context) {
    final display = muscles.take(maxDisplay).toList();
    final remaining = muscles.length - display.length;
    return Row(
      children: [
        ...display.map((m) => Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: Tooltip(
            message: m,
            child: Container(
              width: 26.w,
              height: 26.w,
              decoration: BoxDecoration(
                color: FitColors.neonGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                _muscleIcons[m] ?? Icons.circle_outlined,
                color: FitColors.neonGreen,
                size: 13.sp,
              ),
            ),
          ),
        )),
        if (remaining > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: FitColors.neonGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              '+$remaining',
              style: TextStyle(color: FitColors.neonGreen, fontSize: 8.sp, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

// ─── Difficulty Indicator ──────────────────────────────────────────────────

class DifficultyIndicator extends StatelessWidget {
  const DifficultyIndicator({
    super.key,
    required this.level,
    this.compact = false,
  });

  final String level;
  final bool compact;

  Color get color => switch (level) {
    'Beginner' || 'Easy' || 'Low' => FitColors.neonGreen,
    'Intermediate' || 'Medium' || 'Moderate' => FitColors.orange,
    'Advanced' || 'Hard' || 'High' => FitColors.pink,
    _ => FitColors.cyan,
  };

  String get label => switch (level) {
    'Beginner' || 'Easy' || 'Low' => 'Beginner',
    'Intermediate' || 'Medium' || 'Moderate' => 'Intermediate',
    'Advanced' || 'Hard' || 'High' => 'Advanced',
    _ => level,
  };

  int get filledBars => switch (level) {
    'Beginner' || 'Easy' || 'Low' => 1,
    'Intermediate' || 'Medium' || 'Moderate' => 2,
    'Advanced' || 'Hard' || 'High' => 3,
    _ => 2,
  };

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(label, style: TextStyle(color: color, fontSize: 9.sp, fontWeight: FontWeight.w700)),
      );
    }
    return Row(
      children: [
        ...List.generate(3, (i) => Container(
          width: 18.w,
          height: 5.h,
          margin: EdgeInsets.only(right: 3.w),
          decoration: BoxDecoration(
            color: i < filledBars ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3.r),
          ),
        )),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Equipment List ────────────────────────────────────────────────────────

class EquipmentList extends StatelessWidget {
  const EquipmentList({
    super.key,
    required this.equipment,
  });

  final List<String> equipment;

  static const _equipmentIcons = {
    'Yoga mat': Icons.bed,
    'Dumbbells': Icons.fitness_center,
    'Dumbbell': Icons.fitness_center,
    'Pull-up bar': Icons.vertical_align_top,
    'Bench': Icons.chair,
    'Chair': Icons.chair,
    'Wall': Icons.wallpaper,
    'Resistance band': Icons.attractions,
    'Box': Icons.inventory_2,
    'Towel': Icons.bathroom,
    'Blanket': Icons.bed,
    'Water bottle': Icons.water_drop,
    'Step': Icons.stairs,
    'Doorway': Icons.door_front_door,
  };

  @override
  Widget build(BuildContext context) {
    if (equipment.isEmpty || (equipment.length == 1 && equipment.first == '')) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline, size: 12.sp, color: FitColors.neonGreen),
          SizedBox(width: 4.w),
          Text('No equipment needed', style: TextStyle(color: FitColors.neonGreen, fontSize: 10.sp, fontWeight: FontWeight.w500)),
        ],
      );
    }
    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: equipment.where((e) => e.isNotEmpty).map((e) => Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: FitColors.neonGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_equipmentIcons[e] ?? Icons.circle_outlined, size: 10.sp, color: FitColors.neonGreen),
            SizedBox(width: 3.w),
            Text(e, style: TextStyle(color: FitColors.neonGreen, fontSize: 9.sp, fontWeight: FontWeight.w600)),
          ],
        ),
      )).toList(),
    );
  }
}

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
          color: (Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight),
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
              color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            unit,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 9.sp),
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
          style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 12.sp)),
        Row(children: [
          Text(current.toStringAsFixed(0),
            style: TextStyle(color: color, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          Text(' / ${goal.toStringAsFixed(0)} $unit',
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 11.sp)),
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
            backgroundColor: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight),
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
        color: (Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight)),
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
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight), fontWeight: FontWeight.w700, fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              '${activity.durationMinutes} min  •  ${activity.steps} steps',
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 11.sp),
            ),
            if (activity.notes.isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                activity.notes,
                style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 10.sp),
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
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), fontSize: 10.sp),
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
        style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight), fontSize: 16.sp, fontWeight: FontWeight.w700)),
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
      color: (Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight)),
    ),
    child: Column(children: [
      Text(emoji, style: TextStyle(fontSize: 36.sp)),
      SizedBox(height: 10.h),
      Text(message,
        textAlign: TextAlign.center,
        style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 13.sp, height: 1.5)),
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
        color: (Theme.of(context).brightness == Brightness.dark ? FitColors.cardDark : FitColors.cardLight),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.borderDark : FitColors.borderLight)),
      ),
      child: Row(children: [
        Text(plan.emoji, style: TextStyle(fontSize: 36.sp)),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(plan.name,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight), fontSize: 15.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Row(children: [
            _FitBadge(text: plan.level, color: _levelColor),
            SizedBox(width: 6.w),
            _FitBadge(text: plan.category, color: FitColors.blue),
          ]),
          SizedBox(height: 6.h),
          Row(children: [
            Icon(Icons.timer_rounded, color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 12.sp),
            SizedBox(width: 3.w),
            Text('${plan.durationMins} min',
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 11.sp)),
            SizedBox(width: 10.w),
            Icon(Icons.local_fire_department_rounded, color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 12.sp),
            SizedBox(width: 3.w),
            Text('~${plan.calories} kcal',
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight), fontSize: 11.sp)),
          ]),
        ])),
        Icon(Icons.chevron_right_rounded, color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.6), size: 18.sp),
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
