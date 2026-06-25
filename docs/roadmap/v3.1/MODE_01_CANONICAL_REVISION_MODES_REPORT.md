# MODE-01 - Canonical revision modes & honest UX

## 1. HEADs

API HEAD releve au depart : `9db002dc1bbcfbad8947e7916cd362c21d5ec4c2`.

App HEAD releve au depart : `f8aa5737dac79121a852e30893d3bf4c3514ca8b`.

Aucun commit, push, merge, rebase, amend, tag ou deploiement n'a ete effectue.

## 2. Audit initial MODE-01

### Roadmap

`RESET-01` est `DONE`.

`QB-01` est `DONE`.

`MODE-01` etait le prochain lot apres `QB-01`. `RICH-01` et `DEEP-01A` attendent `MODE-01`. `EXAM-02` attend `RICH-01` et `DEEP-01B`.

Les sub-agents n'etaient pas disponibles via l'outil de decouverte dans ce tour. Le travail a donc ete execute en passes separees : Roadmap, App UX, API Contract, QA, Anti-regression, Reviewer.

### API

Audit lecture seule :

- `courses.controller.ts` expose deja `GET /courses/:courseId/exam-preparation/options`, `POST /courses/:courseId/exam-preparation/sessions`, et l'historique exam.
- `get-course-exam-preparation-options.use-case.ts` retourne readiness, scopes, question counts et `complexityProfile: exam`.
- `start-course-exam-preparation-session.use-case.ts` cree une session `EXAM` a partir du pool QCM quick avec une action `DIAGNOSTIC_QUIZ`.
- `exam-preparation-sessions.use-cases.ts` charge, soumet et ouvre le result exam QCM-only.
- Aucun endpoint ne livre un examen mixte. Aucun besoin de changer le contrat API pour MODE-01.

### App

Avant MODE-01 :

- `CourseDetailPage` affichait `Revision rapide`, `Revision approfondie`, `Preparation examen`.
- `QCM complet` n'etait pas visible comme carte course-level.
- `Revision approfondie` etait desactivee, mais son texte parlait surtout de cours complet et exemples.
- `Preparation examen` ouvrait bien un flux reel, mais son nom pouvait promettre plus que le QCM-only livre.
- L'historique affichait `Questions riches` et `Entrainement examen`.
- `CourseExamPreparationPage`, `ExamRevisionSessionFlow` et `RevisionSessionResultPage` utilisaient encore des titres larges comme `Preparation examen` ou `Examen termine`.

## 3. Wording avant/apres

| Surface | Avant | Apres |
| --- | --- | --- |
| Carte quick | `Revision rapide` | `Revision rapide` |
| Carte rich | Absente | `QCM complet`, desactivee, badge `Bientot` |
| Carte deep | `Revision approfondie`, promesse floue | `Revision approfondie`, question ouverte/redaction/correction, desactivee |
| Carte exam | `Preparation examen` | `Preparation examen - QCM`, action reelle vers la page existante |
| Page exam | `Preparation examen` | `Preparation examen - QCM` |
| CTA exam | `Demarrer l'entrainement` | `Demarrer l'entrainement QCM` |
| Flow exam | `Preparation examen` | `Preparation examen - QCM` |
| Result exam | `Examen termine` | `Preparation examen - QCM terminee` |
| Historique quick | Score + date | `Revision rapide` |
| Historique rich | `Questions riches` | `QCM complet` |
| Historique exam | `Entrainement examen` | `Preparation examen - QCM` |

## 4. Surfaces App modifiees

- `CourseDetailPage` : ajout de la carte `QCM complet` desactivee, clarification deep, renommage exam QCM, labels d'historique.
- `CourseExamPreparationPage` : titre, description, loading/error, readiness/nextStep normalises, CTA QCM.
- `ExamRevisionSessionFlow` : titre et header exam QCM-only.
- `RevisionSessionPage` : redirect terminee exam QCM et launcher rich nomme `QCM complet`.
- `RevisionSessionResultPage` : titre result exam QCM.
- `RevisionsPendingPage` : placeholders deep/exam rendus coherents.
- `HttpCoursesRepository` : fallback d'erreur exam renomme.

## 5. Surfaces volontairement non modifiees

- API product code.
- Prisma schema et migrations.
- Prompts IA et providers IA.
- Routes App existantes et paths.
- Design system global.
- Activities/Today rich closed restent hors RICH-01 : leurs entrees actives historiques ne sont pas transformees en facade course-level `QCM complet`.
- Preparation examen mixte reste reportee a `EXAM-02`.

## 6. Justification API inchangee

MODE-01 est un lot App-first. L'API livre deja la session exam QCM-only issue du pool quick. Les incoherences observees etaient des libelles App et des messages utilisateur. La page App normalise les messages serveur affiches quand ils parlent encore d'entrainement examen, sans changer le contrat ni les payloads.

## 7. Tests ajoutes ou adaptes

- `course_detail_page_test.dart` verifie les quatre modes visibles, `QCM complet` et `Revision approfondie` desactives, exam QCM actif, aucun bouton fake, absence de wording technique sur cette surface.
- `course_exam_preparation_page_test.dart` verifie le titre `Preparation examen - QCM`, la description QCM, le CTA QCM, l'etat bloque et le demarrage reel.
- `revision_session_page_test.dart` verifie `QCM complet` dans le launcher rich et `Preparation examen - QCM` dans le flow exam.
- `revision_session_result_page_test.dart` verifie le titre result exam QCM.

## 8. Validations executees

Executions confirmees :

- `dart analyze lib test` : OK.
- `flutter test test/features/courses --reporter compact` : OK.
- `flutter test test/features/revision_sessions --reporter compact` : OK.
- `flutter test test/app/router --reporter compact` : OK.
- `git diff --check` App : OK.
- `git diff --check` API : OK.
- `flutter test test/features/courses/course_exam_preparation_page_test.dart --reporter compact` : OK.
- `flutter test test/features/revision_sessions/revision_session_page_test.dart --reporter compact` : OK.
- `flutter test test/features/revision_sessions/revision_session_result_page_test.dart --reporter compact` : OK.
- `flutter test test/features/courses/course_detail_page_test.dart --reporter compact` : OK.

## 9. Risques restants

- `ActivitiesPage` et `TodayPage` conservent le wording historique `Questions riches` sur des entrees actives par notion. Cela evite de promettre `QCM complet` course-level avant `RICH-01`, mais `RICH-01` devra harmoniser ces surfaces.
- La page exam QCM normalise certains messages serveur cote App. Un futur lot peut renommer les messages API si le contrat devient public-facing.
- `Preparation examen - QCM` reste une session `EXAM` technique, mais l'UI ne l'expose pas ainsi.

## 9 bis. Prochain lot recommande

`RICH-01 - Course-level QCM complet`.

Raison : `MODE-01` a stabilise les cartes et le wording. La carte `QCM complet` est maintenant visible mais desactivee ; le prochain lot doit brancher une facade course-level reelle sans confondre QCM complet et preparation examen.

## 10. Fichiers modifies

App :

- `lib/features/courses/data/http_courses_repository.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_exam_preparation_page.dart`
- `lib/features/courses/presentation/revisions_pending_page.dart`
- `lib/features/revision_sessions/presentation/exam_revision_session_flow.dart`
- `lib/presentation/pages/revision_sessions/revision_session_page.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/course_exam_preparation_page_test.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`
- `test/features/revision_sessions/revision_session_result_page_test.dart`
- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/MODE_01_CANONICAL_REVISION_MODES_REPORT.md`
- `docs/roadmap/v3.1/MODE_01_CANONICAL_REVISION_MODES_EVIDENCE_PACK.md`

API :

- `docs/roadmap/v3.1/EXECUTION_LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/LOT_TRACKER_V3_1.md`
- `docs/roadmap/v3.1/MODE_01_CANONICAL_REVISION_MODES_REPORT.md`

## 11. Evidence pack

Le contenu detaille des modifications App est documente dans `MODE_01_CANONICAL_REVISION_MODES_EVIDENCE_PACK.md`.

## 12. Auto-review finale

- Aucun examen mixte n'a ete introduit.
- Aucun result/history exam nouveau n'a ete ajoute.
- `QCM complet` est visible depuis le cours mais desactive.
- `Revision approfondie` reste desactivee.
- `Preparation examen - QCM` ouvre le flux existant et reel.
- Aucun bouton actif sans action n'a ete ajoute.
- Les labels quick, rich, deep, exam et history sont coherents sur les surfaces touchees.
- L'API, Prisma, prompts IA et providers IA sont inchanges.
- Aucun secret expose.

## 13. Critique du prompt

Le prompt etait utilement strict sur la frontiere MODE-01/RICH-01/DEEP-01A. Le point le plus delicat etait le wording `Questions riches` hors course detail : le lot a choisi de ne pas renommer globalement Activities/Today pour ne pas transformer une entree active par notion en promesse course-level `QCM complet` avant `RICH-01`.
