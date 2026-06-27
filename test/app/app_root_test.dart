import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/app/app_root.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/core/storage/kv_storage_port.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/features/auth/domain/auth_session.dart';
import 'package:Neralune/features/auth/domain/authenticated_user.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/onboarding/application/revision_goals_controller.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/today/application/today_controller.dart';

import '../fakes/in_memory_activity_api.dart';
import '../fakes/in_memory_documents_api.dart';
import '../fakes/in_memory_revision_goals_repository.dart';
import '../fakes/in_memory_subjects_repository.dart';
import '../fakes/in_memory_today_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedOut();
  }

  @override
  Future<String> requireIdToken() async => 'firebase-id-token';

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> createAccountWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
}

class FakeKvStorage implements KvStoragePort {
  @override
  Future<String?> readString(String key) async => null;

  @override
  Future<void> writeString(String key, String value) async {}
}

void main() {
  testWidgets('AppRoot builds MaterialApp.router from Riverpod providers', (
    tester,
  ) async {
    final authController = AuthController(
      FakeAuthRepository(),
      initialSession: const AuthSession.signedIn(
        AuthenticatedUser(
          uid: 'firebase-123',
          email: 'student@example.com',
          displayName: 'Karim',
        ),
      ),
    );
    addTearDown(authController.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kvStorageProvider.overrideWithValue(FakeKvStorage()),
          authControllerProvider.overrideWithValue(authController),
          subjectsRepositoryProvider.overrideWithValue(
            InMemorySubjectsRepository(),
          ),
          subjectsControllerProvider.overrideWithValue(
            SubjectsController(InMemorySubjectsRepository()),
          ),
          revisionGoalsControllerProvider.overrideWithValue(
            RevisionGoalsController(InMemoryRevisionGoalsRepository()),
          ),
          documentsControllerProvider.overrideWithValue(
            DocumentsController(InMemoryDocumentsApi()),
          ),
          activityControllerProvider.overrideWithValue(
            ActivityController(InMemoryActivityApi()),
          ),
          todayControllerProvider.overrideWithValue(
            TodayController(InMemoryTodayRepository()),
          ),
        ],
        child: const AppRoot(),
      ),
    );
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.darkTheme, isNotNull);
  });
}
