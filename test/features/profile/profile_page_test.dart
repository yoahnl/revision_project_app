import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/core/storage/kv_storage_port.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/features/auth/domain/auth_session.dart';
import 'package:Neralune/features/auth/domain/authenticated_user.dart';
import 'package:Neralune/presentation/pages/profile/profile_page.dart';

class FakeKvStorage implements KvStoragePort {
  final values = <String, String>{};

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }
}

class FakeAuthRepository implements AuthRepository {
  final calls = <String>[];

  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedIn(
      AuthenticatedUser(
        uid: 'user-1',
        email: 'karim@example.test',
        displayName: 'Karim',
      ),
    );
  }

  @override
  Future<void> signInWithApple() async {
    calls.add('apple');
  }

  @override
  Future<void> signInWithGoogle() async {
    calls.add('google');
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
  }

  @override
  Future<String> requireIdToken() async => 'token';
}

void main() {
  testWidgets('shows real account data without fake gamification', (
    tester,
  ) async {
    final controller = AuthController(FakeAuthRepository());
    controller.start();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(FakeKvStorage())],
        child: MaterialApp(home: ProfilePage(authController: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Karim'), findsOneWidget);
    expect(find.text('karim@example.test'), findsOneWidget);
    expect(find.text('Thème'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.textContaining('gemmes'), findsNothing);
    expect(find.textContaining('badge'), findsNothing);
  });

  testWidgets('delegates sign out to the auth controller', (tester) async {
    final repository = FakeAuthRepository();
    final controller = AuthController(repository);
    controller.start();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(FakeKvStorage())],
        child: MaterialApp(home: ProfilePage(authController: controller)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Se déconnecter'));
    await tester.pump();

    expect(repository.calls, contains('signOut'));
  });
}
