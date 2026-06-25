# DEEP-01A Evidence Pack - App

Date : 2026-06-25

Repo : App `yoahnl/revision_project_app`

## Baseline

- HEAD initial App : `e17973dd410ac6ec949f1c7614650a9bf5eb2e73`
- API touchee dans le meme lot : oui, rapport miroir dans le repo API.

## Fichiers applicatifs crees

- `lib/features/courses/presentation/course_deep_revision_page.dart`
- `test/features/courses/course_deep_revision_page_test.dart`

## Fichiers applicatifs modifies

- `lib/features/courses/domain/course_models.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/app/router/app_routes.dart`
- `lib/app/router/app_router.dart`
- `lib/presentation/pages/activities/open_question_page.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/courses/http_courses_repository_test.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/courses_providers_test.dart`
- `test/features/activities/open_question_page_test.dart`
- `test/app/router/app_router_test.dart`

## Documents modifies ou crees

- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/DEEP_01A_COURSE_LEVEL_DEEP_START_REPORT.md`
- `docs/roadmap/v3.1/DEEP_01A_COURSE_LEVEL_DEEP_START_EVIDENCE_PACK.md`

## Contrats livres

```text
GET  /courses/:courseId/deep-revision/options
POST /courses/:courseId/deep-revision/sessions
POST /courses/:courseId/deep-revision/sessions/:sessionId/submit
```

## Preuve de routing

```diff
+ static const courseDeepRevisionPath = '/courses/:courseId/deep-revision';
+
+ static String courseDeepRevision(String courseId) {
+   return '/courses/$courseId/deep-revision';
+ }
```

## Preuve UX

- `CourseDetailPage` ouvre la page `Revision approfondie`.
- La carte est active uniquement quand `canStart` et un scope existent.
- La page affiche les blockers si le cours n'est pas pret.
- Le bouton `Demarrer la question ouverte` appelle le start course-level.
- `OpenQuestionPage` est reutilisee apres demarrage reel.
- La soumission passe par `submitCourseDeepRevisionAnswer`.
- Aucun bouton n'annonce un resultat ou historique deep.

## Preuve anti-jargon

Les tests de page deep verifient l'absence de :

```text
backend
payload
ActivitySession
RevisionSession
sessionId
documentId
knowledgeUnitId
MVP+
DEEP
OPEN_QUESTION
```

## Tests de preuve

```text
http_courses_repository_test.dart
course_deep_revision_page_test.dart
course_detail_page_test.dart
courses_providers_test.dart
open_question_page_test.dart
app_router_test.dart
```

Cas couverts :

- parsing options ;
- parsing start ;
- parsing submit ;
- route course-level ;
- page ready ;
- page blocked ;
- start course-level ;
- submit course-level ;
- absence de faux bouton ;
- non regression open question.

## Validations finales

- `dart analyze lib test` : OK
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/revision_sessions --reporter compact` : OK apres relance sequentielle
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK

## Incident de validation

Une execution parallele initiale de `flutter test test/features/revision_sessions --reporter compact` a crashe avant les tests avec :

```text
PathNotFoundException: Cannot create link ... ios/Flutter/ephemeral/Packages/.packages/video_player_avfoundation-2.9.7
```

La meme commande relancee seule a passe. L'incident est donc classe comme collision d'outillage Flutter/Swift Package Manager, pas comme regression produit.

## Hors scope confirme

- Pas de result deep.
- Pas d'historique deep.
- Pas de reopen result deep.
- Pas d'examen mixte.
- Pas de score canonique calcule cote App.
- Pas de refonte design system.
- Pas de faux bouton.
- Pas de wording technique volontairement affiche.

