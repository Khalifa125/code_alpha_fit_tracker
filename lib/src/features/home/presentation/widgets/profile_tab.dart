import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/signin_screen.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/history_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/bmi_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  static const _menuItems = [
    (Icons.flag_rounded, 'My Goals', FitColors.neonGreen),
    (Icons.straighten_rounded, 'My Measurements', FitColors.blue),
    (Icons.emoji_events_rounded, 'Achievements', FitColors.amber),
    (Icons.history_rounded, 'Activity History', FitColors.orange),
    (Icons.settings_rounded, 'Settings', FitColors.purple),
    (Icons.help_outline_rounded, 'Help & Support', FitColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(fitnessProfileProvider);
    final authState = ref.watch(authStateProvider);
    final userName = authState.user?.name ?? 'Athlete';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userEmail = authState.user?.email ?? '';

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 80.h),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Profile', style: TextStyle(color: FitColors.textPrimary, fontSize: 22.sp, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
                child: Icon(Icons.settings_rounded, color: FitColors.textSecondary, size: 22.sp),
              ),
            ]),
            SizedBox(height: 24.h),
            Center(child: Column(children: [
              Container(
                width: 80.w, height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: FitColors.neonGreen, width: 2.5),
                  color: FitColors.card,
                ),
                child: Icon(Icons.person_rounded, color: FitColors.neonGreen, size: 40.sp),
              ),
              SizedBox(height: 12.h),
              Text(userName, style: TextStyle(color: FitColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text(userEmail, style: TextStyle(color: FitColors.neonGreen, fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ])),
            SizedBox(height: 20.h),
            GlassContainer(
              opacity: isDark ? 0.06 : 0.2,
              radius: 20,
              padding: EdgeInsets.all(16.r),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                const _ProfileStat(label: 'Workouts', value: '48', color: FitColors.neonGreen),
                Container(width: 0.5, height: 36.h, color: FitColors.border),
                const _ProfileStat(label: 'Days Active', value: '32', color: FitColors.blue),
                Container(width: 0.5, height: 36.h, color: FitColors.border),
                const _ProfileStat(label: 'Goals Achieved', value: '12', color: FitColors.orange),
              ]),
            ),
            SizedBox(height: 20.h),
            profileAsync.maybeWhen(
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return GlassContainer(
                  opacity: isDark ? 0.06 : 0.2,
                  radius: 20,
                  padding: EdgeInsets.all(16.r),
                  margin: EdgeInsets.only(bottom: 20.h),
                  child: Row(children: [
                    Expanded(child: _ProfileStat(label: 'Height', value: '${profile.heightCm.toInt()} cm', color: FitColors.purple)),
                    Container(width: 0.5, height: 36.h, color: FitColors.border),
                    Expanded(child: _ProfileStat(label: 'Weight', value: '${profile.weightKg.toInt()} kg', color: FitColors.pink)),
                    Container(width: 0.5, height: 36.h, color: FitColors.border),
                    Expanded(child: _ProfileStat(label: 'BMI', value: profile.bmi.toStringAsFixed(1), color: FitColors.neonGreen)),
                  ]),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            ...List.generate(_menuItems.length, (i) {
              final (icon, label, color) = _menuItems[i];
              return GlassContainer(
                opacity: isDark ? 0.06 : 0.2,
                radius: 14,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                    child: Icon(icon, color: color, size: 18.sp),
                  ),
                  title: Text(label, style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  trailing: Icon(Icons.chevron_right_rounded, color: FitColors.textMuted, size: 18.sp),
                  onTap: () {
                    if (label == 'Activity History') {
                      Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const HistoryScreen()));
                    } else if (label == 'My Measurements') {
                      Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const BmiScreen()));
                    }
                  },
                ),
              ).animate(delay: (i * 40).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
            }),
            SizedBox(height: 20.h),
            if (!authState.isLoggedIn)
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.neonGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sign In / Sign Up', style: TextStyle(color: FitColors.background, fontWeight: FontWeight.w700)),
                ),
              )
            else
              SizedBox(
                width: double.infinity, height: 50,
                child: OutlinedButton(
                  onPressed: () async => ref.read(authStateProvider.notifier).logout(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: FitColors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Sign Out', style: TextStyle(color: FitColors.red, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 16.sp, fontWeight: FontWeight.w800)),
    SizedBox(height: 2.h),
    Text(label, style: TextStyle(color: FitColors.textSecondary, fontSize: 10.sp)),
  ]);
}
