# V4-04B — Learning path frontend timeline — Evidence Pack

## 1. Objectif

Brancher le détail cours Flutter sur le contrat backend `GET /courses/:courseId/learning-path` livré en `V4-04A`, afin de remplacer la timeline provisoire par un parcours de notions réel.

## 2. Contrat backend consommé

Endpoint consommé :

```http
GET /courses/:courseId/learning-path
```

Champs utilisés :

- `generatedAt`
- `course.id`, `course.subjectId`, `course.subjectName`, `course.title`
- `summary.knowledgeUnitCount`
- `summary.solidCount`
- `summary.inProgressCount`
- `summary.toStrengthenCount`
- `summary.undiscoveredCount`
- `summary.estimatedGlobalMastery`
- `summary.mastery`
- `summary.coverage`
- `summary.readySourceCount`
- `activeNodeId`
- `primaryAction.kind`
- `primaryAction.label`
- `primaryAction.description`
- `primaryAction.estimatedMinutes`
- `primaryAction.targetKnowledgeUnitId`
- `primaryAction.targetNodeId`
- `primaryAction.enabled`
- `primaryAction.unavailableReason`
- `nodes[].id`
- `nodes[].knowledgeUnitId`
- `nodes[].courseId`
- `nodes[].subjectId`
- `nodes[].documentId`
- `nodes[].title`
- `nodes[].order`
- `nodes[].state`
- `nodes[].masteryScore`
- `nodes[].lastPracticedAt`
- `nodes[].source`
- `nodes[].display`
- `emptyState`

Champs non utilisés temporairement :

- `summary.mastery`, `summary.coverage`, `summary.readySourceCount` sont parsés mais peu affichés pour garder le détail cours sobre.
- `nodes[].masteryScore` est parsé mais non affiché en pourcentage par node pour éviter une page dashboard.
- `nodes[].display.actionLabel` est parsé mais non utilisé comme action directe tant que la Study Session V4 n'existe pas.

## 3. Résumé des changements

- Ajout des modèles Flutter `CourseLearningPath`, `CourseLearningPathNode`, `CourseLearningPathSummary`, `CourseLearningPathPrimaryAction`, `CourseLearningPathEmptyState` et enums associées.
- Ajout de `CoursesRepository.getCourseLearningPath`.
- Implémentation HTTP du endpoint `/courses/:courseId/learning-path`.
- Ajout du provider Riverpod `courseLearningPathProvider`.
- Invalidation du learning path quand les sources changent, quand une source passe en polling, et après préparation/lancement quick revision.
- Remplacement de la timeline provisoire du détail cours par les `nodes` backend.
- Utilisation de `activeNodeId` pour sélectionner la notion active.
- Utilisation de `summary.estimatedGlobalMastery` pour le ring du header.
- Utilisation de `primaryAction` pour le CTA principal.
- Affichage de `emptyState` quand aucun node n'est disponible.
- Mise à jour des tests repository/widget et du fake courses repository.

## 4. Fichiers modifiés

- `lib/features/courses/domain/course_models.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `test/fakes/in_memory_courses_repository.dart`
- `test/features/courses/http_courses_repository_test.dart`
- `test/features/courses/course_detail_page_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`

## 5. Comportement utilisateur obtenu

- Le détail cours est branché sur `/courses/:courseId/learning-path`.
- Les notions affichées viennent de `nodes` backend.
- Les états visibles viennent de `nodes[].state` et `nodes[].display.statusLabel`.
- La notion active vient de `activeNodeId`.
- Le CTA principal vient de `primaryAction.label` et `primaryAction.description`.
- Les empty states viennent de `emptyState`.
- Historique et modes restent hors du flux principal, accessibles via le menu `...`.
- Aucune timeline provisoire basée sur les options de QCM complet n'est utilisée dans le flux principal.
- Aucune donnée fake n'est inventée par Flutter.

## 6. Données utilisées et données non inventées

Données backend utilisées :

- titre du cours ;
- matière ;
- progression globale estimée ;
- nodes réels ;
- état backend de chaque node ;
- libellés `display` ;
- notion active ;
- action principale ;
- empty state.

Données qui ne sont plus calculées côté Flutter :

- état pédagogique par notion ;
- notion active ;
- statut `Solide`, `En cours`, `À renforcer`, `À découvrir`.

Données restantes indisponibles ou incomplètes :

- action notion-specific directe : le bouton bas peut ouvrir le flow legacy le plus proche, mais Study Session V4 n'existe pas encore ;
- duration picker ;
- vraie révision subject-level depuis la page Cours.

## 7. Décisions UI

Mapping visuel des états :

- `SOLID` → check vert ;
- `IN_PROGRESS` → anneau bleu ;
- `TO_STRENGTHEN` → anneau ambre ;
- `UNDISCOVERED` → cercle neutre ;
- `UNKNOWN` → cercle neutre.

CTA principal :

- `ADD_SOURCE` ouvre la bottom sheet sources ;
- `WAIT_FOR_ANALYSIS` reste non lançable ;
- `REVIEW_ACTIVE_NODE` et `CONTINUE_COURSE` utilisent le flow quick revision existant, ou reprennent une session quick existante si elle est disponible ;
- `PREPARE_QUESTIONS` déclenche la préparation existante ;
- `UNAVAILABLE` ouvre les sources seulement si l'action backend est activée.

Actions du bas :

- `Comprendre` ouvre la fiche de cours existante si une source prête existe ;
- `Réviser cette notion` est affiché quand `targetKnowledgeUnitId` existe, mais reste branché sur la route legacy rich revision ;
- sinon l'action reste `Réviser ce cours`.

Luna :

- La présence statique existante du détail cours est conservée.
- Aucun asset ni système Luna n'a été modifié.

## 8. Tests exécutés

| Commande | Résultat | Notes |
| --- | --- | --- |
| `flutter test test/features/courses/http_courses_repository_test.dart --plain-name "loads course learning path from the learning path endpoint"` | FAIL attendu initial | Rouge TDD : méthode, modèles et fixtures inexistants. |
| `flutter test test/features/courses/http_courses_repository_test.dart --plain-name "learning path"` | PASS | 2 tests : parsing endpoint + enums inconnus. |
| `flutter test test/features/courses/course_detail_page_test.dart --plain-name "course detail shows the V4 path-first layout"` | PASS | Vérifie nodes backend, `activeNodeId`, ring `62%`, absence de faux libellés. |
| `flutter test test/features/courses/course_detail_page_test.dart --plain-name "course detail displays backend learning path empty state"` | PASS | Vérifie empty state backend sans fausse timeline. |
| `flutter test test/features/courses/course_detail_page_test.dart` | PASS | 30 tests. |
| `flutter test test/features/courses/http_courses_repository_test.dart` | PASS | 43 tests. |
| `flutter test test/features/courses/courses_home_page_test.dart` | PASS | 3 tests. |
| `flutter test test/app/router/app_router_test.dart` | PASS | 23 tests. |
| `flutter test test/app/revision_app_test.dart` | PASS | 12 tests. |
| `flutter test test/features/courses/courses_providers_test.dart` | PASS | 23 tests, exécuté en extra car interface/provider modifiés. |
| `flutter analyze` | FAIL outil | Crash connu de l'analysis server : `FormatException: Unexpected end of input`, puis `analysis server exited with code 255`. Rapport écrit dans `flutter_19.log`. Aucun diagnostic de code du lot n'a été produit. |
| `git diff --check` | PASS | Aucun whitespace error. |
| `git status --short` | PASS | Working tree avec les fichiers frontend/docs attendus pour `V4-04B`, sans backend, Prisma, GenUI ni asset. |

## 9. Compatibilité

- Aucun backend modifié.
- Aucun Prisma modifié.
- Aucun contrat backend modifié.
- Le frontend consomme un endpoint additionnel existant.
- Les endpoints existants `/courses/:courseId`, `/progress`, question bank, histories et modes legacy restent conservés.
- Les routes legacy de révision, fiche, sources, historique et modes avancés restent accessibles.

## 10. Risques restants

- L'action notion-specific reste limitée : `targetKnowledgeUnitId` est connu, mais la Study Session V4 et une route notion-specific directe ne sont pas encore livrées.
- Le duration picker est absent.
- La révision subject-level reste à renforcer en `V4-03B`.
- Les modes et historiques restent legacy dans le menu secondaire.
- Les textes `display.actionLabel` par node sont parsés mais pas encore utilisés comme actions directes.

## 11. Autocritique finale

Le lot branche proprement le contrat frontend et supprime la timeline provisoire visible. Le choix le plus prudent est d'utiliser les routes legacy existantes pour les actions tant que la Study Session V4 n'existe pas. Le détail cours reste simple, mais l'action `Réviser cette notion` n'est pas encore une vraie session notion-specific dédiée.

## 12. Prochain lot recommandé

`V4-03B — Sélecteur matière et action “Réviser toute la matière”`

Pourquoi :

- `V4-04A` et `V4-04B` terminent la colonne vertébrale du détail cours.
- La surface Cours doit maintenant renforcer le sélecteur matière et l'entrée “Réviser toute la matière” avant le duration picker.
