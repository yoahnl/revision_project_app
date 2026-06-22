# CORE-10A Async Question Bank Readiness App Audit

## 1. Etat actuel du demarrage quick avant lot

L'app lancait la revision rapide via `CoursesRepository.startCourseQuickRevision`, depuis le detail cours ou le hub. L'appel etait synchrone du point de vue UI : si le backend generait des questions, l'utilisateur restait bloque sur le flow de demarrage.

## 2. Ou la generation IA pouvait bloquer

La generation bloquait cote API, mais l'app ne distinguait pas encore :

- banque prete ;
- questions en preparation ;
- preparation echouee ;
- source non prete.

## 3. Etat actuel de `QuestionBankItem`

L'app ne manipule pas directement `QuestionBankItem`. Elle a besoin d'un contrat utilisateur plus haut niveau : readiness course-level.

## 4. Etat actuel des jobs/queues

Les jobs sont internes au backend. L'app ne gere qu'un endpoint readiness et un endpoint prepare.

## 5. Endpoints existants

Avant CORE-10A, l'app utilisait :

- `POST /courses/:courseId/revision-sessions/quick`

Apres CORE-10A, elle utilise aussi :

- `GET /courses/:courseId/question-bank/readiness`
- `POST /courses/:courseId/question-bank/prepare`

## 6. UI existante

`CourseDetailPage` affichait deja les modes de revision, mais ne pouvait pas montrer l'etat de preparation des questions.

## 7. Risques de doublons

Les taps repétés sur quick pouvaient relancer le backend. CORE-10A limite l'UI en affichant un etat `PREPARING` et en invalidant la readiness apres preparation.

## 8. Risques de concurrence

L'app ne fait pas de locking local avance. Le backend reste source de verite.

## 9. Decision V0 retenue

Afficher une readiness simple dans le detail cours :

- questions pretes ;
- questions en preparation ;
- preparation necessaire ;
- preparation impossible.

Le hub et le launcher mappent les erreurs en messages lisibles.

## 10. Repousse a CORE-10B / CORE-10C

Pas de nouvelle page, pas de streaming, pas de selection multi-KU visible, pas de metriques dans l'app.
