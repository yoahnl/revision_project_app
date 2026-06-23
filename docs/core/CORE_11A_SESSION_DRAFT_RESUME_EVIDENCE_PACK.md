# CORE-11A — Session draft resume evidence pack

## Objectif

Preuves non sensibles côté Flutter pour CORE-11A.

## Tests App

Commandes vertes :

- `dart analyze lib test`
- `flutter test test/features/revision_sessions --reporter compact`
- `flutter test test/features/courses/course_detail_page_test.dart --reporter compact`
- `flutter test test/features/courses/http_courses_repository_test.dart --reporter compact`
- `flutter test --reporter compact`

Résultats clés :

- `revision_sessions` : 42 tests passés ;
- `course_detail_page_test.dart` : 18 tests passés ;
- `http_courses_repository_test.dart` : 26 tests passés ;
- full Flutter : 488 tests passés.

## Runtime

Marionette MCP est disponible, mais le scénario complet n'a pas été exécuté car CORE-11A n'est pas déployé côté backend et PostgreSQL local n'est pas joignable pour appliquer la migration API.

## Scope

Non réalisés volontairement :

- historique CORE-11B ;
- refonte UI ;
- Deep/Exam ;
- Today adaptatif ;
- modification liens juridiques ;
- commit/push.
