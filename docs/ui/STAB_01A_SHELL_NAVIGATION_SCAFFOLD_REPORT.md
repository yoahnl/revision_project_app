# STAB-01A — Shell, navigation & scaffold coherence report

## 1. Résumé

STAB-01A pose le squelette de navigation attendu pour la suite des refontes UI : la bottom navigation principale passe à quatre onglets, l'onglet global Sources sort du parcours principal, les routes de session et de résultat deviennent immersives hors shell, et le layout large du shell est aligné en haut au lieu de centrer verticalement les pages courtes.

Aucun backend n'a été modifié. Aucune API n'a été ajoutée. Aucun commit n'a été effectué.

## 2. Audit initial

### Documents relus

- `docs/roadmap/v2/README.md`
- `docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md`
- `docs/roadmap/v2/UX_UI_TARGET_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/EXECUTION_PLAN_V2.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/DECISIONS_V2.md`
- `docs/roadmap/v2/ROADMAP_UPDATE_PROTOCOL.md`
- `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md`
- `docs/ui/UI_01_PREMIUM_VISUAL_FOUNDATION_REPORT.md`
- `docs/ui/UI_02B_QUICK_REVISION_HARDENING_REPORT.md`
- `docs/ui/REVISION_PROJECT_UI_TARGET.md`

### Code inspecté

- `lib/app/router/app_routes.dart`
- `lib/app/router/app_router.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/presentation/design_system/components/revision_mvp_components.dart`
- `lib/presentation/design_system/components/revision_states.dart`
- `lib/presentation/widgets/revision_navigation.dart`
- `lib/features/courses/presentation/courses_home_page.dart`
- `lib/features/courses/presentation/revisions_pending_page.dart`
- `lib/features/courses/presentation/sources_pending_page.dart`
- `lib/features/courses/presentation/subject_progress_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`
- `test/features/courses/`
- `test/features/revision_sessions/`
- `.github/workflows/flutter-ci.yml`

### Constats

- Le shell principal était un `StatefulShellRoute.indexedStack` avec cinq branches : Accueil, Progrès, Révisions, Sources, Profil.
- `/sources` était présenté comme destination principale alors que les sources utiles vivent déjà depuis le détail cours et la fiche.
- Les routes de session `/revision-sessions/:sessionId`, `/revision-sessions/:sessionId/result`, `/activities/session` et `/activities/rich-closed` étaient dans la branche Révisions, donc avec bottom nav.
- Le shell desktop utilisait un `Center`, ce qui pouvait centrer verticalement des pages courtes et créer le grand vide signalé.
- Les tests routeur couvraient déjà plusieurs routes legacy et les comportements anti-fixtures, mais pas la séparation shell/immersif ni l'absence de Sources dans la navigation principale.

## 3. Sub-agents / passes utilisées

Les passes ont été menées explicitement dans ce lot :

- Router Agent : audit GoRouter, branches shell, routes immersives et routes legacy.
- Shell & Navigation Agent : passage de la bottom navigation à quatre onglets et retrait de Sources.
- Scaffold Agent : correction du top alignment du shell large et ajout d'un test sur `RevisionPageScaffold`.
- Immersive Session Agent : sortie des routes de session/résultat du shell, conservation du fond premium via un wrapper dédié.
- QA Agent : tests router, app, courses, revision sessions, scaffold et full Flutter test.
- Reviewer Agent : vérification du périmètre App-only, absence de backend, absence de nouvelle API et mise à jour roadmap.

## 4. Décisions appliquées

- `DEC-003 — La navigation cible est de quatre onglets` passe à `ACCEPTED`.
- `DEC-010 — La planche UI V2 est la référence visuelle canonique` reste `PROPOSED`, car l'asset `docs/roadmap/v2/assets/revision_project_ui_v2_board.png` est absent localement.

## 5. Routes modifiées

Les routes suivantes restent dans le shell principal :

- `/home`
- `/progress`
- `/revisions`
- `/profile`
- routes de cours et matières rattachées à l'accueil
- `/activities` comme page legacy non immersive principale de la branche Réviser

Les routes suivantes sortent du shell et deviennent top-level avec scaffold immersif :

- `/sources`
- `/revision-sessions/:sessionId`
- `/revision-sessions/:sessionId/result`
- `/activities/session`
- `/activities/rich-closed`

## 6. Shell modifié

- La bottom navigation passe à quatre destinations : `Accueil`, `Progrès`, `Réviser`, `Profil`.
- Le label utilisateur devient `Réviser`, tout en gardant la page existante titrée `Révisions` pour éviter une refonte hors scope.
- Le layout large remplace `Center` par `Align(alignment: Alignment.topCenter)` afin d'éviter les pages courtes verticalement centrées.

## 7. Bottom navigation modifiée

- `Sources` n'est plus une destination principale.
- Les tests app vérifient que `Sources` n'apparaît plus dans la bottom nav.
- La navigation reste route-driven sur layout large via `RevisionNavigationRail`.

## 8. Gestion de Sources

- `/sources` est conservée comme route legacy/top-level afin de ne pas casser un deep link ou un accès manuel.
- `/sources` ne s'affiche plus avec la bottom navigation.
- L'accès utile aux sources de cours reste porté par les pages de cours/fiche existantes.
- Aucune bibliothèque globale Sources n'a été créée dans ce lot.

## 9. Sessions immersives

- Les routes session, résultat et activités immersives sortent du shell.
- Un wrapper `_ImmersiveRouteScaffold` conserve `RevisionBackground` et `SafeArea` sans bottom nav.
- Les tests vérifient l'absence de `RevisionBottomNavigation` et `RevisionNavigationRail` sur session/résultat/rich closed.

## 10. Scaffold / scroll / headers

- Le shell large n'impose plus de centrage vertical global.
- Un test de `RevisionPageScaffold` garantit qu'un header passé dans `headerChildren` reste fixe pendant le scroll du body.
- Un second test garantit qu'une page courte reste alignée en haut.
- Aucune refonte page par page n'a été faite.

## 11. Back navigation

- Les tests existants sur course detail et course sheet continuent de vérifier que le retour ne duplique pas la home ou le détail.
- La sortie des sessions hors shell réduit l'empilement involontaire de la bottom nav pendant le flow immersif.
- Aucun helper de navigation global nouveau n'a été ajouté.

## 12. Tests ajoutés ou modifiés

- `test/app/router/app_router_test.dart` : vérifie les quatre branches shell, les routes immersives hors shell, la conservation de `/sources` hors bottom nav, l'absence de nav sur résultat/session.
- `test/app/revision_app_test.dart` : met à jour la navigation principale attendue (`Réviser`, pas `Sources`).
- `test/presentation/design_system/components/revision_page_scaffold_test.dart` : ajoute deux tests sur header fixe et top alignment.

## 13. Commandes exécutées

### Commandes intermédiaires

- `flutter test test/app/router/app_router_test.dart test/app/revision_app_test.dart test/presentation/design_system/components/revision_page_scaffold_test.dart --reporter compact`
  - Résultat initial attendu : échec avant implémentation, car Sources était encore dans le shell et les sessions affichaient la navigation.
- `dart format lib/app/router/app_router.dart lib/presentation/shell/revision_home_shell.dart test/app/router/app_router_test.dart test/app/revision_app_test.dart test/presentation/design_system/components/revision_page_scaffold_test.dart`
  - Résultat : `Formatted 5 files (0 changed) in 0.04 seconds.` après stabilisation.

### Commandes obligatoires finales

- `flutter --version`
  - Résultat : `Flutter 3.44.0 • channel stable`, `Dart 3.12.0`.
- `flutter pub get`
  - Résultat : `Got dependencies!` avec 23 packages signalés comme ayant des versions plus récentes incompatibles avec les contraintes actuelles.
- `dart analyze lib test`
  - Résultat final : `No issues found!`.
- `flutter test test/app/router/app_router_test.dart --reporter compact`
  - Résultat : `All tests passed!`.
- `flutter test test/app/revision_app_test.dart --reporter compact`
  - Résultat : `All tests passed!`.
- `flutter test test/features/courses --reporter compact`
  - Résultat : `All tests passed!`.
- `flutter test test/features/revision_sessions --reporter compact`
  - Résultat : `All tests passed!`.
- `flutter test test/presentation/design_system/components/revision_page_scaffold_test.dart --reporter compact`
  - Résultat : `All tests passed!`.
- `flutter test --reporter compact`
  - Résultat : `All tests passed!`.
- `git diff --check`
  - Résultat : aucune sortie, exit 0.
- `git status --short --untracked-files=all`
  - Résultat avant création de ce rapport : fichiers Dart/tests/docs modifiés listés, aucun backend.

## 14. Résultats exacts

Les sorties significatives exactes observées :

```text
Flutter 3.44.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 559ffa3f75 (5 weeks ago) • 2026-05-15 14:13:13 -0700
Tools • Dart 3.12.0 • DevTools 2.57.0
```

```text
Got dependencies!
23 packages have newer versions incompatible with dependency constraints.
```

```text
Analyzing lib, test...
No issues found!
```

```text
All tests passed!
```

`git diff --check` n'a produit aucune sortie.

## 15. Limitations

- `/sources` reste une route legacy top-level ; elle n'est pas encore transformée en vraie bibliothèque globale.
- La page Réviser garde encore sa structure actuelle ; la refonte du hub est réservée à STAB-01B.
- La page résultat est immersive mais son UX de sortie dépend encore des CTA existants.
- La planche UI V2 n'a pas été intégrée car l'asset est absent.

## 16. Dette restante pour STAB-01B/STAB-01C

- STAB-01B : clarifier Home, hub Réviser et hiérarchie d'actions du détail cours.
- STAB-01C : wording, fiche/progrès, découvrabilité des matières et masquage/verrouillage des capacités non disponibles.
- CORE-09A : gérer le lifecycle réel archive/delete des sources.

## 17. Fichiers créés/modifiés/supprimés

### Fichiers créés

- `test/presentation/design_system/components/revision_page_scaffold_test.dart`
- `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md`

### Fichiers modifiés

- `lib/app/router/app_router.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`
- `docs/roadmap/v2/DECISIONS_V2.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`

### Fichiers supprimés

Aucun.

## 18. Auto-review

- Bottom navigation = quatre onglets : oui.
- Sources retiré de la destination principale : oui.
- Sources route legacy conservée : oui.
- Sessions/résultat hors shell : oui.
- Scaffold large top-aligned : oui.
- Header fixe testé dans `RevisionPageScaffold` : oui.
- Tests routeur/app/courses/revision_sessions/full : verts.
- Backend modifié : non.
- API inventée : non.
- Commit effectué : non.

## 19. Confirmation backend

Aucun fichier backend n'a été modifié. Le repo API n'a pas été touché.

## 20. Confirmation commit

Aucun commit, amend, merge, rebase, push ou tag n'a été effectué.

## 21. Contenu complet des fichiers créés/modifiés

Le contenu complet des fichiers créés/modifiés est inclus ci-dessous. Le rapport courant ne s'inclut pas lui-même, conformément à la consigne.

### `lib/app/router/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/courses/presentation/course_detail_page.dart';
import '../../features/courses/presentation/course_revision_sheet_page.dart';
import '../../features/courses/presentation/courses_home_page.dart';
import '../../features/courses/presentation/revisions_pending_page.dart';
import '../../features/courses/presentation/subject_progress_page.dart';
import '../../features/courses/presentation/sources_pending_page.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/onboarding/application/revision_goals_controller.dart';
import '../../features/revision_sessions/application/revision_session_controller.dart';
import '../../features/revision_sessions/data/revision_sessions_api.dart';
import '../../features/subjects/application/subjects_controller.dart';
import '../../features/subjects/application/subjects_notifier.dart';
import '../../features/today/application/today_controller.dart';
import '../../presentation/pages/activities/activities_page.dart';
import '../../presentation/pages/auth/sign_in_page.dart';
import '../../presentation/pages/activities/rich_closed_exercise_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/documents/document_detail_page.dart';
import '../../presentation/pages/revision_sessions/revision_session_page.dart';
import '../../presentation/pages/revision_sessions/revision_session_result_page.dart';
import '../../presentation/pages/subjects/subject_detail_page.dart';
import '../../presentation/pages/subjects/subjects_home_page.dart';
import '../../presentation/pages/today/today_page.dart';
import '../../presentation/shell/revision_home_shell.dart';
import '../../presentation/widgets/revision_background.dart';
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
    initialLocation: AppRoutes.home,
    refreshListenable: authController,
    redirect: (context, state) {
      return executeRevisionRedirect(authController, state);
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.home,
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
                path: AppRoutes.home,
                builder: (context, state) => const CoursesHomePage(),
              ),
              GoRoute(
                path: AppRoutes.coursePath,
                builder: (context, state) => CourseDetailPage(
                  courseId: state.pathParameters['courseId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.courseSheetPath,
                builder: (context, state) => CourseRevisionSheetPage(
                  courseId: state.pathParameters['courseId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.courseSheetSourcesPath,
                builder: (context, state) => CourseRevisionSheetSourcesPage(
                  courseId: state.pathParameters['courseId'] ?? '',
                ),
              ),
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
                          documentId: state.pathParameters['documentId'] ?? '',
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
                path: AppRoutes.progress,
                builder: (context, state) => const SubjectProgressPage(),
              ),
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.revisions,
                builder: (context, state) => const RevisionsPendingPage(),
              ),
              GoRoute(
                path: AppRoutes.activities,
                builder: (context, state) => ActivitiesPage(
                  controller: activityController,
                  subjectId: state.uri.queryParameters['subjectId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
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
      GoRoute(
        path: AppRoutes.sources,
        builder: (context, state) =>
            const _ImmersiveRouteScaffold(child: SourcesPendingPage()),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => _ImmersiveRouteScaffold(
          child: RevisionSessionPage(
            revisionSessionController: revisionSessionController,
            activityController: activityController,
            sessionId: state.pathParameters['sessionId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionResultV2Path,
        builder: (context, state) => _ImmersiveRouteScaffold(
          child: RevisionSessionResultPage(
            sessionId: state.pathParameters['sessionId'] ?? '',
            controller: revisionSessionController,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionPath,
        builder: (context, state) => _ImmersiveRouteScaffold(
          child: RevisionSessionPage(
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
      ),
      GoRoute(
        path: AppRoutes.richClosedExercisePath,
        builder: (context, state) => _ImmersiveRouteScaffold(
          child: RichClosedExercisePage(
            controller: activityController,
            sessionId: state.uri.queryParameters['sessionId'],
            subjectId: state.uri.queryParameters['subjectId'],
            documentId: state.uri.queryParameters['documentId'],
            knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
          ),
        ),
      ),
    ],
  );
}

class _ImmersiveRouteScaffold extends StatelessWidget {
  const _ImmersiveRouteScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RevisionBackground(child: SafeArea(child: child)),
    );
  }
}

RevisionSessionPreferredAction? _preferredActionFromQuery(String? value) {
  return switch (value) {
    'diagnostic_quiz' => RevisionSessionPreferredAction.diagnosticQuiz,
    'open_question' => RevisionSessionPreferredAction.openQuestion,
    'rich_closed_exercise' => RevisionSessionPreferredAction.richClosedExercise,
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
    return AppRoutes.home;
  }

  return null;
}

```

### `lib/presentation/shell/revision_home_shell.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/presentation/widgets/revision_background.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

class RevisionHomeShell extends StatelessWidget {
  const RevisionHomeShell({super.key, required this.navigationShell});

  static const double _wideLayoutBreakpoint = 840;
  static const double _maxContentWidth = 900;

  final StatefulNavigationShell navigationShell;

  void _goToDestination(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wideLayoutBreakpoint) {
          return _WideHomeScaffold(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goToDestination,
            child: navigationShell,
          );
        }

        return Scaffold(
          body: RevisionBackground(child: SafeArea(child: navigationShell)),
          bottomNavigationBar: RevisionBottomNavigation(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goToDestination,
            destinations: _navigationDestinations,
          ),
        );
      },
    );
  }
}

class _WideHomeScaffold extends StatelessWidget {
  const _WideHomeScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RevisionBackground(
          child: Row(
            children: [
              RevisionNavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: _navigationDestinations,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: RevisionHomeShell._maxContentWidth,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<_RevisionDestination> _destinations = [
  _RevisionDestination(
    path: homeRoutePath,
    label: 'Accueil',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  _RevisionDestination(
    path: progressRoutePath,
    label: 'Progrès',
    icon: Icons.trending_up_rounded,
    selectedIcon: Icons.trending_up_rounded,
  ),
  _RevisionDestination(
    path: revisionsRoutePath,
    label: 'Réviser',
    icon: Icons.track_changes_rounded,
    selectedIcon: Icons.track_changes_rounded,
  ),
  _RevisionDestination(
    path: profileRoutePath,
    label: 'Profil',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

final List<RevisionNavigationDestination> _navigationDestinations =
    _destinations
        .map(
          (destination) => RevisionNavigationDestination(
            label: destination.label,
            icon: destination.icon,
            selectedIcon: destination.selectedIcon,
          ),
        )
        .toList(growable: false);

class _RevisionDestination {
  const _RevisionDestination({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

```

### `test/app/router/app_router_test.dart`

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
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_courses_repository.dart';
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
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
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

  test('AppRoutes builds rich closed routes with query params', () {
    final route = AppRoutes.richClosedExercise(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
    );

    expect(
      route,
      '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
    );
  });

  test('shell keeps only primary destinations and sessions outside shell', () {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    final shellRoute = harness.router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;
    final branchRoots = shellRoute.branches
        .map((branch) => branch.routes.whereType<GoRoute>().first.path)
        .toList(growable: false);
    final shellPaths = shellRoute.branches
        .expand((branch) => branch.routes.whereType<GoRoute>())
        .map((route) => route.path)
        .toSet();
    final topLevelPaths = harness.router.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toSet();

    expect(branchRoots, [
      AppRoutes.home,
      AppRoutes.progress,
      AppRoutes.revisions,
      AppRoutes.profile,
    ]);
    expect(shellPaths, isNot(contains(AppRoutes.sources)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionV2Path)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionResultV2Path)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionPath)));
    expect(shellPaths, isNot(contains(AppRoutes.richClosedExercisePath)));
    expect(topLevelPaths, contains(AppRoutes.sources));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionV2Path));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionResultV2Path));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionPath));
    expect(topLevelPaths, contains(AppRoutes.richClosedExercisePath));
  });

  testWidgets('home route does not render MVP fixture course data', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Aucune matière réelle'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('course route shows not found instead of fixture fallback', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.course('unknown'));
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Aucun fallback vers un cours fictif'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course route shows real course detail when available', (
    tester,
  ) async {
    final harness = _RouterHarness();
    harness.subjectsRepository.subjects.add(
      const Subject(
        id: 'subject-1',
        name: 'Droit constitutionnel',
        priority: 4,
      ),
    );
    const course = CourseListItem(
      id: 'course-1',
      subjectId: 'subject-1',
      title: 'Institutions de la Ve République',
      chapterLabel: 'Chapitre 2',
      estimatedMinutes: 35,
      sourceCount: 1,
      readySourceCount: 1,
      processingSourceCount: 0,
      failedSourceCount: 0,
    );
    harness.coursesRepository.coursesBySubject['subject-1'] = [course];
    harness.coursesRepository.detailsByCourse['course-1'] = const CourseDetail(
      course: course,
      subject: CourseSubjectSummary(
        id: 'subject-1',
        name: 'Droit constitutionnel',
      ),
      sources: [
        CourseDocument(
          id: 'document-1',
          courseId: 'course-1',
          documentId: 'document-1',
          fileName: 'cours.pdf',
          status: CourseDocumentStatus.ready,
        ),
      ],
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Institutions de la Ve République'), findsOneWidget);
    expect(find.text('Droit constitutionnel'), findsOneWidget);
    await tester.tap(find.widgetWithText(RevisionHeaderActionPill, 'Sources'));
    await tester.pumpAndSettle();
    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course detail back pops to home without forward history', (
    tester,
  ) async {
    final harness = _RouterHarness();
    _seedReadyCourse(harness);
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);

    harness.router.push(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsOneWidget,
    );
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);
    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsNothing,
    );
  });

  testWidgets('course sheet back pops to detail without duplicating home', (
    tester,
  ) async {
    final harness = _RouterHarness();
    _seedReadyCourse(harness);
    harness.coursesRepository.revisionSheetsByCourse['course-1'] =
        _revisionSheet();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    harness.router.push(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();
    harness.router.push(AppRoutes.courseSheet('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour au cours'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsOneWidget,
    );
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);
  });

  testWidgets('course sheet route shows the real course-level revision sheet', (
    tester,
  ) async {
    final harness = _RouterHarness();
    harness.coursesRepository.revisionSheetsByCourse['course-1'] =
        _revisionSheet();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.courseSheet('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('revision session result route displays real backend result', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.revisionSessionResultV2(sessionId: 'fake'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('4/6 bonnes réponses'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);
    expect(find.byType(RevisionNavigationRail), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
  });

  testWidgets(
    'revision session routes are immersive without shell navigation',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(sessionId: 'revision-session-1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.byType(RevisionBottomNavigation), findsNothing);
      expect(find.byType(RevisionNavigationRail), findsNothing);

      harness.router.go(
        AppRoutes.richClosedExercise(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Questions riches'), findsOneWidget);
      expect(find.byType(RevisionBottomNavigation), findsNothing);
      expect(find.byType(RevisionNavigationRail), findsNothing);
    },
  );

  testWidgets('legacy real routes stay accessible', (tester) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());

    harness.router.go(AppRoutes.subjects);
    await tester.pumpAndSettle();
    expect(find.text('Tes matieres'), findsOneWidget);

    harness.router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    expect(find.text('Plan du jour'), findsOneWidget);

    harness.router.go(AppRoutes.activities);
    await tester.pumpAndSettle();
    expect(find.text('Activites'), findsWidgets);

    harness.router.go(AppRoutes.sources);
    await tester.pumpAndSettle();
    expect(find.text('Sources depuis les cours'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);
    expect(find.byType(RevisionNavigationRail), findsNothing);
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

  testWidgets(
    'revision session rich closed action navigates to rich closed exercise',
    (tester) async {
      final harness = _RouterHarness();
      harness.revisionSessionsApi.startResponse =
          richClosedRevisionSessionResponse();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          preferredAction: 'rich_closed_exercise',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Notion: Institutions politiques'), findsOneWidget);
      expect(harness.revisionSessionsApi.startCount, 1);
      expect(
        harness.revisionSessionsApi.startedPreferredAction,
        RevisionSessionPreferredAction.richClosedExercise,
      );
      expect(harness.activityApi.startedRichClosedCount, 0);
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);

      await tester.ensureVisible(
        find.widgetWithText(RevisionButton, 'Commencer'),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -160));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(RevisionButton, 'Commencer'));
      await tester.pumpAndSettle();

      expect(
        harness.router.routeInformationProvider.value.uri.toString(),
        '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
      );
      expect(find.text('Questions riches'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
      expect(harness.activityApi.startedRichClosedDocumentId, 'document-1');
      expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );

  testWidgets('activities route keeps diagnostic quiz behavior', (
    tester,
  ) async {
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
    'rich closed route starts an exercise without diagnostic or open question',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.richClosedExercise(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Questions riches'), findsOneWidget);
      expect(find.text('Exercice institutions politiques'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
    },
  );

  testWidgets('activities page exposes the rich closed entry', (tester) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(
      Uri(
        path: AppRoutes.activities,
        queryParameters: {
          'subjectId': 'subject-1',
          'knowledgeUnitId': 'unit-1',
        },
      ).toString(),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(RevisionButton, 'Questions riches'));
    await tester.pumpAndSettle();

    expect(find.text('Questions riches'), findsOneWidget);
    expect(harness.activityApi.startedRichClosedCount, 1);
    expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
    expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
    expect(harness.revisionSessionsApi.startCount, 0);
  });

  testWidgets(
    'today rich closed action navigates to rich closed without other activity',
    (tester) async {
      final harness = _RouterHarness();
      harness.todayRepository.plan = _todayPlanWithRichClosedAction();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(AppRoutes.today);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Commencer'));
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      expect(
        harness.router.routeInformationProvider.value.uri.toString(),
        '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
      );
      expect(find.text('Questions riches'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
      expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
      expect(harness.activityApi.startedRichClosedDocumentId, 'document-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
      expect(harness.revisionSessionsApi.startCount, 0);
    },
  );

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
      revisionGoalsController = RevisionGoalsController(
        InMemoryRevisionGoalsRepository(),
      ),
      documentsController = DocumentsController(InMemoryDocumentsApi()),
      activityApi = InMemoryActivityApi(),
      revisionSessionsApi = InMemoryRevisionSessionsApi() {
    subjectsRepository = InMemorySubjectsRepository();
    coursesRepository = InMemoryCoursesRepository();
    subjectsController = SubjectsController(subjectsRepository);
    todayRepository = InMemoryTodayRepository();
    todayController = TodayController(todayRepository);
    activityController = ActivityController(activityApi);
    revisionSessionController = RevisionSessionController(revisionSessionsApi);
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
  late final InMemorySubjectsRepository subjectsRepository;
  late final InMemoryCoursesRepository coursesRepository;
  late final SubjectsController subjectsController;
  final RevisionGoalsController revisionGoalsController;
  final DocumentsController documentsController;
  final InMemoryActivityApi activityApi;
  final InMemoryRevisionSessionsApi revisionSessionsApi;
  late final InMemoryTodayRepository todayRepository;
  late final TodayController todayController;
  late final ActivityController activityController;
  late final RevisionSessionController revisionSessionController;
  late final GoRouter router;

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWithValue(authController),
        subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
        subjectsControllerProvider.overrideWithValue(subjectsController),
        coursesRepositoryProvider.overrideWithValue(coursesRepository),
        revisionGoalsControllerProvider.overrideWithValue(
          revisionGoalsController,
        ),
        documentsControllerProvider.overrideWithValue(documentsController),
        activityControllerProvider.overrideWithValue(activityController),
        revisionSessionControllerProvider.overrideWithValue(
          revisionSessionController,
        ),
        todayRepositoryProvider.overrideWithValue(todayRepository),
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

RevisionSheet _revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}

CourseListItem _seedReadyCourse(_RouterHarness harness) {
  harness.subjectsRepository.subjects.add(
    const Subject(id: 'subject-1', name: 'Droit constitutionnel', priority: 4),
  );

  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Institutions de la Ve République',
    chapterLabel: 'Chapitre 2',
    estimatedMinutes: 35,
    sourceCount: 1,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  harness.coursesRepository.coursesBySubject['subject-1'] = [course];
  harness.coursesRepository.detailsByCourse['course-1'] = const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(
      id: 'subject-1',
      name: 'Droit constitutionnel',
    ),
    sources: [
      CourseDocument(
        id: 'document-1',
        courseId: 'course-1',
        documentId: 'document-1',
        fileName: 'cours.pdf',
        status: CourseDocumentStatus.ready,
      ),
    ],
  );
  harness.coursesRepository.progressByCourse['course-1'] = const CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    coverage: 0,
    mastery: null,
    estimatedGlobalMastery: 0,
    knowledgeUnitCount: 3,
    practicedKnowledgeUnitCount: 0,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    state: CourseProgressState.readyNotPracticed,
  );
  harness.coursesRepository.progressBySubject['subject-1'] =
      const SubjectProgress(
        subjectId: 'subject-1',
        knowledgeUnitCount: 3,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        courseCount: 1,
        readyCourseCount: 1,
        courses: [
          SubjectCourseProgressItem(
            courseId: 'course-1',
            title: 'Institutions de la Ve République',
            knowledgeUnitCount: 3,
            practicedKnowledgeUnitCount: 0,
            coverage: 0,
            mastery: null,
            estimatedGlobalMastery: 0,
            state: CourseProgressState.readyNotPracticed,
          ),
        ],
      );

  return course;
}

TodayPlan _todayPlanWithRichClosedAction() {
  return TodayPlan(
    generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
    items: const [
      TodayPlanItem(
        id: 'subject-1:unit-1:rich_closed_exercise',
        subjectId: 'subject-1',
        subjectName: 'Droit constitutionnel',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Institutions politiques',
        masteryScore: 0.2,
        action: TodayPlanActionType.richClosedExercise,
        estimatedMinutes: 8,
        priority: 605,
        reasonCode: TodayPlanReasonCode.richClosedPractice,
        reason: 'Questions riches recommandées.',
        startPayload: TodayPlanStartPayload(
          subjectId: 'subject-1',
          documentId: 'document-1',
          knowledgeUnitId: 'unit-1',
        ),
      ),
    ],
  );
}

```

### `test/app/revision_app_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/app_root.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/core/storage/kv_storage_port.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

import '../fakes/in_memory_activity_api.dart';
import '../fakes/in_memory_courses_repository.dart';
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
  testWidgets('shows a real-ready home without fixture courses', (
    tester,
  ) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Aucune matière réelle'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('12'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Réviser'), findsOneWidget);
    expect(find.text('Sources'), findsNothing);
    expect(find.byType(RevisionBottomNavigation), findsOneWidget);
    expect(testApp.authController.isSignedIn, isTrue);
  });

  testWidgets('bottom navigation opens honest real-ready pages', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progrès'));
    await tester.pumpAndSettle();

    expect(find.text('Aucune matière réelle'), findsOneWidget);
    expect(find.text('Progression réelle en attente'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.textContaining('CORE-06 branchera'), findsNothing);

    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Révisions'), findsWidgets);
    expect(find.text('Choisis ton mode de travail'), findsOneWidget);
    expect(find.text('Aucune matière disponible'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
    expect(find.textContaining('à brancher en CORE-05'), findsNothing);
    expect(find.text('Sources'), findsNothing);
    expect(find.textContaining('CORE-03 branchera'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can list real subjects without inventing courses', (
    tester,
  ) async {
    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsWidgets);
    expect(find.text('Aucun cours réel'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can create and select a subject from the subject picker', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Droits').first);
    await tester.pumpAndSettle();

    expect(find.text('Choisir une matière'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);

    await tester.tap(find.text('Créer une matière'));
    await tester.pumpAndSettle();

    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.text('Nom de la matière'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Histoire');
    await tester.tap(find.text('Créer la matière'));
    await tester.pumpAndSettle();

    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Tes cours de Histoire'), findsOneWidget);
    expect(find.text('Aucun cours réel'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('home can list real courses for the active subject', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
        seedCourses: const [
          CourseListItem(
            id: 'course-real-1',
            subjectId: 'subject-real-1',
            title: 'Institutions de la Ve République',
            chapterLabel: 'Chapitre 2',
            estimatedMinutes: 35,
            sourceCount: 1,
            readySourceCount: 1,
            processingSourceCount: 0,
            failedSourceCount: 0,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Institutions de la Ve République'), findsWidgets);
    expect(find.text('Chapitre 2 · 35 min'), findsOneWidget);
    expect(find.text('1 source · 1 prête'), findsWidgets);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home keeps its premium header fixed while course cards scroll', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    final courses = List<CourseListItem>.generate(
      12,
      (index) => CourseListItem(
        id: 'course-real-${index + 1}',
        subjectId: 'subject-real-1',
        title: 'Cours ${index + 1}',
        chapterLabel: 'Chapitre ${index + 1}',
        estimatedMinutes: 20 + index,
        sourceCount: 1,
        readySourceCount: 1,
        processingSourceCount: 0,
        failedSourceCount: 0,
      ),
    );

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
        seedCourses: courses,
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsOneWidget);
    expect(find.text('Cours 12'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Cours 12'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsOneWidget);
    expect(find.text('Cours 12'), findsOneWidget);
  });

  testWidgets('home can create a real course and open its detail', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Créer un cours'),
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Créer un cours').hitTestable(),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Droit administratif');
    await tester.tap(find.text('Créer le cours'));
    await tester.pumpAndSettle();

    expect(find.text('Droit administratif'), findsOneWidget);
    expect(find.text('Cours introuvable'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course and result routes do not fallback to fixture data', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(RevisionBottomNavigation));
    GoRouter.of(context).go('/courses/unknown');
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);

    GoRouter.of(context).go('/revision-sessions/fake/result');
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le résultat'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
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

    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Révisions'), findsWidgets);
    expect(find.text('Choisis ton mode de travail'), findsOneWidget);
    expect(find.text('Aucune matière disponible'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
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

_RevisionTestApp _createTestApp({
  AuthController? authController,
  List<Subject> seedSubjects = const [],
  List<CourseListItem> seedCourses = const [],
}) {
  final resolvedAuthController = authController ?? signedInAuthController();
  final subjectsRepository = InMemorySubjectsRepository();
  subjectsRepository.subjects.addAll(seedSubjects);
  final coursesRepository = InMemoryCoursesRepository();
  for (final course in seedCourses) {
    coursesRepository.coursesBySubject
        .putIfAbsent(course.subjectId, () => [])
        .add(course);
    coursesRepository.detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(
        id: course.subjectId,
        name: _subjectNameFor(seedSubjects, course.subjectId),
      ),
      sources: const [],
    );
  }
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
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
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

String _subjectNameFor(List<Subject> subjects, String subjectId) {
  for (final subject in subjects) {
    if (subject.id == subjectId) {
      return subject.name;
    }
  }

  return 'Matière réelle';
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

```

### `test/presentation/design_system/components/revision_page_scaffold_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';

void main() {
  testWidgets('keeps header fixed while body content scrolls', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RevisionPageScaffold(
            headerChildren: const [
              Text('Fixed header', key: ValueKey('fixed-header')),
            ],
            children: [
              for (var index = 0; index < 30; index++)
                SizedBox(height: 64, child: Text('Body item $index')),
            ],
          ),
        ),
      ),
    );

    final initialHeaderTop = tester
        .getTopLeft(find.byKey(const ValueKey('fixed-header')))
        .dy;

    await tester.drag(find.byType(Scrollable), const Offset(0, -420));
    await tester.pumpAndSettle();

    final scrolledHeaderTop = tester
        .getTopLeft(find.byKey(const ValueKey('fixed-header')))
        .dy;

    expect(scrolledHeaderTop, initialHeaderTop);
  });

  testWidgets('top-aligns short pages instead of vertically centering them', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevisionPageScaffold(
            children: [
              Text('Short page title', key: ValueKey('short-page-title')),
            ],
          ),
        ),
      ),
    );

    final titleTop = tester
        .getTopLeft(find.byKey(const ValueKey('short-page-title')))
        .dy;

    expect(titleTop, lessThan(120));
  });
}

```

### `docs/roadmap/v2/DECISIONS_V2.md`

```md
# Decisions V2

Ce journal est canonique côté produit. Le repo API pointe vers ce fichier au lieu de maintenir un doublon.

Statuts autorisés : `PROPOSED`, `ACCEPTED`, `REJECTED`, `SUPERSEDED`.

| ID | Décision | Statut | Date | Motif | Impact | Lot |
| --- | --- | --- | --- | --- | --- | --- |
| DEC-001 | La roadmap produit canonique vit dans le repo app. | ACCEPTED | 2026-06-20 | La roadmap décrit aussi l'UX, les écrans et le wording produit. | Le repo API garde une roadmap backend alignée, sans dupliquer toute la vision. | STAB-00 |
| DEC-002 | L'application affiche une seule matière active à la fois. | ACCEPTED | 2026-06-20 | Le produit doit rester lisible et orienté "une matière, des cours, des sources". | Le shell et la home doivent éviter les dashboards multi-matières prématurés. | STAB-01A |
| DEC-003 | La navigation cible est de quatre onglets. | ACCEPTED | 2026-06-21 | L'onglet Sources global est peu actionnable tant que les sources vivent dans les cours. | Appliqué par STAB-01A : Accueil, Progrès, Réviser, Profil. | STAB-01A |
| DEC-004 | Sources vit d'abord dans les cours. | ACCEPTED | 2026-06-20 | Les sources sont attachées à un cours et pilotent fiche, quick et progression. | La page Sources globale doit être informative ou devenir une vraie bibliothèque plus tard. | CORE-09A |
| DEC-005 | Today ne devient pas l'accueil avant une vraie recommandation. | PROPOSED | 2026-06-20 | Un "Aujourd'hui" sans moteur adaptatif deviendrait une façade trompeuse. | Today attend ADAPT-01 ou reste hors navigation principale. | ADAPT-01 |
| DEC-006 | Les modes non disponibles sont masqués ou clairement verrouillés. | ACCEPTED | 2026-06-20 | Un bouton visible doit avoir un contrat honnête. | Les labels utilisateur ne doivent plus dire `MVP+`. | STAB-01B |
| DEC-007 | Macro-lots et lots exécutables sont suivis séparément. | ACCEPTED | 2026-06-20 | Les macro-lots sont utiles stratégiquement mais trop gros pour un prompt unique. | Deux trackers sont maintenus : stratégique et exécutable. | STAB-00B |
| DEC-008 | La CI baseline arrive avant les gros refactors. | ACCEPTED | 2026-06-20 | Les refactors de shell/design/lifecycle ont besoin d'une preuve reproductible. | QUALITY-00 dépend seulement de STAB-00B et peut avancer en parallèle de STAB-01A. | QUALITY-00 |
| DEC-009 | Une source utilisée doit être archivée plutôt que supprimée naïvement. | PROPOSED | 2026-06-20 | Les sessions, questions, fiches et résultats doivent garder leur historique pédagogique. | CORE-09A doit trancher archive/delete avant d'élargir les flows. | CORE-09A |
| DEC-010 | La planche UI V2 est la référence visuelle canonique. | PROPOSED | 2026-06-20 | L'asset final n'est pas encore présent dans `docs/roadmap/v2/assets`. | Dès ajout de l'image, elle devient référence de direction visuelle sans autoriser de données fictives. | STAB-01A |

```

### `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`

```md
# Execution Lot Tracker V2

Ce tracker suit les lots réellement exécutables. Les macro-lots restent suivis dans `LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Parent macro-lot | Horizon | Repo(s) | Statut | Dépend de | Travaux parallélisables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00B | STAB-00 | FOUNDATION | App + API | DONE | STAB-00 | Aucun | Durcir la roadmap V2 et créer les lots exécutables. | Docs, trackers et protocole synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | QUALITY-00 | FOUNDATION | App + API | DONE | STAB-00B | STAB-01A | Installer une baseline CI reproductible. | Flutter analyze/tests côté app ; Prisma/build/lint/tests/e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01A | STAB-01 | MVP_STABLE | App | DONE | STAB-00B | QUALITY-00 | Corriger shell, navigation, scaffold et scrolls globaux. | Bottom nav 4 onglets, routes session immersives, routes legacy conservées, scaffolds top-aligned. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md` |
| STAB-01B | STAB-01 | MVP_STABLE | App | TODO | STAB-01A | CORE-09A | Clarifier Home, Hub Révisions et hiérarchie des actions cours. | Entrées principales actionnables sans impasse ni wording technique. | À créer |
| STAB-01C | STAB-01 | MVP_STABLE | App + API si besoin | TODO | STAB-01B | Aucun | Corriger fiche, progrès, wording et découvrabilité des matières. | Capacités non disponibles masquées ou reliées à un lot API. | À créer |
| STAB-02A | STAB-02 | MVP_STABLE | App | TODO | STAB-01C | CORE-10A si CORE-09A fait | Migrer Auth, Onboarding, Profil et Matières vers le design premium. | Une seule direction visuelle, sans faux état produit. | À créer |
| STAB-02B | STAB-02 | MVP_STABLE | App | TODO | STAB-02A | Aucun | Extraire les widgets feature, isoler ou déprécier le legacy. | `features/*/presentation` vidé progressivement selon la règle d'architecture. | À créer |
| CORE-09A | CORE-09 | MVP_STABLE | App + API | TODO | STAB-01A | STAB-01B | Définir archive/delete des sources. | Une source utilisée n'est plus supprimée naïvement. | À créer |
| CORE-09B | CORE-09 | MVP_STABLE | API | TODO | CORE-09A | CORE-09C | Durcir cleanup blob et abstraction storage. | Politique local/cloud documentée et testée. | À créer |
| CORE-09C | CORE-09 | MVP_STABLE | App + API | TODO | CORE-09A | CORE-09B | Ajouter les APIs de lifecycle sujet/cours nécessaires à l'UX. | Renommer/archiver devient disponible seulement si API réelle. | À créer |
| CORE-10A | CORE-10 | MVP_STABLE | App + API | TODO | CORE-09A | STAB-02A | Préparer la question bank en asynchrone. | Plus de génération longue bloquante au démarrage quick. | À créer |
| CORE-10B | CORE-10 | MVP_STABLE | API | TODO | CORE-10A | CORE-11A | Sélection multi-KU et verrouillage concurrence. | Répartition robuste, pas de double réservation évidente. | À créer |
| CORE-10C | CORE-10 | MVP_STABLE | API | TODO | CORE-10B | ADAPT-01 | Découpler QuestionBankService et ajouter métriques qualité/coût. | Service testable, métriques exploitables. | À créer |
| CORE-11A | CORE-11 | MVP_STABLE | App + API | TODO | CORE-10A | CORE-10B, PLUS-01A | Sauvegarder brouillons de session et reprise. | Une session en cours peut être reprise après fermeture. | À créer |
| CORE-11B | CORE-11 | MVP_STABLE | App + API | TODO | CORE-11A | Aucun | Historique de sessions et détail des sessions terminées. | Historique utilisable sans rouvrir un quiz terminé. | À créer |
| PLUS-01A | PLUS-01 | MVP_PLUS | App + API | TODO | STAB-02A, CORE-10A, quick lifecycle stable | CORE-11A | Deep Revision course-level avec question ouverte V1. | Action open-question réelle, correction IA, pas de résultat deep complet si hors lot. | À créer |
| PLUS-01B | PLUS-01 | MVP_PLUS | App + API | TODO | PLUS-01A, CORE-11A | Aucun | Lifecycle, completion et résultat Deep. | Deep dispose d'un résultat cohérent et testable. | À créer |
| PLUS-02 | PLUS-02 | MVP_PLUS | App + API | TODO | STAB-02B, CORE-09A | PLUS-01A | Fiches complète et pré-examen réelles. | Les faux onglets ne mentent plus. | À créer |
| ADAPT-01 | ADAPT-01 | MVP_PLUS | App + API | TODO | CORE-10B | CORE-10C | Page Today et coach adaptatif. | Recommandation honnête basée sur données réelles. | À créer |
| PLUS-03 | PLUS-03 | POST_MVP | App + API | TODO | PLUS-01B, PLUS-02, CORE-11B | Aucun | Préparation examen V1. | Mode examen distinct, résultat distinct, sources adaptées. | À créer |
| GENUI-01 | GENUI-01 | POST_MVP | App + API | TODO | STAB-02B, ADAPT-01, PLUS-01A | Aucun | Surface GenUI contrôlée par catalogue. | Payloads validés, fallback sûr, aucun UI arbitraire. | À créer |
| RELEASE-01 | RELEASE-01 | RELEASE | App + API | TODO | QUALITY-00, lots MVP_STABLE requis | Aucun | Préparation production complète. | CI, stockage, secrets, monitoring, accessibilité et conformité prêts. | À créer |

```

### `docs/roadmap/v2/LOT_TRACKER_V2.md`

```md
# Lot Tracker V2

Ce tracker suit les macro-lots stratégiques. Le détail exécutable vit dans `EXECUTION_LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Titre | Horizon | Repo(s) | Statut | Dépend de | Lots exécutables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00 | Roadmap V2 canonicalisation | FOUNDATION | App + API | DONE | Aucun | STAB-00B | Créer la source de vérité V2 et le protocole de mise à jour. | Documents V2 créés dans les deux repos. | `docs/roadmap/v2/` |
| STAB-00B | Roadmap V2 hardening, execution slicing & governance | FOUNDATION | App + API | DONE | STAB-00 | STAB-00B | Durcir la roadmap, ajouter horizons, lots exécutables et gouvernance. | Trackers, plans, décisions et protocoles synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | CI baseline | FOUNDATION | App + API | DONE | STAB-00B | QUALITY-00 | Ajouter une baseline CI avant les gros refactors. | Analyse, tests ciblés et full Flutter test côté app ; Prisma, build, lint, unit et e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01 | Product navigation & UX coherence | MVP_STABLE | App | IN_PROGRESS | STAB-00B | STAB-01A, STAB-01B, STAB-01C | Corriger navigation, faux affordances et parcours confus. | Tests router/widget + smoke visuel. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md` |
| STAB-02 | Frontend design system unification | MVP_STABLE | App | TODO | STAB-01C | STAB-02A, STAB-02B | Unifier les écrans legacy et premium. | Tests UI ciblés + anti-régression. | À créer |
| CORE-09 | Source lifecycle & storage policy | MVP_STABLE | API + App | TODO | STAB-01A | CORE-09A, CORE-09B, CORE-09C | Sécuriser archive/suppression de sources et stockage. | Tests Prisma + API + UI. | À créer |
| CORE-10 | Question bank production hardening | MVP_STABLE | API + App | TODO | CORE-09A | CORE-10A, CORE-10B, CORE-10C | Rendre la banque de questions robuste et moins synchrone. | Tests génération, sélection, concurrence. | À créer |
| CORE-11 | Session resume & history | MVP_STABLE | API + App | TODO | CORE-10A | CORE-11A, CORE-11B | Reprise de session et historique utilisateur. | Tests lifecycle + navigation. | À créer |
| PLUS-01 | Deep Revision course-level | MVP_PLUS | API + App | TODO | STAB-02A, CORE-10A | PLUS-01A, PLUS-01B | Activer la révision approfondie réelle. | Tests open question + correction IA. | À créer |
| PLUS-02 | Revision sheet complete / exam modes | MVP_PLUS | API + App | TODO | STAB-02B, CORE-09A | PLUS-02 | Remplacer les faux onglets fiche par de vrais contenus. | Tests fiche complète/examen. | À créer |
| ADAPT-01 | Today / adaptive coach | MVP_PLUS | API + App | TODO | CORE-10B | ADAPT-01 | Guider l'utilisateur vers la prochaine action utile. | Tests recommandation + UI Today. | À créer |
| PLUS-03 | Exam preparation V1 | POST_MVP | API + App | TODO | PLUS-01B, PLUS-02, CORE-11B | PLUS-03 | Créer un vrai mode préparation examen. | Tests session exam + résultat. | À créer |
| GENUI-01 | Controlled GenUI surface | POST_MVP | API + App | TODO | STAB-02B, ADAPT-01, PLUS-01A | GENUI-01 | Réintroduire GenUI avec widgets strictement contrôlés. | Validation payload + fallback. | À créer |
| RELEASE-01 | Production readiness | RELEASE | API + App + Infra | TODO | QUALITY-00, lots MVP_STABLE requis | RELEASE-01 | Préparer CI complète, monitoring, stockage et exploitation. | Checklist release complète. | À créer |

```
