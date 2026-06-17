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
