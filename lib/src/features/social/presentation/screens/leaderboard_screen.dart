import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/gamification/presentation/providers/gamification_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gs = ref.watch(gamificationProvider);

    final userEntry = _LeaderEntry(
      name: 'You',
      xp: gs.totalXp,
      streak: gs.streak.currentStreak,
      workouts: gs.workoutsCompleted,
      isUser: true,
    );

    final friends = _mockFriends;
    final all = [userEntry, ...friends];
    all.sort((a, b) => b.xp.compareTo(a.xp));

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
        title: Text('Leaderboard', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 18.sp, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20.r),
        itemCount: all.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: GlassContainer(
                opacity: isDark ? 0.06 : 0.2,
                padding: EdgeInsets.all(16.r),
                radius: 16,
                tint: FitColors.neonGreen,
                child: Row(
                  children: [
                    Container(
                      width: 44.w, height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: FitColors.neonGreen.withValues(alpha: 0.15),
                      ),
                      child: Center(child: Text(userEntry.rankIcon, style: TextStyle(fontSize: 24.sp))),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Ranking', style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                          Text('#${all.indexOf(userEntry) + 1} of ${all.length}  •  ${gs.totalXp} XP  •  ${gs.streak.currentStreak}-day streak', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 11.sp)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: FitColors.neonGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text('#${all.indexOf(userEntry) + 1}', style: TextStyle(color: FitColors.neonGreen, fontSize: 14.sp, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: -0.05);
          }

          final entry = all[i - 1];
          final rank = i;
          final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '$rank.';

          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: entry.isUser
                  ? FitColors.neonGreen.withValues(alpha: 0.06)
                  : isDark ? FitColors.cardDark : FitColors.cardLight,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: entry.isUser
                    ? FitColors.neonGreen.withValues(alpha: 0.3)
                    : isDark ? FitColors.borderDark : FitColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32.w,
                  child: Text(medal, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 36.w, height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.isUser ? FitColors.neonGreen.withValues(alpha: 0.15) : (isDark ? FitColors.surfaceDark : FitColors.surfaceLight),
                  ),
                  child: Center(child: Text(entry.avatar, style: TextStyle(fontSize: 18.sp))),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name, style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 14.sp, fontWeight: FontWeight.w700)),
                      Text('${entry.xp} XP  •  ${entry.streak}-day streak  •  ${entry.workouts} workouts', style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, fontSize: 10.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (i * 40).ms).slideX(begin: 0.03);
        },
      ),
    );
  }
}

class _LeaderEntry {
  final String name;
  final int xp;
  final int streak;
  final int workouts;
  final bool isUser;

  const _LeaderEntry({required this.name, required this.xp, required this.streak, required this.workouts, this.isUser = false});

  String get avatar {
    final n = name.toLowerCase();
    if (n.contains('alex')) return '🏃';
    if (n.contains('sam')) return '🧘';
    if (n.contains('jordan')) return '🏋️';
    if (n.contains('taylor')) return '🚴';
    if (n.contains('morgan')) return '🤸';
    return '💪';
  }

  String get rankIcon => isUser ? '👑' : avatar;
}

final _mockFriends = [
  const _LeaderEntry(name: 'Alex', xp: 2450, streak: 12, workouts: 48),
  const _LeaderEntry(name: 'Sam', xp: 2100, streak: 8, workouts: 35),
  const _LeaderEntry(name: 'Jordan', xp: 1800, streak: 15, workouts: 60),
  const _LeaderEntry(name: 'Taylor', xp: 1500, streak: 5, workouts: 28),
  const _LeaderEntry(name: 'Morgan', xp: 1200, streak: 3, workouts: 20),
];
