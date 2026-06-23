# CORE-11B — Session history evidence pack App

## Objectif

Regrouper les preuves non sensibles du lot CORE-11B côté Flutter.

## Baseline

```text
App baseline : ccc5c159a0148a1ee090e8a60579f31ba11f0997
```

## Preuves de test

Commandes vertes :

- `dart analyze lib test`
- `flutter test test/features/courses/course_detail_page_test.dart --reporter compact`
- `flutter test test/features/courses/http_courses_repository_test.dart --reporter compact`
- `flutter test test/features/revision_sessions --reporter compact`
- `flutter test --reporter compact`

Résultats clés :

- `course_detail_page_test.dart` : 20 tests passés ;
- `http_courses_repository_test.dart` : 29 tests passés ;
- `test/features/revision_sessions` : suite passée ;
- full Flutter : 494 tests passés.

## Preuves fonctionnelles

- Le repository HTTP lit `/courses/:courseId/revision-sessions/history`.
- Le provider `courseRevisionSessionHistoryProvider(courseId)` charge l'historique par cours.
- `CourseDetailPage` affiche un état vide sans session terminée.
- `CourseDetailPage` affiche score et date pour une session terminée.
- `Voir le résultat` ouvre la route résultat existante.
- La completion quick invalide maintenant l'historique du cours.

## Dokploy

Dokploy montre que le backend production est encore le déploiement CORE-11A. CORE-11B n'a pas été déployé dans ce lot.

## Marionette

Marionette MCP est disponible et `dev/marionette_main.dart` existe. Le scénario complet n'a pas été exécuté faute de backend CORE-11B déployé ou localement seedé. Runtime post-déploiement requis.

## Scope

Non réalisés volontairement :

- historique global visible dans Progrès/Profil ;
- pagination avancée ;
- analytics ;
- refonte UI ;
- modification prompts/providers IA ;
- commit/push.

## Fichiers concernés

Voir `CORE_11B_SESSION_HISTORY_APP_REPORT.md` pour la liste complète des fichiers créés/modifiés.
