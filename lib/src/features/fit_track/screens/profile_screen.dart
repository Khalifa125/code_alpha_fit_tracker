// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/fit_track/providers/auth_provider.dart';
import 'package:fit_tracker/src/features/fit_track/providers/workout_provider.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: (Theme.of(context).brightness == Brightness.dark ? FitColors.backgroundDark : FitColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: FitColors.neonGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: FitColors.neonGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authState.user?.name ?? 'Athlete',
                    style: TextStyle(
                      color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authState.user?.email ?? '',
                    style: TextStyle(
                      color: (Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Statistics', context),
            const SizedBox(height: 16),
            _buildStatCard(context, 
              icon: Icons.fitness_center,
              label: 'Total Workouts',
              value: '${progress.totalWorkouts}',
              color: FitColors.neonGreen,
            ),
            const SizedBox(height: 12),
            _buildStatCard(context, 
              icon: Icons.local_fire_department,
              label: 'Current Streak',
              value: '${progress.currentStreak} days',
              color: FitColors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatCard(context, 
              icon: Icons.timer,
              label: 'Total Minutes',
              value: '${progress.totalMinutes} min',
              color: FitColors.blue,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Account', context),
            const SizedBox(height: 16),
            _buildMenuItem(context, 
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () {},
            ),
            _buildMenuItem(context, 
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {},
            ),
            _buildMenuItem(context, 
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FitColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              value,
                style: TextStyle(
                  color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
  }
}
  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          onTap: onTap,
          tileColor: FitColors.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(icon, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
          title: Text(
            label,
            style: TextStyle(
              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
          ),
        ),
      );
  }
