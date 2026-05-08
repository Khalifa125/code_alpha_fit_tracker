import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_tracker/src/routing/global_navigator.dart';
import 'package:fit_tracker/src/routing/app_routes.dart';

import 'package:fit_tracker/src/features/auth/presentation/screens/signin_screen.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/signup_screen.dart';
import 'package:fit_tracker/src/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:fit_tracker/src/features/onboarding/presentation/screens/onboarding_page.dart' show OnboardingScreen;
import 'package:fit_tracker/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:fit_tracker/src/features/fitness/presentation/screens/map_workout_screen.dart';
import 'package:fit_tracker/src/features/profile/presentation/screens/profile_screen.dart';

import 'package:fit_tracker/src/features/home/presentation/screens/home_page.dart';
import 'package:fit_tracker/src/features/fit_track/screens/home_page.dart' show FitTrackHomePage;
import 'package:fit_tracker/src/features/fitness/presentation/screens/fitness_screen.dart';
import 'package:fit_tracker/src/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:fit_tracker/src/features/water/presentation/screens/water_tracking_screen.dart';
import 'package:fit_tracker/src/features/sleep/presentation/screens/sleep_tracking_screen.dart';
import 'package:fit_tracker/src/theme/fit_colors.dart';

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
          builder: (context, state) => const HomeScreenContent(),
        ),
        GoRoute(
          path: '/fitness',
          name: 'fitness',
          builder: (context, state) => const FitnessScreenContent(),
        ),
        GoRoute(
          path: '/nutrition',
          name: 'nutrition',
          builder: (context, state) => const NutritionScreenContent(),
        ),
        GoRoute(
          path: '/water',
          name: 'water',
          builder: (context, state) => const WaterScreenContent(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreenContent(),
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

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _destinations = [
    ('/home', Icons.home_rounded, 'Home'),
    ('/fitness', Icons.fitness_center_rounded, 'Fitness'),
    ('/nutrition', Icons.restaurant_menu_rounded, 'Nutrition'),
    ('/water', Icons.water_drop_rounded, 'Water'),
    ('/profile', Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    _currentIndex = _destinations.indexWhere((d) => d.$1 == location);
    if (_currentIndex < 0) _currentIndex = 0;

    return Scaffold(
      backgroundColor: FitColors.backgroundDark,
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          context.go(_destinations[index].$1);
        },
        backgroundColor: FitColors.surfaceDark,
        indicatorColor: FitColors.neonGreen.withValues(alpha: 0.2),
        destinations: _destinations.map((d) => NavigationDestination(
          icon: Icon(d.$2, color: FitColors.textSecondary),
          selectedIcon: Icon(d.$2, color: FitColors.neonGreen),
          label: d.$3,
        )).toList(),
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