import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  static String get baseUrl => _getBaseUrl();
  static bool get isFirebaseConfigured => _isFirebaseConfigured;
  static bool _isFirebaseConfigured = false;

  static Future<void> init() async {
    // Check if Firebase is configured
    try {
      await Firebase.initializeApp();
      _isFirebaseConfigured = true;
    } catch (e) {
      // Firebase not configured - app will work in offline mode
      _isFirebaseConfigured = false;
    }

    // Initialize SharedPreferences
    await SharedPreferences.getInstance();
  }

  static String _getBaseUrl() {
    return dotenv.get('API_BASE_URL', fallback: 'https://api.example.com');
  }
}
