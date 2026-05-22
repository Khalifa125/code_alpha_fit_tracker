// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_tracker/src/routing/global_navigator.dart';
import 'package:fit_tracker/src/routing/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:fit_tracker/src/features/auth/presentation/screens/signin_screen.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:fit_tracker/src/features/onboarding/presentation/screens/onboarding_page.dart' show OnboardingScreen;
import 'package:fit_tracker/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/map_workout_screen.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/profile_screen.dart';

import 'package:fit_tracker/src/features/home/presentation/screens/home_page.dart';
import 'package:fit_tracker/src/features/fit_track/screens/home_page.dart' show FitTrackHomePage;
import 'package:fit_tracker/src/features/dashboard/screens/dashboard_screen.dart' show ModernDashboard;
import 'package:fit_tracker/src/features/fitness/presentation/screens/fitness_screen.dart';
import 'package:fit_tracker/src/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:fit_tracker/src/features/water/presentation/screens/water_tracking_screen.dart';
import 'package:fit_tracker/src/features/sleep/presentation/screens/sleep_tracking_screen.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

CustomTransitionPage<void> _darkPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: ValueKey(state.uri),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final theme = Theme.of(context);
      return FadeTransition(
        opacity: animation,
        child: ColoredBox(color: theme.scaffoldBackgroundColor, child: child),
      );
    },
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: <RouteBase>[
    // Auth routes (outside Shell - have their own screens)
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ShellRoute with ONE Scaffold + bottom nav
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => _darkPage(const ModernDashboard(), state),
        ),
        GoRoute(
          path: '/fitness',
          name: 'fitness',
          pageBuilder: (context, state) => _darkPage(const FitnessScreenContent(), state),
        ),
        GoRoute(
          path: '/nutrition',
          name: 'nutrition',
          pageBuilder: (context, state) => _darkPage(const NutritionScreenContent(), state),
        ),
        GoRoute(
          path: '/water',
          name: 'water',
          pageBuilder: (context, state) => _darkPage(const WaterScreenContent(), state),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => _darkPage(const ProfileScreenContent(), state),
        ),
      ],
    ),

    // Other routes (outside Shell)
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.mapWorkout,
      name: 'mapWorkout',
      builder: (context, state) => const MapWorkoutScreen(),
    ),
    GoRoute(
      path: '/sleep',
      name: 'sleep',
      builder: (context, state) => const SleepTrackingScreen(),
    ),
  ],
);

// MainShell - ONE Scaffold only with bottom nav
class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  static const _destinations = [
    ('/home', Icons.home_rounded, 'Home'),
    ('/fitness', Icons.fitness_center_rounded, 'Fitness'),
    ('/nutrition', Icons.restaurant_menu_rounded, 'Nutrition'),
    ('/water', Icons.water_drop_rounded, 'Water'),
    ('/profile', Icons.person_rounded, 'Profile'),
  ];

  late AnimationController _breatheController;
  late Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _breatheAnim = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _destinations.indexWhere((d) => d.$1 == location).clamp(0, _destinations.length - 1);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? FitColors.backgroundDark : FitColors.backgroundLight,
      body: widget.child,
      bottomNavigationBar: AnimatedBuilder(
        animation: _breatheAnim,
        builder: (_, __) => Container(
          margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h + bottomPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: FitColors.neonGreen.withValues(alpha: 0.12 * _breatheAnim.value),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: FitColors.neonGreen.withValues(alpha: 0.06 * _breatheAnim.value),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 64.h,
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF0D1117) : Colors.white).withValues(alpha: 0.75),
                  border: Border(
                    top: BorderSide(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)),
                  ),
                ),
                child: Row(
                  children: List.generate(_destinations.length, (i) {
                    final (path, icon, label) = _destinations[i];
                    final isSelected = i == selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => context.go(path),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: 200.ms,
                          margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: isSelected
                                ? FitColors.neonGreen.withValues(alpha: 0.12)
                                : Colors.transparent,
                            border: isSelected
                                ? Border.all(color: FitColors.neonGreen.withValues(alpha: 0.2))
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 22.sp,
                                color: isSelected ? FitColors.neonGreen : (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? FitColors.neonGreen : (isDark ? FitColors.textSecondaryDark : FitColors.textSecondaryLight),
                                  fontSize: 9.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 16.w,
                                  height: 2.h,
                                  margin: EdgeInsets.only(top: 2.h),
                                  decoration: BoxDecoration(
                                    color: FitColors.neonGreen,
                                    borderRadius: BorderRadius.circular(1.r),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Content-only screen wrappers (no Scaffold)
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) => const FitTrackShell(child: FitTrackHomePage());
}

class FitnessScreenContent extends StatelessWidget {
  const FitnessScreenContent({super.key});

  @override
  Widget build(BuildContext context) => const FitnessScreen();
}

class NutritionScreenContent extends StatelessWidget {
  const NutritionScreenContent({super.key});

  @override
  Widget build(BuildContext context) => const NutritionScreen();
}

class WaterScreenContent extends StatelessWidget {
  const WaterScreenContent({super.key});

  @override
  Widget build(BuildContext context) => const WaterTrackingScreen();
}

class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) => const ProfileScreen();
}
