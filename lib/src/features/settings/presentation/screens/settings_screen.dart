// ignore_for_file: deprecated_member_use, prefer_const_constructors, unnecessary_import, inference_failure_on_function_invocation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/imports/core_imports.dart';
import 'package:fit_tracker/src/features/settings/presentation/providers/theme_provider.dart';
import 'package:fit_tracker/src/features/settings/data/repositories/settings_repository.dart';

final settingsRepoProvider = Provider<SettingsRepository>((ref) => SettingsRepository());

final notificationSettingsProvider = NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(() => NotificationSettingsNotifier());

class NotificationSettings {
  final bool workoutReminders;
  final bool dailyGoals;
  final bool motivationNotifications;
  final int reminderIntervalHours;

  const NotificationSettings({
    this.workoutReminders = true,
    this.dailyGoals = true,
    this.motivationNotifications = true,
    this.reminderIntervalHours = 4,
  });

  NotificationSettings copyWith({
    bool? workoutReminders,
    bool? dailyGoals,
    bool? motivationNotifications,
    int? reminderIntervalHours,
  }) {
    return NotificationSettings(
      workoutReminders: workoutReminders ?? this.workoutReminders,
      dailyGoals: dailyGoals ?? this.dailyGoals,
      motivationNotifications: motivationNotifications ?? this.motivationNotifications,
      reminderIntervalHours: reminderIntervalHours ?? this.reminderIntervalHours,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    final repository = ref.read(settingsRepoProvider);
    _loadSettings(repository);
    return const NotificationSettings();
  }

  Future<void> _loadSettings(SettingsRepository repository) async {
    final settings = await repository.getNotificationSettings();
    state = settings;
  }

  Future<void> setWorkoutReminders(bool value) async {
    final repository = ref.read(settingsRepoProvider);
    state = state.copyWith(workoutReminders: value);
    await repository.saveNotificationSettings(state);
  }

  Future<void> setDailyGoals(bool value) async {
    final repository = ref.read(settingsRepoProvider);
    state = state.copyWith(dailyGoals: value);
    await repository.saveNotificationSettings(state);
  }

  Future<void> setMotivationNotifications(bool value) async {
    final repository = ref.read(settingsRepoProvider);
    state = state.copyWith(motivationNotifications: value);
    await repository.saveNotificationSettings(state);
  }

  Future<void> setReminderInterval(int hours) async {
    final repository = ref.read(settingsRepoProvider);
    state = state.copyWith(reminderIntervalHours: hours);
    await repository.saveNotificationSettings(state);
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final currentLocale = context.locale;

    return Scaffold(
      backgroundColor: FitColors.background,
      appBar: AppBar(
        backgroundColor: FitColors.surface,
        title: Text('Settings', style: TextStyle(color: FitColors.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: FitColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          _SectionHeader(title: 'Appearance'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: _getThemeModeText(themeMode),
            trailing: _ThemeModeSelector(currentMode: themeMode),
          ),
          SizedBox(height: 24.h),
          _SectionHeader(title: 'Notifications'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.fitness_center_rounded,
            title: 'Workout Reminders',
            subtitle: 'Get reminded to exercise',
            trailing: Switch(
              value: notificationSettings.workoutReminders,
              onChanged: (v) => ref.read(notificationSettingsProvider.notifier).setWorkoutReminders(v),
              activeColor: FitColors.neonGreen,
            ),
          ),
          _SettingsTile(
            icon: Icons.flag_rounded,
            title: 'Daily Goals',
            subtitle: 'Track your daily progress',
            trailing: Switch(
              value: notificationSettings.dailyGoals,
              onChanged: (v) => ref.read(notificationSettingsProvider.notifier).setDailyGoals(v),
              activeColor: FitColors.neonGreen,
            ),
          ),
          _SettingsTile(
            icon: Icons.celebration_rounded,
            title: 'Motivation',
            subtitle: 'Encouraging notifications',
            trailing: Switch(
              value: notificationSettings.motivationNotifications,
              onChanged: (v) => ref.read(notificationSettingsProvider.notifier).setMotivationNotifications(v),
              activeColor: FitColors.neonGreen,
            ),
          ),
          _SettingsTile(
            icon: Icons.timer_rounded,
            title: 'Reminder Interval',
            subtitle: '${notificationSettings.reminderIntervalHours} hours',
            onTap: () => _showIntervalPicker(context, ref, notificationSettings.reminderIntervalHours),
          ),
          SizedBox(height: 24.h),
          _SectionHeader(title: 'Language'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: currentLocale.languageCode.toUpperCase(),
            onTap: () => _showLanguagePicker(context),
          ),
          SizedBox(height: 24.h),
          _SectionHeader(title: 'About'),
          SizedBox(height: 8.h),
          _SettingsTile(
            icon: Icons.info_rounded,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.description_rounded,
            title: 'Terms of Service',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showIntervalPicker(BuildContext context, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FitColors.surface,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text('Reminder Interval', style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
          ...[2, 4, 6, 8].map((h) => ListTile(
            title: Text('$h hours', style: TextStyle(color: FitColors.textPrimary)),
            trailing: current == h ? Icon(Icons.check, color: FitColors.neonGreen) : null,
            onTap: () {
              ref.read(notificationSettingsProvider.notifier).setReminderInterval(h);
              Navigator.pop(context);
            },
          )),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: FitColors.surface,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text('Select Language', style: TextStyle(color: FitColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.w600)),
          ),
          ListTile(
            title: Text('English', style: TextStyle(color: FitColors.textPrimary)),
            trailing: context.locale.languageCode == 'en' ? Icon(Icons.check, color: FitColors.neonGreen) : null,
            onTap: () {
              context.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Arabic', style: TextStyle(color: FitColors.textPrimary)),
            trailing: context.locale.languageCode == 'ar' ? Icon(Icons.check, color: FitColors.neonGreen) : null,
            onTap: () {
              context.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: FitColors.textSecondary,
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    decoration: BoxDecoration(
      color: FitColors.card,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: FitColors.border),
    ),
    child: ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: FitColors.neonGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: FitColors.neonGreen, size: 20.sp),
      ),
      title: Text(title, style: TextStyle(color: FitColors.textPrimary, fontSize: 14.sp, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: FitColors.textSecondary, fontSize: 12.sp)) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: FitColors.textMuted) : null),
      onTap: onTap,
    ),
  );
}

class _ThemeModeSelector extends ConsumerWidget {
  final ThemeMode currentMode;
  const _ThemeModeSelector({required this.currentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<ThemeMode>(
      initialValue: currentMode,
      onSelected: (mode) => ref.read(themeProvider.notifier).setThemeMode(mode),
      color: FitColors.card,
      itemBuilder: (context) => [
        PopupMenuItem(value: ThemeMode.system, child: Text('System', style: TextStyle(color: FitColors.textPrimary))),
        PopupMenuItem(value: ThemeMode.light, child: Text('Light', style: TextStyle(color: FitColors.textPrimary))),
        PopupMenuItem(value: ThemeMode.dark, child: Text('Dark', style: TextStyle(color: FitColors.textPrimary))),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: FitColors.neonGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              currentMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : currentMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
              color: FitColors.neonGreen,
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
            Icon(Icons.arrow_drop_down, color: FitColors.neonGreen, size: 16.sp),
          ],
        ),
      ),
    );
  }
}