# FitTrack — Full Functional Flutter App Prompt

You are a senior Flutter developer. Build a **complete, fully functional** Flutter fitness app called **"Fit Track"** where **every single feature works for real** — no dummy data, no placeholders, no TODO comments.

---

## 🎨 Design System (MANDATORY — do not change)

- **Dark background:** `#0D1117`
- **Card surface:** `#1C2333`
- **Border:** `#30363D`
- **Primary / Neon Green:** `#22C55E`
- **Orange:** `#FF6B35`
- **Blue:** `#3B82F6`
- **Purple:** `#8B5CF6`
- **Text primary:** `#F0F6FC`
- **Text secondary:** `#8B949E`
- Font: **Poppins**
- All cards: rounded corners `16–20px`, subtle border, dark fill
- Bottom nav: 5 tabs — Home, Workout, Activity, Nutrition, Profile

---

## 📦 Required Packages (add all to pubspec.yaml)

```yaml
# Core
flutter_riverpod: ^2.6.1
go_router: ^13.0.0
equatable: ^2.0.7

# Firebase
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
cloud_firestore: ^5.0.0

# Sensors — REAL steps + location
pedometer: ^4.0.2
geolocator: ^13.0.0
sensors_plus: ^5.0.0

# Nutrition API
http: ^1.2.0
mobile_scanner: ^5.0.0        # barcode scan

# Workout timer + notifications
flutter_local_notifications: ^17.0.0
flutter_background_service: ^5.0.0

# Storage
shared_preferences: ^2.2.0
hive_flutter: ^1.1.0
hive: ^2.2.0

# UI
flutter_screenutil: ^5.9.3
flutter_animate: ^4.5.2
fl_chart: ^0.68.0
cached_network_image: ^3.3.0
flutter_svg: ^2.0.0

# Auth
google_sign_in: ^6.2.0

# Utils
intl: ^0.19.0
uuid: ^4.3.3
permission_handler: ^11.3.0
```

---

## 🏗️ Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── src/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # All FitColors tokens
│   │   │   └── app_constants.dart
│   │   ├── services/
│   │   │   ├── pedometer_service.dart   # Real step counting
│   │   │   ├── location_service.dart    # GPS distance tracking
│   │   │   ├── notification_service.dart
│   │   │   └── background_service.dart
│   │   └── utils/
│   │       ├── calorie_calculator.dart  # MET-based formula
│   │       └── distance_calculator.dart # Haversine formula
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_repository_impl.dart  # Firebase Auth
│   │   │   ├── domain/
│   │   │   │   └── auth_repository.dart
│   │   │   └── presentation/
│   │   │       ├── providers/auth_provider.dart
│   │   │       └── screens/
│   │   │           ├── splash_screen.dart
│   │   │           ├── onboarding_screen.dart
│   │   │           ├── login_screen.dart
│   │   │           └── signup_screen.dart
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       ├── shell/fit_track_shell.dart  # 5-tab shell
│   │   │       └── screens/home_tab.dart
│   │   ├── activity/
│   │   │   ├── data/
│   │   │   │   ├── models/activity_model.dart
│   │   │   │   └── repositories/activity_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/activity.dart
│   │   │   │   └── repositories/activity_repository.dart
│   │   │   └── presentation/
│   │   │       ├── providers/activity_provider.dart
│   │   │       └── screens/
│   │   │           ├── activity_tab.dart
│   │   │           ├── add_activity_screen.dart
│   │   │           └── history_screen.dart
│   │   ├── workout/
│   │   │   ├── data/
│   │   │   │   └── workout_plans_data.dart     # 6 real plans
│   │   │   ├── domain/
│   │   │   │   └── entities/workout_plan.dart
│   │   │   └── presentation/
│   │   │       ├── providers/workout_provider.dart
│   │   │       └── screens/
│   │   │           ├── workout_tab.dart
│   │   │           ├── workout_detail_screen.dart
│   │   │           └── workout_player_screen.dart  # Real timer
│   │   ├── nutrition/
│   │   │   ├── data/
│   │   │   │   ├── models/food_model.dart
│   │   │   │   ├── repositories/nutrition_repository_impl.dart
│   │   │   │   └── datasources/openfoodfacts_api.dart  # Real API
│   │   │   ├── domain/
│   │   │   │   ├── entities/food_entry.dart
│   │   │   │   └── repositories/nutrition_repository.dart
│   │   │   └── presentation/
│   │   │       ├── providers/nutrition_provider.dart
│   │   │       └── screens/
│   │   │           ├── nutrition_tab.dart
│   │   │           ├── food_search_screen.dart
│   │   │           └── barcode_scan_screen.dart
│   │   ├── bmi/
│   │   │   └── presentation/
│   │   │       ├── providers/bmi_provider.dart
│   │   │       └── screens/bmi_screen.dart
│   │   └── profile/
│   │       └── presentation/
│   │           ├── providers/profile_provider.dart
│   │           └── screens/profile_tab.dart
│   └── shared/
│       └── widgets/
│           ├── fit_stat_card.dart
│           ├── fit_progress_bar.dart
│           ├── activity_tile.dart
│           └── fit_bottom_nav.dart
```

---

## ✅ Feature Specifications — FULLY FUNCTIONAL

### 1. Authentication (Firebase)
- Email/password signup & login with **real Firebase Auth**
- Google Sign-In with `google_sign_in` package
- `StreamProvider` listening to `FirebaseAuth.instance.authStateChanges()`
- On auth state change → auto-navigate (GoRouter redirect)
- Store user profile in **Firestore** (`users/{uid}`)
- Persist session — app reopens directly to home if logged in

### 2. Real Step Counter (Pedometer)
```dart
// pedometer_service.dart
import 'package:pedometer/pedometer.dart';

class PedometerService {
  Stream<StepCount> get stepCountStream => Pedometer.stepCountStream;
  Stream<PedestrianStatus> get pedestrianStatusStream => Pedometer.pedestrianStatusStream;
}
```
- Listen to `Pedometer.stepCountStream` — real hardware sensor
- Store daily step baseline at midnight reset
- Calculate today's steps = current - baseline
- Steps saved to **Firestore** + **Hive** (offline cache)
- Show live steps on Home dashboard — updates every step
- Calories from steps: `steps * 0.04` kcal

### 3. GPS Distance Tracking (Geolocator)
```dart
// location_service.dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Request permission on first use
  // Stream positions during active workout
  // Calculate distance using Haversine formula
  double calculateDistance(List<Position> positions) {
    // sum of Geolocator.distanceBetween() between consecutive points
  }
}
```
- Only activates when user starts a **Running** or **Walking** activity
- Tracks route in real-time, calculates total distance in km
- Distance shown on Home dashboard
- Distance saved with each activity log
- Permissions handled gracefully with `permission_handler`

### 4. Workout Player (Real Timer + Background Notification)
```dart
// workout_player_screen.dart
class WorkoutPlayerScreen extends ConsumerStatefulWidget {
  // Real countdown timer using Timer.periodic
  // Shows current exercise name, sets x reps
  // Rest timer between sets (30s countdown)
  // Play/Pause/Skip controls
  // Progress: exercise 3/5
}
```
- `flutter_local_notifications` — persistent notification showing:
  - Exercise name
  - Time remaining
  - Pause/Resume action button
- `flutter_background_service` — timer keeps running if app is backgrounded
- On workout complete → save to Firestore + Hive with:
  - Total duration
  - Calories burned (MET × weight × hours)
  - Exercises completed

### 5. Nutrition — OpenFoodFacts API
```dart
// openfoodfacts_api.dart
class OpenFoodFactsApi {
  static const _base = 'https://world.openfoodfacts.org';

  // Search by name
  Future<List<FoodModel>> searchFood(String query) async {
    final url = '$_base/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=20';
    // parse response → FoodModel list
  }

  // Search by barcode
  Future<FoodModel?> getByBarcode(String barcode) async {
    final url = '$_base/api/v0/product/$barcode.json';
    // parse response → FoodModel
  }
}
```
- Food search screen with live search (debounced 500ms)
- Barcode scanner using `mobile_scanner`
- Each food entry saved to Firestore `nutrition/{uid}/entries`
- Daily calorie total calculated from real entries
- Macros (carbs/protein/fat) from real API data
- Circular progress shows calories consumed vs daily goal

### 6. BMI Calculator
- Height, weight, age inputs saved to Firestore `users/{uid}/profile`
- BMI = weight / (height/100)²
- Real BMI categories with color-coded scale
- Weight history chart from Firestore data (real entries over time)
- Daily weight logging

### 7. Home Dashboard (All Real Data)
- **Greeting:** user's real name from Firestore
- **Steps circle:** live from Pedometer stream
- **Calories:** sum of today's logged activities (from Hive/Firestore)
- **Distance:** sum of today's GPS-tracked activities
- **Active time:** sum of today's workout durations
- **Goals progress bars:** compared to goals saved in user profile
- **Weekly chart:** real data from last 7 days activities

### 8. Activity Tab
- Weekly bar chart — real calories per day from Firestore
- Steps stats — real pedometer data
- Filter by: Day / Week / Month / Year
- Average steps, best day — calculated from real history

### 9. Profile Tab
- User photo from Firebase Auth (Google profile pic)
- Real stats: total workouts, days active, goals achieved (from Firestore)
- Edit profile → saves to Firestore
- Sign out → clears local cache + navigates to login

---

## 🔌 Data Flow (How Everything Connects)

```
Hardware Sensors
    ├── Pedometer → PedometerService → stepCountProvider → HomeTab + ActivityTab
    └── GPS → LocationService → activeWorkoutProvider → WorkoutPlayer + ActivityLog

Firebase
    ├── Auth → authStateProvider → GoRouter redirect
    ├── Firestore users/{uid} → profileProvider → Profile + Home greeting
    ├── Firestore activities/{uid}/logs → activityProvider → Home + Activity + History
    └── Firestore nutrition/{uid}/entries → nutritionProvider → NutritionTab

Local Cache (Hive)
    ├── activities box → offline access to recent activities
    ├── steps box → daily step baseline
    └── nutrition box → today's food entries cache

OpenFoodFacts API
    └── http → OpenFoodFactsApi → nutritionProvider → NutritionTab
```

---

## 🔒 Permissions Required

### AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

### iOS Info.plist
```xml
<key>NSMotionUsageDescription</key>
<string>Fit Track needs motion access to count your steps</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Fit Track needs location to track your running distance</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Fit Track tracks your route during workouts</string>
<key>NSCameraUsageDescription</key>
<string>Fit Track needs camera to scan food barcodes</string>
```

---

## ⚙️ Providers Architecture (Riverpod)

```dart
// All providers must be properly connected:

// Auth
final authRepositoryProvider = Provider<AuthRepository>(...);
final authStateProvider = StreamProvider<User?>(...);  // FirebaseAuth stream

// Steps — REAL live stream
final stepCountProvider = StreamProvider<int>((ref) {
  return ref.watch(pedometerServiceProvider).stepCountStream
    .map((event) => event.steps);
});

// Location — active during workout
final locationServiceProvider = Provider<LocationService>(...);
final activeRouteProvider = StateNotifierProvider<ActiveRouteNotifier, RouteState>(...);

// Activity
final activityRepositoryProvider = Provider<ActivityRepository>(...);
final todayActivitiesProvider = StreamProvider<List<Activity>>(...);  // Firestore stream
final weeklyCaloriesProvider = FutureProvider<Map<String, double>>(...);

// Workout
final workoutPlayerProvider = StateNotifierProvider<WorkoutPlayerNotifier, WorkoutPlayerState>(...);

// Nutrition
final nutritionRepositoryProvider = Provider<NutritionRepository>(...);
final todayNutritionProvider = StreamProvider<List<FoodEntry>>(...);  // Firestore stream
final foodSearchProvider = StateNotifierProvider<FoodSearchNotifier, FoodSearchState>(...);

// Profile
final userProfileProvider = StreamProvider<UserProfile?>(...);  // Firestore stream

// Home computed
final dailySummaryProvider = Provider<DailySummary>((ref) {
  // Combines: todayActivities + stepCount + activeRoute
  // Returns: totalCalories, totalSteps, totalDistance, totalMinutes
});
```

---

## 📱 Screen-by-Screen Requirements

### SplashScreen
- Check `FirebaseAuth.instance.currentUser`
- If logged in → HomeShell
- If not → Onboarding (first time) or Login

### OnboardingScreen
- 3 pages with smooth PageView
- `SharedPreferences` to track if seen
- "Get Started" → LoginScreen

### LoginScreen
- Real Firebase email/password login
- Google Sign-In button (working)
- Error messages from Firebase exceptions
- Loading state on button

### SignupScreen
- Create Firebase user
- Save name to Firestore `users/{uid}.name`
- Auto-login after signup

### HomeTab
- All data from real providers (steps, calories, distance)
- Pull-to-refresh invalidates all providers
- Greeting uses real user name

### ActivityTab
- Real weekly bar chart from Firestore
- Tab selector (Day/Week/Month/Year) filters real data

### WorkoutTab → WorkoutDetailScreen → WorkoutPlayerScreen
- Player has real countdown timer (`Timer.periodic`)
- Background notification via `flutter_local_notifications`
- On complete → write activity to Firestore with real duration + calories

### NutritionTab
- Today's entries from Firestore stream
- Calorie circle = real sum of entries vs goal
- FAB → FoodSearchScreen (OpenFoodFacts) or BarcodeScanScreen

### FoodSearchScreen
- TextField with debounce → OpenFoodFacts API call
- Results list with food name + calories per 100g
- Tap food → enter grams → calculate calories → save to Firestore

### BarcodeScanScreen
- `mobile_scanner` camera view
- On scan → OpenFoodFacts barcode API → show product → add to diary

### BMIScreen
- Save measurements to Firestore
- Weight history chart from real Firestore entries

### ProfileTab
- Real user data from Firestore
- Edit name/goals → saved to Firestore
- Sign out button → Firebase signOut + clear Hive

---

## 🚫 Absolute Rules

1. **NO** dummy/hardcoded data anywhere except workout plans
2. **NO** `Future.delayed` faking network calls
3. **NO** `TODO` or `// implement later` comments
4. **EVERY** button must do something real
5. **ALL** providers must be connected to real data sources
6. **Steps** must come from `Pedometer.stepCountStream` — not a variable
7. **Distance** must come from `Geolocator.getPositionStream()` — not a formula on fake data
8. **Nutrition data** must come from OpenFoodFacts API — not a hardcoded list
9. **Auth** must use Firebase — not a stub service
10. Error handling on every async operation with user-visible messages

---

## 📋 Calorie Calculations (Real Formulas)

```dart
// calorie_calculator.dart

// From steps
double caloriesFromSteps(int steps, double weightKg) {
  return steps * 0.04 * (weightKg / 70);
}

// From activity (MET-based)
double caloriesFromActivity({
  required String type,
  required int durationMinutes,
  required double weightKg,
}) {
  const mets = {
    'Running': 9.8,
    'Walking': 3.5,
    'Cycling': 7.5,
    'Swimming': 8.0,
    'Gym': 5.0,
    'Yoga': 2.5,
    'HIIT': 12.0,
  };
  final met = mets[type] ?? 5.0;
  return met * weightKg * (durationMinutes / 60);
}

// BMI
double calculateBMI(double weightKg, double heightCm) {
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}
```

---

## 🗄️ Firestore Schema

```
users/
  {uid}/
    name: string
    email: string
    photoUrl: string
    heightCm: number
    weightKg: number
    age: number
    gender: string
    goalCalories: number      # daily calorie burn goal
    goalSteps: number         # default 10000
    goalMinutes: number       # default 60
    createdAt: timestamp

activities/
  {uid}/
    logs/
      {activityId}/
        type: string
        durationMinutes: number
        caloriesBurned: number
        steps: number
        distanceKm: number
        date: timestamp
        notes: string

nutrition/
  {uid}/
    entries/
      {entryId}/
        foodName: string
        calories: number
        carbs: number
        protein: number
        fat: number
        grams: number
        mealType: string       # breakfast/lunch/dinner/snack
        date: timestamp

weights/
  {uid}/
    entries/
      {entryId}/
        weightKg: number
        date: timestamp
```

---

## 🔔 Background Notification (Workout Player)

```dart
// notification_service.dart
class NotificationService {
  // Initialize flutter_local_notifications
  // Show persistent notification during workout:
  //   Title: "Dumbbell Squats — Exercise 3/5"
  //   Body: "Rest time: 00:28"
  //   Actions: [Pause] [Skip]
  // Update notification every second
  // Cancel on workout complete/exit
}
```

---

## 🏁 Output Requirements

- Generate **every file** listed in the folder structure
- Each file must be **complete and compilable**
- All imports must be correct
- `pubspec.yaml` must include all packages
- `AndroidManifest.xml` changes listed
- `Info.plist` changes listed
- `firebase_options.dart` — provide the template (user fills in their values)
- App must run with `flutter run` after `flutter pub get`