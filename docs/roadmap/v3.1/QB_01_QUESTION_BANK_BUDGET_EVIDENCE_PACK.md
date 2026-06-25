# QB-01 Evidence Pack - App

## Portee

Ce pack documente les preuves App du lot `QB-01`.

Fichiers App modifies ou crees :

- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/QB_01_QUESTION_BANK_BUDGET_REPORT.md`
- `docs/roadmap/v3.1/QB_01_QUESTION_BANK_BUDGET_EVIDENCE_PACK.md`
- `lib/features/courses/presentation/course_detail_page.dart`
- `test/features/courses/course_detail_page_test.dart`

Le patch complet local peut etre reconstruit avec :

```bash
git diff -- docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md docs/roadmap/v3.1/LOT_TRACKER_V3_1.md lib/features/courses/presentation/course_detail_page.dart test/features/courses/course_detail_page_test.dart
git diff --no-index /dev/null docs/roadmap/v3.1/QB_01_QUESTION_BANK_BUDGET_REPORT.md
git diff --no-index /dev/null docs/roadmap/v3.1/QB_01_QUESTION_BANK_BUDGET_EVIDENCE_PACK.md
```

## Wording App final

La carte principale n'affiche plus le nombre brut du pool comme promesse produit principale.

Avant :

```text
9 questions pretes. Plus de questions sont en preparation.
9 pretes
```

Apres :

```text
Une session rapide peut demarrer maintenant. D'autres questions sont en preparation.
Pret
```

## Surfaces volontairement non modifiees

- Pas de changement de modele.
- Pas de changement de provider Riverpod.
- Pas de changement de repository HTTP.
- Pas de nouvelle route.
- Pas de rename global des modes.
- Pas de MODE-01.

## Test App adapte

Le test `quick revision shows partial readiness without contradictory CTA` verifie maintenant :

- La carte principale affiche le message non chiffre.
- `9 questions pretes.` n'est plus present.
- Le badge `9 pretes` n'est plus present.
- Les choix de session `5`, `10`, `20`, `30` restent disponibles.
- Le demarrage de la session quick choisit toujours 5 questions quand c'est le choix pret.

## Validation deja executee

```bash
flutter test test/features/courses/course_detail_page_test.dart --reporter compact
```

La commande est passee.
