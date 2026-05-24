# Fit Tracker

> A production-grade Flutter fitness tracking application built as an internship project at **Code Alpha**.

Fit Tracker is a full-featured mobile companion for logging workouts, tracking nutrition, monitoring daily health metrics (steps, water, sleep, heart rate), and staying motivated through gamification — all powered by local-first storage with real-time barcode scanning and Firebase sync.

---

## Features

- 🏋️ **Workout & Activity Logging** — Log exercises with duration, calories, and type. View weekly charts and activity history.
- 🥗 **Nutrition Tracking** — Log meals with macro breakdown (protein, carbs, fat). Scan barcodes via **OpenFoodFacts API** for instant nutritional data.
- 💧 **Health Dashboard** — Track steps, water intake, sleep hours, and heart rate in a unified glass-morphism UI with animated progress rings.
- 🎮 **Gamification & Streaks** — Earn XP, unlock achievements, complete daily challenges, and maintain streaks to stay consistent.
- 🧭 **Multi-tab Navigation** — Five-tab shell (Home, Workout, Activity, Nutrition, Profile) with go_router shell routes and glassy bottom navigation bar.
- 🌙 **Dark & Light Themes** — Full theme support with custom neon green brand palette, glass containers, and smooth animations via `flutter_animate`.
- 📲 **Offline First** — All data persisted locally via **Hive** and **SharedPreferences**. Firebase used for auth and cloud sync.

---

## Built With

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.29+ / Dart 3.2+ |
| **State** | Riverpod 2.x |
| **Routing** | go_router (ShellRoute + nested navigation) |
| **Local Storage** | Hive, SharedPreferences, flutter_secure_storage |
| **Backend** | Firebase (Auth, Firestore, Storage, Analytics, Crashlytics) |
| **Notifications** | flutter_local_notifications + timezone |
| **Charts** | fl_chart |
| **Maps** | flutter_map (OpenStreetMap) |
| **Barcode** | mobile_scanner + OpenFoodFacts HTTP API |
| **Pedometer** | pedometer_2 + sensors_plus |
| **Localization** | easy_localization |
| **Responsive** | flutter_screenutil |
| **Animations** | flutter_animate, lottie |

---

## Screenshots

| Home Dashboard | Workout Log | Nutrition | Profile |
|----------------|-------------|-----------|---------|
| `screenshot1.png` | `screenshot2.png` | `screenshot3.png` | `screenshot4.png` |

> *Screenshots will be added after review.*

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.2.0` [install guide](https://docs.flutter.dev/get-started/install)
- Firebase project with **iOS** and **Android** apps registered
- A physical device or emulator

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/Khalifa125/code_alpha_fit_tracker.git
cd code_alpha_fit_tracker

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
#    - Place google-services.json in android/app/
#    - Place GoogleService-Info.plist in ios/Runner/
#    (Both files are generated from Firebase Console)

# 4. Run on device / emulator
flutter run

# 5. Build release APK
flutter build apk --release

# 6. Build iOS IPA (requires macOS)
flutter build ios --release --no-codesign
```

> ⚠️ The included `GoogleService-Info.plist` is a template. Replace it with your own from [Firebase Console](https://console.firebase.google.com).

---

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── src/
│   ├── app.dart                  # Root widget with Riverpod + startup handler
│   ├── core/
│   │   ├── services/             # Pedometer, Hive, i18n
│   │   └── theme/                # Colors, spacing, dark/light themes
│   ├── features/
│   │   ├── auth/                 # Login, signup, session management
│   │   ├── fitness/              # Workout logging, BMI, history, plans
│   │   ├── nutrition/            # Meal logging, barcode scan
│   │   ├── water/                # Water intake tracking
│   │   ├── sleep/                # Sleep tracking
│   │   ├── heart_rate/           # Heart rate logging
│   │   ├── gamification/         # XP, achievements, streaks, challenges
│   │   ├── dashboard/            # ModernDashboard with progress rings
│   │   ├── home/                 # Tab shell + extracted widgets
│   │   ├── profile/              # User profile, edit profile
│   │   ├── settings/             # App settings
│   │   └── splash/               # Splash screen
│   ├── routing/                  # go_router configuration
│   ├── shared/                   # GlassContainer, buttons, toast
│   └── imports/                  # Barrel exports
├── android/                      # Android native config
├── ios/                          # iOS native config
└── test/                         # Widget tests
```

---

## Code Quality

- `flutter analyze` — **0 issues** (no errors, no warnings, no infos)
- All `// ignore_for_file:` suppressions removed and underlying issues fixed
- Widget tree decomposition: 1855-line `home_page.dart` → 14 focused widget files
- Feature-first folder structure with clear separation of concerns

---

## Internship Context

This application was developed as the capstone deliverable for a software engineering internship at **Code Alpha**. The project demonstrates:

- End-to-end Flutter development from wireframe to production APK/IPA
- Enterprise architecture patterns (Riverpod state management, go_router routing, repository pattern)
- Cross-platform deployment (Android physical device + iOS build pipeline)
- Code quality discipline (zero-lint policy, widget extraction, dead code removal)

---

<p align="center">
  Built with Flutter · Internship Project · Code Alpha<br/>
  <sub>May 2026</sub>
</p>
