# CORE-11B — Session history app report

## Résumé

CORE-11B ajoute l'historique des sessions terminées dans l'app Flutter. Le détail d'un cours affiche une section `Historique`, montre les dernières sessions terminées, et ouvre la route de résultat existante sans relancer le quiz. Les sessions en cours restent gérées par CORE-11A via `Reprendre la session`.

## Audit initial avant implémentation

- Les modèles `RevisionSessionResult`, `RevisionSessionResultSession` et `RevisionSessionResultSummary` existaient déjà.
- `CourseDetailPage` affichait déjà reprise, progression, modes et sources, mais aucun historique terminé.
- `HttpCoursesRepository` savait charger la session reprenable par cours, mais pas l'historique terminé.
- `quick_revision_quiz_flow.dart` invalidait reprise/progrès après completion, mais pas l'historique.

## Décisions produit

- Historique affiché par cours uniquement dans l'UI MVP.
- Historique global non affiché côté app pour éviter une nouvelle surface de navigation.
- L'état vide affiche `Aucune session terminée pour ce cours.`
- Une session terminée ouvre directement le résultat via `AppRoutes.revisionSessionResultV2`.
- Une session en cours n'apparaît pas dans cette section : elle reste dans l'action recommandée `Reprendre`.

## Architecture Flutter

- Ajout de `RevisionSessionHistoryResponse`, `RevisionSessionHistoryItem` et `RevisionSessionHistoryCourse`.
- Extension de `CoursesRepository` avec `getCourseRevisionSessionHistory`.
- Parsing HTTP dans `HttpCoursesRepository` sur `/courses/:courseId/revision-sessions/history`.
- Ajout de `courseRevisionSessionHistoryProvider(courseId)`.
- Invalidation de l'historique après completion quick et après actions de gestion du cours.
- Ajout de `_CourseRevisionHistorySection` dans `CourseDetailPage`.

## Tests ajoutés/modifiés

- `http_courses_repository_test.dart` : parsing historique, état vide, mapping 404.
- `courses_providers_test.dart` : provider historique par cours.
- `course_detail_page_test.dart` : état vide historique et navigation vers résultat depuis une session terminée.
- Non-régression revision sessions : suite existante conservée.

## Validations exécutées

- `dart analyze lib test` : OK
- `flutter test test/features/courses/course_detail_page_test.dart --reporter compact` : 20 tests OK
- `flutter test test/features/courses/http_courses_repository_test.dart --reporter compact` : 29 tests OK
- `flutter test test/features/revision_sessions --reporter compact` : OK
- `flutter test --reporter compact` : 494 tests OK

## Vérification Dokploy

Dokploy montre que le backend production est encore sur CORE-11A. L'app CORE-11B n'a donc pas été testée en runtime contre une API CORE-11B déployée.

## Vérification Marionette

Marionette MCP et `dev/marionette_main.dart` sont disponibles. Le scénario runtime complet n'a pas été exécuté, car il nécessite un backend CORE-11B déployé ou un backend local seedé avec session terminée. À refaire après commit/push/déploiement humain.

## Fichiers créés/modifiés/supprimés

Créés :

- `docs/core/CORE_11B_SESSION_HISTORY_APP_REPORT.md`
- `docs/core/CORE_11B_SESSION_HISTORY_EVIDENCE_PACK.md`

Modifiés :

- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/courses_providers_test.dart`
- `test/features/courses/http_courses_repository_test.dart`

Supprimés : aucun.

## Limites restantes

- Pas d'historique global visible dans Progrès/Profil.
- Pas de pagination longue côté app.
- Runtime post-déploiement requis.

## Auto-review finale

- Aucun wording technique utilisateur ajouté.
- Aucune donnée fictive runtime ajoutée.
- Aucun changement de prompts/providers IA.
- CORE-11A reprise/drafts reste séparé de l'historique terminé.
- Aucun commit effectué.

## Critique du prompt

La validation Marionette complète dépend d'une API CORE-11B déployée alors que le prompt interdit commit/push. Cette preuve ne peut donc pas être honnêtement produite dans ce tour.
