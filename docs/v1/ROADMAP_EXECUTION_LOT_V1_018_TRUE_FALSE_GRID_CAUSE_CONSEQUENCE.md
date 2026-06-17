# LOT V1-018 — True/false grid + cause/consequence V1-B

## 1. Résultat

Lot V1-018 réalisé côté Flutter. L'application parse, stocke, rend et soumet les deux nouveaux types rich closed fermés : `true_false_grid` et `cause_consequence`.

L'UI est volontairement minimale : grille vrai/faux par boutons exclusifs et association cause/conséquence par dropdown. Elle est fonctionnelle, testable, sans rendu JSON arbitraire, sans correction pré-submit et sans calcul de score côté client.

V1-018 est validable côté app.

## 2. Sources inspectées

- `lib/features/activities/domain/rich_closed_exercise.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart`
- Widgets rich closed existants V1-A/V1-017.
- `lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart`
- Page rich closed et tests activities.
- Tests Today, router, revision sessions.
- `docs/v1/ROADMAP_EXECUTION_PLAN_V1.md` et catalogue rich closed.

## 3. Préflight Git

- Repo : `/Users/karim/Project/app-révision/revision_app`.
- Branche initiale : `main`.
- Status initial : clean.
- Derniers commits initiaux :
  - `347ce47 V1-017: Intégration du timeline et slider de date pour les exercices riches fermés`
  - `13e54e0 V1-014: Intégration des sessions de révision avec tests et documentation`
  - `a3b52a9 V1-013: Intégration de la page Today avec tests et documentation`
  - `644137b Fix frontend web cache busting`
  - `30e0a12 V1-012B — Ajout du rapport d'exécution du lot Page rich closed complète et flow submit local avec routes, contrôleurs et tests`
- Repo API : modifié séparément avec son propre rapport V1-018.
- Aucun commit, merge, rebase, push, tag, reset ou action destructive.

## 4. Périmètre réalisé

### Backend API

Traité dans le rapport API `api/docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md`.

### Frontend app

- Ajout des enum values `trueFalseGrid` et `causeConsequence`.
- Ajout des modèles discriminés publics, answers submit et corrections post-submit.
- Parser strict anti-fuite pré-submit.
- Answer controller étendu sans valeurs par défaut pour les nouveaux types.
- Widgets minimaux fonctionnels.
- Correction UI post-submit fondée uniquement sur la correction backend.
- Fixtures/tests V1-018, page rich closed, renderer, widgets et non-régression.
- Roadmap app V1 mise à jour.
- Catalogue app aligné sur le contrat 3 à 8 lignes pour `true_false_grid`.

## 5. Contrat V1-B

### `true_false_grid`

Payload public attendu : `id`, `questionKind`, `prompt`, métadonnées, `instruction?`, `rows: Array<{ id, statement, context? }>`.

Pré-submit interdit : `correctValues`, `explanation`, `correction`, `score`, `feedback`, tout `correct*`.

Answer shape Flutter : `{ questionId, questionKind: 'true_false_grid', values: Array<{ rowId, value }> }`.

Correction post-submit : affichage des valeurs soumises, valeurs attendues, statut et explication fournis par le backend.

### `cause_consequence`

Payload public attendu : `id`, `questionKind`, `prompt`, métadonnées, `instruction?`, `causes`, `consequences`.

Pré-submit interdit : `correctPairs`, `explanation`, `correction`, `score`, `feedback`, tout `correct*`.

Answer shape Flutter : `{ questionId, questionKind: 'cause_consequence', pairs: Array<{ causeId, consequenceId }> }`.

Correction post-submit : affichage des paires soumises, paires attendues, statut et explication fournis par le backend.

## 6. Genkit

Aucun code Genkit dans le repo app. Le frontend ne laisse pas Genkit choisir un widget libre, ne rend aucun JSON arbitraire, et consomme uniquement les question kinds typés par le backend.

## 7. Validation/scoring

- `true_false_grid` : parser 3 à 8 lignes, IDs uniques ; le controller exige une sélection explicite pour chaque ligne avant submit.
- `cause_consequence` : parser au moins 3 causes et 3 conséquences, IDs uniques, et rejette les payloads avec moins de conséquences que de causes car ils seraient impossibles à soumettre avec unicité.
- Aucune règle de scoring calculée côté Flutter.
- Le score et `isCorrect` affichés proviennent du résultat backend.

## 8. Flutter

- Modèles : nouvelles classes question/answer/correction pour `true_false_grid` et `cause_consequence`.
- Parser : strict, avec garde récursive contre les champs de correction pré-submit.
- Widgets : rendu minimal mais utilisable, sans drag obligatoire.
- Correction UI : résumé des réponses soumises et attendues depuis le payload backend.
- Limite assumée : UI non polie car refonte complète prévue plus tard.

## 9. Anti-fuite

- Le parser public rejette les champs `correctValues`, `correctPairs`, `explanation`, `correction`, `score`, `feedback`, `modelAnswer` et tout `correct*` en pré-submit.
- Les widgets ne reçoivent que les modèles publics.
- Les tests vérifient qu'aucune correction n'est visible avant submit.
- Post-submit autorise l'affichage des corrections backend.

## 10. Fichiers créés/modifiés/supprimés

Créés :
- `docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md`
- `lib/features/activities/presentation/rich_closed/rich_closed_cause_consequence_widget.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_true_false_grid_widget.dart`
- `test/features/activities/rich_closed_true_false_cause_widgets_test.dart`

Modifiés :
- `docs/v1/RICH_CLOSED_QUESTION_TYPES_CATALOG.md`
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

- Parser public V1-018 valide.
- Rejet des fuites `correctValues` et `correctPairs` pré-submit.
- Rejet cause/conséquence impossible à soumettre avec moins de conséquences que de causes.
- Sérialisation answers `values` et `pairs`.
- Parsing corrections post-submit `correctValues` et `correctPairs`.
- Answer controller : true/false incomplet puis complet ; cause/consequence avec remplacement des doublons.
- Widgets : affichage, interactions et answer callbacks.
- Page rich closed : renderer et submit/correction V1-018.
- Non-régression V1-A, V1-017, Today, router, revision sessions.

## 12. Validations lancées avec résultats

- `dart format <liste explicite des fichiers modifiés>` : passé.
- `dart analyze lib test` : passé, no issues found.
- `flutter test test/features/activities --reporter compact` : passé, 177 tests.
- `flutter test test/features/today --reporter compact` : passé, 18 tests.
- `flutter test test/features/revision_sessions --reporter compact` : passé, 21 tests.
- `flutter test test/app/router --reporter compact` : passé, 11 tests.
- `flutter test --reporter compact` : passé, 308 tests.
- `git diff --check` : passé.

## 13. Validations non lancées avec justification

- Aucun test d'intégration mobile/simulateur : non demandé, widgets couverts par tests Flutter.
- Aucun provider IA réel : non applicable côté app et interdit.
- Aucun `dart fix --apply` ni `dart format .` : explicitement évités.

## 14. Risques restants

- UI volontairement minimale avant refonte ; elle est testable mais pas design final.
- Les dropdowns cause/conséquence sont simples et peuvent devenir moins confortables si le nombre d'items augmente dans les futurs lots.
- Le parser est strict : un payload backend incohérent sera rejeté plutôt que rendu partiellement.

## 15. Recommandation prochain lot

V1-019 — Institution matrix V1-C, si le moteur rich closed doit continuer à s'étendre. Aucun bis bloquant n'est requis côté app.

## 16. Passes de review

- Backend contract : traité dans le rapport API.
- Backend Genkit : traité dans le rapport API.
- Backend scoring : traité dans le rapport API.
- Public mapper anti-fuite : traité dans le rapport API.
- Flutter parser/model : sous-agent Mendel, bug P1 corrigé sur `consequences.length < causes.length` ; remarque doc 3-6 corrigée en 3-8.
- Flutter widgets/correction : sous-agent Dirac, aucun blocage.
- Tests : review manuelle agent principal, validations listées ci-dessus.
- Sécurité : review manuelle agent principal, pas de score client, pas de JSON arbitraire, pas de correction pré-submit, pas de secret.

## 17. Critique honnête du prompt initial

Le prompt était cohérent. Deux points pratiques sont apparus : le catalogue app était obsolète sur la borne `true_false_grid` 3 à 6 au lieu de 3 à 8, et la règle d'unicité des conséquences impose de rejeter les payloads publics où il y a moins de conséquences que de causes. La demande d'inclure le contenu complet de tous les fichiers créés inclut théoriquement le rapport lui-même, ce qui créerait une récursion infinie ; ce rapport documente explicitement cette limite.

## 18. Contenu complet des fichiers créés/modifiés/supprimés

Note : le rapport courant `docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md` est créé par ce lot. Son auto-inclusion complète est volontairement omise pour éviter une récursion infinie ; son contenu complet est le présent document. Aucun fichier supprimé.

### docs/v1/RICH_CLOSED_QUESTION_TYPES_CATALOG.md

```md
# Catalogue — Types de questions riches fermées

Ce catalogue décrit les types de questions fermées proposés pour la V1. Tous les types ci-dessous interdisent les réponses libres. La correction est calculée côté backend et n'est exposée qu'après soumission.

## 1. `single_choice`

- Nom produit : Choix unique avancé.
- Description : une seule réponse correcte parmi des distracteurs plausibles.
- Quand l'utiliser : qualification simple, exception, conséquence, comparaison fermée.
- Quand ne pas l'utiliser : quand plusieurs conditions sont vraies ou quand l'objectif est une procédure ordonnée.
- Exemple droit constitutionnel : “Dans quel régime le gouvernement est-il politiquement responsable devant le Parlement ?”
- Structure de réponse attendue : `{ questionId, choiceId }`.
- Scoring : 1 si `choiceId` correspond à la correction, 0 sinon.
- Sources : au moins un `sourceChunkId` si la question dépend du document.
- Validation backend : 2 à 5 choix, un seul `correctChoiceId`, distracteurs distincts.
- Validation frontend : un seul choix sélectionnable, pas de correction pré-submit.
- Rendu UI : liste de choix radio.
- Correction UI : réponse choisie, bonne réponse, explication, sources post-submit.
- Risques : trop proche du QCM basique si le prompt n'impose pas l'application ou la comparaison.
- Priorité : V1-A.
- Complexité estimée : faible.

## 2. `multiple_choice`

- Nom produit : Réponses multiples.
- Description : plusieurs réponses correctes doivent être sélectionnées.
- Quand l'utiliser : propriétés cumulatives, conditions, effets multiples.
- Quand ne pas l'utiliser : quand il existe une unique meilleure réponse.
- Exemple droit constitutionnel : sélectionner les traits possibles d'un régime parlementaire.
- Structure de réponse attendue : `{ questionId, choiceIds }`.
- Scoring : ensemble exact en MVP ; scoring partiel à décider.
- Sources : sources sur la notion et idéalement sur chaque explication.
- Validation backend : au moins 2 bonnes réponses, `minSelections` et `maxSelections` cohérents.
- Validation frontend : cases à cocher, compteur de sélection.
- Rendu UI : liste de choix checkbox.
- Correction UI : bonnes réponses, réponses choisies, explication.
- Risques : ambiguïté si “toutes les bonnes réponses” n'est pas clair.
- Priorité : V1-A.
- Complexité estimée : faible à moyenne.

## 3. `true_false`

- Nom produit : Vrai ou faux.
- Description : juger une affirmation isolée.
- Quand l'utiliser : vérifier une idée simple mais piégeuse.
- Quand ne pas l'utiliser : quand plusieurs dimensions doivent être croisées.
- Exemple droit constitutionnel : “Une constitution matérielle se limite au texte écrit appelé Constitution.”
- Structure de réponse attendue : `{ questionId, value: boolean }`.
- Scoring : booléen exact.
- Sources : source exigée si l'affirmation vient du cours.
- Validation backend : une affirmation bornée, une correction booléenne, explication obligatoire.
- Validation frontend : deux boutons exclusifs.
- Rendu UI : segmented control Vrai/Faux.
- Correction UI : valeur attendue et explication.
- Risques : peut redevenir trop facile s'il est isolé.
- Priorité : V1-B.
- Complexité estimée : faible.

## 4. `true_false_grid`

- Nom produit : Grille vrai/faux.
- Description : plusieurs affirmations liées à juger dans une grille.
- Quand l'utiliser : comparer des notions proches ou repérer des confusions.
- Quand ne pas l'utiliser : sur mobile si la grille devient trop large.
- Exemple droit constitutionnel : souveraineté nationale/populaire, référendum, représentation.
- Structure de réponse attendue : `{ questionId, valuesByRowId: Record<string, boolean> }`.
- Scoring : un point par ligne ou ensemble exact selon ADR.
- Sources : source par ligne ou source globale.
- Validation backend : 3 à 8 lignes, affirmations courtes, correction complète.
- Validation frontend : grille accessible avec radios par ligne.
- Rendu UI : tableau vertical compact.
- Correction UI : ligne correcte/incorrecte avec explication groupée.
- Risques : surcharge visuelle.
- Priorité : V1-B.
- Complexité estimée : moyenne.

## 5. `matching`

- Nom produit : Association.
- Description : associer des éléments de gauche à des éléments de droite.
- Quand l'utiliser : notion/définition, institution/compétence, régime/mécanisme.
- Quand ne pas l'utiliser : si les paires ne sont pas univoques.
- Exemple droit constitutionnel : associer motion de censure, dissolution et contrôle de constitutionnalité à leur définition.
- Structure de réponse attendue : `{ questionId, pairs: Array<{ leftId, rightId }> }`.
- Scoring : par paire correcte ; ensemble exact en MVP si besoin.
- Sources : sources sur chaque paire ou sur la question.
- Validation backend : minimum 3 paires, pas de doublon, labels courts.
- Validation frontend : menus déroulants ou sélection en deux temps.
- Rendu UI : colonne de gauche + dropdown à droite.
- Correction UI : paires attendues et paires choisies.
- Risques : ambiguïté si plusieurs éléments semblent compatibles.
- Priorité : V1-A.
- Complexité estimée : moyenne.

## 6. `ordering`

- Nom produit : Remise en ordre.
- Description : remettre des étapes ou éléments dans une séquence.
- Quand l'utiliser : procédure, chronologie courte, raisonnement institutionnel.
- Quand ne pas l'utiliser : si l'ordre est discutable ou dépend d'une interprétation.
- Exemple droit constitutionnel : ordonner les étapes simplifiées d'une révision constitutionnelle.
- Structure de réponse attendue : `{ questionId, orderedIds: string[] }`.
- Scoring : ordre exact en MVP ; score par position plus tard.
- Sources : source sur la procédure ou la chronologie.
- Validation backend : 3 à 6 items, ordre complet, labels courts.
- Validation frontend : drag-and-drop ou boutons monter/descendre.
- Rendu UI : liste ordonnable.
- Correction UI : ordre attendu et ordre soumis.
- Risques : accessibilité drag-and-drop.
- Priorité : V1-A.
- Complexité estimée : moyenne.

## 7. `timeline`

- Nom produit : Frise chronologique.
- Description : ordonner des événements ou périodes sur une frise.
- Quand l'utiliser : républiques, constitutions, régimes, événements historiques.
- Quand ne pas l'utiliser : si les dates sont accessoires à l'apprentissage.
- Exemple droit constitutionnel : placer IIIe République, IVe République et Ve République.
- Structure de réponse attendue : `{ questionId, orderedEventIds: string[] }`.
- Scoring : ordre exact.
- Sources : source historique ou chapitre.
- Validation backend : dates ou périodes cohérentes, 3 à 8 événements.
- Validation frontend : frise ou liste ordonnable.
- Rendu UI : timeline responsive.
- Correction UI : frise correcte.
- Risques : confondre apprentissage juridique et bachotage de dates.
- Priorité : V1-B.
- Complexité estimée : moyenne.

## 8. `date_slider`

- Nom produit : Curseur de date.
- Description : sélectionner une année ou une période dans des bornes fermées.
- Quand l'utiliser : dates constitutionnelles majeures.
- Quand ne pas l'utiliser : si la réponse exige une explication libre.
- Exemple droit constitutionnel : placer l'adoption de la Constitution de 1958.
- Structure de réponse attendue : `{ questionId, year: number }`.
- Scoring : année exacte ou tolérance explicite.
- Sources : source sur l'événement.
- Validation backend : `minYear`, `maxYear`, `correctYear`, tolérance bornée.
- Validation frontend : slider avec champ numérique accessible.
- Rendu UI : slider + libellé.
- Correction UI : année attendue et courte explication.
- Risques : mauvaise accessibilité si slider seul.
- Priorité : V1-B.
- Complexité estimée : moyenne.

## 9. `image_choice`

- Nom produit : Choix d'image.
- Description : identifier un portrait, symbole ou document depuis des assets contrôlés.
- Quand l'utiliser : reconnaissance historique avec images libres de droits.
- Quand ne pas l'utiliser : si les droits ou l'accessibilité ne sont pas maîtrisés.
- Exemple droit constitutionnel : identifier une figure associée à une période constitutionnelle.
- Structure de réponse attendue : `{ questionId, assetId: string }`.
- Scoring : asset exact.
- Sources : source pédagogique + metadata asset.
- Validation backend : asset allowlisté, alt text obligatoire, aucune URL libre.
- Validation frontend : grille d'images avec alt text.
- Rendu UI : cartes image.
- Correction UI : image choisie, image attendue, explication.
- Risques : copyright, accessibilité, stockage.
- Priorité : V1-D.
- Complexité estimée : élevée.

## 10. `diagram_labeling`

- Nom produit : Schéma à compléter.
- Description : placer des labels dans des zones bornées d'un schéma.
- Quand l'utiliser : institutions et relations.
- Quand ne pas l'utiliser : si le schéma doit être librement dessiné ou interprété.
- Exemple droit constitutionnel : compléter un schéma Président/Gouvernement/Parlement.
- Structure de réponse attendue : `{ questionId, labelBySlotId: Record<string, string> }`.
- Scoring : un point par slot.
- Sources : source sur l'organisation institutionnelle.
- Validation backend : slots et labels bornés, relations cohérentes.
- Validation frontend : drag/drop accessible ou dropdown par slot.
- Rendu UI : schéma borné non SVG libre, construit par Flutter.
- Correction UI : slots corrects et erreurs.
- Risques : ne pas rendre Mermaid/SVG libre.
- Priorité : V1-C.
- Complexité estimée : élevée.

## 11. `institution_matrix`

- Nom produit : Matrice institutionnelle.
- Description : compléter ou lire une matrice institutions/propriétés.
- Quand l'utiliser : comparer compétences, responsabilités, désignations.
- Quand ne pas l'utiliser : si la matrice dépasse l'écran ou devient encyclopédique.
- Exemple droit constitutionnel : comparer Président, Gouvernement, Assemblée nationale et Sénat.
- Structure de réponse attendue : `{ questionId, valuesByCellId: Record<string, string> }`.
- Scoring : par cellule.
- Sources : source par ligne ou matrice.
- Validation backend : dimensions bornées, options fermées.
- Validation frontend : table scrollable accessible.
- Rendu UI : matrice compacte.
- Correction UI : cellules correctes/incorrectes.
- Risques : surcharge mobile.
- Priorité : V1-C.
- Complexité estimée : élevée.

## 12. `case_qualification`

- Nom produit : Qualification de cas.
- Description : choisir la notion ou catégorie juridique qui qualifie un cas court.
- Quand l'utiliser : application à des mini-situations fermées.
- Quand ne pas l'utiliser : si plusieurs qualifications sont défendables.
- Exemple droit constitutionnel : un gouvernement responsable devant une chambre élue relève du régime parlementaire.
- Structure de réponse attendue : `{ questionId, choiceId }`.
- Scoring : choix exact.
- Sources : source sur les critères de qualification.
- Validation backend : cas court, choix mutuellement exclusifs, explication obligatoire.
- Validation frontend : bloc cas + choix.
- Rendu UI : panneau de cas puis réponses.
- Correction UI : qualification attendue et critères.
- Risques : cas trop ambigu.
- Priorité : V1-A.
- Complexité estimée : faible à moyenne.

## 13. `error_detection`

- Nom produit : Détection d'erreur.
- Description : repérer l'erreur dans une affirmation ou un raisonnement.
- Quand l'utiliser : corriger des confusions typiques.
- Quand ne pas l'utiliser : si l'affirmation contient plusieurs erreurs indépendantes.
- Exemple droit constitutionnel : “Le régime présidentiel suppose une responsabilité politique du gouvernement devant le Parlement.”
- Structure de réponse attendue : `{ questionId, errorId: string }`.
- Scoring : erreur exacte.
- Sources : source sur la distinction correcte.
- Validation backend : une erreur dominante, options distinctes.
- Validation frontend : affirmation mise en évidence + choix.
- Rendu UI : panneau “raisonnement à auditer”.
- Correction UI : erreur repérée et correction courte.
- Risques : générer des énoncés faux trop plausibles sans correction claire.
- Priorité : V1-A.
- Complexité estimée : moyenne.

## 14. `cause_consequence`

- Nom produit : Cause et conséquence.
- Description : associer un mécanisme à ses effets.
- Quand l'utiliser : relations institutionnelles et logiques de régime.
- Quand ne pas l'utiliser : si la relation est controversée ou ouverte.
- Exemple droit constitutionnel : dissolution -> pression politique possible sur la chambre.
- Structure de réponse attendue : `{ questionId, pairs: Array<{ causeId, consequenceId }> }`.
- Scoring : par paire.
- Sources : source sur le mécanisme.
- Validation backend : paires univoques, pas de doublon.
- Validation frontend : matching spécialisé.
- Rendu UI : association cause/effet.
- Correction UI : paires attendues.
- Risques : causalité trop simplifiée.
- Priorité : V1-B.
- Complexité estimée : moyenne.

## 15. `calculation_mcq`

- Nom produit : Calcul fermé.
- Description : appliquer une règle chiffrée et choisir le résultat.
- Quand l'utiliser : modes de scrutin, répartition simplifiée, seuils.
- Quand ne pas l'utiliser : si l'étudiant doit détailler librement son calcul.
- Exemple droit constitutionnel : choisir une répartition de sièges selon un tableau simplifié.
- Structure de réponse attendue : `{ questionId, choiceId }`.
- Scoring : choix exact ; étapes montrées seulement après submit.
- Sources : source sur la règle.
- Validation backend : données petites, résultat vérifiable, distracteurs plausibles.
- Validation frontend : tableau de données + choix.
- Rendu UI : mini-tableau et QCM.
- Correction UI : résultat attendu et étapes.
- Risques : erreurs IA dans les calculs ; nécessite validation déterministe si possible.
- Priorité : V1-C.
- Complexité estimée : élevée.

## 16. `fill_blank_dropdown`

- Nom produit : Texte à trous fermé.
- Description : compléter des blancs par menus déroulants.
- Quand l'utiliser : phrases conceptuelles, définitions structurées.
- Quand ne pas l'utiliser : si la phrase devient une dictée ou demande formulation libre.
- Exemple droit constitutionnel : “Dans un régime ___, le gouvernement est responsable devant ___.”
- Structure de réponse attendue : `{ questionId, optionByBlankId: Record<string, string> }`.
- Scoring : par blanc ou ensemble exact.
- Sources : source sur les concepts.
- Validation backend : 1 à 5 blancs, options distinctes, texte borné.
- Validation frontend : texte avec dropdowns.
- Rendu UI : phrase interactive.
- Correction UI : options attendues et explication.
- Risques : lisibilité mobile.
- Priorité : V1-B ou V1.1.
- Complexité estimée : moyenne.

## Types optionnels

### `odd_one_out`

- Nom produit : Intrus.
- Usage : identifier l'élément qui ne partage pas la même catégorie.
- Exemple : trouver l'intrus entre régime parlementaire, régime présidentiel, État fédéral, régime semi-présidentiel.
- Priorité : hors MVP, utile V1.1.

### `two_axis_sort`

- Nom produit : Tri à deux axes.
- Usage : classer des notions selon deux dimensions fermées, par exemple “juridique/politique” et “organe/procédure”.
- Priorité : hors MVP, car UI plus délicate.

### `mini_case_set`

- Nom produit : Série de mini-cas.
- Usage : qualifier 3 à 5 mini-cas avec un même jeu d'options.
- Priorité : V1.1, après stabilisation de `case_qualification`.

```

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

### lib/features/activities/domain/rich_closed_exercise.dart

```dart
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
  causeConsequence('cause_consequence');

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
  'answersPayload',
  'expectedAnswer',
  'expectedAnswers',
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
  'answersPayload',
  'expectedAnswer',
  'expectedAnswers',
};

```

### lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart

```dart
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
}

```

### lib/features/activities/presentation/rich_closed/rich_closed_cause_consequence_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedCauseConsequenceWidget extends StatefulWidget {
  const RichClosedCauseConsequenceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedCauseConsequenceQuestion question;
  final ValueChanged<RichClosedCauseConsequenceAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedCauseConsequenceWidget> createState() =>
      _RichClosedCauseConsequenceWidgetState();
}

class _RichClosedCauseConsequenceWidgetState
    extends State<RichClosedCauseConsequenceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedCauseConsequenceWidget oldWidget) {
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
        for (final cause in widget.question.causes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _CauseConsequenceRow(
              question: widget.question,
              cause: cause,
              selectedConsequenceId: _controller.selectedConsequenceIdFor(
                widget.question.id,
                cause.id,
              ),
              enabled: widget.enabled,
              onChanged: (consequenceId) =>
                  _selectPair(cause.id, consequenceId),
            ),
          ),
      ],
    );
  }

  void _selectPair(String causeId, String? consequenceId) {
    if (!widget.enabled || consequenceId == null) {
      return;
    }

    setState(() {
      _controller.setCauseConsequencePair(
        question: widget.question,
        causeId: causeId,
        consequenceId: consequenceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedCauseConsequenceAnswer ? answer : null,
    );
  }
}

class _CauseConsequenceRow extends StatelessWidget {
  const _CauseConsequenceRow({
    required this.question,
    required this.cause,
    required this.selectedConsequenceId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedCauseConsequenceQuestion question;
  final RichClosedCauseConsequenceItem cause;
  final String? selectedConsequenceId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cause.label, style: Theme.of(context).textTheme.labelLarge),
          if (cause.description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              cause.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                key: ValueKey('cause-consequence-${question.id}-${cause.id}'),
                value: selectedConsequenceId,
                isExpanded: true,
                hint: const Text('Choisir une conséquence'),
                items: [
                  for (final consequence in question.consequences)
                    DropdownMenuItem<String>(
                      value: consequence.id,
                      child: Text(consequence.label),
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

```

### lib/features/activities/presentation/rich_closed/rich_closed_correction_presenter.dart

```dart
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

```

### lib/features/activities/presentation/rich_closed/rich_closed_question_card.dart

```dart
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

```

### lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_case_qualification_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_cause_consequence_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_date_slider_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_error_detection_widget.dart';
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

```

### lib/features/activities/presentation/rich_closed/rich_closed_true_false_grid_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedTrueFalseGridWidget extends StatefulWidget {
  const RichClosedTrueFalseGridWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedTrueFalseGridQuestion question;
  final ValueChanged<RichClosedTrueFalseGridAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedTrueFalseGridWidget> createState() =>
      _RichClosedTrueFalseGridWidgetState();
}

class _RichClosedTrueFalseGridWidgetState
    extends State<RichClosedTrueFalseGridWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedTrueFalseGridWidget oldWidget) {
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
        for (final row in widget.question.rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _TrueFalseGridRow(
              row: row,
              selectedValue: _controller.selectedTrueFalseValueFor(
                widget.question.id,
                row.id,
              ),
              enabled: widget.enabled,
              onChanged: (value) => _selectValue(row.id, value),
            ),
          ),
      ],
    );
  }

  void _selectValue(String rowId, bool value) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.setTrueFalseValue(
        question: widget.question,
        rowId: rowId,
        value: value,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedTrueFalseGridAnswer ? answer : null,
    );
  }
}

class _TrueFalseGridRow extends StatelessWidget {
  const _TrueFalseGridRow({
    required this.row,
    required this.selectedValue,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedTrueFalseRow row;
  final bool? selectedValue;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.statement, style: Theme.of(context).textTheme.bodyMedium),
          if (row.context != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(row.context!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _BooleanButton(
                key: ValueKey('true-false-${row.id}-true'),
                label: 'Vrai',
                selected: selectedValue == true,
                enabled: enabled,
                onPressed: () => onChanged(true),
              ),
              _BooleanButton(
                key: ValueKey('true-false-${row.id}-false'),
                label: 'Faux',
                selected: selectedValue == false,
                enabled: enabled,
                onPressed: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BooleanButton extends StatelessWidget {
  const _BooleanButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      child: Text(label),
    );
  }
}

```

### test/features/activities/fixtures/rich_closed_exercise_fixtures.dart

```dart
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
      'institution_matrix';
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

```

### test/features/activities/rich_closed_answer_controller_test.dart

```dart
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

```

### test/features/activities/rich_closed_correction_presenter_test.dart

```dart
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

```

### test/features/activities/rich_closed_exercise_flow_controller_test.dart

```dart
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

```

### test/features/activities/rich_closed_exercise_page_test.dart

```dart
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

```

### test/features/activities/rich_closed_exercise_test.dart

```dart
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

```

### test/features/activities/rich_closed_true_false_cause_widgets_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_cause_consequence_widget.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_true_false_grid_widget.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedV1BFullExerciseJson());
  });

  testWidgets('true_false_grid affiche les lignes et produit values', (
    tester,
  ) async {
    final answers = <RichClosedTrueFalseGridAnswer?>[];
    final question = _question<RichClosedTrueFalseGridQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedTrueFalseGridWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(
      find.text('Le gouvernement peut être responsable devant le Parlement.'),
      findsOneWidget,
    );
    expect(
      find.text('La séparation des pouvoirs interdit toute collaboration.'),
      findsOneWidget,
    );
    _expectNoPreSubmitLeaks();

    await tester.tap(find.byKey(const ValueKey('true-false-row-1-true')));
    await tester.pump();
    expect(answers.last, isNull);

    await tester.tap(find.byKey(const ValueKey('true-false-row-2-false')));
    await tester.tap(find.byKey(const ValueKey('true-false-row-3-true')));
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(answer!.values.map((value) => '${value.rowId}:${value.value}'), [
      'row-1:true',
      'row-2:false',
      'row-3:true',
    ]);
  });

  testWidgets('cause_consequence affiche les causes et produit pairs', (
    tester,
  ) async {
    final answers = <RichClosedCauseConsequenceAnswer?>[];
    final question = _question<RichClosedCauseConsequenceQuestion>(exercise);

    await tester.pumpWidget(
      _TestHost(
        child: RichClosedCauseConsequenceWidget(
          question: question,
          onAnswerChanged: answers.add,
        ),
      ),
    );

    expect(find.text('Motion de censure adoptée'), findsOneWidget);
    expect(find.text('Dissolution de l’Assemblée'), findsOneWidget);
    expect(find.text('Choisir une conséquence'), findsNWidgets(3));
    _expectNoPreSubmitLeaks();

    _selectDropdown(
      tester,
      key: 'cause-consequence-cause-consequence-1-cause-1',
      value: 'consequence-1',
    );
    await tester.pump();
    expect(answers.last, isNull);

    _selectDropdown(
      tester,
      key: 'cause-consequence-cause-consequence-1-cause-2',
      value: 'consequence-2',
    );
    _selectDropdown(
      tester,
      key: 'cause-consequence-cause-consequence-1-cause-3',
      value: 'consequence-3',
    );
    await tester.pump();

    final answer = answers.last;
    expect(answer, isNotNull);
    expect(
      answer!.pairs.map((pair) => '${pair.causeId}:${pair.consequenceId}'),
      [
        'cause-1:consequence-1',
        'cause-2:consequence-2',
        'cause-3:consequence-3',
      ],
    );
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
  expect(find.text('correctPairs'), findsNothing);
  expect(find.text('explanation'), findsNothing);
  expect(find.text('feedback'), findsNothing);
  expect(find.text('score'), findsNothing);
  expect(find.text('modelAnswer'), findsNothing);
}

```
