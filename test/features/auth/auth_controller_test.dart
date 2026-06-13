import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.session = const AuthSession.signedOut(),
    this.googleSignInError,
  });

  final List<String> calls = [];
  final AuthSession session;
  final Object? googleSignInError;

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
