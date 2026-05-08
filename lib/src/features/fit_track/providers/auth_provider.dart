import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/fit_track/services/fittrack_service.dart';
import 'package:fit_tracker/src/features/fit_track/models/user_profile.dart';

final fitTrackServiceProvider = Provider<FitTrackService>((ref) {
  throw UnimplementedError('FitTrackService must be initialized before use');
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(fitTrackServiceProvider);
  return AuthNotifier(service);
});

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserProfile? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    String? errorMessage,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FitTrackService _service;

  AuthNotifier(this._service) : super(AuthState()) {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final user = _service.getUser();
    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      // Simulate sign in - in production, validate against backend
      await Future.delayed(const Duration(seconds: 1));
      
      // Create user (in production, validate credentials)
      final user = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: email.split('@').first,
        email: email,
        isOnboarded: _service.isOnboarded(),
        createdAt: DateTime.now(),
      );
      
      await _service.saveUser(user);
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to sign in. Please check your credentials.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _service.deleteUser();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  Future<void> updateProfile(UserProfile user) async {
    await _service.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<void> completeOnboarding({
    required String goal,
    required String fitnessLevel,
    required int availableMinutes,
  }) async {
    if (state.user == null) return;
    
    final updatedUser = state.user!.copyWith(
      goal: goal,
      fitnessLevel: fitnessLevel,
      availableMinutes: availableMinutes,
      isOnboarded: true,
    );
    
    await _service.saveUser(updatedUser);
    await _service.setOnboarded();
    
    state = state.copyWith(user: updatedUser);
  }
}

final isOnboardedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.isOnboarded ?? false;
});