# Roadmap technique — MVP intégré réel

Date de durcissement : 18 juin 2026
Frontend : `/Users/karim/Project/app-révision/revision_app`
Backend : `/Users/karim/Project/app-révision/api`
Nature du livrable : documentation de planification uniquement, sans implémentation applicative.

## 1. Résumé exécutif

### Constat

L'application a deux réalités.

La couche réelle existe déjà pour l'authentification, les matières, les documents, l'upload PDF, le processing, les knowledge units, les fiches document-level, les activités, les rich closed exercises, Today, les mastery states et une première version de revision sessions.

La nouvelle expérience Duolingo-like Flutter est encore une démonstration locale. Elle a la bonne direction visuelle, mais elle consomme des fixtures sous `lib/features/mvp` via `MvpStudyController.instance`. Les cours, sources, questions, résultats, streak, gems et progressions visibles ne sont pas encore des données métier réelles.

### Décision

Le MVP réel ne doit pas essayer de livrer toute la V1 rêvée. Il doit d'abord rendre réel le coeur de la promesse :

1. utilisateur authentifié ;
2. matières réelles ;
3. cours réels ;
4. sources PDF réelles ;
5. upload PDF réel ;
6. processing réel ;
7. fiche réelle minimale ;
8. révision rapide réelle ;
9. résultat réel ;
10. progression réelle minimale ;
11. aucune fixture métier dans le parcours production.

Tout le reste passe en MVP+.

### Arbitrages structurants

- Modèle MVP Core : `Course` + `Document.courseId`, pas `CourseSource`.
- Révision MVP Core : uniquement `quick`, une action, cinq questions fermées ou rich closed court.
- Fiche MVP Core : fiche de la source principale, avec le libellé explicite `Fiche basée sur la source principale`.
- Session MVP Core : endpoint `POST /revision-sessions/:sessionId/advance` qui vérifie un résultat persisté avant de terminer l'action.
- Progression MVP Core : séparer `coverage`, `mastery` et `estimatedGlobalMastery`.
- Gamification : streak, gems, badges et récompenses restent hors MVP Core.
- Mocks/fixtures : autorisés seulement en tests, previews ou développement local isolé ; aucun mode démo produit à maintenir.

### Nombre de lots recommandé

MVP Core : 7 lots, `CORE-00` à `CORE-06`.
MVP+ : 4 lots, `PLUS-01` à `PLUS-04`.

Ce découpage remplace l'ancien plan `INT-00` à `INT-10`, trop proche d'une V1 complète.

## 2. Sources inspectées

### Frontend

- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/core/routing/route_paths.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/features/mvp/application/mvp_study_controller.dart`
- `lib/features/mvp/domain/mvp_study_models.dart`
- `lib/features/mvp/presentation/mvp_home_page.dart`
- `lib/features/mvp/presentation/mvp_course_detail_page.dart`
- `lib/features/mvp/presentation/mvp_course_sheet_page.dart`
- `lib/features/mvp/presentation/mvp_revisions_page.dart`
- `lib/features/mvp/presentation/mvp_revision_session_page.dart`
- `lib/features/mvp/presentation/mvp_session_result_page.dart`
- `lib/features/mvp/presentation/mvp_progress_page.dart`
- `lib/features/mvp/presentation/mvp_sources_page.dart`
- `lib/features/mvp/presentation/mvp_page_helpers.dart`
- `lib/presentation/design_system/components/revision_mvp_components.dart`
- `lib/features/subjects/data/http_subjects_repository.dart`
- `lib/features/documents/data/documents_api.dart`
- `lib/features/activities/data/http_activities_api.dart`
- `lib/features/revision_sessions/data/http_revision_sessions_api.dart`
- `lib/features/revision_sessions/data/revision_sessions_api.dart`
- `lib/features/revision_sessions/application/revision_session_controller.dart`
- `lib/features/revision_sessions/domain/revision_session.dart`
- `lib/features/today/data/http_today_repository.dart`
- `docs/MVP_DUOLINGO_LIKE_PLAN.md`
- `docs/MVP_DUOLINGO_LIKE_IMPLEMENTATION_REPORT.md`

### Backend

- `prisma/schema.prisma`
- `src/modules/subjects/interfaces/subjects.controller.ts`
- `src/modules/documents/interfaces/documents.controller.ts`
- `src/modules/documents/application/upload-course-pdf.use-case.ts`
- `src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `src/modules/study-artifacts/interfaces/study-artifacts.controller.ts`
- `src/modules/study-artifacts/application/get-revision-sheet.use-case.ts`
- `src/modules/activities/interfaces/activities.controller.ts`
- `src/modules/activities/application/submit-activity-result.use-case.ts`
- `src/modules/activities/application/submit-open-answer.use-case.ts`
- `src/modules/activities/application/rich-closed-questions/submit-rich-closed-exercise.use-case.ts`
- `src/modules/revision/interfaces/today.controller.ts`
- `src/modules/revision/application/get-today-plan.use-case.ts`
- `src/modules/revision-sessions/interfaces/revision-sessions.controller.ts`
- `src/modules/revision-sessions/application/start-revision-session.use-case.ts`
- `src/modules/revision-sessions/application/request-next-revision-session-action.use-case.ts`
- `src/modules/revision-sessions/infrastructure/prisma-revision-sessions.repository.ts`
- `test/critical-paths.e2e-spec.ts`

## 3. Audit réel condensé

### Frontend

| Zone | Constat | Décision MVP Core |
|---|---|---|
| Accueil | `MvpHomePage` lit des fixtures | Rebrancher sur `subjects` + `courses` réels |
| Cours | `MvpCourse` contient titre, progression, sources, couleur, icône | Remplacer par DTO `CourseListItem` sans `Color` ni `IconData` métier |
| Détail cours | `courseOrFallback` masque les ids invalides | Remplacer par loading/error/not-found |
| Sources | `MvpSourceFile` est local | Brancher sur `Document` attaché au cours |
| Fiche | Texte issu de fixtures | Lire la `RevisionSheet` de la source principale |
| Session | `mvpSessionQuestions` globales | Lire une vraie `RevisionSession` et une vraie activité |
| Résultat | `78% / 4/5 bonnes` en dur | Lire un résultat backend calculé |
| Progrès | Moyenne locale de fixtures | Lire `CourseProgress` / `SubjectProgress` |
| Streak/gems | `12`, `870`, `7 jours` en dur | Masquer en mode réel Core |
| Upload | Bouton `+` avec snackbar | Brancher sur upload PDF réel |
| Tests | Tests MVP in-memory utiles | Ajouter tests de cutover réel |

### Backend

| Zone | Existant | Manque MVP Core |
|---|---|---|
| Auth | `StudentProfile` + bootstrap | Suffisant |
| Matières | `Subject` CRUD minimal | Suffisant avec read models |
| Cours | Aucun `Course` Prisma | Créer `Course` |
| Document | `Document` par matière, sans `courseId` | Ajouter attachement à un cours |
| Upload | `POST /documents/course-pdf` | Adapter vers cours |
| Processing | BullMQ + extraction + KU | Réutiliser |
| Fiche | `RevisionSheet` par document | Exposer la fiche de la source principale |
| Activités | QCM, open, rich closed | Réutiliser |
| Mastery | `MasteryState` | Ajouter read models progress |
| RevisionSession | start/get/next-action | Ajouter `courseId`, `mode`, `advance`, `result` |
| Rich closed session | Action possible avec `activitySessionId = null` | Corrélation obligatoire avant `advance` |

## 4. MVP Core vs MVP+

### MVP Core

Le MVP Core doit rendre démontrable le parcours réel minimal :

1. L'utilisateur voit ses matières réelles.
2. Il crée ou ouvre un cours réel.
3. Il ajoute un PDF de cours.
4. Le backend traite le PDF.
5. La fiche de révision de la source principale devient consultable.
6. Le mode `Révision rapide` démarre une vraie session.
7. L'utilisateur répond à cinq questions fermées ou rich closed court.
8. Le résultat est persisté.
9. La session avance puis se termine côté backend.
10. La progression est recalculée depuis les knowledge units et mastery states.
11. Les fixtures métier ne sont plus accessibles en production.

### MVP+

MVP+ contient ce qui enrichit l'expérience sans être nécessaire pour prouver le coeur réel :

- révision approfondie ;
- préparation examen ;
- questions ouvertes dans les sessions de cours ;
- fiches multi-source plus riches ;
- composition ou génération course-level IA ;
- rôles de source `NOTES`, `EXAM`, `CORRECTION` ;
- streak, gems, badges et récompenses ;
- nettoyage complet des routes legacy ;
- polish e2e avancé.

## 5. Décision modèle Course / Source

### Option A — `Document.courseId`

Un document appartient à un seul cours.

Avantages :

- modèle plus simple ;
- moins de jointures ;
- upload plus direct ;
- ownership plus facile à vérifier ;
- backfill plus lisible ;
- très adapté au MVP Core.

Inconvénient :

- partager exactement le même PDF entre plusieurs cours demandera duplication ou refactor.

### Option B — `CourseSource`

Un cours possède plusieurs sources via une table de liaison.

Avantages :

- plus flexible ;
- partage potentiel d'un document ;
- support naturel d'une source principale et de rôles de source ;
- meilleur pour une V1 multi-source.

Inconvénients :

- plus complexe ;
- risque de rattacher un document d'une autre matière si les use cases sont mal gardés ;
- contrainte `isPrimary` délicate à imposer proprement avec Prisma ;
- suppression et backfill plus subtils ;
- pas nécessaire tant que le produit n'a pas prouvé le besoin de partage.

### Choix retenu pour le MVP Core

Décision : utiliser `Document.courseId` pour le MVP Core.

Justification : aucun besoin réel de partager le même PDF entre plusieurs cours n'est démontré. Le modèle le plus simple donne un chemin d'intégration plus court et réduit le risque d'incohérence.

`CourseSource` reste une option MVP+ si le produit confirme le besoin de sources partagées, de rôles multiples ou de composition multi-source avancée.

### Modèle Prisma minimal recommandé

Proposition documentaire, à implémenter dans un futur lot backend :

```prisma
model Course {
  id               String   @id @default(cuid())
  studentId        String
  subjectId        String
  title            String
  description      String?
  chapterLabel     String?
  estimatedMinutes Int?
  displayOrder     Int      @default(0)
  createdAt        DateTime @default(now())
  updatedAt        DateTime @updatedAt

  student StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  documents Document[]
  revisionSessions RevisionSession[]

  @@index([studentId])
  @@index([subjectId, studentId])
  @@index([subjectId, displayOrder])
  @@unique([id, studentId])
}

model Document {
  id          String @id @default(cuid())
  studentId   String
  subjectId   String
  courseId    String?
  kind        DocumentKind
  fileName    String
  storagePath String
  mimeType    String
  status      DocumentStatus @default(UPLOADED)
  errorCode   String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  course Course? @relation(fields: [courseId], references: [id], onDelete: Restrict)

  @@index([studentId])
  @@index([subjectId])
  @@index([courseId])
  @@unique([id, subjectId])
}

model RevisionSession {
  id              String @id @default(cuid())
  studentId       String
  subjectId       String
  courseId        String?
  documentId      String?
  knowledgeUnitId String?
  mode            RevisionSessionMode @default(QUICK)
  status          RevisionSessionStatus @default(STARTED)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  completedAt     DateTime?

  course Course? @relation(fields: [courseId], references: [id], onDelete: NoAction)

  @@index([studentId])
  @@index([subjectId])
  @@index([courseId])
  @@index([documentId])
}

enum RevisionSessionMode {
  QUICK
  DEEP
  EXAM
}
```

### Contraintes à éviter

- Ne pas ajouter `@@unique([subjectId, title])` : deux cours peuvent légitimement avoir le même titre.
- Ne pas ajouter `@@unique([courseId, displayOrder])` : `displayOrder` avec défaut `0` provoquerait vite des collisions.
- Ne pas mettre `iconKey` et `colorKey` dans le backend MVP Core : ce sont des détails de présentation. Le front peut résoudre une apparence par matière/cours via mapping local.

### Ownership

Règle backend : toutes les requêtes `Course` filtrent par `studentId`.
Règle upload : l'endpoint d'upload sous un cours dérive `studentId` et `subjectId` depuis le cours, pas depuis le body client.
Règle d'attachement : un document ne peut recevoir un `courseId` que si le cours appartient au même étudiant et à la même matière.

La relation Prisma simple `Document.courseId -> Course.id` ne suffit pas à elle seule à prouver la cohérence `subjectId`. Cette cohérence doit donc être gardée dans le use case d'attachement/upload et testée en cross-subject/cross-student.

### Suppression

MVP Core :

- supprimer un document doit le retirer du cours et déclencher les nettoyages déjà prévus par le module documents ;
- supprimer un cours contenant des documents doit être refusé avec `409`, sauf si une action explicite `deleteWithSources` est conçue plus tard ;
- ne jamais supprimer implicitement les fichiers d'un utilisateur juste parce qu'un cours est supprimé.

### Backfill

Backfill recommandé :

1. sélectionner les `Document` existants de type `COURSE_PDF` ;
2. créer un `Course` par document, avec un titre dérivé du nom de fichier ;
3. réutiliser `studentId` et `subjectId` du document ;
4. remplir `Document.courseId` ;
5. être idempotent ;
6. proposer un dry-run ;
7. ne supprimer aucun document.

## 6. API Course MVP Core

Endpoints cibles :

| Endpoint | But | MVP Core |
|---|---|---|
| `GET /subjects/:subjectId/courses` | Lister les cours d'une matière | Oui |
| `POST /subjects/:subjectId/courses` | Créer un cours vide | Oui |
| `GET /courses/:courseId` | Détail cours + sources + progression courte | Oui |
| `PATCH /courses/:courseId` | Renommer ou réordonner | Optionnel Core |
| `DELETE /courses/:courseId` | Supprimer si aucune source attachée | Optionnel Core |
| `POST /courses/:courseId/source/course-pdf` | Upload PDF attaché au cours | Oui |
| `GET /courses/:courseId/sheet` | Fiche source principale | Oui |
| `POST /revision-sessions` | Démarrer une session quick sur cours | Oui |
| `POST /revision-sessions/:sessionId/advance` | Valider l'action courante depuis un résultat persisté | Oui |
| `GET /revision-sessions/:sessionId/result` | Résultat calculé | Oui |
| `GET /courses/:courseId/progress` | Progression du cours | Oui |
| `GET /subjects/:subjectId/progress` | Progression de la matière | Oui |

Endpoints repoussés :

- `CourseSource` CRUD ;
- upload de rôles `NOTES`, `EXAM`, `CORRECTION` ;
- fiche `mode=complete|exam` multi-source ;
- session deep/exam ;
- endpoint de gamification.

## 7. Architecture Flutter cible

### Règle de cutover

Les pages MVP peuvent garder leur structure visuelle, mais ne doivent plus dépendre de `MvpStudyController.instance` en production.

### Providers cibles

- `activeSubjectProvider`
- `coursesProvider(subjectId)`
- `courseDetailProvider(courseId)`
- `courseProgressProvider(courseId)`
- `subjectProgressProvider(subjectId)`
- `courseSheetProvider(courseId)`
- `courseSourcesProvider(courseId)`
- `realRevisionSessionProvider(sessionId)`
- `revisionSessionResultProvider(sessionId)`

### Repositories

`CoursesRepository` minimal :

- `listCourses(subjectId)`
- `createCourse(subjectId, input)`
- `getCourse(courseId)`
- `uploadCoursePdf(courseId, file)`
- `getCourseSheet(courseId)`
- `getCourseProgress(courseId)`

`RevisionSessionsRepository` minimal :

- `startQuickCourseSession(courseId)`
- `getRevisionSession(sessionId)`
- `advanceRevisionSession(sessionId)`
- `getRevisionSessionResult(sessionId)`

### Fixtures et mocks

Décision produit : ne pas créer ni maintenir de mode démo comme fonctionnalité de l'app.

Les fixtures peuvent rester utiles pour tests, previews ou développement local isolé, mais elles ne doivent pas devenir une branche fonctionnelle du parcours.

En production, un repository HTTP doit être obligatoire.
Aucun fallback silencieux vers `mvpSubjects` ne doit survivre dans le parcours réel.

## 8. Upload source réel

Parcours MVP Core :

```text
Course detail
-> Ajouter une source
-> file picker PDF
-> POST /courses/:courseId/source/course-pdf
-> Document(courseId, subjectId, studentId)
-> job processing
-> polling status
-> source READY ou FAILED
```

Règles :

- Le client n'envoie pas `studentId`.
- Le client n'envoie pas `subjectId` pour l'upload sous cours.
- Le backend récupère le cours, vérifie l'ownership, puis crée le document.
- Si le processing échoue, le cours reste visible avec source `FAILED`.
- L'UI affiche `Analyse du PDF en cours` pour `PROCESSING`.

## 9. Fiche de révision

### Options

| Option | Coût | Complexité | Qualité | Risque hallucination | Décision |
|---|---:|---:|---:|---:|---|
| Fiche de la source principale | Faible | Faible | Correcte si source bien choisie | Faible | MVP Core |
| Composition de fiches document-level | Moyen | Moyen | Meilleure couverture | Faible à moyen | MVP+ |
| Nouvel artifact course-level IA | Élevé | Élevée | Potentiellement meilleure | Moyen | MVP+ |

### Choix MVP Core

Utiliser la `RevisionSheet` du document principal du cours.

Libellé UI obligatoire :

```text
Fiche basée sur la source principale
```

Si plusieurs sources prêtes existent, l'UI peut afficher :

```text
Les autres sources seront intégrées dans une version ultérieure.
```

Ce choix évite de créer un agrégateur multi-source fragile avant d'avoir un vrai usage observé.

## 10. Modes de révision

### Règle MVP Core

Seul `Révision rapide` est réellement disponible.

### Quick

- Inclus MVP Core.
- Une seule action.
- Cinq questions fermées ou un rich closed court.
- Feedback immédiat.
- Score final simple.
- Session terminée après `advance`.

### Deep

- MVP+.
- Une action fermée + une question ouverte.
- Feedback détaillé.
- Plusieurs actions.

### Exam

- MVP+.
- `complexityProfile=exam`.
- Nombre de questions plus élevé.
- Correction plus stricte.
- Ne doit être activé que si des sources d'examen existent.

### UI Core

Décision : garder les modes `Révision approfondie` et `Préparation examen` visibles mais désactivés avec badge `Bientôt`.

Justification : l'UI montre la promesse produit sans mentir sur la disponibilité réelle.

## 11. Cycle de vie RevisionSession

### Problème actuel

L'API expose `POST /revision-sessions`, `GET /revision-sessions/:sessionId` et `POST /revision-sessions/:sessionId/next-action`.
Le frontend expose seulement start/get.
Le backend peut créer des actions rich closed avec `activitySessionId = null`.

Un endpoint du type `POST /revision-sessions/:sessionId/actions/:actionId/complete` donnerait trop de pouvoir au frontend : il pourrait déclarer une action terminée sans résultat persisté.

### Décision

Créer plutôt :

```http
POST /revision-sessions/:sessionId/advance
```

### Cycle cible

```text
START
-> session STARTED
-> action READY
-> activité créée ou liée
-> réponse soumise
-> résultat persisté
-> advance
-> backend vérifie le résultat
-> action COMPLETED
-> session COMPLETED pour quick
-> result
```

### Comportement `advance`

1. Charger la session avec ownership.
2. Charger l'action courante `READY`.
3. Vérifier que l'action est bien la prochaine action attendue.
4. Vérifier que l'activité liée a un résultat persisté.
5. Refuser si `activitySessionId` est absent pour une action qui exige une activité.
6. Marquer l'action `COMPLETED`.
7. Pour `QUICK`, marquer la session `COMPLETED`.
8. Pour MVP+, créer ou retourner l'action suivante.
9. Retourner la session mise à jour.

### Cas rich closed

Le cas `activitySessionId = null` doit être résolu avant `advance`.

Deux options acceptables :

1. créer l'activité rich closed dès `POST /revision-sessions` pour le mode quick ;
2. ajouter `POST /revision-sessions/:sessionId/actions/:actionId/rich-closed/start`, qui crée l'exercice puis met à jour `RevisionSessionAction.activitySessionId`.

Choix recommandé MVP Core : option 1 pour quick si le coût de génération est maîtrisé et mockable en test. Sinon option 2, mais `advance` doit rester strict et refuser une action sans activité liée.

### Erreurs attendues

- `404` session introuvable ;
- `404` action introuvable ;
- `409` session déjà terminée ;
- `409` aucune action courante ;
- `409` activité non soumise ;
- `409` action non corrélée à une activité ;
- `422` aucune source prête ;
- `422` aucune knowledge unit exploitable.

### Reprise de session

`GET /revision-sessions/:sessionId` doit retourner :

- la session ;
- l'action `READY` courante si elle existe ;
- l'historique des actions ;
- l'`activitySessionId` si l'activité a déjà été créée ;
- le statut `COMPLETED` si la session est terminée.

Le front ne reconstruit pas l'état depuis ses routes locales.

## 12. Résultat de session

Contrat minimal :

```text
RevisionSessionResult
- sessionId
- courseId
- mode
- score
- correctAnswers
- totalQuestions
- completedActions
- weakKnowledgeUnits
- masteredKnowledgeUnits
- completedAt
```

Le résultat est calculé côté backend depuis les résultats d'activité persistés.
Le front n'a pas le droit de recalculer le score.

Pour MVP Core, un read model calculé à la demande suffit. Un snapshot persisté peut attendre MVP+.

## 13. Progression réelle

### Formules

```text
coverage = practicedKnowledgeUnitCount / knowledgeUnitCount
mastery = average(MasteryState.score for practiced units)
estimatedGlobalMastery = coverage * mastery
```

Définitions :

- `knowledgeUnitCount` : notions issues des documents prêts du cours.
- `practicedKnowledgeUnitCount` : notions ayant au moins un `MasteryState`.
- `mastery` : moyenne uniquement des notions pratiquées.
- `estimatedGlobalMastery` : score prudent qui pénalise l'absence de pratique sans faire croire que les notions non vues sont vraiment ratées.

### UI cards

Sur les cards cours :

- sans source : `Ajoute une source pour commencer` ;
- source en processing : `Analyse du PDF en cours` ;
- source prête sans activité : `Notions prêtes, pas encore travaillées` ;
- activité existante : afficher `estimatedGlobalMastery` avec libellé `maîtrise estimée`.

### Page Progrès

La page Progrès doit séparer :

- couverture : `X/Y notions travaillées` ;
- maîtrise : `N% sur les notions travaillées` ;
- estimation globale : `N% estimé sur tout le cours`.

Cette séparation évite l'ancien piège consistant à compter les notions jamais pratiquées comme `0` sans explication.

## 14. Rôles de source et préparation examen

MVP Core :

- une source est principalement un PDF de cours ;
- aucun champ `role` n'est requis ;
- `DocumentKind.COURSE_PDF` suffit.

MVP+ :

```text
COURSE
NOTES
EXAM
CORRECTION
```

Le mode `Préparation examen` ne doit pas prétendre être disponible si aucune source `EXAM` ou `CORRECTION` n'est attachée.

## 15. Gamification et design

### Streak/gems

Décision : hors MVP Core.

Les compteurs `12`, `870` et l'anneau `7 jours` ne doivent pas apparaître en production réelle tant qu'ils ne sont pas calculés.

Options Core :

- masquer ces éléments ;
- garder les valeurs mockées uniquement dans tests/previews si nécessaire.

### Couleur et icône

`iconKey` et `colorKey` restent côté front en MVP Core.
Le backend peut exposer des clés de présentation plus tard si un besoin multi-device/personnalisation apparaît.

## 16. États UI réels requis

Chaque page branchée au réel doit gérer :

- loading ;
- empty ;
- processing ;
- failed ;
- unauthorized ;
- not-found ;
- retry ;
- disabled/bientôt pour deep/exam ;
- no source ;
- no knowledge units ;
- session already completed.

Le fallback silencieux vers le premier cours est interdit.

## 17. Tests requis

### Backend

- Course creation ownership.
- Course list par subject/student.
- Upload PDF sous cours.
- Refus upload cross-student/cross-subject.
- Refus suppression cours avec documents.
- Fiche source principale.
- Start quick session par course.
- Rich closed correlation avant `advance`.
- `advance` refuse sans résultat persisté.
- `advance` complète action et session quick.
- `GET /revision-sessions/:id/result`.
- Progress formulas : no source, processing, KU sans activity, KU avec mastery.

### Frontend

- Parsers `CourseListItem`, `CourseDetail`, `CourseProgress`, `CourseSheet`, `RevisionSessionResult`.
- Accueil sans fixtures en mode real.
- Course not-found sans fallback.
- Source upload states.
- Fiche source principale.
- Deep/exam disabled `Bientôt`.
- Quick session start/submit/advance/result.
- Progress wording no source/processing/not practiced/practiced.
- Absence de fixtures métier dans le parcours production.

### Contrats

- Tests backend/frontend sur les shapes JSON.
- Tests anti-régression sur `rich_closed`.
- Tests route aliases legacy si conservés.

## 18. Lots MVP Core

### CORE-00 — Stabilisation front et suppression des mocks production

Objectif : empêcher les fixtures de se mélanger au parcours production.

Tâches :

- supprimer la notion de mode démo produit ;
- remplacer les fallbacks silencieux par états not-found ;
- masquer streak/gems en mode real ;
- préparer interfaces repository ;
- garder le design actuel.

Done :

- aucune page production ne lit `MvpStudyController.instance`, `mvpSubjects` ou `mvpSessionQuestions` ;
- tests de routing et not-found.

### CORE-01 — Course minimal + `Document.courseId`

Objectif : ajouter la colonne vertébrale métier.

Tâches :

- migration future `Course` ;
- ajout futur `Document.courseId` ;
- relation future `RevisionSession.courseId` et `mode`;
- use cases Course ;
- backfill dry-run ;
- tests ownership.

Done :

- un document peut être rattaché à un seul cours ;
- aucun `CourseSource` n'est nécessaire en Core.

### CORE-02 — Course API + accueil/détail réels

Objectif : afficher les vrais cours dans l'UI existante.

Tâches :

- endpoints list/create/get ;
- repository HTTP Flutter ;
- providers Riverpod ;
- pages accueil/détail branchées ;
- états empty/loading/error.

Done :

- l'accueil ne consomme plus les fixtures en mode real.

### CORE-03 — Upload source réel + processing

Objectif : rattacher un PDF réel au cours.

Tâches :

- endpoint upload sous cours ;
- transaction Course -> Document -> job ;
- polling source status ;
- UI processing/failed/ready.

Done :

- un PDF ajouté depuis le détail cours devient source prête après processing.

### CORE-04 — Fiche réelle minimale

Objectif : remplacer la fiche fixture.

Tâches :

- endpoint `GET /courses/:courseId/sheet` ;
- choix de la source principale ;
- génération document-level si absente ;
- UI avec libellé source principale.

Done :

- la fiche affichée vient du backend et indique sa limite.

### CORE-05 — Révision rapide réelle + résultat réel

Objectif : rendre la session quick bout en bout réelle.

Tâches :

- `RevisionSession.mode=QUICK` ;
- start par `courseId` ;
- cinq questions fermées/rich closed court ;
- corrélation action/activité ;
- `advance` strict ;
- endpoint result ;
- UI session/résultat branchée.

Done :

- le front ne déclare pas une action terminée sans résultat persisté ;
- la session quick se termine côté backend.

### CORE-06 — Progression réelle + suppression mocks production

Objectif : terminer le cutover MVP réel.

Tâches :

- endpoints progress course/subject ;
- formules coverage/mastery/estimatedGlobalMastery ;
- page Progrès branchée ;
- suppression des valeurs `78%`, `4/5`, `12`, `870` du mode real ;
- e2e happy path.

Done :

- le parcours production complet ne dépend plus des fixtures métier.

## 19. Lots MVP+

### PLUS-01 — Révision approfondie

- Plusieurs actions.
- Question ouverte.
- Feedback détaillé.
- Progression plus fine.

### PLUS-02 — Préparation examen

- Source roles `EXAM` et `CORRECTION`.
- Rich closed exam profile.
- Résultat plus strict.
- Conditions d'activation explicites.

### PLUS-03 — Fiches multi-source / exam enrichies

- Composition multi-source.
- Éventuel artifact course-level.
- Déduplication des sections.
- Coûts Genkit contrôlés.

### PLUS-04 — Nettoyage legacy, polish et hardening final

- Migration complète des anciennes routes si nécessaire.
- Suppression ou isolation définitive de `features/mvp`.
- Performance et accessibilité.
- Tests e2e avancés.

## 20. Happy path MVP Core

| Étape | Backend | Frontend | Attendu |
|---|---|---|---|
| 1 | `/students/me` | bootstrap auth | utilisateur connu |
| 2 | `GET /subjects` | accueil | matières réelles |
| 3 | `POST /subjects/:id/courses` | création cours | cours réel |
| 4 | `POST /courses/:id/source/course-pdf` | ajout PDF | source processing |
| 5 | job processing | polling | source ready |
| 6 | `GET /courses/:id/sheet` | fiche | fiche source principale |
| 7 | `POST /revision-sessions` | lancer quick | action ready |
| 8 | activité liée | question UI | réponse possible |
| 9 | submit activité | correction | résultat persisté |
| 10 | `POST /revision-sessions/:id/advance` | continuer | session completed |
| 11 | `GET /revision-sessions/:id/result` | résultat | score réel |
| 12 | `GET /courses/:id/progress` | progrès | estimation réelle |

## 21. Definition of done MVP Core

Le MVP Core est terminé uniquement si :

- le parcours production ne lit plus les fixtures métier ;
- un cours réel peut être créé ;
- un PDF réel peut être attaché à ce cours ;
- le processing est visible et testable ;
- une fiche réelle minimale est consultable ;
- `Révision rapide` démarre une vraie session ;
- la session est avancée par le backend après résultat persisté ;
- le résultat est calculé côté backend ;
- la progression sépare coverage/mastery/estimatedGlobalMastery ;
- deep/exam ne sont pas présentés comme disponibles ;
- streak/gems ne sont pas affichés comme réels ;
- les tests critiques backend/frontend passent.

## 22. Risques

| Risque | Probabilité | Impact | Mitigation |
|---|---:|---:|---|
| `Document.courseId` trop simple pour V1 | Moyenne | Moyen | Documenter `CourseSource` comme MVP+ |
| Cross-subject attachment | Faible | Haut | Use case strict + tests |
| Session quick non corrélée à une activité | Moyenne | Haut | `advance` refuse sans résultat persisté |
| Fiche source principale trop limitée | Moyenne | Moyen | Libellé clair + multi-source MVP+ |
| Progression trompeuse | Moyenne | Haut | Afficher coverage et mastery séparément |
| Fixtures qui fuient en production | Moyenne | Haut | Repository HTTP obligatoire + tests anti-fixture |
| Suppression destructive | Faible | Haut | Refuser delete course avec documents |
| Rich closed sans mastery update | Moyenne | Moyen | Agrégat result d'abord, update mastery si nécessaire en CORE-05/06 |

## 23. Points encore incertains

- Le produit accepte-t-il qu'un document ne puisse appartenir qu'à un seul cours en MVP Core ?
- Le titre d'un cours est-il saisi manuellement ou proposé depuis le nom du PDF ?
- Le mode quick doit-il forcer rich closed uniquement ou accepter diagnostic quiz fermé ?
- Le seuil exact de mastery affiché en card doit-il être `estimatedGlobalMastery` ou un statut textuel ?
- Faut-il masquer complètement deep/exam ou les laisser visibles avec `Bientôt` ?

Décision recommandée actuelle : ne pas bloquer le MVP Core sur ces questions sauf la première, car le modèle `Document.courseId` est le choix structurant.

## 24. Validation documentaire de ce durcissement

Cette mise à jour est une modification de documentation uniquement.

Validations pertinentes :

- vérifier que `docs/MVP_REAL_INTEGRATION_ROADMAP.md` existe ;
- vérifier que `docs/MVP_REAL_INTEGRATION_DECISIONS.md` existe ;
- lancer `git diff --check`.

Ne pas lancer la suite Flutter/Node complète pour cette modification documentaire.

## 25. Recommandation finale

Premier lot conseillé : `CORE-00 — Stabilisation front et suppression des mocks production`.

Raison : avant d'ajouter `Course`, il faut empêcher le front de masquer les erreurs réelles avec des fixtures. C'est le garde-fou qui rendra les lots suivants visibles, testables et honnêtes.

Deuxième lot : `CORE-01 — Course minimal + Document.courseId`.

Ce plan privilégie un MVP réel et testable plutôt qu'une V1 complète déguisée en MVP.
