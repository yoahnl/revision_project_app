# Neralune Roadmap V4 — Product & Tech

Document canonique cree le 2026-06-25 a partir de l'audit local des deux repositories :

- Frontend Flutter : `revision_app`
- Backend NestJS : `api`

Cette roadmap ne contient aucune implementation. Elle fixe la direction produit et technique avant les prochains lots Codex.

## 1. Executive summary

La V4 existe parce que Neralune a deja beaucoup de moteurs utiles, mais les expose encore trop comme un ensemble de modes techniques. Le produit cible doit devenir un coach de revision quotidien : une recommandation claire, une session simple, des questions variees, un feedback immediat, puis une progression comprehensible.

Ce que l'on garde :

- Le socle Flutter avec Riverpod, GoRouter, Firebase Auth, Dio et le design system premium deja present.
- Les tokens visuels existants : `RevisionColors`, `RevisionSpacing`, `RevisionTypography`, `RevisionRadius`, `RevisionShadows`.
- Les composants premium reutilisables : `RevisionPageScaffold`, `RevisionGlassCard`, `RevisionGradientButton`, `RevisionBottomSheetFrame`, `RevisionMasteryRing`, `RevisionProgressLine`, `RevisionConfettiOverlay`.
- Luna et les assets existants : `NeraluneAnimatedLogo`, `neralune_cat.svg`, `neralune_cat_body.svg`, `neralune_cat_tail.svg`.
- Les moteurs backend : subjects, courses, documents, extraction, knowledge units, revision sheets, today plan, question bank, rich closed questions, open question, revision sessions, progress, deep revision, exam preparation partielle.
- Les tests existants et les fakes de repository/API deja utiles pour piloter les lots.

Ce que l'on supprime cote experience utilisateur :

- L'exposition produit de `QCM simple`, `QCM complet`, `Revision rapide`, `Revision approfondie`, `Preparation examen - QCM` comme modes principaux.
- L'onglet principal `Reviser` en tant que destination globale.
- Les pages de modes visibles comme catalogue fonctionnel.
- Les faux onglets ou entrees "bientot" qui ne servent pas une action concrete.
- Les metriques de progression trop nombreuses ou trop proches du modele backend.
- Le jargon technique dans l'interface : `quick`, `rich`, `deep`, `diagnostic`, `question bank`, `knowledge unit`.

Ce que l'on reconstruit :

- Un shell a trois onglets : `Aujourd'hui`, `Cours`, `Progres`.
- Une page `Aujourd'hui` V4 centree sur une seule session recommandee.
- Une bibliotheque `Cours` V4 avec matiere active, carte `Reviser toute la matiere`, liste compacte des cours et selecteur de matiere.
- Un detail cours transforme en parcours vertical de notions.
- Une session V4 en 5 / 15 / 30 min, composee automatiquement a partir de questions variees.
- Un feedback immediat par etape, puis un bilan oriente progression.
- Un `Sujet long` depuis un cours et une `Epreuve blanche` depuis une matiere, separes des sessions normales.
- Une facade technique qui masque les moteurs quick/rich/deep/exam derriere une orchestration unifiee.

Verdict : ce n'est pas une refonte legere. C'est une refonte moyenne a lourde, mais elle est faisable sans big bang parce que les briques metier, IA et UI existent deja en grande partie. Le vrai chantier n'est pas de tout recreer ; c'est de recabler les moteurs derriere un modele produit simple et stable.

## 2. Vision produit canonique

Promesse cible :

> Tu importes tes cours. Neralune les transforme en parcours de revision personnalises. Chaque jour, elle te dit quoi travailler, te fait pratiquer avec des questions variees, corrige tes reponses et te montre ce que tu maitrises.

Neralune V4 est un coach de revision genere depuis les propres cours de l'utilisateur. L'utilisateur ne vient pas gerer des documents, choisir des moteurs IA ou comprendre une taxonomie de modes. Il vient reviser.

La boucle principale :

1. L'utilisateur importe ses cours et sources.
2. Neralune extrait des notions.
3. Neralune construit un parcours par cours et une priorite du jour.
4. L'utilisateur lance une session courte.
5. Neralune compose automatiquement des questions variees.
6. L'utilisateur recoit un feedback immediat.
7. La maitrise evolue.
8. Neralune propose la prochaine action.

Decisions canoniques :

- Toutes les sessions normales utilisent des questions variees.
- L'utilisateur choisit un perimetre et une duree, pas un type d'exercice.
- Les types d'exercices restent des capacites techniques internes.
- La reponse courte peut apparaitre dans les sessions normales, surtout 15 et 30 min.
- La reponse longue ne doit pas etre noyee dans une session normale.
- `Sujet long` est une action avancee depuis un cours.
- `Epreuve blanche` est une action avancee depuis une matiere.
- Luna est un guide visuel discret, pas un avatar humain, pas une mascotte generique, pas un pretexte a surcharger l'interface.

## 3. Principes UX non négociables

- Un ecran = une question utilisateur = une action principale.
- Pas de dashboard de modes.
- Pas de distinction visible `QCM simple` / `QCM complet`.
- Pas d'onglet principal `Reviser`.
- Navigation principale cible : `Aujourd'hui` / `Cours` / `Progres`.
- Login et onboarding ne sont pas prioritaires, sauf raccord design minimal.
- Les gradients servent une zone importante, pas chaque carte.
- Les cartes secondaires restent sobres.
- Pas de faux onglets "bientot".
- Pas de metriques incomprehensibles.
- Pas de sur-affichage de labels.
- Pas de jargon backend dans l'UI.
- Les sources, la gestion et les actions administratives passent en menus secondaires.
- Les sessions sont immersives et masquent la bottom nav.
- Le feedback est encourageant : "pas tout a fait" plutot que culpabilisant.
- Luna reste feline, elegante, malicieuse, gracieuse et sobre.
- Le design respecte le design system existant ; ne pas inventer une nouvelle palette violette hors `RevisionColors`.
- Le desktop n'est pas une simple version etiree du mobile, surtout pour le sujet long.

## 4. Architecture produit cible

| Objet produit | Role cible | Etat dans l'existant |
| --- | --- | --- |
| Matiere | Contexte principal de revision, ex. Droit | Existe via `Subject`, priorite et weekly minutes cote onboarding |
| Cours | Unite de bibliotheque et parcours | Existe via `Course`, sources, progress, detail |
| Source | PDF ou document alimenteur | Existe via documents/course sources |
| Notion | Noeud du parcours de cours | Existe via `KnowledgeUnit`, mais le frontend n'a pas encore un vrai learning path enrichi |
| Maitrise | Etat pedagogique d'une notion ou d'un cours | Existe via `MasteryState`, `CourseProgress`, `SubjectProgress` |
| Session de revision | Experience 5/15/30 min | Existe techniquement via `RevisionSession`, mais expose encore des modes |
| Etape de session | Une question ou micro-tache avec feedback | Existe partiellement via `RevisionSessionAction`, pas encore comme step V4 feedback-first |
| Question variee | Enveloppe produit unifiee pour plusieurs renderers | Existe en morceaux : diagnostic quiz, rich closed, open question |
| Reponse courte | Exercice court dans une session normale | Existe via open question, a integrer dans le planner |
| Sujet long | Experience longue depuis un cours | Existe partiellement via deep revision course-level |
| Epreuve blanche | Experience longue depuis une matiere | A creer comme extension du sujet long |
| Correction | Feedback immediate ou evaluation finale | Existe pour quiz, rich closed, open question/deep, mais non unifie |
| Plan du jour | Recommandation principale | Existe via `TodayPlan`, a simplifier pour la carte V4 |
| Progression | Vue lisible des acquis et priorites | Existe via subject/course progress, manque vue V4 orientee utilisateur |

## 5. État actuel réel du frontend

Audit frontend realise sur `revision_app`.

Stack et dependances confirmees :

- Flutter.
- `flutter_riverpod`.
- `go_router`.
- `dio`.
- `firebase_core` / `firebase_auth`.
- `flutter_svg`.
- `file_picker`.
- `genui`.
- `shared_preferences`.
- Tests avec `flutter_test`, `mocktail`, `marionette_flutter`, `marionette_mcp`.

Fichiers/routes cles :

- `lib/app/router/app_router.dart` : `GoRouter`, `StatefulShellRoute.indexedStack`, routes cours, progress, today, activities, revision sessions, rich closed, result.
- `lib/app/router/app_routes.dart` : chemins applicatifs, dont course, rich revision, deep revision, exam preparation, revision session V2.
- `lib/presentation/shell/revision_home_shell.dart` : shell responsive mobile/desktop avec bottom nav et rail.
- `lib/presentation/widgets/revision_navigation.dart` : bottom nav et rail visuels.
- `lib/presentation/pages/auth/sign_in_page.dart` : login deja premium avec Luna et boutons Google/Apple.
- `lib/presentation/pages/onboarding/onboarding_page.dart` : onboarding deja sur le kit premium.
- `lib/presentation/pages/today/today_page.dart` : page today legacy, encore sur `RevisionPage`, `RevisionPanel`, `AppColors`.
- `lib/features/courses/presentation/courses_home_page.dart` : accueil cours/matiere deja proche d'une bibliotheque vivante.
- `lib/features/courses/presentation/course_detail_page.dart` : detail cours avec action principale, stats, progress, historique, modes.
- `lib/features/courses/presentation/subject_progress_page.dart` : progression matiere deja basee sur `SubjectProgress`.
- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart` : session quick immersive, progression, choix, brouillon, submit final.
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart` : resultat avec score, notions, corrections, confetti.
- `lib/features/courses/presentation/course_deep_revision_page.dart` : base pour sujet long cours.
- `lib/features/courses/presentation/course_exam_preparation_page.dart` : base preparation examen QCM.

Composants existants reutilisables :

- `RevisionPageScaffold` pour layout premium.
- `RevisionGlassCard` pour surfaces glass.
- `RevisionGradientButton` pour CTA principal.
- `RevisionIconTile`, `RevisionHeaderActionPill`, `RevisionActionListTile`.
- `RevisionSubjectSwitcher` pour selecteur matiere.
- `RevisionBottomSheetFrame` pour bottom sheets.
- `RevisionSegmentedControl` pour choix courts.
- `RevisionProgressLine`, `RevisionMasteryRing`, `RevisionStatTriplet`.
- `RevisionCourseCard`, `RevisionModeCard`.
- `RevisionConfettiOverlay`.
- `RevisionLoadingState`, `RevisionEmptyState`, `RevisionErrorState`, `RevisionProcessingState`.
- `NeraluneAnimatedLogo`.

Design system existant :

- `RevisionColors` contient la palette dark premium : ink, glass, borders, text, blue, violet, pink, green, mint, amber, coral, red.
- `revisionSubjectVisualThemeFor` mappe les matieres vers accents et icones.
- Le design system V4 doit rester dans cette palette et eviter une nouvelle identite.

Pages legacy ou visibles a recadrer :

- `TodayPage` utilise encore l'ancien systeme visuel.
- Le shell expose actuellement quatre destinations : Accueil, Progres, Reviser, Profil.
- `CourseDetailPage` expose encore des modes (`Revision rapide`, `QCM complet`, `Revision approfondie`, `Preparation examen - QCM`).
- `QuickRevisionQuestionCountSheet` expose un nombre de questions, pas une duree.
- Certaines routes de mode restent utiles techniquement mais doivent devenir internes ou secondaires.

Points reutilisables :

- Les listes de cours, le selecteur matiere, la creation de matiere/cours et les bottom sheets.
- La navigation responsive.
- Le rendu de questions diagnostic/rich closed et les composants rich closed nombreux.
- Le flow de brouillon et signalement dans la session quick.
- Les resultats, corrections et confetti.
- Les providers et fakes de test.

Ecarts avec la cible :

- Today V4 doit devenir l'ecran d'ouverture prioritaire.
- Le shell doit passer a trois onglets.
- La logique duree 5/15/30 min n'est pas encore un concept produit front.
- Le detail cours n'affiche pas encore un parcours vertical de notions avec etats par notion.
- Les modes techniques restent visibles.
- Le feedback immediat par question n'est pas le coeur du flow quick actuel.
- Le sujet long existe comme base deep revision, mais pas encore comme experience desktop forte.

## 6. État actuel réel du backend

Audit backend realise sur `api`.

Stack et architecture confirmees :

- NestJS.
- Prisma.
- Firebase Auth cote API.
- Organisation par modules : `activities`, `ai`, `courses`, `documents`, `revision`, `revision-sessions`, `subjects`, `study-artifacts`, jobs.
- Use cases applicatifs nombreux, repositories et tests associes.
- Genkit / generateurs IA types pour extraction, fiches, questions, correction.

Modules cles :

- `api/src/modules/revision` : goals, today plan, mastery state, adaptive plan.
- `api/src/modules/courses` : courses, sources, progress, question bank readiness/preparation, rich revision options, deep revision options, exam preparation options.
- `api/src/modules/activities` : diagnostic quiz, open question, rich closed questions, scoring, validation, public mapping.
- `api/src/modules/revision-sessions` : start/get/complete sessions, result, history, draft answers, flagging, next action.
- `api/src/modules/documents` : document upload, course PDF, extraction, revision sheet generation.
- `api/src/modules/ai` : document knowledge extraction, revision sheet generation, question/correction generation.

Use cases et endpoints existants reutilisables :

- `GET /today` ou equivalent module revision via `GetTodayPlanUseCase`.
- `POST /revision-goals` pour objectif.
- `GET /subjects/:subjectId/courses`.
- `GET /courses/:courseId`.
- `GET /courses/:courseId/progress`.
- `GET /subjects/:subjectId/progress`.
- `GET /courses/:courseId/question-bank/readiness`.
- `POST /courses/:courseId/question-bank/prepare`.
- `POST /courses/:courseId/revision-sessions/quick`.
- `GET /courses/:courseId/revision-sessions/resumable`.
- `GET /courses/:courseId/revision-sessions/history`.
- `GET /courses/:courseId/rich-revision/options`.
- `POST /courses/:courseId/rich-revision/sessions`.
- `GET /courses/:courseId/deep-revision/options`.
- `POST /courses/:courseId/deep-revision/sessions`.
- `POST /courses/:courseId/deep-revision/sessions/:sessionId/answer`.
- `GET /courses/:courseId/exam-preparation/options`.
- `POST /courses/:courseId/exam-preparation/sessions`.
- `GET /revision-sessions/:sessionId`.
- `POST /revision-sessions/:sessionId/complete`.
- `GET /revision-sessions/:sessionId/result`.
- `PUT /revision-sessions/:sessionId/questions/:questionId/draft-answer`.
- `DELETE /revision-sessions/:sessionId/questions/:questionId/draft-answer`.
- `POST /revision-sessions/:sessionId/questions/:questionId/flag`.

Modeles Prisma existants utiles :

- `StudentProfile`, `RevisionGoal`, `Subject`, `Course`, `Document`, `KnowledgeUnit`, `KnowledgeUnitSource`.
- `QuestionBankItem`, `QuestionBankItemSource`, `QuestionBankItemVisual`.
- `MasteryState`.
- `ActivitySession`, `Question`, `ActivityResult`, rich closed result models.
- `RevisionSession`, `RevisionSessionAction`, `RevisionQuestionDraftAnswer`.

Progression existante :

- `MasteryState` stocke `score` et `lastPracticedAt` par `studentId` / `knowledgeUnitId`.
- `CourseProgress` expose coverage, mastery, estimatedGlobalMastery, counts, sources, state.
- `SubjectProgress` expose counts, courses et estimatedGlobalMastery.
- L'etat par notion existe cote data, mais n'est pas encore expose en learning path V4.

IA et generation existantes :

- Extraction de knowledge units depuis documents.
- Revision sheets.
- Diagnostic quiz.
- Open question / correction.
- Rich closed questions : choix, vrai/faux, matching, ordering, timelines, sliders, cause/consequence, error detection, diagram labeling, calculation.
- Deep revision et exam preparation partielle.

Points a remplacer ou recadrer :

- `questionCount` est un parametre technique central ; la V4 veut `durationMinutes`.
- Quick/rich/deep/exam sont des modes techniques ; la V4 veut un planner de session variee.
- Le today plan choisit des actions (`diagnostic_quiz`, `rich_closed_exercise`, `open_question`, `revision_session`) ; la V4 veut une recommandation utilisateur unique.
- Exam preparation actuelle est QCM-only et ne couvre pas l'epreuve blanche cible.
- La correction longue et le barème de sujet long ne sont pas encore un modele robuste.

Ecarts avec la cible :

- Pas d'endpoint `learning-path` dedie.
- Pas d'endpoint `study-sessions` V4.
- Pas de modele `StudySessionStep` explicite avec answer/feedback immediat.
- Pas de modele long-form complet : draft, rubric, evaluation, source references, result.
- Pas de planner duree/perimetre qui compose plusieurs types de questions.
- Pas de cout IA encadre pour sujet long / epreuve blanche.

## 7. Gap analysis

| Besoin cible | Existe deja ? | Ou | Manque exact | Complexite | Priorite |
| --- | --- | --- | --- | --- | --- |
| Aujourd'hui V4 | Partiel | `TodayPlan`, `TodayPage` | Refaire UI, selection d'une action principale, wording coach, objectif semaine | M | P0 |
| Cours V4 | Partiel fort | `CoursesHomePage`, `RevisionSubjectSwitcher` | Carte matiere entiere, suppression impression dashboard, wording V4 | M | P0 |
| Selecteur matiere | Oui | `_SubjectPickerSheet`, `RevisionBottomSheetFrame` | Polish, actions plus sobres, ajout matiere V4 | S | P0 |
| Parcours de notions | Partiel | `KnowledgeUnit`, deep/rich scopeOptions | Endpoint learning path avec etat par notion, UI verticale | L | P0 |
| Session 5/15/30 min | Non comme produit | `QuickRevisionQuestionCountSheet`, quick API | Remplacer questionCount visible par duration/perimeter, planner backend | L | P0 |
| Questions variees systematiques | Partiel | diagnostic, rich closed, open question | Facade unifiee et composition multi-types dans une session | L | P0 |
| Suppression quick/rich cote UX | Non | `CourseDetailPage`, routes modes | Cacher modes, garder moteurs internes, migration routes | M | P0 |
| Feedback immediat | Partiel | result/corrections, quiz flow | Answer endpoint par step, feedback avant question suivante | L | P1 |
| Bilan V4 | Partiel | `RevisionSessionResultPage` | Bilan progression-first, score secondaire, next action | M | P1 |
| Progres V4 | Partiel | `SubjectProgressPage` | Solides/a renforcer/a decouvrir, semaine, a revoir maintenant | M | P1 |
| Luna | Oui asset | `NeraluneAnimatedLogo`, sign in | Integration discrete Today/Result/Progress, motion reduced | S/M | P2 |
| Sujet long | Partiel | `CourseDeepRevisionPage` | Branding produit, desktop layout, draft, rubric, result riche | L | P1 |
| Epreuve blanche | Non/partiel | exam preparation QCM | Scope matiere, sujet transversal, correction globale | XL | P2 |
| Desktop writing experience | Faible | Flutter responsive shell | Layout trois panneaux, editor, draft, sources, timers | L | P2 |
| Legacy cleanup | Partiel | routes/app shell/modes | Deprecation UX, redirections, docs, tests regression | M | P2 |
| API cible V4 | Non | endpoints existants | Facade `/study-sessions`, `/learning-path`, long-form | L | P0 |
| Data model V4 | Partiel | RevisionSession/Action/Mastery | Enveloppe step, long-form models, mastery events si utile | L | P1 |
| Cout IA | Partiel | generators | Budgets par duree/type, quotas, fallback, telemetry | M/L | P1 |

## 8. Architecture technique cible

Frontend cible :

- Conserver Flutter, Riverpod et GoRouter.
- Conserver le shell responsive, mais ramener les destinations visibles a `Aujourd'hui`, `Cours`, `Progres`.
- Garder `Profile` et gestion compte dans un menu secondaire.
- Construire les nouvelles surfaces avec `RevisionPageScaffold` et les tokens premium existants.
- Ne pas creer un deuxieme design system.
- Creer des composants V4 orientes produit : `TodayRecommendationCard`, `DurationPickerSheet`, `LearningPathTimeline`, `StudyStepRenderer`, `ImmediateFeedbackPanel`, `ProgressSummaryBand`, `LongFormWorkspace`.
- Garder les renderers existants comme implementation interne des `StudyQuestion`.

Backend cible :

- Garder les modules existants et ajouter une facade de session V4.
- Eviter une migration big bang : `RevisionSession` et `RevisionSessionAction` peuvent porter la premiere version de `StudySession` et `StudySessionStep`.
- Introduire un planner de session qui recoit `scopeKind`, `scopeId`, `durationMinutes` et compose une sequence d'etapes.
- Les moteurs actuels restent derriere des adapters : diagnostic quiz, rich closed, open question, deep.
- Le today plan V4 doit retourner une recommandation principale prete a lancer, pas une liste d'actions techniques.

API cible :

- Stabiliser une facade produit `/study-sessions` sans supprimer immediatement les endpoints historiques.
- Ajouter `/courses/:courseId/learning-path` pour afficher le parcours de notions.
- Ajouter `/long-form-assessments` pour sujet long et epreuve blanche.
- Conserver les endpoints historiques pendant migration et result/history compatibility.

Orchestration de session :

- `StudySessionPlan` choisit le perimetre, la duree et les types d'etapes.
- `StudySessionStep` represente une question actuelle, son renderer, son etat et son feedback.
- Le client recupere une etape a la fois.
- La soumission d'une reponse retourne le feedback immediat et la prochaine etape disponible.
- La finalisation produit un bilan progression-first.

Modele de correction :

- Feedback court par step : statut, explication, source, encouragement, prochaine action.
- Resultat final : notions consolidees, notions a revoir, score secondaire, duree, recommandations.
- Long-form : evaluation structuree par rubric, points reussis, manques, erreurs de raisonnement, structure, vocabulaire, modele de reponse, sources.

Compatibilite avec l'existant :

- Les anciennes sessions restent lisibles par leurs routes historiques.
- Les nouvelles routes V4 peuvent mapper les anciens resultats vers un format result summary.
- Les moteurs quick/rich/open/deep restent testables independamment.
- Les anciens endpoints ne sont supprimes qu'apres stabilisation UI, tests et evidence packs.

Strategie sans big bang :

1. Ajouter les facades V4 sans casser les endpoints actuels.
2. Brancher le frontend V4 sur les facades quand disponibles.
3. Masquer les modes techniques cote UX.
4. Migrer les resultats/historiques vers une presentation unifiee.
5. Nettoyer les routes legacy uniquement apres verification.

## 9. API cible proposée

Les endpoints ci-dessous sont des contrats cibles. Ils ne doivent pas etre implementes en une seule fois.

### `GET /today`

Reutilise l'esprit de l'existant `GetTodayPlanUseCase`, mais retourne une recommandation principale V4.

Response exemple :

```json
{
  "generatedAt": "2026-06-25T20:00:00.000Z",
  "primaryRecommendation": {
    "id": "today-subject-1-course-1-unit-1",
    "subjectId": "subject-1",
    "subjectName": "Droit",
    "courseId": "course-1",
    "courseTitle": "Droit constitutionnel",
    "knowledgeUnitId": "unit-1",
    "knowledgeUnitTitle": "Controle de constitutionnalite",
    "durationMinutes": 8,
    "questionEstimate": 6,
    "reason": "Tu confonds encore controle a priori et QPC.",
    "masteryEstimate": 0.62,
    "cta": "Reviser maintenant"
  },
  "weeklyObjective": {
    "completedSessions": 3,
    "targetSessions": 4
  },
  "continueItem": {
    "courseId": "course-2",
    "courseTitle": "Droit administratif",
    "masteryEstimate": 0.46
  }
}
```

Reutilisable aujourd'hui :

- `TodayPlanItem` contient deja subject, knowledge unit, mastery score, estimated minutes, reason et start payload.
- Il manque le format primary/continue/weekly objectif.

### `GET /courses/:courseId/learning-path`

Nouveau contrat recommande.

Response exemple :

```json
{
  "course": {
    "id": "course-1",
    "subjectId": "subject-1",
    "title": "Droit constitutionnel"
  },
  "masteryEstimate": 0.62,
  "nodes": [
    {
      "knowledgeUnitId": "unit-constitution",
      "title": "La Constitution",
      "state": "solid",
      "mastery": 0.91,
      "lastPracticedAt": "2026-06-24T10:00:00.000Z",
      "canPractice": true,
      "canOpenSheet": true
    },
    {
      "knowledgeUnitId": "unit-qpc",
      "title": "Le controle de constitutionnalite",
      "state": "in_progress",
      "mastery": 0.62,
      "lastPracticedAt": "2026-06-20T10:00:00.000Z",
      "canPractice": true,
      "canOpenSheet": true
    }
  ],
  "advancedActions": {
    "longFormAvailable": true
  }
}
```

Reutilisable aujourd'hui :

- `KnowledgeUnit`, `MasteryState`, `CourseProgress`.
- `findReadyQuickRevisionKnowledgeUnitsForCourse` utilise deja des notions pretes pour deep/rich options.

### `POST /study-sessions`

Nouvelle facade produit.

Request exemple :

```json
{
  "scopeKind": "course",
  "scopeId": "course-1",
  "durationMinutes": 15,
  "entryPoint": "today"
}
```

Response exemple :

```json
{
  "sessionId": "session-1",
  "status": "started",
  "scope": {
    "kind": "course",
    "id": "course-1",
    "title": "Droit constitutionnel"
  },
  "durationMinutes": 15,
  "totalStepCount": 8,
  "currentStep": {
    "id": "step-1",
    "kind": "single_choice",
    "knowledgeUnitId": "unit-qpc",
    "prompt": "Quelle difference principale existe entre le controle a priori et la QPC ?",
    "choices": [
      { "id": "choice-1", "label": "Le moment auquel le controle intervient" },
      { "id": "choice-2", "label": "La juridiction qui rend la decision" }
    ],
    "sourceReference": {
      "documentId": "document-1",
      "label": "Cours PDF"
    }
  }
}
```

Mapping existant possible :

- Premiere version : creer une `RevisionSession` mode `QUICK` ou `UNKNOWN/V4` selon choix technique, avec `RevisionSessionAction`.
- Adapters internes vers diagnostic/rich/open.

### `GET /study-sessions/:sessionId`

Response exemple :

```json
{
  "sessionId": "session-1",
  "status": "started",
  "progress": {
    "current": 3,
    "total": 8
  },
  "currentStep": {
    "id": "step-3",
    "kind": "true_false_grid",
    "prompt": "Identifie les affirmations exactes.",
    "payload": {}
  }
}
```

### `POST /study-sessions/:sessionId/steps/:stepId/answer`

Request exemple :

```json
{
  "answer": {
    "selectedChoiceIds": ["choice-1"]
  }
}
```

Response exemple :

```json
{
  "feedback": {
    "status": "correct",
    "title": "Bonne reponse",
    "explanation": "Le controle a priori intervient avant la promulgation de la loi.",
    "sourceReference": {
      "documentId": "document-1",
      "excerpt": "Le controle peut intervenir avant ou apres promulgation."
    }
  },
  "next": {
    "kind": "continue",
    "nextStepId": "step-4"
  }
}
```

### `GET /study-sessions/:sessionId/result`

Response exemple :

```json
{
  "sessionId": "session-1",
  "summary": {
    "consolidatedCount": 2,
    "reviewCount": 1,
    "score": 0.85,
    "durationSeconds": 512
  },
  "knowledgeUnits": [
    {
      "knowledgeUnitId": "unit-qpc",
      "title": "Conditions de la QPC",
      "state": "to_review",
      "nextAction": "review_now"
    }
  ],
  "nextAction": {
    "label": "Revoir les conditions de la QPC",
    "courseId": "course-1",
    "knowledgeUnitId": "unit-qpc"
  }
}
```

Reutilisable aujourd'hui :

- `RevisionSessionResult`, corrections, knowledge unit result.
- `RevisionSessionResultPage` peut etre recadree sans attendre une refonte totale API.

### `POST /long-form-assessments`

Request exemple :

```json
{
  "scopeKind": "course",
  "scopeId": "course-1",
  "durationMinutes": 45,
  "kind": "long_form_subject"
}
```

Response exemple :

```json
{
  "assessmentId": "long-1",
  "kind": "long_form_subject",
  "status": "drafting",
  "prompt": {
    "title": "Le controle de constitutionnalite protege-t-il efficacement la Constitution ?",
    "instructions": "Repondez de maniere structuree.",
    "criteria": ["Problematique", "Plan", "Precision du vocabulaire", "Sources"]
  },
  "draft": {
    "content": "",
    "updatedAt": null
  }
}
```

### `GET /long-form-assessments/:assessmentId`

Retourne le sujet, le brouillon, les consignes, le temps conseille et les sources.

### `PATCH /long-form-assessments/:assessmentId/draft`

Request exemple :

```json
{
  "content": "Introduction..."
}
```

Response exemple :

```json
{
  "assessmentId": "long-1",
  "draft": {
    "content": "Introduction...",
    "wordCount": 1,
    "updatedAt": "2026-06-25T20:10:00.000Z"
  }
}
```

### `POST /long-form-assessments/:assessmentId/submit`

Lance l'evaluation IA structuree.

### `GET /long-form-assessments/:assessmentId/result`

Response exemple :

```json
{
  "assessmentId": "long-1",
  "score": 0.72,
  "rubric": [
    {
      "criterion": "Structure",
      "score": 0.8,
      "feedback": "Plan clair, transitions a renforcer."
    }
  ],
  "strengths": ["Bonne distinction entre controle a priori et QPC."],
  "missingPoints": ["Role du Conseil constitutionnel insuffisamment detaille."],
  "reasoningIssues": ["Conclusion trop generale."],
  "modelAnswer": "Une reponse solide devait montrer...",
  "sourceReferences": [
    {
      "documentId": "document-1",
      "label": "Cours de droit constitutionnel"
    }
  ],
  "remediationActions": [
    {
      "label": "Revoir la QPC",
      "knowledgeUnitId": "unit-qpc"
    }
  ]
}
```

## 10. Modèle de données cible

Les evolutions ci-dessous sont conceptuelles. Aucune migration finale ne doit etre ecrite avant validation des contrats API et des tests.

### Option recommandee : adapter l'existant d'abord

| Modele cible | Reutilisation court terme | Pourquoi |
| --- | --- | --- |
| `StudySession` | `RevisionSession` | Evite une migration precoce et garde history/result |
| `StudySessionStep` | `RevisionSessionAction` + payload enrichi | Permet une facade produit au-dessus des actions |
| `StudyQuestion` | payload public unifie depuis diagnostic/rich/open | Les renderers existent deja |
| `SourceReference` | refs documents/chunks existants | Les sources sont deja reliees aux questions |
| `MasteryEvent` | optionnel, `MasteryState` suffit au debut | Eviter un event log avant besoin analytique clair |

### `StudySession` ou adaptation de `RevisionSession`

- Justification : representer une session produit V4 en duree/perimetre sans exposer quick/rich/deep.
- Champs principaux : `id`, `studentId`, `scopeKind`, `scopeId`, `subjectId`, `courseId`, `durationMinutes`, `status`, `startedAt`, `completedAt`, `entryPoint`.
- Relations : student, subject, course optionnel, steps, result.
- Risques : duplication avec `RevisionSession`, migration des historiques.
- Alternative : ajouter metadata JSON ou colonnes prudentes a `RevisionSession` et conserver `mode` en interne.

### `StudySessionStep` ou adaptation de `RevisionSessionAction`

- Justification : une etape = une question/tache + feedback immediat.
- Champs principaux : `id`, `sessionId`, `displayOrder`, `kind`, `knowledgeUnitId`, `activitySessionId`, `questionId`, `status`, `answeredAt`, `feedbackPayload`.
- Relations : session, knowledge unit, activity session/action existante.
- Risques : coupler trop fortement tous les types de questions.
- Alternative : garder `RevisionSessionAction` et ajouter un mapper `StudyStepPresenter`.

### `StudyQuestion`

- Justification : presenter des questions variees avec une enveloppe stable cote frontend.
- Champs principaux : `kind`, `prompt`, `payload`, `answerSchema`, `sourceReferences`, `estimatedSeconds`.
- Relations : step, question bank item, source references.
- Risques : schema trop abstrait ou trop permissif.
- Alternative : type union cote API sans table Prisma dediee.

### `LongFormAssessment`

- Justification : separer sujet long/epreuve blanche des sessions normales.
- Champs principaux : `id`, `studentId`, `kind`, `scopeKind`, `scopeId`, `subjectId`, `courseId`, `durationMinutes`, `status`, `promptPayload`, `createdAt`, `submittedAt`.
- Relations : student, subject, course optionnel, draft, evaluation, source references.
- Risques : generation lente, cout IA, evaluation non fiable si sources faibles.
- Alternative : etendre deep revision course-level pour `Sujet long`, puis creer `LongFormAssessment` seulement pour `Epreuve blanche`.

### `LongFormDraft`

- Justification : sauvegarde robuste du texte long, surtout desktop.
- Champs principaux : `assessmentId`, `content`, `wordCount`, `updatedAt`.
- Relations : one-to-one avec long form assessment.
- Risques : conflits multi-device, taille texte.
- Alternative : stocker le draft dans assessment au debut, puis extraire si besoin.

### `LongFormEvaluation`

- Justification : correction detaillee et historisable.
- Champs principaux : `assessmentId`, `score`, `rubricPayload`, `strengths`, `missingPoints`, `reasoningIssues`, `modelAnswer`, `remediationActions`, `createdAt`.
- Relations : assessment, source references.
- Risques : hallucination et variabilite IA.
- Alternative : stocker une evaluation JSON bornee avant de normaliser les sous-entites.

### `Rubric`

- Justification : rendre la correction longue lisible et comparable.
- Champs principaux : `id`, `assessmentKind`, `criteria`, `version`.
- Relations : evaluations.
- Risques : sur-modelisation si les baremes changent vite.
- Alternative : versionner un JSON schema dans le code et stocker seulement `rubricVersion`.

### `SourceReference`

- Justification : sourcer feedback et corrections.
- Champs principaux : `id`, `documentId`, `chunkId`, `label`, `excerpt`, `confidence`, `targetType`, `targetId`.
- Relations : document/chunk, study step ou long form evaluation.
- Risques : citations trop longues ou references faibles.
- Alternative : references inline dans payloads de feedback au debut.

### `MasteryEvent` si necessaire

- Justification : expliquer l'evolution de maitrise et afficher "cette semaine".
- Champs principaux : `id`, `studentId`, `subjectId`, `courseId`, `knowledgeUnitId`, `sourceType`, `delta`, `scoreAfter`, `createdAt`.
- Relations : mastery state, sessions, assessments.
- Risques : volume, complexite analytique.
- Alternative : calculer "cette semaine" depuis `ActivitySession`, `RevisionSession` et `MasteryState.lastPracticedAt` tant que suffisant.

## 11. Stratégie de migration

Migration sans big bang :

1. Documenter les contrats V4 et garder les endpoints actuels.
2. Creer le shell V4 et masquer l'onglet `Reviser`, sans supprimer les routes.
3. Refaire `Aujourd'hui` en utilisant les donnees `TodayPlan` existantes.
4. Refaire `Cours` autour de `coursesProvider`, `activeSubjectProvider`, `subjectProgressProvider`.
5. Ajouter `learning-path` ou adapter temporairement les `scopeOptions` deep/rich pour afficher les notions.
6. Creer `DurationPickerSheet` qui mappe temporairement 5/15/30 min vers un nombre de questions.
7. Introduire backend planner V4 pour remplacer le mapping temporaire.
8. Brancher les renderers existants derriere `StudyQuestion`.
9. Ajouter feedback immediat sur une premiere famille de questions.
10. Etendre aux rich closed puis open question.
11. Migrer le resultat vers bilan V4.
12. Transformer deep revision en `Sujet long`.
13. Creer `Epreuve blanche` matiere.
14. Nettoyer les pages/modes visibles seulement apres tests de regression.

Regles de compatibilite :

- Aucun resultat historique ne doit devenir inaccessible.
- Aucun endpoint historique ne doit etre supprime avant qu'une route V4 le remplace.
- Toute route legacy masquee doit rester testee tant que des sessions existantes l'utilisent.
- Les nouveaux endpoints peuvent coexister avec les anciens pendant plusieurs phases.

## 12. Roadmap par phases

### Phase 0 — Roadmap, contrats produit et inventaire vérité

- Objectif : valider ce document comme source canonique V4.
- Valeur utilisateur : eviter de relancer des lots contradictoires.
- Perimetre : documentation, contrats, decisions, risques.
- Non-objectifs : aucun code, aucune migration, aucun changement UI.
- Backend : audit modules, endpoints, modeles.
- Frontend : audit routes, composants, pages.
- IA/Genkit : audit generateurs et limites.
- Prisma/data : audit schemas, sans migration.
- Tests : aucune execution requise hors verification documentaire.
- Criteres d'acceptation : roadmap creee, structure complete, gaps explicites.
- Risques : document trop theorique ou trop large.
- Fichiers probables : `revision_app/docs/roadmap/v4/NERALUNE_PRODUCT_TECH_ROADMAP_V4.md`.
- Evidence : diff documentation, liste des commandes de lecture.

### Phase 1 — Shell V4 et navigation simplifiée

- Objectif : passer la navigation visible a `Aujourd'hui`, `Cours`, `Progres`.
- Valeur utilisateur : l'app devient comprehensible en deux secondes.
- Perimetre : shell, labels, destinations, acces profil secondaire.
- Non-objectifs : refonte Today, nouveaux endpoints.
- Backend : aucun changement attendu.
- Frontend : `RevisionHomeShell`, `app_router.dart`, `app_routes.dart`, `revision_navigation.dart`.
- IA/Genkit : aucun.
- Prisma/data : aucun.
- Tests : router tests, widget shell, responsive mobile/desktop.
- Criteres d'acceptation : trois onglets visibles ; pas d'onglet `Reviser` ; profil accessible sans destination principale.
- Risques : casser les deep links legacy.
- Fichiers probables : `lib/presentation/shell/revision_home_shell.dart`, `lib/app/router/app_router.dart`, tests router.
- Evidence : captures mobile/desktop, test navigation.

### Phase 2 — Aujourd’hui V4

- Objectif : creer l'ecran d'ouverture avec une carte principale.
- Valeur utilisateur : savoir quoi travailler, combien de temps et pourquoi.
- Perimetre : UI Today, CTA, objectif semaine discret, continuer.
- Non-objectifs : nouveau planner backend complet.
- Backend : adapter si necessaire `GET /today` pour champs V4 manquants.
- Frontend : remplacer l'ancien kit dans `TodayPage` par le design system premium.
- IA/Genkit : aucun ou seulement wording reason existant.
- Prisma/data : pas de migration ; utiliser `RevisionGoal`, `TodayPlan`, history existante.
- Tests : `today_page_test`, `today_notifier`, controller/repository si schema change.
- Criteres d'acceptation : une action principale, no dashboard, empty/error/loading couverts.
- Risques : weekly objective indisponible sans calcul nouveau.
- Fichiers probables : `lib/presentation/pages/today/today_page.dart`, `lib/features/today/domain/today_plan.dart`, `api/src/modules/revision`.
- Evidence : captures, tests, contrat today documente.

### Phase 3 — Cours V4 et sélecteur matière

- Objectif : transformer l'accueil cours en bibliotheque vivante.
- Valeur utilisateur : choisir une matiere, reviser toute la matiere, ouvrir un cours.
- Perimetre : selecteur matiere, carte matiere entiere, liste compacte, ajout matiere.
- Non-objectifs : learning path detaille.
- Backend : verifier `listCourses` et `subjectProgress`.
- Frontend : `CoursesHomePage`, `RevisionSubjectSwitcher`, subject picker.
- IA/Genkit : aucun.
- Prisma/data : aucun.
- Tests : courses page, subject picker, empty/error/loading.
- Criteres d'acceptation : pas de gestionnaire de fichiers en premier plan ; sources en secondaire.
- Risques : le statut cours peut manquer de precision sans learning path.
- Fichiers probables : `lib/features/courses/presentation/courses_home_page.dart`, providers courses/subjects.
- Evidence : captures avec 0/1/n cours, tests.

### Phase 4 — Learning path du cours

- Objectif : afficher un parcours vertical de notions.
- Valeur utilisateur : comprendre ou il en est dans un cours.
- Perimetre : endpoint/path model, timeline UI, etats solide/en progres/a renforcer/non travaille.
- Non-objectifs : feedback immediat session.
- Backend : ajouter ou adapter `GET /courses/:courseId/learning-path`.
- Frontend : composant `LearningPathTimeline`, detail cours simplifie.
- IA/Genkit : aucun nouveau generateur.
- Prisma/data : utiliser `KnowledgeUnit`, `MasteryState`, source readiness.
- Tests : use case learning path, repository, course detail widget.
- Criteres d'acceptation : chaque notion affiche titre, etat, action comprendre/travailler ; sources en menu.
- Risques : etats pedagogiques mal calibres.
- Fichiers probables : `course_detail_page.dart`, `course_models.dart`, `http_courses_repository.dart`, `courses.controller.ts`, `course-progress.use-case.ts`.
- Evidence : contrat API, fixtures, captures, tests.

### Phase 5 — Study Session V4

- Objectif : creer l'experience 5/15/30 min avec perimetre cours/matiere.
- Valeur utilisateur : reviser sans choisir un mode technique.
- Perimetre : bottom sheet duree/perimetre, facade session, planner multi-types.
- Non-objectifs : sujet long, epreuve blanche.
- Backend : `POST /study-sessions`, planner, adapters vers moteurs existants.
- Frontend : `DurationPickerSheet`, route session V4, renderer step.
- IA/Genkit : budget par duree, selection de question types.
- Prisma/data : adapter `RevisionSession`/`RevisionSessionAction` ou ajouter metadata.
- Tests : planner unit, session controller, widget duration/session.
- Criteres d'acceptation : aucune mention QCM simple/complet ; session variee ; resume possible.
- Risques : composition multi-moteur complexe, cout IA, latence.
- Fichiers probables : courses/revision-sessions modules API, `quick_revision_quiz_flow.dart`, new V4 session widgets.
- Evidence : traces de session, tests, captures.

### Phase 6 — Feedback immédiat et bilan V4

- Objectif : repondre puis recevoir feedback avant de continuer.
- Valeur utilisateur : apprendre au moment de l'erreur.
- Perimetre : answer step endpoint, panel feedback, result progression-first.
- Non-objectifs : refonte complete de tous les types de questions en une fois.
- Backend : `POST /study-sessions/:sessionId/steps/:stepId/answer`, feedback normalise.
- Frontend : `ImmediateFeedbackPanel`, update result page.
- IA/Genkit : feedback court source, templates.
- Prisma/data : stocker feedback payload si necessaire.
- Tests : answer endpoint, scorer, widget feedback, result page.
- Criteres d'acceptation : correct/pas tout a fait, explication, source eventuelle, continuer.
- Risques : feedback lent si IA synchrone.
- Fichiers probables : revision-sessions API/use cases, activities scorers, session page/result page.
- Evidence : tests par type de question, captures feedback.

### Phase 7 — Progrès V4

- Objectif : simplifier la progression en signaux actionnables.
- Valeur utilisateur : savoir ce qui est solide, a renforcer, a decouvrir.
- Perimetre : resume matiere, semaine, par cours, a revoir maintenant.
- Non-objectifs : analytics avancees.
- Backend : enrichir subject progress ou ajouter endpoint summary.
- Frontend : `SubjectProgressPage` V4.
- IA/Genkit : aucun.
- Prisma/data : potentiellement `MasteryEvent`, sinon calcul depuis existant.
- Tests : progress use case, widget, states.
- Criteres d'acceptation : moins de metriques, plus de priorites.
- Risques : "cette semaine" fragile sans event log.
- Fichiers probables : `subject_progress_page.dart`, `course-progress.use-case.ts`, Prisma si event.
- Evidence : captures, tests, decisions sur event log.

### Phase 8 — Sujet long cours

- Objectif : transformer deep revision en experience sujet long depuis un cours.
- Valeur utilisateur : s'entrainer a une vraie reponse d'examen.
- Perimetre : sujet, redaction longue, draft, correction structuree, desktop.
- Non-objectifs : epreuve blanche matiere.
- Backend : long-form course scope ou extension deep revision.
- Frontend : workspace responsive, draft save, result detaille.
- IA/Genkit : generateur sujet, evaluateur rubric, source grounding.
- Prisma/data : `LongFormAssessment`, `LongFormDraft`, `LongFormEvaluation` ou extension.
- Tests : generation/evaluation contracts, draft save, desktop widget.
- Criteres d'acceptation : action avancee, pas melangee aux sessions normales.
- Risques : correction IA imprecise, cout, UX mobile/desktop.
- Fichiers probables : course deep revision files, revision-sessions, AI generators, new long-form files.
- Evidence : sample correction, captures desktop/mobile.

### Phase 9 — Épreuve blanche matière

- Objectif : creer une epreuve transversale depuis une matiere.
- Valeur utilisateur : verifier sa capacite globale avant examen.
- Perimetre : scope matiere, sujet transversal, duree 30/45/60, correction globale, historique.
- Non-objectifs : remplacer les sessions normales.
- Backend : long-form subject scope, selection multi-cours, rubric.
- Frontend : entry matiere/progress, workspace, history.
- IA/Genkit : sujet transversal source-grounded, evaluation.
- Prisma/data : long-form models, source references.
- Tests : use cases multi-cours, result/history, source insuffisante.
- Criteres d'acceptation : separee, prestigieuse, desktop forte.
- Risques : sources insuffisantes, hallucinations, temps generation.
- Fichiers probables : subjects/courses/revision-sessions/ai modules, progress page.
- Evidence : fixtures multi-cours, tests, captures.

### Phase 10 — Luna / identité / polish

- Objectif : integrer Luna avec grace et sobriete.
- Valeur utilisateur : sentir une presence de coach sans perdre le serieux.
- Perimetre : Today, result, progress, empty states, animations reduced motion.
- Non-objectifs : mascotte partout ou rebranding complet.
- Backend : aucun.
- Frontend : `NeraluneAnimatedLogo`, assets, motion/accessibility.
- IA/Genkit : aucun.
- Prisma/data : aucun.
- Tests : widget, accessibility, disable animations.
- Criteres d'acceptation : Luna aide les moments importants, ne surcharge pas.
- Risques : cartoonisation, galaxie kitsch.
- Fichiers probables : brand widgets, pages V4.
- Evidence : captures, reduced-motion verification.

### Phase 11 — Cleanup technique et hardening

- Objectif : isoler/supprimer legacy visible et renforcer tests/build.
- Valeur utilisateur : experience stable, coherente, sans routes mortes.
- Perimetre : routes obsoletes, wording, design system, docs, regression.
- Non-objectifs : supprimer les moteurs backend encore utilises.
- Backend : deprecations documentees, compat endpoints.
- Frontend : routes legacy masquees, UI old kit retiree ou isolee.
- IA/Genkit : budgets et fallbacks documentes.
- Prisma/data : migrations seulement si contrats V4 valides.
- Tests : full targeted suite, builds, manual happy path.
- Criteres d'acceptation : pas de jargon, pas de route morte exposee, evidence packs complets.
- Risques : nettoyage trop tot.
- Fichiers probables : router, old pages, docs, tests.
- Evidence : test report, build report, route audit.

## 13. Backlog détaillé

| ID | Titre | Type | Priorite | Description | Dependances | Criteres d'acceptation | Fichiers probables | Tests attendus |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| V4-DOC-01 | Valider roadmap V4 | Docs | P0 | Faire approuver ce document comme source canonique | Aucune | Decisions et risques acceptes | `docs/roadmap/v4` | Relecture |
| V4-UX-01 | Contract UX non negociable | UX | P0 | Extraire les principes V4 en checklist de lot | V4-DOC-01 | Checklist referencee par lots | docs roadmap | Relecture |
| V4-FE-01 | Shell trois onglets | Frontend | P0 | Remplacer nav visible par Aujourd'hui/Cours/Progres | V4-DOC-01 | Plus d'onglet Reviser visible | shell/router/nav | Router/widget |
| V4-FE-02 | Profil en menu secondaire | Frontend | P1 | Deplacer Profil hors tab principal | V4-FE-01 | Profil accessible sans tab | shell/router | Router/widget |
| V4-FE-03 | Today sur design premium | Frontend | P0 | Migrer TodayPage vers `RevisionPageScaffold` | V4-FE-01 | Ancien kit absent de Today | today page | Widget |
| V4-BE-01 | Today primary recommendation | Backend | P0 | Adapter today response vers recommandation principale | V4-FE-03 | primaryRecommendation disponible | revision module | Controller/use case |
| V4-FE-04 | Today recommendation card | Frontend | P0 | Carte "Ta session du jour" | V4-BE-01 | Quoi/duree/pourquoi/CTA | today page/widgets | Widget |
| V4-FE-05 | Today weekly objective | Frontend | P1 | Afficher objectif semaine discret | V4-BE-01 | Empty fallback si indispo | today page | Widget |
| V4-BE-02 | Weekly objective data | Backend | P1 | Calculer progression semaine sans mock | V4-BE-01 | completed/target fiable | revision/session modules | Unit |
| V4-FE-06 | Continue item | Frontend | P1 | Afficher continuation eventuelle | V4-BE-01 | Clic ouvre cours/session | today/router | Widget/router |
| V4-FE-07 | Cours V4 header | Frontend | P0 | Header bibliotheque vivante + matiere active | V4-FE-01 | Pas de dashboard | courses page | Widget |
| V4-FE-08 | Carte reviser matiere | Frontend | P0 | Ajouter "Reviser toute la matiere" | V4-FE-07 | CTA ouvre duree/perimetre | courses page | Widget |
| V4-FE-09 | Liste compacte cours | Frontend | P0 | Lignes tactiles avec progression | V4-FE-07 | Liste lisible et compacte | courses page/components | Widget |
| V4-FE-10 | Selecteur matiere V4 | Frontend | P0 | Bottom sheet simple avec coche | V4-FE-07 | Matiere active selectionnee | courses page | Widget |
| V4-BE-03 | Learning path use case | Backend | P0 | Produire notions + etats | V4-DOC-01 | Nodes solid/in_progress/reinforce/unseen | courses module | Unit |
| V4-PRISMA-01 | Learning path data decision | Prisma | P0 | Decider si `MasteryState` suffit | V4-BE-03 | Pas de migration prematuree | schema/docs | Relecture |
| V4-BE-04 | Learning path endpoint | Backend | P0 | `GET /courses/:courseId/learning-path` | V4-BE-03 | Contract teste | courses.controller | Controller |
| V4-FE-11 | LearningPathTimeline | Frontend | P0 | Timeline verticale de notions | V4-BE-04 | Etats visibles | course detail widgets | Widget |
| V4-FE-12 | Detail cours V4 | Frontend | P0 | Recomposer detail autour du parcours | V4-FE-11 | Modes techniques secondaires | course_detail_page | Widget |
| V4-FE-13 | Actions notion | Frontend | P1 | Comprendre / Travailler cette notion | V4-FE-11 | Actions claires | course detail/router | Widget/router |
| V4-FE-14 | Sources en menu | Frontend | P1 | Deplacer Sources/Gerer hors surface principale | V4-FE-12 | Moins de bruit | course detail sheets | Widget |
| V4-FE-15 | DurationPickerSheet | Frontend | P0 | 5/15/30 + perimetre cours/matiere | V4-FE-08 | Aucun questionCount visible | new widget | Widget |
| V4-BE-05 | Session planner contract | Backend | P0 | Definir planner duration/scope | V4-FE-15 | Contract stable | revision-sessions docs/use case | Unit |
| V4-BE-06 | Study session facade | Backend | P0 | `POST /study-sessions` | V4-BE-05 | Session demarre par duree | new/revision session controller | Controller |
| V4-BE-07 | Study step presenter | Backend | P0 | Mapper diagnostic/rich/open vers StudyQuestion | V4-BE-06 | Union stable | activities/revision sessions | Unit |
| V4-FE-16 | Study session route | Frontend | P0 | Route immersive V4 | V4-BE-06 | Pas de bottom nav | router/session page | Router/widget |
| V4-FE-17 | StudyStepRenderer | Frontend | P0 | Renderer enveloppe StudyQuestion | V4-BE-07 | Au moins choix simple/multiple | session widgets | Widget |
| V4-IA-01 | Question mix policy | IA | P0 | Regles de composition par duree | V4-BE-05 | Budget et types explicites | AI/activity docs/code | Unit |
| V4-BE-08 | Step answer endpoint | Backend | P1 | `POST /study-sessions/:id/steps/:stepId/answer` | V4-BE-07 | Retourne feedback | revision sessions | Controller/unit |
| V4-FE-18 | Immediate feedback panel | Frontend | P1 | Afficher feedback avant continuer | V4-BE-08 | Correct/pas tout a fait/source | session widgets | Widget |
| V4-BE-09 | Result V4 mapper | Backend | P1 | Result progression-first | V4-BE-08 | Consolidated/review/nextAction | revision sessions | Unit |
| V4-FE-19 | Result V4 UI | Frontend | P1 | Bilan score secondaire | V4-BE-09 | Notions/actions visibles | result page | Widget |
| V4-BE-10 | Subject progress V4 | Backend | P1 | Solides/a renforcer/a decouvrir | V4-BE-03 | Summary fiable | courses progress | Unit |
| V4-FE-20 | Progress V4 summary | Frontend | P1 | Vue simple progression | V4-BE-10 | 3 categories + cours | subject_progress_page | Widget |
| V4-BE-11 | Cette semaine | Backend | P1 | Calcul hebdo ou decision MasteryEvent | V4-BE-10 | Non mocke | progress/session modules | Unit |
| V4-PRISMA-02 | MasteryEvent decision | Prisma | P1 | Decider event log ou calcul existant | V4-BE-11 | Decision documentee | schema/docs | Relecture |
| V4-FE-21 | Luna Today | Frontend | P2 | Presence discrete sur Today | V4-FE-04 | Non envahissante | brand/today | Widget |
| V4-FE-22 | Luna Result | Frontend | P2 | Celebration sobre | V4-FE-19 | Reduced motion respecte | result/brand | Widget |
| V4-BE-12 | Long form contract | Backend | P1 | Contrat Sujet long | V4-DOC-01 | Payload prompt/draft/result | long-form docs/use case | Unit |
| V4-PRISMA-03 | Long form models design | Prisma | P1 | Design sans migration finale prematuree | V4-BE-12 | Champs/relations valides | schema draft/docs | Relecture |
| V4-IA-02 | Long form prompt generator | IA | P1 | Sujet source-grounded cours | V4-BE-12 | Sujet cite sources | AI module | Unit/golden |
| V4-FE-23 | Long form workspace mobile | Frontend | P1 | Sujet + champ long + submit | V4-BE-12 | Mobile utilisable | new page | Widget |
| V4-FE-24 | Long form workspace desktop | Frontend | P1 | Trois panneaux desktop | V4-FE-23 | Large layout teste | new page | Widget responsive |
| V4-BE-13 | Long form draft | Backend | P1 | Sauvegarder brouillon | V4-BE-12 | PATCH draft fiable | long-form controller | Controller |
| V4-IA-03 | Long form evaluator | IA | P1 | Correction rubric/source/model answer | V4-IA-02 | Evaluation bornee | AI module | Unit/golden |
| V4-FE-25 | Long form result | Frontend | P1 | Correction detaillee lisible | V4-IA-03 | Rubric/actions/sources | result page | Widget |
| V4-BE-14 | Epreuve blanche scope matiere | Backend | P2 | Sujet transversal matiere | V4-BE-12 | Multi-cours possible | long-form/courses | Unit |
| V4-FE-26 | Epreuve blanche entry | Frontend | P2 | Action matiere avancee | V4-BE-14 | Separee des sessions | courses/progress | Widget |
| V4-QA-01 | Accessibility suite | QA | P1 | Text scaling, semantics, reduced motion | V4-FE-16 | Scenarios documentes | tests | Widget/manual |
| V4-QA-02 | Regression legacy sessions | QA | P1 | Sessions anciennes lisibles | V4-BE-09 | Historiques ok | router/result/API | Integration/manual |
| V4-DOC-02 | Evidence pack template | Docs | P1 | Standardiser evidence de chaque lot | V4-DOC-01 | Template reutilisable | docs roadmap v4 | Relecture |
| V4-CLEAN-01 | Route legacy audit | Frontend | P2 | Lister routes a masquer/garder | V4-FE-01 | Aucun deep link critique casse | router docs/tests | Router |
| V4-CLEAN-02 | Design system consolidation | Frontend | P2 | Retirer ancien kit des surfaces V4 | V4-FE-03 | Pas de double UI visible | presentation widgets/pages | Widget |
| V4-CLEAN-03 | API deprecation plan | Backend | P2 | Plan deprecation endpoints historiques | V4-BE-06 | Aucun endpoint supprime sans remplaçant | API docs | Relecture |

## 14. Décisions produit à valider

- Nom final : `Sujet long` pour cours et `Epreuve blanche` pour matiere semble coherent, mais doit etre valide par usage.
- Profil : sortir `Profil` de la bottom nav est juste pour la cible, mais il faut choisir entre menu Luna, top-right icon ou settings.
- Seuil d'apparition du sujet long : probablement seulement quand un cours a au moins une source prete et plusieurs notions fiables.
- Support du sujet long sans source suffisante : a refuser ou a afficher comme indisponible, pour eviter hallucination.
- Desktop editor : commencer simple, pas un editeur avance type Notion tant que correction/draft ne sont pas solides.
- Routes legacy : les conserver temporairement pour deep links et historique.
- Sessions existantes : compatibilite obligatoire via result/history.
- Duree 5/15/30 : faut-il mapper temporairement a questionCount ou attendre le planner backend ? Recommandation : mapping temporaire seulement en Phase 5 si clairement documente.
- Luna : definir les moments ou elle apparait ; ne pas l'utiliser comme decoration globale.
- `Aujourd'hui` : une seule carte principale ou une carte + continuation ; recommandation : carte principale + continuation tres discrete.

## 15. Risques majeurs

| Risque | Impact | Mitigation |
| --- | --- | --- |
| Big bang frontend | Regression forte, routes cassees | Phases shell/today/cours separees, routes legacy conservees |
| Dette des anciennes routes | Confusion dev et produit | Audit route legacy, deprecation plan |
| Double design system | UI incoherente | Utiliser `Revision*` premium, migrer Today en priorite |
| Confusion quick/rich/deep/exam dans le code | Roadmap contradictoire | Facade `StudySession`, adapters internes |
| Explosion du cout IA | Sessions lentes/chères | Budget par duree/type, cache question bank, generation asynchrone |
| Generation trop lente | Mauvaise experience session | Preparer questions, fallback sur questions pretes |
| Correction longue imprecise | Perte confiance | Rubric bornee, source references, refus si sources insuffisantes |
| Hallucination | Risque pedagogique | Grounding obligatoire, snippets/source refs, tests golden |
| Surcharge de Luna | Produit moins serieux | Moments limites, reduced motion, revue design |
| UX desktop negligee | Sujet long rate | Phase dediee desktop workspace |
| Migration Prisma prematuree | Dette inutile | Adapter `RevisionSession` d'abord, modeles long-form apres contrat |
| Duree 5/15/30 trompeuse | Promesse fausse | Afficher duree estimee et calibrer planner |
| Progression incomprehensible | Perte valeur | Trois categories max + a revoir maintenant |
| Tests insuffisants | Regressions silencieuses | Definition of done avec tests ciblés et evidence pack |

Points du prompt a contester ou nuancer :

- "Toutes les sessions doivent utiliser des questions variees" est bon en cible, mais il ne faut pas forcer tous les types des la premiere implementation. Il faut commencer par une enveloppe stable et quelques renderers.
- La duree 5/15/30 peut etre une promesse fragile tant que le backend raisonne en `questionCount`.
- L'epreuve blanche matiere est un vrai nouveau produit, pas un simple polish de l'exam preparation QCM.
- Luna doit rester secondaire ; si on la priorise avant Today/session/progress, elle risque de masquer la confusion produit au lieu de la resoudre.

## 16. Stratégie de test

Backend :

- Unit tests pour planners et mappers : duration -> plan, scope -> knowledge units, question mix policy.
- Use case tests pour today V4, learning path, study session start, answer step, result V4.
- Controller tests pour nouveaux endpoints.
- Repository/Prisma tests si nouveaux modeles ou nouvelles queries.
- Tests de non-regression sur quick/rich/deep/exam historiques.
- Tests de validation : durees autorisees, scopes invalides, sources insuffisantes.
- Tests IA/golden pour long-form generation/evaluation avec schemas bornes.

Frontend :

- Widget tests pour shell trois onglets.
- Widget tests Today V4 : loading/error/empty/data.
- Widget tests Cours V4 et selecteur matiere.
- Widget tests learning path avec chaque etat.
- Widget tests duration picker.
- Widget tests session immersive et feedback.
- Widget tests result V4.
- Widget tests progress V4.
- Tests responsive desktop pour long-form workspace.
- Tests text scaling sur cards, nav, duration picker, feedback.
- Tests accessibilite : semantics, focus, reduced motion.

Validation manuelle :

- Happy path : login existant -> create subject/course/source -> Today -> session -> feedback -> result -> progress.
- Legacy path : ouvrir un resultat quick/rich/deep/exam existant.
- Empty states : aucune matiere, matiere sans cours, cours sans source, source en traitement, source failed.
- Desktop : sujet long avec trois panneaux.
- Mobile : sujet long simple sans debordement.

Build :

- `flutter test` cible ou suite pertinente.
- `flutter analyze`.
- `npm test` ou tests ciblés backend.
- `npm run lint` si configure.
- Build verifie ou impossibilite documentee.

## 17. Définition de done globale

Une phase est terminee seulement si :

- Les tests ciblés existent.
- Les tests passent ou les echecs sont documentes avec cause et suite.
- Le build/analyze est verifie ou l'impossibilite est expliquee.
- Les etats loading, error et empty sont couverts.
- Aucune donnee mock ne remplace des donnees reelles sans mention explicite.
- Aucune route morte n'est exposee dans l'UX principale.
- Aucun jargon technique n'apparait dans l'UI utilisateur.
- La decision produit du lot est documentee.
- Les screenshots ou evidence packs sont produits quand le lot touche l'UI.
- Les endpoints historiques restent compatibles ou leur deprecation est explicitement documentee.
- Les nouveaux contrats API sont testes au niveau controller/use case.
- Les surfaces mobile et desktop sont verifiees quand le lot est responsive.

## 18. Ordre recommandé des premiers lots Codex

1. `V4-00 — Evidence et contrats` : valider cette roadmap, extraire une checklist d'execution et un template evidence pack.
2. `V4-01 — Shell trois onglets` : navigation `Aujourd'hui / Cours / Progres`, profil secondaire, routes legacy conservees.
3. `V4-02 — Aujourd'hui V4 frontend-first` : refaire `TodayPage` avec donnees existantes, sans planner nouveau.
4. `V4-03 — Today backend enrichment` : ajouter les champs manquants pour primary recommendation / weekly objective / continue.
5. `V4-04 — Cours V4 et selecteur matiere` : bibliotheque vivante, carte `Reviser toute la matiere`, liste compacte.
6. `V4-05 — Learning path contract` : endpoint et modeles de parcours de notions.
7. `V4-06 — Detail cours V4` : timeline verticale, actions notion, sources en menu.
8. `V4-07 — Duration picker V4` : bottom sheet 5/15/30 et perimetre, mapping temporaire documente si planner pas pret.

Ces premiers lots evitent de commencer par le sujet long ou l'epreuve blanche. La priorite est de rendre la boucle quotidienne comprehensible.

## 19. Notes de compatibilité avec l’existant

Sessions deja creees :

- Conserver `RevisionSessionPage` et `RevisionSessionResultPage` pour les sessions historiques tant que les resultats V4 ne couvrent pas tous les modes.
- Ajouter des redirections seulement apres tests de lecture des anciens resultats.

Resultats existants :

- Mapper les resultats quick/exam/rich/deep vers une presentation V4 quand possible.
- Garder les result pages specifiques si certaines corrections ne rentrent pas encore dans le format unifie.

Historiques existants :

- Ne pas supprimer les history endpoints course-level.
- Les afficher dans un wording utilisateur : `Sessions terminees`, `Sujets longs`, `Epreuves blanches`.

Question bank existante :

- Continuer a l'utiliser comme source principale de questions fermees.
- Ne pas exposer `question bank` dans l'UI.
- Encapsuler readiness/preparation derriere "questions pretes" ou "preparation en cours".

Rich closed exercises existants :

- Les garder comme renderers internes pour questions variees.
- Ne plus vendre `QCM complet` comme mode principal.

Deep revision existante :

- La repositionner progressivement en `Sujet long`.
- Ne pas la melanger avec les sessions 5/15/30.

Exam preparation existante :

- La marquer techniquement comme QCM-only tant que l'epreuve blanche n'existe pas.
- Ne pas pretendre que l'epreuve blanche est prete.

Routes et deep links :

- Les routes legacy restent accessibles mais disparaissent de la navigation principale.
- Toute suppression future exige un lot de cleanup avec evidence.

## 20. Conclusion

Verdict : la V4 est une refonte moyenne a lourde, pas un simple reskin. Elle reste realiste parce que les fondations existent : Flutter/Riverpod/GoRouter, design system premium, Luna, sources/cours/notions, today plan, progression, question bank, renderers riches, open question, deep revision, exam preparation et resultats.

Ce qui est deja acquis :

- La base technique mobile/backend est solide.
- Les moteurs pedagogiques existent en morceaux.
- Le design system cible est deja partiellement la.
- Les assets de Luna existent.
- Les tests et fakes donnent une bonne base d'execution.

Le vrai chantier :

- Transformer une taxonomie de modes techniques en une boucle produit simple.
- Passer de `questionCount` visible a `durationMinutes` utilisateur.
- Construire un learning path par notion.
- Orchestrer des questions variees dans une session unique.
- Ajouter feedback immediat.
- Faire du sujet long et de l'epreuve blanche de vraies experiences, pas des noms poses sur l'existant.

Pourquoi cette direction est meilleure :

- Elle reduit la charge cognitive.
- Elle met la prochaine action au centre.
- Elle valorise les cours de l'utilisateur plutot que les fonctionnalites internes.
- Elle rend la progression lisible.
- Elle permet de garder les moteurs actuels sans les exposer.
- Elle cree une identite premium sobre, avec Luna comme presence discrete et non comme artifice.

La recommandation finale est de commencer par la boucle quotidienne : shell, Today, Cours, learning path, puis session V4. Le sujet long et l'epreuve blanche doivent venir apres, quand le modele de session, de correction et de progression est stabilise.
