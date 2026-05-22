import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/profile_screen.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? 'Athlete';
    final now = DateTime.now();
    final dateStr = '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${_getGreeting()}, $userName',
                style: TextStyle(
                  color: FitColors.textPrimary,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                dateStr,
                style: TextStyle(
                  color: FitColors.neonGreen,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]),
            GestureDetector(
              onTap: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      FitColors.neonGreen.withValues(alpha: 0.8),
                      FitColors.neonGreen.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: FitColors.neonGreen.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: FitColors.neonGreen.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: -4),
                  ],
                ),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 24.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "Let's crush your goals today",
          style: TextStyle(
            color: FitColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _weekday(int day) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
  String _month(int m) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}
