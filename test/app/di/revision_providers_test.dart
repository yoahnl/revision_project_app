import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/core/config/app_config.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/auth/application/auth_controller.dart';
import 'package:Neralune/features/auth/domain/auth_session.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/onboarding/application/revision_goals_controller.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/today/application/today_controller.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_documents_api.dart';
import '../../fakes/in_memory_revision_goals_repository.dart';
import '../../fakes/in_memory_subjects_repository.dart';
import '../../fakes/in_memory_today_repository.dart';

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

class FakeProfileBootstrapper implements AuthProfileBootstrapper {
  @override
  Future<void> bootstrapCurrentStudent() async {}
}

void main() {
  test('infrastructure provider creates Dio with API base URL', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    expect(dio, isA<Dio>());
    expect(dio.options.baseUrl, AppConfig.apiBaseUrl);
  });

  test('application providers expose runtime controllers', () {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        authProfileBootstrapperProvider.overrideWithValue(
          FakeProfileBootstrapper(),
        ),
        subjectsRepositoryProvider.overrideWithValue(
          InMemorySubjectsRepository(),
        ),
        revisionGoalsRepositoryProvider.overrideWithValue(
          InMemoryRevisionGoalsRepository(),
        ),
        documentsApiProvider.overrideWithValue(InMemoryDocumentsApi()),
        activityApiProvider.overrideWithValue(InMemoryActivityApi()),
        todayRepositoryProvider.overrideWithValue(InMemoryTodayRepository()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(authControllerProvider), isA<AuthController>());
    expect(
      container.read(subjectsControllerProvider),
      isA<SubjectsController>(),
    );
    expect(
      container.read(revisionGoalsControllerProvider),
      isA<RevisionGoalsController>(),
    );
    expect(
      container.read(documentsControllerProvider),
      isA<DocumentsController>(),
    );
    expect(
      container.read(activityControllerProvider),
      isA<ActivityController>(),
    );
    expect(container.read(todayControllerProvider), isA<TodayController>());
  });
}
