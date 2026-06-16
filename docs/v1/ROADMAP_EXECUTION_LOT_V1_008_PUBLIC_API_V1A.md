# LOT V1-008 — API publique pré-submit/post-submit V1-A

## 1. Résultat

L’API publique V1-A est exposée côté backend avec quatre routes bornées : démarrage, relecture pré-submit, soumission et relecture du résultat. Les réponses pré-submit ne contiennent pas de correction ; les corrections sont disponibles uniquement après soumission.

## 2. Sources inspectées

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.fixtures.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generation-profile.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/infrastructure/genkit-rich-closed-question.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/activities.module.ts`
- `api/src/modules/revision/domain/adaptive-plan.service.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`
- `api/src/modules/revision-sessions/**`
- `api/src/modules/ai/**`
- `api/test/critical-paths.e2e-spec.ts`
- `revision_app/docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`
- `revision_app/docs/v1/RICH_CLOSED_QUESTIONS_PRISMA_DTO_VERSIONING_AUDIT.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md`
- `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/presentation/pages/activities/activities_page.dart`
- `revision_app/lib/presentation/pages/today/today_page.dart`
- `revision_app/lib/features/today/**`
- `revision_app/lib/features/revision_sessions/**`

## 3. Préflight Git

API:
```text
/Users/karim/Project/app-révision/api
/Users/karim/Project/app-révision/api
main
## main...origin/main
0eafeb2 RAPPORT-123: Ajout des générateurs de questions fermées riches et profils associés
206905b #37-2: corrige et améliore la gestion des questions fermées enrichies
8c402a7 #37-1: ajoute gestion des questions fermées enrichies
e552c75 #36-1: ajoute tests e2e pour les chemins critiques
b1d2318 #35-1: ajoute script de démo et données de seed
```

revision_app:
```text
/Users/karim/Project/app-révision/revision_app
/Users/karim/Project/app-révision/revision_app
main
## main...origin/main
786d22b V1-006 — Ajout du rapport d'exécution du lot Génération Genkit rich closed questions V1-A et mise à jour du plan d'exécution
31cdf95 LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING - Mise à jour plan V1 et ajout rapport LOT_V1_005B (Rich Closed Contract Hardening)
75bda98 LOT_V1_002_005 - Ajout ADR, audit DTO Prisma, roadmap V1 (lots 002 à 005 : rich questions, backend, qualité pédagogique)
2667c30 LOT_038_V1 - Ajout documentation V1 (README, catalogues de questions, roadmap et exemples)
b45b6ab LOT_038_DEMO_DEPLOYMENT_RUNBOOK - Mise à jour runbooks démo et ajout rapport LOT_038
```

## 4. Périmètre réalisé

- Ajout des use cases `StartRichClosedExerciseUseCase`, `GetRichClosedExerciseUseCase`, `SubmitRichClosedExerciseUseCase` et `GetRichClosedExerciseResultUseCase`.
- Ajout des routes `POST /activities/rich-closed/start`, `GET /activities/rich-closed/:sessionId`, `POST /activities/rich-closed/:sessionId/submit`, `GET /activities/rich-closed/:sessionId/result`.
- Ajout d’une validation manuelle stricte des DTO entrants, sans dépendance nouvelle.
- Ajout d’un mapping d’erreurs 400/404/409/422 cohérent avec les routes Activities existantes.
- Ajout de tests module et e2e critiques couvrant anti-fuite, erreurs et double submit.

## 5. Architecture retenue

Le contrôleur reste mince : il valide les formes HTTP et délègue aux use cases. Le démarrage appelle le générateur rich closed V1-A existant, valide le contrat et les quality gates, puis persiste la session. La relecture pré-submit passe par le repository public. La soumission score les réponses côté application, persiste le résultat et retourne la correction post-submit.

Aucun endpoint QCM v3 ou open question n’a été modifié. L’API rich closed est isolée sous `/activities/rich-closed/*` pour éviter une ambiguïté avec les routes existantes.

## 6. Fichiers créés/modifiés/supprimés

Fichiers API modifiés :

- `api/src/modules/activities/activities.module.ts`
- `api/src/modules/activities/activities.module.spec.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/test/critical-paths.e2e-spec.ts`

Fichiers API créés :

- `api/src/modules/activities/application/rich-closed-questions/get-rich-closed-exercise-result.use-case.ts`
- `api/src/modules/activities/application/rich-closed-questions/get-rich-closed-exercise.use-case.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-errors.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-scorer.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-scorer.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/start-rich-closed-exercise.use-case.ts`
- `api/src/modules/activities/application/rich-closed-questions/start-rich-closed-exercise.use-case.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/submit-rich-closed-exercise.use-case.ts`
- `api/src/modules/activities/application/rich-closed-questions/submit-rich-closed-exercise.use-case.spec.ts`

Fichier documentation modifié :

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

Aucun fichier supprimé.

## 7. Tests ajoutés ou renforcés

- Tests use case start : mix par défaut, mix explicite, mix incohérent, notion indisponible, contexte sans source, document hors contexte.
- Tests use case get/submit/result : pré-submit sans correction, scoring, double submit, résultat absent.
- Tests module Activities : validation DTO, routes rich closed, correction seulement post-submit, 400/404/409/422.
- Tests e2e critiques : routes protégées, démarrage, relecture, soumission, résultat, anti-fuite.

## 8. Validations lancées avec résultats

- `npx prisma validate` : OK, schema Prisma valide.
- `npm run prisma:generate` : OK, Prisma Client généré.
- `npm test -- rich-closed --runInBand` : OK, 8 suites, 80 tests.
- `npm test -- activities --runInBand` : premier passage combiné interrompu par un 403 transitoire sur un test QCM existant, puis relance du fichier isolé OK et relance du pattern complet OK : 17 suites passées, 1 suite integration skip, 176 tests passés, 1 test skip.
- `npm run test:e2e -- --runInBand` : OK, 2 suites, 18 tests.
- `npm run lint:check` : OK.
- `npm run build` : OK.
- `git diff --check` depuis `api` : OK.
- `git diff --check` depuis `revision_app` : OK.

## 9. Validations non lancées avec justification

- Tests Flutter : non lancés, aucun code Flutter applicatif n’a été modifié.
- `npm run lint` : non lancé, car destructif ; `npm run lint:check` a été utilisé.
- `npm run format` : non lancé ; seul `npx prettier --write` ciblé sur les fichiers API modifiés a été utilisé pour respecter le style sans formatage global.
- `npm run test:cov` : non lancé, hors lot.
- `npx prisma db push`, `npx prisma migrate reset`, `npx prisma migrate deploy` : non lancés, interdits.
- Seed réel : non lancé.
- Provider IA réel : non appelé dans les tests.

## 10. Risques restants

- Le frontend V1-A n’existe pas encore : les endpoints sont testés côté backend mais non consommés par Flutter.
- La migration doit être appliquée plus tard sur une DB cible explicitement désignée.
- Les barèmes partiels et les retours pédagogiques avancés restent simples dans ce MVP.
- La stratégie d’URL est stable mais pourra être ajustée au moment de l’intégration Flutter si un helper de route dédié est introduit.

## 11. Recommandation prochain lot

Poursuivre avec `V1-009 — Domain models Flutter V1-A`, puis les widgets V1-A et l’intégration progressive dans Activities/Today/session.

## 12. Passes de review

- API publique : routes isolées, validation DTO stricte, mapping d’erreurs explicite.
- Anti-fuite : pré-submit sans `correct*`, `feedback`, `explanation`, `modelAnswer`, `answerText`.
- Tests : unitaires, module et e2e critiques ajoutés.
- Scope : aucun frontend, aucun Today, aucune session de révision, aucun seed modifié.
- Sécurité : pas de secret, pas de provider réel, pas de correction pré-submit.

## 13. Critique honnête du prompt initial

Le prompt était suffisamment cadré pour éviter le mélange avec Flutter ou Today. Le seul compromis est que V1-007 et V1-008 partagent des fichiers de repository, types et tests : les traiter ensemble est cohérent, mais les rapports doivent assumer cette zone commune. Le prompt demandait aussi beaucoup de validations ; elles sont utiles ici car l’ajout touche Prisma, module Nest et e2e.

## 14. Contenu complet des fichiers créés/modifiés/supprimés pour review

> Note : cette section montre l’état final partagé après V1-007 et V1-008. Les deux lots ont été réalisés dans le même passage contrôlé ; plusieurs fichiers servent donc les deux lots. Le rapport lui-même n’est pas auto-recopié dans sa propre section afin d’éviter une récursion documentaire infinie.

### api/prisma/schema.prisma

````prisma
generator client {
  provider     = "prisma-client"
  output       = "../src/generated/prisma"
  moduleFormat = "cjs"
}

datasource db {
  provider = "postgresql"
}

model StudentProfile {
  id          String   @id @default(cuid())
  firebaseUid String   @unique
  email       String?
  displayName String?
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  goals    RevisionGoal[]
  subjects Subject[]
  mastery  MasteryState[]
  sessions ActivitySession[]
  revisionSessions RevisionSession[]
  revisionSessionActions RevisionSessionAction[]
  summaries Summary[]
  revisionSheets RevisionSheet[]
  openQuestions OpenQuestion[]
  openAnswerEvaluations OpenAnswerEvaluation[]
}

model RevisionGoal {
  id            String   @id @default(cuid())
  studentId     String
  targetDate    DateTime
  weeklyMinutes Int
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt

  student StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)

  @@index([studentId, createdAt])
}

model Subject {
  id        String   @id @default(cuid())
  studentId String
  name      String
  priority  Int      @default(3)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  student        StudentProfile  @relation(fields: [studentId], references: [id], onDelete: Cascade)
  documents      Document[]
  knowledgeUnits KnowledgeUnit[]
  mastery        MasteryState[]
  sessions       ActivitySession[]
  revisionSessions RevisionSession[]
  revisionSessionActions RevisionSessionAction[]
  summaries      Summary[]
  revisionSheets RevisionSheet[]
  openQuestions  OpenQuestion[]
  openAnswerEvaluations OpenAnswerEvaluation[]

  @@index([studentId])
  @@unique([id, studentId])
}

model Document {
  id          String         @id @default(cuid())
  studentId   String
  subjectId   String
  kind        DocumentKind
  fileName    String
  storagePath String
  mimeType    String
  status      DocumentStatus @default(UPLOADED)
  errorCode   String?
  createdAt   DateTime       @default(now())
  updatedAt   DateTime       @updatedAt

  subject        Subject                 @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  chunks         DocumentChunk[]
  knowledgeUnits KnowledgeUnit[]
  jobs           DocumentProcessingJob[]
  summaries      Summary[]
  revisionSheets RevisionSheet[]
  openQuestions  OpenQuestion[]
  revisionSessions RevisionSession[]
  revisionSessionActions RevisionSessionAction[]

  @@index([studentId])
  @@index([subjectId])
  @@unique([id, subjectId])
}

model DocumentProcessingJob {
  id         String    @id @default(cuid())
  documentId String
  status     JobStatus @default(PENDING)
  attempts   Int       @default(0)
  createdAt  DateTime  @default(now())
  updatedAt  DateTime  @updatedAt

  document Document @relation(fields: [documentId], references: [id], onDelete: Cascade)
}

model KnowledgeUnit {
  id                       String                   @id @default(cuid())
  subjectId                String
  documentId               String?
  title                    String
  summary                  String
  difficulty               KnowledgeUnitDifficulty?
  displayOrder             Int?
  confidence               Float?
  extractionPromptVersion  String?
  extractionSchemaVersion  String?
  createdAt                DateTime                 @default(now())
  updatedAt                DateTime                 @updatedAt

  subject  Subject        @relation(fields: [subjectId], references: [id], onDelete: Cascade)
  document Document?      @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: NoAction)
  mastery  MasteryState[]
  questions Question[]
  sessions ActivitySession[]
  revisionSessions RevisionSession[]
  revisionSessionActions RevisionSessionAction[]
  sources  KnowledgeUnitSource[]
  openQuestions OpenQuestion[]

  @@index([subjectId])
  @@index([documentId])
  @@unique([id, subjectId])
}

model DocumentChunk {
  id         String   @id @default(cuid())
  documentId String
  subjectId  String
  index      Int
  text       String
  charStart  Int?
  charEnd    Int?
  pageNumber Int?
  createdAt  DateTime @default(now())

  document Document              @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources  KnowledgeUnitSource[]
  summarySources SummarySource[]
  revisionSheetSectionSources RevisionSheetSectionSource[]
  questionSources QuestionSource[]
  questionVisualSources QuestionVisualSource[]
  openQuestionSources OpenQuestionSource[]

  @@index([documentId])
  @@index([subjectId])
  @@unique([documentId, index])
  @@unique([id, subjectId])
}

model KnowledgeUnitSource {
  knowledgeUnitId String
  subjectId       String
  chunkId         String
  relevanceScore  Float?
  createdAt       DateTime @default(now())

  knowledgeUnit KnowledgeUnit @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk         DocumentChunk @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([knowledgeUnitId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

model Summary {
  id              String                      @id @default(cuid())
  documentId      String
  subjectId       String
  studentId       String
  status          StudyArtifactStatus
  title           String?
  content         String?
  keyPoints       Json?
  limits          String?
  createdAt       DateTime                    @default(now())
  updatedAt       DateTime                    @updatedAt
  generatedAt     DateTime
  flowName        String
  provider        String
  model           String
  promptVersion   String
  schemaVersion   String
  inputSize       Int?
  sourceStrategy  StudyArtifactSourceStrategy
  errorCode       String?

  student StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  document Document      @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources SummarySource[]

  @@index([studentId])
  @@index([subjectId])
  @@unique([documentId])
  @@unique([id, subjectId])
}

model SummarySource {
  summaryId      String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  summary Summary       @relation(fields: [summaryId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk   DocumentChunk @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([summaryId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

model RevisionSheet {
  id                  String                      @id @default(cuid())
  documentId          String
  subjectId           String
  studentId           String
  status              StudyArtifactStatus
  title               String?
  introduction        String?
  keyPoints           Json?
  commonMistakes      Json?
  mustKnow            Json?
  practiceSuggestions Json?
  createdAt           DateTime                    @default(now())
  updatedAt           DateTime                    @updatedAt
  generatedAt         DateTime
  flowName            String
  provider            String
  model               String
  promptVersion       String
  schemaVersion       String
  inputSize           Int?
  sourceStrategy      StudyArtifactSourceStrategy
  errorCode           String?

  student StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  document Document      @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sections RevisionSheetSection[]

  @@index([studentId])
  @@index([subjectId])
  @@unique([documentId])
  @@unique([id, subjectId])
}

model RevisionSheetSection {
  id              String   @id @default(cuid())
  revisionSheetId String
  subjectId       String
  displayOrder    Int
  title           String
  content         String
  createdAt       DateTime @default(now())

  revisionSheet RevisionSheet @relation(fields: [revisionSheetId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources RevisionSheetSectionSource[]

  @@index([subjectId])
  @@unique([revisionSheetId, displayOrder])
  @@unique([id, subjectId])
}

model RevisionSheetSectionSource {
  sectionId      String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  section RevisionSheetSection @relation(fields: [sectionId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk   DocumentChunk        @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([sectionId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

model MasteryState {
  studentId       String
  subjectId       String
  knowledgeUnitId String
  score           Float
  lastPracticedAt DateTime?
  updatedAt       DateTime  @updatedAt

  student       StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject       Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  knowledgeUnit KnowledgeUnit   @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([studentId, knowledgeUnitId])
  @@index([subjectId, studentId])
  @@index([knowledgeUnitId, subjectId])
}

model ActivitySession {
  id              String         @id @default(cuid())
  studentId       String
  subjectId       String
  knowledgeUnitId String
  version         Int            @default(1)
  documentId      String?
  generationFlowName      String?
  generationProvider      String?
  generationModel         String?
  generationPromptVersion String?
  generationSchemaVersion String?
  generationInputSize     Int?
  type            ActivityType
  status          ActivityStatus @default(STARTED)
  createdAt       DateTime       @default(now())
  completedAt     DateTime?

  student       StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject       Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  knowledgeUnit KnowledgeUnit  @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: Cascade)
  questions     Question[]
  result        ActivityResult?
  answers       QuestionAnswer[]
  openQuestion  OpenQuestion?
  openAnswerEvaluation OpenAnswerEvaluation?
  richClosedExercisePayload RichClosedExercisePayload?
  richClosedExerciseResult RichClosedExerciseResult?
  revisionSessionActions RevisionSessionAction[]

  @@index([studentId])
  @@index([subjectId])
  @@index([documentId])
  @@index([knowledgeUnitId])
  @@unique([id, knowledgeUnitId])
}

model Question {
  id              String @id @default(cuid())
  sessionId       String
  subjectId       String?
  documentId      String?
  knowledgeUnitId String
  prompt          String
  difficulty      KnowledgeUnitDifficulty?
  displayOrder    Int    @default(0)
  choices         Json
  selectionMode   QuestionSelectionMode @default(SINGLE)
  minSelections   Int?
  maxSelections   Int?
  correctChoiceId String?
  correctChoiceIds Json?
  explanation     String

  session       ActivitySession @relation(fields: [sessionId, knowledgeUnitId], references: [id, knowledgeUnitId], onDelete: Cascade)
  knowledgeUnit KnowledgeUnit   @relation(fields: [knowledgeUnitId], references: [id], onDelete: Cascade)
  sources       QuestionSource[]
  answers       QuestionAnswer[]
  visuals       QuestionVisual[]

  @@index([sessionId])
  @@index([subjectId])
  @@index([documentId])
  @@unique([id, subjectId])
}

model QuestionSource {
  questionId     String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  question Question @relation(fields: [questionId], references: [id], onDelete: Cascade)
  chunk    DocumentChunk @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([questionId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

model QuestionVisual {
  id           String             @id @default(cuid())
  questionId   String
  type         QuestionVisualType
  displayOrder Int                @default(0)
  payload      Json
  createdAt    DateTime           @default(now())

  question Question @relation(fields: [questionId], references: [id], onDelete: Cascade)
  sources  QuestionVisualSource[]

  @@index([questionId])
  @@unique([questionId, displayOrder])
}

model QuestionVisualSource {
  visualId       String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  visual QuestionVisual @relation(fields: [visualId], references: [id], onDelete: Cascade)
  chunk  DocumentChunk   @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([visualId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

model QuestionAnswer {
  id               String   @id @default(cuid())
  sessionId        String
  questionId       String
  selectedChoiceId String?
  isCorrect        Boolean
  createdAt        DateTime @default(now())

  session  ActivitySession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  question Question        @relation(fields: [questionId], references: [id], onDelete: Cascade)
  selectedChoices QuestionAnswerChoice[]

  @@unique([sessionId, questionId])
  @@index([questionId])
}

model QuestionAnswerChoice {
  answerId String
  choiceId String

  answer QuestionAnswer @relation(fields: [answerId], references: [id], onDelete: Cascade)

  @@id([answerId, choiceId])
}

model ActivityResult {
  id             String   @id @default(cuid())
  sessionId      String   @unique
  correctAnswers Int
  totalQuestions Int
  score          Float?
  createdAt      DateTime @default(now())

  session ActivitySession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
}

model OpenQuestion {
  id              String   @id @default(cuid())
  sessionId       String   @unique
  studentId       String
  subjectId       String
  documentId      String?
  knowledgeUnitId String
  prompt          String
  instructions    String?
  maxAnswerLength Int      @default(4000)
  version         Int      @default(1)
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  session       ActivitySession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  student       StudentProfile  @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject       Subject         @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  document      Document?       @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: NoAction)
  knowledgeUnit KnowledgeUnit   @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources       OpenQuestionSource[]
  evaluations   OpenAnswerEvaluation[]

  @@index([studentId])
  @@index([subjectId])
  @@index([documentId])
  @@index([knowledgeUnitId])
  @@unique([id, subjectId])
}

model OpenQuestionSource {
  questionId     String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  question OpenQuestion  @relation(fields: [questionId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk    DocumentChunk @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([questionId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

model OpenAnswerEvaluation {
  id                      String                     @id @default(cuid())
  sessionId               String                     @unique
  openQuestionId          String
  studentId               String
  subjectId               String
  answerText              String
  status                  OpenAnswerEvaluationStatus @default(PENDING)
  score                   Float?
  maxScore                Float?
  feedback                String?
  presentPoints           Json?
  missingPoints           Json?
  errors                  Json?
  modelAnswer             String?
  advice                  String?
  generationFlowName      String?
  generationProvider      String?
  generationModel         String?
  generationPromptVersion String?
  generationSchemaVersion String?
  generationInputSize     Int?
  errorCode               String?
  createdAt               DateTime                   @default(now())
  updatedAt               DateTime                   @updatedAt

  session      ActivitySession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  openQuestion OpenQuestion    @relation(fields: [openQuestionId, subjectId], references: [id, subjectId], onDelete: Cascade)
  student      StudentProfile  @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject      Subject         @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)

  @@index([studentId])
  @@index([subjectId])
  @@index([openQuestionId])
}

model RichClosedExercisePayload {
  id                 String   @id @default(cuid())
  activitySessionId  String   @unique
  version            String
  title              String
  subjectId          String
  documentId         String?
  knowledgeUnitId    String
  exercisePayload    Json
  generationMetadata Json?
  qualityMetrics     Json?
  createdAt          DateTime @default(now())
  updatedAt          DateTime @updatedAt

  session ActivitySession @relation(fields: [activitySessionId], references: [id], onDelete: Cascade)

  @@index([subjectId])
  @@index([documentId])
  @@index([knowledgeUnitId])
}

model RichClosedExerciseResult {
  id                String   @id @default(cuid())
  activitySessionId String   @unique
  answersPayload    Json
  correctionPayload Json
  correctAnswers    Int
  totalQuestions    Int
  score             Float
  createdAt         DateTime @default(now())

  session ActivitySession @relation(fields: [activitySessionId], references: [id], onDelete: Cascade)
}

model RevisionSession {
  id              String                @id @default(cuid())
  studentId       String
  subjectId       String
  documentId      String?
  knowledgeUnitId String?
  status          RevisionSessionStatus @default(STARTED)
  createdAt       DateTime              @default(now())
  updatedAt       DateTime              @updatedAt
  completedAt     DateTime?

  student       StudentProfile          @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject       Subject                 @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  document      Document?               @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: NoAction)
  knowledgeUnit KnowledgeUnit?          @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: NoAction)
  actions       RevisionSessionAction[]

  @@index([studentId])
  @@index([subjectId])
  @@index([documentId])
  @@index([knowledgeUnitId])
  @@unique([id, studentId])
}

model RevisionSessionAction {
  id                String                      @id @default(cuid())
  sessionId         String
  studentId         String
  subjectId         String
  kind              RevisionSessionActionKind
  status            RevisionSessionActionStatus @default(READY)
  displayOrder      Int                         @default(0)
  activitySessionId String?
  documentId        String?
  knowledgeUnitId   String?
  createdAt         DateTime                    @default(now())
  completedAt       DateTime?

  session         RevisionSession  @relation(fields: [sessionId, studentId], references: [id, studentId], onDelete: Cascade)
  student         StudentProfile   @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject         Subject          @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  activitySession ActivitySession? @relation(fields: [activitySessionId], references: [id], onDelete: NoAction)
  document        Document?        @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: NoAction)
  knowledgeUnit   KnowledgeUnit?   @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: NoAction)

  @@unique([sessionId, displayOrder])
  @@index([studentId])
  @@index([subjectId])
  @@index([activitySessionId])
  @@index([documentId])
  @@index([knowledgeUnitId])
}

enum DocumentKind {
  COURSE_PDF
  EXAM_PDF
  EXAM_IMAGE
}

enum DocumentStatus {
  UPLOADED
  PROCESSING
  READY
  FAILED
}

enum KnowledgeUnitDifficulty {
  LOW
  MEDIUM
  HIGH
}

enum StudyArtifactStatus {
  READY
  FAILED
}

enum StudyArtifactSourceStrategy {
  DOCUMENT_CHUNKS
  DOCUMENT_CHUNKS_AND_KNOWLEDGE_UNITS
}

enum JobStatus {
  PENDING
  RUNNING
  COMPLETED
  FAILED
}

enum ActivityType {
  DIAGNOSTIC_QUIZ
  OPEN_QUESTION
  RICH_CLOSED_EXERCISE
}

enum ActivityStatus {
  STARTED
  SUBMITTED
  COMPLETED
}

enum RevisionSessionStatus {
  STARTED
  COMPLETED
  ABANDONED
}

enum RevisionSessionActionKind {
  DIAGNOSTIC_QUIZ
  OPEN_QUESTION
}

enum RevisionSessionActionStatus {
  READY
  COMPLETED
  FAILED
}

enum OpenAnswerEvaluationStatus {
  PENDING
  READY
  FAILED
}

enum QuestionSelectionMode {
  SINGLE
  MULTIPLE
}

enum QuestionVisualType {
  IMAGE
  CHART
  DIAGRAM
}
````

### api/prisma/migrations/20260616160000_rich_closed_v1a_persistence/migration.sql

````sql
-- AlterEnum
ALTER TYPE "ActivityType" ADD VALUE 'RICH_CLOSED_EXERCISE';

-- CreateTable
CREATE TABLE "RichClosedExercisePayload" (
    "id" TEXT NOT NULL,
    "activitySessionId" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "documentId" TEXT,
    "knowledgeUnitId" TEXT NOT NULL,
    "exercisePayload" JSONB NOT NULL,
    "generationMetadata" JSONB,
    "qualityMetrics" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RichClosedExercisePayload_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RichClosedExerciseResult" (
    "id" TEXT NOT NULL,
    "activitySessionId" TEXT NOT NULL,
    "answersPayload" JSONB NOT NULL,
    "correctionPayload" JSONB NOT NULL,
    "correctAnswers" INTEGER NOT NULL,
    "totalQuestions" INTEGER NOT NULL,
    "score" DOUBLE PRECISION NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RichClosedExerciseResult_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "RichClosedExercisePayload_activitySessionId_key" ON "RichClosedExercisePayload"("activitySessionId");

-- CreateIndex
CREATE INDEX "RichClosedExercisePayload_subjectId_idx" ON "RichClosedExercisePayload"("subjectId");

-- CreateIndex
CREATE INDEX "RichClosedExercisePayload_documentId_idx" ON "RichClosedExercisePayload"("documentId");

-- CreateIndex
CREATE INDEX "RichClosedExercisePayload_knowledgeUnitId_idx" ON "RichClosedExercisePayload"("knowledgeUnitId");

-- CreateIndex
CREATE UNIQUE INDEX "RichClosedExerciseResult_activitySessionId_key" ON "RichClosedExerciseResult"("activitySessionId");

-- AddForeignKey
ALTER TABLE "RichClosedExercisePayload" ADD CONSTRAINT "RichClosedExercisePayload_activitySessionId_fkey" FOREIGN KEY ("activitySessionId") REFERENCES "ActivitySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RichClosedExerciseResult" ADD CONSTRAINT "RichClosedExerciseResult_activitySessionId_fkey" FOREIGN KEY ("activitySessionId") REFERENCES "ActivitySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;
````

### api/src/modules/activities/activities.module.ts

````ts
import { Module } from '@nestjs/common';
import { AiModule } from '../ai/ai.module';
import { AuthModule } from '../auth/auth.module';
import { AdaptivePlanService } from '../revision/domain/adaptive-plan.service';
import { RevisionModule } from '../revision/revision.module';
import { PrismaModule } from '../../shared/infrastructure/prisma/prisma.module';
import { ACTIVITIES_REPOSITORY } from './application/activities.repository';
import { DIAGNOSTIC_QUIZ_GENERATOR } from './application/diagnostic-quiz-generator';
import { OPEN_ANSWER_EVALUATOR } from './application/open-answer-evaluator';
import { OPEN_QUESTION_GENERATOR } from './application/open-question-generator';
import { GetRichClosedExerciseResultUseCase } from './application/rich-closed-questions/get-rich-closed-exercise-result.use-case';
import { GetRichClosedExerciseUseCase } from './application/rich-closed-questions/get-rich-closed-exercise.use-case';
import { RICH_CLOSED_QUESTION_GENERATOR } from './application/rich-closed-questions/rich-closed-question-generator';
import { StartRichClosedExerciseUseCase } from './application/rich-closed-questions/start-rich-closed-exercise.use-case';
import { SubmitRichClosedExerciseUseCase } from './application/rich-closed-questions/submit-rich-closed-exercise.use-case';
import { StartOpenQuestionActivityUseCase } from './application/start-open-question-activity.use-case';
import { StartNextActivityUseCase } from './application/start-next-activity.use-case';
import { SubmitOpenAnswerUseCase } from './application/submit-open-answer.use-case';
import { SubmitActivityResultUseCase } from './application/submit-activity-result.use-case';
import { GenkitDiagnosticQuizGenerator } from './infrastructure/genkit-diagnostic-quiz.generator';
import { GenkitOpenAnswerEvaluator } from './infrastructure/genkit-open-answer.evaluator';
import { GenkitOpenQuestionGenerator } from './infrastructure/genkit-open-question.generator';
import { GenkitRichClosedQuestionGenerator } from './infrastructure/genkit-rich-closed-question.generator';
import { PrismaActivitiesRepository } from './infrastructure/prisma-activities.repository';
import { ActivitiesController } from './interfaces/activities.controller';

@Module({
  imports: [AiModule, AuthModule, PrismaModule, RevisionModule],
  controllers: [ActivitiesController],
  providers: [
    AdaptivePlanService,
    StartNextActivityUseCase,
    StartOpenQuestionActivityUseCase,
    StartRichClosedExerciseUseCase,
    GetRichClosedExerciseUseCase,
    SubmitRichClosedExerciseUseCase,
    GetRichClosedExerciseResultUseCase,
    SubmitActivityResultUseCase,
    SubmitOpenAnswerUseCase,
    {
      provide: ACTIVITIES_REPOSITORY,
      useClass: PrismaActivitiesRepository,
    },
    {
      provide: DIAGNOSTIC_QUIZ_GENERATOR,
      useClass: GenkitDiagnosticQuizGenerator,
    },
    {
      provide: OPEN_QUESTION_GENERATOR,
      useClass: GenkitOpenQuestionGenerator,
    },
    {
      provide: OPEN_ANSWER_EVALUATOR,
      useClass: GenkitOpenAnswerEvaluator,
    },
    {
      provide: RICH_CLOSED_QUESTION_GENERATOR,
      useClass: GenkitRichClosedQuestionGenerator,
    },
  ],
  exports: [StartNextActivityUseCase, StartOpenQuestionActivityUseCase],
})
export class ActivitiesModule {}
````

### api/src/modules/activities/activities.module.spec.ts

````ts
import { INestApplication } from '@nestjs/common';
import type { ExecutionContext } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../../app.module';
import { REVISION_REPOSITORY } from '../revision/application/revision.repository';
import {
  ACTIVITIES_REPOSITORY,
  type DiagnosticQuizActivity,
  type OpenAnswerSubmissionResult,
  type OpenQuestionActivity,
} from './application/activities.repository';
import {
  DIAGNOSTIC_QUIZ_GENERATOR,
  type DiagnosticQuizGenerationInput,
  type GeneratedDiagnosticQuiz,
} from './application/diagnostic-quiz-generator';
import {
  OPEN_QUESTION_GENERATOR,
  type GeneratedOpenQuestion,
  type OpenQuestionGenerationInput,
} from './application/open-question-generator';
import {
  OPEN_ANSWER_EVALUATOR,
  type GeneratedOpenAnswerEvaluation,
  type OpenAnswerEvaluationInput,
} from './application/open-answer-evaluator';
import {
  RICH_CLOSED_QUESTION_GENERATOR,
  type RichClosedQuestionGenerationInput,
} from './application/rich-closed-questions/rich-closed-question-generator';
import { RICH_CLOSED_SOURCE_CONTEXT_EMPTY } from './application/rich-closed-questions/rich-closed-question-errors';
import { richClosedExerciseFixture } from './application/rich-closed-questions/rich-closed-question.fixtures';
import { scoreRichClosedExerciseSubmission } from './application/rich-closed-questions/rich-closed-question-scorer';
import type {
  RichClosedAnswer,
  RichClosedExercise,
  RichClosedExerciseResult,
  RichClosedPublicExerciseEnvelope,
} from './application/rich-closed-questions/rich-closed-question.types';
import { KnowledgeUnit } from '../revision/domain/knowledge-unit.entity';
import { TOKEN_VERIFIER } from '../auth/application/token-verifier';
import { FirebaseAuthGuard } from '../auth/interfaces/firebase-auth.guard';
import { PrismaService } from '../../shared/infrastructure/prisma/prisma.service';

jest.mock('firebase-admin/app', () => ({
  getApps: jest.fn(() => []),
  initializeApp: jest.fn(),
}));

jest.mock('firebase-admin/auth', () => ({
  getAuth: jest.fn(() => ({
    verifyIdToken: jest.fn(),
  })),
}));

type NextActivityResponseBody = {
  sessionId: string;
  type: string;
  title: string;
  questions: unknown[];
};

type CreateDiagnosticQuizInput = {
  studentId: string;
  subjectId: string;
  knowledgeUnitId: string;
  documentId?: string | null;
  quiz: GeneratedDiagnosticQuiz;
};

describe('ActivitiesModule', () => {
  let app: INestApplication<App>;
  let activitiesRepository: {
    findDiagnosticQuizGenerationContext: jest.Mock;
    findOpenQuestionGenerationContext: jest.Mock;
    findRichClosedGenerationContext: jest.Mock;
    createDiagnosticQuiz: jest.Mock<
      Promise<DiagnosticQuizActivity>,
      [CreateDiagnosticQuizInput]
    >;
    submitResult: jest.Mock;
    createOpenQuestionActivity: jest.Mock;
    findOpenAnswerEvaluationContext: jest.Mock;
    saveOpenAnswerEvaluation: jest.Mock;
    createRichClosedExerciseSession: jest.Mock;
    getRichClosedExerciseForStudent: jest.Mock;
    getInternalRichClosedExerciseForStudent: jest.Mock;
    saveRichClosedExerciseResult: jest.Mock;
    getRichClosedExerciseResultForStudent: jest.Mock;
  };
  let diagnosticQuizGenerator: {
    generate: jest.Mock<
      Promise<GeneratedDiagnosticQuiz>,
      [DiagnosticQuizGenerationInput]
    >;
  };
  let openQuestionGenerator: {
    generate: jest.Mock<
      Promise<GeneratedOpenQuestion>,
      [OpenQuestionGenerationInput]
    >;
  };
  let openAnswerEvaluator: {
    evaluate: jest.Mock<
      Promise<GeneratedOpenAnswerEvaluation>,
      [OpenAnswerEvaluationInput]
    >;
  };
  let richClosedGenerator: {
    generate: jest.Mock<
      Promise<RichClosedExercise>,
      [RichClosedQuestionGenerationInput]
    >;
  };
  let revisionRepository: {
    findKnowledgeUnits: jest.Mock;
    findMasteryStates: jest.Mock;
    upsertMastery: jest.Mock;
  };

  beforeEach(async () => {
    delete process.env.DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT;
    delete process.env.DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT;
    activitiesRepository = {
      findDiagnosticQuizGenerationContext: jest.fn().mockResolvedValue(null),
      findOpenQuestionGenerationContext: jest.fn().mockResolvedValue(null),
      findRichClosedGenerationContext: jest.fn().mockResolvedValue({
        documentId: 'document-1',
        knowledgeUnit: Object.assign(
          new KnowledgeUnit({
            id: 'unit-1',
            subjectId: 'subject-1',
            title: 'Revision constitutionnelle',
            summary:
              'La Constitution de 1958 encadre la procedure de revision.',
          }),
          {
            difficulty: 'MEDIUM' as const,
            sourceChunkIds: ['chunk-1'],
          },
        ),
        chunks: [
          {
            id: 'chunk-1',
            index: 0,
            text: 'Article 89 encadre la revision constitutionnelle.',
            pageNumber: null,
          },
        ],
      }),
      createDiagnosticQuiz: jest.fn<
        Promise<DiagnosticQuizActivity>,
        [CreateDiagnosticQuizInput]
      >((input) =>
        Promise.resolve({
          sessionId: 'session-1',
          type: 'diagnostic_quiz',
          title: input.quiz.title,
          questions: input.quiz.questions.map(
            (
              question: {
                prompt: string;
                choices: Array<{ id: string; label: string }>;
              },
              index: number,
            ) => ({
              id: `question-${index + 1}`,
              prompt: question.prompt,
              choices: question.choices,
            }),
          ),
        }),
      ),
      submitResult: jest.fn().mockResolvedValue({
        correctAnswers: 1,
        totalQuestions: 1,
        score: 1,
        knowledgeUnitId: 'unit-1',
        items: [],
      }),
      findOpenAnswerEvaluationContext: jest.fn().mockResolvedValue({
        sessionId: 'open-session-1',
        subjectId: 'subject-1',
        documentId: null,
        knowledgeUnit: {
          id: 'unit-1',
          subjectId: 'subject-1',
          title: 'Revision constitutionnelle',
          summary: 'La Constitution de 1958 encadre la procedure de revision.',
          sourceChunkIds: [],
        },
        question: {
          id: 'open-question-1',
          prompt:
            'Explique comment la révision constitutionnelle est encadrée.',
          instructions: 'Réponds avec le cours.',
          sourceChunkIds: [],
        },
        chunks: [],
      }),
      createOpenQuestionActivity: jest
        .fn<Promise<OpenQuestionActivity>, []>()
        .mockResolvedValue({
          sessionId: 'open-session-1',
          type: 'open_question',
          version: 1,
          subjectId: 'subject-1',
          documentId: null,
          knowledgeUnitId: 'unit-1',
          question: {
            id: 'open-question-1',
            prompt:
              'Explique avec tes propres mots la notion suivante : Revision constitutionnelle.',
            instructions:
              'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
            maxAnswerLength: 4000,
            sources: [],
          },
        }),
      saveOpenAnswerEvaluation: jest
        .fn<Promise<OpenAnswerSubmissionResult>, []>()
        .mockResolvedValue({
          sessionId: 'open-session-1',
          type: 'open_question',
          status: 'submitted',
          evaluation: {
            id: 'evaluation-1',
            status: 'READY',
            score: 16,
            maxScore: 20,
            feedback: 'Réponse solide.',
            presentPoints: ['Procédure encadrée'],
            missingPoints: ['Limite matérielle'],
            errors: [],
            modelAnswer:
              'La révision constitutionnelle suit une procédure encadrée.',
            advice: 'Relis les limites de révision.',
            sources: [],
          },
        }),
      createRichClosedExerciseSession: jest
        .fn()
        .mockResolvedValue(richClosedPublicExercise()),
      getRichClosedExerciseForStudent: jest
        .fn()
        .mockResolvedValue(richClosedPublicExercise()),
      getInternalRichClosedExerciseForStudent: jest.fn().mockResolvedValue({
        sessionId: 'rich-session-1',
        status: 'STARTED',
        exercise: richClosedExerciseFixture(),
        result: null,
      }),
      saveRichClosedExerciseResult: jest
        .fn()
        .mockResolvedValue(richClosedResult()),
      getRichClosedExerciseResultForStudent: jest
        .fn()
        .mockResolvedValue(richClosedResult()),
    };
    diagnosticQuizGenerator = {
      generate: jest
        .fn<Promise<GeneratedDiagnosticQuiz>, [DiagnosticQuizGenerationInput]>()
        .mockResolvedValue({
          title: 'Diagnostic constitutionnel',
          questions: [
            {
              prompt:
                'Quelle limite materielle encadre la revision constitutionnelle en France ?',
              choices: [
                { id: 'a', label: 'La forme republicaine du gouvernement' },
                { id: 'b', label: 'La suppression du Parlement' },
              ],
              correctChoiceId: 'a',
              explanation:
                'La forme republicaine du gouvernement ne peut pas faire l objet d une revision.',
            },
          ],
        }),
    };
    openQuestionGenerator = {
      generate: jest
        .fn<Promise<GeneratedOpenQuestion>, [OpenQuestionGenerationInput]>()
        .mockResolvedValue({
          version: 1,
          prompt:
            'Explique comment la révision constitutionnelle est encadrée.',
          instructions: 'Réponds avec le cours.',
          maxAnswerLength: 2600,
          sourceChunkIds: [],
          metadata: {
            flowName: 'openQuestionGeneration',
            provider: 'google-genai',
            model: 'googleai/gemini-2.5-flash',
            promptVersion: 'open-question-generation-v1',
            schemaVersion: 'open-question-generation-v1',
            inputSize: 900,
          },
        }),
    };
    openAnswerEvaluator = {
      evaluate: jest
        .fn<
          Promise<GeneratedOpenAnswerEvaluation>,
          [OpenAnswerEvaluationInput]
        >()
        .mockResolvedValue({
          status: 'READY',
          score: 16,
          maxScore: 20,
          feedback: 'Réponse solide.',
          presentPoints: ['Procédure encadrée'],
          missingPoints: ['Limite matérielle'],
          errors: [],
          modelAnswer:
            'La révision constitutionnelle suit une procédure encadrée.',
          advice: 'Relis les limites de révision.',
          sourceChunkIds: [],
          metadata: {
            flowName: 'openAnswerEvaluation',
            provider: 'google-genai',
            model: 'googleai/gemini-2.5-flash',
            promptVersion: 'open-answer-evaluation-v1',
            schemaVersion: 'open-answer-evaluation-v1',
            inputSize: 1100,
          },
        }),
    };
    richClosedGenerator = {
      generate: jest
        .fn<Promise<RichClosedExercise>, [RichClosedQuestionGenerationInput]>()
        .mockResolvedValue(richClosedExerciseFixture()),
    };
    revisionRepository = {
      findKnowledgeUnits: jest.fn().mockResolvedValue([
        new KnowledgeUnit({
          id: 'unit-1',
          subjectId: 'subject-1',
          title: 'Revision constitutionnelle',
          summary: 'La Constitution de 1958 encadre la procedure de revision.',
        }),
      ]),
      findMasteryStates: jest.fn().mockResolvedValue([]),
      upsertMastery: jest.fn().mockResolvedValue({}),
    };

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideGuard(FirebaseAuthGuard)
      .useValue({
        canActivate: (context: ExecutionContext) => {
          const request = context
            .switchToHttp()
            .getRequest<{ student?: { id: string } }>();
          request.student = { id: 'student-1' };
          return true;
        },
      })
      .overrideProvider(TOKEN_VERIFIER)
      .useValue({ verify: jest.fn() })
      .overrideProvider(ACTIVITIES_REPOSITORY)
      .useValue(activitiesRepository)
      .overrideProvider(DIAGNOSTIC_QUIZ_GENERATOR)
      .useValue(diagnosticQuizGenerator)
      .overrideProvider(OPEN_QUESTION_GENERATOR)
      .useValue(openQuestionGenerator)
      .overrideProvider(OPEN_ANSWER_EVALUATOR)
      .useValue(openAnswerEvaluator)
      .overrideProvider(RICH_CLOSED_QUESTION_GENERATOR)
      .useValue(richClosedGenerator)
      .overrideProvider(REVISION_REPOSITORY)
      .useValue(revisionRepository)
      .overrideProvider(PrismaService)
      .useValue({})
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterEach(async () => {
    await app?.close();
    delete process.env.DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT;
    delete process.env.DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT;
  });

  it('registers activity routes through the app module', async () => {
    const nextResponse = await request(app.getHttpServer())
      .post('/activities/next')
      .send({ subjectId: 'subject-1', knowledgeUnitId: 'unit-1' })
      .expect(201);
    const nextBody = nextResponse.body as unknown as NextActivityResponseBody;

    expect(typeof nextBody.sessionId).toBe('string');
    expect(nextBody.type).toBe('diagnostic_quiz');
    expect(nextBody.title).toBe('Diagnostic constitutionnel');
    expect(Array.isArray(nextBody.questions)).toBe(true);
    const [generateInput] =
      diagnosticQuizGenerator.generate.mock.calls[0] ?? [];
    expect(generateInput?.knowledgeUnit.id).toBe('unit-1');
    expect(generateInput?.knowledgeUnit.title).toBe(
      'Revision constitutionnelle',
    );
    expect(generateInput?.questionCount).toBe(10);

    await request(app.getHttpServer())
      .post(`/activities/${nextBody.sessionId}/result`)
      .send({
        answers: [{ questionId: 'question-1', choiceId: 'a' }],
      })
      .expect(201)
      .expect({
        correctAnswers: 1,
        totalQuestions: 1,
        score: 1,
        items: [],
      });
  });

  it('accepts an explicit activity question count up to the configured max', async () => {
    await request(app.getHttpServer())
      .post('/activities/next')
      .send({
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        questionCount: 20,
      })
      .expect(201);

    const [generateInput] =
      diagnosticQuizGenerator.generate.mock.calls[0] ?? [];
    expect(generateInput?.questionCount).toBe(20);
  });

  it('accepts bounded visual and selection capabilities for the next activity', async () => {
    await request(app.getHttpServer())
      .post('/activities/next')
      .send({
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        visualsEnabled: true,
        visualTypes: ['CHART', 'DIAGRAM'],
        selectionModes: ['single', 'multiple'],
      })
      .expect(201);

    const [generateInput] =
      diagnosticQuizGenerator.generate.mock.calls[0] ?? [];
    expect(generateInput).toMatchObject({
      visualsEnabled: true,
      visualTypes: ['CHART', 'DIAGRAM'],
      selectionModes: ['single', 'multiple'],
    });
  });

  it('rejects image visual capability while document media is unsupported', async () => {
    await request(app.getHttpServer())
      .post('/activities/next')
      .send({
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        visualsEnabled: true,
        visualTypes: ['IMAGE'],
      })
      .expect(400);

    expect(diagnosticQuizGenerator.generate).not.toHaveBeenCalled();
  });

  it.each([
    ['zero', 0],
    ['negative', -1],
    ['too high', 21],
    ['decimal', 1.5],
    ['string', '10'],
  ])('rejects %s activity question counts with 400', async (_label, value) => {
    await request(app.getHttpServer())
      .post('/activities/next')
      .send({
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        questionCount: value,
      })
      .expect(400);

    expect(activitiesRepository.createDiagnosticQuiz).not.toHaveBeenCalled();
    expect(diagnosticQuizGenerator.generate).not.toHaveBeenCalled();
  });

  it('rejects malformed activity start payloads with 400', async () => {
    await request(app.getHttpServer())
      .post('/activities/next')
      .send({ subjectId: '', knowledgeUnitId: 'unit-1' })
      .expect(400);

    expect(activitiesRepository.createDiagnosticQuiz).not.toHaveBeenCalled();
  });

  it('returns 404 when an activity session is not found', async () => {
    activitiesRepository.submitResult.mockRejectedValue(
      new Error('Activity session not found'),
    );

    await request(app.getHttpServer())
      .post('/activities/missing-session/result')
      .send({
        answers: [{ questionId: 'question-1', choiceId: 'a' }],
      })
      .expect(404);
  });

  it('returns 409 when an activity session was already completed', async () => {
    activitiesRepository.submitResult.mockRejectedValue(
      new Error('Activity session already completed'),
    );

    await request(app.getHttpServer())
      .post('/activities/session-1/result')
      .send({
        answers: [{ questionId: 'question-1', choiceId: 'a' }],
      })
      .expect(409);
  });

  it('rejects malformed activity result payloads with 400', async () => {
    await request(app.getHttpServer())
      .post('/activities/session-1/result')
      .send({ answers: null })
      .expect(400);

    await request(app.getHttpServer())
      .post('/activities/session-1/result')
      .send({
        answers: [{ questionId: 'question-1' }],
      })
      .expect(400);

    expect(activitiesRepository.submitResult).not.toHaveBeenCalled();
  });

  it('accepts multiple choice answer payloads for result submission', async () => {
    await request(app.getHttpServer())
      .post('/activities/session-1/result')
      .send({
        answers: [{ questionId: 'question-1', choiceIds: ['a', 'c'] }],
      })
      .expect(201);

    expect(activitiesRepository.submitResult).toHaveBeenCalledWith({
      studentId: 'student-1',
      sessionId: 'session-1',
      answers: [{ questionId: 'question-1', choiceIds: ['a', 'c'] }],
    });
  });

  it('rejects malformed activity session ids with 400', async () => {
    await request(app.getHttpServer())
      .post('/activities/%20/result')
      .send({
        answers: [{ questionId: 'question-1', choiceId: 'a' }],
      })
      .expect(400);

    expect(activitiesRepository.submitResult).not.toHaveBeenCalled();
  });

  it('starts an open question activity without exposing correction data', async () => {
    const response = await request(app.getHttpServer())
      .post('/activities/open-question')
      .send({ subjectId: 'subject-1', knowledgeUnitId: 'unit-1' })
      .expect(201);

    expect(activitiesRepository.createOpenQuestionActivity).toHaveBeenCalled();
    expect(response.body).toEqual({
      sessionId: 'open-session-1',
      type: 'open_question',
      version: 1,
      subjectId: 'subject-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      question: {
        id: 'open-question-1',
        prompt:
          'Explique avec tes propres mots la notion suivante : Revision constitutionnelle.',
        instructions:
          'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
        maxAnswerLength: 4000,
        sources: [],
      },
    });
    const publicPayload = JSON.stringify(response.body);
    expect(publicPayload).not.toContain('answerText');
    expect(publicPayload).not.toContain('modelAnswer');
    expect(publicPayload).not.toContain('score');
    expect(publicPayload).not.toContain('feedback');
  });

  it('starts a rich closed exercise without exposing pre-submit correction data', async () => {
    const response = await request(app.getHttpServer())
      .post('/activities/rich-closed/start')
      .send({
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        questionCount: 6,
        complexityProfile: 'exam',
      })
      .expect(201);

    expect(richClosedGenerator.generate).toHaveBeenCalledWith(
      expect.objectContaining({
        studentId: 'student-1',
        subjectId: 'subject-1',
        documentId: 'document-1',
        questionCount: 6,
        complexityProfile: 'exam',
      }),
    );
    expect(
      activitiesRepository.createRichClosedExerciseSession,
    ).toHaveBeenCalled();
    expect(response.body).toMatchObject({
      sessionId: 'rich-session-1',
      type: 'rich_closed_exercise',
      version: 'rich-closed-question-v1',
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
    });
    const publicPayload = JSON.stringify(response.body);
    expect(publicPayload).not.toContain('correctChoiceId');
    expect(publicPayload).not.toContain('correctChoiceIds');
    expect(publicPayload).not.toContain('correctPairs');
    expect(publicPayload).not.toContain('correctOrder');
    expect(publicPayload).not.toContain('correctErrorId');
    expect(publicPayload).not.toContain('explanation');
    expect(publicPayload).not.toContain('feedback');
    expect(publicPayload).not.toContain('score');
  });

  it('gets rich closed pre-submit payload and returns post-submit result', async () => {
    await request(app.getHttpServer())
      .get('/activities/rich-closed/rich-session-1')
      .expect(200)
      .expect(richClosedPublicExercise());

    expect(
      activitiesRepository.getRichClosedExerciseForStudent,
    ).toHaveBeenCalledWith({
      studentId: 'student-1',
      sessionId: 'rich-session-1',
    });

    await request(app.getHttpServer())
      .get('/activities/rich-closed/rich-session-1/result')
      .expect(200)
      .expect(richClosedResult());

    expect(
      activitiesRepository.getRichClosedExerciseResultForStudent,
    ).toHaveBeenCalledWith({
      studentId: 'student-1',
      sessionId: 'rich-session-1',
    });
  });

  it('submits rich closed structured answers and exposes correction only post-submit', async () => {
    const response = await request(app.getHttpServer())
      .post('/activities/rich-closed/rich-session-1/submit')
      .send({
        answers: richClosedAnswers(),
      })
      .expect(201);

    expect(
      activitiesRepository.saveRichClosedExerciseResult,
    ).toHaveBeenCalledWith({
      studentId: 'student-1',
      sessionId: 'rich-session-1',
      answers: richClosedAnswers(),
      result: expect.objectContaining({
        correctAnswers: 6,
        totalQuestions: 6,
        score: 1,
      }) as RichClosedExerciseResult,
    });
    expect(response.body).toMatchObject({
      sessionId: 'rich-session-1',
      type: 'rich_closed_exercise',
      status: 'completed',
      correctAnswers: 6,
      totalQuestions: 6,
      score: 1,
    });
    expect(JSON.stringify(response.body)).toContain('correctChoiceId');
    expect(JSON.stringify(richClosedPublicExercise())).not.toContain(
      'correctChoiceId',
    );
  });

  it('validates rich closed start and submit payloads', async () => {
    await request(app.getHttpServer())
      .post('/activities/rich-closed/start')
      .send({
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        questionCount: 5,
      })
      .expect(400);

    await request(app.getHttpServer())
      .post('/activities/rich-closed/rich-session-1/submit')
      .send({
        answers: [
          {
            questionId: 'single-1',
            questionKind: 'single_choice',
            choiceId: 'choice-a',
            answerText: 'texte libre interdit',
          },
        ],
      })
      .expect(400);

    expect(richClosedGenerator.generate).not.toHaveBeenCalled();
  });

  it('maps rich closed source and double-submit errors', async () => {
    activitiesRepository.findRichClosedGenerationContext.mockResolvedValueOnce({
      documentId: 'document-1',
      knowledgeUnit: Object.assign(
        new KnowledgeUnit({
          id: 'unit-1',
          subjectId: 'subject-1',
          title: 'Revision constitutionnelle',
          summary: 'La Constitution de 1958 encadre la procedure de revision.',
        }),
        {
          difficulty: 'MEDIUM' as const,
          sourceChunkIds: [],
        },
      ),
      chunks: [],
    });

    await request(app.getHttpServer())
      .post('/activities/rich-closed/start')
      .send({ subjectId: 'subject-1', knowledgeUnitId: 'unit-1' })
      .expect(422);

    activitiesRepository.getInternalRichClosedExerciseForStudent.mockResolvedValueOnce(
      {
        sessionId: 'rich-session-1',
        status: 'COMPLETED',
        exercise: richClosedExerciseFixture(),
        result: richClosedResult(),
      },
    );

    await request(app.getHttpServer())
      .post('/activities/rich-closed/rich-session-1/submit')
      .send({ answers: richClosedAnswers() })
      .expect(409);

    activitiesRepository.getRichClosedExerciseForStudent.mockRejectedValueOnce(
      new Error(RICH_CLOSED_SOURCE_CONTEXT_EMPTY),
    );
  });

  it('submits an open answer and returns a ready evaluation contract', async () => {
    await request(app.getHttpServer())
      .post('/activities/open-session-1/open-answer')
      .send({
        answerText:
          'La révision constitutionnelle est une procédure encadrée par la Constitution.',
      })
      .expect(201)
      .expect({
        sessionId: 'open-session-1',
        type: 'open_question',
        status: 'submitted',
        evaluation: {
          id: 'evaluation-1',
          status: 'READY',
          score: 16,
          maxScore: 20,
          feedback: 'Réponse solide.',
          presentPoints: ['Procédure encadrée'],
          missingPoints: ['Limite matérielle'],
          errors: [],
          modelAnswer:
            'La révision constitutionnelle suit une procédure encadrée.',
          advice: 'Relis les limites de révision.',
          sources: [],
        },
      });

    expect(activitiesRepository.saveOpenAnswerEvaluation).toHaveBeenCalled();
    expect(openAnswerEvaluator.evaluate).toHaveBeenCalled();
    expect(activitiesRepository.saveOpenAnswerEvaluation).toHaveBeenCalledWith({
      studentId: 'student-1',
      sessionId: 'open-session-1',
      answerText:
        'La révision constitutionnelle est une procédure encadrée par la Constitution.',
      evaluation: expect.objectContaining({
        status: 'READY',
        score: 16,
        maxScore: 20,
      }) as GeneratedOpenAnswerEvaluation,
    });
    expect(revisionRepository.upsertMastery).toHaveBeenCalled();
  });

  it('rejects malformed open question and open answer payloads', async () => {
    await request(app.getHttpServer())
      .post('/activities/open-question')
      .send({ subjectId: '', knowledgeUnitId: 'unit-1' })
      .expect(400);

    await request(app.getHttpServer())
      .post('/activities/open-session-1/open-answer')
      .send({ answerText: '' })
      .expect(400);

    expect(
      activitiesRepository.createOpenQuestionActivity,
    ).not.toHaveBeenCalled();
    expect(
      activitiesRepository.saveOpenAnswerEvaluation,
    ).not.toHaveBeenCalled();
  });
});

function richClosedPublicExercise(): RichClosedPublicExerciseEnvelope {
  const exercise = richClosedExerciseFixture();

  return {
    sessionId: 'rich-session-1',
    type: 'rich_closed_exercise',
    id: exercise.id,
    version: exercise.version,
    title: exercise.title,
    subjectId: exercise.subjectId,
    documentId: exercise.documentId,
    knowledgeUnitId: exercise.knowledgeUnitId,
    questions: exercise.questions.map((question) => {
      const base = {
        id: question.id,
        questionKind: question.questionKind,
        prompt: question.prompt,
        difficulty: question.difficulty,
        cognitiveSkill: question.cognitiveSkill,
        sourceChunkIds: question.sourceChunkIds,
      };

      switch (question.questionKind) {
        case 'single_choice':
          return {
            ...base,
            questionKind: question.questionKind,
            choices: question.choices.map(({ id, label }) => ({ id, label })),
          };
        case 'multiple_choice':
          return {
            ...base,
            questionKind: question.questionKind,
            choices: question.choices.map(({ id, label }) => ({ id, label })),
            minSelections: question.minSelections,
            maxSelections: question.maxSelections,
          };
        case 'matching':
          return {
            ...base,
            questionKind: question.questionKind,
            leftItems: question.leftItems,
            rightItems: question.rightItems,
          };
        case 'ordering':
          return {
            ...base,
            questionKind: question.questionKind,
            items: question.items,
          };
        case 'case_qualification':
          return {
            ...base,
            questionKind: question.questionKind,
            caseText: question.caseText,
            choices: question.choices.map(({ id, label }) => ({ id, label })),
          };
        case 'error_detection':
          return {
            ...base,
            questionKind: question.questionKind,
            statement: question.statement,
            errorOptions: question.errorOptions.map(({ id, label }) => ({
              id,
              label,
            })),
          };
      }
    }),
  };
}

function richClosedResult(): RichClosedExerciseResult {
  return scoreRichClosedExerciseSubmission({
    sessionId: 'rich-session-1',
    exercise: richClosedExerciseFixture(),
    answers: richClosedAnswers(),
  });
}

function richClosedAnswers(): RichClosedAnswer[] {
  return [
    {
      questionId: 'single-1',
      questionKind: 'single_choice',
      choiceId: 'choice-a',
    },
    {
      questionId: 'multiple-1',
      questionKind: 'multiple_choice',
      choiceIds: ['choice-a', 'choice-b'],
    },
    {
      questionId: 'matching-1',
      questionKind: 'matching',
      pairs: [
        { leftId: 'left-1', rightId: 'right-1' },
        { leftId: 'left-2', rightId: 'right-2' },
        { leftId: 'left-3', rightId: 'right-3' },
      ],
    },
    {
      questionId: 'ordering-1',
      questionKind: 'ordering',
      orderedIds: ['item-1', 'item-2', 'item-3'],
    },
    {
      questionId: 'case-1',
      questionKind: 'case_qualification',
      choiceId: 'choice-a',
    },
    {
      questionId: 'error-1',
      questionKind: 'error_detection',
      errorId: 'error-a',
    },
  ];
}
````

### api/src/modules/activities/application/activities.repository.ts

````ts
import type {
  DiagnosticQuizDifficulty,
  DiagnosticQuizVisualType,
  DiagnosticQuizGenerationChunk,
  DiagnosticQuizGenerationKnowledgeUnit,
  GeneratedDiagnosticQuiz,
} from './diagnostic-quiz-generator';
import type {
  GeneratedOpenAnswerEvaluation,
  OpenAnswerEvaluationQuestion,
} from './open-answer-evaluator';
import type { OpenQuestionGenerationMetadata } from './open-question-generator';
import type {
  GeneratedRichClosedExercise,
  RichClosedQuestionGenerationMetadata,
} from './rich-closed-questions/rich-closed-question-generator';
import type {
  RichClosedAnswer,
  RichClosedExercise,
  RichClosedExerciseResult,
  RichClosedPublicExerciseEnvelope,
} from './rich-closed-questions/rich-closed-question.types';

export interface ActivityQuestionChoice {
  id: string;
  label: string;
}

export interface ActivityQuestion {
  id: string;
  knowledgeUnitId?: string;
  prompt: string;
  difficulty?: DiagnosticQuizDifficulty | null;
  selectionMode?: 'single' | 'multiple';
  minSelections?: number | null;
  maxSelections?: number | null;
  choices: ActivityQuestionChoice[];
  sources?: ActivityQuestionSource[];
  visuals?: ActivityQuestionVisual[];
}

export interface ActivityQuestionSource {
  chunkId: string;
  pageNumber: number | null;
  index: number;
}

export type ActivityQuestionVisual =
  | ActivityQuestionImageVisual
  | ActivityQuestionChartVisual
  | ActivityQuestionDiagramVisual;

export interface ActivityQuestionVisualBase {
  id?: string;
  type: DiagnosticQuizVisualType;
  displayOrder: number;
  sources: ActivityQuestionSource[];
}

export interface ActivityQuestionImageVisual extends ActivityQuestionVisualBase {
  type: 'IMAGE';
  imageUrl: string;
  altText: string;
  caption?: string | null;
}

export interface ActivityQuestionChartVisual extends ActivityQuestionVisualBase {
  type: 'CHART';
  chartType: 'bar' | 'line' | 'pie' | 'scatter';
  title: string;
  description?: string | null;
  data: Array<Record<string, string | number | null>>;
  xKey?: string | null;
  yKeys?: string[] | null;
}

export interface ActivityQuestionDiagramVisual extends ActivityQuestionVisualBase {
  type: 'DIAGRAM';
  title: string;
  description?: string | null;
  nodes: Array<{
    id: string;
    label: string;
  }>;
  edges?: Array<{
    from: string;
    to: string;
    label?: string | null;
  }>;
}

export interface DiagnosticQuizActivity {
  sessionId: string;
  type: 'diagnostic_quiz';
  title: string;
  version?: number;
  documentId?: string | null;
  subjectId?: string;
  questions: ActivityQuestion[];
}

export interface OpenQuestionActivitySource {
  chunkId: string;
  pageNumber: number | null;
  index: number;
}

export interface OpenQuestionActivity {
  sessionId: string;
  type: 'open_question';
  version: number;
  subjectId: string;
  documentId?: string | null;
  knowledgeUnitId: string;
  question: {
    id: string;
    prompt: string;
    instructions: string | null;
    maxAnswerLength: number;
    sources: OpenQuestionActivitySource[];
  };
}

export interface OpenQuestionDraft {
  prompt: string;
  instructions: string | null;
  maxAnswerLength: number;
  sourceChunkIds: string[];
  version: number;
  metadata?: OpenQuestionGenerationMetadata;
}

export const ACTIVITIES_REPOSITORY = Symbol('ACTIVITIES_REPOSITORY');

export interface DiagnosticQuizGenerationContext {
  documentId: string | null;
  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit;
  chunks: DiagnosticQuizGenerationChunk[];
}

export interface ActivityQuestionCorrectionSource {
  chunkId: string;
  text: string;
  pageNumber: number | null;
  index: number;
}

export interface ActivityQuestionChoiceFeedback {
  choiceId: string;
  feedback: string;
}

export interface ActivityQuestionCorrectionItem {
  questionId: string;
  knowledgeUnitId: string;
  prompt: string;
  selectedChoiceId?: string;
  selectedChoiceIds?: string[];
  correctChoiceId?: string;
  correctChoiceIds?: string[];
  isCorrect: boolean;
  partialScore?: number;
  explanation: string;
  choiceFeedback: ActivityQuestionChoiceFeedback[];
  sources: ActivityQuestionCorrectionSource[];
}

export interface DiagnosticQuizSubmissionResult {
  correctAnswers: number;
  totalQuestions: number;
  score: number;
  knowledgeUnitId: string;
  items: ActivityQuestionCorrectionItem[];
}

export interface OpenAnswerSubmissionResult {
  sessionId: string;
  type: 'open_question';
  status: 'submitted';
  evaluation: {
    id: string;
    status: 'PENDING' | 'READY' | 'FAILED';
    score: number | null;
    maxScore: number | null;
    feedback: string | null;
    presentPoints: unknown[];
    missingPoints: unknown[];
    errors: unknown[];
    modelAnswer: string | null;
    advice: string | null;
    sources: ActivityQuestionCorrectionSource[];
  };
}

export interface OpenAnswerEvaluationContext {
  sessionId: string;
  subjectId: string;
  documentId: string | null;
  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit;
  question: OpenAnswerEvaluationQuestion;
  chunks: DiagnosticQuizGenerationChunk[];
}

export interface RichClosedExerciseInternalEnvelope {
  sessionId: string;
  status: 'STARTED' | 'SUBMITTED' | 'COMPLETED';
  exercise: RichClosedExercise;
  result: RichClosedExerciseResult | null;
}

export type OpenAnswerEvaluationDraft =
  | GeneratedOpenAnswerEvaluation
  | {
      status: 'FAILED';
      errorCode: string;
      metadata?: OpenQuestionGenerationMetadata;
    };

export interface ActivitiesRepository {
  findDiagnosticQuizGenerationContext(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<DiagnosticQuizGenerationContext | null>;

  findOpenQuestionGenerationContext(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<DiagnosticQuizGenerationContext | null>;

  createDiagnosticQuiz(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
    documentId?: string | null;
    quiz: GeneratedDiagnosticQuiz;
  }): Promise<DiagnosticQuizActivity>;

  createOpenQuestionActivity(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
    documentId?: string | null;
    question: OpenQuestionDraft;
  }): Promise<OpenQuestionActivity>;

  findRichClosedGenerationContext(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<DiagnosticQuizGenerationContext | null>;

  createRichClosedExerciseSession(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
    documentId?: string | null;
    exercise: GeneratedRichClosedExercise;
    qualityMetrics?: unknown;
    generationMetadata?: RichClosedQuestionGenerationMetadata;
  }): Promise<RichClosedPublicExerciseEnvelope>;

  getRichClosedExerciseForStudent(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedPublicExerciseEnvelope>;

  getInternalRichClosedExerciseForStudent(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedExerciseInternalEnvelope>;

  saveRichClosedExerciseResult(input: {
    studentId: string;
    sessionId: string;
    answers: RichClosedAnswer[];
    result: RichClosedExerciseResult;
  }): Promise<RichClosedExerciseResult>;

  getRichClosedExerciseResultForStudent(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedExerciseResult>;

  submitResult(input: {
    studentId: string;
    sessionId: string;
    answers: Array<{
      questionId: string;
      choiceId?: string;
      choiceIds?: string[];
    }>;
  }): Promise<DiagnosticQuizSubmissionResult>;

  findOpenAnswerEvaluationContext(input: {
    studentId: string;
    sessionId: string;
  }): Promise<OpenAnswerEvaluationContext>;

  saveOpenAnswerEvaluation(input: {
    studentId: string;
    sessionId: string;
    answerText: string;
    evaluation: OpenAnswerEvaluationDraft;
  }): Promise<OpenAnswerSubmissionResult>;
}
````

### api/src/modules/activities/application/rich-closed-questions/get-rich-closed-exercise-result.use-case.ts

````ts
import { Inject, Injectable } from '@nestjs/common';
import {
  ACTIVITIES_REPOSITORY,
  type ActivitiesRepository,
} from '../activities.repository';
import type { RichClosedExerciseResult } from './rich-closed-question.types';

@Injectable()
export class GetRichClosedExerciseResultUseCase {
  constructor(
    @Inject(ACTIVITIES_REPOSITORY)
    private readonly activitiesRepository: ActivitiesRepository,
  ) {}

  execute(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedExerciseResult> {
    return this.activitiesRepository.getRichClosedExerciseResultForStudent(
      input,
    );
  }
}
````

### api/src/modules/activities/application/rich-closed-questions/get-rich-closed-exercise.use-case.ts

````ts
import { Inject, Injectable } from '@nestjs/common';
import {
  ACTIVITIES_REPOSITORY,
  type ActivitiesRepository,
} from '../activities.repository';
import type { RichClosedPublicExerciseEnvelope } from './rich-closed-question.types';

@Injectable()
export class GetRichClosedExerciseUseCase {
  constructor(
    @Inject(ACTIVITIES_REPOSITORY)
    private readonly activitiesRepository: ActivitiesRepository,
  ) {}

  execute(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedPublicExerciseEnvelope> {
    return this.activitiesRepository.getRichClosedExerciseForStudent(input);
  }
}
````

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-errors.ts

````ts
export const RICH_CLOSED_START_INVALID_INPUT =
  'RICH_CLOSED_START_INVALID_INPUT';
export const RICH_CLOSED_SUBMIT_INVALID_INPUT =
  'RICH_CLOSED_SUBMIT_INVALID_INPUT';
export const RICH_CLOSED_SESSION_NOT_FOUND = 'RICH_CLOSED_SESSION_NOT_FOUND';
export const RICH_CLOSED_SESSION_FORBIDDEN = 'RICH_CLOSED_SESSION_FORBIDDEN';
export const RICH_CLOSED_SESSION_ALREADY_COMPLETED =
  'RICH_CLOSED_SESSION_ALREADY_COMPLETED';
export const RICH_CLOSED_SESSION_NOT_COMPLETED =
  'RICH_CLOSED_SESSION_NOT_COMPLETED';
export const RICH_CLOSED_SOURCE_CONTEXT_EMPTY =
  'RICH_CLOSED_SOURCE_CONTEXT_EMPTY';
export const RICH_CLOSED_GENERATION_FAILED = 'RICH_CLOSED_GENERATION_FAILED';
export const RICH_CLOSED_GENERATION_SCHEMA_INVALID =
  'RICH_CLOSED_GENERATION_SCHEMA_INVALID';
export const RICH_CLOSED_GENERATION_CONTRACT_INVALID =
  'RICH_CLOSED_GENERATION_CONTRACT_INVALID';
export const RICH_CLOSED_GENERATION_QUALITY_REJECTED =
  'RICH_CLOSED_GENERATION_QUALITY_REJECTED';
export const RICH_CLOSED_GENERATION_SOURCE_INVALID =
  'RICH_CLOSED_GENERATION_SOURCE_INVALID';
````

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.ts

````ts
import type {
  RichClosedExercise,
  RichClosedPublicChoice,
  RichClosedPublicExercise,
  RichClosedPublicExerciseEnvelope,
  RichClosedPublicQuestion,
  RichClosedQuestion,
} from './rich-closed-question.types';

export function toRichClosedPublicExercise(
  exercise: RichClosedExercise,
): RichClosedPublicExercise {
  return {
    id: exercise.id,
    version: exercise.version,
    title: exercise.title,
    ...(exercise.subjectId === undefined
      ? {}
      : { subjectId: exercise.subjectId }),
    ...(exercise.documentId === undefined
      ? {}
      : { documentId: exercise.documentId }),
    ...(exercise.knowledgeUnitId === undefined
      ? {}
      : { knowledgeUnitId: exercise.knowledgeUnitId }),
    questions: exercise.questions.map(toRichClosedPublicQuestion),
  };
}

export function toRichClosedPublicExerciseEnvelope(input: {
  sessionId: string;
  exercise: RichClosedExercise;
}): RichClosedPublicExerciseEnvelope {
  return {
    sessionId: input.sessionId,
    type: 'rich_closed_exercise',
    ...toRichClosedPublicExercise(input.exercise),
  };
}

export function toRichClosedPublicQuestion(
  question: RichClosedQuestion,
): RichClosedPublicQuestion {
  const base = {
    id: question.id,
    questionKind: question.questionKind,
    prompt: question.prompt,
    difficulty: question.difficulty,
    cognitiveSkill: question.cognitiveSkill,
    sourceChunkIds: [...question.sourceChunkIds],
  };

  switch (question.questionKind) {
    case 'single_choice':
      return {
        ...base,
        questionKind: question.questionKind,
        choices: publicChoices(question.choices),
      };
    case 'multiple_choice':
      return {
        ...base,
        questionKind: question.questionKind,
        choices: publicChoices(question.choices),
        minSelections: question.minSelections,
        maxSelections: question.maxSelections,
      };
    case 'matching':
      return {
        ...base,
        questionKind: question.questionKind,
        leftItems: cloneLabelItems(question.leftItems),
        rightItems: cloneLabelItems(question.rightItems),
      };
    case 'ordering':
      return {
        ...base,
        questionKind: question.questionKind,
        items: cloneLabelItems(question.items),
      };
    case 'case_qualification':
      return {
        ...base,
        questionKind: question.questionKind,
        caseText: question.caseText,
        choices: publicChoices(question.choices),
      };
    case 'error_detection':
      return {
        ...base,
        questionKind: question.questionKind,
        statement: question.statement,
        errorOptions: publicChoices(question.errorOptions),
      };
  }
}

function publicChoices(
  choices: Array<{ id: string; label: string }>,
): RichClosedPublicChoice[] {
  return choices.map((choice) => ({
    id: choice.id,
    label: choice.label,
  }));
}

function cloneLabelItems(items: Array<{ id: string; label: string }>) {
  return items.map((item) => ({
    id: item.id,
    label: item.label,
  }));
}
````

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-scorer.spec.ts

````ts
import { RICH_CLOSED_SUBMIT_INVALID_INPUT } from './rich-closed-question-errors';
import { richClosedExerciseFixture } from './rich-closed-question.fixtures';
import { scoreRichClosedExerciseSubmission } from './rich-closed-question-scorer';
import type { RichClosedAnswer } from './rich-closed-question.types';

describe('scoreRichClosedExerciseSubmission', () => {
  it('scores a fully correct rich closed exercise', () => {
    const result = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: correctAnswers(),
    });

    expect(result).toMatchObject({
      sessionId: 'session-1',
      type: 'rich_closed_exercise',
      status: 'completed',
      correctAnswers: 6,
      totalQuestions: 6,
      score: 1,
    });
    expect(result.items).toHaveLength(6);
    expect(result.items.every((item) => item.isCorrect)).toBe(true);
    expect(result.items[0]?.correction).toEqual({
      correctChoiceId: 'choice-a',
    });
    expect(result.items[1]?.correction).toEqual({
      correctChoiceIds: ['choice-a', 'choice-b'],
    });
  });

  it('scores exact and incorrect answers by question kind', () => {
    const result = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: [
        {
          questionId: 'single-1',
          questionKind: 'single_choice',
          choiceId: 'choice-b',
        },
        {
          questionId: 'multiple-1',
          questionKind: 'multiple_choice',
          choiceIds: ['choice-b', 'choice-a'],
        },
        {
          questionId: 'matching-1',
          questionKind: 'matching',
          pairs: [
            { leftId: 'left-2', rightId: 'right-2' },
            { leftId: 'left-1', rightId: 'right-1' },
            { leftId: 'left-3', rightId: 'right-3' },
          ],
        },
        {
          questionId: 'ordering-1',
          questionKind: 'ordering',
          orderedIds: ['item-1', 'item-3', 'item-2'],
        },
        {
          questionId: 'case-1',
          questionKind: 'case_qualification',
          choiceId: 'choice-a',
        },
        {
          questionId: 'error-1',
          questionKind: 'error_detection',
          errorId: 'error-b',
        },
      ],
    });

    expect(result.correctAnswers).toBe(3);
    expect(result.score).toBe(0.5);
    expect(result.items.map((item) => item.isCorrect)).toEqual([
      false,
      true,
      true,
      false,
      true,
      false,
    ]);
  });

  it('accepts multiple choice answer order but requires an exact set', () => {
    const exact = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: correctAnswers().map((answer) =>
        answer.questionId === 'multiple-1'
          ? {
              questionId: 'multiple-1',
              questionKind: 'multiple_choice',
              choiceIds: ['choice-b', 'choice-a'],
            }
          : answer,
      ),
    });
    const missing = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: correctAnswers().map((answer) =>
        answer.questionId === 'multiple-1'
          ? {
              questionId: 'multiple-1',
              questionKind: 'multiple_choice',
              choiceIds: ['choice-a'],
            }
          : answer,
      ),
    });

    expect(
      exact.items.find((item) => item.questionId === 'multiple-1'),
    ).toMatchObject({
      isCorrect: true,
    });
    expect(
      missing.items.find((item) => item.questionId === 'multiple-1'),
    ).toMatchObject({
      isCorrect: false,
    });
  });

  it('accepts matching pair order but requires exact logical pairs', () => {
    const wrongPair = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: correctAnswers().map((answer) =>
        answer.questionId === 'matching-1'
          ? {
              questionId: 'matching-1',
              questionKind: 'matching',
              pairs: [
                { leftId: 'left-1', rightId: 'right-2' },
                { leftId: 'left-2', rightId: 'right-1' },
                { leftId: 'left-3', rightId: 'right-3' },
              ],
            }
          : answer,
      ),
    });

    expect(
      wrongPair.items.find((item) => item.questionId === 'matching-1'),
    ).toMatchObject({
      isCorrect: false,
    });
  });

  it('rejects incomplete ordering answers', () => {
    expect(() =>
      scoreRichClosedExerciseSubmission({
        sessionId: 'session-1',
        exercise: richClosedExerciseFixture(),
        answers: correctAnswers().map((answer) =>
          answer.questionId === 'ordering-1'
            ? {
                questionId: 'ordering-1',
                questionKind: 'ordering',
                orderedIds: ['item-1', 'item-2'],
              }
            : answer,
        ),
      }),
    ).toThrow(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  });

  it('rejects unknown, duplicate, missing and kind-mismatched answers', () => {
    expectInvalid([
      ...correctAnswers(),
      {
        questionId: 'unknown-question',
        questionKind: 'single_choice',
        choiceId: 'choice-a',
      },
    ]);
    expectInvalid([
      ...correctAnswers(),
      {
        questionId: 'single-1',
        questionKind: 'single_choice',
        choiceId: 'choice-a',
      },
    ]);
    expectInvalid(
      correctAnswers().filter((answer) => answer.questionId !== 'single-1'),
    );
    expectInvalid(
      correctAnswers().map((answer) =>
        answer.questionId === 'single-1'
          ? {
              questionId: 'single-1',
              questionKind: 'multiple_choice',
              choiceIds: ['choice-a', 'choice-b'],
            }
          : answer,
      ),
    );
  });

  it('rejects answers carrying free text or correction fields', () => {
    expectInvalid([
      ...correctAnswers().filter((answer) => answer.questionId !== 'single-1'),
      {
        questionId: 'single-1',
        questionKind: 'single_choice',
        choiceId: 'choice-a',
        answerText: 'réponse libre interdite',
      },
    ]);
    expectInvalid([
      ...correctAnswers().filter(
        (answer) => answer.questionId !== 'multiple-1',
      ),
      {
        questionId: 'multiple-1',
        questionKind: 'multiple_choice',
        choiceIds: ['choice-a', 'choice-b'],
        correctChoiceIds: ['choice-a', 'choice-b'],
      },
    ]);
  });

  it('produces global scores at 0 and 1', () => {
    const zero = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: [
        {
          questionId: 'single-1',
          questionKind: 'single_choice',
          choiceId: 'choice-b',
        },
        {
          questionId: 'multiple-1',
          questionKind: 'multiple_choice',
          choiceIds: ['choice-a', 'choice-c'],
        },
        {
          questionId: 'matching-1',
          questionKind: 'matching',
          pairs: [
            { leftId: 'left-1', rightId: 'right-2' },
            { leftId: 'left-2', rightId: 'right-3' },
            { leftId: 'left-3', rightId: 'right-1' },
          ],
        },
        {
          questionId: 'ordering-1',
          questionKind: 'ordering',
          orderedIds: ['item-3', 'item-2', 'item-1'],
        },
        {
          questionId: 'case-1',
          questionKind: 'case_qualification',
          choiceId: 'choice-b',
        },
        {
          questionId: 'error-1',
          questionKind: 'error_detection',
          errorId: 'error-b',
        },
      ],
    });

    expect(zero.score).toBe(0);
    expect(
      scoreRichClosedExerciseSubmission({
        sessionId: 'session-1',
        exercise: richClosedExerciseFixture(),
        answers: correctAnswers(),
      }).score,
    ).toBe(1);
  });
});

function expectInvalid(answers: unknown[]) {
  expect(() =>
    scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers,
    }),
  ).toThrow(RICH_CLOSED_SUBMIT_INVALID_INPUT);
}

function correctAnswers(): RichClosedAnswer[] {
  return [
    {
      questionId: 'single-1',
      questionKind: 'single_choice',
      choiceId: 'choice-a',
    },
    {
      questionId: 'multiple-1',
      questionKind: 'multiple_choice',
      choiceIds: ['choice-a', 'choice-b'],
    },
    {
      questionId: 'matching-1',
      questionKind: 'matching',
      pairs: [
        { leftId: 'left-1', rightId: 'right-1' },
        { leftId: 'left-2', rightId: 'right-2' },
        { leftId: 'left-3', rightId: 'right-3' },
      ],
    },
    {
      questionId: 'ordering-1',
      questionKind: 'ordering',
      orderedIds: ['item-1', 'item-2', 'item-3'],
    },
    {
      questionId: 'case-1',
      questionKind: 'case_qualification',
      choiceId: 'choice-a',
    },
    {
      questionId: 'error-1',
      questionKind: 'error_detection',
      errorId: 'error-a',
    },
  ];
}
````

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-scorer.ts

````ts
import {
  RICH_CLOSED_SUBMIT_INVALID_INPUT,
  RICH_CLOSED_SESSION_NOT_FOUND,
} from './rich-closed-question-errors';
import {
  type RichClosedAnswer,
  type RichClosedCorrectionItem,
  type RichClosedCorrectionPayload,
  type RichClosedExercise,
  type RichClosedExerciseResult,
  type RichClosedPair,
  type RichClosedQuestion,
} from './rich-closed-question.types';

export function scoreRichClosedExerciseSubmission(input: {
  sessionId: string;
  exercise: RichClosedExercise;
  answers: unknown[];
}): RichClosedExerciseResult {
  if (input.exercise.questions.length === 0) {
    throw new Error(RICH_CLOSED_SESSION_NOT_FOUND);
  }

  const answersByQuestionId = normalizeAnswers(input.answers);
  const questionIds = new Set(
    input.exercise.questions.map((question) => question.id),
  );

  for (const answer of answersByQuestionId.values()) {
    if (!questionIds.has(answer.questionId)) {
      throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
    }
  }

  const items = input.exercise.questions.map((question) => {
    const answer = answersByQuestionId.get(question.id);

    if (!answer) {
      throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
    }

    return scoreQuestion(question, answer);
  });
  const correctAnswers = items.filter((item) => item.isCorrect).length;
  const totalQuestions = input.exercise.questions.length;
  const score =
    totalQuestions === 0
      ? 0
      : Number((correctAnswers / totalQuestions).toFixed(3));

  return {
    sessionId: input.sessionId,
    type: 'rich_closed_exercise',
    status: 'completed',
    correctAnswers,
    totalQuestions,
    score,
    items,
  };
}

function normalizeAnswers(answers: unknown[]): Map<string, RichClosedAnswer> {
  if (!Array.isArray(answers) || answers.length === 0) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }

  const answersByQuestionId = new Map<string, RichClosedAnswer>();

  for (const answer of answers) {
    const normalizedAnswer = normalizeAnswer(answer);

    if (answersByQuestionId.has(normalizedAnswer.questionId)) {
      throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
    }

    answersByQuestionId.set(normalizedAnswer.questionId, normalizedAnswer);
  }

  return answersByQuestionId;
}

function normalizeAnswer(answer: unknown): RichClosedAnswer {
  if (!isRecord(answer) || hasForbiddenSubmitField(answer)) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }

  const questionId = readRequiredString(answer.questionId);
  const questionKind = readRequiredString(answer.questionKind);

  switch (questionKind) {
    case 'single_choice':
    case 'case_qualification':
      return {
        questionId,
        questionKind,
        choiceId: readRequiredString(answer.choiceId),
      };
    case 'multiple_choice':
      return {
        questionId,
        questionKind,
        choiceIds: readStringArray(answer.choiceIds),
      };
    case 'matching':
      return {
        questionId,
        questionKind,
        pairs: readPairs(answer.pairs),
      };
    case 'ordering':
      return {
        questionId,
        questionKind,
        orderedIds: readStringArray(answer.orderedIds),
      };
    case 'error_detection':
      return {
        questionId,
        questionKind,
        errorId: readRequiredString(answer.errorId),
      };
    default:
      throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }
}

function scoreQuestion(
  question: RichClosedQuestion,
  answer: RichClosedAnswer,
): RichClosedCorrectionItem {
  if (question.questionKind !== answer.questionKind) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }

  switch (question.questionKind) {
    case 'single_choice': {
      const singleAnswer = answer as Extract<
        RichClosedAnswer,
        { questionKind: 'single_choice' }
      >;
      return buildCorrectionItem({
        question,
        answer: singleAnswer,
        isCorrect: singleAnswer.choiceId === question.correctChoiceId,
        correction: { correctChoiceId: question.correctChoiceId },
      });
    }
    case 'case_qualification': {
      const caseAnswer = answer as Extract<
        RichClosedAnswer,
        { questionKind: 'case_qualification' }
      >;
      return buildCorrectionItem({
        question,
        answer: caseAnswer,
        isCorrect: caseAnswer.choiceId === question.correctChoiceId,
        correction: { correctChoiceId: question.correctChoiceId },
      });
    }
    case 'error_detection': {
      const errorAnswer = answer as Extract<
        RichClosedAnswer,
        { questionKind: 'error_detection' }
      >;
      return buildCorrectionItem({
        question,
        answer: errorAnswer,
        isCorrect: errorAnswer.errorId === question.correctErrorId,
        correction: { correctErrorId: question.correctErrorId },
      });
    }
    case 'multiple_choice': {
      const multipleAnswer = answer as Extract<
        RichClosedAnswer,
        { questionKind: 'multiple_choice' }
      >;
      assertKnownIds(
        multipleAnswer.choiceIds,
        question.choices.map((choice) => choice.id),
      );

      return buildCorrectionItem({
        question,
        answer: multipleAnswer,
        isCorrect: areStringSetsEqual(
          multipleAnswer.choiceIds,
          question.correctChoiceIds,
        ),
        correction: { correctChoiceIds: [...question.correctChoiceIds] },
      });
    }
    case 'matching': {
      const matchingAnswer = answer as Extract<
        RichClosedAnswer,
        { questionKind: 'matching' }
      >;
      assertKnownPairs(matchingAnswer.pairs, question);

      return buildCorrectionItem({
        question,
        answer: matchingAnswer,
        isCorrect: arePairsEqual(matchingAnswer.pairs, question.correctPairs),
        correction: { correctPairs: clonePairs(question.correctPairs) },
      });
    }
    case 'ordering': {
      const orderingAnswer = answer as Extract<
        RichClosedAnswer,
        { questionKind: 'ordering' }
      >;
      assertKnownIds(
        orderingAnswer.orderedIds,
        question.items.map((item) => item.id),
      );

      if (orderingAnswer.orderedIds.length !== question.items.length) {
        throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
      }

      return buildCorrectionItem({
        question,
        answer: orderingAnswer,
        isCorrect: areStringArraysEqual(
          orderingAnswer.orderedIds,
          question.correctOrder,
        ),
        correction: { correctOrder: [...question.correctOrder] },
      });
    }
  }
}

function buildCorrectionItem(input: {
  question: RichClosedQuestion;
  answer: RichClosedAnswer;
  isCorrect: boolean;
  correction: RichClosedCorrectionPayload;
}): RichClosedCorrectionItem {
  return {
    questionId: input.question.id,
    questionKind: input.question.questionKind,
    prompt: input.question.prompt,
    submittedAnswer: cloneAnswer(input.answer),
    isCorrect: input.isCorrect,
    partialScore: input.isCorrect ? 1 : 0,
    explanation: input.question.explanation,
    sourceChunkIds: [...input.question.sourceChunkIds],
    correction: input.correction,
  };
}

function assertKnownIds(submittedIds: string[], knownIds: string[]) {
  if (
    submittedIds.length === 0 ||
    hasDuplicates(submittedIds) ||
    submittedIds.some((id) => !knownIds.includes(id))
  ) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }
}

function assertKnownPairs(
  pairs: RichClosedPair[],
  question: Extract<RichClosedQuestion, { questionKind: 'matching' }>,
) {
  const leftIds = question.leftItems.map((item) => item.id);
  const rightIds = question.rightItems.map((item) => item.id);
  const submittedLeftIds = pairs.map((pair) => pair.leftId);
  const submittedRightIds = pairs.map((pair) => pair.rightId);

  if (
    pairs.length === 0 ||
    pairs.length !== question.correctPairs.length ||
    hasDuplicates(submittedLeftIds) ||
    hasDuplicates(submittedRightIds) ||
    pairs.some(
      (pair) =>
        !leftIds.includes(pair.leftId) || !rightIds.includes(pair.rightId),
    )
  ) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }
}

function readRequiredString(value: unknown): string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }

  return value.trim();
}

function readStringArray(value: unknown): string[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }

  return value.map(readRequiredString);
}

function readPairs(value: unknown): RichClosedPair[] {
  if (!Array.isArray(value) || value.length === 0) {
    throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
  }

  return value.map((pair) => {
    if (!isRecord(pair)) {
      throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
    }

    return {
      leftId: readRequiredString(pair.leftId),
      rightId: readRequiredString(pair.rightId),
    };
  });
}

function hasForbiddenSubmitField(value: unknown): boolean {
  if (Array.isArray(value)) {
    return value.some(hasForbiddenSubmitField);
  }

  if (!isRecord(value)) {
    return false;
  }

  return Object.entries(value).some(([key, nestedValue]) => {
    if (
      key.startsWith('correct') ||
      key === 'correctionPayload' ||
      key === 'explanation' ||
      key === 'feedback' ||
      key === 'choiceFeedback' ||
      key === 'modelAnswer' ||
      key === 'answerText' ||
      key === 'freeTextAnswer' ||
      key === 'textAnswer' ||
      key === 'score' ||
      key === 'partialScore' ||
      key === 'workedSteps' ||
      key === 'expectedAnswer' ||
      key === 'expectedAnswers'
    ) {
      return true;
    }

    return hasForbiddenSubmitField(nestedValue);
  });
}

function cloneAnswer(answer: RichClosedAnswer): RichClosedAnswer {
  switch (answer.questionKind) {
    case 'single_choice':
    case 'case_qualification':
      return { ...answer };
    case 'multiple_choice':
      return { ...answer, choiceIds: [...answer.choiceIds] };
    case 'matching':
      return { ...answer, pairs: clonePairs(answer.pairs) };
    case 'ordering':
      return { ...answer, orderedIds: [...answer.orderedIds] };
    case 'error_detection':
      return { ...answer };
  }
}

function clonePairs(pairs: RichClosedPair[]): RichClosedPair[] {
  return pairs.map((pair) => ({ ...pair }));
}

function areStringSetsEqual(left: string[], right: string[]): boolean {
  return (
    left.length === right.length &&
    left.every((value) => right.includes(value)) &&
    right.every((value) => left.includes(value))
  );
}

function arePairsEqual(left: RichClosedPair[], right: RichClosedPair[]) {
  return areStringSetsEqual(pairKeys(left), pairKeys(right));
}

function areStringArraysEqual(left: string[], right: string[]) {
  return (
    left.length === right.length &&
    left.every((value, index) => value === right[index])
  );
}

function pairKeys(pairs: RichClosedPair[]): string[] {
  return pairs.map((pair) => `${pair.leftId}:${pair.rightId}`);
}

function hasDuplicates(values: string[]): boolean {
  return new Set(values).size !== values.length;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
````

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts

````ts
export const RICH_CLOSED_EXERCISE_VERSION = 'rich-closed-question-v1';

export type RichClosedExerciseVersion = typeof RICH_CLOSED_EXERCISE_VERSION;

export const RICH_CLOSED_QUESTION_KINDS = [
  'single_choice',
  'multiple_choice',
  'matching',
  'ordering',
  'case_qualification',
  'error_detection',
] as const;

export type RichClosedQuestionKind =
  (typeof RICH_CLOSED_QUESTION_KINDS)[number];

export type RichClosedDifficulty = 'LOW' | 'MEDIUM' | 'HIGH';

export const RICH_CLOSED_COGNITIVE_SKILLS = [
  'memorization',
  'comprehension',
  'comparison',
  'classification',
  'case_application',
  'procedure',
  'error_detection',
  'causality',
] as const;

export type RichClosedCognitiveSkill =
  (typeof RICH_CLOSED_COGNITIVE_SKILLS)[number];

export interface RichClosedChoice {
  id: string;
  label: string;
  feedback?: string | null;
}

export interface RichClosedPublicChoice {
  id: string;
  label: string;
}

export interface RichClosedPair {
  leftId: string;
  rightId: string;
}

export interface RichClosedLabelItem {
  id: string;
  label: string;
}

export interface RichClosedQuestionBase {
  id: string;
  questionKind: RichClosedQuestionKind;
  prompt: string;
  difficulty: RichClosedDifficulty;
  cognitiveSkill: RichClosedCognitiveSkill;
  sourceChunkIds: string[];
}

export interface RichClosedSingleChoiceQuestion extends RichClosedQuestionBase {
  questionKind: 'single_choice';
  choices: RichClosedChoice[];
  correctChoiceId: string;
  explanation: string;
}

export interface RichClosedMultipleChoiceQuestion extends RichClosedQuestionBase {
  questionKind: 'multiple_choice';
  choices: RichClosedChoice[];
  minSelections: number;
  maxSelections: number;
  correctChoiceIds: string[];
  explanation: string;
}

export interface RichClosedMatchingQuestion extends RichClosedQuestionBase {
  questionKind: 'matching';
  leftItems: RichClosedLabelItem[];
  rightItems: RichClosedLabelItem[];
  correctPairs: RichClosedPair[];
  explanation: string;
}

export interface RichClosedOrderingQuestion extends RichClosedQuestionBase {
  questionKind: 'ordering';
  items: RichClosedLabelItem[];
  correctOrder: string[];
  explanation: string;
}

export interface RichClosedCaseQualificationQuestion extends RichClosedQuestionBase {
  questionKind: 'case_qualification';
  caseText: string;
  choices: RichClosedChoice[];
  correctChoiceId: string;
  explanation: string;
}

export interface RichClosedErrorDetectionQuestion extends RichClosedQuestionBase {
  questionKind: 'error_detection';
  statement: string;
  errorOptions: RichClosedChoice[];
  correctErrorId: string;
  explanation: string;
}

export type RichClosedQuestion =
  | RichClosedSingleChoiceQuestion
  | RichClosedMultipleChoiceQuestion
  | RichClosedMatchingQuestion
  | RichClosedOrderingQuestion
  | RichClosedCaseQualificationQuestion
  | RichClosedErrorDetectionQuestion;

export interface RichClosedPublicQuestionBase {
  id: string;
  questionKind: RichClosedQuestionKind;
  prompt: string;
  difficulty: RichClosedDifficulty;
  cognitiveSkill: RichClosedCognitiveSkill;
  sourceChunkIds: string[];
}

export interface RichClosedPublicSingleChoiceQuestion extends RichClosedPublicQuestionBase {
  questionKind: 'single_choice';
  choices: RichClosedPublicChoice[];
}

export interface RichClosedPublicMultipleChoiceQuestion extends RichClosedPublicQuestionBase {
  questionKind: 'multiple_choice';
  choices: RichClosedPublicChoice[];
  minSelections: number;
  maxSelections: number;
}

export interface RichClosedPublicMatchingQuestion extends RichClosedPublicQuestionBase {
  questionKind: 'matching';
  leftItems: RichClosedLabelItem[];
  rightItems: RichClosedLabelItem[];
}

export interface RichClosedPublicOrderingQuestion extends RichClosedPublicQuestionBase {
  questionKind: 'ordering';
  items: RichClosedLabelItem[];
}

export interface RichClosedPublicCaseQualificationQuestion extends RichClosedPublicQuestionBase {
  questionKind: 'case_qualification';
  caseText: string;
  choices: RichClosedPublicChoice[];
}

export interface RichClosedPublicErrorDetectionQuestion extends RichClosedPublicQuestionBase {
  questionKind: 'error_detection';
  statement: string;
  errorOptions: RichClosedPublicChoice[];
}

export type RichClosedPublicQuestion =
  | RichClosedPublicSingleChoiceQuestion
  | RichClosedPublicMultipleChoiceQuestion
  | RichClosedPublicMatchingQuestion
  | RichClosedPublicOrderingQuestion
  | RichClosedPublicCaseQualificationQuestion
  | RichClosedPublicErrorDetectionQuestion;

export type RichClosedAnswer =
  | {
      questionId: string;
      questionKind: 'single_choice';
      choiceId: string;
    }
  | {
      questionId: string;
      questionKind: 'case_qualification';
      choiceId: string;
    }
  | {
      questionId: string;
      questionKind: 'multiple_choice';
      choiceIds: string[];
    }
  | {
      questionId: string;
      questionKind: 'matching';
      pairs: RichClosedPair[];
    }
  | {
      questionId: string;
      questionKind: 'ordering';
      orderedIds: string[];
    }
  | {
      questionId: string;
      questionKind: 'error_detection';
      errorId: string;
    };

export interface RichClosedCorrection {
  questionId: string;
  questionKind: RichClosedQuestionKind;
  isCorrect: boolean;
  partialScore?: number;
  explanation: string;
}

export type RichClosedCorrectionPayload =
  | { correctChoiceId: string }
  | { correctChoiceIds: string[] }
  | { correctPairs: RichClosedPair[] }
  | { correctOrder: string[] }
  | { correctErrorId: string };

export interface RichClosedCorrectionItem {
  questionId: string;
  questionKind: RichClosedQuestionKind;
  prompt: string;
  submittedAnswer: RichClosedAnswer | null;
  isCorrect: boolean;
  partialScore: number;
  explanation: string;
  sourceChunkIds: string[];
  correction: RichClosedCorrectionPayload;
}

export interface RichClosedExerciseResult {
  sessionId: string;
  type: 'rich_closed_exercise';
  status: 'completed';
  correctAnswers: number;
  totalQuestions: number;
  score: number;
  items: RichClosedCorrectionItem[];
}

export interface RichClosedExercise {
  id: string;
  version: RichClosedExerciseVersion;
  title: string;
  subjectId?: string;
  documentId?: string | null;
  knowledgeUnitId?: string;
  questions: RichClosedQuestion[];
}

export interface RichClosedPublicExercise {
  id: string;
  version: RichClosedExerciseVersion;
  title: string;
  subjectId?: string;
  documentId?: string | null;
  knowledgeUnitId?: string;
  questions: RichClosedPublicQuestion[];
}

export interface RichClosedPublicExerciseEnvelope extends RichClosedPublicExercise {
  sessionId: string;
  type: 'rich_closed_exercise';
}

export type RichClosedExerciseValidationSeverity = 'error' | 'warning';

export interface RichClosedExerciseValidationIssue {
  code: string;
  message: string;
  path?: string;
  severity: RichClosedExerciseValidationSeverity;
}

export interface RichClosedExerciseValidationResult {
  accepted: boolean;
  issues: RichClosedExerciseValidationIssue[];
}
````

### api/src/modules/activities/application/rich-closed-questions/start-rich-closed-exercise.use-case.spec.ts

````ts
import type { RevisionRepository } from '../../../revision/application/revision.repository';
import { KnowledgeUnit } from '../../../revision/domain/knowledge-unit.entity';
import type { ActivitiesRepository } from '../activities.repository';
import {
  RICH_CLOSED_SOURCE_CONTEXT_EMPTY,
  RICH_CLOSED_START_INVALID_INPUT,
} from './rich-closed-question-errors';
import { richClosedExerciseFixture } from './rich-closed-question.fixtures';
import type { RichClosedQuestionGenerator } from './rich-closed-question-generator';
import { StartRichClosedExerciseUseCase } from './start-rich-closed-exercise.use-case';

describe('StartRichClosedExerciseUseCase', () => {
  it('starts a rich closed exercise with the default V1-A mix', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const generator = createGenerator();

    const result = await new StartRichClosedExerciseUseCase(
      activitiesRepository,
      revisionRepository,
      generator,
    ).execute({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    });

    const [generationInput] = generator.generate.mock.calls[0] ?? [];
    expect(generationInput).toMatchObject({
      studentId: 'student-1',
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnit: {
        id: 'unit-1',
        sourceChunkIds: ['chunk-1'],
      },
      chunks: [
        {
          id: 'chunk-1',
          index: 0,
          text: 'La séparation des pouvoirs structure les régimes.',
          pageNumber: 1,
        },
      ],
      questionCount: 6,
      complexityProfile: 'exam',
      questionTypeMix: {
        single_choice: 1,
        multiple_choice: 1,
        matching: 1,
        ordering: 1,
        case_qualification: 1,
        error_detection: 1,
      },
    });
    expect(
      activitiesRepository.createRichClosedExerciseSession.mock.calls[0]?.[0],
    ).toMatchObject({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
      exercise: richClosedExerciseFixture(),
    });
    expect(result.type).toBe('rich_closed_exercise');
  });

  it('accepts an explicit question type mix', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const generator = createGenerator();

    await new StartRichClosedExerciseUseCase(
      activitiesRepository,
      revisionRepository,
      generator,
    ).execute({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      questionCount: 6,
      complexityProfile: 'advanced',
      questionTypeMix: {
        single_choice: 1,
        multiple_choice: 1,
        matching: 1,
        ordering: 1,
        case_qualification: 1,
        error_detection: 1,
      },
    });

    expect(generator.generate.mock.calls[0]?.[0]).toMatchObject({
      questionCount: 6,
      complexityProfile: 'advanced',
      questionTypeMix: {
        single_choice: 1,
        multiple_choice: 1,
        matching: 1,
        ordering: 1,
        case_qualification: 1,
        error_detection: 1,
      },
    });
  });

  it('rejects an incoherent explicit question type mix before calling the generator', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const generator = createGenerator();

    await expect(
      new StartRichClosedExerciseUseCase(
        activitiesRepository,
        revisionRepository,
        generator,
      ).execute({
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        questionCount: 6,
        questionTypeMix: {
          single_choice: 6,
          multiple_choice: 1,
        },
      }),
    ).rejects.toThrow(RICH_CLOSED_START_INVALID_INPUT);
    expect(generator.generate.mock.calls).toHaveLength(0);
  });

  it('rejects unavailable knowledge units', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const generator = createGenerator();
    revisionRepository.findKnowledgeUnits.mockResolvedValue([]);

    await expect(
      new StartRichClosedExerciseUseCase(
        activitiesRepository,
        revisionRepository,
        generator,
      ).execute({
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      }),
    ).rejects.toThrow(RICH_CLOSED_START_INVALID_INPUT);
    expect(generator.generate.mock.calls).toHaveLength(0);
  });

  it('rejects source-empty contexts before calling the generator', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const generator = createGenerator();
    activitiesRepository.findRichClosedGenerationContext.mockResolvedValue({
      documentId: 'document-1',
      knowledgeUnit: Object.assign(knowledgeUnit(), {
        difficulty: 'MEDIUM' as const,
        sourceChunkIds: [],
      }),
      chunks: [],
    });

    await expect(
      new StartRichClosedExerciseUseCase(
        activitiesRepository,
        revisionRepository,
        generator,
      ).execute({
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      }),
    ).rejects.toThrow(RICH_CLOSED_SOURCE_CONTEXT_EMPTY);
    expect(generator.generate.mock.calls).toHaveLength(0);
  });

  it('rejects an explicit document outside the source context', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const generator = createGenerator();

    await expect(
      new StartRichClosedExerciseUseCase(
        activitiesRepository,
        revisionRepository,
        generator,
      ).execute({
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        documentId: 'other-document',
      }),
    ).rejects.toThrow(RICH_CLOSED_START_INVALID_INPUT);
    expect(generator.generate.mock.calls).toHaveLength(0);
  });
});

function createActivitiesRepository(): jest.Mocked<ActivitiesRepository> {
  return {
    findDiagnosticQuizGenerationContext: jest.fn(),
    findOpenQuestionGenerationContext: jest.fn(),
    createDiagnosticQuiz: jest.fn(),
    createOpenQuestionActivity: jest.fn(),
    submitResult: jest.fn(),
    findOpenAnswerEvaluationContext: jest.fn(),
    saveOpenAnswerEvaluation: jest.fn(),
    findRichClosedGenerationContext: jest.fn().mockResolvedValue({
      documentId: 'document-1',
      knowledgeUnit: Object.assign(knowledgeUnit(), {
        difficulty: 'MEDIUM' as const,
        sourceChunkIds: ['chunk-1'],
      }),
      chunks: [
        {
          id: 'chunk-1',
          index: 0,
          text: 'La séparation des pouvoirs structure les régimes.',
          pageNumber: 1,
        },
      ],
    }),
    createRichClosedExerciseSession: jest.fn().mockResolvedValue({
      sessionId: 'rich-session-1',
      type: 'rich_closed_exercise',
      ...richClosedExerciseFixture(),
    }),
    getRichClosedExerciseForStudent: jest.fn(),
    getInternalRichClosedExerciseForStudent: jest.fn(),
    saveRichClosedExerciseResult: jest.fn(),
    getRichClosedExerciseResultForStudent: jest.fn(),
  };
}

function createRevisionRepository(): jest.Mocked<RevisionRepository> {
  return {
    getActiveGoal: jest.fn(),
    saveGoal: jest.fn(),
    findKnowledgeUnits: jest.fn().mockResolvedValue([knowledgeUnit()]),
    findMasteryStates: jest.fn(),
    upsertMastery: jest.fn(),
  };
}

function createGenerator(): jest.Mocked<RichClosedQuestionGenerator> {
  return {
    generate: jest.fn().mockResolvedValue(richClosedExerciseFixture()),
  };
}

function knowledgeUnit() {
  return new KnowledgeUnit({
    id: 'unit-1',
    subjectId: 'subject-1',
    title: 'Séparation des pouvoirs',
    summary: 'La séparation des pouvoirs structure les régimes politiques.',
  });
}
````

### api/src/modules/activities/application/rich-closed-questions/start-rich-closed-exercise.use-case.ts

````ts
import { Inject, Injectable } from '@nestjs/common';
import {
  REVISION_REPOSITORY,
  type RevisionRepository,
} from '../../../revision/application/revision.repository';
import type { KnowledgeUnit } from '../../../revision/domain/knowledge-unit.entity';
import {
  ACTIVITIES_REPOSITORY,
  type ActivitiesRepository,
} from '../activities.repository';
import {
  RICH_CLOSED_SOURCE_CONTEXT_EMPTY,
  RICH_CLOSED_START_INVALID_INPUT,
} from './rich-closed-question-errors';
import { resolveRichClosedQuestionTypeMix } from './rich-closed-question-generation-profile';
import {
  RICH_CLOSED_QUESTION_GENERATOR,
  type RichClosedComplexityProfile,
  type RichClosedQuestionGenerator,
} from './rich-closed-question-generator';
import { evaluateRichClosedExerciseQuality } from './rich-closed-question-quality-gate';
import {
  RICH_CLOSED_QUESTION_KINDS,
  type RichClosedPublicExerciseEnvelope,
  type RichClosedQuestionKind,
} from './rich-closed-question.types';
import { validateRichClosedExercise } from './rich-closed-question.validator';

export interface StartRichClosedExerciseInput {
  studentId: string;
  subjectId: string;
  documentId?: string | null;
  knowledgeUnitId: string;
  questionCount?: number;
  complexityProfile?: RichClosedComplexityProfile;
  questionTypeMix?: Partial<Record<RichClosedQuestionKind, number>>;
}

const DEFAULT_RICH_CLOSED_QUESTION_COUNT = 6;

@Injectable()
export class StartRichClosedExerciseUseCase {
  constructor(
    @Inject(ACTIVITIES_REPOSITORY)
    private readonly activitiesRepository: ActivitiesRepository,
    @Inject(REVISION_REPOSITORY)
    private readonly revisionRepository: RevisionRepository,
    @Inject(RICH_CLOSED_QUESTION_GENERATOR)
    private readonly generator: RichClosedQuestionGenerator,
  ) {}

  async execute(
    input: StartRichClosedExerciseInput,
  ): Promise<RichClosedPublicExerciseEnvelope> {
    const questionCount =
      input.questionCount ?? DEFAULT_RICH_CLOSED_QUESTION_COUNT;
    const complexityProfile = input.complexityProfile ?? 'exam';
    const questionTypeMix =
      input.questionTypeMix ??
      resolveRichClosedQuestionTypeMix({
        questionCount,
        complexityProfile,
      });
    assertRichClosedQuestionTypeMix({
      questionCount,
      questionTypeMix,
    });
    const knowledgeUnit = await this.findKnowledgeUnit(input);
    const generationContext =
      await this.activitiesRepository.findRichClosedGenerationContext({
        studentId: input.studentId,
        subjectId: input.subjectId,
        knowledgeUnitId: knowledgeUnit.id,
      });

    if (!generationContext || generationContext.chunks.length === 0) {
      throw new Error(RICH_CLOSED_SOURCE_CONTEXT_EMPTY);
    }

    const documentId = input.documentId ?? generationContext.documentId;

    if (
      input.documentId !== undefined &&
      input.documentId !== generationContext.documentId
    ) {
      throw new Error(RICH_CLOSED_START_INVALID_INPUT);
    }

    const exercise = await this.generator.generate({
      studentId: input.studentId,
      subjectId: input.subjectId,
      documentId,
      knowledgeUnit: generationContext.knowledgeUnit,
      chunks: generationContext.chunks.map((chunk) => ({
        ...chunk,
        pageNumber: chunk.pageNumber ?? null,
      })),
      questionCount,
      questionTypeMix,
      complexityProfile,
    });
    const knownSourceChunkIds = new Set(
      generationContext.chunks.map((chunk) => chunk.id),
    );
    const validation = validateRichClosedExercise(exercise, {
      knownSourceChunkIds,
    });

    if (!validation.accepted) {
      throw new Error(RICH_CLOSED_START_INVALID_INPUT);
    }

    const quality = evaluateRichClosedExerciseQuality(exercise, {
      knownSourceChunkIds,
    });

    if (!quality.accepted) {
      throw new Error(RICH_CLOSED_START_INVALID_INPUT);
    }

    return this.activitiesRepository.createRichClosedExerciseSession({
      studentId: input.studentId,
      subjectId: input.subjectId,
      knowledgeUnitId: knowledgeUnit.id,
      documentId,
      exercise,
      qualityMetrics: quality.metrics,
      generationMetadata: exercise.metadata,
    });
  }

  private async findKnowledgeUnit(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<KnowledgeUnit> {
    const knowledgeUnits = await this.revisionRepository.findKnowledgeUnits(
      input.studentId,
    );
    const knowledgeUnit = knowledgeUnits.find(
      (unit) =>
        unit.id === input.knowledgeUnitId && unit.subjectId === input.subjectId,
    );

    if (!knowledgeUnit) {
      throw new Error(RICH_CLOSED_START_INVALID_INPUT);
    }

    return knowledgeUnit;
  }
}

export function assertRichClosedQuestionTypeMix(input: {
  questionCount: number;
  questionTypeMix: Partial<Record<RichClosedQuestionKind, number>>;
}): void {
  const entries = Object.entries(input.questionTypeMix);
  const allowedKinds = new Set<string>(RICH_CLOSED_QUESTION_KINDS);

  if (entries.length === 0) {
    throw new Error(RICH_CLOSED_START_INVALID_INPUT);
  }

  for (const [kind, count] of entries) {
    if (
      !allowedKinds.has(kind) ||
      !Number.isInteger(count) ||
      Number(count) < 0
    ) {
      throw new Error(RICH_CLOSED_START_INVALID_INPUT);
    }
  }

  const total = entries.reduce((sum, [, count]) => sum + Number(count), 0);

  if (total !== input.questionCount) {
    throw new Error(RICH_CLOSED_START_INVALID_INPUT);
  }
}
````

### api/src/modules/activities/application/rich-closed-questions/submit-rich-closed-exercise.use-case.spec.ts

````ts
import type { ActivitiesRepository } from '../activities.repository';
import {
  RICH_CLOSED_SESSION_ALREADY_COMPLETED,
  RICH_CLOSED_SESSION_NOT_COMPLETED,
  RICH_CLOSED_SUBMIT_INVALID_INPUT,
} from './rich-closed-question-errors';
import { richClosedExerciseFixture } from './rich-closed-question.fixtures';
import { scoreRichClosedExerciseSubmission } from './rich-closed-question-scorer';
import type { RichClosedAnswer } from './rich-closed-question.types';
import { GetRichClosedExerciseResultUseCase } from './get-rich-closed-exercise-result.use-case';
import { GetRichClosedExerciseUseCase } from './get-rich-closed-exercise.use-case';
import { SubmitRichClosedExerciseUseCase } from './submit-rich-closed-exercise.use-case';

describe('rich closed exercise use cases', () => {
  it('gets public pre-submit exercise without correction', async () => {
    const repository = createActivitiesRepository();
    const result = await new GetRichClosedExerciseUseCase(repository).execute({
      studentId: 'student-1',
      sessionId: 'rich-session-1',
    });

    expect(
      repository.getRichClosedExerciseForStudent.mock.calls[0]?.[0],
    ).toEqual({
      studentId: 'student-1',
      sessionId: 'rich-session-1',
    });
    expect(JSON.stringify(result)).not.toContain('correctChoiceId');
    expect(JSON.stringify(result)).not.toContain('explanation');
  });

  it('scores and persists a submitted exercise', async () => {
    const repository = createActivitiesRepository();
    const result = await new SubmitRichClosedExerciseUseCase(
      repository,
    ).execute({
      studentId: 'student-1',
      sessionId: 'rich-session-1',
      answers: correctAnswers(),
    });

    expect(
      repository.saveRichClosedExerciseResult.mock.calls[0]?.[0],
    ).toMatchObject({
      studentId: 'student-1',
      sessionId: 'rich-session-1',
      answers: correctAnswers(),
      result: {
        correctAnswers: 6,
        totalQuestions: 6,
        score: 1,
      },
    });
    expect(result.correctAnswers).toBe(6);
  });

  it('rejects invalid submitted answers', async () => {
    const repository = createActivitiesRepository();

    await expect(
      new SubmitRichClosedExerciseUseCase(repository).execute({
        studentId: 'student-1',
        sessionId: 'rich-session-1',
        answers: [
          {
            questionId: 'unknown-question',
            questionKind: 'single_choice',
            choiceId: 'choice-a',
          },
        ],
      }),
    ).rejects.toThrow(RICH_CLOSED_SUBMIT_INVALID_INPUT);
    expect(repository.saveRichClosedExerciseResult.mock.calls).toHaveLength(0);
  });

  it('rejects double submit when the session is not started', async () => {
    const repository = createActivitiesRepository();
    repository.getInternalRichClosedExerciseForStudent.mockResolvedValue({
      sessionId: 'rich-session-1',
      status: 'COMPLETED',
      exercise: richClosedExerciseFixture(),
      result: scoreRichClosedExerciseSubmission({
        sessionId: 'rich-session-1',
        exercise: richClosedExerciseFixture(),
        answers: correctAnswers(),
      }),
    });

    await expect(
      new SubmitRichClosedExerciseUseCase(repository).execute({
        studentId: 'student-1',
        sessionId: 'rich-session-1',
        answers: correctAnswers(),
      }),
    ).rejects.toThrow(RICH_CLOSED_SESSION_ALREADY_COMPLETED);
    expect(repository.saveRichClosedExerciseResult.mock.calls).toHaveLength(0);
  });

  it('gets a post-submit result or rejects an unsubmitted session', async () => {
    const repository = createActivitiesRepository();

    await expect(
      new GetRichClosedExerciseResultUseCase(repository).execute({
        studentId: 'student-1',
        sessionId: 'rich-session-1',
      }),
    ).resolves.toMatchObject({
      sessionId: 'rich-session-1',
      status: 'completed',
    });

    repository.getRichClosedExerciseResultForStudent.mockRejectedValueOnce(
      new Error(RICH_CLOSED_SESSION_NOT_COMPLETED),
    );
    await expect(
      new GetRichClosedExerciseResultUseCase(repository).execute({
        studentId: 'student-1',
        sessionId: 'rich-session-2',
      }),
    ).rejects.toThrow(RICH_CLOSED_SESSION_NOT_COMPLETED);
  });
});

function createActivitiesRepository(): jest.Mocked<ActivitiesRepository> {
  const exercise = richClosedExerciseFixture();
  const result = scoreRichClosedExerciseSubmission({
    sessionId: 'rich-session-1',
    exercise,
    answers: correctAnswers(),
  });

  return {
    findDiagnosticQuizGenerationContext: jest.fn(),
    findOpenQuestionGenerationContext: jest.fn(),
    createDiagnosticQuiz: jest.fn(),
    createOpenQuestionActivity: jest.fn(),
    submitResult: jest.fn(),
    findOpenAnswerEvaluationContext: jest.fn(),
    saveOpenAnswerEvaluation: jest.fn(),
    findRichClosedGenerationContext: jest.fn(),
    createRichClosedExerciseSession: jest.fn(),
    getRichClosedExerciseForStudent: jest.fn().mockResolvedValue({
      sessionId: 'rich-session-1',
      type: 'rich_closed_exercise',
      id: exercise.id,
      version: exercise.version,
      title: exercise.title,
      subjectId: exercise.subjectId,
      documentId: exercise.documentId,
      knowledgeUnitId: exercise.knowledgeUnitId,
      questions: [],
    }),
    getInternalRichClosedExerciseForStudent: jest.fn().mockResolvedValue({
      sessionId: 'rich-session-1',
      status: 'STARTED',
      exercise,
      result: null,
    }),
    saveRichClosedExerciseResult: jest.fn().mockResolvedValue(result),
    getRichClosedExerciseResultForStudent: jest.fn().mockResolvedValue(result),
  };
}

function correctAnswers(): RichClosedAnswer[] {
  return [
    {
      questionId: 'single-1',
      questionKind: 'single_choice',
      choiceId: 'choice-a',
    },
    {
      questionId: 'multiple-1',
      questionKind: 'multiple_choice',
      choiceIds: ['choice-a', 'choice-b'],
    },
    {
      questionId: 'matching-1',
      questionKind: 'matching',
      pairs: [
        { leftId: 'left-1', rightId: 'right-1' },
        { leftId: 'left-2', rightId: 'right-2' },
        { leftId: 'left-3', rightId: 'right-3' },
      ],
    },
    {
      questionId: 'ordering-1',
      questionKind: 'ordering',
      orderedIds: ['item-1', 'item-2', 'item-3'],
    },
    {
      questionId: 'case-1',
      questionKind: 'case_qualification',
      choiceId: 'choice-a',
    },
    {
      questionId: 'error-1',
      questionKind: 'error_detection',
      errorId: 'error-a',
    },
  ];
}
````

### api/src/modules/activities/application/rich-closed-questions/submit-rich-closed-exercise.use-case.ts

````ts
import { Inject, Injectable } from '@nestjs/common';
import {
  ACTIVITIES_REPOSITORY,
  type ActivitiesRepository,
} from '../activities.repository';
import {
  RICH_CLOSED_SESSION_ALREADY_COMPLETED,
  RICH_CLOSED_SUBMIT_INVALID_INPUT,
} from './rich-closed-question-errors';
import { scoreRichClosedExerciseSubmission } from './rich-closed-question-scorer';
import type {
  RichClosedAnswer,
  RichClosedExerciseResult,
} from './rich-closed-question.types';

@Injectable()
export class SubmitRichClosedExerciseUseCase {
  constructor(
    @Inject(ACTIVITIES_REPOSITORY)
    private readonly activitiesRepository: ActivitiesRepository,
  ) {}

  async execute(input: {
    studentId: string;
    sessionId: string;
    answers: RichClosedAnswer[];
  }): Promise<RichClosedExerciseResult> {
    const internal =
      await this.activitiesRepository.getInternalRichClosedExerciseForStudent({
        studentId: input.studentId,
        sessionId: input.sessionId,
      });

    if (internal.status !== 'STARTED' || internal.result) {
      throw new Error(RICH_CLOSED_SESSION_ALREADY_COMPLETED);
    }

    let result: RichClosedExerciseResult;

    try {
      result = scoreRichClosedExerciseSubmission({
        sessionId: input.sessionId,
        exercise: internal.exercise,
        answers: input.answers,
      });
    } catch (error) {
      if (
        error instanceof Error &&
        error.message === RICH_CLOSED_SESSION_ALREADY_COMPLETED
      ) {
        throw error;
      }

      throw new Error(RICH_CLOSED_SUBMIT_INVALID_INPUT);
    }

    return this.activitiesRepository.saveRichClosedExerciseResult({
      studentId: input.studentId,
      sessionId: input.sessionId,
      answers: input.answers,
      result,
    });
  }
}
````

### api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts

````ts
import { PrismaActivitiesRepository } from './prisma-activities.repository';
import { RICH_CLOSED_SESSION_ALREADY_COMPLETED } from '../application/rich-closed-questions/rich-closed-question-errors';
import { richClosedExerciseFixture } from '../application/rich-closed-questions/rich-closed-question.fixtures';
import { scoreRichClosedExerciseSubmission } from '../application/rich-closed-questions/rich-closed-question-scorer';
import type {
  RichClosedAnswer,
  RichClosedExercise,
} from '../application/rich-closed-questions/rich-closed-question.types';

type ActivitySessionRecord = {
  id: string;
  studentId: string;
  subjectId: string;
  knowledgeUnitId: string;
  version: number;
  documentId: string | null;
  generationFlowName: string | null;
  generationProvider: string | null;
  generationModel: string | null;
  generationPromptVersion: string | null;
  generationSchemaVersion: string | null;
  generationInputSize: number | null;
  status: 'STARTED' | 'SUBMITTED' | 'COMPLETED';
  completedAt: Date | null;
};

type RichClosedExercisePayloadRecord = {
  id: string;
  activitySessionId: string;
  version: string;
  title: string;
  subjectId: string;
  documentId: string | null;
  knowledgeUnitId: string;
  exercisePayload: RichClosedExercise;
  generationMetadata: unknown;
  qualityMetrics: unknown;
};

type RichClosedExerciseResultRecord = {
  id: string;
  activitySessionId: string;
  answersPayload: RichClosedAnswer[];
  correctionPayload: ReturnType<
    typeof scoreRichClosedExerciseSubmission
  >['items'];
  correctAnswers: number;
  totalQuestions: number;
  score: number;
  createdAt: Date;
};

type QuestionRecord = {
  id: string;
  sessionId: string;
  subjectId: string | null;
  documentId: string | null;
  knowledgeUnitId: string;
  prompt: string;
  difficulty: 'LOW' | 'MEDIUM' | 'HIGH' | null;
  displayOrder: number;
  choices: Array<{ id: string; label: string; feedback?: string | null }>;
  selectionMode?: 'SINGLE' | 'MULTIPLE';
  minSelections?: number | null;
  maxSelections?: number | null;
  correctChoiceId: string | null;
  correctChoiceIds?: string[] | null;
  explanation: string;
  sources?: QuestionSourceRecord[];
  visuals?: QuestionVisualRecord[];
};

type ActivityResultRecord = {
  id: string;
  sessionId: string;
  correctAnswers: number;
  totalQuestions: number;
  score: number | null;
  createdAt: Date;
};

type DocumentChunkRecord = {
  id: string;
  documentId: string;
  subjectId: string;
  index: number;
  pageNumber: number | null;
  text: string;
};

type QuestionSourceRecord = {
  questionId: string;
  subjectId: string;
  chunkId: string;
  chunk: DocumentChunkRecord;
};

type QuestionVisualRecord = {
  id: string;
  questionId: string;
  type: 'IMAGE' | 'CHART' | 'DIAGRAM';
  displayOrder: number;
  payload: Record<string, unknown>;
  sources?: QuestionVisualSourceRecord[];
};

type QuestionVisualSourceRecord = {
  visualId: string;
  subjectId: string;
  chunkId: string;
  chunk: DocumentChunkRecord;
};

type QuestionCreatePayload = {
  data: {
    sessionId: string;
    knowledgeUnitId: string;
    prompt: string;
    choices: Array<{ id: string; label: string }>;
    selectionMode?: 'SINGLE' | 'MULTIPLE';
    minSelections?: number | null;
    maxSelections?: number | null;
    correctChoiceId?: string | null;
    correctChoiceIds?: string[] | null;
    explanation: string;
  };
};

type ActivitySessionCreatePayload = {
  data: Record<string, unknown>;
};

type QuestionVisualCreatePayload = {
  data: {
    questionId: string;
    type: 'IMAGE' | 'CHART' | 'DIAGRAM';
    displayOrder: number;
    payload: Record<string, unknown>;
  };
};

type ActivitySessionUpdatePayload = {
  where: {
    id: string;
  };
  data: {
    status: 'SUBMITTED' | 'COMPLETED';
    completedAt?: Date;
  };
};

type OpenQuestionRecord = {
  id: string;
  sessionId: string;
  studentId: string;
  subjectId: string;
  documentId: string | null;
  knowledgeUnitId: string;
  prompt: string;
  instructions: string | null;
  maxAnswerLength: number;
  version: number;
  sources?: OpenQuestionSourceRecord[];
};

type OpenQuestionSourceRecord = {
  questionId: string;
  subjectId: string;
  chunkId: string;
  chunk: DocumentChunkRecord;
};

type OpenAnswerEvaluationRecord = {
  id: string;
  sessionId: string;
  openQuestionId: string;
  studentId: string;
  subjectId: string;
  answerText: string;
  status: 'PENDING' | 'READY' | 'FAILED';
  score: number | null;
  maxScore: number | null;
  feedback: string | null;
  presentPoints: unknown;
  missingPoints: unknown;
  errors: unknown;
  modelAnswer: string | null;
  advice: string | null;
};

type OpenQuestionCreatePayload = {
  data: {
    sessionId: string;
    studentId: string;
    subjectId: string;
    documentId?: string | null;
    knowledgeUnitId: string;
    prompt: string;
    instructions?: string | null;
    maxAnswerLength: number;
    version: number;
  };
};

type OpenAnswerEvaluationCreatePayload = {
  data: {
    sessionId: string;
    openQuestionId: string;
    studentId: string;
    subjectId: string;
    answerText: string;
    status: 'READY' | 'FAILED';
    score: number | null;
    maxScore: number | null;
    feedback: string | null;
    presentPoints: unknown[];
    missingPoints: unknown[];
    errors: unknown[];
    modelAnswer: string | null;
    advice: string | null;
    generationFlowName?: string;
    generationProvider?: string;
    generationModel?: string;
    generationPromptVersion?: string;
    generationSchemaVersion?: string;
    generationInputSize?: number;
    errorCode?: string;
  };
};

type OpenQuestionSessionRecord = ActivitySessionRecord & {
  openQuestion: OpenQuestionRecord | null;
  openAnswerEvaluation: OpenAnswerEvaluationRecord | null;
  knowledgeUnit?: KnowledgeUnitRecord;
};

type RichClosedExerciseSessionRecord = ActivitySessionRecord & {
  richClosedExercisePayload: RichClosedExercisePayloadRecord | null;
  richClosedExerciseResult: RichClosedExerciseResultRecord | null;
};

type KnowledgeUnitRecord = {
  id: string;
  subjectId: string;
  documentId: string | null;
  title: string;
  summary: string;
  difficulty: 'LOW' | 'MEDIUM' | 'HIGH' | null;
  sources?: Array<{
    chunk: DocumentChunkRecord;
  }>;
};

type SessionWithQuestions = ActivitySessionRecord & {
  questions: QuestionRecord[];
  result: ActivityResultRecord | null;
};

type PrismaActivitiesMock = {
  knowledgeUnit: {
    findFirst: jest.Mock;
  };
  documentChunk: {
    findMany: jest.Mock;
  };
  activitySession: {
    create: jest.Mock<ActivitySessionRecord, [ActivitySessionCreatePayload]>;
    findFirst: jest.Mock;
    update: jest.Mock<ActivitySessionRecord, [ActivitySessionUpdatePayload]>;
  };
  question: {
    create: jest.Mock<QuestionRecord, [QuestionCreatePayload]>;
  };
  questionSource: {
    createMany: jest.Mock;
  };
  questionVisual: {
    create: jest.Mock<QuestionVisualRecord, [QuestionVisualCreatePayload]>;
  };
  questionVisualSource: {
    createMany: jest.Mock;
  };
  openQuestion: {
    create: jest.Mock<OpenQuestionRecord, [OpenQuestionCreatePayload]>;
  };
  openQuestionSource: {
    createMany: jest.Mock;
  };
  openAnswerEvaluation: {
    create: jest.Mock<
      OpenAnswerEvaluationRecord,
      [OpenAnswerEvaluationCreatePayload]
    >;
  };
  questionAnswer: {
    create: jest.Mock;
    createMany: jest.Mock;
  };
  questionAnswerChoice: {
    createMany: jest.Mock;
  };
  activityResult: {
    create: jest.Mock;
  };
  richClosedExercisePayload: {
    create: jest.Mock;
  };
  richClosedExerciseResult: {
    create: jest.Mock;
  };
  $transaction: jest.Mock<Promise<unknown>, [TransactionCallback]>;
};

type TransactionCallback = (tx: PrismaActivitiesMock) => unknown;

describe('PrismaActivitiesRepository', () => {
  const createdAt = new Date('2026-06-12T10:00:00.000Z');

  const createRepository = () => {
    const prisma: PrismaActivitiesMock = {
      knowledgeUnit: {
        findFirst: jest.fn(),
      },
      documentChunk: {
        findMany: jest.fn(),
      },
      activitySession: {
        create: jest.fn<
          ActivitySessionRecord,
          [ActivitySessionCreatePayload]
        >(),
        findFirst: jest.fn(),
        update: jest.fn<
          ActivitySessionRecord,
          [ActivitySessionUpdatePayload]
        >(),
      },
      question: {
        create: jest.fn<QuestionRecord, [QuestionCreatePayload]>(),
      },
      questionSource: {
        createMany: jest.fn(),
      },
      questionVisual: {
        create: jest.fn<QuestionVisualRecord, [QuestionVisualCreatePayload]>(),
      },
      questionVisualSource: {
        createMany: jest.fn(),
      },
      openQuestion: {
        create: jest.fn<OpenQuestionRecord, [OpenQuestionCreatePayload]>(),
      },
      openQuestionSource: {
        createMany: jest.fn(),
      },
      openAnswerEvaluation: {
        create: jest.fn<
          OpenAnswerEvaluationRecord,
          [OpenAnswerEvaluationCreatePayload]
        >(),
      },
      questionAnswer: {
        create: jest.fn(),
        createMany: jest.fn(),
      },
      questionAnswerChoice: {
        createMany: jest.fn(),
      },
      activityResult: {
        create: jest.fn(),
      },
      richClosedExercisePayload: {
        create: jest.fn(),
      },
      richClosedExerciseResult: {
        create: jest.fn(),
      },
      $transaction: jest.fn<Promise<unknown>, [TransactionCallback]>(),
    };
    prisma.$transaction.mockImplementation((callback) =>
      Promise.resolve(callback(prisma)),
    );

    return {
      prisma,
      repository: new PrismaActivitiesRepository(prisma as never),
    };
  };

  const sessionRecord = (
    input: Partial<ActivitySessionRecord> = {},
  ): ActivitySessionRecord => ({
    id: 'session-1',
    studentId: 'student-1',
    subjectId: 'subject-1',
    knowledgeUnitId: 'unit-1',
    version: 1,
    documentId: null,
    generationFlowName: null,
    generationProvider: null,
    generationModel: null,
    generationPromptVersion: null,
    generationSchemaVersion: null,
    generationInputSize: null,
    status: 'STARTED',
    completedAt: null,
    ...input,
  });

  const questionRecord = (
    input: Partial<QuestionRecord> = {},
  ): QuestionRecord => ({
    id: 'question-1',
    sessionId: 'session-1',
    subjectId: 'subject-1',
    documentId: null,
    knowledgeUnitId: 'unit-1',
    prompt:
      'Quelle structure est principalement responsable de la contraction cardiaque ?',
    difficulty: null,
    displayOrder: 0,
    choices: [
      { id: 'a', label: 'Myocarde' },
      { id: 'b', label: 'Pericarde' },
    ],
    correctChoiceId: 'a',
    explanation: 'Le myocarde est le muscle cardiaque.',
    ...input,
  });

  const sessionWithQuestions = (
    input: Partial<SessionWithQuestions> = {},
  ): SessionWithQuestions => ({
    ...sessionRecord(),
    questions: [questionRecord()],
    result: null,
    ...input,
  });

  const resultRecord = (
    input: Partial<ActivityResultRecord> = {},
  ): ActivityResultRecord => ({
    id: 'result-1',
    sessionId: 'session-1',
    correctAnswers: 1,
    totalQuestions: 1,
    score: 1,
    createdAt,
    ...input,
  });

  const chunkRecord = (
    input: Partial<DocumentChunkRecord> = {},
  ): DocumentChunkRecord => ({
    id: 'chunk-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    index: 0,
    pageNumber: null,
    text: 'Article 89 encadre la revision constitutionnelle.',
    ...input,
  });

  const knowledgeUnitRecord = (
    input: Partial<KnowledgeUnitRecord> = {},
  ): KnowledgeUnitRecord => ({
    id: 'unit-1',
    subjectId: 'subject-1',
    documentId: 'document-1',
    title: 'Séparation des pouvoirs',
    summary: 'Résumé.',
    difficulty: null,
    sources: [{ chunk: chunkRecord() }],
    ...input,
  });

  const openQuestionRecord = (
    input: Partial<OpenQuestionRecord> = {},
  ): OpenQuestionRecord => ({
    id: 'open-question-1',
    sessionId: 'session-1',
    studentId: 'student-1',
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-1',
    prompt:
      'Explique avec tes propres mots la notion suivante : Séparation des pouvoirs.',
    instructions:
      'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
    maxAnswerLength: 4000,
    version: 1,
    sources: [
      {
        questionId: 'open-question-1',
        subjectId: 'subject-1',
        chunkId: 'chunk-1',
        chunk: chunkRecord(),
      },
    ],
    ...input,
  });

  const openAnswerEvaluationRecord = (
    input: Partial<OpenAnswerEvaluationRecord> = {},
  ): OpenAnswerEvaluationRecord => ({
    id: 'evaluation-1',
    sessionId: 'session-1',
    openQuestionId: 'open-question-1',
    studentId: 'student-1',
    subjectId: 'subject-1',
    answerText:
      'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
    status: 'PENDING',
    score: null,
    maxScore: null,
    feedback: null,
    presentPoints: [],
    missingPoints: [],
    errors: [],
    modelAnswer: null,
    advice: null,
    ...input,
  });

  const richClosedPayloadRecord = (
    input: Partial<RichClosedExercisePayloadRecord> = {},
  ): RichClosedExercisePayloadRecord => ({
    id: 'rich-payload-1',
    activitySessionId: 'session-1',
    version: 'rich-closed-question-v1',
    title: 'Droit constitutionnel - exercice riche fermé',
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-1',
    exercisePayload: richClosedExerciseFixture(),
    generationMetadata: null,
    qualityMetrics: null,
    ...input,
  });

  const richClosedResultRecord = (
    input: Partial<RichClosedExerciseResultRecord> = {},
  ): RichClosedExerciseResultRecord => {
    const result = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: correctRichClosedAnswers(),
    });

    return {
      id: 'rich-result-1',
      activitySessionId: 'session-1',
      answersPayload: correctRichClosedAnswers(),
      correctionPayload: result.items,
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      score: result.score,
      createdAt,
      ...input,
    };
  };

  const richClosedSessionRecord = (
    input: Partial<RichClosedExerciseSessionRecord> = {},
  ): RichClosedExerciseSessionRecord => ({
    ...sessionRecord({
      type: 'RICH_CLOSED_EXERCISE' as never,
      version: 1,
      documentId: 'document-1',
    }),
    richClosedExercisePayload: richClosedPayloadRecord(),
    richClosedExerciseResult: null,
    ...input,
  });

  const generatedQuizQuestions = (questionCount: number) =>
    Array.from({ length: questionCount }, (_value, index) => ({
      prompt: `Question de revision ${index + 1}`,
      choices: [
        { id: `a-${index + 1}`, label: 'Bonne reponse' },
        { id: `b-${index + 1}`, label: 'Distracteur' },
      ],
      correctChoiceId: `a-${index + 1}`,
      explanation: 'Explication de correction.',
    }));

  it('persists the generated diagnostic quiz after verifying ownership', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue({
      id: 'unit-1',
      subjectId: 'subject-1',
    });
    prisma.activitySession.create.mockResolvedValue(sessionRecord());
    prisma.question.create.mockResolvedValue(
      questionRecord({
        prompt:
          'Quel principe limite le pouvoir constituant derive dans la Constitution de 1958 ?',
        choices: [
          { id: 'a', label: 'La forme republicaine du gouvernement' },
          { id: 'b', label: 'La superiorite du pouvoir reglementaire' },
        ],
        correctChoiceId: 'a',
        explanation:
          'La Constitution interdit de reviser la forme republicaine du gouvernement.',
      }),
    );

    const activity = await repository.createDiagnosticQuiz({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      quiz: {
        title: 'Diagnostic constitutionnel',
        questions: [
          {
            prompt:
              'Quel principe limite le pouvoir constituant derive dans la Constitution de 1958 ?',
            choices: [
              { id: 'a', label: 'La forme republicaine du gouvernement' },
              { id: 'b', label: 'La superiorite du pouvoir reglementaire' },
            ],
            correctChoiceId: 'a',
            explanation:
              'La Constitution interdit de reviser la forme republicaine du gouvernement.',
          },
        ],
      },
    });

    expect(prisma.knowledgeUnit.findFirst).toHaveBeenCalledWith({
      where: {
        id: 'unit-1',
        subjectId: 'subject-1',
        subject: {
          studentId: 'student-1',
        },
      },
    });
    expect(prisma.activitySession.create).toHaveBeenCalledWith({
      data: {
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        type: 'DIAGNOSTIC_QUIZ',
        status: 'STARTED',
      },
    });
    const [questionCreatePayload] = prisma.question.create.mock.calls[0] as
      | [QuestionCreatePayload]
      | [];
    expect(questionCreatePayload?.data).toMatchObject({
      sessionId: 'session-1',
      knowledgeUnitId: 'unit-1',
      prompt:
        'Quel principe limite le pouvoir constituant derive dans la Constitution de 1958 ?',
      choices: [
        { id: 'a', label: 'La forme republicaine du gouvernement' },
        { id: 'b', label: 'La superiorite du pouvoir reglementaire' },
      ],
      correctChoiceId: 'a',
      explanation:
        'La Constitution interdit de reviser la forme republicaine du gouvernement.',
    });
    expect(activity).toMatchObject({
      sessionId: 'session-1',
      type: 'diagnostic_quiz',
      title: 'Diagnostic constitutionnel',
      questions: [{ id: 'question-1' }],
    });
  });

  it('persists a generated diagnostic quiz with ten questions', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue({
      id: 'unit-1',
      subjectId: 'subject-1',
    });
    prisma.activitySession.create.mockResolvedValue(sessionRecord());
    prisma.question.create.mockImplementation(
      ({ data }: QuestionCreatePayload) =>
        questionRecord({
          id: `question-${prisma.question.create.mock.calls.length}`,
          prompt: data.prompt,
          choices: data.choices,
          correctChoiceId: data.correctChoiceId,
          explanation: data.explanation,
        }),
    );

    const activity = await repository.createDiagnosticQuiz({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      quiz: {
        title: 'Diagnostic constitutionnel',
        questions: generatedQuizQuestions(10),
      },
    });

    expect(prisma.question.create).toHaveBeenCalledTimes(10);
    expect(activity.questions).toHaveLength(10);
    expect(activity.questions[9]?.id).toBe('question-10');
  });

  it('persists a sourced v2 diagnostic quiz without leaking correction fields before submit', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue({
      id: 'unit-1',
      subjectId: 'subject-1',
    });
    prisma.documentChunk.findMany.mockResolvedValue([chunkRecord()]);
    prisma.activitySession.create.mockResolvedValue(
      sessionRecord({
        version: 2,
        documentId: 'document-1',
        generationFlowName: 'diagnosticQuizGeneration',
        generationProvider: 'google-genai',
        generationModel: 'googleai/custom-model',
        generationPromptVersion: 'diagnostic-quiz-v2',
        generationSchemaVersion: 'diagnostic-quiz-v2',
        generationInputSize: 1200,
      }),
    );
    prisma.question.create.mockResolvedValue(
      questionRecord({
        documentId: 'document-1',
        difficulty: 'MEDIUM',
        choices: [
          {
            id: 'a',
            label: 'La forme republicaine du gouvernement',
            feedback: 'Correct.',
          },
          {
            id: 'b',
            label: 'La suppression du Parlement',
            feedback: 'Incorrect.',
          },
        ],
        sources: [
          {
            questionId: 'question-1',
            subjectId: 'subject-1',
            chunkId: 'chunk-1',
            chunk: chunkRecord(),
          },
        ],
      }),
    );

    const activity = await repository.createDiagnosticQuiz({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
      quiz: {
        title: 'Diagnostic constitutionnel',
        version: 2,
        metadata: {
          flowName: 'diagnosticQuizGeneration',
          provider: 'google-genai',
          model: 'googleai/custom-model',
          promptVersion: 'diagnostic-quiz-v2',
          schemaVersion: 'diagnostic-quiz-v2',
          inputSize: 1200,
        },
        questions: [
          {
            prompt:
              'Quelle limite materielle encadre la revision constitutionnelle ?',
            difficulty: 'MEDIUM',
            choices: [
              {
                id: 'a',
                label: 'La forme republicaine du gouvernement',
                feedback: 'Correct.',
              },
              {
                id: 'b',
                label: 'La suppression du Parlement',
                feedback: 'Incorrect.',
              },
            ],
            correctChoiceId: 'a',
            explanation: 'La Constitution protege cette limite materielle.',
            sourceChunkIds: ['chunk-1'],
          },
        ],
      },
    });

    expect(prisma.activitySession.create).toHaveBeenCalledWith({
      data: {
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        type: 'DIAGNOSTIC_QUIZ',
        status: 'STARTED',
        version: 2,
        documentId: 'document-1',
        generationFlowName: 'diagnosticQuizGeneration',
        generationProvider: 'google-genai',
        generationModel: 'googleai/custom-model',
        generationPromptVersion: 'diagnostic-quiz-v2',
        generationSchemaVersion: 'diagnostic-quiz-v2',
        generationInputSize: 1200,
      },
    });
    expect(prisma.documentChunk.findMany).toHaveBeenCalledWith({
      where: {
        id: { in: ['chunk-1'] },
        subjectId: 'subject-1',
        documentId: 'document-1',
      },
      select: {
        id: true,
        documentId: true,
        subjectId: true,
        index: true,
        pageNumber: true,
        text: true,
      },
    });
    expect(prisma.question.create).toHaveBeenCalledWith({
      data: {
        sessionId: 'session-1',
        knowledgeUnitId: 'unit-1',
        subjectId: 'subject-1',
        documentId: 'document-1',
        prompt:
          'Quelle limite materielle encadre la revision constitutionnelle ?',
        difficulty: 'MEDIUM',
        displayOrder: 0,
        choices: [
          {
            id: 'a',
            label: 'La forme republicaine du gouvernement',
            feedback: 'Correct.',
          },
          {
            id: 'b',
            label: 'La suppression du Parlement',
            feedback: 'Incorrect.',
          },
        ],
        correctChoiceId: 'a',
        explanation: 'La Constitution protege cette limite materielle.',
      },
    });
    expect(prisma.questionSource.createMany).toHaveBeenCalledWith({
      data: [
        {
          questionId: 'question-1',
          subjectId: 'subject-1',
          chunkId: 'chunk-1',
        },
      ],
    });
    expect(activity).toEqual({
      sessionId: 'session-1',
      type: 'diagnostic_quiz',
      title: 'Diagnostic constitutionnel',
      version: 2,
      documentId: 'document-1',
      subjectId: 'subject-1',
      questions: [
        {
          id: 'question-1',
          knowledgeUnitId: 'unit-1',
          prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
          difficulty: 'MEDIUM',
          choices: [
            { id: 'a', label: 'La forme republicaine du gouvernement' },
            { id: 'b', label: 'La suppression du Parlement' },
          ],
          sources: [{ chunkId: 'chunk-1', pageNumber: null, index: 0 }],
        },
      ],
    });
    const publicPayload = JSON.stringify(activity);
    expect(publicPayload).not.toContain('correctChoiceId');
    expect(publicPayload).not.toContain('explanation');
    expect(publicPayload).not.toContain('feedback');
    expect(publicPayload).not.toContain('isCorrect');
    expect(publicPayload).not.toContain('Article 89');
  });

  it('persists a v3 quiz with multiple answers and visual sources without leaking correction fields before submit', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue({
      id: 'unit-1',
      subjectId: 'subject-1',
    });
    prisma.documentChunk.findMany.mockResolvedValue([chunkRecord()]);
    prisma.activitySession.create.mockResolvedValue(
      sessionRecord({ version: 3, documentId: 'document-1' }),
    );
    prisma.question.create.mockResolvedValue(
      questionRecord({
        id: 'question-1',
        documentId: 'document-1',
        selectionMode: 'MULTIPLE',
        minSelections: 1,
        maxSelections: 2,
        correctChoiceId: null,
        correctChoiceIds: ['a', 'c'],
        visuals: [
          {
            id: 'visual-1',
            questionId: 'question-1',
            type: 'CHART',
            displayOrder: 0,
            payload: {
              chartType: 'bar',
              title: 'Elements de controle',
              data: [{ category: 'Controle', value: 2 }],
              xKey: 'category',
              yKeys: ['value'],
            },
            sources: [
              {
                visualId: 'visual-1',
                subjectId: 'subject-1',
                chunkId: 'chunk-1',
                chunk: chunkRecord(),
              },
            ],
          },
        ],
        sources: [
          {
            questionId: 'question-1',
            subjectId: 'subject-1',
            chunkId: 'chunk-1',
            chunk: chunkRecord(),
          },
        ],
      }),
    );
    prisma.questionVisual.create.mockResolvedValue({
      id: 'visual-1',
      questionId: 'question-1',
      type: 'CHART',
      displayOrder: 0,
      payload: {
        chartType: 'bar',
        title: 'Elements de controle',
        data: [{ category: 'Controle', value: 2 }],
        xKey: 'category',
        yKeys: ['value'],
      },
    });

    const activity = await repository.createDiagnosticQuiz({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
      quiz: {
        title: 'Diagnostic enrichi',
        version: 3,
        questions: [
          {
            prompt: 'Quels elements controlent le pouvoir ?',
            selectionMode: 'multiple',
            minSelections: 1,
            maxSelections: 2,
            choices: [
              { id: 'a', label: 'Controle juridictionnel', feedback: 'Oui.' },
              { id: 'b', label: 'Pouvoir absolu', feedback: 'Non.' },
              { id: 'c', label: 'Separation des pouvoirs', feedback: 'Oui.' },
            ],
            correctChoiceIds: ['a', 'c'],
            explanation: 'Ces elements limitent le pouvoir.',
            sourceChunkIds: ['chunk-1'],
            visuals: [
              {
                type: 'CHART',
                displayOrder: 0,
                chartType: 'bar',
                title: 'Elements de controle',
                data: [{ category: 'Controle', value: 2 }],
                xKey: 'category',
                yKeys: ['value'],
                sourceChunkIds: ['chunk-1'],
              },
            ],
          },
        ],
      },
    });

    const sessionCreatePayload =
      prisma.activitySession.create.mock.calls[0]?.[0];
    const questionCreatePayload = prisma.question.create.mock.calls[0]?.[0] as
      | QuestionCreatePayload
      | undefined;
    const visualCreatePayload = prisma.questionVisual.create.mock.calls[0]?.[0];

    expect(sessionCreatePayload?.data).toMatchObject({
      version: 3,
      documentId: 'document-1',
    });
    expect(questionCreatePayload?.data).toMatchObject({
      selectionMode: 'MULTIPLE',
      minSelections: 1,
      maxSelections: 2,
      correctChoiceId: null,
      correctChoiceIds: ['a', 'c'],
    });
    expect(visualCreatePayload?.data).toMatchObject({
      questionId: 'question-1',
      type: 'CHART',
      displayOrder: 0,
    });
    expect(prisma.questionVisualSource.createMany).toHaveBeenCalledWith({
      data: [
        {
          visualId: 'visual-1',
          subjectId: 'subject-1',
          chunkId: 'chunk-1',
        },
      ],
    });
    expect(activity.questions[0]).toMatchObject({
      selectionMode: 'multiple',
      minSelections: 1,
      maxSelections: 2,
      visuals: [
        expect.objectContaining({
          id: 'visual-1',
          type: 'CHART',
          sources: [{ chunkId: 'chunk-1', pageNumber: null, index: 0 }],
        }),
      ],
    });
    const publicPayload = JSON.stringify(activity);
    expect(publicPayload).not.toContain('correctChoiceId');
    expect(publicPayload).not.toContain('correctChoiceIds');
    expect(publicPayload).not.toContain('explanation');
    expect(publicPayload).not.toContain('feedback');
    expect(publicPayload).not.toContain('Article 89');
  });

  it('rejects sourced v2 quiz creation when a source chunk is unknown or cross-document', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue({
      id: 'unit-1',
      subjectId: 'subject-1',
    });
    prisma.documentChunk.findMany.mockResolvedValue([]);

    await expect(
      repository.createDiagnosticQuiz({
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        documentId: 'document-1',
        quiz: {
          title: 'Diagnostic constitutionnel',
          version: 2,
          questions: [
            {
              prompt:
                'Quelle limite materielle encadre la revision constitutionnelle ?',
              choices: [
                { id: 'a', label: 'La forme republicaine du gouvernement' },
                { id: 'b', label: 'La suppression du Parlement' },
              ],
              correctChoiceId: 'a',
              explanation: 'La Constitution protege cette limite materielle.',
              sourceChunkIds: ['missing-chunk'],
            },
          ],
        },
      }),
    ).rejects.toThrow('Question source chunk not found');

    expect(prisma.activitySession.create).not.toHaveBeenCalled();
    expect(prisma.question.create).not.toHaveBeenCalled();
  });

  it('rejects quiz creation when the knowledge unit is outside the student subject', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue(null);

    await expect(
      repository.createDiagnosticQuiz({
        studentId: 'student-1',
        subjectId: 'subject-2',
        knowledgeUnitId: 'unit-1',
        quiz: {
          title: 'Diagnostic constitutionnel',
          questions: [
            {
              prompt:
                'Quelle est la norme supreme dans la hierarchie interne ?',
              choices: [
                { id: 'a', label: 'La Constitution' },
                { id: 'b', label: 'Le reglement' },
              ],
              correctChoiceId: 'a',
              explanation:
                'La Constitution se situe au sommet de la hierarchie interne.',
            },
          ],
        },
      }),
    ).rejects.toThrow('Knowledge unit does not belong to student subject');

    expect(prisma.activitySession.create).not.toHaveBeenCalled();
    expect(prisma.question.create).not.toHaveBeenCalled();
  });

  it('persists a bounded score and completes the activity session', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(sessionWithQuestions());
    prisma.activityResult.create.mockResolvedValue(resultRecord());

    const result = await repository.submitResult({
      studentId: 'student-1',
      sessionId: 'session-1',
      answers: [{ questionId: 'question-1', choiceId: 'a' }],
    });

    expect(prisma.activitySession.findFirst).toHaveBeenCalledWith({
      where: {
        id: 'session-1',
        studentId: 'student-1',
      },
      include: {
        questions: {
          include: {
            sources: {
              include: {
                chunk: true,
              },
            },
          },
          orderBy: {
            displayOrder: 'asc',
          },
        },
        result: true,
      },
    });
    expect(prisma.activityResult.create).toHaveBeenCalledWith({
      data: {
        sessionId: 'session-1',
        correctAnswers: 1,
        totalQuestions: 1,
        score: 1,
      },
    });
    const [activitySessionUpdatePayload] = prisma.activitySession.update.mock
      .calls[0] as [ActivitySessionUpdatePayload] | [];
    expect(activitySessionUpdatePayload).toEqual({
      where: { id: 'session-1' },
      data: {
        status: 'COMPLETED',
        completedAt: expect.any(Date) as Date,
      },
    });
    expect(result).toEqual({
      correctAnswers: 1,
      totalQuestions: 1,
      score: 1,
      knowledgeUnitId: 'unit-1',
      items: [
        {
          questionId: 'question-1',
          knowledgeUnitId: 'unit-1',
          prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
          selectedChoiceId: 'a',
          correctChoiceId: 'a',
          isCorrect: true,
          explanation: 'Le myocarde est le muscle cardiaque.',
          choiceFeedback: [],
          sources: [],
        },
      ],
    });
  });

  it('persists v2 answers and returns detailed correction with source text after submit', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(
      sessionWithQuestions({
        version: 2,
        documentId: 'document-1',
        questions: [
          questionRecord({
            documentId: 'document-1',
            difficulty: 'MEDIUM',
            choices: [
              {
                id: 'a',
                label: 'La forme republicaine du gouvernement',
                feedback: 'Ce choix est correct.',
              },
              {
                id: 'b',
                label: 'La suppression du Parlement',
                feedback: 'Ce choix est incorrect.',
              },
            ],
            correctChoiceId: 'a',
            explanation:
              'La revision ne peut pas porter atteinte a la forme republicaine.',
            sources: [
              {
                questionId: 'question-1',
                subjectId: 'subject-1',
                chunkId: 'chunk-1',
                chunk: chunkRecord(),
              },
            ],
          }),
        ],
      }),
    );
    prisma.activityResult.create.mockResolvedValue(
      resultRecord({ correctAnswers: 0, totalQuestions: 1, score: 0 }),
    );

    const result = await repository.submitResult({
      studentId: 'student-1',
      sessionId: 'session-1',
      answers: [{ questionId: 'question-1', choiceId: 'b' }],
    });

    expect(prisma.questionAnswer.createMany).toHaveBeenCalledWith({
      data: [
        {
          sessionId: 'session-1',
          questionId: 'question-1',
          selectedChoiceId: 'b',
          isCorrect: false,
        },
      ],
    });
    expect(prisma.activityResult.create).toHaveBeenCalledWith({
      data: {
        sessionId: 'session-1',
        correctAnswers: 0,
        totalQuestions: 1,
        score: 0,
      },
    });
    expect(result).toEqual({
      correctAnswers: 0,
      totalQuestions: 1,
      score: 0,
      knowledgeUnitId: 'unit-1',
      items: [
        {
          questionId: 'question-1',
          knowledgeUnitId: 'unit-1',
          prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
          selectedChoiceId: 'b',
          correctChoiceId: 'a',
          isCorrect: false,
          explanation:
            'La revision ne peut pas porter atteinte a la forme republicaine.',
          choiceFeedback: [
            { choiceId: 'a', feedback: 'Ce choix est correct.' },
            { choiceId: 'b', feedback: 'Ce choix est incorrect.' },
          ],
          sources: [
            {
              chunkId: 'chunk-1',
              text: 'Article 89 encadre la revision constitutionnelle.',
              pageNumber: null,
              index: 0,
            },
          ],
        },
      ],
    });
  });

  it('submits multiple answers with all-or-nothing scoring and post-submit correction only', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(
      sessionWithQuestions({
        version: 3,
        documentId: 'document-1',
        questions: [
          questionRecord({
            id: 'question-1',
            documentId: 'document-1',
            selectionMode: 'MULTIPLE',
            minSelections: 1,
            maxSelections: 2,
            choices: [
              { id: 'a', label: 'Controle', feedback: 'Oui.' },
              { id: 'b', label: 'Pouvoir absolu', feedback: 'Non.' },
              { id: 'c', label: 'Separation', feedback: 'Oui.' },
            ],
            correctChoiceId: null,
            correctChoiceIds: ['a', 'c'],
            explanation: 'Les deux choix corrects limitent le pouvoir.',
            sources: [
              {
                questionId: 'question-1',
                subjectId: 'subject-1',
                chunkId: 'chunk-1',
                chunk: chunkRecord(),
              },
            ],
          }),
        ],
      }),
    );
    prisma.questionAnswer.create.mockResolvedValue({ id: 'answer-1' });
    prisma.activityResult.create.mockResolvedValue(
      resultRecord({ correctAnswers: 1, totalQuestions: 1, score: 1 }),
    );

    const result = await repository.submitResult({
      studentId: 'student-1',
      sessionId: 'session-1',
      answers: [{ questionId: 'question-1', choiceIds: ['a', 'c'] }],
    });

    expect(prisma.questionAnswer.create).toHaveBeenCalledWith({
      data: {
        sessionId: 'session-1',
        questionId: 'question-1',
        selectedChoiceId: null,
        isCorrect: true,
      },
    });
    expect(prisma.questionAnswerChoice.createMany).toHaveBeenCalledWith({
      data: [
        { answerId: 'answer-1', choiceId: 'a' },
        { answerId: 'answer-1', choiceId: 'c' },
      ],
    });
    expect(result).toEqual({
      correctAnswers: 1,
      totalQuestions: 1,
      score: 1,
      knowledgeUnitId: 'unit-1',
      items: [
        {
          questionId: 'question-1',
          knowledgeUnitId: 'unit-1',
          prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
          selectedChoiceIds: ['a', 'c'],
          correctChoiceIds: ['a', 'c'],
          isCorrect: true,
          partialScore: 1,
          explanation: 'Les deux choix corrects limitent le pouvoir.',
          choiceFeedback: [
            { choiceId: 'a', feedback: 'Oui.' },
            { choiceId: 'b', feedback: 'Non.' },
            { choiceId: 'c', feedback: 'Oui.' },
          ],
          sources: [
            {
              chunkId: 'chunk-1',
              text: 'Article 89 encadre la revision constitutionnelle.',
              pageNumber: null,
              index: 0,
            },
          ],
        },
      ],
    });
  });

  it('rejects duplicate choice ids for a multiple-answer question', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(
      sessionWithQuestions({
        version: 3,
        questions: [
          questionRecord({
            selectionMode: 'MULTIPLE',
            minSelections: 1,
            maxSelections: 2,
            correctChoiceId: null,
            correctChoiceIds: ['a', 'b'],
          }),
        ],
      }),
    );

    await expect(
      repository.submitResult({
        studentId: 'student-1',
        sessionId: 'session-1',
        answers: [{ questionId: 'question-1', choiceIds: ['a', 'a'] }],
      }),
    ).rejects.toThrow('Duplicate choices are not allowed');

    expect(prisma.questionAnswer.create).not.toHaveBeenCalled();
    expect(prisma.activityResult.create).not.toHaveBeenCalled();
  });

  it('rejects missing answers when submitting a quiz', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(
      sessionWithQuestions({
        questions: [
          questionRecord({ id: 'question-1' }),
          questionRecord({ id: 'question-2' }),
        ],
      }),
    );

    await expect(
      repository.submitResult({
        studentId: 'student-1',
        sessionId: 'session-1',
        answers: [{ questionId: 'question-1', choiceId: 'a' }],
      }),
    ).rejects.toThrow('Missing answers are not allowed');

    expect(prisma.questionAnswer.createMany).not.toHaveBeenCalled();
    expect(prisma.activityResult.create).not.toHaveBeenCalled();
  });

  it('rejects duplicate answers before writing an impossible score', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(sessionWithQuestions());

    await expect(
      repository.submitResult({
        studentId: 'student-1',
        sessionId: 'session-1',
        answers: [
          { questionId: 'question-1', choiceId: 'a' },
          { questionId: 'question-1', choiceId: 'a' },
        ],
      }),
    ).rejects.toThrow('Duplicate answers are not allowed');

    expect(prisma.activityResult.create).not.toHaveBeenCalled();
    expect(prisma.activitySession.update).not.toHaveBeenCalled();
  });

  it('rejects already completed sessions before creating a duplicate result', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(
      sessionWithQuestions({
        status: 'COMPLETED',
        completedAt: createdAt,
        result: resultRecord(),
      }),
    );

    await expect(
      repository.submitResult({
        studentId: 'student-1',
        sessionId: 'session-1',
        answers: [{ questionId: 'question-1', choiceId: 'a' }],
      }),
    ).rejects.toThrow('Activity session already completed');

    expect(prisma.activityResult.create).not.toHaveBeenCalled();
    expect(prisma.activitySession.update).not.toHaveBeenCalled();
  });

  it('rejects missing or cross-student sessions', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(null);

    await expect(
      repository.submitResult({
        studentId: 'student-2',
        sessionId: 'session-1',
        answers: [{ questionId: 'question-1', choiceId: 'a' }],
      }),
    ).rejects.toThrow('Activity session not found');

    expect(prisma.activityResult.create).not.toHaveBeenCalled();
  });

  it('rejects unknown question ids and choice ids', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(sessionWithQuestions());

    await expect(
      repository.submitResult({
        studentId: 'student-1',
        sessionId: 'session-1',
        answers: [{ questionId: 'question-2', choiceId: 'a' }],
      }),
    ).rejects.toThrow('Question does not belong to activity session');

    await expect(
      repository.submitResult({
        studentId: 'student-1',
        sessionId: 'session-1',
        answers: [{ questionId: 'question-1', choiceId: 'c' }],
      }),
    ).rejects.toThrow('Choice does not belong to question');

    expect(prisma.activityResult.create).not.toHaveBeenCalled();
  });

  it('creates an open question activity without leaking source text or correction fields', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue({
      id: 'unit-1',
      subjectId: 'subject-1',
    });
    prisma.documentChunk.findMany.mockResolvedValue([chunkRecord()]);
    prisma.activitySession.create.mockResolvedValue(
      sessionRecord({
        type: 'OPEN_QUESTION' as never,
        version: 1,
        documentId: 'document-1',
      }),
    );
    prisma.openQuestion.create.mockResolvedValue(openQuestionRecord());

    const activity = await repository.createOpenQuestionActivity({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
      question: {
        prompt:
          'Explique avec tes propres mots la notion suivante : Séparation des pouvoirs.',
        instructions:
          'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
        maxAnswerLength: 4000,
        sourceChunkIds: ['chunk-1'],
        version: 1,
      },
    });

    expect(prisma.activitySession.create).toHaveBeenCalledWith({
      data: {
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        documentId: 'document-1',
        type: 'OPEN_QUESTION',
        status: 'STARTED',
        version: 1,
      },
    });
    expect(prisma.openQuestion.create).toHaveBeenCalledWith({
      data: {
        sessionId: 'session-1',
        studentId: 'student-1',
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        prompt:
          'Explique avec tes propres mots la notion suivante : Séparation des pouvoirs.',
        instructions:
          'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
        maxAnswerLength: 4000,
        version: 1,
      },
    });
    expect(prisma.openQuestionSource.createMany).toHaveBeenCalledWith({
      data: [
        {
          questionId: 'open-question-1',
          subjectId: 'subject-1',
          chunkId: 'chunk-1',
        },
      ],
    });
    expect(activity).toEqual({
      sessionId: 'session-1',
      type: 'open_question',
      version: 1,
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      question: {
        id: 'open-question-1',
        prompt:
          'Explique avec tes propres mots la notion suivante : Séparation des pouvoirs.',
        instructions:
          'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
        maxAnswerLength: 4000,
        sources: [{ chunkId: 'chunk-1', pageNumber: null, index: 0 }],
      },
    });
    const publicPayload = JSON.stringify(activity);
    expect(publicPayload).not.toContain('answerText');
    expect(publicPayload).not.toContain('modelAnswer');
    expect(publicPayload).not.toContain('score');
    expect(publicPayload).not.toContain('feedback');
    expect(publicPayload).not.toContain('Article 89');
  });

  it('builds an open answer evaluation context with sourced chunks', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue({
      ...sessionRecord({
        type: 'OPEN_QUESTION' as never,
        status: 'STARTED',
      }),
      knowledgeUnit: knowledgeUnitRecord(),
      openQuestion: openQuestionRecord(),
      openAnswerEvaluation: null,
    } satisfies OpenQuestionSessionRecord);

    const context = await repository.findOpenAnswerEvaluationContext({
      studentId: 'student-1',
      sessionId: 'session-1',
    });

    expect(context.knowledgeUnit).toMatchObject({
      id: 'unit-1',
      subjectId: 'subject-1',
      title: 'Séparation des pouvoirs',
      summary: 'Résumé.',
      sourceChunkIds: ['chunk-1'],
    });
    expect(context).toEqual({
      sessionId: 'session-1',
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnit: context.knowledgeUnit,
      question: {
        id: 'open-question-1',
        prompt:
          'Explique avec tes propres mots la notion suivante : Séparation des pouvoirs.',
        instructions:
          'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
        sourceChunkIds: ['chunk-1'],
      },
      chunks: [
        {
          id: 'chunk-1',
          index: 0,
          text: 'Article 89 encadre la revision constitutionnelle.',
          pageNumber: null,
        },
      ],
    });
  });

  it('saves a ready open answer evaluation with sourced feedback', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue({
      ...sessionRecord({
        type: 'OPEN_QUESTION' as never,
        status: 'STARTED',
      }),
      knowledgeUnit: knowledgeUnitRecord(),
      openQuestion: openQuestionRecord(),
      openAnswerEvaluation: null,
    } satisfies OpenQuestionSessionRecord);
    prisma.openAnswerEvaluation.create.mockResolvedValue(
      openAnswerEvaluationRecord({
        status: 'READY',
        score: 16,
        maxScore: 20,
        feedback: 'Réponse solide.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil.',
      }),
    );

    const result = await repository.saveOpenAnswerEvaluation({
      studentId: 'student-1',
      sessionId: 'session-1',
      answerText:
        'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
      evaluation: {
        status: 'READY',
        score: 16,
        maxScore: 20,
        feedback: 'Réponse solide.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil.',
        sourceChunkIds: ['chunk-1'],
        metadata: {
          flowName: 'openAnswerEvaluation',
          provider: 'google-genai',
          model: 'googleai/gemini-2.5-flash',
          promptVersion: 'open-answer-evaluation-v1',
          schemaVersion: 'open-answer-evaluation-v1',
          inputSize: 1400,
        },
      },
    });

    expect(prisma.openAnswerEvaluation.create).toHaveBeenCalledWith({
      data: {
        sessionId: 'session-1',
        openQuestionId: 'open-question-1',
        studentId: 'student-1',
        subjectId: 'subject-1',
        answerText:
          'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
        status: 'READY',
        score: 16,
        maxScore: 20,
        feedback: 'Réponse solide.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil.',
        generationFlowName: 'openAnswerEvaluation',
        generationProvider: 'google-genai',
        generationModel: 'googleai/gemini-2.5-flash',
        generationPromptVersion: 'open-answer-evaluation-v1',
        generationSchemaVersion: 'open-answer-evaluation-v1',
        generationInputSize: 1400,
      },
    });
    expect(prisma.activitySession.update).toHaveBeenCalledTimes(1);
    const [sessionUpdateInput] = prisma.activitySession.update.mock.calls[0] as
      | [ActivitySessionUpdatePayload]
      | [];
    expect(sessionUpdateInput).toEqual({
      where: {
        id: 'session-1',
      },
      data: {
        status: 'SUBMITTED',
        completedAt: expect.any(Date) as Date,
      },
    });
    expect(result).toEqual({
      sessionId: 'session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: {
        id: 'evaluation-1',
        status: 'READY',
        score: 16,
        maxScore: 20,
        feedback: 'Réponse solide.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil.',
        sources: [
          {
            chunkId: 'chunk-1',
            text: 'Article 89 encadre la revision constitutionnelle.',
            pageNumber: null,
            index: 0,
          },
        ],
      },
    });
  });

  it('rejects double submit and non-open-question sessions for open answers', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue({
      ...sessionRecord({
        type: 'OPEN_QUESTION' as never,
        status: 'SUBMITTED',
      }),
      knowledgeUnit: knowledgeUnitRecord(),
      openQuestion: openQuestionRecord(),
      openAnswerEvaluation: openAnswerEvaluationRecord(),
    } satisfies OpenQuestionSessionRecord);

    await expect(
      repository.saveOpenAnswerEvaluation({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText:
          'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
        evaluation: {
          status: 'FAILED',
          errorCode: 'OPEN_ANSWER_EVALUATION_SOURCE_INVALID',
        },
      }),
    ).rejects.toThrow('Activity session already submitted');

    prisma.activitySession.findFirst.mockResolvedValue(sessionWithQuestions());

    await expect(
      repository.saveOpenAnswerEvaluation({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText:
          'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
        evaluation: {
          status: 'FAILED',
          errorCode: 'OPEN_ANSWER_EVALUATION_SOURCE_INVALID',
        },
      }),
    ).rejects.toThrow('Activity session is not an open question');

    expect(prisma.openAnswerEvaluation.create).not.toHaveBeenCalled();
  });

  it('persists rich closed exercise payloads and returns a public pre-submit envelope', async () => {
    const { prisma, repository } = createRepository();
    prisma.knowledgeUnit.findFirst.mockResolvedValue({
      id: 'unit-1',
      subjectId: 'subject-1',
    });
    prisma.documentChunk.findMany.mockResolvedValue([{ id: 'chunk-1' }]);
    prisma.activitySession.create.mockResolvedValue(
      sessionRecord({
        id: 'rich-session-1',
        type: 'RICH_CLOSED_EXERCISE' as never,
        version: 1,
        documentId: 'document-1',
      }),
    );

    const result = await repository.createRichClosedExerciseSession({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
      exercise: {
        ...richClosedExerciseFixture(),
        metadata: {
          flowName: 'richClosedQuestionGeneration',
          provider: 'test-provider',
          model: 'test-model',
          promptVersion: 'rich-closed-v1a-001',
          schemaVersion: 'rich-closed-question-v1',
          inputSize: 1234,
        },
      },
      qualityMetrics: {
        questionCount: 6,
      },
    });

    const [sessionCreatePayload] = prisma.activitySession.create.mock
      .calls[0] as [ActivitySessionCreatePayload] | [];
    expect(sessionCreatePayload?.data).toMatchObject({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      documentId: 'document-1',
      type: 'RICH_CLOSED_EXERCISE',
      status: 'STARTED',
    });

    const [richClosedPayloadCreate] = prisma.richClosedExercisePayload.create
      .mock.calls[0] as
      | [
          {
            data: {
              activitySessionId: string;
              version: string;
              subjectId: string;
              documentId: string | null;
              knowledgeUnitId: string;
              exercisePayload: RichClosedExercise;
              generationMetadata: { flowName: string };
              qualityMetrics: { questionCount: number };
            };
          },
        ]
      | [];
    expect(richClosedPayloadCreate?.data).toMatchObject({
      activitySessionId: 'rich-session-1',
      version: 'rich-closed-question-v1',
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
    });
    expect(richClosedPayloadCreate?.data.exercisePayload.questions).toEqual(
      expect.any(Array),
    );
    expect(richClosedPayloadCreate?.data.generationMetadata.flowName).toBe(
      'richClosedQuestionGeneration',
    );
    expect(richClosedPayloadCreate?.data.qualityMetrics).toEqual({
      questionCount: 6,
    });
    expect(result).toMatchObject({
      sessionId: 'rich-session-1',
      type: 'rich_closed_exercise',
      version: 'rich-closed-question-v1',
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
    });
    expect(JSON.stringify(result)).not.toContain('correctChoiceId');
    expect(JSON.stringify(result)).not.toContain('explanation');
  });

  it('relreads rich closed exercises for the owning student without leaking corrections', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue(
      richClosedSessionRecord(),
    );

    const result = await repository.getRichClosedExerciseForStudent({
      studentId: 'student-1',
      sessionId: 'session-1',
    });

    expect(prisma.activitySession.findFirst).toHaveBeenCalledWith({
      where: {
        id: 'session-1',
        studentId: 'student-1',
      },
      include: {
        richClosedExercisePayload: true,
        richClosedExerciseResult: true,
      },
    });
    expect(result.type).toBe('rich_closed_exercise');
    expect(JSON.stringify(result)).not.toContain('correct');
    expect(JSON.stringify(result)).not.toContain('feedback');
    expect(JSON.stringify(result)).not.toContain('modelAnswer');
    expect(JSON.stringify(result)).not.toContain('answerText');
  });

  it('saves and relreads a rich closed post-submit result', async () => {
    const { prisma, repository } = createRepository();
    const result = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: correctRichClosedAnswers(),
    });
    prisma.activitySession.findFirst.mockResolvedValue(
      richClosedSessionRecord(),
    );
    prisma.richClosedExerciseResult.create.mockResolvedValue(
      richClosedResultRecord(),
    );
    prisma.activitySession.update.mockResolvedValue(
      sessionRecord({ status: 'COMPLETED' }),
    );

    const saved = await repository.saveRichClosedExerciseResult({
      studentId: 'student-1',
      sessionId: 'session-1',
      answers: correctRichClosedAnswers(),
      result,
    });

    expect(prisma.richClosedExerciseResult.create).toHaveBeenCalledWith({
      data: {
        activitySessionId: 'session-1',
        answersPayload: correctRichClosedAnswers(),
        correctionPayload: result.items,
        correctAnswers: 6,
        totalQuestions: 6,
        score: 1,
      },
    });
    expect(prisma.activitySession.update).toHaveBeenCalledWith({
      where: {
        id: 'session-1',
      },
      data: {
        status: 'COMPLETED',
        completedAt: expect.any(Date) as Date,
      },
    });
    expect(saved).toEqual(result);

    prisma.activitySession.findFirst.mockResolvedValue(
      richClosedSessionRecord({
        richClosedExerciseResult: richClosedResultRecord(),
      }),
    );

    await expect(
      repository.getRichClosedExerciseResultForStudent({
        studentId: 'student-1',
        sessionId: 'session-1',
      }),
    ).resolves.toMatchObject({
      sessionId: 'session-1',
      type: 'rich_closed_exercise',
      status: 'completed',
      correctAnswers: 6,
      totalQuestions: 6,
      score: 1,
    });
  });

  it('rejects rich closed double submit', async () => {
    const { prisma, repository } = createRepository();
    const result = scoreRichClosedExerciseSubmission({
      sessionId: 'session-1',
      exercise: richClosedExerciseFixture(),
      answers: correctRichClosedAnswers(),
    });
    prisma.activitySession.findFirst.mockResolvedValue(
      richClosedSessionRecord({
        status: 'COMPLETED',
        richClosedExerciseResult: richClosedResultRecord(),
      }),
    );

    await expect(
      repository.saveRichClosedExerciseResult({
        studentId: 'student-1',
        sessionId: 'session-1',
        answers: correctRichClosedAnswers(),
        result,
      }),
    ).rejects.toThrow(RICH_CLOSED_SESSION_ALREADY_COMPLETED);
  });
});

function correctRichClosedAnswers(): RichClosedAnswer[] {
  return [
    {
      questionId: 'single-1',
      questionKind: 'single_choice',
      choiceId: 'choice-a',
    },
    {
      questionId: 'multiple-1',
      questionKind: 'multiple_choice',
      choiceIds: ['choice-a', 'choice-b'],
    },
    {
      questionId: 'matching-1',
      questionKind: 'matching',
      pairs: [
        { leftId: 'left-1', rightId: 'right-1' },
        { leftId: 'left-2', rightId: 'right-2' },
        { leftId: 'left-3', rightId: 'right-3' },
      ],
    },
    {
      questionId: 'ordering-1',
      questionKind: 'ordering',
      orderedIds: ['item-1', 'item-2', 'item-3'],
    },
    {
      questionId: 'case-1',
      questionKind: 'case_qualification',
      choiceId: 'choice-a',
    },
    {
      questionId: 'error-1',
      questionKind: 'error_detection',
      errorId: 'error-a',
    },
  ];
}
````

### api/src/modules/activities/infrastructure/prisma-activities.repository.ts

````ts
import { Injectable } from '@nestjs/common';
import {
  ActivityStatus,
  ActivityType,
  OpenAnswerEvaluationStatus,
  QuestionSelectionMode,
  QuestionVisualType,
} from '../../../generated/prisma/enums';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../../shared/infrastructure/prisma/prisma.service';
import { KnowledgeUnit } from '../../revision/domain/knowledge-unit.entity';
import type {
  ActivitiesRepository,
  ActivityQuestion,
  ActivityQuestionCorrectionItem,
  ActivityQuestionVisual,
  OpenAnswerEvaluationContext,
  OpenAnswerEvaluationDraft,
  DiagnosticQuizActivity,
  DiagnosticQuizGenerationContext,
  DiagnosticQuizSubmissionResult,
  OpenAnswerSubmissionResult,
  OpenQuestionActivity,
  OpenQuestionDraft,
  RichClosedExerciseInternalEnvelope,
} from '../application/activities.repository';
import type {
  GeneratedDiagnosticQuiz,
  GeneratedDiagnosticQuizChoice,
  GeneratedDiagnosticQuizQuestion,
  GeneratedDiagnosticQuizVisual,
} from '../application/diagnostic-quiz-generator';
import {
  RICH_CLOSED_GENERATION_SOURCE_INVALID,
  RICH_CLOSED_SESSION_ALREADY_COMPLETED,
  RICH_CLOSED_SESSION_NOT_COMPLETED,
  RICH_CLOSED_SESSION_NOT_FOUND,
  RICH_CLOSED_START_INVALID_INPUT,
} from '../application/rich-closed-questions/rich-closed-question-errors';
import type {
  GeneratedRichClosedExercise,
  RichClosedQuestionGenerationMetadata,
} from '../application/rich-closed-questions/rich-closed-question-generator';
import { toRichClosedPublicExerciseEnvelope } from '../application/rich-closed-questions/rich-closed-question-public.mapper';
import type {
  RichClosedAnswer,
  RichClosedExercise,
  RichClosedExerciseResult,
  RichClosedPublicExerciseEnvelope,
} from '../application/rich-closed-questions/rich-closed-question.types';
import { validateRichClosedExercise } from '../application/rich-closed-questions/rich-closed-question.validator';

type ActivityQuestionChoiceRecord = {
  id: string;
  label: string;
  feedback?: string | null;
};

type QuestionSourceRecord = {
  chunkId: string;
  chunk: {
    id: string;
    text: string;
    pageNumber: number | null;
    index: number;
  };
};

type QuestionRecord = {
  id: string;
  knowledgeUnitId: string;
  prompt: string;
  choices: unknown;
  selectionMode?: 'SINGLE' | 'MULTIPLE';
  minSelections?: number | null;
  maxSelections?: number | null;
  correctChoiceId?: string | null;
  correctChoiceIds?: unknown;
  explanation: string;
  difficulty?: 'LOW' | 'MEDIUM' | 'HIGH' | null;
  displayOrder?: number;
  sources?: QuestionSourceRecord[];
  visuals?: QuestionVisualRecord[];
};

type QuestionVisualRecord = {
  id: string;
  type: 'IMAGE' | 'CHART' | 'DIAGRAM';
  displayOrder: number;
  payload: unknown;
  sources?: QuestionSourceRecord[];
};

type ActivitySessionRecord = {
  id: string;
  subjectId: string;
  knowledgeUnitId: string;
  type: ActivityType;
  status: ActivityStatus;
  version?: number;
  documentId?: string | null;
  questions: QuestionRecord[];
  result?: object | null;
};

type OpenQuestionSourceRecord = {
  chunkId: string;
  chunk: DocumentChunkRecord;
};

type OpenQuestionRecord = {
  id: string;
  sessionId: string;
  subjectId: string;
  documentId: string | null;
  knowledgeUnitId: string;
  prompt: string;
  instructions: string | null;
  maxAnswerLength: number;
  version: number;
  sources?: OpenQuestionSourceRecord[];
};

type OpenAnswerEvaluationRecord = {
  id: string;
  sessionId: string;
  openQuestionId?: string;
  answerText?: string;
  status: 'PENDING' | 'READY' | 'FAILED';
  score: number | null;
  maxScore: number | null;
  feedback: string | null;
  presentPoints: unknown;
  missingPoints: unknown;
  errors: unknown;
  modelAnswer: string | null;
  advice: string | null;
  generationFlowName?: string | null;
  generationProvider?: string | null;
  generationModel?: string | null;
  generationPromptVersion?: string | null;
  generationSchemaVersion?: string | null;
  generationInputSize?: number | null;
  errorCode?: string | null;
};

type OpenQuestionSessionRecord = ActivitySessionRecord & {
  openQuestion?: OpenQuestionRecord | null;
  openAnswerEvaluation?: OpenAnswerEvaluationRecord | null;
};

type OpenAnswerEvaluationSessionRecord = OpenQuestionSessionRecord & {
  knowledgeUnit: KnowledgeUnitRecord;
  openQuestion: OpenQuestionRecord | null;
  openAnswerEvaluation: OpenAnswerEvaluationRecord | null;
};

type RichClosedExercisePayloadRecord = {
  id: string;
  activitySessionId: string;
  version: string;
  title: string;
  subjectId: string;
  documentId: string | null;
  knowledgeUnitId: string;
  exercisePayload: unknown;
  generationMetadata?: unknown;
  qualityMetrics?: unknown;
};

type RichClosedExerciseResultRecord = {
  id: string;
  activitySessionId: string;
  answersPayload: unknown;
  correctionPayload: unknown;
  correctAnswers: number;
  totalQuestions: number;
  score: number;
  createdAt: Date;
};

type RichClosedExerciseSessionRecord = ActivitySessionRecord & {
  richClosedExercisePayload?: RichClosedExercisePayloadRecord | null;
  richClosedExerciseResult?: RichClosedExerciseResultRecord | null;
};

type RichClosedPersistedSessionRecord = RichClosedExerciseSessionRecord & {
  richClosedExercisePayload: RichClosedExercisePayloadRecord;
};

type DocumentChunkRecord = {
  id: string;
  documentId: string;
  subjectId: string;
  index: number;
  text: string;
  pageNumber: number | null;
};

type KnowledgeUnitSourceRecord = {
  chunk: DocumentChunkRecord;
};

type KnowledgeUnitRecord = {
  id: string;
  subjectId: string;
  documentId: string | null;
  title: string;
  summary: string;
  difficulty: 'LOW' | 'MEDIUM' | 'HIGH' | null;
  sources?: KnowledgeUnitSourceRecord[];
};

const OPEN_ANSWER_SOURCE_EXCERPT_MAX_LENGTH = 520;

@Injectable()
export class PrismaActivitiesRepository implements ActivitiesRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findDiagnosticQuizGenerationContext(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<DiagnosticQuizGenerationContext | null> {
    const knowledgeUnit = await this.prisma.knowledgeUnit.findFirst({
      where: {
        id: input.knowledgeUnitId,
        subjectId: input.subjectId,
        subject: {
          studentId: input.studentId,
        },
      },
      include: {
        sources: {
          include: {
            chunk: true,
          },
        },
      },
    });

    if (!knowledgeUnit) {
      return null;
    }

    return toDiagnosticQuizGenerationContext(knowledgeUnit);
  }

  async findOpenQuestionGenerationContext(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<DiagnosticQuizGenerationContext | null> {
    return this.findDiagnosticQuizGenerationContext(input);
  }

  async findRichClosedGenerationContext(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<DiagnosticQuizGenerationContext | null> {
    return this.findDiagnosticQuizGenerationContext(input);
  }

  async createDiagnosticQuiz(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
    documentId?: string | null;
    quiz: GeneratedDiagnosticQuiz;
  }): Promise<DiagnosticQuizActivity> {
    assertGeneratedQuizIsPersistable(input.quiz);

    return this.prisma.$transaction(async (tx) => {
      const knowledgeUnit = await tx.knowledgeUnit.findFirst({
        where: {
          id: input.knowledgeUnitId,
          subjectId: input.subjectId,
          subject: {
            studentId: input.studentId,
          },
        },
      });

      if (!knowledgeUnit) {
        throw new Error('Knowledge unit does not belong to student subject');
      }

      const sourceChunkIds = collectQuizSourceChunkIds(input.quiz.questions);
      const sourceChunks =
        sourceChunkIds.length === 0
          ? []
          : await tx.documentChunk.findMany({
              where: {
                id: {
                  in: sourceChunkIds,
                },
                subjectId: input.subjectId,
                ...(input.documentId ? { documentId: input.documentId } : {}),
              },
              select: {
                id: true,
                documentId: true,
                subjectId: true,
                index: true,
                pageNumber: true,
                text: true,
              },
            });

      if (sourceChunks.length !== sourceChunkIds.length) {
        throw new Error('Question source chunk not found');
      }

      const sourceChunkById = new Map(
        sourceChunks.map((chunk) => [chunk.id, chunk]),
      );

      const session = await tx.activitySession.create({
        data: buildActivitySessionCreateData(input),
      });

      const questions: QuestionRecord[] = [];

      for (const [index, question] of input.quiz.questions.entries()) {
        const createdQuestion = await tx.question.create({
          data: buildQuestionCreateData({
            sessionId: session.id,
            subjectId: input.subjectId,
            documentId: input.documentId ?? null,
            knowledgeUnitId: input.knowledgeUnitId,
            question,
            index,
            isSourcedVersion: (input.quiz.version ?? 1) > 1,
          }),
        });
        const questionSourceChunkIds = dedupeStrings(
          question.sourceChunkIds ?? [],
        );

        if (questionSourceChunkIds.length > 0) {
          await tx.questionSource.createMany({
            data: questionSourceChunkIds.map((chunkId) => ({
              questionId: createdQuestion.id,
              subjectId: input.subjectId,
              chunkId,
            })),
          });
        }

        const visuals: QuestionVisualRecord[] = [];

        for (const [visualIndex, visual] of (
          question.visuals ?? []
        ).entries()) {
          const visualSourceChunkIds = dedupeStrings(visual.sourceChunkIds);
          const createdVisual = await tx.questionVisual.create({
            data: buildQuestionVisualCreateData({
              questionId: createdQuestion.id,
              visual,
              fallbackDisplayOrder: visualIndex,
            }),
          });

          await tx.questionVisualSource.createMany({
            data: visualSourceChunkIds.map((chunkId) => ({
              visualId: createdVisual.id,
              subjectId: input.subjectId,
              chunkId,
            })),
          });

          visuals.push({
            id: createdVisual.id,
            type: createdVisual.type,
            displayOrder: createdVisual.displayOrder,
            payload: createdVisual.payload,
            sources: visualSourceChunkIds
              .map((chunkId) => sourceChunkById.get(chunkId))
              .filter((chunk): chunk is DocumentChunkRecord => Boolean(chunk))
              .map((chunk) => ({
                chunkId: chunk.id,
                chunk: {
                  id: chunk.id,
                  text: chunk.text,
                  pageNumber: chunk.pageNumber,
                  index: chunk.index,
                },
              })),
          });
        }

        questions.push({
          id: createdQuestion.id,
          knowledgeUnitId: createdQuestion.knowledgeUnitId,
          prompt: createdQuestion.prompt,
          choices: createdQuestion.choices,
          selectionMode: createdQuestion.selectionMode,
          minSelections: createdQuestion.minSelections,
          maxSelections: createdQuestion.maxSelections,
          correctChoiceId: createdQuestion.correctChoiceId,
          correctChoiceIds: createdQuestion.correctChoiceIds,
          explanation: createdQuestion.explanation,
          difficulty: createdQuestion.difficulty,
          displayOrder: createdQuestion.displayOrder,
          sources: questionSourceChunkIds
            .map((chunkId) => sourceChunkById.get(chunkId))
            .filter((chunk): chunk is DocumentChunkRecord => Boolean(chunk))
            .map((chunk) => ({
              chunkId: chunk.id,
              chunk: {
                id: chunk.id,
                text: chunk.text,
                pageNumber: chunk.pageNumber,
                index: chunk.index,
              },
            })),
          visuals,
        });
      }

      return toDiagnosticQuizActivity(
        {
          id: session.id,
          subjectId: session.subjectId,
          knowledgeUnitId: session.knowledgeUnitId,
          type: session.type,
          status: session.status,
          version: session.version,
          documentId: session.documentId,
          questions,
        },
        input.quiz.title,
      );
    });
  }

  async createOpenQuestionActivity(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
    documentId?: string | null;
    question: OpenQuestionDraft;
  }): Promise<OpenQuestionActivity> {
    return this.prisma.$transaction(async (tx) => {
      const knowledgeUnit = await tx.knowledgeUnit.findFirst({
        where: {
          id: input.knowledgeUnitId,
          subjectId: input.subjectId,
          subject: {
            studentId: input.studentId,
          },
        },
      });

      if (!knowledgeUnit) {
        throw new Error('Knowledge unit does not belong to student subject');
      }

      const sourceChunkIds = dedupeStrings(input.question.sourceChunkIds);
      const sourceChunks =
        sourceChunkIds.length === 0
          ? []
          : await tx.documentChunk.findMany({
              where: {
                id: {
                  in: sourceChunkIds,
                },
                subjectId: input.subjectId,
                ...(input.documentId ? { documentId: input.documentId } : {}),
              },
              select: {
                id: true,
                documentId: true,
                subjectId: true,
                pageNumber: true,
                index: true,
                text: true,
              },
            });

      if (sourceChunks.length !== sourceChunkIds.length) {
        throw new Error('Open question source chunk not found');
      }

      const sourceChunkById = new Map(
        sourceChunks.map((chunk) => [chunk.id, chunk]),
      );
      const session = await tx.activitySession.create({
        data: buildOpenQuestionSessionCreateData(input),
      });
      const question = await tx.openQuestion.create({
        data: {
          sessionId: session.id,
          studentId: input.studentId,
          subjectId: input.subjectId,
          documentId: input.documentId ?? null,
          knowledgeUnitId: input.knowledgeUnitId,
          prompt: input.question.prompt,
          instructions: input.question.instructions,
          maxAnswerLength: input.question.maxAnswerLength,
          version: input.question.version,
        },
      });

      if (sourceChunkIds.length > 0) {
        await tx.openQuestionSource.createMany({
          data: sourceChunkIds.map((chunkId) => ({
            questionId: question.id,
            subjectId: input.subjectId,
            chunkId,
          })),
        });
      }

      return toOpenQuestionActivity({
        id: session.id,
        subjectId: session.subjectId,
        knowledgeUnitId: session.knowledgeUnitId,
        type: session.type,
        status: session.status,
        version: session.version,
        documentId: session.documentId,
        questions: [],
        openQuestion: {
          id: question.id,
          sessionId: question.sessionId,
          subjectId: question.subjectId,
          documentId: question.documentId,
          knowledgeUnitId: question.knowledgeUnitId,
          prompt: question.prompt,
          instructions: question.instructions,
          maxAnswerLength: question.maxAnswerLength,
          version: question.version,
          sources: sourceChunkIds
            .map((chunkId) => sourceChunkById.get(chunkId))
            .filter((chunk): chunk is DocumentChunkRecord => Boolean(chunk))
            .map((chunk) => ({
              chunkId: chunk.id,
              chunk: {
                id: chunk.id,
                documentId: chunk.documentId,
                subjectId: chunk.subjectId,
                pageNumber: chunk.pageNumber,
                index: chunk.index,
                text: chunk.text,
              },
            })),
        },
      });
    });
  }

  async createRichClosedExerciseSession(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
    documentId?: string | null;
    exercise: GeneratedRichClosedExercise;
    qualityMetrics?: unknown;
    generationMetadata?: RichClosedQuestionGenerationMetadata;
  }): Promise<RichClosedPublicExerciseEnvelope> {
    assertRichClosedExerciseIsPersistable(input.exercise);

    return this.prisma.$transaction(async (tx) => {
      const knowledgeUnit = await tx.knowledgeUnit.findFirst({
        where: {
          id: input.knowledgeUnitId,
          subjectId: input.subjectId,
          subject: {
            studentId: input.studentId,
          },
        },
      });

      if (!knowledgeUnit) {
        throw new Error('Knowledge unit does not belong to student subject');
      }

      const sourceChunkIds = collectRichClosedSourceChunkIds(input.exercise);
      const sourceChunks =
        sourceChunkIds.length === 0
          ? []
          : await tx.documentChunk.findMany({
              where: {
                id: {
                  in: sourceChunkIds,
                },
                subjectId: input.subjectId,
                ...(input.documentId ? { documentId: input.documentId } : {}),
              },
              select: {
                id: true,
              },
            });

      if (sourceChunks.length !== sourceChunkIds.length) {
        throw new Error(RICH_CLOSED_GENERATION_SOURCE_INVALID);
      }

      const session = await tx.activitySession.create({
        data: buildRichClosedActivitySessionCreateData(input),
      });
      const exercise: RichClosedExercise = {
        id: input.exercise.id,
        version: input.exercise.version,
        title: input.exercise.title,
        subjectId: input.subjectId,
        documentId: input.documentId ?? null,
        knowledgeUnitId: input.knowledgeUnitId,
        questions: input.exercise.questions,
      };

      await tx.richClosedExercisePayload.create({
        data: {
          activitySessionId: session.id,
          version: exercise.version,
          title: exercise.title,
          subjectId: input.subjectId,
          documentId: input.documentId ?? null,
          knowledgeUnitId: input.knowledgeUnitId,
          exercisePayload: toJsonValue(exercise),
          generationMetadata: toNullableJsonValue(
            input.generationMetadata ?? input.exercise.metadata,
          ),
          qualityMetrics: toNullableJsonValue(input.qualityMetrics),
        },
      });

      return toRichClosedPublicExerciseEnvelope({
        sessionId: session.id,
        exercise,
      });
    });
  }

  async getRichClosedExerciseForStudent(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedPublicExerciseEnvelope> {
    const session = await this.findRichClosedExerciseSession(input);

    return toRichClosedPublicExerciseEnvelope({
      sessionId: session.id,
      exercise: toRichClosedExercise(session.richClosedExercisePayload),
    });
  }

  async getInternalRichClosedExerciseForStudent(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedExerciseInternalEnvelope> {
    const session = await this.findRichClosedExerciseSession(input);
    const result = session.richClosedExerciseResult
      ? toRichClosedExerciseResult(session.id, session.richClosedExerciseResult)
      : null;

    return {
      sessionId: session.id,
      status: session.status,
      exercise: toRichClosedExercise(session.richClosedExercisePayload),
      result,
    };
  }

  async saveRichClosedExerciseResult(input: {
    studentId: string;
    sessionId: string;
    answers: RichClosedAnswer[];
    result: RichClosedExerciseResult;
  }): Promise<RichClosedExerciseResult> {
    return this.prisma.$transaction(async (tx) => {
      const session = (await tx.activitySession.findFirst({
        where: {
          id: input.sessionId,
          studentId: input.studentId,
        },
        include: {
          richClosedExercisePayload: true,
          richClosedExerciseResult: true,
        },
      })) as RichClosedExerciseSessionRecord | null;

      assertRichClosedSession(session);

      if (
        session.status !== ActivityStatus.STARTED ||
        session.richClosedExerciseResult
      ) {
        throw new Error(RICH_CLOSED_SESSION_ALREADY_COMPLETED);
      }

      await tx.richClosedExerciseResult.create({
        data: {
          activitySessionId: session.id,
          answersPayload: toJsonValue(input.answers),
          correctionPayload: toJsonValue(input.result.items),
          correctAnswers: input.result.correctAnswers,
          totalQuestions: input.result.totalQuestions,
          score: input.result.score,
        },
      });

      await tx.activitySession.update({
        where: {
          id: session.id,
        },
        data: {
          status: ActivityStatus.COMPLETED,
          completedAt: new Date(),
        },
      });

      return input.result;
    });
  }

  async getRichClosedExerciseResultForStudent(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedExerciseResult> {
    const session = await this.findRichClosedExerciseSession(input);

    if (!session.richClosedExerciseResult) {
      throw new Error(RICH_CLOSED_SESSION_NOT_COMPLETED);
    }

    return toRichClosedExerciseResult(
      session.id,
      session.richClosedExerciseResult,
    );
  }

  async submitResult(input: {
    studentId: string;
    sessionId: string;
    answers: Array<{
      questionId: string;
      choiceId?: string;
      choiceIds?: string[];
    }>;
  }): Promise<DiagnosticQuizSubmissionResult> {
    return this.prisma.$transaction(async (tx) => {
      const session = await tx.activitySession.findFirst({
        where: {
          id: input.sessionId,
          studentId: input.studentId,
        },
        include: {
          questions: {
            include: {
              sources: {
                include: {
                  chunk: true,
                },
              },
            },
            orderBy: {
              displayOrder: 'asc',
            },
          },
          result: true,
        },
      });

      if (!session) {
        throw new Error('Activity session not found');
      }

      if (session.status === ActivityStatus.COMPLETED || session.result) {
        throw new Error('Activity session already completed');
      }

      const result = scoreDiagnosticQuizSubmission(session, input.answers);

      if (result.items.every((item) => item.selectedChoiceId)) {
        await tx.questionAnswer.createMany({
          data: result.items.map((item) => ({
            sessionId: session.id,
            questionId: item.questionId,
            selectedChoiceId: item.selectedChoiceId,
            isCorrect: item.isCorrect,
          })),
        });
      } else {
        for (const item of result.items) {
          const answer = await tx.questionAnswer.create({
            data: {
              sessionId: session.id,
              questionId: item.questionId,
              selectedChoiceId: item.selectedChoiceId ?? null,
              isCorrect: item.isCorrect,
            },
          });

          if ((item.selectedChoiceIds ?? []).length > 0) {
            await tx.questionAnswerChoice.createMany({
              data: (item.selectedChoiceIds ?? []).map((choiceId) => ({
                answerId: answer.id,
                choiceId,
              })),
            });
          }
        }
      }

      await tx.activityResult.create({
        data: {
          sessionId: session.id,
          correctAnswers: result.correctAnswers,
          totalQuestions: result.totalQuestions,
          score: result.score,
        },
      });

      await tx.activitySession.update({
        where: {
          id: session.id,
        },
        data: {
          status: ActivityStatus.COMPLETED,
          completedAt: new Date(),
        },
      });

      return {
        ...result,
        knowledgeUnitId: session.knowledgeUnitId,
      };
    });
  }

  private async findRichClosedExerciseSession(input: {
    studentId: string;
    sessionId: string;
  }): Promise<RichClosedPersistedSessionRecord> {
    const session = (await this.prisma.activitySession.findFirst({
      where: {
        id: input.sessionId,
        studentId: input.studentId,
      },
      include: {
        richClosedExercisePayload: true,
        richClosedExerciseResult: true,
      },
    })) as RichClosedExerciseSessionRecord | null;

    assertRichClosedSession(session);

    return session;
  }

  async findOpenAnswerEvaluationContext(input: {
    studentId: string;
    sessionId: string;
  }): Promise<OpenAnswerEvaluationContext> {
    const session = (await this.prisma.activitySession.findFirst({
      where: {
        id: input.sessionId,
        studentId: input.studentId,
      },
      include: {
        knowledgeUnit: {
          include: {
            sources: {
              include: {
                chunk: true,
              },
            },
          },
        },
        openQuestion: {
          include: {
            sources: {
              include: {
                chunk: true,
              },
            },
          },
        },
        openAnswerEvaluation: true,
      },
    })) as OpenAnswerEvaluationSessionRecord | null;

    assertOpenQuestionSessionCanBeEvaluated(session);

    return toOpenAnswerEvaluationContext(session);
  }

  async saveOpenAnswerEvaluation(input: {
    studentId: string;
    sessionId: string;
    answerText: string;
    evaluation: OpenAnswerEvaluationDraft;
  }): Promise<OpenAnswerSubmissionResult> {
    return this.prisma.$transaction(async (tx) => {
      const session = (await tx.activitySession.findFirst({
        where: {
          id: input.sessionId,
          studentId: input.studentId,
        },
        include: {
          knowledgeUnit: {
            include: {
              sources: {
                include: {
                  chunk: true,
                },
              },
            },
          },
          openQuestion: {
            include: {
              sources: {
                include: {
                  chunk: true,
                },
              },
            },
          },
          openAnswerEvaluation: true,
        },
      })) as OpenAnswerEvaluationSessionRecord | null;

      assertOpenQuestionSessionCanBeEvaluated(session);

      const sourceChunks = collectOpenQuestionSourceChunks(session);
      assertOpenAnswerEvaluationSources(input.evaluation, sourceChunks);
      const resultSourceChunks = selectOpenAnswerEvaluationSourceChunks(
        input.evaluation,
        sourceChunks,
      );

      const evaluation = await tx.openAnswerEvaluation.create({
        data: buildOpenAnswerEvaluationCreateData({
          session,
          studentId: input.studentId,
          answerText: input.answerText,
          evaluation: input.evaluation,
        }),
      });

      await tx.activitySession.update({
        where: {
          id: session.id,
        },
        data: {
          status: ActivityStatus.SUBMITTED,
          completedAt: new Date(),
        },
      });

      return toOpenAnswerSubmissionResult(evaluation, resultSourceChunks);
    });
  }
}

function buildActivitySessionCreateData(input: {
  studentId: string;
  subjectId: string;
  knowledgeUnitId: string;
  documentId?: string | null;
  quiz: GeneratedDiagnosticQuiz;
}) {
  const data: Prisma.ActivitySessionUncheckedCreateInput = {
    studentId: input.studentId,
    subjectId: input.subjectId,
    knowledgeUnitId: input.knowledgeUnitId,
    type: ActivityType.DIAGNOSTIC_QUIZ,
    status: ActivityStatus.STARTED,
  };

  if ((input.quiz.version ?? 1) > 1) {
    data.version = input.quiz.version;
    data.documentId = input.documentId ?? null;
  }

  if (input.quiz.metadata) {
    data.generationFlowName = input.quiz.metadata.flowName;
    data.generationProvider = input.quiz.metadata.provider;
    data.generationModel = input.quiz.metadata.model;
    data.generationPromptVersion = input.quiz.metadata.promptVersion;
    data.generationSchemaVersion = input.quiz.metadata.schemaVersion;
    data.generationInputSize = input.quiz.metadata.inputSize;
  }

  return data;
}

function buildOpenQuestionSessionCreateData(input: {
  studentId: string;
  subjectId: string;
  knowledgeUnitId: string;
  documentId?: string | null;
  question: OpenQuestionDraft;
}): Prisma.ActivitySessionUncheckedCreateInput {
  const data: Prisma.ActivitySessionUncheckedCreateInput = {
    studentId: input.studentId,
    subjectId: input.subjectId,
    knowledgeUnitId: input.knowledgeUnitId,
    documentId: input.documentId ?? null,
    type: ActivityType.OPEN_QUESTION,
    status: ActivityStatus.STARTED,
    version: input.question.version,
  };

  if (input.question.metadata) {
    data.generationFlowName = input.question.metadata.flowName;
    data.generationProvider = input.question.metadata.provider;
    data.generationModel = input.question.metadata.model;
    data.generationPromptVersion = input.question.metadata.promptVersion;
    data.generationSchemaVersion = input.question.metadata.schemaVersion;
    data.generationInputSize = input.question.metadata.inputSize;
  }

  return data;
}

function buildRichClosedActivitySessionCreateData(input: {
  studentId: string;
  subjectId: string;
  knowledgeUnitId: string;
  documentId?: string | null;
  exercise: GeneratedRichClosedExercise;
}): Prisma.ActivitySessionUncheckedCreateInput {
  const metadata = input.exercise.metadata;
  const data: Prisma.ActivitySessionUncheckedCreateInput = {
    studentId: input.studentId,
    subjectId: input.subjectId,
    knowledgeUnitId: input.knowledgeUnitId,
    documentId: input.documentId ?? null,
    type: ActivityType.RICH_CLOSED_EXERCISE,
    status: ActivityStatus.STARTED,
    version: 1,
  };

  if (metadata) {
    data.generationFlowName = metadata.flowName;
    data.generationProvider = metadata.provider;
    data.generationModel = metadata.model;
    data.generationPromptVersion = metadata.promptVersion;
    data.generationSchemaVersion = metadata.schemaVersion;
    data.generationInputSize = metadata.inputSize;
  }

  return data;
}

function assertRichClosedExerciseIsPersistable(
  exercise: RichClosedExercise,
): void {
  const validation = validateRichClosedExercise(exercise);

  if (!validation.accepted) {
    throw new Error(RICH_CLOSED_START_INVALID_INPUT);
  }
}

function assertRichClosedSession(
  session: RichClosedExerciseSessionRecord | null,
): asserts session is RichClosedExerciseSessionRecord & {
  richClosedExercisePayload: RichClosedExercisePayloadRecord;
} {
  if (!session) {
    throw new Error(RICH_CLOSED_SESSION_NOT_FOUND);
  }

  if (
    session.type !== ActivityType.RICH_CLOSED_EXERCISE ||
    !session.richClosedExercisePayload
  ) {
    throw new Error(RICH_CLOSED_SESSION_NOT_FOUND);
  }
}

function toRichClosedExercise(
  payload: RichClosedExercisePayloadRecord,
): RichClosedExercise {
  const exercise = payload.exercisePayload;
  const validation = validateRichClosedExercise(exercise);

  if (!validation.accepted || !isRichClosedExercise(exercise)) {
    throw new Error(RICH_CLOSED_START_INVALID_INPUT);
  }

  return exercise;
}

function toRichClosedExerciseResult(
  sessionId: string,
  result: RichClosedExerciseResultRecord,
): RichClosedExerciseResult {
  if (!Array.isArray(result.correctionPayload)) {
    throw new Error(RICH_CLOSED_START_INVALID_INPUT);
  }

  return {
    sessionId,
    type: 'rich_closed_exercise',
    status: 'completed',
    correctAnswers: result.correctAnswers,
    totalQuestions: result.totalQuestions,
    score: result.score,
    items: result.correctionPayload as RichClosedExerciseResult['items'],
  };
}

function collectRichClosedSourceChunkIds(
  exercise: RichClosedExercise,
): string[] {
  return dedupeStrings(
    exercise.questions.flatMap((question) => question.sourceChunkIds),
  );
}

function isRichClosedExercise(value: unknown): value is RichClosedExercise {
  return (
    typeof value === 'object' &&
    value !== null &&
    !Array.isArray(value) &&
    Array.isArray((value as { questions?: unknown }).questions)
  );
}

function toJsonValue(value: unknown): Prisma.InputJsonValue {
  return JSON.parse(JSON.stringify(value)) as Prisma.InputJsonValue;
}

function toNullableJsonValue(
  value: unknown,
): Prisma.InputJsonValue | undefined {
  if (value === undefined) {
    return undefined;
  }

  return toJsonValue(value);
}

function buildQuestionCreateData(input: {
  sessionId: string;
  subjectId: string;
  documentId: string | null;
  knowledgeUnitId: string;
  question: GeneratedDiagnosticQuizQuestion;
  index: number;
  isSourcedVersion: boolean;
}) {
  const selectionMode =
    input.question.selectionMode === 'multiple'
      ? QuestionSelectionMode.MULTIPLE
      : QuestionSelectionMode.SINGLE;
  const data: Prisma.QuestionUncheckedCreateInput = {
    sessionId: input.sessionId,
    knowledgeUnitId: input.knowledgeUnitId,
    prompt: input.question.prompt,
    choices: toQuestionChoicesJson(input.question.choices),
    correctChoiceId:
      selectionMode === QuestionSelectionMode.SINGLE
        ? (input.question.correctChoiceId ?? null)
        : null,
    explanation: input.question.explanation,
  };

  if (selectionMode === QuestionSelectionMode.MULTIPLE) {
    data.selectionMode = QuestionSelectionMode.MULTIPLE;
    data.minSelections = input.question.minSelections ?? null;
    data.maxSelections = input.question.maxSelections ?? null;
    data.correctChoiceIds = toCorrectChoiceIdsJson(
      input.question.correctChoiceIds ?? [],
    );
  }

  if (input.isSourcedVersion) {
    data.subjectId = input.subjectId;
    data.documentId = input.documentId;
    data.difficulty = input.question.difficulty ?? null;
    data.displayOrder = input.index;
  }

  return data;
}

function buildQuestionVisualCreateData(input: {
  questionId: string;
  visual: GeneratedDiagnosticQuizVisual;
  fallbackDisplayOrder: number;
}): Prisma.QuestionVisualUncheckedCreateInput {
  return {
    questionId: input.questionId,
    type: toPrismaQuestionVisualType(input.visual.type),
    displayOrder: input.visual.displayOrder ?? input.fallbackDisplayOrder,
    payload: toQuestionVisualPayload(input.visual),
  };
}

function toPrismaQuestionVisualType(
  type: GeneratedDiagnosticQuizVisual['type'],
) {
  if (type === 'IMAGE') {
    return QuestionVisualType.IMAGE;
  }

  if (type === 'CHART') {
    return QuestionVisualType.CHART;
  }

  return QuestionVisualType.DIAGRAM;
}

function toQuestionVisualPayload(
  visual: GeneratedDiagnosticQuizVisual,
): Prisma.InputJsonValue {
  if (visual.type === 'IMAGE') {
    return {
      imageUrl: visual.imageUrl,
      altText: visual.altText,
      ...(visual.caption === undefined ? {} : { caption: visual.caption }),
    };
  }

  if (visual.type === 'CHART') {
    return {
      chartType: visual.chartType,
      title: visual.title,
      ...(visual.description === undefined
        ? {}
        : { description: visual.description }),
      data: visual.data,
      ...(visual.xKey === undefined ? {} : { xKey: visual.xKey }),
      ...(visual.yKeys === undefined ? {} : { yKeys: visual.yKeys }),
    };
  }

  return {
    title: visual.title,
    ...(visual.description === undefined
      ? {}
      : { description: visual.description }),
    nodes: visual.nodes,
    ...(visual.edges === undefined ? {} : { edges: visual.edges }),
  };
}

function assertGeneratedQuizIsPersistable(quiz: GeneratedDiagnosticQuiz): void {
  if (quiz.title.trim().length === 0 || quiz.questions.length === 0) {
    throw new Error('Generated diagnostic quiz is invalid');
  }

  for (const question of quiz.questions) {
    if (
      question.prompt.trim().length === 0 ||
      question.explanation.trim().length === 0 ||
      question.choices.length < 2
    ) {
      throw new Error('Generated diagnostic quiz is invalid');
    }

    const choiceIds = question.choices.map((choice) => choice.id);
    const selectionMode = question.selectionMode ?? 'single';

    if (new Set(choiceIds).size !== choiceIds.length) {
      throw new Error('Generated diagnostic quiz is invalid');
    }

    if (selectionMode === 'multiple') {
      const correctChoiceIds = question.correctChoiceIds ?? [];
      const minSelections = question.minSelections ?? 1;
      const maxSelections = question.maxSelections ?? correctChoiceIds.length;

      if (
        correctChoiceIds.length === 0 ||
        new Set(correctChoiceIds).size !== correctChoiceIds.length ||
        correctChoiceIds.some((choiceId) => !choiceIds.includes(choiceId)) ||
        minSelections < 1 ||
        maxSelections < minSelections ||
        maxSelections > choiceIds.length
      ) {
        throw new Error('Generated diagnostic quiz is invalid');
      }
    } else if (!choiceIds.includes(question.correctChoiceId ?? '')) {
      throw new Error('Generated diagnostic quiz is invalid');
    }

    if (
      (quiz.version ?? 1) > 1 &&
      (question.sourceChunkIds ?? []).length === 0
    ) {
      throw new Error('Generated diagnostic quiz is invalid');
    }

    for (const visual of question.visuals ?? []) {
      if ((visual.sourceChunkIds ?? []).length === 0) {
        throw new Error('Generated diagnostic quiz is invalid');
      }
    }
  }
}

function scoreDiagnosticQuizSubmission(
  session: ActivitySessionRecord,
  answers: Array<{
    questionId: string;
    choiceId?: string;
    choiceIds?: string[];
  }>,
): DiagnosticQuizSubmissionResult {
  if (session.questions.length === 0) {
    throw new Error('Activity session has no questions');
  }

  const answersByQuestionId = new Map<
    string,
    { choiceId?: string; choiceIds?: string[] }
  >();

  for (const answer of answers) {
    if (answersByQuestionId.has(answer.questionId)) {
      throw new Error('Duplicate answers are not allowed');
    }

    answersByQuestionId.set(answer.questionId, {
      ...(answer.choiceId === undefined ? {} : { choiceId: answer.choiceId }),
      ...(answer.choiceIds === undefined
        ? {}
        : { choiceIds: answer.choiceIds }),
    });
  }

  const items: ActivityQuestionCorrectionItem[] = [];
  let correctAnswers = 0;
  const questionIds = new Set(session.questions.map((question) => question.id));

  for (const answer of answers) {
    if (!questionIds.has(answer.questionId)) {
      throw new Error('Question does not belong to activity session');
    }
  }

  for (const question of session.questions) {
    const answer = answersByQuestionId.get(question.id);

    if (!answer) {
      throw new Error('Missing answers are not allowed');
    }

    const choices = parseInternalQuestionChoices(question.choices);
    const selectionMode =
      question.selectionMode === 'MULTIPLE' ? 'multiple' : 'single';
    const item =
      selectionMode === 'multiple'
        ? scoreMultipleAnswerQuestion(question, answer, choices)
        : scoreSingleAnswerQuestion(question, answer, choices);

    if (item.isCorrect) {
      correctAnswers += 1;
    }

    items.push(item);
  }

  const totalQuestions = session.questions.length;
  const score =
    totalQuestions === 0
      ? 0
      : Number((correctAnswers / totalQuestions).toFixed(3));

  return {
    correctAnswers,
    totalQuestions,
    score,
    knowledgeUnitId: session.knowledgeUnitId,
    items,
  };
}

function scoreSingleAnswerQuestion(
  question: QuestionRecord,
  answer: { choiceId?: string; choiceIds?: string[] },
  choices: ActivityQuestionChoiceRecord[],
): ActivityQuestionCorrectionItem {
  if (answer.choiceId === undefined || answer.choiceIds !== undefined) {
    throw new Error('Answer shape does not match question selection mode');
  }

  if (!choices.some((choice) => choice.id === answer.choiceId)) {
    throw new Error('Choice does not belong to question');
  }

  if (!question.correctChoiceId) {
    throw new Error('Generated diagnostic quiz is invalid');
  }

  const isCorrect = answer.choiceId === question.correctChoiceId;

  return {
    ...buildCorrectionItemBase(question, choices),
    selectedChoiceId: answer.choiceId,
    correctChoiceId: question.correctChoiceId,
    isCorrect,
  };
}

function scoreMultipleAnswerQuestion(
  question: QuestionRecord,
  answer: { choiceId?: string; choiceIds?: string[] },
  choices: ActivityQuestionChoiceRecord[],
): ActivityQuestionCorrectionItem {
  if (answer.choiceIds === undefined || answer.choiceId !== undefined) {
    throw new Error('Answer shape does not match question selection mode');
  }

  const selectedChoiceIds = dedupeStrings(answer.choiceIds);

  if (selectedChoiceIds.length !== answer.choiceIds.length) {
    throw new Error('Duplicate choices are not allowed');
  }

  const minSelections = question.minSelections ?? 1;
  const maxSelections = question.maxSelections ?? choices.length;

  if (
    selectedChoiceIds.length < minSelections ||
    selectedChoiceIds.length > maxSelections
  ) {
    throw new Error('Selection count is invalid for question');
  }

  const knownChoiceIds = new Set(choices.map((choice) => choice.id));

  if (selectedChoiceIds.some((choiceId) => !knownChoiceIds.has(choiceId))) {
    throw new Error('Choice does not belong to question');
  }

  const correctChoiceIds = parseStringArray(question.correctChoiceIds);

  if (correctChoiceIds.length === 0) {
    throw new Error('Generated diagnostic quiz is invalid');
  }

  const isCorrect = areStringSetsEqual(selectedChoiceIds, correctChoiceIds);

  return {
    ...buildCorrectionItemBase(question, choices),
    selectedChoiceIds,
    correctChoiceIds,
    isCorrect,
    partialScore: isCorrect ? 1 : 0,
  };
}

function buildCorrectionItemBase(
  question: QuestionRecord,
  choices: ActivityQuestionChoiceRecord[],
) {
  return {
    questionId: question.id,
    knowledgeUnitId: question.knowledgeUnitId,
    prompt: question.prompt,
    explanation: question.explanation,
    choiceFeedback: choices
      .filter((choice) => typeof choice.feedback === 'string')
      .map((choice) => ({
        choiceId: choice.id,
        feedback: choice.feedback as string,
      })),
    sources: (question.sources ?? [])
      .map((source) => ({
        chunkId: source.chunkId,
        text: source.chunk.text,
        pageNumber: source.chunk.pageNumber,
        index: source.chunk.index,
      }))
      .sort((left, right) => left.index - right.index),
  };
}

function parseStringArray(input: unknown): string[] {
  if (!Array.isArray(input)) {
    return [];
  }

  return input.filter((value): value is string => typeof value === 'string');
}

function areStringSetsEqual(left: string[], right: string[]): boolean {
  if (left.length !== right.length) {
    return false;
  }

  const rightValues = new Set(right);

  return left.every((value) => rightValues.has(value));
}

function toDiagnosticQuizGenerationContext(
  knowledgeUnit: KnowledgeUnitRecord,
): DiagnosticQuizGenerationContext {
  const chunkById = new Map<string, DocumentChunkRecord>();

  for (const source of knowledgeUnit.sources ?? []) {
    chunkById.set(source.chunk.id, source.chunk);
  }

  const chunks = Array.from(chunkById.values())
    .sort((left, right) => left.index - right.index)
    .map((chunk) => ({
      id: chunk.id,
      index: chunk.index,
      text: chunk.text,
      pageNumber: chunk.pageNumber,
    }));

  const baseKnowledgeUnit = new KnowledgeUnit({
    id: knowledgeUnit.id,
    subjectId: knowledgeUnit.subjectId,
    title: knowledgeUnit.title,
    summary: knowledgeUnit.summary,
  });

  return {
    documentId: knowledgeUnit.documentId,
    knowledgeUnit: Object.assign(baseKnowledgeUnit, {
      difficulty: knowledgeUnit.difficulty,
      sourceChunkIds: chunks.map((chunk) => chunk.id),
    }),
    chunks,
  };
}

function toDiagnosticQuizActivity(
  session: ActivitySessionRecord,
  title = 'Quiz de diagnostic',
): DiagnosticQuizActivity {
  const activity: DiagnosticQuizActivity = {
    sessionId: session.id,
    type: 'diagnostic_quiz',
    title,
    questions: session.questions.map(toActivityQuestion),
  };

  if ((session.version ?? 1) > 1) {
    activity.version = session.version;
    activity.documentId = session.documentId ?? null;
    activity.subjectId = session.subjectId;
  }

  return activity;
}

function toOpenQuestionActivity(
  session: OpenQuestionSessionRecord,
): OpenQuestionActivity {
  if (!session.openQuestion) {
    throw new Error('Open question not found');
  }

  return {
    sessionId: session.id,
    type: 'open_question',
    version: session.openQuestion.version,
    subjectId: session.subjectId,
    documentId: session.openQuestion.documentId,
    knowledgeUnitId: session.knowledgeUnitId,
    question: {
      id: session.openQuestion.id,
      prompt: session.openQuestion.prompt,
      instructions: session.openQuestion.instructions,
      maxAnswerLength: session.openQuestion.maxAnswerLength,
      sources: (session.openQuestion.sources ?? [])
        .map((source) => ({
          chunkId: source.chunkId,
          pageNumber: source.chunk.pageNumber,
          index: source.chunk.index,
        }))
        .sort((left, right) => left.index - right.index),
    },
  };
}

function assertOpenQuestionSessionCanBeEvaluated(
  session: OpenAnswerEvaluationSessionRecord | null,
): asserts session is OpenAnswerEvaluationSessionRecord & {
  openQuestion: OpenQuestionRecord;
} {
  if (!session) {
    throw new Error('Activity session not found');
  }

  if (session.type !== ActivityType.OPEN_QUESTION) {
    throw new Error('Activity session is not an open question');
  }

  if (
    session.status !== ActivityStatus.STARTED ||
    session.openAnswerEvaluation
  ) {
    throw new Error('Activity session already submitted');
  }

  if (!session.openQuestion) {
    throw new Error('Open question not found');
  }
}

function toOpenAnswerEvaluationContext(
  session: OpenAnswerEvaluationSessionRecord & {
    openQuestion: OpenQuestionRecord;
  },
): OpenAnswerEvaluationContext {
  const chunks = collectOpenQuestionSourceChunks(session);

  return {
    sessionId: session.id,
    subjectId: session.subjectId,
    documentId: session.openQuestion.documentId,
    knowledgeUnit: Object.assign(
      new KnowledgeUnit({
        id: session.knowledgeUnit.id,
        subjectId: session.knowledgeUnit.subjectId,
        title: session.knowledgeUnit.title,
        summary: session.knowledgeUnit.summary,
      }),
      {
        difficulty: session.knowledgeUnit.difficulty,
        sourceChunkIds: chunks.map((chunk) => chunk.id),
      },
    ),
    question: {
      id: session.openQuestion.id,
      prompt: session.openQuestion.prompt,
      instructions: session.openQuestion.instructions,
      sourceChunkIds: chunks.map((chunk) => chunk.id),
    },
    chunks: chunks.map((chunk) => ({
      id: chunk.id,
      index: chunk.index,
      text: chunk.text,
      pageNumber: chunk.pageNumber,
    })),
  };
}

function collectOpenQuestionSourceChunks(
  session: OpenAnswerEvaluationSessionRecord & {
    openQuestion: OpenQuestionRecord;
  },
): DocumentChunkRecord[] {
  const chunksById = new Map<string, DocumentChunkRecord>();

  for (const source of session.openQuestion.sources ?? []) {
    chunksById.set(source.chunk.id, source.chunk);
  }

  if (chunksById.size === 0) {
    for (const source of session.knowledgeUnit.sources ?? []) {
      chunksById.set(source.chunk.id, source.chunk);
    }
  }

  return [...chunksById.values()].sort(
    (left, right) => left.index - right.index,
  );
}

function assertOpenAnswerEvaluationSources(
  evaluation: OpenAnswerEvaluationDraft,
  sourceChunks: DocumentChunkRecord[],
): void {
  if (evaluation.status === 'FAILED') {
    return;
  }

  const knownChunkIds = new Set(sourceChunks.map((chunk) => chunk.id));
  const sourceChunkIds = dedupeStrings(evaluation.sourceChunkIds);

  if (sourceChunks.length === 0 && sourceChunkIds.length > 0) {
    throw new Error('OPEN_ANSWER_EVALUATION_SOURCE_INVALID');
  }

  if (
    sourceChunks.length > 0 &&
    (sourceChunkIds.length === 0 ||
      sourceChunkIds.some((chunkId) => !knownChunkIds.has(chunkId)))
  ) {
    throw new Error('OPEN_ANSWER_EVALUATION_SOURCE_INVALID');
  }
}

function selectOpenAnswerEvaluationSourceChunks(
  evaluation: OpenAnswerEvaluationDraft,
  sourceChunks: DocumentChunkRecord[],
): DocumentChunkRecord[] {
  if (evaluation.status === 'FAILED') {
    return [];
  }

  const requestedIds = new Set(evaluation.sourceChunkIds);

  return sourceChunks.filter((chunk) => requestedIds.has(chunk.id));
}

function buildOpenAnswerEvaluationCreateData(input: {
  session: OpenAnswerEvaluationSessionRecord & {
    openQuestion: OpenQuestionRecord;
  };
  studentId: string;
  answerText: string;
  evaluation: OpenAnswerEvaluationDraft;
}): Prisma.OpenAnswerEvaluationUncheckedCreateInput {
  const base: Prisma.OpenAnswerEvaluationUncheckedCreateInput = {
    sessionId: input.session.id,
    openQuestionId: input.session.openQuestion.id,
    studentId: input.studentId,
    subjectId: input.session.subjectId,
    answerText: input.answerText,
    status:
      input.evaluation.status === 'READY'
        ? OpenAnswerEvaluationStatus.READY
        : OpenAnswerEvaluationStatus.FAILED,
    score: null,
    maxScore: null,
    feedback: null,
    presentPoints: [],
    missingPoints: [],
    errors: [],
    modelAnswer: null,
    advice: null,
  };

  if (input.evaluation.metadata) {
    base.generationFlowName = input.evaluation.metadata.flowName;
    base.generationProvider = input.evaluation.metadata.provider;
    base.generationModel = input.evaluation.metadata.model;
    base.generationPromptVersion = input.evaluation.metadata.promptVersion;
    base.generationSchemaVersion = input.evaluation.metadata.schemaVersion;
    base.generationInputSize = input.evaluation.metadata.inputSize;
  }

  if (input.evaluation.status === 'FAILED') {
    base.errorCode = input.evaluation.errorCode;
    base.errors = [input.evaluation.errorCode];
    return base;
  }

  base.score = input.evaluation.score;
  base.maxScore = input.evaluation.maxScore;
  base.feedback = input.evaluation.feedback;
  base.presentPoints = input.evaluation.presentPoints;
  base.missingPoints = input.evaluation.missingPoints;
  base.errors = input.evaluation.errors;
  base.modelAnswer = input.evaluation.modelAnswer;
  base.advice = input.evaluation.advice;

  return base;
}

function toOpenAnswerSubmissionResult(
  evaluation: OpenAnswerEvaluationRecord,
  sourceChunks: DocumentChunkRecord[] = [],
): OpenAnswerSubmissionResult {
  return {
    sessionId: evaluation.sessionId,
    type: 'open_question',
    status: 'submitted',
    evaluation: {
      id: evaluation.id,
      status: evaluation.status,
      score: evaluation.score,
      maxScore: evaluation.maxScore,
      feedback: evaluation.feedback,
      presentPoints: parseJsonArray(evaluation.presentPoints),
      missingPoints: parseJsonArray(evaluation.missingPoints),
      errors: parseJsonArray(evaluation.errors),
      modelAnswer: evaluation.modelAnswer,
      advice: evaluation.advice,
      sources:
        evaluation.status === 'READY'
          ? sourceChunks.map((chunk) => ({
              chunkId: chunk.id,
              text: truncateText(
                chunk.text,
                OPEN_ANSWER_SOURCE_EXCERPT_MAX_LENGTH,
              ),
              pageNumber: chunk.pageNumber,
              index: chunk.index,
            }))
          : [],
    },
  };
}

function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) {
    return text;
  }

  return text.slice(0, maxLength).trimEnd();
}

function parseJsonArray(input: unknown): unknown[] {
  return Array.isArray(input) ? input : [];
}

function toActivityQuestion(question: QuestionRecord): ActivityQuestion {
  const sources = (question.sources ?? [])
    .map((source) => ({
      chunkId: source.chunkId,
      pageNumber: source.chunk.pageNumber,
      index: source.chunk.index,
    }))
    .sort((left, right) => left.index - right.index);

  return {
    id: question.id,
    knowledgeUnitId: question.knowledgeUnitId,
    prompt: question.prompt,
    difficulty: question.difficulty ?? null,
    ...(question.selectionMode === 'MULTIPLE'
      ? { selectionMode: toPublicSelectionMode(question.selectionMode) }
      : {}),
    ...(question.minSelections === undefined
      ? {}
      : { minSelections: question.minSelections }),
    ...(question.maxSelections === undefined
      ? {}
      : { maxSelections: question.maxSelections }),
    choices: parsePublicQuestionChoices(question.choices),
    ...(sources.length > 0 ? { sources } : {}),
    ...toPublicQuestionVisuals(question.visuals),
  };
}

function toPublicSelectionMode(
  selectionMode: QuestionRecord['selectionMode'],
): 'single' | 'multiple' {
  return selectionMode === 'MULTIPLE' ? 'multiple' : 'single';
}

function toPublicQuestionVisuals(visuals: QuestionVisualRecord[] | undefined) {
  const publicVisuals = (visuals ?? [])
    .map(toPublicQuestionVisual)
    .filter(
      (
        visual,
      ): visual is NonNullable<ReturnType<typeof toPublicQuestionVisual>> =>
        Boolean(visual),
    )
    .sort((left, right) => left.displayOrder - right.displayOrder);

  return publicVisuals.length > 0 ? { visuals: publicVisuals } : {};
}

function toPublicQuestionVisual(
  visual: QuestionVisualRecord,
): ActivityQuestionVisual | null {
  const sources = (visual.sources ?? [])
    .map((source) => ({
      chunkId: source.chunkId,
      pageNumber: source.chunk.pageNumber,
      index: source.chunk.index,
    }))
    .sort((left, right) => left.index - right.index);

  if (visual.type === 'IMAGE') {
    const payload = parseRecord(visual.payload);
    const imageUrl =
      typeof payload.imageUrl === 'string' ? payload.imageUrl : '';
    const altText = typeof payload.altText === 'string' ? payload.altText : '';

    if (!imageUrl || !altText) {
      return null;
    }

    return {
      id: visual.id,
      type: 'IMAGE' as const,
      displayOrder: visual.displayOrder,
      imageUrl,
      altText,
      caption:
        typeof payload.caption === 'string' || payload.caption === null
          ? payload.caption
          : undefined,
      sources,
    };
  }

  if (visual.type === 'CHART') {
    const payload = parseRecord(visual.payload);
    const chartType = parseChartType(payload.chartType);
    const title = typeof payload.title === 'string' ? payload.title : '';
    const data = parseChartData(payload.data);

    if (!chartType || !title || data.length === 0) {
      return null;
    }

    return {
      id: visual.id,
      type: 'CHART' as const,
      displayOrder: visual.displayOrder,
      chartType,
      title,
      description:
        typeof payload.description === 'string' || payload.description === null
          ? payload.description
          : undefined,
      data,
      xKey:
        typeof payload.xKey === 'string' || payload.xKey === null
          ? payload.xKey
          : undefined,
      yKeys: parseOptionalStringArray(payload.yKeys),
      sources,
    };
  }

  const payload = parseRecord(visual.payload);
  const title = typeof payload.title === 'string' ? payload.title : '';
  const nodes = parseDiagramNodes(payload.nodes);
  const edges = parseDiagramEdges(payload.edges);

  if (!title || nodes.length === 0) {
    return null;
  }

  return {
    id: visual.id,
    type: 'DIAGRAM' as const,
    displayOrder: visual.displayOrder,
    title,
    description:
      typeof payload.description === 'string' || payload.description === null
        ? payload.description
        : undefined,
    nodes,
    ...(edges === undefined ? {} : { edges }),
    sources,
  };
}

function toQuestionChoicesJson(
  choices: GeneratedDiagnosticQuizChoice[],
): Prisma.InputJsonValue {
  return choices.map((choice) => ({
    id: choice.id,
    label: choice.label,
    ...(choice.feedback !== undefined ? { feedback: choice.feedback } : {}),
  }));
}

function toCorrectChoiceIdsJson(choiceIds: string[]): Prisma.InputJsonValue {
  return choiceIds;
}

function parsePublicQuestionChoices(input: unknown) {
  return parseInternalQuestionChoices(input).map((choice) => ({
    id: choice.id,
    label: choice.label,
  }));
}

function parseInternalQuestionChoices(
  input: unknown,
): ActivityQuestionChoiceRecord[] {
  if (!Array.isArray(input)) {
    return [];
  }

  return input
    .filter(
      (choice): choice is Record<string, unknown> =>
        typeof choice === 'object' && choice !== null,
    )
    .map((choice) => ({
      id: typeof choice.id === 'string' ? choice.id : '',
      label: typeof choice.label === 'string' ? choice.label : '',
      feedback:
        typeof choice.feedback === 'string'
          ? choice.feedback
          : choice.feedback === null
            ? null
            : undefined,
    }))
    .filter((choice) => choice.id.length > 0 && choice.label.length > 0);
}

function parseRecord(input: unknown): Record<string, unknown> {
  if (typeof input !== 'object' || input === null || Array.isArray(input)) {
    return {};
  }

  return input as Record<string, unknown>;
}

function parseChartType(
  input: unknown,
): 'bar' | 'line' | 'pie' | 'scatter' | null {
  return input === 'bar' ||
    input === 'line' ||
    input === 'pie' ||
    input === 'scatter'
    ? input
    : null;
}

function parseChartData(
  input: unknown,
): Array<Record<string, string | number | null>> {
  if (!Array.isArray(input)) {
    return [];
  }

  return input
    .map(parseRecord)
    .map((row) =>
      Object.fromEntries(
        Object.entries(row).filter(
          (entry): entry is [string, string | number | null] =>
            typeof entry[1] === 'string' ||
            typeof entry[1] === 'number' ||
            entry[1] === null,
        ),
      ),
    )
    .filter((row) => Object.keys(row).length > 0);
}

function parseOptionalStringArray(input: unknown): string[] | null | undefined {
  if (input === null) {
    return null;
  }

  if (input === undefined) {
    return undefined;
  }

  if (!Array.isArray(input)) {
    return undefined;
  }

  const values = input.filter(
    (value): value is string => typeof value === 'string',
  );

  return values.length === input.length ? values : undefined;
}

function parseDiagramNodes(input: unknown) {
  if (!Array.isArray(input)) {
    return [];
  }

  return input
    .map(parseRecord)
    .map((node) => ({
      id: typeof node.id === 'string' ? node.id : '',
      label: typeof node.label === 'string' ? node.label : '',
    }))
    .filter((node) => node.id.length > 0 && node.label.length > 0);
}

function parseDiagramEdges(input: unknown) {
  if (input === undefined) {
    return undefined;
  }

  if (!Array.isArray(input)) {
    return undefined;
  }

  return input
    .map(parseRecord)
    .map((edge) => ({
      from: typeof edge.from === 'string' ? edge.from : '',
      to: typeof edge.to === 'string' ? edge.to : '',
      label:
        typeof edge.label === 'string' || edge.label === null
          ? edge.label
          : undefined,
    }))
    .filter((edge) => edge.from.length > 0 && edge.to.length > 0);
}

function collectQuizSourceChunkIds(
  questions: GeneratedDiagnosticQuizQuestion[],
): string[] {
  return dedupeStrings(
    questions.flatMap((question) => [
      ...(question.sourceChunkIds ?? []),
      ...(question.visuals ?? []).flatMap((visual) => visual.sourceChunkIds),
    ]),
  );
}

function dedupeStrings(values: string[]): string[] {
  return Array.from(new Set(values));
}
````

### api/src/modules/activities/interfaces/activities.controller.ts

````ts
import {
  BadRequestException,
  Body,
  ConflictException,
  Controller,
  Get,
  NotFoundException,
  Param,
  Post,
  UnprocessableEntityException,
  UseGuards,
} from '@nestjs/common';
import { CurrentStudent } from '../../auth/interfaces/current-student.decorator';
import { FirebaseAuthGuard } from '../../auth/interfaces/firebase-auth.guard';
import {
  DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID,
  resolveDiagnosticQuizMaxQuestionCount,
  resolveDiagnosticQuizQuestionCount,
} from '../application/diagnostic-quiz-question-count';
import { StartOpenQuestionActivityUseCase } from '../application/start-open-question-activity.use-case';
import { StartNextActivityUseCase } from '../application/start-next-activity.use-case';
import { SubmitOpenAnswerUseCase } from '../application/submit-open-answer.use-case';
import { SubmitActivityResultUseCase } from '../application/submit-activity-result.use-case';
import {
  RICH_CLOSED_GENERATION_CONTRACT_INVALID,
  RICH_CLOSED_GENERATION_FAILED,
  RICH_CLOSED_GENERATION_QUALITY_REJECTED,
  RICH_CLOSED_GENERATION_SCHEMA_INVALID,
  RICH_CLOSED_GENERATION_SOURCE_INVALID,
  RICH_CLOSED_SESSION_ALREADY_COMPLETED,
  RICH_CLOSED_SESSION_NOT_COMPLETED,
  RICH_CLOSED_SESSION_NOT_FOUND,
  RICH_CLOSED_SOURCE_CONTEXT_EMPTY,
  RICH_CLOSED_START_INVALID_INPUT,
  RICH_CLOSED_SUBMIT_INVALID_INPUT,
} from '../application/rich-closed-questions/rich-closed-question-errors';
import { GetRichClosedExerciseResultUseCase } from '../application/rich-closed-questions/get-rich-closed-exercise-result.use-case';
import { GetRichClosedExerciseUseCase } from '../application/rich-closed-questions/get-rich-closed-exercise.use-case';
import {
  RICH_CLOSED_QUESTION_KINDS,
  type RichClosedAnswer,
  type RichClosedQuestionKind,
} from '../application/rich-closed-questions/rich-closed-question.types';
import {
  assertRichClosedQuestionTypeMix,
  StartRichClosedExerciseUseCase,
} from '../application/rich-closed-questions/start-rich-closed-exercise.use-case';
import { SubmitRichClosedExerciseUseCase } from '../application/rich-closed-questions/submit-rich-closed-exercise.use-case';
import type {
  DiagnosticQuizSelectionMode,
  DiagnosticQuizVisualType,
} from '../application/diagnostic-quiz-generator';

class StartActivityDto {
  subjectId!: string;
  knowledgeUnitId?: string;
  questionCount?: number;
  visualsEnabled?: boolean;
  visualTypes?: string[];
  selectionModes?: string[];
}

class SubmitActivityDto {
  answers!: Array<{
    questionId: string;
    choiceId?: string;
    choiceIds?: string[];
  }>;
}

class StartOpenQuestionDto {
  subjectId!: string;
  knowledgeUnitId!: string;
}

class SubmitOpenAnswerDto {
  answerText!: string;
}

class StartRichClosedExerciseDto {
  subjectId!: string;
  documentId?: string | null;
  knowledgeUnitId!: string;
  questionCount?: number;
  complexityProfile?: string;
  questionTypeMix?: Record<string, unknown>;
}

class SubmitRichClosedExerciseDto {
  answers!: unknown[];
}

interface ValidatedActivityAnswer {
  questionId: string;
  choiceId?: string;
  choiceIds?: string[];
}

interface ValidatedStartActivityBody {
  subjectId: string;
  knowledgeUnitId?: string;
  questionCount?: number;
  visualsEnabled?: boolean;
  visualTypes?: DiagnosticQuizVisualType[];
  selectionModes?: DiagnosticQuizSelectionMode[];
}

interface ValidatedStartRichClosedBody {
  subjectId: string;
  documentId?: string | null;
  knowledgeUnitId: string;
  questionCount: number;
  complexityProfile: 'standard' | 'exam' | 'advanced';
  questionTypeMix?: Partial<Record<RichClosedQuestionKind, number>>;
}

@Controller('activities')
@UseGuards(FirebaseAuthGuard)
export class ActivitiesController {
  constructor(
    private readonly startNextActivity: StartNextActivityUseCase,
    private readonly startOpenQuestionActivity: StartOpenQuestionActivityUseCase,
    private readonly submitActivityResult: SubmitActivityResultUseCase,
    private readonly submitOpenAnswer: SubmitOpenAnswerUseCase,
    private readonly startRichClosedExercise: StartRichClosedExerciseUseCase,
    private readonly getRichClosedExercise: GetRichClosedExerciseUseCase,
    private readonly submitRichClosedExercise: SubmitRichClosedExerciseUseCase,
    private readonly getRichClosedExerciseResult: GetRichClosedExerciseResultUseCase,
  ) {}

  @Post('next')
  start(
    @CurrentStudent() student: { id: string },
    @Body() body: StartActivityDto,
  ) {
    const validatedBody = validateStartActivityBody(body);

    return this.startNextActivity
      .execute({
        studentId: student.id,
        subjectId: validatedBody.subjectId,
        knowledgeUnitId: validatedBody.knowledgeUnitId,
        questionCount: validatedBody.questionCount,
        visualsEnabled: validatedBody.visualsEnabled,
        visualTypes: validatedBody.visualTypes,
        selectionModes: validatedBody.selectionModes,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }

  @Post('open-question')
  startOpenQuestion(
    @CurrentStudent() student: { id: string },
    @Body() body: StartOpenQuestionDto,
  ) {
    const validatedBody = validateStartOpenQuestionBody(body);

    return this.startOpenQuestionActivity
      .execute({
        studentId: student.id,
        subjectId: validatedBody.subjectId,
        knowledgeUnitId: validatedBody.knowledgeUnitId,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }

  @Post('rich-closed/start')
  startRichClosed(
    @CurrentStudent() student: { id: string },
    @Body() body: StartRichClosedExerciseDto,
  ) {
    const validatedBody = validateStartRichClosedBody(body);

    return this.startRichClosedExercise
      .execute({
        studentId: student.id,
        subjectId: validatedBody.subjectId,
        documentId: validatedBody.documentId,
        knowledgeUnitId: validatedBody.knowledgeUnitId,
        questionCount: validatedBody.questionCount,
        complexityProfile: validatedBody.complexityProfile,
        questionTypeMix: validatedBody.questionTypeMix,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }

  @Get('rich-closed/:sessionId')
  getRichClosed(
    @CurrentStudent() student: { id: string },
    @Param('sessionId') sessionId: string,
  ) {
    const validatedSessionId = validateRequiredId(
      sessionId,
      'Activity session id',
    );

    return this.getRichClosedExercise
      .execute({
        studentId: student.id,
        sessionId: validatedSessionId,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }

  @Post('rich-closed/:sessionId/submit')
  submitRichClosed(
    @CurrentStudent() student: { id: string },
    @Param('sessionId') sessionId: string,
    @Body() body: SubmitRichClosedExerciseDto,
  ) {
    const validatedSessionId = validateRequiredId(
      sessionId,
      'Activity session id',
    );
    const validatedBody = validateSubmitRichClosedBody(body);

    return this.submitRichClosedExercise
      .execute({
        studentId: student.id,
        sessionId: validatedSessionId,
        answers: validatedBody.answers,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }

  @Get('rich-closed/:sessionId/result')
  getRichClosedResult(
    @CurrentStudent() student: { id: string },
    @Param('sessionId') sessionId: string,
  ) {
    const validatedSessionId = validateRequiredId(
      sessionId,
      'Activity session id',
    );

    return this.getRichClosedExerciseResult
      .execute({
        studentId: student.id,
        sessionId: validatedSessionId,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }

  @Post(':sessionId/result')
  submit(
    @CurrentStudent() student: { id: string },
    @Param('sessionId') sessionId: string,
    @Body() body: SubmitActivityDto,
  ) {
    const validatedSessionId = validateRequiredId(
      sessionId,
      'Activity session id',
    );
    const validatedBody = validateSubmitActivityBody(body);

    return this.submitActivityResult
      .execute({
        studentId: student.id,
        sessionId: validatedSessionId,
        answers: validatedBody.answers,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }

  @Post(':sessionId/open-answer')
  submitOpenQuestionAnswer(
    @CurrentStudent() student: { id: string },
    @Param('sessionId') sessionId: string,
    @Body() body: SubmitOpenAnswerDto,
  ) {
    const validatedSessionId = validateRequiredId(
      sessionId,
      'Activity session id',
    );
    const validatedBody = validateSubmitOpenAnswerBody(body);

    return this.submitOpenAnswer
      .execute({
        studentId: student.id,
        sessionId: validatedSessionId,
        answerText: validatedBody.answerText,
      })
      .catch((error: unknown) => {
        normalizeActivityError(error);
      });
  }
}

function validateStartActivityBody(
  input: StartActivityDto,
): ValidatedStartActivityBody {
  return {
    subjectId: validateRequiredId(input?.subjectId, 'Subject id'),
    knowledgeUnitId:
      input?.knowledgeUnitId === undefined
        ? undefined
        : validateRequiredId(input.knowledgeUnitId, 'Knowledge unit id'),
    questionCount: validateQuestionCount(input?.questionCount),
    visualsEnabled: validateOptionalBoolean(
      input?.visualsEnabled,
      'Visuals enabled',
    ),
    visualTypes: validateVisualTypes(input?.visualTypes),
    selectionModes: validateSelectionModes(input?.selectionModes),
  };
}

function validateSubmitActivityBody(input: SubmitActivityDto): {
  answers: ValidatedActivityAnswer[];
} {
  if (!Array.isArray(input?.answers)) {
    throw new BadRequestException('Activity answers must be an array');
  }

  const seenQuestionIds = new Set<string>();
  const answers = input.answers.map((answer) => {
    const questionId = validateRequiredId(answer?.questionId, 'Question id');
    const choiceId =
      answer?.choiceId === undefined
        ? undefined
        : validateRequiredId(answer.choiceId, 'Choice id');
    const choiceIds =
      answer?.choiceIds === undefined
        ? undefined
        : validateChoiceIds(answer.choiceIds);

    if ((choiceId === undefined) === (choiceIds === undefined)) {
      throw new BadRequestException(
        'Exactly one of choiceId or choiceIds is required',
      );
    }

    if (seenQuestionIds.has(questionId)) {
      throw new BadRequestException('Duplicate answers are not allowed');
    }

    seenQuestionIds.add(questionId);

    return {
      questionId,
      ...(choiceId === undefined ? {} : { choiceId }),
      ...(choiceIds === undefined ? {} : { choiceIds }),
    };
  });

  return { answers };
}

function validateStartOpenQuestionBody(input: StartOpenQuestionDto): {
  subjectId: string;
  knowledgeUnitId: string;
} {
  return {
    subjectId: validateRequiredId(input?.subjectId, 'Subject id'),
    knowledgeUnitId: validateRequiredId(
      input?.knowledgeUnitId,
      'Knowledge unit id',
    ),
  };
}

function validateSubmitOpenAnswerBody(input: SubmitOpenAnswerDto): {
  answerText: string;
} {
  if (typeof input?.answerText !== 'string') {
    throw new BadRequestException('Open answer text is required');
  }

  const answerText = input.answerText.trim();

  if (answerText.length === 0) {
    throw new BadRequestException('Open answer text is required');
  }

  return { answerText };
}

function validateStartRichClosedBody(
  input: StartRichClosedExerciseDto,
): ValidatedStartRichClosedBody {
  const questionCount = validateRichClosedQuestionCount(input?.questionCount);
  const questionTypeMix =
    input?.questionTypeMix === undefined
      ? undefined
      : validateRichClosedQuestionTypeMix(input.questionTypeMix, questionCount);

  return {
    subjectId: validateRequiredId(input?.subjectId, 'Subject id'),
    documentId: validateOptionalId(input?.documentId, 'Document id'),
    knowledgeUnitId: validateRequiredId(
      input?.knowledgeUnitId,
      'Knowledge unit id',
    ),
    questionCount,
    complexityProfile: validateRichClosedComplexityProfile(
      input?.complexityProfile,
    ),
    ...(questionTypeMix === undefined ? {} : { questionTypeMix }),
  };
}

function validateSubmitRichClosedBody(input: SubmitRichClosedExerciseDto): {
  answers: RichClosedAnswer[];
} {
  if (!Array.isArray(input?.answers) || input.answers.length === 0) {
    throw new BadRequestException(
      'Rich closed answers must be a non-empty array',
    );
  }

  const seenQuestionIds = new Set<string>();
  const answers = input.answers.map((answer) => {
    const validatedAnswer = validateRichClosedAnswer(answer);

    if (seenQuestionIds.has(validatedAnswer.questionId)) {
      throw new BadRequestException('Duplicate answers are not allowed');
    }

    seenQuestionIds.add(validatedAnswer.questionId);

    return validatedAnswer;
  });

  return { answers };
}

function validateOptionalBoolean(input: unknown, label: string) {
  if (input === undefined) {
    return undefined;
  }

  if (typeof input !== 'boolean') {
    throw new BadRequestException(`${label} must be a boolean`);
  }

  return input;
}

function validateVisualTypes(
  input: unknown,
): DiagnosticQuizVisualType[] | undefined {
  if (input === undefined) {
    return undefined;
  }

  if (!Array.isArray(input)) {
    throw new BadRequestException(
      'Diagnostic quiz visualTypes must be an array',
    );
  }

  const visualTypes = input.map((value) => {
    if (typeof value !== 'string') {
      throw new BadRequestException(
        'Diagnostic quiz visualTypes must contain strings',
      );
    }

    const normalized = value.trim().toUpperCase();

    if (normalized === 'IMAGE') {
      throw new BadRequestException(
        'Diagnostic quiz IMAGE visuals are not supported yet',
      );
    }

    if (normalized !== 'CHART' && normalized !== 'DIAGRAM') {
      throw new BadRequestException('Diagnostic quiz visual type is invalid');
    }

    return normalized;
  });

  return Array.from(new Set(visualTypes));
}

function validateSelectionModes(
  input: unknown,
): DiagnosticQuizSelectionMode[] | undefined {
  if (input === undefined) {
    return undefined;
  }

  if (!Array.isArray(input)) {
    throw new BadRequestException(
      'Diagnostic quiz selectionModes must be an array',
    );
  }

  const selectionModes = input.map((value) => {
    if (typeof value !== 'string') {
      throw new BadRequestException(
        'Diagnostic quiz selectionModes must contain strings',
      );
    }

    const normalized = value.trim();

    if (normalized !== 'single' && normalized !== 'multiple') {
      throw new BadRequestException(
        'Diagnostic quiz selection mode is invalid',
      );
    }

    return normalized;
  });

  return Array.from(new Set(selectionModes));
}

function validateChoiceIds(input: unknown): string[] {
  if (!Array.isArray(input) || input.length === 0) {
    throw new BadRequestException('Choice ids must be a non-empty array');
  }

  return input.map((choiceId) => validateRequiredId(choiceId, 'Choice id'));
}

function validateOptionalId(
  input: unknown,
  label: string,
): string | null | undefined {
  if (input === undefined) {
    return undefined;
  }

  if (input === null) {
    return null;
  }

  return validateRequiredId(input, label);
}

function validateRequiredId(input: unknown, label: string): string {
  if (typeof input !== 'string' || input.trim().length === 0) {
    throw new BadRequestException(`${label} is required`);
  }

  return input.trim();
}

function validateQuestionCount(input: unknown): number | undefined {
  if (input === undefined) {
    return undefined;
  }

  if (typeof input !== 'number') {
    throw questionCountBadRequest();
  }

  try {
    return resolveDiagnosticQuizQuestionCount(input);
  } catch (error) {
    if (
      error instanceof Error &&
      error.message === DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID
    ) {
      throw questionCountBadRequest();
    }

    throw error;
  }
}

function validateRichClosedQuestionCount(input: unknown): number {
  if (input === undefined) {
    return 6;
  }

  if (
    typeof input !== 'number' ||
    !Number.isInteger(input) ||
    input < 6 ||
    input > 20
  ) {
    throw new BadRequestException(
      'Rich closed question count must be an integer between 6 and 20',
    );
  }

  return input;
}

function validateRichClosedComplexityProfile(
  input: unknown,
): 'standard' | 'exam' | 'advanced' {
  if (input === undefined) {
    return 'exam';
  }

  if (input === 'standard' || input === 'exam' || input === 'advanced') {
    return input;
  }

  throw new BadRequestException('Rich closed complexity profile is invalid');
}

function validateRichClosedQuestionTypeMix(
  input: unknown,
  questionCount: number,
): Partial<Record<RichClosedQuestionKind, number>> {
  if (typeof input !== 'object' || input === null || Array.isArray(input)) {
    throw new BadRequestException(
      'Rich closed questionTypeMix must be an object',
    );
  }

  const mix: Partial<Record<RichClosedQuestionKind, number>> = {};

  for (const [key, value] of Object.entries(input)) {
    if (
      !isRichClosedQuestionKind(key) ||
      !Number.isInteger(value) ||
      value < 0
    ) {
      throw new BadRequestException('Rich closed questionTypeMix is invalid');
    }

    mix[key] = Number(value);
  }

  try {
    assertRichClosedQuestionTypeMix({
      questionCount,
      questionTypeMix: mix,
    });
  } catch {
    throw new BadRequestException('Rich closed questionTypeMix is invalid');
  }

  return mix;
}

function validateRichClosedAnswer(input: unknown): RichClosedAnswer {
  if (
    typeof input !== 'object' ||
    input === null ||
    Array.isArray(input) ||
    containsForbiddenRichClosedSubmitField(input)
  ) {
    throw new BadRequestException('Rich closed answer is invalid');
  }

  const answer = input as Record<string, unknown>;
  const questionId = validateRequiredId(answer.questionId, 'Question id');
  const questionKind = answer.questionKind;

  if (!isRichClosedQuestionKind(questionKind)) {
    throw new BadRequestException('Rich closed question kind is invalid');
  }

  switch (questionKind) {
    case 'single_choice':
    case 'case_qualification':
      return {
        questionId,
        questionKind,
        choiceId: validateRequiredId(answer.choiceId, 'Choice id'),
      };
    case 'multiple_choice':
      return {
        questionId,
        questionKind,
        choiceIds: validateChoiceIds(answer.choiceIds),
      };
    case 'matching':
      return {
        questionId,
        questionKind,
        pairs: validateRichClosedPairs(answer.pairs),
      };
    case 'ordering':
      return {
        questionId,
        questionKind,
        orderedIds: validateChoiceIds(answer.orderedIds),
      };
    case 'error_detection':
      return {
        questionId,
        questionKind,
        errorId: validateRequiredId(answer.errorId, 'Error id'),
      };
  }
}

function validateRichClosedPairs(input: unknown): Array<{
  leftId: string;
  rightId: string;
}> {
  if (!Array.isArray(input) || input.length === 0) {
    throw new BadRequestException('Rich closed matching pairs are required');
  }

  return input.map((pair) => {
    if (typeof pair !== 'object' || pair === null || Array.isArray(pair)) {
      throw new BadRequestException('Rich closed matching pair is invalid');
    }

    const record = pair as Record<string, unknown>;

    return {
      leftId: validateRequiredId(record.leftId, 'Left id'),
      rightId: validateRequiredId(record.rightId, 'Right id'),
    };
  });
}

function containsForbiddenRichClosedSubmitField(value: unknown): boolean {
  if (Array.isArray(value)) {
    return value.some(containsForbiddenRichClosedSubmitField);
  }

  if (typeof value !== 'object' || value === null) {
    return false;
  }

  return Object.entries(value).some(([key, nested]) => {
    if (
      key.startsWith('correct') ||
      key === 'correctionPayload' ||
      key === 'explanation' ||
      key === 'feedback' ||
      key === 'choiceFeedback' ||
      key === 'modelAnswer' ||
      key === 'answerText' ||
      key === 'freeTextAnswer' ||
      key === 'textAnswer' ||
      key === 'score' ||
      key === 'partialScore' ||
      key === 'workedSteps'
    ) {
      return true;
    }

    return containsForbiddenRichClosedSubmitField(nested);
  });
}

function isRichClosedQuestionKind(
  value: unknown,
): value is RichClosedQuestionKind {
  return (
    typeof value === 'string' &&
    RICH_CLOSED_QUESTION_KINDS.includes(value as RichClosedQuestionKind)
  );
}

function questionCountBadRequest(): BadRequestException {
  return new BadRequestException(
    `Diagnostic quiz question count must be an integer between 1 and ${resolveDiagnosticQuizMaxQuestionCount()}`,
  );
}

function normalizeActivityError(error: unknown): never {
  if (error instanceof Error) {
    if (error.message === 'Activity session not found') {
      throw new NotFoundException(error.message);
    }

    if (error.message === RICH_CLOSED_SESSION_NOT_FOUND) {
      throw new NotFoundException(error.message);
    }

    if (error.message === 'Activity session already completed') {
      throw new ConflictException(error.message);
    }

    if (error.message === 'Activity session already submitted') {
      throw new ConflictException(error.message);
    }

    if (
      error.message === RICH_CLOSED_SESSION_ALREADY_COMPLETED ||
      error.message === RICH_CLOSED_SESSION_NOT_COMPLETED
    ) {
      throw new ConflictException(error.message);
    }

    if (
      error.message === 'Knowledge unit does not belong to student subject' ||
      error.message === 'No knowledge unit available for subject' ||
      error.message === 'Activity session is not an open question' ||
      error.message === 'Open answer is too short' ||
      error.message === 'Open answer is too long' ||
      error.message === 'Duplicate answers are not allowed' ||
      error.message === 'Missing answers are not allowed' ||
      error.message === 'Question does not belong to activity session' ||
      error.message === 'Choice does not belong to question' ||
      error.message === 'Answer shape does not match question selection mode' ||
      error.message === 'Selection count is invalid for question' ||
      error.message === RICH_CLOSED_START_INVALID_INPUT ||
      error.message === RICH_CLOSED_SUBMIT_INVALID_INPUT
    ) {
      throw new BadRequestException(error.message);
    }

    if (
      error.message === 'Generated diagnostic quiz is invalid' ||
      error.message === 'Question source chunk not found' ||
      error.message === 'Question visual source chunk not found' ||
      error.message === 'Open question source chunk not found' ||
      error.message === 'OPEN_QUESTION_SOURCE_INVALID' ||
      error.message === 'OPEN_QUESTION_GENERATION_INVALID' ||
      error.message === 'OPEN_QUESTION_EMPTY_OUTPUT' ||
      error.message === 'OPEN_ANSWER_EVALUATION_SOURCE_INVALID' ||
      error.message === 'OPEN_ANSWER_EVALUATION_INVALID' ||
      error.message === 'OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT' ||
      error.message === 'OPEN_ANSWER_EVALUATION_FAILED' ||
      error.message === RICH_CLOSED_SOURCE_CONTEXT_EMPTY ||
      error.message === RICH_CLOSED_GENERATION_FAILED ||
      error.message === RICH_CLOSED_GENERATION_SCHEMA_INVALID ||
      error.message === RICH_CLOSED_GENERATION_CONTRACT_INVALID ||
      error.message === RICH_CLOSED_GENERATION_QUALITY_REJECTED ||
      error.message === RICH_CLOSED_GENERATION_SOURCE_INVALID
    ) {
      throw new UnprocessableEntityException(error.message);
    }
  }

  throw error;
}
````

### api/test/critical-paths.e2e-spec.ts

````ts
import { INestApplication, NotFoundException } from '@nestjs/common';
import type { ExecutionContext } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { TOKEN_VERIFIER } from '../src/modules/auth/application/token-verifier';
import { FirebaseAuthGuard } from '../src/modules/auth/interfaces/firebase-auth.guard';
import { StartNextActivityUseCase } from '../src/modules/activities/application/start-next-activity.use-case';
import { StartOpenQuestionActivityUseCase } from '../src/modules/activities/application/start-open-question-activity.use-case';
import { SubmitActivityResultUseCase } from '../src/modules/activities/application/submit-activity-result.use-case';
import { SubmitOpenAnswerUseCase } from '../src/modules/activities/application/submit-open-answer.use-case';
import { GetRichClosedExerciseResultUseCase } from '../src/modules/activities/application/rich-closed-questions/get-rich-closed-exercise-result.use-case';
import { GetRichClosedExerciseUseCase } from '../src/modules/activities/application/rich-closed-questions/get-rich-closed-exercise.use-case';
import { StartRichClosedExerciseUseCase } from '../src/modules/activities/application/rich-closed-questions/start-rich-closed-exercise.use-case';
import { SubmitRichClosedExerciseUseCase } from '../src/modules/activities/application/rich-closed-questions/submit-rich-closed-exercise.use-case';
import { GetDocumentUseCase } from '../src/modules/documents/application/get-document.use-case';
import { ListDocumentKnowledgeUnitsUseCase } from '../src/modules/documents/application/list-document-knowledge-units.use-case';
import { GetTodayPlanUseCase } from '../src/modules/revision/application/get-today-plan.use-case';
import { GetRevisionSessionUseCase } from '../src/modules/revision-sessions/application/get-revision-session.use-case';
import { RequestNextRevisionSessionActionUseCase } from '../src/modules/revision-sessions/application/request-next-revision-session-action.use-case';
import { StartRevisionSessionUseCase } from '../src/modules/revision-sessions/application/start-revision-session.use-case';
import { GenerateDocumentSummaryUseCase } from '../src/modules/study-artifacts/application/generate-document-summary.use-case';
import { GenerateRevisionSheetUseCase } from '../src/modules/study-artifacts/application/generate-revision-sheet.use-case';
import { GetDocumentSummaryUseCase } from '../src/modules/study-artifacts/application/get-document-summary.use-case';
import { GetRevisionSheetUseCase } from '../src/modules/study-artifacts/application/get-revision-sheet.use-case';
import { PrismaService } from '../src/shared/infrastructure/prisma/prisma.service';

jest.mock('firebase-admin/app', () => ({
  getApps: jest.fn(() => []),
  initializeApp: jest.fn(),
}));

jest.mock('firebase-admin/auth', () => ({
  getAuth: jest.fn(() => ({
    verifyIdToken: jest.fn(),
  })),
}));

type CriticalPathMocks = ReturnType<typeof createCriticalPathMocks>;
type KnowledgeUnitsResponse = ReturnType<typeof documentKnowledgeUnits>;
type SummaryResponse = ReturnType<typeof documentSummary>;
type RevisionSheetResponse = ReturnType<typeof revisionSheet>;
type TodayPlanResponse = ReturnType<typeof todayPlan>;
type ActivityResponse = ReturnType<typeof diagnosticQuizActivity>;
type OpenQuestionResponse = ReturnType<typeof openQuestionActivity>;

const currentStudent = {
  id: 'student-demo-test',
  firebaseUid: 'firebase-demo-test-uid',
  email: 'demo-revision@example.test',
  displayName: 'Demo Revision',
};

describe('Critical demo paths (e2e)', () => {
  describe('protected routes', () => {
    let app: INestApplication<App>;

    beforeEach(async () => {
      app = await createAppWithRealAuthGuard();
    });

    afterEach(async () => {
      await app?.close();
    });

    it('rejects critical demo routes without a bearer token', async () => {
      // This suite keeps the real FirebaseAuthGuard behavior for missing-token
      // checks, but the verifier itself is mocked so no Firebase network call
      // can happen even if a future test adds a token.
      const server = app.getHttpServer();

      await request(server).get('/today').expect(401);
      await request(server).get('/documents/document-1').expect(401);
      await request(server)
        .get('/documents/document-1/knowledge-units')
        .expect(401);
      await request(server)
        .post('/activities/next')
        .send({ subjectId: 'subject-1' })
        .expect(401);
      await request(server)
        .post('/activities/open-question')
        .send({ subjectId: 'subject-1', knowledgeUnitId: 'unit-1' })
        .expect(401);
      await request(server)
        .post('/activities/rich-closed/start')
        .send({ subjectId: 'subject-1', knowledgeUnitId: 'unit-1' })
        .expect(401);
      await request(server)
        .post('/revision-sessions')
        .send({ subjectId: 'subject-1' })
        .expect(401);
    });
  });

  describe('authenticated contracts', () => {
    let app: INestApplication<App>;
    let mocks: CriticalPathMocks;

    beforeEach(async () => {
      mocks = createCriticalPathMocks();
      app = await createAuthenticatedApp(mocks);
    });

    afterEach(async () => {
      await app?.close();
    });

    it('routes document and knowledge-unit reads with ownership context and no storage path leak', async () => {
      const server = app.getHttpServer();

      const documentResponse = await request(server)
        .get('/documents/document-1')
        .expect(200);

      expect(mocks.getDocument.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        documentId: 'document-1',
      });
      expect(documentResponse.body).toMatchObject({
        id: 'document-1',
        subjectId: 'subject-1',
        status: 'READY',
      });
      assertNoSensitivePreSubmitFields(documentResponse.body);

      const knowledgeUnitsResponse = await request(server)
        .get('/documents/document-1/knowledge-units')
        .expect(200);
      const knowledgeUnitsBody =
        knowledgeUnitsResponse.body as KnowledgeUnitsResponse;

      expect(mocks.listDocumentKnowledgeUnits.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        documentId: 'document-1',
      });
      expect(knowledgeUnitsBody.items[0].sources[0]).toMatchObject({
        chunkId: 'chunk-1',
        pageNumber: 1,
        index: 0,
      });
      assertNoSensitivePreSubmitFields(knowledgeUnitsResponse.body);
    });

    it('maps missing documents to a clean 404 response', async () => {
      mocks.getDocument.execute.mockRejectedValueOnce(
        new NotFoundException('Document not found'),
      );

      await request(app.getHttpServer())
        .get('/documents/missing-document')
        .expect(404);
    });

    it('serves ready summary and revision sheet without internal metadata', async () => {
      const server = app.getHttpServer();

      const summaryResponse = await request(server)
        .get('/documents/document-1/summary')
        .expect(200);
      const summaryBody = summaryResponse.body as SummaryResponse;

      expect(mocks.getDocumentSummary.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        documentId: 'document-1',
      });
      expect(summaryBody.title).toBe('Synthèse de démonstration');
      assertNoSensitivePreSubmitFields(summaryResponse.body);
      expect(JSON.stringify(summaryResponse.body)).not.toContain('provider');
      expect(JSON.stringify(summaryResponse.body)).not.toContain(
        'promptVersion',
      );

      const sheetResponse = await request(server)
        .get('/documents/document-1/revision-sheet')
        .expect(200);
      const sheetBody = sheetResponse.body as RevisionSheetResponse;

      expect(mocks.getRevisionSheet.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        documentId: 'document-1',
      });
      expect(sheetBody.sections).toHaveLength(1);
      assertNoSensitivePreSubmitFields(sheetResponse.body);
      expect(JSON.stringify(sheetResponse.body)).not.toContain('provider');
      expect(JSON.stringify(sheetResponse.body)).not.toContain('promptVersion');
    });

    it('returns a deterministic multi-action TodayPlan for the current student', async () => {
      const response = await request(app.getHttpServer())
        .get('/today')
        .expect(200);
      const todayBody = response.body as TodayPlanResponse;

      expect(mocks.getTodayPlan.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
      });
      expect(todayBody.items.map((item) => item.action)).toEqual([
        'diagnostic_quiz',
        'open_question',
        'revision_session',
      ]);
      expect(JSON.stringify(response.body)).not.toContain('other-student');
    });

    it('starts a QCM with bounded v3 options and no correction leak', async () => {
      const response = await request(app.getHttpServer())
        .post('/activities/next')
        .send({
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          questionCount: 12,
          visualsEnabled: true,
          visualTypes: ['CHART', 'DIAGRAM'],
          selectionModes: ['single', 'multiple'],
        })
        .expect(201);
      const responseBody = response.body as ActivityResponse;

      expect(mocks.startNextActivity.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
        questionCount: 12,
        visualsEnabled: true,
        visualTypes: ['CHART', 'DIAGRAM'],
        selectionModes: ['single', 'multiple'],
      });
      expect(responseBody.type).toBe('diagnostic_quiz');
      assertNoSensitivePreSubmitFields(response.body);
    });

    it('rejects invalid QCM payloads before calling the use case', async () => {
      await request(app.getHttpServer())
        .post('/activities/next')
        .send({
          subjectId: 'subject-1',
          questionCount: 25,
          visualTypes: ['IMAGE'],
        })
        .expect(400);

      expect(mocks.startNextActivity.execute).not.toHaveBeenCalled();
    });

    it('submits QCM answers and maps critical submit errors', async () => {
      const server = app.getHttpServer();

      await request(server)
        .post('/activities/quiz-session-1/result')
        .send({
          answers: [
            { questionId: 'question-1', choiceId: 'choice-1' },
            { questionId: 'question-2', choiceIds: ['choice-2', 'choice-3'] },
          ],
        })
        .expect(201);

      expect(mocks.submitActivityResult.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        sessionId: 'quiz-session-1',
        answers: [
          { questionId: 'question-1', choiceId: 'choice-1' },
          { questionId: 'question-2', choiceIds: ['choice-2', 'choice-3'] },
        ],
      });

      await request(server)
        .post('/activities/quiz-session-1/result')
        .send({ answers: [{ questionId: 'question-1' }] })
        .expect(400);

      mocks.submitActivityResult.execute.mockRejectedValueOnce(
        new Error('Activity session not found'),
      );
      await request(server)
        .post('/activities/missing-session/result')
        .send({ answers: [{ questionId: 'question-1', choiceId: 'choice-1' }] })
        .expect(404);

      mocks.submitActivityResult.execute.mockRejectedValueOnce(
        new Error('Activity session already submitted'),
      );
      await request(server)
        .post('/activities/submitted-session/result')
        .send({ answers: [{ questionId: 'question-1', choiceId: 'choice-1' }] })
        .expect(409);

      mocks.submitActivityResult.execute.mockRejectedValueOnce(
        new Error('Generated diagnostic quiz is invalid'),
      );
      await request(server)
        .post('/activities/invalid-generation/result')
        .send({ answers: [{ questionId: 'question-1', choiceId: 'choice-1' }] })
        .expect(422);
    });

    it('starts an open question without exposing correction fields', async () => {
      const response = await request(app.getHttpServer())
        .post('/activities/open-question')
        .send({ subjectId: 'subject-1', knowledgeUnitId: 'unit-1' })
        .expect(201);
      const responseBody = response.body as OpenQuestionResponse;

      expect(mocks.startOpenQuestionActivity.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      });
      expect(responseBody.type).toBe('open_question');
      assertNoSensitivePreSubmitFields(response.body);
    });

    it('validates open question start and submit payloads', async () => {
      const server = app.getHttpServer();

      await request(server)
        .post('/activities/open-question')
        .send({ subjectId: 'subject-1' })
        .expect(400);
      expect(mocks.startOpenQuestionActivity.execute).not.toHaveBeenCalled();

      await request(server)
        .post('/activities/open-session-1/open-answer')
        .send({ answerText: '   ' })
        .expect(400);
      expect(mocks.submitOpenAnswer.execute).not.toHaveBeenCalled();
    });

    it('submits an open answer and maps critical evaluation errors', async () => {
      const server = app.getHttpServer();
      const answerText =
        'La distinction entre les régimes parlementaire et présidentiel repose sur la responsabilité politique du gouvernement et sur la séparation institutionnelle des pouvoirs.';

      await request(server)
        .post('/activities/open-session-1/open-answer')
        .send({ answerText })
        .expect(201);

      expect(mocks.submitOpenAnswer.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        sessionId: 'open-session-1',
        answerText,
      });

      mocks.submitOpenAnswer.execute.mockRejectedValueOnce(
        new Error('Activity session not found'),
      );
      await request(server)
        .post('/activities/missing-session/open-answer')
        .send({ answerText })
        .expect(404);

      mocks.submitOpenAnswer.execute.mockRejectedValueOnce(
        new Error('Activity session is not an open question'),
      );
      await request(server)
        .post('/activities/quiz-session/open-answer')
        .send({ answerText })
        .expect(400);

      mocks.submitOpenAnswer.execute.mockRejectedValueOnce(
        new Error('OPEN_ANSWER_EVALUATION_INVALID'),
      );
      await request(server)
        .post('/activities/open-session-invalid/open-answer')
        .send({ answerText })
        .expect(422);
    });

    it('routes rich closed start, get, submit and result without pre-submit leaks', async () => {
      const server = app.getHttpServer();

      const startResponse = await request(server)
        .post('/activities/rich-closed/start')
        .send({
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          questionCount: 6,
        })
        .expect(201);

      expect(mocks.startRichClosedExercise.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        subjectId: 'subject-1',
        documentId: undefined,
        knowledgeUnitId: 'unit-1',
        questionCount: 6,
        complexityProfile: 'exam',
        questionTypeMix: undefined,
      });
      const startBody = startResponse.body as { type: string };
      expect(startBody.type).toBe('rich_closed_exercise');
      assertNoSensitivePreSubmitFields(startResponse.body);
      expect(JSON.stringify(startResponse.body)).not.toContain('explanation');
      expect(JSON.stringify(startResponse.body)).not.toContain('feedback');

      await request(server)
        .get('/activities/rich-closed/rich-session-1')
        .expect(200);
      expect(mocks.getRichClosedExercise.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        sessionId: 'rich-session-1',
      });

      const submitResponse = await request(server)
        .post('/activities/rich-closed/rich-session-1/submit')
        .send({ answers: richClosedAnswers() })
        .expect(201);

      expect(mocks.submitRichClosedExercise.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        sessionId: 'rich-session-1',
        answers: richClosedAnswers(),
      });
      const submitBody = submitResponse.body as {
        items: Array<Record<string, unknown>>;
      };
      expect(submitBody.items[0]).toHaveProperty('correction');

      await request(server)
        .get('/activities/rich-closed/rich-session-1/result')
        .expect(200);
      expect(mocks.getRichClosedExerciseResult.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        sessionId: 'rich-session-1',
      });
    });

    it('validates and maps rich closed errors', async () => {
      const server = app.getHttpServer();

      await request(server)
        .post('/activities/rich-closed/start')
        .send({
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          questionCount: 5,
        })
        .expect(400);
      expect(mocks.startRichClosedExercise.execute).not.toHaveBeenCalled();

      await request(server)
        .post('/activities/rich-closed/rich-session-1/submit')
        .send({
          answers: [
            {
              questionId: 'single-1',
              questionKind: 'single_choice',
              choiceId: 'choice-a',
              modelAnswer: 'interdit',
            },
          ],
        })
        .expect(400);
      expect(mocks.submitRichClosedExercise.execute).not.toHaveBeenCalled();

      mocks.getRichClosedExercise.execute.mockRejectedValueOnce(
        new Error('RICH_CLOSED_SESSION_NOT_FOUND'),
      );
      await request(server)
        .get('/activities/rich-closed/missing-session')
        .expect(404);

      mocks.submitRichClosedExercise.execute.mockRejectedValueOnce(
        new Error('RICH_CLOSED_SESSION_ALREADY_COMPLETED'),
      );
      await request(server)
        .post('/activities/rich-closed/rich-session-1/submit')
        .send({ answers: richClosedAnswers() })
        .expect(409);

      mocks.startRichClosedExercise.execute.mockRejectedValueOnce(
        new Error('RICH_CLOSED_GENERATION_QUALITY_REJECTED'),
      );
      await request(server)
        .post('/activities/rich-closed/start')
        .send({
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          questionCount: 6,
        })
        .expect(422);
    });

    it('routes revision sessions and next actions without free-message leakage', async () => {
      const server = app.getHttpServer();

      const startResponse = await request(server)
        .post('/revision-sessions')
        .send({
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          preferredAction: 'open_question',
        })
        .expect(201);

      expect(mocks.startRevisionSession.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        subjectId: 'subject-1',
        documentId: undefined,
        knowledgeUnitId: 'unit-1',
        preferredAction: 'open_question',
      });
      assertNoSensitivePreSubmitFields(startResponse.body);

      await request(server)
        .get('/revision-sessions/revision-session-1')
        .expect(200);
      expect(mocks.getRevisionSession.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        sessionId: 'revision-session-1',
      });

      await request(server)
        .post('/revision-sessions/revision-session-1/next-action')
        .send({ message: 'ignore this free text' })
        .expect(201);

      expect(mocks.requestNextAction.execute).toHaveBeenCalledWith({
        studentId: currentStudent.id,
        sessionId: 'revision-session-1',
      });
      expect(
        JSON.stringify(mocks.requestNextAction.execute.mock.calls),
      ).not.toContain('ignore this free text');
    });

    it('validates and maps revision session errors', async () => {
      const server = app.getHttpServer();

      await request(server)
        .post('/revision-sessions')
        .send({ subjectId: 'subject-1', preferredAction: 'chat' })
        .expect(400);
      expect(mocks.startRevisionSession.execute).not.toHaveBeenCalled();

      mocks.startRevisionSession.execute.mockRejectedValueOnce(
        new Error('Open question revision session requires a knowledge unit'),
      );
      await request(server)
        .post('/revision-sessions')
        .send({ subjectId: 'subject-1', preferredAction: 'open_question' })
        .expect(422);

      mocks.getRevisionSession.execute.mockRejectedValueOnce(
        new Error('Revision session not found'),
      );
      await request(server)
        .get('/revision-sessions/missing-session')
        .expect(404);
    });
  });
});

async function createAppWithRealAuthGuard(): Promise<INestApplication<App>> {
  const moduleFixture = await Test.createTestingModule({
    imports: [AppModule],
  })
    .overrideProvider(TOKEN_VERIFIER)
    .useValue({ verify: jest.fn() })
    .overrideProvider(PrismaService)
    .useValue({})
    .compile();

  const app = moduleFixture.createNestApplication();
  await app.init();
  return app;
}

async function createAuthenticatedApp(
  mocks: CriticalPathMocks,
): Promise<INestApplication<App>> {
  const moduleFixture = await Test.createTestingModule({
    imports: [AppModule],
  })
    .overrideGuard(FirebaseAuthGuard)
    .useValue({
      canActivate: (context: ExecutionContext) => {
        // The e2e suite verifies controller contracts, not Firebase itself.
        // Injecting an explicit fake student keeps every request scoped while
        // avoiding Firebase Admin and BootstrapStudentUseCase side effects.
        const httpRequest = context
          .switchToHttp()
          .getRequest<{ student?: typeof currentStudent }>();
        httpRequest.student = currentStudent;
        return true;
      },
    })
    .overrideProvider(TOKEN_VERIFIER)
    .useValue({ verify: jest.fn() })
    .overrideProvider(PrismaService)
    .useValue({})
    .overrideProvider(GetDocumentUseCase)
    .useValue(mocks.getDocument)
    .overrideProvider(ListDocumentKnowledgeUnitsUseCase)
    .useValue(mocks.listDocumentKnowledgeUnits)
    .overrideProvider(GetDocumentSummaryUseCase)
    .useValue(mocks.getDocumentSummary)
    .overrideProvider(GenerateDocumentSummaryUseCase)
    .useValue(mocks.generateDocumentSummary)
    .overrideProvider(GetRevisionSheetUseCase)
    .useValue(mocks.getRevisionSheet)
    .overrideProvider(GenerateRevisionSheetUseCase)
    .useValue(mocks.generateRevisionSheet)
    .overrideProvider(GetTodayPlanUseCase)
    .useValue(mocks.getTodayPlan)
    .overrideProvider(StartNextActivityUseCase)
    .useValue(mocks.startNextActivity)
    .overrideProvider(StartOpenQuestionActivityUseCase)
    .useValue(mocks.startOpenQuestionActivity)
    .overrideProvider(SubmitActivityResultUseCase)
    .useValue(mocks.submitActivityResult)
    .overrideProvider(SubmitOpenAnswerUseCase)
    .useValue(mocks.submitOpenAnswer)
    .overrideProvider(StartRichClosedExerciseUseCase)
    .useValue(mocks.startRichClosedExercise)
    .overrideProvider(GetRichClosedExerciseUseCase)
    .useValue(mocks.getRichClosedExercise)
    .overrideProvider(SubmitRichClosedExerciseUseCase)
    .useValue(mocks.submitRichClosedExercise)
    .overrideProvider(GetRichClosedExerciseResultUseCase)
    .useValue(mocks.getRichClosedExerciseResult)
    .overrideProvider(StartRevisionSessionUseCase)
    .useValue(mocks.startRevisionSession)
    .overrideProvider(GetRevisionSessionUseCase)
    .useValue(mocks.getRevisionSession)
    .overrideProvider(RequestNextRevisionSessionActionUseCase)
    .useValue(mocks.requestNextAction)
    .compile();

  const app = moduleFixture.createNestApplication();
  await app.init();
  return app;
}

function createCriticalPathMocks() {
  return {
    getDocument: {
      execute: jest.fn().mockResolvedValue(publicDocument()),
    },
    listDocumentKnowledgeUnits: {
      execute: jest.fn().mockResolvedValue(documentKnowledgeUnits()),
    },
    getDocumentSummary: {
      execute: jest.fn().mockResolvedValue(documentSummary()),
    },
    generateDocumentSummary: {
      execute: jest.fn().mockResolvedValue(documentSummary()),
    },
    getRevisionSheet: {
      execute: jest.fn().mockResolvedValue(revisionSheet()),
    },
    generateRevisionSheet: {
      execute: jest.fn().mockResolvedValue(revisionSheet()),
    },
    getTodayPlan: {
      execute: jest.fn().mockResolvedValue(todayPlan()),
    },
    startNextActivity: {
      execute: jest.fn().mockResolvedValue(diagnosticQuizActivity()),
    },
    startOpenQuestionActivity: {
      execute: jest.fn().mockResolvedValue(openQuestionActivity()),
    },
    submitActivityResult: {
      execute: jest.fn().mockResolvedValue(qcmSubmissionResult()),
    },
    submitOpenAnswer: {
      execute: jest.fn().mockResolvedValue(openAnswerSubmissionResult()),
    },
    startRichClosedExercise: {
      execute: jest.fn().mockResolvedValue(richClosedPublicExercise()),
    },
    getRichClosedExercise: {
      execute: jest.fn().mockResolvedValue(richClosedPublicExercise()),
    },
    submitRichClosedExercise: {
      execute: jest.fn().mockResolvedValue(richClosedResult()),
    },
    getRichClosedExerciseResult: {
      execute: jest.fn().mockResolvedValue(richClosedResult()),
    },
    startRevisionSession: {
      execute: jest.fn().mockResolvedValue(revisionSessionResponse()),
    },
    getRevisionSession: {
      execute: jest.fn().mockResolvedValue(revisionSessionResponse()),
    },
    requestNextAction: {
      execute: jest.fn().mockResolvedValue(revisionSessionResponse()),
    },
  };
}

function publicDocument() {
  return {
    id: 'document-1',
    subjectId: 'subject-1',
    kind: 'COURSE_PDF',
    fileName: 'demo-droit-constitutionnel.pdf',
    mimeType: 'application/pdf',
    status: 'READY',
    errorCode: null,
  };
}

function documentKnowledgeUnits() {
  return {
    documentId: 'document-1',
    items: [
      {
        id: 'unit-1',
        subjectId: 'subject-1',
        documentId: 'document-1',
        title: 'Séparation des pouvoirs',
        summary: 'La séparation des pouvoirs organise les institutions.',
        difficulty: 'MEDIUM',
        displayOrder: 0,
        sources: [
          {
            chunkId: 'chunk-1',
            pageNumber: 1,
            index: 0,
          },
        ],
      },
    ],
  };
}

function documentSummary() {
  return {
    id: 'summary-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Synthèse de démonstration',
    content: 'La Ve République articule stabilité exécutive et contrôle.',
    keyPoints: ['Séparation des pouvoirs', 'Contrôle constitutionnel'],
    limits: 'Synthèse courte issue des fixtures de démonstration.',
    errorCode: null,
    metadata: {
      provider: 'demo-seed',
      promptVersion: 'demo-seed-v1',
    },
    storagePath: 'internal/demo.pdf',
    sources: [
      {
        chunkId: 'chunk-1',
        text: 'Extrait borné.',
        pageNumber: 1,
        index: 0,
        relevanceScore: 0.9,
      },
    ],
  };
}

function revisionSheet() {
  return {
    id: 'sheet-1',
    documentId: 'document-1',
    subjectId: 'subject-1',
    status: 'READY',
    title: 'Fiche de démonstration',
    introduction: 'Fiche courte de droit constitutionnel.',
    keyPoints: ['Pouvoir exécutif', 'Parlement'],
    commonMistakes: ['Confondre régime parlementaire et présidentiel.'],
    mustKnow: ['Responsabilité politique du gouvernement.'],
    practiceSuggestions: ['Comparer deux institutions.'],
    errorCode: null,
    metadata: {
      provider: 'demo-seed',
      promptVersion: 'demo-seed-v1',
    },
    sections: [
      {
        id: 'section-1',
        displayOrder: 0,
        title: 'Institutions',
        content: 'Le régime organise les rapports entre les pouvoirs.',
        sources: [
          {
            chunkId: 'chunk-2',
            text: 'Extrait de fiche borné.',
            pageNumber: 2,
            index: 1,
            relevanceScore: 0.8,
          },
        ],
      },
    ],
  };
}

function todayPlan() {
  return {
    generatedAt: new Date('2026-06-15T12:00:00.000Z'),
    items: [
      {
        id: 'today-1',
        subjectId: 'subject-1',
        subjectName: 'Droit constitutionnel',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Séparation des pouvoirs',
        masteryScore: 0.2,
        action: 'diagnostic_quiz',
        estimatedMinutes: 12,
        priority: 170,
        reasonCode: 'LOW_MASTERY',
        reason: 'À revoir en priorité.',
        startPayload: {
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
          preferredAction: 'diagnostic_quiz',
        },
      },
      {
        id: 'today-2',
        subjectId: 'subject-1',
        subjectName: 'Droit constitutionnel',
        knowledgeUnitId: 'unit-2',
        knowledgeUnitTitle: 'Contrôle de constitutionnalité',
        masteryScore: null,
        action: 'open_question',
        estimatedMinutes: 18,
        priority: 140,
        reasonCode: 'MIX_ACTIVITY_TYPE',
        reason: 'Change de format pour renforcer la mémorisation.',
        startPayload: {
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-2',
          preferredAction: 'open_question',
        },
      },
      {
        id: 'today-3',
        subjectId: 'subject-1',
        subjectName: 'Droit constitutionnel',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Séparation des pouvoirs',
        masteryScore: 0.2,
        action: 'revision_session',
        estimatedMinutes: 25,
        priority: 120,
        reasonCode: 'START_REVISION_SESSION',
        reason: 'Lance une session guidée.',
        startPayload: {
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        },
      },
    ],
  };
}

function diagnosticQuizActivity() {
  return {
    sessionId: 'quiz-session-1',
    type: 'diagnostic_quiz',
    title: 'QCM de démonstration',
    questions: [
      {
        id: 'question-1',
        prompt: 'Quel principe organise les pouvoirs ?',
        difficulty: 'MEDIUM',
        selectionMode: 'single',
        choices: [
          { id: 'choice-1', label: 'La séparation des pouvoirs' },
          { id: 'choice-2', label: 'La confusion des pouvoirs' },
        ],
        sources: [{ chunkId: 'chunk-1', pageNumber: 1, index: 0 }],
      },
    ],
  };
}

function qcmSubmissionResult() {
  return {
    correctAnswers: 2,
    totalQuestions: 2,
    score: 1,
    knowledgeUnitId: 'unit-1',
    items: [
      {
        questionId: 'question-1',
        selectedChoiceId: 'choice-1',
        correctChoiceId: 'choice-1',
        isCorrect: true,
      },
    ],
  };
}

function openQuestionActivity() {
  return {
    sessionId: 'open-session-1',
    type: 'open_question',
    version: 1,
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-1',
    question: {
      id: 'open-question-1',
      prompt: 'Explique la séparation des pouvoirs.',
      instructions: 'Structure ta réponse en deux paragraphes.',
      maxAnswerLength: 2500,
      sources: [{ chunkId: 'chunk-1', pageNumber: 1, index: 0 }],
    },
  };
}

function openAnswerSubmissionResult() {
  return {
    sessionId: 'open-session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: {
      id: 'evaluation-1',
      status: 'READY',
      score: 16,
      maxScore: 20,
      feedback: 'Réponse structurée.',
      presentPoints: ['Séparation institutionnelle'],
      missingPoints: ['Responsabilité politique'],
      errors: [],
      modelAnswer: 'La séparation des pouvoirs distingue les fonctions.',
      advice: 'Revois le régime parlementaire.',
      sources: [
        {
          chunkId: 'chunk-1',
          text: 'Extrait post-submit borné.',
          pageNumber: 1,
          index: 0,
        },
      ],
    },
  };
}

function richClosedPublicExercise() {
  return {
    sessionId: 'rich-session-1',
    type: 'rich_closed_exercise',
    id: 'rich-exercise-1',
    version: 'rich-closed-question-v1',
    title: 'Exercice fermé riche',
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-1',
    questions: [
      {
        id: 'single-1',
        questionKind: 'single_choice',
        prompt: 'Quel critère institutionnel caractérise le parlementarisme ?',
        difficulty: 'MEDIUM',
        cognitiveSkill: 'comparison',
        sourceChunkIds: ['chunk-1'],
        choices: [
          { id: 'choice-a', label: 'Responsabilité politique' },
          { id: 'choice-b', label: 'Indépendance absolue' },
        ],
      },
    ],
  };
}

function richClosedResult() {
  return {
    sessionId: 'rich-session-1',
    type: 'rich_closed_exercise',
    status: 'completed',
    correctAnswers: 1,
    totalQuestions: 1,
    score: 1,
    items: [
      {
        questionId: 'single-1',
        questionKind: 'single_choice',
        prompt: 'Quel critère institutionnel caractérise le parlementarisme ?',
        submittedAnswer: {
          questionId: 'single-1',
          questionKind: 'single_choice',
          choiceId: 'choice-a',
        },
        isCorrect: true,
        partialScore: 1,
        explanation:
          'La responsabilité politique est un critère du régime parlementaire.',
        sourceChunkIds: ['chunk-1'],
        correction: {
          correctChoiceId: 'choice-a',
        },
      },
    ],
  };
}

function richClosedAnswers() {
  return [
    {
      questionId: 'single-1',
      questionKind: 'single_choice',
      choiceId: 'choice-a',
    },
  ];
}

function revisionSessionResponse() {
  return {
    session: {
      id: 'revision-session-1',
      status: 'STARTED',
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      createdAt: new Date('2026-06-15T12:00:00.000Z'),
      completedAt: null,
    },
    currentAction: {
      id: 'action-1',
      kind: 'OPEN_QUESTION',
      status: 'READY',
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: openQuestionActivity(),
    },
    history: [
      {
        id: 'action-1',
        kind: 'OPEN_QUESTION',
        status: 'READY',
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
      },
    ],
  };
}

function assertNoSensitivePreSubmitFields(payload: unknown): void {
  const serialized = JSON.stringify(payload);

  expect(serialized).not.toContain('correctChoiceId');
  expect(serialized).not.toContain('correctChoiceIds');
  expect(serialized).not.toContain('modelAnswer');
  expect(serialized).not.toContain('storagePath');
  expect(serialized).not.toContain('promptVersion');
  expect(serialized).not.toContain('completion');
}
````

### revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md

````md
# Plan d'exécution V1 — Questions riches fermées

## Introduction

Ce plan découpe la V1 “questions riches fermées” en lots atomiques. La règle directrice est d'éviter le big bang : on stabilise d'abord le contrat, puis les quality gates, puis un sous-ensemble V1-A très rentable pédagogiquement, avant d'étendre progressivement Today, les sessions IA, les fixtures et les types plus complexes.

Tous les rapports V1 doivent être créés dans `docs/v1`.

## Principes d'exécution

- Lots de 0,5 à 2 jours quand possible.
- Aucun type de question n'est ajouté sans contrat backend, parser frontend, tests anti-fuite et fallback.
- Le QCM v3 V0 reste compatible jusqu'à migration explicite.
- La réponse libre reste exclusivement dans `open_question`.
- Genkit ne choisit jamais de widget libre.
- Flutter ne rend jamais un payload arbitraire.
- Les corrections restent post-submit.
- Chaque lot doit documenter les validations lancées et les validations non lancées.

## Tableau des lots V1

| Lot | Titre | Statut | Rapport |
| --- | --- | --- | --- |
| V1-001 | Roadmap et catalogue questions riches fermées | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md |
| V1-002 | ADR contrat rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md |
| V1-003 | Audit Prisma/DTO et décision versioning | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md |
| V1-004 | Contrat backend rich question kinds | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md |
| V1-005 | Quality gates pédagogiques backend | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md |
| V1-005B | Hardening contrat public et validators rich closed questions | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md |
| V1-006 | Génération Genkit rich closed questions V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md |
| V1-007 | Persistance minimale V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md |
| V1-008 | API publique pré-submit/post-submit V1-A | Réalisé | docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md |
| V1-009 | Domain models Flutter V1-A | À faire | À créer |
| V1-010 | Widgets Flutter V1-A single/multiple/case/error | À faire | À créer |
| V1-011 | Widgets Flutter matching/ordering | À faire | À créer |
| V1-012 | Scoring/correction UI V1-A | À faire | À créer |
| V1-013 | Today integration V1 | À faire | À créer |
| V1-014 | Revision session integration V1 | À faire | À créer |
| V1-015 | Seed V1 rich demo fixtures | À faire | À créer |
| V1-016 | E2E/smoke V1 rich questions | À faire | À créer |
| V1-017 | Timeline/date slider V1-B | À faire | À créer |
| V1-018 | True/false grid + cause/consequence V1-B | À faire | À créer |
| V1-019 | Institution matrix V1-C | À faire | À créer |
| V1-020 | Diagram labeling V1-C | À faire | À créer |
| V1-021 | Calculation MCQ modes de scrutin V1-C | À faire | À créer |
| V1-022 | Image choice/personnages historiques V1-D | À faire | À créer |
| V1-023 | Runbook demo V1 | À faire | À créer |
| V1-024 | Polish UI/accessibilité/performance | À faire | À créer |
| V1-025 | Revue finale V1 et readiness audit | À faire | À créer |

## Lots détaillés

### V1-001 — Roadmap et catalogue questions riches fermées

- Objectif : créer la vision V1, le catalogue, les exemples et le plan d'exécution.
- Pourquoi maintenant : la V0 est stable, mais les QCM restent trop basiques.
- Périmètre inclus : documentation stratégique dans `docs/v1`.
- Non-objectifs : runtime, Prisma, Genkit, Flutter, tests.
- Fichiers probablement concernés : `docs/v1/*`.
- Backend : audit seulement.
- Frontend : audit seulement.
- Genkit : audit seulement.
- GenUI : audit seulement.
- Prisma : audit seulement.
- API : aucune modification.
- Tests attendus : aucun test applicatif.
- Validations à lancer : `git diff --check` depuis `revision_app`.
- Critères d'acceptation : docs V1 créées, aucun runtime modifié.
- Critère de stop : si les repos complets ne sont pas accessibles.
- Risques : plan trop large ou trop proche d'une implémentation.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_001_RICH_QUESTIONS_ROADMAP.md`.

### V1-002 — ADR contrat rich closed questions

- Objectif : trancher le modèle de contrat : QCM v4, nouvelle activité `RICH_CLOSED_EXERCISE`, JSON typé ou tables spécialisées.
- Pourquoi maintenant : toutes les implémentations futures dépendent de cette décision.
- Périmètre inclus : ADR, alternatives, décision recommandée, impacts.
- Non-objectifs : migration ou code runtime.
- Fichiers probablement concernés : `docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`, rapport V1-002.
- Backend : définir discriminant `questionKind`, `answerShape`, `interactionPayload`, `correctionPayload`.
- Frontend : définir besoins de parser discriminé.
- Genkit : définir nom de schema version.
- GenUI : définir place du catalogue borné.
- Prisma : comparer stratégie JSON typé et tables dédiées.
- API : définir endpoints futurs.
- Tests attendus : aucun test runtime, checklist ADR.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : une décision claire et réversible.
- Critère de stop : si l'ADR demande une migration destructive.
- Risques : sous-estimer la dette du modèle `Question`.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_002_RICH_CLOSED_QUESTIONS_ADR.md`.

### V1-003 — Audit Prisma/DTO et décision versioning

- Objectif : auditer précisément les modèles, DTO publics, serializers et mappings nécessaires à la décision V1.
- Pourquoi maintenant : éviter une migration ou un contrat incomplet.
- Périmètre inclus : documentation technique, diagrammes de mapping, risques DB.
- Non-objectifs : création de migration.
- Fichiers probablement concernés : docs V1 uniquement.
- Backend : `ActivitySession`, `Question`, `QuestionAnswer`, `QuestionVisual`, `RevisionSessionAction`.
- Frontend : modèles QCM actuels et parsers sessions.
- Genkit : versions de prompts et schemas.
- GenUI : validators existants.
- Prisma : inventaire des colonnes et contraintes.
- API : inventaire pré-submit/post-submit.
- Tests attendus : aucun test runtime.
- Validations à lancer : `git diff --check`.
- Critères d'acceptation : table claire des champs réutilisables vs manquants.
- Critère de stop : si l'audit révèle un besoin de refonte plus large.
- Risques : ambiguïté entre `DIAGNOSTIC_QUIZ` et nouveau type.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_003_PRISMA_DTO_VERSIONING_AUDIT.md`.

### V1-004 — Contrat backend rich question kinds

- Objectif : ajouter les types applicatifs backend V1-A sans Genkit réel.
- Pourquoi maintenant : stabiliser les invariants avant génération.
- Périmètre inclus : union discriminée V1-A, validators purs, tests unitaires.
- Non-objectifs : persistance complète ou UI.
- Fichiers probablement concernés : `api/src/modules/activities/application/**`.
- Backend : `single_choice`, `multiple_choice`, `matching`, `ordering`, `case_qualification`, `error_detection`.
- Frontend : aucun.
- Genkit : aucun flow.
- GenUI : aucun.
- Prisma : aucune migration si possible.
- API : pas encore exposée publiquement sauf helpers internes.
- Tests attendus : validators et anti-fuite.
- Validations à lancer : `npm test -- activities --runInBand`, `npm run lint:check`, `npm run build`.
- Critères d'acceptation : types fermés validés et corrections séparées.
- Critère de stop : si l'ADR n'est pas validée.
- Risques : contrat trop abstrait.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md`.

### V1-005 — Quality gates pédagogiques backend

- Objectif : refuser les exercices trop basiques ou incohérents.
- Pourquoi maintenant : éviter que Genkit V1-A produise un QCM classique.
- Périmètre inclus : règles de mix, sources, correction, tailles minimales.
- Non-objectifs : régénération IA complexe.
- Fichiers probablement concernés : générateurs/validators activities.
- Backend : quality gate pur et testé.
- Frontend : aucun.
- Genkit : prépare l'intégration.
- GenUI : aucun.
- Prisma : aucun.
- API : erreurs contrôlées.
- Tests attendus : mix insuffisant, type interdit, correction pré-submit, source invalide.
- Validations à lancer : tests activities, lint check, build.
- Critères d'acceptation : une sortie 100 % QCM simple est rejetée.
- Critère de stop : gates trop stricts pour données pauvres.
- Risques : faux négatifs sur petits documents.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md`.

### V1-005B — Hardening contrat public et validators rich closed questions

- Objectif : durcir le contrat public, les validators et les gates avant Genkit.
- Pourquoi maintenant : éviter que V1-006 produise ou accepte des payloads ambigus ou semi-privés.
- Périmètre inclus : types publics sans feedback, validation stricte de `cognitiveSkill`, bornes `multiple_choice`, scan anti-fuite renforcé.
- Non-objectifs : Genkit réel, Prisma, API publique, Flutter UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md`.

### V1-006 — Génération Genkit rich closed questions V1-A

- Objectif : générer les types V1-A via Genkit avec quotas stricts.
- Pourquoi maintenant : le contrat et les gates existent.
- Périmètre inclus : prompt, schema Zod, observer metadata-only, fallback contrôlé.
- Non-objectifs : images, matrices, timeline.
- Fichiers probablement concernés : `api/src/modules/activities/infrastructure/genkit-*`.
- Backend : adapter generator V1-A.
- Frontend : aucun.
- Genkit : nouveau flow ou nouveau mode selon ADR.
- GenUI : aucun.
- Prisma : aucun.
- API : pas encore public si persistance absente.
- Note V1-006 réalisé : le générateur reste non public, non persisté et non branché API.
- Tests attendus : mock Genkit, schema strict, error codes whitelistés.
- Validations à lancer : tests ai/activities, lint check, build.
- Critères d'acceptation : le prompt impose `questionTypeMix`.
- Critère de stop : provider réel requis dans tests.
- Risques : prompts trop longs.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md`.

### V1-007 — Persistance minimale V1-A

- Objectif : persister les questions riches V1-A.
- Pourquoi maintenant : génération utile seulement si relue et soumise.
- Périmètre inclus : modèle choisi par ADR, migration si nécessaire, repository.
- Non-objectifs : UI Flutter.
- Fichiers probablement concernés : Prisma, repository activities.
- Backend : adapter Prisma.
- Frontend : aucun.
- Genkit : aucun changement fonctionnel.
- GenUI : aucun.
- Prisma : migration non destructive si nécessaire.
- API : mapping interne.
- Note V1-007 réalisé : persistance dédiée `RichClosedExercisePayload` et `RichClosedExerciseResult`, payload interne JSON typé, relecture pré-submit via mapper public.
- Tests attendus : persistance, relecture pré-submit, anti-fuite.
- Validations à lancer : `npx prisma validate`, `npm run prisma:generate`, tests activities, migration sur DB jetable si créée.
- Critères d'acceptation : données privées jamais exposées pré-submit.
- Critère de stop : migration destructive.
- Risques : JSON difficile à requêter.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_007_PERSISTENCE_V1A.md`.

### V1-008 — API publique pré-submit/post-submit V1-A

- Objectif : exposer un contrat public pour démarrer et soumettre un exercice riche fermé.
- Pourquoi maintenant : la persistance existe.
- Périmètre inclus : endpoints ou extension contrôlée, DTO, error mapping.
- Non-objectifs : Flutter UI.
- Fichiers probablement concernés : controller activities, use cases.
- Backend : pré-submit sans correction, post-submit avec correction.
- Frontend : lecture seule du contrat.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : nouveau type d'activité ou version selon ADR.
- Note V1-008 réalisé : endpoints `/activities/rich-closed/start`, `/activities/rich-closed/:sessionId`, `/activities/rich-closed/:sessionId/submit` et `/activities/rich-closed/:sessionId/result`.
- Tests attendus : e2e critiques, 400/404/409/422, anti-fuite.
- Validations à lancer : tests e2e, activities, lint check, build.
- Critères d'acceptation : endpoints exploitables par Flutter.
- Critère de stop : contrat public ambigu.
- Risques : casser QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_008_PUBLIC_API_V1A.md`.

### V1-009 — Domain models Flutter V1-A

- Objectif : ajouter les modèles Flutter discriminés pour V1-A.
- Pourquoi maintenant : le contrat API est public.
- Périmètre inclus : domain, parsers data, fakes, tests.
- Non-objectifs : widgets complets.
- Fichiers probablement concernés : `lib/features/activities/domain/**`, data, tests.
- Backend : aucun.
- Frontend : sealed classes par `questionKind`.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation stricte.
- Tests attendus : parse valide/invalide, correction pré-submit rejetée.
- Validations à lancer : `dart analyze lib test`, tests activities.
- Critères d'acceptation : parser discriminé strict.
- Critère de stop : contrat backend instable.
- Risques : duplication avec QCM v3.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_009_FLUTTER_DOMAIN_V1A.md`.

### V1-010 — Widgets Flutter V1-A single/multiple/case/error

- Objectif : rendre les premiers types V1-A natifs.
- Pourquoi maintenant : modèles Flutter disponibles.
- Périmètre inclus : choix unique, multiple, cas, détection d'erreur.
- Non-objectifs : matching/ordering.
- Fichiers probablement concernés : pages/widgets activities.
- Backend : aucun.
- Frontend : widgets natifs accessibles.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : pré-submit, sélection, submit, correction.
- Validations à lancer : analyze, widget tests, full flutter test si possible.
- Critères d'acceptation : aucune correction visible avant submit.
- Critère de stop : overflow mobile non résolu.
- Risques : UX trop proche du QCM actuel.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_010_FLUTTER_WIDGETS_CORE_V1A.md`.

### V1-011 — Widgets Flutter matching/ordering

- Objectif : ajouter association et remise en ordre.
- Pourquoi maintenant : ce sont les interactions V1-A les plus nouvelles.
- Périmètre inclus : matching, ordering, validations locales.
- Non-objectifs : timeline complète.
- Fichiers probablement concernés : widgets activities, tests.
- Backend : aucun.
- Frontend : menus/dropdowns ou reordering accessible.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : aucun.
- Tests attendus : associations, ordre, correction, accessibilité minimale.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : interactions utilisables sans drag-only obligatoire.
- Critère de stop : interaction inaccessible.
- Risques : ergonomie mobile.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_011_FLUTTER_MATCHING_ORDERING.md`.

### V1-012 — Scoring/correction UI V1-A

- Objectif : unifier affichage des corrections et scores V1-A.
- Pourquoi maintenant : plusieurs widgets existent.
- Périmètre inclus : panels correction, score par type, sources post-submit.
- Non-objectifs : recalcul frontend.
- Fichiers probablement concernés : widgets correction activities.
- Backend : aucun sauf bug de contrat.
- Frontend : affichage post-submit.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : consommation.
- Tests attendus : aucune correction pré-submit, rendu post-submit.
- Validations à lancer : analyze, tests activities.
- Critères d'acceptation : correction lisible pour chaque type V1-A.
- Critère de stop : score frontend inventé.
- Risques : incohérence visuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_012_SCORING_CORRECTION_UI_V1A.md`.

### V1-013 — Today integration V1

- Objectif : permettre à Today de recommander un exercice riche fermé.
- Pourquoi maintenant : runtime V1-A complet.
- Périmètre inclus : action type, start payload, routing.
- Non-objectifs : ranking IA.
- Fichiers probablement concernés : backend revision Today, Flutter Today.
- Backend : action déterministe `rich_closed_exercise`.
- Frontend : navigation vers activité V1.
- Genkit : aucun.
- GenUI : aucun.
- Prisma : aucun.
- API : Today DTO enrichi.
- Tests attendus : ranking stable, navigation.
- Validations à lancer : backend revision tests, flutter today tests.
- Critères d'acceptation : Today peut lancer un exercice riche ciblé.
- Critère de stop : ambiguïté avec open question.
- Risques : route Activities actuelle.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_013_TODAY_INTEGRATION_V1.md`.

### V1-014 — Revision session integration V1

- Objectif : orchestrer les exercices riches dans la session IA.
- Pourquoi maintenant : Today et activité V1 sont prêts.
- Périmètre inclus : action kind fermée, next-action bornée.
- Non-objectifs : widget libre ou chat libre.
- Fichiers probablement concernés : revision-sessions backend, Flutter session.
- Backend : `RICH_CLOSED_EXERCISE` action.
- Frontend : rendu payload métier.
- Genkit : coach choisit une enum, pas un widget.
- GenUI : aucun widget arbitraire.
- Prisma : migration possible si enum action.
- API : session response.
- Tests attendus : action, anti-fuite, routing.
- Validations à lancer : tests revision-sessions, activities, flutter revision sessions.
- Critères d'acceptation : session peut enchaîner rich closed exercise.
- Critère de stop : action coach non bornée.
- Risques : migration enum.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_014_REVISION_SESSION_INTEGRATION_V1.md`.

### V1-015 — Seed V1 rich demo fixtures

- Objectif : préparer une démo stable d'exercices riches.
- Pourquoi maintenant : intégrations principales prêtes.
- Périmètre inclus : fixtures synthétiques, dry-run, docs.
- Non-objectifs : provider IA réel.
- Fichiers probablement concernés : demo-seed API, docs demo.
- Backend : seed fixtures.
- Frontend : aucun.
- Genkit : aucun appel.
- GenUI : aucun.
- Prisma : aucun schéma si possible.
- API : aucun endpoint.
- Tests attendus : fixtures sans secret, IDs stables.
- Validations à lancer : demo-seed tests, revision/activities si impact.
- Critères d'acceptation : golden demo V1 rejouable.
- Critère de stop : besoin de données propriétaires.
- Risques : seed trop couplé au schéma.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_015_RICH_DEMO_FIXTURES.md`.

### V1-016 — E2E/smoke V1 rich questions

- Objectif : protéger les chemins critiques V1.
- Pourquoi maintenant : seed V1 disponible.
- Périmètre inclus : e2e API, smoke docs.
- Non-objectifs : couverture exhaustive.
- Fichiers probablement concernés : tests e2e API, docs demo.
- Backend : tests endpoints V1.
- Frontend : smoke manuel.
- Genkit : mocké.
- GenUI : anti-widget libre.
- Prisma : DB mockée ou test safe.
- API : contrats critiques.
- Tests attendus : pré-submit, submit, anti-fuite, error mapping.
- Validations à lancer : e2e, activities, build.
- Critères d'acceptation : régression démo détectée.
- Critère de stop : test dépendant d'un provider réel.
- Risques : flakiness.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_016_E2E_SMOKE_RICH_QUESTIONS.md`.

### V1-017 — Timeline/date slider V1-B

- Objectif : ajouter chronologie et date slider.
- Pourquoi maintenant : V1-A stabilisé.
- Périmètre inclus : backend contrat, Flutter widgets, tests.
- Non-objectifs : matrices.
- Fichiers probablement concernés : activities backend/frontend.
- Backend : validation bornes.
- Frontend : timeline responsive, slider accessible.
- Genkit : schema V1-B.
- GenUI : optionnel catalogué.
- Prisma : selon ADR.
- API : type V1-B.
- Tests attendus : ordre, bornes, correction.
- Validations à lancer : backend + Flutter targeted.
- Critères d'acceptation : dates bornées et accessibles.
- Critère de stop : slider inaccessible.
- Risques : dates discutables.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_017_TIMELINE_DATE_SLIDER.md`.

### V1-018 — True/false grid + cause/consequence V1-B

- Objectif : ajouter grille et relations cause/conséquence.
- Pourquoi maintenant : interactions comparatives avancées.
- Périmètre inclus : contrats, widgets, correction.
- Non-objectifs : matrix institutionnelle complète.
- Fichiers probablement concernés : activities.
- Backend : validations lignes/paires.
- Frontend : grille accessible et matching spécialisé.
- Genkit : quotas V1-B.
- GenUI : optionnel.
- Prisma : selon ADR.
- API : types V1-B.
- Tests attendus : lignes complètes, paires univoques.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : pas de grille trop large.
- Critère de stop : UX mobile illisible.
- Risques : surcharge cognitive.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_018_TRUE_FALSE_GRID_CAUSE_CONSEQUENCE.md`.

### V1-019 — Institution matrix V1-C

- Objectif : ajouter matrice institutionnelle.
- Pourquoi maintenant : base des grids disponible.
- Périmètre inclus : contrat borné, widget table.
- Non-objectifs : diagram labeling.
- Fichiers probablement concernés : activities.
- Backend : dimensions bornées.
- Frontend : table scrollable accessible.
- Genkit : schema V1-C.
- GenUI : non principal.
- Prisma : selon ADR.
- API : type matrix.
- Tests attendus : dimensions, cellules, correction.
- Validations à lancer : targeted backend/flutter.
- Critères d'acceptation : matrice lisible mobile.
- Critère de stop : table inaccessible.
- Risques : complexité UI.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_019_INSTITUTION_MATRIX.md`.

### V1-020 — Diagram labeling V1-C

- Objectif : compléter des schémas institutionnels bornés.
- Pourquoi maintenant : type coûteux mais différenciant.
- Périmètre inclus : slots, labels, correction.
- Non-objectifs : SVG/Mermaid libre.
- Fichiers probablement concernés : activities widgets/validators.
- Backend : schéma de diagramme strict.
- Frontend : rendu Flutter natif.
- Genkit : payload borné.
- GenUI : éventuellement composant catalogué.
- Prisma : selon ADR.
- API : type diagram_labeling.
- Tests attendus : pas de rendu arbitraire, slots complets.
- Validations à lancer : tests ciblés.
- Critères d'acceptation : aucun HTML/SVG/Mermaid.
- Critère de stop : payload libre requis.
- Risques : tentation de Mermaid.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_020_DIAGRAM_LABELING.md`.

### V1-021 — Calculation MCQ modes de scrutin V1-C

- Objectif : gérer des calculs fermés.
- Pourquoi maintenant : utile mais nécessite validation forte.
- Périmètre inclus : mini-données, choix, étapes post-submit.
- Non-objectifs : réponse de calcul libre.
- Fichiers probablement concernés : activities.
- Backend : vérification déterministe si possible.
- Frontend : tableau + choix.
- Genkit : génération bornée.
- GenUI : aucun libre.
- Prisma : selon ADR.
- API : type calculation_mcq.
- Tests attendus : résultats déterministes.
- Validations à lancer : tests unitaires calcul.
- Critères d'acceptation : pas de calcul IA non vérifié.
- Critère de stop : impossibilité de valider les résultats.
- Risques : erreurs de calcul.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_021_CALCULATION_MCQ.md`.

### V1-022 — Image choice/personnages historiques V1-D

- Objectif : ajouter choix d'image avec assets contrôlés.
- Pourquoi maintenant : après stabilisation de la chaîne d'assets.
- Périmètre inclus : allowlist assets, alt text, droits.
- Non-objectifs : URL image libre générée par IA.
- Fichiers probablement concernés : storage/assets, activities.
- Backend : asset refs.
- Frontend : grille image accessible.
- Genkit : référence uniquement des assets autorisés.
- GenUI : aucun asset libre.
- Prisma : table asset possible.
- API : image_choice.
- Tests attendus : droits/allowlist, alt text obligatoire.
- Validations à lancer : tests targeted.
- Critères d'acceptation : aucun asset non allowlisté.
- Critère de stop : droits non clarifiés.
- Risques : copyright.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_022_IMAGE_CHOICE.md`.

### V1-023 — Runbook demo V1

- Objectif : documenter démo V1 de bout en bout.
- Pourquoi maintenant : fonctionnalités et seed V1 prêts.
- Périmètre inclus : runbook, smoke, scénario.
- Non-objectifs : déploiement prod.
- Fichiers probablement concernés : docs demo V1.
- Backend : commandes confirmées.
- Frontend : commandes confirmées.
- Genkit : config provider documentée.
- GenUI : limites documentées.
- Prisma : commandes non destructives.
- API : smoke.
- Tests attendus : docs diff check.
- Validations à lancer : git diff check, validations non destructives.
- Critères d'acceptation : démo rejouable.
- Critère de stop : commande non vérifiable présentée comme certaine.
- Risques : drift documentaire.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_023_DEMO_RUNBOOK_V1.md`.

### V1-024 — Polish UI/accessibilité/performance

- Objectif : rendre l'expérience V1 robuste et agréable.
- Pourquoi maintenant : les types principaux existent.
- Périmètre inclus : accessibilité, petits écrans, performance, états vides.
- Non-objectifs : nouveaux types.
- Fichiers probablement concernés : Flutter widgets activities.
- Backend : aucun sauf bug.
- Frontend : UI polish.
- Genkit : aucun.
- GenUI : aucun arbitraire.
- Prisma : aucun.
- API : aucun.
- Tests attendus : widget tests, screenshots si possible.
- Validations à lancer : analyze, flutter test.
- Critères d'acceptation : pas d'overflow, interactions accessibles.
- Critère de stop : refactor massif requis.
- Risques : dérive design.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_024_UI_ACCESSIBILITY_PERFORMANCE.md`.

### V1-025 — Revue finale V1 et readiness audit

- Objectif : auditer la readiness V1.
- Pourquoi maintenant : clôturer la roadmap.
- Périmètre inclus : audit produit, sécurité, tests, docs, démo.
- Non-objectifs : nouvelle feature.
- Fichiers probablement concernés : docs V1, tests smoke.
- Backend : vérification.
- Frontend : vérification.
- Genkit : vérification logs et prompts.
- GenUI : vérification catalogue borné.
- Prisma : migration status.
- API : e2e.
- Tests attendus : suite non destructive complète selon contexte.
- Validations à lancer : backend + frontend ciblés, build, diff check.
- Critères d'acceptation : V1 présentable et sûre.
- Critère de stop : fuite de correction, widget libre, tests critiques rouges.
- Risques : dette non documentée.
- Rapport attendu : `docs/v1/ROADMAP_EXECUTION_LOT_V1_025_READINESS_AUDIT.md`.
````

