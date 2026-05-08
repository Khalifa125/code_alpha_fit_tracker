/// Centralized route path constants for GoRouter.
///
/// Use these variables instead of raw strings throughout the app.
/// Example: `context.go(AppRoutes.onboarding)` instead of `context.go('/')`.
abstract final class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String settings = '/settings';
  static const String mapWorkout = '/map-workout';
  static const String fitness = '/fitness';
  static const String nutrition = '/nutrition';
  static const String water = '/water';
  static const String profile = '/profile';
}
