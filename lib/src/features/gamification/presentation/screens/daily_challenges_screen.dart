import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fit_tracker/src/features/gamification/data/models/gamification_models.dart';

class DailyChallengesScreen extends ConsumerWidget {
  const DailyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gs = ref.watch(gamificationProvider);
    final completed = gs.challenges.where((c) => c.isCompleted).length;

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
        title: Text('Daily Challenges', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [FitColors.orange.withValues(alpha: 0.15), FitColors.amber.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Text('📋', style: TextStyle(fontSize: 36.sp)),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$completed / ${gs.challenges.length} Done', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4.h),
                    Text('${gs.streak.currentStreak} day streak', style: TextStyle(color: FitColors.orange, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          ...gs.challenges.map((c) => _ChallengeCard(c: c, isDark: isDark)),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final DailyChallenge c;
  final bool isDark;

  const _ChallengeCard({required this.c, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: c.isCompleted
            ? FitColors.neonGreen.withValues(alpha: 0.06)
            : isDark ? FitColors.cardDark : FitColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: c.isCompleted
              ? FitColors.neonGreen.withValues(alpha: 0.3)
              : isDark ? FitColors.borderDark : FitColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Text(c.icon, style: TextStyle(fontSize: 36.sp)),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 2.h),
                Text(c.description, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: FitColors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: FitColors.amber),
                    SizedBox(width: 2.w),
                    Text('+${c.xpReward}', style: const TextStyle(color: FitColors.amber, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              if (c.isCompleted)
                const Icon(Icons.check_circle_rounded, color: FitColors.neonGreen, size: 22),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }
}
