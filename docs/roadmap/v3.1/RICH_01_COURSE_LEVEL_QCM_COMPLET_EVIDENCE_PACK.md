# RICH-01 — App evidence pack

Date : 2026-06-25

## Baseline

- HEAD initial App : `c4ec04b69ff4acfef25ef65df5585d3c2d8d4d77`

## Fichiers crees

- `lib/features/courses/presentation/course_rich_revision_page.dart`
- `test/features/courses/course_rich_revision_page_test.dart`
- `docs/roadmap/v3.1/RICH_01_COURSE_LEVEL_QCM_COMPLET_REPORT.md`
- `docs/roadmap/v3.1/RICH_01_COURSE_LEVEL_QCM_COMPLET_EVIDENCE_PACK.md`

## Fichiers modifies

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/domain/course_models.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/presentation/pages/activities/activities_page.dart`
- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `test/app/router/app_router_test.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/activities/rich_closed_exercise_page_test.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/http_courses_repository_test.dart`
- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`

## UX preuve

- Carte `QCM complet` active seulement quand `courseRichRevisionOptionsProvider` confirme `canStart`.
- Etat source manquante : carte desactivee, message clair.
- Etat notion manquante : carte desactivee, message clair.
- Page dediee : titre `QCM complet`, readiness, notion, 6/10/13, profil, types inclus.
- Bouton `Demarrer le QCM complet` affiche une action reelle et appelle le repository.
- Navigation finale : `AppRoutes.richClosedExercise(sessionId: exercise.sessionId)`.

## Contrat HTTP App

```text
GET /courses/:courseId/rich-revision/options
POST /courses/:courseId/rich-revision/sessions
```

Payload de start envoye par l'App :

```json
{
  "scopeKind": "knowledge_unit",
  "scopeId": "ku-1",
  "questionCount": 10,
  "complexityProfile": "advanced"
}
```

L'App n'envoie pas `subjectId`, `documentId`, `knowledgeUnitId`, score ou correction.

## Tests de preuve

- Le parser options lit readiness, scopes, counts, profiles.
- Le repository POST envoie seulement la configuration autorisee.
- La page ready permet de choisir `10 questions` et `Avance`.
- La page blocked n'affiche pas de bouton de demarrage.
- Le detail cours ouvre la page QCM complet.
- Les routes QCM complet par session continuent de fonctionner.

## Validations

- `dart analyze lib test` : OK
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/revision_sessions --reporter compact` : OK
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK

## Hors scope confirme

- Pas de score canonique cote client.
- Pas de resultat riche reimplemente.
- Pas de preparation examen mixte.
- Pas de deep revision.
- Pas de refonte globale routeur.
- Pas de refonte design system.
