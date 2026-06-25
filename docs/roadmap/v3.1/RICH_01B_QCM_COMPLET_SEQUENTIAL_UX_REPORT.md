# RICH-01B -- QCM complet sequential mobile UX report

Date : 2026-06-25

Repo : App `yoahnl/revision_project_app`

Baseline relevee avant travaux : `21d16f880213644f417b3a5adc0ae6c7f08bac7f`

## 1. HEAD releve

- HEAD App initial et courant avant modifications : `21d16f880213644f417b3a5adc0ae6c7f08bac7f`.
- Repo API non touche.

## 2. Audit initial RICH-01B

Fichiers audites :

- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `lib/features/activities/application/rich_closed_exercise_flow_controller.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_correction_list.dart`
- `lib/features/activities/domain/rich_closed_exercise.dart`
- `lib/app/router/app_routes.dart`
- `lib/app/router/app_router.dart`
- `test/features/activities/rich_closed_exercise_page_test.dart`

Constats :

- `RichClosedExercisePage` rendait toutes les questions avec une boucle sur `exercise.questions`.
- Les reponses locales etaient deja centralisees dans `RichClosedCoreAnswerController`.
- Le flow applicatif conservait deja les reponses via `RichClosedExerciseFlowController.recordAnswer`.
- La soumission etait deja protegee par `_activeSubmit` dans le controleur.
- Le chargement par session existante passait par `load(sessionId: ...)`; le demarrage legacy passait par `start(subjectId, knowledgeUnitId, documentId)`.
- Le resultat existant utilisait `RichClosedCorrectionList`; il ne fallait pas reconstruire la page resultat.
- Le libelle visible `Score backend` etait encore present dans la carte resultat et contrevenait au garde-fou anti-jargon.

## 3. Probleme UX constate

Le QCM complet affichait plusieurs questions dans le meme scroll. Sur mobile, cela melangeait progression, reponses et validation finale. Le bouton final pouvait etre loin de la question courante et l'utilisateur pouvait voir des morceaux de questions precedentes ou suivantes.

## 4. Architecture retenue

La correction reste locale a la page d'exercice :

- `_ReadyExercisePanel` devient stateful avec `int _questionIndex = 0`.
- La page choisit uniquement `exercise.questions[_questionIndex]`.
- `RichClosedQuestionRenderer` reste le renderer unique par type de question.
- `RichClosedCoreAnswerController` reste la source de verite des reponses locales.
- `_StepNavigationBar` gere `Precedent`, `Suivant` et `Valider le QCM`.
- La soumission finale appelle le `submit` existant et reste protegee par le controleur.

Aucun contrat backend, routeur, prompt IA, provider IA ou schema Prisma n'a ete modifie.

## 5. Comportement avant/apres

Avant :

- toutes les questions etaient visibles en liste verticale ;
- le message de blocage parlait de toutes les questions ;
- le bouton final etait libelle `Valider mes reponses` ;
- la carte resultat affichait `Score backend`.

Apres :

- une seule question est visible ;
- l'en-tete affiche `Question X / N` avec une barre de progression ;
- `Suivant` est bloque tant que la question courante est incomplete ;
- `Precedent` est desactive sur la premiere question ;
- la derniere etape affiche `Valider le QCM` ;
- le bouton final est desactive pendant la soumission et affiche `Correction en cours...` ;
- les reponses precedentes restent visibles au retour ;
- la carte resultat affiche `Score final`.

## 6. Fichiers modifies

Voir `RICH_01B_QCM_COMPLET_SEQUENTIAL_UX_EVIDENCE_PACK.md`.

Fichiers applicatifs :

- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `lib/features/activities/presentation/rich_closed/rich_closed_result_summary_card.dart`

Tests :

- `test/features/activities/rich_closed_exercise_page_test.dart`

Documentation :

- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/RICH_01B_QCM_COMPLET_SEQUENTIAL_UX_REPORT.md`
- `docs/roadmap/v3.1/RICH_01B_QCM_COMPLET_SEQUENTIAL_UX_EVIDENCE_PACK.md`

## 7. Tests ajoutes

Tests ajoutes ou adaptes dans `rich_closed_exercise_page_test.dart` :

- affichage d'une seule question au demarrage ;
- question 2 non visible au demarrage ;
- `Suivant` bloque avant reponse ;
- passage a la question 2 apres reponse ;
- retour a la question 1 ;
- conservation de la reponse selectionnee ;
- chargement par session existante sans nouveau demarrage ;
- soumission finale appelee une seule fois malgre un double tap ;
- resultat existant toujours affiche apres correction ;
- libelle resultat anti-jargon `Score final`.

## 8. Validations executees

Validations finales executees apres modifications :

- `dart analyze lib test` : OK
- `flutter test test/features/activities/rich_closed_exercise_page_test.dart --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK

## 9. Risques restants

- Les tres grands formats de question peuvent encore necessiter du scroll interne a la question courante.
- Le type `date_slider` est considere complet avec sa valeur initiale existante, comme avant ce lot.
- Le smoke manuel mobile reel n'a pas ete execute dans un simulateur ; la couverture est assuree par tests widget et analyse statique.

## 10. Evidence pack

Le contenu de preuve est dans `RICH_01B_QCM_COMPLET_SEQUENTIAL_UX_EVIDENCE_PACK.md`.

## 11. Auto-review finale

- Pas de commit, push, merge, rebase, amend, tag ou deploiement.
- Aucun fichier API/backend modifie.
- Aucune modification Prisma, prompt IA ou provider IA.
- Pas de nouveau type de question.
- Pas de calcul de score cote App.
- Pas de reconstruction du resultat ou de l'historique.
- Le demarrage par session existante reste teste.
- Le demarrage legacy par `subjectId` / `knowledgeUnitId` reste couvert par le test de page existant.
- Aucun bouton actif sans action reelle : `Suivant` et `Valider le QCM` sont desactives tant que l'action n'est pas disponible.
- Aucun rendu en liste de toutes les questions dans `RichClosedExercisePage`.
- Le scan des libelles visibles n'a pas retrouve `rich closed`, `backend`, `payload`, `sessionId`, `ActivitySession` ou `MVP+`.

## 12. Critique du prompt

Le prompt etait tres utile car il nommait le vrai probleme UX, pas seulement le symptome technique. La contrainte "ne pas refaire le resultat" a evite un scope creep naturel. Le point le plus fragile reste la validation par type de question complexe : elle depend du controleur existant, ce qui est le bon choix pour ce lot, mais devra rester surveille si de nouveaux formats riches arrivent.
