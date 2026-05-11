// ignore_for_file: inference_failure_on_function_invocation, unnecessary_import, inference_failure_on_instance_creation, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/imports/core_imports.dart';
import 'src/app.dart';
import 'src/services/notification_service.dart';
import 'src/features/splash/presentation/screens/splash_screen.dart';
import 'src/features/water/data/services/water_service.dart';
import 'src/features/water/presentation/providers/water_provider.dart';
import 'src/features/sleep/data/services/sleep_service.dart';
import 'src/features/sleep/presentation/providers/sleep_provider.dart';
import 'src/features/heart_rate/data/services/heart_rate_service.dart';
import 'src/features/heart_rate/presentation/providers/heart_rate_provider.dart';
import 'src/features/progress_photos/data/services/progress_photo_service.dart';
import 'src/features/progress_photos/presentation/providers/progress_photo_provider.dart';
import 'src/features/fit_track/services/fittrack_service.dart';
import 'src/features/fit_track/providers/auth_provider.dart';

Future<void> main() async {
  final WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Setup global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    return true;
  };

  // Initialize Firebase with offline persistence
  try {
    await Firebase.initializeApp();
    _setupFirebaseOfflinePersistence();
  } catch (e) {
    // Firebase not configured (e.g. missing GoogleService-Info.plist on iOS)
  }

  // Initialize Hive in parallel for faster startup
  await Hive.initFlutter();
  await _initHiveBoxes();

  await EasyLocalization.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env', mergeWith: {});
  } catch (_) {}

  await AppConfig.init();
  await NotificationService().init();
  await NotificationService().requestPermissions();

  // Initialize services in parallel
  final waterService = await WaterService.init();
  final sleepService = await SleepService.init();
  final heartRateService = await HeartRateService.init();
  final progressPhotoService = await ProgressPhotoService.init();
  final fitTrackService = await FitTrackService.init();

  runApp(
    ProviderScope(
      overrides: [
        waterServiceProvider.overrideWithValue(waterService),
        sleepServiceProvider.overrideWithValue(sleepService),
        heartRateServiceProvider.overrideWithValue(heartRateService),
        progressPhotoServiceProvider.overrideWithValue(progressPhotoService),
        fitTrackServiceProvider.overrideWithValue(fitTrackService),
      ],
      child: const LocalizationWrapper(child: SplashScreenWrapper()),
    ),
  );
}

/// Initialize all Hive boxes in parallel for faster startup
Future<void> _initHiveBoxes() async {
  final boxes = [
    Hive.openBox('settings'),
    Hive.openBox('user_data'),
    Hive.openBox('workouts'),
    Hive.openBox('nutrition'),
    Hive.openBox('water'),
    Hive.openBox('sleep'),
    Hive.openBox('progress'),
  ];
  await Future.wait(boxes);
}

/// Setup Firebase offline persistence
void _setupFirebaseOfflinePersistence() {
  // Enable Firestore offline persistence with cache
  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: true,
  //   cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  // );
}

class SplashScreenWrapper extends ConsumerStatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  ConsumerState<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends ConsumerState<SplashScreenWrapper> {
  bool _showSplash = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (mounted) {
      setState(() {
        _showSplash = false;
        _isLoading = false;
      });
      // Remove native splash screen
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash || _isLoading) {
      return const SplashScreen();
    }

    // Go directly to home - no login required
    return const App();
  }
}