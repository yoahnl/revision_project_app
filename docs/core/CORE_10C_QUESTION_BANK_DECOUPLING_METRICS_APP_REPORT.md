# CORE-10C — Question bank decoupling & metrics App report

## Résumé

CORE-10C est principalement API. Côté Flutter, le lot applique uniquement deux garde-fous bornés pour fermer proprement le contrat quick readiness :

- ne plus proposer de préparation quand l'API renvoie `NO_KNOWLEDGE_UNITS` ;
- vérifier que le 409 quick avec readiness `PREPARING` invalide bien la readiness ciblée `courseId + questionCount`.

## Changements runtime Flutter

Modifié :

```text
lib/features/courses/presentation/course_detail_page.dart
```

Quand la readiness vaut `CourseQuestionBankReadinessStatus.noKnowledgeUnits`, l'action principale devient :

```text
Questions indisponibles
Voir la fiche
```

Le bouton est désactivé (`run: null`) et ne déclenche plus `Préparer les questions`.

## Contrat public

Aucun endpoint n'a changé côté app.

Contrats conservés :

```text
GET  /courses/:courseId/question-bank/readiness?questionCount=X
POST /courses/:courseId/question-bank/prepare
POST /courses/:courseId/revision-sessions/quick
```

## Tests ajoutés/modifiés

Modifiés :

- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/courses_providers_test.dart`

Couverture ajoutée :

- source `READY` + readiness `NO_KNOWLEDGE_UNITS` -> aucun CTA `Préparer les questions`, message utilisateur lisible ;
- quick 409 avec readiness `PREPARING` -> invalidation du provider target-aware `courseId + questionCount`.

## Tests exécutés

```bash
dart analyze lib test
```

Résultat : PASS, aucun problème.

```bash
flutter test test/features/courses/course_detail_page_test.dart --reporter compact
```

Résultat : PASS, 17 tests.

```bash
flutter test --reporter compact
```

Résultat : PASS, full Flutter test, 482 tests.

```bash
git diff --check
```

Résultat : PASS.

Note : un premier essai antérieur avec deux commandes Flutter en parallèle avait déclenché une erreur de symlink Swift Package Manager dans `ios/Flutter/ephemeral/Packages`. Les validations finales ont été relancées en série et passent. CocoaPods n'a pas été utilisé.

## Vérification Marionette

Marionette macOS était disponible.

Réalisé :

- lancement local de l'app macOS via `flutter run -d macos -t dev/marionette_main.dart` ;
- connexion Marionette réussie au VM service local ;
- arrêt propre de l'instance lancée par Codex.

Limite : pas de parcours complet `prepare -> polling -> session` rejoué avec un cours contrôlé pour CORE-10C. Le contrat Flutter modifié est couvert par les tests widget/provider et le full Flutter test.

## Fichiers créés/modifiés/supprimés

Créés :

- `docs/core/CORE_10C_QUESTION_BANK_DECOUPLING_METRICS_APP_REPORT.md`

Modifiés :

- `lib/features/courses/presentation/course_detail_page.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/courses_providers_test.dart`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`

Supprimés : aucun.

## Risques restants

- L'app ne montre pas provider/model/fallback IA, volontairement.
- Le flow runtime complet devra être revérifié après déploiement API CORE-10C.
- Pas de refonte UX quick : uniquement le garde-fou `NO_KNOWLEDGE_UNITS`.

## Auto-review

- Pas de nouvelle feature produit.
- Pas de refonte UI.
- Pas de lien juridique modifié.
- Pas de Xcode Cloud.
- Pas de CocoaPods.
- Pas de wording technique exposé à l'utilisateur.
- Full Flutter test vert.
- Aucun commit effectué.

## Confirmation Git

Aucun commit, amend, merge, rebase, tag ou push n'a été effectué.
