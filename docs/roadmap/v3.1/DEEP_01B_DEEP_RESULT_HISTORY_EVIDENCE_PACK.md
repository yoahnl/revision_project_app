# DEEP-01B Evidence Pack - App

Date : 2026-06-25

Repo : App `yoahnl/revision_project_app`

## Baseline

- HEAD initial App : `861ad2f9194f3f27d1fc269c5c2f24c465c2a580`
- API touchee dans le meme lot : oui, rapport miroir dans le repo API.

## Fichiers applicatifs crees

- `lib/features/courses/presentation/course_deep_revision_result_page.dart`
- `test/features/courses/course_deep_revision_result_page_test.dart`

## Fichiers applicatifs modifies

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/domain/course_models.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/presentation/course_deep_revision_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/presentation/pages/activities/open_question_page.dart`
- `test/app/router/app_router_test.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/courses/course_deep_revision_page_test.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/courses_providers_test.dart`
- `test/features/courses/http_courses_repository_test.dart`

## Documents modifies ou crees

- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/DEEP_01B_DEEP_RESULT_HISTORY_REPORT.md`
- `docs/roadmap/v3.1/DEEP_01B_DEEP_RESULT_HISTORY_EVIDENCE_PACK.md`

## Contrats livres

```text
GET /courses/:courseId/deep-revision/sessions/:sessionId/result
GET /courses/:courseId/deep-revision/history?limit=5
```

## Preuve de routing

```diff
+ static const courseDeepRevisionResultPath =
+     '/courses/:courseId/deep-revision/sessions/:sessionId/result';
+
+ static String courseDeepRevisionResult({
+   required String courseId,
+   required String sessionId,
+ }) {
+   return '/courses/$courseId/deep-revision/sessions/$sessionId/result';
+ }
```

## Preuve UX

- `OpenQuestionPage` expose `afterEvaluationBuilder`.
- `CourseDeepRevisionPage` affiche `Voir le resultat` apres correction.
- `Voir le resultat` ouvre `AppRoutes.courseDeepRevisionResult`.
- `CourseDeepRevisionResultPage` charge le result backend.
- `CourseDetailPage` consomme `courseDeepRevisionHistoryProvider`.
- L'historique deep ouvre le result dedie.

## Preuve anti-jargon

Les tests de page result et page deep verifient l'absence de :

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

## Preuve anti-score-client

- Le score affiche dans result vient de `OpenAnswerEvaluation.score/maxScore`.
- Le score affiche dans l'historique vient de `CourseDeepRevisionHistoryItem.score`.
- Aucun score deep n'est recalcule depuis la reponse ou la correction cote App.

## Tests de preuve

```text
http_courses_repository_test.dart
course_deep_revision_page_test.dart
course_deep_revision_result_page_test.dart
course_detail_page_test.dart
courses_providers_test.dart
app_router_test.dart
```

## Validations finales

- `dart analyze lib test` : OK
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/revision_sessions --reporter compact` : OK
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK apres creation documentaire finale

## Hors scope confirme

- Pas d'examen mixte.
- Pas de quality pool.
- Pas de refonte globale CourseDetailPage.
- Pas de refonte design system.
- Pas de score canonique calcule cote App.
- Pas d'historique fake.
- Pas de faux bouton.

