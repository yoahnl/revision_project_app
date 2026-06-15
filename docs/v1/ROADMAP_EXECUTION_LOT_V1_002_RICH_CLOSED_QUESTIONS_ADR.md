# LOT V1-002 — ADR contrat rich closed questions

## 1. Résultat

ADR créée pour cadrer les rich closed questions V1-A. La décision retenue est un contrat applicatif discriminé par `questionKind`, versionné `rich-closed-question-v1`, sans migration Prisma et sans modification d'endpoint public dans ce passage.

## 2. Sources inspectées

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/application/diagnostic-quiz-question-count.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/revision/domain/adaptive-plan.service.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`
- `api/src/modules/revision-sessions/**`
- `api/src/modules/ai/**`
- `api/src/modules/demo-seed/**`
- `api/test/critical-paths.e2e-spec.ts`
- `revision_app/docs/v1/README.md`
- `revision_app/docs/v1/ROADMAP_V1_RICH_CLOSED_QUESTIONS.md`
- `revision_app/docs/v1/RICH_CLOSED_QUESTION_TYPES_CATALOG.md`
- `revision_app/docs/v1/RICH_CLOSED_QUESTIONS_DROIT_CONSTITUTIONNEL_EXAMPLES.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`
- `revision_app/lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `revision_app/lib/presentation/pages/activities/activities_page.dart`
- `revision_app/lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `revision_app/lib/presentation/pages/today/today_page.dart`
- `revision_app/lib/features/today/**`
- `revision_app/lib/features/revision_sessions/**`

Note : `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md` n'existe pas dans l'arbre local, malgré la ligne V1-001 déjà marquée réalisée.

## 3. Préflight Git

API :

```text
/Users/karim/Project/app-révision/api
branche: main
status initial: ## main...origin/main
derniers commits:
e552c75 #36-1: ajoute tests e2e pour les chemins critiques
b1d2318 #35-1: ajoute script de démo et données de seed
a08fd4e #34-1: améliore planification adaptative et plan du jour
783a728 #33-1: ajoute coach de révision et sélection d'actions
5e71dde #31-1: ajoute module revision-sessions avec structure minimale
```

Frontend/docs :

```text
/Users/karim/Project/app-révision/revision_app
branche: main
status initial: ## main...origin/main
derniers commits:
2667c30 LOT_038_V1 - Ajout documentation V1 (README, catalogues de questions, roadmap et exemples)
b45b6ab LOT_038_DEMO_DEPLOYMENT_RUNBOOK - Mise à jour runbooks démo et ajout rapport LOT_038
b31b17c LOT_037_E2E_SMOKE_CHECKS - Mise à jour plan d'exécution, ajout rapport LOT_037 et checks smoke démo
10fd329 LOT_036_DEMO_SEED_FIXTURES - Mise à jour plan d'exécution, ajout rapport LOT_036 et runbook de seed démo
f321d04 LOT_035_TODAY_PAGE_V2_FRONTEND - Mise à jour repository Today, domaine, page et tests, ajout rapport LOT_035
```

## 4. Périmètre réalisé

- Création de `docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`.
- Décision formelle : contrat applicatif pur, version `rich-closed-question-v1`.
- Décision formelle : pas de migration Prisma dans V1-002 à V1-005.
- Décision formelle : préparer une activité distincte `RICH_CLOSED_EXERCISE`, à persister plus tard.
- Mise à jour de la ligne V1-002 du plan V1.

## 5. Décisions prises

- Le QCM v3 reste intact.
- La réponse libre reste exclusivement dans `open_question`.
- Les rich closed questions sont fermées, typées et discriminées par `questionKind`.
- GenUI ne devient pas source de vérité.
- Les corrections restent privées pré-submit.

## 6. Fichiers créés/modifiés/supprimés

Créés :

- `revision_app/docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md`

Modifiés :

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

Supprimés : aucun.

## 7. Tests ajoutés

Aucun test runtime pour V1-002. Ce lot est documentaire.

## 8. Validations lancées avec résultats

- `git diff --check` depuis `api` : passé.
- `git diff --check` depuis `revision_app` : passé.
- Les validations backend globales sont documentées dans les rapports V1-004 et V1-005.

## 9. Validations non lancées avec justification

- Tests Flutter : non lancés, aucun code Flutter modifié.
- Migrations Prisma : non lancées, interdites et non nécessaires.
- Seed réel : non lancé, hors scope et interdit.

## 10. Risques restants

- La persistance future devra trancher définitivement le stockage JSON typé vs tables spécialisées.
- Les sessions IA et Today devront apprendre un futur action kind riche fermé.
- Le submit DTO discriminé reste à concevoir en V1-008.

## 11. Recommandation prochain lot

Poursuivre avec V1-006 après validation de V1-004/V1-005 : génération Genkit rich closed questions V1-A, en s'appuyant strictement sur le contrat et les gates.

## 12. Passes de review

- Architecture backend : séparation QCM v3 / rich closed.
- Prisma/DTO : pas de migration prématurée.
- Anti-fuite : correction privée avant submit.
- Scope : aucune API publique, aucun Flutter, aucun Genkit runtime.

## 13. Critique honnête du prompt initial

Le prompt est très clair sur les interdits et sur la séparation V0/V1. Le point le plus délicat est la demande de contenu complet dans chaque rapport pour les fichiers partagés : le plan V1 est partagé par les quatre lots, donc ce rapport précise l'état final et le rapport V1-005 contient aussi la trace de la mise à jour globale.

## 14. Contenu complet des fichiers créés/modifiés/supprimés pour review

### `revision_app/docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`

```md
# ADR — Contrat rich closed questions

## Statut

Accepté pour la trajectoire V1-A.

## Contexte

Revision App possède déjà un QCM v3 stable : single/multiple, sources, correction post-submit, visuels bornés `CHART`/`DIAGRAM`, TodayPlan, session IA et e2e critiques. Ce socle reste utile, mais il ne force pas les exercices riches. Les options avancées actuelles autorisent `selectionModes` et `visualTypes`, sans imposer de familles pédagogiques comme `matching`, `ordering`, `case_qualification` ou `error_detection`.

La réponse libre reste séparée dans `open_question`. Les rich closed questions doivent rester fermées et typées.

## Problème

Il faut créer un contrat capable de représenter plusieurs interactions fermées sans :

- casser le QCM v3 ;
- exposer la correction avant submit ;
- modifier Prisma trop tôt ;
- transformer GenUI en runtime arbitraire ;
- réutiliser de force le DTO public actuel `choiceId`/`choiceIds` pour des réponses non choix.

## Options étudiées

### Option A — QCM v4 dans `DIAGNOSTIC_QUIZ`

Cette option étendrait le QCM actuel en ajoutant un `questionKind` à `Question`.

Avantages :

- chemin API existant ;
- réutilisation du repository QCM ;
- migration conceptuellement légère.

Inconvénients :

- le modèle Prisma `Question` est déjà choix-centré ;
- `QuestionAnswer` stocke `selectedChoiceId` ou `selectedChoices` ;
- le submit public actuel accepte seulement `choiceId` ou `choiceIds` ;
- risque de tordre matching/ordering en faux QCM ;
- plus difficile d'expliquer la différence produit entre “QCM rapide” et “exercice riche”.

### Option B — Nouvelle activité `RICH_CLOSED_EXERCISE`

Cette option introduit une famille d'activité distincte, orchestrable par Today et les sessions IA.

Avantages :

- frontière produit claire ;
- évite de casser `DIAGNOSTIC_QUIZ` ;
- permet un submit DTO discriminé ;
- rend l'évolution Today/session plus explicite ;
- facilite les quality gates par type.

Inconvénients :

- nouvelle intégration API/frontend ;
- migration future sur `ActivityType` et `RevisionSessionActionKind` ;
- plus de code applicatif.

### Option C — Tables spécialisées par type

Chaque type aurait ses tables propres.

Avantages :

- contraintes DB fortes ;
- requêtes analytiques plus faciles par type.

Inconvénients :

- migration lourde ;
- beaucoup de tables avant validation produit ;
- coût élevé pour V1-A.

### Option D — Payload JSON typé

Les interactions et corrections sont stockées comme payloads JSON discriminés, validés applicativement.

Avantages :

- excellent compromis pour une première V1 ;
- supporte rapidement plusieurs types ;
- compatible avec validators stricts ;
- migration plus légère qu'une table par type.

Inconvénients :

- contraintes DB plus faibles ;
- nécessite tests et validation applicative robustes ;
- requêtage analytique plus limité.

## Décision

La V1 adopte un contrat applicatif discriminé par `questionKind`, préparant une future activité distincte `RICH_CLOSED_EXERCISE`.

Décisions concrètes :

- ne pas modifier Prisma dans V1-002 à V1-005 ;
- ne pas modifier les endpoints publics existants ;
- ne pas brancher Genkit réel ;
- créer en V1-004 un contrat applicatif pur indépendant de la persistance ;
- couvrir uniquement V1-A :
  - `single_choice` ;
  - `multiple_choice` ;
  - `matching` ;
  - `ordering` ;
  - `case_qualification` ;
  - `error_detection` ;
- utiliser le versioning `rich-closed-question-v1` ;
- préparer un futur submit DTO discriminé par `questionKind` ;
- recommander pour V1-007 une persistance dédiée à l'activité riche fermée, avec payload JSON typé validé applicativement, plutôt qu'une surcharge directe du modèle `Question`.

## Position de `questionKind`

`questionKind` est le discriminant principal du contrat.

Il doit être présent sur chaque question interne et publique, et doit appartenir à l'allowlist V1-A dans ce passage.

## Position de `interactionPayload`

Conceptuellement, `interactionPayload` désigne les données nécessaires au rendu pré-submit.

En V1-004, le contrat applicatif garde des champs explicites par type plutôt qu'un champ `interactionPayload` générique. Pour une persistance future, ces champs pourront être sérialisés dans un payload JSON typé.

## Position de `answerShape`

`answerShape` est un contrat public décrivant la réponse attendue :

- choix unique ;
- ensemble de choix ;
- paires ;
- ordre d'IDs ;
- erreur choisie.

En V1-004, les types `RichClosedAnswer` représentent cette forme. Le submit public sera ajouté plus tard, en V1-008.

## Position de `correctionPayload`

`correctionPayload` reste privé jusqu'au submit.

En V1-004, les structures internes portent directement les champs privés :

- `correctChoiceId` ;
- `correctChoiceIds` ;
- `correctPairs` ;
- `correctOrder` ;
- `correctErrorId` ;
- `explanation`.

Le mapper public pré-submit doit les supprimer systématiquement.

## Stratégie anti-fuite pré-submit

Un payload public pré-submit ne doit jamais contenir :

- tout champ commençant par `correct` ;
- `correctionPayload` ;
- `explanation` ;
- `score` ;
- `partialScore` ;
- texte source complet ;
- réponse modèle ;
- réponse libre.

Les tests V1-004/V1-005 sérialisent les payloads publics pour vérifier cette absence.

## Stratégie post-submit

La correction post-submit sera normalisée plus tard autour de `RichClosedCorrection` et de corrections spécifiques par type.

Principe décidé : le frontend ne calcule pas la correction. Il rend uniquement la correction backend.

## Compatibilité QCM v3

Le QCM v3 reste intact :

- `DIAGNOSTIC_QUIZ` continue à gérer single/multiple ;
- les endpoints `/activities/next` et `/activities/:sessionId/result` restent inchangés dans ce passage ;
- les tests activities existants doivent rester verts ;
- aucun changement de schema Prisma.

## Compatibilité `open_question`

`open_question` reste l'activité de réponse libre.

Les rich closed questions refusent explicitement les champs de réponse libre comme `answerText`, `freeTextAnswer`, `textAnswer` ou `modelAnswer`.

## Place de GenUI

GenUI peut rendre des composants catalogués à partir de DTO métier déjà validés.

GenUI ne définit jamais :

- `questionKind` ;
- scoring ;
- forme de réponse ;
- correction ;
- visibilité pré-submit/post-submit.

Aucun widget libre, HTML, SVG, Mermaid, JavaScript ou JSON brut n'est autorisé.

## Place des widgets natifs Flutter

Les widgets natifs Flutter restent le runtime produit recommandé.

GenUI peut servir de rendu borné secondaire, mais pas de source de vérité.

## Stratégie de versioning

Version retenue : `rich-closed-question-v1`.

Cette version identifie le contrat applicatif de question fermée riche, pas une migration DB.

## Stratégie de migration progressive

1. V1-004 : contrat applicatif pur.
2. V1-005 : quality gates purs.
3. V1-006 : génération Genkit V1-A mockée et validée.
4. V1-007 : persistance dédiée ou JSON typé selon audit final.
5. V1-008 : API publique pré-submit/post-submit.
6. V1-009+ : modèles et UI Flutter.

## Conséquences positives

- Le QCM v3 reste stable.
- Le contrat V1-A est testable sans DB.
- Les questions non choix ne sont pas forcées dans `choiceId`/`choiceIds`.
- Le risque de fuite pré-submit est isolé dans un mapper public.
- La séparation avec `open_question` est claire.

## Conséquences négatives

- Il faudra ajouter une nouvelle intégration API/front plus tard.
- Les sessions IA et Today devront apprendre un nouveau kind d'activité.
- Une migration enum sera probablement nécessaire en V1-007/V1-014.
- Le choix JSON typé exige des validators applicatifs solides.

## Alternatives rejetées

- Étendre immédiatement `Question` : rejeté pour éviter une surcharge choix-centrée.
- Créer toutes les tables spécialisées maintenant : rejeté pour éviter un big bang.
- Rendre les questions riches via GenUI libre : rejeté pour raisons de sécurité et de maintenabilité.
- Ajouter les types V1-B/C/D maintenant : rejeté pour garder V1-A livrable.

## Impacts backend

- Nouveau dossier applicatif pur dans `activities/application`.
- Validators par type.
- Mapper public pré-submit.
- Quality gates pédagogiques.
- Future interface de correction par `questionKind`.
- Future enveloppe de submit discriminée.

## Impacts frontend

- Futurs modèles Flutter discriminés.
- Futurs widgets natifs par type.
- Future validation locale de complétion, sans calcul de correction.
- Future route ou paramètre `preferredActivityKind` pour éviter l'ambiguïté QCM/open question.

## Impacts Prisma

Aucun dans ce passage.

À trancher en V1-007 :

- nouvelle activité `RICH_CLOSED_EXERCISE` ;
- stockage de questions et réponses par payload JSON typé ;
- stratégie de correction post-submit ;
- migration enum compatible.

## Impacts Genkit

Aucun flow Genkit réel n'est modifié dans ce passage.

V1-006 devra produire un JSON strict conforme à `rich-closed-question-v1` et respecter les gates V1-005.

## Impacts GenUI

Aucun composant GenUI n'est créé dans ce passage.

Tout futur composant devra consommer un DTO validé et ne jamais définir la logique métier.

## Questions ouvertes

- Nom final de l'endpoint public V1.
- Format final du submit discriminé.
- Scoring exact vs partiel pour `matching` et `ordering`.
- Persistance JSON typée dans table dédiée ou extension plus légère.
- Stratégie d'accessibilité pour ordering/matching sur mobile.
- Timing exact du paramètre `preferredActivityKind` côté Activities/Today.
```

### `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

Fichier partagé entre V1-002, V1-003, V1-004 et V1-005. Contenu complet non dupliqué ici pour éviter quatre copies longues identiques ; les lignes modifiées sont :

```md
| V1-002 | ADR contrat rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md |
| V1-003 | Audit Prisma/DTO et décision versioning | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md |
| V1-004 | Contrat backend rich question kinds | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md |
| V1-005 | Quality gates pédagogiques backend | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md |
```

### Fichiers supprimés

Aucun fichier supprimé.
