# LOT V1-012B — Page rich closed complète et flow submit local

## 1. Résultat

Le lot V1-012B assemble les briques rich closed V1-A Flutter en une expérience utilisable dans l’application, hors Today et hors sessions IA.

Une page `RichClosedExercisePage` permet désormais de démarrer ou charger un exercice rich closed, de rendre les six types V1-A, de centraliser les réponses, de soumettre une réponse par question via l’API Flutter existante, puis d’afficher la correction backend avec les composants V1-012.

Le flow reste strictement frontend : aucun fichier backend, aucun endpoint, aucun Prisma, aucun GenUI catalogue et aucune intégration Today/session n’ont été modifiés.

## 2. Sources inspectées

### Domaine rich closed

- `revision_app/lib/features/activities/domain/rich_closed_exercise.dart`
- `revision_app/test/features/activities/fixtures/rich_closed_exercise_fixtures.dart`

### API rich closed

- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/test/features/activities/http_activities_api_test.dart`

### Application activities

- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/app/di/revision_providers.dart`
- `revision_app/test/fakes/in_memory_activity_api.dart`

### Widgets rich closed

- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_correction_list.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_correction_card.dart`

### Pages et routing

- `revision_app/lib/presentation/pages/activities/activities_page.dart`
- `revision_app/lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `revision_app/lib/presentation/pages/activities/open_question_page.dart`
- `revision_app/lib/app/router/app_routes.dart`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/core/routing/route_paths.dart`

### Tests existants

- `revision_app/test/features/activities/rich_closed_answer_controller_test.dart`
- `revision_app/test/features/activities/rich_closed_core_widgets_test.dart`
- `revision_app/test/features/activities/rich_closed_matching_ordering_widgets_test.dart`
- `revision_app/test/features/activities/rich_closed_correction_presenter_test.dart`
- `revision_app/test/features/activities/rich_closed_correction_widgets_test.dart`
- `revision_app/test/features/activities/activities_page_test.dart`
- `revision_app/test/features/activities/activity_controller_test.dart`
- `revision_app/test/app/router/app_router_test.dart`

### Docs V1

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md`

## 3. Préflight Git

Repo `revision_app` :

- Racine : `/Users/karim/Project/app-révision/revision_app`
- Branche : `main`
- Statut initial : `## main...origin/main`
- Derniers commits initiaux :
  - `9f4dc4a V1-012 — Ajout du rapport d'exécution du lot Scoring/correction UI V1-A avec widgets et présentateur`
  - `3f1bd89 V1-011 — Ajout du rapport d'exécution du lot Widgets Flutter matching/ordering et mise à jour du contrôleur`
  - `debe6f8 V1-010 — Ajout du rapport d'exécution du lot Widgets Flutter V1-A pour single/multiple/case/error et contrôleur de réponses`
  - `341a7c6 V1-009 — Ajout du rapport d'exécution du lot Domain models Flutter V1-A, modèles rich closed, DTOs, parsers et tests`
  - `7f400b6 V1-008B — Ajout du rapport d'exécution du lot Hardening API/scoring rich closed V1-A et mise à jour du plan`

Aucun fichier backend n’a été modifié. Aucune commande n’a été lancée dans `api/`.

## 4. Pourquoi ce lot existe

Les lots V1-010, V1-011 et V1-012 avaient livré les widgets pré-submit et post-submit, mais ils restaient isolés et non visibles dans une expérience produit complète.

Ce lot assemble ces briques dans une page exploitable : démarrage ou chargement d’exercice, rendu des six types, source de vérité globale pour les réponses, submit unique, affichage de correction backend.

Today reste volontairement reporté à V1-013 afin de ne pas mélanger page produit et ranking/recommandation.

## 5. Périmètre réalisé

- Extension de `ActivityApi` et `ActivityController` pour exposer les méthodes rich closed déjà présentes dans `HttpActivitiesApi`.
- Ajout de `RichClosedExerciseFlowController` et `RichClosedExerciseFlowState`.
- Ajout de `RichClosedQuestionRenderer`.
- Ajout de `RichClosedExercisePage`.
- Injection optionnelle d’un `RichClosedCoreAnswerController` dans les six widgets pré-submit existants.
- Ajout d’une route `/activities/rich-closed` sœur de `/activities` et `/activities/session`.
- Ajout d’un bouton “Questions riches” dans `ActivitiesPage`, activé seulement avec `subjectId + knowledgeUnitId`.
- Adaptation des fakes de tests et de `DemoActivityApi` au nouveau contrat Flutter.
- Ajout de tests unitaires flow, widget tests page/renderer et tests router.
- Mise à jour du plan V1 avec V1-012B.
- Création du rapport V1-012B dans `docs/v1`.

## 6. Architecture retenue

### Page

`RichClosedExercisePage` est une page Flutter non Today et non session IA. Elle accepte un `sessionId` pour charger un exercice existant ou `subjectId + knowledgeUnitId` pour démarrer un exercice.

### Controller global

`RichClosedExerciseFlowController` conserve une source de vérité globale des réponses sous forme de `RichClosedAnswer`, sans dépendre des widgets. Il gère les états `idle`, `loadingExercise`, `ready`, `submitting`, `completed` et `failed`.

### Renderer

`RichClosedQuestionRenderer` centralise le switch des six types V1-A vers les widgets natifs existants. Il ne rend aucun fallback dynamique et ne rend aucun JSON arbitraire.

### API submit

La page passe par `ActivityController.submitRichClosedExercise`, qui délègue à `ActivityApi`. Le submit envoie exactement une answer par question quand l’exercice est complet.

### État pré-submit/post-submit

Pré-submit : les widgets sont actifs, la progression affiche le nombre de questions répondables, le bouton submit reste désactivé tant que l’exercice est incomplet.

Post-submit : les widgets pré-submit disparaissent au profit de `RichClosedCorrectionList`, qui affiche la correction backend via le presenter V1-012.

### Gestion erreurs

La page affiche un message contrôlé pour erreur de démarrage/chargement, erreur de submit et absence de contexte notion.

### Absence Today/session

Aucune route Today, aucun TodayPlan, aucune page de session IA et aucun flow revision session ne sont modifiés.

## 7. Flow utilisateur

1. Depuis `ActivitiesPage`, l’utilisateur voit “Questions riches” si une notion est disponible.
2. Le bouton navigue vers `/activities/rich-closed?subjectId=...&knowledgeUnitId=...`.
3. `RichClosedExercisePage` démarre l’exercice via l’API Flutter.
4. La page affiche les six types V1-A via le renderer.
5. L’utilisateur répond aux questions.
6. Le bouton “Valider mes réponses” devient actif quand toutes les answers sont prêtes.
7. Le submit envoie les answers à l’API.
8. La page affiche le résumé et les corrections backend.

## 8. Gestion des answers

- La source de vérité globale est le `RichClosedExerciseFlowController`.
- Les widgets pré-submit peuvent partager un `RichClosedCoreAnswerController` injecté par la page.
- `single_choice`, `case_qualification` et `error_detection` produisent une answer après sélection.
- `multiple_choice` produit une answer seulement quand les bornes min/max sont respectées.
- `matching` produit une answer seulement quand toutes les paires sont complètes et uniques.
- `ordering` est considéré répondable avec l’ordre initial si l’utilisateur ne le modifie pas.
- Le submit préserve l’ordre des questions.
- Le flow ignore une answer incohérente avec sa question.
- Aucune correction, aucun score, aucune explication et aucun feedback ne sont envoyés dans les answers.

## 9. Anti-recalcul / anti-fuite

- Le frontend ne recalcule pas `score`, `isCorrect` ou `partialScore`.
- Le frontend ne déduit jamais une bonne réponse à partir des choix utilisateur.
- Le pré-submit n’affiche aucune correction.
- Le post-submit utilise `RichClosedCorrectionList` et le presenter V1-012.
- Aucun JSON arbitraire n’est rendu.
- Aucun widget libre n’est ajouté.
- Les tests vérifient que les answers envoyées ne contiennent pas `correct`, `score`, `explanation` ou `feedback`.

## 10. Fichiers créés/modifiés/supprimés

### Créés

- `revision_app/lib/features/activities/application/rich_closed_exercise_flow_controller.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart`
- `revision_app/lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `revision_app/test/features/activities/rich_closed_exercise_flow_controller_test.dart`
- `revision_app/test/features/activities/rich_closed_exercise_page_test.dart`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_012B_RICH_CLOSED_PAGE_FLOW.md`

### Modifiés

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/app/router/app_routes.dart`
- `revision_app/lib/core/routing/route_paths.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/features/activities/data/demo_activity_api.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart`
- `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart`
- `revision_app/lib/presentation/pages/activities/activities_page.dart`
- `revision_app/test/app/router/app_router_test.dart`
- `revision_app/test/fakes/in_memory_activity_api.dart`
- `revision_app/test/features/activities/activity_controller_test.dart`

### Supprimés

Aucun fichier supprimé.

## 11. Tests ajoutés ou renforcés

- Tests `RichClosedExerciseFlowController` : start, load, erreurs, answers, ordering initial, submit complet, prévention double submit, anti-fuite answers, answer incohérente ignorée.
- Tests `RichClosedExercisePage` : renderer six types, page start, progression, submit disabled/enabled, correction en cours, correction affichée, erreurs, état vide.
- Tests router : route `/activities/rich-closed`, route sœur, navigation directe, entrée visible depuis `ActivitiesPage`.
- Tests `ActivityController` : méthodes rich closed et validations minimales.
- Fakes adaptés : `InMemoryActivityApi` et fakes locaux.

## 12. Validations lancées avec résultats

Depuis `revision_app` :

- `flutter test test/features/activities/rich_closed_exercise_flow_controller_test.dart --reporter compact` : échec RED attendu avant implémentation, fichier manquant.
- `flutter test test/features/activities/rich_closed_exercise_flow_controller_test.dart --reporter compact` : réussi après implémentation.
- `flutter test test/features/activities/rich_closed_exercise_page_test.dart --reporter compact` : réussi.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : réussi.
- `dart format lib/app/router/app_router.dart lib/app/router/app_routes.dart lib/core/routing/route_paths.dart lib/features/activities/application/activity_controller.dart lib/features/activities/application/rich_closed_exercise_flow_controller.dart lib/features/activities/data/demo_activity_api.dart lib/features/activities/data/http_activities_api.dart lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart lib/presentation/pages/activities/activities_page.dart lib/presentation/pages/activities/rich_closed_exercise_page.dart test/app/router/app_router_test.dart test/fakes/in_memory_activity_api.dart test/features/activities/activity_controller_test.dart test/features/activities/rich_closed_exercise_flow_controller_test.dart test/features/activities/rich_closed_exercise_page_test.dart` : réussi.
- `dart analyze lib test` : premier passage avec 2 warnings, corrigés.
- `dart analyze lib test` : réussi, `No issues found!`.
- `flutter test test/features/activities --reporter compact` : réussi, `All tests passed!`.
- `flutter test --reporter compact` : réussi, `All tests passed!`.
- `git diff --check` : réussi avant génération du rapport, puis réussi en fin de lot après création du rapport.

Note : une tentative de lancer plusieurs `flutter test` en parallèle a provoqué un crash Flutter tooling lié aux fichiers éphémères iOS/native assets et à la startup lock. Les mêmes tests ont ensuite été relancés séquentiellement avec succès. Le lot ne retient pas cette tentative comme échec applicatif.

## 13. Validations non lancées avec justification

- Aucun test backend lancé : le lot interdit toute commande dans `api/`.
- Aucune commande dans `api/` : backend hors périmètre.
- Aucun lancement manuel de l’app : non requis, couvert par tests widget/router et suite Flutter.
- Aucun provider IA lancé : hors périmètre et interdit.
- Aucun `dart fix --apply` ni `dart format .` global : interdits.

## 14. Risques restants

- L’UX est fonctionnelle mais pas encore polishée par capture mobile réelle.
- L’entrée “Questions riches” dépend d’un contexte `subjectId + knowledgeUnitId`; les parcours sans notion affichent/maintiennent un état contrôlé mais ne proposent pas encore de sélection de notion.
- `DemoActivityApi` renvoie une correction fixe de démonstration ; la page réelle utilise l’API HTTP en environnement connecté.
- V1-013 devra décider comment Today recommande `rich_closed_exercise` sans ambiguïté avec QCM/open question.

## 15. Recommandation prochain lot

Le prochain lot logique est `V1-013 — Today integration V1`.

Aucun mini-bis bloquant n’est recommandé avant V1-013. Un polish visuel pourra être traité plus tard dans V1-024.

## 16. Passes de review

- Page flow : page start/load/ready/submitting/completed/failed vérifiée par tests.
- Controller/state : source de vérité globale, double submit bloqué, ordering initial accepté.
- Renderer six types : switch central, aucun fallback dynamique.
- API integration : méthodes rich closed exposées par `ActivityController`, fakes et HTTP API alignés.
- Anti-recalcul : corrections affichées via V1-012, answers envoyées sans correction/score.
- Entrée visible : bouton `Questions riches` depuis `ActivitiesPage`, route sœur.
- Scope : aucun backend, aucun Today, aucune revision session, aucun GenUI.

## 17. Critique honnête du prompt initial

Le prompt était clair sur le besoin produit : rendre enfin les widgets visibles dans l’app. La contrainte “page visible depuis un flow existant” nécessitait forcément une petite modification de routing GoRouter, bien que le prompt interdise le routing global sauf nécessité ; ce choix est documenté et borné à une route sœur `/activities/rich-closed`.

Le point le plus délicat était l’architecture du flow controller. Une première idée aurait été de le coupler au `RichClosedCoreAnswerController`, mais cela aurait inversé la dépendance application → présentation. Le choix final conserve un flow controller pur qui stocke des `RichClosedAnswer`, et laisse le controller UI aux widgets.

## 18. Contenu complet des fichiers créés/modifiés/supprimés pour review

Le contenu complet de tous les fichiers créés/modifiés par ce lot est inclus ci-dessous. Le fichier de rapport courant n’est pas dupliqué dans lui-même afin d’éviter une récursion documentaire infinie ; son contenu complet est le présent document.


### Modifié — `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

````markdown
# Plan d'exécution V1 — Questions riches fermées

## Introduction

Ce plan découpe la V1 “questions riches fermées” en lots atomiques. La règle directrice est d'éviter le big bang : on stabilise d'abord le contrat, puis les quality gates, puis un sous-ensemble V1-A très rentable pédagogiquement, avant d'étendre progressivement Today, les sessions IA, les fixtures et les types plus complexes.

Tous les rapports V1 doivent être créés dans `docs/v1`.

## Principes d'exécution

- Lots de 0,5 à 2 jours quand possible.
- Aucun type de question n'est ajouté sans contrat backend, parser frontend, tests anti-fuite et fallback.
- Le QCM v3 V0 reste compatible jusqu'à migration explicite.
- La réponse libre reste exclusivement dans `open_question`.
- Genkit ne choisit jamais de widget libre.
- Flutter ne rend jamais un payload arbitraire.
- Les corrections restent post-submit.
- Chaque lot doit documenter les validations lancées et les validations non lancées.

## Tableau des lots V1

| Lot | Titre | Statut | Rapport |
| --- | --- | --- | --- |
| V1-001 | Roadmap et catalogue questions riches fermées | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md |
| V1-002 | ADR contrat rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md |
| V1-003 | Audit Prisma/DTO et décision versioning | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md |
| V1-004 | Contrat backend rich question kinds | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md |
| V1-005 | Quality gates pédagogiques backend | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md |
| V1-005B | Hardening contrat public et validators rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md |
| V1-006 | Génération Genkit rich closed questions V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md |
| V1-007 | Persistance minimale V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md |
| V1-008 | API publique pré-submit/post-submit V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md |
| V1-008B | Hardening API/scoring rich closed V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_008B_RICH_CLOSED_API_SCORING_HARDENING.md |
| V1-009 | Domain models Flutter V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md |
| V1-010 | Widgets Flutter V1-A single/multiple/case/error | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md |
| V1-011 | Widgets Flutter matching/ordering | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md |
| V1-012 | Scoring/correction UI V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md |
| V1-012B | Page rich closed complète et flow submit local | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_012B_RICH_CLOSED_PAGE_FLOW.md |
| V1-013 | Today integration V1 | À faire | À créer |
| V1-014 | Revision session integration V1 | À faire | À créer |
| V1-015 | Seed V1 rich demo fixtures | À faire | À créer |
| V1-016 | E2E/smoke V1 rich questions | À faire | À créer |
| V1-017 | Timeline/date slider V1-B | À faire | À créer |
| V1-018 | True/false grid + cause/consequence V1-B | À faire | À créer |
| V1-019 | Institution matrix V1-C | À faire | À créer |
| V1-020 | Diagram labeling V1-C | À faire | À créer |
| V1-021 | Calculation MCQ modes de scrutin V1-C | À faire | À créer |
| V1-022 | Image choice/personnages historiques V1-D | À faire | À créer |
| V1-023 | Runbook demo V1 | À faire | À créer |
| V1-024 | Polish UI/accessibilité/performance | À faire | À créer |
| V1-025 | Revue finale V1 et readiness audit | À faire | À créer |

## Lots détaillés

### V1-001 — Roadmap et catalogue questions riches fermées

- Objectif : créer la vision V1, le catalogue, les exemples et le plan d'exécution.
- Pourquoi maintenant : la V0 est stable, mais les QCM restent trop basiques.
- Périmètre inclus : documentation stratégique dans `docs/v1`.
- Non-objectifs : runtime, Prisma, Genkit, Flutter, tests.
- Fichiers probablement concernés : `docs/v1/*`.
- Backend : audit seulement.
- Frontend : audit seulement.
- Genkit : audit seulement.
- GenUI : audit seulement.
- Prisma : audit seulement.
- API : aucune modification.
- Tests attendus : aucun test applicatif.
- Validations à lancer : `git diff --check` depuis `revision_app`.
- Critères d'acceptation : docs V1 créées, aucun runtime modifié.
- Critère de stop : si les repos complets ne sont pas accessibles.
- Risques : plan trop large ou trop proche d'une implémentation.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md`.

### V1-002 — ADR contrat rich closed questions

- Objectif : trancher le modèle de contrat : QCM v4, nouvelle activité `RICH_CLOSED_EXERCISE`, JSON typé ou tables spécialisées.
- Pourquoi maintenant : toutes les implémentations futures dépendent de cette décision.
- Périmètre inclus : ADR, alternatives, décision recommandée, impacts.
- Non-objectifs : migration ou code runtime.
- Fichiers probablement concernés : `docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`, rapport V1-002.
- Backend : définir discriminant `questionKind`, `answerShape`, `interactionPayload`, `correctionPayload`.
- Frontend : définir besoins de parser discriminé.
- Genkit : définir nom de schema version.
- GenUI : définir place du catalogue borné.
- Prisma : comparer stratégie JSON typé et tables dédiées.
- API : définir endpoints futurs.
- Tests attendus : aucun test runtime, checklist ADR.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : une décision claire et réversible.
- Critère de stop : si l'ADR demande une migration destructive.
- Risques : sous-estimer la dette du modèle `Question`.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md`.

### V1-003 — Audit Prisma/DTO et décision versioning

- Objectif : auditer précisément les modèles, DTO publics, serializers et mappings nécessaires à la décision V1.
- Pourquoi maintenant : éviter une migration ou un contrat incomplet.
- Périmètre inclus : documentation technique, diagrammes de mapping, risques DB.
- Non-objectifs : création de migration.
- Fichiers probablement concernés : docs V1 uniquement.
- Backend : `ActivitySession`, `Question`, `QuestionAnswer`, `QuestionVisual`, `RevisionSessionAction`.
- Frontend : modèles QCM actuels et parsers sessions.
- Genkit : versions de prompts et schemas.
- GenUI : validators existants.
- Prisma : inventaire des colonnes et contraintes.
- API : inventaire pré-submit/post-submit.
- Tests attendus : aucun test runtime.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : table claire des champs réutilisables vs manquants.
- Critère de stop : si l'audit révèle un besoin de refonte plus large.
- Risques : ambiguïté entre `DIAGNOSTIC_QUIZ` et nouveau type.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md`.

### V1-004 — Contrat backend rich question kinds

- Objectif : ajouter les types applicatifs backend V1-A sans Genkit réel.
- Pourquoi maintenant : stabiliser les invariants avant génération.
- Périmètre inclus : union discriminée V1-A, validators purs, tests unitaires.
- Non-objectifs : persistance complète ou UI.
- Fichiers probablement concernés : `api/src/modules/activities/application/**`.
- Backend : `single_choice`, `multiple_choice`, `matching`, `ordering`, `case_qualification`, `error_detection`.
- Frontend : aucun.
- Genkit : aucun flow.
- GenUI : aucun.
- Prisma : aucune migration si possible.
- API : pas encore exposée publiquement sauf helpers internes.
- Tests attendus : validators et anti-fuite.
- Validations à lancer : `npm test -- activities --runInBand`, `npm run lint:check`, `npm run build`.
- Critères d'acceptation : types fermés validés et corrections séparées.
- Critère de stop : si l'ADR n'est pas validée.
- Risques : contrat trop abstrait.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md`.

### V1-005 — Quality gates pédagogiques backend

- Objectif : refuser les exercices trop basiques ou incohérents.
- Pourquoi maintenant : éviter que Genkit V1-A produise un QCM classique.
- Périmètre inclus : règles de mix, sources, correction, tailles minimales.
- Non-objectifs : régénération IA complexe.
- Fichiers probablement concernés : générateurs/validators activities.
- Backend : quality gate pur et testé.
- Frontend : aucun.
- Genkit : prépare l'intégration.
- GenUI : aucun.
- Prisma : aucun.
- API : erreurs contrôlées.
- Tests attendus : mix insuffisant, type interdit, correction pré-submit, source invalide.
- Validations à lancer : tests activities, lint check, build.
- Critères d'acceptation : une sortie 100 % QCM simple est rejetée.
- Critère de stop : gates trop stricts pour données pauvres.
- Risques : faux négatifs sur petits documents.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md`.

### V1-005B — Hardening contrat public et validators rich closed questions

- Objectif : durcir le contrat public, les validators et les gates avant Genkit.
- Pourquoi maintenant : éviter que V1-006 produise ou accepte des payloads ambigus ou semi-privés.
- Périmètre inclus : types publics sans feedback, validation stricte de `cognitiveSkill`, bornes `multiple_choice`, scan anti-fuite renforcé.
- Non-objectifs : Genkit réel, Prisma, API publique, Flutter UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md`.

### V1-006 — Génération Genkit rich closed questions V1-A

- Objectif : générer les types V1-A via Genkit avec quotas stricts.
- Pourquoi maintenant : le contrat et les gates existent.
- Périmètre inclus : prompt, schema Zod, observer metadata-only, fallback contrôlé.
- Non-objectifs : images, matrices, timeline.
- Fichiers probablement concernés : `api/src/modules/activities/infrastructure/genkit-*`.
- Backend : adapter generator V1-A.
- Frontend : aucun.
- Genkit : nouveau flow ou nouveau mode selon ADR.
- GenUI : aucun.
- Prisma : aucun.
- API : pas encore public si persistance absente.
- Note V1-006 réalisé : le générateur reste non public, non persisté et non branché API.
- Tests attendus : mock Genkit, schema strict, error codes whitelistés.
- Validations à lancer : tests ai/activities, lint check, build.
- Critères d'acceptation : le prompt impose `questionTypeMix`.
- Critère de stop : provider réel requis dans tests.
- Risques : prompts trop longs.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md`.

### V1-007 — Persistance minimale V1-A

- Objectif : persister les questions riches V1-A.
- Pourquoi maintenant : génération utile seulement si relue et soumise.
- Périmètre inclus : modèle choisi par ADR, migration si nécessaire, repository.
- Non-objectifs : UI Flutter.
- Fichiers probablement concernés : Prisma, repository activities.
- Backend : adapter Prisma.
- Frontend : aucun.
- Genkit : aucun changement fonctionnel.
- GenUI : aucun.
- Prisma : migration non destructive si nécessaire.
- API : mapping interne.
- Note V1-007 réalisé : persistance dédiée `RichClosedExercisePayload` et `RichClosedExerciseResult`, payload interne JSON typé, relecture pré-submit via mapper public.
- Tests attendus : persistance, relecture pré-submit, anti-fuite.
- Validations à lancer : `npx prisma validate`, `npm run prisma:generate`, tests activities, migration sur DB jetable si créée.
- Critères d'acceptation : données privées jamais exposées pré-submit.
- Critère de stop : migration destructive.
- Risques : JSON difficile à requêter.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md`.

### V1-008 — API publique pré-submit/post-submit V1-A

- Objectif : exposer un contrat public pour démarrer et soumettre un exercice riche fermé.
- Pourquoi maintenant : la persistance existe.
- Périmètre inclus : endpoints ou extension contrôlée, DTO, error mapping.
- Non-objectifs : Flutter UI.
- Fichiers probablement concernés : controller activities, use cases.
- Backend : pré-submit sans correction, post-submit avec correction.
- Frontend : lecture seule du contrat.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : nouveau type d'activité ou version selon ADR.
- Note V1-008 réalisé : endpoints `/activities/rich-closed/start`, `/activities/rich-closed/:sessionId`, `/activities/rich-closed/:sessionId/submit` et `/activities/rich-closed/:sessionId/result`.
- Tests attendus : e2e critiques, 400/404/409/422, anti-fuite.
- Validations à lancer : tests e2e, activities, lint check, build.
- Critères d'acceptation : endpoints exploitables par Flutter.
- Critère de stop : contrat public ambigu.
- Risques : casser QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md`.

### V1-008B — Hardening API/scoring rich closed V1-A

- Objectif : corriger les validations de soumission et le cas `documentId: null` avant l’intégration Flutter.
- Pourquoi maintenant : éviter que V1-009 consomme un contrat qui accepte des IDs inconnus ou rejette artificiellement un document nul.
- Périmètre inclus : scorer rich closed, use case de démarrage, tests module/use case/scorer.
- Non-objectifs : Prisma, Genkit, Flutter, Today, revision sessions, seed.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_008B_RICH_CLOSED_API_SCORING_HARDENING.md`.

### V1-009 — Domain models Flutter V1-A

- Objectif : ajouter les modèles Flutter discriminés pour V1-A.
- Pourquoi maintenant : le contrat API est public.
- Périmètre inclus : domain, parsers data, fakes, tests.
- Non-objectifs : widgets complets.
- Fichiers probablement concernés : `lib/features/activities/domain/**`, data, tests.
- Backend : aucun.
- Frontend : sealed classes par `questionKind`.
- Note V1-009 réalisé : modèles discriminés, parsers stricts, API client préparée, aucune UI branchée.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation stricte.
- Tests attendus : parse valide/invalide, correction pré-submit rejetée.
- Validations à lancer : `dart analyze lib test`, tests activities.
- Critères d'acceptation : parser discriminé strict.
- Critère de stop : contrat backend instable.
- Risques : duplication avec QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md`.

### V1-010 — Widgets Flutter V1-A single/multiple/case/error

- Objectif : rendre les premiers types V1-A natifs.
- Pourquoi maintenant : modèles Flutter disponibles.
- Périmètre inclus : choix unique, multiple, cas, détection d'erreur.
- Non-objectifs : matching/ordering.
- Note V1-010 réalisé : widgets core V1-A ajoutés pour single/multiple/case/error, matching/ordering non inclus, correction UI complète reportée à V1-012, aucune intégration Today/session.
- Fichiers probablement concernés : pages/widgets activities.
- Backend : aucun.
- Frontend : widgets natifs accessibles.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : pré-submit, sélection, submit, correction.
- Validations à lancer : analyze, widget tests, full flutter test si possible.
- Critères d'acceptation : aucune correction visible avant submit.
- Critère de stop : overflow mobile non résolu.
- Risques : UX trop proche du QCM actuel.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md`.

### V1-011 — Widgets Flutter matching/ordering

- Objectif : ajouter association et remise en ordre.
- Pourquoi maintenant : ce sont les interactions V1-A les plus nouvelles.
- Périmètre inclus : matching, ordering, validations locales.
- Non-objectifs : timeline complète.
- Note V1-011 réalisé : widgets matching/ordering ajoutés avec interactions accessibles sans drag-only, correction UI complète reportée à V1-012, aucune intégration Today/session.
- Fichiers probablement concernés : widgets activities, tests.
- Backend : aucun.
- Frontend : menus/dropdowns ou reordering accessible.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : associations, ordre, correction, accessibilité minimale.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : interactions utilisables sans drag-only obligatoire.
- Critère de stop : interaction inaccessible.
- Risques : ergonomie mobile.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md`.

### V1-012 — Scoring/correction UI V1-A

- Objectif : unifier affichage des corrections et scores V1-A.
- Pourquoi maintenant : plusieurs widgets existent.
- Périmètre inclus : panels correction, score par type, sources post-submit.
- Non-objectifs : recalcul frontend.
- Note V1-012 réalisé : summary/result UI et correction cards V1-A ajoutées, aucun recalcul frontend, aucune intégration Today/session.
- Fichiers probablement concernés : widgets correction activities.
- Backend : aucun sauf bug de contrat.
- Frontend : affichage post-submit.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation.
- Tests attendus : aucune correction pré-submit, rendu post-submit.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : correction lisible pour chaque type V1-A.
- Critère de stop : score frontend inventé.
- Risques : incohérence visuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md`.

### V1-012B — Page rich closed complète et flow submit local

- Objectif : assembler les widgets pré-submit/post-submit rich closed en une page utilisable.
- Pourquoi maintenant : les widgets existent mais ne sont pas encore visibles dans l’app.
- Périmètre inclus : page Flutter, controller global, renderer six types, submit API, affichage correction.
- Non-objectifs : Today, revision sessions, backend, GenUI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_012B_RICH_CLOSED_PAGE_FLOW.md`.

### V1-013 — Today integration V1

- Objectif : permettre à Today de recommander un exercice riche fermé.
- Pourquoi maintenant : runtime V1-A complet.
- Périmètre inclus : action type, start payload, routing.
- Non-objectifs : ranking IA.
- Fichiers probablement concernés : backend revision Today, Flutter Today.
- Backend : action déterministe `rich_closed_exercise`.
- Frontend : navigation vers activité V1.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : Today DTO enrichi.
- Tests attendus : ranking stable, navigation.
- Validations à lancer : backend revision tests, flutter today tests.
- Critères d'acceptation : Today peut lancer un exercice riche ciblé.
- Critère de stop : ambiguïté avec open question.
- Risques : route Activities actuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md`.

### V1-014 — Revision session integration V1

- Objectif : orchestrer les exercices riches dans la session IA.
- Pourquoi maintenant : Today et activité V1 sont prêts.
- Périmètre inclus : action kind fermée, next-action bornée.
- Non-objectifs : widget libre ou chat libre.
- Fichiers probablement concernés : revision-sessions backend, Flutter session.
- Backend : `RICH_CLOSED_EXERCISE` action.
- Frontend : rendu payload métier.
- Genkit : coach choisit une enum, pas un widget.
- GenUI : aucun widget arbitraire.
- Prisma : migration possible si enum action.
- API : session response.
- Tests attendus : action, anti-fuite, routing.
- Validations à lancer : tests revision-sessions, activities, flutter revision sessions.
- Critères d'acceptation : session peut enchaîner rich closed exercise.
- Critère de stop : action coach non bornée.
- Risques : migration enum.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_014_REVISION_SESSION_INTEGRATION_V1.md`.

### V1-015 — Seed V1 rich demo fixtures

- Objectif : préparer une démo stable d'exercices riches.
- Pourquoi maintenant : intégrations principales prêtes.
- Périmètre inclus : fixtures synthétiques, dry-run, docs.
- Non-objectifs : provider IA réel.
- Fichiers probablement concernés : demo-seed API, docs demo.
- Backend : seed fixtures.
- Frontend : aucun.
- Genkit : aucun appel.
- GenUI : aucun.
- Prisma : aucun schéma si possible.
- API : aucun endpoint.
- Tests attendus : fixtures sans secret, IDs stables.
- Validations à lancer : demo-seed tests, revision/activities si impact.
- Critères d'acceptation : golden demo V1 rejouable.
- Critère de stop : besoin de données propriétaires.
- Risques : seed trop couplé au schéma.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_015_RICH_DEMO_FIXTURES.md`.

### V1-016 — E2E/smoke V1 rich questions

- Objectif : protéger les chemins critiques V1.
- Pourquoi maintenant : seed V1 disponible.
- Périmètre inclus : e2e API, smoke docs.
- Non-objectifs : couverture exhaustive.
- Fichiers probablement concernés : tests e2e API, docs demo.
- Backend : tests endpoints V1.
- Frontend : smoke manuel.
- Genkit : mocké.
- GenUI : anti-widget libre.
- Prisma : DB mockée ou test safe.
- API : contrats critiques.
- Tests attendus : pré-submit, submit, anti-fuite, error mapping.
- Validations à lancer : e2e, activities, build.
- Critères d'acceptation : régression démo détectée.
- Critère de stop : test dépendant d'un provider réel.
- Risques : flakiness.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_016_E2E_SMOKE_RICH_QUESTIONS.md`.

### V1-017 — Timeline/date slider V1-B

- Objectif : ajouter chronologie et date slider.
- Pourquoi maintenant : V1-A stabilisé.
- Périmètre inclus : backend contrat, Flutter widgets, tests.
- Non-objectifs : matrices.
- Fichiers probablement concernés : activities backend/frontend.
- Backend : validation bornes.
- Frontend : timeline responsive, slider accessible.
- Genkit : schema V1-B.
- GenUI : optionnel catalogué.
- Prisma : selon ADR.
- API : type V1-B.
- Tests attendus : ordre, bornes, correction.
- Validations à lancer : backend + Flutter targeted.
- Critères d'acceptation : dates bornées et accessibles.
- Critère de stop : slider inaccessible.
- Risques : dates discutables.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_017_TIMELINE_DATE_SLIDER.md`.

### V1-018 — True/false grid + cause/consequence V1-B

- Objectif : ajouter grille et relations cause/conséquence.
- Pourquoi maintenant : interactions comparatives avancées.
- Périmètre inclus : contrats, widgets, correction.
- Non-objectifs : matrix institutionnelle complète.
- Fichiers probablement concernés : activities.
- Backend : validations lignes/paires.
- Frontend : grille accessible et matching spécialisé.
- Genkit : quotas V1-B.
- GenUI : optionnel.
- Prisma : selon ADR.
- API : types V1-B.
- Tests attendus : lignes complètes, paires univoques.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : pas de grille trop large.
- Critère de stop : UX mobile illisible.
- Risques : surcharge cognitive.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md`.

### V1-019 — Institution matrix V1-C

- Objectif : ajouter matrice institutionnelle.
- Pourquoi maintenant : base des grids disponible.
- Périmètre inclus : contrat borné, widget table.
- Non-objectifs : diagram labeling.
- Fichiers probablement concernés : activities.
- Backend : dimensions bornées.
- Frontend : table scrollable accessible.
- Genkit : schema V1-C.
- GenUI : non principal.
- Prisma : selon ADR.
- API : type matrix.
- Tests attendus : dimensions, cellules, correction.
- Validations à lancer : targeted backend/flutter.
- Critères d'acceptation : matrice lisible mobile.
- Critère de stop : table inaccessible.
- Risques : complexité UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_019_INSTITUTION_MATRIX.md`.

### V1-020 — Diagram labeling V1-C

- Objectif : compléter des schémas institutionnels bornés.
- Pourquoi maintenant : type coûteux mais différenciant.
- Périmètre inclus : slots, labels, correction.
- Non-objectifs : SVG/Mermaid libre.
- Fichiers probablement concernés : activities widgets/validators.
- Backend : schéma de diagramme strict.
- Frontend : rendu Flutter natif.
- Genkit : payload borné.
- GenUI : éventuellement composant catalogué.
- Prisma : selon ADR.
- API : type diagram_labeling.
- Tests attendus : pas de rendu arbitraire, slots complets.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : aucun HTML/SVG/Mermaid.
- Critère de stop : payload libre requis.
- Risques : tentation de Mermaid.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_020_DIAGRAM_LABELING.md`.

### V1-021 — Calculation MCQ modes de scrutin V1-C

- Objectif : gérer des calculs fermés.
- Pourquoi maintenant : utile mais nécessite validation forte.
- Périmètre inclus : mini-données, choix, étapes post-submit.
- Non-objectifs : réponse de calcul libre.
- Fichiers probablement concernés : activities.
- Backend : vérification déterministe si possible.
- Frontend : tableau + choix.
- Genkit : génération bornée.
- GenUI : aucun libre.
- Prisma : selon ADR.
- API : type calculation_mcq.
- Tests attendus : résultats déterministes.
- Validations à lancer : tests unitaires calcul.
- Critères d'acceptation : pas de calcul IA non vérifié.
- Critère de stop : impossibilité de valider les résultats.
- Risques : erreurs de calcul.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md`.

### V1-022 — Image choice/personnages historiques V1-D

- Objectif : ajouter choix d'image avec assets contrôlés.
- Pourquoi maintenant : après stabilisation de la chaîne d'assets.
- Périmètre inclus : allowlist assets, alt text, droits.
- Non-objectifs : URL image libre générée par IA.
- Fichiers probablement concernés : storage/assets, activities.
- Backend : asset refs.
- Frontend : grille image accessible.
- Genkit : référence uniquement des assets autorisés.
- GenUI : aucun asset libre.
- Prisma : table asset possible.
- API : image_choice.
- Tests attendus : droits/allowlist, alt text obligatoire.
- Validations à lancer : tests targeted.
- Critères d'acceptation : aucun asset non allowlisté.
- Critère de stop : droits non clarifiés.
- Risques : copyright.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_022_IMAGE_CHOICE.md`.

### V1-023 — Runbook demo V1

- Objectif : documenter démo V1 de bout en bout.
- Pourquoi maintenant : fonctionnalités et seed V1 prêts.
- Périmètre inclus : runbook, smoke, scénario.
- Non-objectifs : déploiement prod.
- Fichiers probablement concernés : docs demo V1.
- Backend : commandes confirmées.
- Frontend : commandes confirmées.
- Genkit : config provider documentée.
- GenUI : limites documentées.
- Prisma : commandes non destructives.
- API : smoke.
- Tests attendus : docs diff check.
- Validations à lancer : git diff check, validations non destructives.
- Critères d'acceptation : démo rejouable.
- Critère de stop : commande non vérifiable présentée comme certaine.
- Risques : drift documentaire.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_023_DEMO_RUNBOOK_V1.md`.

### V1-024 — Polish UI/accessibilité/performance

- Objectif : rendre l'expérience V1 robuste et agréable.
- Pourquoi maintenant : les types principaux existent.
- Périmètre inclus : accessibilité, petits écrans, performance, états vides.
- Non-objectifs : nouveaux types.
- Fichiers probablement concernés : Flutter widgets activities.
- Backend : aucun sauf bug.
- Frontend : UI polish.
- Genkit : aucun.
- GenUI : aucun arbitraire.
- Prisma : aucun.
- API : aucun.
- Tests attendus : widget tests, screenshots si possible.
- Validations à lancer : analyze, flutter test.
- Critères d'acceptation : pas d'overflow, interactions accessibles.
- Critère de stop : refactor massif requis.
- Risques : dérive design.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_024_UI_ACCESSIBILITY_PERFORMANCE.md`.

### V1-025 — Revue finale V1 et readiness audit

- Objectif : auditer la readiness V1.
- Pourquoi maintenant : clôturer la roadmap.
- Périmètre inclus : audit produit, sécurité, tests, docs, démo.
- Non-objectifs : nouvelle feature.
- Fichiers probablement concernés : docs V1, tests smoke.
- Backend : vérification.
- Frontend : vérification.
- Genkit : vérification logs et prompts.
- GenUI : vérification catalogue borné.
- Prisma : migration status.
- API : e2e.
- Tests attendus : suite non destructive complète selon contexte.
- Validations à lancer : backend + frontend ciblés, build, diff check.
- Critères d'acceptation : V1 présentable et sûre.
- Critère de stop : fuite de correction, widget libre, tests critiques rouges.
- Risques : dette non documentée.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_025_READINESS_AUDIT.md`.

````


### Modifié — `revision_app/lib/app/router/app_router.dart`

````dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/activities/application/activity_controller.dart';
import '../../features/auth/application/auth_controller.dart';
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
    initialLocation: AppRoutes.subjects,
    refreshListenable: authController,
    redirect: (context, state) {
      return executeRevisionRedirect(authController, state);
    },
    routes: [
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.subjects,
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
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
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
    return AppRoutes.subjects;
  }

  return null;
}

````


### Modifié — `revision_app/lib/app/router/app_routes.dart`

````dart
class AppRoutes {
  const AppRoutes._();

  static const root = '/';
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

````


### Modifié — `revision_app/lib/core/routing/route_paths.dart`

````dart
import '../../app/router/app_routes.dart';

const String subjectsRoutePath = AppRoutes.subjects;
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

````


### Modifié — `revision_app/lib/features/activities/application/activity_controller.dart`

````dart
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';
import '../domain/rich_closed_exercise.dart';

typedef DiagnosticQuizSubmitter =
    Future<DiagnosticQuizResult> Function(List<DiagnosticQuizAnswer> answers);
typedef OpenAnswerSubmitter =
    Future<OpenAnswerSubmissionResult> Function(String answerText);

const openQuestionMinAnswerLength = 12;

abstract interface class ActivityApi {
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  });

  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  });

  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  });

  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  });

  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  });

  Future<RichClosedExercise> getRichClosedExercise(String sessionId);

  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  });

  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  );
}

class ActivityController {
  const ActivityController(this._api);

  final ActivityApi _api;

  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    final trimmedSubjectId = subjectId.trim();

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _api.startNextActivity(
      subjectId: trimmedSubjectId,
      knowledgeUnitId: knowledgeUnitId,
    );
  }

  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    if (answers.isEmpty) {
      throw ArgumentError('At least one answer is required');
    }

    return _api.submitResult(sessionId: sessionId, answers: answers);
  }

  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    final trimmedSubjectId = subjectId.trim();
    final trimmedKnowledgeUnitId = knowledgeUnitId.trim();

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    if (trimmedKnowledgeUnitId.isEmpty) {
      throw ArgumentError('Knowledge unit id is required');
    }

    return _api.startOpenQuestion(
      subjectId: trimmedSubjectId,
      knowledgeUnitId: trimmedKnowledgeUnitId,
    );
  }

  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    final trimmedSessionId = sessionId.trim();
    final trimmedAnswerText = answerText.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Activity session id is required');
    }

    if (trimmedAnswerText.isEmpty) {
      throw ArgumentError('Open answer text is required');
    }

    return _api.submitOpenAnswer(
      sessionId: trimmedSessionId,
      answerText: trimmedAnswerText,
    );
  }

  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) {
    final trimmedSubjectId = subjectId.trim();
    final trimmedKnowledgeUnitId = knowledgeUnitId.trim();
    final trimmedDocumentId = documentId?.trim();

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    if (trimmedKnowledgeUnitId.isEmpty) {
      throw ArgumentError('Knowledge unit id is required');
    }

    return _api.startRichClosedExercise(
      subjectId: trimmedSubjectId,
      knowledgeUnitId: trimmedKnowledgeUnitId,
      documentId: trimmedDocumentId == null || trimmedDocumentId.isEmpty
          ? null
          : trimmedDocumentId,
      questionCount: questionCount,
      complexityProfile: complexityProfile,
      questionTypeMix: questionTypeMix,
    );
  }

  Future<RichClosedExercise> getRichClosedExercise(String sessionId) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Activity session id is required');
    }

    return _api.getRichClosedExercise(trimmedSessionId);
  }

  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Activity session id is required');
    }

    if (answers.isEmpty) {
      throw ArgumentError('At least one answer is required');
    }

    return _api.submitRichClosedExercise(
      sessionId: trimmedSessionId,
      answers: answers,
    );
  }

  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Activity session id is required');
    }

    return _api.getRichClosedExerciseResult(trimmedSessionId);
  }
}

class OpenQuestionSessionController {
  OpenQuestionSessionController({required this.activity, this.submitter});

  final OpenQuestionActivity activity;
  final OpenAnswerSubmitter? submitter;

  String _answerText = '';
  OpenAnswerSubmissionResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  String get answerText => _answerText;
  OpenAnswerSubmissionResult? get result => _result;
  Object? get submitError => _submitError;
  bool get isSubmitting => _isSubmitting;
  bool get hasCorrection => _result != null;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        validationMessage == null;
  }

  String? get validationMessage {
    final trimmedAnswer = _answerText.trim();

    if (trimmedAnswer.length < openQuestionMinAnswerLength) {
      return 'Réponse trop courte';
    }

    if (trimmedAnswer.length > activity.question.maxAnswerLength) {
      return 'Réponse trop longue';
    }

    return null;
  }

  String? get submitErrorMessage {
    if (_submitError == null) {
      return null;
    }

    return 'Impossible de récupérer la correction. La correction a peut-être été enregistrée. Réessaie dans un instant.';
  }

  void updateAnswer(String answerText) {
    if (_result != null || _isSubmitting) {
      return;
    }

    _answerText = answerText;
    _submitError = null;
  }

  Future<void> submit() {
    final activeSubmit = _activeSubmit;
    if (activeSubmit != null) {
      return activeSubmit;
    }

    if (!canSubmit) {
      return Future.value();
    }

    _isSubmitting = true;
    _submitError = null;

    final future = _submitAnswer();
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitAnswer() async {
    try {
      _result = await submitter!(_answerText.trim());
    } catch (error) {
      _submitError = error;
    } finally {
      _isSubmitting = false;
      _activeSubmit = null;
    }
  }
}

class DiagnosticQuizSessionController {
  DiagnosticQuizSessionController({required this.activity, this.submitter});

  final DiagnosticQuizActivity activity;
  final DiagnosticQuizSubmitter? submitter;
  final Map<String, Set<String>> _selectedChoiceIdsByQuestion = {};

  DiagnosticQuizResult? _result;
  Object? _submitError;
  bool _isSubmitting = false;
  Future<void>? _activeSubmit;

  DiagnosticQuizResult? get result => _result;
  Object? get submitError => _submitError;
  bool get isSubmitting => _isSubmitting;
  int get answeredCount => activity.questions
      .where((question) => _isQuestionComplete(question))
      .length;
  bool get hasCorrection => _result != null;

  bool get canSubmit {
    return submitter != null &&
        !_isSubmitting &&
        _result == null &&
        activity.questions.isNotEmpty &&
        activity.questions.every(_isQuestionComplete);
  }

  String? selectedChoiceIdFor(String questionId) {
    final selectedChoiceIds = selectedChoiceIdsFor(questionId);
    return selectedChoiceIds.isEmpty ? null : selectedChoiceIds.first;
  }

  List<String> selectedChoiceIdsFor(String questionId) {
    final selectedChoiceIds = _selectedChoiceIdsByQuestion[questionId];
    if (selectedChoiceIds == null || selectedChoiceIds.isEmpty) {
      return const [];
    }

    final question = _questionById(questionId);
    if (question == null) {
      return selectedChoiceIds.toList(growable: false);
    }

    return question.choices
        .where((choice) => selectedChoiceIds.contains(choice.id))
        .map((choice) => choice.id)
        .toList(growable: false);
  }

  void selectChoice({required String questionId, required String choiceId}) {
    if (_result != null || _isSubmitting) {
      return;
    }

    final question = _questionById(questionId);
    if (question == null) {
      return;
    }

    if (!question.choices.any((choice) => choice.id == choiceId)) {
      return;
    }

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      _toggleMultipleChoice(question: question, choiceId: choiceId);
    } else {
      _selectedChoiceIdsByQuestion[questionId] = {choiceId};
    }

    _submitError = null;
  }

  Future<void> submit() {
    final activeSubmit = _activeSubmit;
    if (activeSubmit != null) {
      return activeSubmit;
    }

    if (!canSubmit) {
      return Future.value();
    }

    _isSubmitting = true;
    _submitError = null;

    final future = _submitSelectedAnswers();
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitSelectedAnswers() async {
    try {
      final result = await submitter!(
        activity.questions
            .map((question) => _answerForQuestion(question))
            .toList(growable: false),
      );
      _result = result;
    } catch (error) {
      _submitError = error;
    } finally {
      _isSubmitting = false;
      _activeSubmit = null;
    }
  }

  void _toggleMultipleChoice({
    required DiagnosticQuizQuestion question,
    required String choiceId,
  }) {
    final selectedChoiceIds = {...?_selectedChoiceIdsByQuestion[question.id]};

    if (selectedChoiceIds.contains(choiceId)) {
      selectedChoiceIds.remove(choiceId);
    } else if (selectedChoiceIds.length < question.maxSelections) {
      selectedChoiceIds.add(choiceId);
    }

    if (selectedChoiceIds.isEmpty) {
      _selectedChoiceIdsByQuestion.remove(question.id);
      return;
    }

    _selectedChoiceIdsByQuestion[question.id] = selectedChoiceIds;
  }

  bool _isQuestionComplete(DiagnosticQuizQuestion question) {
    final selectedChoiceIds = _selectedChoiceIdsByQuestion[question.id];
    if (selectedChoiceIds == null) {
      return false;
    }

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      return selectedChoiceIds.length >= question.minSelections &&
          selectedChoiceIds.length <= question.maxSelections;
    }

    return selectedChoiceIds.length == 1;
  }

  DiagnosticQuizAnswer _answerForQuestion(DiagnosticQuizQuestion question) {
    final selectedChoiceIds = selectedChoiceIdsFor(question.id);

    if (question.selectionMode == DiagnosticQuizSelectionMode.multiple) {
      return DiagnosticQuizAnswer(
        questionId: question.id,
        choiceIds: selectedChoiceIds,
      );
    }

    return DiagnosticQuizAnswer(
      questionId: question.id,
      choiceId: selectedChoiceIds.first,
    );
  }

  DiagnosticQuizQuestion? _questionById(String questionId) {
    for (final question in activity.questions) {
      if (question.id == questionId) {
        return question;
      }
    }

    return null;
  }
}

````


### Créé — `revision_app/lib/features/activities/application/rich_closed_exercise_flow_controller.dart`

````dart
import '../domain/rich_closed_exercise.dart';
import 'activity_controller.dart';

enum RichClosedExerciseFlowStatus {
  idle,
  loadingExercise,
  ready,
  submitting,
  completed,
  failed,
}

class RichClosedExerciseFlowState {
  const RichClosedExerciseFlowState({
    required this.status,
    this.exercise,
    this.result,
    this.error,
    this.answeredCount = 0,
    this.totalQuestions = 0,
  });

  const RichClosedExerciseFlowState.idle()
    : status = RichClosedExerciseFlowStatus.idle,
      exercise = null,
      result = null,
      error = null,
      answeredCount = 0,
      totalQuestions = 0;

  final RichClosedExerciseFlowStatus status;
  final RichClosedExercise? exercise;
  final RichClosedExerciseResult? result;
  final Object? error;
  final int answeredCount;
  final int totalQuestions;

  bool get isLoading => status == RichClosedExerciseFlowStatus.loadingExercise;
  bool get isSubmitting => status == RichClosedExerciseFlowStatus.submitting;
  bool get hasResult => result != null;

  bool get canSubmit {
    return status == RichClosedExerciseFlowStatus.ready &&
        exercise != null &&
        result == null &&
        totalQuestions > 0 &&
        answeredCount == totalQuestions;
  }
}

class RichClosedExerciseFlowController {
  RichClosedExerciseFlowController({required this.activityController});

  final ActivityController activityController;
  final Map<String, RichClosedAnswer> _answersByQuestionId = {};
  RichClosedExerciseFlowState _state = const RichClosedExerciseFlowState.idle();
  Future<void>? _activeSubmit;

  RichClosedExerciseFlowState get state => _state;

  List<RichClosedAnswer> get currentAnswers {
    final exercise = _state.exercise;
    if (exercise == null) {
      return const [];
    }

    return _answersFor(exercise) ?? const [];
  }

  Future<void> start({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    _state = const RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.loadingExercise,
    );

    try {
      final exercise = await activityController.startRichClosedExercise(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
        documentId: documentId,
        questionCount: questionCount,
        complexityProfile: complexityProfile,
        questionTypeMix: questionTypeMix,
      );
      _answersByQuestionId.clear();
      _state = _readyState(exercise);
    } catch (error) {
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.failed,
        error: error,
      );
    }
  }

  Future<void> load({required String sessionId}) async {
    _state = const RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.loadingExercise,
    );

    try {
      final exercise = await activityController.getRichClosedExercise(
        sessionId,
      );
      _answersByQuestionId.clear();
      _state = _readyState(exercise);
    } catch (error) {
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.failed,
        error: error,
      );
    }
  }

  void refreshAnswers() {
    final exercise = _state.exercise;
    if (exercise == null || _state.result != null) {
      return;
    }

    _state = _readyState(exercise);
  }

  void recordAnswer(RichClosedQuestion question, RichClosedAnswer? answer) {
    final exercise = _state.exercise;
    if (exercise == null || _state.result != null || _state.isSubmitting) {
      return;
    }

    if (answer == null) {
      _answersByQuestionId.remove(question.id);
    } else if (answer.questionId != question.id ||
        answer.questionKind != question.questionKind) {
      _answersByQuestionId.remove(question.id);
    } else {
      _answersByQuestionId[question.id] = answer;
    }

    _state = _readyState(exercise);
  }

  Future<void> submit() {
    final activeSubmit = _activeSubmit;
    if (activeSubmit != null) {
      return activeSubmit;
    }

    final exercise = _state.exercise;
    if (exercise == null) {
      return Future.value();
    }

    final answers = _answersFor(exercise);
    if (answers == null || !_state.canSubmit) {
      return Future.value();
    }

    _state = RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.submitting,
      exercise: exercise,
      answeredCount: _answeredCount(exercise),
      totalQuestions: exercise.questions.length,
    );

    final future = _submitAnswers(exercise: exercise, answers: answers);
    _activeSubmit = future;

    return future;
  }

  Future<void> _submitAnswers({
    required RichClosedExercise exercise,
    required List<RichClosedAnswer> answers,
  }) async {
    try {
      final result = await activityController.submitRichClosedExercise(
        sessionId: exercise.sessionId,
        answers: answers,
      );
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.completed,
        exercise: exercise,
        result: result,
        answeredCount: exercise.questions.length,
        totalQuestions: exercise.questions.length,
      );
    } catch (error) {
      _state = RichClosedExerciseFlowState(
        status: RichClosedExerciseFlowStatus.failed,
        exercise: exercise,
        error: error,
        answeredCount: _answeredCount(exercise),
        totalQuestions: exercise.questions.length,
      );
    } finally {
      _activeSubmit = null;
    }
  }

  RichClosedExerciseFlowState _readyState(RichClosedExercise exercise) {
    return RichClosedExerciseFlowState(
      status: RichClosedExerciseFlowStatus.ready,
      exercise: exercise,
      answeredCount: _answeredCount(exercise),
      totalQuestions: exercise.questions.length,
    );
  }

  int _answeredCount(RichClosedExercise exercise) {
    return exercise.questions.where(_answerForQuestionExists).length;
  }

  List<RichClosedAnswer>? _answersFor(RichClosedExercise exercise) {
    final answers = <RichClosedAnswer>[];

    for (final question in exercise.questions) {
      final answer = _answerForQuestion(question);
      if (answer == null) {
        return null;
      }
      answers.add(answer);
    }

    return answers;
  }

  bool _answerForQuestionExists(RichClosedQuestion question) {
    return _answerForQuestion(question) != null;
  }

  RichClosedAnswer? _answerForQuestion(RichClosedQuestion question) {
    final recordedAnswer = _answersByQuestionId[question.id];
    if (recordedAnswer != null) {
      return recordedAnswer;
    }

    if (question is RichClosedOrderingQuestion) {
      return RichClosedOrderingAnswer(
        questionId: question.id,
        orderedIds: [for (final item in question.items) item.id],
      );
    }

    return null;
  }
}

````


### Modifié — `revision_app/lib/features/activities/data/demo_activity_api.dart`

````dart
import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';
import '../domain/rich_closed_exercise.dart';

class DemoActivityApi implements ActivityApi {
  static const DiagnosticQuizActivity _activity = DiagnosticQuizActivity(
    sessionId: 'demo-session-1',
    title: 'Diagnostic rapide',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-1',
        prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
        choices: [
          DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
          DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
        ],
      ),
    ],
  );

  static const OpenQuestionActivity _openQuestionActivity =
      OpenQuestionActivity(
        sessionId: 'demo-open-session-1',
        type: 'open_question',
        version: 1,
        subjectId: 'demo-subject',
        documentId: null,
        knowledgeUnitId: 'demo-unit',
        question: OpenQuestion(
          id: 'demo-open-question-1',
          prompt: 'Explique avec tes mots le point principal de cette notion.',
          instructions: 'Réponds en quelques phrases structurées.',
          maxAnswerLength: 4000,
        ),
      );

  static final RichClosedExercise _richClosedExercise = RichClosedExercise(
    sessionId: 'demo-rich-session-1',
    type: richClosedExerciseType,
    id: 'demo-rich-exercise-1',
    version: richClosedExerciseVersion,
    title: 'Questions riches de démonstration',
    subjectId: 'demo-subject',
    documentId: null,
    knowledgeUnitId: 'demo-unit',
    questions: [
      RichClosedSingleChoiceQuestion(
        base: _base(
          id: 'demo-single-1',
          prompt: 'Quel critère caractérise un régime parlementaire ?',
          skill: RichClosedCognitiveSkill.classification,
        ),
        choices: const [
          RichClosedChoice(id: 'choice-a', label: 'Responsabilité politique'),
          RichClosedChoice(id: 'choice-b', label: 'Séparation étanche'),
        ],
      ),
      RichClosedMultipleChoiceQuestion(
        base: _base(
          id: 'demo-multiple-1',
          prompt: 'Quels indices orientent vers un régime parlementaire ?',
          skill: RichClosedCognitiveSkill.comparison,
        ),
        choices: const [
          RichClosedChoice(
            id: 'choice-a',
            label: 'Responsabilité du gouvernement',
          ),
          RichClosedChoice(id: 'choice-b', label: 'Collaboration des pouvoirs'),
          RichClosedChoice(id: 'choice-c', label: 'Indépendance absolue'),
        ],
        minSelections: 2,
        maxSelections: 2,
      ),
      RichClosedMatchingQuestion(
        base: _base(
          id: 'demo-matching-1',
          prompt: 'Associe chaque mécanisme à sa fonction.',
          skill: RichClosedCognitiveSkill.comparison,
        ),
        leftItems: const [
          RichClosedLabelItem(id: 'left-1', label: 'Motion de censure'),
          RichClosedLabelItem(id: 'left-2', label: 'Dissolution'),
          RichClosedLabelItem(id: 'left-3', label: 'Contrôle constitutionnel'),
        ],
        rightItems: const [
          RichClosedLabelItem(id: 'right-1', label: 'Responsabilité politique'),
          RichClosedLabelItem(
            id: 'right-2',
            label: 'Fin anticipée d’une chambre',
          ),
          RichClosedLabelItem(id: 'right-3', label: 'Vérification d’une norme'),
        ],
      ),
      RichClosedOrderingQuestion(
        base: _base(
          id: 'demo-ordering-1',
          prompt: 'Ordonne les étapes du raisonnement.',
          skill: RichClosedCognitiveSkill.procedure,
        ),
        items: const [
          RichClosedLabelItem(id: 'item-1', label: 'Repérer les organes'),
          RichClosedLabelItem(id: 'item-2', label: 'Analyser les moyens'),
          RichClosedLabelItem(id: 'item-3', label: 'Qualifier le régime'),
        ],
      ),
      RichClosedCaseQualificationQuestion(
        base: _base(
          id: 'demo-case-1',
          prompt: 'Choisis la qualification la plus pertinente.',
          skill: RichClosedCognitiveSkill.caseApplication,
        ),
        caseText:
            'Un gouvernement doit conserver la confiance d’une chambre élue.',
        choices: const [
          RichClosedChoice(id: 'choice-a', label: 'Régime parlementaire'),
          RichClosedChoice(id: 'choice-b', label: 'Régime présidentiel'),
        ],
      ),
      RichClosedErrorDetectionQuestion(
        base: _base(
          id: 'demo-error-1',
          prompt: 'Repère l’erreur dominante.',
          skill: RichClosedCognitiveSkill.errorDetection,
        ),
        statement:
            'Un régime présidentiel se définit par la responsabilité politique du gouvernement devant le Parlement.',
        errorOptions: const [
          RichClosedChoice(
            id: 'error-a',
            label: 'Confusion avec le parlementarisme',
          ),
          RichClosedChoice(
            id: 'error-b',
            label: 'Confusion avec le fédéralisme',
          ),
        ],
      ),
    ],
  );

  static final RichClosedExerciseResult
  _richClosedResult = RichClosedExerciseResult(
    sessionId: 'demo-rich-session-1',
    type: richClosedExerciseType,
    status: 'completed',
    correctAnswers: 6,
    totalQuestions: 6,
    score: 1,
    items: const [
      RichClosedCorrectionItem(
        questionId: 'demo-single-1',
        questionKind: RichClosedQuestionKind.singleChoice,
        prompt: 'Quel critère caractérise un régime parlementaire ?',
        submittedAnswer: RichClosedSingleChoiceAnswer(
          questionId: 'demo-single-1',
          choiceId: 'choice-a',
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'La responsabilité politique est un critère du parlementarisme.',
        sourceChunkIds: ['demo-chunk-1'],
        correction: RichClosedCorrectChoiceIdCorrection(
          correctChoiceId: 'choice-a',
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-multiple-1',
        questionKind: RichClosedQuestionKind.multipleChoice,
        prompt: 'Quels indices orientent vers un régime parlementaire ?',
        submittedAnswer: RichClosedMultipleChoiceAnswer(
          questionId: 'demo-multiple-1',
          choiceIds: ['choice-a', 'choice-b'],
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'Responsabilité et collaboration des pouvoirs vont ensemble.',
        sourceChunkIds: ['demo-chunk-1'],
        correction: RichClosedCorrectChoiceIdsCorrection(
          correctChoiceIds: ['choice-a', 'choice-b'],
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-matching-1',
        questionKind: RichClosedQuestionKind.matching,
        prompt: 'Associe chaque mécanisme à sa fonction.',
        submittedAnswer: RichClosedMatchingAnswer(
          questionId: 'demo-matching-1',
          pairs: [
            RichClosedPair(leftId: 'left-1', rightId: 'right-1'),
            RichClosedPair(leftId: 'left-2', rightId: 'right-2'),
            RichClosedPair(leftId: 'left-3', rightId: 'right-3'),
          ],
        ),
        isCorrect: true,
        partialScore: 1,
        explanation: 'Chaque mécanisme est associé à sa fonction.',
        sourceChunkIds: ['demo-chunk-2'],
        correction: RichClosedCorrectPairsCorrection(
          correctPairs: [
            RichClosedPair(leftId: 'left-1', rightId: 'right-1'),
            RichClosedPair(leftId: 'left-2', rightId: 'right-2'),
            RichClosedPair(leftId: 'left-3', rightId: 'right-3'),
          ],
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-ordering-1',
        questionKind: RichClosedQuestionKind.ordering,
        prompt: 'Ordonne les étapes du raisonnement.',
        submittedAnswer: RichClosedOrderingAnswer(
          questionId: 'demo-ordering-1',
          orderedIds: ['item-1', 'item-2', 'item-3'],
        ),
        isCorrect: true,
        partialScore: 1,
        explanation: 'La qualification vient après l’analyse.',
        sourceChunkIds: ['demo-chunk-3'],
        correction: RichClosedCorrectOrderCorrection(
          correctOrder: ['item-1', 'item-2', 'item-3'],
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-case-1',
        questionKind: RichClosedQuestionKind.caseQualification,
        prompt: 'Choisis la qualification la plus pertinente.',
        submittedAnswer: RichClosedCaseQualificationAnswer(
          questionId: 'demo-case-1',
          choiceId: 'choice-a',
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'La confiance parlementaire qualifie le régime parlementaire.',
        sourceChunkIds: ['demo-chunk-4'],
        correction: RichClosedCorrectChoiceIdCorrection(
          correctChoiceId: 'choice-a',
        ),
      ),
      RichClosedCorrectionItem(
        questionId: 'demo-error-1',
        questionKind: RichClosedQuestionKind.errorDetection,
        prompt: 'Repère l’erreur dominante.',
        submittedAnswer: RichClosedErrorDetectionAnswer(
          questionId: 'demo-error-1',
          errorId: 'error-a',
        ),
        isCorrect: true,
        partialScore: 1,
        explanation:
            'La responsabilité devant le Parlement relève du parlementarisme.',
        sourceChunkIds: ['demo-chunk-5'],
        correction: RichClosedCorrectErrorIdCorrection(
          correctErrorId: 'error-a',
        ),
      ),
    ],
  );

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    return _activity;
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final correctAnswers = answers.where((answer) {
      return answer.questionId == 'question-1' && answer.choiceId == 'a';
    }).length;

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: _activity.questions.length,
    );
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    return _openQuestionActivity;
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    return const OpenAnswerSubmissionResult(
      sessionId: 'demo-open-session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: OpenAnswerEvaluation(
        id: 'demo-open-evaluation-1',
        status: OpenAnswerEvaluationStatus.ready,
        score: 14,
        maxScore: 20,
        feedback: 'Réponse claire pour une démonstration locale.',
        presentPoints: ['Idée principale identifiée'],
        missingPoints: ['Exemple précis à ajouter'],
        errors: [],
        modelAnswer: 'Une réponse complète définit la notion et l’illustre.',
        advice: 'Ajoute un exemple issu du cours.',
        sources: [],
      ),
    );
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    return _richClosedExercise;
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    return _richClosedExercise;
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    return _richClosedResult;
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return _richClosedResult;
  }
}

RichClosedQuestionBase _base({
  required String id,
  required String prompt,
  required RichClosedCognitiveSkill skill,
}) {
  return RichClosedQuestionBase(
    id: id,
    prompt: prompt,
    difficulty: RichClosedDifficulty.medium,
    cognitiveSkill: skill,
    sourceChunkIds: const ['demo-chunk-1'],
  );
}

````


### Modifié — `revision_app/lib/features/activities/data/http_activities_api.dart`

````dart
import 'package:dio/dio.dart';

import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';
import '../domain/rich_closed_exercise.dart';

class HttpActivitiesApi implements ActivityApi {
  HttpActivitiesApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpActivitiesApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    final data = <String, Object>{
      'subjectId': subjectId,
      'selectionModes': ['single', 'multiple'],
      'visualsEnabled': true,
      'visualTypes': ['CHART', 'DIAGRAM'],
    };
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }

    final response = await _dio.post<Object?>(
      '/activities/next',
      data: data,
      options: await _authorizedOptions(),
    );

    return _ActivityJson(response.data).toActivity();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/result',
      data: {
        'answers': [for (final answer in answers) _AnswerJson(answer).toJson()],
      },
      options: await _authorizedOptions(),
    );

    return _ResultJson(response.data).toResult();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/open-question',
      data: {'subjectId': subjectId, 'knowledgeUnitId': knowledgeUnitId},
      options: await _authorizedOptions(),
    );

    return _OpenQuestionActivityJson(response.data).toActivity();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/$sessionId/open-answer',
      data: {'answerText': answerText},
      options: await _authorizedOptions(),
    );

    return _OpenAnswerSubmissionJson(response.data).toResult();
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    final data = <String, Object?>{
      'subjectId': subjectId,
      'knowledgeUnitId': knowledgeUnitId,
      'questionCount': questionCount,
      'complexityProfile': complexityProfile.wireValue,
    };

    if (documentId != null) {
      data['documentId'] = documentId;
    }

    if (questionTypeMix != null) {
      data['questionTypeMix'] = {
        for (final entry in questionTypeMix.entries)
          entry.key.wireValue: entry.value,
      };
    }

    final response = await _dio.post<Object?>(
      '/activities/rich-closed/start',
      data: data,
      options: await _authorizedOptions(),
    );

    return RichClosedExercise.fromJson(response.data);
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    final response = await _dio.get<Object?>(
      '/activities/rich-closed/$sessionId',
      options: await _authorizedOptions(),
    );

    return RichClosedExercise.fromJson(response.data);
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    final response = await _dio.post<Object?>(
      '/activities/rich-closed/$sessionId/submit',
      data: RichClosedExerciseSubmission(answers: answers).toJson(),
      options: await _authorizedOptions(),
    );

    return RichClosedExerciseResult.fromJson(response.data);
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    final response = await _dio.get<Object?>(
      '/activities/rich-closed/$sessionId/result',
      options: await _authorizedOptions(),
    );

    return RichClosedExerciseResult.fromJson(response.data);
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for activities');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}

class _ActivityJson {
  const _ActivityJson(this.value);

  final Object? value;

  DiagnosticQuizActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final title = json['title'];
    final documentId = json['documentId'];
    final subjectId = json['subjectId'];
    final questions = json['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid activity response');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _QuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _QuestionJson {
  const _QuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question response');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid question response');
    }

    final parsedChoices = choices
        .map((choice) => _ChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(
      json['minSelections'],
      fallback: 1,
      fieldName: 'minSelections',
    );
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
      fieldName: 'maxSelections',
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid question selection response');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _VisualJson(visual, index).toVisual(),
      ]);
      parsedVisuals.sort(
        (left, right) => left.displayOrder.compareTo(right.displayOrder),
      );
    }

    return DiagnosticQuizQuestion(
      id: id,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      difficulty: difficulty is String ? difficulty : null,
      selectionMode: selectionMode,
      minSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? minSelections
          : 1,
      maxSelections: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? maxSelections
          : 1,
      choices: parsedChoices,
      sources: sources is List
          ? sources
                .map((source) => _SourceRefJson(source).toSourceRef())
                .toList(growable: false)
          : const [],
      visuals: parsedVisuals,
    );
  }

  DiagnosticQuizSelectionMode _selectionMode(Object? value) {
    if (value == null || value == 'single') {
      return DiagnosticQuizSelectionMode.single;
    }

    if (value == 'multiple') {
      return DiagnosticQuizSelectionMode.multiple;
    }

    throw const FormatException('Invalid question selection response');
  }

  int _selectionCount(
    Object? value, {
    required int fallback,
    required String fieldName,
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw FormatException('Invalid question selection response: $fieldName');
  }
}

class _ChoiceJson {
  const _ChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice response');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid choice response');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _VisualJson {
  const _VisualJson(this.value, this.fallbackIndex);

  final Object? value;
  final int fallbackIndex;

  DiagnosticQuizVisual toVisual() {
    final json = value;

    if (json is! Map<String, Object?>) {
      return _unsupported('UNKNOWN');
    }

    final type = json['type'];
    if (type is! String) {
      return _unsupported('UNKNOWN', json: json);
    }

    return switch (type) {
      'CHART' => _chart(json),
      'DIAGRAM' => _diagram(json),
      _ => _unsupported(type, json: json),
    };
  }

  DiagnosticQuizVisual _chart(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final chartType = _chartType(json['chartType']);
      final title = json['title'];
      final description = json['description'];
      final data = json['data'];
      final xKey = json['xKey'];
      final yKeys = json['yKeys'];
      final sources = json['sources'];

      if (title is! String || data is! List) {
        return _unsupported('CHART', json: json);
      }

      return DiagnosticQuizChartVisual(
        id: id,
        displayOrder: displayOrder,
        chartType: chartType,
        title: title,
        description: description is String ? description : null,
        data: data.map(_chartRow).toList(growable: false),
        xKey: xKey is String ? xKey : null,
        yKeys: yKeys is List ? _stringList(yKeys) : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('CHART', json: json);
    }
  }

  DiagnosticQuizVisual _diagram(Map<String, Object?> json) {
    try {
      final id = _id(json);
      final displayOrder = _displayOrder(json);
      final title = json['title'];
      final description = json['description'];
      final nodes = json['nodes'];
      final edges = json['edges'];
      final sources = json['sources'];

      if (title is! String || nodes is! List) {
        return _unsupported('DIAGRAM', json: json);
      }

      return DiagnosticQuizDiagramVisual(
        id: id,
        displayOrder: displayOrder,
        title: title,
        description: description is String ? description : null,
        nodes: nodes.map(_diagramNode).toList(growable: false),
        edges: edges is List
            ? edges.map(_diagramEdge).toList(growable: false)
            : const [],
        sources: sources is List ? _sourceRefs(sources) : const [],
      );
    } on FormatException {
      return _unsupported('DIAGRAM', json: json);
    }
  }

  DiagnosticQuizUnsupportedVisual _unsupported(
    String type, {
    Map<String, Object?>? json,
  }) {
    final sources = json?['sources'];

    return DiagnosticQuizUnsupportedVisual(
      id: json == null ? 'visual-$fallbackIndex' : _safeId(json),
      displayOrder: json == null ? fallbackIndex : _safeDisplayOrder(json),
      type: type,
      sources: sources is List ? _safeSourceRefs(sources) : const [],
    );
  }

  String _id(Map<String, Object?> json) {
    final id = json['id'];
    if (id is String && id.trim().isNotEmpty) {
      return id;
    }

    throw const FormatException('Invalid visual response');
  }

  String _safeId(Map<String, Object?> json) {
    final id = json['id'];
    return id is String && id.trim().isNotEmpty ? id : 'visual-$fallbackIndex';
  }

  int _displayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    if (displayOrder == null) {
      return fallbackIndex;
    }

    if (displayOrder is int) {
      return displayOrder;
    }

    throw const FormatException('Invalid visual response');
  }

  int _safeDisplayOrder(Map<String, Object?> json) {
    final displayOrder = json['displayOrder'];
    return displayOrder is int ? displayOrder : fallbackIndex;
  }

  DiagnosticQuizChartType _chartType(Object? value) {
    return switch (value) {
      'bar' => DiagnosticQuizChartType.bar,
      'line' => DiagnosticQuizChartType.line,
      'pie' => DiagnosticQuizChartType.pie,
      'scatter' => DiagnosticQuizChartType.scatter,
      _ => throw const FormatException('Invalid chart visual response'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid chart visual response');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid chart visual response');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid diagram visual response');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid diagram visual response');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid diagram visual response');
    }

    return DiagnosticQuizDiagramEdge(
      from: from,
      to: to,
      label: label is String ? label : null,
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid visual response');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _SourceRefJson(source).toSourceRef())
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _safeSourceRefs(List<Object?> values) {
    try {
      return _sourceRefs(values);
    } on FormatException {
      return const [];
    }
  }
}

class _SourceRefJson {
  const _SourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid question source response');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _AnswerJson {
  const _AnswerJson(this.answer);

  final DiagnosticQuizAnswer answer;

  Map<String, Object?> toJson() {
    final choiceId = answer.choiceId;
    if (choiceId != null) {
      return {'questionId': answer.questionId, 'choiceId': choiceId};
    }

    return {'questionId': answer.questionId, 'choiceIds': answer.choiceIds};
  }
}

class _ResultJson {
  const _ResultJson(this.value);

  final Object? value;

  DiagnosticQuizResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid activity result response');
    }

    final correctAnswers = json['correctAnswers'];
    final totalQuestions = json['totalQuestions'];
    final score = json['score'];
    final items = json['items'];

    if (correctAnswers is! int || totalQuestions is! int) {
      throw const FormatException('Invalid activity result response');
    }

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      score: score is num ? score.toDouble() : null,
      items: items is List
          ? items
                .map((item) => _CorrectionItemJson(item).toCorrectionItem())
                .toList(growable: false)
          : const [],
    );
  }
}

class _CorrectionItemJson {
  const _CorrectionItemJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionItem toCorrectionItem() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction item response');
    }

    final questionId = json['questionId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final selectedChoiceId = json['selectedChoiceId'];
    final correctChoiceId = json['correctChoiceId'];
    final selectedChoiceIds = json['selectedChoiceIds'];
    final correctChoiceIds = json['correctChoiceIds'];
    final isCorrect = json['isCorrect'];
    final partialScore = json['partialScore'];
    final explanation = json['explanation'];
    final choiceFeedback = json['choiceFeedback'];
    final sources = json['sources'];

    if (questionId is! String ||
        prompt is! String ||
        isCorrect is! bool ||
        explanation is! String) {
      throw const FormatException('Invalid correction item response');
    }

    final parsedSelectedChoiceIds = selectedChoiceIds is List
        ? _stringList(selectedChoiceIds)
        : const <String>[];
    final parsedCorrectChoiceIds = correctChoiceIds is List
        ? _stringList(correctChoiceIds)
        : const <String>[];

    if (selectedChoiceId is! String &&
        correctChoiceId is! String &&
        (parsedSelectedChoiceIds.isEmpty || parsedCorrectChoiceIds.isEmpty)) {
      throw const FormatException('Invalid correction item response');
    }

    return DiagnosticQuizCorrectionItem(
      questionId: questionId,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      prompt: prompt,
      selectedChoiceId: selectedChoiceId is String ? selectedChoiceId : null,
      correctChoiceId: correctChoiceId is String ? correctChoiceId : null,
      selectedChoiceIds: parsedSelectedChoiceIds,
      correctChoiceIds: parsedCorrectChoiceIds,
      isCorrect: isCorrect,
      partialScore: partialScore is num ? partialScore.toDouble() : null,
      explanation: explanation,
      choiceFeedback: choiceFeedback is List
          ? choiceFeedback
                .map(
                  (feedback) =>
                      _ChoiceFeedbackJson(feedback).toChoiceFeedback(),
                )
                .toList(growable: false)
          : const [],
      sources: sources is List
          ? sources
                .map((source) => _CorrectionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  List<String> _stringList(List<Object?> values) {
    return values
        .map((value) {
          if (value is String) {
            return value;
          }

          throw const FormatException('Invalid correction item response');
        })
        .toList(growable: false);
  }
}

class _ChoiceFeedbackJson {
  const _ChoiceFeedbackJson(this.value);

  final Object? value;

  DiagnosticQuizChoiceFeedback toChoiceFeedback() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid choice feedback response');
    }

    final choiceId = json['choiceId'];
    final feedback = json['feedback'];

    if (choiceId is! String || feedback is! String) {
      throw const FormatException('Invalid choice feedback response');
    }

    return DiagnosticQuizChoiceFeedback(choiceId: choiceId, feedback: feedback);
  }
}

class _CorrectionSourceJson {
  const _CorrectionSourceJson(this.value);

  final Object? value;

  DiagnosticQuizCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid correction source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid correction source response');
    }

    return DiagnosticQuizCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Object? value;

  OpenQuestionActivity toActivity() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final version = json['version'];
    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final question = json['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid open question response');
    }

    return OpenQuestionActivity(
      sessionId: sessionId,
      type: type as String,
      version: version is int ? version : null,
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      question: _OpenQuestionJson(question).toQuestion(),
    );
  }
}

class _OpenQuestionJson {
  const _OpenQuestionJson(this.value);

  final Map<String, Object?> value;

  OpenQuestion toQuestion() {
    final id = value['id'];
    final prompt = value['prompt'];
    final instructions = value['instructions'];
    final maxAnswerLength = value['maxAnswerLength'];
    final sources = value['sources'];

    if (id is! String || prompt is! String || maxAnswerLength is! int) {
      throw const FormatException('Invalid open question response');
    }

    return OpenQuestion(
      id: id,
      prompt: prompt,
      instructions: instructions is String ? instructions : null,
      maxAnswerLength: maxAnswerLength,
      sources: sources is List
          ? sources
                .map((source) => _OpenQuestionSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }
}

class _OpenQuestionSourceJson {
  const _OpenQuestionSourceJson(this.value);

  final Object? value;

  OpenQuestionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open question source response');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid open question source response');
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenAnswerSubmissionJson {
  const _OpenAnswerSubmissionJson(this.value);

  final Object? value;

  OpenAnswerSubmissionResult toResult() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    final sessionId = json['sessionId'];
    final type = json['type'];
    final status = json['status'];
    final evaluation = json['evaluation'];

    if (sessionId is! String ||
        type != 'open_question' ||
        status is! String ||
        evaluation is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer response');
    }

    return OpenAnswerSubmissionResult(
      sessionId: sessionId,
      type: type as String,
      status: status,
      evaluation: _OpenAnswerEvaluationJson(evaluation).toEvaluation(),
    );
  }
}

class _OpenAnswerEvaluationJson {
  const _OpenAnswerEvaluationJson(this.value);

  final Map<String, Object?> value;

  OpenAnswerEvaluation toEvaluation() {
    final id = value['id'];
    final status = value['status'];
    final score = value['score'];
    final maxScore = value['maxScore'];
    final feedback = value['feedback'];
    final presentPoints = value['presentPoints'];
    final missingPoints = value['missingPoints'];
    final errors = value['errors'];
    final modelAnswer = value['modelAnswer'];
    final advice = value['advice'];
    final sources = value['sources'];

    if (id is! String || status is! String) {
      throw const FormatException('Invalid open answer evaluation response');
    }

    return OpenAnswerEvaluation(
      id: id,
      status: _openAnswerEvaluationStatus(status),
      score: score is num ? score.toDouble() : null,
      maxScore: maxScore is num ? maxScore.toDouble() : null,
      feedback: feedback is String ? feedback : null,
      presentPoints: presentPoints is List
          ? _stringList(
              presentPoints,
              'Invalid open answer evaluation response',
            )
          : const [],
      missingPoints: missingPoints is List
          ? _stringList(
              missingPoints,
              'Invalid open answer evaluation response',
            )
          : const [],
      errors: errors is List
          ? _stringList(errors, 'Invalid open answer evaluation response')
          : const [],
      modelAnswer: modelAnswer is String ? modelAnswer : null,
      advice: advice is String ? advice : null,
      sources: sources is List
          ? sources
                .map((source) => _OpenAnswerSourceJson(source).toSource())
                .toList(growable: false)
          : const [],
    );
  }

  OpenAnswerEvaluationStatus _openAnswerEvaluationStatus(String status) {
    return switch (status) {
      'PENDING' => OpenAnswerEvaluationStatus.pending,
      'READY' => OpenAnswerEvaluationStatus.ready,
      'FAILED' => OpenAnswerEvaluationStatus.failed,
      _ => throw const FormatException(
        'Invalid open answer evaluation response',
      ),
    };
  }
}

class _OpenAnswerSourceJson {
  const _OpenAnswerSourceJson(this.value);

  final Object? value;

  OpenAnswerCorrectionSource toSource() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid open answer source response');
    }

    final chunkId = json['chunkId'];
    final text = json['text'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || text is! String || index is! int) {
      throw const FormatException('Invalid open answer source response');
    }

    return OpenAnswerCorrectionSource(
      chunkId: chunkId,
      text: text,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

List<String> _stringList(List<Object?> values, String errorMessage) {
  return values
      .map((value) {
        if (value is String) {
          return value;
        }

        throw FormatException(errorMessage);
      })
      .toList(growable: false);
}

````


### Modifié — `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedCaseQualificationWidget extends StatefulWidget {
  const RichClosedCaseQualificationWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedCaseQualificationQuestion question;
  final ValueChanged<RichClosedCaseQualificationAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedCaseQualificationWidget> createState() =>
      _RichClosedCaseQualificationWidgetState();
}

class _RichClosedCaseQualificationWidgetState
    extends State<RichClosedCaseQualificationWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedCaseQualificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      leading: _RichClosedContextBlock(
        label: 'Cas',
        text: widget.question.caseText,
      ),
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: selectedChoiceId == null
              ? const []
              : [selectedChoiceId],
          enabled: widget.enabled,
          onChoiceSelected: _selectChoice,
        ),
      ],
    );
  }

  void _selectChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectCaseQualification(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedCaseQualificationAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _RichClosedContextBlock extends StatelessWidget {
  const _RichClosedContextBlock({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(text),
        ],
      ),
    );
  }
}

````


### Modifié — `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedErrorDetectionWidget extends StatefulWidget {
  const RichClosedErrorDetectionWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedErrorDetectionQuestion question;
  final ValueChanged<RichClosedErrorDetectionAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedErrorDetectionWidget> createState() =>
      _RichClosedErrorDetectionWidgetState();
}

class _RichClosedErrorDetectionWidgetState
    extends State<RichClosedErrorDetectionWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedErrorDetectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedErrorId = _controller.selectedChoiceIdFor(widget.question.id);

    return RichClosedQuestionCard(
      question: widget.question,
      leading: _RichClosedStatementBlock(text: widget.question.statement),
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.errorOptions,
          selectedChoiceIds: selectedErrorId == null
              ? const []
              : [selectedErrorId],
          enabled: widget.enabled,
          onChoiceSelected: _selectError,
        ),
      ],
    );
  }

  void _selectError(String errorId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectErrorDetection(
        question: widget.question,
        errorId: errorId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedErrorDetectionAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _RichClosedStatementBlock extends StatelessWidget {
  const _RichClosedStatementBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Énoncé à vérifier',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(text),
        ],
      ),
    );
  }
}

````


### Modifié — `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedMatchingWidget extends StatefulWidget {
  const RichClosedMatchingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedMatchingQuestion question;
  final ValueChanged<RichClosedMatchingAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedMatchingWidget> createState() =>
      _RichClosedMatchingWidgetState();
}

class _RichClosedMatchingWidgetState extends State<RichClosedMatchingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedMatchingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          'Associe chaque élément de gauche à une proposition de droite.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final leftItem in widget.question.leftItems)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _MatchingRow(
              question: widget.question,
              leftItem: leftItem,
              selectedRightId: _controller.selectedRightIdFor(
                widget.question.id,
                leftItem.id,
              ),
              enabled: widget.enabled,
              onChanged: (rightId) => _selectPair(leftItem.id, rightId),
            ),
          ),
      ],
    );
  }

  void _selectPair(String leftId, String? rightId) {
    if (!widget.enabled || rightId == null) {
      return;
    }

    setState(() {
      _controller.setMatchingPair(
        question: widget.question,
        leftId: leftId,
        rightId: rightId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(answer is RichClosedMatchingAnswer ? answer : null);
  }
}

class _MatchingRow extends StatelessWidget {
  const _MatchingRow({
    required this.question,
    required this.leftItem,
    required this.selectedRightId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedMatchingQuestion question;
  final RichClosedLabelItem leftItem;
  final String? selectedRightId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(leftItem.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.s),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                key: ValueKey('matching-${question.id}-${leftItem.id}'),
                value: selectedRightId,
                isExpanded: true,
                hint: const Text('Choisir une association'),
                items: [
                  for (final rightItem in question.rightItems)
                    DropdownMenuItem<String>(
                      value: rightItem.id,
                      child: Text(rightItem.label),
                    ),
                ],
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

````


### Modifié — `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';

class RichClosedMultipleChoiceWidget extends StatefulWidget {
  const RichClosedMultipleChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedMultipleChoiceQuestion question;
  final ValueChanged<RichClosedMultipleChoiceAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedMultipleChoiceWidget> createState() =>
      _RichClosedMultipleChoiceWidgetState();
}

class _RichClosedMultipleChoiceWidgetState
    extends State<RichClosedMultipleChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedMultipleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          _selectionInstruction(widget.question),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        if (_controller.message != null) ...[
          RevisionMessage(
            message: _controller.message!,
            color: Theme.of(context).colorScheme.error,
            icon: Icons.info_outline,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: _controller.selectedChoiceIdsFor(widget.question),
          enabled: widget.enabled,
          onChoiceSelected: _toggleChoice,
        ),
      ],
    );
  }

  void _toggleChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.toggleMultipleChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedMultipleChoiceAnswer ? answer : null,
    );
  }

  String _selectionInstruction(RichClosedMultipleChoiceQuestion question) {
    if (question.minSelections == question.maxSelections) {
      return 'Choisis ${question.minSelections} réponses.';
    }

    return 'Choisis entre ${question.minSelections} et ${question.maxSelections} réponses.';
  }
}

````


### Modifié — `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedOrderingWidget extends StatefulWidget {
  const RichClosedOrderingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedOrderingQuestion question;
  final ValueChanged<RichClosedOrderingAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedOrderingWidget> createState() =>
      _RichClosedOrderingWidgetState();
}

class _RichClosedOrderingWidgetState extends State<RichClosedOrderingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedOrderingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderedIds = _controller.orderedIdsFor(widget.question);
    final itemsById = {for (final item in widget.question.items) item.id: item};

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          'Réorganise les étapes avec les boutons monter et descendre.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final indexedItem in orderedIds.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _OrderingRow(
              item: itemsById[indexedItem.$2]!,
              position: indexedItem.$1 + 1,
              canMoveUp: widget.enabled && indexedItem.$1 > 0,
              canMoveDown:
                  widget.enabled && indexedItem.$1 < orderedIds.length - 1,
              onMoveUp: () => _moveUp(indexedItem.$2),
              onMoveDown: () => _moveDown(indexedItem.$2),
            ),
          ),
      ],
    );
  }

  void _moveUp(String itemId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveOrderingItemUp(question: widget.question, itemId: itemId);
    });
    _emitAnswer();
  }

  void _moveDown(String itemId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveOrderingItemDown(
        question: widget.question,
        itemId: itemId,
      );
    });
    _emitAnswer();
  }

  void _emitAnswer() {
    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedOrderingAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _OrderingRow extends StatelessWidget {
  const _OrderingRow({
    required this.item,
    required this.position,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final RichClosedLabelItem item;
  final int position;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(item.label)),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            key: ValueKey('ordering-up-${item.id}'),
            tooltip: 'Monter ${item.label}',
            onPressed: canMoveUp ? onMoveUp : null,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            key: ValueKey('ordering-down-${item.id}'),
            tooltip: 'Descendre ${item.label}',
            onPressed: canMoveDown ? onMoveDown : null,
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}

````


### Créé — `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart';

class RichClosedQuestionRenderer extends StatelessWidget {
  const RichClosedQuestionRenderer({
    required this.question,
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedQuestion question;
  final RichClosedCoreAnswerController controller;
  final ValueChanged<RichClosedAnswer?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = question;

    return switch (currentQuestion) {
      RichClosedSingleChoiceQuestion() => RichClosedSingleChoiceWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedMultipleChoiceQuestion() => RichClosedMultipleChoiceWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedMatchingQuestion() => RichClosedMatchingWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedOrderingQuestion() => RichClosedOrderingWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedCaseQualificationQuestion() =>
        RichClosedCaseQualificationWidget(
          question: currentQuestion,
          controller: controller,
          enabled: enabled,
          onAnswerChanged: onChanged,
        ),
      RichClosedErrorDetectionQuestion() => RichClosedErrorDetectionWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
    };
  }
}

````


### Modifié — `revision_app/lib/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';

class RichClosedSingleChoiceWidget extends StatefulWidget {
  const RichClosedSingleChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedSingleChoiceQuestion question;
  final ValueChanged<RichClosedSingleChoiceAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedSingleChoiceWidget> createState() =>
      _RichClosedSingleChoiceWidgetState();
}

class _RichClosedSingleChoiceWidgetState
    extends State<RichClosedSingleChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedSingleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: selectedChoiceId == null
              ? const []
              : [selectedChoiceId],
          enabled: widget.enabled,
          onChoiceSelected: _selectChoice,
        ),
      ],
    );
  }

  void _selectChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectSingleChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedSingleChoiceAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

````


### Modifié — `revision_app/lib/presentation/pages/activities/activities_page.dart`

````dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/genui/diagnostic_quiz_activity_validator.dart';
import 'package:revision_app/features/activities/genui/revision_activity_catalog.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

import 'diagnostic_quiz_page.dart';
import 'open_question_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({
    required this.controller,
    required this.subjectId,
    this.knowledgeUnitId,
    super.key,
  });

  final ActivityController controller;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  Future<_LoadedActivity>? _activity;
  _ActivityKind _selectedKind = _ActivityKind.diagnosticQuiz;
  final _catalog = buildRevisionActivityCatalog();

  @override
  void initState() {
    super.initState();
    _setActivityFromCurrentParams();
  }

  @override
  void didUpdateWidget(covariant ActivitiesPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalizeId(oldWidget.subjectId) != _trimmedSubjectId ||
        _normalizeId(oldWidget.knowledgeUnitId) != _trimmedKnowledgeUnitId) {
      setState(_setActivityFromCurrentParams);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RevisionPage(
      title: 'Activites',
      subtitle: 'Diagnostics rapides et exercices adaptatifs.',
      children: [
        _ActivityActions(
          selectedKind: _selectedKind,
          canStartOpenQuestion: _canStartOpenQuestion,
          canStartRevisionSession: _trimmedSubjectId != null,
          canStartRichClosedExercise: _canStartOpenQuestion,
          onDiagnosticSelected: _startDiagnosticQuiz,
          onOpenQuestionSelected: _startOpenQuestion,
          onRevisionSessionSelected: _startRevisionSession,
          onRichClosedSelected: _startRichClosedExercise,
        ),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.68,
          child: _activity == null
              ? const Center(child: Text('Aucune activite selectionnee'))
              : FutureBuilder<_LoadedActivity>(
                  future: _activity,
                  builder: (context, snapshot) {
                    final loadedActivity = snapshot.data;

                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || loadedActivity == null) {
                      return const Center(
                        child: Text("Impossible de charger l'activite"),
                      );
                    }

                    return switch (loadedActivity) {
                      _LoadedDiagnosticQuiz(:final activity) =>
                        _DiagnosticQuizActivityPanel(
                          activity: activity,
                          controller: widget.controller,
                          catalogId:
                              _catalog.catalogId ?? 'revisionActivityCatalog',
                        ),
                      _LoadedOpenQuestion(:final activity) =>
                        _OpenQuestionActivityPanel(
                          activity: activity,
                          controller: widget.controller,
                        ),
                    };
                  },
                ),
        ),
      ],
    );
  }

  bool get _canStartOpenQuestion {
    return _trimmedSubjectId != null && _trimmedKnowledgeUnitId != null;
  }

  String? get _trimmedSubjectId {
    return _normalizeId(widget.subjectId);
  }

  String? get _trimmedKnowledgeUnitId {
    return _normalizeId(widget.knowledgeUnitId);
  }

  String? _normalizeId(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }

  void _setActivityFromCurrentParams() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = null;
      return;
    }

    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (knowledgeUnitId != null) {
      _selectedKind = _ActivityKind.openQuestion;
      _activity = _loadOpenQuestion(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      );
      return;
    }

    _selectedKind = _ActivityKind.diagnosticQuiz;
    _activity = _loadDiagnosticQuiz(subjectId);
  }

  Future<_LoadedActivity> _loadDiagnosticQuiz(String subjectId) async {
    final activity = await widget.controller.startNextActivity(
      subjectId: subjectId,
      knowledgeUnitId: _trimmedKnowledgeUnitId,
    );

    return _LoadedDiagnosticQuiz(activity);
  }

  Future<_LoadedActivity> _loadOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    final activity = await widget.controller.startOpenQuestion(
      subjectId: subjectId,
      knowledgeUnitId: knowledgeUnitId,
    );

    return _LoadedOpenQuestion(activity);
  }

  void _startDiagnosticQuiz() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.diagnosticQuiz;
      _activity = _loadDiagnosticQuiz(subjectId);
    });
  }

  void _startOpenQuestion() {
    final subjectId = _trimmedSubjectId;
    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (subjectId == null || knowledgeUnitId == null) {
      return;
    }

    setState(() {
      _selectedKind = _ActivityKind.openQuestion;
      _activity = _loadOpenQuestion(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      );
    });
  }

  void _startRevisionSession() {
    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return;
    }

    context.go(
      revisionSessionRoutePathFor(
        subjectId: subjectId,
        knowledgeUnitId: _trimmedKnowledgeUnitId,
      ),
    );
  }

  void _startRichClosedExercise() {
    final subjectId = _trimmedSubjectId;
    final knowledgeUnitId = _trimmedKnowledgeUnitId;
    if (subjectId == null || knowledgeUnitId == null) {
      return;
    }

    context.go(
      richClosedExerciseRoutePathFor(
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }
}

enum _ActivityKind { diagnosticQuiz, openQuestion }

sealed class _LoadedActivity {
  const _LoadedActivity();
}

class _LoadedDiagnosticQuiz extends _LoadedActivity {
  const _LoadedDiagnosticQuiz(this.activity);

  final DiagnosticQuizActivity activity;
}

class _LoadedOpenQuestion extends _LoadedActivity {
  const _LoadedOpenQuestion(this.activity);

  final OpenQuestionActivity activity;
}

class _ActivityActions extends StatelessWidget {
  const _ActivityActions({
    required this.selectedKind,
    required this.canStartOpenQuestion,
    required this.canStartRevisionSession,
    required this.canStartRichClosedExercise,
    required this.onDiagnosticSelected,
    required this.onOpenQuestionSelected,
    required this.onRevisionSessionSelected,
    required this.onRichClosedSelected,
  });

  final _ActivityKind selectedKind;
  final bool canStartOpenQuestion;
  final bool canStartRevisionSession;
  final bool canStartRichClosedExercise;
  final VoidCallback onDiagnosticSelected;
  final VoidCallback onOpenQuestionSelected;
  final VoidCallback onRevisionSessionSelected;
  final VoidCallback onRichClosedSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            RevisionButton(
              onPressed: onDiagnosticSelected,
              icon: Icons.quiz_outlined,
              label: 'QCM',
              style: selectedKind == _ActivityKind.diagnosticQuiz
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartOpenQuestion ? onOpenQuestionSelected : null,
              icon: Icons.rate_review_outlined,
              label: 'Question ouverte',
              style: selectedKind == _ActivityKind.openQuestion
                  ? RevisionButtonStyle.primary
                  : RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartRevisionSession
                  ? onRevisionSessionSelected
                  : null,
              icon: Icons.auto_awesome_outlined,
              label: 'Révision IA',
              style: RevisionButtonStyle.ghost,
            ),
            RevisionButton(
              onPressed: canStartRichClosedExercise
                  ? onRichClosedSelected
                  : null,
              icon: Icons.extension_outlined,
              label: 'Questions riches',
              style: RevisionButtonStyle.ghost,
            ),
          ],
        ),
        if (!canStartOpenQuestion) ...[
          const SizedBox(height: AppSpacing.s),
          RevisionMessage(
            message:
                'Question ouverte et questions riches disponibles depuis une notion précise du cours.',
            color: Theme.of(context).colorScheme.secondary,
            icon: Icons.info_outline,
          ),
        ],
      ],
    );
  }
}

class _DiagnosticQuizActivityPanel extends StatelessWidget {
  const _DiagnosticQuizActivityPanel({
    required this.activity,
    required this.controller,
    required this.catalogId,
  });

  final DiagnosticQuizActivity activity;
  final ActivityController controller;
  final String catalogId;

  @override
  Widget build(BuildContext context) {
    if (!isDiagnosticQuizActivityCatalogSafe(activity)) {
      return const Center(child: Text('Activite indisponible'));
    }

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Semantics(
        label: catalogId,
        child: DiagnosticQuizPage(
          activity: activity,
          onSubmit: (answers) {
            return controller.submitResult(
              sessionId: activity.sessionId,
              answers: answers,
            );
          },
        ),
      ),
    );
  }
}

class _OpenQuestionActivityPanel extends StatelessWidget {
  const _OpenQuestionActivityPanel({
    required this.activity,
    required this.controller,
  });

  final OpenQuestionActivity activity;
  final ActivityController controller;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: OpenQuestionPage(
        activity: activity,
        onSubmit: (answerText) {
          return controller.submitOpenAnswer(
            sessionId: activity.sessionId,
            answerText: answerText,
          );
        },
      ),
    );
  }
}

````


### Créé — `revision_app/lib/presentation/pages/activities/rich_closed_exercise_page.dart`

````dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/application/rich_closed_exercise_flow_controller.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_list.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedExercisePage extends StatefulWidget {
  const RichClosedExercisePage({
    required this.controller,
    this.subjectId,
    this.knowledgeUnitId,
    this.documentId,
    this.sessionId,
    super.key,
  });

  final ActivityController controller;
  final String? subjectId;
  final String? knowledgeUnitId;
  final String? documentId;
  final String? sessionId;

  @override
  State<RichClosedExercisePage> createState() => _RichClosedExercisePageState();
}

class _RichClosedExercisePageState extends State<RichClosedExercisePage> {
  late RichClosedExerciseFlowController _flowController;
  late RichClosedCoreAnswerController _answerController;

  @override
  void initState() {
    super.initState();
    _resetControllers();
    _startOrLoadExercise();
  }

  @override
  void didUpdateWidget(covariant RichClosedExercisePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalized(oldWidget.sessionId) != _normalized(widget.sessionId) ||
        _normalized(oldWidget.subjectId) != _normalized(widget.subjectId) ||
        _normalized(oldWidget.knowledgeUnitId) !=
            _normalized(widget.knowledgeUnitId) ||
        _normalized(oldWidget.documentId) != _normalized(widget.documentId)) {
      _resetControllers();
      _startOrLoadExercise();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _flowController.state;

    return RevisionPage(
      title: 'Questions riches',
      subtitle: 'Un exercice fermé structuré, corrigé par le backend.',
      children: [
        if (!_hasLoadContext)
          _MissingContextPanel()
        else if (state.isLoading)
          const _LoadingPanel()
        else if (state.status == RichClosedExerciseFlowStatus.failed)
          _FailurePanel(
            message: _failureMessage(state),
            canRetrySubmit: state.exercise != null,
            onRetry: state.exercise == null ? _startOrLoadExercise : _submit,
          )
        else if (state.hasResult && state.exercise != null)
          _CompletedExercisePanel(
            exercise: state.exercise!,
            result: state.result!,
            onRestart: _startFreshExercise,
          )
        else if (state.exercise != null)
          _ReadyExercisePanel(
            exercise: state.exercise!,
            state: state,
            answerController: _answerController,
            onAnswerChanged: _recordAnswer,
            onSubmit: _submit,
          )
        else
          _MissingContextPanel(),
      ],
    );
  }

  bool get _hasLoadContext {
    return _normalized(widget.sessionId) != null ||
        (_normalized(widget.subjectId) != null &&
            _normalized(widget.knowledgeUnitId) != null);
  }

  void _resetControllers() {
    _answerController = RichClosedCoreAnswerController();
    _flowController = RichClosedExerciseFlowController(
      activityController: widget.controller,
    );
  }

  Future<void> _startOrLoadExercise() async {
    final sessionId = _normalized(widget.sessionId);
    final subjectId = _normalized(widget.subjectId);
    final knowledgeUnitId = _normalized(widget.knowledgeUnitId);

    if (sessionId == null && (subjectId == null || knowledgeUnitId == null)) {
      return;
    }

    final future = sessionId != null
        ? _flowController.load(sessionId: sessionId)
        : _flowController.start(
            subjectId: subjectId!,
            knowledgeUnitId: knowledgeUnitId!,
            documentId: _normalized(widget.documentId),
          );
    setState(() {});
    await future;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startFreshExercise() async {
    _resetControllers();
    await _startOrLoadExercise();
  }

  void _recordAnswer(RichClosedQuestion question, RichClosedAnswer? answer) {
    setState(() {
      _flowController.recordAnswer(question, answer);
    });
  }

  Future<void> _submit() async {
    final future = _flowController.submit();
    setState(() {});
    await future;

    if (mounted) {
      setState(() {});
    }
  }

  String _failureMessage(RichClosedExerciseFlowState state) {
    if (state.exercise == null) {
      return 'Impossible de charger les questions riches. Réessaie dans un instant.';
    }

    return 'Impossible de corriger les réponses. Réessaie dans un instant.';
  }

  String? _normalized(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }
}

class _ReadyExercisePanel extends StatelessWidget {
  const _ReadyExercisePanel({
    required this.exercise,
    required this.state,
    required this.answerController,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseFlowState state;
  final RichClosedCoreAnswerController answerController;
  final void Function(RichClosedQuestion question, RichClosedAnswer? answer)
  onAnswerChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionPanel(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                '${state.answeredCount} / ${state.totalQuestions} répondues',
              ),
              if (!state.canSubmit) ...[
                const SizedBox(height: AppSpacing.s),
                RevisionMessage(
                  message: 'Réponds à toutes les questions avant de valider.',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.info_outline,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        for (final question in exercise.questions) ...[
          RichClosedQuestionRenderer(
            question: question,
            controller: answerController,
            enabled: !isSubmitting,
            onChanged: (answer) => onAnswerChanged(question, answer),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        _SubmitBar(
          canSubmit: state.canSubmit,
          isSubmitting: isSubmitting,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSubmitting) ...[
            RevisionMessage(
              message: 'Correction en cours...',
              color: Theme.of(context).colorScheme.secondary,
              icon: Icons.hourglass_top,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          RevisionButton(
            label: 'Valider mes réponses',
            icon: Icons.check_circle_outline,
            onPressed: canSubmit && !isSubmitting ? onSubmit : null,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _CompletedExercisePanel extends StatelessWidget {
  const _CompletedExercisePanel({
    required this.exercise,
    required this.result,
    required this.onRestart,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichClosedCorrectionList(exercise: exercise, result: result),
        RevisionButton(
          label: 'Recommencer un exercice',
          icon: Icons.refresh,
          onPressed: onRestart,
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const RevisionPanel(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _FailurePanel extends StatelessWidget {
  const _FailurePanel({
    required this.message,
    required this.canRetrySubmit,
    required this.onRetry,
  });

  final String message;
  final bool canRetrySubmit;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionMessage(
            message: message,
            color: Theme.of(context).colorScheme.error,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            label: canRetrySubmit ? 'Relancer la correction' : 'Réessayer',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _MissingContextPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: RevisionMessage(
        message:
            'Sélectionne une notion depuis une matière pour démarrer des questions riches.',
        color: Theme.of(context).colorScheme.secondary,
        icon: Icons.info_outline,
      ),
    );
  }
}

````


### Modifié — `revision_app/test/app/router/app_router_test.dart`

````dart
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
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
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
      expect(
        router.routeInformationProvider.value.uri.path,
        AppRoutes.subjects,
      );
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
      revisionSessionsApi = InMemoryRevisionSessionsApi(),
      todayController = TodayController(InMemoryTodayRepository()) {
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
  final TodayController todayController;
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

````


### Modifié — `revision_app/test/fakes/in_memory_activity_api.dart`

````dart
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import '../features/activities/fixtures/rich_closed_exercise_fixtures.dart';

class InMemoryActivityApi implements ActivityApi {
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  String? startedRichClosedSubjectId;
  String? startedRichClosedKnowledgeUnitId;
  String? loadedRichClosedSessionId;
  String? submittedRichClosedSessionId;
  int startedDiagnosticQuizCount = 0;
  int startedOpenQuestionCount = 0;
  int startedRichClosedCount = 0;
  int submittedRichClosedCount = 0;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  List<RichClosedAnswer>? submittedRichClosedAnswers;
  String? submittedOpenAnswerText;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedDiagnosticQuizCount += 1;

    return const DiagnosticQuizActivity(
      sessionId: 'session-1',
      title: 'Diagnostic rapide',
      questions: [
        DiagnosticQuizQuestion(
          id: 'question-1',
          prompt: 'Question test',
          choices: [
            DiagnosticQuizChoice(id: 'a', label: 'Reponse A'),
            DiagnosticQuizChoice(id: 'b', label: 'Reponse B'),
          ],
        ),
      ],
    );
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    submittedAnswers = answers;

    return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    startedOpenQuestionSubjectId = subjectId;
    startedOpenQuestionKnowledgeUnitId = knowledgeUnitId;
    startedOpenQuestionCount += 1;

    return const OpenQuestionActivity(
      sessionId: 'open-session-1',
      type: 'open_question',
      version: 1,
      subjectId: 'subject-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      question: OpenQuestion(
        id: 'open-question-1',
        prompt: 'Question ouverte test',
        instructions: 'Réponds en quelques phrases.',
        maxAnswerLength: 4000,
      ),
    );
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    submittedOpenAnswerText = answerText;

    return const OpenAnswerSubmissionResult(
      sessionId: 'open-session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: OpenAnswerEvaluation(
        id: 'evaluation-1',
        status: OpenAnswerEvaluationStatus.ready,
        score: 16,
        maxScore: 20,
        feedback: 'Réponse solide.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil de révision.',
        sources: [],
      ),
    );
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    startedRichClosedSubjectId = subjectId;
    startedRichClosedKnowledgeUnitId = knowledgeUnitId;
    startedRichClosedCount += 1;

    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    loadedRichClosedSessionId = sessionId;

    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submittedRichClosedSessionId = sessionId;
    submittedRichClosedAnswers = answers;
    submittedRichClosedCount += 1;

    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }
}

````


### Modifié — `revision_app/test/features/activities/activity_controller_test.dart`

````dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

class FakeActivityApi implements ActivityApi {
  String? startedSubjectId;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  String? startedRichClosedSubjectId;
  String? startedRichClosedKnowledgeUnitId;
  String? startedRichClosedDocumentId;
  String? submittedRichClosedSessionId;
  String? submittedOpenAnswerText;
  List<RichClosedAnswer>? submittedRichClosedAnswers;
  int submitCallCount = 0;
  int openAnswerSubmitCallCount = 0;
  Completer<DiagnosticQuizResult>? submitCompleter;
  Completer<OpenAnswerSubmissionResult>? openAnswerSubmitCompleter;
  Object? submitError;
  Object? openAnswerSubmitError;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;

    return const DiagnosticQuizActivity(
      sessionId: 'session-1',
      title: 'Diagnostic rapide',
      questions: [
        DiagnosticQuizQuestion(
          id: 'question-1',
          prompt: 'Quelle structure contractile propulse le sang ?',
          choices: [
            DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
            DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
          ],
        ),
      ],
    );
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    submitCallCount += 1;
    submittedAnswers = answers;

    if (submitError != null) {
      throw submitError!;
    }

    final completer = submitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    startedOpenQuestionSubjectId = subjectId;
    startedOpenQuestionKnowledgeUnitId = knowledgeUnitId;

    return openQuestionActivity();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    openAnswerSubmitCallCount += 1;
    submittedOpenAnswerText = answerText;

    if (openAnswerSubmitError != null) {
      throw openAnswerSubmitError!;
    }

    final completer = openAnswerSubmitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return openAnswerReadyResult();
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    startedRichClosedSubjectId = subjectId;
    startedRichClosedKnowledgeUnitId = knowledgeUnitId;
    startedRichClosedDocumentId = documentId;

    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submittedRichClosedSessionId = sessionId;
    submittedRichClosedAnswers = answers;

    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }
}

void main() {
  test('loads the next diagnostic activity', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final activity = await controller.startNextActivity(
      subjectId: ' subject-1 ',
    );

    expect(activity.sessionId, 'session-1');
    expect(activity.questions.single.choices, hasLength(2));
    expect(api.startedSubjectId, 'subject-1');
  });

  test('submits selected answers to the activity api', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final result = await controller.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'a'),
      ],
    );

    expect(api.submittedAnswers, hasLength(1));
    expect(api.submittedAnswers?.single.choiceId, 'a');
    expect(result.correctAnswers, 1);
  });

  test('loads an open question activity', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final activity = await controller.startOpenQuestion(
      subjectId: ' subject-1 ',
      knowledgeUnitId: ' unit-1 ',
    );

    expect(activity.sessionId, 'open-session-1');
    expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
  });

  test('submits an open answer through the activity api', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final result = await controller.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: ' La séparation des pouvoirs limite chaque autorité. ',
    );

    expect(
      api.submittedOpenAnswerText,
      'La séparation des pouvoirs limite chaque autorité.',
    );
    expect(result.evaluation.status, OpenAnswerEvaluationStatus.ready);
  });

  test('starts a rich closed exercise with trimmed context', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final exercise = await controller.startRichClosedExercise(
      subjectId: ' subject-1 ',
      knowledgeUnitId: ' unit-1 ',
      documentId: ' document-1 ',
    );

    expect(exercise.sessionId, 'rich-session-1');
    expect(api.startedRichClosedSubjectId, 'subject-1');
    expect(api.startedRichClosedKnowledgeUnitId, 'unit-1');
    expect(api.startedRichClosedDocumentId, 'document-1');
  });

  test(
    'submits rich closed answers without accepting empty payloads',
    () async {
      final api = FakeActivityApi();
      final controller = ActivityController(api);

      expect(
        () => controller.submitRichClosedExercise(
          sessionId: 'rich-session-1',
          answers: const [],
        ),
        throwsArgumentError,
      );

      await controller.submitRichClosedExercise(
        sessionId: ' rich-session-1 ',
        answers: const [
          RichClosedSingleChoiceAnswer(
            questionId: 'single-1',
            choiceId: 'choice-a',
          ),
        ],
      );

      expect(api.submittedRichClosedSessionId, 'rich-session-1');
      expect(api.submittedRichClosedAnswers, hasLength(1));
    },
  );

  test('manages selected answers and enriched correction state', () async {
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 2),
      submitter: (answers) async {
        return DiagnosticQuizResult(
          correctAnswers: 1,
          totalQuestions: 2,
          score: 0.5,
          items: [
            DiagnosticQuizCorrectionItem(
              questionId: 'question-1',
              knowledgeUnitId: 'unit-1',
              prompt: 'Question 1',
              selectedChoiceId: 'a',
              correctChoiceId: 'b',
              isCorrect: false,
              explanation: 'Explication sourcée.',
              choiceFeedback: const [
                DiagnosticQuizChoiceFeedback(
                  choiceId: 'a',
                  feedback: 'Distracteur plausible.',
                ),
              ],
              sources: const [
                DiagnosticQuizCorrectionSource(
                  chunkId: 'chunk-1',
                  text: 'Source après submit.',
                  pageNumber: null,
                  index: 0,
                ),
              ],
            ),
          ],
        );
      },
    );

    expect(controller.result, isNull);
    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-1', choiceId: 'a');
    controller.selectChoice(questionId: 'question-1', choiceId: 'b');
    controller.selectChoice(questionId: 'question-2', choiceId: 'a');

    expect(controller.selectedChoiceIdFor('question-1'), 'b');
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(controller.result?.score, 0.5);
    expect(controller.result?.items.single.explanation, 'Explication sourcée.');
  });

  test('manages multiple selections and submits choiceIds', () async {
    List<DiagnosticQuizAnswer>? submittedAnswers;
    final controller = DiagnosticQuizSessionController(
      activity: multipleActivity(),
      submitter: (answers) async {
        submittedAnswers = answers;

        return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
      },
    );

    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');
    controller.selectChoice(questionId: 'question-multiple', choiceId: 'c');
    controller.selectChoice(questionId: 'question-multiple', choiceId: 'b');

    expect(controller.selectedChoiceIdsFor('question-multiple'), ['a', 'c']);
    expect(controller.canSubmit, isTrue);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');

    expect(controller.selectedChoiceIdsFor('question-multiple'), ['c']);
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(submittedAnswers?.single.choiceId, isNull);
    expect(submittedAnswers?.single.choiceIds, ['c']);
  });

  test('requires the minimum selection count for multiple questions', () async {
    final controller = DiagnosticQuizSessionController(
      activity: multipleActivity(minSelections: 2, maxSelections: 3),
      submitter: (_) async =>
          const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1),
    );

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');

    expect(controller.answeredCount, 0);
    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'c');

    expect(controller.answeredCount, 1);
    expect(controller.canSubmit, isTrue);
  });

  test('prevents duplicate submit while a submission is running', () async {
    final completer = Completer<DiagnosticQuizResult>();
    var submitCount = 0;
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 1),
      submitter: (answers) {
        submitCount += 1;
        return completer.future;
      },
    );

    controller.selectChoice(questionId: 'question-1', choiceId: 'a');

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(submitCount, 1);

    completer.complete(
      const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1),
    );
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.isSubmitting, isFalse);
    expect(controller.result?.correctAnswers, 1);
  });

  test('keeps submit errors visible and supports long quizzes', () async {
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 15),
      submitter: (_) async => throw StateError('Activity already completed'),
    );

    for (var index = 1; index <= 15; index += 1) {
      controller.selectChoice(questionId: 'question-$index', choiceId: 'a');
    }

    expect(controller.answeredCount, 15);
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(controller.result, isNull);
    expect(controller.submitError, isA<StateError>());
  });

  test('manages open answer validation and READY correction state', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (answerText) async => openAnswerReadyResult(),
    );

    expect(controller.canSubmit, isFalse);
    expect(controller.validationMessage, 'Réponse trop courte');

    controller.updateAnswer('Réponse assez longue.');

    expect(controller.canSubmit, isTrue);
    expect(controller.answerText, 'Réponse assez longue.');

    await controller.submit();

    expect(
      controller.result?.evaluation.status,
      OpenAnswerEvaluationStatus.ready,
    );
    expect(controller.result?.evaluation.feedback, 'Réponse solide.');
    expect(controller.canSubmit, isFalse);
  });

  test('blocks open answers that exceed max length', () {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(maxAnswerLength: 20),
      submitter: (answerText) async => openAnswerReadyResult(),
    );

    controller.updateAnswer('Une réponse beaucoup trop longue pour la limite.');

    expect(controller.canSubmit, isFalse);
    expect(controller.validationMessage, 'Réponse trop longue');
  });

  test('stores FAILED open answer evaluations', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (answerText) async => openAnswerFailedResult(),
    );

    controller.updateAnswer('Réponse assez longue.');

    await controller.submit();

    expect(
      controller.result?.evaluation.status,
      OpenAnswerEvaluationStatus.failed,
    );
    expect(controller.submitError, isNull);
  });

  test('keeps the open answer text when submit fails', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (_) async => throw StateError('network failed'),
    );

    controller.updateAnswer('Réponse assez longue.');

    await controller.submit();

    expect(controller.result, isNull);
    expect(controller.answerText, 'Réponse assez longue.');
    expect(controller.submitError, isA<StateError>());
    expect(
      controller.submitErrorMessage,
      contains('peut-être été enregistrée'),
    );
  });

  test('prevents duplicate open answer submit while running', () async {
    final completer = Completer<OpenAnswerSubmissionResult>();
    var submitCount = 0;
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (_) {
        submitCount += 1;
        return completer.future;
      },
    );

    controller.updateAnswer('Réponse assez longue.');

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(submitCount, 1);

    completer.complete(openAnswerReadyResult());
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.isSubmitting, isFalse);
    expect(
      controller.result?.evaluation.status,
      OpenAnswerEvaluationStatus.ready,
    );
  });
}

DiagnosticQuizActivity multipleActivity({
  int minSelections = 1,
  int maxSelections = 2,
}) {
  return DiagnosticQuizActivity(
    sessionId: 'session-multiple',
    title: 'Diagnostic multiple',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-multiple',
        prompt: 'Quels éléments contrôlent le pouvoir ?',
        selectionMode: DiagnosticQuizSelectionMode.multiple,
        minSelections: minSelections,
        maxSelections: maxSelections,
        choices: const [
          DiagnosticQuizChoice(id: 'a', label: 'Contrôle juridictionnel'),
          DiagnosticQuizChoice(id: 'b', label: 'Pouvoir absolu'),
          DiagnosticQuizChoice(id: 'c', label: 'Séparation des pouvoirs'),
        ],
      ),
    ],
  );
}

DiagnosticQuizActivity longActivity({required int questionCount}) {
  return DiagnosticQuizActivity(
    sessionId: 'session-long',
    title: 'Diagnostic long',
    questions: [
      for (var index = 1; index <= questionCount; index += 1)
        DiagnosticQuizQuestion(
          id: 'question-$index',
          knowledgeUnitId: 'unit-$index',
          prompt: 'Question $index',
          difficulty: 'MEDIUM',
          choices: const [
            DiagnosticQuizChoice(id: 'a', label: 'Choix A'),
            DiagnosticQuizChoice(id: 'b', label: 'Choix B'),
          ],
          sources: [
            DiagnosticQuizSourceRef(
              chunkId: 'chunk-$index',
              pageNumber: null,
              index: index - 1,
            ),
          ],
        ),
    ],
  );
}

OpenQuestionActivity openQuestionActivity({int maxAnswerLength = 4000}) {
  return OpenQuestionActivity(
    sessionId: 'open-session-1',
    type: 'open_question',
    version: 1,
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-1',
    question: OpenQuestion(
      id: 'open-question-1',
      prompt: 'Explique la séparation des pouvoirs.',
      instructions: 'Réponds en quelques phrases.',
      maxAnswerLength: maxAnswerLength,
      sources: const [
        OpenQuestionSource(chunkId: 'chunk-1', pageNumber: null, index: 0),
      ],
    ),
  );
}

OpenAnswerSubmissionResult openAnswerReadyResult() {
  return const OpenAnswerSubmissionResult(
    sessionId: 'open-session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: OpenAnswerEvaluation(
      id: 'evaluation-1',
      status: OpenAnswerEvaluationStatus.ready,
      score: 16,
      maxScore: 20,
      feedback: 'Réponse solide.',
      presentPoints: ['Définition correcte'],
      missingPoints: ['Exemple attendu'],
      errors: [],
      modelAnswer: 'Réponse modèle.',
      advice: 'Ajoute un exemple.',
      sources: [
        OpenAnswerCorrectionSource(
          chunkId: 'chunk-1',
          text: 'Source post-submit.',
          pageNumber: null,
          index: 0,
        ),
      ],
    ),
  );
}

OpenAnswerSubmissionResult openAnswerFailedResult() {
  return const OpenAnswerSubmissionResult(
    sessionId: 'open-session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: OpenAnswerEvaluation(
      id: 'evaluation-1',
      status: OpenAnswerEvaluationStatus.failed,
      score: null,
      maxScore: null,
      feedback: null,
      presentPoints: [],
      missingPoints: [],
      errors: ['OPEN_ANSWER_EVALUATION_FAILED'],
      modelAnswer: null,
      advice: null,
      sources: [],
    ),
  );
}

````


### Créé — `revision_app/test/features/activities/rich_closed_exercise_flow_controller_test.dart`

````dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/application/rich_closed_exercise_flow_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;
  late RichClosedExerciseResult result;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
    result = RichClosedExerciseResult.fromJson(richClosedResultJson());
  });

  test('démarre un exercice rich closed avec un état ready', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(
      subjectId: ' subject-1 ',
      knowledgeUnitId: ' unit-1 ',
    );

    expect(controller.state.status, RichClosedExerciseFlowStatus.ready);
    expect(controller.state.exercise, same(exercise));
    expect(controller.state.totalQuestions, 6);
    expect(controller.state.answeredCount, 1);
    expect(controller.state.canSubmit, isFalse);
    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
  });

  test('charge un exercice existant par sessionId', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.load(sessionId: ' rich-session-1 ');

    expect(controller.state.status, RichClosedExerciseFlowStatus.ready);
    expect(controller.state.exercise?.sessionId, 'rich-session-1');
    expect(api.loadedSessionId, 'rich-session-1');
  });

  test('collecte une réponse par question et submit sans correction', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    _answerAllQuestions(controller);

    expect(controller.state.answeredCount, 6);
    expect(controller.state.canSubmit, isTrue);

    await controller.submit();

    expect(controller.state.status, RichClosedExerciseFlowStatus.completed);
    expect(controller.state.result, same(result));
    expect(api.submittedSessionId, 'rich-session-1');
    expect(api.submittedAnswers, hasLength(6));
    expect(api.submittedAnswers!.map((answer) => answer.questionId), [
      'single-1',
      'multiple-1',
      'matching-1',
      'ordering-1',
      'case-1',
      'error-1',
    ]);
    for (final answer in api.submittedAnswers!) {
      final json = answer.toJson().toString();
      expect(json, isNot(contains('correct')));
      expect(json, isNot(contains('score')));
      expect(json, isNot(contains('explanation')));
      expect(json, isNot(contains('feedback')));
    }
  });

  test('refuse submit si les réponses sont incomplètes', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    final single = exercise.questions
        .whereType<RichClosedSingleChoiceQuestion>()
        .single;
    controller.recordAnswer(
      single,
      const RichClosedSingleChoiceAnswer(
        questionId: 'single-1',
        choiceId: 'choice-a',
      ),
    );

    await controller.submit();

    expect(controller.state.status, RichClosedExerciseFlowStatus.ready);
    expect(api.submitCallCount, 0);
  });

  test('ignore une réponse incohérente avec la question', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    final single = exercise.questions
        .whereType<RichClosedSingleChoiceQuestion>()
        .single;

    controller.recordAnswer(
      single,
      const RichClosedSingleChoiceAnswer(
        questionId: 'other-question',
        choiceId: 'choice-a',
      ),
    );

    expect(controller.state.answeredCount, 1);
    expect(controller.state.canSubmit, isFalse);
  });

  test('empêche deux submit simultanés', () async {
    final completer = Completer<RichClosedExerciseResult>();
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      submitCompleter: completer,
    );
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    _answerAllQuestions(controller);

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(api.submitCallCount, 1);
    expect(controller.state.status, RichClosedExerciseFlowStatus.submitting);

    completer.complete(result);
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.state.status, RichClosedExerciseFlowStatus.completed);
  });

  test('expose les erreurs start et submit dans un état failed', () async {
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      startError: StateError('start failed'),
      submitError: StateError('submit failed'),
    );
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');

    expect(controller.state.status, RichClosedExerciseFlowStatus.failed);
    expect(controller.state.error, isA<StateError>());

    api.startError = null;
    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    _answerAllQuestions(controller);
    await controller.submit();

    expect(controller.state.status, RichClosedExerciseFlowStatus.failed);
    expect(controller.state.exercise, same(exercise));
    expect(controller.state.result, isNull);
    expect(controller.state.error, isA<StateError>());
  });
}

void _answerAllQuestions(RichClosedExerciseFlowController controller) {
  final exercise = controller.state.exercise!;

  for (final question in exercise.questions) {
    switch (question) {
      case RichClosedSingleChoiceQuestion():
        controller.recordAnswer(
          question,
          RichClosedSingleChoiceAnswer(
            questionId: question.id,
            choiceId: 'choice-a',
          ),
        );
      case RichClosedMultipleChoiceQuestion():
        controller.recordAnswer(
          question,
          RichClosedMultipleChoiceAnswer(
            questionId: question.id,
            choiceIds: const ['choice-a', 'choice-b'],
          ),
        );
      case RichClosedMatchingQuestion():
        controller.recordAnswer(
          question,
          RichClosedMatchingAnswer(
            questionId: question.id,
            pairs: const [
              RichClosedPair(leftId: 'left-1', rightId: 'right-1'),
              RichClosedPair(leftId: 'left-2', rightId: 'right-2'),
              RichClosedPair(leftId: 'left-3', rightId: 'right-3'),
            ],
          ),
        );
      case RichClosedOrderingQuestion():
        break;
      case RichClosedCaseQualificationQuestion():
        controller.recordAnswer(
          question,
          RichClosedCaseQualificationAnswer(
            questionId: question.id,
            choiceId: 'choice-a',
          ),
        );
      case RichClosedErrorDetectionQuestion():
        controller.recordAnswer(
          question,
          RichClosedErrorDetectionAnswer(
            questionId: question.id,
            errorId: 'error-a',
          ),
        );
    }
  }
}

class _FakeRichClosedActivityApi implements ActivityApi {
  _FakeRichClosedActivityApi({
    required this.exercise,
    required this.result,
    this.submitCompleter,
    this.startError,
    this.submitError,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final Completer<RichClosedExerciseResult>? submitCompleter;
  Object? startError;
  Object? submitError;
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  String? loadedSessionId;
  String? submittedSessionId;
  List<RichClosedAnswer>? submittedAnswers;
  int submitCallCount = 0;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    if (startError != null) {
      throw startError!;
    }

    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    return exercise;
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    loadedSessionId = sessionId;
    return exercise;
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submitCallCount += 1;
    submittedSessionId = sessionId;
    submittedAnswers = answers;

    if (submitError != null) {
      throw submitError!;
    }

    final completer = submitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return result;
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return result;
  }
}

````


### Créé — `revision_app/test/features/activities/rich_closed_exercise_page_test.dart`

````dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart';
import 'package:revision_app/presentation/pages/activities/rich_closed_exercise_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;
  late RichClosedExerciseResult result;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
    result = RichClosedExerciseResult.fromJson(richClosedResultJson());
  });

  testWidgets('renderer rend les six widgets V1-A et propage le controller', (
    tester,
  ) async {
    final controller = RichClosedCoreAnswerController();
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            for (final question in exercise.questions)
              RichClosedQuestionRenderer(
                question: question,
                controller: controller,
                enabled: true,
                onChanged: (_) => changedQuestions.add(question.id),
              ),
          ],
        ),
      ),
    );

    expect(
      find.text('Quel critère caractérise un régime parlementaire ?'),
      findsOneWidget,
    );
    expect(
      find.text('Quels indices orientent vers un régime parlementaire ?'),
      findsOneWidget,
    );
    expect(
      find.text('Associe chaque mécanisme à sa fonction.'),
      findsOneWidget,
    );
    expect(find.text('Ordonne les étapes du raisonnement.'), findsOneWidget);
    expect(
      find.text('Choisis la qualification la plus pertinente.'),
      findsOneWidget,
    );
    expect(find.text('Repère l’erreur dominante.'), findsOneWidget);
    expect(find.textContaining('{'), findsNothing);

    await _tapVisible(tester, find.text('Responsabilité politique').first);

    expect(changedQuestions, contains('single-1'));
    expect(controller.canSubmitQuestion(exercise.questions.first), isTrue);
  });

  testWidgets('page démarre, collecte six réponses et affiche la correction', (
    tester,
  ) async {
    final submitCompleter = Completer<RichClosedExerciseResult>();
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      submitCompleter: submitCompleter,
    );

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedExercisePage(
          controller: ActivityController(api),
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startCount, 1);
    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
    expect(find.text('Questions riches'), findsOneWidget);
    expect(find.text('1 / 6 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNull);
    expect(
      find.text('La responsabilité politique est centrale.'),
      findsNothing,
    );

    await _answerAllQuestions(tester);

    expect(find.text('6 / 6 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pump();

    expect(find.text('Correction en cours...'), findsOneWidget);
    expect(api.submitCallCount, 1);
    expect(api.submittedAnswers, hasLength(6));
    for (final answer in api.submittedAnswers!) {
      final json = answer.toJson().toString();
      expect(json, isNot(contains('correct')));
      expect(json, isNot(contains('score')));
      expect(json, isNot(contains('explanation')));
    }

    submitCompleter.complete(result);
    await tester.pumpAndSettle();

    expect(find.text('Résultat'), findsOneWidget);
    expect(find.text('5 / 6'), findsOneWidget);
    expect(find.text('0.833'), findsOneWidget);
    expect(find.text('Réponse envoyée'), findsNWidgets(6));
    expect(
      find.text('La responsabilité politique est centrale.'),
      findsOneWidget,
    );
    expect(find.text('Valider mes réponses'), findsNothing);
  });

  testWidgets('page affiche une erreur contrôlée au démarrage', (tester) async {
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      startError: StateError('network failed'),
    );

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedExercisePage(
          controller: ActivityController(api),
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Impossible de charger les questions riches'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
  });

  testWidgets('page affiche un état vide sans contexte notion', (tester) async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedExercisePage(
          controller: ActivityController(api),
          subjectId: 'subject-1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.startCount, 0);
    expect(find.textContaining('Sélectionne une notion'), findsOneWidget);
  });
}

RevisionButton _submitButton(WidgetTester tester) {
  return tester.widget<RevisionButton>(
    find.widgetWithText(RevisionButton, 'Valider mes réponses'),
  );
}

Future<void> _answerAllQuestions(WidgetTester tester) async {
  await _tapVisible(tester, find.text('Responsabilité politique').first);
  await _tapVisible(tester, find.text('Responsabilité du gouvernement').first);
  await _tapVisible(tester, find.text('Collaboration des pouvoirs').first);
  await _selectMatchingRight(
    tester,
    leftId: 'left-1',
    label: 'Responsabilité politique',
  );
  await _selectMatchingRight(
    tester,
    leftId: 'left-2',
    label: 'Fin anticipée d’une chambre',
  );
  await _selectMatchingRight(
    tester,
    leftId: 'left-3',
    label: 'Vérification d’une norme',
  );
  await _tapVisible(tester, find.text('Régime parlementaire').first);
  await _tapVisible(
    tester,
    find.text('Confusion avec le parlementarisme').first,
  );
}

Future<void> _selectMatchingRight(
  WidgetTester tester, {
  required String leftId,
  required String label,
}) async {
  final dropdown = find.byKey(ValueKey('matching-matching-1-$leftId'));
  await tester.ensureVisible(dropdown);
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.child, this.scrollable = false});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)
        : child;

    return MaterialApp(home: Scaffold(body: body));
  }
}

class _FakeRichClosedActivityApi implements ActivityApi {
  _FakeRichClosedActivityApi({
    required this.exercise,
    required this.result,
    this.submitCompleter,
    this.startError,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final Completer<RichClosedExerciseResult>? submitCompleter;
  final Object? startError;
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  List<RichClosedAnswer>? submittedAnswers;
  int startCount = 0;
  int submitCallCount = 0;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    startCount += 1;
    if (startError != null) {
      throw startError!;
    }

    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    return exercise;
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    return exercise;
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submitCallCount += 1;
    submittedAnswers = answers;

    final completer = submitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return result;
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return result;
  }
}

````
