// ignore_for_file: deprecated_member_use, inference_failure_on_function_return_type, inference_failure_on_function_invocation, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/sleep/presentation/providers/sleep_provider.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class SleepTrackingScreen extends ConsumerWidget {
  const SleepTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(sleepProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitColors.purple.withValues(alpha: 0.03),
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: RepaintBoundary(child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            children: [
              Text('Sleep', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              )),
              SizedBox(height: 16.h),

              _DateSelector(
                selectedDate: state.selectedDate,
                onTap: () => _selectDate(context, ref),
              ),
              SizedBox(height: 16.h),

              _SleepSummaryCard(state: state),
              SizedBox(height: 16.h),

              _AddSleepButton(
                onAdd: (start, end, quality) => ref.read(sleepProvider.notifier).addSleep(
                  startTime: start,
                  endTime: end,
                  quality: quality,
                ),
              ),
              SizedBox(height: 16.h),

              if (state.entries.isNotEmpty) ...[
                Text('History', style: TextStyle(
                  color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                )),
                SizedBox(height: 10.h),
                ...state.entries.map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _SleepEntryTile(
                    entry: entry,
                    onDelete: () => ref.read(sleepProvider.notifier).deleteEntry(entry.id),
                  ),
                )),
              ],

              SizedBox(height: 16.h),
              _WeeklySleepChart(),
            ],
          )),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: ref.read(sleepProvider).selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: FitColors.purple,
            surface: FitColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) ref.read(sleepProvider.notifier).selectDate(date);
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
            Icon(Icons.calendar_today, color: FitColors.purple, size: 18.sp),
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

class _SleepSummaryCard extends StatelessWidget {
  final SleepState state;

  const _SleepSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalMins = state.totalHours * 60 + state.totalMinutes;
    final hours = totalMins ~/ 60;
    final mins = totalMins % 60;

    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(20.r),
      radius: 16,
      tint: FitColors.purple,
      child: Column(
        children: [
          Icon(Icons.nightlight_round, color: FitColors.purple, size: 36.sp),
          SizedBox(height: 10.h),
          Text('$hours h $mins m', style: TextStyle(
            color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          )),
          Text('total sleep', style: TextStyle(
            color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
            fontSize: 12.sp,
          )),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Sessions',
                value: '${state.entries.length}',
                icon: Icons.bedtime,
                color: FitColors.purple,
              ),
              Container(width: 1, height: 28.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
              _StatItem(
                label: 'Quality',
                value: state.avgQuality > 0 ? state.avgQuality.toStringAsFixed(1) : '-',
                icon: Icons.star,
                color: FitColors.amber,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 20.sp),
      SizedBox(height: 4.h),
      Text(value, style: TextStyle(
        color: color,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
      )),
      Text(label, style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
        fontSize: 11.sp,
      )),
    ],
  );
}

class _AddSleepButton extends StatelessWidget {
  final Function(DateTime start, DateTime end, int? quality) onAdd;

  const _AddSleepButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showAddDialog(context),
      child: GlassCard(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(16.r),
        radius: 12,
        tint: FitColors.purple,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: FitColors.purple),
            SizedBox(width: 8.w),
            Text('Log Sleep', style: TextStyle(
              color: FitColors.purple,
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
    DateTime startTime = DateTime.now().subtract(const Duration(hours: 8));
    DateTime endTime = DateTime.now();
    int? quality;

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
              Text('Log Sleep', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              )),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: 'Bedtime',
                      time: startTime,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(startTime),
                        );
                        if (t != null) {
                          setState(() => startTime = DateTime(
                            startTime.year, startTime.month, startTime.day, t.hour, t.minute,
                          ));
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _TimeButton(
                      label: 'Wake up',
                      time: endTime,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(endTime),
                        );
                        if (t != null) {
                          setState(() => endTime = DateTime(
                            endTime.year, endTime.month, endTime.day, t.hour, t.minute,
                          ));
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text('Sleep Quality', style: TextStyle(
                color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                fontSize: 12.sp,
              )),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => quality = i + 1),
                  child: Icon(
                    quality != null && i < quality! ? Icons.star : Icons.star_border,
                    color: FitColors.amber,
                    size: 32.sp,
                  ),
                )),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (endTime.isAfter(startTime)) {
                      onAdd(startTime, endTime, quality);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FitColors.purple,
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

class _TimeButton extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(12.r),
        radius: 12,
        child: Column(
          children: [
            Text(label, style: TextStyle(
              color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
              fontSize: 12.sp,
            )),
            SizedBox(height: 4.h),
            Text(DateFormat('hh:mm a').format(time), style: TextStyle(
              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}

class _SleepEntryTile extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onDelete;

  const _SleepEntryTile({required this.entry, required this.onDelete});

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
                color: FitColors.purple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.nightlight_round, color: FitColors.purple, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.hours}h ${entry.minutes}m', style: TextStyle(
                    color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  )),
                  Text('${DateFormat('hh:mm a').format(entry.startTime)} - ${DateFormat('hh:mm a').format(entry.endTime)}',
                    style: TextStyle(
                      color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                      fontSize: 11.sp,
                    )),
                ],
              ),
            ),
            if (entry.quality != null)
              Row(
                children: List.generate(entry.quality, (i) =>
                  Icon(Icons.star, color: FitColors.amber, size: 14.sp)),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySleepChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(weeklySleepProvider);

    return summaryAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (summary) => GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(16.r),
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Week', style: TextStyle(
              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            )),
            SizedBox(height: 16.h),
            SizedBox(
              height: 120.h,
              child: BarChart(BarChartData(
                maxY: 12,
                barGroups: List.generate(7, (i) {
                  final hours = summary.hoursByDay[i]?.toDouble() ?? 0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [BarChartRodData(
                      toY: hours,
                      width: 20.w,
                      color: hours >= 7 ? FitColors.purple : FitColors.orange,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(5.r)),
                    )],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: isDark ? FitColors.borderDark : FitColors.borderLight,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][v.toInt()],
                        style: TextStyle(
                          color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight,
                          fontSize: 10.sp,
                        )),
                    ),
                  )),
                ),
                borderData: FlBorderData(show: false),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
