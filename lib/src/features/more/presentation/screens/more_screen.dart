// ignore_for_file: unused_import, unused_field, inference_failure_on_function_invocation, prefer_const_constructors, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/settings/presentation/providers/theme_provider.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  static const _features = [
    ('Water Tracking', Icons.water_drop, FitColors.blue),
    ('Sleep Tracking', Icons.nightlight_round, FitColors.purple),
    ('Heart Rate', Icons.favorite, FitColors.red),
    ('Progress Photos', Icons.camera_alt, FitColors.orange),
    ('Achievements', Icons.emoji_events, FitColors.amber),
    ('Export Data', Icons.download, FitColors.neonGreen),
    ('Help & Support', Icons.help_outline, FitColors.textSecondary),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitColors.neonGreen.withValues(alpha: 0.03),
              isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
              isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              Text('More', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              )),
              SizedBox(height: 20.h),

              _QuickAccessGrid(),
              SizedBox(height: 20.h),

              _SectionHeader(title: 'Settings'),
              SizedBox(height: 12.h),

              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'Dark Mode',
                subtitle: themeMode == ThemeMode.dark ? 'On' : 'Off',
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  activeColor: FitColors.neonGreen,
                  onChanged: (v) => ref.read(themeProvider.notifier).setThemeMode(
                    v ? ThemeMode.dark : ThemeMode.light,
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage alerts',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacy',
                subtitle: 'Data & permissions',
                onTap: () {},
              ),
              SizedBox(height: 20.h),

              _SectionHeader(title: 'Support'),
              SizedBox(height: 12.h),

              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'FAQs & guides',
                onTap: () => _launchUrl('https://fittracker.app/help'),
              ),
              _SettingsTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve',
                onTap: () => _showFeedbackDialog(context),
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showFeedbackDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(20.w),
        radius: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send Feedback', style: TextStyle(
              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            )),
            SizedBox(height: 16.h),
            TextField(
              maxLines: 4,
              style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                hintStyle: TextStyle(color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight),
                filled: true,
                fillColor: isDark ? FitColors.surfaceDark : FitColors.surfaceLight,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FitColors.neonGreen,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Send', style: TextStyle(
                  color: FitColors.background,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        content: GlassContainer(
          opacity: isDark ? 0.06 : 0.2,
          padding: EdgeInsets.all(20.r),
          radius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: FitColors.neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.fitness_center, color: FitColors.neonGreen),
                  ),
                  SizedBox(width: 12.w),
                  Text('Fit Tracker', style: TextStyle(
                    color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                    fontSize: 18.sp, fontWeight: FontWeight.bold,
                  )),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'Version 1.0.0\n\nTrack your fitness journey with step counting, workouts, nutrition, sleep, and more.\n\n© 2024 Fit Tracker',
                style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: TextStyle(color: FitColors.neonGreen)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      ('Water', Icons.water_drop, FitColors.blue),
      ('Sleep', Icons.nightlight_round, FitColors.purple),
      ('Heart Rate', Icons.favorite, FitColors.red),
      ('Photos', Icons.camera_alt, FitColors.orange),
      ('Achievements', Icons.emoji_events, FitColors.amber),
      ('Export', Icons.download, FitColors.neonGreen),
    ];

    return GridView.builder(
      cacheExtent: 500,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) {
        final (label, icon, color) = features[i];
        return _QuickAccessTile(key: ValueKey('qa_$label'), label: label, icon: icon, color: color);
      },
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _QuickAccessTile({super.key, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.zero,
        radius: 16,
        tint: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 6.h),
            Text(label, style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(title, style: TextStyle(
      color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
    ));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GlassCard(
        opacity: isDark ? 0.06 : 0.2,
        radius: 12,
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: FitColors.neonGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: FitColors.neonGreen, size: 20.sp),
          ),
          title: Text(title, style: TextStyle(
            color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          )),
          subtitle: Text(subtitle, style: TextStyle(
            color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
            fontSize: 12.sp,
          )),
          trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight),
        ),
      ),
    );
  }
}
