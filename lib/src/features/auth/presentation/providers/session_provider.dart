import 'dart:async';
import 'package:fit_tracker/src/imports/packages_imports.dart';
import 'package:fit_tracker/src/features/auth/domain/entities/user.dart';
import 'package:fit_tracker/src/features/auth/domain/repositories/auth_repository.dart';

import 'package:fit_tracker/src/features/auth/data/repositories/auth_repository_impl.dart';

/// Provides the AuthRepository instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provides a stream of auth state changes
final authStateStreamProvider = StreamProvider<AppUser?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.onAuthStateChanged;
});

/// Session states
enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState {
  final SessionStatus status;
  final AppUser? user;

  const SessionState({this.status = SessionStatus.unknown, this.user});

  SessionState copyWith({SessionStatus? status, AppUser? user}) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}

/// Provides the current session state
final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(() => SessionNotifier());

class SessionNotifier extends Notifier<SessionState> {
  StreamSubscription<AppUser?>? _authSub;

@override
  SessionState build() {
    Future.microtask(() => _init());
    ref.onDispose(() {
      _authSub?.cancel();
    });
    return const SessionState();
  }

  Future<void> _init() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.checkAuthState();
    result.fold(
      (_) => state = const SessionState(status: SessionStatus.unauthenticated),
      (user) {
        if (user != null) {
          state = SessionState(status: SessionStatus.authenticated, user: user);
        } else {
          state = const SessionState(status: SessionStatus.unauthenticated);
        }
      },
    );

    _authSub = repository.onAuthStateChanged.listen((user) {
      if (user != null) {
        state = SessionState(status: SessionStatus.authenticated, user: user);
      } else {
        state = const SessionState(status: SessionStatus.unauthenticated);
      }
    });
    } catch (_) {
      state = const SessionState(status: SessionStatus.unauthenticated);
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }
}
