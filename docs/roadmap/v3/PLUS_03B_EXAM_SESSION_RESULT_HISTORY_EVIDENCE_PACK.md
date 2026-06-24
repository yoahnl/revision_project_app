# PLUS-03B - Evidence pack App

Ce pack documente les preuves App du lot. Les docs du lot sont exclues des statistiques pour éviter l'auto-récursion.

## Fichiers App produit/test

Modifiés :

```text
lib/app/router/app_router.dart
lib/features/courses/application/courses_providers.dart
lib/features/courses/data/http_courses_repository.dart
lib/features/courses/domain/courses_repository.dart
lib/features/courses/presentation/course_detail_page.dart
lib/features/courses/presentation/course_exam_preparation_page.dart
lib/features/revision_sessions/application/revision_session_controller.dart
lib/features/revision_sessions/data/http_revision_sessions_api.dart
lib/features/revision_sessions/data/revision_sessions_api.dart
lib/presentation/pages/revision_sessions/revision_session_page.dart
lib/presentation/pages/revision_sessions/revision_session_result_page.dart
test/fakes/in_memory_courses_repository.dart
test/fakes/in_memory_revision_sessions_api.dart
test/features/courses/course_detail_page_test.dart
test/features/courses/course_exam_preparation_page_test.dart
test/features/courses/courses_providers_test.dart
test/features/courses/http_courses_repository_test.dart
test/features/revision_sessions/http_revision_sessions_api_test.dart
test/features/revision_sessions/revision_session_controller_test.dart
test/features/revision_sessions/revision_session_page_test.dart
test/features/revision_sessions/revision_session_result_page_test.dart
```

Créé :

```text
lib/features/revision_sessions/presentation/exam_revision_session_flow.dart
```

## Diff stat App hors docs

```text
lib/app/router/app_router.dart                     |   2 +
.../courses/application/courses_providers.dart     |  10 ++
.../courses/data/http_courses_repository.dart      |  60 +++++++
.../courses/domain/courses_repository.dart         |  10 ++
.../courses/presentation/course_detail_page.dart   |  79 ++++++++-
.../presentation/course_exam_preparation_page.dart | 159 ++++++++++++++---
.../application/revision_session_controller.dart   |  41 +++++
.../data/http_revision_sessions_api.dart           | 105 +++++++++++
.../data/revision_sessions_api.dart                |  14 ++
.../revision_sessions/revision_session_page.dart   |  91 +++++++++-
.../revision_session_result_page.dart              |  15 +-
test/fakes/in_memory_courses_repository.dart       |  90 ++++++++++
test/fakes/in_memory_revision_sessions_api.dart    | 143 +++++++++++++++
test/features/courses/course_detail_page_test.dart |  46 ++++-
.../courses/course_exam_preparation_page_test.dart | 111 ++++++++----
test/features/courses/courses_providers_test.dart  |  30 +++-
.../courses/http_courses_repository_test.dart      |  94 +++++++++-
.../http_revision_sessions_api_test.dart           | 191 ++++++++++++++++++---
.../revision_session_controller_test.dart          |  52 ++++++
.../revision_session_page_test.dart                | 136 ++++++++++++++-
.../revision_session_result_page_test.dart         |  31 +++-
21 files changed, 1398 insertions(+), 112 deletions(-)
```

Note : le fichier `exam_revision_session_flow.dart` est non suivi tant qu'aucun commit n'est fait ; il est listé ci-dessus.

## Contrats App ajoutés

```text
Course repository:
- startCourseExamPreparation
- getCourseExamPreparationHistory

Revision sessions API:
- getExamPreparationSession
- submitExamPreparationSession
- getExamPreparationSessionResult

Route mode:
- /revision-sessions/:sessionId?mode=exam
- /revision-sessions/:sessionId/result?mode=exam
```

## Preuves de non-régression App

```text
dart analyze lib test                                      OK
flutter test test/features/courses --reporter compact      OK
flutter test test/features/activities --reporter compact   OK
flutter test test/features/revision_sessions --reporter compact OK
flutter test --reporter compact                            OK
```

## Garde-fous vérifiés

| Garde-fou | Preuve |
| --- | --- |
| Pas de faux bouton | `CourseExamPreparationPage` teste la CTA réelle et la navigation session exam. |
| Pas de score client | `ExamRevisionSessionFlow` soumet les réponses et redirige vers le résultat serveur. |
| Pas de correction pré-submit | Parser HTTP refuse les champs de correction dans les payloads QCM. |
| Quick non régressé | Tests quick session, draft, flag, completion et result toujours OK. |
| QCM riche non régressé | Suite activities et full Flutter OK. |
| Historique distinct | `CourseDetailPage` teste `Entraînement examen` et route result `mode=exam`. |

## Revue des fichiers clés

| Fichier | Rôle |
| --- | --- |
| `course_exam_preparation_page.dart` | Ajoute la CTA réelle de démarrage. |
| `exam_revision_session_flow.dart` | Flux exam dédié, sans draft ni score client. |
| `revision_session_page.dart` | Charge l'endpoint exam si `mode=exam`. |
| `revision_session_result_page.dart` | Charge le résultat exam si `mode=exam`. |
| `course_detail_page.dart` | Affiche l'historique exam et rouvre le résultat. |

## Smoke manuel

Non exécuté par Codex. Le parcours a été couvert par tests widget/router, mais aucun test manuel simulateur n'a été déclaré.
