// ignore_for_file: deprecated_member_use, inference_failure_on_function_return_type, inference_failure_on_function_invocation, unused_import, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fit_tracker/src/theme/app_spacing.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/heart_rate/data/models/heart_rate_models.dart';
import 'package:fit_tracker/src/features/heart_rate/presentation/providers/heart_rate_provider.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class HeartRateScreen extends ConsumerWidget {
  const HeartRateScreen({super.key});

  static const _activityTypes = ['Resting', 'Walking', 'Running', 'Workout', 'Sleep'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(heartRateProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitColors.red.withValues(alpha: 0.03),
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: RepaintBoundary(child: ListView(
            padding: EdgeInsets.all(20.w),
            children: [
              Text('Heart Rate', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              )),
              SizedBox(height: 20.h),

              _DateSelector(
                selectedDate: state.selectedDate,
                onTap: () => _selectDate(context, ref),
              ),
              SizedBox(height: 20.h),

              _HeartRateCard(state: state),
              SizedBox(height: 20.h),

              if (state.stats != null) _HeartRateStats(stats: state.stats!),
              SizedBox(height: 20.h),

              _AddHeartRateButton(
                onAdd: (bpm, activity) => ref.read(heartRateProvider.notifier).addHeartRate(bpm, activity: activity),
              ),
              SizedBox(height: 20.h),

              if (state.entries.isNotEmpty) ...[
                Text('Recent Readings', style: TextStyle(
                  color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                )),
                SizedBox(height: 12.h),
                ...state.entries.take(10).map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _HeartRateTile(
                    entry: entry,
                    onDelete: () => ref.read(heartRateProvider.notifier).deleteEntry(entry.id),
                  ),
                )),
              ],

              SizedBox(height: 20.h),
              _HeartRateZones(),
            ],
          )),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: ref.read(heartRateProvider).selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: FitColors.red,
            surface: FitColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) ref.read(heartRateProvider.notifier).selectDate(date);
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const _DateSelector({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        radius: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: FitColors.red, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              isToday ? 'Today' : DateFormat('MMM dd, yyyy').format(selectedDate),
              style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_drop_down, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
          ],
        ),
      ),
    );
  }
}

class _HeartRateCard extends StatelessWidget {
  final HeartRateState state;

  const _HeartRateCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bpm = state.latestBpm ?? '--';
    final zone = state.entries.isNotEmpty ? state.entries.first.zone : '-';

    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(24.r),
      radius: 24,
      tint: FitColors.red,
      child: Column(
        children: [
          Icon(Icons.favorite, color: FitColors.red, size: 48.sp),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$bpm', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 48.sp,
                fontWeight: FontWeight.w800,
              )),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(' BPM', style: TextStyle(
                  color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                  fontSize: 16.sp,
                )),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getZoneColor(zone).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(zone, style: TextStyle(
              color: _getZoneColor(zone),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            )),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Color _getZoneColor(String zone) {
    switch (zone) {
      case 'Rest': return const Color(0xFF6B7280);
      case 'Resting': return FitColors.neonGreen;
      case 'Light': return FitColors.blue;
      case 'Moderate': return FitColors.amber;
      case 'Hard': return FitColors.orange;
      case 'Max': return FitColors.red;
      default: return const Color(0xFF6B7280);
    }
  }
}

class _HeartRateStats extends StatelessWidget {
  final HeartRateStats stats;

  const _HeartRateStats({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(16.r),
      radius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Min', value: '${stats.min}', color: FitColors.neonGreen),
          Container(width: 1, height: 40.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
          _StatItem(label: 'Avg', value: stats.avg.toStringAsFixed(0), color: FitColors.amber),
          Container(width: 1, height: 40.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
          _StatItem(label: 'Max', value: '${stats.max}', color: FitColors.red),
          Container(width: 1, height: 40.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
          _StatItem(label: 'Readings', value: '${stats.count}', color: FitColors.blue),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: TextStyle(
        color: color,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      )),
      Text(label, style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
        fontSize: 11.sp,
      )),
    ],
  );
}

class _AddHeartRateButton extends StatelessWidget {
  final Function(int bpm, String? activity) onAdd;

  const _AddHeartRateButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showAddDialog(context),
      child: GlassCard(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(16.r),
        radius: 12,
        tint: FitColors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: FitColors.red),
            SizedBox(width: 8.w),
            Text('Log Heart Rate', style: TextStyle(
              color: FitColors.red,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bpmController = TextEditingController();
    String? selectedActivity;

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
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Heart Rate', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              )),
              SizedBox(height: 20.h),
              TextField(
                controller: bpmController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, fontSize: 24.sp),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'BPM',
                  hintStyle: TextStyle(color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight),
                  suffixText: 'BPM',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: FitColors.red),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('Activity', style: TextStyle(
                color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                fontSize: 12.sp,
              )),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: HeartRateScreen._activityTypes.map((activity) => ChoiceChip(
                  label: Text(activity),
                  selected: selectedActivity == activity,
                  selectedColor: FitColors.red.withValues(alpha: 0.3),
                  onSelected: (selected) => setState(() =>
                    selectedActivity = selected ? activity : null),
                )).toList(),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final bpm = int.tryParse(bpmController.text);
                    if (bpm != null && bpm > 0 && bpm < 250) {
                      onAdd(bpm, selectedActivity);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.red,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Save', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartRateTile extends StatelessWidget {
  final HeartRateEntry entry;
  final VoidCallback onDelete;

  const _HeartRateTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: FitColors.orange,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(12.r),
        radius: 12,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: FitColors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.favorite, color: FitColors.red, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${entry.bpm} BPM', style: TextStyle(
                        color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      )),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getZoneColor(entry.zone).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(entry.zone, style: TextStyle(
                          color: _getZoneColor(entry.zone),
                          fontSize: 10.sp,
                        )),
                      ),
                    ],
                  ),
                  Text(DateFormat('hh:mm a').format(entry.timestamp),
                    style: TextStyle(
                      color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                      fontSize: 11.sp,
                    )),
                ],
              ),
            ),
            if (entry.activity != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isDark ? FitColors.surfaceDark : FitColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(entry.activity!, style: TextStyle(
                  color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                  fontSize: 11.sp,
                )),
              ),
          ],
        ),
      ),
    );
  }

  Color _getZoneColor(String zone) {
    switch (zone) {
      case 'Rest': return const Color(0xFF6B7280);
      case 'Resting': return FitColors.neonGreen;
      case 'Light': return FitColors.blue;
      case 'Moderate': return FitColors.amber;
      case 'Hard': return FitColors.orange;
      case 'Max': return FitColors.red;
      default: return const Color(0xFF6B7280);
    }
  }
}

class _HeartRateZones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zones = HeartRateZone.zones;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(16.r),
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Heart Rate Zones', style: TextStyle(
            color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          )),
          SizedBox(height: 12.h),
          ...zones.map((zone) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: zone.color,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(zone.name, style: TextStyle(
                    color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  )),
                ),
                Text('${zone.minBpm}-${zone.maxBpm} BPM', style: TextStyle(
                  color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                  fontSize: 11.sp,
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
