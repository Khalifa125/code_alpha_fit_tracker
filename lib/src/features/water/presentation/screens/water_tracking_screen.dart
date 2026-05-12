// ignore_for_file: unused_element, inference_failure_on_function_return_type, deprecated_member_use, prefer_const_constructors, inference_failure_on_function_invocation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';

class WaterTrackingScreen extends ConsumerWidget {
  const WaterTrackingScreen({super.key});

  static const _quickAmounts = [100, 200, 250, 300, 500];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waterProvider);

    return Scaffold(
      backgroundColor: FitColors.backgroundDark,
      body: SafeArea(
        child: RepaintBoundary(child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Water', style: TextStyle(
                  color: FitColors.textPrimaryDark,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                )),
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: FitColors.cardDark,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: FitColors.borderDark),
                  ),
                  child: Icon(Icons.settings_outlined, color: FitColors.textSecondaryDark, size: 18),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Date selector
            _DateSelector(
              selectedDate: state.selectedDate,
              onTap: () => _selectDate(context, ref),
            ),
            SizedBox(height: 16.h),

            // Main progress
            _WaterProgressCard(state: state),
            SizedBox(height: 16.h),

            // Quick add buttons
            Text('Quick add', style: TextStyle(
              color: FitColors.textSecondaryDark,
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

            // Custom amount
            _CustomAmountButton(
              onAdd: (amount) => ref.read(waterProvider.notifier).addWater(amount),
            ),
            SizedBox(height: 20.h),

            // Today's entries
            if (state.entries.isNotEmpty) ...[
              Text('Today\'s Log', style: TextStyle(
                color: FitColors.textPrimary,
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
      backgroundColor: FitColors.card,
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
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: FitColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: FitColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: FitColors.neonGreen, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              isToday ? 'Today' : DateFormat('MMM dd, yyyy').format(selectedDate),
              style: TextStyle(
                color: FitColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_drop_down, color: FitColors.textSecondary),
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
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FitColors.blue.withValues(alpha: 0.15),
            FitColors.blue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: FitColors.blue.withValues(alpha: 0.3)),
      ),
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
                      backgroundColor: FitColors.surfaceDark,
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
                        color: FitColors.textPrimaryDark,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      )),
                    Text('ml',
                      style: TextStyle(
                        color: FitColors.textSecondaryDark.withValues(alpha: 0.7),
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
              Container(width: 1, height: 32.h, color: FitColors.borderDark),
              _StatItem(label: 'Left', value: '${state.remaining}', color: FitColors.neonGreen),
              Container(width: 1, height: 32.h, color: FitColors.borderDark),
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
        color: FitColors.textSecondary,
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: FitColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: FitColors.blue.withValues(alpha: 0.3)),
      ),
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
            color: FitColors.textSecondary,
            fontSize: 10.sp,
          )),
        ],
      ),
    ),
  );
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _showDialog(context),
    child: Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: FitColors.border),
      ),
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

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FitColors.card,
        title: Text('Add Water', style: TextStyle(color: FitColors.textPrimary)),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: FitColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Amount in ml',
            hintStyle: TextStyle(color: FitColors.textMuted),
            suffixText: 'ml',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: FitColors.border),
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: FitColors.neonGreen),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: FitColors.textSecondary)),
          ),
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
    );
  }
}

class _WaterEntryTile extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onDelete;

  const _WaterEntryTile({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) => Dismissible(
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
    child: Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: FitColors.card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: FitColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: FitColors.blue.withValues(alpha: 0.1),
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
                  color: FitColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                )),
                Text(DateFormat('hh:mm a').format(entry.timestamp), style: TextStyle(
                  color: FitColors.textSecondary,
                  fontSize: 11.sp,
                )),
              ],
            ),
          ),
          if (entry.note != null) Text(entry.note!, style: TextStyle(
            color: FitColors.textMuted,
            fontSize: 12.sp,
          )),
        ],
      ),
    ),
  );
}

class _WaterSettingsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(waterProvider);
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Settings', style: TextStyle(
                color: FitColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              )),
              IconButton(
                icon: Icon(Icons.close, color: FitColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Goal setting
          ListTile(
            leading: Icon(Icons.flag, color: FitColors.neonGreen),
            title: Text('Daily Goal', style: TextStyle(color: FitColors.textPrimary)),
            subtitle: Text('${state.goal} ml', style: TextStyle(color: FitColors.textSecondary)),
            onTap: () => _showGoalDialog(context, ref, state.goal),
          ),
          Divider(color: FitColors.border),
          // Reminders
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text('Reminders', style: TextStyle(
              color: FitColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            )),
          ),
          ...state.reminders.map((reminder) => SwitchListTile(
            secondary: Icon(Icons.access_time, color: FitColors.blue),
            title: Text(reminder.label ?? 'Reminder', style: TextStyle(color: FitColors.textPrimary)),
            subtitle: Text('${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: FitColors.textSecondary)),
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
    final controller = TextEditingController(text: currentGoal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FitColors.card,
        title: Text('Set Daily Goal', style: TextStyle(color: FitColors.textPrimary)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: FitColors.textPrimary),
          decoration: InputDecoration(
            suffixText: 'ml',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: FitColors.border),
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: FitColors.neonGreen),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: FitColors.textSecondary)),
          ),
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
    );
  }
}
