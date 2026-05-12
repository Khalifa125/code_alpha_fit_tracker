import 'package:fpdart/fpdart.dart';
import 'package:fit_tracker/src/services/auth_service.dart';
import 'package:fit_tracker/src/utils/failure.dart';
import 'package:fit_tracker/src/utils/typedefs.dart';
import 'package:fit_tracker/src/features/auth/domain/entities/user.dart';
import 'package:fit_tracker/src/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService();

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return Stream.fromFuture(_authService.isLoggedIn()).asyncMap((isLoggedIn) async {
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        return user != null ? AppUser(id: user.id, email: user.email, name: user.name) : null;
      }
      return null;
    });
  }

  @override
  FutureEither<AppUser> login({
    required String email, 
    required String password,
  }) async {
    try {
      final user = await _authService.login(
        email: email,
        password: password,
        name: email.split('@').first,
      );
      return right(AppUser(id: user.id, email: user.email, name: user.name));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppUser> signUp({
    required String name, 
    required String email, 
    required String password,
  }) async {
    try {
      final user = await _authService.login(
        email: email,
        password: password,
        name: name,
      );
      return right(AppUser(id: user.id, email: user.email, name: user.name));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<void> forgotPassword({required String email}) async {
    return right(null);
  }

  @override
  FutureEither<void> logout() async {
    try {
      await _authService.logout();
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          return right(AppUser(id: user.id, email: user.email, name: user.name));
        }
      }
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
