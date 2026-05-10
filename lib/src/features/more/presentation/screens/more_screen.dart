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
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            Text('More', style: TextStyle(
              color: FitColors.textPrimary,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            )),
            SizedBox(height: 20.h),

            // Quick Access Grid
            _QuickAccessGrid(),
            SizedBox(height: 20.h),

            // Settings Section
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

            // Support Section
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
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _showFeedbackDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: FitColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send Feedback', style: TextStyle(
              color: FitColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            )),
            SizedBox(height: 16.h),
            TextField(
              maxLines: 4,
              style: TextStyle(color: FitColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                hintStyle: TextStyle(color: FitColors.textMuted),
                filled: true,
                fillColor: FitColors.background,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: FitColors.border),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FitColors.card,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: FitColors.neonGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.fitness_center, color: FitColors.neonGreen),
            ),
            SizedBox(width: 12.w),
            Text('Fit Tracker', style: TextStyle(color: FitColors.textPrimary)),
          ],
        ),
        content: Text(
          'Version 1.0.0\n\nTrack your fitness journey with step counting, workouts, nutrition, sleep, and more.\n\n© 2024 Fit Tracker',
          style: TextStyle(color: FitColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: FitColors.neonGreen)),
          ),
        ],
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {},
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: TextStyle(
    color: FitColors.textPrimary,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
  ));
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
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      tileColor: FitColors.card,
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: FitColors.neonGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: FitColors.neonGreen, size: 20.sp),
      ),
      title: Text(title, style: TextStyle(
        color: FitColors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      )),
      subtitle: Text(subtitle, style: TextStyle(
        color: FitColors.textSecondary,
        fontSize: 12.sp,
      )),
      trailing: trailing ?? Icon(Icons.chevron_right, color: FitColors.textMuted),
    ),
  );
}