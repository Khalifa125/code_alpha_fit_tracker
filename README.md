# CodeAlpha_FitnessTracker

> **Task 3 — App Development Internship @ CodeAlpha**
> Intern: Mohamed Gamal Abdelkader Mohamed Khalifa | ID: CA/DF1/51128

---

## 📱 Features

| Feature | Description |
|--------|-------------|
| 🏠 **Dashboard** | Daily stats (calories, steps, active minutes) + weekly bar chart + goal progress |
| ➕ **Log Activity** | 8 activity types with auto-calorie calculation |
| 🏋️ **Workout Plans** | 6 preset plans (Beginner → Advanced), filterable by level/category |
| ⚖️ **BMI Calculator** | BMI result with visual scale + weight history chart |
| 📋 **History** | All activities grouped by date, swipe-to-delete |
| 💾 **Local Storage** | SharedPreferences — works offline, no backend needed |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| Charts | fl_chart |
| Storage | SharedPreferences |
| UI | flutter_screenutil + flutter_animate |
| Auth | Firebase Auth (ready) |

---

## 🚀 Getting Started

```bash
# 1. Install dependencies
flutter pub get

# 2. Run code generation (Firebase, etc.)
dart run build_runner build --delete-conflicting-outputs

# 3. Run localization (if using easy_localization)
flutter pub run easy_localization:generate -S assets/translations -O lib/src/core/i18n -o locale_keys.g.dart

# 4. Add Firebase (optional for auth)
# Follow setup at: https://firebase.google.com/docs/flutter/setup

# 5. Build native splash screen
dart run flutter_native_splash:create --path=flutter_native_splash.yaml

# 6. Run
flutter run
```

### Environment Variables

Create a `.env` file in the project root with required variables:
```
API_URL=https://api.example.com
```

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Permissions

Configure in `ios/Podfile` - see [SETUP.md](SETUP.md) for complete permission configuration.

### Firebase Setup

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

---

## 📁 Project Structure

```
lib/src/
├── features/
│   ├── fitness/
│   │   ├── data/
│   │   │   ├── models/         # ActivityModel, WeightModel, FitnessProfileModel
│   │   │   └── repositories/   # WorkoutPlansData (static data)
│   │   ├── domain/
│   │   │   └── entities/       # Activity, WeightEntry, FitnessProfile, WorkoutPlan
│   │   └── presentation/
│   │       ├── providers/      # Riverpod providers
│   │       ├── screens/        # Dashboard, AddActivity, History, WorkoutPlans, BMI
│   │       └── widgets/        # FitStatCard, FitProgressBar, ActivityTile, ...
│   ├── auth/                   # Login, Signup, ForgotPassword (Firebase ready)
│   ├── home/                   # Main dashboard (HomePage)
│   └── onboarding/             # 3-page onboarding
├── theme/                      # Colors, typography, spacing
├── routing/                    # GoRouter config
└── services/                   # Auth, storage, permissions
```
