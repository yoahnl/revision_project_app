# LOT V1-021 — Calculation MCQ modes de scrutin V1-C

## 1. Résultat

V1-021 est implémenté côté Flutter et validable. Le type fermé `calculation_mcq` est parsé, rendu et soumis via `choiceId`, avec correction post-submit affichée depuis le backend. Flutter ne calcule ni score, ni correction, ni valeur attendue.

## 2. Sources inspectées

- `lib/features/activities/domain/rich_closed_exercise.dart`
- parser/API rich closed et fixtures activities
- `lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `rich_closed_question_renderer.dart`, widgets V1-A/V1-B/V1-C existants
- `rich_closed_correction_presenter.dart`
- page rich closed, flow controller, tests activities/today/revision_sessions/router
- docs V1 app et rapports V1-019/V1-020

## 3. Préflight Git

- repo : `revision_app`
- branche : `main`
- status initial : clean
- derniers commits initiaux : `be1c3dd V1-020: Ajout du widget Diagram Labeling...`, `1c5c384 V1-019...`, `0fe0583 V1-018...`
- repo API touché séparément : voir `api/docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md`
- aucun commit, merge, rebase, tag ou push lancé

## 4. Périmètre réalisé

Backend API : voir rapport API.

Frontend app :
- ajout de `RichClosedQuestionKind.calculationMcq` ;
- modèles discriminés calculation ;
- parser strict pré-submit ;
- answer DTO `choiceId` ;
- correction payload `correctChoiceId/expectedValue/workedSteps` ;
- controller local sans valeur par défaut ;
- widget minimal scénario + données + choix ;
- renderer/card label ;
- correction presenter ;
- fixtures et tests parser/controller/widget/page.

## 5. Contrat V1-C

`calculation_mcq` public contient `scenario`, `calculation` et `choices`. Les modes parsés sont `absolute_majority_threshold` et `largest_remainder_target_party_seats`.

Answer submit : `{ questionId, questionKind: 'calculation_mcq', choiceId }`.

Correction post-submit : `{ correctChoiceId, expectedValue, workedSteps }`.

Flutter rejette les fuites pré-submit comme `correctChoiceId`, `expectedValue`, `workedSteps`, `explanation`, `formula`, `eval`, `Function`, `render`, `renderPayload` et champs `correct*`.

## 6. Genkit

Côté app, aucun Genkit n'est lancé. Le frontend consomme uniquement le contrat API typé et ne laisse jamais Flutter rendre un widget libre ou un JSON arbitraire.

## 7. Validation/scoring

Flutter ne valide que la structure fermée et la cohérence locale minimale : choix non vides/uniques, mode connu, données de calcul bornées pour l'affichage, target party existante, votes de parti `>= 0` pour rester aligné avec le backend. Le scoring et la valeur attendue restent exclusivement backend.

## 8. Flutter

- modèles : `RichClosedCalculationData`, `RichClosedCalculationChoice`, `RichClosedCalculationParty`, `RichClosedCalculationWorkedStep`, question/answer/correction dédiées ;
- parser : strict, anti-fuite pré-submit et submit ;
- widget minimal : panneau scénario, données fermées, tuiles sélectionnables sans valeur par défaut ;
- correction UI : choix envoyé, choix attendu, valeur attendue, étapes backend, explication backend ;
- limite UI : rendu volontairement simple avant refonte complète.

## 9. Anti-fuite

Pré-submit : aucune correction, aucun `expectedValue`, aucun `workedSteps`, aucun `formula`, `eval`, `Function`, `render` ou `renderPayload`. Submit : seulement `choiceId`. Post-submit : correction affichée depuis le backend.

## 10. Fichiers créés/modifiés/supprimés

Créés :
- `lib/features/activities/presentation/rich_closed/rich_closed_calculation_mcq_widget.dart`
- `test/features/activities/rich_closed_calculation_mcq_widget_test.dart`
- `docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md`

Modifiés :
- `docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `lib/features/activities/domain/rich_closed_exercise.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_question_card.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart`
- `test/features/activities/fixtures/rich_closed_exercise_fixtures.dart`
- `test/features/activities/rich_closed_answer_controller_test.dart`
- `test/features/activities/rich_closed_correction_presenter_test.dart`
- `test/features/activities/rich_closed_exercise_flow_controller_test.dart`
- `test/features/activities/rich_closed_exercise_page_test.dart`
- `test/features/activities/rich_closed_exercise_test.dart`

Supprimés : aucun.

## 11. Tests ajoutés ou renforcés

- parser/model calculation public, largest remainder, parti à zéro voix, fuites privées/formule/rendu/`eval`, correction post-submit ;
- answer controller incomplete/complete/ignore invalid/replace/no correction ;
- widget calculation minimal ;
- correction presenter ;
- page rich closed renderer + submit/correction V1-021 ;
- flow controller test exhaustif.

## 12. Validations lancées avec résultats

- `dart format <liste explicite des fichiers modifiés>` : PASS.
- `dart analyze lib test` : PASS, no issues.
- `flutter test test/features/activities --reporter compact` : PASS, 216 tests.
- `flutter test test/features/today --reporter compact` : PASS, 18 tests.
- `flutter test test/features/revision_sessions --reporter compact` : PASS, 21 tests.
- `flutter test test/app/router --reporter compact` : PASS, 11 tests.
- `flutter test --reporter compact` : PASS, 347 tests.
- `git diff --check` : PASS après génération finale des rapports.

## 13. Validations non lancées avec justification

Aucune validation frontend demandée n'a été volontairement omise. Une première relance Today plus tôt dans le lot avait échoué par crash de tooling Flutter startup lock lors d'une exécution parallèle ; les validations finales ci-dessus ont été relancées séquentiellement et passent.

## 14. Risques restants

- UI provisoire minimaliste, assumée avant refonte.
- Les tuiles de choix affichent la valeur publique de chaque option ; ce n'est pas une correction, mais il faut conserver des libellés pédagogiques clairs côté génération.
- Le frontend vérifie la cohérence locale, mais ne doit pas être traité comme source de vérité.

## 15. Recommandation prochain lot

Recommandation : V1-022 — Image choice/personnages historiques V1-D, si le besoin produit est maintenu. Aucun bis Flutter n'est nécessaire pour V1-021.

## 16. Passes de review

- backend contract : voir rapport API.
- backend Genkit : voir rapport API.
- backend scoring : voir rapport API.
- public mapper anti-fuite : voir rapport API.
- Flutter parser/model : P2 corrigé, rejet explicite de `eval`, `Function/function` et `render`.
- Flutter widget : OK, pas de valeur par défaut, pas de JSON arbitraire.
- correction UI : OK, affichage backend only.
- tests/docs/sécurité : P2 corrigé, votes de parti à zéro acceptés comme backend.
- sécurité : OK, pas de secret, pas de provider réel, pas de V1-022.

## 17. Critique honnête du prompt initial

Prompt cohérent. Les contraintes “full content report” et validations longues imposent un rapport très volumineux ; j'ai évité l'auto-inclusion récursive du rapport. La seule friction réelle a été l'exécution parallèle de commandes Flutter, qui peut provoquer un crash de tooling sans impact applicatif.

## 18. Notes anti-récursion

La section suivante contient tous les fichiers touchés du repo app sauf le présent rapport lui-même.

## 19. Contenu complet des fichiers créés/modifiés/supprimés

Note : `docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md` est le présent rapport. Il est listé dans les fichiers créés mais son contenu n'est pas auto-inclus pour éviter une récursion documentaire.


### docs/v1/ROADMAP_EXECUTION_PLAN_V1.md

~~~text
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
| V1-013 | Today integration V1 | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md |
| V1-014 | Revision session integration V1 | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_014_REVISION_SESSION_INTEGRATION_V1.md |
| V1-015 | Seed V1 rich demo fixtures | Non applicable côté app (API-only) | Voir api/docs/v1/ROADMAP_EXECUTION_LOT_V1_015_016_RICH_DEMO_SEED_AND_SMOKE.md |
| V1-016 | E2E/smoke V1 rich questions | Non applicable côté app (API-only) | Voir api/docs/v1/ROADMAP_EXECUTION_LOT_V1_015_016_RICH_DEMO_SEED_AND_SMOKE.md |
| V1-017 | Timeline/date slider V1-B | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_017_TIMELINE_DATE_SLIDER.md |
| V1-018 | True/false grid + cause/consequence V1-B | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md |
| V1-019 | Institution matrix V1-C | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_019_INSTITUTION_MATRIX.md |
| V1-020 | Diagram labeling V1-C | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_020_DIAGRAM_LABELING.md |
| V1-021 | Calculation MCQ modes de scrutin V1-C | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md |
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
- Périmètre inclus : parser du lanceur rich closed, `preferredAction`, rendu borné en session, navigation vers `/activities/rich-closed`.
- Non-objectifs : widget libre, chat libre, rendu des questions/corrections rich closed dans la session.
- Fichiers concernés : modèles/API revision sessions, page session, router, fakes et tests.
- Backend : traité dans le rapport API V1-014.
- Frontend : rendu d'un lanceur borné et navigation vers le flow rich closed existant.
- Genkit : coach choisit une enum, pas un widget.
- GenUI : aucun widget arbitraire.
- Prisma : aucun côté app.
- API : parsing du payload `rich_closed_exercise`.
- Tests attendus : parser, contrôleur, page, routing, anti-fuite.
- Validations lancées : `dart analyze lib test`, `flutter test test/features/revision_sessions --reporter compact`, `flutter test test/app/router --reporter compact`, `flutter test --reporter compact`, `git diff --check`.
- Critères d'acceptation : une session peut proposer rich closed sans afficher de question/correction, puis lancer le flow dédié au clic.
- Critère de stop : action coach non bornée.
- Risques : migration enum.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_014_REVISION_SESSION_INTEGRATION_V1.md`.

### V1-015 — Seed V1 rich demo fixtures

- Objectif : préparer une démo stable d'exercices riches.
- Statut côté app : non applicable, lot réalisé côté API uniquement.
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
- Statut côté app : non applicable, lot réalisé côté API uniquement.
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

- Objectif : ajouter les types rich closed fermés `true_false_grid` et `cause_consequence`.
- Pourquoi maintenant : V1-017 a ajouté `timeline` et `date_slider`; l'app peut rendre deux interactions fermées supplémentaires.
- Périmètre inclus : modèles Flutter, parser strict, answers typées, widgets minimaux, correction UI post-submit, tests parser/controller/widgets/page.
- Non-objectifs : V1-019, `institution_matrix`, refonte de page rich closed, widget libre, rendu JSON arbitraire, score côté Flutter.
- Fichiers concernés : activities rich closed.
- Backend : traité dans le repo API.
- Frontend : grille vrai/faux sans valeur par défaut, association cause/conséquence par dropdown sans drag obligatoire.
- Genkit : non appelé côté app.
- GenUI : non modifié.
- Prisma : non applicable.
- API : consommation des types V1-B fournis par le backend.
- Tests attendus : réponses complètes, paires univoques, correction post-submit, anti-fuite pré-submit.
- Validations à lancer : tests activities, analyze, tests non-régression Today/sessions/router/full suite.
- Critères d'acceptation : aucune correction pré-submit, aucun score Flutter, V1-A et V1-017 non cassés.
- Critère de stop : payload public non typé ou fuite de correction.
- Risques : UI volontairement minimale avant refonte.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md`.

### V1-019 — Institution matrix V1-C

- Objectif : ajouter matrice institutionnelle.
- Pourquoi maintenant : base des grids disponible.
- Périmètre inclus : modèles Flutter typés, parser strict, controller de réponses fermées par cellule, widget liste groupée mobile-safe, correction UI post-submit.
- Non-objectifs : diagram labeling, nouveau flow UI global, rendu JSON arbitraire, score côté Flutter.
- Fichiers probablement concernés : activities rich closed.
- Backend : traité côté API.
- Frontend : liste groupée par ligne avec dropdown fermé par cellule.
- Genkit : traité côté API.
- GenUI : non modifié.
- Prisma : non modifié.
- API : type `institution_matrix`.
- Tests attendus : parser anti-fuite, controller, widget, page, correction.
- Validations à lancer : `dart analyze lib test`, `flutter test test/features/activities --reporter compact`, puis suites non-régression.
- Critères d'acceptation : matrice lisible mobile sans valeur par défaut.
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

- Objectif : rendre le type fermé `calculation_mcq` côté Flutter sans calcul de score côté app.
- Pourquoi maintenant : V1-020 a stabilisé le dernier type V1-C non calculatoire; le backend peut fournir un contrat fermé et déterministe.
- Périmètre inclus : modèles discriminés, parser strict, réponse submit `choiceId`, widget minimal, correction UI, tests parser/controller/widget/page.
- Non-objectifs : V1-022, `image_choice`, `fill_blank_dropdown`, réponse de calcul libre, formule libre, tableau de calcul avancé, nouveau flow UI global.
- Fichiers probablement concernés : activities domain, controller, renderer, correction presenter, widgets et tests.
- Backend : vérification déterministe côté API uniquement.
- Frontend : scénario + données fermées + choix, sans recalcul du résultat attendu.
- Genkit : génération bornée côté API uniquement.
- GenUI : aucun libre.
- Prisma : aucun.
- API : type `calculation_mcq`.
- Tests attendus : parser anti-fuite, answer controller, widget, page, correction presenter.
- Validations à lancer : `dart analyze`, tests activities/today/revision_sessions/router/full.
- Critères d'acceptation : aucune correction pré-submit, aucun score Flutter, aucun JSON arbitraire.
- Critère de stop : impossibilité de valider les résultats.
- Risques : UI provisoire volontairement simple avant refonte.
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

~~~

### lib/features/activities/domain/rich_closed_exercise.dart

~~~text
const richClosedExerciseType = 'rich_closed_exercise';
const richClosedExerciseVersion = 'rich-closed-question-v1';

class RichClosedExerciseParseException implements Exception {
  const RichClosedExerciseParseException(this.message);

  final String message;

  @override
  String toString() => 'RichClosedExerciseParseException: $message';
}

enum RichClosedQuestionKind {
  singleChoice('single_choice'),
  multipleChoice('multiple_choice'),
  matching('matching'),
  ordering('ordering'),
  caseQualification('case_qualification'),
  errorDetection('error_detection'),
  timeline('timeline'),
  dateSlider('date_slider'),
  trueFalseGrid('true_false_grid'),
  causeConsequence('cause_consequence'),
  institutionMatrix('institution_matrix'),
  diagramLabeling('diagram_labeling'),
  calculationMcq('calculation_mcq');

  const RichClosedQuestionKind(this.wireValue);

  final String wireValue;

  static RichClosedQuestionKind parse(Object? value) {
    for (final kind in values) {
      if (value == kind.wireValue) {
        return kind;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed question kind',
    );
  }
}

enum RichClosedDifficulty {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH');

  const RichClosedDifficulty(this.wireValue);

  final String wireValue;

  static RichClosedDifficulty parse(Object? value) {
    for (final difficulty in values) {
      if (value == difficulty.wireValue) {
        return difficulty;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed difficulty',
    );
  }
}

enum RichClosedCognitiveSkill {
  memorization('memorization'),
  comprehension('comprehension'),
  comparison('comparison'),
  classification('classification'),
  caseApplication('case_application'),
  procedure('procedure'),
  errorDetection('error_detection'),
  causality('causality');

  const RichClosedCognitiveSkill(this.wireValue);

  final String wireValue;

  static RichClosedCognitiveSkill parse(Object? value) {
    for (final skill in values) {
      if (value == skill.wireValue) {
        return skill;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed cognitive skill',
    );
  }
}

enum RichClosedDiagramLayout {
  verticalFlow('vertical_flow'),
  twoColumn('two_column'),
  cycle('cycle'),
  hierarchy('hierarchy'),
  plain('plain');

  const RichClosedDiagramLayout(this.wireValue);

  final String wireValue;

  static RichClosedDiagramLayout parse(Object? value) {
    for (final layout in values) {
      if (value == layout.wireValue) {
        return layout;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed diagram layout',
    );
  }
}

enum RichClosedDiagramAnchorType {
  node('node'),
  edge('edge');

  const RichClosedDiagramAnchorType(this.wireValue);

  final String wireValue;

  static RichClosedDiagramAnchorType parse(Object? value) {
    for (final type in values) {
      if (value == type.wireValue) {
        return type;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed diagram anchor type',
    );
  }
}

enum RichClosedCalculationMode {
  absoluteMajorityThreshold('absolute_majority_threshold'),
  largestRemainderTargetPartySeats('largest_remainder_target_party_seats');

  const RichClosedCalculationMode(this.wireValue);

  final String wireValue;

  static RichClosedCalculationMode parse(Object? value) {
    for (final mode in values) {
      if (value == mode.wireValue) {
        return mode;
      }
    }

    throw const RichClosedExerciseParseException(
      'Invalid rich closed calculation mode',
    );
  }
}

enum RichClosedComplexityProfile {
  standard('standard'),
  exam('exam'),
  advanced('advanced');

  const RichClosedComplexityProfile(this.wireValue);

  final String wireValue;
}

class RichClosedExercise {
  const RichClosedExercise({
    required this.sessionId,
    required this.type,
    required this.id,
    required this.version,
    required this.title,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.questions,
  });

  factory RichClosedExercise.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed exercise response');
    _assertNoPreSubmitLeaks(json);

    final type = _readString(json['type'], 'Invalid rich closed exercise type');
    final version = _readString(
      json['version'],
      'Invalid rich closed exercise version',
    );
    final questions = _readList(
      json['questions'],
      'Invalid rich closed exercise questions',
    );

    if (type != richClosedExerciseType ||
        version != richClosedExerciseVersion) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed exercise envelope',
      );
    }

    if (questions.isEmpty) {
      throw const RichClosedExerciseParseException(
        'Rich closed exercise must contain questions',
      );
    }

    return RichClosedExercise(
      sessionId: _readString(
        json['sessionId'],
        'Invalid rich closed exercise session id',
      ),
      type: type,
      id: _readString(json['id'], 'Invalid rich closed exercise id'),
      version: version,
      title: _readString(json['title'], 'Invalid rich closed exercise title'),
      subjectId: _readString(
        json['subjectId'],
        'Invalid rich closed exercise subject id',
      ),
      documentId: _readOptionalString(json['documentId']),
      knowledgeUnitId: _readString(
        json['knowledgeUnitId'],
        'Invalid rich closed exercise knowledge unit id',
      ),
      questions: questions
          .map(RichClosedQuestion.fromJson)
          .toList(growable: false),
    );
  }

  final String sessionId;
  final String type;
  final String id;
  final String version;
  final String title;
  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final List<RichClosedQuestion> questions;
}

sealed class RichClosedQuestion {
  const RichClosedQuestion({
    required this.id,
    required this.questionKind,
    required this.prompt,
    required this.difficulty,
    required this.cognitiveSkill,
    required this.sourceChunkIds,
  });

  factory RichClosedQuestion.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed question response');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);
    final base = RichClosedQuestionBase.fromJson(json, kind);

    return switch (kind) {
      RichClosedQuestionKind.singleChoice => RichClosedSingleChoiceQuestion(
        base: base,
        choices: _choices(json['choices']),
      ),
      RichClosedQuestionKind.multipleChoice => RichClosedMultipleChoiceQuestion(
        base: base,
        choices: _choices(json['choices']),
        minSelections: _readInt(
          json['minSelections'],
          'Invalid multiple choice min selections',
        ),
        maxSelections: _readInt(
          json['maxSelections'],
          'Invalid multiple choice max selections',
        ),
      ).._validateSelectionBounds(),
      RichClosedQuestionKind.matching => RichClosedMatchingQuestion(
        base: base,
        leftItems: _labelItems(json['leftItems'], 'Invalid matching left'),
        rightItems: _labelItems(json['rightItems'], 'Invalid matching right'),
      ),
      RichClosedQuestionKind.ordering => RichClosedOrderingQuestion(
        base: base,
        items: _labelItems(json['items'], 'Invalid ordering items'),
      ),
      RichClosedQuestionKind.timeline => RichClosedTimelineQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        events: _timelineEvents(json['events']),
      ).._validateEvents(),
      RichClosedQuestionKind.dateSlider => RichClosedDateSliderQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        minYear: _readInt(json['minYear'], 'Invalid date slider min year'),
        maxYear: _readInt(json['maxYear'], 'Invalid date slider max year'),
        step: _readInt(json['step'], 'Invalid date slider step'),
        toleranceYears: _readInt(
          json['toleranceYears'],
          'Invalid date slider tolerance',
        ),
      ).._validateBounds(),
      RichClosedQuestionKind.trueFalseGrid => RichClosedTrueFalseGridQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        rows: _trueFalseRows(json['rows']),
      ).._validateRows(),
      RichClosedQuestionKind.causeConsequence =>
        RichClosedCauseConsequenceQuestion(
          base: base,
          instruction: _readOptionalString(json['instruction']),
          causes: _causeConsequenceItems(
            json['causes'],
            'Invalid cause/consequence causes',
          ),
          consequences: _causeConsequenceItems(
            json['consequences'],
            'Invalid cause/consequence consequences',
          ),
        ).._validateItems(),
      RichClosedQuestionKind.institutionMatrix =>
        RichClosedInstitutionMatrixQuestion(
          base: base,
          instruction: _readOptionalString(json['instruction']),
          rows: _institutionMatrixAxisItems(
            json['rows'],
            'Invalid institution matrix rows',
          ),
          columns: _institutionMatrixAxisItems(
            json['columns'],
            'Invalid institution matrix columns',
          ),
          cells: _institutionMatrixCells(json['cells']),
        ).._validateMatrix(),
      RichClosedQuestionKind.diagramLabeling =>
        RichClosedDiagramLabelingQuestion(
          base: base,
          instruction: _readOptionalString(json['instruction']),
          diagram: RichClosedDiagram.fromJson(json['diagram']),
          slots: _diagramLabelingSlots(json['slots']),
        ).._validateDiagram(),
      RichClosedQuestionKind.calculationMcq => RichClosedCalculationMcqQuestion(
        base: base,
        instruction: _readOptionalString(json['instruction']),
        scenario: _readString(json['scenario'], 'Invalid calculation scenario'),
        calculation: RichClosedCalculationData.fromJson(json['calculation']),
        choices: _calculationChoices(json['choices']),
      ).._validateCalculation(),
      RichClosedQuestionKind.caseQualification =>
        RichClosedCaseQualificationQuestion(
          base: base,
          caseText: _readString(
            json['caseText'],
            'Invalid case qualification text',
          ),
          choices: _choices(json['choices']),
        ),
      RichClosedQuestionKind.errorDetection => RichClosedErrorDetectionQuestion(
        base: base,
        statement: _readString(
          json['statement'],
          'Invalid error detection statement',
        ),
        errorOptions: _choices(json['errorOptions']),
      ),
    };
  }

  final String id;
  final RichClosedQuestionKind questionKind;
  final String prompt;
  final RichClosedDifficulty difficulty;
  final RichClosedCognitiveSkill cognitiveSkill;
  final List<String> sourceChunkIds;
}

class RichClosedSingleChoiceQuestion extends RichClosedQuestion {
  RichClosedSingleChoiceQuestion({
    required RichClosedQuestionBase base,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.singleChoice,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedChoice> choices;
}

class RichClosedMultipleChoiceQuestion extends RichClosedQuestion {
  RichClosedMultipleChoiceQuestion({
    required RichClosedQuestionBase base,
    required this.choices,
    required this.minSelections,
    required this.maxSelections,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.multipleChoice,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedChoice> choices;
  final int minSelections;
  final int maxSelections;

  void _validateSelectionBounds() {
    if (minSelections < 1 ||
        maxSelections < minSelections ||
        maxSelections > choices.length) {
      throw const RichClosedExerciseParseException(
        'Invalid multiple choice selection bounds',
      );
    }
  }
}

class RichClosedMatchingQuestion extends RichClosedQuestion {
  RichClosedMatchingQuestion({
    required RichClosedQuestionBase base,
    required this.leftItems,
    required this.rightItems,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.matching,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedLabelItem> leftItems;
  final List<RichClosedLabelItem> rightItems;
}

class RichClosedOrderingQuestion extends RichClosedQuestion {
  RichClosedOrderingQuestion({
    required RichClosedQuestionBase base,
    required this.items,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.ordering,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final List<RichClosedLabelItem> items;
}

class RichClosedTimelineQuestion extends RichClosedQuestion {
  RichClosedTimelineQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.events,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.timeline,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedTimelineEvent> events;

  void _validateEvents() {
    final eventIds = events.map((event) => event.id).toSet();
    if (events.length < 3 || eventIds.length != events.length) {
      throw const RichClosedExerciseParseException('Invalid timeline events');
    }
  }
}

class RichClosedDateSliderQuestion extends RichClosedQuestion {
  RichClosedDateSliderQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.minYear,
    required this.maxYear,
    required this.step,
    required this.toleranceYears,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.dateSlider,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final int minYear;
  final int maxYear;
  final int step;
  final int toleranceYears;

  void _validateBounds() {
    if (minYear >= maxYear || step < 1 || toleranceYears < 0) {
      throw const RichClosedExerciseParseException(
        'Invalid date slider bounds',
      );
    }
  }
}

class RichClosedTrueFalseGridQuestion extends RichClosedQuestion {
  RichClosedTrueFalseGridQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.rows,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.trueFalseGrid,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedTrueFalseRow> rows;

  void _validateRows() {
    final rowIds = rows.map((row) => row.id).toSet();
    if (rows.length < 3 || rows.length > 8 || rowIds.length != rows.length) {
      throw const RichClosedExerciseParseException(
        'Invalid true/false grid rows',
      );
    }
  }
}

class RichClosedCauseConsequenceQuestion extends RichClosedQuestion {
  RichClosedCauseConsequenceQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.causes,
    required this.consequences,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.causeConsequence,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedCauseConsequenceItem> causes;
  final List<RichClosedCauseConsequenceItem> consequences;

  void _validateItems() {
    final causeIds = causes.map((cause) => cause.id).toSet();
    final consequenceIds = consequences
        .map((consequence) => consequence.id)
        .toSet();
    if (causes.length < 3 ||
        consequences.length < 3 ||
        consequences.length < causes.length ||
        causeIds.length != causes.length ||
        consequenceIds.length != consequences.length) {
      throw const RichClosedExerciseParseException(
        'Invalid cause/consequence items',
      );
    }
  }
}

class RichClosedInstitutionMatrixQuestion extends RichClosedQuestion {
  RichClosedInstitutionMatrixQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.rows,
    required this.columns,
    required this.cells,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.institutionMatrix,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final List<RichClosedInstitutionMatrixAxisItem> rows;
  final List<RichClosedInstitutionMatrixAxisItem> columns;
  final List<RichClosedInstitutionMatrixCell> cells;

  void _validateMatrix() {
    final rowIds = rows.map((row) => row.id).toSet();
    final columnIds = columns.map((column) => column.id).toSet();
    final cellIds = cells.map((cell) => cell.id).toSet();

    if (rows.length < 2 ||
        rows.length > 5 ||
        rowIds.length != rows.length ||
        columns.length < 2 ||
        columns.length > 5 ||
        columnIds.length != columns.length ||
        cells.length < 3 ||
        cells.length > rows.length * columns.length ||
        cellIds.length != cells.length) {
      throw const RichClosedExerciseParseException(
        'Invalid institution matrix contract',
      );
    }

    final cellCoordinates = <String>{};
    for (final cell in cells) {
      final coordinate = '${cell.rowId}\u0000${cell.columnId}';
      final optionIds = cell.options.map((option) => option.id).toSet();
      if (!cellCoordinates.add(coordinate) ||
          !rowIds.contains(cell.rowId) ||
          !columnIds.contains(cell.columnId) ||
          cell.options.length < 2 ||
          cell.options.length > 6 ||
          optionIds.length != cell.options.length) {
        throw const RichClosedExerciseParseException(
          'Invalid institution matrix contract',
        );
      }
    }
  }
}

class RichClosedDiagramLabelingQuestion extends RichClosedQuestion {
  RichClosedDiagramLabelingQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.diagram,
    required this.slots,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.diagramLabeling,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final RichClosedDiagram diagram;
  final List<RichClosedDiagramLabelingSlot> slots;

  void _validateDiagram() {
    final nodeIds = diagram.nodes.map((node) => node.id).toSet();
    final groupIds = diagram.groups.map((group) => group.id).toSet();
    final edgeIds = diagram.edges.map((edge) => edge.id).toSet();
    final slotIds = slots.map((slot) => slot.id).toSet();

    if (diagram.nodes.length < 2 ||
        diagram.nodes.length > 8 ||
        nodeIds.length != diagram.nodes.length ||
        diagram.groups.length > 4 ||
        groupIds.length != diagram.groups.length ||
        diagram.edges.length > 12 ||
        edgeIds.length != diagram.edges.length ||
        slots.length < 2 ||
        slots.length > 8 ||
        slotIds.length != slots.length) {
      throw const RichClosedExerciseParseException(
        'Invalid diagram labeling contract',
      );
    }

    for (final node in diagram.nodes) {
      final groupId = node.groupId;
      if (groupId != null && !groupIds.contains(groupId)) {
        throw const RichClosedExerciseParseException(
          'Invalid diagram labeling contract',
        );
      }
    }

    for (final edge in diagram.edges) {
      if (!nodeIds.contains(edge.fromNodeId) ||
          !nodeIds.contains(edge.toNodeId)) {
        throw const RichClosedExerciseParseException(
          'Invalid diagram labeling contract',
        );
      }
    }

    for (final slot in slots) {
      final optionIds = slot.options.map((option) => option.id).toSet();
      final anchorExists = switch (slot.anchorType) {
        RichClosedDiagramAnchorType.node => nodeIds.contains(slot.anchorId),
        RichClosedDiagramAnchorType.edge => edgeIds.contains(slot.anchorId),
      };

      if (!anchorExists ||
          slot.options.length < 2 ||
          slot.options.length > 6 ||
          optionIds.length != slot.options.length) {
        throw const RichClosedExerciseParseException(
          'Invalid diagram labeling contract',
        );
      }
    }
  }
}

class RichClosedCalculationMcqQuestion extends RichClosedQuestion {
  RichClosedCalculationMcqQuestion({
    required RichClosedQuestionBase base,
    required this.instruction,
    required this.scenario,
    required this.calculation,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.calculationMcq,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String? instruction;
  final String scenario;
  final RichClosedCalculationData calculation;
  final List<RichClosedCalculationChoice> choices;

  void _validateCalculation() {
    final choiceIds = choices.map((choice) => choice.id).toSet();
    final choiceValues = choices.map((choice) => choice.value).toSet();

    if (choices.length < 2 ||
        choices.length > 6 ||
        choiceIds.length != choices.length ||
        choiceValues.length != choices.length) {
      throw const RichClosedExerciseParseException(
        'Invalid calculation choices',
      );
    }

    switch (calculation) {
      case RichClosedAbsoluteMajorityThresholdCalculation(:final validVotes):
        if (validVotes < 1) {
          throw const RichClosedExerciseParseException(
            'Invalid calculation data',
          );
        }
      case RichClosedLargestRemainderTargetPartySeatsCalculation(
        :final totalSeats,
        :final targetPartyId,
        :final parties,
      ):
        final partyIds = parties.map((party) => party.id).toSet();
        if (totalSeats < 1 ||
            parties.length < 2 ||
            parties.length > 8 ||
            partyIds.length != parties.length ||
            !partyIds.contains(targetPartyId) ||
            parties.any((party) => party.votes < 0)) {
          throw const RichClosedExerciseParseException(
            'Invalid calculation data',
          );
        }
    }
  }
}

class RichClosedCaseQualificationQuestion extends RichClosedQuestion {
  RichClosedCaseQualificationQuestion({
    required RichClosedQuestionBase base,
    required this.caseText,
    required this.choices,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.caseQualification,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String caseText;
  final List<RichClosedChoice> choices;
}

class RichClosedErrorDetectionQuestion extends RichClosedQuestion {
  RichClosedErrorDetectionQuestion({
    required RichClosedQuestionBase base,
    required this.statement,
    required this.errorOptions,
  }) : super(
         id: base.id,
         questionKind: RichClosedQuestionKind.errorDetection,
         prompt: base.prompt,
         difficulty: base.difficulty,
         cognitiveSkill: base.cognitiveSkill,
         sourceChunkIds: base.sourceChunkIds,
       );

  final String statement;
  final List<RichClosedChoice> errorOptions;
}

class RichClosedQuestionBase {
  const RichClosedQuestionBase({
    required this.id,
    required this.prompt,
    required this.difficulty,
    required this.cognitiveSkill,
    required this.sourceChunkIds,
  });

  factory RichClosedQuestionBase.fromJson(
    Map<String, Object?> json,
    RichClosedQuestionKind kind,
  ) {
    return RichClosedQuestionBase(
      id: _readString(json['id'], 'Invalid rich closed question id'),
      prompt: _readString(
        json['prompt'],
        'Invalid rich closed question prompt',
      ),
      difficulty: RichClosedDifficulty.parse(json['difficulty']),
      cognitiveSkill: RichClosedCognitiveSkill.parse(json['cognitiveSkill']),
      sourceChunkIds: _stringList(
        json['sourceChunkIds'],
        'Invalid rich closed source chunk ids',
      ),
    );
  }

  final String id;
  final String prompt;
  final RichClosedDifficulty difficulty;
  final RichClosedCognitiveSkill cognitiveSkill;
  final List<String> sourceChunkIds;
}

class RichClosedChoice {
  const RichClosedChoice({required this.id, required this.label});

  factory RichClosedChoice.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed choice');
    if (json.containsKey('feedback')) {
      throw const RichClosedExerciseParseException(
        'Rich closed pre-submit choices cannot contain feedback',
      );
    }

    return RichClosedChoice(
      id: _readString(json['id'], 'Invalid rich closed choice id'),
      label: _readString(json['label'], 'Invalid rich closed choice label'),
    );
  }

  final String id;
  final String label;
}

class RichClosedLabelItem {
  const RichClosedLabelItem({required this.id, required this.label});

  factory RichClosedLabelItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed label item');

    return RichClosedLabelItem(
      id: _readString(json['id'], 'Invalid rich closed label item id'),
      label: _readString(json['label'], 'Invalid rich closed label item label'),
    );
  }

  final String id;
  final String label;
}

class RichClosedTimelineEvent {
  const RichClosedTimelineEvent({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedTimelineEvent.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed timeline event');

    return RichClosedTimelineEvent(
      id: _readString(json['id'], 'Invalid rich closed timeline event id'),
      label: _readString(
        json['label'],
        'Invalid rich closed timeline event label',
      ),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedTrueFalseRow {
  const RichClosedTrueFalseRow({
    required this.id,
    required this.statement,
    required this.context,
  });

  factory RichClosedTrueFalseRow.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed true/false row');

    return RichClosedTrueFalseRow(
      id: _readString(json['id'], 'Invalid true/false row id'),
      statement: _readString(
        json['statement'],
        'Invalid true/false row statement',
      ),
      context: _readOptionalString(json['context']),
    );
  }

  final String id;
  final String statement;
  final String? context;
}

class RichClosedTrueFalseGridValue {
  const RichClosedTrueFalseGridValue({
    required this.rowId,
    required this.value,
  });

  factory RichClosedTrueFalseGridValue.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed true/false value');

    return RichClosedTrueFalseGridValue(
      rowId: _readString(json['rowId'], 'Invalid true/false row id'),
      value: _readBool(json['value'], 'Invalid true/false value'),
    );
  }

  Map<String, Object?> toJson() => {'rowId': rowId, 'value': value};

  final String rowId;
  final bool value;
}

class RichClosedCauseConsequenceItem {
  const RichClosedCauseConsequenceItem({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedCauseConsequenceItem.fromJson(Object? value) {
    final json = _readObject(
      value,
      'Invalid rich closed cause/consequence item',
    );

    return RichClosedCauseConsequenceItem(
      id: _readString(json['id'], 'Invalid cause/consequence item id'),
      label: _readString(json['label'], 'Invalid cause/consequence item label'),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedCauseConsequencePair {
  const RichClosedCauseConsequencePair({
    required this.causeId,
    required this.consequenceId,
  });

  factory RichClosedCauseConsequencePair.fromJson(Object? value) {
    final json = _readObject(
      value,
      'Invalid rich closed cause/consequence pair',
    );

    return RichClosedCauseConsequencePair(
      causeId: _readString(json['causeId'], 'Invalid cause id'),
      consequenceId: _readString(
        json['consequenceId'],
        'Invalid consequence id',
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'causeId': causeId,
    'consequenceId': consequenceId,
  };

  final String causeId;
  final String consequenceId;
}

class RichClosedInstitutionMatrixAxisItem {
  const RichClosedInstitutionMatrixAxisItem({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedInstitutionMatrixAxisItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid institution matrix axis item');

    return RichClosedInstitutionMatrixAxisItem(
      id: _readString(json['id'], 'Invalid institution matrix axis id'),
      label: _readString(
        json['label'],
        'Invalid institution matrix axis label',
      ),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedInstitutionMatrixCell {
  const RichClosedInstitutionMatrixCell({
    required this.id,
    required this.rowId,
    required this.columnId,
    required this.prompt,
    required this.options,
  });

  factory RichClosedInstitutionMatrixCell.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid institution matrix cell');

    return RichClosedInstitutionMatrixCell(
      id: _readString(json['id'], 'Invalid institution matrix cell id'),
      rowId: _readString(json['rowId'], 'Invalid institution matrix row id'),
      columnId: _readString(
        json['columnId'],
        'Invalid institution matrix column id',
      ),
      prompt: _readOptionalString(json['prompt']),
      options: _choices(json['options']),
    );
  }

  final String id;
  final String rowId;
  final String columnId;
  final String? prompt;
  final List<RichClosedChoice> options;
}

class RichClosedInstitutionMatrixValue {
  const RichClosedInstitutionMatrixValue({
    required this.cellId,
    required this.optionId,
  });

  factory RichClosedInstitutionMatrixValue.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid institution matrix value');

    return RichClosedInstitutionMatrixValue(
      cellId: _readString(json['cellId'], 'Invalid institution matrix cell id'),
      optionId: _readString(
        json['optionId'],
        'Invalid institution matrix option id',
      ),
    );
  }

  Map<String, Object?> toJson() => {'cellId': cellId, 'optionId': optionId};

  final String cellId;
  final String optionId;
}

class RichClosedDiagram {
  const RichClosedDiagram({
    required this.title,
    required this.description,
    required this.layout,
    required this.nodes,
    required this.groups,
    required this.edges,
  });

  factory RichClosedDiagram.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram');

    return RichClosedDiagram(
      title: _readOptionalString(json['title']),
      description: _readOptionalString(json['description']),
      layout: RichClosedDiagramLayout.parse(json['layout']),
      nodes: _diagramNodes(json['nodes']),
      groups: _diagramGroups(json['groups']),
      edges: _diagramEdges(json['edges']),
    );
  }

  final String? title;
  final String? description;
  final RichClosedDiagramLayout layout;
  final List<RichClosedDiagramNode> nodes;
  final List<RichClosedDiagramGroup> groups;
  final List<RichClosedDiagramEdge> edges;
}

class RichClosedDiagramGroup {
  const RichClosedDiagramGroup({
    required this.id,
    required this.label,
    required this.description,
  });

  factory RichClosedDiagramGroup.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram group');

    return RichClosedDiagramGroup(
      id: _readString(json['id'], 'Invalid diagram group id'),
      label: _readString(json['label'], 'Invalid diagram group label'),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String label;
  final String? description;
}

class RichClosedDiagramNode {
  const RichClosedDiagramNode({
    required this.id,
    required this.label,
    required this.description,
    required this.groupId,
  });

  factory RichClosedDiagramNode.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram node');

    return RichClosedDiagramNode(
      id: _readString(json['id'], 'Invalid diagram node id'),
      label: _readString(json['label'], 'Invalid diagram node label'),
      description: _readOptionalString(json['description']),
      groupId: _readOptionalString(json['groupId']),
    );
  }

  final String id;
  final String label;
  final String? description;
  final String? groupId;
}

class RichClosedDiagramEdge {
  const RichClosedDiagramEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.label,
    required this.description,
  });

  factory RichClosedDiagramEdge.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram edge');

    return RichClosedDiagramEdge(
      id: _readString(json['id'], 'Invalid diagram edge id'),
      fromNodeId: _readString(
        json['fromNodeId'],
        'Invalid diagram edge source node id',
      ),
      toNodeId: _readString(
        json['toNodeId'],
        'Invalid diagram edge target node id',
      ),
      label: _readOptionalString(json['label']),
      description: _readOptionalString(json['description']),
    );
  }

  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String? label;
  final String? description;
}

class RichClosedDiagramLabelingSlot {
  const RichClosedDiagramLabelingSlot({
    required this.id,
    required this.anchorType,
    required this.anchorId,
    required this.prompt,
    required this.options,
  });

  factory RichClosedDiagramLabelingSlot.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed diagram slot');

    return RichClosedDiagramLabelingSlot(
      id: _readString(json['id'], 'Invalid diagram slot id'),
      anchorType: RichClosedDiagramAnchorType.parse(json['anchorType']),
      anchorId: _readString(json['anchorId'], 'Invalid diagram anchor id'),
      prompt: _readString(json['prompt'], 'Invalid diagram slot prompt'),
      options: _choices(json['options']),
    );
  }

  final String id;
  final RichClosedDiagramAnchorType anchorType;
  final String anchorId;
  final String prompt;
  final List<RichClosedChoice> options;
}

class RichClosedDiagramLabelingValue {
  const RichClosedDiagramLabelingValue({
    required this.slotId,
    required this.optionId,
  });

  factory RichClosedDiagramLabelingValue.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid diagram labeling value');

    return RichClosedDiagramLabelingValue(
      slotId: _readString(json['slotId'], 'Invalid diagram slot id'),
      optionId: _readString(json['optionId'], 'Invalid diagram option id'),
    );
  }

  Map<String, Object?> toJson() => {'slotId': slotId, 'optionId': optionId};

  final String slotId;
  final String optionId;
}

sealed class RichClosedCalculationData {
  const RichClosedCalculationData({required this.mode});

  factory RichClosedCalculationData.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed calculation data');
    final mode = RichClosedCalculationMode.parse(json['mode']);

    return switch (mode) {
      RichClosedCalculationMode.absoluteMajorityThreshold =>
        RichClosedAbsoluteMajorityThresholdCalculation(
          validVotes: _readInt(
            json['validVotes'],
            'Invalid calculation valid votes',
          ),
        ),
      RichClosedCalculationMode.largestRemainderTargetPartySeats =>
        RichClosedLargestRemainderTargetPartySeatsCalculation(
          totalSeats: _readInt(
            json['totalSeats'],
            'Invalid calculation total seats',
          ),
          targetPartyId: _readString(
            json['targetPartyId'],
            'Invalid calculation target party',
          ),
          parties: _calculationParties(json['parties']),
        ),
    };
  }

  final RichClosedCalculationMode mode;
}

class RichClosedAbsoluteMajorityThresholdCalculation
    extends RichClosedCalculationData {
  const RichClosedAbsoluteMajorityThresholdCalculation({
    required this.validVotes,
  }) : super(mode: RichClosedCalculationMode.absoluteMajorityThreshold);

  final int validVotes;
}

class RichClosedLargestRemainderTargetPartySeatsCalculation
    extends RichClosedCalculationData {
  const RichClosedLargestRemainderTargetPartySeatsCalculation({
    required this.totalSeats,
    required this.targetPartyId,
    required this.parties,
  }) : super(mode: RichClosedCalculationMode.largestRemainderTargetPartySeats);

  final int totalSeats;
  final String targetPartyId;
  final List<RichClosedCalculationParty> parties;
}

class RichClosedCalculationParty {
  const RichClosedCalculationParty({
    required this.id,
    required this.label,
    required this.votes,
  });

  factory RichClosedCalculationParty.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid calculation party');

    return RichClosedCalculationParty(
      id: _readString(json['id'], 'Invalid calculation party id'),
      label: _readString(json['label'], 'Invalid calculation party label'),
      votes: _readInt(json['votes'], 'Invalid calculation party votes'),
    );
  }

  final String id;
  final String label;
  final int votes;
}

class RichClosedCalculationChoice {
  const RichClosedCalculationChoice({
    required this.id,
    required this.label,
    required this.value,
  });

  factory RichClosedCalculationChoice.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid calculation choice');

    return RichClosedCalculationChoice(
      id: _readString(json['id'], 'Invalid calculation choice id'),
      label: _readString(json['label'], 'Invalid calculation choice label'),
      value: _readInt(json['value'], 'Invalid calculation choice value'),
    );
  }

  final String id;
  final String label;
  final int value;
}

class RichClosedCalculationWorkedStep {
  const RichClosedCalculationWorkedStep({
    required this.id,
    required this.label,
    required this.detail,
    required this.value,
  });

  factory RichClosedCalculationWorkedStep.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid calculation worked step');

    return RichClosedCalculationWorkedStep(
      id: _readString(json['id'], 'Invalid calculation worked step id'),
      label: _readString(
        json['label'],
        'Invalid calculation worked step label',
      ),
      detail: _readString(
        json['detail'],
        'Invalid calculation worked step detail',
      ),
      value: json.containsKey('value')
          ? _readInt(json['value'], 'Invalid calculation worked step value')
          : null,
    );
  }

  final String id;
  final String label;
  final String detail;
  final int? value;
}

class RichClosedPair {
  const RichClosedPair({required this.leftId, required this.rightId});

  factory RichClosedPair.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed pair');

    return RichClosedPair(
      leftId: _readString(json['leftId'], 'Invalid rich closed pair left id'),
      rightId: _readString(
        json['rightId'],
        'Invalid rich closed pair right id',
      ),
    );
  }

  Map<String, Object?> toJson() => {'leftId': leftId, 'rightId': rightId};

  final String leftId;
  final String rightId;
}

sealed class RichClosedAnswer {
  const RichClosedAnswer({
    required this.questionId,
    required this.questionKind,
  });

  factory RichClosedAnswer.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed answer');
    _assertNoAnswerLeaks(json);

    final questionId = _readString(json['questionId'], 'Invalid answer id');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);

    return switch (kind) {
      RichClosedQuestionKind.singleChoice => RichClosedSingleChoiceAnswer(
        questionId: questionId,
        choiceId: _readString(json['choiceId'], 'Invalid single choice answer'),
      ),
      RichClosedQuestionKind.multipleChoice => RichClosedMultipleChoiceAnswer(
        questionId: questionId,
        choiceIds: _nonEmptyStringList(
          json['choiceIds'],
          'Invalid multiple choice answer',
        ),
      ),
      RichClosedQuestionKind.matching => RichClosedMatchingAnswer(
        questionId: questionId,
        pairs: _pairs(json['pairs']),
      ),
      RichClosedQuestionKind.ordering => RichClosedOrderingAnswer(
        questionId: questionId,
        orderedIds: _nonEmptyStringList(
          json['orderedIds'],
          'Invalid ordering answer',
        ),
      ),
      RichClosedQuestionKind.timeline => RichClosedTimelineAnswer(
        questionId: questionId,
        orderedEventIds: _nonEmptyStringList(
          json['orderedEventIds'],
          'Invalid timeline answer',
        ),
      ),
      RichClosedQuestionKind.dateSlider => RichClosedDateSliderAnswer(
        questionId: questionId,
        year: _readInt(json['year'], 'Invalid date slider answer'),
      ),
      RichClosedQuestionKind.trueFalseGrid => RichClosedTrueFalseGridAnswer(
        questionId: questionId,
        values: _trueFalseValues(json['values']),
      ),
      RichClosedQuestionKind.causeConsequence =>
        RichClosedCauseConsequenceAnswer(
          questionId: questionId,
          pairs: _causeConsequencePairs(json['pairs']),
        ),
      RichClosedQuestionKind.institutionMatrix =>
        RichClosedInstitutionMatrixAnswer(
          questionId: questionId,
          values: _institutionMatrixValues(json['values']),
        ),
      RichClosedQuestionKind.diagramLabeling => RichClosedDiagramLabelingAnswer(
        questionId: questionId,
        values: _diagramLabelingValues(json['values']),
      ),
      RichClosedQuestionKind.calculationMcq => RichClosedCalculationMcqAnswer(
        questionId: questionId,
        choiceId: _readString(json['choiceId'], 'Invalid calculation answer'),
      ),
      RichClosedQuestionKind.caseQualification =>
        RichClosedCaseQualificationAnswer(
          questionId: questionId,
          choiceId: _readString(
            json['choiceId'],
            'Invalid case qualification answer',
          ),
        ),
      RichClosedQuestionKind.errorDetection => RichClosedErrorDetectionAnswer(
        questionId: questionId,
        errorId: _readString(json['errorId'], 'Invalid error detection answer'),
      ),
    };
  }

  final String questionId;
  final RichClosedQuestionKind questionKind;

  Map<String, Object?> toJson();
}

class RichClosedSingleChoiceAnswer extends RichClosedAnswer {
  const RichClosedSingleChoiceAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.singleChoice);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedMultipleChoiceAnswer extends RichClosedAnswer {
  const RichClosedMultipleChoiceAnswer({
    required super.questionId,
    required this.choiceIds,
  }) : super(questionKind: RichClosedQuestionKind.multipleChoice);

  final List<String> choiceIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceIds': choiceIds,
  };
}

class RichClosedMatchingAnswer extends RichClosedAnswer {
  const RichClosedMatchingAnswer({
    required super.questionId,
    required this.pairs,
  }) : super(questionKind: RichClosedQuestionKind.matching);

  final List<RichClosedPair> pairs;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'pairs': [for (final pair in pairs) pair.toJson()],
  };
}

class RichClosedOrderingAnswer extends RichClosedAnswer {
  const RichClosedOrderingAnswer({
    required super.questionId,
    required this.orderedIds,
  }) : super(questionKind: RichClosedQuestionKind.ordering);

  final List<String> orderedIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'orderedIds': orderedIds,
  };
}

class RichClosedTimelineAnswer extends RichClosedAnswer {
  const RichClosedTimelineAnswer({
    required super.questionId,
    required this.orderedEventIds,
  }) : super(questionKind: RichClosedQuestionKind.timeline);

  final List<String> orderedEventIds;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'orderedEventIds': orderedEventIds,
  };
}

class RichClosedDateSliderAnswer extends RichClosedAnswer {
  const RichClosedDateSliderAnswer({
    required super.questionId,
    required this.year,
  }) : super(questionKind: RichClosedQuestionKind.dateSlider);

  final int year;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'year': year,
  };
}

class RichClosedTrueFalseGridAnswer extends RichClosedAnswer {
  const RichClosedTrueFalseGridAnswer({
    required super.questionId,
    required this.values,
  }) : super(questionKind: RichClosedQuestionKind.trueFalseGrid);

  final List<RichClosedTrueFalseGridValue> values;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'values': [for (final value in values) value.toJson()],
  };
}

class RichClosedCauseConsequenceAnswer extends RichClosedAnswer {
  const RichClosedCauseConsequenceAnswer({
    required super.questionId,
    required this.pairs,
  }) : super(questionKind: RichClosedQuestionKind.causeConsequence);

  final List<RichClosedCauseConsequencePair> pairs;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'pairs': [for (final pair in pairs) pair.toJson()],
  };
}

class RichClosedInstitutionMatrixAnswer extends RichClosedAnswer {
  const RichClosedInstitutionMatrixAnswer({
    required super.questionId,
    required this.values,
  }) : super(questionKind: RichClosedQuestionKind.institutionMatrix);

  final List<RichClosedInstitutionMatrixValue> values;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'values': [for (final value in values) value.toJson()],
  };
}

class RichClosedDiagramLabelingAnswer extends RichClosedAnswer {
  const RichClosedDiagramLabelingAnswer({
    required super.questionId,
    required this.values,
  }) : super(questionKind: RichClosedQuestionKind.diagramLabeling);

  final List<RichClosedDiagramLabelingValue> values;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'values': [for (final value in values) value.toJson()],
  };
}

class RichClosedCalculationMcqAnswer extends RichClosedAnswer {
  const RichClosedCalculationMcqAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.calculationMcq);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedCaseQualificationAnswer extends RichClosedAnswer {
  const RichClosedCaseQualificationAnswer({
    required super.questionId,
    required this.choiceId,
  }) : super(questionKind: RichClosedQuestionKind.caseQualification);

  final String choiceId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'choiceId': choiceId,
  };
}

class RichClosedErrorDetectionAnswer extends RichClosedAnswer {
  const RichClosedErrorDetectionAnswer({
    required super.questionId,
    required this.errorId,
  }) : super(questionKind: RichClosedQuestionKind.errorDetection);

  final String errorId;

  @override
  Map<String, Object?> toJson() => {
    'questionId': questionId,
    'questionKind': questionKind.wireValue,
    'errorId': errorId,
  };
}

class RichClosedExerciseSubmission {
  const RichClosedExerciseSubmission({required this.answers});

  final List<RichClosedAnswer> answers;

  Map<String, Object?> toJson() => {
    'answers': [for (final answer in answers) answer.toJson()],
  };
}

class RichClosedExerciseResult {
  const RichClosedExerciseResult({
    required this.sessionId,
    required this.type,
    required this.status,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.items,
  });

  factory RichClosedExerciseResult.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed result response');
    final type = _readString(json['type'], 'Invalid rich closed result type');
    final status = _readString(
      json['status'],
      'Invalid rich closed result status',
    );
    final score = json['score'];

    if (type != richClosedExerciseType || status != 'completed') {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed result envelope',
      );
    }

    if (score is! num) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed result score',
      );
    }

    return RichClosedExerciseResult(
      sessionId: _readString(json['sessionId'], 'Invalid result session id'),
      type: type,
      status: status,
      correctAnswers: _readInt(
        json['correctAnswers'],
        'Invalid result correct answers',
      ),
      totalQuestions: _readInt(
        json['totalQuestions'],
        'Invalid result total questions',
      ),
      score: score.toDouble(),
      items: _readList(
        json['items'],
        'Invalid rich closed result items',
      ).map(RichClosedCorrectionItem.fromJson).toList(growable: false),
    );
  }

  final String sessionId;
  final String type;
  final String status;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final List<RichClosedCorrectionItem> items;
}

class RichClosedCorrectionItem {
  const RichClosedCorrectionItem({
    required this.questionId,
    required this.questionKind,
    required this.prompt,
    required this.submittedAnswer,
    required this.isCorrect,
    required this.partialScore,
    required this.explanation,
    required this.sourceChunkIds,
    required this.correction,
  });

  factory RichClosedCorrectionItem.fromJson(Object? value) {
    final json = _readObject(value, 'Invalid rich closed correction item');
    final kind = RichClosedQuestionKind.parse(json['questionKind']);
    final partialScore = json['partialScore'];

    if (partialScore is! num) {
      throw const RichClosedExerciseParseException(
        'Invalid rich closed correction partial score',
      );
    }

    return RichClosedCorrectionItem(
      questionId: _readString(json['questionId'], 'Invalid correction id'),
      questionKind: kind,
      prompt: _readString(json['prompt'], 'Invalid correction prompt'),
      submittedAnswer: RichClosedAnswer.fromJson(json['submittedAnswer']),
      isCorrect: _readBool(json['isCorrect'], 'Invalid correction status'),
      partialScore: partialScore.toDouble(),
      explanation: _readString(
        json['explanation'],
        'Invalid correction explanation',
      ),
      sourceChunkIds: _stringList(
        json['sourceChunkIds'],
        'Invalid correction sources',
      ),
      correction: RichClosedCorrectionPayload.fromJson(
        kind,
        json['correction'],
      ),
    );
  }

  final String questionId;
  final RichClosedQuestionKind questionKind;
  final String prompt;
  final RichClosedAnswer submittedAnswer;
  final bool isCorrect;
  final double partialScore;
  final String explanation;
  final List<String> sourceChunkIds;
  final RichClosedCorrectionPayload correction;
}

sealed class RichClosedCorrectionPayload {
  const RichClosedCorrectionPayload();

  factory RichClosedCorrectionPayload.fromJson(
    RichClosedQuestionKind kind,
    Object? value,
  ) {
    final json = _readObject(value, 'Invalid rich closed correction payload');

    return switch (kind) {
      RichClosedQuestionKind.singleChoice ||
      RichClosedQuestionKind.caseQualification =>
        RichClosedCorrectChoiceIdCorrection(
          correctChoiceId: _readString(
            json['correctChoiceId'],
            'Invalid correct choice id',
          ),
        ),
      RichClosedQuestionKind.multipleChoice =>
        RichClosedCorrectChoiceIdsCorrection(
          correctChoiceIds: _nonEmptyStringList(
            json['correctChoiceIds'],
            'Invalid correct choice ids',
          ),
        ),
      RichClosedQuestionKind.matching => RichClosedCorrectPairsCorrection(
        correctPairs: _pairs(json['correctPairs']),
      ),
      RichClosedQuestionKind.ordering => RichClosedCorrectOrderCorrection(
        correctOrder: _nonEmptyStringList(
          json['correctOrder'],
          'Invalid correct order',
        ),
      ),
      RichClosedQuestionKind.timeline => RichClosedCorrectOrderCorrection(
        correctOrder: _nonEmptyStringList(
          json['correctOrder'],
          'Invalid correct timeline order',
        ),
      ),
      RichClosedQuestionKind.dateSlider => RichClosedCorrectYearCorrection(
        correctYear: _readInt(json['correctYear'], 'Invalid correct year'),
        minAcceptedYear: _readInt(
          json['minAcceptedYear'],
          'Invalid minimum accepted year',
        ),
        maxAcceptedYear: _readInt(
          json['maxAcceptedYear'],
          'Invalid maximum accepted year',
        ),
      ),
      RichClosedQuestionKind.trueFalseGrid =>
        RichClosedCorrectTrueFalseValuesCorrection(
          correctValues: _trueFalseValues(json['correctValues']),
        ),
      RichClosedQuestionKind.causeConsequence =>
        RichClosedCorrectCauseConsequencePairsCorrection(
          correctPairs: _causeConsequencePairs(json['correctPairs']),
        ),
      RichClosedQuestionKind.institutionMatrix =>
        RichClosedCorrectInstitutionMatrixValuesCorrection(
          correctValues: _institutionMatrixValues(json['correctValues']),
        ),
      RichClosedQuestionKind.diagramLabeling =>
        RichClosedCorrectDiagramLabelingValuesCorrection(
          correctValues: _diagramLabelingValues(json['correctValues']),
        ),
      RichClosedQuestionKind.calculationMcq =>
        RichClosedCorrectCalculationMcqCorrection(
          correctChoiceId: _readString(
            json['correctChoiceId'],
            'Invalid correct calculation choice id',
          ),
          expectedValue: _readInt(
            json['expectedValue'],
            'Invalid calculation expected value',
          ),
          workedSteps: _calculationWorkedSteps(json['workedSteps']),
        ),
      RichClosedQuestionKind.errorDetection =>
        RichClosedCorrectErrorIdCorrection(
          correctErrorId: _readString(
            json['correctErrorId'],
            'Invalid correct error id',
          ),
        ),
    };
  }
}

class RichClosedCorrectChoiceIdCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectChoiceIdCorrection({required this.correctChoiceId});

  final String correctChoiceId;
}

class RichClosedCorrectChoiceIdsCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectChoiceIdsCorrection({required this.correctChoiceIds});

  final List<String> correctChoiceIds;
}

class RichClosedCorrectPairsCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectPairsCorrection({required this.correctPairs});

  final List<RichClosedPair> correctPairs;
}

class RichClosedCorrectOrderCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectOrderCorrection({required this.correctOrder});

  final List<String> correctOrder;
}

class RichClosedCorrectYearCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectYearCorrection({
    required this.correctYear,
    required this.minAcceptedYear,
    required this.maxAcceptedYear,
  });

  final int correctYear;
  final int minAcceptedYear;
  final int maxAcceptedYear;
}

class RichClosedCorrectTrueFalseValuesCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectTrueFalseValuesCorrection({
    required this.correctValues,
  });

  final List<RichClosedTrueFalseGridValue> correctValues;
}

class RichClosedCorrectCauseConsequencePairsCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectCauseConsequencePairsCorrection({
    required this.correctPairs,
  });

  final List<RichClosedCauseConsequencePair> correctPairs;
}

class RichClosedCorrectInstitutionMatrixValuesCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectInstitutionMatrixValuesCorrection({
    required this.correctValues,
  });

  final List<RichClosedInstitutionMatrixValue> correctValues;
}

class RichClosedCorrectDiagramLabelingValuesCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectDiagramLabelingValuesCorrection({
    required this.correctValues,
  });

  final List<RichClosedDiagramLabelingValue> correctValues;
}

class RichClosedCorrectCalculationMcqCorrection
    extends RichClosedCorrectionPayload {
  const RichClosedCorrectCalculationMcqCorrection({
    required this.correctChoiceId,
    required this.expectedValue,
    required this.workedSteps,
  });

  final String correctChoiceId;
  final int expectedValue;
  final List<RichClosedCalculationWorkedStep> workedSteps;
}

class RichClosedCorrectErrorIdCorrection extends RichClosedCorrectionPayload {
  const RichClosedCorrectErrorIdCorrection({required this.correctErrorId});

  final String correctErrorId;
}

List<RichClosedChoice> _choices(Object? value) {
  final choices = _readList(
    value,
    'Invalid rich closed choices',
  ).map(RichClosedChoice.fromJson).toList(growable: false);

  if (choices.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed choices cannot be empty',
    );
  }

  return choices;
}

List<RichClosedLabelItem> _labelItems(Object? value, String message) {
  final items = _readList(
    value,
    message,
  ).map(RichClosedLabelItem.fromJson).toList(growable: false);

  if (items.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return items;
}

List<RichClosedTimelineEvent> _timelineEvents(Object? value) {
  final events = _readList(
    value,
    'Invalid rich closed timeline events',
  ).map(RichClosedTimelineEvent.fromJson).toList(growable: false);

  if (events.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed timeline events cannot be empty',
    );
  }

  return events;
}

List<RichClosedTrueFalseRow> _trueFalseRows(Object? value) {
  final rows = _readList(
    value,
    'Invalid rich closed true/false rows',
  ).map(RichClosedTrueFalseRow.fromJson).toList(growable: false);

  if (rows.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed true/false rows cannot be empty',
    );
  }

  return rows;
}

List<RichClosedTrueFalseGridValue> _trueFalseValues(Object? value) {
  final values = _readList(
    value,
    'Invalid rich closed true/false values',
  ).map(RichClosedTrueFalseGridValue.fromJson).toList(growable: false);

  if (values.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed true/false values cannot be empty',
    );
  }

  return values;
}

List<RichClosedCauseConsequenceItem> _causeConsequenceItems(
  Object? value,
  String message,
) {
  final items = _readList(
    value,
    message,
  ).map(RichClosedCauseConsequenceItem.fromJson).toList(growable: false);

  if (items.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return items;
}

List<RichClosedCauseConsequencePair> _causeConsequencePairs(Object? value) {
  final pairs = _readList(
    value,
    'Invalid rich closed cause/consequence pairs',
  ).map(RichClosedCauseConsequencePair.fromJson).toList(growable: false);

  if (pairs.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed cause/consequence pairs cannot be empty',
    );
  }

  return pairs;
}

List<RichClosedInstitutionMatrixAxisItem> _institutionMatrixAxisItems(
  Object? value,
  String message,
) {
  final items = _readList(
    value,
    message,
  ).map(RichClosedInstitutionMatrixAxisItem.fromJson).toList(growable: false);

  if (items.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return items;
}

List<RichClosedInstitutionMatrixCell> _institutionMatrixCells(Object? value) {
  final cells = _readList(
    value,
    'Invalid institution matrix cells',
  ).map(RichClosedInstitutionMatrixCell.fromJson).toList(growable: false);

  if (cells.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Institution matrix cells cannot be empty',
    );
  }

  return cells;
}

List<RichClosedInstitutionMatrixValue> _institutionMatrixValues(Object? value) {
  final values = _readList(
    value,
    'Invalid institution matrix values',
  ).map(RichClosedInstitutionMatrixValue.fromJson).toList(growable: false);

  if (values.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Institution matrix values cannot be empty',
    );
  }

  return values;
}

List<RichClosedDiagramNode> _diagramNodes(Object? value) {
  final nodes = _readList(
    value,
    'Invalid rich closed diagram nodes',
  ).map(RichClosedDiagramNode.fromJson).toList(growable: false);

  if (nodes.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed diagram nodes cannot be empty',
    );
  }

  return nodes;
}

List<RichClosedDiagramGroup> _diagramGroups(Object? value) {
  if (value == null) {
    return const [];
  }

  return _readList(
    value,
    'Invalid rich closed diagram groups',
  ).map(RichClosedDiagramGroup.fromJson).toList(growable: false);
}

List<RichClosedDiagramEdge> _diagramEdges(Object? value) {
  if (value == null) {
    return const [];
  }

  return _readList(
    value,
    'Invalid rich closed diagram edges',
  ).map(RichClosedDiagramEdge.fromJson).toList(growable: false);
}

List<RichClosedDiagramLabelingSlot> _diagramLabelingSlots(Object? value) {
  final slots = _readList(
    value,
    'Invalid diagram labeling slots',
  ).map(RichClosedDiagramLabelingSlot.fromJson).toList(growable: false);

  if (slots.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Diagram labeling slots cannot be empty',
    );
  }

  return slots;
}

List<RichClosedDiagramLabelingValue> _diagramLabelingValues(Object? value) {
  final values = _readList(
    value,
    'Invalid diagram labeling values',
  ).map(RichClosedDiagramLabelingValue.fromJson).toList(growable: false);

  if (values.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Diagram labeling values cannot be empty',
    );
  }

  return values;
}

List<RichClosedCalculationChoice> _calculationChoices(Object? value) {
  final choices = _readList(
    value,
    'Invalid calculation choices',
  ).map(RichClosedCalculationChoice.fromJson).toList(growable: false);

  if (choices.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Calculation choices cannot be empty',
    );
  }

  return choices;
}

List<RichClosedCalculationParty> _calculationParties(Object? value) {
  final parties = _readList(
    value,
    'Invalid calculation parties',
  ).map(RichClosedCalculationParty.fromJson).toList(growable: false);

  if (parties.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Calculation parties cannot be empty',
    );
  }

  return parties;
}

List<RichClosedCalculationWorkedStep> _calculationWorkedSteps(Object? value) {
  final steps = _readList(
    value,
    'Invalid calculation worked steps',
  ).map(RichClosedCalculationWorkedStep.fromJson).toList(growable: false);

  if (steps.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Calculation worked steps cannot be empty',
    );
  }

  return steps;
}

List<RichClosedPair> _pairs(Object? value) {
  final pairs = _readList(
    value,
    'Invalid rich closed pairs',
  ).map(RichClosedPair.fromJson).toList(growable: false);

  if (pairs.isEmpty) {
    throw const RichClosedExerciseParseException(
      'Rich closed pairs cannot be empty',
    );
  }

  return pairs;
}

Map<String, Object?> _readObject(Object? value, String message) {
  if (value is Map<String, Object?>) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

List<Object?> _readList(Object? value, String message) {
  if (value is List) {
    return value.cast<Object?>();
  }

  throw RichClosedExerciseParseException(message);
}

String _readString(Object? value, String message) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }

  throw RichClosedExerciseParseException(message);
}

String? _readOptionalString(Object? value) {
  if (value == null) {
    return null;
  }

  return _readString(value, 'Invalid optional rich closed string');
}

int _readInt(Object? value, String message) {
  if (value is int) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

bool _readBool(Object? value, String message) {
  if (value is bool) {
    return value;
  }

  throw RichClosedExerciseParseException(message);
}

List<String> _stringList(Object? value, String message) {
  return _readList(
    value,
    message,
  ).map((item) => _readString(item, message)).toList(growable: false);
}

List<String> _nonEmptyStringList(Object? value, String message) {
  final values = _stringList(value, message);
  if (values.isEmpty) {
    throw RichClosedExerciseParseException(message);
  }

  return values;
}

void _assertNoPreSubmitLeaks(Object? value) {
  if (_containsForbiddenPreSubmitField(value)) {
    throw const RichClosedExerciseParseException(
      'Rich closed pre-submit payload contains correction data',
    );
  }
}

void _assertNoAnswerLeaks(Object? value) {
  if (_containsForbiddenAnswerField(value)) {
    throw const RichClosedExerciseParseException(
      'Rich closed answer payload contains forbidden data',
    );
  }
}

bool _containsForbiddenPreSubmitField(Object? value) {
  return _containsForbiddenField(value, _forbiddenPreSubmitKeys);
}

bool _containsForbiddenAnswerField(Object? value) {
  return _containsForbiddenField(value, _forbiddenAnswerKeys);
}

bool _containsForbiddenField(Object? value, Set<String> forbiddenKeys) {
  if (value is List) {
    return value.any((item) => _containsForbiddenField(item, forbiddenKeys));
  }

  if (value is! Map) {
    return false;
  }

  for (final entry in value.entries) {
    final key = entry.key;
    if (key is String &&
        (key.startsWith('correct') || forbiddenKeys.contains(key))) {
      return true;
    }

    if (_containsForbiddenField(entry.value, forbiddenKeys)) {
      return true;
    }
  }

  return false;
}

const _forbiddenPreSubmitKeys = {
  'correctionPayload',
  'correction',
  'explanation',
  'feedback',
  'choiceFeedback',
  'modelAnswer',
  'answerText',
  'freeTextAnswer',
  'textAnswer',
  'score',
  'partialScore',
  'workedSteps',
  'expectedValue',
  'answersPayload',
  'expectedAnswer',
  'expectedAnswers',
  'html',
  'svg',
  'rawSvg',
  'mermaid',
  'markdown',
  'widget',
  'component',
  'render',
  'renderPayload',
  'style',
  'css',
  'script',
  'imageUrl',
  'assetUrl',
  'canvas',
  'code',
  'eval',
  'Function',
  'function',
  'formula',
  'expression',
  'rawFormula',
  'calculationCode',
  'javascript',
  'python',
  'markup',
};

const _forbiddenAnswerKeys = {
  'correctionPayload',
  'correction',
  'explanation',
  'feedback',
  'choiceFeedback',
  'modelAnswer',
  'answerText',
  'freeTextAnswer',
  'textAnswer',
  'score',
  'partialScore',
  'workedSteps',
  'expectedValue',
  'answersPayload',
  'expectedAnswer',
  'expectedAnswers',
  'html',
  'svg',
  'rawSvg',
  'mermaid',
  'markdown',
  'widget',
  'component',
  'render',
  'renderPayload',
  'style',
  'css',
  'script',
  'imageUrl',
  'assetUrl',
  'canvas',
  'code',
  'eval',
  'Function',
  'function',
  'formula',
  'expression',
  'rawFormula',
  'calculationCode',
  'javascript',
  'python',
  'markup',
};

~~~

### lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart

~~~text
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCoreAnswerController {
  final Map<String, String> _singleSelections = {};
  final Map<String, Set<String>> _multipleSelections = {};
  final Map<String, Map<String, String>> _matchingSelections = {};
  final Map<String, List<String>> _orderingSelections = {};
  final Map<String, List<String>> _timelineSelections = {};
  final Map<String, int> _dateSliderSelections = {};
  final Map<String, Map<String, bool>> _trueFalseSelections = {};
  final Map<String, Map<String, String>> _causeConsequenceSelections = {};
  final Map<String, Map<String, String>> _institutionMatrixSelections = {};
  final Map<String, Map<String, String>> _diagramLabelingSelections = {};
  final Map<String, String> _calculationMcqSelections = {};

  String? _message;

  String? get message => _message;

  String? selectedChoiceIdFor(String questionId) {
    return _singleSelections[questionId];
  }

  List<String> selectedChoiceIdsFor(RichClosedMultipleChoiceQuestion question) {
    final selectedIds = _multipleSelections[question.id];
    if (selectedIds == null || selectedIds.isEmpty) {
      return const [];
    }

    return question.choices
        .where((choice) => selectedIds.contains(choice.id))
        .map((choice) => choice.id)
        .toList(growable: false);
  }

  String? selectedRightIdFor(String questionId, String leftId) {
    return _matchingSelections[questionId]?[leftId];
  }

  List<RichClosedPair> matchingPairsFor(RichClosedMatchingQuestion question) {
    final selections = _matchingSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final leftItem in question.leftItems)
        if (selections[leftItem.id] != null)
          RichClosedPair(
            leftId: leftItem.id,
            rightId: selections[leftItem.id]!,
          ),
    ];
  }

  List<String> orderedIdsFor(RichClosedOrderingQuestion question) {
    final orderedIds = _orderingSelections[question.id];
    if (orderedIds == null || !_isCompleteOrdering(question, orderedIds)) {
      return question.items.map((item) => item.id).toList(growable: false);
    }

    return orderedIds.toList(growable: false);
  }

  List<String> orderedEventIdsFor(RichClosedTimelineQuestion question) {
    final orderedEventIds = _timelineSelections[question.id];
    if (orderedEventIds == null ||
        !_isCompleteTimeline(question, orderedEventIds)) {
      return question.events.map((event) => event.id).toList(growable: false);
    }

    return orderedEventIds.toList(growable: false);
  }

  int selectedYearFor(RichClosedDateSliderQuestion question) {
    return _dateSliderSelections.putIfAbsent(
      question.id,
      () => _initialYearFor(question),
    );
  }

  bool? selectedTrueFalseValueFor(String questionId, String rowId) {
    return _trueFalseSelections[questionId]?[rowId];
  }

  List<RichClosedTrueFalseGridValue> trueFalseValuesFor(
    RichClosedTrueFalseGridQuestion question,
  ) {
    final selections = _trueFalseSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final row in question.rows)
        if (selections[row.id] != null)
          RichClosedTrueFalseGridValue(
            rowId: row.id,
            value: selections[row.id]!,
          ),
    ];
  }

  String? selectedConsequenceIdFor(String questionId, String causeId) {
    return _causeConsequenceSelections[questionId]?[causeId];
  }

  List<RichClosedCauseConsequencePair> causeConsequencePairsFor(
    RichClosedCauseConsequenceQuestion question,
  ) {
    final selections = _causeConsequenceSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final cause in question.causes)
        if (selections[cause.id] != null)
          RichClosedCauseConsequencePair(
            causeId: cause.id,
            consequenceId: selections[cause.id]!,
          ),
    ];
  }

  String? selectedInstitutionMatrixOptionIdFor(
    String questionId,
    String cellId,
  ) {
    return _institutionMatrixSelections[questionId]?[cellId];
  }

  List<RichClosedInstitutionMatrixValue> institutionMatrixValuesFor(
    RichClosedInstitutionMatrixQuestion question,
  ) {
    final selections = _institutionMatrixSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final cell in question.cells)
        if (selections[cell.id] != null)
          RichClosedInstitutionMatrixValue(
            cellId: cell.id,
            optionId: selections[cell.id]!,
          ),
    ];
  }

  String? selectedDiagramLabelingOptionIdFor(String questionId, String slotId) {
    return _diagramLabelingSelections[questionId]?[slotId];
  }

  List<RichClosedDiagramLabelingValue> diagramLabelingValuesFor(
    RichClosedDiagramLabelingQuestion question,
  ) {
    final selections = _diagramLabelingSelections[question.id];
    if (selections == null || selections.isEmpty) {
      return const [];
    }

    return [
      for (final slot in question.slots)
        if (selections[slot.id] != null)
          RichClosedDiagramLabelingValue(
            slotId: slot.id,
            optionId: selections[slot.id]!,
          ),
    ];
  }

  String? selectedCalculationChoiceIdFor(String questionId) {
    return _calculationMcqSelections[questionId];
  }

  void selectSingleChoice({
    required RichClosedSingleChoiceQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    _singleSelections[question.id] = choiceId;
    _message = null;
  }

  void selectCaseQualification({
    required RichClosedCaseQualificationQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    _singleSelections[question.id] = choiceId;
    _message = null;
  }

  void selectErrorDetection({
    required RichClosedErrorDetectionQuestion question,
    required String errorId,
  }) {
    if (!_hasChoice(question.errorOptions, errorId)) {
      return;
    }

    _singleSelections[question.id] = errorId;
    _message = null;
  }

  void toggleMultipleChoice({
    required RichClosedMultipleChoiceQuestion question,
    required String choiceId,
  }) {
    if (!_hasChoice(question.choices, choiceId)) {
      return;
    }

    final selectedIds = _multipleSelections.putIfAbsent(
      question.id,
      () => <String>{},
    );

    if (selectedIds.contains(choiceId)) {
      selectedIds.remove(choiceId);
      _message = null;
      return;
    }

    if (selectedIds.length >= question.maxSelections) {
      _message =
          'Tu peux sélectionner ${question.maxSelections} réponses au maximum.';
      return;
    }

    selectedIds.add(choiceId);
    _message = null;
  }

  void setMatchingPair({
    required RichClosedMatchingQuestion question,
    required String leftId,
    required String rightId,
  }) {
    if (!_hasLabelItem(question.leftItems, leftId) ||
        !_hasLabelItem(question.rightItems, rightId)) {
      return;
    }

    final selections = _matchingSelections.putIfAbsent(
      question.id,
      () => <String, String>{},
    );

    selections.removeWhere(
      (existingLeftId, existingRightId) =>
          existingLeftId != leftId && existingRightId == rightId,
    );
    selections[leftId] = rightId;
    _message = null;
  }

  void moveOrderingItemUp({
    required RichClosedOrderingQuestion question,
    required String itemId,
  }) {
    _moveOrderingItem(question: question, itemId: itemId, delta: -1);
  }

  void moveOrderingItemDown({
    required RichClosedOrderingQuestion question,
    required String itemId,
  }) {
    _moveOrderingItem(question: question, itemId: itemId, delta: 1);
  }

  void moveTimelineEventUp({
    required RichClosedTimelineQuestion question,
    required String eventId,
  }) {
    _moveTimelineEvent(question: question, eventId: eventId, delta: -1);
  }

  void moveTimelineEventDown({
    required RichClosedTimelineQuestion question,
    required String eventId,
  }) {
    _moveTimelineEvent(question: question, eventId: eventId, delta: 1);
  }

  void setDateSliderYear({
    required RichClosedDateSliderQuestion question,
    required int year,
  }) {
    _dateSliderSelections[question.id] = _snapYear(question, year);
    _message = null;
  }

  void setTrueFalseValue({
    required RichClosedTrueFalseGridQuestion question,
    required String rowId,
    required bool value,
  }) {
    if (!_hasTrueFalseRow(question.rows, rowId)) {
      return;
    }

    final selections = _trueFalseSelections.putIfAbsent(
      question.id,
      () => <String, bool>{},
    );
    selections[rowId] = value;
    _message = null;
  }

  void setCauseConsequencePair({
    required RichClosedCauseConsequenceQuestion question,
    required String causeId,
    required String consequenceId,
  }) {
    if (!_hasCauseConsequenceItem(question.causes, causeId) ||
        !_hasCauseConsequenceItem(question.consequences, consequenceId)) {
      return;
    }

    final selections = _causeConsequenceSelections.putIfAbsent(
      question.id,
      () => <String, String>{},
    );
    selections.removeWhere(
      (existingCauseId, existingConsequenceId) =>
          existingCauseId != causeId && existingConsequenceId == consequenceId,
    );
    selections[causeId] = consequenceId;
    _message = null;
  }

  void setInstitutionMatrixValue({
    required RichClosedInstitutionMatrixQuestion question,
    required String cellId,
    required String optionId,
  }) {
    final cell = _institutionMatrixCell(question.cells, cellId);
    if (cell == null || !_hasChoice(cell.options, optionId)) {
      return;
    }

    final selections = _institutionMatrixSelections.putIfAbsent(
      question.id,
      () => <String, String>{},
    );
    selections[cellId] = optionId;
    _message = null;
  }

  void setDiagramLabelingValue({
    required RichClosedDiagramLabelingQuestion question,
    required String slotId,
    required String optionId,
  }) {
    final slot = _diagramLabelingSlot(question.slots, slotId);
    if (slot == null || !_hasChoice(slot.options, optionId)) {
      return;
    }

    final selections = _diagramLabelingSelections.putIfAbsent(
      question.id,
      () => <String, String>{},
    );
    selections[slotId] = optionId;
    _message = null;
  }

  void selectCalculationChoice({
    required RichClosedCalculationMcqQuestion question,
    required String choiceId,
  }) {
    if (!_hasCalculationChoice(question.choices, choiceId)) {
      return;
    }

    _calculationMcqSelections[question.id] = choiceId;
    _message = null;
  }

  bool canSubmitQuestion(RichClosedQuestion question) {
    return switch (question) {
      RichClosedSingleChoiceQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMultipleChoiceQuestion() => _canSubmitMultipleChoice(question),
      RichClosedCaseQualificationQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedErrorDetectionQuestion() =>
        _singleSelections[question.id] != null,
      RichClosedMatchingQuestion() => _canSubmitMatching(question),
      RichClosedOrderingQuestion() => _canSubmitOrdering(question),
      RichClosedTimelineQuestion() => _canSubmitTimeline(question),
      RichClosedDateSliderQuestion() => true,
      RichClosedTrueFalseGridQuestion() => _canSubmitTrueFalseGrid(question),
      RichClosedCauseConsequenceQuestion() => _canSubmitCauseConsequence(
        question,
      ),
      RichClosedInstitutionMatrixQuestion() => _canSubmitInstitutionMatrix(
        question,
      ),
      RichClosedDiagramLabelingQuestion() => _canSubmitDiagramLabeling(
        question,
      ),
      RichClosedCalculationMcqQuestion() =>
        _calculationMcqSelections[question.id] != null,
    };
  }

  RichClosedAnswer? answerFor(RichClosedQuestion question) {
    if (!canSubmitQuestion(question)) {
      return null;
    }

    return switch (question) {
      RichClosedSingleChoiceQuestion() => RichClosedSingleChoiceAnswer(
        questionId: question.id,
        choiceId: _singleSelections[question.id]!,
      ),
      RichClosedMultipleChoiceQuestion() => RichClosedMultipleChoiceAnswer(
        questionId: question.id,
        choiceIds: selectedChoiceIdsFor(question),
      ),
      RichClosedCaseQualificationQuestion() =>
        RichClosedCaseQualificationAnswer(
          questionId: question.id,
          choiceId: _singleSelections[question.id]!,
        ),
      RichClosedErrorDetectionQuestion() => RichClosedErrorDetectionAnswer(
        questionId: question.id,
        errorId: _singleSelections[question.id]!,
      ),
      RichClosedMatchingQuestion() => RichClosedMatchingAnswer(
        questionId: question.id,
        pairs: matchingPairsFor(question),
      ),
      RichClosedOrderingQuestion() => RichClosedOrderingAnswer(
        questionId: question.id,
        orderedIds: orderedIdsFor(question),
      ),
      RichClosedTimelineQuestion() => RichClosedTimelineAnswer(
        questionId: question.id,
        orderedEventIds: orderedEventIdsFor(question),
      ),
      RichClosedDateSliderQuestion() => RichClosedDateSliderAnswer(
        questionId: question.id,
        year: selectedYearFor(question),
      ),
      RichClosedTrueFalseGridQuestion() => RichClosedTrueFalseGridAnswer(
        questionId: question.id,
        values: trueFalseValuesFor(question),
      ),
      RichClosedCauseConsequenceQuestion() => RichClosedCauseConsequenceAnswer(
        questionId: question.id,
        pairs: causeConsequencePairsFor(question),
      ),
      RichClosedInstitutionMatrixQuestion() =>
        RichClosedInstitutionMatrixAnswer(
          questionId: question.id,
          values: institutionMatrixValuesFor(question),
        ),
      RichClosedDiagramLabelingQuestion() => RichClosedDiagramLabelingAnswer(
        questionId: question.id,
        values: diagramLabelingValuesFor(question),
      ),
      RichClosedCalculationMcqQuestion() => RichClosedCalculationMcqAnswer(
        questionId: question.id,
        choiceId: _calculationMcqSelections[question.id]!,
      ),
    };
  }

  bool _canSubmitMultipleChoice(RichClosedMultipleChoiceQuestion question) {
    final selectedCount = _multipleSelections[question.id]?.length ?? 0;
    return selectedCount >= question.minSelections &&
        selectedCount <= question.maxSelections;
  }

  bool _canSubmitMatching(RichClosedMatchingQuestion question) {
    final selections = _matchingSelections[question.id];
    if (selections == null || selections.length != question.leftItems.length) {
      return false;
    }

    final leftIds = question.leftItems.map((item) => item.id).toSet();
    final rightIds = question.rightItems.map((item) => item.id).toSet();
    final selectedRightIds = selections.values.toSet();

    return selections.keys.every(leftIds.contains) &&
        selections.values.every(rightIds.contains) &&
        selectedRightIds.length == selections.length;
  }

  bool _canSubmitOrdering(RichClosedOrderingQuestion question) {
    return _isCompleteOrdering(question, orderedIdsFor(question));
  }

  bool _canSubmitTimeline(RichClosedTimelineQuestion question) {
    return _isCompleteTimeline(question, orderedEventIdsFor(question));
  }

  bool _canSubmitTrueFalseGrid(RichClosedTrueFalseGridQuestion question) {
    final selections = _trueFalseSelections[question.id];
    if (selections == null || selections.length != question.rows.length) {
      return false;
    }

    final rowIds = question.rows.map((row) => row.id).toSet();

    return selections.keys.every(rowIds.contains);
  }

  bool _canSubmitCauseConsequence(RichClosedCauseConsequenceQuestion question) {
    final selections = _causeConsequenceSelections[question.id];
    if (selections == null || selections.length != question.causes.length) {
      return false;
    }

    final causeIds = question.causes.map((cause) => cause.id).toSet();
    final consequenceIds = question.consequences
        .map((consequence) => consequence.id)
        .toSet();
    final selectedConsequenceIds = selections.values.toSet();

    return selections.keys.every(causeIds.contains) &&
        selections.values.every(consequenceIds.contains) &&
        selectedConsequenceIds.length == selections.length;
  }

  bool _canSubmitInstitutionMatrix(
    RichClosedInstitutionMatrixQuestion question,
  ) {
    final selections = _institutionMatrixSelections[question.id];
    if (selections == null || selections.length != question.cells.length) {
      return false;
    }

    final cellIds = question.cells.map((cell) => cell.id).toSet();

    return selections.entries.every((entry) {
      final cell = _institutionMatrixCell(question.cells, entry.key);
      return cellIds.contains(entry.key) &&
          cell != null &&
          _hasChoice(cell.options, entry.value);
    });
  }

  bool _canSubmitDiagramLabeling(RichClosedDiagramLabelingQuestion question) {
    final selections = _diagramLabelingSelections[question.id];
    if (selections == null || selections.length != question.slots.length) {
      return false;
    }

    final slotIds = question.slots.map((slot) => slot.id).toSet();

    return selections.entries.every((entry) {
      final slot = _diagramLabelingSlot(question.slots, entry.key);
      return slotIds.contains(entry.key) &&
          slot != null &&
          _hasChoice(slot.options, entry.value);
    });
  }

  void _moveOrderingItem({
    required RichClosedOrderingQuestion question,
    required String itemId,
    required int delta,
  }) {
    if (!_hasLabelItem(question.items, itemId)) {
      return;
    }

    final orderedIds = orderedIdsFor(question).toList();
    final currentIndex = orderedIds.indexOf(itemId);
    final nextIndex = currentIndex + delta;

    if (currentIndex < 0 || nextIndex < 0 || nextIndex >= orderedIds.length) {
      return;
    }

    final movedId = orderedIds.removeAt(currentIndex);
    orderedIds.insert(nextIndex, movedId);
    _orderingSelections[question.id] = orderedIds;
    _message = null;
  }

  void _moveTimelineEvent({
    required RichClosedTimelineQuestion question,
    required String eventId,
    required int delta,
  }) {
    if (!_hasTimelineEvent(question.events, eventId)) {
      return;
    }

    final orderedEventIds = orderedEventIdsFor(question).toList();
    final currentIndex = orderedEventIds.indexOf(eventId);
    final nextIndex = currentIndex + delta;

    if (currentIndex < 0 ||
        nextIndex < 0 ||
        nextIndex >= orderedEventIds.length) {
      return;
    }

    final movedId = orderedEventIds.removeAt(currentIndex);
    orderedEventIds.insert(nextIndex, movedId);
    _timelineSelections[question.id] = orderedEventIds;
    _message = null;
  }

  bool _isCompleteOrdering(
    RichClosedOrderingQuestion question,
    List<String> orderedIds,
  ) {
    final expectedIds = question.items.map((item) => item.id).toSet();
    final actualIds = orderedIds.toSet();

    return orderedIds.length == question.items.length &&
        actualIds.length == orderedIds.length &&
        actualIds.length == expectedIds.length &&
        actualIds.every(expectedIds.contains);
  }

  bool _isCompleteTimeline(
    RichClosedTimelineQuestion question,
    List<String> orderedEventIds,
  ) {
    final expectedIds = question.events.map((event) => event.id).toSet();
    final actualIds = orderedEventIds.toSet();

    return orderedEventIds.length == question.events.length &&
        actualIds.length == orderedEventIds.length &&
        actualIds.length == expectedIds.length &&
        actualIds.every(expectedIds.contains);
  }

  int _initialYearFor(RichClosedDateSliderQuestion question) {
    final midpoint =
        question.minYear + ((question.maxYear - question.minYear) / 2).round();

    return _snapYear(question, midpoint);
  }

  int _snapYear(RichClosedDateSliderQuestion question, int year) {
    final clamped = year.clamp(question.minYear, question.maxYear);
    final offset = clamped - question.minYear;
    final stepsFromMin = (offset / question.step).round();
    final snapped = question.minYear + stepsFromMin * question.step;

    if (snapped < question.minYear) {
      return question.minYear;
    }
    if (snapped > question.maxYear) {
      return question.maxYear;
    }
    return snapped;
  }

  bool _hasChoice(List<RichClosedChoice> choices, String choiceId) {
    return choices.any((choice) => choice.id == choiceId);
  }

  bool _hasCalculationChoice(
    List<RichClosedCalculationChoice> choices,
    String choiceId,
  ) {
    return choices.any((choice) => choice.id == choiceId);
  }

  bool _hasLabelItem(List<RichClosedLabelItem> items, String itemId) {
    return items.any((item) => item.id == itemId);
  }

  bool _hasTimelineEvent(List<RichClosedTimelineEvent> events, String eventId) {
    return events.any((event) => event.id == eventId);
  }

  bool _hasTrueFalseRow(List<RichClosedTrueFalseRow> rows, String rowId) {
    return rows.any((row) => row.id == rowId);
  }

  bool _hasCauseConsequenceItem(
    List<RichClosedCauseConsequenceItem> items,
    String itemId,
  ) {
    return items.any((item) => item.id == itemId);
  }

  RichClosedInstitutionMatrixCell? _institutionMatrixCell(
    List<RichClosedInstitutionMatrixCell> cells,
    String cellId,
  ) {
    for (final cell in cells) {
      if (cell.id == cellId) {
        return cell;
      }
    }
    return null;
  }

  RichClosedDiagramLabelingSlot? _diagramLabelingSlot(
    List<RichClosedDiagramLabelingSlot> slots,
    String slotId,
  ) {
    for (final slot in slots) {
      if (slot.id == slotId) {
        return slot;
      }
    }
    return null;
  }
}

~~~

### lib/features/activities/presentation/rich_closed/rich_closed_calculation_mcq_widget.dart

~~~text
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedCalculationMcqWidget extends StatefulWidget {
  const RichClosedCalculationMcqWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedCalculationMcqQuestion question;
  final ValueChanged<RichClosedCalculationMcqAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedCalculationMcqWidget> createState() =>
      _RichClosedCalculationMcqWidgetState();
}

class _RichClosedCalculationMcqWidgetState
    extends State<RichClosedCalculationMcqWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedCalculationMcqWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedCalculationChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        if (widget.question.instruction != null) ...[
          Text(
            widget.question.instruction!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        _CalculationScenarioPanel(question: widget.question),
        const SizedBox(height: AppSpacing.m),
        for (final choice in widget.question.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _CalculationChoiceTile(
              key: ValueKey(
                'calculation-mcq-${widget.question.id}-${choice.id}',
              ),
              choice: choice,
              selected: selectedChoiceId == choice.id,
              enabled: widget.enabled,
              onTap: () => _selectChoice(choice.id),
            ),
          ),
      ],
    );
  }

  void _selectChoice(String? choiceId) {
    if (!widget.enabled || choiceId == null) {
      return;
    }

    setState(() {
      _controller.selectCalculationChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedCalculationMcqAnswer ? answer : null,
    );
  }
}

class _CalculationChoiceTile extends StatelessWidget {
  const _CalculationChoiceTile({
    required this.choice,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final RichClosedCalculationChoice choice;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : null,
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(choice.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Valeur : ${choice.value}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculationScenarioPanel extends StatelessWidget {
  const _CalculationScenarioPanel({required this.question});

  final RichClosedCalculationMcqQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.scenario, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.s),
          ..._calculationLines(question.calculation),
        ],
      ),
    );
  }

  List<Widget> _calculationLines(RichClosedCalculationData calculation) {
    return switch (calculation) {
      RichClosedAbsoluteMajorityThresholdCalculation(:final validVotes) => [
        Text('Suffrages exprimés : $validVotes'),
      ],
      RichClosedLargestRemainderTargetPartySeatsCalculation(
        :final totalSeats,
        :final targetPartyId,
        :final parties,
      ) =>
        [
          Text('Sièges à répartir : $totalSeats'),
          Text('Parti ciblé : ${_partyLabel(parties, targetPartyId)}'),
          const SizedBox(height: AppSpacing.xs),
          for (final party in parties)
            Text('${party.label} : ${party.votes} voix'),
        ],
    };
  }

  String _partyLabel(List<RichClosedCalculationParty> parties, String partyId) {
    for (final party in parties) {
      if (party.id == partyId) {
        return party.label;
      }
    }

    return partyId;
  }
}

~~~

### lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart

~~~text
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

class RichClosedCorrectionPresentationException implements Exception {
  const RichClosedCorrectionPresentationException(this.message);

  final String message;

  @override
  String toString() => 'RichClosedCorrectionPresentationException: $message';
}

class RichClosedCorrectionPresenter {
  const RichClosedCorrectionPresenter();

  RichClosedCorrectionViewModel present({
    required RichClosedExercise exercise,
    required RichClosedExerciseResult result,
  }) {
    final questionsById = {
      for (final question in exercise.questions) question.id: question,
    };

    final items = <RichClosedCorrectionItemViewModel>[
      for (final item in result.items)
        _presentItem(
          question: _questionFor(questionsById, item.questionId),
          item: item,
        ),
    ];

    return RichClosedCorrectionViewModel(
      summary: RichClosedResultSummaryViewModel(
        sessionId: result.sessionId,
        status: result.status,
        correctAnswers: result.correctAnswers,
        totalQuestions: result.totalQuestions,
        score: result.score,
      ),
      items: items,
    );
  }

  RichClosedCorrectionItemViewModel _presentItem({
    required RichClosedQuestion question,
    required RichClosedCorrectionItem item,
  }) {
    _assertQuestionContract(question, item);

    return switch (question) {
      RichClosedSingleChoiceQuestion() => _presentSingleChoice(question, item),
      RichClosedMultipleChoiceQuestion() => _presentMultipleChoice(
        question,
        item,
      ),
      RichClosedMatchingQuestion() => _presentMatching(question, item),
      RichClosedOrderingQuestion() => _presentOrdering(question, item),
      RichClosedTimelineQuestion() => _presentTimeline(question, item),
      RichClosedDateSliderQuestion() => _presentDateSlider(question, item),
      RichClosedTrueFalseGridQuestion() => _presentTrueFalseGrid(
        question,
        item,
      ),
      RichClosedCauseConsequenceQuestion() => _presentCauseConsequence(
        question,
        item,
      ),
      RichClosedInstitutionMatrixQuestion() => _presentInstitutionMatrix(
        question,
        item,
      ),
      RichClosedDiagramLabelingQuestion() => _presentDiagramLabeling(
        question,
        item,
      ),
      RichClosedCalculationMcqQuestion() => _presentCalculationMcq(
        question,
        item,
      ),
      RichClosedCaseQualificationQuestion() => _presentCaseQualification(
        question,
        item,
      ),
      RichClosedErrorDetectionQuestion() => _presentErrorDetection(
        question,
        item,
      ),
    };
  }

  RichClosedCorrectionItemViewModel _presentSingleChoice(
    RichClosedSingleChoiceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _singleChoiceAnswer(item);
    final correction = _choiceIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: [
        _choiceLabel(question.choices, submitted.choiceId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(question.choices, correction.correctChoiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentMultipleChoice(
    RichClosedMultipleChoiceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _multipleChoiceAnswer(item);
    final correction = _choiceIdsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: [
        for (final choiceId in submitted.choiceIds)
          _choiceLabel(question.choices, choiceId, question.id),
      ],
      correctAnswerLines: [
        for (final choiceId in correction.correctChoiceIds)
          _choiceLabel(question.choices, choiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentMatching(
    RichClosedMatchingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _matchingAnswer(item);
    final correction = _pairsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: _matchingLines(question, submitted.pairs),
      correctAnswerLines: _matchingLines(question, correction.correctPairs),
    );
  }

  RichClosedCorrectionItemViewModel _presentOrdering(
    RichClosedOrderingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _orderingAnswer(item);
    final correction = _orderCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      submittedAnswerLines: _orderedLines(question, submitted.orderedIds),
      correctAnswerLines: _orderedLines(question, correction.correctOrder),
    );
  }

  RichClosedCorrectionItemViewModel _presentTimeline(
    RichClosedTimelineQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _timelineAnswer(item);
    final correction = _orderCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _timelineLines(question, submitted.orderedEventIds),
      correctAnswerLines: _timelineLines(question, correction.correctOrder),
    );
  }

  RichClosedCorrectionItemViewModel _presentDateSlider(
    RichClosedDateSliderQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _dateSliderAnswer(item);
    final correction = _yearCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: ['Année choisie : ${submitted.year}'],
      correctAnswerLines: [
        'Année correcte : ${correction.correctYear}',
        'Plage acceptée : ${correction.minAcceptedYear} - ${correction.maxAcceptedYear}',
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentTrueFalseGrid(
    RichClosedTrueFalseGridQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _trueFalseGridAnswer(item);
    final correction = _trueFalseValuesCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _trueFalseLines(question, submitted.values),
      correctAnswerLines: _trueFalseLines(question, correction.correctValues),
    );
  }

  RichClosedCorrectionItemViewModel _presentCauseConsequence(
    RichClosedCauseConsequenceQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _causeConsequenceAnswer(item);
    final correction = _causeConsequencePairsCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _causeConsequenceLines(question, submitted.pairs),
      correctAnswerLines: _causeConsequenceLines(
        question,
        correction.correctPairs,
      ),
    );
  }

  RichClosedCorrectionItemViewModel _presentInstitutionMatrix(
    RichClosedInstitutionMatrixQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _institutionMatrixAnswer(item);
    final correction = _institutionMatrixValuesCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _institutionMatrixLines(question, submitted.values),
      correctAnswerLines: _institutionMatrixLines(
        question,
        correction.correctValues,
      ),
    );
  }

  RichClosedCorrectionItemViewModel _presentDiagramLabeling(
    RichClosedDiagramLabelingQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _diagramLabelingAnswer(item);
    final correction = _diagramLabelingValuesCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction,
      submittedAnswerLines: _diagramLabelingLines(question, submitted.values),
      correctAnswerLines: _diagramLabelingLines(
        question,
        correction.correctValues,
      ),
    );
  }

  RichClosedCorrectionItemViewModel _presentCalculationMcq(
    RichClosedCalculationMcqQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _calculationMcqAnswer(item);
    final correction = _calculationMcqCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.instruction == null
          ? question.scenario
          : '${question.instruction}\n${question.scenario}',
      submittedAnswerLines: [
        'Choix envoyé : ${_calculationChoiceLabel(question.choices, submitted.choiceId, question.id)}',
      ],
      correctAnswerLines: [
        'Choix attendu : ${_calculationChoiceLabel(question.choices, correction.correctChoiceId, question.id)}',
        'Valeur attendue : ${correction.expectedValue}',
        for (final step in correction.workedSteps)
          '${step.label} : ${step.detail}',
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentCaseQualification(
    RichClosedCaseQualificationQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _caseQualificationAnswer(item);
    final correction = _choiceIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.caseText,
      submittedAnswerLines: [
        _choiceLabel(question.choices, submitted.choiceId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(question.choices, correction.correctChoiceId, question.id),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _presentErrorDetection(
    RichClosedErrorDetectionQuestion question,
    RichClosedCorrectionItem item,
  ) {
    final submitted = _errorDetectionAnswer(item);
    final correction = _errorIdCorrection(item);

    return _baseItem(
      question: question,
      item: item,
      contextText: question.statement,
      submittedAnswerLines: [
        _choiceLabel(question.errorOptions, submitted.errorId, question.id),
      ],
      correctAnswerLines: [
        _choiceLabel(
          question.errorOptions,
          correction.correctErrorId,
          question.id,
        ),
      ],
    );
  }

  RichClosedCorrectionItemViewModel _baseItem({
    required RichClosedQuestion question,
    required RichClosedCorrectionItem item,
    required List<String> submittedAnswerLines,
    required List<String> correctAnswerLines,
    String? contextText,
  }) {
    return RichClosedCorrectionItemViewModel(
      questionId: question.id,
      questionKind: question.questionKind,
      kindLabel: _kindLabel(question.questionKind),
      prompt: item.prompt,
      contextText: contextText,
      isCorrect: item.isCorrect,
      partialScore: item.partialScore,
      explanation: item.explanation,
      sourceLabels: [
        for (final sourceChunkId in item.sourceChunkIds)
          'Source $sourceChunkId',
      ],
      submittedAnswerLines: submittedAnswerLines,
      correctAnswerLines: correctAnswerLines,
    );
  }

  RichClosedQuestion _questionFor(
    Map<String, RichClosedQuestion> questionsById,
    String questionId,
  ) {
    final question = questionsById[questionId];
    if (question == null) {
      throw RichClosedCorrectionPresentationException(
        'Correction references unknown question $questionId',
      );
    }
    return question;
  }

  void _assertQuestionContract(
    RichClosedQuestion question,
    RichClosedCorrectionItem item,
  ) {
    if (item.questionKind != question.questionKind) {
      throw RichClosedCorrectionPresentationException(
        'Correction kind mismatch for question ${question.id}',
      );
    }

    if (item.submittedAnswer.questionId != question.id ||
        item.submittedAnswer.questionKind != question.questionKind) {
      throw RichClosedCorrectionPresentationException(
        'Submitted answer mismatch for question ${question.id}',
      );
    }
  }

  RichClosedSingleChoiceAnswer _singleChoiceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedSingleChoiceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid single choice submitted answer for ${item.questionId}',
    );
  }

  RichClosedMultipleChoiceAnswer _multipleChoiceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedMultipleChoiceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid multiple choice submitted answer for ${item.questionId}',
    );
  }

  RichClosedMatchingAnswer _matchingAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedMatchingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid matching submitted answer for ${item.questionId}',
    );
  }

  RichClosedOrderingAnswer _orderingAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedOrderingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid ordering submitted answer for ${item.questionId}',
    );
  }

  RichClosedTimelineAnswer _timelineAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedTimelineAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid timeline submitted answer for ${item.questionId}',
    );
  }

  RichClosedDateSliderAnswer _dateSliderAnswer(RichClosedCorrectionItem item) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedDateSliderAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid date slider submitted answer for ${item.questionId}',
    );
  }

  RichClosedTrueFalseGridAnswer _trueFalseGridAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedTrueFalseGridAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid true/false submitted answer for ${item.questionId}',
    );
  }

  RichClosedCauseConsequenceAnswer _causeConsequenceAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedCauseConsequenceAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid cause/consequence submitted answer for ${item.questionId}',
    );
  }

  RichClosedInstitutionMatrixAnswer _institutionMatrixAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedInstitutionMatrixAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid institution matrix submitted answer for ${item.questionId}',
    );
  }

  RichClosedDiagramLabelingAnswer _diagramLabelingAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedDiagramLabelingAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid diagram labeling submitted answer for ${item.questionId}',
    );
  }

  RichClosedCalculationMcqAnswer _calculationMcqAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedCalculationMcqAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid calculation submitted answer for ${item.questionId}',
    );
  }

  RichClosedCaseQualificationAnswer _caseQualificationAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedCaseQualificationAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid case qualification submitted answer for ${item.questionId}',
    );
  }

  RichClosedErrorDetectionAnswer _errorDetectionAnswer(
    RichClosedCorrectionItem item,
  ) {
    final answer = item.submittedAnswer;
    if (answer is RichClosedErrorDetectionAnswer) {
      return answer;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid error detection submitted answer for ${item.questionId}',
    );
  }

  RichClosedCorrectChoiceIdCorrection _choiceIdCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectChoiceIdCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid choice correction for ${item.questionId}',
    );
  }

  RichClosedCorrectChoiceIdsCorrection _choiceIdsCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectChoiceIdsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid choices correction for ${item.questionId}',
    );
  }

  RichClosedCorrectPairsCorrection _pairsCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectPairsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid matching correction for ${item.questionId}',
    );
  }

  RichClosedCorrectOrderCorrection _orderCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectOrderCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid ordering correction for ${item.questionId}',
    );
  }

  RichClosedCorrectYearCorrection _yearCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectYearCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid date slider correction for ${item.questionId}',
    );
  }

  RichClosedCorrectTrueFalseValuesCorrection _trueFalseValuesCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectTrueFalseValuesCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid true/false correction for ${item.questionId}',
    );
  }

  RichClosedCorrectCauseConsequencePairsCorrection
  _causeConsequencePairsCorrection(RichClosedCorrectionItem item) {
    final correction = item.correction;
    if (correction is RichClosedCorrectCauseConsequencePairsCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid cause/consequence correction for ${item.questionId}',
    );
  }

  RichClosedCorrectInstitutionMatrixValuesCorrection
  _institutionMatrixValuesCorrection(RichClosedCorrectionItem item) {
    final correction = item.correction;
    if (correction is RichClosedCorrectInstitutionMatrixValuesCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid institution matrix correction for ${item.questionId}',
    );
  }

  RichClosedCorrectDiagramLabelingValuesCorrection
  _diagramLabelingValuesCorrection(RichClosedCorrectionItem item) {
    final correction = item.correction;
    if (correction is RichClosedCorrectDiagramLabelingValuesCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid diagram labeling correction for ${item.questionId}',
    );
  }

  RichClosedCorrectCalculationMcqCorrection _calculationMcqCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectCalculationMcqCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid calculation correction for ${item.questionId}',
    );
  }

  RichClosedCorrectErrorIdCorrection _errorIdCorrection(
    RichClosedCorrectionItem item,
  ) {
    final correction = item.correction;
    if (correction is RichClosedCorrectErrorIdCorrection) {
      return correction;
    }
    throw RichClosedCorrectionPresentationException(
      'Invalid error detection correction for ${item.questionId}',
    );
  }

  String _timelineEventLabel(
    List<RichClosedTimelineEvent> events,
    String eventId,
    String questionId,
  ) {
    for (final event in events) {
      if (event.id == eventId) {
        return event.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown timeline event $eventId for question $questionId',
    );
  }

  String _choiceLabel(
    List<RichClosedChoice> choices,
    String choiceId,
    String questionId,
  ) {
    for (final choice in choices) {
      if (choice.id == choiceId) {
        return choice.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown choice $choiceId for question $questionId',
    );
  }

  String _calculationChoiceLabel(
    List<RichClosedCalculationChoice> choices,
    String choiceId,
    String questionId,
  ) {
    for (final choice in choices) {
      if (choice.id == choiceId) {
        return choice.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown calculation choice $choiceId for question $questionId',
    );
  }

  String _causeConsequenceItemLabel(
    List<RichClosedCauseConsequenceItem> items,
    String itemId,
    String questionId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown cause/consequence item $itemId for question $questionId',
    );
  }

  String _institutionMatrixAxisLabel(
    List<RichClosedInstitutionMatrixAxisItem> items,
    String itemId,
    String questionId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown institution matrix axis $itemId for question $questionId',
    );
  }

  RichClosedInstitutionMatrixCell _institutionMatrixCell(
    RichClosedInstitutionMatrixQuestion question,
    String cellId,
  ) {
    for (final cell in question.cells) {
      if (cell.id == cellId) {
        return cell;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown institution matrix cell $cellId for question ${question.id}',
    );
  }

  RichClosedDiagramLabelingSlot _diagramLabelingSlot(
    RichClosedDiagramLabelingQuestion question,
    String slotId,
  ) {
    for (final slot in question.slots) {
      if (slot.id == slotId) {
        return slot;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown diagram labeling slot $slotId for question ${question.id}',
    );
  }

  RichClosedDiagramNode _diagramNode(
    RichClosedDiagramLabelingQuestion question,
    String nodeId,
  ) {
    for (final node in question.diagram.nodes) {
      if (node.id == nodeId) {
        return node;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown diagram node $nodeId for question ${question.id}',
    );
  }

  RichClosedDiagramEdge _diagramEdge(
    RichClosedDiagramLabelingQuestion question,
    String edgeId,
  ) {
    for (final edge in question.diagram.edges) {
      if (edge.id == edgeId) {
        return edge;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown diagram edge $edgeId for question ${question.id}',
    );
  }

  String _labelItem(
    List<RichClosedLabelItem> items,
    String itemId,
    String questionId,
  ) {
    for (final item in items) {
      if (item.id == itemId) {
        return item.label;
      }
    }
    throw RichClosedCorrectionPresentationException(
      'Unknown item $itemId for question $questionId',
    );
  }

  List<String> _matchingLines(
    RichClosedMatchingQuestion question,
    List<RichClosedPair> pairs,
  ) {
    return [
      for (final pair in pairs)
        '${_labelItem(question.leftItems, pair.leftId, question.id)} → '
            '${_labelItem(question.rightItems, pair.rightId, question.id)}',
    ];
  }

  List<String> _orderedLines(
    RichClosedOrderingQuestion question,
    List<String> orderedIds,
  ) {
    return [
      for (var index = 0; index < orderedIds.length; index += 1)
        '${index + 1}. ${_labelItem(question.items, orderedIds[index], question.id)}',
    ];
  }

  List<String> _timelineLines(
    RichClosedTimelineQuestion question,
    List<String> orderedEventIds,
  ) {
    return [
      for (var index = 0; index < orderedEventIds.length; index += 1)
        '${index + 1}. ${_timelineEventLabel(question.events, orderedEventIds[index], question.id)}',
    ];
  }

  List<String> _trueFalseLines(
    RichClosedTrueFalseGridQuestion question,
    List<RichClosedTrueFalseGridValue> values,
  ) {
    final valuesByRowId = {for (final value in values) value.rowId: value};

    return [
      for (final row in question.rows)
        '${row.statement} : ${_booleanLabel(valuesByRowId[row.id]?.value, question.id, row.id)}',
    ];
  }

  List<String> _causeConsequenceLines(
    RichClosedCauseConsequenceQuestion question,
    List<RichClosedCauseConsequencePair> pairs,
  ) {
    return [
      for (final pair in pairs)
        '${_causeConsequenceItemLabel(question.causes, pair.causeId, question.id)} → '
            '${_causeConsequenceItemLabel(question.consequences, pair.consequenceId, question.id)}',
    ];
  }

  List<String> _institutionMatrixLines(
    RichClosedInstitutionMatrixQuestion question,
    List<RichClosedInstitutionMatrixValue> values,
  ) {
    return [
      for (final value in values) _institutionMatrixLine(question, value),
    ];
  }

  String _institutionMatrixLine(
    RichClosedInstitutionMatrixQuestion question,
    RichClosedInstitutionMatrixValue value,
  ) {
    final cell = _institutionMatrixCell(question, value.cellId);
    final rowLabel = _institutionMatrixAxisLabel(
      question.rows,
      cell.rowId,
      question.id,
    );
    final columnLabel = _institutionMatrixAxisLabel(
      question.columns,
      cell.columnId,
      question.id,
    );
    final optionLabel = _choiceLabel(cell.options, value.optionId, question.id);

    return '$rowLabel / $columnLabel : $optionLabel';
  }

  List<String> _diagramLabelingLines(
    RichClosedDiagramLabelingQuestion question,
    List<RichClosedDiagramLabelingValue> values,
  ) {
    _assertCompleteDiagramLabelingValues(question, values);

    return [for (final value in values) _diagramLabelingLine(question, value)];
  }

  void _assertCompleteDiagramLabelingValues(
    RichClosedDiagramLabelingQuestion question,
    List<RichClosedDiagramLabelingValue> values,
  ) {
    final expectedSlotIds = question.slots.map((slot) => slot.id).toSet();
    final seenSlotIds = <String>{};

    if (values.length != question.slots.length) {
      throw RichClosedCorrectionPresentationException(
        'Incomplete diagram labeling values for question ${question.id}',
      );
    }

    for (final value in values) {
      if (!expectedSlotIds.contains(value.slotId) ||
          !seenSlotIds.add(value.slotId)) {
        throw RichClosedCorrectionPresentationException(
          'Invalid diagram labeling values for question ${question.id}',
        );
      }
    }
  }

  String _diagramLabelingLine(
    RichClosedDiagramLabelingQuestion question,
    RichClosedDiagramLabelingValue value,
  ) {
    final slot = _diagramLabelingSlot(question, value.slotId);
    final anchorLabel = switch (slot.anchorType) {
      RichClosedDiagramAnchorType.node => _diagramNode(
        question,
        slot.anchorId,
      ).label,
      RichClosedDiagramAnchorType.edge => _diagramEdgeLine(
        question,
        _diagramEdge(question, slot.anchorId),
      ),
    };
    final optionLabel = _choiceLabel(slot.options, value.optionId, question.id);

    return '$anchorLabel : $optionLabel';
  }

  String _diagramEdgeLine(
    RichClosedDiagramLabelingQuestion question,
    RichClosedDiagramEdge edge,
  ) {
    final from = _diagramNode(question, edge.fromNodeId).label;
    final to = _diagramNode(question, edge.toNodeId).label;
    final label = edge.label;
    final endpoints = '$from -> $to';

    if (label == null) {
      return endpoints;
    }
    return '$endpoints / $label';
  }

  String _booleanLabel(bool? value, String questionId, String rowId) {
    if (value == null) {
      throw RichClosedCorrectionPresentationException(
        'Missing true/false value $rowId for question $questionId',
      );
    }

    return value ? 'Vrai' : 'Faux';
  }

  String _kindLabel(RichClosedQuestionKind kind) {
    return switch (kind) {
      RichClosedQuestionKind.singleChoice => 'Choix unique',
      RichClosedQuestionKind.multipleChoice => 'Choix multiples',
      RichClosedQuestionKind.matching => 'Association',
      RichClosedQuestionKind.ordering => 'Ordonnancement',
      RichClosedQuestionKind.caseQualification => 'Qualification',
      RichClosedQuestionKind.errorDetection => 'Erreur à repérer',
      RichClosedQuestionKind.timeline => 'Chronologie',
      RichClosedQuestionKind.dateSlider => 'Curseur temporel',
      RichClosedQuestionKind.trueFalseGrid => 'Vrai / faux',
      RichClosedQuestionKind.causeConsequence => 'Cause / conséquence',
      RichClosedQuestionKind.institutionMatrix => 'Matrice',
      RichClosedQuestionKind.diagramLabeling => 'Schéma',
      RichClosedQuestionKind.calculationMcq => 'Calcul',
    };
  }
}

class RichClosedCorrectionViewModel {
  const RichClosedCorrectionViewModel({
    required this.summary,
    required this.items,
  });

  final RichClosedResultSummaryViewModel summary;
  final List<RichClosedCorrectionItemViewModel> items;
}

class RichClosedResultSummaryViewModel {
  const RichClosedResultSummaryViewModel({
    required this.sessionId,
    required this.status,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
  });

  final String sessionId;
  final String status;
  final int correctAnswers;
  final int totalQuestions;
  final double score;

  String get scoreLabel => score.toString();
  String get answerRatioLabel => '$correctAnswers / $totalQuestions';

  String get message {
    if (score >= 0.85) {
      return 'Excellent résultat.';
    }
    if (score >= 0.6) {
      return 'Solide, avec quelques points à consolider.';
    }
    return 'À retravailler en priorité.';
  }
}

class RichClosedCorrectionItemViewModel {
  const RichClosedCorrectionItemViewModel({
    required this.questionId,
    required this.questionKind,
    required this.kindLabel,
    required this.prompt,
    required this.contextText,
    required this.isCorrect,
    required this.partialScore,
    required this.explanation,
    required this.sourceLabels,
    required this.submittedAnswerLines,
    required this.correctAnswerLines,
  });

  final String questionId;
  final RichClosedQuestionKind questionKind;
  final String kindLabel;
  final String prompt;
  final String? contextText;
  final bool isCorrect;
  final double partialScore;
  final String explanation;
  final List<String> sourceLabels;
  final List<String> submittedAnswerLines;
  final List<String> correctAnswerLines;

  String get statusLabel => isCorrect ? 'Correct' : 'Incorrect';
  String get partialScoreLabel => partialScore.toString();
}

~~~

### lib/features/activities/presentation/rich_closed/rich_closed_question_card.dart

~~~text
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RichClosedQuestionCard extends StatelessWidget {
  const RichClosedQuestionCard({
    required this.question,
    required this.children,
    this.leading,
    super.key,
  });

  final RichClosedQuestion question;
  final Widget? leading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RevisionStatusPill(
                label: _kindLabel(question.questionKind),
                color: colorScheme.primary,
                icon: Icons.checklist_rtl,
              ),
              RevisionStatusPill(
                label: _difficultyLabel(question.difficulty),
                color: colorScheme.tertiary,
              ),
              RevisionStatusPill(
                label: _cognitiveSkillLabel(question.cognitiveSkill),
                color: colorScheme.secondary,
              ),
              if (question.sourceChunkIds.isNotEmpty)
                RevisionStatusPill(
                  label: '${question.sourceChunkIds.length} source(s)',
                  color: colorScheme.secondary,
                  icon: Icons.source_outlined,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (leading != null) ...[
            const SizedBox(height: AppSpacing.m),
            leading!,
          ],
          const SizedBox(height: AppSpacing.m),
          ...children,
        ],
      ),
    );
  }

  String _kindLabel(RichClosedQuestionKind kind) {
    return switch (kind) {
      RichClosedQuestionKind.singleChoice => 'Choix unique',
      RichClosedQuestionKind.multipleChoice => 'Choix multiples',
      RichClosedQuestionKind.matching => 'Association',
      RichClosedQuestionKind.ordering => 'Ordonnancement',
      RichClosedQuestionKind.caseQualification => 'Qualification',
      RichClosedQuestionKind.errorDetection => 'Erreur à repérer',
      RichClosedQuestionKind.timeline => 'Chronologie',
      RichClosedQuestionKind.dateSlider => 'Curseur temporel',
      RichClosedQuestionKind.trueFalseGrid => 'Vrai / faux',
      RichClosedQuestionKind.causeConsequence => 'Cause / conséquence',
      RichClosedQuestionKind.institutionMatrix => 'Matrice',
      RichClosedQuestionKind.diagramLabeling => 'Schéma',
      RichClosedQuestionKind.calculationMcq => 'Calcul',
    };
  }

  String _difficultyLabel(RichClosedDifficulty difficulty) {
    return switch (difficulty) {
      RichClosedDifficulty.low => 'Facile',
      RichClosedDifficulty.medium => 'Intermédiaire',
      RichClosedDifficulty.high => 'Avancé',
    };
  }

  String _cognitiveSkillLabel(RichClosedCognitiveSkill skill) {
    return switch (skill) {
      RichClosedCognitiveSkill.memorization => 'Mémorisation',
      RichClosedCognitiveSkill.comprehension => 'Compréhension',
      RichClosedCognitiveSkill.comparison => 'Comparaison',
      RichClosedCognitiveSkill.classification => 'Classification',
      RichClosedCognitiveSkill.caseApplication => 'Cas pratique',
      RichClosedCognitiveSkill.procedure => 'Procédure',
      RichClosedCognitiveSkill.errorDetection => 'Détection d’erreur',
      RichClosedCognitiveSkill.causality => 'Causalité',
    };
  }
}

~~~

### lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart

~~~text
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_calculation_mcq_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_cause_consequence_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_date_slider_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_diagram_labeling_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_institution_matrix_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_matching_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_multiple_choice_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_ordering_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_single_choice_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_timeline_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_true_false_grid_widget.dart';

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
      RichClosedTimelineQuestion() => RichClosedTimelineWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedDateSliderQuestion() => RichClosedDateSliderWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedTrueFalseGridQuestion() => RichClosedTrueFalseGridWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedCauseConsequenceQuestion() => RichClosedCauseConsequenceWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedInstitutionMatrixQuestion() =>
        RichClosedInstitutionMatrixWidget(
          question: currentQuestion,
          controller: controller,
          enabled: enabled,
          onAnswerChanged: onChanged,
        ),
      RichClosedDiagramLabelingQuestion() => RichClosedDiagramLabelingWidget(
        question: currentQuestion,
        controller: controller,
        enabled: enabled,
        onAnswerChanged: onChanged,
      ),
      RichClosedCalculationMcqQuestion() => RichClosedCalculationMcqWidget(
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

~~~

### test/features/activities/fixtures/rich_closed_exercise_fixtures.dart

~~~text
Map<String, Object?> richClosedExerciseJson() {
  return {
    'sessionId': 'rich-session-1',
    'type': 'rich_closed_exercise',
    'id': 'exercise-1',
    'version': 'rich-closed-question-v1',
    'title': 'Exercice institutions politiques',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnitId': 'unit-1',
    'questions': [
      {
        'id': 'single-1',
        'questionKind': 'single_choice',
        'prompt': 'Quel critère caractérise un régime parlementaire ?',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'classification',
        'sourceChunkIds': ['chunk-1'],
        'choices': [
          {'id': 'choice-a', 'label': 'Responsabilité politique'},
          {'id': 'choice-b', 'label': 'Séparation étanche'},
          {'id': 'choice-c', 'label': 'Confédération'},
        ],
      },
      {
        'id': 'multiple-1',
        'questionKind': 'multiple_choice',
        'prompt': 'Quels indices orientent vers un régime parlementaire ?',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'comparison',
        'sourceChunkIds': ['chunk-1', 'chunk-2'],
        'choices': [
          {'id': 'choice-a', 'label': 'Responsabilité du gouvernement'},
          {'id': 'choice-b', 'label': 'Collaboration des pouvoirs'},
          {'id': 'choice-c', 'label': 'Indépendance absolue'},
          {'id': 'choice-d', 'label': 'Absence de Parlement'},
        ],
        'minSelections': 2,
        'maxSelections': 2,
      },
      {
        'id': 'matching-1',
        'questionKind': 'matching',
        'prompt': 'Associe chaque mécanisme à sa fonction.',
        'difficulty': 'HIGH',
        'cognitiveSkill': 'comparison',
        'sourceChunkIds': ['chunk-2'],
        'leftItems': [
          {'id': 'left-1', 'label': 'Motion de censure'},
          {'id': 'left-2', 'label': 'Dissolution'},
          {'id': 'left-3', 'label': 'Contrôle constitutionnel'},
        ],
        'rightItems': [
          {'id': 'right-1', 'label': 'Responsabilité politique'},
          {'id': 'right-2', 'label': 'Fin anticipée d’une chambre'},
          {'id': 'right-3', 'label': 'Vérification d’une norme'},
        ],
      },
      {
        'id': 'ordering-1',
        'questionKind': 'ordering',
        'prompt': 'Ordonne les étapes du raisonnement.',
        'difficulty': 'LOW',
        'cognitiveSkill': 'procedure',
        'sourceChunkIds': ['chunk-3'],
        'items': [
          {'id': 'item-1', 'label': 'Repérer les organes'},
          {'id': 'item-2', 'label': 'Analyser les moyens d’action'},
          {'id': 'item-3', 'label': 'Qualifier le régime'},
        ],
      },
      {
        'id': 'case-1',
        'questionKind': 'case_qualification',
        'prompt': 'Choisis la qualification la plus pertinente.',
        'difficulty': 'HIGH',
        'cognitiveSkill': 'case_application',
        'sourceChunkIds': ['chunk-4'],
        'caseText':
            'Un gouvernement doit conserver la confiance d’une chambre élue.',
        'choices': [
          {'id': 'choice-a', 'label': 'Régime parlementaire'},
          {'id': 'choice-b', 'label': 'Régime présidentiel'},
          {'id': 'choice-c', 'label': 'Confédération'},
        ],
      },
      {
        'id': 'error-1',
        'questionKind': 'error_detection',
        'prompt': 'Repère l’erreur dominante.',
        'difficulty': 'MEDIUM',
        'cognitiveSkill': 'error_detection',
        'sourceChunkIds': ['chunk-5'],
        'statement':
            'Un régime présidentiel se définit par la responsabilité politique du gouvernement devant le Parlement.',
        'errorOptions': [
          {'id': 'error-a', 'label': 'Confusion avec le parlementarisme'},
          {'id': 'error-b', 'label': 'Confusion avec l’État fédéral'},
          {
            'id': 'error-c',
            'label': 'Confusion avec le contrôle juridictionnel',
          },
        ],
      },
    ],
  };
}

Map<String, Object?> richClosedResultJson() {
  return {
    'sessionId': 'rich-session-1',
    'type': 'rich_closed_exercise',
    'status': 'completed',
    'correctAnswers': 5,
    'totalQuestions': 6,
    'score': 0.833,
    'items': [
      {
        'questionId': 'single-1',
        'questionKind': 'single_choice',
        'prompt': 'Quel critère caractérise un régime parlementaire ?',
        'submittedAnswer': {
          'questionId': 'single-1',
          'questionKind': 'single_choice',
          'choiceId': 'choice-a',
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La responsabilité politique est centrale.',
        'sourceChunkIds': ['chunk-1'],
        'correction': {'correctChoiceId': 'choice-a'},
      },
      {
        'questionId': 'multiple-1',
        'questionKind': 'multiple_choice',
        'prompt': 'Quels indices orientent vers un régime parlementaire ?',
        'submittedAnswer': {
          'questionId': 'multiple-1',
          'questionKind': 'multiple_choice',
          'choiceIds': ['choice-a', 'choice-b'],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'Responsabilité et collaboration sont attendues.',
        'sourceChunkIds': ['chunk-1', 'chunk-2'],
        'correction': {
          'correctChoiceIds': ['choice-a', 'choice-b'],
        },
      },
      {
        'questionId': 'matching-1',
        'questionKind': 'matching',
        'prompt': 'Associe chaque mécanisme à sa fonction.',
        'submittedAnswer': {
          'questionId': 'matching-1',
          'questionKind': 'matching',
          'pairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
            {'leftId': 'left-2', 'rightId': 'right-2'},
            {'leftId': 'left-3', 'rightId': 'right-3'},
          ],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'Chaque mécanisme renvoie à sa fonction.',
        'sourceChunkIds': ['chunk-2'],
        'correction': {
          'correctPairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
            {'leftId': 'left-2', 'rightId': 'right-2'},
            {'leftId': 'left-3', 'rightId': 'right-3'},
          ],
        },
      },
      {
        'questionId': 'ordering-1',
        'questionKind': 'ordering',
        'prompt': 'Ordonne les étapes du raisonnement.',
        'submittedAnswer': {
          'questionId': 'ordering-1',
          'questionKind': 'ordering',
          'orderedIds': ['item-1', 'item-2', 'item-3'],
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La qualification vient après l’analyse.',
        'sourceChunkIds': ['chunk-3'],
        'correction': {
          'correctOrder': ['item-1', 'item-2', 'item-3'],
        },
      },
      {
        'questionId': 'case-1',
        'questionKind': 'case_qualification',
        'prompt': 'Choisis la qualification la plus pertinente.',
        'submittedAnswer': {
          'questionId': 'case-1',
          'questionKind': 'case_qualification',
          'choiceId': 'choice-a',
        },
        'isCorrect': true,
        'partialScore': 1,
        'explanation': 'La confiance parlementaire qualifie le régime.',
        'sourceChunkIds': ['chunk-4'],
        'correction': {'correctChoiceId': 'choice-a'},
      },
      {
        'questionId': 'error-1',
        'questionKind': 'error_detection',
        'prompt': 'Repère l’erreur dominante.',
        'submittedAnswer': {
          'questionId': 'error-1',
          'questionKind': 'error_detection',
          'errorId': 'error-b',
        },
        'isCorrect': false,
        'partialScore': 0,
        'explanation': 'L’erreur dominante est la confusion de régime.',
        'sourceChunkIds': ['chunk-5'],
        'correction': {'correctErrorId': 'error-a'},
      },
    ],
  };
}

Map<String, Object?> richClosedV1BExerciseJson() {
  final json = richClosedExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.addAll([
    {
      'id': 'timeline-1',
      'questionKind': 'timeline',
      'prompt': 'Remets dans l’ordre ces étapes du contrôle parlementaire.',
      'instruction': 'Classe les événements du début vers la fin.',
      'difficulty': 'MEDIUM',
      'cognitiveSkill': 'procedure',
      'sourceChunkIds': ['chunk-6'],
      'events': [
        {
          'id': 'event-1',
          'label': 'Dépôt de la motion',
          'description': 'Des parlementaires engagent la procédure.',
        },
        {
          'id': 'event-2',
          'label': 'Débat politique',
          'description': 'La chambre débat de la responsabilité.',
        },
        {
          'id': 'event-3',
          'label': 'Vote de la chambre',
          'description': 'La chambre adopte ou rejette la motion.',
        },
      ],
    },
    {
      'id': 'date-slider-1',
      'questionKind': 'date_slider',
      'prompt':
          'Place approximativement l’adoption de la Constitution de la Ve République.',
      'instruction': 'Choisis une année entière.',
      'difficulty': 'LOW',
      'cognitiveSkill': 'comprehension',
      'sourceChunkIds': ['chunk-7'],
      'minYear': 1945,
      'maxYear': 1970,
      'step': 1,
      'toleranceYears': 0,
    },
  ]);

  return json;
}

Map<String, Object?> richClosedV1BResultJson() {
  final json = richClosedResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 7;
  json['totalQuestions'] = 8;
  json['score'] = 0.875;
  json['items'] = items;
  items.addAll([
    {
      'questionId': 'timeline-1',
      'questionKind': 'timeline',
      'prompt': 'Remets dans l’ordre ces étapes du contrôle parlementaire.',
      'submittedAnswer': {
        'questionId': 'timeline-1',
        'questionKind': 'timeline',
        'orderedEventIds': ['event-1', 'event-2', 'event-3'],
      },
      'isCorrect': true,
      'partialScore': 1,
      'explanation': 'La procédure suit initiative, débat puis vote.',
      'sourceChunkIds': ['chunk-6'],
      'correction': {
        'correctOrder': ['event-1', 'event-2', 'event-3'],
      },
    },
    {
      'questionId': 'date-slider-1',
      'questionKind': 'date_slider',
      'prompt':
          'Place approximativement l’adoption de la Constitution de la Ve République.',
      'submittedAnswer': {
        'questionId': 'date-slider-1',
        'questionKind': 'date_slider',
        'year': 1960,
      },
      'isCorrect': false,
      'partialScore': 0,
      'explanation': 'La Constitution de la Ve République est adoptée en 1958.',
      'sourceChunkIds': ['chunk-7'],
      'correction': {
        'correctYear': 1958,
        'minAcceptedYear': 1958,
        'maxAcceptedYear': 1958,
      },
    },
  ]);

  return json;
}

Map<String, Object?> richClosedV1BFullExerciseJson() {
  final json = richClosedV1BExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.addAll([
    {
      'id': 'true-false-grid-1',
      'questionKind': 'true_false_grid',
      'prompt':
          'Indique si chaque affirmation sur le régime parlementaire est vraie ou fausse.',
      'instruction': 'Réponds à toutes les lignes.',
      'difficulty': 'MEDIUM',
      'cognitiveSkill': 'classification',
      'sourceChunkIds': ['chunk-8'],
      'rows': [
        {
          'id': 'row-1',
          'statement':
              'Le gouvernement peut être responsable devant le Parlement.',
          'context': 'Critère du régime parlementaire.',
        },
        {
          'id': 'row-2',
          'statement':
              'La séparation des pouvoirs interdit toute collaboration.',
          'context': 'La collaboration est possible en régime parlementaire.',
        },
        {
          'id': 'row-3',
          'statement': 'La dissolution peut être un moyen réciproque.',
          'context': 'Elle peut équilibrer la responsabilité politique.',
        },
      ],
    },
    {
      'id': 'cause-consequence-1',
      'questionKind': 'cause_consequence',
      'prompt':
          'Associe chaque mécanisme institutionnel à sa conséquence politique.',
      'instruction': 'Choisis une conséquence différente pour chaque cause.',
      'difficulty': 'HIGH',
      'cognitiveSkill': 'causality',
      'sourceChunkIds': ['chunk-9'],
      'causes': [
        {
          'id': 'cause-1',
          'label': 'Motion de censure adoptée',
          'description': 'La chambre retire sa confiance.',
        },
        {
          'id': 'cause-2',
          'label': 'Dissolution de l’Assemblée',
          'description': 'Le mandat de la chambre prend fin.',
        },
        {
          'id': 'cause-3',
          'label': 'Question de confiance rejetée',
          'description': 'Le gouvernement engage sa responsabilité.',
        },
      ],
      'consequences': [
        {
          'id': 'consequence-1',
          'label': 'Démission du gouvernement',
          'description': 'La responsabilité politique produit ses effets.',
        },
        {
          'id': 'consequence-2',
          'label': 'Nouvelles élections législatives',
          'description': 'Le corps électoral renouvelle la chambre.',
        },
        {
          'id': 'consequence-3',
          'label': 'Crise politique ou départ du gouvernement',
          'description': 'Le rejet manifeste une perte de confiance.',
        },
      ],
    },
  ]);

  return json;
}

Map<String, Object?> richClosedV1BFullResultJson() {
  final json = richClosedV1BResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 9;
  json['totalQuestions'] = 10;
  json['score'] = 0.9;
  json['items'] = items;
  items.addAll([
    {
      'questionId': 'true-false-grid-1',
      'questionKind': 'true_false_grid',
      'prompt':
          'Indique si chaque affirmation sur le régime parlementaire est vraie ou fausse.',
      'submittedAnswer': {
        'questionId': 'true-false-grid-1',
        'questionKind': 'true_false_grid',
        'values': [
          {'rowId': 'row-1', 'value': true},
          {'rowId': 'row-2', 'value': true},
          {'rowId': 'row-3', 'value': true},
        ],
      },
      'isCorrect': false,
      'partialScore': 0,
      'explanation': 'Le parlementarisme admet la collaboration des pouvoirs.',
      'sourceChunkIds': ['chunk-8'],
      'correction': {
        'correctValues': [
          {'rowId': 'row-1', 'value': true},
          {'rowId': 'row-2', 'value': false},
          {'rowId': 'row-3', 'value': true},
        ],
      },
    },
    {
      'questionId': 'cause-consequence-1',
      'questionKind': 'cause_consequence',
      'prompt':
          'Associe chaque mécanisme institutionnel à sa conséquence politique.',
      'submittedAnswer': {
        'questionId': 'cause-consequence-1',
        'questionKind': 'cause_consequence',
        'pairs': [
          {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
          {'causeId': 'cause-2', 'consequenceId': 'consequence-2'},
          {'causeId': 'cause-3', 'consequenceId': 'consequence-3'},
        ],
      },
      'isCorrect': true,
      'partialScore': 1,
      'explanation':
          'Chaque mécanisme active une conséquence institutionnelle distincte.',
      'sourceChunkIds': ['chunk-9'],
      'correction': {
        'correctPairs': [
          {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
          {'causeId': 'cause-2', 'consequenceId': 'consequence-2'},
          {'causeId': 'cause-3', 'consequenceId': 'consequence-3'},
        ],
      },
    },
  ]);

  return json;
}

Map<String, Object?> richClosedV1CExerciseJson() {
  final json = richClosedV1BFullExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.add({
    'id': 'institution-matrix-1',
    'questionKind': 'institution_matrix',
    'prompt':
        'Complète la matrice comparant Président, Gouvernement et Assemblée nationale.',
    'instruction': 'Choisis une option fermée pour chaque cellule demandée.',
    'difficulty': 'MEDIUM',
    'cognitiveSkill': 'comparison',
    'sourceChunkIds': ['chunk-10'],
    'rows': [
      {
        'id': 'row-president',
        'label': 'Président de la République',
        'description': 'Chef de l’État.',
      },
      {
        'id': 'row-government',
        'label': 'Gouvernement',
        'description': 'Organe chargé de conduire la politique nationale.',
      },
      {
        'id': 'row-assembly',
        'label': 'Assemblée nationale',
        'description': 'Chambre élue au suffrage universel direct.',
      },
    ],
    'columns': [
      {
        'id': 'column-legitimacy',
        'label': 'Mode de légitimité',
        'description': 'Origine politique principale.',
      },
      {
        'id': 'column-action',
        'label': 'Moyen d’action',
        'description': 'Instrument institutionnel caractéristique.',
      },
      {
        'id': 'column-responsibility',
        'label': 'Responsabilité politique',
        'description': 'Lien de responsabilité devant une institution.',
      },
    ],
    'cells': [
      {
        'id': 'cell-president-legitimacy',
        'rowId': 'row-president',
        'columnId': 'column-legitimacy',
        'prompt': 'Quelle légitimité caractérise principalement le Président ?',
        'options': [
          {'id': 'option-legitimacy-election', 'label': 'Élection nationale'},
          {
            'id': 'option-legitimacy-confidence',
            'label': 'Confiance parlementaire',
          },
          {'id': 'option-legitimacy-nomination', 'label': 'Nomination simple'},
        ],
      },
      {
        'id': 'cell-government-responsibility',
        'rowId': 'row-government',
        'columnId': 'column-responsibility',
        'prompt':
            'Devant qui le Gouvernement est-il politiquement responsable ?',
        'options': [
          {
            'id': 'option-responsibility-assembly',
            'label': 'Assemblée nationale',
          },
          {'id': 'option-responsibility-senate', 'label': 'Sénat'},
          {'id': 'option-responsibility-none', 'label': 'Aucune institution'},
        ],
      },
      {
        'id': 'cell-assembly-action',
        'rowId': 'row-assembly',
        'columnId': 'column-action',
        'prompt': 'Quel moyen d’action vise le Gouvernement ?',
        'options': [
          {'id': 'option-action-censure', 'label': 'Motion de censure'},
          {'id': 'option-action-dissolution', 'label': 'Dissolution'},
          {'id': 'option-action-promulgation', 'label': 'Promulgation'},
        ],
      },
    ],
  });

  return json;
}

Map<String, Object?> richClosedV1CResultJson() {
  final json = richClosedV1BFullResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 10;
  json['totalQuestions'] = 11;
  json['score'] = 0.909;
  json['items'] = items;
  items.add({
    'questionId': 'institution-matrix-1',
    'questionKind': 'institution_matrix',
    'prompt':
        'Complète la matrice comparant Président, Gouvernement et Assemblée nationale.',
    'submittedAnswer': {
      'questionId': 'institution-matrix-1',
      'questionKind': 'institution_matrix',
      'values': [
        {
          'cellId': 'cell-president-legitimacy',
          'optionId': 'option-legitimacy-election',
        },
        {
          'cellId': 'cell-government-responsibility',
          'optionId': 'option-responsibility-assembly',
        },
        {'cellId': 'cell-assembly-action', 'optionId': 'option-action-censure'},
      ],
    },
    'isCorrect': true,
    'partialScore': 1,
    'explanation':
        'Chaque cellule associe une institution à une propriété fermée du régime.',
    'sourceChunkIds': ['chunk-10'],
    'correction': {
      'correctValues': [
        {
          'cellId': 'cell-president-legitimacy',
          'optionId': 'option-legitimacy-election',
        },
        {
          'cellId': 'cell-government-responsibility',
          'optionId': 'option-responsibility-assembly',
        },
        {'cellId': 'cell-assembly-action', 'optionId': 'option-action-censure'},
      ],
    },
  });

  return json;
}

Map<String, Object?> richClosedV1CFullExerciseJson() {
  final json = richClosedV1CExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.add({
    'id': 'diagram-labeling-1',
    'questionKind': 'diagram_labeling',
    'prompt':
        'Complète le schéma des rapports institutionnels sous la Ve République.',
    'instruction':
        'Choisis une option fermée pour chaque zone du schéma textuel.',
    'difficulty': 'MEDIUM',
    'cognitiveSkill': 'classification',
    'sourceChunkIds': ['chunk-11'],
    'diagram': {
      'title': 'Rapports institutionnels',
      'description':
          'Schéma textuel borné entre exécutif et Parlement, sans SVG ni HTML.',
      'layout': 'vertical_flow',
      'nodes': [
        {
          'id': 'node-president',
          'label': 'Président de la République',
          'description': 'Chef de l’État.',
          'groupId': 'group-executive',
        },
        {
          'id': 'node-government',
          'label': 'Gouvernement',
          'description': 'Conduit la politique nationale.',
          'groupId': 'group-executive',
        },
        {
          'id': 'node-assembly',
          'label': 'Assemblée nationale',
          'description': 'Chambre politiquement déterminante.',
          'groupId': 'group-parliament',
        },
        {
          'id': 'node-senate',
          'label': 'Sénat',
          'description': 'Chambre représentant les collectivités.',
          'groupId': 'group-parliament',
        },
      ],
      'groups': [
        {'id': 'group-executive', 'label': 'Exécutif'},
        {'id': 'group-parliament', 'label': 'Parlement'},
      ],
      'edges': [
        {
          'id': 'edge-president-government',
          'fromNodeId': 'node-president',
          'toNodeId': 'node-government',
          'label': 'nomme',
          'description': 'Nomination du Premier ministre.',
        },
        {
          'id': 'edge-government-assembly',
          'fromNodeId': 'node-government',
          'toNodeId': 'node-assembly',
          'label': 'responsable devant',
          'description': 'Responsabilité politique.',
        },
        {
          'id': 'edge-assembly-government',
          'fromNodeId': 'node-assembly',
          'toNodeId': 'node-government',
          'label': 'contrôle',
          'description': 'Contrôle parlementaire.',
        },
      ],
    },
    'slots': [
      {
        'id': 'slot-government-role',
        'anchorType': 'node',
        'anchorId': 'node-government',
        'prompt': 'Quel organe conduit la politique nationale ?',
        'options': [
          {'id': 'option-government', 'label': 'Gouvernement'},
          {'id': 'option-president', 'label': 'Président'},
          {'id': 'option-senate', 'label': 'Sénat'},
        ],
      },
      {
        'id': 'slot-censure',
        'anchorType': 'edge',
        'anchorId': 'edge-assembly-government',
        'prompt': 'Quel mécanisme illustre le contrôle parlementaire ?',
        'options': [
          {'id': 'option-motion-censure', 'label': 'Motion de censure'},
          {'id': 'option-referendum', 'label': 'Référendum'},
          {'id': 'option-promulgation', 'label': 'Promulgation'},
        ],
      },
      {
        'id': 'slot-nomination',
        'anchorType': 'edge',
        'anchorId': 'edge-president-government',
        'prompt': 'Quelle relation relie le Président au Gouvernement ?',
        'options': [
          {'id': 'option-nomination', 'label': 'Nomination'},
          {'id': 'option-censure', 'label': 'Censure'},
          {'id': 'option-election', 'label': 'Élection parlementaire'},
        ],
      },
    ],
  });

  return json;
}

Map<String, Object?> richClosedV1CFullResultJson() {
  final json = richClosedV1CResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 11;
  json['totalQuestions'] = 12;
  json['score'] = 0.917;
  json['items'] = items;
  items.add({
    'questionId': 'diagram-labeling-1',
    'questionKind': 'diagram_labeling',
    'prompt':
        'Complète le schéma des rapports institutionnels sous la Ve République.',
    'submittedAnswer': {
      'questionId': 'diagram-labeling-1',
      'questionKind': 'diagram_labeling',
      'values': [
        {'slotId': 'slot-government-role', 'optionId': 'option-government'},
        {'slotId': 'slot-censure', 'optionId': 'option-motion-censure'},
        {'slotId': 'slot-nomination', 'optionId': 'option-nomination'},
      ],
    },
    'isCorrect': true,
    'partialScore': 1,
    'explanation':
        'Le schéma relie des organes et mécanismes institutionnels fermés.',
    'sourceChunkIds': ['chunk-11'],
    'correction': {
      'correctValues': [
        {'slotId': 'slot-government-role', 'optionId': 'option-government'},
        {'slotId': 'slot-censure', 'optionId': 'option-motion-censure'},
        {'slotId': 'slot-nomination', 'optionId': 'option-nomination'},
      ],
    },
  });

  return json;
}

Map<String, Object?> richClosedV1CCalculationExerciseJson() {
  final json = richClosedV1CFullExerciseJson();
  final questions = List<Object?>.from(json['questions']! as List<Object?>);
  json['questions'] = questions;

  questions.add({
    'id': 'calculation-mcq-majority-1',
    'questionKind': 'calculation_mcq',
    'prompt': 'Calcule le seuil de majorité absolue.',
    'instruction': 'Choisis le résultat entier parmi les options proposées.',
    'difficulty': 'MEDIUM',
    'cognitiveSkill': 'procedure',
    'sourceChunkIds': ['chunk-12'],
    'scenario':
        'Une assemblée compte 577 suffrages exprimés pour une décision.',
    'calculation': {'mode': 'absolute_majority_threshold', 'validVotes': 577},
    'choices': [
      {'id': 'choice-288', 'label': '288 voix', 'value': 288},
      {'id': 'choice-289', 'label': '289 voix', 'value': 289},
      {'id': 'choice-290', 'label': '290 voix', 'value': 290},
    ],
  });

  return json;
}

Map<String, Object?> richClosedV1CCalculationResultJson() {
  final json = richClosedV1CFullResultJson();
  final items = List<Object?>.from(json['items']! as List<Object?>);

  json['correctAnswers'] = 12;
  json['totalQuestions'] = 13;
  json['score'] = 0.923;
  json['items'] = items;
  items.add({
    'questionId': 'calculation-mcq-majority-1',
    'questionKind': 'calculation_mcq',
    'prompt': 'Calcule le seuil de majorité absolue.',
    'submittedAnswer': {
      'questionId': 'calculation-mcq-majority-1',
      'questionKind': 'calculation_mcq',
      'choiceId': 'choice-289',
    },
    'isCorrect': true,
    'partialScore': 1,
    'explanation':
        'La majorité absolue correspond à la moitié des suffrages exprimés, arrondie à l’entier inférieur, puis augmentée d’une voix.',
    'sourceChunkIds': ['chunk-12'],
    'correction': {
      'correctChoiceId': 'choice-289',
      'expectedValue': 289,
      'workedSteps': [
        {
          'id': 'valid-votes',
          'label': 'Suffrages exprimés',
          'detail': 'Suffrages exprimés : 577.',
          'value': 577,
        },
        {
          'id': 'majority-rule',
          'label': 'Majorité absolue',
          'detail': 'Prendre la partie entière de 577 / 2, puis ajouter 1.',
        },
        {
          'id': 'threshold',
          'label': 'Seuil attendu',
          'detail': 'Seuil attendu : 289.',
          'value': 289,
        },
      ],
    },
  });

  return json;
}

Map<String, Object?> richClosedCalculationLargestRemainderQuestionJson() {
  return {
    'id': 'calculation-mcq-remainder-1',
    'questionKind': 'calculation_mcq',
    'prompt': 'Calcule les sièges obtenus par le parti A.',
    'instruction':
        'Utilise les données fournies, puis choisis le résultat entier.',
    'difficulty': 'HIGH',
    'cognitiveSkill': 'procedure',
    'sourceChunkIds': ['chunk-13'],
    'scenario':
        'Quatre partis se répartissent 10 sièges selon le plus fort reste.',
    'calculation': {
      'mode': 'largest_remainder_target_party_seats',
      'totalSeats': 10,
      'targetPartyId': 'party-a',
      'parties': [
        {'id': 'party-a', 'label': 'Parti A', 'votes': 4300},
        {'id': 'party-b', 'label': 'Parti B', 'votes': 3100},
        {'id': 'party-c', 'label': 'Parti C', 'votes': 1600},
        {'id': 'party-d', 'label': 'Parti D', 'votes': 1000},
      ],
    },
    'choices': [
      {'id': 'choice-3', 'label': '3 sièges', 'value': 3},
      {'id': 'choice-4', 'label': '4 sièges', 'value': 4},
      {'id': 'choice-5', 'label': '5 sièges', 'value': 5},
    ],
  };
}

Map<String, Object?> richClosedExerciseWithCorrectChoiceLeak() {
  final json = richClosedExerciseJson();
  ((json['questions']! as List<Object?>).first!
          as Map<String, Object?>)['correctChoiceId'] =
      'choice-a';
  return json;
}

Map<String, Object?> richClosedExerciseWithFeedbackLeak() {
  final json = richClosedExerciseJson();
  final question =
      (json['questions']! as List<Object?>).first! as Map<String, Object?>;
  final choice =
      (question['choices']! as List<Object?>).first! as Map<String, Object?>;
  choice['feedback'] = 'Ne doit pas être présent en pré-submit.';
  return json;
}

Map<String, Object?> richClosedExerciseWithUnknownKind() {
  final json = richClosedExerciseJson();
  ((json['questions']! as List<Object?>).first!
          as Map<String, Object?>)['questionKind'] =
      'image_choice';
  return json;
}

Map<String, Object?> richClosedResultWithIncoherentCorrection() {
  final json = richClosedResultJson();
  final item = (json['items']! as List<Object?>).first! as Map<String, Object?>;
  item['correction'] = {
    'correctOrder': ['item-1', 'item-2'],
  };
  return json;
}

~~~

### test/features/activities/rich_closed_answer_controller_test.dart

~~~text
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
  });

  test('single choice remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');
    controller.selectSingleChoice(question: question, choiceId: 'choice-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedSingleChoiceAnswer>());
    expect((answer! as RichClosedSingleChoiceAnswer).choiceId, 'choice-b');
  });

  test('case qualification remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedCaseQualificationQuestion>(exercise);

    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-a',
    );
    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-b',
    );

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedCaseQualificationAnswer>());
    expect((answer! as RichClosedCaseQualificationAnswer).choiceId, 'choice-b');
  });

  test('error detection remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectErrorDetection(question: question, errorId: 'error-a');
    controller.selectErrorDetection(question: question, errorId: 'error-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedErrorDetectionAnswer>());
    expect((answer! as RichClosedErrorDetectionAnswer).errorId, 'error-b');
  });

  test('multiple choice toggle ajoute et enlève', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    expect(controller.selectedChoiceIdsFor(question), ['choice-b']);
  });

  test('multiple choice ne dépasse pas maxSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-c');

    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);
    expect(controller.message, contains('2 réponses au maximum'));
  });

  test('multiple choice canSubmit est faux sous minSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');

    expect(controller.canSubmitQuestion(question), isFalse);
    expect(controller.answerFor(question), isNull);
  });

  test(
    'multiple choice canSubmit est vrai quand les bornes sont respectées',
    () {
      final controller = RichClosedCoreAnswerController();
      final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

      controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
      controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');

      final answer = controller.answerFor(question);
      expect(controller.canSubmitQuestion(question), isTrue);
      expect(answer, isA<RichClosedMultipleChoiceAnswer>());
      expect((answer! as RichClosedMultipleChoiceAnswer).choiceIds, [
        'choice-a',
        'choice-b',
      ]);
    },
  );

  test('produit les quatre réponses V1-010', () {
    final controller = RichClosedCoreAnswerController();
    final single = _question<RichClosedSingleChoiceQuestion>(exercise);
    final multiple = _question<RichClosedMultipleChoiceQuestion>(exercise);
    final caseQuestion = _question<RichClosedCaseQualificationQuestion>(
      exercise,
    );
    final error = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectSingleChoice(question: single, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-b');
    controller.selectCaseQualification(
      question: caseQuestion,
      choiceId: 'choice-a',
    );
    controller.selectErrorDetection(question: error, errorId: 'error-a');

    expect(controller.answerFor(single), isA<RichClosedSingleChoiceAnswer>());
    expect(
      controller.answerFor(multiple),
      isA<RichClosedMultipleChoiceAnswer>(),
    );
    expect(
      controller.answerFor(caseQuestion),
      isA<RichClosedCaseQualificationAnswer>(),
    );
    expect(controller.answerFor(error), isA<RichClosedErrorDetectionAnswer>());
  });

  test(
    'matching commence incomplet et devient submitable une fois complet',
    () {
      final controller = RichClosedCoreAnswerController();
      final matching = _question<RichClosedMatchingQuestion>(exercise);

      expect(controller.canSubmitQuestion(matching), isFalse);
      expect(controller.answerFor(matching), isNull);

      controller.setMatchingPair(
        question: matching,
        leftId: 'left-1',
        rightId: 'right-1',
      );

      expect(controller.selectedRightIdFor(matching.id, 'left-1'), 'right-1');
      expect(controller.answerFor(matching), isNull);

      controller.setMatchingPair(
        question: matching,
        leftId: 'left-2',
        rightId: 'right-2',
      );
      controller.setMatchingPair(
        question: matching,
        leftId: 'left-3',
        rightId: 'right-3',
      );

      final answer = controller.answerFor(matching);
      expect(controller.canSubmitQuestion(matching), isTrue);
      expect(answer, isA<RichClosedMatchingAnswer>());
      final matchingAnswer = answer! as RichClosedMatchingAnswer;
      expect(matchingAnswer.pairs.map((pair) => pair.leftId), [
        'left-1',
        'left-2',
        'left-3',
      ]);
      expect(matchingAnswer.pairs.map((pair) => pair.rightId), [
        'right-1',
        'right-2',
        'right-3',
      ]);
    },
  );

  test('matching garantit unicité des rightIds', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-1',
    );

    expect(controller.selectedRightIdFor(matching.id, 'left-1'), isNull);
    expect(controller.selectedRightIdFor(matching.id, 'left-2'), 'right-1');
    expect(controller.canSubmitQuestion(matching), isFalse);
  });

  test('matching ignore les IDs inconnus sans casser l’état', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-unknown',
      rightId: 'right-2',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-unknown',
    );

    expect(controller.matchingPairsFor(matching).single.leftId, 'left-1');
    expect(controller.matchingPairsFor(matching).single.rightId, 'right-1');
  });

  test('ordering retourne l’ordre initial complet', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
    expect(controller.canSubmitQuestion(ordering), isTrue);
  });

  test('ordering move down et move up déplacent les items', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemDown(question: ordering, itemId: 'item-1');
    expect(controller.orderedIdsFor(ordering), ['item-2', 'item-1', 'item-3']);

    controller.moveOrderingItemUp(question: ordering, itemId: 'item-1');
    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
  });

  test('ordering ignore les déplacements impossibles ou inconnus', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemUp(question: ordering, itemId: 'item-1');
    controller.moveOrderingItemDown(question: ordering, itemId: 'item-3');
    controller.moveOrderingItemDown(question: ordering, itemId: 'item-unknown');

    expect(controller.orderedIdsFor(ordering), ['item-1', 'item-2', 'item-3']);
  });

  test('ordering produit une answer complète sans doublons', () {
    final controller = RichClosedCoreAnswerController();
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.moveOrderingItemDown(question: ordering, itemId: 'item-1');

    final answer = controller.answerFor(ordering);
    expect(answer, isA<RichClosedOrderingAnswer>());
    final orderingAnswer = answer! as RichClosedOrderingAnswer;
    expect(orderingAnswer.orderedIds, ['item-2', 'item-1', 'item-3']);
    expect(
      orderingAnswer.orderedIds.toSet().length,
      orderingAnswer.orderedIds.length,
    );
  });

  test('timeline retourne l’ordre initial complet', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);

    expect(controller.orderedEventIdsFor(timeline), [
      'event-1',
      'event-2',
      'event-3',
    ]);
    expect(controller.canSubmitQuestion(timeline), isTrue);
  });

  test('timeline move down et move up déplacent les événements', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);

    controller.moveTimelineEventDown(question: timeline, eventId: 'event-1');
    expect(controller.orderedEventIdsFor(timeline), [
      'event-2',
      'event-1',
      'event-3',
    ]);

    controller.moveTimelineEventUp(question: timeline, eventId: 'event-1');
    expect(controller.orderedEventIdsFor(timeline), [
      'event-1',
      'event-2',
      'event-3',
    ]);
  });

  test('timeline produit une answer orderedEventIds complète', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);

    controller.moveTimelineEventDown(question: timeline, eventId: 'event-1');

    final answer = controller.answerFor(timeline);
    expect(answer, isA<RichClosedTimelineAnswer>());
    expect((answer! as RichClosedTimelineAnswer).orderedEventIds, [
      'event-2',
      'event-1',
      'event-3',
    ]);
  });

  test('date slider produit une année initiale puis mise à jour', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final dateSlider = _question<RichClosedDateSliderQuestion>(v1bExercise);

    expect(controller.canSubmitQuestion(dateSlider), isTrue);
    expect(controller.selectedYearFor(dateSlider), 1958);

    controller.setDateSliderYear(question: dateSlider, year: 1960);

    final answer = controller.answerFor(dateSlider);
    expect(answer, isA<RichClosedDateSliderAnswer>());
    expect((answer! as RichClosedDateSliderAnswer).year, 1960);
  });

  test('true_false_grid commence incomplet puis produit values', () {
    final controller = RichClosedCoreAnswerController();
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final trueFalse = _question<RichClosedTrueFalseGridQuestion>(
      v1bFullExercise,
    );

    expect(controller.canSubmitQuestion(trueFalse), isFalse);
    expect(controller.answerFor(trueFalse), isNull);

    controller.setTrueFalseValue(
      question: trueFalse,
      rowId: 'row-1',
      value: true,
    );
    controller.setTrueFalseValue(
      question: trueFalse,
      rowId: 'row-2',
      value: false,
    );

    expect(controller.canSubmitQuestion(trueFalse), isFalse);

    controller.setTrueFalseValue(
      question: trueFalse,
      rowId: 'row-3',
      value: true,
    );

    final answer = controller.answerFor(trueFalse);
    expect(answer, isA<RichClosedTrueFalseGridAnswer>());
    expect(
      (answer! as RichClosedTrueFalseGridAnswer).values.map(
        (value) => '${value.rowId}:${value.value}',
      ),
      ['row-1:true', 'row-2:false', 'row-3:true'],
    );
  });

  test('cause_consequence commence incomplet et remplace les doublons', () {
    final controller = RichClosedCoreAnswerController();
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final causeConsequence = _question<RichClosedCauseConsequenceQuestion>(
      v1bFullExercise,
    );

    expect(controller.canSubmitQuestion(causeConsequence), isFalse);
    expect(controller.answerFor(causeConsequence), isNull);

    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-1',
      consequenceId: 'consequence-1',
    );
    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-2',
      consequenceId: 'consequence-1',
    );

    expect(
      controller.selectedConsequenceIdFor(causeConsequence.id, 'cause-1'),
      isNull,
    );
    expect(
      controller.selectedConsequenceIdFor(causeConsequence.id, 'cause-2'),
      'consequence-1',
    );
    expect(controller.canSubmitQuestion(causeConsequence), isFalse);

    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-1',
      consequenceId: 'consequence-2',
    );
    controller.setCauseConsequencePair(
      question: causeConsequence,
      causeId: 'cause-3',
      consequenceId: 'consequence-3',
    );

    final answer = controller.answerFor(causeConsequence);
    expect(answer, isA<RichClosedCauseConsequenceAnswer>());
    expect(
      (answer! as RichClosedCauseConsequenceAnswer).pairs.map(
        (pair) => '${pair.causeId}:${pair.consequenceId}',
      ),
      [
        'cause-1:consequence-2',
        'cause-2:consequence-1',
        'cause-3:consequence-3',
      ],
    );
  });

  test('institution_matrix commence incomplet puis produit values', () {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final matrix = _question<RichClosedInstitutionMatrixQuestion>(v1cExercise);

    expect(controller.canSubmitQuestion(matrix), isFalse);
    expect(controller.answerFor(matrix), isNull);
    expect(controller.institutionMatrixValuesFor(matrix), isEmpty);

    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-legitimacy-election',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-government-responsibility',
      optionId: 'option-responsibility-assembly',
    );

    expect(controller.canSubmitQuestion(matrix), isFalse);

    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-assembly-action',
      optionId: 'option-action-censure',
    );

    final answer = controller.answerFor(matrix);
    expect(controller.canSubmitQuestion(matrix), isTrue);
    expect(answer, isA<RichClosedInstitutionMatrixAnswer>());
    expect(
      (answer! as RichClosedInstitutionMatrixAnswer).values.map(
        (value) => '${value.cellId}:${value.optionId}',
      ),
      [
        'cell-president-legitimacy:option-legitimacy-election',
        'cell-government-responsibility:option-responsibility-assembly',
        'cell-assembly-action:option-action-censure',
      ],
    );
  });

  test('institution_matrix ignore ids inconnus et remplace une valeur', () {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final matrix = _question<RichClosedInstitutionMatrixQuestion>(v1cExercise);

    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-unknown',
      optionId: 'option-legitimacy-election',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-unknown',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-legitimacy-confidence',
    );
    controller.setInstitutionMatrixValue(
      question: matrix,
      cellId: 'cell-president-legitimacy',
      optionId: 'option-legitimacy-election',
    );

    expect(
      controller.selectedInstitutionMatrixOptionIdFor(
        matrix.id,
        'cell-president-legitimacy',
      ),
      'option-legitimacy-election',
    );
    expect(
      controller
          .institutionMatrixValuesFor(matrix)
          .map((value) => '${value.cellId}:${value.optionId}'),
      ['cell-president-legitimacy:option-legitimacy-election'],
    );
    expect(controller.canSubmitQuestion(matrix), isFalse);
  });

  test('diagram_labeling commence incomplet puis produit values', () {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final diagram = _question<RichClosedDiagramLabelingQuestion>(
      v1cFullExercise,
    );

    expect(controller.canSubmitQuestion(diagram), isFalse);
    expect(controller.answerFor(diagram), isNull);
    expect(controller.diagramLabelingValuesFor(diagram), isEmpty);

    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-government',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-censure',
      optionId: 'option-motion-censure',
    );

    expect(controller.canSubmitQuestion(diagram), isFalse);

    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-nomination',
      optionId: 'option-nomination',
    );

    final answer = controller.answerFor(diagram);
    expect(controller.canSubmitQuestion(diagram), isTrue);
    expect(answer, isA<RichClosedDiagramLabelingAnswer>());
    expect(
      (answer! as RichClosedDiagramLabelingAnswer).values.map(
        (value) => '${value.slotId}:${value.optionId}',
      ),
      [
        'slot-government-role:option-government',
        'slot-censure:option-motion-censure',
        'slot-nomination:option-nomination',
      ],
    );
  });

  test('diagram_labeling ignore ids inconnus et remplace une valeur', () {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final diagram = _question<RichClosedDiagramLabelingQuestion>(
      v1cFullExercise,
    );

    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-unknown',
      optionId: 'option-government',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-unknown',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-president',
    );
    controller.setDiagramLabelingValue(
      question: diagram,
      slotId: 'slot-government-role',
      optionId: 'option-government',
    );

    expect(
      controller.selectedDiagramLabelingOptionIdFor(
        diagram.id,
        'slot-government-role',
      ),
      'option-government',
    );
    expect(
      controller
          .diagramLabelingValuesFor(diagram)
          .map((value) => '${value.slotId}:${value.optionId}'),
      ['slot-government-role:option-government'],
    );
    expect(controller.canSubmitQuestion(diagram), isFalse);
  });

  test('calculation_mcq commence incomplet puis produit choiceId', () {
    final controller = RichClosedCoreAnswerController();
    final v1cCalculationExercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
    final calculation = _question<RichClosedCalculationMcqQuestion>(
      v1cCalculationExercise,
    );

    expect(controller.canSubmitQuestion(calculation), isFalse);
    expect(controller.answerFor(calculation), isNull);
    expect(controller.selectedCalculationChoiceIdFor(calculation.id), isNull);

    controller.selectCalculationChoice(
      question: calculation,
      choiceId: 'choice-289',
    );

    final answer = controller.answerFor(calculation);
    expect(controller.canSubmitQuestion(calculation), isTrue);
    expect(answer, isA<RichClosedCalculationMcqAnswer>());
    expect((answer! as RichClosedCalculationMcqAnswer).choiceId, 'choice-289');
    expect(answer.toJson(), {
      'questionId': 'calculation-mcq-majority-1',
      'questionKind': 'calculation_mcq',
      'choiceId': 'choice-289',
    });
  });

  test('calculation_mcq ignore ids inconnus et remplace une valeur', () {
    final controller = RichClosedCoreAnswerController();
    final v1cCalculationExercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
    final calculation = _question<RichClosedCalculationMcqQuestion>(
      v1cCalculationExercise,
    );

    controller.selectCalculationChoice(
      question: calculation,
      choiceId: 'choice-unknown',
    );
    controller.selectCalculationChoice(
      question: calculation,
      choiceId: 'choice-288',
    );
    controller.selectCalculationChoice(
      question: calculation,
      choiceId: 'choice-289',
    );

    expect(
      controller.selectedCalculationChoiceIdFor(calculation.id),
      'choice-289',
    );
    expect(
      (controller.answerFor(calculation)! as RichClosedCalculationMcqAnswer)
          .choiceId,
      'choice-289',
    );
  });

  test('matching et ordering ne produisent jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    controller.setMatchingPair(
      question: matching,
      leftId: 'left-1',
      rightId: 'right-1',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-2',
      rightId: 'right-2',
    );
    controller.setMatchingPair(
      question: matching,
      leftId: 'left-3',
      rightId: 'right-3',
    );

    final matchingJson = controller.answerFor(matching)!.toJson();
    final orderingJson = controller.answerFor(ordering)!.toJson();

    for (final json in [matchingJson, orderingJson]) {
      expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
      expect(json.containsKey('correction'), isFalse);
      expect(json.containsKey('score'), isFalse);
      expect(json.containsKey('explanation'), isFalse);
    }
  });

  test('timeline et date_slider ne produisent jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final timeline = _question<RichClosedTimelineQuestion>(v1bExercise);
    final dateSlider = _question<RichClosedDateSliderQuestion>(v1bExercise);

    final timelineJson = controller.answerFor(timeline)!.toJson();
    final dateSliderJson = controller.answerFor(dateSlider)!.toJson();

    for (final json in [timelineJson, dateSliderJson]) {
      expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
      expect(json.containsKey('correction'), isFalse);
      expect(json.containsKey('score'), isFalse);
      expect(json.containsKey('explanation'), isFalse);
    }
  });

  test(
    'true_false_grid et cause_consequence ne produisent jamais de correction',
    () {
      final controller = RichClosedCoreAnswerController();
      final v1bFullExercise = RichClosedExercise.fromJson(
        richClosedV1BFullExerciseJson(),
      );
      final trueFalse = _question<RichClosedTrueFalseGridQuestion>(
        v1bFullExercise,
      );
      final causeConsequence = _question<RichClosedCauseConsequenceQuestion>(
        v1bFullExercise,
      );

      for (final row in trueFalse.rows) {
        controller.setTrueFalseValue(
          question: trueFalse,
          rowId: row.id,
          value: true,
        );
      }
      for (final indexedCause in causeConsequence.causes.indexed) {
        controller.setCauseConsequencePair(
          question: causeConsequence,
          causeId: indexedCause.$2.id,
          consequenceId: causeConsequence.consequences[indexedCause.$1].id,
        );
      }

      final trueFalseJson = controller.answerFor(trueFalse)!.toJson();
      final causeConsequenceJson = controller
          .answerFor(causeConsequence)!
          .toJson();

      for (final json in [trueFalseJson, causeConsequenceJson]) {
        expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
        expect(json.containsKey('correction'), isFalse);
        expect(json.containsKey('score'), isFalse);
        expect(json.containsKey('explanation'), isFalse);
      }
    },
  );

  test('institution_matrix ne produit jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final matrix = _question<RichClosedInstitutionMatrixQuestion>(v1cExercise);

    for (final cell in matrix.cells) {
      controller.setInstitutionMatrixValue(
        question: matrix,
        cellId: cell.id,
        optionId: cell.options.first.id,
      );
    }

    final json = controller.answerFor(matrix)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
  });

  test('diagram_labeling ne produit jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final diagram = _question<RichClosedDiagramLabelingQuestion>(
      v1cFullExercise,
    );

    for (final slot in diagram.slots) {
      controller.setDiagramLabelingValue(
        question: diagram,
        slotId: slot.id,
        optionId: slot.options.first.id,
      );
    }

    final json = controller.answerFor(diagram)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
    expect(json.containsKey('renderPayload'), isFalse);
  });

  test('calculation_mcq ne produit jamais de correction', () {
    final controller = RichClosedCoreAnswerController();
    final v1cCalculationExercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
    final calculation = _question<RichClosedCalculationMcqQuestion>(
      v1cCalculationExercise,
    );

    controller.selectCalculationChoice(
      question: calculation,
      choiceId: 'choice-289',
    );

    final json = controller.answerFor(calculation)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
    expect(json.containsKey('expectedValue'), isFalse);
    expect(json.containsKey('workedSteps'), isFalse);
    expect(json.containsKey('formula'), isFalse);
  });

  test('ne produit jamais de correction dans le JSON de réponse', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');

    final json = controller.answerFor(question)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
  });
}

T _question<T extends RichClosedQuestion>(RichClosedExercise exercise) {
  return exercise.questions.whereType<T>().single;
}

~~~

### test/features/activities/rich_closed_calculation_mcq_widget_test.dart

~~~text
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_calculation_mcq_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
  });

  testWidgets('calculation_mcq affiche les donnees et produit choiceId', (
    tester,
  ) async {
    final answers = <RichClosedCalculationMcqAnswer?>[];
    final question = _question<RichClosedCalculationMcqQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCalculationMcqWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Calcul'), findsOneWidget);
    expect(find.textContaining('577 suffrages exprimés'), findsOneWidget);
    expect(find.text('Suffrages exprimés : 577'), findsOneWidget);
    expect(find.text('288 voix'), findsOneWidget);
    expect(find.text('289 voix'), findsOneWidget);
    expect(find.text('290 voix'), findsOneWidget);
    expect(find.text('Valeur : 289'), findsOneWidget);
    _expectNoPreSubmitLeaks();

    await tester.tap(
      find.byKey(
        const ValueKey('calculation-mcq-calculation-mcq-majority-1-choice-289'),
      ),
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.choiceId, 'choice-289');
    expect(answer.toJson(), {
      'questionId': 'calculation-mcq-majority-1',
      'questionKind': 'calculation_mcq',
      'choiceId': 'choice-289',
    });
  });
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

T _question<T extends RichClosedQuestion>(RichClosedExercise exercise) {
  return exercise.questions.whereType<T>().single;
}

void _expectNoPreSubmitLeaks() {
  expect(find.text('correctChoiceId'), findsNothing);
  expect(find.text('expectedValue'), findsNothing);
  expect(find.text('workedSteps'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('formula'), findsNothing);
  expect(find.text('renderPayload'), findsNothing);
}

~~~

### test/features/activities/rich_closed_correction_presenter_test.dart

~~~text
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;
  late RichClosedExerciseResult result;
  late RichClosedCorrectionPresenter presenter;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
    result = RichClosedExerciseResult.fromJson(richClosedResultJson());
    presenter = const RichClosedCorrectionPresenter();
  });

  test('construit un summary depuis les valeurs backend', () {
    final viewModel = presenter.present(exercise: exercise, result: result);

    expect(viewModel.summary.sessionId, 'rich-session-1');
    expect(viewModel.summary.status, 'completed');
    expect(viewModel.summary.correctAnswers, 5);
    expect(viewModel.summary.totalQuestions, 6);
    expect(viewModel.summary.score, 0.833);
    expect(viewModel.summary.scoreLabel, '0.833');
    expect(viewModel.summary.answerRatioLabel, '5 / 6');
  });

  test('mappe les six types de corrections en labels lisibles', () {
    final viewModel = presenter.present(exercise: exercise, result: result);

    expect(_item(viewModel, 'single-1').submittedAnswerLines, [
      'Responsabilité politique',
    ]);
    expect(_item(viewModel, 'single-1').correctAnswerLines, [
      'Responsabilité politique',
    ]);

    expect(_item(viewModel, 'multiple-1').submittedAnswerLines, [
      'Responsabilité du gouvernement',
      'Collaboration des pouvoirs',
    ]);
    expect(_item(viewModel, 'multiple-1').correctAnswerLines, [
      'Responsabilité du gouvernement',
      'Collaboration des pouvoirs',
    ]);

    expect(_item(viewModel, 'case-1').contextText, contains('confiance'));
    expect(_item(viewModel, 'case-1').submittedAnswerLines, [
      'Régime parlementaire',
    ]);
    expect(_item(viewModel, 'case-1').correctAnswerLines, [
      'Régime parlementaire',
    ]);

    expect(_item(viewModel, 'error-1').contextText, contains('présidentiel'));
    expect(_item(viewModel, 'error-1').submittedAnswerLines, [
      'Confusion avec l’État fédéral',
    ]);
    expect(_item(viewModel, 'error-1').correctAnswerLines, [
      'Confusion avec le parlementarisme',
    ]);

    expect(_item(viewModel, 'matching-1').submittedAnswerLines, [
      'Motion de censure → Responsabilité politique',
      'Dissolution → Fin anticipée d’une chambre',
      'Contrôle constitutionnel → Vérification d’une norme',
    ]);
    expect(_item(viewModel, 'matching-1').correctAnswerLines, [
      'Motion de censure → Responsabilité politique',
      'Dissolution → Fin anticipée d’une chambre',
      'Contrôle constitutionnel → Vérification d’une norme',
    ]);

    expect(_item(viewModel, 'ordering-1').submittedAnswerLines, [
      '1. Repérer les organes',
      '2. Analyser les moyens d’action',
      '3. Qualifier le régime',
    ]);
    expect(_item(viewModel, 'ordering-1').correctAnswerLines, [
      '1. Repérer les organes',
      '2. Analyser les moyens d’action',
      '3. Qualifier le régime',
    ]);
  });

  test('mappe timeline et date_slider depuis les corrections backend', () {
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final v1bResult = RichClosedExerciseResult.fromJson(
      richClosedV1BResultJson(),
    );
    final viewModel = presenter.present(
      exercise: v1bExercise,
      result: v1bResult,
    );

    expect(_item(viewModel, 'timeline-1').kindLabel, 'Chronologie');
    expect(_item(viewModel, 'timeline-1').submittedAnswerLines, [
      '1. Dépôt de la motion',
      '2. Débat politique',
      '3. Vote de la chambre',
    ]);
    expect(_item(viewModel, 'timeline-1').correctAnswerLines, [
      '1. Dépôt de la motion',
      '2. Débat politique',
      '3. Vote de la chambre',
    ]);

    expect(_item(viewModel, 'date-slider-1').kindLabel, 'Curseur temporel');
    expect(_item(viewModel, 'date-slider-1').submittedAnswerLines, [
      'Année choisie : 1960',
    ]);
    expect(_item(viewModel, 'date-slider-1').correctAnswerLines, [
      'Année correcte : 1958',
      'Plage acceptée : 1958 - 1958',
    ]);
    expect(_item(viewModel, 'date-slider-1').isCorrect, isFalse);
  });

  test(
    'mappe true_false_grid et cause_consequence depuis les corrections backend',
    () {
      final v1bFullExercise = RichClosedExercise.fromJson(
        richClosedV1BFullExerciseJson(),
      );
      final v1bFullResult = RichClosedExerciseResult.fromJson(
        richClosedV1BFullResultJson(),
      );
      final viewModel = presenter.present(
        exercise: v1bFullExercise,
        result: v1bFullResult,
      );

      expect(_item(viewModel, 'true-false-grid-1').kindLabel, 'Vrai / faux');
      expect(_item(viewModel, 'true-false-grid-1').submittedAnswerLines, [
        'Le gouvernement peut être responsable devant le Parlement. : Vrai',
        'La séparation des pouvoirs interdit toute collaboration. : Vrai',
        'La dissolution peut être un moyen réciproque. : Vrai',
      ]);
      expect(_item(viewModel, 'true-false-grid-1').correctAnswerLines, [
        'Le gouvernement peut être responsable devant le Parlement. : Vrai',
        'La séparation des pouvoirs interdit toute collaboration. : Faux',
        'La dissolution peut être un moyen réciproque. : Vrai',
      ]);
      expect(_item(viewModel, 'true-false-grid-1').isCorrect, isFalse);

      expect(
        _item(viewModel, 'cause-consequence-1').kindLabel,
        'Cause / conséquence',
      );
      expect(_item(viewModel, 'cause-consequence-1').submittedAnswerLines, [
        'Motion de censure adoptée → Démission du gouvernement',
        'Dissolution de l’Assemblée → Nouvelles élections législatives',
        'Question de confiance rejetée → Crise politique ou départ du gouvernement',
      ]);
      expect(_item(viewModel, 'cause-consequence-1').correctAnswerLines, [
        'Motion de censure adoptée → Démission du gouvernement',
        'Dissolution de l’Assemblée → Nouvelles élections législatives',
        'Question de confiance rejetée → Crise politique ou départ du gouvernement',
      ]);
    },
  );

  test('mappe institution_matrix depuis les corrections backend', () {
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final v1cResult = RichClosedExerciseResult.fromJson(
      richClosedV1CResultJson(),
    );
    final viewModel = presenter.present(
      exercise: v1cExercise,
      result: v1cResult,
    );

    expect(_item(viewModel, 'institution-matrix-1').kindLabel, 'Matrice');
    expect(_item(viewModel, 'institution-matrix-1').submittedAnswerLines, [
      'Président de la République / Mode de légitimité : Élection nationale',
      'Gouvernement / Responsabilité politique : Assemblée nationale',
      'Assemblée nationale / Moyen d’action : Motion de censure',
    ]);
    expect(_item(viewModel, 'institution-matrix-1').correctAnswerLines, [
      'Président de la République / Mode de légitimité : Élection nationale',
      'Gouvernement / Responsabilité politique : Assemblée nationale',
      'Assemblée nationale / Moyen d’action : Motion de censure',
    ]);
    expect(_item(viewModel, 'institution-matrix-1').isCorrect, isTrue);
  });

  test('mappe diagram_labeling depuis les corrections backend', () {
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final v1cFullResult = RichClosedExerciseResult.fromJson(
      richClosedV1CFullResultJson(),
    );
    final viewModel = presenter.present(
      exercise: v1cFullExercise,
      result: v1cFullResult,
    );

    expect(_item(viewModel, 'diagram-labeling-1').kindLabel, 'Schéma');
    expect(_item(viewModel, 'diagram-labeling-1').submittedAnswerLines, [
      'Gouvernement : Gouvernement',
      'Assemblée nationale -> Gouvernement / contrôle : Motion de censure',
      'Président de la République -> Gouvernement / nomme : Nomination',
    ]);
    expect(_item(viewModel, 'diagram-labeling-1').correctAnswerLines, [
      'Gouvernement : Gouvernement',
      'Assemblée nationale -> Gouvernement / contrôle : Motion de censure',
      'Président de la République -> Gouvernement / nomme : Nomination',
    ]);
    expect(_item(viewModel, 'diagram-labeling-1').isCorrect, isTrue);
  });

  test('mappe calculation_mcq depuis les corrections backend', () {
    final v1cCalculationExercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
    final v1cCalculationResult = RichClosedExerciseResult.fromJson(
      richClosedV1CCalculationResultJson(),
    );
    final viewModel = presenter.present(
      exercise: v1cCalculationExercise,
      result: v1cCalculationResult,
    );

    final item = _item(viewModel, 'calculation-mcq-majority-1');
    expect(item.kindLabel, 'Calcul');
    expect(item.contextText, contains('577 suffrages exprimés'));
    expect(item.submittedAnswerLines, ['Choix envoyé : 289 voix']);
    expect(item.correctAnswerLines, [
      'Choix attendu : 289 voix',
      'Valeur attendue : 289',
      'Suffrages exprimés : Suffrages exprimés : 577.',
      'Majorité absolue : Prendre la partie entière de 577 / 2, puis ajouter 1.',
      'Seuil attendu : Seuil attendu : 289.',
    ]);
    expect(item.isCorrect, isTrue);
  });

  test('rejette une correction diagram_labeling incomplète ou dupliquée', () {
    final exercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );

    for (final correctValues in [
      [
        {'slotId': 'slot-government-role', 'optionId': 'option-government'},
        {'slotId': 'slot-censure', 'optionId': 'option-motion-censure'},
      ],
      [
        {'slotId': 'slot-government-role', 'optionId': 'option-government'},
        {'slotId': 'slot-government-role', 'optionId': 'option-president'},
        {'slotId': 'slot-nomination', 'optionId': 'option-nomination'},
      ],
    ]) {
      final json = richClosedV1CFullResultJson();
      final item =
          (json['items']! as List<Object?>).last! as Map<String, Object?>;
      final correction = item['correction']! as Map<String, Object?>;
      correction['correctValues'] = correctValues;

      expect(
        () => presenter.present(
          exercise: exercise,
          result: RichClosedExerciseResult.fromJson(json),
        ),
        throwsA(isA<RichClosedCorrectionPresentationException>()),
      );
    }
  });

  test('conserve isCorrect et partialScore backend sans recalcul', () {
    final json = richClosedResultJson();
    final single =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    single['isCorrect'] = false;
    single['partialScore'] = 0.42;

    final viewModel = presenter.present(
      exercise: exercise,
      result: RichClosedExerciseResult.fromJson(json),
    );
    final item = _item(viewModel, 'single-1');

    expect(item.submittedAnswerLines, item.correctAnswerLines);
    expect(item.isCorrect, isFalse);
    expect(item.statusLabel, 'Incorrect');
    expect(item.partialScore, 0.42);
    expect(item.partialScoreLabel, '0.42');
  });

  test('conserve isCorrect true même si les labels soumis diffèrent', () {
    final json = richClosedResultJson();
    final single =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    final answer = single['submittedAnswer']! as Map<String, Object?>;
    answer['choiceId'] = 'choice-b';
    single['isCorrect'] = true;

    final viewModel = presenter.present(
      exercise: exercise,
      result: RichClosedExerciseResult.fromJson(json),
    );
    final item = _item(viewModel, 'single-1');

    expect(item.submittedAnswerLines, ['Séparation étanche']);
    expect(item.correctAnswerLines, ['Responsabilité politique']);
    expect(item.isCorrect, isTrue);
    expect(item.statusLabel, 'Correct');
  });

  test('conserve score/correctAnswers/totalQuestions backend atypiques', () {
    final json = richClosedResultJson()
      ..['score'] = 0.123
      ..['correctAnswers'] = 99
      ..['totalQuestions'] = 100;

    final viewModel = presenter.present(
      exercise: exercise,
      result: RichClosedExerciseResult.fromJson(json),
    );

    expect(viewModel.summary.score, 0.123);
    expect(viewModel.summary.scoreLabel, '0.123');
    expect(viewModel.summary.correctAnswers, 99);
    expect(viewModel.summary.totalQuestions, 100);
    expect(viewModel.summary.answerRatioLabel, '99 / 100');
  });

  test('rejette une question inconnue', () {
    final json = richClosedResultJson();
    final item =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    item['questionId'] = 'unknown-question';
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    answer['questionId'] = 'unknown-question';

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette un choice soumis inconnu', () {
    final json = richClosedResultJson();
    final item =
        (json['items']! as List<Object?>).first! as Map<String, Object?>;
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    answer['choiceId'] = 'unknown-choice';

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette une paire matching inconnue', () {
    final json = richClosedResultJson();
    final item = (json['items']! as List<Object?>)[2]! as Map<String, Object?>;
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    final pairs = answer['pairs']! as List<Object?>;
    (pairs.first! as Map<String, Object?>)['rightId'] = 'unknown-right';

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette un item ordering inconnu', () {
    final json = richClosedResultJson();
    final item = (json['items']! as List<Object?>)[3]! as Map<String, Object?>;
    final answer = item['submittedAnswer']! as Map<String, Object?>;
    answer['orderedIds'] = ['item-1', 'unknown-item', 'item-3'];

    expect(
      () => presenter.present(
        exercise: exercise,
        result: RichClosedExerciseResult.fromJson(json),
      ),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });

  test('rejette une correction incohérente avec questionKind', () {
    final badResult = RichClosedExerciseResult(
      sessionId: result.sessionId,
      type: result.type,
      status: result.status,
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      score: result.score,
      items: [
        RichClosedCorrectionItem(
          questionId: 'single-1',
          questionKind: RichClosedQuestionKind.singleChoice,
          prompt: 'Quel critère caractérise un régime parlementaire ?',
          submittedAnswer: const RichClosedSingleChoiceAnswer(
            questionId: 'single-1',
            choiceId: 'choice-a',
          ),
          isCorrect: true,
          partialScore: 1,
          explanation: 'Correction incohérente.',
          sourceChunkIds: const ['chunk-1'],
          correction: const RichClosedCorrectOrderCorrection(
            correctOrder: ['item-1'],
          ),
        ),
      ],
    );

    expect(
      () => presenter.present(exercise: exercise, result: badResult),
      throwsA(isA<RichClosedCorrectionPresentationException>()),
    );
  });
}

RichClosedCorrectionItemViewModel _item(
  RichClosedCorrectionViewModel viewModel,
  String questionId,
) {
  return viewModel.items.singleWhere((item) => item.questionId == questionId);
}

~~~

### test/features/activities/rich_closed_exercise_flow_controller_test.dart

~~~text
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

  test(
    'collecte timeline et date_slider avec réponses initiales typées',
    () async {
      final v1bExercise = RichClosedExercise.fromJson(
        richClosedV1BExerciseJson(),
      );
      final v1bResult = RichClosedExerciseResult.fromJson(
        richClosedV1BResultJson(),
      );
      final api = _FakeRichClosedActivityApi(
        exercise: v1bExercise,
        result: v1bResult,
      );
      final controller = RichClosedExerciseFlowController(
        activityController: ActivityController(api),
      );

      await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');

      expect(controller.state.answeredCount, 3);
      _answerAllQuestions(controller);
      expect(controller.state.answeredCount, 8);
      expect(controller.state.canSubmit, isTrue);

      await controller.submit();

      expect(api.submittedAnswers, hasLength(8));
      expect(
        api.submittedAnswers!
            .whereType<RichClosedTimelineAnswer>()
            .single
            .orderedEventIds,
        ['event-1', 'event-2', 'event-3'],
      );
      expect(
        api.submittedAnswers!
            .whereType<RichClosedDateSliderAnswer>()
            .single
            .year,
        1958,
      );
    },
  );

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
      case RichClosedTimelineQuestion():
        break;
      case RichClosedDateSliderQuestion():
        break;
      case RichClosedTrueFalseGridQuestion():
        controller.recordAnswer(
          question,
          RichClosedTrueFalseGridAnswer(
            questionId: question.id,
            values: [
              for (final row in question.rows)
                RichClosedTrueFalseGridValue(rowId: row.id, value: true),
            ],
          ),
        );
      case RichClosedCauseConsequenceQuestion():
        controller.recordAnswer(
          question,
          RichClosedCauseConsequenceAnswer(
            questionId: question.id,
            pairs: [
              for (final indexedCause in question.causes.indexed)
                RichClosedCauseConsequencePair(
                  causeId: indexedCause.$2.id,
                  consequenceId: question.consequences[indexedCause.$1].id,
                ),
            ],
          ),
        );
      case RichClosedInstitutionMatrixQuestion():
        controller.recordAnswer(
          question,
          RichClosedInstitutionMatrixAnswer(
            questionId: question.id,
            values: [
              for (final cell in question.cells)
                RichClosedInstitutionMatrixValue(
                  cellId: cell.id,
                  optionId: cell.options.first.id,
                ),
            ],
          ),
        );
      case RichClosedDiagramLabelingQuestion():
        controller.recordAnswer(
          question,
          RichClosedDiagramLabelingAnswer(
            questionId: question.id,
            values: [
              for (final slot in question.slots)
                RichClosedDiagramLabelingValue(
                  slotId: slot.id,
                  optionId: slot.options.first.id,
                ),
            ],
          ),
        );
      case RichClosedCalculationMcqQuestion():
        controller.recordAnswer(
          question,
          RichClosedCalculationMcqAnswer(
            questionId: question.id,
            choiceId: question.choices.first.id,
          ),
        );
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

~~~

### test/features/activities/rich_closed_exercise_page_test.dart

~~~text
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

  testWidgets('renderer rend timeline et date_slider', (tester) async {
    final controller = RichClosedCoreAnswerController();
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            for (final question in v1bExercise.questions.skip(6))
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
    await tester.pump();

    expect(find.text('Dépôt de la motion'), findsOneWidget);
    expect(find.text('Année sélectionnée : 1958'), findsOneWidget);
    expect(changedQuestions, containsAll(['timeline-1', 'date-slider-1']));
    expect(find.text('correctOrder'), findsNothing);
    expect(find.text('correctYear'), findsNothing);
  });

  testWidgets('renderer rend true_false_grid et cause_consequence', (
    tester,
  ) async {
    final controller = RichClosedCoreAnswerController();
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            for (final question in v1bFullExercise.questions.skip(8))
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
      find.text('Le gouvernement peut être responsable devant le Parlement.'),
      findsOneWidget,
    );
    expect(find.text('Motion de censure adoptée'), findsOneWidget);
    expect(find.text('correctValues'), findsNothing);
    expect(find.text('correctPairs'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('true-false-row-1-true')));
    await tester.pump();

    expect(changedQuestions, contains('true-false-grid-1'));
  });

  testWidgets('renderer rend institution_matrix', (tester) async {
    final controller = RichClosedCoreAnswerController();
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            RichClosedQuestionRenderer(
              question: v1cExercise.questions.last,
              controller: controller,
              enabled: true,
              onChanged: (_) =>
                  changedQuestions.add(v1cExercise.questions.last.id),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Président de la République'), findsOneWidget);
    expect(find.text('Mode de légitimité'), findsOneWidget);
    expect(find.text('correctValues'), findsNothing);
    expect(find.text('explanation'), findsNothing);

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byKey(
        const ValueKey(
          'institution-matrix-institution-matrix-1-cell-president-legitimacy',
        ),
      ),
    );
    dropdown.onChanged!('option-legitimacy-election');
    await tester.pump();

    expect(changedQuestions, contains('institution-matrix-1'));
    expect(controller.canSubmitQuestion(v1cExercise.questions.last), isFalse);
  });

  testWidgets('renderer rend diagram_labeling', (tester) async {
    final controller = RichClosedCoreAnswerController();
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final changedQuestions = <String>[];

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: Column(
          children: [
            RichClosedQuestionRenderer(
              question: v1cFullExercise.questions.last,
              controller: controller,
              enabled: true,
              onChanged: (_) =>
                  changedQuestions.add(v1cFullExercise.questions.last.id),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Rapports institutionnels'), findsOneWidget);
    expect(find.text('Président de la République'), findsOneWidget);
    expect(
      find.text('Quel organe conduit la politique nationale ?'),
      findsOneWidget,
    );
    expect(find.text('correctValues'), findsNothing);
    expect(find.text('explanation'), findsNothing);
    expect(find.text('svg'), findsNothing);
    expect(find.text('renderPayload'), findsNothing);

    final dropdown = tester.widget<DropdownButton<String>>(
      find.byKey(
        const ValueKey(
          'diagram-labeling-diagram-labeling-1-slot-government-role',
        ),
      ),
    );
    dropdown.onChanged!('option-government');
    await tester.pump();

    expect(changedQuestions, contains('diagram-labeling-1'));
    expect(
      controller.canSubmitQuestion(v1cFullExercise.questions.last),
      isFalse,
    );
  });

  testWidgets('renderer rend calculation_mcq', (tester) async {
    final controller = RichClosedCoreAnswerController();
    final v1cCalculationExercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
    final changedQuestions = <String>[];
    final question = v1cCalculationExercise.questions.last;

    await tester.pumpWidget(
      _TestHost(
        scrollable: true,
        child: RichClosedQuestionRenderer(
          question: question,
          controller: controller,
          enabled: true,
          onChanged: (_) => changedQuestions.add(question.id),
        ),
      ),
    );

    expect(find.textContaining('577 suffrages exprimés'), findsOneWidget);
    expect(find.text('Suffrages exprimés : 577'), findsOneWidget);
    expect(find.text('289 voix'), findsOneWidget);
    expect(find.text('correctChoiceId'), findsNothing);
    expect(find.text('expectedValue'), findsNothing);
    expect(find.text('workedSteps'), findsNothing);
    expect(find.text('formula'), findsNothing);

    await _tapVisible(
      tester,
      find.byKey(
        const ValueKey('calculation-mcq-calculation-mcq-majority-1-choice-289'),
      ),
    );

    expect(changedQuestions, contains('calculation-mcq-majority-1'));
    expect(controller.canSubmitQuestion(question), isTrue);
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

  testWidgets('page submit et affiche les corrections V1-B', (tester) async {
    final v1bExercise = RichClosedExercise.fromJson(
      richClosedV1BExerciseJson(),
    );
    final v1bResult = RichClosedExerciseResult.fromJson(
      richClosedV1BResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1bExercise,
      result: v1bResult,
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

    expect(find.text('3 / 8 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('8 / 8 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(8));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedTimelineAnswer>()
          .single
          .orderedEventIds,
      ['event-1', 'event-2', 'event-3'],
    );
    expect(
      api.submittedAnswers!.whereType<RichClosedDateSliderAnswer>().single.year,
      1958,
    );
    expect(find.text('Année correcte : 1958'), findsOneWidget);
    expect(find.text('Plage acceptée : 1958 - 1958'), findsOneWidget);
  });

  testWidgets('page submit et affiche les corrections V1-018', (tester) async {
    final v1bFullExercise = RichClosedExercise.fromJson(
      richClosedV1BFullExerciseJson(),
    );
    final v1bFullResult = RichClosedExerciseResult.fromJson(
      richClosedV1BFullResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1bFullExercise,
      result: v1bFullResult,
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

    expect(find.text('3 / 10 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('10 / 10 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(10));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedTrueFalseGridAnswer>()
          .single
          .values
          .map((value) => '${value.rowId}:${value.value}'),
      ['row-1:true', 'row-2:true', 'row-3:true'],
    );
    expect(
      api.submittedAnswers!
          .whereType<RichClosedCauseConsequenceAnswer>()
          .single
          .pairs
          .map((pair) => '${pair.causeId}:${pair.consequenceId}'),
      [
        'cause-1:consequence-1',
        'cause-2:consequence-2',
        'cause-3:consequence-3',
      ],
    );
    expect(
      find.text(
        'La séparation des pouvoirs interdit toute collaboration. : Faux',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Motion de censure adoptée → Démission du gouvernement'),
      findsWidgets,
    );
  });

  testWidgets('page submit et affiche les corrections V1-C', (tester) async {
    final v1cExercise = RichClosedExercise.fromJson(
      richClosedV1CExerciseJson(),
    );
    final v1cResult = RichClosedExerciseResult.fromJson(
      richClosedV1CResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1cExercise,
      result: v1cResult,
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

    expect(find.text('3 / 11 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('11 / 11 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(11));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedInstitutionMatrixAnswer>()
          .single
          .values
          .map((value) => '${value.cellId}:${value.optionId}'),
      [
        'cell-president-legitimacy:option-legitimacy-election',
        'cell-government-responsibility:option-responsibility-assembly',
        'cell-assembly-action:option-action-censure',
      ],
    );
    expect(
      find.text(
        'Président de la République / Mode de légitimité : Élection nationale',
      ),
      findsWidgets,
    );
  });

  testWidgets('page submit et affiche les corrections V1-020', (tester) async {
    final v1cFullExercise = RichClosedExercise.fromJson(
      richClosedV1CFullExerciseJson(),
    );
    final v1cFullResult = RichClosedExerciseResult.fromJson(
      richClosedV1CFullResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1cFullExercise,
      result: v1cFullResult,
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

    expect(find.text('3 / 12 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('12 / 12 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(12));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedDiagramLabelingAnswer>()
          .single
          .values
          .map((value) => '${value.slotId}:${value.optionId}'),
      [
        'slot-government-role:option-government',
        'slot-censure:option-motion-censure',
        'slot-nomination:option-nomination',
      ],
    );
    expect(find.text('Gouvernement : Gouvernement'), findsWidgets);
    expect(
      find.text(
        'Assemblée nationale -> Gouvernement / contrôle : Motion de censure',
      ),
      findsWidgets,
    );
  });

  testWidgets('page submit et affiche les corrections V1-021', (tester) async {
    final v1cCalculationExercise = RichClosedExercise.fromJson(
      richClosedV1CCalculationExerciseJson(),
    );
    final v1cCalculationResult = RichClosedExerciseResult.fromJson(
      richClosedV1CCalculationResultJson(),
    );
    final api = _FakeRichClosedActivityApi(
      exercise: v1cCalculationExercise,
      result: v1cCalculationResult,
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

    expect(find.text('3 / 13 répondues'), findsOneWidget);

    await _answerAllQuestions(tester);

    expect(find.text('13 / 13 répondues'), findsOneWidget);
    expect(_submitButton(tester).onPressed, isNotNull);

    await _tapVisible(
      tester,
      find.widgetWithText(RevisionButton, 'Valider mes réponses'),
    );
    await tester.pumpAndSettle();

    expect(api.submittedAnswers, hasLength(13));
    expect(
      api.submittedAnswers!
          .whereType<RichClosedCalculationMcqAnswer>()
          .single
          .choiceId,
      'choice-289',
    );
    expect(find.text('Choix attendu : 289 voix'), findsWidgets);
    expect(find.text('Valeur attendue : 289'), findsWidgets);
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
  await _tapIfPresent(
    tester,
    find.byKey(const ValueKey('true-false-row-1-true')),
  );
  await _tapIfPresent(
    tester,
    find.byKey(const ValueKey('true-false-row-2-true')),
  );
  await _tapIfPresent(
    tester,
    find.byKey(const ValueKey('true-false-row-3-true')),
  );
  await _selectCauseConsequence(
    tester,
    causeId: 'cause-1',
    consequenceId: 'consequence-1',
  );
  await _selectCauseConsequence(
    tester,
    causeId: 'cause-2',
    consequenceId: 'consequence-2',
  );
  await _selectCauseConsequence(
    tester,
    causeId: 'cause-3',
    consequenceId: 'consequence-3',
  );
  await _selectInstitutionMatrix(
    tester,
    cellId: 'cell-president-legitimacy',
    optionId: 'option-legitimacy-election',
  );
  await _selectInstitutionMatrix(
    tester,
    cellId: 'cell-government-responsibility',
    optionId: 'option-responsibility-assembly',
  );
  await _selectInstitutionMatrix(
    tester,
    cellId: 'cell-assembly-action',
    optionId: 'option-action-censure',
  );
  await _selectDiagramLabeling(
    tester,
    slotId: 'slot-government-role',
    optionId: 'option-government',
  );
  await _selectDiagramLabeling(
    tester,
    slotId: 'slot-censure',
    optionId: 'option-motion-censure',
  );
  await _selectDiagramLabeling(
    tester,
    slotId: 'slot-nomination',
    optionId: 'option-nomination',
  );
  await _selectCalculationMcq(tester, choiceId: 'choice-289');
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

Future<void> _selectCauseConsequence(
  WidgetTester tester, {
  required String causeId,
  required String consequenceId,
}) async {
  final finder = find.byKey(
    ValueKey('cause-consequence-cause-consequence-1-$causeId'),
  );
  if (finder.evaluate().isEmpty) {
    return;
  }

  await tester.ensureVisible(finder);
  final dropdown = tester.widget<DropdownButton<String>>(finder);
  dropdown.onChanged!(consequenceId);
  await tester.pumpAndSettle();
}

Future<void> _selectInstitutionMatrix(
  WidgetTester tester, {
  required String cellId,
  required String optionId,
}) async {
  final finder = find.byKey(
    ValueKey('institution-matrix-institution-matrix-1-$cellId'),
  );
  if (finder.evaluate().isEmpty) {
    return;
  }

  await tester.ensureVisible(finder);
  final dropdown = tester.widget<DropdownButton<String>>(finder);
  dropdown.onChanged!(optionId);
  await tester.pumpAndSettle();
}

Future<void> _selectDiagramLabeling(
  WidgetTester tester, {
  required String slotId,
  required String optionId,
}) async {
  final finder = find.byKey(
    ValueKey('diagram-labeling-diagram-labeling-1-$slotId'),
  );
  if (finder.evaluate().isEmpty) {
    return;
  }

  await tester.ensureVisible(finder);
  final dropdown = tester.widget<DropdownButton<String>>(finder);
  dropdown.onChanged!(optionId);
  await tester.pumpAndSettle();
}

Future<void> _selectCalculationMcq(
  WidgetTester tester, {
  required String choiceId,
}) async {
  final finder = find.byKey(
    ValueKey('calculation-mcq-calculation-mcq-majority-1-$choiceId'),
  );
  if (finder.evaluate().isEmpty) {
    return;
  }

  await _tapVisible(tester, finder);
}

Future<void> _tapIfPresent(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    return;
  }

  await _tapVisible(tester, finder);
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

~~~

### test/features/activities/rich_closed_exercise_test.dart

~~~text
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  group('RichClosedExercise parsing', () {
    test('parses a complete V1-A pre-submit exercise', () {
      final exercise = RichClosedExercise.fromJson(richClosedExerciseJson());

      expect(exercise.sessionId, 'rich-session-1');
      expect(exercise.type, richClosedExerciseType);
      expect(exercise.version, richClosedExerciseVersion);
      expect(exercise.documentId, 'document-1');
      expect(exercise.questions, hasLength(6));
      expect(exercise.questions[0], isA<RichClosedSingleChoiceQuestion>());
      expect(exercise.questions[1], isA<RichClosedMultipleChoiceQuestion>());
      expect(exercise.questions[2], isA<RichClosedMatchingQuestion>());
      expect(exercise.questions[3], isA<RichClosedOrderingQuestion>());
      expect(exercise.questions[4], isA<RichClosedCaseQualificationQuestion>());
      expect(exercise.questions[5], isA<RichClosedErrorDetectionQuestion>());
    });

    test('parses all V1-A question fields explicitly', () {
      final questions = RichClosedExercise.fromJson(
        richClosedExerciseJson(),
      ).questions;

      final single = questions[0] as RichClosedSingleChoiceQuestion;
      final multiple = questions[1] as RichClosedMultipleChoiceQuestion;
      final matching = questions[2] as RichClosedMatchingQuestion;
      final ordering = questions[3] as RichClosedOrderingQuestion;
      final caseQuestion = questions[4] as RichClosedCaseQualificationQuestion;
      final error = questions[5] as RichClosedErrorDetectionQuestion;

      expect(single.choices.first.label, 'Responsabilité politique');
      expect(single.difficulty, RichClosedDifficulty.medium);
      expect(single.cognitiveSkill, RichClosedCognitiveSkill.classification);
      expect(multiple.minSelections, 2);
      expect(multiple.maxSelections, 2);
      expect(matching.leftItems, hasLength(3));
      expect(matching.rightItems, hasLength(3));
      expect(ordering.items.map((item) => item.id), [
        'item-1',
        'item-2',
        'item-3',
      ]);
      expect(caseQuestion.caseText, contains('confiance'));
      expect(error.statement, contains('régime présidentiel'));
      expect(error.errorOptions.first.id, 'error-a');
    });

    test('parses timeline and date_slider public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1BExerciseJson(),
      ).questions;
      final timeline = questions[6] as RichClosedTimelineQuestion;
      final dateSlider = questions[7] as RichClosedDateSliderQuestion;

      expect(questions, hasLength(8));
      expect(timeline.questionKind, RichClosedQuestionKind.timeline);
      expect(timeline.instruction, contains('événements'));
      expect(timeline.events.map((event) => event.id), [
        'event-1',
        'event-2',
        'event-3',
      ]);
      expect(timeline.events.first.description, contains('procédure'));
      expect(dateSlider.questionKind, RichClosedQuestionKind.dateSlider);
      expect(dateSlider.minYear, 1945);
      expect(dateSlider.maxYear, 1970);
      expect(dateSlider.step, 1);
      expect(dateSlider.toleranceYears, 0);
    });

    test('parses true_false_grid and cause_consequence public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1BFullExerciseJson(),
      ).questions;
      final trueFalse = questions[8] as RichClosedTrueFalseGridQuestion;
      final causeConsequence =
          questions[9] as RichClosedCauseConsequenceQuestion;

      expect(questions, hasLength(10));
      expect(trueFalse.questionKind, RichClosedQuestionKind.trueFalseGrid);
      expect(trueFalse.instruction, contains('lignes'));
      expect(trueFalse.rows.map((row) => row.id), ['row-1', 'row-2', 'row-3']);
      expect(trueFalse.rows.first.context, contains('parlementaire'));
      expect(
        causeConsequence.questionKind,
        RichClosedQuestionKind.causeConsequence,
      );
      expect(causeConsequence.causes.map((cause) => cause.id), [
        'cause-1',
        'cause-2',
        'cause-3',
      ]);
      expect(
        causeConsequence.consequences.map((consequence) => consequence.id),
        ['consequence-1', 'consequence-2', 'consequence-3'],
      );
      expect(causeConsequence.causes.first.description, contains('confiance'));
    });

    test('parses institution_matrix public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1CExerciseJson(),
      ).questions;
      final matrix = questions[10] as RichClosedInstitutionMatrixQuestion;

      expect(questions, hasLength(11));
      expect(matrix.questionKind, RichClosedQuestionKind.institutionMatrix);
      expect(matrix.instruction, contains('option fermée'));
      expect(matrix.rows.map((row) => row.id), [
        'row-president',
        'row-government',
        'row-assembly',
      ]);
      expect(matrix.columns.map((column) => column.id), [
        'column-legitimacy',
        'column-action',
        'column-responsibility',
      ]);
      expect(matrix.cells.map((cell) => cell.id), [
        'cell-president-legitimacy',
        'cell-government-responsibility',
        'cell-assembly-action',
      ]);
      expect(matrix.cells.first.options.map((option) => option.id), [
        'option-legitimacy-election',
        'option-legitimacy-confidence',
        'option-legitimacy-nomination',
      ]);
    });

    test('parses diagram_labeling public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1CFullExerciseJson(),
      ).questions;
      final diagram = questions[11] as RichClosedDiagramLabelingQuestion;

      expect(questions, hasLength(12));
      expect(diagram.questionKind, RichClosedQuestionKind.diagramLabeling);
      expect(diagram.instruction, contains('option fermée'));
      expect(diagram.diagram.layout, RichClosedDiagramLayout.verticalFlow);
      expect(diagram.diagram.nodes.map((node) => node.id), [
        'node-president',
        'node-government',
        'node-assembly',
        'node-senate',
      ]);
      expect(diagram.diagram.groups.map((group) => group.id), [
        'group-executive',
        'group-parliament',
      ]);
      expect(diagram.diagram.edges.map((edge) => edge.id), [
        'edge-president-government',
        'edge-government-assembly',
        'edge-assembly-government',
      ]);
      expect(diagram.slots.map((slot) => slot.id), [
        'slot-government-role',
        'slot-censure',
        'slot-nomination',
      ]);
      expect(diagram.slots.first.anchorType, RichClosedDiagramAnchorType.node);
      expect(diagram.slots.first.options.map((option) => option.id), [
        'option-government',
        'option-president',
        'option-senate',
      ]);
    });

    test('parses calculation_mcq public questions', () {
      final questions = RichClosedExercise.fromJson(
        richClosedV1CCalculationExerciseJson(),
      ).questions;
      final calculation = questions[12] as RichClosedCalculationMcqQuestion;

      expect(questions, hasLength(13));
      expect(calculation.questionKind, RichClosedQuestionKind.calculationMcq);
      expect(calculation.instruction, contains('résultat entier'));
      expect(calculation.scenario, contains('577 suffrages'));
      expect(
        calculation.calculation,
        isA<RichClosedAbsoluteMajorityThresholdCalculation>(),
      );
      expect(
        (calculation.calculation
                as RichClosedAbsoluteMajorityThresholdCalculation)
            .validVotes,
        577,
      );
      expect(
        calculation.choices.map((choice) => '${choice.id}:${choice.value}'),
        ['choice-288:288', 'choice-289:289', 'choice-290:290'],
      );
    });

    test('parses largest remainder calculation data without scoring it', () {
      final payload = richClosedExerciseJson();
      payload['questions'] = [
        richClosedCalculationLargestRemainderQuestionJson(),
      ];

      final question =
          RichClosedExercise.fromJson(payload).questions.single
              as RichClosedCalculationMcqQuestion;
      final calculation =
          question.calculation
              as RichClosedLargestRemainderTargetPartySeatsCalculation;

      expect(calculation.totalSeats, 10);
      expect(calculation.targetPartyId, 'party-a');
      expect(calculation.parties.map((party) => '${party.id}:${party.votes}'), [
        'party-a:4300',
        'party-b:3100',
        'party-c:1600',
        'party-d:1000',
      ]);
      expect(question.choices.map((choice) => choice.value), [3, 4, 5]);
    });

    test('accepts zero-vote parties in largest remainder calculation data', () {
      final questionJson = richClosedCalculationLargestRemainderQuestionJson();
      final calculationJson =
          questionJson['calculation']! as Map<String, Object?>;
      ((calculationJson['parties']! as List<Object?>).last!
              as Map<String, Object?>)['votes'] =
          0;
      final payload = richClosedExerciseJson();
      payload['questions'] = [questionJson];

      final question =
          RichClosedExercise.fromJson(payload).questions.single
              as RichClosedCalculationMcqQuestion;
      final calculation =
          question.calculation
              as RichClosedLargestRemainderTargetPartySeatsCalculation;

      expect(calculation.parties.last.votes, 0);
    });

    test('rejects cause_consequence with fewer consequences than causes', () {
      final payload = richClosedV1BFullExerciseJson();
      final question =
          (payload['questions'] as List<Object?>)[9]! as Map<String, Object?>;
      question['causes'] = [
        ...(question['causes']! as List<Object?>),
        {'id': 'cause-4', 'label': 'Cause sans conséquence disponible'},
      ];

      expectParseError(() => RichClosedExercise.fromJson(payload));
    });

    test('rejects unsupported question kinds', () {
      expectParseError(
        () => RichClosedExercise.fromJson(richClosedExerciseWithUnknownKind()),
      );
    });

    test('rejects pre-submit correction and feedback leaks', () {
      expectParseError(
        () => RichClosedExercise.fromJson(
          richClosedExerciseWithCorrectChoiceLeak(),
        ),
      );
      expectParseError(
        () => RichClosedExercise.fromJson(richClosedExerciseWithFeedbackLeak()),
      );
    });

    test('rejects every forbidden pre-submit correction field', () {
      for (final field in [
        'correctChoiceId',
        'correctChoiceIds',
        'correctPairs',
        'correctOrder',
        'correctValues',
        'correctErrorId',
        'correctYear',
        'explanation',
        'score',
        'modelAnswer',
        'answerText',
        'freeTextAnswer',
        'textAnswer',
        'answersPayload',
        'expectedValue',
        'workedSteps',
        'render',
        'renderPayload',
        'code',
        'eval',
        'Function',
        'function',
        'formula',
        'expression',
        'rawFormula',
        'calculationCode',
        'javascript',
        'python',
      ]) {
        final json = richClosedExerciseJson();
        ((json['questions']! as List<Object?>).first!
            as Map<String, Object?>)[field] = field == 'score'
            ? 1
            : 'forbidden';

        expectParseError(() => RichClosedExercise.fromJson(json));
      }
    });

    test('rejects unknown enums and incoherent multiple choice bounds', () {
      final badDifficulty = richClosedExerciseJson();
      ((badDifficulty['questions']! as List<Object?>).first!
              as Map<String, Object?>)['difficulty'] =
          'UNKNOWN';
      expectParseError(() => RichClosedExercise.fromJson(badDifficulty));

      final badSkill = richClosedExerciseJson();
      ((badSkill['questions']! as List<Object?>).first!
              as Map<String, Object?>)['cognitiveSkill'] =
          'analysis';
      expectParseError(() => RichClosedExercise.fromJson(badSkill));

      final badBounds = richClosedExerciseJson();
      final multiple =
          (badBounds['questions']! as List<Object?>)[1]!
              as Map<String, Object?>;
      multiple['minSelections'] = 3;
      multiple['maxSelections'] = 2;
      expectParseError(() => RichClosedExercise.fromJson(badBounds));
    });

    test('rejects empty ids and labels', () {
      final badId = richClosedExerciseJson();
      ((badId['questions']! as List<Object?>).first!
              as Map<String, Object?>)['id'] =
          ' ';
      expectParseError(() => RichClosedExercise.fromJson(badId));

      final badLabel = richClosedExerciseJson();
      final question =
          (badLabel['questions']! as List<Object?>).first!
              as Map<String, Object?>;
      ((question['choices']! as List<Object?>).first!
              as Map<String, Object?>)['label'] =
          '';
      expectParseError(() => RichClosedExercise.fromJson(badLabel));
    });

    test(
      'rejects V1-B public questions carrying private correction fields',
      () {
        final timelineLeak = richClosedV1BExerciseJson();
        ((timelineLeak['questions']! as List<Object?>)[6]!
            as Map<String, Object?>)['correctOrder'] = [
          'event-1',
          'event-2',
          'event-3',
        ];
        final dateLeak = richClosedV1BExerciseJson();
        ((dateLeak['questions']! as List<Object?>)[7]!
                as Map<String, Object?>)['correctYear'] =
            1958;

        expectParseError(() => RichClosedExercise.fromJson(timelineLeak));
        expectParseError(() => RichClosedExercise.fromJson(dateLeak));
      },
    );

    test(
      'rejects V1-018 public questions carrying private correction fields',
      () {
        final trueFalseLeak = richClosedV1BFullExerciseJson();
        ((trueFalseLeak['questions']! as List<Object?>)[8]!
            as Map<String, Object?>)['correctValues'] = [
          {'rowId': 'row-1', 'value': true},
        ];
        final causeConsequenceLeak = richClosedV1BFullExerciseJson();
        ((causeConsequenceLeak['questions']! as List<Object?>)[9]!
            as Map<String, Object?>)['correctPairs'] = [
          {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
        ];

        expectParseError(() => RichClosedExercise.fromJson(trueFalseLeak));
        expectParseError(
          () => RichClosedExercise.fromJson(causeConsequenceLeak),
        );
      },
    );

    test(
      'rejects institution_matrix public questions carrying private fields',
      () {
        final correctValuesLeak = richClosedV1CExerciseJson();
        ((correctValuesLeak['questions']! as List<Object?>)[10]!
            as Map<String, Object?>)['correctValues'] = [
          {
            'cellId': 'cell-president-legitimacy',
            'optionId': 'option-legitimacy-election',
          },
        ];
        final explanationLeak = richClosedV1CExerciseJson();
        ((explanationLeak['questions']! as List<Object?>)[10]!
                as Map<String, Object?>)['explanation'] =
            'Ne doit pas être visible en pré-submit.';

        expectParseError(() => RichClosedExercise.fromJson(correctValuesLeak));
        expectParseError(() => RichClosedExercise.fromJson(explanationLeak));
      },
    );

    test(
      'rejects diagram_labeling public questions carrying private or render fields',
      () {
        for (final field in [
          'correctValues',
          'explanation',
          'html',
          'svg',
          'rawSvg',
          'mermaid',
          'markdown',
          'widget',
          'component',
          'render',
          'renderPayload',
          'style',
          'css',
          'script',
          'imageUrl',
          'assetUrl',
          'canvas',
          'code',
          'eval',
          'Function',
          'function',
          'markup',
        ]) {
          final payload = richClosedV1CFullExerciseJson();
          ((payload['questions']! as List<Object?>)[11]!
              as Map<String, Object?>)[field] = field == 'correctValues'
              ? [
                  {
                    'slotId': 'slot-government-role',
                    'optionId': 'option-government',
                  },
                ]
              : 'forbidden';

          expectParseError(() => RichClosedExercise.fromJson(payload));
        }
      },
    );

    test(
      'rejects calculation_mcq public questions carrying private or formula fields',
      () {
        for (final field in [
          'correctChoiceId',
          'expectedValue',
          'workedSteps',
          'explanation',
          'formula',
          'expression',
          'rawFormula',
          'calculationCode',
          'javascript',
          'python',
          'render',
          'renderPayload',
          'code',
          'eval',
          'Function',
          'function',
        ]) {
          final payload = richClosedV1CCalculationExerciseJson();
          ((payload['questions']! as List<Object?>)[12]!
              as Map<String, Object?>)[field] = field == 'workedSteps'
              ? [
                  {'id': 'step-1', 'label': 'Étape', 'detail': 'Privé'},
                ]
              : 'forbidden';

          expectParseError(() => RichClosedExercise.fromJson(payload));
        }
      },
    );

    test('rejects incoherent calculation_mcq public contracts', () {
      final badMode = richClosedV1CCalculationExerciseJson();
      final badModeQuestion =
          (badMode['questions']! as List<Object?>)[12]! as Map<String, Object?>;
      badModeQuestion['calculation'] = {'mode': 'dhondt_highest_average'};

      final duplicateChoiceValue = richClosedV1CCalculationExerciseJson();
      final duplicateQuestion =
          (duplicateChoiceValue['questions']! as List<Object?>)[12]!
              as Map<String, Object?>;
      ((duplicateQuestion['choices']! as List<Object?>)[1]!
              as Map<String, Object?>)['value'] =
          288;

      final badTarget = richClosedExerciseJson();
      final remainderQuestion =
          richClosedCalculationLargestRemainderQuestionJson();
      final remainderCalculation =
          remainderQuestion['calculation']! as Map<String, Object?>;
      remainderCalculation['targetPartyId'] = 'party-unknown';
      badTarget['questions'] = [remainderQuestion];

      expectParseError(() => RichClosedExercise.fromJson(badMode));
      expectParseError(() => RichClosedExercise.fromJson(duplicateChoiceValue));
      expectParseError(() => RichClosedExercise.fromJson(badTarget));
    });

    test('rejects diagram_labeling incoherent diagram references', () {
      final badEdge = richClosedV1CFullExerciseJson();
      final badEdgeQuestion =
          (badEdge['questions']! as List<Object?>)[11]! as Map<String, Object?>;
      final badEdgeDiagram =
          badEdgeQuestion['diagram']! as Map<String, Object?>;
      ((badEdgeDiagram['edges']! as List<Object?>).first!
              as Map<String, Object?>)['fromNodeId'] =
          'node-unknown';

      final badGroup = richClosedV1CFullExerciseJson();
      final badGroupQuestion =
          (badGroup['questions']! as List<Object?>)[11]!
              as Map<String, Object?>;
      final badGroupDiagram =
          badGroupQuestion['diagram']! as Map<String, Object?>;
      ((badGroupDiagram['nodes']! as List<Object?>).first!
              as Map<String, Object?>)['groupId'] =
          'group-unknown';

      expectParseError(() => RichClosedExercise.fromJson(badEdge));
      expectParseError(() => RichClosedExercise.fromJson(badGroup));
    });

    test('rejects diagram_labeling slots with unknown anchors', () {
      final badNodeAnchor = richClosedV1CFullExerciseJson();
      final badNodeQuestion =
          (badNodeAnchor['questions']! as List<Object?>)[11]!
              as Map<String, Object?>;
      ((badNodeQuestion['slots']! as List<Object?>).first!
              as Map<String, Object?>)['anchorId'] =
          'node-unknown';

      final badEdgeAnchor = richClosedV1CFullExerciseJson();
      final badEdgeQuestion =
          (badEdgeAnchor['questions']! as List<Object?>)[11]!
              as Map<String, Object?>;
      final slot =
          (badEdgeQuestion['slots']! as List<Object?>).first!
              as Map<String, Object?>;
      slot['anchorType'] = 'edge';
      slot['anchorId'] = 'edge-unknown';

      expectParseError(() => RichClosedExercise.fromJson(badNodeAnchor));
      expectParseError(() => RichClosedExercise.fromJson(badEdgeAnchor));
    });

    test('rejects institution_matrix cells with unknown axis references', () {
      final badRow = richClosedV1CExerciseJson();
      final badRowQuestion =
          (badRow['questions']! as List<Object?>)[10]! as Map<String, Object?>;
      ((badRowQuestion['cells']! as List<Object?>).first!
              as Map<String, Object?>)['rowId'] =
          'row-unknown';
      final badColumn = richClosedV1CExerciseJson();
      final badColumnQuestion =
          (badColumn['questions']! as List<Object?>)[10]!
              as Map<String, Object?>;
      ((badColumnQuestion['cells']! as List<Object?>).first!
              as Map<String, Object?>)['columnId'] =
          'column-unknown';

      expectParseError(() => RichClosedExercise.fromJson(badRow));
      expectParseError(() => RichClosedExercise.fromJson(badColumn));
    });

    test(
      'rejects institution_matrix cells with duplicate row/column slots',
      () {
        final payload = richClosedV1CExerciseJson();
        final question =
            (payload['questions']! as List<Object?>)[10]!
                as Map<String, Object?>;
        final cells = question['cells']! as List<Object?>;
        final firstCell = cells[0]! as Map<String, Object?>;
        final secondCell = cells[1]! as Map<String, Object?>;
        secondCell['rowId'] = firstCell['rowId'];
        secondCell['columnId'] = firstCell['columnId'];

        expectParseError(() => RichClosedExercise.fromJson(payload));
      },
    );
  });

  group('RichClosedAnswer submit DTO', () {
    test('serializes each V1-A answer shape', () {
      expect(
        const RichClosedSingleChoiceAnswer(
          questionId: 'single-1',
          choiceId: 'choice-a',
        ).toJson(),
        {
          'questionId': 'single-1',
          'questionKind': 'single_choice',
          'choiceId': 'choice-a',
        },
      );
      expect(
        const RichClosedMultipleChoiceAnswer(
          questionId: 'multiple-1',
          choiceIds: ['choice-a', 'choice-b'],
        ).toJson(),
        {
          'questionId': 'multiple-1',
          'questionKind': 'multiple_choice',
          'choiceIds': ['choice-a', 'choice-b'],
        },
      );
      expect(
        const RichClosedMatchingAnswer(
          questionId: 'matching-1',
          pairs: [RichClosedPair(leftId: 'left-1', rightId: 'right-1')],
        ).toJson(),
        {
          'questionId': 'matching-1',
          'questionKind': 'matching',
          'pairs': [
            {'leftId': 'left-1', 'rightId': 'right-1'},
          ],
        },
      );
      expect(
        const RichClosedOrderingAnswer(
          questionId: 'ordering-1',
          orderedIds: ['item-1', 'item-2'],
        ).toJson(),
        {
          'questionId': 'ordering-1',
          'questionKind': 'ordering',
          'orderedIds': ['item-1', 'item-2'],
        },
      );
      expect(
        const RichClosedCaseQualificationAnswer(
          questionId: 'case-1',
          choiceId: 'choice-a',
        ).toJson(),
        {
          'questionId': 'case-1',
          'questionKind': 'case_qualification',
          'choiceId': 'choice-a',
        },
      );
      expect(
        const RichClosedErrorDetectionAnswer(
          questionId: 'error-1',
          errorId: 'error-a',
        ).toJson(),
        {
          'questionId': 'error-1',
          'questionKind': 'error_detection',
          'errorId': 'error-a',
        },
      );
      expect(
        const RichClosedTimelineAnswer(
          questionId: 'timeline-1',
          orderedEventIds: ['event-1', 'event-2', 'event-3'],
        ).toJson(),
        {
          'questionId': 'timeline-1',
          'questionKind': 'timeline',
          'orderedEventIds': ['event-1', 'event-2', 'event-3'],
        },
      );
      expect(
        const RichClosedDateSliderAnswer(
          questionId: 'date-slider-1',
          year: 1958,
        ).toJson(),
        {
          'questionId': 'date-slider-1',
          'questionKind': 'date_slider',
          'year': 1958,
        },
      );
      expect(
        const RichClosedTrueFalseGridAnswer(
          questionId: 'true-false-grid-1',
          values: [
            RichClosedTrueFalseGridValue(rowId: 'row-1', value: true),
            RichClosedTrueFalseGridValue(rowId: 'row-2', value: false),
          ],
        ).toJson(),
        {
          'questionId': 'true-false-grid-1',
          'questionKind': 'true_false_grid',
          'values': [
            {'rowId': 'row-1', 'value': true},
            {'rowId': 'row-2', 'value': false},
          ],
        },
      );
      expect(
        const RichClosedCauseConsequenceAnswer(
          questionId: 'cause-consequence-1',
          pairs: [
            RichClosedCauseConsequencePair(
              causeId: 'cause-1',
              consequenceId: 'consequence-1',
            ),
          ],
        ).toJson(),
        {
          'questionId': 'cause-consequence-1',
          'questionKind': 'cause_consequence',
          'pairs': [
            {'causeId': 'cause-1', 'consequenceId': 'consequence-1'},
          ],
        },
      );
      expect(
        const RichClosedInstitutionMatrixAnswer(
          questionId: 'institution-matrix-1',
          values: [
            RichClosedInstitutionMatrixValue(
              cellId: 'cell-president-legitimacy',
              optionId: 'option-legitimacy-election',
            ),
          ],
        ).toJson(),
        {
          'questionId': 'institution-matrix-1',
          'questionKind': 'institution_matrix',
          'values': [
            {
              'cellId': 'cell-president-legitimacy',
              'optionId': 'option-legitimacy-election',
            },
          ],
        },
      );
      expect(
        const RichClosedDiagramLabelingAnswer(
          questionId: 'diagram-labeling-1',
          values: [
            RichClosedDiagramLabelingValue(
              slotId: 'slot-government-role',
              optionId: 'option-government',
            ),
          ],
        ).toJson(),
        {
          'questionId': 'diagram-labeling-1',
          'questionKind': 'diagram_labeling',
          'values': [
            {'slotId': 'slot-government-role', 'optionId': 'option-government'},
          ],
        },
      );
      expect(
        const RichClosedCalculationMcqAnswer(
          questionId: 'calculation-mcq-majority-1',
          choiceId: 'choice-289',
        ).toJson(),
        {
          'questionId': 'calculation-mcq-majority-1',
          'questionKind': 'calculation_mcq',
          'choiceId': 'choice-289',
        },
      );
    });

    test('serializes submit wrapper without correction or free text', () {
      final json = const RichClosedExerciseSubmission(
        answers: [
          RichClosedSingleChoiceAnswer(
            questionId: 'single-1',
            choiceId: 'choice-a',
          ),
        ],
      ).toJson();
      final serialized = json.toString();

      expect(json, {
        'answers': [
          {
            'questionId': 'single-1',
            'questionKind': 'single_choice',
            'choiceId': 'choice-a',
          },
        ],
      });
      expect(serialized, isNot(contains('correct')));
      expect(serialized, isNot(contains('answerText')));
      expect(serialized, isNot(contains('feedback')));
    });

    test('rejects forbidden formula and render fields in parsed answers', () {
      for (final field in [
        'correctChoiceId',
        'expectedValue',
        'workedSteps',
        'render',
        'renderPayload',
        'code',
        'eval',
        'Function',
        'function',
        'formula',
        'expression',
      ]) {
        expectParseError(
          () => RichClosedAnswer.fromJson({
            'questionId': 'calculation-mcq-majority-1',
            'questionKind': 'calculation_mcq',
            'choiceId': 'choice-289',
            field: field == 'workedSteps'
                ? [
                    {'id': 'step-1', 'label': 'Étape', 'detail': 'Privé'},
                  ]
                : 'forbidden',
          }),
        );
      }
    });
  });

  group('RichClosedExerciseResult parsing', () {
    test('parses a complete post-submit result from backend score', () {
      final result = RichClosedExerciseResult.fromJson(richClosedResultJson());

      expect(result.sessionId, 'rich-session-1');
      expect(result.type, richClosedExerciseType);
      expect(result.status, 'completed');
      expect(result.correctAnswers, 5);
      expect(result.totalQuestions, 6);
      expect(result.score, 0.833);
      expect(result.items, hasLength(6));
      expect(result.items.last.isCorrect, isFalse);
    });

    test('parses submitted answers and all correction payload forms', () {
      final result = RichClosedExerciseResult.fromJson(richClosedResultJson());

      expect(
        result.items[0].submittedAnswer,
        isA<RichClosedSingleChoiceAnswer>(),
      );
      expect(
        result.items[0].correction,
        isA<RichClosedCorrectChoiceIdCorrection>(),
      );
      expect(
        result.items[1].correction,
        isA<RichClosedCorrectChoiceIdsCorrection>(),
      );
      expect(
        result.items[2].correction,
        isA<RichClosedCorrectPairsCorrection>(),
      );
      expect(
        result.items[3].correction,
        isA<RichClosedCorrectOrderCorrection>(),
      );
      expect(
        result.items[5].correction,
        isA<RichClosedCorrectErrorIdCorrection>(),
      );
    });

    test('parses timeline and date_slider post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1BResultJson(),
      );
      final timeline = result.items[6];
      final dateSlider = result.items[7];

      expect(timeline.submittedAnswer, isA<RichClosedTimelineAnswer>());
      expect(timeline.correction, isA<RichClosedCorrectOrderCorrection>());
      expect(
        (timeline.correction as RichClosedCorrectOrderCorrection).correctOrder,
        ['event-1', 'event-2', 'event-3'],
      );
      expect(dateSlider.submittedAnswer, isA<RichClosedDateSliderAnswer>());
      expect(dateSlider.correction, isA<RichClosedCorrectYearCorrection>());
      expect(
        (dateSlider.correction as RichClosedCorrectYearCorrection).correctYear,
        1958,
      );
    });

    test(
      'parses true_false_grid and cause_consequence post-submit corrections',
      () {
        final result = RichClosedExerciseResult.fromJson(
          richClosedV1BFullResultJson(),
        );
        final trueFalse = result.items[8];
        final causeConsequence = result.items[9];

        expect(trueFalse.submittedAnswer, isA<RichClosedTrueFalseGridAnswer>());
        expect(
          trueFalse.correction,
          isA<RichClosedCorrectTrueFalseValuesCorrection>(),
        );
        expect(
          (trueFalse.correction as RichClosedCorrectTrueFalseValuesCorrection)
              .correctValues
              .map((value) => '${value.rowId}:${value.value}'),
          ['row-1:true', 'row-2:false', 'row-3:true'],
        );
        expect(
          causeConsequence.submittedAnswer,
          isA<RichClosedCauseConsequenceAnswer>(),
        );
        expect(
          causeConsequence.correction,
          isA<RichClosedCorrectCauseConsequencePairsCorrection>(),
        );
        expect(
          (causeConsequence.correction
                  as RichClosedCorrectCauseConsequencePairsCorrection)
              .correctPairs
              .map((pair) => '${pair.causeId}:${pair.consequenceId}'),
          [
            'cause-1:consequence-1',
            'cause-2:consequence-2',
            'cause-3:consequence-3',
          ],
        );
      },
    );

    test('parses institution_matrix post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1CResultJson(),
      );
      final matrix = result.items[10];

      expect(matrix.submittedAnswer, isA<RichClosedInstitutionMatrixAnswer>());
      expect(
        (matrix.submittedAnswer as RichClosedInstitutionMatrixAnswer).values
            .map((value) => '${value.cellId}:${value.optionId}'),
        [
          'cell-president-legitimacy:option-legitimacy-election',
          'cell-government-responsibility:option-responsibility-assembly',
          'cell-assembly-action:option-action-censure',
        ],
      );
      expect(
        matrix.correction,
        isA<RichClosedCorrectInstitutionMatrixValuesCorrection>(),
      );
      expect(
        (matrix.correction
                as RichClosedCorrectInstitutionMatrixValuesCorrection)
            .correctValues
            .map((value) => '${value.cellId}:${value.optionId}'),
        [
          'cell-president-legitimacy:option-legitimacy-election',
          'cell-government-responsibility:option-responsibility-assembly',
          'cell-assembly-action:option-action-censure',
        ],
      );
    });

    test('parses diagram_labeling post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1CFullResultJson(),
      );
      final diagram = result.items[11];

      expect(diagram.submittedAnswer, isA<RichClosedDiagramLabelingAnswer>());
      expect(
        (diagram.submittedAnswer as RichClosedDiagramLabelingAnswer).values.map(
          (value) => '${value.slotId}:${value.optionId}',
        ),
        [
          'slot-government-role:option-government',
          'slot-censure:option-motion-censure',
          'slot-nomination:option-nomination',
        ],
      );
      expect(
        diagram.correction,
        isA<RichClosedCorrectDiagramLabelingValuesCorrection>(),
      );
      expect(
        (diagram.correction as RichClosedCorrectDiagramLabelingValuesCorrection)
            .correctValues
            .map((value) => '${value.slotId}:${value.optionId}'),
        [
          'slot-government-role:option-government',
          'slot-censure:option-motion-censure',
          'slot-nomination:option-nomination',
        ],
      );
    });

    test('parses calculation_mcq post-submit corrections', () {
      final result = RichClosedExerciseResult.fromJson(
        richClosedV1CCalculationResultJson(),
      );
      final calculation = result.items[12];

      expect(
        calculation.submittedAnswer,
        isA<RichClosedCalculationMcqAnswer>(),
      );
      expect(
        (calculation.submittedAnswer as RichClosedCalculationMcqAnswer)
            .choiceId,
        'choice-289',
      );
      expect(
        calculation.correction,
        isA<RichClosedCorrectCalculationMcqCorrection>(),
      );

      final correction =
          calculation.correction as RichClosedCorrectCalculationMcqCorrection;
      expect(correction.correctChoiceId, 'choice-289');
      expect(correction.expectedValue, 289);
      expect(correction.workedSteps.map((step) => step.id), [
        'valid-votes',
        'majority-rule',
        'threshold',
      ]);
    });

    test('rejects absent or incoherent correction payloads', () {
      final missing = richClosedResultJson();
      final item =
          (missing['items']! as List<Object?>).first! as Map<String, Object?>;
      item.remove('correction');
      expectParseError(() => RichClosedExerciseResult.fromJson(missing));

      expectParseError(
        () => RichClosedExerciseResult.fromJson(
          richClosedResultWithIncoherentCorrection(),
        ),
      );
    });

    test('rejects invalid result envelope and score', () {
      final wrongStatus = richClosedResultJson()..['status'] = 'pending';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongStatus));

      final wrongType = richClosedResultJson()..['type'] = 'open_question';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongType));

      final wrongScore = richClosedResultJson()..['score'] = '0.8';
      expectParseError(() => RichClosedExerciseResult.fromJson(wrongScore));
    });
  });
}

void expectParseError(Object? Function() parse) {
  expect(parse, throwsA(isA<RichClosedExerciseParseException>()));
}

~~~
