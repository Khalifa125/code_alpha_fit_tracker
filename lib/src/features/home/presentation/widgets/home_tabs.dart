import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/home_tab.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/workout_tab.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/activity_tab.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/nutrition_tab.dart';
import 'package:fit_tracker/src/features/home/presentation/widgets/profile_tab.dart';

class HomeTabs extends StatefulWidget {
  final Widget? child;
  const HomeTabs({super.key, this.child});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _selectedIndex = 0;

  static const _screens = [
    HomeTab(),
    WorkoutTab(),
    ActivityTab(),
    NutritionTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _FitBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

class _FitBottomNav extends StatelessWidget {
  const _FitBottomNav({required this.selectedIndex, required this.onTap});
  final int selectedIndex;
  final void Function(int) onTap;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.fitness_center_rounded, 'Workout'),
    (Icons.bar_chart_rounded, 'Activity'),
    (Icons.restaurant_menu_rounded, 'Nutrition'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: FitColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: FitColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: FitColors.neonGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          height: 46.h,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final (icon, label) = e.value;
              final selected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: selected ? FitColors.neonGreen.withValues(alpha: 0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: 200.ms,
                          child: Icon(
                            icon,
                            key: ValueKey('$i-$selected'),
                            size: 20.sp,
                            color: selected ? FitColors.textPrimary : FitColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        AnimatedDefaultTextStyle(
                          duration: 200.ms,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: selected ? FitColors.textPrimary : FitColors.textMuted,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          child: Text(label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
