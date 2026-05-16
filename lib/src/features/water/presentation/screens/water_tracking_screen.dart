// ignore_for_file: unused_element, inference_failure_on_function_return_type, deprecated_member_use, prefer_const_constructors, inference_failure_on_function_invocation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';

class WaterTrackingScreen extends ConsumerWidget {
  const WaterTrackingScreen({super.key});

  static const _quickAmounts = [100, 200, 250, 300, 500];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(waterProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitColors.blue.withValues(alpha: 0.03),
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
              if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: RepaintBoundary(child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Water', style: TextStyle(
                    color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  )),
                  GlassContainer(
                    opacity: isDark ? 0.06 : 0.2,
                    radius: 8,
                    padding: EdgeInsets.all(8.w),
                    child: Icon(Icons.settings_outlined, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight, size: 18),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              _DateSelector(
                selectedDate: state.selectedDate,
                onTap: () => _selectDate(context, ref),
              ),
              SizedBox(height: 16.h),

              _WaterProgressCard(state: state),
              SizedBox(height: 16.h),

              Text('Quick add', style: TextStyle(
                color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              )),
              SizedBox(height: 10.h),
              Row(
                children: _quickAmounts.map((amount) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: _QuickAddButton(
                      amount: amount,
                      onTap: () => ref.read(waterProvider.notifier).addWater(amount),
                    ),
                  ),
                )).toList(),
              ),
              SizedBox(height: 16.h),

              _CustomAmountButton(
                onAdd: (amount) => ref.read(waterProvider.notifier).addWater(amount),
              ),
              SizedBox(height: 20.h),

              if (state.entries.isNotEmpty) ...[
                Text('Today\'s Log', style: TextStyle(
                  color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                )),
                SizedBox(height: 12.h),
                ...state.entries.map((entry) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _WaterEntryTile(
                    entry: entry,
                    onDelete: () => ref.read(waterProvider.notifier).deleteEntry(entry.id),
                  ),
                )),
              ],
            ],
          )),
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: ref.read(waterProvider).selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: FitColors.neonGreen,
            surface: FitColors.card,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) ref.read(waterProvider.notifier).selectDate(date);
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _WaterSettingsSheet(),
    );
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
            Icon(Icons.calendar_today, color: FitColors.blue, size: 18.sp),
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

class _WaterProgressCard extends StatelessWidget {
  final WaterState state;

  const _WaterProgressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(20.r),
      radius: 16,
      tint: FitColors.blue,
      child: Column(
        children: [
          SizedBox(
            width: 140.w,
            height: 140.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140.w,
                  height: 140.w,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: state.progress),
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 10,
                      backgroundColor: isDark ? FitColors.surfaceDark : FitColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation(FitColors.blue),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop, color: FitColors.blue, size: 28.sp),
                    SizedBox(height: 4.h),
                    Text('${state.totalIntake}',
                      style: TextStyle(
                        color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      )),
                    Text('ml',
                      style: TextStyle(
                        color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
                        fontSize: 12.sp,
                      )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Goal', value: '${state.goal}', color: FitColors.blue),
              Container(width: 1, height: 32.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
              _StatItem(label: 'Left', value: '${state.remaining}', color: FitColors.neonGreen),
              Container(width: 1, height: 32.h, color: isDark ? FitColors.borderDark : FitColors.borderLight),
              _StatItem(label: 'Entries', value: '${state.entries.length}', color: FitColors.blue),
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
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: TextStyle(
        color: color,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
      )),
      SizedBox(height: 4.h),
      Text(label, style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
        fontSize: 11.sp,
      )),
    ],
  );
}

class _QuickAddButton extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAddButton({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        radius: 12,
        tint: FitColors.blue,
        child: Column(
          children: [
            Icon(Icons.water_drop, color: FitColors.blue, size: 20.sp),
            SizedBox(height: 4.h),
            Text('+$amount', style: TextStyle(
              color: FitColors.blue,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            )),
            Text('ml', style: TextStyle(
              color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
              fontSize: 10.sp,
            )),
          ],
        ),
      ),
    );
  }
}

class _CustomAmountButton extends StatefulWidget {
  final Function(int) onAdd;

  const _CustomAmountButton({required this.onAdd});

  @override
  State<_CustomAmountButton> createState() => _CustomAmountButtonState();
}

class _CustomAmountButtonState extends State<_CustomAmountButton> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showDialog(context),
      child: GlassCard(
        opacity: isDark ? 0.06 : 0.2,
        padding: EdgeInsets.all(16.r),
        radius: 12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: FitColors.neonGreen),
            SizedBox(width: 8.w),
            Text('Custom Amount', style: TextStyle(
              color: FitColors.neonGreen,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
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
              Text('Add Water', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18.sp, fontWeight: FontWeight.bold,
              )),
              SizedBox(height: 16.h),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
                decoration: InputDecoration(
                  hintText: 'Amount in ml',
                  hintStyle: TextStyle(color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight),
                  suffixText: 'ml',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: FitColors.neonGreen),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(
                      color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                    )),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: () {
                      final amount = int.tryParse(_controller.text);
                      if (amount != null && amount > 0) {
                        widget.onAdd(amount);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Add', style: TextStyle(color: FitColors.neonGreen)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterEntryTile extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onDelete;

  const _WaterEntryTile({required this.entry, required this.onDelete});

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
                color: FitColors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.water_drop, color: FitColors.blue, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${entry.amount} ml', style: TextStyle(
                    color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  )),
                  Text(DateFormat('hh:mm a').format(entry.timestamp), style: TextStyle(
                    color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                    fontSize: 11.sp,
                  )),
                ],
              ),
            ),
            if (entry.note != null) Text(entry.note!, style: TextStyle(
              color: isDark ? FitColors.textMutedDark : FitColors.textMutedLight,
              fontSize: 12.sp,
            )),
          ],
        ),
      ),
    );
  }
}

class _WaterSettingsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(waterProvider);
    return GlassContainer(
      opacity: isDark ? 0.06 : 0.2,
      padding: EdgeInsets.all(20.w),
      radius: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Settings', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              )),
              IconButton(
                icon: Icon(Icons.close, color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListTile(
            leading: Icon(Icons.flag, color: FitColors.neonGreen),
            title: Text('Daily Goal', style: TextStyle(
              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            )),
            subtitle: Text('${state.goal} ml', style: TextStyle(
              color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
            )),
            onTap: () => _showGoalDialog(context, ref, state.goal),
          ),
          Divider(color: isDark ? FitColors.borderDark : FitColors.borderLight),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text('Reminders', style: TextStyle(
              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            )),
          ),
          ...state.reminders.map((reminder) => SwitchListTile(
            secondary: Icon(Icons.access_time, color: FitColors.blue),
            title: Text(reminder.label ?? 'Reminder', style: TextStyle(
              color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
            )),
            subtitle: Text('${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight)),
            value: reminder.isEnabled,
            activeColor: FitColors.neonGreen,
            onChanged: (v) => ref.read(waterProvider.notifier).toggleReminder(reminder.id, v),
          )),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context, WidgetRef ref, int currentGoal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: currentGoal.toString());
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
              Text('Set Daily Goal', style: TextStyle(
                color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                fontSize: 18.sp, fontWeight: FontWeight.bold,
              )),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight),
                decoration: InputDecoration(
                  suffixText: 'ml',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: isDark ? FitColors.borderDark : FitColors.borderLight),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: FitColors.neonGreen),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(
                      color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                    )),
                  ),
                  SizedBox(width: 8.w),
                  TextButton(
                    onPressed: () {
                      final goal = int.tryParse(controller.text);
                      if (goal != null && goal > 0) {
                        ref.read(waterProvider.notifier).setGoal(goal);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save', style: TextStyle(color: FitColors.neonGreen)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
