# HOTFIX-032B — Isolation route session de révision IA

## 1. Résultat

La route publique `/activities/session` reste inchangée, mais elle n'est plus une sous-route UI de `ActivitiesPage`.

Elle est maintenant une route sœur de `/activities` dans la même branche `StatefulShellBranch`, ce qui conserve l'onglet Activités actif sans monter `ActivitiesPage` en parent.

Conséquence validée par tests :

* `/activities` affiche toujours `ActivitiesPage` ;
* `/activities?subjectId=subject-1` démarre toujours un QCM ;
* `/activities/session?subjectId=subject-1&knowledgeUnitId=unit-1` affiche directement `RevisionSessionPage` ;
* `/activities/session?...` ne déclenche plus `ActivityController.startNextActivity` ;
* `/activities/session?...` ne déclenche plus `ActivityController.startOpenQuestion`.

## 2. Problème corrigé

Après `LOT-032`, la route `/activities/session` était déclarée comme enfant de la route `/activities`.

Comme `ActivitiesPage` démarre automatiquement une activité quand elle reçoit `subjectId`, et directement une question ouverte quand elle reçoit `subjectId + knowledgeUnitId`, cette imbrication pouvait déclencher une activité hors session en arrière-plan pendant que `RevisionSessionPage` démarrait la session de révision.

Ce hotfix isole la page session pour éviter les appels parallèles non déterministes.

## 3. Sources inspectées

Documentation :

* `revision_app/docs/ROADMAP_EXECUTION_LOT_032_REVISION_SESSION_SCREEN.md`
* `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
* `revision_app/AGENTS.md`
* `revision_app/codex_rule.md`

Flutter :

* `revision_app/lib/app/router/app_router.dart`
* `revision_app/lib/app/router/app_routes.dart`
* `revision_app/lib/core/routing/route_paths.dart`
* `revision_app/lib/presentation/pages/activities/activities_page.dart`
* `revision_app/lib/presentation/pages/revision_sessions/revision_session_page.dart`
* `revision_app/lib/features/activities/application/activity_controller.dart`
* `revision_app/lib/features/revision_sessions/application/revision_session_controller.dart`
* `revision_app/test/app/router/app_router_test.dart`
* `revision_app/test/features/revision_sessions/revision_session_page_test.dart`
* `revision_app/test/fakes/in_memory_activity_api.dart`
* `revision_app/test/fakes/in_memory_revision_sessions_api.dart`

## 4. Préflight Git

API :

```text
/Users/karim/Project/app-révision/api
/Users/karim/Project/app-révision/api
main
## main...origin/main
5e71dde #31-1: ajoute module revision-sessions avec structure minimale
0f25fed #27-3: finalise corrections de l'évaluateur de réponses ouvertes
0cf3f17 #27-2: corrige évaluation des réponses ouvertes et soumission
ba5daba #27-1: ajoute évaluation des réponses ouvertes et génération de questions
93dad71 #26-1: ajoute gestion des questions ouvertes et soumissions d'activités
```

Frontend :

```text
/Users/karim/Project/app-révision/revision_app
/Users/karim/Project/app-révision/revision_app
main
## main...origin/main
a4a76f4 LOT_032_REVISION_SESSION_SCREEN - Ajout écran session de révision, contrôleur, API, routes et tests, ajout rapport LOT_032
6d33db0 LOT_031_REVISION_SESSION_MINIMAL - Mise à jour plan d'exécution et ajout rapport LOT_031 (Revision Session Minimal)
710941b HOTFIX_028B_OPEN_QUESTION_ENTRY - Mise à jour page activités, API fake et tests, ajout rapport hotfix 028B
2c8b57d LOT_028_OPEN_QUESTION_UI - Ajout UI question ouverte, contrôleur, API demo, routes et tests, ajout rapport LOT_028
513b4f0 HOTFIX_027B_OPEN_ANSWER_ERROR_PATH - Ajout rapport hotfix 027B (Open Answer Error Path)
```

État initial :

* API : propre.
* Frontend : propre.

Décision sur fichiers hors scope :

* aucun fichier backend modifié ;
* aucun fichier Prisma modifié ;
* aucun fichier Genkit modifié ;
* aucun fichier GenUI modifié ;
* aucun fichier TodayPlan modifié ;
* aucun `pubspec.yaml` ou `pubspec.lock` modifié.

## 5. Décision de routing

Avant :

```dart
GoRoute(
  path: AppRoutes.activities,
  builder: ... ActivitiesPage(...),
  routes: [
    GoRoute(
      path: AppRoutes.revisionSessionSegment,
      builder: ... RevisionSessionPage(...),
    ),
  ],
)
```

Après :

```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: AppRoutes.activities,
      builder: ... ActivitiesPage(...),
    ),
    GoRoute(
      path: AppRoutes.revisionSessionPath,
      builder: ... RevisionSessionPage(...),
    ),
  ],
)
```

La route session reste dans la branche Activités du shell, mais n'est plus enfant de `ActivitiesPage`.

L'URL publique reste :

```text
/activities/session
```

Les helpers `AppRoutes.revisionSession(...)` et `revisionSessionRoutePathFor(...)` restent compatibles.

## 6. Fichiers modifiés

Fichiers modifiés :

* `revision_app/lib/app/router/app_router.dart`
* `revision_app/test/app/router/app_router_test.dart`

Fichier créé :

* `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_032B_REVISION_SESSION_ROUTE_ISOLATION.md`

Fichiers supprimés :

* aucun.

## 7. Tests ajoutés/modifiés

Tests ajoutés dans `revision_app/test/app/router/app_router_test.dart` :

* vérifie que la route session est sœur de la route activities ;
* vérifie que `/activities/session?subjectId=...&knowledgeUnitId=...` démarre une session sans activité directe ;
* vérifie que `/activities?subjectId=...` garde le comportement QCM ;
* vérifie que `/activities/session?sessionId=...` charge une session existante sans activité directe.

TDD :

* le test structurel a d'abord échoué sur l'ancien routeur avec :

```text
Expected: contains all of ['/activities', '/activities/session']
Actual: ['/activities']
```

* après modification du routeur, `flutter test test/app/router --reporter compact` passe.

## 8. Validations lancées

Depuis `revision_app` :

```bash
dart analyze lib test
```

Résultat :

```text
No issues found!
```

```bash
flutter test test/app/router --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
flutter test test/features/revision_sessions --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
flutter test test/features/activities --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
flutter test --reporter compact
```

Résultat :

```text
All tests passed!
```

```bash
git diff --check
```

Résultat :

```text
OK
```

Depuis `api` :

```bash
git diff --check
```

Résultat :

```text
OK
```

## 9. Validations non lancées avec justification

Non lancées :

* tests backend : aucun fichier backend modifié ;
* tests Prisma/migrations : aucun fichier Prisma ou migration modifié ;
* tests Genkit/provider IA : aucun Genkit modifié, aucun provider IA réel concerné ;
* `dart fix --apply` : interdit ;
* `dart format .` : interdit ;
* `flutter pub upgrade` / `flutter pub add` : interdits ;
* `npm run lint`, `npm run format`, `npm run test:cov`, `npx prisma db push`, `npx prisma migrate reset`, `npx prisma migrate deploy` : interdits.

## 10. Risques restants

Risques faibles :

* `AppRoutes.revisionSessionSegment` reste présent pour compatibilité historique, même si la route sœur utilise maintenant `AppRoutes.revisionSessionPath`.
* Le comportement exact d'activation visuelle de l'onglet dépend toujours du `StatefulShellRoute`, mais la route reste bien dans la branche Activités.

Risques non changés par ce hotfix :

* aucune logique métier de session n'est modifiée ;
* aucune stratégie Genkit n'est modifiée ;
* aucun comportement de `ActivitiesPage` n'est modifié.

## 11. Code complet créé/modifié/supprimé pour review

### Fichier modifié — `revision_app/lib/app/router/app_router.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/onboarding/application/revision_goals_controller.dart';
import '../../features/revision_sessions/application/revision_session_controller.dart';
import '../../features/revision_sessions/data/revision_sessions_api.dart';
import '../../features/subjects/application/subjects_controller.dart';
import '../../features/subjects/application/subjects_notifier.dart';
import '../../features/today/application/today_controller.dart';
import '../../presentation/pages/activities/activities_page.dart';
import '../../presentation/pages/auth/sign_in_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/documents/document_detail_page.dart';
import '../../presentation/pages/revision_sessions/revision_session_page.dart';
import '../../presentation/pages/subjects/subject_detail_page.dart';
import '../../presentation/pages/subjects/subjects_home_page.dart';
import '../../presentation/pages/today/today_page.dart';
import '../../presentation/shell/revision_home_shell.dart';
import '../di/providers.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter(
    authController: ref.read(authControllerProvider),
    subjectsController: ref.read(subjectsControllerProvider),
    revisionGoalsController: ref.read(revisionGoalsControllerProvider),
    documentsController: ref.read(documentsControllerProvider),
    activityController: ref.read(activityControllerProvider),
    revisionSessionController: ref.read(revisionSessionControllerProvider),
    todayController: ref.read(todayControllerProvider),
    onSubjectCreated: () => ref.invalidate(subjectsNotifierProvider),
  );
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createAppRouter({
  required AuthController authController,
  required SubjectsController subjectsController,
  required RevisionGoalsController revisionGoalsController,
  required DocumentsController documentsController,
  required ActivityController activityController,
  required RevisionSessionController revisionSessionController,
  required TodayController todayController,
  VoidCallback? onSubjectCreated,
}) {
  return GoRouter(
    initialLocation: AppRoutes.subjects,
    refreshListenable: authController,
    redirect: (context, state) {
      return executeRevisionRedirect(authController, state);
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.subjects,
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => SignInPage(authController: authController),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => OnboardingPage(
          subjectsController: subjectsController,
          revisionGoalsController: revisionGoalsController,
          onSubjectCreated: onSubjectCreated,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RevisionHomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subjects,
                builder: (context, state) => const SubjectsHomePage(),
                routes: [
                  GoRoute(
                    path: ':subjectId',
                    builder: (context, state) => SubjectDetailPage(
                      subjectId: state.pathParameters['subjectId'] ?? '',
                      controller: subjectsController,
                      documentsController: documentsController,
                    ),
                    routes: [
                      GoRoute(
                        path: 'documents/:documentId',
                        builder: (context, state) => DocumentDetailPage(
                          documentId:
                              state.pathParameters['documentId'] ?? '',
                          controller: documentsController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.activities,
                builder: (context, state) => ActivitiesPage(
                  controller: activityController,
                  subjectId: state.uri.queryParameters['subjectId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
                ),
              ),
              GoRoute(
                path: AppRoutes.revisionSessionPath,
                builder: (context, state) => RevisionSessionPage(
                  revisionSessionController: revisionSessionController,
                  activityController: activityController,
                  sessionId: state.uri.queryParameters['sessionId'],
                  subjectId: state.uri.queryParameters['subjectId'],
                  documentId: state.uri.queryParameters['documentId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
                  preferredAction: _preferredActionFromQuery(
                    state.uri.queryParameters['preferredAction'],
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    ProfilePage(authController: authController),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

RevisionSessionPreferredAction? _preferredActionFromQuery(String? value) {
  return switch (value) {
    'diagnostic_quiz' => RevisionSessionPreferredAction.diagnosticQuiz,
    'open_question' => RevisionSessionPreferredAction.openQuestion,
    _ => null,
  };
}

@visibleForTesting
String? executeRevisionRedirect(
  AuthController authController,
  GoRouterState state,
) {
  final isSigningIn = state.uri.path == AppRoutes.signIn;

  if (authController.isLoading) {
    return null;
  }

  if (!authController.isSignedIn) {
    return isSigningIn ? null : AppRoutes.signIn;
  }

  if (isSigningIn) {
    return AppRoutes.subjects;
  }

  return null;
}
```

### Fichier modifié — `revision_app/test/app/router/app_router_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/app/router/app_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_documents_api.dart';
import '../../fakes/in_memory_revision_goals_repository.dart';
import '../../fakes/in_memory_revision_sessions_api.dart';
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
  Future<void> signOut() async {}
}

void main() {
  test(
    'appRouterProvider exposes a GoRouter with Revision initial location',
    () {
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

      final container = ProviderContainer(
        overrides: [
          authControllerProvider.overrideWithValue(authController),
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
          revisionSessionControllerProvider.overrideWithValue(
            RevisionSessionController(InMemoryRevisionSessionsApi()),
          ),
          todayControllerProvider.overrideWithValue(
            TodayController(InMemoryTodayRepository()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      expect(router, isA<GoRouter>());
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.subjects,
      );
    },
  );

  test('AppRoutes builds revision session routes with query params', () {
    final route = AppRoutes.revisionSession(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: 'open_question',
    );

    expect(
      route,
      '/activities/session?subjectId=subject-1&knowledgeUnitId=unit-1&preferredAction=open_question',
    );
  });

  test('revision session route is a sibling of activities route', () {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    final shellRoute = harness.router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;
    final activitiesBranch = shellRoute.branches.singleWhere((branch) {
      return branch.routes
          .whereType<GoRoute>()
          .any((route) => route.path == AppRoutes.activities);
    });
    final activitiesRoutes = activitiesBranch.routes.whereType<GoRoute>();
    final activitiesRoute = activitiesRoutes.singleWhere(
      (route) => route.path == AppRoutes.activities,
    );

    expect(
      activitiesRoutes.map((route) => route.path),
      containsAll([AppRoutes.activities, AppRoutes.revisionSessionPath]),
    );
    expect(activitiesRoute.routes, isEmpty);
  });

  testWidgets(
    'revision session route starts a session without direct activity',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Question ouverte test'), findsOneWidget);
      expect(harness.revisionSessionsApi.startCount, 1);
      expect(harness.revisionSessionsApi.startedSubjectId, 'subject-1');
      expect(harness.revisionSessionsApi.startedKnowledgeUnitId, 'unit-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );

  testWidgets('activities route keeps diagnostic quiz behavior', (tester) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.activitiesForSubject('subject-1'));
    await tester.pumpAndSettle();

    expect(find.text('Activites'), findsWidgets);
    expect(find.text('Diagnostic rapide'), findsOneWidget);
    expect(harness.activityApi.startedDiagnosticQuizCount, 1);
    expect(harness.activityApi.startedOpenQuestionCount, 0);
    expect(harness.revisionSessionsApi.startCount, 0);
  });

  testWidgets(
    'revision session route by session id loads without direct activity',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(sessionId: 'revision-session-1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(harness.revisionSessionsApi.loadCount, 1);
      expect(harness.revisionSessionsApi.loadedSessionId, 'revision-session-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );
}

class _RouterHarness {
  _RouterHarness()
      : authController = AuthController(
          _SignedInAuthRepository(),
          initialSession: _signedInSession,
        ),
        subjectsController = SubjectsController(InMemorySubjectsRepository()),
        revisionGoalsController = RevisionGoalsController(
          InMemoryRevisionGoalsRepository(),
        ),
        documentsController = DocumentsController(InMemoryDocumentsApi()),
        activityApi = InMemoryActivityApi(),
        revisionSessionsApi = InMemoryRevisionSessionsApi(),
        todayController = TodayController(InMemoryTodayRepository()) {
    activityController = ActivityController(activityApi);
    revisionSessionController =
        RevisionSessionController(revisionSessionsApi);
    router = createAppRouter(
      authController: authController,
      subjectsController: subjectsController,
      revisionGoalsController: revisionGoalsController,
      documentsController: documentsController,
      activityController: activityController,
      revisionSessionController: revisionSessionController,
      todayController: todayController,
    );
  }

  final AuthController authController;
  final SubjectsController subjectsController;
  final RevisionGoalsController revisionGoalsController;
  final DocumentsController documentsController;
  final InMemoryActivityApi activityApi;
  final InMemoryRevisionSessionsApi revisionSessionsApi;
  final TodayController todayController;
  late final ActivityController activityController;
  late final RevisionSessionController revisionSessionController;
  late final GoRouter router;

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWithValue(authController),
        subjectsControllerProvider.overrideWithValue(subjectsController),
        revisionGoalsControllerProvider.overrideWithValue(
          revisionGoalsController,
        ),
        documentsControllerProvider.overrideWithValue(documentsController),
        activityControllerProvider.overrideWithValue(activityController),
        revisionSessionControllerProvider.overrideWithValue(
          revisionSessionController,
        ),
        todayControllerProvider.overrideWithValue(todayController),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  void dispose() {
    router.dispose();
    authController.dispose();
  }
}

class _SignedInAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield _signedInSession;
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

const _signedInSession = AuthSession.signedIn(
  AuthenticatedUser(
    uid: 'firebase-123',
    email: 'student@example.com',
    displayName: 'Karim',
  ),
);
```

### Fichier créé — `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_032B_REVISION_SESSION_ROUTE_ISOLATION.md`

Le contenu complet de ce fichier est le présent rapport. Le recopier intégralement dans lui-même créerait une récursion infinie ; les deux fichiers de code modifiés sont inclus ci-dessus en entier pour review.

### Fichiers supprimés

Aucun fichier supprimé.
