# DEEP-01B - Deep result, history & reopen report

Date : 2026-06-25

Repo : App `yoahnl/revision_project_app`

Baseline relevee avant travaux : `861ad2f9194f3f27d1fc269c5c2f24c465c2a580`

## 1. HEAD releves

- API : `0373a43419b6112be8b06c2d20cef3abf5f1020c`
- App : `861ad2f9194f3f27d1fc269c5c2f24c465c2a580`

## 2. Audit initial DEEP-01B

Roadmap V3.1 : `RESET-01`, `QB-01`, `MODE-01`, `RICH-01`, `RICH-01B` et `DEEP-01A` etaient livres. Parent `DEEP` etait `IN_PROGRESS`. `DEEP-01B` etait le prochain lot. `EXAM-02A` devait rester `TODO`.

App :

- `CourseDeepRevisionPage` permettait deja de demarrer une question ouverte et d'afficher la correction inline.
- Il n'existait pas de page result deep reopenable.
- `CourseDetailPage` affichait les historiques quick, QCM complet et preparation examen QCM, mais pas les revisions approfondies terminees.
- Le repository courses ne connaissait pas encore les endpoints deep result/history.
- `OpenQuestionPage` affichait deja le panneau de correction, mais il n'exposait pas de zone CTA post-correction reutilisable.

Risques identifies :

- creer un historique fake cote App ;
- recycler la page result QCM et calculer un score cote App ;
- afficher des termes techniques dans l'UI ;
- ajouter un bouton `Voir le resultat` sans endpoint reel ;
- casser quick, QCM complet, QCM complet sequentiel ou preparation examen QCM.

## 3. Architecture retenue

L'App ajoute un contrat repository/provider dedie :

```text
getCourseDeepRevisionResult(courseId, sessionId)
getCourseDeepRevisionHistory(courseId, limit)
courseDeepRevisionResultProvider((courseId, sessionId))
courseDeepRevisionHistoryProvider(courseId)
```

La route result dediee est :

```text
/courses/:courseId/deep-revision/sessions/:sessionId/result
```

La page `CourseDeepRevisionResultPage` consomme uniquement les donnees backend. Elle ne calcule pas de score canonique et ne fabrique pas d'historique.

## 4. Contrat App final

Nouveaux modeles :

- `CourseDeepRevisionHistoryResponse`
- `CourseDeepRevisionHistoryItem`
- `CourseDeepRevisionResult`
- `CourseDeepRevisionResultSession`
- `CourseDeepRevisionAnswer`

Repository :

- `getCourseDeepRevisionHistory`
- `getCourseDeepRevisionResult`

Provider :

- `courseDeepRevisionHistoryProvider`
- `courseDeepRevisionResultProvider`

Route :

- `AppRoutes.courseDeepRevisionResultPath`
- `AppRoutes.courseDeepRevisionResult(...)`
- `CourseDeepRevisionResultPage`

## 5. UX finale

Apres correction inline dans `Revision approfondie` :

- `Voir le resultat` ouvre la vraie page result course-level ;
- `Retour au cours` revient au detail du cours ;
- les deux CTA ont une action reelle.

Page result :

- titre `Resultat de revision approfondie` ;
- notion et source ;
- question ;
- reponse envoyee ;
- correction detaillee via le composant open question partage ;
- sources du cours ;
- retour au cours.

Detail cours :

- l'historique inclut une entree `Revision approfondie` quand le backend renvoie des items deep ;
- l'entree affiche score fourni par l'API, notion, date et `Voir le resultat` ;
- aucun item n'est affiche si l'historique deep est vide.

## 6. Ce qui est supporte

- result deep reopenable depuis URL ;
- reopen depuis historique cours ;
- CTA post-correction vers result ;
- affichage score fourni par l'API ;
- etat erreur user-facing si result indisponible ;
- absence de jargon technique dans les widgets cibles.

## 7. Ce qui est reporte

- fusion chronologique globale parfaite des historiques ;
- polish global des loaders/empty states ;
- statistiques deep avancees ;
- examen mixte ;
- Rena/animations.

## 8. Tests ajoutes ou adaptes

- `course_deep_revision_result_page_test.dart`
- `course_deep_revision_page_test.dart`
- `course_detail_page_test.dart`
- `courses_providers_test.dart`
- `http_courses_repository_test.dart`
- `app_router_test.dart`
- `in_memory_courses_repository.dart`

Cas couverts :

- parser result/history ;
- mapping 404 result indisponible ;
- provider history ;
- provider result ;
- CTA `Voir le resultat` apres correction ;
- page result chargee depuis backend ;
- page result affiche question, reponse, correction, score et sources ;
- detail cours affiche l'historique deep ;
- historique deep ouvre le result ;
- absence de jargon technique visible.

## 9. Validations executees

- `dart analyze lib test` : OK
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/revision_sessions --reporter compact` : OK
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK apres creation documentaire finale

## 10. Fichiers modifies

Voir `DEEP_01B_DEEP_RESULT_HISTORY_EVIDENCE_PACK.md`.

## 11. Trackers

- `DEEP-01B` marque `DONE`.
- Parent `DEEP` marque `DONE`.
- `EXAM-02A` reste `TODO`.

## 12. Smoke manuel

Smoke manuel non execute dans ce lot. Les garanties disponibles sont les tests widget/repository/router et les validations App/API.

## 13. Auto-review finale

- Pas de commit, push, merge, rebase, amend, tag ou deploiement.
- Aucun score canonique calcule cote App.
- Aucun historique fake cote App.
- Aucun bouton actif sans action.
- Aucun wording technique volontairement affiche.
- Quick revision, QCM complet, QCM complet sequentiel et preparation examen QCM restent couverts par tests.

## 14. Critique du prompt

Le prompt etait tres utile pour eviter de transformer DEEP-01B en refonte globale d'historique. Le point delicat cote App etait de ne pas recycler la page QCM result. La page dediee conserve une UX claire et limite le scope au result/history/reopen deep.

## 15. Etat Git honnete

Operations Git volontairement executees dans ce lot :

- `git rev-parse HEAD`
- `git status --short`
- `git diff --check`

Aucun commit, push, merge, rebase, amend, tag ou deploiement n'a ete execute.

Etat Git final observe apres ce lot : modifications locales non commitees dans les fichiers du lot et documents V3.1.
