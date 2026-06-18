# Rapport d'implémentation — MVP Duolingo-like Flutter

Date: 18 juin 2026  
Repo: `revision_project_app`  
Branche: `main`  
Statut: non commité au moment de ce rapport

## 1. Résumé exécutif

J'ai implémenté une première tranche Flutter du plan `MVP_DUOLINGO_LIKE_PLAN.md` : une expérience mobile dark premium inspirée des références visuelles fournies, avec navigation cible, design system MVP, écrans course-centric et interactions de démonstration.

Cette tranche est volontairement front-only : elle rend l'expérience produit visible et testable sans lancer immédiatement une migration backend `Course` / `CourseSource`. Les données métier des cours, sources, progrès, questions de session et résultats sont donc locales et mockées dans Flutter.

## 2. Ce qui est réel

- Design system MVP Flutter sous `lib/presentation/design_system`.
- Nouvelle navigation cible : Accueil, Progrès, Révisions, Sources, Profil.
- Nouvelles routes :
  - `/home`
  - `/progress`
  - `/revisions`
  - `/sources`
  - `/courses/:courseId`
  - `/courses/:courseId/sheet`
  - `/revision-sessions/:sessionId`
  - `/revision-sessions/:sessionId/result`
- Écrans MVP fonctionnels : home, détail cours, fiche, sources, hub révisions, session, résultat, progrès.
- Anciennes routes V1 conservées : `/subjects`, `/today`, `/activities`, `/activities/session`, `/activities/rich-closed`.
- Tests app/router mis à jour pour couvrir le nouveau shell et le parcours session/résultat.
- Build web debug validé.
- Rapport Product Design QA ajouté.

## 3. Ce qui est mocké ou temporaire

- `MvpStudyController` est un adaptateur front-only temporaire.
- `mvp_study_models.dart` contient des données locales Math/Philosophie et des cours de démonstration.
- Les sources PDF affichées ne sont pas chargées depuis l'API.
- Les fiches ne viennent pas encore de `RevisionSheet` backend.
- La progression est calculée depuis les données locales.
- La session de révision MVP utilise deux questions locales.
- Le résultat de session est statique côté Flutter.
- Le bouton d'ajout de source affiche un snackbar et ne déclenche pas encore d'upload `CourseSource`.

## 4. Décisions prises

### 4.1 Livrer une tranche front avant la migration backend

J'ai choisi de ne pas implémenter immédiatement `Course`, `CourseSource`, les migrations Prisma et les endpoints backend dans le même lot. La raison est simple : combiner refonte visuelle, nouvelle navigation, nouveau modèle backend, upload source, fiches course-level et progression aurait créé un lot trop large et risqué.

Le choix livré est donc :

1. rendre l'UX cible visible ;
2. stabiliser les composants et routes ;
3. garder les anciens flows V1 intacts ;
4. brancher le backend réel dans un lot suivant.

### 4.2 Créer un namespace MVP isolé

Les nouveaux écrans sont dans `lib/features/mvp` afin de ne pas mélanger la nouvelle expérience avec les anciens écrans `subjects`, `today`, `activities` et `revision_sessions`.

Cela permet :

- de garder les anciens tests utilisables ;
- de supprimer facilement l'adaptateur mocké plus tard ;
- de remplacer progressivement `features/mvp` par une vraie feature `courses`.

### 4.3 Créer un design system dédié

J'ai ajouté `lib/presentation/design_system` au lieu de disperser les styles dans chaque page.

Objectif : éviter les cartes et boutons bricolés localement, et préparer le remplacement propre par une vraie UI cohérente.

### 4.4 Respecter les références visuelles sans faire du pixel-perfect artificiel

Les images montrent une app mobile dark premium avec :

- fond bleu nuit ;
- cards glass ;
- accents bleu/cyan/violet/rose/vert ;
- anneaux de maîtrise ;
- cartes cours compactes ;
- bottom nav à cinq onglets ;
- sessions focalisées ;
- résultat clair.

J'ai reproduit cette direction avec des composants Flutter natifs et les Material Icons existantes. Je n'ai pas ajouté d'assets image externes ni d'images distantes.

### 4.5 Garder les routes legacy

Les routes V1 sont conservées pour ne pas casser :

- rich closed exercise ;
- Today ;
- revision sessions existantes ;
- tests router ;
- deep links actuels.

### 4.6 Ne pas ajouter de dépendance lourde

Aucune nouvelle dépendance n'a été ajoutée. La tranche utilise Flutter, GoRouter et les dépendances déjà présentes.

## 5. Architecture livrée

### 5.1 Design system

- Tokens : couleurs, spacing, radius, shadows, typography.
- Composants : scaffold, glass card, gradient button, icon tile, subject switcher, course card, mode card, source card, segmented control, stat triplet, mastery ring, floating add button.

### 5.2 Feature MVP

- `application` : contrôleur local temporaire.
- `domain` : modèles et fixtures locales.
- `presentation` : pages MVP et helpers partagés.

### 5.3 Routing

- L'application démarre maintenant sur `/home`.
- Le shell a 5 branches principales.
- Les anciennes routes sont toujours déclarées.

## 6. Validations réalisées

- `dart analyze lib test` : OK.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK.
- `flutter test test/app --reporter compact` : OK.
- `flutter test test/features/subjects --reporter compact` : OK.
- `flutter test test/features/revision_sessions --reporter compact` : OK.
- `flutter test test/features/activities --reporter compact` : OK.
- `flutter test test/features/today --reporter compact` : OK.
- `flutter test --reporter compact` : OK.
- `flutter build web --debug` : OK.
- `git diff --check` : OK.

Note : des lancements Flutter en parallèle ont provoqué des erreurs d'artefacts natifs/lock Flutter. Les mêmes suites relancées séquentiellement sont passées.

## 7. Limites et risques restants

- Le MVP visuel est branché sur données mockées, pas sur l'API.
- L'auth existante empêche une capture web automatique de l'état connecté sans harness spécifique.
- Le backend `Course` / `CourseSource` reste à faire.
- Les fiches, sources, progression et résultats doivent être remplacés par des DTO backend.
- L'adaptateur `MvpStudyController` doit être retiré dès que la feature `courses` réelle existe.

## 8. Prochaine étape recommandée

Faire un lot backend + front de branchement réel :

1. Ajouter `Course` et `CourseSource` côté Prisma/API.
2. Ajouter endpoints `GET /subjects/:subjectId/courses`, `GET /courses/:courseId`, `GET /courses/:courseId/sources`.
3. Ajouter `POST /courses/:courseId/sources/course-pdf`.
4. Créer une vraie feature Flutter `courses`.
5. Remplacer `MvpStudyController` par API/provider réels.
6. Supprimer les fixtures locales de cours.

## 9. Fichiers créés

- `design-qa.md`
- `docs/MVP_DUOLINGO_LIKE_IMPLEMENTATION_REPORT.md`
- `lib/features/mvp/application/mvp_study_controller.dart`
- `lib/features/mvp/domain/mvp_study_models.dart`
- `lib/features/mvp/presentation/mvp_course_detail_page.dart`
- `lib/features/mvp/presentation/mvp_course_sheet_page.dart`
- `lib/features/mvp/presentation/mvp_home_page.dart`
- `lib/features/mvp/presentation/mvp_page_helpers.dart`
- `lib/features/mvp/presentation/mvp_progress_page.dart`
- `lib/features/mvp/presentation/mvp_revision_session_page.dart`
- `lib/features/mvp/presentation/mvp_revisions_page.dart`
- `lib/features/mvp/presentation/mvp_session_result_page.dart`
- `lib/features/mvp/presentation/mvp_sources_page.dart`
- `lib/presentation/design_system/components/revision_mvp_components.dart`
- `lib/presentation/design_system/tokens/revision_colors.dart`
- `lib/presentation/design_system/tokens/revision_radius.dart`
- `lib/presentation/design_system/tokens/revision_shadows.dart`
- `lib/presentation/design_system/tokens/revision_spacing.dart`
- `lib/presentation/design_system/tokens/revision_typography.dart`

## 10. Fichiers modifiés

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/core/routing/route_paths.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/presentation/theme/app_colors.dart`
- `lib/presentation/widgets/revision_background.dart`
- `lib/presentation/widgets/revision_navigation.dart`
- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`

## 11. Fichiers supprimés

Aucun fichier supprimé.

## 12. Code complet des fichiers créés/modifiés

Le présent rapport ne s'inclut pas lui-même dans les blocs de code pour éviter une récursion infinie.

### design-qa.md

~~~md
# Design QA — MVP Duolingo-like Flutter

final result: passed

## Source visual target

- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_19_27 AM (2).png`
- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_19_27 AM (1).png`
- `/Users/karim/Downloads/ChatGPT Image Jun 17, 2026, 12_06_07 AM.png`

## Scope checked

- Accueil matiere active.
- Subject switcher.
- Detail cours.
- Sources.
- Fiche de lecture.
- Hub revisions.
- Session de revision.
- Resultat de session.
- Progres.

## Design checks

- Palette moved to the reference direction: ink/navy background, glass surfaces, blue/cyan primary action, violet/pink secondary accents, green mastery.
- Bottom navigation now matches the target information architecture: Accueil, Progres, Revisions, Sources, Profil.
- Cards, mode rows, progress lines, mastery rings, source rows and CTA buttons are centralized in the MVP design-system components.
- The implementation avoids remote image loading and keeps icons from Flutter's Material icon set.
- Pages remain mobile-first with constrained width on larger screens.

## Known differences from reference

- This is an in-app Flutter implementation, not a pixel-perfect static clone.
- The first shipped slice uses front-only demo Course data while the backend Course/CourseSource model is still pending.
- Browser screenshot capture of the signed-in MVP state is not automated in this run because the real app keeps the existing auth guard.
- The status bar/device frame from the reference is not recreated inside the app; the app renders as a normal Flutter screen.

## Validation evidence

- `dart analyze lib test`: passed.
- `flutter test --reporter compact`: passed.
- `flutter build web --debug`: passed.
- `git diff --check`: passed.

## Follow-up design notes

- Replace the demo Course adapter with the real Course API.
- Add licensed/generated custom course icons only if the product needs stronger visual identity.
- Run device screenshots on an authenticated simulator once the backend Course flow is available.

~~~

### lib/app/router/app_router.dart

~~~dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/documents/application/documents_controller.dart';
import '../../features/mvp/presentation/mvp_course_detail_page.dart';
import '../../features/mvp/presentation/mvp_course_sheet_page.dart';
import '../../features/mvp/presentation/mvp_home_page.dart';
import '../../features/mvp/presentation/mvp_progress_page.dart';
import '../../features/mvp/presentation/mvp_revision_session_page.dart';
import '../../features/mvp/presentation/mvp_revisions_page.dart';
import '../../features/mvp/presentation/mvp_session_result_page.dart';
import '../../features/mvp/presentation/mvp_sources_page.dart';
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
                builder: (context, state) => const MvpHomePage(),
              ),
              GoRoute(
                path: AppRoutes.coursePath,
                builder: (context, state) => MvpCourseDetailPage(
                  courseId: state.pathParameters['courseId'] ?? '',
                ),
              ),
              GoRoute(
                path: AppRoutes.courseSheetPath,
                builder: (context, state) => MvpCourseSheetPage(
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
                builder: (context, state) => const MvpProgressPage(),
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
                builder: (context, state) => const MvpRevisionsPage(),
              ),
              GoRoute(
                path: AppRoutes.revisionSessionV2Path,
                builder: (context, state) => MvpRevisionSessionPage(
                  sessionId: state.pathParameters['sessionId'] ?? '',
                  courseId: state.uri.queryParameters['courseId'],
                  mode: state.uri.queryParameters['mode'],
                ),
              ),
              GoRoute(
                path: AppRoutes.revisionSessionResultV2Path,
                builder: (context, state) => MvpSessionResultPage(
                  sessionId: state.pathParameters['sessionId'] ?? '',
                  courseId: state.uri.queryParameters['courseId'],
                  mode: state.uri.queryParameters['mode'],
                ),
              ),
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
              GoRoute(
                path: AppRoutes.richClosedExercisePath,
                builder: (context, state) => RichClosedExercisePage(
                  controller: activityController,
                  sessionId: state.uri.queryParameters['sessionId'],
                  subjectId: state.uri.queryParameters['subjectId'],
                  documentId: state.uri.queryParameters['documentId'],
                  knowledgeUnitId: state.uri.queryParameters['knowledgeUnitId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.sources,
                builder: (context, state) => const MvpSourcesPage(),
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

~~~

### lib/app/router/app_routes.dart

~~~dart
class AppRoutes {
  const AppRoutes._();

  static const root = '/';
  static const home = '/home';
  static const progress = '/progress';
  static const revisions = '/revisions';
  static const sources = '/sources';
  static const coursePath = '/courses/:courseId';
  static const courseSheetPath = '/courses/:courseId/sheet';
  static const revisionSessionV2Path = '/revision-sessions/:sessionId';
  static const revisionSessionResultV2Path =
      '/revision-sessions/:sessionId/result';
  static const subjects = '/subjects';
  static const today = '/today';
  static const activities = '/activities';
  static const revisionSessionSegment = 'session';
  static const revisionSessionPath = '/activities/session';
  static const richClosedExercisePath = '/activities/rich-closed';
  static const profile = '/profile';
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';

  static String subjectDetail(String subjectId) => '/subjects/$subjectId';

  static String course(String courseId) => '/courses/$courseId';

  static String courseSheet(String courseId) => '/courses/$courseId/sheet';

  static String revisionSessionV2({
    required String sessionId,
    String? courseId,
    String? mode,
  }) {
    final queryParameters = <String, String>{};
    if (courseId != null && courseId.trim().isNotEmpty) {
      queryParameters['courseId'] = courseId.trim();
    }
    if (mode != null && mode.trim().isNotEmpty) {
      queryParameters['mode'] = mode.trim();
    }

    return Uri(
      path: '/revision-sessions/${sessionId.trim()}',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String revisionSessionResultV2({
    required String sessionId,
    String? courseId,
    String? mode,
  }) {
    final queryParameters = <String, String>{};
    if (courseId != null && courseId.trim().isNotEmpty) {
      queryParameters['courseId'] = courseId.trim();
    }
    if (mode != null && mode.trim().isNotEmpty) {
      queryParameters['mode'] = mode.trim();
    }

    return Uri(
      path: '/revision-sessions/${sessionId.trim()}/result',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String documentDetail({
    required String subjectId,
    required String documentId,
  }) {
    return '/subjects/$subjectId/documents/$documentId';
  }

  static String activitiesForSubject(String subjectId) {
    return Uri(
      path: activities,
      queryParameters: {'subjectId': subjectId},
    ).toString();
  }

  static String revisionSession({
    String? sessionId,
    String? subjectId,
    String? documentId,
    String? knowledgeUnitId,
    String? preferredAction,
  }) {
    final queryParameters = <String, String>{};
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      queryParameters['sessionId'] = sessionId.trim();
    }
    if (subjectId != null && subjectId.trim().isNotEmpty) {
      queryParameters['subjectId'] = subjectId.trim();
    }
    if (documentId != null && documentId.trim().isNotEmpty) {
      queryParameters['documentId'] = documentId.trim();
    }
    if (knowledgeUnitId != null && knowledgeUnitId.trim().isNotEmpty) {
      queryParameters['knowledgeUnitId'] = knowledgeUnitId.trim();
    }
    if (preferredAction != null && preferredAction.trim().isNotEmpty) {
      queryParameters['preferredAction'] = preferredAction.trim();
    }

    return Uri(
      path: revisionSessionPath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String richClosedExercise({
    String? sessionId,
    String? subjectId,
    String? documentId,
    String? knowledgeUnitId,
  }) {
    final queryParameters = <String, String>{};
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      queryParameters['sessionId'] = sessionId.trim();
    }
    if (subjectId != null && subjectId.trim().isNotEmpty) {
      queryParameters['subjectId'] = subjectId.trim();
    }
    if (documentId != null && documentId.trim().isNotEmpty) {
      queryParameters['documentId'] = documentId.trim();
    }
    if (knowledgeUnitId != null && knowledgeUnitId.trim().isNotEmpty) {
      queryParameters['knowledgeUnitId'] = knowledgeUnitId.trim();
    }

    return Uri(
      path: richClosedExercisePath,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }
}

~~~

### lib/core/routing/route_paths.dart

~~~dart
import '../../app/router/app_routes.dart';

const String subjectsRoutePath = AppRoutes.subjects;
const String homeRoutePath = AppRoutes.home;
const String progressRoutePath = AppRoutes.progress;
const String revisionsRoutePath = AppRoutes.revisions;
const String sourcesRoutePath = AppRoutes.sources;
const String todayRoutePath = AppRoutes.today;
const String activitiesRoutePath = AppRoutes.activities;
const String revisionSessionRoutePath = AppRoutes.revisionSessionPath;
const String richClosedExerciseRoutePath = AppRoutes.richClosedExercisePath;
const String profileRoutePath = AppRoutes.profile;
const String onboardingRoutePath = AppRoutes.onboarding;
const String signInRoutePath = AppRoutes.signIn;
const String subjectDetailRoutePattern = '/subjects/:subjectId';
const String documentDetailRoutePattern =
    '/subjects/:subjectId/documents/:documentId';

String subjectDetailRoutePath(String subjectId) {
  return AppRoutes.subjectDetail(subjectId);
}

String courseRoutePath(String courseId) {
  return AppRoutes.course(courseId);
}

String courseSheetRoutePath(String courseId) {
  return AppRoutes.courseSheet(courseId);
}

String documentDetailRoutePath({
  required String subjectId,
  required String documentId,
}) {
  return AppRoutes.documentDetail(subjectId: subjectId, documentId: documentId);
}

String revisionSessionRoutePathFor({
  String? sessionId,
  String? subjectId,
  String? documentId,
  String? knowledgeUnitId,
  String? preferredAction,
}) {
  return AppRoutes.revisionSession(
    sessionId: sessionId,
    subjectId: subjectId,
    documentId: documentId,
    knowledgeUnitId: knowledgeUnitId,
    preferredAction: preferredAction,
  );
}

String richClosedExerciseRoutePathFor({
  String? sessionId,
  String? subjectId,
  String? documentId,
  String? knowledgeUnitId,
}) {
  return AppRoutes.richClosedExercise(
    sessionId: sessionId,
    subjectId: subjectId,
    documentId: documentId,
    knowledgeUnitId: knowledgeUnitId,
  );
}

~~~

### lib/features/mvp/application/mvp_study_controller.dart

~~~dart
import 'package:flutter/foundation.dart';

import '../domain/mvp_study_models.dart';

class MvpStudyController extends ChangeNotifier {
  MvpStudyController._();

  // Adapter temporaire front-only : il donne une experience Course visible
  // pendant que le modele backend Course/CourseSource est implemente.
  static final MvpStudyController instance = MvpStudyController._();

  String _activeSubjectId = mvpSubjects.first.id;

  List<MvpSubject> get subjects => mvpSubjects;

  MvpSubject get activeSubject {
    return subjects.firstWhere((subject) => subject.id == _activeSubjectId);
  }

  MvpCourse get resumeCourse => activeSubject.courses.first;

  MvpCourse? courseById(String id) {
    for (final subject in subjects) {
      for (final course in subject.courses) {
        if (course.id == id) {
          return course;
        }
      }
    }

    return null;
  }

  MvpCourse courseOrFallback(String id) {
    return courseById(id) ?? resumeCourse;
  }

  Iterable<MvpSourceFile> get activeSources {
    return activeSubject.courses.expand((course) => course.sources);
  }

  double get activeMastery {
    final courses = activeSubject.courses;
    if (courses.isEmpty) {
      return 0;
    }

    final total = courses.fold<double>(
      0,
      (sum, course) => sum + course.mastery,
    );
    return total / courses.length;
  }

  void selectSubject(String id) {
    if (id == _activeSubjectId) {
      return;
    }

    if (!subjects.any((subject) => subject.id == id)) {
      return;
    }

    _activeSubjectId = id;
    notifyListeners();
  }

  void resetForTests() {
    _activeSubjectId = mvpSubjects.first.id;
    notifyListeners();
  }
}

~~~

### lib/features/mvp/domain/mvp_study_models.dart

~~~dart
import 'package:flutter/material.dart';

import '../../../presentation/design_system/tokens/revision_colors.dart';

enum MvpRevisionMode { quick, deep, exam }

extension MvpRevisionModeLabel on MvpRevisionMode {
  String get label {
    return switch (this) {
      MvpRevisionMode.quick => 'Rapide',
      MvpRevisionMode.deep => 'Complète',
      MvpRevisionMode.exam => 'Examen',
    };
  }

  String get sessionTitle {
    return switch (this) {
      MvpRevisionMode.quick => 'Révision rapide',
      MvpRevisionMode.deep => 'Révision approfondie',
      MvpRevisionMode.exam => 'Préparation examen',
    };
  }
}

class MvpSubject {
  const MvpSubject({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.courses,
  });

  final String id;
  final String name;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final List<MvpCourse> courses;
}

class MvpCourse {
  const MvpCourse({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.chapterLabel,
    required this.description,
    required this.icon,
    required this.accent,
    required this.completedLessons,
    required this.totalLessons,
    required this.durationMinutes,
    required this.difficulty,
    required this.mastery,
    required this.sources,
    required this.learnItems,
    required this.keyPoints,
    required this.commonMistakes,
    required this.weakSpot,
  });

  final String id;
  final String subjectId;
  final String title;
  final String chapterLabel;
  final String description;
  final IconData icon;
  final Color accent;
  final int completedLessons;
  final int totalLessons;
  final int durationMinutes;
  final String difficulty;
  final double mastery;
  final List<MvpSourceFile> sources;
  final List<String> learnItems;
  final List<String> keyPoints;
  final List<String> commonMistakes;
  final String weakSpot;

  double get progress => completedLessons / totalLessons;

  String get progressLabel => '$completedLessons/$totalLessons leçons';
}

class MvpSourceFile {
  const MvpSourceFile({
    required this.fileName,
    required this.sizeLabel,
    required this.statusLabel,
  });

  final String fileName;
  final String sizeLabel;
  final String statusLabel;
}

class MvpSessionQuestion {
  const MvpSessionQuestion({
    required this.prompt,
    required this.choices,
    required this.correctChoice,
  });

  final String prompt;
  final List<String> choices;
  final String correctChoice;
}

const mvpSessionQuestions = [
  MvpSessionQuestion(
    prompt:
        'Soit X ~ N(0, 1). Quelle est la probabilité que X soit comprise entre -1 et 1 ?',
    choices: ['0,3413', '0,6826', '0,9545', '0,2718'],
    correctChoice: '0,6826',
  ),
  MvpSessionQuestion(
    prompt:
        'Quel réflexe permet de comparer une valeur à une loi normale centrée réduite ?',
    choices: [
      'Standardiser avec Z',
      'Changer la moyenne',
      'Ignorer l’écart-type',
      'Arrondir la probabilité',
    ],
    correctChoice: 'Standardiser avec Z',
  ),
];

final mvpSubjects = [
  MvpSubject(
    id: 'math',
    name: 'Math',
    subtitle: 'Continue ton progrès',
    accent: RevisionColors.mathAccent,
    icon: Icons.calculate_rounded,
    courses: [
      MvpCourse(
        id: 'loi-normale',
        subjectId: 'math',
        title: 'Loi normale',
        chapterLabel: 'Chapitre 3',
        description:
            'Comprendre la loi normale, ses propriétés et son utilisation en statistique inférentielle.',
        icon: Icons.show_chart_rounded,
        accent: RevisionColors.blue,
        completedLessons: 3,
        totalLessons: 7,
        durationMinutes: 20,
        difficulty: 'Intermédiaire',
        mastery: 0.43,
        sources: [
          MvpSourceFile(
            fileName: 'Cours_stats_S1.pdf',
            sizeLabel: '2,4 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'TD_loi_normale.pdf',
            sizeLabel: '1,8 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'notes_chapitre_3.pdf',
            sizeLabel: '3,3 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: [
          'Comprendre la courbe de la loi normale',
          'Utiliser la loi normale pour des calculs de probabilités',
        ],
        keyPoints: [
          'Courbe symétrique autour de μ',
          '68% des valeurs dans [μ − σ, μ + σ]',
          '95% des valeurs dans [μ − 2σ, μ + 2σ]',
          'Standardisation : Z = (X − μ) / σ ~ N(0, 1)',
        ],
        commonMistakes: [
          'Confondre variance σ² et écart-type σ',
          'Oublier de standardiser avant d’utiliser les tables',
          'Interpréter une probabilité en % sans vérifier l’intervalle',
        ],
        weakSpot: 'Temps estimé et calculs',
      ),
      MvpCourse(
        id: 'bases-statistiques',
        subjectId: 'math',
        title: 'Bases des statistiques',
        chapterLabel: 'Chapitre 2',
        description:
            'Moyenne, médiane, dispersion et lecture rapide des séries.',
        icon: Icons.pie_chart_rounded,
        accent: RevisionColors.mint,
        completedLessons: 2,
        totalLessons: 6,
        durationMinutes: 18,
        difficulty: 'Facile',
        mastery: 0.33,
        sources: [
          MvpSourceFile(
            fileName: 'stats_intro.pdf',
            sizeLabel: '1,6 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'exercices_stats.pdf',
            sizeLabel: '900 Ko',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: ['Lire une série statistique', 'Identifier une dispersion'],
        keyPoints: ['Moyenne sensible aux valeurs extrêmes', 'Médiane robuste'],
        commonMistakes: ['Comparer deux séries sans regarder la dispersion'],
        weakSpot: 'Lecture des écarts',
      ),
      MvpCourse(
        id: 'algebre-lineaire',
        subjectId: 'math',
        title: 'Algèbre linéaire',
        chapterLabel: 'Chapitre 5',
        description: 'Matrices, vecteurs et transformations linéaires.',
        icon: Icons.view_in_ar_rounded,
        accent: RevisionColors.violet,
        completedLessons: 4,
        totalLessons: 8,
        durationMinutes: 25,
        difficulty: 'Intermédiaire',
        mastery: 0.50,
        sources: [
          MvpSourceFile(
            fileName: 'algebre_matrices.pdf',
            sizeLabel: '3,0 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: ['Manipuler les matrices', 'Lire une transformation'],
        keyPoints: [
          'Produit matriciel non commutatif',
          'Le rang mesure l’information',
        ],
        commonMistakes: ['Inverser les dimensions dans un produit'],
        weakSpot: 'Produit matriciel',
      ),
      MvpCourse(
        id: 'probabilites',
        subjectId: 'math',
        title: 'Probabilités',
        chapterLabel: 'Chapitre 6',
        description: 'Evénements, indépendance et variables aléatoires.',
        icon: Icons.casino_rounded,
        accent: RevisionColors.coral,
        completedLessons: 0,
        totalLessons: 6,
        durationMinutes: 15,
        difficulty: 'À lancer',
        mastery: 0,
        sources: [
          MvpSourceFile(
            fileName: 'probabilites.pdf',
            sizeLabel: '2,2 Mo',
            statusLabel: 'À traiter',
          ),
        ],
        learnItems: [
          'Identifier les événements',
          'Calculer une probabilité conditionnelle',
        ],
        keyPoints: ['P(A ∩ B) = P(A)P(B) si indépendants'],
        commonMistakes: ['Confondre union et intersection'],
        weakSpot: 'Probabilité conditionnelle',
      ),
    ],
  ),
  MvpSubject(
    id: 'philo',
    name: 'Philosophie',
    subtitle: 'Continue ton progrès',
    accent: RevisionColors.philosophyAccent,
    icon: Icons.account_balance_rounded,
    courses: [
      MvpCourse(
        id: 'kant',
        subjectId: 'philo',
        title: 'Kant',
        chapterLabel: 'Leçon 2',
        description: 'Devoir, raison pratique et autonomie morale.',
        icon: Icons.menu_book_rounded,
        accent: RevisionColors.pink,
        completedLessons: 2,
        totalLessons: 6,
        durationMinutes: 22,
        difficulty: 'Intermédiaire',
        mastery: 0.36,
        sources: [
          MvpSourceFile(
            fileName: 'kant_devoir.pdf',
            sizeLabel: '1,9 Mo',
            statusLabel: 'Prêt',
          ),
          MvpSourceFile(
            fileName: 'notes_kant.pdf',
            sizeLabel: '850 Ko',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: [
          'Comprendre l’impératif catégorique',
          'Distinguer devoir et intérêt',
        ],
        keyPoints: [
          'La morale suppose l’autonomie',
          'L’action morale vaut par son intention',
        ],
        commonMistakes: ['Réduire Kant à une morale de l’obéissance'],
        weakSpot: 'Impératif catégorique',
      ),
      MvpCourse(
        id: 'descartes',
        subjectId: 'philo',
        title: 'Descartes',
        chapterLabel: 'Leçon 3',
        description: 'Doute méthodique, cogito et vérité.',
        icon: Icons.psychology_rounded,
        accent: RevisionColors.amber,
        completedLessons: 1,
        totalLessons: 6,
        durationMinutes: 20,
        difficulty: 'Facile',
        mastery: 0.20,
        sources: [
          MvpSourceFile(
            fileName: 'descartes_cogito.pdf',
            sizeLabel: '1,4 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: ['Comprendre le doute méthodique', 'Expliquer le cogito'],
        keyPoints: ['Le doute sert à fonder une certitude'],
        commonMistakes: ['Confondre doute sceptique et doute méthodique'],
        weakSpot: 'Cogito',
      ),
      MvpCourse(
        id: 'liberte-devoir',
        subjectId: 'philo',
        title: 'Liberté et devoir',
        chapterLabel: 'Leçon 4',
        description: 'Responsabilité, contrainte et autonomie.',
        icon: Icons.balance_rounded,
        accent: RevisionColors.mint,
        completedLessons: 0,
        totalLessons: 5,
        durationMinutes: 18,
        difficulty: 'À lancer',
        mastery: 0,
        sources: [
          MvpSourceFile(
            fileName: 'liberte_devoir.pdf',
            sizeLabel: '2,1 Mo',
            statusLabel: 'Prêt',
          ),
        ],
        learnItems: [
          'Distinguer liberté et caprice',
          'Relier devoir et autonomie',
        ],
        keyPoints: [
          'Une contrainte peut rendre libre si elle structure l’action',
        ],
        commonMistakes: ['Opposer mécaniquement liberté et devoir'],
        weakSpot: 'Définitions',
      ),
    ],
  ),
];

~~~

### lib/features/mvp/presentation/mvp_course_detail_page.dart

~~~dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpCourseDetailPage extends StatelessWidget {
  const MvpCourseDetailPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(courseId);
    final subject = MvpStudyController.instance.subjects.firstWhere(
      (subject) => subject.id == course.subjectId,
    );

    return RevisionPageScaffold(
      children: [
        MvpBackBar(
          trailing: Wrap(
            spacing: RevisionSpacing.s,
            children: [
              mvpSmallPill(
                icon: Icons.description_outlined,
                label: 'Fiche',
                color: RevisionColors.textMuted,
              ),
              GestureDetector(
                onTap: () => showMvpSourcesSheet(context, course),
                child: mvpSmallPill(
                  icon: Icons.folder_copy_outlined,
                  label: 'Sources',
                  color: RevisionColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevisionIconTile(
              icon: course.icon,
              accent: course.accent,
              size: 64,
              iconSize: 36,
            ),
            const SizedBox(width: RevisionSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: RevisionTypography.caption.copyWith(
                      color: subject.accent,
                    ),
                  ),
                  Text(course.title, style: RevisionTypography.pageTitle),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    '${course.chapterLabel} · ${course.durationMinutes} min',
                    style: RevisionTypography.body,
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          course.description,
          style: RevisionTypography.body.copyWith(color: RevisionColors.text),
        ),
        RevisionStatTriplet(
          items: [
            RevisionStatItem(
              icon: Icons.track_changes_rounded,
              label: 'Progression',
              value: course.progressLabel,
              color: RevisionColors.cyan,
            ),
            RevisionStatItem(
              icon: Icons.schedule_rounded,
              label: 'Temps estimé',
              value: '${course.durationMinutes} min',
              color: RevisionColors.textMuted,
            ),
            RevisionStatItem(
              icon: Icons.star_border_rounded,
              label: 'Difficulté',
              value: course.difficulty,
              color: RevisionColors.amber,
            ),
          ],
        ),
        Column(
          children: [
            RevisionModeCard(
              title: 'Révision rapide',
              description: 'Synthèse essentielle',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              onTap: () =>
                  _startSession(context, course, MvpRevisionMode.quick),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Révision approfondie',
              description: 'Cours complet et exemples',
              icon: Icons.menu_book_rounded,
              accent: RevisionColors.violet,
              onTap: () => _startSession(context, course, MvpRevisionMode.deep),
            ),
            const SizedBox(height: RevisionSpacing.m),
            RevisionModeCard(
              title: 'Préparation examen',
              description: 'Exercices et sujets corrigés',
              icon: Icons.ads_click_rounded,
              accent: RevisionColors.pink,
              onTap: () => _startSession(context, course, MvpRevisionMode.exam),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: RevisionGradientButton(
                label: 'Voir la fiche',
                icon: Icons.article_outlined,
                expanded: true,
                onPressed: () => context.go(AppRoutes.courseSheet(course.id)),
              ),
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: RevisionGradientButton(
                label: 'Sources',
                icon: Icons.folder_copy_outlined,
                expanded: true,
                gradient: const LinearGradient(
                  colors: [RevisionColors.glassStrong, RevisionColors.glass],
                ),
                onPressed: () => showMvpSourcesSheet(context, course),
              ),
            ),
          ],
        ),
        RevisionSectionHeader(title: 'Ce que tu vas apprendre'),
        RevisionGlassCard(
          child: Column(
            children: [
              for (final item in course.learnItems) ...[
                mvpLearnItem(item),
                if (item != course.learnItems.last)
                  const SizedBox(height: RevisionSpacing.m),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _startSession(
    BuildContext context,
    MvpCourse course,
    MvpRevisionMode mode,
  ) {
    context.go(
      AppRoutes.revisionSessionV2(
        sessionId: 'session-${course.id}-${mode.name}',
        courseId: course.id,
        mode: mode.name,
      ),
    );
  }
}

~~~

### lib/features/mvp/presentation/mvp_course_sheet_page.dart

~~~dart
import 'package:flutter/material.dart';

import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpCourseSheetPage extends StatefulWidget {
  const MvpCourseSheetPage({required this.courseId, super.key});

  final String courseId;

  @override
  State<MvpCourseSheetPage> createState() => _MvpCourseSheetPageState();
}

class _MvpCourseSheetPageState extends State<MvpCourseSheetPage> {
  MvpRevisionMode _mode = MvpRevisionMode.quick;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(
      widget.courseId,
    );

    return RevisionPageScaffold(
      children: [
        MvpBackBar(
          title: course.title,
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_rounded),
            color: RevisionColors.text,
            tooltip: 'Partager',
          ),
        ),
        RevisionSegmentedControl<MvpRevisionMode>(
          values: MvpRevisionMode.values,
          selected: _mode,
          labelOf: (mode) => mode.label,
          onChanged: (mode) => setState(() => _mode = mode),
        ),
        _SheetPanel(
          icon: Icons.summarize_rounded,
          iconColor: RevisionColors.blue,
          title: 'Résumé',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _summaryFor(course, _mode),
                style: RevisionTypography.body.copyWith(
                  color: RevisionColors.text,
                ),
              ),
              if (course.id == 'loi-normale') ...[
                const SizedBox(height: RevisionSpacing.m),
                Center(
                  child: Text(
                    'X ~ N(μ, σ²)',
                    style: RevisionTypography.sectionTitle.copyWith(
                      color: RevisionColors.blue,
                      fontSize: 22,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        _SheetPanel(
          icon: Icons.check_rounded,
          iconColor: RevisionColors.green,
          title: 'Points clés',
          child: Column(
            children: [
              for (final point in course.keyPoints) ...[
                _BulletLine(label: point, color: RevisionColors.mint),
                if (point != course.keyPoints.last)
                  const SizedBox(height: RevisionSpacing.s),
              ],
            ],
          ),
        ),
        _SheetPanel(
          icon: Icons.warning_rounded,
          iconColor: RevisionColors.coral,
          title: 'Pièges fréquents',
          child: Column(
            children: [
              for (final mistake in course.commonMistakes) ...[
                _BulletLine(label: mistake, color: RevisionColors.textMuted),
                if (mistake != course.commonMistakes.last)
                  const SizedBox(height: RevisionSpacing.s),
              ],
              if (course.sources.isNotEmpty) ...[
                const SizedBox(height: RevisionSpacing.m),
                RevisionSourceFileCard(
                  fileName: 'Source : ${course.sources.first.fileName}',
                  sizeLabel: course.sources.first.sizeLabel,
                  statusLabel: course.sources.first.statusLabel,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetPanel extends StatelessWidget {
  const _SheetPanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RevisionIconTile(
                icon: icon,
                accent: iconColor,
                size: 26,
                iconSize: 16,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Text(title, style: RevisionTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          child,
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('•', style: RevisionTypography.body.copyWith(color: color)),
        const SizedBox(width: RevisionSpacing.s),
        Expanded(
          child: Text(
            label,
            style: RevisionTypography.body.copyWith(color: RevisionColors.text),
          ),
        ),
      ],
    );
  }
}

String _summaryFor(MvpCourse course, MvpRevisionMode mode) {
  return switch (mode) {
    MvpRevisionMode.quick =>
      '${course.title} : l’essentiel à retenir pour répondre vite sans perdre le fil.',
    MvpRevisionMode.deep => course.description,
    MvpRevisionMode.exam =>
      '${course.title} : méthode, points clés et pièges à repérer avant le jour J.',
  };
}

~~~

### lib/features/mvp/presentation/mvp_home_page.dart

~~~dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import 'mvp_page_helpers.dart';

class MvpHomePage extends StatelessWidget {
  const MvpHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final controller = MvpStudyController.instance;
        final subject = controller.activeSubject;
        final resumeCourse = controller.resumeCourse;

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.name, style: RevisionTypography.hero),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(subject.subtitle, style: RevisionTypography.body),
                    ],
                  ),
                ),
                RevisionMasteryRing(
                  value: 0.72,
                  label: '7',
                  caption: 'jours',
                  size: 74,
                  color: subject.accent == RevisionColors.pink
                      ? RevisionColors.pink
                      : RevisionColors.green,
                ),
              ],
            ),
            RevisionResumeCourseCard(
              title: resumeCourse.title,
              subtitle: 'Reprendre le cours',
              progressLabel:
                  'Leçon ${resumeCourse.completedLessons} sur ${resumeCourse.totalLessons}',
              progress: resumeCourse.progress,
              accent: subject.accent,
              icon: resumeCourse.icon,
              onContinue: () => context.go(AppRoutes.course(resumeCourse.id)),
            ),
            RevisionSectionHeader(title: 'Tes cours de ${subject.name}'),
            Column(
              children: [
                for (final course in subject.courses) ...[
                  RevisionCourseCard(
                    title: course.title,
                    progressLabel: course.progressLabel,
                    durationLabel: '${course.durationMinutes} min',
                    progress: course.progress,
                    accent: course.accent,
                    icon: course.icon,
                    onTap: () => context.go(AppRoutes.course(course.id)),
                  ),
                  if (course != subject.courses.last)
                    const SizedBox(height: RevisionSpacing.m),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

~~~

### lib/features/mvp/presentation/mvp_page_helpers.dart

~~~dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_radius.dart';
import '../../../presentation/design_system/tokens/revision_shadows.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';

class MvpTopBar extends StatelessWidget {
  const MvpTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final subject = MvpStudyController.instance.activeSubject;

        return Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: RevisionSubjectSwitcher(
                  label: subject.name,
                  accent: subject.accent,
                  icon: subject.icon,
                  onTap: () => showMvpSubjectSheet(context),
                ),
              ),
            ),
            const RevisionTopCounters(),
          ],
        );
      },
    );
  }
}

class MvpBackBar extends StatelessWidget {
  const MvpBackBar({this.title, this.trailing, super.key});

  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            context.go(AppRoutes.home);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: RevisionColors.text,
          tooltip: 'Retour',
        ),
        Expanded(
          child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RevisionTypography.sectionTitle,
          ),
        ),
        trailing ?? const SizedBox(width: 48),
      ],
    );
  }
}

Future<void> showMvpSubjectSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _MvpSheetFrame(
        title: 'Changer de matière',
        child: AnimatedBuilder(
          animation: MvpStudyController.instance,
          builder: (context, child) {
            final controller = MvpStudyController.instance;
            final active = controller.activeSubject;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final subject in controller.subjects) ...[
                  RevisionGlassCard(
                    selected: active.id == subject.id,
                    onTap: () {
                      controller.selectSubject(subject.id);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        RevisionIconTile(
                          icon: subject.icon,
                          accent: subject.accent,
                        ),
                        const SizedBox(width: RevisionSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: RevisionTypography.sectionTitle,
                              ),
                              const SizedBox(height: RevisionSpacing.xs),
                              Text(
                                subject.subtitle,
                                style: RevisionTypography.body,
                              ),
                            ],
                          ),
                        ),
                        if (active.id == subject.id)
                          Icon(
                            Icons.check_circle_rounded,
                            color: subject.accent,
                          ),
                      ],
                    ),
                  ),
                  if (subject != controller.subjects.last)
                    const SizedBox(height: RevisionSpacing.m),
                ],
                const SizedBox(height: RevisionSpacing.l),
                RevisionGradientButton(
                  label: 'Ajouter une matière',
                  icon: Icons.add_rounded,
                  expanded: true,
                  onPressed: () {},
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

Future<void> showMvpSourcesSheet(BuildContext context, MvpCourse course) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _MvpSheetFrame(
        title: 'Sources',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final source in course.sources) ...[
              RevisionSourceFileCard(
                fileName: source.fileName,
                sizeLabel: source.sizeLabel,
                statusLabel: source.statusLabel,
              ),
              if (source != course.sources.last)
                const SizedBox(height: RevisionSpacing.m),
            ],
            const SizedBox(height: RevisionSpacing.xl),
            Center(
              child: RevisionFloatingAddButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ajout de source branché au backend au lot suivant.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _MvpSheetFrame extends StatelessWidget {
  const _MvpSheetFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: RevisionSpacing.l,
        right: RevisionSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + RevisionSpacing.l,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RevisionColors.glassStrong,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(RevisionRadius.xxl),
            bottom: Radius.circular(RevisionRadius.xl),
          ),
          border: Border.all(color: RevisionColors.borderBright),
          boxShadow: RevisionShadows.nav,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RevisionSpacing.l,
            RevisionSpacing.m,
            RevisionSpacing.l,
            RevisionSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RevisionColors.borderBright,
                    borderRadius: RevisionRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: RevisionSpacing.l),
              Text(title, style: RevisionTypography.pageTitle),
              const SizedBox(height: RevisionSpacing.l),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}

Widget mvpLearnItem(String label, {Color color = RevisionColors.green}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.check_circle_rounded, color: color, size: 18),
      const SizedBox(width: RevisionSpacing.s),
      Expanded(child: Text(label, style: RevisionTypography.body)),
    ],
  );
}

Widget mvpSmallPill({
  required IconData icon,
  required String label,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: RevisionSpacing.m,
      vertical: RevisionSpacing.s,
    ),
    decoration: BoxDecoration(
      color: RevisionColors.glassSoft,
      borderRadius: RevisionRadius.pill,
      border: Border.all(color: RevisionColors.border),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: RevisionSpacing.xs),
        Text(
          label,
          style: RevisionTypography.caption.copyWith(
            color: RevisionColors.text,
          ),
        ),
      ],
    ),
  );
}

~~~

### lib/features/mvp/presentation/mvp_progress_page.dart

~~~dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import 'mvp_page_helpers.dart';

class MvpProgressPage extends StatelessWidget {
  const MvpProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final controller = MvpStudyController.instance;
        final subject = controller.activeSubject;
        final mastery = controller.activeMastery;
        final weakCourse = subject.courses.reduce(
          (a, b) => a.mastery <= b.mastery ? a : b,
        );

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            const RevisionSectionHeader(
              title: 'Progrès',
              subtitle: 'Ta progression en un coup d’œil',
            ),
            RevisionGlassCard(
              child: Row(
                children: [
                  RevisionMasteryRing(
                    value: mastery,
                    label: '${(mastery * 100).round()}%',
                    size: 72,
                    color: RevisionColors.green,
                  ),
                  const SizedBox(width: RevisionSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bien joué !',
                          style: RevisionTypography.sectionTitle,
                        ),
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          'Tu es sur la bonne voie.',
                          style: RevisionTypography.body,
                        ),
                        const SizedBox(height: RevisionSpacing.m),
                        RevisionProgressLine(
                          value: mastery,
                          color: RevisionColors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RevisionSectionHeader(title: 'Tes cours de ${subject.name}'),
            Column(
              children: [
                for (final course in subject.courses) ...[
                  RevisionCourseCard(
                    title: course.title,
                    progressLabel: course.progressLabel,
                    durationLabel: '${(course.mastery * 100).round()}%',
                    progress: course.mastery,
                    accent: course.accent,
                    icon: course.icon,
                    onTap: () => context.go(AppRoutes.course(course.id)),
                  ),
                  if (course != subject.courses.last)
                    const SizedBox(height: RevisionSpacing.m),
                ],
              ],
            ),
            const RevisionSectionHeader(title: 'Points faibles'),
            RevisionGlassCard(
              onTap: () => context.go(AppRoutes.course(weakCourse.id)),
              child: Row(
                children: [
                  RevisionIconTile(
                    icon: Icons.priority_high_rounded,
                    accent: RevisionColors.amber,
                    size: 38,
                  ),
                  const SizedBox(width: RevisionSpacing.m),
                  Expanded(
                    child: Text(
                      weakCourse.weakSpot,
                      style: RevisionTypography.sectionTitle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    'À revoir',
                    style: RevisionTypography.caption.copyWith(
                      color: RevisionColors.amber,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: RevisionColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

~~~

### lib/features/mvp/presentation/mvp_revision_session_page.dart

~~~dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpRevisionSessionPage extends StatefulWidget {
  const MvpRevisionSessionPage({
    required this.sessionId,
    this.courseId,
    this.mode,
    super.key,
  });

  final String sessionId;
  final String? courseId;
  final String? mode;

  @override
  State<MvpRevisionSessionPage> createState() => _MvpRevisionSessionPageState();
}

class _MvpRevisionSessionPageState extends State<MvpRevisionSessionPage> {
  int _questionIndex = 0;
  String? _selectedChoice;
  bool _validated = false;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(
      widget.courseId ?? MvpStudyController.instance.resumeCourse.id,
    );
    final mode = _modeFromName(widget.mode);
    final question = mvpSessionQuestions[_questionIndex];
    final isCorrect = _selectedChoice == question.correctChoice;

    return RevisionPageScaffold(
      children: [
        MvpBackBar(
          title: mode.sessionTitle,
          trailing: mvpSmallPill(
            icon: Icons.timer_outlined,
            label: '20 min',
            color: RevisionColors.textMuted,
          ),
        ),
        Row(
          children: [
            RevisionIconTile(
              icon: course.icon,
              accent: course.accent,
              size: 58,
            ),
            const SizedBox(width: RevisionSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: RevisionTypography.sectionTitle),
                  Text(course.chapterLabel, style: RevisionTypography.body),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_questionIndex + 1} sur ${mvpSessionQuestions.length}',
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
            const SizedBox(height: RevisionSpacing.s),
            RevisionProgressLine(
              value: (_questionIndex + 1) / mvpSessionQuestions.length,
              color: RevisionColors.blue,
            ),
          ],
        ),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.prompt,
                style: RevisionTypography.body.copyWith(
                  color: RevisionColors.text,
                ),
              ),
              const SizedBox(height: RevisionSpacing.l),
              for (var index = 0; index < question.choices.length; index++) ...[
                _ChoiceTile(
                  letter: String.fromCharCode(65 + index),
                  label: question.choices[index],
                  selected: _selectedChoice == question.choices[index],
                  correct:
                      _validated &&
                      question.choices[index] == question.correctChoice,
                  incorrect:
                      _validated &&
                      _selectedChoice == question.choices[index] &&
                      question.choices[index] != question.correctChoice,
                  onTap: _validated
                      ? null
                      : () => setState(
                          () => _selectedChoice = question.choices[index],
                        ),
                ),
                if (index != question.choices.length - 1)
                  const SizedBox(height: RevisionSpacing.s),
              ],
              if (_validated) ...[
                const SizedBox(height: RevisionSpacing.l),
                Text(
                  isCorrect
                      ? 'Bonne réponse, on continue.'
                      : 'À revoir : pense à standardiser avant de lire la table.',
                  style: RevisionTypography.body.copyWith(
                    color: isCorrect
                        ? RevisionColors.green
                        : RevisionColors.amber,
                  ),
                ),
              ],
            ],
          ),
        ),
        RevisionGradientButton(
          label: _validated ? 'Continuer' : 'Valider',
          expanded: true,
          onPressed: _selectedChoice == null
              ? null
              : () {
                  if (!_validated) {
                    setState(() => _validated = true);
                    return;
                  }

                  if (_questionIndex < mvpSessionQuestions.length - 1) {
                    setState(() {
                      _questionIndex++;
                      _selectedChoice = null;
                      _validated = false;
                    });
                    return;
                  }

                  context.go(
                    AppRoutes.revisionSessionResultV2(
                      sessionId: widget.sessionId,
                      courseId: course.id,
                      mode: mode.name,
                    ),
                  );
                },
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.letter,
    required this.label,
    required this.selected,
    required this.correct,
    required this.incorrect,
    required this.onTap,
  });

  final String letter;
  final String label;
  final bool selected;
  final bool correct;
  final bool incorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = correct
        ? RevisionColors.green
        : incorrect
        ? RevisionColors.coral
        : selected
        ? RevisionColors.blue
        : RevisionColors.border;

    return RevisionGlassCard(
      onTap: onTap,
      selected: selected || correct || incorrect,
      borderColor: borderColor,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: borderColor.withValues(alpha: 0.18),
            child: Text(
              letter,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Text(
              label,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
              ),
            ),
          ),
          if (correct)
            const Icon(Icons.check_circle_rounded, color: RevisionColors.green)
          else if (incorrect)
            const Icon(Icons.cancel_rounded, color: RevisionColors.coral)
          else if (selected)
            const Icon(
              Icons.radio_button_checked_rounded,
              color: RevisionColors.blue,
            ),
        ],
      ),
    );
  }
}

MvpRevisionMode _modeFromName(String? name) {
  return MvpRevisionMode.values.firstWhere(
    (mode) => mode.name == name,
    orElse: () => MvpRevisionMode.quick,
  );
}

~~~

### lib/features/mvp/presentation/mvp_revisions_page.dart

~~~dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpRevisionsPage extends StatelessWidget {
  const MvpRevisionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final course = MvpStudyController.instance.resumeCourse;

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            const RevisionSectionHeader(
              title: 'Révisions',
              subtitle: 'Choisis ton mode de travail',
            ),
            RevisionModeCard(
              title: 'Révision rapide',
              description:
                  'Sessions courtes et ciblées pour réactiver l’essentiel.',
              icon: Icons.flash_on_rounded,
              accent: RevisionColors.blue,
              onTap: () => _start(context, course, MvpRevisionMode.quick),
            ),
            RevisionModeCard(
              title: 'Révision approfondie',
              description: 'Cours complets et exemples détaillés.',
              icon: Icons.menu_book_rounded,
              accent: RevisionColors.violet,
              onTap: () => _start(context, course, MvpRevisionMode.deep),
            ),
            RevisionModeCard(
              title: 'Préparation examen',
              description:
                  'Entraînements et sujets corrigés pour être prêt le jour J.',
              icon: Icons.ads_click_rounded,
              accent: RevisionColors.pink,
              onTap: () => _start(context, course, MvpRevisionMode.exam),
            ),
            RevisionSectionHeader(title: 'Recommandé aujourd’hui'),
            RevisionCourseCard(
              title: course.title,
              progressLabel:
                  '${course.chapterLabel} · ${course.durationMinutes} min',
              durationLabel: '${course.durationMinutes} min',
              progress: course.progress,
              accent: course.accent,
              icon: course.icon,
              onTap: () => context.go(AppRoutes.course(course.id)),
            ),
          ],
        );
      },
    );
  }

  void _start(BuildContext context, MvpCourse course, MvpRevisionMode mode) {
    context.go(
      AppRoutes.revisionSessionV2(
        sessionId: 'session-${course.id}-${mode.name}',
        courseId: course.id,
        mode: mode.name,
      ),
    );
  }
}

~~~

### lib/features/mvp/presentation/mvp_session_result_page.dart

~~~dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/mvp_study_controller.dart';
import '../domain/mvp_study_models.dart';
import 'mvp_page_helpers.dart';

class MvpSessionResultPage extends StatelessWidget {
  const MvpSessionResultPage({
    required this.sessionId,
    this.courseId,
    this.mode,
    super.key,
  });

  final String sessionId;
  final String? courseId;
  final String? mode;

  @override
  Widget build(BuildContext context) {
    final course = MvpStudyController.instance.courseOrFallback(
      courseId ?? MvpStudyController.instance.resumeCourse.id,
    );

    return RevisionPageScaffold(
      children: [
        const MvpBackBar(title: 'Session terminée'),
        const RevisionConfettiStrip(),
        RevisionGlassCard(
          child: Column(
            children: [
              const RevisionMasteryRing(
                value: 0.78,
                label: '78%',
                caption: '4/5 bonnes',
                size: 116,
                color: RevisionColors.green,
              ),
              const SizedBox(height: RevisionSpacing.l),
              Text(
                'Belle progression !',
                style: RevisionTypography.pageTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: RevisionSpacing.xs),
              Text(
                'Tu comprends mieux ${course.title.toLowerCase()}.',
                style: RevisionTypography.body,
              ),
            ],
          ),
        ),
        const RevisionSectionHeader(title: 'Tu maîtrises'),
        RevisionGlassCard(
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: RevisionColors.green,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Text(
                  'Propriétés et utilisation',
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RevisionColors.textMuted,
              ),
            ],
          ),
        ),
        const RevisionSectionHeader(title: 'À retravailler'),
        RevisionGlassCard(
          child: Row(
            children: [
              const Icon(Icons.warning_rounded, color: RevisionColors.amber),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Text(
                  course.weakSpot,
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RevisionColors.textMuted,
              ),
            ],
          ),
        ),
        const RevisionSectionHeader(title: 'Prochaine étape'),
        RevisionGlassCard(
          onTap: () => context.go(AppRoutes.course(course.id)),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: RevisionColors.violet,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Text(
                  'Révision approfondie sur ${course.title.toLowerCase()}',
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: RevisionColors.textMuted,
              ),
            ],
          ),
        ),
        RevisionGradientButton(
          label: 'Voir la fiche complète',
          expanded: true,
          gradient: const LinearGradient(
            colors: [RevisionColors.glassStrong, RevisionColors.glass],
          ),
          onPressed: () => context.go(AppRoutes.courseSheet(course.id)),
        ),
        RevisionGradientButton(
          label: 'Lancer la préparation examen',
          expanded: true,
          onPressed: () => context.go(
            AppRoutes.revisionSessionV2(
              sessionId: 'session-${course.id}-${MvpRevisionMode.exam.name}',
              courseId: course.id,
              mode: MvpRevisionMode.exam.name,
            ),
          ),
        ),
      ],
    );
  }
}

~~~

### lib/features/mvp/presentation/mvp_sources_page.dart

~~~dart
import 'package:flutter/material.dart';

import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../application/mvp_study_controller.dart';
import 'mvp_page_helpers.dart';

class MvpSourcesPage extends StatelessWidget {
  const MvpSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MvpStudyController.instance,
      builder: (context, child) {
        final controller = MvpStudyController.instance;
        final sources = controller.activeSources.toList();

        return RevisionPageScaffold(
          children: [
            const MvpTopBar(),
            RevisionSectionHeader(
              title: 'Sources',
              subtitle:
                  'Fichiers attachés aux cours de ${controller.activeSubject.name}',
            ),
            if (sources.isEmpty)
              const RevisionGlassCard(
                child: Text('Aucune source pour le moment.'),
              )
            else
              Column(
                children: [
                  for (final source in sources) ...[
                    RevisionSourceFileCard(
                      fileName: source.fileName,
                      sizeLabel: source.sizeLabel,
                      statusLabel: source.statusLabel,
                    ),
                    if (source != sources.last)
                      const SizedBox(height: RevisionSpacing.m),
                  ],
                ],
              ),
            Center(
              child: RevisionFloatingAddButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ajout de source prévu avec l’API CourseSource.',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

~~~

### lib/presentation/design_system/components/revision_mvp_components.dart

~~~dart
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/revision_colors.dart';
import '../tokens/revision_radius.dart';
import '../tokens/revision_shadows.dart';
import '../tokens/revision_spacing.dart';
import '../tokens/revision_typography.dart';

class RevisionPageScaffold extends StatelessWidget {
  const RevisionPageScaffold({
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(
      RevisionSpacing.pageX,
      RevisionSpacing.pageTop,
      RevisionSpacing.pageX,
      110,
    ),
    this.maxWidth = 520,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: padding,
              sliver: SliverList.list(
                children: [
                  for (final child in children) ...[
                    child,
                    if (child != children.last)
                      const SizedBox(height: RevisionSpacing.l),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevisionGlassCard extends StatelessWidget {
  const RevisionGlassCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RevisionSpacing.l),
    this.radius = RevisionRadius.radiusL,
    this.borderColor,
    this.backgroundColor,
    this.gradient,
    this.selected = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? backgroundColor ?? RevisionColors.glassSoft
            : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(
          color:
              borderColor ??
              (selected ? RevisionColors.blue : RevisionColors.border),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: selected
            ? RevisionShadows.soft(RevisionColors.blue)
            : RevisionShadows.glass,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: radius, onTap: onTap, child: content),
    );
  }
}

class RevisionGradientButton extends StatelessWidget {
  const RevisionGradientButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = false,
    this.gradient,
    this.foreground = RevisionColors.text,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final Gradient? gradient;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient:
              gradient ??
              const LinearGradient(
                colors: [RevisionColors.blue, RevisionColors.blueDeep],
              ),
          borderRadius: RevisionRadius.pill,
          boxShadow: RevisionShadows.soft(RevisionColors.blue),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.xl,
            vertical: RevisionSpacing.m,
          ),
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 19),
                const SizedBox(width: RevisionSpacing.s),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: expanded
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

class RevisionIconTile extends StatelessWidget {
  const RevisionIconTile({
    required this.icon,
    required this.accent,
    this.size = 52,
    this.iconSize = 28,
    super.key,
  });

  final IconData icon;
  final Color accent;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: RevisionRadius.radiusM,
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: RevisionShadows.soft(accent),
      ),
      child: Icon(icon, color: RevisionColors.text, size: iconSize),
    );
  }
}

class RevisionSubjectSwitcher extends StatelessWidget {
  const RevisionSubjectSwitcher({
    required this.label,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Changer de matiere',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40, maxWidth: 190),
          padding: const EdgeInsets.symmetric(
            horizontal: RevisionSpacing.m,
            vertical: RevisionSpacing.s,
          ),
          decoration: BoxDecoration(
            color: RevisionColors.glassSoft,
            borderRadius: RevisionRadius.pill,
            border: Border.all(color: accent, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RevisionIconTile(
                icon: icon,
                accent: accent,
                size: 24,
                iconSize: 15,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: RevisionSpacing.xs),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: RevisionColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RevisionTopCounters extends StatelessWidget {
  const RevisionTopCounters({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CounterPill(icon: Icons.local_fire_department_rounded, label: '12'),
        SizedBox(width: RevisionSpacing.s),
        _CounterPill(
          icon: Icons.diamond_rounded,
          label: '870',
          accent: RevisionColors.cyan,
        ),
      ],
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({
    required this.icon,
    required this.label,
    this.accent = RevisionColors.amber,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RevisionSpacing.s,
        vertical: RevisionSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: RevisionRadius.pill,
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: RevisionSpacing.xs),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionProgressLine extends StatelessWidget {
  const RevisionProgressLine({
    required this.value,
    this.color = RevisionColors.blue,
    this.height = 5,
    super.key,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0, 1).toDouble();

    return ClipRRect(
      borderRadius: RevisionRadius.pill,
      child: LinearProgressIndicator(
        value: clamped,
        minHeight: height,
        color: color,
        backgroundColor: RevisionColors.border.withValues(alpha: 0.72),
      ),
    );
  }
}

class RevisionMasteryRing extends StatelessWidget {
  const RevisionMasteryRing({
    required this.value,
    required this.label,
    this.size = 82,
    this.color = RevisionColors.green,
    this.caption,
    super.key,
  });

  final double value;
  final String label;
  final String? caption;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(
              value: value.clamp(0, 1).toDouble(),
              strokeWidth: 7,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: RevisionColors.border,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RevisionColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class RevisionResumeCourseCard extends StatelessWidget {
  const RevisionResumeCourseCard({
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onContinue,
    super.key,
  });

  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [accent.withValues(alpha: 0.92), RevisionColors.blueDeep],
      ),
      borderColor: Colors.white.withValues(alpha: 0.14),
      child: Row(
        children: [
          RevisionIconTile(
            icon: Icons.play_arrow_rounded,
            accent: RevisionColors.cyan,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.text.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.m),
                Row(
                  children: [
                    Expanded(
                      child: RevisionProgressLine(
                        value: progress,
                        color: RevisionColors.cyan,
                      ),
                    ),
                    const SizedBox(width: RevisionSpacing.s),
                    Text(
                      progressLabel,
                      style: RevisionTypography.caption.copyWith(
                        color: RevisionColors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          TextButton(
            onPressed: onContinue,
            style: TextButton.styleFrom(
              backgroundColor: RevisionColors.text,
              foregroundColor: RevisionColors.blueDeep,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: RevisionSpacing.m,
                vertical: RevisionSpacing.s,
              ),
            ),
            child: const Text(
              'Continuer',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class RevisionCourseCard extends StatelessWidget {
  const RevisionCourseCard({
    required this.title,
    required this.progressLabel,
    required this.durationLabel,
    required this.progress,
    required this.accent,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String progressLabel;
  final String durationLabel;
  final double progress;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48, iconSize: 27),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.s),
                Row(
                  children: [
                    Text(
                      progressLabel,
                      style: RevisionTypography.caption.copyWith(color: accent),
                    ),
                    const SizedBox(width: RevisionSpacing.m),
                    Expanded(
                      child: RevisionProgressLine(
                        value: progress,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.m),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: RevisionColors.textMuted,
                size: 15,
              ),
              const SizedBox(width: RevisionSpacing.xs),
              Text(durationLabel, style: RevisionTypography.caption),
            ],
          ),
          const SizedBox(width: RevisionSpacing.s),
          const Icon(
            Icons.chevron_right_rounded,
            color: RevisionColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class RevisionModeCard extends StatelessWidget {
  const RevisionModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [accent.withValues(alpha: 0.78), RevisionColors.glassStrong],
      ),
      borderColor: accent.withValues(alpha: 0.30),
      child: Row(
        children: [
          RevisionIconTile(icon: icon, accent: accent, size: 48),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(description, style: RevisionTypography.body),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: RevisionColors.text),
        ],
      ),
    );
  }
}

class RevisionSourceFileCard extends StatelessWidget {
  const RevisionSourceFileCard({
    required this.fileName,
    required this.sizeLabel,
    required this.statusLabel,
    this.onTap,
    super.key,
  });

  final String fileName;
  final String sizeLabel;
  final String statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.picture_as_pdf_rounded,
            accent: RevisionColors.red,
            size: 42,
            iconSize: 23,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: RevisionTypography.sectionTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '$sizeLabel · $statusLabel',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: RevisionColors.textMuted),
        ],
      ),
    );
  }
}

class RevisionSegmentedControl<T> extends StatelessWidget {
  const RevisionSegmentedControl({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.xxs),
      radius: RevisionRadius.radiusM,
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    vertical: RevisionSpacing.s,
                  ),
                  decoration: BoxDecoration(
                    gradient: value == selected
                        ? const LinearGradient(
                            colors: [
                              RevisionColors.blue,
                              RevisionColors.blueDeep,
                            ],
                          )
                        : null,
                    borderRadius: RevisionRadius.radiusS,
                  ),
                  child: Text(
                    labelOf(value),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: value == selected
                          ? RevisionColors.text
                          : RevisionColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RevisionStatTriplet extends StatelessWidget {
  const RevisionStatTriplet({required this.items, super.key});

  final List<RevisionStatItem> items;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(child: _StatItemView(item: items[index])),
            if (index != items.length - 1)
              Container(width: 1, height: 44, color: RevisionColors.border),
          ],
        ],
      ),
    );
  }
}

class RevisionStatItem {
  const RevisionStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatItemView extends StatelessWidget {
  const _StatItemView({required this.item});

  final RevisionStatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(item.icon, color: item.color, size: 20),
        const SizedBox(height: RevisionSpacing.xs),
        Text(item.label, style: RevisionTypography.caption),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          item.value,
          textAlign: TextAlign.center,
          style: RevisionTypography.sectionTitle.copyWith(
            color: item.color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class RevisionSectionHeader extends StatelessWidget {
  const RevisionSectionHeader({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: RevisionTypography.sectionTitle),
        if (subtitle != null) ...[
          const SizedBox(height: RevisionSpacing.xs),
          Text(subtitle!, style: RevisionTypography.body),
        ],
      ],
    );
  }
}

class RevisionFloatingAddButton extends StatelessWidget {
  const RevisionFloatingAddButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ajouter une source',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [RevisionColors.pink, RevisionColors.pinkDeep],
            ),
            border: Border.all(
              color: RevisionColors.pink.withValues(alpha: 0.55),
              width: 6,
            ),
            boxShadow: RevisionShadows.soft(RevisionColors.pink),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: RevisionColors.text,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class RevisionConfettiStrip extends StatelessWidget {
  const RevisionConfettiStrip({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = [
      RevisionColors.blue,
      RevisionColors.green,
      RevisionColors.pink,
      RevisionColors.amber,
      RevisionColors.violet,
      RevisionColors.mint,
    ];

    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var index = 0; index < 18; index++)
            Transform.rotate(
              angle: (index % 5 - 2) * math.pi / 8,
              child: Container(
                width: index.isEven ? 4 : 3,
                height: index.isEven ? 8 : 6,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: RevisionRadius.radiusS,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

~~~

### lib/presentation/design_system/tokens/revision_colors.dart

~~~dart
import 'package:flutter/material.dart';

class RevisionColors {
  const RevisionColors._();

  static const ink = Color(0xFF020A12);
  static const ink2 = Color(0xFF061522);
  static const ink3 = Color(0xFF0A2130);
  static const glass = Color(0xCC122230);
  static const glassSoft = Color(0x9913212E);
  static const glassStrong = Color(0xF0182C3B);
  static const border = Color(0xFF243746);
  static const borderBright = Color(0xFF335067);

  static const text = Color(0xFFF7FBFF);
  static const textMuted = Color(0xFFB6C6D5);
  static const textFaint = Color(0xFF7F93A7);

  static const blue = Color(0xFF268DFF);
  static const blueDeep = Color(0xFF3159FF);
  static const cyan = Color(0xFF35D5FF);
  static const violet = Color(0xFF8B64FF);
  static const pink = Color(0xFFFF4EA0);
  static const pinkDeep = Color(0xFFB92C75);
  static const green = Color(0xFF72E653);
  static const mint = Color(0xFF31E6BE);
  static const amber = Color(0xFFFFBC3C);
  static const coral = Color(0xFFFF5B6B);
  static const red = Color(0xFFFF475B);

  static const mathAccent = blue;
  static const philosophyAccent = pink;
  static const lawAccent = violet;
  static const financeAccent = mint;
}

~~~

### lib/presentation/design_system/tokens/revision_radius.dart

~~~dart
import 'package:flutter/material.dart';

class RevisionRadius {
  const RevisionRadius._();

  static const double s = 10;
  static const double m = 14;
  static const double l = 18;
  static const double xl = 24;
  static const double xxl = 30;
  static const double pillValue = 999;

  static const radiusS = BorderRadius.all(Radius.circular(s));
  static const radiusM = BorderRadius.all(Radius.circular(m));
  static const radiusL = BorderRadius.all(Radius.circular(l));
  static const radiusXl = BorderRadius.all(Radius.circular(xl));
  static const radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const pill = BorderRadius.all(Radius.circular(pillValue));
}

~~~

### lib/presentation/design_system/tokens/revision_shadows.dart

~~~dart
import 'package:flutter/material.dart';

import 'revision_colors.dart';

class RevisionShadows {
  const RevisionShadows._();

  static List<BoxShadow> soft(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.20),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static const List<BoxShadow> glass = [
    BoxShadow(color: Color(0x66000000), blurRadius: 22, offset: Offset(0, 14)),
  ];

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.38),
        blurRadius: 24,
        spreadRadius: 1,
      ),
    ];
  }

  static const List<BoxShadow> nav = [
    BoxShadow(color: Color(0x7A000000), blurRadius: 26, offset: Offset(0, 14)),
    BoxShadow(color: RevisionColors.glassSoft, blurRadius: 1, spreadRadius: 1),
  ];
}

~~~

### lib/presentation/design_system/tokens/revision_spacing.dart

~~~dart
class RevisionSpacing {
  const RevisionSpacing._();

  static const double xxs = 3;
  static const double xs = 6;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 36;
  static const double pageX = 20;
  static const double pageTop = 18;
  static const double navX = 16;
}

~~~

### lib/presentation/design_system/tokens/revision_typography.dart

~~~dart
import 'package:flutter/material.dart';

import 'revision_colors.dart';

class RevisionTypography {
  const RevisionTypography._();

  static const hero = TextStyle(
    color: RevisionColors.text,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: 0,
  );

  static const pageTitle = TextStyle(
    color: RevisionColors.text,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.08,
    letterSpacing: 0,
  );

  static const sectionTitle = TextStyle(
    color: RevisionColors.text,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    color: RevisionColors.textMuted,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0,
  );

  static const caption = TextStyle(
    color: RevisionColors.textFaint,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );
}

~~~

### lib/presentation/shell/revision_home_shell.dart

~~~dart
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
                child: Center(
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
    label: 'Révisions',
    icon: Icons.track_changes_rounded,
    selectedIcon: Icons.track_changes_rounded,
  ),
  _RevisionDestination(
    path: sourcesRoutePath,
    label: 'Sources',
    icon: Icons.description_outlined,
    selectedIcon: Icons.description_rounded,
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

~~~

### lib/presentation/theme/app_colors.dart

~~~dart
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const background = Color(0xFFF3FBF7);
  static const backgroundDark = Color(0xFF020A12);
  static const backgroundDarkEnd = Color(0xFF071B2B);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF122230);
  static const surfaceGlassDark = Color(0xCC122230);
  static const surfaceSubtle = Color(0xFFEAF4F0);
  static const surfaceSubtleDark = Color(0xFF1A3142);
  static const primary = Color(0xFF246B5F);
  static const primaryDark = Color(0xFF268DFF);
  static const primaryLight = Color(0xFF35D5FF);
  static const mintGlow = Color(0x66268DFF);
  static const aqua = Color(0xFF4FC4B7);
  static const violet = Color(0xFF8E6CF4);
  static const coral = Color(0xFFE977A3);
  static const amber = Color(0xFFE8C86A);
  static const text = Color(0xFF17211F);
  static const textDark = Color(0xFFEAF4F0);
  static const textSecondary = Color(0xFF5E6B67);
  static const textSecondaryDark = Color(0xFFB4C3BE);
  static const border = Color(0xFFD7E1DD);
  static const borderDark = Color(0xFF243746);
  static const success = Color(0xFF0F9F6E);
  static const warning = Color(0xFFB7791F);
  static const danger = Color(0xFFC2413A);
}

~~~

### lib/presentation/widgets/revision_background.dart

~~~dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RevisionBackground extends StatelessWidget {
  const RevisionBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF020A12),
                  Color(0xFF06182A),
                  Color(0xFF0B1028),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.background, AppColors.surfaceSubtle],
              ),
      ),
      child: child,
    );
  }
}

~~~

### lib/presentation/widgets/revision_navigation.dart

~~~dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../design_system/tokens/revision_colors.dart';
import 'revision_panel.dart';

class RevisionNavigationDestination {
  const RevisionNavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class RevisionBottomNavigation extends StatelessWidget {
  const RevisionBottomNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<RevisionNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        child: RevisionPanel(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.s,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _NavigationItem(
                    destination: destinations[index],
                    isSelected: selectedIndex == index,
                    onTap: () => onDestinationSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RevisionNavigationRail extends StatelessWidget {
  const RevisionNavigationRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final List<RevisionNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: RevisionPanel(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < destinations.length; index++) ...[
              _NavigationItem(
                destination: destinations[index],
                isSelected: selectedIndex == index,
                onTap: () => onDestinationSelected(index),
                isRail: true,
              ),
              if (index != destinations.length - 1)
                const SizedBox(height: AppSpacing.s),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    this.isRail = false,
  });

  final RevisionNavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const activeColor = RevisionColors.blue;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.58);
    final foreground = isSelected ? activeColor : inactiveColor;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: isRail ? AppSpacing.l : AppSpacing.s,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: AppRadius.radiusPill,
      ),
      child: isRail
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationIcon(
                  icon: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  color: foreground,
                  glow: isSelected,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  destination.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavigationIcon(
                  icon: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                  color: foreground,
                  glow: isSelected,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
    );

    return Semantics(
      selected: isSelected,
      button: true,
      label: destination.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({
    required this.icon,
    required this.color,
    required this.glow,
  });

  final IconData icon;
  final Color color;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          if (glow)
            BoxShadow(
              color: AppColors.mintGlow.withValues(alpha: 0.45),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

~~~

### test/app/revision_app_test.dart

~~~dart
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

~~~

### test/app/router/app_router_test.dart

~~~dart
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
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

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

  test('revision session route is a sibling of activities route', () {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    final shellRoute = harness.router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;
    final activitiesBranch = shellRoute.branches.singleWhere((branch) {
      return branch.routes.whereType<GoRoute>().any(
        (route) => route.path == AppRoutes.activities,
      );
    });
    final activitiesRoutes = activitiesBranch.routes.whereType<GoRoute>();
    final activitiesRoute = activitiesRoutes.singleWhere(
      (route) => route.path == AppRoutes.activities,
    );

    expect(
      activitiesRoutes.map((route) => route.path),
      containsAll([
        AppRoutes.activities,
        AppRoutes.revisionSessionPath,
        AppRoutes.richClosedExercisePath,
      ]),
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
      subjectsController = SubjectsController(InMemorySubjectsRepository()),
      revisionGoalsController = RevisionGoalsController(
        InMemoryRevisionGoalsRepository(),
      ),
      documentsController = DocumentsController(InMemoryDocumentsApi()),
      activityApi = InMemoryActivityApi(),
      revisionSessionsApi = InMemoryRevisionSessionsApi() {
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
  final SubjectsController subjectsController;
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
        subjectsControllerProvider.overrideWithValue(subjectsController),
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

~~~
