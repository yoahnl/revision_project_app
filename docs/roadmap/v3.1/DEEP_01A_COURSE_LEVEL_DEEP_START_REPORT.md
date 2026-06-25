# DEEP-01A - Course-level deep revision start & correction report

Date : 2026-06-25

Repo : App `yoahnl/revision_project_app`

Baseline relevee avant travaux : `e17973dd410ac6ec949f1c7614650a9bf5eb2e73`

## 1. Audit initial DEEP-01A

Roadmap V3.1 : `RESET-01`, `QB-01`, `MODE-01`, `RICH-01` et `RICH-01B` etaient livres cote produit. `DEEP-01A` etait le prochain lot executable. `DEEP-01B` et `EXAM-02A` restent a faire.

App :

- `CourseDetailPage` affichait deja une carte `Revision approfondie`, mais elle restait une intention produit.
- Le routeur n'avait pas de page course-level dediee pour la revision approfondie.
- `OpenQuestionPage` existait deja et savait afficher une correction d'open question.
- Les repositories courses ne connaissaient pas encore les contrats deep course-level.
- Les tests course detail/router/activities couvraient les modes existants et devaient rester verts.

Risques identifies :

- bouton actif sans vraie action ;
- affichage de jargon technique utilisateur ;
- calcul de score cote App ;
- promesse d'un result/historique deep avant `DEEP-01B` ;
- regression QCM complet sequentiel, quick revision, preparation examen QCM ou result/history existants.

## 2. Architecture retenue

L'App ajoute une surface course-level :

```text
/courses/:courseId/deep-revision
```

Cette page :

- charge les options API ;
- affiche readiness, notion utilisable et conseils de reponse ;
- demarre une vraie question ouverte course-level ;
- reutilise `OpenQuestionPage` pour la redaction et la correction ;
- soumet la reponse via le endpoint course-level deep ;
- ne cree pas de page resultat ou historique deep.

Le repository courses ajoute les appels HTTP dedies. Le routeur branche la page. La carte du detail cours devient active seulement si une action reelle est possible.

## 3. Contrat App final

Nouveaux modeles :

- `CourseDeepRevisionOptions`
- `CourseDeepRevisionReadiness`
- `CourseDeepRevisionScopeOption`
- `CourseDeepRevisionAnswerGuidelines`
- `CourseDeepRevisionConfig`
- `CourseDeepRevisionSession`
- `CourseDeepRevisionSubmitResponse`

Repository :

- `getDeepRevisionOptions(courseId)`
- `startCourseDeepRevision(courseId, config)`
- `submitCourseDeepRevisionAnswer(courseId, sessionId, answer)`

Provider :

- `courseDeepRevisionOptionsProvider(courseId)`

Route :

- `AppRoutes.courseDeepRevision(courseId)`
- `CourseDeepRevisionPage`

## 4. UX finale

Sur le detail cours :

- `Revision approfondie` devient une vraie carte active quand une source prete et une notion exploitable existent ;
- la carte affiche `Configurer` quand l'action est disponible ;
- la carte reste desactivee avec un message clair sinon ;
- aucune mention de result/historique deep n'est faite.

Sur la page `Revision approfondie` :

- titre clair ;
- etat de preparation en francais simple ;
- selection de notion ;
- conseils de redaction ;
- bouton `Demarrer la question ouverte` seulement si le start est possible ;
- reutilisation de la page de reponse ouverte pour envoyer la reponse et afficher la correction.

Le wording visible evite `backend`, `payload`, `ActivitySession`, `RevisionSession`, `sessionId`, `documentId`, `knowledgeUnitId`, `MVP+`, `DEEP` et `OPEN_QUESTION`.

## 5. Ce qui est livre

- page course-level `Revision approfondie` ;
- route dediee ;
- parser HTTP options/start/submit ;
- provider options ;
- carte course detail active et honnete ;
- reutilisation de l'open question pour correction ;
- wording open question nettoye (`Sources du cours`, `Envoyer ma reponse`, `Points reussis`) ;
- tests route/page/repository/provider/course detail/open question.

## 6. Ce qui est reporte a DEEP-01B

- resultat deep dedie ;
- historique deep dedie ;
- reopen result ;
- resume de session deep terminee ;
- agregats et statistiques ;
- integration avec examen mixte ;
- refonte globale de l'open question.

## 7. Tests ajoutes ou adaptes

- `course_deep_revision_page_test.dart`
- `http_courses_repository_test.dart`
- `courses_providers_test.dart`
- `course_detail_page_test.dart`
- `app_router_test.dart`
- `open_question_page_test.dart`
- `in_memory_courses_repository.dart`

Les tests couvrent :

- parser options/start/submit ;
- endpoint HTTP appele ;
- provider options ;
- route course-level ;
- carte course detail active ;
- etat bloque sans faux bouton ;
- demarrage de question ouverte ;
- soumission course-level ;
- absence de jargon visible ;
- non-regression open question et QCM complet.

## 8. Validations executees

- `dart analyze lib test` : OK
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/revision_sessions --reporter compact` : OK apres relance sequentielle
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK apres creation documentaire

Note : une premiere execution parallele de `flutter test test/features/revision_sessions` a crashe dans l'outillage Flutter/Swift Package Manager avant execution des tests. Le dossier ephemeral a ete regenere, puis la meme commande relancee seule a passe.

## 9. Fichiers modifies

Voir `DEEP_01A_COURSE_LEVEL_DEEP_START_EVIDENCE_PACK.md`.

## 10. Trackers

- `DEEP-01A` marque `DONE`.
- Parent `DEEP` marque `IN_PROGRESS`.
- `DEEP-01B` reste `TODO`.
- `EXAM-02A` reste `TODO`.

## 11. Smoke manuel

Smoke manuel non execute dans ce lot. Les garanties disponibles sont les tests widget/repository/router et les validations App.

## 12. Auto-review finale

- Pas de commit, push, merge, rebase, amend, tag ou deploiement.
- Pas de result/history/reopen deep introduit.
- Aucun bouton actif sans action reelle.
- Aucun score canonique calcule cote App.
- Pas de jargon technique dans l'UI cible.
- Quick revision, QCM complet, preparation examen QCM, result/history existants restent couverts par tests.

## 13. Critique du prompt

Le prompt etait tres utile pour tenir la frontiere entre activation course-level et lifecycle complet. Le point le plus delicat etait de reutiliser `OpenQuestionPage` sans transformer cela en result/history deep. Le choix retenu garde une correction reelle immediate et reporte proprement les surfaces persistantes a `DEEP-01B`.
