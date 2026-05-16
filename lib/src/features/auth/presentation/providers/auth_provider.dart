import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isLoggedIn;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(() => _checkAuthStatus());
    return const AuthState();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final authService = ref.read(authServiceProvider);
      state = state.copyWith(isLoading: true);
      final isLoggedIn = await authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await authService.getCurrentUser();
        state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (_) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    String name = '',
  }) async {
    final authService = ref.read(authServiceProvider);
    state = state.copyWith(isLoading: true);
    try {
      final user = await authService.login(
        email: email,
        password: password,
        name: name,
      );
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    state = state.copyWith(isLoading: true);
    await authService.logout();
    state = const AuthState(isLoading: false);
  }

  Future<void> updateProfile({String? name}) async {
    final authService = ref.read(authServiceProvider);
    if (state.user != null && name != null) {
      final updatedUser = UserModel(
        id: state.user!.id,
        name: name,
        email: state.user!.email,
      );
      await authService.updateUser(updatedUser);
      state = state.copyWith(user: updatedUser);
    }
  }

  void updateUserName(String name) {
    if (state.user != null) {
      final updatedUser = UserModel(
        id: state.user!.id,
        name: name,
        email: state.user!.email,
      );
      state = state.copyWith(user: updatedUser);
    }
  }
}
