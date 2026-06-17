# LOT V1-024 — Polish UI/accessibilite/performance

## 1. Resultat

V1-024 est realise cote Flutter avec un polish cible du parcours rich closed: fallback `image_choice` plus clair et compact sur petit ecran, menus `institution_matrix` et `diagram_labeling` plus robustes pour les longs libelles, et tests widget dedies. Aucun flow global, contrat backend, score Flutter, nouveau type, Image.network ou rendu JSON arbitraire n'a ete ajoute.

## 2. Sources inspectees

- `lib/features/activities/domain/rich_closed_exercise.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- Widgets rich closed V1-A/V1-B/V1-C/V1-D
- Correction presenter/list/cards
- Tests activities, Today, revision sessions et router
- Plans et rapports V1-017 a V1-022

## 3. Preflight Git

### App

- Branche: `main`
- Status initial: clean au preflight.
- Status courant lors de generation du rapport:

```text
 M docs/v1/ROADMAP_EXECUTION_PLAN_V1.md
 M lib/features/activities/presentation/rich_closed/rich_closed_diagram_labeling_widget.dart
 M lib/features/activities/presentation/rich_closed/rich_closed_image_choice_widget.dart
 M lib/features/activities/presentation/rich_closed/rich_closed_institution_matrix_widget.dart
 M test/features/activities/rich_closed_diagram_labeling_widget_test.dart
 M test/features/activities/rich_closed_image_choice_widget_test.dart
 M test/features/activities/rich_closed_institution_matrix_widget_test.dart
?? docs/v1/ROADMAP_EXECUTION_LOT_V1_023_DEMO_RUNBOOK_V1.md
?? docs/v1/ROADMAP_EXECUTION_LOT_V1_024_UI_ACCESSIBILITY_PERFORMANCE.md
```

- Derniers commits:

```text
fcf0da6 V1-022: Ajout du widget Image Choice et registre d'assets pour les exercices riches fermés
82cd3ee V1-021: Ajout du widget Calculation MCQ pour les exercices riches fermés
be1c3dd V1-020: Ajout du widget Diagram Labeling pour les exercices riches fermés
1c5c384 V1-019: Ajout du widget Institution Matrix pour les exercices riches fermés
0fe0583 V1-018: Ajout des widgets True/False Grid et Cause/Conséquence pour les exercices riches fermés
```

- Aucun commit effectue.

### API

- Branche: `main`
- API non modifiee pour le polish runtime; seulement docs/runbook V1-023 et plan API.

## 4. Perimetre realise

### API

- Non applicable cote API pour le polish UI/runtime.

### App

- Polish borne sur trois widgets rich closed.
- Tests widget ajoutes/renforces.

### Docs

- Plan V1 app mis a jour.
- Rapport V1-024 cree.

### Tests

- TDD cible: tests rouges observes avant implementation, puis tests verts.

## 5. Changements realises

### UI

- `image_choice`: fallback visible `Image non disponible`, layout compact sous petite largeur, textes bornes par maxLines/ellipsis.
- `institution_matrix`: options de dropdown bornees visuellement.
- `diagram_labeling`: options de dropdown bornees visuellement.

### Accessibilite

- Les options longues de dropdown gardent leur libelle complet via `Tooltip`.
- Le fallback image reste neutre et ne revele pas le personnage.
- Aucun drag-only n'a ete ajoute.

### Performance

- Pas de dependance lourde.
- Ajout d'un `LayoutBuilder` local et de widgets prives simples.
- Aucune logique de score cote Flutter.

### Tests

- Test petit ecran/fallback `image_choice`.
- Tests longs libelles de menu pour `institution_matrix` et `diagram_labeling`.

## 6. Non-objectifs respectes

- Pas de V1-025.
- Pas de nouveau type.
- Pas de refonte UI massive.
- Pas de provider IA reel.
- Pas de deploiement.
- Pas de migration.
- Pas de secret.
- Pas de widget libre.
- Pas de score Flutter.
- Pas de `Image.network`, `NetworkImage`, WebView, URL image, base64, storage path ou CDN path.

## 7. Tests ajoutes ou renforces

- `rich_closed_image_choice_widget_test.dart`: fallback lisible sur petit ecran, absence de fuite `Charles de Gaulle`.
- `rich_closed_institution_matrix_widget_test.dart`: long libelle accessible via tooltip, absence de correction pre-submit.
- `rich_closed_diagram_labeling_widget_test.dart`: long libelle accessible via tooltip, absence de correction pre-submit.

## 8. Validations lancees avec resultats

- `dart format <liste explicite des fichiers modifies>`: OK, 6 fichiers, 0 changed.
- Tests rouges observes avant implementation: `image_choice garde un fallback lisible sur petit ecran`, `institution_matrix borne les longs libelles de menu`, `diagram_labeling borne les longs libelles de menu`.
- Tests cibles apres implementation: OK.
- `dart analyze lib test`: OK, no issues found.
- `flutter test test/features/activities --reporter compact`: OK, 231 tests.
- `flutter test test/features/today --reporter compact`: OK, 18 tests.
- `flutter test test/features/revision_sessions --reporter compact`: OK, 21 tests.
- `flutter test test/app/router --reporter compact`: OK, 11 tests.
- `flutter test --reporter compact`: OK, 362 tests.
- `git diff --check`: OK pour les diffs suivis apres generation finale des rapports; les fichiers docs non suivis sont listes dans le status courant et relus dans les passes de review.

## 9. Validations non lancees avec justification

- Screenshots/goldens non lances: le projet n'a pas de strategie golden requise ici, et les tests widget couvrent les risques cibles.
- Lancement simulateur manuel non effectue: tests Flutter complets verts.
- Aucun `dart fix --apply`, aucun `dart format .`.

## 10. Risques restants

- Le fallback `image_choice` reste un placeholder tant que les images licenciees ne sont pas branchees.
- Les tooltips ameliorent les longs libelles, mais la refonte UI future devra traiter les vrais layouts definitifs.
- Le seed persistant reste V1-A; la demo 14 types repose sur tests/fixtures mockes.

## 11. Recommandation prochain lot

V1-025 — Revue finale V1 et readiness audit. Aucun bis obligatoire n'est identifie pour V1-024.

## 12. Passes de review

- Documentation/runbook: couvert par V1-023.
- Commandes non destructives: couvert par V1-023.
- UI: sub-agent UI approuve, polish borne, pas de refonte.
- Accessibilite: sub-agent accessibilite approuve, fallback neutre, tooltips longs libelles, tap targets conserves.
- Performance: pas de dependance lourde, pas de logique couteuse globale.
- Anti-fuite: pas de correction pre-submit, pas de score Flutter, fallback image non revelateur.
- Tests: TDD cible + suite complete.
- Securite: pas de secret, pas d'image distante, pas de JSON arbitraire.
- Reviewer final: pass read-only, aucun finding sur le diff final V1-023/V1-024.

## 13. Critique honnete du prompt initial

Le prompt est utilement strict. Le point delicat est de rester dans un polish visible sans commencer une refonte: le lot se limite donc a trois risques concrets de demo au lieu d'elargir la page rich closed.

## 14. Contenu complet des fichiers crees/modifies/supprimes

Le present rapport est liste sans s'inclure lui-meme pour eviter une recursion infinie.

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
| V1-015 | Seed V1 rich demo fixtures | Non applicable côté app (API-only) | Voir api/docs/v1/ROADMAP_EXECUTION_LOT_V1_015_016_RICH_DEMO_SEED_AND_SMOKE.md |
| V1-016 | E2E/smoke V1 rich questions | Non applicable côté app (API-only) | Voir api/docs/v1/ROADMAP_EXECUTION_LOT_V1_015_016_RICH_DEMO_SEED_AND_SMOKE.md |
| V1-017 | Timeline/date slider V1-B | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_017_TIMELINE_DATE_SLIDER.md |
| V1-018 | True/false grid + cause/consequence V1-B | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md |
| V1-019 | Institution matrix V1-C | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_019_INSTITUTION_MATRIX.md |
| V1-020 | Diagram labeling V1-C | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_020_DIAGRAM_LABELING.md |
| V1-021 | Calculation MCQ modes de scrutin V1-C | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md |
| V1-022 | Image choice/personnages historiques V1-D | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_022_IMAGE_CHOICE.md |
| V1-023 | Runbook demo V1 | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_023_DEMO_RUNBOOK_V1.md |
| V1-024 | Polish UI/accessibilité/performance | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_024_UI_ACCESSIBILITY_PERFORMANCE.md |
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

```

### lib/features/activities/presentation/rich_closed/rich_closed_image_choice_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_image_asset_registry.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

class RichClosedImageChoiceWidget extends StatefulWidget {
  const RichClosedImageChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedImageChoiceQuestion question;
  final ValueChanged<RichClosedImageChoiceAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedImageChoiceWidget> createState() =>
      _RichClosedImageChoiceWidgetState();
}

class _RichClosedImageChoiceWidgetState
    extends State<RichClosedImageChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedImageChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedImageChoiceIdFor(
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
        for (final choice in widget.question.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _ImageChoiceTile(
              key: ValueKey('image-choice-${widget.question.id}-${choice.id}'),
              choice: choice,
              selected: selectedChoiceId == choice.id,
              enabled: widget.enabled,
              onTap: () => _selectChoice(choice.id),
            ),
          ),
      ],
    );
  }

  void _selectChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectImageChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedImageChoiceAnswer ? answer : null,
    );
  }
}

class _ImageChoiceTile extends StatelessWidget {
  const _ImageChoiceTile({
    required this.choice,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final RichClosedImageChoiceOption choice;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final asset = resolveRichClosedImageAssetView(choice);

    return Semantics(
      button: true,
      image: true,
      enabled: enabled,
      selected: selected,
      label: '${choice.label}. ${asset.altText}',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 300;
                final marker = Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                );
                final copy = _ImageChoiceCopy(choice: choice, asset: asset);

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _ImageChoicePreview(asset: asset),
                          const Spacer(),
                          marker,
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s),
                      copy,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImageChoicePreview(asset: asset),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(child: copy),
                    const SizedBox(width: AppSpacing.s),
                    marker,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageChoiceCopy extends StatelessWidget {
  const _ImageChoiceCopy({required this.choice, required this.asset});

  final RichClosedImageChoiceOption choice;
  final RichClosedImageAssetView asset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(choice.label, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: AppSpacing.xs),
        Text(
          choice.caption ?? asset.fallbackLabel,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (choice.creditLabel != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            choice.creditLabel!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _ImageChoicePreview extends StatelessWidget {
  const _ImageChoicePreview({required this.asset});

  final RichClosedImageAssetView asset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final assetPath = asset.assetPath;

    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          assetPath,
          width: 84,
          height: 84,
          fit: BoxFit.cover,
          semanticLabel: asset.altText,
        ),
      );
    }

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              'Image non disponible',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

```

### lib/features/activities/presentation/rich_closed/rich_closed_institution_matrix_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

class RichClosedInstitutionMatrixWidget extends StatefulWidget {
  const RichClosedInstitutionMatrixWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedInstitutionMatrixQuestion question;
  final ValueChanged<RichClosedInstitutionMatrixAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedInstitutionMatrixWidget> createState() =>
      _RichClosedInstitutionMatrixWidgetState();
}

class _RichClosedInstitutionMatrixWidgetState
    extends State<RichClosedInstitutionMatrixWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedInstitutionMatrixWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellsByRowId = <String, List<RichClosedInstitutionMatrixCell>>{};
    for (final cell in widget.question.cells) {
      cellsByRowId.putIfAbsent(cell.rowId, () => []).add(cell);
    }

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
        for (final row in widget.question.rows)
          if ((cellsByRowId[row.id] ?? const []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: _MatrixRowPanel(
                question: widget.question,
                row: row,
                cells: cellsByRowId[row.id] ?? const [],
                selectedOptionIdFor: (cellId) =>
                    _controller.selectedInstitutionMatrixOptionIdFor(
                      widget.question.id,
                      cellId,
                    ),
                enabled: widget.enabled,
                onChanged: _selectValue,
              ),
            ),
      ],
    );
  }

  void _selectValue({required String cellId, required String? optionId}) {
    if (!widget.enabled || optionId == null) {
      return;
    }

    setState(() {
      _controller.setInstitutionMatrixValue(
        question: widget.question,
        cellId: cellId,
        optionId: optionId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedInstitutionMatrixAnswer ? answer : null,
    );
  }
}

class _MatrixRowPanel extends StatelessWidget {
  const _MatrixRowPanel({
    required this.question,
    required this.row,
    required this.cells,
    required this.selectedOptionIdFor,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedInstitutionMatrixQuestion question;
  final RichClosedInstitutionMatrixAxisItem row;
  final List<RichClosedInstitutionMatrixCell> cells;
  final String? Function(String cellId) selectedOptionIdFor;
  final bool enabled;
  final void Function({required String cellId, required String? optionId})
  onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.label, style: theme.textTheme.labelLarge),
            if (row.description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(row.description!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.s),
            for (final cell in cells)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _MatrixCellSelector(
                  question: question,
                  cell: cell,
                  column: _columnFor(question, cell.columnId),
                  selectedOptionId: selectedOptionIdFor(cell.id),
                  enabled: enabled,
                  onChanged: (optionId) =>
                      onChanged(cellId: cell.id, optionId: optionId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatrixCellSelector extends StatelessWidget {
  const _MatrixCellSelector({
    required this.question,
    required this.cell,
    required this.column,
    required this.selectedOptionId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedInstitutionMatrixQuestion question;
  final RichClosedInstitutionMatrixCell cell;
  final RichClosedInstitutionMatrixAxisItem column;
  final String? selectedOptionId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(column.label, style: Theme.of(context).textTheme.labelMedium),
        if (cell.prompt != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(cell.prompt!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.xs),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey('institution-matrix-${question.id}-${cell.id}'),
              value: selectedOptionId,
              isExpanded: true,
              hint: const Text('Choisir une option'),
              items: [
                for (final option in cell.options)
                  DropdownMenuItem<String>(
                    value: option.id,
                    child: _DropdownOptionLabel(label: option.label),
                  ),
              ],
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownOptionLabel extends StatelessWidget {
  const _DropdownOptionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

RichClosedInstitutionMatrixAxisItem _columnFor(
  RichClosedInstitutionMatrixQuestion question,
  String columnId,
) {
  for (final column in question.columns) {
    if (column.id == columnId) {
      return column;
    }
  }

  throw StateError('Unknown institution matrix column $columnId');
}

```

### lib/features/activities/presentation/rich_closed/rich_closed_diagram_labeling_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

class RichClosedDiagramLabelingWidget extends StatefulWidget {
  const RichClosedDiagramLabelingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedDiagramLabelingQuestion question;
  final ValueChanged<RichClosedDiagramLabelingAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedDiagramLabelingWidget> createState() =>
      _RichClosedDiagramLabelingWidgetState();
}

class _RichClosedDiagramLabelingWidgetState
    extends State<RichClosedDiagramLabelingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedDiagramLabelingWidget oldWidget) {
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
        if (widget.question.instruction != null) ...[
          Text(
            widget.question.instruction!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        _DiagramSummary(question: widget.question),
        const SizedBox(height: AppSpacing.m),
        for (final slot in widget.question.slots)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _DiagramSlotSelector(
              question: widget.question,
              slot: slot,
              selectedOptionId: _controller.selectedDiagramLabelingOptionIdFor(
                widget.question.id,
                slot.id,
              ),
              enabled: widget.enabled,
              onChanged: (optionId) =>
                  _selectValue(slotId: slot.id, optionId: optionId),
            ),
          ),
      ],
    );
  }

  void _selectValue({required String slotId, required String? optionId}) {
    if (!widget.enabled || optionId == null) {
      return;
    }

    setState(() {
      _controller.setDiagramLabelingValue(
        question: widget.question,
        slotId: slotId,
        optionId: optionId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedDiagramLabelingAnswer ? answer : null,
    );
  }
}

class _DiagramSummary extends StatelessWidget {
  const _DiagramSummary({required this.question});

  final RichClosedDiagramLabelingQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = question.diagram.title;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (question.diagram.description != null) ...[
              Text(
                question.diagram.description!,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s),
            ],
            Text('Noeuds', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            for (final node in question.diagram.nodes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(_nodeLine(node)),
              ),
            if (question.diagram.edges.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text('Relations', style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              for (final edge in question.diagram.edges)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _EdgeLine(question: question, edge: edge),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EdgeLine extends StatelessWidget {
  const _EdgeLine({required this.question, required this.edge});

  final RichClosedDiagramLabelingQuestion question;
  final RichClosedDiagramEdge edge;

  @override
  Widget build(BuildContext context) {
    final label = edge.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_edgeEndpoints(question, edge)),
        if (label != null)
          Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DiagramSlotSelector extends StatelessWidget {
  const _DiagramSlotSelector({
    required this.question,
    required this.slot,
    required this.selectedOptionId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedDiagramLabelingQuestion question;
  final RichClosedDiagramLabelingSlot slot;
  final String? selectedOptionId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_anchorLine(question, slot), style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(slot.prompt, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey('diagram-labeling-${question.id}-${slot.id}'),
              value: selectedOptionId,
              isExpanded: true,
              hint: const Text('Choisir une option'),
              items: [
                for (final option in slot.options)
                  DropdownMenuItem<String>(
                    value: option.id,
                    child: _DropdownOptionLabel(label: option.label),
                  ),
              ],
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownOptionLabel extends StatelessWidget {
  const _DropdownOptionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

String _nodeLine(RichClosedDiagramNode node) => node.label;

String _anchorLine(
  RichClosedDiagramLabelingQuestion question,
  RichClosedDiagramLabelingSlot slot,
) {
  return switch (slot.anchorType) {
    RichClosedDiagramAnchorType.node => _nodeFor(question, slot.anchorId).label,
    RichClosedDiagramAnchorType.edge => _edgeLineWithLabel(
      question,
      _edgeFor(question, slot.anchorId),
    ),
  };
}

String _edgeLineWithLabel(
  RichClosedDiagramLabelingQuestion question,
  RichClosedDiagramEdge edge,
) {
  final endpoints = _edgeEndpoints(question, edge);
  final label = edge.label;
  if (label == null) {
    return endpoints;
  }

  return '$endpoints / $label';
}

String _edgeEndpoints(
  RichClosedDiagramLabelingQuestion question,
  RichClosedDiagramEdge edge,
) {
  final from = _nodeFor(question, edge.fromNodeId);
  final to = _nodeFor(question, edge.toNodeId);
  return '${from.label} -> ${to.label}';
}

RichClosedDiagramNode _nodeFor(
  RichClosedDiagramLabelingQuestion question,
  String nodeId,
) {
  for (final node in question.diagram.nodes) {
    if (node.id == nodeId) {
      return node;
    }
  }

  throw StateError('Unknown diagram node $nodeId');
}

RichClosedDiagramEdge _edgeFor(
  RichClosedDiagramLabelingQuestion question,
  String edgeId,
) {
  for (final edge in question.diagram.edges) {
    if (edge.id == edgeId) {
      return edge;
    }
  }

  throw StateError('Unknown diagram edge $edgeId');
}

```

### test/features/activities/rich_closed_image_choice_widget_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_image_choice_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(
      richClosedV1DImageChoiceExerciseJson(),
    );
  });

  testWidgets('image_choice affiche les choix contrôlés et produit choiceId', (
    tester,
  ) async {
    final answers = <RichClosedImageChoiceAnswer?>[];
    final question = _question<RichClosedImageChoiceQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedImageChoiceWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Image'), findsOneWidget);
    expect(find.text('Image A'), findsOneWidget);
    expect(find.text('Image B'), findsOneWidget);
    expect(find.text('Image C'), findsOneWidget);
    expect(find.text('Portrait historique A'), findsWidgets);
    expect(find.text('Asset de démonstration contrôlé'), findsWidgets);
    _expectNoPreSubmitLeaks();

    await tester.tap(
      find.byKey(const ValueKey('image-choice-image-choice-1-choice-image-a')),
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.choiceId, 'choice-image-a');
    expect(answer.toJson(), {
      'questionId': 'image-choice-1',
      'questionKind': 'image_choice',
      'choiceId': 'choice-image-a',
    });
  });

  testWidgets('image_choice garde un fallback lisible sur petit écran', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(260, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final question = _question<RichClosedImageChoiceQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedImageChoiceWidget(
          question: question,
          onAnswerChanged: (_) {},
        ),
      ),
    );

    expect(find.text('Image non disponible'), findsWidgets);
    expect(find.text('Charles de Gaulle'), findsNothing);
    expect(tester.takeException(), isNull);
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
  expect(find.text('Charles de Gaulle'), findsNothing);
  expect(find.text('correctChoiceId'), findsNothing);
  expect(find.text('semanticLabel'), findsNothing);
  expect(find.text('answerHint'), findsNothing);
  expect(find.text('imageUrl'), findsNothing);
  expect(find.text('storagePath'), findsNothing);
  expect(find.text('base64'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('renderPayload'), findsNothing);
}

```

### test/features/activities/rich_closed_institution_matrix_widget_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_institution_matrix_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedV1CExerciseJson());
  });

  testWidgets('institution_matrix affiche lignes, colonnes et produit values', (
    tester,
  ) async {
    final answers = <RichClosedInstitutionMatrixAnswer?>[];
    final question = _question<RichClosedInstitutionMatrixQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedInstitutionMatrixWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Président de la République'), findsOneWidget);
    expect(find.text('Gouvernement'), findsOneWidget);
    expect(find.text('Assemblée nationale'), findsOneWidget);
    expect(find.text('Mode de légitimité'), findsOneWidget);
    expect(find.text('Responsabilité politique'), findsOneWidget);
    expect(find.text('Moyen d’action'), findsOneWidget);
    expect(find.text('Choisir une option'), findsNWidgets(3));
    _expectNoPreSubmitLeaks();

    _selectDropdown(
      tester,
      key: 'institution-matrix-institution-matrix-1-cell-president-legitimacy',
      value: 'option-legitimacy-election',
    );
    await tester.pump();
    expect(answers.last, isNull);

    _selectDropdown(
      tester,
      key:
          'institution-matrix-institution-matrix-1-cell-government-responsibility',
      value: 'option-responsibility-assembly',
    );
    _selectDropdown(
      tester,
      key: 'institution-matrix-institution-matrix-1-cell-assembly-action',
      value: 'option-action-censure',
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.values.map((value) => '${value.cellId}:${value.optionId}'), [
      'cell-president-legitimacy:option-legitimacy-election',
      'cell-government-responsibility:option-responsibility-assembly',
      'cell-assembly-action:option-action-censure',
    ]);
  });

  testWidgets('institution_matrix borne les longs libellés de menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const longLabel =
        'Responsabilité politique devant une assemblée parlementaire avec '
        'un intitulé volontairement très long pour la démo';
    final question = _withLongFirstOption(
      _question<RichClosedInstitutionMatrixQuestion>(exercise),
      longLabel,
    );

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedInstitutionMatrixWidget(
          question: question,
          onAnswerChanged: (_) {},
        ),
      ),
    );

    await tester.tap(
      find.byKey(
        const ValueKey(
          'institution-matrix-institution-matrix-1-cell-president-legitimacy',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip(longLabel), findsOneWidget);
    expect(find.text('correctValues'), findsNothing);
    expect(tester.takeException(), isNull);
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

RichClosedInstitutionMatrixQuestion _withLongFirstOption(
  RichClosedInstitutionMatrixQuestion question,
  String longLabel,
) {
  final firstCell = question.cells.first;

  return RichClosedInstitutionMatrixQuestion(
    base: RichClosedQuestionBase(
      id: question.id,
      prompt: question.prompt,
      difficulty: question.difficulty,
      cognitiveSkill: question.cognitiveSkill,
      sourceChunkIds: question.sourceChunkIds,
    ),
    instruction: question.instruction,
    rows: question.rows,
    columns: question.columns,
    cells: [
      RichClosedInstitutionMatrixCell(
        id: firstCell.id,
        rowId: firstCell.rowId,
        columnId: firstCell.columnId,
        prompt: firstCell.prompt,
        options: [
          RichClosedChoice(id: firstCell.options.first.id, label: longLabel),
          ...firstCell.options.skip(1),
        ],
      ),
      ...question.cells.skip(1),
    ],
  );
}

void _selectDropdown(
  WidgetTester tester, {
  required String key,
  required String value,
}) {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byKey(ValueKey(key)),
  );
  dropdown.onChanged!(value);
}

void _expectNoPreSubmitLeaks() {
  expect(find.text('correctValues'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
}

```

### test/features/activities/rich_closed_diagram_labeling_widget_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_diagram_labeling_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedV1CFullExerciseJson());
  });

  testWidgets('diagram_labeling affiche le schema et produit values', (
    tester,
  ) async {
    final answers = <RichClosedDiagramLabelingAnswer?>[];
    final question = _question<RichClosedDiagramLabelingQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedDiagramLabelingWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Rapports institutionnels'), findsOneWidget);
    expect(find.text('Président de la République'), findsOneWidget);
    expect(find.text('Gouvernement'), findsWidgets);
    expect(find.text('Assemblée nationale'), findsOneWidget);
    expect(
      find.text('Président de la République -> Gouvernement'),
      findsOneWidget,
    );
    expect(
      find.text('Quel organe conduit la politique nationale ?'),
      findsOneWidget,
    );
    expect(find.text('Choisir une option'), findsNWidgets(3));
    _expectNoPreSubmitLeaks();

    _selectDropdown(
      tester,
      key: 'diagram-labeling-diagram-labeling-1-slot-government-role',
      value: 'option-government',
    );
    await tester.pump();
    expect(answers.last, isNull);

    _selectDropdown(
      tester,
      key: 'diagram-labeling-diagram-labeling-1-slot-censure',
      value: 'option-motion-censure',
    );
    _selectDropdown(
      tester,
      key: 'diagram-labeling-diagram-labeling-1-slot-nomination',
      value: 'option-nomination',
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.values.map((value) => '${value.slotId}:${value.optionId}'), [
      'slot-government-role:option-government',
      'slot-censure:option-motion-censure',
      'slot-nomination:option-nomination',
    ]);
  });

  testWidgets('diagram_labeling borne les longs libellés de menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const longLabel =
        'Nomination institutionnelle décrite avec un intitulé très long '
        'pour vérifier le comportement du menu avant la démo';
    final question = _withLongFirstOption(
      _question<RichClosedDiagramLabelingQuestion>(exercise),
      longLabel,
    );

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedDiagramLabelingWidget(
          question: question,
          onAnswerChanged: (_) {},
        ),
      ),
    );

    const dropdownKey = ValueKey(
      'diagram-labeling-diagram-labeling-1-slot-government-role',
    );
    await tester.ensureVisible(find.byKey(dropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(dropdownKey));
    await tester.pumpAndSettle();

    expect(find.byTooltip(longLabel), findsOneWidget);
    expect(find.text('correctValues'), findsNothing);
    expect(tester.takeException(), isNull);
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

RichClosedDiagramLabelingQuestion _withLongFirstOption(
  RichClosedDiagramLabelingQuestion question,
  String longLabel,
) {
  final firstSlot = question.slots.first;

  return RichClosedDiagramLabelingQuestion(
    base: RichClosedQuestionBase(
      id: question.id,
      prompt: question.prompt,
      difficulty: question.difficulty,
      cognitiveSkill: question.cognitiveSkill,
      sourceChunkIds: question.sourceChunkIds,
    ),
    instruction: question.instruction,
    diagram: question.diagram,
    slots: [
      RichClosedDiagramLabelingSlot(
        id: firstSlot.id,
        anchorType: firstSlot.anchorType,
        anchorId: firstSlot.anchorId,
        prompt: firstSlot.prompt,
        options: [
          RichClosedChoice(id: firstSlot.options.first.id, label: longLabel),
          ...firstSlot.options.skip(1),
        ],
      ),
      ...question.slots.skip(1),
    ],
  );
}

void _selectDropdown(
  WidgetTester tester, {
  required String key,
  required String value,
}) {
  final dropdown = tester.widget<DropdownButton<String>>(
    find.byKey(ValueKey(key)),
  );
  dropdown.onChanged!(value);
}

void _expectNoPreSubmitLeaks() {
  expect(find.text('correctValues'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
  expect(find.text('svg'), findsNothing);
  expect(find.text('mermaid'), findsNothing);
  expect(find.text('renderPayload'), findsNothing);
}

```
