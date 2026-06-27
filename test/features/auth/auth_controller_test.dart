import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/features/auth/domain/auth_session.dart';
import 'package:Neralune/features/auth/domain/authenticated_user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.session = const AuthSession.signedOut(),
    this.googleSignInError,
    this.emailSignInError,
    this.createAccountError,
    this.passwordResetError,
  });

  final List<String> calls = [];
  final AuthSession session;
  final Object? googleSignInError;
  final Object? emailSignInError;
  final Object? createAccountError;
  final Object? passwordResetError;

  @override
  Stream<AuthSession> watchSession() async* {
    yield session;
  }

  @override
  Future<void> signInWithApple() async {
    calls.add('apple');
  }

  @override
  Future<void> signInWithGoogle() async {
    calls.add('google');
    final error = googleSignInError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    calls.add('emailSignIn:$email:$password');
    final error = emailSignInError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> createAccountWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    calls.add('createAccount:$email:$password');
    final error = createAccountError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    calls.add('passwordReset:$email');
    final error = passwordResetError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
  }

  @override
  Future<String> requireIdToken() async {
    calls.add('token');

    return 'firebase-id-token';
  }
}

class FakeProfileBootstrapper implements AuthProfileBootstrapper {
  int callCount = 0;

  @override
  Future<void> bootstrapCurrentStudent() async {
    callCount += 1;
  }
}

class FakeFirebaseAuthException implements Exception {
  const FakeFirebaseAuthException(this.code);

  final String code;

  @override
  String toString() => '[firebase_auth/$code]';
}

void main() {
  test('delegates Google, Apple, sign out and token requests', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(
      repository,
      initialSession: const AuthSession.signedIn(
        AuthenticatedUser(
          uid: 'firebase-123',
          email: 'student@example.com',
          displayName: 'Karim',
        ),
      ),
    );

    await controller.signInWithGoogle();
    await controller.signInWithApple();
    await controller.signOut();
    final token = await controller.requireIdToken();

    expect(token, 'firebase-id-token');
    expect(repository.calls, ['google', 'apple', 'signOut', 'token']);
  });

  test('delegates Firebase email auth actions with a trimmed email', () async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);

    await controller.signInWithEmailAndPassword(
      email: ' student@example.com ',
      password: 'secret123',
    );
    await controller.createAccountWithEmailAndPassword(
      email: ' student@example.com ',
      password: 'secret123',
    );
    await controller.sendPasswordResetEmail(email: ' student@example.com ');

    expect(repository.calls, [
      'emailSignIn:student@example.com:secret123',
      'createAccount:student@example.com:secret123',
      'passwordReset:student@example.com',
    ]);
  });

  test('maps Firebase email auth failures to user-visible state', () async {
    final controller = AuthController(
      FakeAuthRepository(
        createAccountError: const FakeFirebaseAuthException(
          'email-already-in-use',
        ),
      ),
    );

    await controller.createAccountWithEmailAndPassword(
      email: 'student@example.com',
      password: 'secret123',
    );

    expect(controller.isBusy, isFalse);
    expect(
      controller.errorMessage,
      'Un compte existe déjà avec cette adresse email.',
    );
  });

  test('stores auth action failures as user-visible state', () async {
    final controller = AuthController(
      FakeAuthRepository(googleSignInError: StateError('network failed')),
    );

    await controller.signInWithGoogle();

    expect(controller.isBusy, isFalse);
    expect(controller.errorMessage, 'Connexion impossible pour le moment.');
  });

  test(
    'bootstraps the backend profile when a signed-in session appears',
    () async {
      final bootstrapper = FakeProfileBootstrapper();
      final controller = AuthController(
        FakeAuthRepository(
          session: const AuthSession.signedIn(
            AuthenticatedUser(
              uid: 'firebase-123',
              email: 'student@example.com',
              displayName: 'Karim',
            ),
          ),
        ),
        profileBootstrapper: bootstrapper,
      );

      controller.start();
      await pumpEventQueue();

      expect(controller.isSignedIn, isTrue);
      expect(bootstrapper.callCount, 1);
    },
  );
}
