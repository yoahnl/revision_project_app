# STAB-01C — Sheet, Progress, Wording & Subject Discoverability Report

## 1. Résumé
STAB-01C clôt le macro-lot STAB-01 côté Flutter. Le lot simplifie la fiche de cours en retirant les faux onglets actifs, clarifie la page Progrès autour de la matière active et de la maîtrise, nettoie les libellés utilisateur qui sentaient encore le debug ou la roadmap interne, et met à jour les trackers pour marquer STAB-01C et STAB-01 comme terminés.

Aucun backend n'a été modifié.

## 2. Audit initial
Fichiers audités ou relus avant intervention :

- `docs/roadmap/v2/README.md`
- `docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md`
- `docs/roadmap/v2/UX_UI_TARGET_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/EXECUTION_PLAN_V2.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/DECISIONS_V2.md`
- `docs/roadmap/v2/ROADMAP_UPDATE_PROTOCOL.md`
- `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md`
- `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md`
- `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md`
- `docs/ui/UI_01_PREMIUM_VISUAL_FOUNDATION_REPORT.md`
- `docs/ui/UI_02B_QUICK_REVISION_HARDENING_REPORT.md`
- `docs/ui/REVISION_PROJECT_UI_TARGET.md`
- `docs/roadmap/v2/assets/README.md`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_quick_revision_launcher.dart`
- `lib/features/courses/presentation/courses_home_page.dart`
- `lib/features/courses/presentation/revisions_pending_page.dart`
- `lib/features/courses/presentation/subject_progress_page.dart`
- `lib/features/courses/application/active_subject_provider.dart`
- `lib/features/courses/application/courses_providers.dart`
- `lib/features/courses/domain/course_models.dart`
- `lib/features/courses/domain/courses_repository.dart`
- `lib/features/subjects/application/subjects_notifier.dart`
- `lib/features/subjects/domain/subject.dart`
- `lib/presentation/design_system/components/revision_mvp_components.dart`
- `lib/presentation/design_system/components/revision_states.dart`
- `lib/presentation/design_system/tokens/`
- `lib/app/router/app_routes.dart`
- `lib/app/router/app_router.dart`
- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`
- `test/features/courses/`
- `test/features/revision_sessions/`

Constats principaux :

- La fiche de cours exposait encore `Rapide`, `Complète` et `Examen`, alors que seule la fiche rapide existe réellement.
- La fiche pouvait afficher des formulations trop techniques ou défensives, dont des références à des données fictives.
- La page Progrès affichait des textes comme `Aucune matière réelle`, `Aucun cours réel` et `Progression réelle basée...`, trop proches du vocabulaire de debug.
- La page Progrès lisait déjà la matière active, mais ne la rendait pas assez explicite et n'offrait pas de chemin clair pour changer de matière.
- Quelques pages pending / not found / session contenaient encore des formulations internes ou exposaient des identifiants techniques dans des libellés utilisateur.

## 3. Sub-agents / passes utilisées

- Sheet UX Agent : audit et simplification de la fiche de cours, retrait des faux onglets actifs, vérification des états indisponibles.
- Progress UX Agent : clarification de la matière active, des états vides et du vocabulaire de progression.
- Subject Discoverability Agent : ajout d'un rappel visible de matière active et d'un chemin `Changer de matière` vers l'accueil.
- Wording Agent : suppression des libellés utilisateur `réel/réelle`, `fictif`, `MVP+`, `backend`, `payload`, `courseId`, `documentId`, `KnowledgeUnit`, `CORE-*` quand ils apparaissaient comme texte utilisateur.
- Capability Honesty Agent : conservation des capacités non disponibles en dehors des surfaces actives ; pas de faux onglet complet/examen.
- QA Agent : tests fiche, progression, app/router, revision sessions, scans anti-wording et anti-fixtures.
- Reviewer Agent : vérification du périmètre App-only, trackers et absence de backend.

## 4. Fiche de cours : état avant/après

Avant :

- Segmented control `Rapide / Complète / Examen` visible.
- `Complète` et `Examen` affichaient des états de disponibilité future, ce qui créait une fausse surface produit.
- Le header était plus centré sur le mode que sur la lecture de fiche disponible.
- Les erreurs mentionnaient encore des données fictives dans certains cas.

Après :

- Les faux onglets actifs ont été retirés.
- La page affiche une fiche honnête : titre, résumé, points, pièges et sections générées si elles existent.
- Le header présente simplement `Fiche` avec une courte description utilisateur.
- Le bouton `Sources` ouvre la page dédiée des sources de fiche au lieu de renvoyer vers le cours.
- Les états indisponibles expliquent quoi faire sans promettre de fiche complète ni d'examen.

## 5. Progrès : état avant/après

Avant :

- La matière active était utilisée mais pas assez explicitement nommée.
- Certains états vides employaient `réelle/réel` et sonnaient comme du debug.
- Le label de progression pratiquée parlait de `Progression réelle`, ce qui n'est pas un wording produit.
- Le badge de cours prêts pouvait être lu comme un indicateur de maîtrise.

Après :

- La carte principale affiche `Matière active` et un bouton `Changer de matière`.
- L'état sans matière dit `Crée une matière pour suivre ta progression.`
- L'état matière sans cours dit `Aucun cours à suivre` et invite à créer un cours.
- Le badge source est formulé `avec source prête`.
- Le libellé pratiqué devient `Progression basée sur tes réponses.`
- La section à surveiller devient `À préparer`, plus orientée action et moins anxiogène.

## 6. Matière active / découvrabilité : état final

- Accueil : déjà couvert par STAB-01B, matière active visible.
- Réviser : déjà couvert par STAB-01B, matière active visible dans le hub.
- Détail cours : matière visible dans le header cours.
- Fiche : la fiche reste contextualisée par le cours et les sources consultables.
- Progrès : matière active explicitement affichée avec un bouton `Changer de matière` vers l'accueil.

Limite volontaire : pas de gestion avancée des matières dans Progrès. La vraie gestion/migration matières reste pour STAB-02A ou un lot dédié.

## 7. Capacités non disponibles : décisions

- Fiche complète : non exposée comme onglet actif, renvoyée à PLUS-02.
- Fiche examen : non exposée comme onglet actif, renvoyée à PLUS-02 / PLUS-03.
- Deep Revision : pas implémentée ni activée ici.
- Exam : pas implémenté ni activé ici.
- Today adaptatif, historique et reprise de session : pas ajoutés.
- Sources globales : pas transformées en bibliothèque globale.

## 8. Wording corrigé

Corrections principales :

- `Aucune matière réelle` -> `Crée une matière pour suivre ta progression.`
- `Aucun cours réel` -> `Aucun cours à suivre`
- `Progression réelle basée sur tes réponses.` -> `Progression basée sur tes réponses.`
- `Session réelle` dans les états pending -> `Session` / `parcours de révision`
- `données fictives` dans la fiche -> message neutre de chargement impossible.
- Identifiants visibles `Document <id>` / `Notion <id>` -> `Document lié` / `Notion liée` / `Notion à travailler`.

## 9. Tests ajoutés/modifiés

- `test/features/courses/course_revision_sheet_page_test.dart`
  - vérifie que `Complète` et `Examen` ne sont plus affichés comme faux onglets actifs ;
  - vérifie que les états d'erreur ne parlent plus de données fictives.
- `test/features/courses/subject_progress_page_test.dart`
  - met à jour les attentes no-subject ;
  - vérifie la matière active et le CTA `Changer de matière` ;
  - ajoute un cas matière sans cours ;
  - vérifie le nouveau wording de progression.
- `test/app/revision_app_test.dart`
  - met à jour les attentes de wording Progress / Course not found.
- `test/app/router/app_router_test.dart`
  - met à jour les attentes de wording Course not found et Rich Closed launcher.
- `test/features/revision_sessions/revision_session_page_test.dart`
  - met à jour le libellé notion avec la typographie finale.

## 10. Commandes exécutées

```bash
flutter --version
```
Résultat : code 0.

```text
Flutter 3.44.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 559ffa3f75 (5 weeks ago) • 2026-05-15 14:13:13 -0700
Engine • hash fcf463a2242790d1fdcd9d044f533080f5022e18 (revision 4c525dac5e) (1 months ago) • 2026-05-15 19:00:04.000Z
Tools • Dart 3.12.0 • DevTools 2.57.0
```

```bash
flutter pub get
```
Résultat : code 0. Dépendances résolues ; 23 packages plus récents sont signalés comme incompatibles avec les contraintes actuelles.

```bash
dart analyze lib test
```
Résultat final : code 0.

```text
Analyzing lib, test...
No issues found!
```

```bash
flutter test test/app/router/app_router_test.dart --reporter compact
```
Résultat final : code 0.

```text
All tests passed!
```

```bash
flutter test test/app/revision_app_test.dart --reporter compact
```
Résultat : code 0.

```text
All tests passed!
```

```bash
flutter test test/features/courses --reporter compact
```
Résultat : code 0.

```text
All tests passed!
```

```bash
flutter test test/features/revision_sessions --reporter compact
```
Résultat final : code 0.

```text
All tests passed!
```

```bash
flutter test --reporter compact
```
Résultat final : code 0. Le log complet a été tronqué par l'outil, mais la commande se termine avec :

```text
All tests passed!
```

Note : une tentative parallèle de tests Flutter a échoué avec un lock sur `ios/Flutter/ephemeral/Packages/.packages`. Les suites concernées ont ensuite été relancées séquentiellement et sont passées.

```bash
git diff --check
```
Résultat final : code 0, aucune sortie.

```bash
git status --short --untracked-files=all
```
Résultat final : code 0.

```text
 M docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md
 M docs/roadmap/v2/LOT_TRACKER_V2.md
 M lib/features/courses/presentation/course_not_found_page.dart
 M lib/features/courses/presentation/course_pending_page.dart
 M lib/features/courses/presentation/course_revision_sheet_page.dart
 M lib/features/courses/presentation/revision_session_pending_page.dart
 M lib/features/courses/presentation/revision_session_result_pending_page.dart
 M lib/features/courses/presentation/sources_pending_page.dart
 M lib/features/courses/presentation/subject_progress_page.dart
 M lib/presentation/pages/revision_sessions/revision_session_page.dart
 M lib/presentation/pages/revision_sessions/revision_session_result_page.dart
 M test/app/revision_app_test.dart
 M test/app/router/app_router_test.dart
 M test/features/courses/course_revision_sheet_page_test.dart
 M test/features/courses/subject_progress_page_test.dart
 M test/features/revision_sessions/revision_session_page_test.dart
?? docs/ui/STAB_01C_SHEET_PROGRESS_WORDING_SUBJECTS_REPORT.md
```

## 11. Résultats exacts

- `flutter --version` : OK.
- `flutter pub get` : OK avec avertissements de versions plus récentes incompatibles.
- `dart analyze lib test` : OK, `No issues found!`.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK, `All tests passed!`.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK, `All tests passed!`.
- `flutter test test/features/courses --reporter compact` : OK, `All tests passed!`.
- `flutter test test/features/revision_sessions --reporter compact` : OK, `All tests passed!`.
- `flutter test --reporter compact` : OK, `All tests passed!`.
- `git diff --check` : OK, aucune sortie.
- `git status --short --untracked-files=all` : OK, liste les fichiers STAB-01C modifiés et le rapport créé.

## 12. Recherche anti-wording

Commande :

```bash
rg -n "MVP\+|backend|payload|fixture|courseId|documentId|KnowledgeUnit|CORE-05|CORE-03|à brancher|Aucune matière réelle|Aucun cours réel|Progression réelle|Session réelle" lib/features/courses/presentation lib/presentation/pages/revision_sessions lib/presentation/shell || true
```

Résultat : la commande remonte encore des identifiants et types de code (`courseId`, `documentId`, `payload`, `KnowledgeUnit`) mais plus de texte utilisateur interdit. Les fuites utilisateur constatées pendant le lot (`Document <id>`, `Notion <id>`) ont été remplacées par `Document lié`, `Notion liée` et `Notion à travailler`.

## 13. Recherche anti-fixtures

Commande :

```bash
rg -n "Loi normale|Kant|Math|78%|4/5 bonnes|870|7 jours" lib/features/courses/presentation lib/presentation/pages/revision_sessions lib/presentation/shell || true
```

Résultat : aucune occurrence.

## 14. Limitations

- Le scan anti-wording brut continue de remonter les noms de variables Dart et de types métier. Une vraie règle anti-wording future devrait cibler les string literals ou les snapshots UI, pas les identifiants de code.
- Le changement de matière depuis Progrès renvoie vers l'accueil au lieu d'ouvrir directement un selector local. C'est volontaire pour éviter une refonte de gestion des matières dans STAB-01C.
- La fiche complète et la fiche examen ne sont pas implémentées ; elles sont retirées comme faux onglets actifs et restent pour PLUS-02.

## 15. Dette restante vers STAB-02 / CORE-09 / PLUS-02 / CORE-11

- STAB-02 : harmoniser les pages legacy restantes et extraire davantage de widgets partagés.
- CORE-09 : durcir l'archive/suppression des sources utilisées par des sessions.
- PLUS-02 : créer de vrais contenus `Fiche complète` et `Fiche examen` avant de réexposer ces surfaces.
- CORE-11 : ajouter reprise/historique de session avant tout wording du type `reprendre une session`.

## 16. Fichiers créés/modifiés/supprimés

### Créés

- `docs/ui/STAB_01C_SHEET_PROGRESS_WORDING_SUBJECTS_REPORT.md`

### Modifiés

- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `lib/features/courses/presentation/course_not_found_page.dart`
- `lib/features/courses/presentation/course_pending_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/revision_session_pending_page.dart`
- `lib/features/courses/presentation/revision_session_result_pending_page.dart`
- `lib/features/courses/presentation/sources_pending_page.dart`
- `lib/features/courses/presentation/subject_progress_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`
- `test/features/courses/course_revision_sheet_page_test.dart`
- `test/features/courses/subject_progress_page_test.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`


### Supprimés

- Aucun.

## 17. Auto-review

- [x] Docs roadmap V2 relues.
- [x] Rapports STAB-01A/STAB-01B relus.
- [x] Fiche de cours auditée.
- [x] Page Progrès auditée.
- [x] Matière active auditée.
- [x] Capacités non disponibles auditées.
- [x] Faux onglets actifs supprimés.
- [x] Wording technique utilisateur supprimé.
- [x] Données fictives évitées.
- [x] Aucune API inventée.
- [x] Tests ajoutés/ajustés.
- [x] Commandes obligatoires exécutées.
- [x] Recherches anti-wording exécutées.
- [x] Recherches anti-fixtures exécutées.
- [x] Trackers mis à jour.
- [x] Rapport créé.
- [x] Aucun commit effectué.

## 18. Confirmation backend

Aucun fichier du backend `revision_project_api` n'a été modifié. Le lot est resté App-only.

## 19. Confirmation Git

Aucun commit, amend, merge, rebase, push ou tag n'a été effectué.

## 20. Contenu complet des fichiers créés/modifiés/supprimés

Le rapport courant est créé mais ne s'inclut pas lui-même, conformément à la règle du lot.


### `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`

```md
# Execution Lot Tracker V2

Ce tracker suit les lots réellement exécutables. Les macro-lots restent suivis dans `LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Parent macro-lot | Horizon | Repo(s) | Statut | Dépend de | Travaux parallélisables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00B | STAB-00 | FOUNDATION | App + API | DONE | STAB-00 | Aucun | Durcir la roadmap V2 et créer les lots exécutables. | Docs, trackers et protocole synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | QUALITY-00 | FOUNDATION | App + API | DONE | STAB-00B | STAB-01A | Installer une baseline CI reproductible. | Flutter analyze/tests côté app ; Prisma/build/lint/tests/e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01A | STAB-01 | MVP_STABLE | App | DONE | STAB-00B | QUALITY-00 | Corriger shell, navigation, scaffold et scrolls globaux. | Bottom nav 4 onglets, routes session immersives, routes legacy conservées, scaffolds top-aligned. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md` |
| STAB-01B | STAB-01 | MVP_STABLE | App | DONE | STAB-01A | CORE-09A | Clarifier Home, Hub Révisions et hiérarchie des actions cours. | Home, hub Réviser et détail cours ont une action principale honnête, sans impasse ni wording technique. | `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md` |
| STAB-01C | STAB-01 | MVP_STABLE | App | DONE | STAB-01B | Aucun | Corriger fiche, progrès, wording et découvrabilité des matières. | Fiche sans faux onglets actifs, Progrès plus lisible, wording utilisateur nettoyé. | `docs/ui/STAB_01C_SHEET_PROGRESS_WORDING_SUBJECTS_REPORT.md` |
| STAB-02A | STAB-02 | MVP_STABLE | App | TODO | STAB-01C | CORE-10A si CORE-09A fait | Migrer Auth, Onboarding, Profil et Matières vers le design premium. | Une seule direction visuelle, sans faux état produit. | À créer |
| STAB-02B | STAB-02 | MVP_STABLE | App | TODO | STAB-02A | Aucun | Extraire les widgets feature, isoler ou déprécier le legacy. | `features/*/presentation` vidé progressivement selon la règle d'architecture. | À créer |
| CORE-09A | CORE-09 | MVP_STABLE | App + API | TODO | STAB-01A | STAB-01B | Définir archive/delete des sources. | Une source utilisée n'est plus supprimée naïvement. | À créer |
| CORE-09B | CORE-09 | MVP_STABLE | API | TODO | CORE-09A | CORE-09C | Durcir cleanup blob et abstraction storage. | Politique local/cloud documentée et testée. | À créer |
| CORE-09C | CORE-09 | MVP_STABLE | App + API | TODO | CORE-09A | CORE-09B | Ajouter les APIs de lifecycle sujet/cours nécessaires à l'UX. | Renommer/archiver devient disponible seulement si API réelle. | À créer |
| CORE-10A | CORE-10 | MVP_STABLE | App + API | TODO | CORE-09A | STAB-02A | Préparer la question bank en asynchrone. | Plus de génération longue bloquante au démarrage quick. | À créer |
| CORE-10B | CORE-10 | MVP_STABLE | API | TODO | CORE-10A | CORE-11A | Sélection multi-KU et verrouillage concurrence. | Répartition robuste, pas de double réservation évidente. | À créer |
| CORE-10C | CORE-10 | MVP_STABLE | API | TODO | CORE-10B | ADAPT-01 | Découpler QuestionBankService et ajouter métriques qualité/coût. | Service testable, métriques exploitables. | À créer |
| CORE-11A | CORE-11 | MVP_STABLE | App + API | TODO | CORE-10A | CORE-10B, PLUS-01A | Sauvegarder brouillons de session et reprise. | Une session en cours peut être reprise après fermeture. | À créer |
| CORE-11B | CORE-11 | MVP_STABLE | App + API | TODO | CORE-11A | Aucun | Historique de sessions et détail des sessions terminées. | Historique utilisable sans rouvrir un quiz terminé. | À créer |
| PLUS-01A | PLUS-01 | MVP_PLUS | App + API | TODO | STAB-02A, CORE-10A, quick lifecycle stable | CORE-11A | Deep Revision course-level avec question ouverte V1. | Action open-question réelle, correction IA, pas de résultat deep complet si hors lot. | À créer |
| PLUS-01B | PLUS-01 | MVP_PLUS | App + API | TODO | PLUS-01A, CORE-11A | Aucun | Lifecycle, completion et résultat Deep. | Deep dispose d'un résultat cohérent et testable. | À créer |
| PLUS-02 | PLUS-02 | MVP_PLUS | App + API | TODO | STAB-02B, CORE-09A | PLUS-01A | Fiches complète et pré-examen réelles. | Les faux onglets ne mentent plus. | À créer |
| ADAPT-01 | ADAPT-01 | MVP_PLUS | App + API | TODO | CORE-10B | CORE-10C | Page Today et coach adaptatif. | Recommandation honnête basée sur données réelles. | À créer |
| PLUS-03 | PLUS-03 | POST_MVP | App + API | TODO | PLUS-01B, PLUS-02, CORE-11B | Aucun | Préparation examen V1. | Mode examen distinct, résultat distinct, sources adaptées. | À créer |
| GENUI-01 | GENUI-01 | POST_MVP | App + API | TODO | STAB-02B, ADAPT-01, PLUS-01A | Aucun | Surface GenUI contrôlée par catalogue. | Payloads validés, fallback sûr, aucun UI arbitraire. | À créer |
| RELEASE-01 | RELEASE-01 | RELEASE | App + API | TODO | QUALITY-00, lots MVP_STABLE requis | Aucun | Préparation production complète. | CI, stockage, secrets, monitoring, accessibilité et conformité prêts. | À créer |

```


### `docs/roadmap/v2/LOT_TRACKER_V2.md`

```md
# Lot Tracker V2

Ce tracker suit les macro-lots stratégiques. Le détail exécutable vit dans `EXECUTION_LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Titre | Horizon | Repo(s) | Statut | Dépend de | Lots exécutables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00 | Roadmap V2 canonicalisation | FOUNDATION | App + API | DONE | Aucun | STAB-00B | Créer la source de vérité V2 et le protocole de mise à jour. | Documents V2 créés dans les deux repos. | `docs/roadmap/v2/` |
| STAB-00B | Roadmap V2 hardening, execution slicing & governance | FOUNDATION | App + API | DONE | STAB-00 | STAB-00B | Durcir la roadmap, ajouter horizons, lots exécutables et gouvernance. | Trackers, plans, décisions et protocoles synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | CI baseline | FOUNDATION | App + API | DONE | STAB-00B | QUALITY-00 | Ajouter une baseline CI avant les gros refactors. | Analyse, tests ciblés et full Flutter test côté app ; Prisma, build, lint, unit et e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01 | Product navigation & UX coherence | MVP_STABLE | App | DONE | STAB-00B | STAB-01A, STAB-01B, STAB-01C | Corriger navigation, faux affordances et parcours confus. | Tests router/widget + smoke visuel. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md`, `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md`, `docs/ui/STAB_01C_SHEET_PROGRESS_WORDING_SUBJECTS_REPORT.md` |
| STAB-02 | Frontend design system unification | MVP_STABLE | App | TODO | STAB-01C | STAB-02A, STAB-02B | Unifier les écrans legacy et premium. | Tests UI ciblés + anti-régression. | À créer |
| CORE-09 | Source lifecycle & storage policy | MVP_STABLE | API + App | TODO | STAB-01A | CORE-09A, CORE-09B, CORE-09C | Sécuriser archive/suppression de sources et stockage. | Tests Prisma + API + UI. | À créer |
| CORE-10 | Question bank production hardening | MVP_STABLE | API + App | TODO | CORE-09A | CORE-10A, CORE-10B, CORE-10C | Rendre la banque de questions robuste et moins synchrone. | Tests génération, sélection, concurrence. | À créer |
| CORE-11 | Session resume & history | MVP_STABLE | API + App | TODO | CORE-10A | CORE-11A, CORE-11B | Reprise de session et historique utilisateur. | Tests lifecycle + navigation. | À créer |
| PLUS-01 | Deep Revision course-level | MVP_PLUS | API + App | TODO | STAB-02A, CORE-10A | PLUS-01A, PLUS-01B | Activer la révision approfondie réelle. | Tests open question + correction IA. | À créer |
| PLUS-02 | Revision sheet complete / exam modes | MVP_PLUS | API + App | TODO | STAB-02B, CORE-09A | PLUS-02 | Remplacer les faux onglets fiche par de vrais contenus. | Tests fiche complète/examen. | À créer |
| ADAPT-01 | Today / adaptive coach | MVP_PLUS | API + App | TODO | CORE-10B | ADAPT-01 | Guider l'utilisateur vers la prochaine action utile. | Tests recommandation + UI Today. | À créer |
| PLUS-03 | Exam preparation V1 | POST_MVP | API + App | TODO | PLUS-01B, PLUS-02, CORE-11B | PLUS-03 | Créer un vrai mode préparation examen. | Tests session exam + résultat. | À créer |
| GENUI-01 | Controlled GenUI surface | POST_MVP | API + App | TODO | STAB-02B, ADAPT-01, PLUS-01A | GENUI-01 | Réintroduire GenUI avec widgets strictement contrôlés. | Validation payload + fallback. | À créer |
| RELEASE-01 | Production readiness | RELEASE | API + App + Infra | TODO | QUALITY-00, lots MVP_STABLE requis | RELEASE-01 | Préparer CI complète, monitoring, stockage et exploitation. | Checklist release complète. | À créer |

```


### `lib/features/courses/presentation/course_not_found_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class CourseNotFoundPage extends StatelessWidget {
  const CourseNotFoundPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Cours introuvable', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Ce cours est introuvable ou n’est plus disponible.',
          style: RevisionTypography.body,
        ),
        RevisionNotFoundState(
          title: 'Impossible d’ouvrir ce cours',
          message: 'Retourne à l’accueil pour choisir un cours disponible.',
          actionLabel: 'Retour à l’accueil',
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}

```


### `lib/features/courses/presentation/course_pending_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class CoursePendingPage extends StatelessWidget {
  const CoursePendingPage({
    required this.title,
    required this.message,
    this.actionLabel = 'Retour à l’accueil',
    super.key,
  });

  final String title;
  final String message;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text(title, style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(message, style: RevisionTypography.body),
        RevisionEmptyState(
          title: 'Page bientôt disponible',
          message:
              'Cette page est conservée pour un prochain parcours. Reviens à l’accueil pour continuer.',
          icon: Icons.pending_actions_rounded,
          actionLabel: actionLabel,
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}

```


### `lib/features/courses/presentation/course_revision_sheet_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../documents/domain/revision_document.dart';
import '../application/courses_providers.dart';
import '../domain/courses_repository.dart';

class CourseRevisionSheetPage extends ConsumerWidget {
  const CourseRevisionSheetPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheet = ref.watch(courseRevisionSheetProvider(courseId));

    return RevisionPageScaffold(
      headerChildren: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour au cours',
              onPressed: () => _popOrGo(context, AppRoutes.course(courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
            RevisionHeaderActionPill(
              label: 'Sources',
              icon: Icons.description_outlined,
              onTap: () => context.push(AppRoutes.courseSheetSources(courseId)),
            ),
          ],
        ),
        Text('Fiche', style: RevisionTypography.hero),
        Text(
          'Résumé du cours, points à retenir et sources consultables.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        sheet.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement de la fiche'),
          error: (error, stackTrace) =>
              _SheetErrorState(error: error, courseId: courseId),
          data: (sheet) {
            if (sheet == null) {
              return _GenerateSheetCard(courseId: courseId);
            }

            return _RevisionSheetContent(courseId: courseId, sheet: sheet);
          },
        ),
      ],
    );
  }
}

class _GenerateSheetCard extends ConsumerWidget {
  const _GenerateSheetCard({required this.courseId});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generateCourseRevisionSheetControllerProvider);

    if (state.isLoading) {
      return const RevisionProcessingState(
        title: 'Génération de la fiche',
        message: 'La fiche est créée depuis la première source PDF prête.',
      );
    }

    if (state.hasError) {
      return _SheetErrorState(error: state.error!, courseId: courseId);
    }

    return RevisionEmptyState(
      title: 'Fiche non générée',
      message:
          'Une source est prête, mais aucune fiche n’a encore été créée pour ce cours.',
      icon: Icons.article_outlined,
      actionLabel: 'Générer la fiche',
      onAction: () async {
        try {
          await ref
              .read(generateCourseRevisionSheetControllerProvider.notifier)
              .generate(courseId: courseId);
        } catch (_) {
          // The controller stores the error state; the next rebuild renders the
          // message mapped to the course state.
        }
      },
    );
  }
}

class _SheetErrorState extends StatelessWidget {
  const _SheetErrorState({required this.error, required this.courseId});

  final Object error;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    if (error is CourseRevisionSheetNotReadyException) {
      return RevisionErrorState(
        title: 'Aucune source prête',
        message:
            'Ajoute ou attends une source PDF traitée avec succès avant de créer une fiche.',
        actionLabel: 'Retour au cours',
        onAction: () => context.go(AppRoutes.course(courseId)),
      );
    }

    if (error is CourseNotFoundException) {
      return RevisionNotFoundState(
        title: 'Cours introuvable',
        message: 'Ce cours est introuvable.',
        actionLabel: 'Retour à l’accueil',
        onAction: () => context.go(AppRoutes.home),
      );
    }

    return RevisionErrorState(
      title: 'Fiche indisponible',
      message:
          'Impossible de charger cette fiche pour le moment. Réessaie ou retourne au cours.',
      actionLabel: 'Réessayer',
      onAction: () => context.go(AppRoutes.courseSheet(courseId)),
    );
  }
}

class CourseRevisionSheetSourcesPage extends ConsumerWidget {
  const CourseRevisionSheetSourcesPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sheet = ref.watch(courseRevisionSheetProvider(courseId));

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour à la fiche',
              onPressed: () =>
                  _popOrGo(context, AppRoutes.courseSheet(courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
        Text('Sources de la fiche', style: RevisionTypography.pageTitle),
        Text(
          'Les extraits longs sont séparés pour garder la fiche lisible.',
          style: RevisionTypography.body,
        ),
        sheet.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des sources'),
          error: (error, stackTrace) =>
              _SheetErrorState(error: error, courseId: courseId),
          data: (sheet) {
            if (sheet == null) {
              return RevisionEmptyState(
                title: 'Fiche non générée',
                message:
                    'Génère la fiche avant de consulter ses sources détaillées.',
                icon: Icons.article_outlined,
                actionLabel: 'Retour à la fiche',
                onAction: () => context.go(AppRoutes.courseSheet(courseId)),
              );
            }

            final sections = sheet.sections
                .where((section) => section.sources.isNotEmpty)
                .toList(growable: false);

            if (sections.isEmpty) {
              return const RevisionEmptyState(
                title: 'Aucune source détaillée',
                message: 'Cette fiche ne contient pas d’extrait source long.',
                icon: Icons.source_outlined,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final section in sections)
                  RevisionSheetSectionCard(
                    title: _readableStudyText(section.title),
                    icon: Icons.source_outlined,
                    accent: RevisionColors.mint,
                    children: [
                      for (final source in section.sources)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: RevisionSpacing.m,
                          ),
                          child: RevisionGlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Page ${source.pageNumber ?? '-'}',
                                  style: RevisionTypography.caption,
                                ),
                                const SizedBox(height: RevisionSpacing.xs),
                                Text(
                                  _readableStudyText(source.text),
                                  style: RevisionTypography.body,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RevisionSheetContent extends StatelessWidget {
  const _RevisionSheetContent({required this.courseId, required this.sheet});

  final String courseId;
  final RevisionSheet sheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s,
      children: [
        RevisionGlassCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              RevisionColors.blue.withValues(alpha: 0.30),
              RevisionColors.glassStrong,
            ],
          ),
          borderColor: RevisionColors.blue.withValues(alpha: 0.32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const RevisionIconTile(
                    icon: Icons.article_rounded,
                    accent: RevisionColors.blue,
                    size: 36,
                    iconSize: 20,
                  ),
                  const SizedBox(width: RevisionSpacing.s),
                  Text('Fiche de cours', style: RevisionTypography.caption),
                ],
              ),
              const SizedBox(height: RevisionSpacing.m),
              Text(
                _readableStudyText(sheet.title),
                style: RevisionTypography.pageTitle,
              ),
            ],
          ),
        ),
        if (sheet.introduction != null)
          RevisionSheetSectionCard(
            title: 'Résumé',
            icon: Icons.summarize_rounded,
            accent: RevisionColors.blue,
            children: [
              Text(
                _readableStudyText(sheet.introduction!),
                style: RevisionTypography.body,
              ),
            ],
          ),
        if (sheet.keyPoints.isNotEmpty)
          _TextListCard(
            title: 'Points clés',
            icon: Icons.check_circle_rounded,
            accent: RevisionColors.green,
            items: sheet.keyPoints.map(_readableStudyText).toList(),
          ),
        if (sheet.commonMistakes.isNotEmpty)
          _TextListCard(
            title: 'Pièges fréquents',
            icon: Icons.warning_amber_rounded,
            accent: RevisionColors.coral,
            items: sheet.commonMistakes.map(_readableStudyText).toList(),
          ),
        if (sheet.mustKnow.isNotEmpty)
          _TextListCard(
            title: 'À connaître',
            icon: Icons.school_rounded,
            accent: RevisionColors.violet,
            items: sheet.mustKnow.map(_readableStudyText).toList(),
          ),
        for (final section in sheet.sections)
          _SectionCard(courseId: courseId, section: section),
        if (sheet.practiceSuggestions.isNotEmpty)
          _TextListCard(
            title: 'S’entraîner',
            icon: Icons.fitness_center_rounded,
            accent: RevisionColors.pink,
            items: sheet.practiceSuggestions.map(_readableStudyText).toList(),
          ),
      ],
    );
  }
}

class _TextListCard extends StatelessWidget {
  const _TextListCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return RevisionSheetSectionCard(
      title: title,
      icon: icon,
      accent: accent,
      children: [
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•', style: RevisionTypography.body.copyWith(color: accent)),
              const SizedBox(width: RevisionSpacing.s),
              Expanded(child: Text(item, style: RevisionTypography.body)),
            ],
          ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.courseId, required this.section});

  final String courseId;
  final RevisionSheetSection section;

  @override
  Widget build(BuildContext context) {
    return RevisionSheetSectionCard(
      title: section.title,
      icon: Icons.notes_rounded,
      accent: RevisionColors.mint,
      children: [
        Text(
          _readableStudyText(section.content),
          style: RevisionTypography.body,
        ),
        if (section.sources.isNotEmpty) ...[
          const SizedBox(height: RevisionSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  context.push(AppRoutes.courseSheetSources(courseId)),
              icon: const Icon(Icons.source_outlined, size: 16),
              label: const Text('Sources >'),
            ),
          ),
        ],
      ],
    );
  }
}

String _readableStudyText(String value) {
  return value
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)[\.·-]e[\.·-]s\b'),
        (match) => '${match.group(1)}s',
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)[\.·-]es\b'),
        (match) => '${match.group(1)}s',
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)\(e\)s\b'),
        (match) => '${match.group(1)}s',
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)[\.·-]e\b'),
        (match) => match.group(1)!,
      )
      .replaceAllMapped(
        RegExp(r'\b([A-Za-zÀ-ÖØ-öø-ÿ]+)\(e\)\b'),
        (match) => match.group(1)!,
      );
}

void _popOrGo(BuildContext context, String fallbackLocation) {
  // The sheet is normally stacked above course detail; direct URLs still need a
  // deterministic fallback because there may be nothing to pop.
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackLocation);
}

```


### `lib/features/courses/presentation/revision_session_pending_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class RevisionSessionPendingPage extends StatelessWidget {
  const RevisionSessionPendingPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Session de révision', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Cette page sera utilisée par les prochains parcours de révision.',
          style: RevisionTypography.body,
        ),
        RevisionEmptyState(
          title: 'Session indisponible',
          message:
              'Pour le moment, lance une session rapide depuis un cours prêt.',
          icon: Icons.track_changes_rounded,
          actionLabel: 'Retour aux révisions',
          onAction: () => context.go(AppRoutes.revisions),
        ),
      ],
    );
  }
}

```


### `lib/features/courses/presentation/revision_session_result_pending_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class RevisionSessionResultPendingPage extends StatelessWidget {
  const RevisionSessionResultPendingPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      children: [
        Text('Résultat de session', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Le résultat sera affiché après une session terminée.',
          style: RevisionTypography.body,
        ),
        RevisionEmptyState(
          title: 'Résultat indisponible',
          message:
              'Aucun score n’est affiché tant qu’une session n’a pas été finalisée.',
          icon: Icons.emoji_events_outlined,
          actionLabel: 'Retour aux révisions',
          onAction: () => context.go(AppRoutes.revisions),
        ),
      ],
    );
  }
}

```


### `lib/features/courses/presentation/sources_pending_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';

class SourcesPendingPage extends StatelessWidget {
  const SourcesPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RevisionPageScaffold(
      headerChildren: [
        Text('Sources', style: RevisionTypography.pageTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(
          'Les PDF se gèrent depuis le détail de chaque cours.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        RevisionEmptyState(
          title: 'Sources depuis les cours',
          message:
              'Ouvre un cours puis utilise Ajouter une source. Cette page globale deviendra un catalogue centralisé plus tard.',
          icon: Icons.description_outlined,
          actionLabel: 'Ouvrir les cours',
          onAction: () => context.go(AppRoutes.home),
        ),
      ],
    );
  }
}

```


### `lib/features/courses/presentation/subject_progress_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_subject_visuals.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../subjects/application/subjects_notifier.dart';
import '../../subjects/domain/subject.dart';
import '../application/active_subject_provider.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';

class SubjectProgressPage extends ConsumerWidget {
  const SubjectProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubject = ref.watch(activeSubjectProvider);

    return RevisionPageScaffold(
      headerChildren: [
        Text('Progrès', style: RevisionTypography.hero),
        Text(
          'Ta progression vient des notions générées depuis tes sources prêtes et de tes réponses.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        activeSubject.when(
          loading: () =>
              const RevisionLoadingState(label: 'Chargement des matières'),
          error: (error, stackTrace) => RevisionErrorState(
            title: 'Impossible de charger les matières',
            message:
                'Choisis ou crée une matière pour afficher ta progression.',
            actionLabel: 'Réessayer',
            onAction: () =>
                ref.read(subjectsNotifierProvider.notifier).reload(),
          ),
          data: (subject) {
            if (subject == null) {
              return RevisionEmptyState(
                title: 'Crée une matière pour suivre ta progression.',
                message:
                    'Ajoute ensuite un cours et une source pour commencer à voir tes notions.',
                icon: Icons.trending_up_rounded,
                actionLabel: 'Ouvrir les matières',
                onAction: () => context.go(AppRoutes.subjects),
              );
            }

            return _SubjectProgressContent(subject: subject);
          },
        ),
      ],
    );
  }
}

class _SubjectProgressContent extends ConsumerWidget {
  const _SubjectProgressContent({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(subjectProgressProvider(subject.id));

    return progress.when(
      loading: () =>
          const RevisionLoadingState(label: 'Chargement de la progression'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Progression indisponible',
        message:
            'Impossible de charger les informations de progression pour cette matière.',
        actionLabel: 'Réessayer',
        onAction: () => ref.invalidate(subjectProgressProvider(subject.id)),
      ),
      data: (progress) =>
          _SubjectProgressLoaded(subject: subject, progress: progress),
    );
  }
}

class _SubjectProgressLoaded extends StatelessWidget {
  const _SubjectProgressLoaded({required this.subject, required this.progress});

  final Subject subject;
  final SubjectProgress progress;

  @override
  Widget build(BuildContext context) {
    final visual = revisionSubjectVisualThemeFor(subject.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionGlassCard(
          padding: const EdgeInsets.all(RevisionSpacing.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              visual.accent.withValues(alpha: 0.26),
              RevisionColors.glassStrong,
            ],
          ),
          borderColor: visual.accent.withValues(alpha: 0.36),
          child: Row(
            children: [
              RevisionMasteryRing(
                value: progress.estimatedGlobalMastery,
                label: _percent(progress.estimatedGlobalMastery),
                caption: 'global',
                color: progress.mastery == null
                    ? visual.accent
                    : RevisionColors.green,
                size: 104,
              ),
              const SizedBox(width: RevisionSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name, style: RevisionTypography.sectionTitle),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text('Matière active', style: RevisionTypography.caption),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      '${progress.practicedKnowledgeUnitCount}/${progress.knowledgeUnitCount} notions travaillées',
                      style: RevisionTypography.sectionTitle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    RevisionProgressLine(
                      value: progress.coverage,
                      color: visual.accent,
                      height: 8,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    Text(
                      _masteryLabel(progress.mastery),
                      style: RevisionTypography.caption,
                    ),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text(
                      'Estimation globale : ${_percent(progress.estimatedGlobalMastery)}',
                      style: RevisionTypography.caption,
                    ),
                    const SizedBox(height: RevisionSpacing.s),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                        label: const Text('Changer de matière'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.l),
        _SubjectProgressMeta(progress: progress, visual: visual),
        const SizedBox(height: RevisionSpacing.l),
        if (progress.courses.isEmpty)
          RevisionEmptyState(
            title: 'Aucun cours à suivre',
            message:
                'Crée un cours, ajoute une source PDF, puis révise pour suivre tes notions.',
            icon: Icons.layers_outlined,
            actionLabel: 'Retour à l’accueil',
            onAction: () => context.go(AppRoutes.home),
          )
        else ...[
          Text('Tes cours', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          for (final course in progress.courses) ...[
            _SubjectCourseProgressCard(course: course, visual: visual),
            const SizedBox(height: RevisionSpacing.m),
          ],
          _WeakPointSummary(courses: progress.courses),
        ],
      ],
    );
  }
}

class _SubjectProgressMeta extends StatelessWidget {
  const _SubjectProgressMeta({required this.progress, required this.visual});

  final SubjectProgress progress;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RevisionSpacing.s,
      runSpacing: RevisionSpacing.s,
      children: [
        RevisionMetricPill(
          label: '${progress.courseCount} cours',
          icon: Icons.layers_rounded,
          accent: visual.accent,
        ),
        RevisionMetricPill(
          label: '${progress.readyCourseCount} avec source prête',
          icon: Icons.check_circle_rounded,
          accent: RevisionColors.green,
        ),
        RevisionMetricPill(
          label: progress.lastPracticedAt == null
              ? 'Pas encore pratiqué'
              : 'Déjà pratiqué',
          icon: Icons.history_rounded,
          accent: RevisionColors.amber,
        ),
      ],
    );
  }
}

class _SubjectCourseProgressCard extends StatelessWidget {
  const _SubjectCourseProgressCard({
    required this.course,
    required this.visual,
  });

  final SubjectCourseProgressItem course;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(course.state, visual);

    return RevisionGlassCard(
      onTap: () => context.push(AppRoutes.course(course.courseId)),
      padding: const EdgeInsets.all(RevisionSpacing.m),
      child: Row(
        children: [
          RevisionIconTile(
            icon: visual.icon,
            accent: color,
            size: 48,
            iconSize: 26,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '${course.practicedKnowledgeUnitCount}/${course.knowledgeUnitCount} notions travaillées',
                  style: RevisionTypography.body,
                ),
                const SizedBox(height: RevisionSpacing.s),
                RevisionProgressLine(
                  value: course.coverage,
                  color: color,
                  height: 6,
                ),
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  _stateLabel(course.state),
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          Text(
            _percent(course.estimatedGlobalMastery),
            style: RevisionTypography.sectionTitle.copyWith(
              color: RevisionColors.text,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeakPointSummary extends StatelessWidget {
  const _WeakPointSummary({required this.courses});

  final List<SubjectCourseProgressItem> courses;

  @override
  Widget build(BuildContext context) {
    final weakCourses = courses
        .where((course) => course.state != CourseProgressState.practiced)
        .take(3)
        .toList(growable: false);

    if (weakCourses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: RevisionSpacing.s),
        Text('À préparer', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        for (final course in weakCourses) ...[
          RevisionGlassCard(
            onTap: () => context.push(AppRoutes.course(course.courseId)),
            padding: const EdgeInsets.all(RevisionSpacing.m),
            child: Row(
              children: [
                const RevisionIconTile(
                  icon: Icons.priority_high_rounded,
                  accent: RevisionColors.amber,
                  size: 36,
                  iconSize: 20,
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: RevisionTypography.sectionTitle,
                      ),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        _stateLabel(course.state),
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.s),
        ],
      ],
    );
  }
}

String _masteryLabel(double? mastery) {
  if (mastery == null) {
    return 'Maîtrise travaillée : en attente';
  }

  return 'Maîtrise travaillée : ${_percent(mastery)}';
}

String _stateLabel(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.noSource => 'Ajoute une source pour commencer.',
    CourseProgressState.processing => 'Analyse du PDF en cours.',
    CourseProgressState.failedOnly =>
      'Les sources ont échoué. Ajoute ou corrige une source.',
    CourseProgressState.noKnowledgeUnits =>
      'Source prête, mais aucune notion exploitable.',
    CourseProgressState.readyNotPracticed =>
      'Notions prêtes, pas encore travaillées.',
    CourseProgressState.practiced => 'Progression basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression disponible.',
  };
}

Color _stateColor(
  CourseProgressState state,
  RevisionSubjectVisualTheme visual,
) {
  return switch (state) {
    CourseProgressState.practiced => RevisionColors.green,
    CourseProgressState.readyNotPracticed => visual.accent,
    CourseProgressState.processing => RevisionColors.amber,
    CourseProgressState.failedOnly => RevisionColors.red,
    CourseProgressState.noKnowledgeUnits => RevisionColors.violet,
    CourseProgressState.noSource => visual.accent,
    CourseProgressState.unknown => RevisionColors.mint,
  };
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
}

```


### `lib/presentation/pages/revision_sessions/revision_session_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';
import 'package:revision_app/features/revision_sessions/presentation/quick_revision_quiz_flow.dart';
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

    if (session == null) {
      return const RevisionPage(
        title: 'Révision IA',
        subtitle: 'Une session contrôlée à partir de tes activités existantes.',
        children: [_EmptyRevisionSessionState()],
      );
    }

    return FutureBuilder<RevisionSessionResponse>(
      future: session,
      builder: (context, snapshot) {
        final response = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPage(
            title: 'Révision rapide',
            subtitle: 'Préparation de ta session.',
            children: [Center(child: CircularProgressIndicator())],
          );
        }

        if (snapshot.hasError || response == null) {
          return RevisionPage(
            title: 'Révision IA',
            subtitle:
                'Une session contrôlée à partir de tes activités existantes.',
            children: [_RevisionSessionErrorState(onRetry: _retry)],
          );
        }

        if (_isCompletedCourseQuickSession(response) ||
            _isCompletedCourseQuickAction(response)) {
          return _CompletedCourseQuickSessionRedirect(response: response);
        }

        final premiumActivity = _premiumQuickActivity(response);
        if (premiumActivity != null) {
          return QuickRevisionQuizFlow(
            response: response,
            activity: premiumActivity,
            activityController: widget.activityController,
            revisionSessionController: widget.revisionSessionController,
          );
        }

        return RevisionPage(
          title: 'Révision IA',
          subtitle:
              'Une session contrôlée à partir de tes activités existantes.',
          children: [
            _RevisionSessionContent(
              response: response,
              activityController: widget.activityController,
            ),
          ],
        );
      },
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

DiagnosticQuizActivity? _premiumQuickActivity(
  RevisionSessionResponse response,
) {
  final action = response.currentAction;
  final payload = action?.payload;
  if (response.session.status != RevisionSessionStatus.started ||
      response.session.mode != RevisionSessionMode.quick ||
      response.session.courseId == null ||
      action?.kind != RevisionSessionActionKind.diagnosticQuiz ||
      action?.status != RevisionSessionActionStatus.ready ||
      payload is! RevisionSessionDiagnosticQuizPayload) {
    return null;
  }

  if (payload.activity.questions.isEmpty) {
    return null;
  }

  return payload.activity;
}

bool _isCompletedCourseQuickSession(RevisionSessionResponse response) {
  return response.session.status == RevisionSessionStatus.completed &&
      response.session.mode == RevisionSessionMode.quick &&
      response.session.courseId != null;
}

bool _isCompletedCourseQuickAction(RevisionSessionResponse response) {
  final action = response.currentAction;
  return response.session.mode == RevisionSessionMode.quick &&
      response.session.courseId != null &&
      action?.kind == RevisionSessionActionKind.diagnosticQuiz &&
      action?.status == RevisionSessionActionStatus.completed;
}

class _CompletedCourseQuickSessionRedirect extends StatefulWidget {
  const _CompletedCourseQuickSessionRedirect({required this.response});

  final RevisionSessionResponse response;

  @override
  State<_CompletedCourseQuickSessionRedirect> createState() =>
      _CompletedCourseQuickSessionRedirectState();
}

class _CompletedCourseQuickSessionRedirectState
    extends State<_CompletedCourseQuickSessionRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.go(
        AppRoutes.revisionSessionResultV2(
          sessionId: widget.response.session.id,
          courseId: widget.response.session.courseId,
          mode: 'quick',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const RevisionPage(
      title: 'Révision terminée',
      subtitle: 'Ouverture du résultat.',
      children: [Center(child: CircularProgressIndicator())],
    );
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
                label: 'Matière liée',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.menu_book_outlined,
              ),
              if (session.documentId != null)
                RevisionStatusPill(
                  label: 'Document lié',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.description_outlined,
                ),
              if (session.knowledgeUnitId != null)
                RevisionStatusPill(
                  label: 'Notion liée',
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
      return 'Notion : $title';
    }

    return 'Notion à travailler';
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


### `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../features/revision_sessions/application/revision_session_controller.dart';
import '../../../features/revision_sessions/data/revision_sessions_api.dart';
import '../../../features/revision_sessions/domain/revision_session.dart';
import '../../design_system/components/revision_mvp_components.dart';
import '../../design_system/components/revision_states.dart';
import '../../design_system/tokens/revision_colors.dart';
import '../../design_system/tokens/revision_spacing.dart';
import '../../design_system/tokens/revision_typography.dart';

class RevisionSessionResultPage extends StatefulWidget {
  const RevisionSessionResultPage({
    required this.sessionId,
    required this.controller,
    super.key,
  });

  final String sessionId;
  final RevisionSessionController controller;

  @override
  State<RevisionSessionResultPage> createState() =>
      _RevisionSessionResultPageState();
}

class _RevisionSessionResultPageState extends State<RevisionSessionResultPage> {
  late Future<RevisionSessionResult> _result;

  @override
  void initState() {
    super.initState();
    _result = _load();
  }

  @override
  void didUpdateWidget(covariant RevisionSessionResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      _result = _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RevisionSessionResult>(
      future: _result,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPageScaffold(
            children: [
              RevisionProcessingState(
                title: 'Chargement du résultat',
                message: 'Préparation du bilan de la session.',
              ),
            ],
          );
        }

        final result = snapshot.data;
        if (snapshot.hasError || result == null) {
          return RevisionPageScaffold(
            children: [
              Text('Résultat', style: RevisionTypography.pageTitle),
              RevisionErrorState(
                title: _errorTitle(snapshot.error),
                message: _errorMessage(snapshot.error),
                actionLabel: 'Réessayer',
                onAction: () => setState(() => _result = _load()),
              ),
            ],
          );
        }

        return _ResultContent(result: result);
      },
    );
  }

  Future<RevisionSessionResult> _load() {
    return widget.controller.loadResult(sessionId: widget.sessionId);
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.result});

  final RevisionSessionResult result;

  @override
  Widget build(BuildContext context) {
    final mastered = result.knowledgeUnits
        .where(
          (unit) =>
              unit.state == RevisionSessionKnowledgeUnitResultState.mastered,
        )
        .toList(growable: false);
    final toReview = result.knowledgeUnits
        .where(
          (unit) =>
              unit.state == RevisionSessionKnowledgeUnitResultState.toReview,
        )
        .toList(growable: false);
    final missedCorrections = result.corrections
        .where((correction) => !correction.isCorrect)
        .toList(growable: false);
    final courseId = result.session.courseId;

    final showConfetti = result.summary.score > 0.70;

    return Stack(
      children: [
        RevisionPageScaffold(
          children: [
            Text(
              'Session terminée',
              textAlign: TextAlign.center,
              style: RevisionTypography.sectionTitle,
            ),
            RevisionGlassCard(
              child: Column(
                children: [
                  RevisionMasteryRing(
                    value: result.summary.score,
                    label: '${(result.summary.score * 100).round()}%',
                    caption: 'global',
                    size: 112,
                    color: _scoreColor(result.summary.score),
                  ),
                  const SizedBox(height: RevisionSpacing.m),
                  Text(
                    _resultMessage(result.summary.score),
                    style: RevisionTypography.sectionTitle,
                  ),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    '${result.summary.correctAnswers}/${result.summary.totalQuestions} bonnes réponses',
                    style: RevisionTypography.body,
                  ),
                ],
              ),
            ),
            if (mastered.isNotEmpty)
              _ResultSection(
                title: 'Tu maîtrises',
                icon: Icons.check_circle_rounded,
                color: RevisionColors.green,
                units: mastered,
              ),
            if (toReview.isNotEmpty)
              _ResultSection(
                title: 'À retravailler',
                icon: Icons.error_rounded,
                color: RevisionColors.amber,
                units: toReview,
              ),
            if (missedCorrections.isNotEmpty)
              _MissedCorrectionsSection(corrections: missedCorrections),
            RevisionGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Prochaine étape',
                    style: RevisionTypography.sectionTitle,
                  ),
                  const SizedBox(height: RevisionSpacing.m),
                  if (courseId != null) ...[
                    RevisionGradientButton(
                      label: 'Voir la fiche',
                      icon: Icons.description_rounded,
                      expanded: true,
                      gradient: const LinearGradient(
                        colors: [
                          RevisionColors.glassStrong,
                          RevisionColors.ink3,
                        ],
                      ),
                      onPressed: () =>
                          context.push(AppRoutes.courseSheet(courseId)),
                    ),
                    const SizedBox(height: RevisionSpacing.m),
                    RevisionGradientButton(
                      label: 'Retour au cours',
                      icon: Icons.arrow_back_rounded,
                      expanded: true,
                      onPressed: () => context.go(AppRoutes.course(courseId)),
                    ),
                  ] else
                    RevisionGradientButton(
                      label: 'Retour aux révisions',
                      icon: Icons.arrow_back_rounded,
                      expanded: true,
                      onPressed: () => context.go(AppRoutes.revisions),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (showConfetti)
          const Positioned.fill(child: RevisionConfettiOverlay()),
      ],
    );
  }
}

class _MissedCorrectionsSection extends StatelessWidget {
  const _MissedCorrectionsSection({required this.corrections});

  final List<RevisionSessionQuestionCorrection> corrections;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: RevisionColors.blue),
              const SizedBox(width: RevisionSpacing.s),
              Text(
                'Ce que tu as loupé',
                style: RevisionTypography.sectionTitle,
              ),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final correction in corrections) ...[
            Text(
              correction.prompt,
              style: RevisionTypography.body.copyWith(
                color: RevisionColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: RevisionSpacing.s),
            _CorrectionLine(
              label: 'Ta réponse',
              value: _answersLabel(correction.selectedAnswers),
              color: RevisionColors.red,
            ),
            const SizedBox(height: RevisionSpacing.xs),
            _CorrectionLine(
              label: 'Correction',
              value: _answersLabel(correction.correctAnswers),
              color: RevisionColors.green,
            ),
            if (correction.explanation != null) ...[
              const SizedBox(height: RevisionSpacing.s),
              Text(correction.explanation!, style: RevisionTypography.caption),
            ],
            if (correction != corrections.last)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: RevisionSpacing.m),
                child: Divider(color: RevisionColors.border),
              ),
          ],
        ],
      ),
    );
  }
}

class _CorrectionLine extends StatelessWidget {
  const _CorrectionLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: RevisionSpacing.s),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label : ',
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.textMuted,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.units,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<RevisionSessionKnowledgeUnitResult> units;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: RevisionSpacing.s),
              Text(title, style: RevisionTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          for (final unit in units)
            Padding(
              padding: const EdgeInsets.only(bottom: RevisionSpacing.s),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      unit.title,
                      style: RevisionTypography.body.copyWith(
                        color: RevisionColors.text,
                      ),
                    ),
                  ),
                  Text(
                    '${(unit.score * 100).round()}%',
                    style: RevisionTypography.caption.copyWith(color: color),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _resultMessage(double score) {
  if (score >= 0.85) {
    return 'Très belle maîtrise.';
  }
  if (score >= 0.65) {
    return 'Bonne progression.';
  }
  if (score >= 0.40) {
    return 'Les bases prennent forme.';
  }

  return 'Cette notion mérite une nouvelle passe.';
}

String _answersLabel(List<String> answers) {
  if (answers.isEmpty) {
    return 'Aucune réponse';
  }

  return answers.join(', ');
}

Color _scoreColor(double score) {
  if (score >= 0.8) {
    return RevisionColors.green;
  }
  if (score >= 0.4) {
    return RevisionColors.amber;
  }

  return RevisionColors.red;
}

String _errorTitle(Object? error) {
  if (error is RevisionSessionNotFoundException) {
    return 'Session introuvable';
  }
  if (error is RevisionSessionResultNotReadyException) {
    return 'Résultat indisponible';
  }

  return 'Impossible de charger le résultat';
}

String _errorMessage(Object? error) {
  if (error is RevisionSessionResultNotReadyException) {
    return error.message;
  }

  return 'Le résultat sera affiché après une session finalisée.';
}

```


### `test/app/revision_app_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/app_root.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/core/storage/kv_storage_port.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/auth/application/auth_controller.dart';
import 'package:revision_app/features/auth/domain/auth_session.dart';
import 'package:revision_app/features/auth/domain/authenticated_user.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

import '../fakes/in_memory_activity_api.dart';
import '../fakes/in_memory_courses_repository.dart';
import '../fakes/in_memory_documents_api.dart';
import '../fakes/in_memory_revision_goals_repository.dart';
import '../fakes/in_memory_subjects_repository.dart';
import '../fakes/in_memory_today_repository.dart';

class SignedInAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedIn(
      AuthenticatedUser(
        uid: 'firebase-123',
        email: 'student@example.com',
        displayName: 'Karim',
      ),
    );
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

class SignedOutAuthRepository implements AuthRepository {
  @override
  Stream<AuthSession> watchSession() async* {
    yield const AuthSession.signedOut();
  }

  @override
  Future<String> requireIdToken() async {
    throw StateError('A signed-in user is required');
  }

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class FakeKvStorage implements KvStoragePort {
  @override
  Future<String?> readString(String key) async => null;

  @override
  Future<void> writeString(String key, String value) async {}
}

void main() {
  testWidgets('shows a real-ready home without fixture courses', (
    tester,
  ) async {
    final testApp = _createTestApp();

    await tester.pumpWidget(testApp.widget);
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Commence par créer une matière.'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('12'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
    expect(find.text('Progrès'), findsOneWidget);
    expect(find.text('Réviser'), findsOneWidget);
    expect(find.text('Sources'), findsNothing);
    expect(find.byType(RevisionBottomNavigation), findsOneWidget);
    expect(testApp.authController.isSignedIn, isTrue);
  });

  testWidgets('bottom navigation opens honest real-ready pages', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progrès'));
    await tester.pumpAndSettle();

    expect(
      find.text('Crée une matière pour suivre ta progression.'),
      findsOneWidget,
    );
    expect(find.text('Progression réelle en attente'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.textContaining('CORE-06 branchera'), findsNothing);

    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Réviser'), findsWidgets);
    expect(find.text('Choisis une session courte et utile.'), findsOneWidget);
    expect(find.text('Aucune matière disponible'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
    expect(find.textContaining('à brancher en CORE-05'), findsNothing);
    expect(find.text('Sources'), findsNothing);
    expect(find.textContaining('CORE-03 branchera'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can list real subjects without inventing courses', (
    tester,
  ) async {
    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsWidgets);
    expect(find.text('Aucun cours pour le moment'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home can create and select a subject from the subject picker', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Droits').first);
    await tester.pumpAndSettle();

    expect(find.text('Choisir une matière'), findsOneWidget);
    expect(find.text('Créer une matière'), findsOneWidget);

    await tester.tap(find.text('Créer une matière'));
    await tester.pumpAndSettle();

    expect(find.text('Créer une matière'), findsOneWidget);
    expect(find.text('Nom de la matière'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Histoire');
    await tester.tap(find.text('Créer la matière'));
    await tester.pumpAndSettle();

    expect(find.text('Histoire'), findsWidgets);
    expect(find.text('Tes cours de Histoire'), findsOneWidget);
    expect(find.text('Aucun cours pour le moment'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('home can list real courses for the active subject', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
        seedCourses: const [
          CourseListItem(
            id: 'course-real-1',
            subjectId: 'subject-real-1',
            title: 'Institutions de la Ve République',
            chapterLabel: 'Chapitre 2',
            estimatedMinutes: 35,
            sourceCount: 1,
            readySourceCount: 1,
            processingSourceCount: 0,
            failedSourceCount: 0,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Institutions de la Ve République'), findsWidgets);
    expect(find.text('Chapitre 2 · 35 min'), findsOneWidget);
    expect(find.text('1 source · 1 prête'), findsWidgets);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('home keeps its premium header fixed while course cards scroll', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    final courses = List<CourseListItem>.generate(
      12,
      (index) => CourseListItem(
        id: 'course-real-${index + 1}',
        subjectId: 'subject-real-1',
        title: 'Cours ${index + 1}',
        chapterLabel: 'Chapitre ${index + 1}',
        estimatedMinutes: 20 + index,
        sourceCount: 1,
        readySourceCount: 1,
        processingSourceCount: 0,
        failedSourceCount: 0,
      ),
    );

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(id: 'subject-real-1', name: 'Droits', priority: 4),
        ],
        seedCourses: courses,
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Cours prêt à réviser'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsNothing);
    expect(find.text('Cours 12'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Cours 12'),
      600,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Droits'), findsWidgets);
    expect(find.text('Continue ton progrès'), findsOneWidget);
    expect(find.text('Cours prêt à réviser'), findsOneWidget);
    expect(find.text('Reprendre le cours'), findsNothing);
    expect(find.text('Cours 12'), findsOneWidget);
  });

  testWidgets('home can create a real course and open its detail', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(430, 932);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(
      _createTestApp(
        seedSubjects: const [
          Subject(
            id: 'subject-real-1',
            name: 'Droit constitutionnel',
            priority: 4,
          ),
        ],
      ).widget,
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Créer un cours'),
    );
    await tester.tap(
      find.widgetWithText(FilledButton, 'Créer un cours').hitTestable(),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Droit administratif');
    await tester.tap(find.text('Créer le cours'));
    await tester.pumpAndSettle();

    expect(find.text('Droit administratif'), findsOneWidget);
    expect(find.text('Cours introuvable'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course and result routes do not fallback to fixture data', (
    tester,
  ) async {
    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(RevisionBottomNavigation));
    GoRouter.of(context).go('/courses/unknown');
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Impossible d’ouvrir ce cours'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);

    GoRouter.of(context).go('/revision-sessions/fake/result');
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le résultat'), findsOneWidget);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
  });

  testWidgets('uses route-driven navigation rail on wide layouts', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(1200, 900);
    addTearDown(view.resetDevicePixelRatio);
    addTearDown(view.resetPhysicalSize);

    await tester.pumpWidget(_createTestApp().widget);
    await tester.pumpAndSettle();

    expect(find.byType(RevisionNavigationRail), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);

    await tester.tap(find.text('Réviser'));
    await tester.pumpAndSettle();

    expect(find.text('Réviser'), findsWidgets);
    expect(find.text('Choisis une session courte et utile.'), findsOneWidget);
    expect(find.text('Aucune matière disponible'), findsOneWidget);
    expect(find.textContaining('CORE-05 branchera'), findsNothing);
  });

  testWidgets('redirects signed-out users to the sign-in page', (tester) async {
    await tester.pumpWidget(
      _createTestApp(
        authController: AuthController(SignedOutAuthRepository()),
      ).widget,
    );
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
    expect(find.text('Continuer avec Apple'), findsOneWidget);
  });
}

AuthController signedInAuthController() {
  return AuthController(SignedInAuthRepository());
}

_RevisionTestApp _createTestApp({
  AuthController? authController,
  List<Subject> seedSubjects = const [],
  List<CourseListItem> seedCourses = const [],
}) {
  final resolvedAuthController = authController ?? signedInAuthController();
  final subjectsRepository = InMemorySubjectsRepository();
  subjectsRepository.subjects.addAll(seedSubjects);
  final coursesRepository = InMemoryCoursesRepository();
  for (final course in seedCourses) {
    coursesRepository.coursesBySubject
        .putIfAbsent(course.subjectId, () => [])
        .add(course);
    coursesRepository.detailsByCourse[course.id] = CourseDetail(
      course: course,
      subject: CourseSubjectSummary(
        id: course.subjectId,
        name: _subjectNameFor(seedSubjects, course.subjectId),
      ),
      sources: const [],
    );
  }
  final revisionGoalsRepository = InMemoryRevisionGoalsRepository();
  final documentsApi = InMemoryDocumentsApi();
  final activityApi = InMemoryActivityApi();
  final todayRepository = InMemoryTodayRepository();

  resolvedAuthController.start();
  addTearDown(resolvedAuthController.dispose);

  final widget = ProviderScope(
    overrides: [
      kvStorageProvider.overrideWithValue(FakeKvStorage()),
      authControllerProvider.overrideWithValue(resolvedAuthController),
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      subjectsControllerProvider.overrideWithValue(
        SubjectsController(subjectsRepository),
      ),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
      revisionGoalsControllerProvider.overrideWithValue(
        RevisionGoalsController(revisionGoalsRepository),
      ),
      documentsControllerProvider.overrideWithValue(
        DocumentsController(documentsApi),
      ),
      documentsApiProvider.overrideWithValue(documentsApi),
      activityControllerProvider.overrideWithValue(
        ActivityController(activityApi),
      ),
      todayRepositoryProvider.overrideWithValue(todayRepository),
      todayControllerProvider.overrideWithValue(
        TodayController(todayRepository),
      ),
    ],
    child: const AppRoot(),
  );

  return _RevisionTestApp(
    widget: widget,
    authController: resolvedAuthController,
    revisionGoalsRepository: revisionGoalsRepository,
    activityApi: activityApi,
    todayRepository: todayRepository,
  );
}

String _subjectNameFor(List<Subject> subjects, String subjectId) {
  for (final subject in subjects) {
    if (subject.id == subjectId) {
      return subject.name;
    }
  }

  return 'Matière réelle';
}

class _RevisionTestApp {
  const _RevisionTestApp({
    required this.widget,
    required this.authController,
    required this.revisionGoalsRepository,
    required this.activityApi,
    required this.todayRepository,
  });

  final Widget widget;
  final AuthController authController;
  final InMemoryRevisionGoalsRepository revisionGoalsRepository;
  final InMemoryActivityApi activityApi;
  final InMemoryTodayRepository todayRepository;
}

```


### `test/app/router/app_router_test.dart`

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
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/onboarding/application/revision_goals_controller.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/subjects/application/subjects_controller.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';
import 'package:revision_app/features/today/application/today_controller.dart';
import 'package:revision_app/features/today/domain/today_plan.dart';
import 'package:revision_app/presentation/design_system/components/revision_mvp_components.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_navigation.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_courses_repository.dart';
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
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
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

  test('shell keeps only primary destinations and sessions outside shell', () {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    final shellRoute = harness.router.configuration.routes
        .whereType<StatefulShellRoute>()
        .single;
    final branchRoots = shellRoute.branches
        .map((branch) => branch.routes.whereType<GoRoute>().first.path)
        .toList(growable: false);
    final shellPaths = shellRoute.branches
        .expand((branch) => branch.routes.whereType<GoRoute>())
        .map((route) => route.path)
        .toSet();
    final topLevelPaths = harness.router.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toSet();

    expect(branchRoots, [
      AppRoutes.home,
      AppRoutes.progress,
      AppRoutes.revisions,
      AppRoutes.profile,
    ]);
    expect(shellPaths, isNot(contains(AppRoutes.sources)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionV2Path)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionResultV2Path)));
    expect(shellPaths, isNot(contains(AppRoutes.revisionSessionPath)));
    expect(shellPaths, isNot(contains(AppRoutes.richClosedExercisePath)));
    expect(topLevelPaths, contains(AppRoutes.sources));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionV2Path));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionResultV2Path));
    expect(topLevelPaths, contains(AppRoutes.revisionSessionPath));
    expect(topLevelPaths, contains(AppRoutes.richClosedExercisePath));
  });

  testWidgets('home route does not render MVP fixture course data', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsWidgets);
    expect(find.text('Commence par créer une matière.'), findsOneWidget);
    expect(find.text('Math'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('course route shows not found instead of fixture fallback', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.course('unknown'));
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Impossible d’ouvrir ce cours'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course route shows real course detail when available', (
    tester,
  ) async {
    final harness = _RouterHarness();
    harness.subjectsRepository.subjects.add(
      const Subject(
        id: 'subject-1',
        name: 'Droit constitutionnel',
        priority: 4,
      ),
    );
    const course = CourseListItem(
      id: 'course-1',
      subjectId: 'subject-1',
      title: 'Institutions de la Ve République',
      chapterLabel: 'Chapitre 2',
      estimatedMinutes: 35,
      sourceCount: 1,
      readySourceCount: 1,
      processingSourceCount: 0,
      failedSourceCount: 0,
    );
    harness.coursesRepository.coursesBySubject['subject-1'] = [course];
    harness.coursesRepository.detailsByCourse['course-1'] = const CourseDetail(
      course: course,
      subject: CourseSubjectSummary(
        id: 'subject-1',
        name: 'Droit constitutionnel',
      ),
      sources: [
        CourseDocument(
          id: 'document-1',
          courseId: 'course-1',
          documentId: 'document-1',
          fileName: 'cours.pdf',
          status: CourseDocumentStatus.ready,
        ),
      ],
    );
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Institutions de la Ve République'), findsOneWidget);
    expect(find.text('Droit constitutionnel'), findsOneWidget);
    await tester.tap(find.widgetWithText(RevisionHeaderActionPill, 'Sources'));
    await tester.pumpAndSettle();
    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('course detail back pops to home without forward history', (
    tester,
  ) async {
    final harness = _RouterHarness();
    _seedReadyCourse(harness);
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);

    harness.router.push(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsOneWidget,
    );
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);
    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsNothing,
    );
  });

  testWidgets('course sheet back pops to detail without duplicating home', (
    tester,
  ) async {
    final harness = _RouterHarness();
    _seedReadyCourse(harness);
    harness.coursesRepository.revisionSheetsByCourse['course-1'] =
        _revisionSheet();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    await tester.pumpAndSettle();

    harness.router.push(AppRoutes.course('course-1'));
    await tester.pumpAndSettle();
    harness.router.push(AppRoutes.courseSheet('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour au cours'));
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(RevisionHeaderActionPill, 'Fiche'),
      findsOneWidget,
    );
    expect(harness.router.canPop(), isTrue);

    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();

    expect(
      harness.router.routeInformationProvider.value.uri.path,
      AppRoutes.home,
    );
    expect(harness.router.canPop(), isFalse);
  });

  testWidgets('course sheet route shows the real course-level revision sheet', (
    tester,
  ) async {
    final harness = _RouterHarness();
    harness.coursesRepository.revisionSheetsByCourse['course-1'] =
        _revisionSheet();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.courseSheet('course-1'));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
  });

  testWidgets('revision session result route displays real backend result', (
    tester,
  ) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());
    harness.router.go(AppRoutes.revisionSessionResultV2(sessionId: 'fake'));
    await tester.pumpAndSettle();

    expect(find.text('Session terminée'), findsOneWidget);
    expect(find.text('4/6 bonnes réponses'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);
    expect(find.byType(RevisionNavigationRail), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('4/5 bonnes'), findsNothing);
  });

  testWidgets(
    'revision session routes are immersive without shell navigation',
    (tester) async {
      final harness = _RouterHarness();
      addTearDown(harness.dispose);

      await tester.pumpWidget(harness.buildApp());
      harness.router.go(
        AppRoutes.revisionSession(sessionId: 'revision-session-1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision IA'), findsOneWidget);
      expect(find.byType(RevisionBottomNavigation), findsNothing);
      expect(find.byType(RevisionNavigationRail), findsNothing);

      harness.router.go(
        AppRoutes.richClosedExercise(
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Questions riches'), findsOneWidget);
      expect(find.byType(RevisionBottomNavigation), findsNothing);
      expect(find.byType(RevisionNavigationRail), findsNothing);
    },
  );

  testWidgets('legacy real routes stay accessible', (tester) async {
    final harness = _RouterHarness();
    addTearDown(harness.dispose);

    await tester.pumpWidget(harness.buildApp());

    harness.router.go(AppRoutes.subjects);
    await tester.pumpAndSettle();
    expect(find.text('Tes matieres'), findsOneWidget);

    harness.router.go(AppRoutes.today);
    await tester.pumpAndSettle();
    expect(find.text('Plan du jour'), findsOneWidget);

    harness.router.go(AppRoutes.activities);
    await tester.pumpAndSettle();
    expect(find.text('Activites'), findsWidgets);

    harness.router.go(AppRoutes.sources);
    await tester.pumpAndSettle();
    expect(find.text('Sources depuis les cours'), findsOneWidget);
    expect(find.byType(RevisionBottomNavigation), findsNothing);
    expect(find.byType(RevisionNavigationRail), findsNothing);
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
      expect(find.text('Notion : Institutions politiques'), findsOneWidget);
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
      revisionGoalsController = RevisionGoalsController(
        InMemoryRevisionGoalsRepository(),
      ),
      documentsController = DocumentsController(InMemoryDocumentsApi()),
      activityApi = InMemoryActivityApi(),
      revisionSessionsApi = InMemoryRevisionSessionsApi() {
    subjectsRepository = InMemorySubjectsRepository();
    coursesRepository = InMemoryCoursesRepository();
    subjectsController = SubjectsController(subjectsRepository);
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
  late final InMemorySubjectsRepository subjectsRepository;
  late final InMemoryCoursesRepository coursesRepository;
  late final SubjectsController subjectsController;
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
        subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
        subjectsControllerProvider.overrideWithValue(subjectsController),
        coursesRepositoryProvider.overrideWithValue(coursesRepository),
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

RevisionSheet _revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}

CourseListItem _seedReadyCourse(_RouterHarness harness) {
  harness.subjectsRepository.subjects.add(
    const Subject(id: 'subject-1', name: 'Droit constitutionnel', priority: 4),
  );

  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Institutions de la Ve République',
    chapterLabel: 'Chapitre 2',
    estimatedMinutes: 35,
    sourceCount: 1,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
  );
  harness.coursesRepository.coursesBySubject['subject-1'] = [course];
  harness.coursesRepository.detailsByCourse['course-1'] = const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(
      id: 'subject-1',
      name: 'Droit constitutionnel',
    ),
    sources: [
      CourseDocument(
        id: 'document-1',
        courseId: 'course-1',
        documentId: 'document-1',
        fileName: 'cours.pdf',
        status: CourseDocumentStatus.ready,
      ),
    ],
  );
  harness.coursesRepository.progressByCourse['course-1'] = const CourseProgress(
    courseId: 'course-1',
    subjectId: 'subject-1',
    coverage: 0,
    mastery: null,
    estimatedGlobalMastery: 0,
    knowledgeUnitCount: 3,
    practicedKnowledgeUnitCount: 0,
    readySourceCount: 1,
    processingSourceCount: 0,
    failedSourceCount: 0,
    state: CourseProgressState.readyNotPracticed,
  );
  harness.coursesRepository.progressBySubject['subject-1'] =
      const SubjectProgress(
        subjectId: 'subject-1',
        knowledgeUnitCount: 3,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        courseCount: 1,
        readyCourseCount: 1,
        courses: [
          SubjectCourseProgressItem(
            courseId: 'course-1',
            title: 'Institutions de la Ve République',
            knowledgeUnitCount: 3,
            practicedKnowledgeUnitCount: 0,
            coverage: 0,
            mastery: null,
            estimatedGlobalMastery: 0,
            state: CourseProgressState.readyNotPracticed,
          ),
        ],
      );

  return course;
}

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


### `test/features/courses/course_revision_sheet_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/courses_repository.dart';
import 'package:revision_app/features/courses/presentation/course_revision_sheet_page.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';

import '../../fakes/in_memory_courses_repository.dart';

void main() {
  testWidgets('course revision sheet page displays an existing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche de cours'), findsWidgets);
    expect(find.text('Introduction destinée aux étudiants'), findsOneWidget);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Le Parlement contrôle le Gouvernement.'), findsOneWidget);
    expect(find.text('Complète'), findsNothing);
    expect(find.text('Examen'), findsNothing);
    expect(find.textContaining('réel'), findsNothing);
    expect(find.textContaining('étudiant.es'), findsNothing);
    expect(find.textContaining('Cours mais à la disposition'), findsNothing);
    expect(find.text('Sources >'), findsOneWidget);
    expect(find.text('Loi normale'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('course revision sheet page can generate a missing sheet', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..generatedRevisionSheetsByCourse['course-1'] = revisionSheet();

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Fiche non générée'), findsOneWidget);

    await tester.tap(find.text('Générer la fiche'));
    await tester.pumpAndSettle();

    expect(repository.generateRevisionSheetCount, 1);
    expect(find.text('Institutions'), findsOneWidget);
  });

  testWidgets('course revision sheet page shows no-ready-source errors', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetErrorsByCourse['course-1'] =
          const CourseRevisionSheetNotReadyException(
            'Course has no ready source',
          );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Aucune source prête'), findsOneWidget);
    expect(find.textContaining('traitée avec succès'), findsOneWidget);
    expect(find.textContaining('données réelles'), findsNothing);
    expect(find.textContaining('fictive'), findsNothing);
  });

  testWidgets('course revision sheet page shows course not found errors', (
    tester,
  ) async {
    final repository = InMemoryCoursesRepository()
      ..revisionSheetErrorsByCourse['course-1'] = const CourseNotFoundException(
        'Course not found',
      );

    await tester.pumpWidget(testApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Cours introuvable'), findsOneWidget);
    expect(find.text('Fiche non générée'), findsNothing);
  });

  testWidgets(
    'course revision sheet sources page shows long sources separately',
    (tester) async {
      final repository = InMemoryCoursesRepository()
        ..revisionSheetsByCourse['course-1'] = revisionSheet();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
          child: const MaterialApp(
            home: Scaffold(
              body: CourseRevisionSheetSourcesPage(courseId: 'course-1'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sources de la fiche'), findsOneWidget);
      expect(find.text('Institutions'), findsOneWidget);
      expect(
        find.textContaining('Cours mais à la disposition'),
        findsOneWidget,
      );
      expect(find.textContaining('étudiant.es'), findsNothing);
      expect(find.textContaining('étudiants'), findsOneWidget);
    },
  );
}

Widget testApp(InMemoryCoursesRepository repository) {
  return ProviderScope(
    overrides: [coursesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(
      home: Scaffold(body: CourseRevisionSheetPage(courseId: 'course-1')),
    ),
  );
}

RevisionSheet revisionSheet() {
  return const RevisionSheet(
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de cours',
    introduction: 'Introduction destinée aux étudiant.es',
    sections: [
      RevisionSheetSection(
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le Parlement contrôle le Gouvernement.',
        sources: [
          DocumentArtifactSource(
            chunkId: 'chunk-1',
            index: 0,
            text:
                'Cours mais à la disposition des étudiant.es de l’UFR 11. Table des matières très longue.',
            pageNumber: 1,
          ),
        ],
      ),
    ],
    keyPoints: ['Point clé'],
    commonMistakes: ['Erreur fréquente'],
    mustKnow: ['À savoir'],
    practiceSuggestions: ['S’entraîner'],
    errorCode: null,
  );
}

```


### `test/features/courses/subject_progress_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/courses/presentation/subject_progress_page.dart';
import 'package:revision_app/features/subjects/domain/subject.dart';

import '../../fakes/in_memory_courses_repository.dart';
import '../../fakes/in_memory_subjects_repository.dart';

void main() {
  testWidgets('progress page shows an honest empty state without subjects', (
    tester,
  ) async {
    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: InMemorySubjectsRepository(),
        coursesRepository: InMemoryCoursesRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progrès'), findsOneWidget);
    expect(
      find.text('Crée une matière pour suivre ta progression.'),
      findsOneWidget,
    );
    expect(find.textContaining('réelle'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('870'), findsNothing);
    expect(find.text('7 jours'), findsNothing);
  });

  testWidgets('progress page displays real subject and course progress', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );
    final coursesRepository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();

    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Droit constitutionnel'), findsOneWidget);
    expect(find.text('Matière active'), findsOneWidget);
    expect(find.text('Changer de matière'), findsOneWidget);
    expect(find.text('3/12 notions travaillées'), findsWidgets);
    expect(find.text('Maîtrise travaillée : 72%'), findsOneWidget);
    expect(find.text('Estimation globale : 18%'), findsOneWidget);
    expect(find.text('Institutions'), findsOneWidget);
    expect(find.text('Progression basée sur tes réponses.'), findsOneWidget);
    expect(find.textContaining('Progression réelle'), findsNothing);
    expect(find.text('78%'), findsNothing);
    expect(find.text('Loi normale'), findsNothing);
  });

  testWidgets('progress page explains an active subject without courses', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );
    final coursesRepository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = const SubjectProgress(
        subjectId: 'subject-1',
        knowledgeUnitCount: 0,
        practicedKnowledgeUnitCount: 0,
        coverage: 0,
        mastery: null,
        estimatedGlobalMastery: 0,
        courseCount: 0,
        readyCourseCount: 0,
        courses: [],
      );

    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aucun cours à suivre'), findsOneWidget);
    expect(find.textContaining('Crée un cours'), findsOneWidget);
    expect(find.textContaining('réel'), findsNothing);
  });

  testWidgets('progress page keeps its header fixed while content scrolls', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );
    final coursesRepository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgressWithManyCourses();

    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('Progrès');
    final before = tester.getTopLeft(title);

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -360));
    await tester.pumpAndSettle();

    final after = tester.getTopLeft(title);
    expect(after.dy, before.dy);
  });

  testWidgets('progress page opens a course from the real progress list', (
    tester,
  ) async {
    final subjectsRepository = InMemorySubjectsRepository()
      ..subjects.add(
        const Subject(
          id: 'subject-1',
          name: 'Droit constitutionnel',
          priority: 4,
        ),
      );
    final coursesRepository = InMemoryCoursesRepository()
      ..progressBySubject['subject-1'] = subjectProgress();

    final router = GoRouter(
      initialLocation: AppRoutes.progress,
      routes: [
        GoRoute(
          path: AppRoutes.progress,
          builder: (context, state) => const SubjectProgressPage(),
        ),
        GoRoute(
          path: AppRoutes.coursePath,
          builder: (context, state) => Text(
            'Cours ${state.pathParameters['courseId']}',
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      progressTestApp(
        subjectsRepository: subjectsRepository,
        coursesRepository: coursesRepository,
        router: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Institutions'));
    await tester.pumpAndSettle();

    expect(find.text('Cours course-1'), findsOneWidget);
  });
}

Widget progressTestApp({
  required InMemorySubjectsRepository subjectsRepository,
  required InMemoryCoursesRepository coursesRepository,
  GoRouter? router,
}) {
  return ProviderScope(
    overrides: [
      subjectsRepositoryProvider.overrideWithValue(subjectsRepository),
      coursesRepositoryProvider.overrideWithValue(coursesRepository),
    ],
    child: router == null
        ? const MaterialApp(home: Scaffold(body: SubjectProgressPage()))
        : MaterialApp.router(routerConfig: router),
  );
}

SubjectProgress subjectProgress() {
  return const SubjectProgress(
    subjectId: 'subject-1',
    knowledgeUnitCount: 12,
    practicedKnowledgeUnitCount: 3,
    coverage: 0.25,
    mastery: 0.72,
    estimatedGlobalMastery: 0.18,
    courseCount: 1,
    readyCourseCount: 1,
    courses: [
      SubjectCourseProgressItem(
        courseId: 'course-1',
        title: 'Institutions',
        knowledgeUnitCount: 12,
        practicedKnowledgeUnitCount: 3,
        coverage: 0.25,
        mastery: 0.72,
        estimatedGlobalMastery: 0.18,
        state: CourseProgressState.practiced,
      ),
    ],
  );
}

SubjectProgress subjectProgressWithManyCourses() {
  return SubjectProgress(
    subjectId: 'subject-1',
    knowledgeUnitCount: 100,
    practicedKnowledgeUnitCount: 20,
    coverage: 0.2,
    mastery: 0.5,
    estimatedGlobalMastery: 0.1,
    courseCount: 16,
    readyCourseCount: 16,
    courses: List.generate(
      16,
      (index) => SubjectCourseProgressItem(
        courseId: 'course-$index',
        title: 'Cours ${index + 1}',
        knowledgeUnitCount: 10,
        practicedKnowledgeUnitCount: index.isEven ? 2 : 0,
        coverage: index.isEven ? 0.2 : 0,
        mastery: index.isEven ? 0.5 : null,
        estimatedGlobalMastery: index.isEven ? 0.1 : 0,
        state: index.isEven
            ? CourseProgressState.practiced
            : CourseProgressState.readyNotPracticed,
      ),
    ),
  );
}

```


### `test/features/revision_sessions/revision_session_page_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:revision_app/app/router/app_routes.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/courses/application/courses_providers.dart';
import 'package:revision_app/features/courses/domain/course_models.dart';
import 'package:revision_app/features/revision_sessions/application/revision_session_controller.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';
import 'package:revision_app/presentation/pages/revision_sessions/revision_session_page.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';

import '../../fakes/in_memory_activity_api.dart';
import '../../fakes/in_memory_courses_repository.dart';
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
      expect(find.text('Notion : Institutions politiques'), findsOneWidget);
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

  testWidgets(
    'course quick session renders one question at a time and completes remotely',
    (tester) async {
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse();
      final activityApi = InMemoryActivityApi();
      final coursesRepository = InMemoryCoursesRepository()
        ..detailsByCourse['course-1'] = _courseDetail();
      final router = GoRouter(
        initialLocation: AppRoutes.revisionSessionV2(
          sessionId: 'revision-session-1',
        ),
        routes: [
          GoRoute(
            path: AppRoutes.revisionSessionV2Path,
            builder: (context, state) => RevisionSessionPage(
              revisionSessionController: RevisionSessionController(revisionApi),
              activityController: ActivityController(activityApi),
              sessionId: state.pathParameters['sessionId'],
            ),
          ),
          GoRoute(
            path: AppRoutes.revisionSessionResultV2Path,
            builder: (context, state) => const Text('Result route'),
          ),
          GoRoute(
            path: AppRoutes.coursePath,
            builder: (context, state) => const Text('Course route'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(coursesRepository),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Révision rapide'), findsOneWidget);
      expect(find.text('Question 1 sur 2'), findsOneWidget);
      expect(
        find.text('Quel principe organise les pouvoirs ?'),
        findsOneWidget,
      );
      expect(find.text('Quelle institution vote la loi ?'), findsNothing);
      expect(find.text('quiz-session-1'), findsNothing);
      expect(find.text('correctChoiceId'), findsNothing);

      await tester.tap(find.text('La séparation des pouvoirs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();

      expect(find.text('Question 2 sur 2'), findsOneWidget);
      expect(find.text('Quelle institution vote la loi ?'), findsOneWidget);

      await tester.tap(find.text('Le Parlement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(activityApi.submittedDiagnosticSessionId, 'quiz-session-1');
      expect(activityApi.submittedAnswers, hasLength(2));
      expect(revisionApi.completeCount, 1);
      expect(revisionApi.completedSessionId, 'revision-session-1');
      expect(
        router.routeInformationProvider.value.uri.path,
        '/revision-sessions/revision-session-1/result',
      );
      expect(find.text('Result route'), findsOneWidget);
    },
  );

  testWidgets('course quick session renders diagnostic question visuals', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _courseQuickRevisionSessionWithVisuals();
    final coursesRepository = InMemoryCoursesRepository()
      ..detailsByCourse['course-1'] = _courseDetail();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(coursesRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Répartition des pouvoirs'), findsOneWidget);
    expect(find.textContaining('Exécutif'), findsOneWidget);
    expect(find.text('Visuel non pris en charge'), findsOneWidget);
    expect(find.text('correctChoiceId'), findsNothing);
  });

  testWidgets(
    'course quick session flags the current question without submit',
    (tester) async {
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse();
      final activityApi = InMemoryActivityApi();
      final router = _quickRouter(
        revisionApi: revisionApi,
        activityApi: activityApi,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(
              InMemoryCoursesRepository()
                ..detailsByCourse['course-1'] = _courseDetail(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signaler'));
      await tester.pumpAndSettle();

      expect(revisionApi.flagCount, 1);
      expect(revisionApi.flaggedSessionId, 'revision-session-1');
      expect(revisionApi.flaggedQuestionId, 'question-1');
      expect(find.text('Question signalée'), findsOneWidget);
      expect(activityApi.submittedDiagnosticQuizCount, 0);
      expect(revisionApi.completeCount, 0);
    },
  );

  testWidgets('completed course quick session redirects to result route', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _completedCourseQuickRevisionSessionResponse();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Result route'), findsOneWidget);
    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
  });

  testWidgets('completed quick action does not reopen the premium quiz', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _courseQuickRevisionSessionWithCompletedAction();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: InMemoryActivityApi(),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quel principe organise les pouvoirs ?'), findsNothing);
    expect(find.text('Result route'), findsOneWidget);
  });

  testWidgets('multiple choice respects min and max selections', (
    tester,
  ) async {
    _useTallSurface(tester);
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = _multipleChoiceQuickRevisionSession();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contrôle parlementaire'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Terminer', skipOffstage: false));
    await tester.tap(find.text('Terminer'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 0);

    await tester.tap(find.text('Responsabilité du gouvernement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dissolution'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Motion de censure'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Terminer', skipOffstage: false));
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(activityApi.submittedDiagnosticQuizCount, 1);
    expect(activityApi.submittedAnswers, hasLength(1));
    expect(activityApi.submittedAnswers!.single.choiceIds, [
      'choice-a',
      'choice-b',
      'choice-c',
    ]);
    expect(revisionApi.completeCount, 1);
  });

  testWidgets('previous and next keep selected answers before submit', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = courseQuickRevisionSessionResponse();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('La séparation des pouvoirs'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Le Parlement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Précédent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();

    expect(
      activityApi.submittedAnswers
          ?.map((answer) => '${answer.questionId}:${answer.choiceId}')
          .toList(),
      ['question-1:choice-1', 'question-2:choice-3'],
    );
  });

  testWidgets(
    'retry completion does not submit the diagnostic activity twice',
    (tester) async {
      _useTallSurface(tester);
      final revisionApi = InMemoryRevisionSessionsApi()
        ..loadResponse = courseQuickRevisionSessionResponse()
        ..completeError = StateError('complete failed');
      final activityApi = InMemoryActivityApi();
      final router = _quickRouter(
        revisionApi: revisionApi,
        activityApi: activityApi,
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coursesRepositoryProvider.overrideWithValue(
              InMemoryCoursesRepository()
                ..detailsByCourse['course-1'] = _courseDetail(),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('La séparation des pouvoirs'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Le Parlement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(revisionApi.completeCount, 1);
      expect(find.text('Finaliser la session'), findsOneWidget);

      revisionApi.completeError = null;
      await tester.ensureVisible(
        find.text('Finaliser la session', skipOffstage: false),
      );
      await tester.tap(find.text('Finaliser la session'));
      await tester.pumpAndSettle();

      expect(activityApi.submittedDiagnosticQuizCount, 1);
      expect(revisionApi.completeCount, 2);
      expect(find.text('Result route'), findsOneWidget);
    },
  );

  testWidgets('back button asks for confirmation before abandoning the quiz', (
    tester,
  ) async {
    final revisionApi = InMemoryRevisionSessionsApi()
      ..loadResponse = courseQuickRevisionSessionResponse();
    final activityApi = InMemoryActivityApi();
    final router = _quickRouter(
      revisionApi: revisionApi,
      activityApi: activityApi,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coursesRepositoryProvider.overrideWithValue(
            InMemoryCoursesRepository()
              ..detailsByCourse['course-1'] = _courseDetail(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Quitter la session ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Quel principe organise les pouvoirs ?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Quitter'));
    await tester.pumpAndSettle();

    expect(find.text('Course route'), findsOneWidget);
    expect(activityApi.submittedDiagnosticQuizCount, 0);
    expect(revisionApi.completeCount, 0);
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

void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

CourseDetail _courseDetail() {
  const course = CourseListItem(
    id: 'course-1',
    subjectId: 'subject-1',
    title: 'Droit constitutionnel',
    sourceCount: 1,
    readySourceCount: 1,
  );

  return const CourseDetail(
    course: course,
    subject: CourseSubjectSummary(id: 'subject-1', name: 'Droits'),
    sources: [
      CourseDocument(
        id: 'document-1',
        courseId: 'course-1',
        documentId: 'document-1',
        fileName: 'source.pdf',
        status: CourseDocumentStatus.ready,
      ),
    ],
  );
}

GoRouter _quickRouter({
  required InMemoryRevisionSessionsApi revisionApi,
  required InMemoryActivityApi activityApi,
}) {
  return GoRouter(
    initialLocation: AppRoutes.revisionSessionV2(
      sessionId: 'revision-session-1',
    ),
    routes: [
      GoRoute(
        path: AppRoutes.revisionSessionV2Path,
        builder: (context, state) => RevisionSessionPage(
          revisionSessionController: RevisionSessionController(revisionApi),
          activityController: ActivityController(activityApi),
          sessionId: state.pathParameters['sessionId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.revisionSessionResultV2Path,
        builder: (context, state) => const Text('Result route'),
      ),
      GoRoute(
        path: AppRoutes.coursePath,
        builder: (context, state) => const Text('Course route'),
      ),
    ],
  );
}

RevisionSessionResponse _courseQuickRevisionSessionWithVisuals() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: const RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'Révision rapide réelle',
          subjectId: 'subject-1',
          documentId: 'document-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Quel principe organise les pouvoirs ?',
              knowledgeUnitId: 'unit-1',
              visuals: [
                DiagnosticQuizChartVisual(
                  id: 'visual-1',
                  displayOrder: 0,
                  chartType: DiagnosticQuizChartType.bar,
                  title: 'Répartition des pouvoirs',
                  description: 'Lecture synthétique du cours.',
                  xKey: 'branche',
                  yKeys: ['poids'],
                  data: [
                    {'branche': 'Exécutif', 'poids': 2},
                    {'branche': 'Législatif', 'poids': 3},
                  ],
                ),
                DiagnosticQuizUnsupportedVisual(
                  id: 'visual-2',
                  displayOrder: 1,
                  type: 'MAP',
                ),
              ],
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-1',
                  label: 'La séparation des pouvoirs',
                ),
                DiagnosticQuizChoice(
                  id: 'choice-2',
                  label: 'La confusion des pouvoirs',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    history: base.history,
  );
}

RevisionSessionResponse _completedCourseQuickRevisionSessionResponse() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: RevisionSession(
      id: base.session.id,
      status: RevisionSessionStatus.completed,
      mode: RevisionSessionMode.quick,
      subjectId: base.session.subjectId,
      courseId: base.session.courseId,
      documentId: base.session.documentId,
      knowledgeUnitId: base.session.knowledgeUnitId,
      createdAt: base.session.createdAt,
      completedAt: DateTime.parse('2026-06-15T12:04:12.000Z'),
    ),
    currentAction: base.currentAction,
    history: base.history,
  );
}

RevisionSessionResponse _courseQuickRevisionSessionWithCompletedAction() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: RevisionSessionAction(
      id: base.currentAction!.id,
      kind: base.currentAction!.kind,
      status: RevisionSessionActionStatus.completed,
      displayOrder: base.currentAction!.displayOrder,
      activitySessionId: base.currentAction!.activitySessionId,
      documentId: base.currentAction!.documentId,
      knowledgeUnitId: base.currentAction!.knowledgeUnitId,
      payload: base.currentAction!.payload,
    ),
    history: base.history,
  );
}

RevisionSessionResponse _multipleChoiceQuickRevisionSession() {
  final base = courseQuickRevisionSessionResponse();
  return RevisionSessionResponse(
    session: base.session,
    currentAction: const RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'Révision rapide réelle',
          subjectId: 'subject-1',
          documentId: 'document-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-multiple',
              prompt: 'Quels mécanismes relèvent du contrôle parlementaire ?',
              knowledgeUnitId: 'unit-1',
              selectionMode: DiagnosticQuizSelectionMode.multiple,
              minSelections: 2,
              maxSelections: 3,
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-a',
                  label: 'Contrôle parlementaire',
                ),
                DiagnosticQuizChoice(
                  id: 'choice-b',
                  label: 'Responsabilité du gouvernement',
                ),
                DiagnosticQuizChoice(id: 'choice-c', label: 'Dissolution'),
                DiagnosticQuizChoice(
                  id: 'choice-d',
                  label: 'Motion de censure',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    history: base.history,
  );
}

```
