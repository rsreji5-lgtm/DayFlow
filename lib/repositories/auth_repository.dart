import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  Future<UserCredential> login(
    String email,
    String password,
  ) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> register(
    String email,
    String password,
  ) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> resetPassword(
    String email,
  ) {
    return _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  Future<void> logout() {
    return _auth.signOut();
  }
}