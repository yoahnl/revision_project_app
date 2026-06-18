import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/app_root.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/core/storage/kv_storage_port.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/mvp/application/mvp_study_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

import '../fakes/in_memory_activity_api.dart';
import '../fakes/in_memory_documents_api.dart';
import '../fakes/in_memory_revision_goals_repository.dart';
import '../fakes/in_memory_subjects_repository.dart';
import '../fakes/in_memory_today_repository.dart';

class SignedInAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedIn(
      AuthenticatedUser(
        uid: 'firebase-123',
        email: 'student@example.com',
        displayName: 'Karim',
      ),
    );
  }

  @override
  Future<String> requireIdToken() async => 'firebase-id-token';

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class SignedOutAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedOut();
  }

  @override
  Future<String> requireIdToken() async {
    throw StateError('A signed-in user is required');
  }

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

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
  setUp(() {
    MvpStudyController.instance.resetForTests();
  });

  testWidgets('shows the MVP home as the first app screen', (tester) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    expect(find.text('Math'), findsWidgets);
    expect(find.text('Reprendre le cours'), findsOneWidget);
    expect(find.text('Loi normale'), findsWidgets);
    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Révisions'), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsOneWidget);
    expect(testApp.authController.isSignedIn, isTrue);
  });

  testWidgets('changes MVP routes when tapping bottom navigation', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progrès'));
    await tester.pumpAndSettle();

    expect(find.text('Ta progression en un coup d’œil'), findsOneWidget);

    await tester.tap(find.text('Révisions'));
    await tester.pumpAndSettle();

    expect(find.text('Choisis ton mode de travail'), findsOneWidget);

    await tester.tap(find.text('Sources'));
    await tester.pumpAndSettle();

    expect(find.text('Fichiers attachés aux cours de Math'), findsOneWidget);
  });

  testWidgets('subject switcher changes active MVP subject', (tester) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Math').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Philosophie').last);
    await tester.pumpAndSettle();

    expect(find.text('Kant'), findsWidgets);
    expect(find.text('Tes cours de Philosophie'), findsOneWidget);
  });

  testWidgets('course flow opens detail, session and result', (tester) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionCourseCard, 'Loi normale'));
    await tester.pumpAndSettle();

    expect(find.text('Révision rapide'), findsOneWidget);

    await tester.tap(find.text('Révision rapide'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 sur 2'), findsOneWidget);
    await tester.tap(find.text('0,6826'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect(find.text('Bonne réponse, on continue.'), findsOneWidget);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).last, const Offset(0, 420));
    await tester.pumpAndSettle();
    expect(find.text('Question 2 sur 2'), findsOneWidget);
    await tester.tap(find.text('Standardiser avec Z'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Belle progression !'), findsOneWidget);
  });

  testWidgets('uses route-driven navigation rail on wide layouts', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(1200, 900);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    expect(find.byType(RevisionNavigationRail), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);

    await tester.tap(find.text('Révisions'));
    await tester.pumpAndSettle();

    expect(find.text('Révisions'), findsWidgets);
    expect(find.text('Choisis ton mode de travail'), findsOneWidget);
  });

  testWidgets('redirects signed-out users to the sign-in page', (tester) async {
    await tester.pumpWidget(
      _createTestApp(
        authController: AuthController(SignedOutAuthRepository()),
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Continuer avec Apple'), findsOneWidget);
  });
}

AuthController signedInAuthController() {
  return AuthController(SignedInAuthRepository());
}

_RevisionTestApp _createTestApp({AuthController? authController}) {
  final resolvedAuthController = authController ?? signedInAuthController();
  final subjectsRepository = InMemorySubjectsRepository();
  final revisionGoalsRepository = InMemoryRevisionGoalsRepository();
  final documentsApi = InMemoryDocumentsApi();
  final activityApi = InMemoryActivityApi();
  final todayRepository = InMemoryTodayRepository();

  resolvedAuthController.start();
  addTearDown(resolvedAuthController.dispose);

  final widget = ProviderScope(
    overrides: [
      kvStorageProvider.overrideWithValue(FakeKvStorage()),
      authControllerProvider.overrideWithValue(resolvedAuthController),
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      subjectsControllerProvider.overrideWithValue(
        SubjectsController(subjectsRepository),
      ),
      revisionGoalsControllerProvider.overrideWithValue(
        RevisionGoalsController(revisionGoalsRepository),
      ),
      documentsControllerProvider.overrideWithValue(
        DocumentsController(documentsApi),
      ),
      documentsApiProvider.overrideWithValue(documentsApi),
      activityControllerProvider.overrideWithValue(
        ActivityController(activityApi),
      ),
      todayRepositoryProvider.overrideWithValue(todayRepository),
      todayControllerProvider.overrideWithValue(
        TodayController(todayRepository),
      ),
    ],
    child: const AppRoot(),
  );

  return _RevisionTestApp(
    widget: widget,
    authController: resolvedAuthController,
    revisionGoalsRepository: revisionGoalsRepository,
    activityApi: activityApi,
    todayRepository: todayRepository,
  );
}

class _RevisionTestApp {
  const _RevisionTestApp({
    required this.widget,
    required this.authController,
    required this.revisionGoalsRepository,
    required this.activityApi,
    required this.todayRepository,
  });

  final Widget widget;
  final AuthController authController;
  final InMemoryRevisionGoalsRepository revisionGoalsRepository;
  final InMemoryActivityApi activityApi;
  final InMemoryTodayRepository todayRepository;
}
