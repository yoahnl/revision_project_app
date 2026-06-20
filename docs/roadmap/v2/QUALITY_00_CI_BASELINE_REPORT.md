# QUALITY-00 — CI baseline report — App

## 1. Résumé

QUALITY-00 ajoute une baseline GitHub Actions côté Flutter avec un workflow `Flutter CI` déclenché sur `pull_request` et sur `push` vers `main`.

Le workflow vérifie :

- la version Flutter ;
- l'installation des dépendances ;
- l'analyse statique ;
- les tests router ;
- les tests shell app ;
- les tests courses ;
- les tests revision sessions ;
- la suite Flutter complète ;
- `git diff --check`.

Le lot ne modifie aucune logique runtime Flutter. La seule limite détectée est le check `dart format --output=none --set-exit-if-changed lib test`, qui sort `1` sur 8 fichiers existants. Cette dette n'est pas corrigée ici, car QUALITY-00 interdit les modifications runtime. Le gate format est donc explicitement reporté à un lot de nettoyage dédié.

## 2. Audit initial

### Workflows existants

Aucun dossier `.github/workflows` n'existait côté app.

### CI Apple existante

Le repo possède des scripts Xcode Cloud dans `ios/ci_scripts/`, mais QUALITY-00 ne les modifie pas. Le workflow GitHub Actions ne fait aucun build iOS signé et n'utilise aucun secret Apple.

### Version Flutter/Dart

- `pubspec.yaml` : SDK Dart `^3.12.0`.
- Toolchain locale validée : Flutter `3.44.0`, Dart `3.12.0`.
- Workflow : `subosito/flutter-action@v2` avec `flutter-version: "3.44.0"`.

### Tests existants retenus

- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`
- `test/features/courses`
- `test/features/revision_sessions`
- `flutter test` complet

Les tests utilisent les fakes Riverpod/API existants et ne nécessitent pas Firebase réel.

## 3. Workflow créé

Créé :

```text
.github/workflows/flutter-ci.yml
```

## 4. Commandes retenues

```bash
flutter --version
flutter pub get
dart analyze lib test
flutter test test/app/router/app_router_test.dart --reporter compact
flutter test test/app/revision_app_test.dart --reporter compact
flutter test test/features/courses --reporter compact
flutter test test/features/revision_sessions --reporter compact
flutter test --reporter compact
git diff --check
```

## 5. Commandes exclues

### `dart format --output=none --set-exit-if-changed lib test`

La commande a été exécutée localement et a échoué avec `EXIT_CODE=1`.

Fichiers signalés :

```text
Changed lib/features/activities/genui/activity_correction_component_validator.dart
Changed lib/features/activities/genui/revision_activity_catalog.dart
Changed lib/presentation/pages/activities/open_question_page.dart
Changed lib/presentation/pages/documents/document_detail_page.dart
Changed lib/presentation/pages/subjects/subjects_home_page.dart
Changed test/features/activities/open_question_page_test.dart
Changed test/features/activities/revision_activity_catalog_test.dart
Changed test/features/documents/subject_documents_notifier_test.dart
Formatted 227 files (8 changed) in 0.72 seconds.
```

Comme ce lot interdit les modifications runtime, ces fichiers ne sont pas modifiés. Le format gate est reporté.

### Builds iOS/macOS signés

Exclus de QUALITY-00 : ils demanderaient une stratégie Apple/signing/Xcode Cloud hors périmètre.

## 6. Variables et secrets

Aucun secret n'est utilisé par le workflow Flutter.

## 7. Tests couverts

Le workflow couvre les tests app les plus critiques et la suite complète Flutter.

## 8. Tests non couverts

- Aucun test device/simulator.
- Aucun build iOS signé.
- Aucun test Xcode Cloud.
- Aucun gate format tant que la dette existante n'est pas résolue.

## 9. Commandes exécutées

```text
ruby -e "require 'yaml'; Dir['.github/workflows/*.yml'].each { |f| YAML.load_file(f); puts f }"
EXIT_CODE=0
Note locale : Ruby affiche un warning ffi local, sans lien avec le YAML.

flutter --version
EXIT_CODE=0
Flutter 3.44.0 / Dart 3.12.0

flutter pub get
EXIT_CODE=0
Got dependencies.

dart format --output=none --set-exit-if-changed lib test
EXIT_CODE=1
8 fichiers existants signalés.

dart analyze lib test
EXIT_CODE=0
No issues found.

flutter test test/app/router/app_router_test.dart --reporter compact
EXIT_CODE=0
All tests passed.

flutter test test/app/revision_app_test.dart --reporter compact
EXIT_CODE=0
All tests passed.

flutter test test/features/courses --reporter compact
EXIT_CODE=0
All tests passed.

flutter test test/features/revision_sessions --reporter compact
EXIT_CODE=0
All tests passed.

flutter test --reporter compact
EXIT_CODE=0
441 tests passed.

git diff --check
EXIT_CODE=0
```

## 10. Impact roadmap

`QUALITY-00` passe à `DONE` dans :

- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`

Le README pointe vers ce rapport.

## 11. Limites

- Le format gate Flutter reste à introduire après correction dédiée.
- Le workflow ne couvre pas Xcode Cloud.
- Le workflow ne couvre pas les builds natifs signés.

## 12. Risques

- Un futur refactor peut continuer à passer CI malgré une dette de format sur des fichiers anciens.
- `subosito/flutter-action` doit pouvoir résoudre Flutter `3.44.0` sur GitHub Actions.

## 13. Comment lire les résultats CI

Un PR est acceptable côté app si :

- `Flutter CI / Analyze and test Flutter app` est vert ;
- les tests ciblés et la suite complète passent ;
- `git diff --check` ne signale aucune whitespace error.

Le format Dart reste une vérification manuelle/documentée jusqu'à nettoyage.

## 14. Auto-review

- Workflow app créé.
- Aucun secret réel.
- Pas de build iOS signé.
- Pas de modification Xcode Cloud.
- Flutter analyze couvert.
- Tests Flutter ciblés couverts.
- Full Flutter test couvert.
- YAML valide.
- Trackers mis à jour.
- Rapport créé.
- Aucun runtime modifié volontairement.
- Aucun commit effectué.

## 15. Fichiers créés/modifiés

### Créés

- `.github/workflows/flutter-ci.yml`
- `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md`

### Modifiés

- `docs/roadmap/v2/README.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`

## 16. Contenu complet des fichiers créés/modifiés

Le rapport courant n'est pas auto-inclus pour éviter une duplication récursive.

### `.github/workflows/flutter-ci.yml`

```yaml
name: Flutter CI

on:
  pull_request:
  push:
    branches:
      - main

concurrency:
  group: flutter-ci-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  flutter:
    name: Analyze and test Flutter app
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.44.0"
          channel: stable
          cache: true

      - name: Show Flutter version
        run: flutter --version

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: dart analyze lib test

      - name: Test router
        run: flutter test test/app/router/app_router_test.dart --reporter compact

      - name: Test app shell
        run: flutter test test/app/revision_app_test.dart --reporter compact

      - name: Test courses feature
        run: flutter test test/features/courses --reporter compact

      - name: Test revision sessions feature
        run: flutter test test/features/revision_sessions --reporter compact

      - name: Test full Flutter suite
        run: flutter test --reporter compact

      - name: Check whitespace
        run: git diff --check
```

### `docs/roadmap/v2/README.md`

````md
# Roadmap V2 — Revision Project

Ce dossier contient la roadmap officielle V2 de Revision Project côté produit et Flutter.

La roadmap V2 existe pour remplacer mentalement les anciennes roadmaps dispersées sans les supprimer. Les rapports `docs/core/` et `docs/ui/` restent l'historique détaillé des lots déjà réalisés. La source de vérité stratégique devient ce dossier.

## Fichiers à lire

- `REVISION_PROJECT_ROADMAP_V2.md` : roadmap produit et technique canonique.
- `LOT_TRACKER_V2.md` : statut vivant des macro-lots.
- `EXECUTION_PLAN_V2.md` : découpage opérationnel des macro-lots en lots exécutables.
- `EXECUTION_LOT_TRACKER_V2.md` : statut vivant des lots exécutables.
- `UX_UI_TARGET_V2.md` : cible UX/UI, matrice de capacités et règles d'interface.
- `DECISIONS_V2.md` : journal canonique des décisions produit.
- `ROADMAP_UPDATE_PROTOCOL.md` : protocole de mise à jour après chaque lot.
- `STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` : rapport du durcissement de la roadmap.
- `QUALITY_00_CI_BASELINE_REPORT.md` : rapport de la baseline CI GitHub Actions.

Le backend possède une roadmap alignée dans `revision_project_api/docs/roadmap/v2/`, mais la vision produit complète vit ici pour éviter deux narrations divergentes.

## Règle de maintenance

Après chaque lot, Codex doit mettre à jour au minimum :

- le tracker ;
- l'état réel actuel ;
- les risques ;
- les dépendances ;
- le prochain lot recommandé ;
- les liens vers les rapports créés.

Les anciennes roadmaps ne doivent pas être réécrites pour faire semblant que le projet a toujours suivi ce chemin. Elles restent des traces historiques.

## Source de vérité

Pour décider du prochain lot, lire dans cet ordre :

1. `REVISION_PROJECT_ROADMAP_V2.md`
2. `LOT_TRACKER_V2.md`
3. `EXECUTION_PLAN_V2.md`
4. `EXECUTION_LOT_TRACKER_V2.md`
5. `UX_UI_TARGET_V2.md`
6. `DECISIONS_V2.md`
7. `ROADMAP_UPDATE_PROTOCOL.md`
8. le rapport du dernier lot terminé

## Référence visuelle V2

La planche visuelle canonique doit vivre à terme dans :

```text
docs/roadmap/v2/assets/revision_project_ui_v2_board.png
```

Si elle n'est pas encore présente, `docs/roadmap/v2/assets/README.md` reste la source de vérité sur son statut. Aucune image de remplacement ne doit être inventée.
````

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
| STAB-01 | Product navigation & UX coherence | MVP_STABLE | App | TODO | STAB-00B | STAB-01A, STAB-01B, STAB-01C | Corriger navigation, faux affordances et parcours confus. | Tests router/widget + smoke visuel. | À créer |
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
| STAB-01A | STAB-01 | MVP_STABLE | App | TODO | STAB-00B | QUALITY-00 | Corriger shell, navigation, scaffold et scrolls globaux. | Aucune navigation stack parasite, sessions immersives, headers cohérents. | À créer |
| STAB-01B | STAB-01 | MVP_STABLE | App | TODO | STAB-01A | CORE-09A | Clarifier Home, Hub Révisions et hiérarchie des actions cours. | Entrées principales actionnables sans impasse ni wording technique. | À créer |
| STAB-01C | STAB-01 | MVP_STABLE | App + API si besoin | TODO | STAB-01B | Aucun | Corriger fiche, progrès, wording et découvrabilité des matières. | Capacités non disponibles masquées ou reliées à un lot API. | À créer |
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

## 17. Confirmation

Aucun code runtime n'a été modifié volontairement.

Aucun commit n'a été effectué.
