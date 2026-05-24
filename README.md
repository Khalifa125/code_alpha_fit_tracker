# Fit Tracker

A production-grade Flutter fitness tracking application developed as an internship deliverable at **Code Alpha**.

Fit Tracker is a full-featured mobile application for logging workouts, tracking nutrition, monitoring daily health metrics (steps, water, sleep, heart rate), and sustaining motivation through gamification. Data is persisted locally with optional Firebase sync.

---

## Features

- **Workout and Activity Logging** -- Log exercises with duration, calories, and type. Review progress via weekly charts and historical activity records.
- **Nutrition Tracking** -- Log meals with macro breakdown (protein, carbohydrates, fat). Scan barcodes via the OpenFoodFacts API for instant nutritional data with per-serving scaling.
- **Health Dashboard** -- Monitor steps, water intake, sleep hours, and heart rate through a unified glass-morphism interface with animated progress rings and key performance indicators.
- **Gamification and Streaks** -- Earn experience points, unlock achievements, complete daily challenges, and maintain streaks to reinforce consistency.
- **Multi-tab Navigation** -- Five-tab shell (Home, Workout, Activity, Nutrition, Profile) built with go_router shell routes and a glassy bottom navigation bar.
- **Dark and Light Themes** -- Full theme support with a custom neon green brand palette, glass containers, and smooth animations.
- **Offline-first Architecture** -- All data persisted locally via Hive and SharedPreferences. Firebase used for authentication and cloud synchronisation.

---

## Built With

| Layer | Technology |
|-------|------------|
| Framework | Flutter 3.29+ / Dart 3.2+ |
| State Management | Riverpod 2.x |
| Routing | go_router (ShellRoute with nested navigation) |
| Local Storage | Hive, SharedPreferences, flutter_secure_storage |
| Backend Services | Firebase Auth, Firestore, Storage, Analytics, Crashlytics |
| Notifications | flutter_local_notifications with timezone support |
| Charts | fl_chart |
| Maps | flutter_map (OpenStreetMap, no API key required) |
| Barcode Scanning | mobile_scanner with OpenFoodFacts HTTP API |
| Pedometer | pedometer_2 with sensors_plus |
| Localisation | easy_localization |
| Responsive Layout | flutter_screenutil |
| Animations | flutter_animate, lottie |

---

## Screenshots

| Home Dashboard | Workout Log | Nutrition | Profile |
|----------------|-------------|-----------|---------|
| *(placeholder)* | *(placeholder)* | *(placeholder)* | *(placeholder)* |

Screenshots will be added pending review.

---

## Getting Started

### Prerequisites

- Flutter SDK version 3.2.0 or higher ([install guide](https://docs.flutter.dev/get-started/install))
- A Firebase project with iOS and Android applications registered
- A physical device or emulator for deployment

### Setup

```bash
# Clone the repository
git clone https://github.com/Khalifa125/code_alpha_fit_tracker.git
cd code_alpha_fit_tracker

# Install dependencies
flutter pub get

# Configure Firebase
#   - Place google-services.json in android/app/
#   - Place GoogleService-Info.plist in ios/Runner/
#   (Both files are downloaded from Firebase Console)

# Run on a connected device or emulator
flutter run

# Build a release APK (Android)
flutter build apk --release

# Build an iOS IPA (requires macOS)
flutter build ios --release --no-codesign
```

> The included `GoogleService-Info.plist` is a template. Replace it with your own configuration from the [Firebase Console](https://console.firebase.google.com).

---

## Project Structure

```
lib/
 main.dart                         # Application entry point
 src/
  app.dart                         # Root widget with Riverpod and startup handler
  core/
   services/                       # Pedometer, Hive storage, internationalisation
   theme/                          # Colour palette, spacing, dark and light themes
  features/
   auth/                           # Login, signup, session management
   fitness/                        # Workout logging, BMI calculator, activity history, workout plans
   nutrition/                      # Meal logging, barcode scanning
   water/                          # Water intake tracking
   sleep/                          # Sleep tracking
   heart_rate/                     # Heart rate logging
   gamification/                   # Experience points, achievements, streaks, daily challenges
   dashboard/                      # Modern dashboard with animated progress rings
   home/                           # Tab shell and extracted widget components
   profile/                        # User profile and edit profile screens
   settings/                       # Application settings
   splash/                         # Splash screen with native splash integration
  routing/                         # go_router configuration
  shared/                          # GlassContainer, buttons, toast helpers
  imports/                         # Barrel export files
android/                           # Android native configuration
ios/                               # iOS native configuration with Podfile and permissions
test/                              # Widget and unit tests
```

---

## Code Quality

- `flutter analyze` produces **zero issues** across the entire project (no errors, warnings, or infos).
- All file-level `// ignore_for_file:` suppressions have been removed and the underlying issues resolved.
- The 1,855-line `home_page.dart` was decomposed into 14 focused widget files to improve maintainability and testability.
- A feature-first folder structure enforces clear separation of concerns.

---

## Internship Context

This application was developed as the capstone deliverable for a software engineering internship at **Code Alpha**. The project demonstrates:

- End-to-end Flutter development from wireframe through to production APK and iOS IPA builds.
- Enterprise architecture patterns including Riverpod state management, go_router shell navigation, and repository-based data access.
- Cross-platform deployment to a physical Android device (M2101K6G) and a configured iOS build pipeline via GitHub Actions.
- A code quality discipline enforcing a zero-lint policy, systematic widget extraction, and removal of dead code.

---

<p align="center">
Built with Flutter &middot; Internship Project &middot; Code Alpha<br/>
May 2026
</p>
