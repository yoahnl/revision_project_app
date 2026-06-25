# RICH-01 — Course-level QCM complet report

Date : 2026-06-25

Repo : App `yoahnl/revision_project_app`

Baseline relevee avant travaux : `c4ec04b69ff4acfef25ef65df5585d3c2d8d4d77`

## 1. Audit initial RICH-01

Roadmap V3.1 : `RESET-01`, `QB-01` et `MODE-01` etaient `DONE`; `RICH-01` etait le prochain lot executable.

App :

- `CourseDetailPage` affichait deja la carte `QCM complet`, mais elle n'etait pas branchee sur une page course-level dediee.
- Le routeur exposait deja les routes QCM complet historiques par activite et par `sessionId`.
- Les pages/resultats QCM complet existaient deja dans `features/activities`.
- Les providers `courses` avaient deja les surfaces course detail, history, readiness, exam et quick revision.
- Aucun composant design system nouveau n'etait necessaire.

Risques identifies :

- bouton QCM complet active sans vraie action ;
- double generation si la page naviguait vers l'ancien demarrage par source/notion au lieu du `sessionId` cree par l'API ;
- wording utilisateur avec jargon technique ;
- regression sur quick revision, preparation examen QCM, result/history riches.

## 2. Architecture retenue

L'App ajoute une surface course-level :

```text
/courses/:courseId/rich-revision
```

Cette page :

- charge les options API ;
- affiche readiness, notion, nombre de questions, profil et types inclus ;
- demarre le QCM complet via le contrat course-level ;
- navigue ensuite vers la route QCM complet existante avec le `sessionId` retourne par l'API.

La page d'exercice existante garde la responsabilite de la session, de la correction, du resultat et de l'historique.

## 3. Contrat App final

Nouveaux modeles :

- `CourseRichRevisionOptions`
- `CourseRichRevisionReadiness`
- `CourseRichRevisionScopeOption`
- `CourseRichRevisionConfig`
- `CourseRichRevisionNextStep`

Repository :

- `getRichRevisionOptions(courseId)`
- `startCourseRichRevision(courseId, config)`

Providers :

- `courseRichRevisionOptionsProvider(courseId)`
- `startCourseRichRevisionControllerProvider`

Route :

- `AppRoutes.courseRichRevision(courseId)`
- `CourseRichRevisionPage`

## 4. UX finale

Sur le detail cours :

- `QCM complet` devient une vraie carte active quand une notion exploitable existe ;
- la carte reste desactivee avec un message clair quand aucune source ou aucune notion n'est disponible ;
- `Revision approfondie` reste volontairement `Bientot` ;
- `Preparation examen - QCM` n'est pas melangee avec RICH-01.

Sur la page `QCM complet` :

- etat readiness en francais simple ;
- selection d'une notion ;
- choix 6, 10 ou 13 questions ;
- choix `Standard` ou `Avance` ;
- bouton `Demarrer le QCM complet` uniquement si une vraie action est possible ;
- navigation vers l'exercice existant par session creee.

Aucun wording utilisateur n'expose `rich closed`, `ActivitySession`, `payload`, `backend`, `sessionId`, `documentId`, `knowledgeUnitId` ou `MVP+`.

## 5. Ce qui est livre

- page course-level QCM complet ;
- route dediee ;
- parser HTTP options ;
- POST start course-level ;
- provider options ;
- controller start ;
- carte course detail active et honnete ;
- non-regression du titre de page QCM complet ;
- tests route/page/repository/course detail.

## 6. Ce qui est reporte

- refonte de l'historique ;
- result UI nouvelle ;
- mix fin des types de questions ;
- quality pool et doublons ;
- deep revision ;
- preparation examen mixte.

## 7. Tests ajoutes ou adaptes

- `course_rich_revision_page_test.dart`
- `http_courses_repository_test.dart`
- `course_detail_page_test.dart`
- `app_router_test.dart`
- `rich_closed_exercise_page_test.dart`
- fake repository course et fixtures mises a jour.

Les tests couvrent :

- parsing options ;
- repository start ;
- route course-level ;
- carte course detail active ;
- carte desactivee sans notion ;
- absence de faux bouton ;
- navigation par session creee ;
- non-regression route result/history riche existante.

## 8. Validations executees

- `dart analyze lib test` : OK, aucune issue apres remplacement de `RadioListTile` deprecie
- `flutter test test/features/courses --reporter compact` : OK
- `flutter test test/features/activities --reporter compact` : OK
- `flutter test test/features/revision_sessions --reporter compact` : OK
- `flutter test test/app/router --reporter compact` : OK
- `git diff --check` : OK apres creation documentaire

## 9. Fichiers modifies

Voir `RICH_01_COURSE_LEVEL_QCM_COMPLET_EVIDENCE_PACK.md`.

## 10. Trackers

- `RICH-01` marque `DONE`.
- Parent `RICH` marque `DONE`.
- Les prochains lots restent `DEEP-01A` puis `DEEP-01B`, avant exam mixte.

## 11. Auto-review finale

- Pas de commit, push, merge, rebase, tag ou deploiement.
- Aucun bouton actif sans action reelle.
- Aucun demarrage double du QCM complet.
- L'App ne calcule pas de score canonique.
- Pas de changement design system global.
- Quick revision, preparation examen QCM, rich result/history et course detail restent couverts par tests.

## 12. Critique du prompt

Le prompt protegeait bien contre la tentation de reconstruire le moteur riche. Le point le plus utile etait l'exigence de router par session creee : c'est ce qui evite la double generation et garde result/history stables.
