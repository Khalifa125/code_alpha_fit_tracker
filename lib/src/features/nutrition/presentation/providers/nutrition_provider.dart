import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/core/services/nutrition_api_service.dart';
import 'package:fit_tracker/src/core/services/hive_storage_service.dart';

class NutritionEntry {
  final String id;
  final String name;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;
  final double grams;
  final String mealType;
  final DateTime date;

  NutritionEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.grams,
    required this.mealType,
    required this.date,
  });
}

class NutritionState {
  final List<NutritionEntry> entries;
  final double calorieGoal;
  final int proteinGoal;
  final int carbsGoal;
  final int fatGoal;
  final bool isLoading;
  final String? error;

  const NutritionState({
    this.entries = const [],
    this.calorieGoal = 2000,
    this.proteinGoal = 150,
    this.carbsGoal = 250,
    this.fatGoal = 65,
    this.isLoading = false,
    this.error,
  });

  double get totalCalories => entries.fold(0, (sum, e) => sum + e.calories);
  double get totalCarbs => entries.fold(0, (sum, e) => sum + e.carbs);
  double get totalProtein => entries.fold(0, (sum, e) => sum + e.protein);
  double get totalFat => entries.fold(0, (sum, e) => sum + e.fat);
  double get remaining => calorieGoal - totalCalories;

  List<NutritionEntry> entriesForDate(DateTime date) =>
      entries.where((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day).toList();

  NutritionState copyWith({
    List<NutritionEntry>? entries,
    double? calorieGoal,
    int? proteinGoal,
    int? carbsGoal,
    int? fatGoal,
    bool? isLoading,
    String? error,
  }) {
    return NutritionState(
      entries: entries ?? this.entries,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NutritionNotifier extends Notifier<NutritionState> {
  @override
  NutritionState build() {
    _loadFromStorage();
    return const NutritionState();
  }

  Future<void> _loadFromStorage() async {
    final entries = await HiveStorageService.loadNutritionEntries();
    final goal = await HiveStorageService.loadCalorieGoal();
    final proteinGoal = await HiveStorageService.loadMacroGoal('proteinGoal') ?? 150;
    final carbsGoal = await HiveStorageService.loadMacroGoal('carbsGoal') ?? 250;
    final fatGoal = await HiveStorageService.loadMacroGoal('fatGoal') ?? 65;
    state = NutritionState(
      entries: entries,
      calorieGoal: goal,
      proteinGoal: proteinGoal,
      carbsGoal: carbsGoal,
      fatGoal: fatGoal,
    );
  }

  Future<void> _persistEntries() => HiveStorageService.saveNutritionEntries(state.entries);
  Future<void> _persistGoal() => HiveStorageService.saveCalorieGoal(state.calorieGoal);

  void addEntry(NutritionEntry entry) {
    state = state.copyWith(entries: [...state.entries, entry]);
    _persistEntries();
  }

  void removeEntry(String id) {
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
    _persistEntries();
  }

  void setCalorieGoal(double goal) {
    state = state.copyWith(calorieGoal: goal);
    _persistGoal();
  }

  void setProteinGoal(int goal) {
    state = state.copyWith(proteinGoal: goal);
    HiveStorageService.saveMacroGoal('proteinGoal', goal);
  }

  void setCarbsGoal(int goal) {
    state = state.copyWith(carbsGoal: goal);
    HiveStorageService.saveMacroGoal('carbsGoal', goal);
  }

  void setFatGoal(int goal) {
    state = state.copyWith(fatGoal: goal);
    HiveStorageService.saveMacroGoal('fatGoal', goal);
  }

  void clearEntries() {
    state = state.copyWith(entries: []);
    _persistEntries();
  }
}

final nutritionProvider = NotifierProvider<NutritionNotifier, NutritionState>(() => NutritionNotifier());

final foodSearchProvider = NotifierProvider<FoodSearchNotifier, FoodSearchState>(() => FoodSearchNotifier());

class FoodSearchState {
  final String query;
  final List<FoodModel> results;
  final bool isLoading;
  final String? error;

  const FoodSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  FoodSearchState copyWith({
    String? query,
    List<FoodModel>? results,
    bool? isLoading,
    String? error,
  }) {
    return FoodSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FoodSearchNotifier extends Notifier<FoodSearchState> {
  @override
  FoodSearchState build() => const FoodSearchState();

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(query: '', results: []);
      return;
    }

    state = state.copyWith(query: query, isLoading: true, error: null);
    
    try {
      final results = await openFoodFactsApi.searchFood(query);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clear() {
    state = const FoodSearchState();
  }
}

final selectedFoodProvider = Provider<FoodModel?>((ref) => null);
final foodQuantityProvider = Provider<double>((ref) => 100);
