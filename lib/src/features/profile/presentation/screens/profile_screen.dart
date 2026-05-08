// ignore_for_file: deprecated_member_use, use_if_null_to_convert_nulls_to_bools, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/signin_screen.dart';
import 'package:fit_tracker/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: FitColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: FitColors.textPrimaryDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: FitColors.cardDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: FitColors.borderDark),
                    ),
                    child: const Icon(Icons.settings, color: FitColors.textSecondaryDark, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      FitColors.neonGreen.withOpacity(0.3),
                      FitColors.neonGreen.withOpacity(0.1),
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
                style: const TextStyle(
                  color: FitColors.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 2),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: FitColors.textSecondaryDark.withOpacity(0.7),
                  fontSize: 12,
                ),
              ).animate().fadeIn(delay: 200.ms),
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
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FitColors.red,
                    side: const BorderSide(color: FitColors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: FitColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FitColors.borderDark),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: FitColors.neonGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: FitColors.neonGreen, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: FitColors.textPrimaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: FitColors.textSecondaryDark,
        ),
      ),
    );
  }
}