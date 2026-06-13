import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/revision_app.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';

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

void main() {
  testWidgets('shows the subject home as the first app screen', (tester) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    expect(find.text('Tes matieres'), findsOneWidget);
    expect(find.text('Ajouter une matiere'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(testApp.authController.isSignedIn, isTrue);
  });

  testWidgets('changes route when tapping bottom navigation', (tester) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aujourd hui'));
    await tester.pumpAndSettle();

    expect(find.text('Plan du jour'), findsOneWidget);
  });

  testWidgets('keeps tab state when switching between destinations', (
    tester,
  ) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aujourd hui'));
    await tester.pumpAndSettle();

    expect(find.text('Plan du jour'), findsOneWidget);
    expect(testApp.todayRepository.getTodayPlanCalls, 1);

    await tester.tap(find.text('Activites'));
    await tester.pumpAndSettle();

    expect(find.text('Aucune activite selectionnee'), findsOneWidget);

    await tester.tap(find.text('Aujourd hui'));
    await tester.pumpAndSettle();

    expect(find.text('Plan du jour'), findsOneWidget);
    expect(testApp.todayRepository.getTodayPlanCalls, 1);
  });

  testWidgets('opens onboarding from the add subject action', (tester) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter une matiere'));
    await tester.pumpAndSettle();

    expect(find.text('Prepare ton premier plan'), findsOneWidget);
    expect(find.text('Matiere'), findsOneWidget);
    expect(find.text('Minutes par semaine'), findsOneWidget);
    expect(find.text('Creer mon plan'), findsOneWidget);
  });

  testWidgets('creates a subject from onboarding and returns home', (
    tester,
  ) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter une matiere'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Anatomie');
    await tester.enterText(find.byType(TextField).last, '180');
    await tester.tap(find.text('Creer mon plan'));
    await tester.pumpAndSettle();

    expect(find.text('Anatomie'), findsOneWidget);
    expect(find.text('Priorite 4'), findsOneWidget);
    expect(testApp.revisionGoalsRepository.goals.single.weeklyMinutes, 180);
  });

  testWidgets('keeps the home tab selected on subject detail and resets it', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter une matiere'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Droit');
    await tester.enterText(find.byType(TextField).last, '120');
    await tester.tap(find.text('Creer mon plan'));
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.selectedIndex, 0);
    expect(find.text('Droit'), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();

    expect(find.text('Tes matieres'), findsOneWidget);
    expect(find.text('Droit'), findsOneWidget);
  });

  testWidgets('starts an activity with the selected subject id', (
    tester,
  ) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajouter une matiere'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Constitutionnel');
    await tester.enterText(find.byType(TextField).last, '90');
    await tester.tap(find.text('Creer mon plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lancer un diagnostic'));
    await tester.pumpAndSettle();

    expect(find.text('Question test'), findsOneWidget);
    expect(testApp.activityApi.startedSubjectId, 'subject-1');
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

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Activites'));
    await tester.pumpAndSettle();

    expect(find.text('Activites'), findsNWidgets(2));
    expect(find.text('Aucune activite selectionnee'), findsOneWidget);
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

  final widget = RevisionApp(
    authController: resolvedAuthController,
    subjectsController: SubjectsController(subjectsRepository),
    revisionGoalsController: RevisionGoalsController(revisionGoalsRepository),
    documentsController: DocumentsController(documentsApi),
    activityController: ActivityController(activityApi),
    todayController: TodayController(todayRepository),
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

  final RevisionApp widget;
  final AuthController authController;
  final InMemoryRevisionGoalsRepository revisionGoalsRepository;
  final InMemoryActivityApi activityApi;
  final InMemoryTodayRepository todayRepository;
}
