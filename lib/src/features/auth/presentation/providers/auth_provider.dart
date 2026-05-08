import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_tracker/src/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authService.getCurrentUser();
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
    } else {
      state = const AuthState(isLoading: false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    String name = '',
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.login(
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
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = const AuthState(isLoading: false);
  }

  Future<void> updateProfile({String? name}) async {
    if (state.user != null && name != null) {
      final updatedUser = UserModel(
        id: state.user!.id,
        name: name,
        email: state.user!.email,
      );
      await _authService.updateUser(updatedUser);
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