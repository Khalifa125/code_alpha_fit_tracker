import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the app.
///
/// You need to replace these values with your own Firebase project credentials.
/// Visit https://console.firebase.google.com/ to create a project and get the credentials.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace with your Firebase Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fit-track-app',
    authDomain: 'fit-track-app.firebaseapp.com',
    storageBucket: 'fit-track-app.appspot.com',
  );

  // Replace with your Firebase Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fit-track-app',
    storageBucket: 'fit-track-app.appspot.com',
  );

  // Replace with your Firebase iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fit-track-app',
    storageBucket: 'fit-track-app.appspot.com',
    iosClientId: '000000000000-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitTracker',
  );

  // Replace with your Firebase macOS configuration
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:000000000000:macos:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fit-track-app',
    storageBucket: 'fit-track-app.appspot.com',
    iosClientId: '000000000000-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitTracker',
  );

  // Replace with your Firebase Windows configuration
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: '1:000000000000:windows:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fit-track-app',
    storageBucket: 'fit-track-app.appspot.com',
  );
}