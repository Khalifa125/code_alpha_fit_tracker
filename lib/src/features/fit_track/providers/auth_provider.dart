import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/features/fit_track/services/fittrack_service.dart';
import 'package:fit_tracker/src/features/fit_track/models/user_profile.dart';

final fitTrackServiceProvider = Provider<FitTrackService>((ref) {
  throw UnimplementedError('FitTrackService must be initialized before use');
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

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

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => _checkAuthStatus());
    return AuthState();
  }

  void _checkAuthStatus() {
    try {
      final service = ref.read(fitTrackServiceProvider);
      final user = service.getUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> signIn(String email, String password) async {
    final service = ref.read(fitTrackServiceProvider);
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final user = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: email.split('@').first,
        email: email,
        isOnboarded: service.isOnboarded(),
        createdAt: DateTime.now(),
      );
      
      await service.saveUser(user);
      
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
    final service = ref.read(fitTrackServiceProvider);
    await service.deleteUser();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  Future<void> updateProfile(UserProfile user) async {
    final service = ref.read(fitTrackServiceProvider);
    await service.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<void> completeOnboarding({
    required String goal,
    required String fitnessLevel,
    required int availableMinutes,
  }) async {
    final service = ref.read(fitTrackServiceProvider);
    if (state.user == null) return;
    
    final updatedUser = state.user!.copyWith(
      goal: goal,
      fitnessLevel: fitnessLevel,
      availableMinutes: availableMinutes,
      isOnboarded: true,
    );
    
    await service.saveUser(updatedUser);
    await service.setOnboarded();
    
    state = state.copyWith(user: updatedUser);
  }
}

final isOnboardedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.isOnboarded ?? false;
});
