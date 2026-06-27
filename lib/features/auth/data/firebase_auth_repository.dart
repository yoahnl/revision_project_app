import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../application/auth_controller.dart';
import '../domain/auth_session.dart';
import '../domain/authenticated_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AuthSession> watchSession() {
    return _firebaseAuth.authStateChanges().map(_toSession);
  }

  @override
  Future<void> signInWithGoogle() async {
    final provider = GoogleAuthProvider();

    if (kIsWeb) {
      await _firebaseAuth.signInWithPopup(provider);
      return;
    }

    await _firebaseAuth.signInWithProvider(provider);
  }

  @override
  Future<void> signInWithApple() async {
    final provider = AppleAuthProvider();

    if (kIsWeb) {
      await _firebaseAuth.signInWithPopup(provider);
      return;
    }

    await _firebaseAuth.signInWithProvider(provider);
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> createAccountWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<String> requireIdToken() async {
    final token = await _firebaseAuth.currentUser?.getIdToken(true);

    if (token == null || token.trim().isEmpty) {
      throw StateError('A signed-in Firebase user is required');
    }

    return token;
  }
}

AuthSession _toSession(User? user) {
  if (user == null) {
    return const AuthSession.signedOut();
  }

  return AuthSession.signedIn(
    AuthenticatedUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    ),
  );
}
