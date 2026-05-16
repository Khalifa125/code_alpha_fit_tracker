// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';
import 'package:fit_tracker/src/shared/widgets/glass_container.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/category_screen.dart';
import 'package:fit_tracker/src/features/fit_track/screens/workout_session_screen.dart';
import 'package:fit_tracker/src/features/fit_track/providers/workout_provider.dart';

class FitnessScreen extends ConsumerStatefulWidget {
  const FitnessScreen({super.key});

  @override
  ConsumerState<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends ConsumerState<FitnessScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const _categories = [
    {'icon': Icons.fitness_center, 'name': 'Strength', 'count': '12 workouts', 'color': FitColors.neonGreen, 'category': 'Strength'},
    {'icon': Icons.directions_run, 'name': 'Cardio', 'count': '8 workouts', 'color': FitColors.orange, 'category': 'Cardio'},
    {'icon': Icons.bolt, 'name': 'HIIT', 'count': '6 workouts', 'color': FitColors.amber, 'category': 'HIIT'},
    {'icon': Icons.self_improvement, 'name': 'Yoga', 'count': '10 workouts', 'color': FitColors.purple, 'category': 'Yoga'},
  ];

  static const _plans = [
    {'title': 'PPL — Push Pull Legs', 'subtitle': '6 days / week · 8 weeks', 'color': FitColors.neonGreen, 'level': 'inter'},
    {'title': '5×5 Strength', 'subtitle': '3 days / week · 12 weeks', 'color': FitColors.orange, 'level': 'adv'},
    {'title': 'Home — No Equipment', 'subtitle': '4 days / week · 6 weeks', 'color': FitColors.blue, 'level': 'beg'},
    {'title': 'HIIT Fat Burn', 'subtitle': '4 days / week · 4 weeks', 'color': FitColors.purple, 'level': 'inter'},
  ];

  void _onCategoryTap(String category) {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(category: category)));
  }

  void _generateQuickWorkout() {
    try { HapticFeedback.mediumImpact(); } catch (_) {}
    ref.read(workoutProvider.notifier).generateWorkout(
      goal: 'Stay Active',
      fitnessLevel: 'Intermediate',
      availableMinutes: 10,
    );
    final workout = ref.read(workoutProvider).currentWorkout;
    if (workout != null && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutSessionScreen(workout: workout)));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: Scaffold(
        backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                FitColors.neonGreen.withValues(alpha: 0.03),
                if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
                if (isDark) FitColors.backgroundDark else FitColors.backgroundLight,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassContainer(
              opacity: isDark ? 0.06 : 0.2,
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              radius: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fitness',
                    style: TextStyle(
                      color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: _generateQuickWorkout,
                    child: GlassContainer(
                      opacity: isDark ? 0.06 : 0.2,
                      radius: 10,
                      padding: EdgeInsets.all(8.w),
                      tint: FitColors.neonGreen,
                      child: Icon(Icons.add, color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight, size: 18),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: -0.1),
            SizedBox(height: 16.h),

            // Categories section
            Text(
              'Categories',
              style: TextStyle(
                color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 10.h),
            GlassContainer(
              opacity: isDark ? 0.06 : 0.2,
              radius: 20,
              padding: EdgeInsets.zero,
              child: GridView.builder(
                cacheExtent: 500,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8.w,
                  crossAxisSpacing: 8.w,
                  childAspectRatio: 1.5,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return _CategoryCard(
                    key: ValueKey('cat_${cat['name']}'),
                    icon: cat['icon'] as IconData,
                    name: cat['name'] as String,
                    count: cat['count'] as String,
                    color: cat['color'] as Color,
                    index: index,
                    onTap: () => _onCategoryTap(cat['category'] as String),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),

            // Workout plans section
            Text(
              'Workout plans',
              style: TextStyle(
                color: isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 10.h),
            GlassContainer(
              opacity: isDark ? 0.06 : 0.2,
              radius: 20,
              padding: EdgeInsets.zero,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  return _PlanItem(
                    title: plan['title'] as String,
                    subtitle: plan['subtitle'] as String,
                    color: plan['color'] as Color,
                    level: plan['level'] as String,
                    index: index,
                  );
                },
              ),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    ),
  ),
),
);
  }
}

class _CategoryCard extends StatefulWidget {
  final IconData icon;
  final String name;
  final String count;
  final Color color;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    super.key,
    required this.icon,
    required this.name,
    required this.count,
    required this.color,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: GlassCard(
          opacity: isDark ? 0.06 : 0.2,
          radius: 12,
          padding: EdgeInsets.all(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(widget.icon, color: widget.color, size: 16),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.name,
                style: TextStyle(
                  color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                widget.count,
                style: TextStyle(
                  color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 + widget.index * 30).ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _PlanItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final String level;
  final int index;

  const _PlanItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.level,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levelLabel = level == 'beg' ? 'Beg' : level == 'inter' ? 'Inter' : 'Adv';
    final levelColor = level == 'beg' ? FitColors.neonGreen : level == 'inter' ? FitColors.orange : FitColors.red;

    return GlassCard(
      opacity: isDark ? 0.06 : 0.2,
      radius: 12,
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? FitColors.textPrimaryDark : FitColors.textPrimaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight).withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              levelLabel,
              style: TextStyle(
                color: levelColor,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(begin: 0.05);
  }
}
