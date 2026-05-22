import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class StepsSkeletonCard extends StatelessWidget {
  const StepsSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 24,
      padding: EdgeInsets.all(20.r),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 14, width: 140.w, decoration: BoxDecoration(color: FitColors.border, borderRadius: BorderRadius.circular(4))),
        SizedBox(height: 16.h),
        Row(children: [
          Container(width: 80.w, height: 80.w, decoration: const BoxDecoration(shape: BoxShape.circle, color: FitColors.border)),
          SizedBox(width: 20.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 12, width: 100.w, decoration: BoxDecoration(color: FitColors.border, borderRadius: BorderRadius.circular(4))),
            SizedBox(height: 8.h),
            Container(height: 10, width: 60.w, decoration: BoxDecoration(color: FitColors.border, borderRadius: BorderRadius.circular(4))),
          ]),
        ]),
      ]),
    );
  }
}

class ActivitySkeleton extends StatelessWidget {
  const ActivitySkeleton({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 20,
      padding: EdgeInsets.all(16.r),
    ).animate(onPlay: (c) => c.repeat())
      .shimmer(duration: 1200.ms, color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.1));
  }
}

class ActivityError extends StatelessWidget {
  const ActivityError({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 20,
      padding: EdgeInsets.all(16.r),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline_rounded, color: FitColors.orange, size: 32.sp),
          SizedBox(height: 8.h),
          Text('Something went wrong', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp)),
        ]),
      ),
    );
  }
}
