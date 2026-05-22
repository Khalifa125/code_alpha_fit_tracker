import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: GlassContainer(
      radius: 16,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      tint: color,
      border: BorderSide(color: color.withValues(alpha: 0.15)),
      shadow: [
        BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: -2)],
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    ),
  ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w700)),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: TextStyle(color: FitColors.neonGreen, fontSize: 13.sp, fontWeight: FontWeight.w600)),
        ),
    ],
  );
}

class FitEmptyCard extends StatelessWidget {
  const FitEmptyCard({super.key, required this.emoji, required this.message});

  final String emoji;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      radius: 16,
      padding: EdgeInsets.symmetric(vertical: 32.h),
      child: Column(children: [
        Text(emoji, style: TextStyle(fontSize: 36.sp)),
        SizedBox(height: 10.h),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 13.sp, height: 1.5)),
      ]),
    );
  }
}
