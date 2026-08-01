import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  StreamSubscription<User?>?
      _subscription;

  AuthCubit(
    this.repository,
  ) : super(const AuthInitial());

  void listenToAuthChanges() {
    _subscription?.cancel();

    _subscription =
        repository.authStateChanges.listen(
      (user) {
        if (user == null) {
          emit(
            const AuthUnauthenticated(),
          );
        } else {
          emit(
            AuthAuthenticated(
              user.email ?? '',
            ),
          );
        }
      },
    );
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    emit(const AuthLoading());

    try {
      await repository.login(
        email,
        password,
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          _message(e.code),
        ),
      );

      emit(
        const AuthUnauthenticated(),
      );
    } catch (_) {
      emit(
        const AuthError(
          'Something went wrong. Please try again.',
        ),
      );

      emit(
        const AuthUnauthenticated(),
      );
    }
  }

  Future<void> register(
    String email,
    String password,
  ) async {
    emit(const AuthLoading());

    try {
      await repository.register(
        email,
        password,
      );
    } on FirebaseAuthException catch (e) {
      emit(
        AuthError(
          _message(e.code),
        ),
      );

      emit(
        const AuthUnauthenticated(),
      );
    } catch (_) {
      emit(
        const AuthError(
          'Something went wrong. Please try again.',
        ),
      );

      emit(
        const AuthUnauthenticated(),
      );
    }
  }

  Future<void> resetPassword(
    String email,
  ) async {
    try {
      await repository.resetPassword(
        email,
      );
    } catch (_) {}
  }

  Future<void> logout() {
    return repository.logout();
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
        return 'Incorrect email or password.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password must be at least 6 characters.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}