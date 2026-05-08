import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/core/services/nutrition_api_service.dart';

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
  final bool isLoading;
  final String? error;

  const NutritionState({
    this.entries = const [],
    this.calorieGoal = 2000,
    this.isLoading = false,
    this.error,
  });

  double get totalCalories => entries.fold(0, (sum, e) => sum + e.calories);
  double get totalCarbs => entries.fold(0, (sum, e) => sum + e.carbs);
  double get totalProtein => entries.fold(0, (sum, e) => sum + e.protein);
  double get totalFat => entries.fold(0, (sum, e) => sum + e.fat);
  double get remaining => calorieGoal - totalCalories;

  NutritionState copyWith({
    List<NutritionEntry>? entries,
    double? calorieGoal,
    bool? isLoading,
    String? error,
  }) {
    return NutritionState(
      entries: entries ?? this.entries,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier() : super(const NutritionState());

  void addEntry(NutritionEntry entry) {
    state = state.copyWith(entries: [...state.entries, entry]);
  }

  void removeEntry(String id) {
    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
  }

  void setCalorieGoal(double goal) {
    state = state.copyWith(calorieGoal: goal);
  }

  void clearEntries() {
    state = state.copyWith(entries: []);
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  return NutritionNotifier();
});

final foodSearchProvider = StateNotifierProvider<FoodSearchNotifier, FoodSearchState>((ref) {
  return FoodSearchNotifier();
});

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

class FoodSearchNotifier extends StateNotifier<FoodSearchState> {
  FoodSearchNotifier() : super(const FoodSearchState());

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

final selectedFoodProvider = StateProvider<FoodModel?>((ref) => null);
final foodQuantityProvider = StateProvider<double>((ref) => 100);