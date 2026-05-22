import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/gamification/presentation/providers/gamification_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final achievements = ref.watch(achievementsProvider);
    final unlocked = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
        title: Text('Achievements', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, size: 20.sp),
            onPressed: () {
              final unlockedList = achievements.where((a) => a.isUnlocked).toList();
              final text = '🏆 Fit Tracker Achievements\n\n'
                  'Unlocked $unlocked / ${achievements.length} achievements\n\n'
                  '${unlockedList.map((a) => '${a.icon} ${a.title}').join('\n')}\n\n'
                  'Keep pushing! 💪';
              HapticFeedback.lightImpact();
              Share.share(text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20.r),
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [FitColors.neonGreen.withValues(alpha: 0.15), FitColors.cyan.withValues(alpha: 0.08)]),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Text('🏆', style: TextStyle(fontSize: 40.sp)),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$unlocked / ${achievements.length} Unlocked', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w800)),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: unlocked / achievements.length,
                        backgroundColor: (isDark ? FitColors.cardDark : FitColors.cardLight).withValues(alpha: 0.5),
                        valueColor: const AlwaysStoppedAnimation(FitColors.neonGreen),
                        minHeight: 8.h,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: achievements.length,
              itemBuilder: (_, i) {
                final a = achievements[i];
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: a.isUnlocked
                        ? FitColors.neonGreen.withValues(alpha: 0.06)
                        : isDark ? FitColors.cardDark : FitColors.cardLight,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: a.isUnlocked
                          ? FitColors.neonGreen.withValues(alpha: 0.3)
                          : isDark ? FitColors.borderDark : FitColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(a.icon, style: TextStyle(fontSize: 32.sp)),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.title, style: TextStyle(color: a.isUnlocked ? FitColors.neonGreen : isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                            SizedBox(height: 2.h),
                            Text(a.description, style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                            SizedBox(height: 6.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3.r),
                              child: LinearProgressIndicator(
                                value: a.progress,
                                backgroundColor: (isDark ? FitColors.surfaceDark : FitColors.surfaceLight).withValues(alpha: 0.5),
                                valueColor: AlwaysStoppedAnimation(a.isUnlocked ? FitColors.neonGreen : FitColors.amber),
                                minHeight: 4.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (a.isUnlocked)
                        Icon(Icons.check_circle_rounded, color: FitColors.neonGreen, size: 22.sp),
                    ],
                  ),
                ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05);
              },
            ),
          ),
        ],
      ),
    );
  }
}
