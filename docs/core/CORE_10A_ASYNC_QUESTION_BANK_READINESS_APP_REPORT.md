# CORE-10A Async Question Bank Readiness App Report

## 1. Resume

L'app sait maintenant lire et declencher la readiness question bank course-level. Le detail cours affiche l'etat de preparation et la revision rapide gere le cas "questions en preparation" sans exposer de code technique.

## 2. Audit initial

`HttpCoursesRepository` ne connaissait que `startCourseQuickRevision`. `CourseDetailPage` affichait un CTA quick selon l'etat des sources, pas selon l'etat de la banque de questions.

## 3. Sub-agents / passes

- App Integration Agent : contrats repository, provider, UI.
- UX/Wording Agent : messages utilisateur en francais.
- QA Agent : tests repository/providers/widgets/full suite.
- Reviewer Agent : absence de fausse UI et de code technique affiche.

## 4. Architecture retenue

Ajout d'un modele domaine `CourseQuestionBankReadiness` et d'un enum `CourseQuestionBankReadinessStatus`. Le repository expose `getQuestionBankReadiness` et `prepareQuestionBank`. Riverpod expose un provider de readiness et un controller de preparation.

## 5. Readiness contract

Statuts app :

- `noReadySource`
- `noKnowledgeUnits`
- `notPrepared`
- `preparing`
- `ready`
- `failed`
- `unknown`

## 6. App integration

Le detail cours affiche un label adapte :

- `Questions pretes`
- `Questions en preparation`
- `Preparation necessaire`
- `Preparation impossible`

Le CTA quick prepare les questions quand c'est possible, ou ouvre le picker de questions si la banque est prete.

## 7. Tests ajoutes / modifies

- Parsing readiness dans `HttpCoursesRepository`.
- Mapping `409 COURSE_QUICK_REVISION_QUESTIONS_PREPARING`.
- Controller `prepareQuestionBankController`.
- Widget detail cours pour etat preparation.

## 8. Commandes executees

- `flutter --version` : Flutter 3.44.0 / Dart 3.12.0.
- `flutter pub get` : OK, avec avertissement de versions plus recentes incompatibles.
- `dart analyze lib test` : OK.
- `flutter test test/features/courses --reporter compact` : OK.
- `flutter test test/features/revision_sessions --reporter compact` : OK.
- `flutter test test/features/subjects --reporter compact` : OK.
- `flutter test test/app/router/app_router_test.dart --reporter compact` : OK.
- `flutter test test/app/revision_app_test.dart --reporter compact` : OK.
- `flutter test --reporter compact` : OK, 479 tests.

## 9. Recherches statiques

Recherche executee en fin de lot :

- `rg -n "QuestionBankReadiness|questions en préparation|COURSE_QUICK_REVISION_QUESTIONS_PREPARING|CourseQuickRevisionUnavailable|startCourseQuickRevision|prepareQuestionBank" lib test`

Verification : le code technique backend n'est pas affiche tel quel dans les textes utilisateur.

## 10. Limitations

La readiness est visible surtout sur le detail cours. Le hub profite du mapping d'erreur mais n'a pas encore une experience riche de preparation proactive.

## 11. Dette CORE-10B

- etats plus fins si selection multi-KU ;
- meilleur refresh automatique apres job termine.

## 12. Dette CORE-10C

- metriques qualite/cout visibles en interne seulement si necessaire ;
- messages plus detailles selon l'observabilite backend.

## 13. Fichiers crees / modifies

Crees : audit et rapport app.

Modifies : modeles courses, repository, repository HTTP, providers, detail cours, launcher quick, fakes et tests.

## 14. Auto-review

- Pas de nouvelle feature hors readiness.
- Pas de donnees fictives.
- Pas de backend code dans l'UI.
- Pas de commit effectue.

## 15. Critique du prompt

Le prompt demandait une UI minimale acceptable ; le choix retenu evite une nouvelle page, ce qui est plus prudent pour CORE-10A.

## 16. Confirmation

Aucun commit n'a ete effectue.
