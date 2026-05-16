// ignore_for_file: deprecated_member_use, use_if_null_to_convert_nulls_to_bools, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/signin_screen.dart';
import 'package:fit_tracker/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitColors.neonGreen.withValues(alpha: 0.03),
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    GlassContainer(
                      opacity: isDark ? 0.06 : 0.2,
                      radius: 8,
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.settings, color: FitColors.textSecondaryDark, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  opacity: isDark ? 0.06 : 0.2,
                  padding: const EdgeInsets.all(24),
                  radius: 20,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              FitColors.neonGreen.withValues(alpha: 0.3),
                              FitColors.neonGreen.withValues(alpha: 0.1),
                            ],
                          ),
                          border: Border.all(
                            color: FitColors.neonGreen,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: FitColors.neonGreen,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().scale(),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? 'User',
                        style: TextStyle(
                          color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
                _ProfileMenuItem(
                  icon: Icons.flag_outlined,
                  title: 'My Goals',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1, end: 0),
                _ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
                _ProfileMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1, end: 0),
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),
                const SizedBox(height: 20),
                GlassCard(
                  opacity: isDark ? 0.06 : 0.2,
                  radius: 16,
                  padding: EdgeInsets.zero,
                  onTap: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: FitColors.red),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(
                            color: FitColors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      opacity: isDark ? 0.06 : 0.2,
      radius: 16,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: FitColors.neonGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: FitColors.neonGreen, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
        ),
      ),
    );
  }
}
