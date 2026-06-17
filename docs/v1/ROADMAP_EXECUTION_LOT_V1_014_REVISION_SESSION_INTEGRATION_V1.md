# LOT V1-014 — Revision session integration V1

## Statut

Réalisé côté Flutter. La page de session de révision sait maintenant lire une action bornée `rich_closed_exercise`, afficher un lanceur métier et naviguer vers la page rich closed existante.

La session ne rend pas les questions rich closed, ne rend pas de payload arbitraire et ne montre aucune correction pré-submit. Le démarrage effectif reste dans le flow `/activities/rich-closed`.

## Comportement livré

- Modèle `RevisionSessionActionKind.richClosedExercise` et payload `RevisionSessionRichClosedExercisePayload`.
- `RevisionSessionPreferredAction.richClosedExercise` sérialisé en `rich_closed_exercise`.
- Parser HTTP strict côté session : un payload rich closed contenant déjà `questions`, `answers`, `correction`, `correctAnswers` ou `score` est rejeté en payload inconnu.
- Carte de session `Questions riches` avec contexte notion, raison, durée estimée et bouton `Commencer`.
- Navigation vers `/activities/rich-closed` avec `subjectId`, `documentId` optionnel et `knowledgeUnitId`.
- Router compatible avec `preferredAction=rich_closed_exercise`.

## Validations

- `dart format <fichiers touchés>` : réussi.
- `dart analyze lib test` : réussi, no issues found.
- `flutter test test/features/revision_sessions --reporter compact` : réussi, 21 tests.
- `flutter test test/app/router --reporter compact` : réussi, 11 tests.
- `flutter test --reporter compact` : réussi, all tests passed.
- `git diff --check` : réussi.

Note validation : un premier lancement parallèle de deux commandes Flutter a déclenché un crash outil sur le lock/ephemeral iOS (`FileSystemException ... ios/Flutter/ephemeral/Packages/.packages`). Les suites ont ensuite été relancées séquentiellement et réussissent.

## Fichiers touchés

- `docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/features/revision_sessions/data/revision_sessions_api.dart`
- `lib/features/revision_sessions/data/http_revision_sessions_api.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/app/router/app_router.dart`
- `test/fakes/in_memory_revision_sessions_api.dart`
- `test/features/revision_sessions/revision_session_controller_test.dart`
- `test/features/revision_sessions/http_revision_sessions_api_test.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`
- `test/app/router/app_router_test.dart`

Le présent rapport est créé dans `docs/v1/ROADMAP_EXECUTION_LOT_V1_014_REVISION_SESSION_INTEGRATION_V1.md`. Son contenu n’est pas recopié récursivement dans lui-même afin d’éviter une expansion infinie.

## Contenu complet des fichiers touchés

### docs/v1/ROADMAP_EXECUTION_PLAN_V1.md

```md
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
```

### lib/features/revision_sessions/domain/revision_session.dart

```dart
import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';

class RevisionSession {
  const RevisionSession({
    required this.id,
    required this.status,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final RevisionSessionStatus status;
  final String subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final DateTime createdAt;
  final DateTime? completedAt;
}

enum RevisionSessionStatus { started, completed, abandoned, unknown }

class RevisionSessionAction {
  const RevisionSessionAction({
    required this.id,
    required this.kind,
    required this.status,
    required this.displayOrder,
    required this.activitySessionId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.payload,
  });

  final String id;
  final RevisionSessionActionKind kind;
  final RevisionSessionActionStatus status;
  final int displayOrder;
  final String? activitySessionId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionActionPayload? payload;
}

enum RevisionSessionActionKind {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
  unknown,
}

enum RevisionSessionActionStatus { ready, completed, failed, unknown }

class RevisionSessionResponse {
  const RevisionSessionResponse({
    required this.session,
    required this.currentAction,
    required this.history,
  });

  final RevisionSession session;
  final RevisionSessionAction? currentAction;
  final List<RevisionSessionAction> history;
}

sealed class RevisionSessionActionPayload {
  const RevisionSessionActionPayload();
}

class RevisionSessionDiagnosticQuizPayload
    extends RevisionSessionActionPayload {
  const RevisionSessionDiagnosticQuizPayload(this.activity);

  final DiagnosticQuizActivity activity;
}

class RevisionSessionOpenQuestionPayload extends RevisionSessionActionPayload {
  const RevisionSessionOpenQuestionPayload(this.activity);

  final OpenQuestionActivity activity;
}

class RevisionSessionRichClosedExercisePayload
    extends RevisionSessionActionPayload {
  const RevisionSessionRichClosedExercisePayload({
    required this.subjectId,
    required this.knowledgeUnitId,
    required this.reason,
    required this.estimatedMinutes,
    this.documentId,
    this.knowledgeUnitTitle,
    this.preferredAction,
  });

  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final String? knowledgeUnitTitle;
  final String reason;
  final int estimatedMinutes;
  final String? preferredAction;
}

class RevisionSessionMinimalPayload extends RevisionSessionActionPayload {
  const RevisionSessionMinimalPayload({required this.type, this.sessionId});

  final String type;
  final String? sessionId;
}

class RevisionSessionUnknownPayload extends RevisionSessionActionPayload {
  const RevisionSessionUnknownPayload();
}
```

### lib/features/revision_sessions/data/revision_sessions_api.dart

```dart
import '../domain/revision_session.dart';

enum RevisionSessionPreferredAction {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
}

abstract interface class RevisionSessionsApi {
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  });

  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  });
}
```

### lib/features/revision_sessions/data/http_revision_sessions_api.dart

```dart
import 'package:dio/dio.dart';

import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';
import '../domain/revision_session.dart';
import 'revision_sessions_api.dart';

class HttpRevisionSessionsApi implements RevisionSessionsApi {
  HttpRevisionSessionsApi({
    required Dio dio,
    required Future<String> Function() getIdToken,
  }) : this._(dio, getIdToken);

  const HttpRevisionSessionsApi._(this._dio, this._getIdToken);

  final Dio _dio;
  final Future<String> Function() _getIdToken;

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    final data = <String, Object?>{'subjectId': subjectId};
    if (documentId != null) {
      data['documentId'] = documentId;
    }
    if (knowledgeUnitId != null) {
      data['knowledgeUnitId'] = knowledgeUnitId;
    }
    if (preferredAction != null) {
      data['preferredAction'] = _preferredActionJson(preferredAction);
    }

    final response = await _dio.post<Object?>(
      '/revision-sessions',
      data: data,
      options: await _authorizedOptions(),
    );

    return _RevisionSessionResponseJson(response.data).toResponse();
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    final response = await _dio.get<Object?>(
      '/revision-sessions/$sessionId',
      options: await _authorizedOptions(),
    );

    return _RevisionSessionResponseJson(response.data).toResponse();
  }

  Future<Options> _authorizedOptions() async {
    final token = (await _getIdToken()).trim();

    if (token.isEmpty) {
      throw StateError('A Firebase ID token is required for revision sessions');
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _preferredActionJson(RevisionSessionPreferredAction action) {
    return switch (action) {
      RevisionSessionPreferredAction.diagnosticQuiz => 'diagnostic_quiz',
      RevisionSessionPreferredAction.openQuestion => 'open_question',
      RevisionSessionPreferredAction.richClosedExercise =>
        'rich_closed_exercise',
    };
  }
}

class _RevisionSessionResponseJson {
  const _RevisionSessionResponseJson(this.value);

  final Object? value;

  RevisionSessionResponse toResponse() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session response');
    }

    final session = json['session'];
    final currentAction = json['currentAction'];
    final history = json['history'];

    if (session is! Map<String, Object?> || history is! List) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSessionResponse(
      session: _RevisionSessionJson(session).toSession(),
      currentAction: currentAction == null
          ? null
          : _RevisionSessionActionJson(
              currentAction,
              allowPayload: true,
            ).toAction(),
      history: history
          .map(
            (action) => _RevisionSessionActionJson(
              action,
              allowPayload: false,
            ).toAction(),
          )
          .toList(growable: false),
    );
  }
}

class _RevisionSessionJson {
  const _RevisionSessionJson(this.value);

  final Map<String, Object?> value;

  RevisionSession toSession() {
    final id = value['id'];
    final status = value['status'];
    final subjectId = value['subjectId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final createdAt = value['createdAt'];
    final completedAt = value['completedAt'];

    if (id is! String ||
        status is! String ||
        subjectId is! String ||
        createdAt is! String) {
      throw const FormatException('Invalid revision session response');
    }

    return RevisionSession(
      id: id,
      status: _sessionStatus(status),
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      createdAt: DateTime.parse(createdAt),
      completedAt: completedAt is String ? DateTime.parse(completedAt) : null,
    );
  }

  RevisionSessionStatus _sessionStatus(String status) {
    return switch (status) {
      'STARTED' => RevisionSessionStatus.started,
      'COMPLETED' => RevisionSessionStatus.completed,
      'ABANDONED' => RevisionSessionStatus.abandoned,
      _ => RevisionSessionStatus.unknown,
    };
  }
}

class _RevisionSessionActionJson {
  const _RevisionSessionActionJson(this.value, {required this.allowPayload});

  final Object? value;
  final bool allowPayload;

  RevisionSessionAction toAction() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision session action response');
    }

    final id = json['id'];
    final kind = json['kind'];
    final status = json['status'];
    final displayOrder = json['displayOrder'];
    final activitySessionId = json['activitySessionId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];

    if (id is! String ||
        kind is! String ||
        status is! String ||
        displayOrder is! int) {
      throw const FormatException('Invalid revision session action response');
    }

    return RevisionSessionAction(
      id: id,
      kind: _actionKind(kind),
      status: _actionStatus(status),
      displayOrder: displayOrder,
      activitySessionId: activitySessionId is String ? activitySessionId : null,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId is String ? knowledgeUnitId : null,
      payload: allowPayload
          ? _ActionPayloadJson(json['payload']).toPayload()
          : null,
    );
  }

  RevisionSessionActionKind _actionKind(String kind) {
    return switch (kind) {
      'DIAGNOSTIC_QUIZ' => RevisionSessionActionKind.diagnosticQuiz,
      'OPEN_QUESTION' => RevisionSessionActionKind.openQuestion,
      'RICH_CLOSED_EXERCISE' => RevisionSessionActionKind.richClosedExercise,
      _ => RevisionSessionActionKind.unknown,
    };
  }

  RevisionSessionActionStatus _actionStatus(String status) {
    return switch (status) {
      'READY' => RevisionSessionActionStatus.ready,
      'COMPLETED' => RevisionSessionActionStatus.completed,
      'FAILED' => RevisionSessionActionStatus.failed,
      _ => RevisionSessionActionStatus.unknown,
    };
  }
}

class _ActionPayloadJson {
  const _ActionPayloadJson(this.value);

  final Object? value;

  RevisionSessionActionPayload? toPayload() {
    final json = value;
    if (json == null) {
      return null;
    }

    if (json is! Map<String, Object?>) {
      return const RevisionSessionUnknownPayload();
    }

    final type = json['type'];
    if (type == 'diagnostic_quiz') {
      return _diagnosticQuizPayload(json);
    }
    if (type == 'open_question') {
      return _openQuestionPayload(json);
    }
    if (type == 'rich_closed_exercise') {
      return _richClosedExercisePayload(json);
    }

    return const RevisionSessionUnknownPayload();
  }

  RevisionSessionActionPayload _diagnosticQuizPayload(
    Map<String, Object?> json,
  ) {
    if (json['questions'] is List && json['title'] is String) {
      try {
        return RevisionSessionDiagnosticQuizPayload(
          _DiagnosticQuizActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'diagnostic_quiz',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _openQuestionPayload(Map<String, Object?> json) {
    if (json['question'] is Map<String, Object?>) {
      try {
        return RevisionSessionOpenQuestionPayload(
          _OpenQuestionActivityJson(json).toActivity(),
        );
      } on FormatException {
        return const RevisionSessionUnknownPayload();
      }
    }

    return RevisionSessionMinimalPayload(
      type: 'open_question',
      sessionId: json['sessionId'] is String
          ? json['sessionId'] as String
          : null,
    );
  }

  RevisionSessionActionPayload _richClosedExercisePayload(
    Map<String, Object?> json,
  ) {
    if (_containsRichClosedExerciseContent(json)) {
      return const RevisionSessionUnknownPayload();
    }

    final subjectId = json['subjectId'];
    final documentId = json['documentId'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final knowledgeUnitTitle = json['knowledgeUnitTitle'];
    final reason = json['reason'];
    final estimatedMinutes = json['estimatedMinutes'];
    final preferredAction = json['preferredAction'];

    if (subjectId is! String || knowledgeUnitId is! String) {
      return const RevisionSessionUnknownPayload();
    }

    return RevisionSessionRichClosedExercisePayload(
      subjectId: subjectId,
      documentId: documentId is String ? documentId : null,
      knowledgeUnitId: knowledgeUnitId,
      knowledgeUnitTitle: knowledgeUnitTitle is String
          ? knowledgeUnitTitle
          : null,
      reason: reason is String ? reason : 'Questions riches recommandées.',
      estimatedMinutes: estimatedMinutes is int ? estimatedMinutes : 8,
      preferredAction: preferredAction is String ? preferredAction : null,
    );
  }

  bool _containsRichClosedExerciseContent(Map<String, Object?> json) {
    return json.containsKey('questions') ||
        json.containsKey('answers') ||
        json.containsKey('correction') ||
        json.containsKey('correctAnswers') ||
        json.containsKey('score');
  }
}

class _DiagnosticQuizActivityJson {
  const _DiagnosticQuizActivityJson(this.value);

  final Map<String, Object?> value;

  DiagnosticQuizActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final title = value['title'];
    final documentId = value['documentId'];
    final subjectId = value['subjectId'];
    final questions = value['questions'];

    if (sessionId is! String || title is! String || questions is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizActivity(
      sessionId: sessionId,
      type: type is String ? type : 'diagnostic_quiz',
      version: version is int ? version : null,
      title: title,
      documentId: documentId is String ? documentId : null,
      subjectId: subjectId is String ? subjectId : null,
      questions: questions
          .map((question) => _DiagnosticQuizQuestionJson(question).toQuestion())
          .toList(growable: false),
    );
  }
}

class _DiagnosticQuizQuestionJson {
  const _DiagnosticQuizQuestionJson(this.value);

  final Object? value;

  DiagnosticQuizQuestion toQuestion() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final knowledgeUnitId = json['knowledgeUnitId'];
    final prompt = json['prompt'];
    final difficulty = json['difficulty'];
    final choices = json['choices'];
    final sources = json['sources'];
    final visuals = json['visuals'];

    if (id is! String || prompt is! String || choices is! List) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedChoices = choices
        .map((choice) => _DiagnosticQuizChoiceJson(choice).toChoice())
        .toList(growable: false);
    final selectionMode = _selectionMode(json['selectionMode']);
    final minSelections = _selectionCount(json['minSelections'], fallback: 1);
    final maxSelections = _selectionCount(
      json['maxSelections'],
      fallback: selectionMode == DiagnosticQuizSelectionMode.multiple
          ? parsedChoices.length
          : 1,
    );

    if (selectionMode == DiagnosticQuizSelectionMode.multiple &&
        (minSelections < 1 ||
            maxSelections < minSelections ||
            maxSelections > parsedChoices.length)) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final parsedVisuals = <DiagnosticQuizVisual>[];
    if (visuals is List) {
      parsedVisuals.addAll([
        for (final (index, visual) in visuals.indexed)
          _DiagnosticQuizVisualJson(visual, index).toVisual(),
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
                .map(
                  (source) =>
                      _DiagnosticQuizSourceRefJson(source).toSourceRef(),
                )
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

    throw const FormatException('Invalid revision quiz payload');
  }

  int _selectionCount(Object? value, {required int fallback}) {
    if (value == null) {
      return fallback;
    }

    if (value is int) {
      return value;
    }

    throw const FormatException('Invalid revision quiz payload');
  }
}

class _DiagnosticQuizChoiceJson {
  const _DiagnosticQuizChoiceJson(this.value);

  final Object? value;

  DiagnosticQuizChoice toChoice() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];

    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizChoice(id: id, label: label);
  }
}

class _DiagnosticQuizVisualJson {
  const _DiagnosticQuizVisualJson(this.value, this.fallbackIndex);

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

    throw const FormatException('Invalid revision quiz payload');
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

    throw const FormatException('Invalid revision quiz payload');
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
      _ => throw const FormatException('Invalid revision quiz payload'),
    };
  }

  Map<String, Object?> _chartRow(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return json.map((key, value) {
      if (value == null || value is String || value is num) {
        return MapEntry(key, value);
      }

      throw const FormatException('Invalid revision quiz payload');
    });
  }

  DiagnosticQuizDiagramNode _diagramNode(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final id = json['id'];
    final label = json['label'];
    if (id is! String || label is! String) {
      throw const FormatException('Invalid revision quiz payload');
    }

    return DiagnosticQuizDiagramNode(id: id, label: label);
  }

  DiagnosticQuizDiagramEdge _diagramEdge(Object? value) {
    final json = value;
    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz payload');
    }

    final from = json['from'];
    final to = json['to'];
    final label = json['label'];
    if (from is! String || to is! String) {
      throw const FormatException('Invalid revision quiz payload');
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

          throw const FormatException('Invalid revision quiz payload');
        })
        .toList(growable: false);
  }

  List<DiagnosticQuizSourceRef> _sourceRefs(List<Object?> values) {
    return values
        .map((source) => _DiagnosticQuizSourceRefJson(source).toSourceRef())
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

class _DiagnosticQuizSourceRefJson {
  const _DiagnosticQuizSourceRefJson(this.value);

  final Object? value;

  DiagnosticQuizSourceRef toSourceRef() {
    final json = value;

    if (json is! Map<String, Object?>) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException('Invalid revision quiz source payload');
    }

    return DiagnosticQuizSourceRef(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}

class _OpenQuestionActivityJson {
  const _OpenQuestionActivityJson(this.value);

  final Map<String, Object?> value;

  OpenQuestionActivity toActivity() {
    final sessionId = value['sessionId'];
    final type = value['type'];
    final version = value['version'];
    final subjectId = value['subjectId'];
    final documentId = value['documentId'];
    final knowledgeUnitId = value['knowledgeUnitId'];
    final question = value['question'];

    if (sessionId is! String ||
        type != 'open_question' ||
        subjectId is! String ||
        knowledgeUnitId is! String ||
        question is! Map<String, Object?>) {
      throw const FormatException('Invalid revision open question payload');
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
      throw const FormatException('Invalid revision open question payload');
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
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    final chunkId = json['chunkId'];
    final pageNumber = json['pageNumber'];
    final index = json['index'];

    if (chunkId is! String || index is! int) {
      throw const FormatException(
        'Invalid revision open question source payload',
      );
    }

    return OpenQuestionSource(
      chunkId: chunkId,
      pageNumber: pageNumber is int ? pageNumber : null,
      index: index,
    );
  }
}
```

### lib/presentation/pages/revision_sessions/revision_session_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';
import 'package:revision_app/core/routing/route_paths.dart';
import 'package:revision_app/presentation/pages/activities/diagnostic_quiz_page.dart';
import 'package:revision_app/presentation/pages/activities/open_question_page.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class RevisionSessionPage extends StatefulWidget {
  const RevisionSessionPage({
    required this.revisionSessionController,
    required this.activityController,
    this.sessionId,
    this.subjectId,
    this.documentId,
    this.knowledgeUnitId,
    this.preferredAction,
    super.key,
  });

  final RevisionSessionController revisionSessionController;
  final ActivityController activityController;
  final String? sessionId;
  final String? subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionPreferredAction? preferredAction;

  @override
  State<RevisionSessionPage> createState() => _RevisionSessionPageState();
}

class _RevisionSessionPageState extends State<RevisionSessionPage> {
  Future<RevisionSessionResponse>? _session;

  @override
  void initState() {
    super.initState();
    _session = _loadFromParams();
  }

  @override
  void didUpdateWidget(covariant RevisionSessionPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalizeId(oldWidget.sessionId) != _trimmedSessionId ||
        _normalizeId(oldWidget.subjectId) != _trimmedSubjectId ||
        _normalizeId(oldWidget.documentId) != _trimmedDocumentId ||
        _normalizeId(oldWidget.knowledgeUnitId) != _trimmedKnowledgeUnitId ||
        oldWidget.preferredAction != widget.preferredAction) {
      setState(() {
        _session = _loadFromParams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return RevisionPage(
      title: 'Révision IA',
      subtitle: 'Une session contrôlée à partir de tes activités existantes.',
      children: [
        if (session == null)
          const _EmptyRevisionSessionState()
        else
          FutureBuilder<RevisionSessionResponse>(
            future: session,
            builder: (context, snapshot) {
              final response = snapshot.data;

              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || response == null) {
                return _RevisionSessionErrorState(onRetry: _retry);
              }

              return _RevisionSessionContent(
                response: response,
                activityController: widget.activityController,
              );
            },
          ),
      ],
    );
  }

  String? get _trimmedSessionId => _normalizeId(widget.sessionId);
  String? get _trimmedSubjectId => _normalizeId(widget.subjectId);
  String? get _trimmedDocumentId => _normalizeId(widget.documentId);
  String? get _trimmedKnowledgeUnitId => _normalizeId(widget.knowledgeUnitId);

  Future<RevisionSessionResponse>? _loadFromParams() {
    final sessionId = _trimmedSessionId;
    if (sessionId != null) {
      return widget.revisionSessionController.loadSession(sessionId: sessionId);
    }

    final subjectId = _trimmedSubjectId;
    if (subjectId == null) {
      return null;
    }

    return widget.revisionSessionController.startSession(
      subjectId: subjectId,
      documentId: _trimmedDocumentId,
      knowledgeUnitId: _trimmedKnowledgeUnitId,
      preferredAction: widget.preferredAction,
    );
  }

  String? _normalizeId(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }

  void _retry() {
    setState(() {
      _session = _loadFromParams();
    });
  }
}

class _EmptyRevisionSessionState extends StatelessWidget {
  const _EmptyRevisionSessionState();

  @override
  Widget build(BuildContext context) {
    return RevisionMessage(
      message: 'Choisis une matière pour lancer une session de révision IA.',
      color: Theme.of(context).colorScheme.secondary,
      icon: Icons.info_outline,
    );
  }
}

class _RevisionSessionErrorState extends StatelessWidget {
  const _RevisionSessionErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionMessage(
          message: 'Impossible de charger la session de révision.',
          color: Theme.of(context).colorScheme.error,
          icon: Icons.error_outline,
        ),
        const SizedBox(height: AppSpacing.m),
        RevisionButton(
          label: 'Réessayer',
          icon: Icons.refresh,
          onPressed: onRetry,
          style: RevisionButtonStyle.ghost,
        ),
      ],
    );
  }
}

class _RevisionSessionContent extends StatelessWidget {
  const _RevisionSessionContent({
    required this.response,
    required this.activityController,
  });

  final RevisionSessionResponse response;
  final ActivityController activityController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SessionSummaryPanel(session: response.session),
        const SizedBox(height: AppSpacing.l),
        _CurrentActionPanel(action: response.currentAction),
        const SizedBox(height: AppSpacing.l),
        _CurrentActionRenderer(
          action: response.currentAction,
          activityController: activityController,
        ),
        const SizedBox(height: AppSpacing.l),
        _HistoryPanel(actions: response.history),
      ],
    );
  }
}

class _SessionSummaryPanel extends StatelessWidget {
  const _SessionSummaryPanel({required this.session});

  final RevisionSession session;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Session', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: _sessionStatusLabel(session.status),
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.play_circle_outline,
              ),
              RevisionStatusPill(
                label: 'Matière ${session.subjectId}',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.menu_book_outlined,
              ),
              if (session.documentId != null)
                RevisionStatusPill(
                  label: 'Document ${session.documentId}',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.description_outlined,
                ),
              if (session.knowledgeUnitId != null)
                RevisionStatusPill(
                  label: 'Notion ${session.knowledgeUnitId}',
                  color: Theme.of(context).colorScheme.tertiary,
                  icon: Icons.psychology_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentActionPanel extends StatelessWidget {
  const _CurrentActionPanel({required this.action});

  final RevisionSessionAction? action;

  @override
  Widget build(BuildContext context) {
    final action = this.action;

    if (action == null) {
      return const RevisionMessage(
        message: 'Aucune action courante dans cette session.',
        color: Colors.teal,
        icon: Icons.info_outline,
      );
    }

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action courante',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: _actionKindLabel(action.kind),
                color: Theme.of(context).colorScheme.primary,
                icon: _actionKindIcon(action.kind),
              ),
              RevisionStatusPill(
                label: _actionStatusLabel(action.status),
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.check_circle_outline,
              ),
              RevisionStatusPill(
                label: 'Ordre ${action.displayOrder + 1}',
                color: Theme.of(context).colorScheme.tertiary,
                icon: Icons.format_list_numbered,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentActionRenderer extends StatelessWidget {
  const _CurrentActionRenderer({
    required this.action,
    required this.activityController,
  });

  final RevisionSessionAction? action;
  final ActivityController activityController;

  @override
  Widget build(BuildContext context) {
    final action = this.action;
    final payload = action?.payload;

    if (action == null || payload == null) {
      return const _MinimalPayloadFallback();
    }

    return switch (payload) {
      RevisionSessionDiagnosticQuizPayload(:final activity) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: DiagnosticQuizPage(
          activity: activity,
          onSubmit: (answers) {
            return activityController.submitResult(
              sessionId: activity.sessionId,
              answers: answers,
            );
          },
        ),
      ),
      RevisionSessionOpenQuestionPayload(:final activity) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.68,
        child: OpenQuestionPage(
          activity: activity,
          onSubmit: (answerText) {
            return activityController.submitOpenAnswer(
              sessionId: activity.sessionId,
              answerText: answerText,
            );
          },
        ),
      ),
      RevisionSessionRichClosedExercisePayload() => _RichClosedLauncher(
        payload: payload,
      ),
      RevisionSessionMinimalPayload(:final type, :final sessionId) =>
        _MinimalPayloadFallback(type: type, sessionId: sessionId),
      RevisionSessionUnknownPayload() => const _UnknownPayloadFallback(),
    };
  }
}

class _RichClosedLauncher extends StatelessWidget {
  const _RichClosedLauncher({required this.payload});

  final RevisionSessionRichClosedExercisePayload payload;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions riches',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(_contextLabel),
          const SizedBox(height: AppSpacing.s),
          Text(payload.reason),
          const SizedBox(height: AppSpacing.s),
          RevisionStatusPill(
            label: '${payload.estimatedMinutes} min',
            color: Theme.of(context).colorScheme.tertiary,
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            label: 'Commencer',
            icon: Icons.play_arrow,
            onPressed: () {
              context.go(
                richClosedExerciseRoutePathFor(
                  subjectId: payload.subjectId,
                  documentId: payload.documentId,
                  knowledgeUnitId: payload.knowledgeUnitId,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String get _contextLabel {
    final title = payload.knowledgeUnitTitle?.trim();
    if (title != null && title.isNotEmpty) {
      return 'Notion: $title';
    }

    return 'Notion ${payload.knowledgeUnitId}';
  }
}

class _MinimalPayloadFallback extends StatelessWidget {
  const _MinimalPayloadFallback({this.type, this.sessionId});

  final String? type;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action à reprendre',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          const Text(
            "Cette action existe déjà, mais son détail complet n'est pas encore rechargeable.",
          ),
          const SizedBox(height: AppSpacing.s),
          if (type != null) Text('Type: $type'),
          if (sessionId != null) Text("Session d'activité: $sessionId"),
        ],
      ),
    );
  }
}

class _UnknownPayloadFallback extends StatelessWidget {
  const _UnknownPayloadFallback();

  @override
  Widget build(BuildContext context) {
    return const RevisionMessage(
      message: 'Cette action ne peut pas encore être affichée.',
      color: Colors.teal,
      icon: Icons.widgets_outlined,
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.actions});

  final List<RevisionSessionAction> actions;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Historique', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          if (actions.isEmpty)
            const Text('Aucune action enregistrée.')
          else
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Wrap(
                  spacing: AppSpacing.s,
                  runSpacing: AppSpacing.s,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RevisionStatusPill(
                      label: '#${action.displayOrder + 1}',
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    Text(_actionKindLabel(action.kind)),
                    Text(_actionStatusLabel(action.status)),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

String _sessionStatusLabel(RevisionSessionStatus status) {
  return switch (status) {
    RevisionSessionStatus.started => 'Démarrée',
    RevisionSessionStatus.completed => 'Terminée',
    RevisionSessionStatus.abandoned => 'Abandonnée',
    RevisionSessionStatus.unknown => 'Statut inconnu',
  };
}

String _actionKindLabel(RevisionSessionActionKind kind) {
  return switch (kind) {
    RevisionSessionActionKind.diagnosticQuiz => 'QCM',
    RevisionSessionActionKind.openQuestion => 'Question ouverte',
    RevisionSessionActionKind.richClosedExercise => 'Questions riches',
    RevisionSessionActionKind.unknown => 'Action inconnue',
  };
}

IconData _actionKindIcon(RevisionSessionActionKind kind) {
  return switch (kind) {
    RevisionSessionActionKind.diagnosticQuiz => Icons.quiz_outlined,
    RevisionSessionActionKind.openQuestion => Icons.rate_review_outlined,
    RevisionSessionActionKind.richClosedExercise => Icons.extension_outlined,
    RevisionSessionActionKind.unknown => Icons.help_outline,
  };
}

String _actionStatusLabel(RevisionSessionActionStatus status) {
  return switch (status) {
    RevisionSessionActionStatus.ready => 'Prête',
    RevisionSessionActionStatus.completed => 'Terminée',
    RevisionSessionActionStatus.failed => 'Échouée',
    RevisionSessionActionStatus.unknown => 'Statut inconnu',
  };
}
```

### lib/app/router/app_router.dart

```dart
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
    'rich_closed_exercise' => RevisionSessionPreferredAction.richClosedExercise,
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
```

### test/fakes/in_memory_revision_sessions_api.dart

```dart
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

class InMemoryRevisionSessionsApi implements RevisionSessionsApi {
  String? startedSubjectId;
  String? startedDocumentId;
  String? startedKnowledgeUnitId;
  RevisionSessionPreferredAction? startedPreferredAction;
  String? loadedSessionId;
  int startCount = 0;
  int loadCount = 0;
  Object? startError;
  Object? loadError;
  RevisionSessionResponse startResponse = openQuestionRevisionSessionResponse();
  RevisionSessionResponse loadResponse = minimalRevisionSessionResponse();

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    startCount += 1;
    startedSubjectId = subjectId;
    startedDocumentId = documentId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedPreferredAction = preferredAction;
    final error = startError;
    if (error != null) {
      throw error;
    }
    return startResponse;
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    loadCount += 1;
    loadedSessionId = sessionId;
    final error = loadError;
    if (error != null) {
      throw error;
    }
    return loadResponse;
  }
}

RevisionSessionResponse diagnosticQuizRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: null,
      knowledgeUnitId: null,
      payload: const RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'QCM de session',
          subjectId: 'subject-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Question test',
              choices: [
                DiagnosticQuizChoice(id: 'choice-1', label: 'Réponse A'),
                DiagnosticQuizChoice(id: 'choice-2', label: 'Réponse B'),
              ],
            ),
          ],
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-quiz-1',
        kind: RevisionSessionActionKind.diagnosticQuiz,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'quiz-session-1',
        documentId: null,
        knowledgeUnitId: null,
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse openQuestionRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: RevisionSessionAction(
      id: 'action-open-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: const RevisionSessionOpenQuestionPayload(
        OpenQuestionActivity(
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
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-open-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse richClosedRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: const RevisionSessionAction(
      id: 'action-rich-1',
      kind: RevisionSessionActionKind.richClosedExercise,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: null,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionRichClosedExercisePayload(
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Institutions politiques',
        reason: 'Questions riches recommandées.',
        estimatedMinutes: 8,
        preferredAction: 'rich_closed_exercise',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-rich-1',
        kind: RevisionSessionActionKind.richClosedExercise,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: null,
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse minimalRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: const RevisionSessionAction(
      id: 'action-minimal-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionMinimalPayload(
        type: 'open_question',
        sessionId: 'open-session-1',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-minimal-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSession revisionSession({String? knowledgeUnitId}) {
  return RevisionSession(
    id: 'revision-session-1',
    status: RevisionSessionStatus.started,
    subjectId: 'subject-1',
    documentId: null,
    knowledgeUnitId: knowledgeUnitId,
    createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
    completedAt: null,
  );
}
```

### test/features/revision_sessions/revision_session_controller_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';

import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  test('starts a revision session with subject only', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    final response = await controller.startSession(subjectId: ' subject-1 ');

    expect(response.session.id, 'revision-session-1');
    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, isNull);
    expect(api.startCount, 1);
  });

  test(
    'starts a revision session with knowledge unit and preferred action',
    () async {
      final api = InMemoryRevisionSessionsApi();
      final controller = RevisionSessionController(api);

      await controller.startSession(
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        preferredAction: RevisionSessionPreferredAction.openQuestion,
      );

      expect(api.startedSubjectId, 'subject-1');
      expect(api.startedKnowledgeUnitId, 'unit-1');
      expect(
        api.startedPreferredAction,
        RevisionSessionPreferredAction.openQuestion,
      );
    },
  );

  test('starts a revision session with rich closed preferred action', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    await controller.startSession(
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.richClosedExercise,
    );

    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
    expect(
      api.startedPreferredAction,
      RevisionSessionPreferredAction.richClosedExercise,
    );
  });

  test('loads a revision session by id', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    final response = await controller.loadSession(sessionId: ' session-1 ');

    expect(response.session.id, 'revision-session-1');
    expect(api.loadedSessionId, 'session-1');
    expect(api.loadCount, 1);
  });

  test('rejects empty start and load inputs', () async {
    final api = InMemoryRevisionSessionsApi();
    final controller = RevisionSessionController(api);

    expect(() => controller.startSession(subjectId: ' '), throwsArgumentError);
    expect(() => controller.loadSession(sessionId: ' '), throwsArgumentError);
    expect(api.startCount, 0);
    expect(api.loadCount, 0);
  });
}
```

### test/features/revision_sessions/http_revision_sessions_api_test.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/revision_sessions/data/http_revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

class CapturingHttpClientAdapter implements HttpClientAdapter {
  CapturingHttpClientAdapter(this.response);

  ResponseBody response;
  int fetchCallCount = 0;
  RequestOptions? lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    fetchCallCount += 1;
    lastOptions = options;
    return response;
  }
}

void main() {
  test('starts a revision session with preferred action payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.openQuestion,
    );

    expect(adapter.lastOptions?.path, '/revision-sessions');
    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'open_question',
    });
    expect(
      adapter.lastOptions?.headers['Authorization'],
      'Bearer firebase-id-token',
    );
    expect(response.session.id, 'revision-session-1');
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.diagnosticQuiz,
    );
    expect(
      response.currentAction?.payload,
      isA<RevisionSessionDiagnosticQuizPayload>(),
    );
  });

  test('starts and parses a rich closed launcher payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: richClosedPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.startRevisionSession(
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      preferredAction: RevisionSessionPreferredAction.richClosedExercise,
    );

    expect(adapter.lastOptions?.data, {
      'subjectId': 'subject-1',
      'documentId': 'document-1',
      'knowledgeUnitId': 'unit-1',
      'preferredAction': 'rich_closed_exercise',
    });
    expect(
      response.currentAction?.kind,
      RevisionSessionActionKind.richClosedExercise,
    );
    expect(response.currentAction?.activitySessionId, isNull);
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionRichClosedExercisePayload>());
    final launcher = payload as RevisionSessionRichClosedExercisePayload;
    expect(launcher.subjectId, 'subject-1');
    expect(launcher.documentId, 'document-1');
    expect(launcher.knowledgeUnitId, 'unit-1');
    expect(launcher.knowledgeUnitTitle, 'Institutions politiques');
    expect(launcher.estimatedMinutes, 8);
  });

  test('omits null fields from start request', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: diagnosticQuizPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await api.startRevisionSession(subjectId: 'subject-1');

    expect(adapter.lastOptions?.data, {'subjectId': 'subject-1'});
  });

  test('gets a revision session with minimal payload', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(adapter.lastOptions?.path, '/revision-sessions/revision-session-1');
    final payload = response.currentAction?.payload;
    expect(payload, isA<RevisionSessionMinimalPayload>());
    expect((payload as RevisionSessionMinimalPayload).type, 'open_question');
    expect(payload.sessionId, 'open-session-1');
  });

  test(
    'parses an open question full payload without correction leaks',
    () async {
      final adapter = CapturingHttpClientAdapter(
        jsonResponse(revisionSessionJson(payload: openQuestionPayloadJson())),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final api = HttpRevisionSessionsApi(
        dio: dio,
        getIdToken: () async => 'firebase-id-token',
      );

      final response = await api.startRevisionSession(
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      );

      final payload = response.currentAction?.payload;
      expect(payload, isA<RevisionSessionOpenQuestionPayload>());
      final activity = (payload as RevisionSessionOpenQuestionPayload).activity;
      expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
      expect(activity.question.sources.single.chunkId, 'chunk-1');
    },
  );

  test('parses currentAction null and history', () async {
    final json = revisionSessionJson(payload: null)..['currentAction'] = null;
    final adapter = CapturingHttpClientAdapter(jsonResponse(json));
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(response.currentAction, isNull);
    expect(response.history, hasLength(1));
    expect(
      response.history.single.kind,
      RevisionSessionActionKind.openQuestion,
    );
  });

  test('rejects rich closed payloads that contain exercise content', () async {
    final payload = richClosedPayloadJson()
      ..['questions'] = [
        {'id': 'question-1'},
      ]
      ..['correction'] = {'correctChoiceId': 'choice-1'};
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: payload)),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    final response = await api.getRevisionSession(
      sessionId: 'revision-session-1',
    );

    expect(
      response.currentAction?.payload,
      isA<RevisionSessionUnknownPayload>(),
    );
  });

  test('refuses an empty token before network call', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse(revisionSessionJson(payload: minimalPayloadJson())),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(dio: dio, getIdToken: () async => ' ');

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsStateError,
    );
    expect(adapter.fetchCallCount, 0);
  });

  test('rejects invalid revision session responses', () async {
    final adapter = CapturingHttpClientAdapter(
      jsonResponse({'session': null, 'currentAction': null, 'history': []}),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final api = HttpRevisionSessionsApi(
      dio: dio,
      getIdToken: () async => 'firebase-id-token',
    );

    await expectLater(
      api.getRevisionSession(sessionId: 'revision-session-1'),
      throwsFormatException,
    );
  });
}

ResponseBody jsonResponse(Object? payload) {
  return ResponseBody.fromString(
    jsonEncode(payload),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, Object?> revisionSessionJson({required Object? payload}) {
  final actionKind = payload == null ? 'OPEN_QUESTION' : actionKindFor(payload);
  final isRichClosed = actionKind == 'RICH_CLOSED_EXERCISE';

  return {
    'session': {
      'id': 'revision-session-1',
      'status': 'STARTED',
      'subjectId': 'subject-1',
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'createdAt': '2026-06-15T12:00:00.000Z',
      'completedAt': null,
    },
    'currentAction': {
      'id': 'action-1',
      'kind': actionKind,
      'status': 'READY',
      'displayOrder': 0,
      'activitySessionId': isRichClosed ? null : 'activity-session-1',
      'documentId': null,
      'knowledgeUnitId': 'unit-1',
      'payload': payload,
    },
    'history': [
      {
        'id': 'action-1',
        'kind': actionKind,
        'status': 'READY',
        'displayOrder': 0,
        'activitySessionId': isRichClosed ? null : 'activity-session-1',
        'documentId': null,
        'knowledgeUnitId': 'unit-1',
      },
    ],
  };
}

String actionKindFor(Object payload) {
  if (payload is Map && payload['type'] == 'diagnostic_quiz') {
    return 'DIAGNOSTIC_QUIZ';
  }
  if (payload is Map && payload['type'] == 'rich_closed_exercise') {
    return 'RICH_CLOSED_EXERCISE';
  }
  return 'OPEN_QUESTION';
}

Map<String, Object?> minimalPayloadJson() {
  return {'type': 'open_question', 'sessionId': 'open-session-1'};
}

Map<String, Object?> diagnosticQuizPayloadJson() {
  return {
    'sessionId': 'quiz-session-1',
    'type': 'diagnostic_quiz',
    'version': 3,
    'title': 'QCM de session',
    'documentId': null,
    'subjectId': 'subject-1',
    'questions': [
      {
        'id': 'question-1',
        'knowledgeUnitId': 'unit-1',
        'prompt': 'Question test',
        'difficulty': 'MEDIUM',
        'correctChoiceId': 'choice-1',
        'explanation': 'Ne doit pas être mappé.',
        'sources': [
          {
            'chunkId': 'chunk-1',
            'pageNumber': null,
            'index': 0,
            'text': 'Texte source complet interdit.',
          },
        ],
        'choices': [
          {'id': 'choice-1', 'label': 'Réponse A', 'feedback': 'Interdit'},
          {'id': 'choice-2', 'label': 'Réponse B'},
        ],
      },
    ],
  };
}

Map<String, Object?> openQuestionPayloadJson() {
  return {
    'sessionId': 'open-session-1',
    'type': 'open_question',
    'version': 1,
    'subjectId': 'subject-1',
    'documentId': null,
    'knowledgeUnitId': 'unit-1',
    'score': 20,
    'feedback': 'Interdit avant submit.',
    'modelAnswer': 'Interdit avant submit.',
    'question': {
      'id': 'open-question-1',
      'prompt': 'Explique la séparation des pouvoirs.',
      'instructions': 'Réponds en quelques phrases.',
      'maxAnswerLength': 4000,
      'sources': [
        {
          'chunkId': 'chunk-1',
          'pageNumber': null,
          'index': 0,
          'text': 'Texte source complet interdit.',
        },
      ],
    },
  };
}

Map<String, Object?> richClosedPayloadJson() {
  return {
    'type': 'rich_closed_exercise',
    'subjectId': 'subject-1',
    'documentId': 'document-1',
    'knowledgeUnitId': 'unit-1',
    'knowledgeUnitTitle': 'Institutions politiques',
    'reason': 'Questions riches recommandées.',
    'estimatedMinutes': 8,
    'preferredAction': 'rich_closed_exercise',
  };
}
```

### test/features/revision_sessions/revision_session_page_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/presentation/pages/revision_sessions/revision_session_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_revision_sessions_api.dart';

void main() {
  testWidgets(
    'start mode starts a revision session and renders open question',
    (tester) async {
      final api = InMemoryRevisionSessionsApi();

      await tester.pumpWidget(
        _Harness(api: api, subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      );
      await tester.pumpAndSettle();

      expect(api.startCount, 1);
      expect(api.startedSubjectId, 'subject-1');
      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Question ouverte test'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
    },
  );

  testWidgets('start mode renders diagnostic quiz full payload', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..startResponse = diagnosticQuizRevisionSessionResponse();

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(api.startCount, 1);
    expect(find.text('QCM de session'), findsOneWidget);
    expect(find.text('Question test'), findsOneWidget);
  });

  testWidgets(
    'start mode renders rich closed launcher without exercise content',
    (tester) async {
      final api = InMemoryRevisionSessionsApi()
        ..startResponse = richClosedRevisionSessionResponse();

      await tester.pumpWidget(
        _Harness(api: api, subjectId: 'subject-1', knowledgeUnitId: 'unit-1'),
      );
      await tester.pumpAndSettle();

      expect(api.startCount, 1);
      expect(find.text('Questions riches'), findsWidgets);
      expect(find.text('Notion: Institutions politiques'), findsOneWidget);
      expect(find.text('Questions riches recommandées.'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);
      expect(find.text('question-1'), findsNothing);
      expect(find.text('correctChoiceId'), findsNothing);
    },
  );

  testWidgets('load mode loads existing session and renders minimal fallback', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(
      _Harness(api: api, sessionId: 'revision-session-1'),
    );
    await tester.pumpAndSettle();

    expect(api.loadCount, 1);
    expect(api.loadedSessionId, 'revision-session-1');
    expect(
      find.textContaining("détail complet n'est pas encore rechargeable"),
      findsOneWidget,
    );
    expect(find.textContaining('open-session-1'), findsOneWidget);
  });

  testWidgets('empty state is shown without subject or session id', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi();

    await tester.pumpWidget(_Harness(api: api));
    await tester.pumpAndSettle();

    expect(api.startCount, 0);
    expect(api.loadCount, 0);
    expect(find.textContaining('Choisis une matière'), findsOneWidget);
  });

  testWidgets('error state keeps retry action', (tester) async {
    final api = InMemoryRevisionSessionsApi()..startError = StateError('boom');

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(
      find.text('Impossible de charger la session de révision.'),
      findsOneWidget,
    );

    api.startError = null;
    await tester.tap(find.widgetWithText(RevisionButton, 'Réessayer'));
    await tester.pumpAndSettle();

    expect(api.startCount, 2);
    expect(find.text('Question ouverte test'), findsOneWidget);
  });

  testWidgets('does not show sensitive correction fields before submit', (
    tester,
  ) async {
    final api = InMemoryRevisionSessionsApi()
      ..startResponse = diagnosticQuizRevisionSessionResponse();

    await tester.pumpWidget(_Harness(api: api, subjectId: 'subject-1'));
    await tester.pumpAndSettle();

    expect(find.text('correctChoiceId'), findsNothing);
    expect(find.text('feedback'), findsNothing);
    expect(find.text('modelAnswer'), findsNothing);
    expect(find.text('score'), findsNothing);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({
    required this.api,
    this.sessionId,
    this.subjectId,
    this.knowledgeUnitId,
  });

  final InMemoryRevisionSessionsApi api;
  final String? sessionId;
  final String? subjectId;
  final String? knowledgeUnitId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RevisionSessionPage(
        revisionSessionController: RevisionSessionController(api),
        activityController: ActivityController(InMemoryActivityApi()),
        sessionId: sessionId,
        subjectId: subjectId,
        knowledgeUnitId: knowledgeUnitId,
      ),
    );
  }
}
```

### test/app/router/app_router_test.dart

```dart
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
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
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

  testWidgets(
    'revision session rich closed action navigates to rich closed exercise',
    (tester) async {
      final harness = _RouterHarness();
      harness.revisionSessionsApi.startResponse =
          richClosedRevisionSessionResponse();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          preferredAction: 'rich_closed_exercise',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.text('Notion: Institutions politiques'), findsOneWidget);
      expect(harness.revisionSessionsApi.startCount, 1);
      expect(
        harness.revisionSessionsApi.startedPreferredAction,
        RevisionSessionPreferredAction.richClosedExercise,
      );
      expect(harness.activityApi.startedRichClosedCount, 0);
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);

      await tester.ensureVisible(
        find.widgetWithText(RevisionButton, 'Commencer'),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -160));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(RevisionButton, 'Commencer'));
      await tester.pumpAndSettle();

      expect(
        harness.router.routeInformationProvider.value.uri.toString(),
        '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
      );
      expect(find.text('Questions riches'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
      expect(harness.activityApi.startedRichClosedDocumentId, 'document-1');
      expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
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
    'today rich closed action navigates to rich closed without other activity',
    (tester) async {
      final harness = _RouterHarness();
      harness.todayRepository.plan = _todayPlanWithRichClosedAction();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(AppRoutes.today);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Commencer'));
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      expect(
        harness.router.routeInformationProvider.value.uri.toString(),
        '/activities/rich-closed?subjectId=subject-1&documentId=document-1&knowledgeUnitId=unit-1',
      );
      expect(find.text('Questions riches'), findsOneWidget);
      expect(harness.activityApi.startedRichClosedCount, 1);
      expect(harness.activityApi.startedRichClosedSubjectId, 'subject-1');
      expect(harness.activityApi.startedRichClosedKnowledgeUnitId, 'unit-1');
      expect(harness.activityApi.startedRichClosedDocumentId, 'document-1');
      expect(harness.activityApi.startedDiagnosticQuizCount, 0);
      expect(harness.activityApi.startedOpenQuestionCount, 0);
      expect(harness.revisionSessionsApi.startCount, 0);
    },
  );

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
      revisionSessionsApi = InMemoryRevisionSessionsApi() {
    todayRepository = InMemoryTodayRepository();
    todayController = TodayController(todayRepository);
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
  late final InMemoryTodayRepository todayRepository;
  late final TodayController todayController;
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
        todayRepositoryProvider.overrideWithValue(todayRepository),
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

TodayPlan _todayPlanWithRichClosedAction() {
  return TodayPlan(
    generatedAt: DateTime.parse('2026-06-15T10:00:00.000Z'),
    items: const [
      TodayPlanItem(
        id: 'subject-1:unit-1:rich_closed_exercise',
        subjectId: 'subject-1',
        subjectName: 'Droit constitutionnel',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Institutions politiques',
        masteryScore: 0.2,
        action: TodayPlanActionType.richClosedExercise,
        estimatedMinutes: 8,
        priority: 605,
        reasonCode: TodayPlanReasonCode.richClosedPractice,
        reason: 'Questions riches recommandées.',
        startPayload: TodayPlanStartPayload(
          subjectId: 'subject-1',
          documentId: 'document-1',
          knowledgeUnitId: 'unit-1',
        ),
      ),
    ],
  );
}
```
