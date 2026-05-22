
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/imports/core_imports.dart';
import 'package:fit_tracker/src/features/settings/presentation/providers/theme_provider.dart';
import 'package:fit_tracker/src/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fit_tracker/src/features/water/presentation/providers/water_provider.dart';
import 'package:fit_tracker/src/features/sleep/presentation/providers/sleep_provider.dart';
import 'package:fit_tracker/src/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fit_tracker/src/shared/wrappers/error_boundary.dart';

class _FitScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    ref.listen(gamificationProvider, (_, __) {});
    ref.listen(achievementsProvider, (_, __) {});

    Widget current = _buildMaterialApp(context, themeMode);
    current = _StartupHandler(child: current);
    current = ScreenUtilWrapper(child: current);
    current = ErrorBoundary(child: current);
    return current;
  }

  Widget _buildMaterialApp(BuildContext context, ThemeMode themeMode) {
    return MaterialApp.router(
      title: 'Fit Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(primaryColorHex: '#22C55E'),
      darkTheme: buildDarkTheme(primaryColorHex: '#22C55E'),
      themeMode: themeMode,
      routerConfig: appRouter,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        Widget current = child!;
        current = SkeletonWrapper(child: current);
        current = SessionListenerWrapper(child: current);
        current = ScrollConfiguration(
          behavior: _FitScrollBehavior(),
          child: current,
        );
        return current;
      },
    );
  }
}

class _StartupHandler extends ConsumerStatefulWidget {
  final Widget child;
  const _StartupHandler({required this.child});

  @override
  ConsumerState<_StartupHandler> createState() => _StartupHandlerState();
}

class _StartupHandlerState extends ConsumerState<_StartupHandler> {
  bool _initialized = false;
  int _lastDay = DateTime.now().day;
  Timer? _midnightTimer;

  void _syncAchievements() {
    final gs = ref.read(gamificationProvider);
    int waterGlasses = 0;
    try { waterGlasses = ref.read(waterProvider).totalIntake ~/ 250; } catch (_) {}
    int sleepHours = 0;
    try { sleepHours = ref.read(sleepProvider).totalHours; } catch (_) {}
    int steps = 0;
    try {
      final summary = ref.read(dailySummaryProvider).valueOrNull;
      if (summary != null) steps = summary.totalSteps;
    } catch (_) {}
    ref.read(achievementsProvider.notifier).updateProgress(
      gs, waterGlasses: waterGlasses, sleepHours: sleepHours, steps: steps,
    );
  }

  void _checkMidnight() {
    final now = DateTime.now();
    if (now.day != _lastDay) {
      _lastDay = now.day;
      ref.read(gamificationProvider.notifier).generateDailyChallenges();
    }
  }

  @override
  void initState() {
    super.initState();
    _lastDay = DateTime.now().day;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        ref.read(gamificationProvider.notifier).generateDailyChallenges();
        _syncAchievements();
        ref.listenManual(waterProvider, (_, __) => _syncAchievements());
        ref.listenManual(sleepProvider, (_, __) => _syncAchievements());
        _midnightTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkMidnight());
      }
    });
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
