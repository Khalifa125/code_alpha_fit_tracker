import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/gamification/data/models/gamification_models.dart';
import 'package:fit_tracker/src/features/gamification/presentation/providers/gamification_provider.dart';

class XpBar extends ConsumerWidget {
  final double height;

  const XpBar({super.key, this.height = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gs = ref.watch(gamificationProvider);
    final xpLevel = XpLevel.fromTotalXp(gs.totalXp);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: height.h,
      decoration: BoxDecoration(
        color: (isDark ? FitColors.cardDark : FitColors.cardLight).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(height.h / 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: FitColors.amber, size: 14),
          SizedBox(width: 4.w),
          Text('Lv.${xpLevel.level}', style: const TextStyle(color: FitColors.amber, fontSize: 11, fontWeight: FontWeight.w800)),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: xpLevel.progress,
                backgroundColor: (isDark ? FitColors.surfaceDark : FitColors.surfaceLight),
                valueColor: const AlwaysStoppedAnimation(FitColors.neonGreen),
                minHeight: 6.h,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Text('${xpLevel.totalXp} XP', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 9.sp)),
        ],
      ),
    );
  }
}

class StreakIndicator extends StatelessWidget {
  final int streak;

  const StreakIndicator({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department_rounded,
          color: streak >= 7 ? FitColors.orange : streak >= 3 ? FitColors.amber : FitColors.neonGreen,
          size: 18,
        ),
        SizedBox(width: 3.w),
        Text('$streak day${streak == 1 ? '' : 's'}', style: TextStyle(
          color: streak >= 7 ? FitColors.orange : streak >= 3 ? FitColors.amber : FitColors.neonGreen,
          fontSize: 12, fontWeight: FontWeight.w700,
        )),
      ],
    );
  }
}
