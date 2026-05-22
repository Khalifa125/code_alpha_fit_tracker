import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';
import 'src/imports/core_imports.dart';
import 'src/app.dart';import 'src/features/water/data/services/water_service.dart';
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
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled platform error: $error\n$stack');
    return false;
  };

  await _initFirebase();
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<dynamic>('settings'),
    Hive.openBox<dynamic>('user_data'),
    Hive.openBox<dynamic>('workouts'),
    Hive.openBox<dynamic>('nutrition'),
    Hive.openBox<dynamic>('water'),
    Hive.openBox<dynamic>('sleep'),
    Hive.openBox<dynamic>('progress'),
  ]);

  await EasyLocalization.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env', mergeWith: {});
  } catch (_) {}

  await AppConfig.init();
  await NotificationService().init();
  await NotificationService().requestPermissions();

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
      child: const LocalizationWrapper(child: App()),
    ),
  );

  FlutterNativeSplash.remove();
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
}
