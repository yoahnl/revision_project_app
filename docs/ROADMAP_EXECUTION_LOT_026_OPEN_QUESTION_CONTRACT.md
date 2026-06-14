# LOT-026 — Contrat question ouverte

## 1. Résultat

LOT-026 ajoute le contrat backend minimal d'activité `OPEN_QUESTION` sans flow IA réel. Le backend peut créer une session de question ouverte liée à une notion, exposer un DTO pré-submit sans correction ni source textuelle complète, accepter une réponse ouverte, refuser les réponses invalides et le double submit, puis persister une évaluation `PENDING` sans score, sans feedback et sans réponse modèle inventée.

## 2. Sources inspectées

Documentation inspectée ou vérifiée pendant le lot :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_018.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_019_020.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_021_029.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_022.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025F_QCM_V3_DB_RUNTIME_VALIDATION.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_030_GENUI_ACTIVITY_CORRECTION.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`

Backend inspecté ou modifié :

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/prisma/migrations/**/migration.sql`
- `api/src/app.module.ts`
- `api/src/modules/activities/activities.module.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.spec.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.spec.ts`
- `api/src/modules/activities/activities.module.spec.ts`
- `api/src/modules/revision/application/revision.repository.ts`
- `api/src/modules/revision/domain/mastery-state.entity.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`

## 3. Préflight Git

API initial :

```text
/Users/karim/Project/app-révision/api
/Users/karim/Project/app-révision/api
main
## main...origin/main
02d3e57 #135: finalise corrections du générateur de quiz diagnostique
1fc13d5 #134: améliore entrée de génération d'artefacts et générateur de fiches de révision
fa23091 #133: corrige implémentation et tests du générateur de quiz diagnostique
2c31e40 #132: ajoute tests d'intégration pour le repository d'activités
2d4bf1e #131: ajoute suppression de documents et matières avec tests associés
```

Frontend initial :

```text
/Users/karim/Project/app-révision/revision_app
/Users/karim/Project/app-révision/revision_app
main
## main...origin/main
ce4cc5b LOT_030_GENUI_ACTIVITY_CORRECTION - Mise à jour catalogue GenUI, validateur de correction et ajout rapport LOT_030
769c73a LOT_027 - Mise à jour API HTTP activités et tests associés
4af6f0b LOT_025F_QCM_V3_DB_RUNTIME_VALIDATION - Mise à jour plan d'exécution et ajout rapport LOT_025F (QCM V3 DB runtime validation)
63f815d LOT_026 - Mise à jour contrôleurs documents/matières, APIs, pages et tests, ajout test subjects_home_page
7a9f377 LOT_025E_QCM_MEDIA_MULTI_UI - Mise à jour contrôleur QCM, API, UI et tests, ajout rapport LOT_025E
```

État au début de l'implémentation effective :

```text
api:
 M src/modules/activities/activities.module.spec.ts
 M src/modules/activities/infrastructure/prisma-activities.repository.spec.ts
?? src/modules/activities/application/start-open-question-activity.use-case.spec.ts
?? src/modules/activities/application/submit-open-answer.use-case.spec.ts

revision_app:
## main...origin/main
```

Ces fichiers API correspondaient aux tests RED du lot. Le frontend applicatif était propre et n'a pas été modifié.

## 4. Périmètre réalisé

- Ajout de `OPEN_QUESTION` à `ActivityType`.
- Ajout de `SUBMITTED` à `ActivityStatus` pour représenter une réponse ouverte soumise mais non évaluée.
- Ajout de `OpenAnswerEvaluationStatus` avec `PENDING`, `READY`, `FAILED`.
- Ajout des modèles `OpenQuestion`, `OpenQuestionSource`, `OpenAnswerEvaluation`.
- Ajout de `StartOpenQuestionActivityUseCase`.
- Ajout de `SubmitOpenAnswerUseCase`.
- Ajout des endpoints `POST /activities/open-question` et `POST /activities/:sessionId/open-answer`.
- Ajout de tests use cases, repository Prisma mocké et module/controller.
- Mise à jour du plan pour marquer `LOT-026` réalisé.

## 5. Décisions d'architecture

La question ouverte est modélisée avec des tables dédiées plutôt qu'en surchargeant les tables QCM. Cela préserve la compatibilité QCM v3 et évite de mélanger des champs de correction ouverte avec les questions à choix.

La génération LOT-026 est contractuelle et non IA : la question est construite depuis la `KnowledgeUnit` validée, avec une consigne stable et des références de chunks si disponibles. Aucun flow Genkit, adapter Genkit, prompt IA ou provider n'est créé.

La soumission ne met pas à jour la maîtrise, car aucune correction fiable n'existe encore. Elle crée seulement une évaluation `PENDING`.

## 6. Contrat API question ouverte

### `POST /activities/open-question`

Payload :

```json
{
  "subjectId": "subject-1",
  "knowledgeUnitId": "unit-1"
}
```

Réponse :

```json
{
  "sessionId": "session-1",
  "type": "open_question",
  "version": 1,
  "subjectId": "subject-1",
  "documentId": "document-1",
  "knowledgeUnitId": "unit-1",
  "question": {
    "id": "open-question-1",
    "prompt": "Explique avec tes propres mots la notion suivante : Séparation des pouvoirs.",
    "instructions": "Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.",
    "maxAnswerLength": 4000,
    "sources": [
      {
        "chunkId": "chunk-1",
        "pageNumber": null,
        "index": 0
      }
    ]
  }
}
```

### `POST /activities/:sessionId/open-answer`

Payload :

```json
{
  "answerText": "Réponse de l'étudiant."
}
```

Réponse LOT-026 :

```json
{
  "sessionId": "session-1",
  "type": "open_question",
  "status": "submitted",
  "evaluation": {
    "id": "evaluation-1",
    "status": "PENDING",
    "score": null,
    "maxScore": null,
    "feedback": null,
    "presentPoints": [],
    "missingPoints": [],
    "errors": [],
    "modelAnswer": null,
    "advice": null,
    "sources": []
  }
}
```

## 7. Modèles Prisma ajoutés ou modifiés

- `ActivityType.OPEN_QUESTION`.
- `ActivityStatus.SUBMITTED`.
- `OpenAnswerEvaluationStatus`.
- `OpenQuestion` pour la question ouverte liée à une session.
- `OpenQuestionSource` pour référencer des `DocumentChunk` sans source libre.
- `OpenAnswerEvaluation` pour stocker la réponse et l'état d'évaluation future.
- Relations ajoutées sur `StudentProfile`, `Subject`, `Document`, `KnowledgeUnit`, `DocumentChunk`, `ActivitySession`.

## 8. Migration créée et méthode de génération

Migration créée : `api/prisma/migrations/20260614213000_open_question_contract/migration.sql`.

Méthode :

```bash
cd api
cp prisma/schema.prisma /tmp/revision_schema_before_lot026.prisma
npx prisma migrate diff --from-schema /tmp/revision_schema_before_lot026.prisma --to-schema prisma/schema.prisma --script --output prisma/migrations/20260614213000_open_question_contract/migration.sql
```

La migration ne contient aucun `DROP` ni `TRUNCATE`. La recherche `DROP|TRUNCATE|DELETE` ne remonte que les clauses de clés étrangères `ON DELETE`.

## 9. Use cases ajoutés

- `StartOpenQuestionActivityUseCase` : vérifie la notion possédée par l'étudiant, récupère le contexte source, crée une question ouverte contractuelle.
- `SubmitOpenAnswerUseCase` : valide longueur minimale/maximale, trim la réponse, délègue au repository pour persistance et protection anti-double-submit.

## 10. Repository et adapter Prisma

Le port `ActivitiesRepository` expose trois nouveaux contrats :

- `findOpenQuestionGenerationContext`
- `createOpenQuestionActivity`
- `submitOpenAnswer`

L'adapter Prisma vérifie l'ownership par `studentId`, valide les chunks sources par `subjectId` et `documentId` quand disponible, persiste la session `OPEN_QUESTION`, persiste la question, puis crée une évaluation `PENDING` à la soumission.

## 11. Stratégie sans Genkit dans LOT-026

Aucun flow Genkit n'est créé. Aucun adapter IA n'est ajouté. Aucun provider n'est appelé. Aucun prompt complet ni completion n'est stocké. La question LOT-026 est un contrat minimal, construit de manière déterministe depuis la notion.

## 12. Stratégie anti-fuite

Pré-submit, la réponse ne contient jamais :

- `answerText`
- `modelAnswer`
- `expectedAnswer`
- `expectedPoints`
- `rubric`
- `score`
- `feedback`
- `presentPoints`
- `missingPoints`
- `errors`
- `advice`
- `sources[].text`
- chunks complets
- prompt ou completion IA
- payload GenUI

Post-submit LOT-026, l'évaluation reste `PENDING` avec score et feedback nuls.

## 13. Ownership et statuts

- Création : notion validée via `RevisionRepository.findKnowledgeUnits(studentId)` et `subjectId`.
- Persistance : `Subject` est relié par `(subjectId, studentId)`.
- Sources : chunks vérifiés par `subjectId` et, si disponible, `documentId`.
- Soumission : session cherchée par `(sessionId, studentId)`.
- Double submit : refusé si session non `STARTED` ou évaluation existante.
- Statut session après submit : `SUBMITTED`.
- Statut évaluation LOT-026 : `PENDING`.

## 14. Tests créés ou modifiés

Créés :

- `api/src/modules/activities/application/start-open-question-activity.use-case.spec.ts`
- `api/src/modules/activities/application/submit-open-answer.use-case.spec.ts`

Modifiés :

- `api/src/modules/activities/activities.module.spec.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`

Couvertures principales :

- création de session question ouverte ;
- rejet notion hors ownership ;
- réponse vide/trop courte/trop longue refusée ;
- soumission valide crée une évaluation pending ;
- double submit refusé ;
- session QCM refusée via endpoint open answer ;
- endpoints protégés via garde existant dans le module de test ;
- absence de fuite pré-submit ;
- absence de fausse correction post-submit.

## 15. Validations lancées avec résultats

```bash
cd api && npx prisma validate
```

Résultat : succès, schéma valide.

```bash
cd api && npm run prisma:generate
```

Résultat : succès, client Prisma généré.

```bash
cd api && npm test -- activities --runInBand
```

Résultat : succès, `Test Suites: 1 skipped, 7 passed, 7 of 8 total`, `Tests: 1 skipped, 74 passed, 75 total`.

```bash
cd api && npm run lint:check
```

Résultat : succès.

```bash
cd api && npm run build
```

Résultat : succès.

```bash
cd api && git diff --check
```

Résultat : succès.

```bash
cd revision_app && git diff --check
```

Résultat : succès.

## 16. Validations non lancées avec justification

- `npm run test:cov` : explicitement interdit.
- `npm run lint` : interdit car potentiellement auto-fix.
- `npm run format` : explicitement interdit.
- `npx prisma migrate deploy` : interdit pour ce lot.
- `npx prisma db push` : explicitement interdit.
- Tests Flutter : aucun code Flutter applicatif modifié.
- Provider IA réel : hors scope et interdit.
- Déploiement : hors scope et interdit.

## 17. Risques restants

- La migration n'a pas été appliquée à une DB runtime dans ce lot, conformément aux interdictions de migration deploy.
- LOT-027 devra ajouter une vraie génération/évaluation IA typée, sourcée et observable.
- Le statut `SUBMITTED` est suffisant pour le contrat LOT-026, mais LOT-027 devra décider le passage `READY`/`FAILED` de l'évaluation.
- La maîtrise n'est pas mise à jour pour une réponse non évaluée, ce qui est voulu mais laisse l'activité sans impact pédagogique jusqu'à LOT-027.
- L'UI Flutter question ouverte n'existe pas encore.
- Les composants GenUI question ouverte restent reportés.

## 18. Recommandation prochain lot

Recommandation : `LOT-027 — Genkit question ouverte et correction`, avec schémas Zod stricts, validation des sources, évaluation pédagogique post-submit, observabilité sans prompt/completion, et mise à jour de maîtrise uniquement après correction fiable.

## 19. Passes de review

- Passe backend/API : endpoints ajoutés, controller mince, erreurs HTTP cohérentes.
- Passe données : modèles dédiés et migration non destructive.
- Passe ownership : requêtes filtrées par `studentId`, `subjectId`, relations composées.
- Passe anti-fuite : DTO pré-submit pauvre, sources sans texte, évaluation pending sans correction.
- Passe Genkit : aucun flow ou provider ajouté.
- Passe frontend : aucune modification Flutter applicative.
- Passe critique : le contrat est minimal et volontairement non pédagogique tant que LOT-027 n'existe pas.

## 20. Code complet créé/modifié/supprimé pour review

Aucun fichier supprimé.

Le présent fichier est le rapport du lot ; son contenu complet est ce document. Les autres fichiers créés ou modifiés sont reproduits ci-dessous.

### api/prisma/schema.prisma

````````prisma
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
}

enum ActivityStatus {
  STARTED
  SUBMITTED
  COMPLETED
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

````````
### api/prisma/migrations/20260614213000_open_question_contract/migration.sql

````````sql
-- CreateEnum
CREATE TYPE "OpenAnswerEvaluationStatus" AS ENUM ('PENDING', 'READY', 'FAILED');

-- AlterEnum
ALTER TYPE "ActivityType" ADD VALUE 'OPEN_QUESTION';

-- AlterEnum
ALTER TYPE "ActivityStatus" ADD VALUE 'SUBMITTED';

-- CreateTable
CREATE TABLE "OpenQuestion" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "documentId" TEXT,
    "knowledgeUnitId" TEXT NOT NULL,
    "prompt" TEXT NOT NULL,
    "instructions" TEXT,
    "maxAnswerLength" INTEGER NOT NULL DEFAULT 4000,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OpenQuestion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OpenQuestionSource" (
    "questionId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "chunkId" TEXT NOT NULL,
    "relevanceScore" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OpenQuestionSource_pkey" PRIMARY KEY ("questionId","chunkId")
);

-- CreateTable
CREATE TABLE "OpenAnswerEvaluation" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "openQuestionId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "answerText" TEXT NOT NULL,
    "status" "OpenAnswerEvaluationStatus" NOT NULL DEFAULT 'PENDING',
    "score" DOUBLE PRECISION,
    "maxScore" DOUBLE PRECISION,
    "feedback" TEXT,
    "presentPoints" JSONB,
    "missingPoints" JSONB,
    "errors" JSONB,
    "modelAnswer" TEXT,
    "advice" TEXT,
    "generationFlowName" TEXT,
    "generationProvider" TEXT,
    "generationModel" TEXT,
    "generationPromptVersion" TEXT,
    "generationSchemaVersion" TEXT,
    "generationInputSize" INTEGER,
    "errorCode" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OpenAnswerEvaluation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "OpenQuestion_sessionId_key" ON "OpenQuestion"("sessionId");

-- CreateIndex
CREATE INDEX "OpenQuestion_studentId_idx" ON "OpenQuestion"("studentId");

-- CreateIndex
CREATE INDEX "OpenQuestion_subjectId_idx" ON "OpenQuestion"("subjectId");

-- CreateIndex
CREATE INDEX "OpenQuestion_documentId_idx" ON "OpenQuestion"("documentId");

-- CreateIndex
CREATE INDEX "OpenQuestion_knowledgeUnitId_idx" ON "OpenQuestion"("knowledgeUnitId");

-- CreateIndex
CREATE UNIQUE INDEX "OpenQuestion_id_subjectId_key" ON "OpenQuestion"("id", "subjectId");

-- CreateIndex
CREATE INDEX "OpenQuestionSource_chunkId_idx" ON "OpenQuestionSource"("chunkId");

-- CreateIndex
CREATE INDEX "OpenQuestionSource_subjectId_idx" ON "OpenQuestionSource"("subjectId");

-- CreateIndex
CREATE UNIQUE INDEX "OpenAnswerEvaluation_sessionId_key" ON "OpenAnswerEvaluation"("sessionId");

-- CreateIndex
CREATE INDEX "OpenAnswerEvaluation_studentId_idx" ON "OpenAnswerEvaluation"("studentId");

-- CreateIndex
CREATE INDEX "OpenAnswerEvaluation_subjectId_idx" ON "OpenAnswerEvaluation"("subjectId");

-- CreateIndex
CREATE INDEX "OpenAnswerEvaluation_openQuestionId_idx" ON "OpenAnswerEvaluation"("openQuestionId");

-- AddForeignKey
ALTER TABLE "OpenQuestion" ADD CONSTRAINT "OpenQuestion_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "ActivitySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenQuestion" ADD CONSTRAINT "OpenQuestion_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenQuestion" ADD CONSTRAINT "OpenQuestion_subjectId_studentId_fkey" FOREIGN KEY ("subjectId", "studentId") REFERENCES "Subject"("id", "studentId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenQuestion" ADD CONSTRAINT "OpenQuestion_documentId_subjectId_fkey" FOREIGN KEY ("documentId", "subjectId") REFERENCES "Document"("id", "subjectId") ON DELETE NO ACTION ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenQuestion" ADD CONSTRAINT "OpenQuestion_knowledgeUnitId_subjectId_fkey" FOREIGN KEY ("knowledgeUnitId", "subjectId") REFERENCES "KnowledgeUnit"("id", "subjectId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenQuestionSource" ADD CONSTRAINT "OpenQuestionSource_questionId_subjectId_fkey" FOREIGN KEY ("questionId", "subjectId") REFERENCES "OpenQuestion"("id", "subjectId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenQuestionSource" ADD CONSTRAINT "OpenQuestionSource_chunkId_subjectId_fkey" FOREIGN KEY ("chunkId", "subjectId") REFERENCES "DocumentChunk"("id", "subjectId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenAnswerEvaluation" ADD CONSTRAINT "OpenAnswerEvaluation_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "ActivitySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenAnswerEvaluation" ADD CONSTRAINT "OpenAnswerEvaluation_openQuestionId_subjectId_fkey" FOREIGN KEY ("openQuestionId", "subjectId") REFERENCES "OpenQuestion"("id", "subjectId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenAnswerEvaluation" ADD CONSTRAINT "OpenAnswerEvaluation_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OpenAnswerEvaluation" ADD CONSTRAINT "OpenAnswerEvaluation_subjectId_studentId_fkey" FOREIGN KEY ("subjectId", "studentId") REFERENCES "Subject"("id", "studentId") ON DELETE CASCADE ON UPDATE CASCADE;

````````
### api/src/modules/activities/application/activities.repository.ts

````````ts
import type {
  DiagnosticQuizDifficulty,
  DiagnosticQuizVisualType,
  DiagnosticQuizGenerationChunk,
  DiagnosticQuizGenerationKnowledgeUnit,
  GeneratedDiagnosticQuiz,
} from './diagnostic-quiz-generator';

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

  submitResult(input: {
    studentId: string;
    sessionId: string;
    answers: Array<{
      questionId: string;
      choiceId?: string;
      choiceIds?: string[];
    }>;
  }): Promise<DiagnosticQuizSubmissionResult>;

  submitOpenAnswer(input: {
    studentId: string;
    sessionId: string;
    answerText: string;
  }): Promise<OpenAnswerSubmissionResult>;
}

````````
### api/src/modules/activities/application/start-open-question-activity.use-case.ts

````````ts
import { Inject, Injectable } from '@nestjs/common';
import {
  REVISION_REPOSITORY,
  type RevisionRepository,
} from '../../revision/application/revision.repository';
import type { KnowledgeUnit } from '../../revision/domain/knowledge-unit.entity';
import {
  ACTIVITIES_REPOSITORY,
  type ActivitiesRepository,
  type OpenQuestionActivity,
} from './activities.repository';

export const OPEN_QUESTION_MAX_ANSWER_LENGTH = 4000;
export const OPEN_QUESTION_INSTRUCTIONS =
  'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.';

@Injectable()
export class StartOpenQuestionActivityUseCase {
  constructor(
    @Inject(ACTIVITIES_REPOSITORY)
    private readonly activitiesRepository: ActivitiesRepository,
    @Inject(REVISION_REPOSITORY)
    private readonly revisionRepository: RevisionRepository,
  ) {}

  async execute(input: {
    studentId: string;
    subjectId: string;
    knowledgeUnitId: string;
  }): Promise<OpenQuestionActivity> {
    const knowledgeUnit = await this.findKnowledgeUnit(input);
    const generationContext =
      await this.activitiesRepository.findOpenQuestionGenerationContext({
        studentId: input.studentId,
        subjectId: input.subjectId,
        knowledgeUnitId: knowledgeUnit.id,
      });
    const sourceChunkIds = Array.from(
      new Set(generationContext?.knowledgeUnit.sourceChunkIds ?? []),
    );

    return this.activitiesRepository.createOpenQuestionActivity({
      studentId: input.studentId,
      subjectId: input.subjectId,
      knowledgeUnitId: knowledgeUnit.id,
      documentId: generationContext?.documentId ?? null,
      question: {
        prompt: buildOpenQuestionPrompt(knowledgeUnit),
        instructions: OPEN_QUESTION_INSTRUCTIONS,
        maxAnswerLength: OPEN_QUESTION_MAX_ANSWER_LENGTH,
        sourceChunkIds,
        version: 1,
      },
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
      throw new Error('Knowledge unit does not belong to student subject');
    }

    return knowledgeUnit;
  }
}

function buildOpenQuestionPrompt(knowledgeUnit: KnowledgeUnit): string {
  return `Explique avec tes propres mots la notion suivante : ${knowledgeUnit.title}.`;
}

````````
### api/src/modules/activities/application/start-open-question-activity.use-case.spec.ts

````````ts
import type { RevisionRepository } from '../../revision/application/revision.repository';
import { KnowledgeUnit } from '../../revision/domain/knowledge-unit.entity';
import type { ActivitiesRepository } from './activities.repository';
import { StartOpenQuestionActivityUseCase } from './start-open-question-activity.use-case';

describe('StartOpenQuestionActivityUseCase', () => {
  it('creates an open question activity for an owned knowledge unit', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const knowledgeUnit = new KnowledgeUnit({
      id: 'unit-1',
      subjectId: 'subject-1',
      title: 'Séparation des pouvoirs',
      summary:
        'La séparation des pouvoirs distingue les fonctions législative, exécutive et juridictionnelle.',
    });
    revisionRepository.findKnowledgeUnits.mockResolvedValue([knowledgeUnit]);
    activitiesRepository.findOpenQuestionGenerationContext.mockResolvedValue({
      documentId: 'document-1',
      knowledgeUnit: Object.assign(knowledgeUnit, {
        difficulty: 'MEDIUM' as const,
        sourceChunkIds: ['chunk-1'],
      }),
      chunks: [
        {
          id: 'chunk-1',
          index: 0,
          text: 'La séparation des pouvoirs organise les fonctions de l’État.',
          pageNumber: null,
        },
      ],
    });
    activitiesRepository.createOpenQuestionActivity.mockResolvedValue(
      openQuestionActivity(),
    );

    const activity = await new StartOpenQuestionActivityUseCase(
      activitiesRepository,
      revisionRepository,
    ).execute({
      studentId: 'student-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    });

    expect(activity).toEqual(openQuestionActivity());
    expect(
      activitiesRepository.findOpenQuestionGenerationContext.mock.calls,
    ).toEqual([
      [
        {
          studentId: 'student-1',
          subjectId: 'subject-1',
          knowledgeUnitId: 'unit-1',
        },
      ],
    ]);
    expect(activitiesRepository.createOpenQuestionActivity.mock.calls).toEqual([
      [
        {
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
        },
      ],
    ]);
  });

  it('rejects a knowledge unit outside the student subject', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    revisionRepository.findKnowledgeUnits.mockResolvedValue([
      new KnowledgeUnit({
        id: 'unit-1',
        subjectId: 'subject-2',
        title: 'Séparation des pouvoirs',
        summary: 'Résumé.',
      }),
    ]);

    await expect(
      new StartOpenQuestionActivityUseCase(
        activitiesRepository,
        revisionRepository,
      ).execute({
        studentId: 'student-1',
        subjectId: 'subject-1',
        knowledgeUnitId: 'unit-1',
      }),
    ).rejects.toThrow('Knowledge unit does not belong to student subject');

    expect(
      activitiesRepository.createOpenQuestionActivity.mock.calls,
    ).toHaveLength(0);
  });
});

function createActivitiesRepository(): jest.Mocked<ActivitiesRepository> {
  return {
    findDiagnosticQuizGenerationContext: jest.fn(),
    createDiagnosticQuiz: jest.fn(),
    submitResult: jest.fn(),
    findOpenQuestionGenerationContext: jest.fn(),
    createOpenQuestionActivity: jest.fn(),
    submitOpenAnswer: jest.fn(),
  };
}

function createRevisionRepository(): jest.Mocked<RevisionRepository> {
  return {
    getActiveGoal: jest.fn(),
    saveGoal: jest.fn(),
    findKnowledgeUnits: jest.fn(),
    findMasteryStates: jest.fn(),
    upsertMastery: jest.fn(),
  };
}

function openQuestionActivity() {
  return {
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
  };
}

````````
### api/src/modules/activities/application/submit-open-answer.use-case.ts

````````ts
import { Inject, Injectable } from '@nestjs/common';
import {
  ACTIVITIES_REPOSITORY,
  type ActivitiesRepository,
  type OpenAnswerSubmissionResult,
} from './activities.repository';
import { OPEN_QUESTION_MAX_ANSWER_LENGTH } from './start-open-question-activity.use-case';

export const OPEN_ANSWER_MIN_LENGTH = 12;

@Injectable()
export class SubmitOpenAnswerUseCase {
  constructor(
    @Inject(ACTIVITIES_REPOSITORY)
    private readonly activitiesRepository: ActivitiesRepository,
  ) {}

  async execute(input: {
    studentId: string;
    sessionId: string;
    answerText: string;
  }): Promise<OpenAnswerSubmissionResult> {
    const answerText = input.answerText.trim();

    if (answerText.length < OPEN_ANSWER_MIN_LENGTH) {
      throw new Error('Open answer is too short');
    }

    if (answerText.length > OPEN_QUESTION_MAX_ANSWER_LENGTH) {
      throw new Error('Open answer is too long');
    }

    return this.activitiesRepository.submitOpenAnswer({
      studentId: input.studentId,
      sessionId: input.sessionId,
      answerText,
    });
  }
}

````````
### api/src/modules/activities/application/submit-open-answer.use-case.spec.ts

````````ts
import type { ActivitiesRepository } from './activities.repository';
import { SubmitOpenAnswerUseCase } from './submit-open-answer.use-case';

describe('SubmitOpenAnswerUseCase', () => {
  it('submits a valid open answer and returns a pending evaluation contract', async () => {
    const activitiesRepository = createActivitiesRepository();
    activitiesRepository.submitOpenAnswer.mockResolvedValue(
      pendingEvaluationResult(),
    );

    const result = await new SubmitOpenAnswerUseCase(
      activitiesRepository,
    ).execute({
      studentId: 'student-1',
      sessionId: 'session-1',
      answerText:
        'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
    });

    expect(activitiesRepository.submitOpenAnswer.mock.calls).toEqual([
      [
        {
          studentId: 'student-1',
          sessionId: 'session-1',
          answerText:
            'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
        },
      ],
    ]);
    expect(result).toEqual(pendingEvaluationResult());
  });

  it.each([
    ['empty', ''],
    ['blank', '     '],
    ['too short', 'trop court'],
  ])('rejects %s answers', async (_label, answerText) => {
    const activitiesRepository = createActivitiesRepository();

    await expect(
      new SubmitOpenAnswerUseCase(activitiesRepository).execute({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText,
      }),
    ).rejects.toThrow('Open answer is too short');

    expect(activitiesRepository.submitOpenAnswer.mock.calls).toHaveLength(0);
  });

  it('rejects answers longer than the contract limit', async () => {
    const activitiesRepository = createActivitiesRepository();

    await expect(
      new SubmitOpenAnswerUseCase(activitiesRepository).execute({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText: 'a'.repeat(4001),
      }),
    ).rejects.toThrow('Open answer is too long');

    expect(activitiesRepository.submitOpenAnswer.mock.calls).toHaveLength(0);
  });
});

function createActivitiesRepository(): jest.Mocked<ActivitiesRepository> {
  return {
    findDiagnosticQuizGenerationContext: jest.fn(),
    createDiagnosticQuiz: jest.fn(),
    submitResult: jest.fn(),
    findOpenQuestionGenerationContext: jest.fn(),
    createOpenQuestionActivity: jest.fn(),
    submitOpenAnswer: jest.fn(),
  };
}

function pendingEvaluationResult() {
  return {
    sessionId: 'session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: {
      id: 'evaluation-1',
      status: 'PENDING',
      score: null,
      maxScore: null,
      feedback: null,
      presentPoints: [],
      missingPoints: [],
      errors: [],
      modelAnswer: null,
      advice: null,
      sources: [],
    },
  };
}

````````
### api/src/modules/activities/activities.module.ts

````````ts
import { Module } from '@nestjs/common';
import { AiModule } from '../ai/ai.module';
import { AuthModule } from '../auth/auth.module';
import { AdaptivePlanService } from '../revision/domain/adaptive-plan.service';
import { RevisionModule } from '../revision/revision.module';
import { PrismaModule } from '../../shared/infrastructure/prisma/prisma.module';
import { ACTIVITIES_REPOSITORY } from './application/activities.repository';
import { DIAGNOSTIC_QUIZ_GENERATOR } from './application/diagnostic-quiz-generator';
import { StartOpenQuestionActivityUseCase } from './application/start-open-question-activity.use-case';
import { StartNextActivityUseCase } from './application/start-next-activity.use-case';
import { SubmitOpenAnswerUseCase } from './application/submit-open-answer.use-case';
import { SubmitActivityResultUseCase } from './application/submit-activity-result.use-case';
import { GenkitDiagnosticQuizGenerator } from './infrastructure/genkit-diagnostic-quiz.generator';
import { PrismaActivitiesRepository } from './infrastructure/prisma-activities.repository';
import { ActivitiesController } from './interfaces/activities.controller';

@Module({
  imports: [AiModule, AuthModule, PrismaModule, RevisionModule],
  controllers: [ActivitiesController],
  providers: [
    AdaptivePlanService,
    StartNextActivityUseCase,
    StartOpenQuestionActivityUseCase,
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
  ],
})
export class ActivitiesModule {}

````````
### api/src/modules/activities/activities.module.spec.ts

````````ts
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
    createDiagnosticQuiz: jest.Mock<
      Promise<DiagnosticQuizActivity>,
      [CreateDiagnosticQuizInput]
    >;
    submitResult: jest.Mock;
    createOpenQuestionActivity: jest.Mock;
    submitOpenAnswer: jest.Mock;
  };
  let diagnosticQuizGenerator: {
    generate: jest.Mock<
      Promise<GeneratedDiagnosticQuiz>,
      [DiagnosticQuizGenerationInput]
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
      submitOpenAnswer: jest
        .fn<Promise<OpenAnswerSubmissionResult>, []>()
        .mockResolvedValue({
          sessionId: 'open-session-1',
          type: 'open_question',
          status: 'submitted',
          evaluation: {
            id: 'evaluation-1',
            status: 'PENDING',
            score: null,
            maxScore: null,
            feedback: null,
            presentPoints: [],
            missingPoints: [],
            errors: [],
            modelAnswer: null,
            advice: null,
            sources: [],
          },
        }),
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

  it('submits an open answer and returns a pending evaluation contract', async () => {
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
          status: 'PENDING',
          score: null,
          maxScore: null,
          feedback: null,
          presentPoints: [],
          missingPoints: [],
          errors: [],
          modelAnswer: null,
          advice: null,
          sources: [],
        },
      });

    expect(activitiesRepository.submitOpenAnswer).toHaveBeenCalledWith({
      studentId: 'student-1',
      sessionId: 'open-session-1',
      answerText:
        'La révision constitutionnelle est une procédure encadrée par la Constitution.',
    });
    expect(revisionRepository.upsertMastery).not.toHaveBeenCalled();
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
    expect(activitiesRepository.submitOpenAnswer).not.toHaveBeenCalled();
  });
});

````````
### api/src/modules/activities/infrastructure/prisma-activities.repository.ts

````````ts
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
  DiagnosticQuizActivity,
  DiagnosticQuizGenerationContext,
  DiagnosticQuizSubmissionResult,
  OpenAnswerSubmissionResult,
  OpenQuestionActivity,
  OpenQuestionDraft,
} from '../application/activities.repository';
import type {
  GeneratedDiagnosticQuiz,
  GeneratedDiagnosticQuizChoice,
  GeneratedDiagnosticQuizQuestion,
  GeneratedDiagnosticQuizVisual,
} from '../application/diagnostic-quiz-generator';

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
  chunk: {
    id: string;
    pageNumber: number | null;
    index: number;
  };
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

type OpenQuestionSessionRecord = ActivitySessionRecord & {
  openQuestion?: OpenQuestionRecord | null;
  openAnswerEvaluation?: OpenAnswerEvaluationRecord | null;
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
                pageNumber: true,
                index: true,
              },
            });

      if (sourceChunks.length !== sourceChunkIds.length) {
        throw new Error('Open question source chunk not found');
      }

      const sourceChunkById = new Map(
        sourceChunks.map((chunk) => [chunk.id, chunk]),
      );
      const session = await tx.activitySession.create({
        data: {
          studentId: input.studentId,
          subjectId: input.subjectId,
          knowledgeUnitId: input.knowledgeUnitId,
          documentId: input.documentId ?? null,
          type: ActivityType.OPEN_QUESTION,
          status: ActivityStatus.STARTED,
          version: input.question.version,
        },
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
            .filter(
              (
                chunk,
              ): chunk is {
                id: string;
                pageNumber: number | null;
                index: number;
              } => Boolean(chunk),
            )
            .map((chunk) => ({
              chunkId: chunk.id,
              chunk: {
                id: chunk.id,
                pageNumber: chunk.pageNumber,
                index: chunk.index,
              },
            })),
        },
      });
    });
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

  async submitOpenAnswer(input: {
    studentId: string;
    sessionId: string;
    answerText: string;
  }): Promise<OpenAnswerSubmissionResult> {
    return this.prisma.$transaction(async (tx) => {
      const session = await tx.activitySession.findFirst({
        where: {
          id: input.sessionId,
          studentId: input.studentId,
        },
        include: {
          questions: true,
          openQuestion: {
            include: {
              sources: {
                include: {
                  chunk: {
                    select: {
                      id: true,
                      pageNumber: true,
                      index: true,
                    },
                  },
                },
              },
            },
          },
          openAnswerEvaluation: true,
        },
      });

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

      const evaluation = await tx.openAnswerEvaluation.create({
        data: {
          sessionId: session.id,
          openQuestionId: session.openQuestion.id,
          studentId: input.studentId,
          subjectId: session.subjectId,
          answerText: input.answerText,
          status: OpenAnswerEvaluationStatus.PENDING,
          score: null,
          maxScore: null,
          feedback: null,
          presentPoints: [],
          missingPoints: [],
          errors: [],
          modelAnswer: null,
          advice: null,
        },
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

      return toOpenAnswerSubmissionResult(evaluation);
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

function toOpenAnswerSubmissionResult(
  evaluation: OpenAnswerEvaluationRecord,
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
      sources: [],
    },
  };
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

````````
### api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts

````````ts
import { PrismaActivitiesRepository } from './prisma-activities.repository';

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
    status: 'PENDING';
    score: null;
    maxScore: null;
    feedback: null;
    presentPoints: [];
    missingPoints: [];
    errors: [];
    modelAnswer: null;
    advice: null;
  };
};

type OpenQuestionSessionRecord = ActivitySessionRecord & {
  openQuestion: OpenQuestionRecord | null;
  openAnswerEvaluation: OpenAnswerEvaluationRecord | null;
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

  it('submits an open answer and creates a pending evaluation without fake correction', async () => {
    const { prisma, repository } = createRepository();
    prisma.activitySession.findFirst.mockResolvedValue({
      ...sessionRecord({
        type: 'OPEN_QUESTION' as never,
        status: 'STARTED',
      }),
      openQuestion: openQuestionRecord({ sources: [] }),
      openAnswerEvaluation: null,
    } satisfies OpenQuestionSessionRecord);
    prisma.openAnswerEvaluation.create.mockResolvedValue(
      openAnswerEvaluationRecord(),
    );

    const result = await repository.submitOpenAnswer({
      studentId: 'student-1',
      sessionId: 'session-1',
      answerText:
        'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
    });

    expect(prisma.openAnswerEvaluation.create).toHaveBeenCalledWith({
      data: {
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
        status: 'PENDING',
        score: null,
        maxScore: null,
        feedback: null,
        presentPoints: [],
        missingPoints: [],
        errors: [],
        modelAnswer: null,
        advice: null,
        sources: [],
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
      openQuestion: openQuestionRecord(),
      openAnswerEvaluation: openAnswerEvaluationRecord(),
    } satisfies OpenQuestionSessionRecord);

    await expect(
      repository.submitOpenAnswer({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText:
          'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
      }),
    ).rejects.toThrow('Activity session already submitted');

    prisma.activitySession.findFirst.mockResolvedValue(sessionWithQuestions());

    await expect(
      repository.submitOpenAnswer({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText:
          'La séparation des pouvoirs évite la concentration des fonctions étatiques.',
      }),
    ).rejects.toThrow('Activity session is not an open question');

    expect(prisma.openAnswerEvaluation.create).not.toHaveBeenCalled();
  });
});

````````
### api/src/modules/activities/interfaces/activities.controller.ts

````````ts
import {
  BadRequestException,
  Body,
  ConflictException,
  Controller,
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

@Controller('activities')
@UseGuards(FirebaseAuthGuard)
export class ActivitiesController {
  constructor(
    private readonly startNextActivity: StartNextActivityUseCase,
    private readonly startOpenQuestionActivity: StartOpenQuestionActivityUseCase,
    private readonly submitActivityResult: SubmitActivityResultUseCase,
    private readonly submitOpenAnswer: SubmitOpenAnswerUseCase,
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

    if (error.message === 'Activity session already completed') {
      throw new ConflictException(error.message);
    }

    if (error.message === 'Activity session already submitted') {
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
      error.message === 'Selection count is invalid for question'
    ) {
      throw new BadRequestException(error.message);
    }

    if (
      error.message === 'Generated diagnostic quiz is invalid' ||
      error.message === 'Question source chunk not found' ||
      error.message === 'Question visual source chunk not found' ||
      error.message === 'Open question source chunk not found'
    ) {
      throw new UnprocessableEntityException(error.message);
    }
  }

  throw error;
}

````````
### revision_app/docs/ROADMAP_EXECUTION_PLAN.md

````````md
# Roadmap Execution Plan — Revision App

## 1. But du document

Ce fichier transforme `docs/ROADMAP.md` en lots d'exécution atomiques, ordonnés et validables.

La roadmap existante donne une bonne direction produit et technique. Ce plan ajoute l'ordre d'attaque, les dépendances, les critères de stop, les validations futures et les zones probables à inspecter ou modifier. Il ne remplace pas la roadmap stratégique : il la rend exécutable par petits lots de 0,5 à 2 jours.

Ce document ne prescrit aucune implémentation immédiate. Les lots ci-dessous décrivent le travail futur à réaliser en conservant :

- la Clean Architecture NestJS ;
- les patterns Flutter, Riverpod et GoRouter existants ;
- Genkit côté backend comme moteur IA typé et validé ;
- GenUI côté frontend comme catalogue borné de composants, jamais comme interpréteur libre ;
- l'isolation stricte par `studentId`.

## 2. Lecture critique de la roadmap actuelle

### Ce qui est solide

- La vision produit est claire : importer un cours, extraire des notions, générer des supports, entraîner l'étudiant, corriger et adapter le plan.
- Le pipeline actuel existe déjà : upload PDF, job BullMQ, extraction texte, extraction Genkit, `KnowledgeUnit`, QCM, mastery, `GET /today`.
- L'architecture backend a déjà des ports applicatifs et adapters : repositories Prisma, `DocumentTextExtractor`, `DocumentKnowledgeExtractor`, `DiagnosticQuizGenerator`.
- Le frontend a déjà GoRouter, Riverpod, un shell par onglets persistants, des pages principales et des repositories HTTP.
- Genkit est déjà réellement utilisé, pas seulement installé.
- GenUI est déjà amorcé via un catalogue d'activité, même s'il reste très limité.
- La roadmap identifie bien les grandes fonctionnalités produit : fiches, QCM enrichi, question ouverte, session IA, plan du jour avancé.

### Ce qui est trop large

- Les phases de la roadmap sont trop grosses pour être exécutées telles quelles. Par exemple, “Documents et knowledge units enrichis” mélange extraction, schéma, persistance, API, UI et anti-hallucination.
- “Résumés et fiches” suppose des sources fiables, mais les sources ne sont pas encore stabilisées.
- “Session de révision IA avec GenUI” dépend de composants isolés qui ne sont pas encore conçus, validés ni testés.
- “Plan du jour adaptatif avancé” dépend de nouveaux types d'activités et d'un historique de maîtrise plus riche.
- La phase “Démo, qualité, sécurité et déploiement” arrive trop tard pour l'observabilité Genkit et les limites de coûts.

### Ce qui doit être déplacé plus tôt

- Les fondations documentaires doivent précéder les résumés : `DocumentChunk`, `SourceReference`, liens entre chunks et notions, stratégie anti-hallucination.
- L'observabilité Genkit doit arriver avant les nouveaux flows : nom du flow, provider, modèle, durée, taille input, statut, erreur, version de prompt, version de schéma.
- Le versioning des outputs IA doit être défini avant les nouvelles tables et les nouveaux endpoints.
- La stratégie des artefacts générés doit être décidée tôt : modèles spécialisés (`Summary`, `RevisionSheet`, `OpenAnswerEvaluation`) ou modèle transversal (`GeneratedArtifact`, `AiGenerationJob`) avec relations typées.
- Le golden demo path doit être préparé tôt, car il conditionne le PDF de test, les seeds, les validations manuelles et le récit de démonstration.

### Ce qui doit être repoussé

- La session coach complète doit être retardée. Elle ne doit venir qu'après stabilisation des composants isolés : résumé, source excerpt, QCM, correction et question ouverte.
- Le plan du jour multi-actions avancé doit attendre que les activités et mastery events soient plus riches.
- Les imports OCR, image et audio doivent rester hors MVP tant que les PDF texte ne sont pas robustes.
- La génération libre de widgets doit rester interdite.
- Une refonte UI totale non bornée doit être évitée : il faut avancer par primitives réutilisables et surfaces prioritaires.

### Ce qui manque pour sécuriser la démo

- Un PDF de démonstration connu, texte et stable.
- Un scénario reproductible avec états attendus.
- Des données de seed contrôlées.
- Des contrôles d'ownership sur chaque nouveau endpoint.
- Des tests anti-hallucination sur les références sources.
- Une validation GenUI stricte et testée.
- Des erreurs IA affichables côté produit.
- Des limites de coût, timeout et taille input dès les premiers flows enrichis.

### Points critiques à corriger dans l'ordre d'exécution

- Ne pas demander à l'IA de produire librement des `sourceExcerpt`. Le backend doit découper ou référencer des chunks existants, puis Genkit doit pointer vers ces références quand c'est possible.
- Ne pas laisser coexister deux chemins documentaires flous. Le plan doit trancher tôt entre upload direct backend, Firebase Storage lu par le backend, ou coexistence temporaire documentée.
- Ne pas construire `generateCoachNextActionFlow` avant d'avoir des contrats d'activité stables.
- Ne pas enrichir le QCM sans protéger la non-fuite de `correctChoiceId` avant submit.
- Ne pas rendre des payloads GenUI sans validation stricte côté Flutter.
- Ne pas exposer des contenus générés sans version de schéma et de prompt.

## 3. Principes d'exécution

- Chaque lot doit rester réalisable en environ 0,5 à 2 jours.
- Aucun lot ne doit contenir un refactor massif.
- Aucun commit Git ne doit être fait par défaut.
- Aucun `git commit`, `git amend`, `git merge`, `git rebase`, `git push`, `git tag` ou autre écriture Git ne doit être lancé sans demande explicite.
- Aucun objectif hors lot ne doit être ajouté pendant l'implémentation future.
- Toute modification de code future doit être accompagnée de tests pertinents ou d'une justification explicite.
- Le backend doit continuer à suivre la Clean Architecture NestJS : controller mince, use case applicatif, port, adapter.
- Le frontend doit continuer à utiliser Riverpod pour les états et GoRouter pour la navigation.
- Genkit doit produire des outputs typés, validés et versionnés.
- GenUI doit rester borné par un catalogue strict.
- L'ownership `studentId` doit être vérifié dans chaque nouveau chemin backend.
- Une UI de fallback doit exister quand GenUI ou l'IA échoue.
- Les erreurs IA doivent être explicites, journalisées et traduisibles côté produit.
- Aucun widget arbitraire ne doit être généré par l'IA.
- Les validations doivent être lancées depuis les racines réelles : `api` pour NestJS et `revision_app` pour Flutter.
- Les scripts qui écrivent automatiquement, comme `npm run lint` côté API avec `--fix`, ne doivent pas être utilisés comme validation non destructive ; préférer `npm run lint:check`.

## 4. Découpage macro recommandé

### Bloc A — Audit et vérité projet

Objectif : connaître précisément l'existant avant d'ajouter.

Ce bloc verrouille les contrats actuels, les scripts disponibles, les gaps entre roadmap et code réel, et les décisions structurantes.

### Bloc B — Design system minimal et surfaces premium

Objectif : sortir du Material brut sans refaire toute l'app.

Ce bloc stabilise les primitives Flutter réutilisables, puis les applique seulement aux surfaces prioritaires de la démo.

### Bloc C — Fondations documentaires et sources

Objectif : chunks, source references, knowledge units enrichies, anti-hallucination.

Ce bloc rend possible la génération de fiches et corrections sourcées sans demander à l'IA d'inventer des extraits.

### Bloc D — Détail document et notions côté front

Objectif : rendre le processing IA visible et utile.

Ce bloc expose les notions, statuts, erreurs et sources à l'utilisateur avant d'ajouter des artefacts avancés.

### Bloc E — Observabilité et versioning Genkit

Objectif : rendre les flows IA diagnostiquables dès les premières générations.

Ce bloc doit arriver tôt pour éviter de debuguer les fiches, QCM et corrections à l'aveugle.

### Bloc F — Résumés et fiches

Objectif : premier artefact IA exploitable.

Ce bloc ajoute les résumés et fiches après stabilisation des sources.

### Bloc G — QCM enrichi

Objectif : correction détaillée, feedback, maîtrise.

Ce bloc améliore l'activité existante sans changer tout le modèle d'activité d'un coup.

### Bloc H — Question ouverte corrigée

Objectif : fonctionnalité forte de démonstration.

Ce bloc ajoute l'activité la plus différenciante, mais seulement après les sources et l'observabilité.

### Bloc I — GenUI catalog isolé

Objectif : composants bornés avant la session coach.

Ce bloc stabilise les composants dynamiques un par un.

### Bloc J — Session de révision IA

Objectif : orchestration seulement après stabilisation des briques.

Ce bloc assemble les artefacts et activités existants dans une session coach contrôlée.

### Bloc K — Plan du jour avancé

Objectif : recommandations multi-actions déterministes.

Ce bloc élargit `TodayPlan` quand les actions existent déjà.

### Bloc L — Golden demo, qualité et déploiement

Objectif : rendre la démo reproductible.

Ce bloc ajoute seed, scénario, validations manuelles, runbooks et checks critiques.

## 5. Lots d'exécution ordonnés

### Suivi d'exécution des lots

Ce tableau doit être mis à jour à chaque lot réalisé. Cette règle est également inscrite dans `revision_app/AGENTS.md`.

| Lot | Titre | Statut | Rapport |
| --- | --- | --- | --- |
| LOT-001 | Audit des contrats actuels | Réalisé | `docs/ROADMAP_EXECUTION_LOT_001_001B.md` |
| LOT-001B | Décision stratégie upload et lecture document | Réalisé | `docs/ROADMAP_EXECUTION_LOT_001_001B.md` |
| LOT-002 | Décisions fondations IA et documentaire | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-002B | Revue de schéma avant migrations | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-003 | Golden demo baseline | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-004 | Port d'observabilité Genkit | Réalisé | `docs/ROADMAP_EXECUTION_LOT_004_005.md` |
| LOT-005 | Instrumentation des flows Genkit existants | Réalisé | `docs/ROADMAP_EXECUTION_LOT_004_005.md` |
| LOT-006 | Inventaire design system et surfaces prioritaires | À faire | À créer |
| LOT-007 | Primitives UI minimales pour la démo | À faire | À créer |
| LOT-008 | Application UI ciblée aux pages existantes | À faire | À créer |
| LOT-009 | Modèle documentaire cible détaillé | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-010 | Persistance minimale des chunks et sources | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-010B | Réparation migration Prisma DocumentChunk / KnowledgeUnitSource | Réalisé | `docs/ROADMAP_EXECUTION_LOT_010B.md` |
| LOT-011 | Chunking PDF dans le worker | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-012 | Extraction Genkit v2 basée sur chunks | Réalisé | `docs/ROADMAP_EXECUTION_LOT_012_013.md` |
| LOT-013 | Persistance KnowledgeUnit enrichie | Réalisé | `docs/ROADMAP_EXECUTION_LOT_012_013.md` |
| LOT-014 | API détail document et notions sourcées | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-015 | Data layer Flutter pour détail document | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-016 | Page détail document et notions | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-017 | Contrat artefacts générés | Réalisé | `docs/ROADMAP_EXECUTION_LOT_017.md` |
| LOT-018 | Persistance Summary et RevisionSheet | Réalisé | `docs/ROADMAP_EXECUTION_LOT_018.md` |
| LOT-019 | Flow Genkit résumé et fiche | Réalisé | `docs/ROADMAP_EXECUTION_LOT_019_020.md` |
| LOT-020 | API résumés et fiches | Réalisé | `docs/ROADMAP_EXECUTION_LOT_019_020.md` |
| LOT-021 | UI résumé et fiche | Réalisé | `docs/ROADMAP_EXECUTION_LOT_021_029.md` |
| LOT-022 | Contrat QCM v2 | Réalisé | `docs/ROADMAP_EXECUTION_LOT_022.md` |
| LOT-023 | Genkit QCM enrichi | Réalisé | `docs/ROADMAP_EXECUTION_LOT_023.md` |
| LOT-024 | Persistance et soumission QCM enrichies | Réalisé | `docs/ROADMAP_EXECUTION_LOT_024.md` |
| LOT-025 | UI QCM enrichi | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025.md` |
| LOT-025B | QCM questionCount configurable et contrat média/multi-réponse | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md` |
| LOT-025C | QCM média et multi-réponse : contrat backend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md` |
| LOT-025D | QCM média et multi-réponse : backend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md` |
| LOT-025E | QCM média et multi-réponse : UI | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md` |
| LOT-025F | Validation DB/runtime QCM v3 | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025F_QCM_V3_DB_RUNTIME_VALIDATION.md` |
| LOT-026 | Contrat question ouverte | Réalisé | `docs/ROADMAP_EXECUTION_LOT_026_OPEN_QUESTION_CONTRACT.md` |
| LOT-027 | Genkit question ouverte et correction | À faire | À créer |
| LOT-028 | UI question ouverte corrigée | À faire | À créer |
| LOT-029 | GenUI composants lecture sourcée | Réalisé | `docs/ROADMAP_EXECUTION_LOT_021_029.md` |
| LOT-030 | GenUI composants activité et correction | Réalisé | `docs/ROADMAP_EXECUTION_LOT_030_GENUI_ACTIVITY_CORRECTION.md` |
| LOT-031 | Session de révision IA minimale | À faire | À créer |
| LOT-032 | Écran Révision IA minimal | À faire | À créer |
| LOT-033 | Orchestration coach Genkit | À faire | À créer |
| LOT-034 | TodayPlan multi-actions backend | À faire | À créer |
| LOT-035 | TodayPage v2 frontend | À faire | À créer |
| LOT-036 | Seed et fixtures de démo | À faire | À créer |
| LOT-037 | Tests e2e critiques et smoke checks | À faire | À créer |
| LOT-038 | Runbook démo et déploiement | À faire | À créer |

### LOT-001 — Audit des contrats actuels

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Établir l'inventaire exact des routes, use cases, modèles, providers et tests existants.

**Pourquoi maintenant :**
Le plan doit partir du code réel, pas de la roadmap idéale.

**Périmètre inclus :**

- Cartographier les endpoints backend existants.
- Cartographier les pages et routes Flutter existantes.
- Cartographier les flows Genkit existants.
- Cartographier le catalogue GenUI actuel.
- Lister les tests déjà présents.

**Non-objectifs :**

- Modifier du code.
- Modifier Prisma.
- Ajouter des endpoints.
- Ajouter des composants UI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/**`
- `api/prisma/schema.prisma`
- `api/package.json`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/features/**`
- `revision_app/lib/presentation/**`
- `revision_app/test/**`

**Backend :**
Lecture des modules `documents`, `jobs`, `ai`, `activities`, `revision`, `subjects`, `auth`.

**Frontend :**
Lecture des routes, providers, pages, APIs HTTP et composants partagés.

**Genkit :**
Identifier extraction de notions et génération QCM.

**GenUI :**
Identifier le catalogue `revision_activity_catalog.dart` et son validateur.

**Données / Prisma :**
Lecture seule du schéma.

**API :**
Inventaire uniquement.

**Tests futurs attendus :**
Validation documentaire par checklist.

**Commandes de validation futures :**

- `cd api && npm run lint:check`
- `cd api && npm test`
- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les endpoints actuels sont listés.
- Les modèles Prisma actuels sont listés.
- Les flows Genkit actuels sont listés.
- Les composants GenUI actuels sont listés.

**Critère de stop :**
Ne pas passer au lot suivant si le schéma Prisma réel ou les routes actuelles n'ont pas été inspectés.

**Risques :**

- Partir sur des noms de modèles qui n'existent pas.
- Écrire un plan incompatible avec les providers actuels.

### LOT-001B — Décision stratégie upload et lecture document

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Choisir le chemin officiel de stockage et lecture des documents pour le MVP.

**Pourquoi maintenant :**
Le worker de chunks et d'extraction doit lire le PDF au bon endroit. Si le front upload dans Firebase Storage mais que le worker lit le stockage local backend, le pipeline échoue silencieusement ou part dans deux directions.

**Périmètre inclus :**

- Comparer upload direct backend via `POST /documents/course-pdf`.
- Comparer upload Firebase Storage puis `POST /documents` metadata.
- Vérifier l'implémentation actuelle `LocalDocumentFileStorage`.
- Vérifier le comportement actuel du front multipart.
- Choisir le chemin officiel MVP.
- Documenter le chemin secondaire si on le garde temporairement.

**Non-objectifs :**

- Modifier l'upload.
- Ajouter un adapter Firebase Storage backend.
- Supprimer un endpoint existant.
- Migrer les documents déjà uploadés.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/infrastructure/local-document-file-storage.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/presentation/document_import_button.dart`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

**Backend :**
Décider quel `DocumentContentReader` est source de vérité pour le worker MVP.

**Frontend :**
Décider si l'upload officiel reste multipart backend ou redevient Firebase Storage.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Décider le statut de :

- `POST /documents/course-pdf`
- `POST /documents`

**Tests futurs attendus :**
Validation manuelle ou test d'intégration du chemin choisi.

**Commandes de validation futures :**

- `cd api && npm test -- documents`
- `cd revision_app && flutter test test/features/documents`

**Critères d'acceptation :**

- Le chemin officiel MVP est écrit.
- Le worker sait où lire le PDF.
- Le chemin non officiel est explicitement marqué comme legacy, secondaire ou futur.
- Aucun futur lot chunk/worker ne dépend d'une hypothèse implicite.

**Critère de stop :**
Ne pas modifier le pipeline chunks/worker tant que la stratégie de lecture document n'est pas tranchée.

**Risques :**

- Deux chemins d'upload divergents.
- Worker qui lit un fichier absent.
- Documentation contradictoire entre front et back.

### LOT-002 — Décisions fondations IA et documentaire

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Décider les options structurantes avant d'ajouter les résumés, fiches et corrections.

**Pourquoi maintenant :**
Les choix `DocumentChunk`, `SourceReference`, `GeneratedArtifact` et `AiGenerationJob` influencent presque tous les lots suivants.

**Périmètre inclus :**

- Comparer modèle spécialisé et modèle transversal pour les artefacts IA.
- Décider si `DocumentChunk` est nécessaire en MVP.
- Décider comment stocker ou référencer les sources.
- Décider si les générations sont synchrones ou asynchrones.
- Documenter les versions de prompt et de schéma.

**Non-objectifs :**

- Écrire la migration Prisma.
- Implémenter les modèles.
- Changer les flows existants.

**Fichiers ou zones probablement concernés :**

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- Futur document ADR dans `docs/` si demandé.

**Backend :**
Définir les options d'architecture.

**Frontend :**
Identifier l'impact sur les DTO affichés.

**Genkit :**
Définir `promptVersion`, `schemaVersion`, provider et modèle comme métadonnées obligatoires.

**GenUI :**
Décider si les payloads GenUI sont stockés comme artefacts ou reconstruits depuis les données métier.

**Données / Prisma :**
Options à comparer :

- modèles spécialisés uniquement ;
- `GeneratedArtifact` transversal ;
- `AiGenerationJob` pour statut et observabilité ;
- combinaison légère : modèles métier + table d'observabilité.

**API :**
Aucun contrat public à ajouter.

**Tests futurs attendus :**
Revue d'architecture.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Une recommandation est écrite pour chunks, sources et artefacts IA.
- Les décisions reportées sont explicites.
- Les lots suivants savent quelle option suivre.

**Critère de stop :**
Ne pas créer de résumé ou correction IA avant d'avoir choisi une stratégie source et versioning.

**Risques :**

- Sur-modéliser trop tôt.
- Sous-modéliser et rendre les sources impossibles à vérifier.

### LOT-002B — Revue de schéma avant migrations

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Regrouper les décisions de schéma avant la première migration documentaire.

**Pourquoi maintenant :**
Les lots futurs peuvent sinon produire une suite de migrations Prisma trop nombreuses : chunks, sources, knowledge units enrichies, summaries, QCM v2, questions ouvertes et sessions.

**Périmètre inclus :**

- Relire les décisions du LOT-001B et du LOT-002.
- Lister les migrations indispensables au MVP Cut 1.
- Lister les migrations à reporter.
- Définir un découpage de migrations cohérent et réversible.
- Vérifier les impacts sur tests Prisma et repositories.

**Non-objectifs :**

- Écrire une migration.
- Modifier `schema.prisma`.
- Générer le client Prisma.
- Ajouter des modèles applicatifs.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents`
- `api/src/modules/revision`
- `api/src/modules/activities`
- `api/src/modules/ai`

**Backend :**
Préparer une séquence de migrations, sans l'exécuter.

**Frontend :**
Identifier les DTO qui dépendront des champs nouveaux.

**Genkit :**
Vérifier que les schémas IA peuvent évoluer sans migration inutile.

**GenUI :**
Non concerné.

**Données / Prisma :**
Décider le minimum migratoire pour le premier cut :

- `DocumentChunk`
- lien notion-source
- champs enrichis `KnowledgeUnit`
- artefacts de fiche si inclus dans MVP Cut 1

**API :**
Aucun.

**Tests futurs attendus :**
Revue de schéma documentée.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- La première migration future a un périmètre clair.
- Les migrations non indispensables sont reportées.
- Les dépendances entre modèles sont explicites.

**Critère de stop :**
Ne pas lancer LOT-010 tant que cette revue n'a pas validé le périmètre migratoire.

**Risques :**

- Trop de migrations successives.
- Coupler le MVP à des modèles de session ou open question trop tôt.

### LOT-003 — Golden demo baseline

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Définir le PDF de démo, le scénario et les états attendus avant les fonctionnalités avancées.

**Pourquoi maintenant :**
Le PDF de démonstration pilote les tests manuels, les prompts et les exemples de sources.

**Périmètre inclus :**

- Choisir un PDF texte, court, légalement utilisable.
- Définir la matière de démo.
- Définir les états attendus du document.
- Définir les notions attendues approximatives.
- Définir la checklist de démonstration.

**Non-objectifs :**

- Ajouter un seed automatisé.
- Ajouter OCR ou support image.
- Ajouter des fixtures dans le code.

**Fichiers ou zones probablement concernés :**

- `revision_app/docs/`
- `api/README.md`
- Futurs fichiers de seed dans `api/prisma` si validé plus tard.

**Backend :**
Non concerné.

**Frontend :**
Non concerné.

**Genkit :**
Préparer les attentes de sortie pour tests manuels.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**
Checklist manuelle.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le PDF de démo est identifié.
- Le scénario de démo initial est écrit.
- Les preuves visuelles attendues sont listées.

**Critère de stop :**
Ne pas écrire de seed ou test e2e de démo sans PDF cible.

**Risques :**

- PDF trop long.
- PDF scanné sans texte.
- Contenu difficile à valider.

### LOT-004 — Port d'observabilité Genkit

**Bloc :**
Bloc E — Observabilité et versioning Genkit.

**Objectif :**
Introduire une interface backend pour tracer les générations IA sans coupler les use cases à un provider.

**Pourquoi maintenant :**
Les prochains flows doivent être observables dès leur création.

**Périmètre inclus :**

- Définir un port applicatif d'observabilité IA.
- Définir les champs obligatoires : flow, provider, model, duration, inputSize, status, error, promptVersion, schemaVersion.
- Ajouter un adapter minimal de log structuré si aucune persistance n'est décidée.
- Préparer les tests unitaires du port.

**Non-objectifs :**

- Ajouter une table Prisma si la décision n'est pas prise.
- Changer tous les flows IA avancés.
- Ajouter un dashboard.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/ai/ai.module.ts`

**Backend :**
Créer le port et l'adapter d'observabilité.

**Frontend :**
Non concerné.

**Genkit :**
Préparer l'enveloppe de mesure autour des appels `ai.generate`.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune au départ, sauf décision contraire du LOT-002.

**API :**
Aucun.

**Tests futurs attendus :**

- Test unitaire de l'adapter.
- Test que les champs obligatoires sont acceptés.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le backend a un port d'observabilité IA injectable.
- Les champs obligatoires sont documentés.
- Le port interdit explicitement de logger le texte complet du cours, le prompt complet ou la réponse complète du modèle.
- Aucun flow existant n'est cassé.

**Critère de stop :**
Ne pas instrumenter les flows si le port n'est pas testable sans provider externe.

**Risques :**

- Logger des contenus de cours sensibles.
- Rendre le port trop spécifique à Genkit.

### LOT-005 — Instrumentation des flows Genkit existants

**Bloc :**
Bloc E — Observabilité et versioning Genkit.

**Objectif :**
Tracer l'extraction de notions et la génération QCM existantes.

**Pourquoi maintenant :**
Ces flows sont déjà critiques et servent de base aux futures générations.

**Périmètre inclus :**

- Instrumenter `GenkitDocumentKnowledgeExtractor`.
- Instrumenter `GenkitDiagnosticQuizGenerator`.
- Ajouter `promptVersion` et `schemaVersion` constants.
- Mesurer durée et taille d'input.
- Capturer statut succès/échec.

**Non-objectifs :**

- Changer les prompts métier.
- Changer les modèles Prisma.
- Ajouter des nouveaux flows.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/ai/infrastructure/*.spec.ts`
- `api/src/modules/activities/infrastructure/*.spec.ts`

**Backend :**
Ajouter l'injection du port d'observabilité.

**Frontend :**
Non concerné.

**Genkit :**
Ajouter l'enveloppe de mesure autour de `generate`.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Flow success loggé.
- Flow error loggé.
- Taille input calculée sans stocker le texte complet.

**Commandes de validation futures :**

- `cd api && npm test -- genkit`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les deux flows existants produisent une trace.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.
- Les erreurs restent propagées comme avant.

**Critère de stop :**
Ne pas ajouter de nouveaux flows IA sans observabilité minimale.

**Risques :**

- Exposer des données personnelles dans les logs.
- Modifier involontairement le comportement IA.

### LOT-006 — Inventaire design system et surfaces prioritaires

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Identifier les primitives UI manquantes et les pages à traiter en priorité.

**Pourquoi maintenant :**
L'application a déjà des primitives, mais certaines surfaces restent trop Material-like.

**Périmètre inclus :**

- Auditer `presentation/widgets`.
- Auditer `presentation/pages`.
- Lister les usages restants de `Card`, `LinearProgressIndicator`, `CircularProgressIndicator`, états texte bruts.
- Définir les composants manquants prioritaires.

**Non-objectifs :**

- Refaire toutes les pages.
- Changer la navigation.
- Modifier les flows métier.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/widgets`
- `revision_app/lib/presentation/pages`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`

**Backend :**
Non concerné.

**Frontend :**
Audit des composants et pages.

**Genkit :**
Non concerné.

**GenUI :**
Identifier les composants qui doivent réutiliser les primitives.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**
Tests widget à prévoir par composant modifié.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- La liste des composants manquants est claire.
- Les pages prioritaires sont ordonnées.
- Aucun changement visuel massif n'est lancé.

**Critère de stop :**
Ne pas modifier les pages si les composants réutilisables cibles ne sont pas définis.

**Risques :**

- Recréer des composants redondants.
- Transformer ce lot en refonte complète.

### LOT-007 — Primitives UI minimales pour la démo

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Ajouter les composants UI réutilisables nécessaires au golden path.

**Pourquoi maintenant :**
Les futures pages document, fiche, QCM et correction doivent partager une identité visuelle.

**Périmètre inclus :**

- `DocumentStatusCard`.
- `StudyActionCard`.
- `MasteryRing`.
- `AiSurface`.
- États loading/error/empty premium.
- Tests widget des composants non triviaux.

**Non-objectifs :**

- Refaire toutes les pages existantes.
- Ajouter logique métier.
- Modifier les routes.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/widgets`
- `revision_app/test/presentation/widgets`

**Backend :**
Non concerné.

**Frontend :**
Créer les primitives et tests.

**Genkit :**
Non concerné.

**GenUI :**
Préparer les composants GenUI à réutiliser ces primitives plus tard.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Rendu light/dark.
- Texte long ne déborde pas.
- États erreur et retry.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les composants sont disponibles sous `presentation/widgets`.
- Les pages futures peuvent les réutiliser.
- Les tests widget passent.

**Critère de stop :**
Ne pas refactorer les pages avant que les primitives soient stables.

**Risques :**

- Sur-design de composants avant usage réel.
- Tokens visuels incohérents.

### LOT-008 — Application UI ciblée aux pages existantes

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Remplacer les surfaces brutes dans les pages du golden path sans changer la logique.

**Pourquoi maintenant :**
Les pages existantes doivent être présentables avant d'ajouter plus de contenu IA.

**Périmètre inclus :**

- Page matières.
- Page détail matière.
- Page activités.
- Page aujourd'hui.
- États vides, loading et erreurs.

**Non-objectifs :**

- Modifier les DTO.
- Ajouter détail document.
- Ajouter résumés ou questions ouvertes.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/pages/subjects`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/lib/presentation/pages/today`
- `revision_app/test/features/**`

**Backend :**
Non concerné.

**Frontend :**
Refactor UI ciblé vers primitives.

**Genkit :**
Non concerné.

**GenUI :**
Ne modifier que le rendu fallback si nécessaire.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Tests widget pages existantes.
- Tests navigation inchangée.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les pages principales utilisent les primitives.
- Les routes publiques restent identiques.
- Aucun comportement métier n'a changé.

**Critère de stop :**
Ne pas continuer si un test de navigation ou page existante casse.

**Risques :**

- Régression visuelle mobile.
- Changement involontaire de comportement.

### LOT-009 — Modèle documentaire cible détaillé

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Définir précisément `DocumentChunk`, `SourceReference` et les liens vers `KnowledgeUnit`.

**Pourquoi maintenant :**
Les sources doivent être stables avant de générer des résumés, fiches et corrections.

**Périmètre inclus :**

- Définir champs de `DocumentChunk`.
- Définir champs de `SourceReference`.
- Définir relations avec `Document`, `KnowledgeUnit`, futurs artefacts.
- Définir règles de chunking.
- Définir stratégie anti-hallucination : l'IA pointe vers des chunks existants.

**Non-objectifs :**

- Écrire migration.
- Modifier worker.
- Modifier prompts.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/domain`
- `api/src/modules/revision/domain`
- `api/src/modules/ai/application`

**Backend :**
Préparer le modèle cible.

**Frontend :**
Identifier les champs nécessaires à l'affichage.

**Genkit :**
Définir que les outputs retournent des `chunkId` ou références, pas des extraits libres seuls.

**GenUI :**
Préparer le futur `SourceExcerptCard`.

**Données / Prisma :**
Planifier un modèle minimal plutôt qu'un modèle documentaire trop générique.

Recommandation MVP :

- `DocumentChunk(id, documentId, index, text, charStart?, charEnd?, pageNumber?)`
- `KnowledgeUnitSource(knowledgeUnitId, chunkId, relevanceScore?)`
- `ArtifactSource(artifactId, chunkId, quoteStart?, quoteEnd?)` seulement si un modèle `GeneratedArtifact` est retenu

À éviter au départ :

- modèle polymorphe trop générique ;
- citations libres non vérifiées ;
- `pageNumber` obligatoire si l'extraction PDF ne le fournit pas proprement ;
- structure pensée pour OCR/image/audio avant que le PDF texte soit robuste.

**API :**
Planifier les DTO de notions sourcées.

**Tests futurs attendus :**
Revue de schéma avant migration.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le modèle documentaire cible est validé.
- Les relations minimales sont connues.
- Les champs trop ambitieux sont reportés.
- Le modèle retenu permet de vérifier qu'une citation vient d'un chunk stocké.

**Critère de stop :**
Ne pas écrire de migration avant validation du modèle.

**Risques :**

- Overengineering.
- Relations trop polymorphes difficiles à maintenir.

### LOT-010 — Persistance minimale des chunks et sources

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Ajouter la persistance minimale nécessaire aux chunks et références sources.

**Pourquoi maintenant :**
Le worker doit pouvoir stocker des références vérifiables avant extraction IA v2.

**Périmètre inclus :**

- Migration Prisma pour `DocumentChunk`.
- Migration Prisma pour `SourceReference` si retenu.
- Mise à jour du client Prisma.
- Repositories minimaux.
- Tests repository.

**Non-objectifs :**

- Générer des résumés.
- Exposer l'UI.
- Ajouter GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/revision/infrastructure`

**Backend :**
Ajouter ports et adapters minimaux.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter les modèles retenus.

**API :**
Aucun public.

**Tests futurs attendus :**

- Repository create/list chunks.
- Ownership par document.
- Suppression cascade si document supprimé.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les chunks sont persistables.
- Les chunks restent liés à un document étudiant.
- Les tests repository passent.

**Critère de stop :**
Ne pas changer le worker si la persistance chunk n'est pas testée.

**Risques :**

- Migration incorrecte.
- Cascade de suppression mal définie.

### LOT-011 — Chunking PDF dans le worker

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Découper le texte extrait en chunks stables avant appel Genkit.

**Pourquoi maintenant :**
Les flows IA doivent recevoir des références de chunks existants.

**Périmètre inclus :**

- Ajouter un service de chunking déterministe.
- Stocker les chunks dans le worker.
- Limiter taille chunk et nombre de chunks.
- Conserver ordre et offsets si possible.
- Tests unitaires du chunker.

**Non-objectifs :**

- Page number parfaite.
- OCR.
- Résumés.
- Correction IA.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`

**Backend :**
Créer et appeler le chunker.

**Frontend :**
Non concerné.

**Genkit :**
Préparer l'input chunké.

**GenUI :**
Non concerné.

**Données / Prisma :**
Utiliser `DocumentChunk`.

**API :**
Aucun public.

**Tests futurs attendus :**

- Texte court.
- Texte long.
- Texte avec paragraphes.
- Limites de taille.
- Worker stocke chunks avant extraction.

**Commandes de validation futures :**

- `cd api && npm test -- document-processing`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Chaque document texte produit des chunks ordonnés.
- Le worker échoue proprement si aucun chunk utile n'est produit.
- Les chunks ne dupliquent pas tout le document dans les logs.

**Critère de stop :**
Ne pas faire extraction v2 si les chunks ne sont pas stables.

**Risques :**

- Découpage trop naïf.
- Explosion du nombre de chunks.
- Perte de contexte.

### LOT-012 — Extraction Genkit v2 basée sur chunks

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Faire produire à Genkit des notions qui référencent des chunks existants.

**Pourquoi maintenant :**
Les notions enrichies doivent être sourcées sans hallucination d'extraits libres.

**Périmètre inclus :**

- Adapter le port `DocumentKnowledgeExtractor`.
- Fournir à Genkit une liste de chunks avec IDs courts.
- Demander des `sourceChunkIds`.
- Ajouter `difficulty`, `order`, `confidence`.
- Valider strictement les IDs retournés.
- Fallback si les IDs sont invalides.

**Non-objectifs :**

- Résumés.
- Fiches.
- Questions ouvertes.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`

**Backend :**
Adapter les DTO et validations.

**Frontend :**
Non concerné.

**Genkit :**
Créer extraction v2 sourcée.

**GenUI :**
Non concerné.

**Données / Prisma :**
Préparer les champs enrichis sur `KnowledgeUnit`.

**API :**
Aucun public.

**Tests futurs attendus :**

- Output avec chunks valides.
- Output avec chunk inconnu rejeté.
- Output sans notions.
- Document trop long.
- Provider Google et Mistral si supporté.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- document-processing`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les notions retournées référencent des chunks existants.
- Les sorties invalides sont rejetées.
- Les erreurs sont observées via le port Genkit.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas persister les notions enrichies si les références chunks ne sont pas validées.

**Risques :**

- Le modèle retourne des IDs invalides.
- Prompt trop complexe.
- Trop de chunks fournis au modèle.

### LOT-013 — Persistance KnowledgeUnit enrichie

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Persister les notions enrichies et leurs références sources.

**Pourquoi maintenant :**
Le frontend et les futurs artefacts IA doivent lire des notions sourcées.

**Périmètre inclus :**

- Ajouter champs enrichis à `KnowledgeUnit`.
- Persister `difficulty`, `order`, `confidence`.
- Créer les liens sources vers chunks.
- Mettre à jour `markReadyWithKnowledgeUnits`.
- Tests repository et worker.

**Non-objectifs :**

- UI détail document.
- Résumés.
- QCM enrichi.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`

**Backend :**
Mettre à jour domain, repository, worker.

**Frontend :**
Non concerné.

**Genkit :**
Consommer l'output v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Évolutions de `KnowledgeUnit` et liens source.

**API :**
Aucun public.

**Tests futurs attendus :**

- Persistence des champs enrichis.
- Liens sources créés.
- Document READY avec notions.
- Failure si source invalide.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- documents`
- `cd api && npm test -- jobs`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les notions enrichies sont persistées.
- Les références sources restent liées au bon document.
- Le worker conserve les statuts `READY` et `FAILED` correctement.

**Critère de stop :**
Ne pas exposer l'API notions tant que la persistance n'est pas fiable.

**Risques :**

- Incompatibilité avec tests existants.
- Données partielles si transaction mal découpée.

### LOT-014 — API détail document et notions sourcées

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Exposer un contrat backend stable pour lire un document, ses notions et leurs sources.

**Pourquoi maintenant :**
Le frontend doit rendre visible le processing IA avant fiches et QCM avancés.

**Périmètre inclus :**

- Ajouter `GET /documents/:documentId/knowledge-units`.
- Enrichir `GET /documents/:documentId` si nécessaire.
- Retourner sources sans exposer `storagePath`.
- Trier les notions par `order` puis création.
- Tests controller et repository.

**Non-objectifs :**

- Génération de fiche.
- Modification upload.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/revision/infrastructure`

**Backend :**
Créer use case et DTO.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Lecture des modèles ajoutés.

**API :**

- `GET /documents/:documentId/knowledge-units`
- `GET /documents/:documentId`

**Tests futurs attendus :**

- 401 sans token.
- 404 cross-student.
- Document non READY.
- Réponse triée.
- Sources filtrées.

**Commandes de validation futures :**

- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le frontend peut charger les notions d'un document.
- Aucun chemin interne de stockage n'est exposé.
- L'ownership est vérifié.

**Critère de stop :**
Ne pas construire la page détail document si le contrat API n'est pas stable.

**Risques :**

- Réponse trop volumineuse.
- Fuite de données source.

### LOT-015 — Data layer Flutter pour détail document

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Ajouter les modèles et repository HTTP Flutter pour lire le détail document et les notions.

**Pourquoi maintenant :**
La page UI doit dépendre d'un controller propre, pas de Dio directement.

**Périmètre inclus :**

- Modèle `KnowledgeUnit` côté Flutter.
- Modèle source reference léger.
- Méthodes dans `DocumentsApi` ou repository dédié.
- Controller/notifier Riverpod.
- Tests parsing JSON et erreurs.

**Non-objectifs :**

- Page complète.
- Résumés.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/documents/domain`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/application`
- `revision_app/test/features/documents`

**Backend :**
Non concerné.

**Frontend :**
Ajouter domain, API et état.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Consommer `GET /documents/:documentId/knowledge-units`.

**Tests futurs attendus :**

- JSON valide.
- JSON invalide.
- Token manquant.
- Erreur API.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/documents`

**Critères d'acceptation :**

- Le frontend parse les notions sourcées.
- Les erreurs sont remontées au controller.
- Les tests data passent.

**Critère de stop :**
Ne pas créer l'écran si le modèle front ne correspond pas au contrat API.

**Risques :**

- Divergence DTO backend/frontend.
- Gestion insuffisante des champs optionnels.

### LOT-016 — Page détail document et notions

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Afficher un document READY, ses notions, difficultés et sources.

**Pourquoi maintenant :**
C'est la première preuve utilisateur que l'IA a analysé le cours.

**Périmètre inclus :**

- Route ou navigation vers détail document.
- Page détail document.
- Cartes notions.
- Extraits sources.
- États upload, processing, ready, failed.
- Retry visuel si supporté par API.

**Non-objectifs :**

- Générer une fiche.
- Lancer QCM depuis chaque notion si non prévu.
- Session GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/core/routing/route_paths.dart`
- `revision_app/lib/presentation/pages/subjects`
- `revision_app/lib/presentation/pages/documents`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/documents`
- `revision_app/test/app/router`

**Backend :**
Non concerné.

**Frontend :**
Créer la page et brancher la navigation.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Consommer les endpoints du LOT-014.

**Tests futurs attendus :**

- Tap document ouvre détail.
- Document READY affiche notions.
- Document FAILED affiche erreur.
- Document PROCESSING affiche attente.
- Cross-platform layout raisonnable.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Un étudiant voit les notions extraites d'un document.
- Les sources sont affichées quand disponibles.
- Les états sont lisibles.

**Critère de stop :**
Ne pas lancer les fiches si l'utilisateur ne peut pas inspecter les notions sources.

**Risques :**

- Page trop chargée.
- Navigation profonde mal intégrée aux onglets.

### LOT-017 — Contrat artefacts générés

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Définir comment stocker et exposer les artefacts IA générés.

**Pourquoi maintenant :**
Résumé, fiche, correction et blocs GenUI ont des besoins communs de versioning, statut et sources.

**Périmètre inclus :**

- Choisir entre modèles spécialisés et `GeneratedArtifact`.
- Définir statuts : pending, processing, ready, failed si asynchrone.
- Définir métadonnées : flow, provider, model, promptVersion, schemaVersion.
- Définir relation aux sources.

**Non-objectifs :**

- Écrire migration.
- Implémenter génération.
- Ajouter UI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/ai`
- `api/src/modules/documents`
- `api/src/modules/activities`

**Backend :**
Architecture du contrat.

**Frontend :**
Identifier les DTO à afficher.

**Genkit :**
Définir métadonnées communes.

**GenUI :**
Décider si les blocs GenUI sont persistés comme artefacts.

**Données / Prisma :**
Options :

- `Summary` + `RevisionSheet` + `OpenAnswerEvaluation`.
- `GeneratedArtifact` transversal avec `type`.
- `AiGenerationJob` séparé pour statut et observabilité.

**API :**
Aucun public.

**Tests futurs attendus :**
Revue de contrat.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le stockage des artefacts est décidé.
- Les lots résumé et fiche peuvent avancer sans ambiguïté.

**Critère de stop :**
Ne pas créer `Summary` sans décider s'il dépend d'un artifact commun.

**Risques :**

- Modèle générique trop vague.
- Modèles spécialisés trop répétitifs.

### LOT-018 — Persistance Summary et RevisionSheet

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Ajouter les modèles et repositories nécessaires aux fiches.

**Pourquoi maintenant :**
La génération doit persister des objets métier relisibles après redémarrage.

**Périmètre inclus :**

- Modèles `Summary` et `RevisionSheet` ou artefact retenu.
- Repository.
- Use cases `GetSummary` et stockage minimal.
- Ownership par `studentId`.

**Non-objectifs :**

- Flow Genkit.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/summaries` ou `api/src/modules/documents`
- `api/src/modules/ai`

**Backend :**
Créer module/use cases/repository.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter les modèles retenus.

**API :**
Aucun ou endpoints de lecture si séparés.

**Tests futurs attendus :**

- Création.
- Lecture.
- Ownership.
- Source references liées.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- summaries`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les fiches sont persistables.
- Les sources sont associables.
- Aucun cross-student leak.

**Critère de stop :**
Ne pas appeler Genkit pour résumés si la persistance n'est pas prête.

**Risques :**

- Nouveau module mal intégré à `AppModule`.
- Duplication entre Summary et RevisionSheet.

### LOT-019 — Flow Genkit résumé et fiche

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Créer des flows Genkit typés pour résumé et fiche, basés sur chunks et notions.

**Pourquoi maintenant :**
Le premier artefact IA visible doit être fiable et sourcé.

**Périmètre inclus :**

- `generateSummaryFlow`.
- `generateRevisionSheetFlow`.
- Schémas Zod stricts.
- Inputs avec chunks sélectionnés.
- Outputs avec références sources.
- Observabilité.

**Non-objectifs :**

- UI.
- GenUI.
- Question ouverte.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/summaries`

**Backend :**
Ajouter ports et adapters Genkit.

**Frontend :**
Non concerné.

**Genkit :**
Créer flows et tests.

**GenUI :**
Non concerné.

**Données / Prisma :**
Consommer les sources et produire artefacts.

**API :**
Aucun public dans ce lot si isolé.

**Tests futurs attendus :**

- Output valide.
- Source inconnue rejetée.
- Document sans notion refusé.
- Erreur provider gérée.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- summaries`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les flows retournent des DTO validés.
- Les sources pointent vers des chunks existants.
- Les erreurs sont observées.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas exposer endpoint génération si le flow peut halluciner des sources non validées.

**Risques :**

- Prompt trop long.
- Sortie trop verbeuse.
- Coût IA.

### LOT-020 — API résumés et fiches

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Exposer la génération et la lecture des fiches depuis un document READY.

**Pourquoi maintenant :**
Le frontend a besoin d'un contrat stable pour afficher le premier artefact IA.

**Périmètre inclus :**

- `POST /documents/:documentId/summaries`.
- `GET /documents/:documentId/summaries`.
- Endpoint fiche si séparé.
- Validation document READY.
- Rate limit ou garde-fou minimal si disponible.
- Tests controller.

**Non-objectifs :**

- Génération asynchrone complexe si non décidée.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces`
- `api/src/modules/summaries`
- `api/src/modules/ai`

**Backend :**
Brancher use case, repository et flow.

**Frontend :**
Non concerné.

**Genkit :**
Appelé via use case.

**GenUI :**
Non concerné.

**Données / Prisma :**
Persisted summaries.

**API :**

- `POST /documents/:documentId/summaries`
- `GET /documents/:documentId/summaries`

**Tests futurs attendus :**

- 409 si document non READY.
- 404 cross-student.
- 422 output invalide.
- Résumé persisté.

**Commandes de validation futures :**

- `cd api && npm test -- summaries`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Un résumé peut être généré depuis un document READY.
- Le résumé est relisible.
- Les sources sont présentes si disponibles.

**Critère de stop :**
Ne pas construire l'écran fiche si les endpoints ne protègent pas l'ownership.

**Risques :**

- Endpoint trop lent si génération synchrone.
- Générations répétées coûteuses.

### LOT-021 — UI résumé et fiche

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Permettre à l'utilisateur de générer et lire une fiche sourcée.

**Pourquoi maintenant :**
C'est le premier usage IA visible après l'import.

**Périmètre inclus :**

- Data layer Flutter pour summaries.
- CTA générer une fiche.
- Affichage résumé express, points clés, pièges.
- Affichage sources.
- États loading/error/empty.

**Non-objectifs :**

- GenUI dynamique.
- Question ouverte.
- Session coach.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/documents`
- `revision_app/lib/presentation/pages/documents`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/documents`

**Backend :**
Non concerné.

**Frontend :**
Créer repository, controller et UI.

**Genkit :**
Non concerné côté front.

**GenUI :**
Non concerné dans ce lot.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints LOT-020.

**Tests futurs attendus :**

- CTA appelle endpoint.
- Fiche existante affichée.
- Erreur génération affichée.
- Sources affichées.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Depuis un document READY, l'utilisateur lit une fiche.
- La fiche reste visible après reload.
- Les erreurs sont compréhensibles.

**Critère de stop :**
Ne pas passer au QCM enrichi si le premier artefact IA n'est pas démontrable.

**Risques :**

- UI trop dense sur mobile.
- Confusion entre notion et fiche.

### LOT-022 — Contrat QCM v2

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Définir le contrat QCM enrichi sans fuite de correction avant submit.

**Pourquoi maintenant :**
Le QCM existe déjà, il faut l'améliorer sans casser l'activité actuelle.

**Périmètre inclus :**

- DTO QCM public sans `correctChoiceId`.
- DTO correction après submit.
- Nombre de questions configurable.
- Difficulty.
- Feedback par question.
- Compatibilité temporaire avec `/activities/next`.

**Non-objectifs :**

- Question ouverte.
- GenUI.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/activities/application`
- `api/src/modules/activities/interfaces`
- `api/src/modules/activities/domain`
- `revision_app/lib/features/activities/domain`

**Backend :**
Définir use cases et DTO.

**Frontend :**
Préparer modèles.

**Genkit :**
Adapter output cible.

**GenUI :**
Préparer composant futur.

**Données / Prisma :**
Préparer extensions `Question` et `ActivityResult`.

**API :**

- `POST /activities/diagnostic-quiz`
- `POST /activities/:sessionId/result`

**Tests futurs attendus :**
Contrat de non-fuite de correction.

**Commandes de validation futures :**

- `cd api && npm test -- activities`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- Le contrat public ne révèle pas la bonne réponse avant submit.
- La correction après submit est structurée.

**Critère de stop :**
Ne pas changer le flow Genkit QCM sans contrat clair.

**Risques :**

- Régression de l'activité existante.
- Incompatibilité DTO front/back.

### LOT-023 — Genkit QCM enrichi

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Améliorer la génération QCM avec feedback et grounding sur sources.

**Pourquoi maintenant :**
Le contrat QCM v2 exige des explications et distracteurs plus fiables.

**Périmètre inclus :**

- Schéma QCM v2.
- Prompt basé sur notion et chunks.
- Feedback par choix si retenu.
- Difficulté.
- Observabilité.
- Validation de distracteurs.

**Non-objectifs :**

- UI.
- Question ouverte.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/*.spec.ts`

**Backend :**
Adapter le generator.

**Frontend :**
Non concerné.

**Genkit :**
Flow QCM v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune directe, sauf champs du LOT-024.

**API :**
Aucun nouveau.

**Tests futurs attendus :**

- Une seule bonne réponse.
- Choix uniques.
- Feedback présent.
- Sources valides.

**Commandes de validation futures :**

- `cd api && npm test -- genkit-diagnostic-quiz`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le flow produit un QCM v2 valide.
- Le QCM reste basé sur le cours.
- Les outputs invalides sont rejetés.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas persister les corrections si le flow ne garantit pas les invariants.

**Risques :**

- Questions hors sujet.
- Distracteurs absurdes.

### LOT-024 — Persistance et soumission QCM enrichies

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Persister les métadonnées QCM v2 et renvoyer une correction détaillée après submit.

**Pourquoi maintenant :**
La maîtrise et la correction doivent être fiables côté backend avant UI avancée.

**Périmètre inclus :**

- Étendre `Question` et `ActivityResult`.
- Ajouter feedback par question.
- Ajouter score par notion.
- Ajouter `MasteryEvent` si retenu.
- Tests double submit, réponses inconnues, mastery.

**Non-objectifs :**

- UI correction.
- GenUI.
- Question ouverte.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/activities/application`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/revision`

**Backend :**
Mettre à jour repository et use cases.

**Frontend :**
Non concerné.

**Genkit :**
Consommer output QCM v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Extensions activité/résultat/maîtrise.

**API :**
Réponse enrichie de `POST /activities/:sessionId/result`.

**Tests futurs attendus :**

- Correction détaillée.
- Mastery update.
- Double submit 409.
- Réponse inconnue 400.
- Cross-student interdit.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- activities`
- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- La correction détaillée est renvoyée après submit.
- La maîtrise est mise à jour.
- Les protections existantes restent actives.

**Critère de stop :**
Ne pas refaire l'UI QCM tant que la correction backend n'est pas stable.

**Risques :**

- Calcul mastery opaque.
- Migration qui casse les sessions existantes.

### LOT-025 — UI QCM enrichi

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Afficher un QCM enrichi avec correction détaillée et feedback.

**Pourquoi maintenant :**
L'utilisateur doit comprendre pourquoi il a réussi ou échoué.

**Périmètre inclus :**

- Adapter `HttpActivitiesApi`.
- Adapter modèles domain Flutter.
- Refaire `DiagnosticQuizPage`.
- Afficher correction par question.
- Afficher score et feedback.

**Non-objectifs :**

- GenUI.
- Question ouverte.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Mettre à jour data/domain/UI.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné, fallback natif seulement.

**Données / Prisma :**
Aucune.

**API :**
Consommer les contrats LOT-022/024.

**Tests futurs attendus :**

- Parsing correction.
- Correction affichée après submit.
- Pas de correction avant submit.
- État erreur submit.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- L'utilisateur voit la correction détaillée.
- Les réponses correctes ne sont pas visibles avant validation.
- Le score est clair.

**Critère de stop :**
Ne pas ajouter GenUI QCM tant que le fallback natif n'est pas stable.

**Risques :**

- Régression mobile.
- UI trop longue pour plusieurs questions.

### LOT-026 — Contrat question ouverte

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Ajouter les modèles et contrats pour une question ouverte corrigée.

**Pourquoi maintenant :**
C'est la feature démo forte, mais elle doit reposer sur sources et QCM/mastery stabilisés.

**Périmètre inclus :**

- Nouveau type activité `OPEN_QUESTION`.
- Modèle question ouverte.
- Modèle évaluation.
- Endpoints de démarrage et soumission.
- Ownership et statuts.

**Non-objectifs :**

- Flow Genkit complet.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/activities`
- `api/src/modules/revision`

**Backend :**
Ajouter domain, use cases, repository.

**Frontend :**
Préparer DTO plus tard.

**Genkit :**
Définir interfaces seulement.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter modèles retenus.

**API :**

- `POST /activities/open-question`
- `POST /activities/:sessionId/open-answer`

**Tests futurs attendus :**

- Session créée.
- Réponse vide refusée.
- Double correction bloquée.
- Cross-student interdit.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- activities`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le backend peut représenter une question ouverte.
- Les endpoints sont protégés.
- Aucun flow IA non validé n'est requis pour les tests de contrat.

**Critère de stop :**
Ne pas brancher l'évaluation IA tant que les statuts et ownership ne sont pas testés.

**Risques :**

- Mélange trop fort avec QCM.
- Modèle d'activité trop rigide.

### LOT-027 — Genkit question ouverte et correction

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Créer les flows de génération et correction de question ouverte.

**Pourquoi maintenant :**
Les contrats backend sont prêts et les sources sont vérifiables.

**Périmètre inclus :**

- `generateOpenQuestionFlow`.
- `evaluateOpenAnswerFlow`.
- Schémas stricts.
- Barème.
- Points présents/manquants.
- Erreurs.
- Réponse modèle.
- Conseils.
- Sources.
- Observabilité.

**Non-objectifs :**

- UI.
- GenUI.
- Session coach.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/activities/application`
- `api/src/modules/activities/infrastructure`

**Backend :**
Brancher flows aux use cases.

**Frontend :**
Non concerné.

**Genkit :**
Créer et tester les flows.

**GenUI :**
Non concerné.

**Données / Prisma :**
Persisted evaluation.

**API :**
Utiliser endpoints LOT-026.

**Tests futurs attendus :**

- Bonne réponse.
- Réponse partielle.
- Réponse hors sujet.
- Sources invalides rejetées.
- Erreur IA explicite.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- activities`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- L'évaluation est structurée.
- Le score est séparé du feedback.
- Les sources sont référencées.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas créer l'UI si la correction n'est pas stable et testée.

**Risques :**

- Correction trop vague.
- Coût IA.
- Hallucination de points non présents dans le cours.

### LOT-028 — UI question ouverte corrigée

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Permettre à l'étudiant de répondre à une question ouverte et lire la correction.

**Pourquoi maintenant :**
Le backend peut générer et corriger l'activité.

**Périmètre inclus :**

- Modèles Flutter.
- Méthodes `HttpActivitiesApi`.
- Page ou mode d'activité question ouverte.
- Champ réponse long.
- État correction en cours.
- Affichage score, points manquants, réponse modèle.

**Non-objectifs :**

- GenUI.
- Coach.
- Plan du jour multi-actions.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Ajouter data/domain/UI.

**Genkit :**
Non concerné côté front.

**GenUI :**
Non concerné dans ce lot.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints question ouverte.

**Tests futurs attendus :**

- Réponse vide non soumise.
- Correction affichée.
- Erreur correction affichée.
- Champ long utilisable.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- L'étudiant reçoit une correction argumentée.
- Le fallback natif est complet.
- Les erreurs sont lisibles.

**Critère de stop :**
Ne pas construire GenUI question ouverte avant fallback natif stable.

**Risques :**

- UX de rédaction pénible sur mobile.
- Correction trop longue à afficher.

### LOT-029 — GenUI composants lecture sourcée

**Bloc :**
Bloc I — GenUI catalog isolé.

**Objectif :**
Ajouter des composants GenUI isolés pour résumé et sources.

**Pourquoi maintenant :**
GenUI doit être validé composant par composant avant la session.

**Périmètre inclus :**

- `SummaryCard`.
- `KeyPointsList`.
- `SourceExcerptCard`.
- Schémas JSON.
- Validateur.
- Fallback natif.
- Tests catalogue.

**Non-objectifs :**

- Session coach.
- Génération libre de widgets.
- QCM GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Étendre catalogue et validators.

**Genkit :**
Non concerné.

**GenUI :**
Ajouter composants lecture sourcée.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Payload valide rendu.
- Payload invalide rejeté.
- Fallback affiché.
- Longueur texte limitée.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities/revision_activity_catalog_test.dart`

**Critères d'acceptation :**

- Les composants sont bornés.
- Le catalogue refuse les payloads inconnus.
- Les composants réutilisent les primitives UI.

**Critère de stop :**
Ne pas ajouter la session GenUI tant que les composants source/résumé ne sont pas testés.

**Risques :**

- Schémas trop permissifs.
- Retour à des widgets Material bruts.

### LOT-030 — GenUI composants activité et correction

**Bloc :**
Bloc I — GenUI catalog isolé.

**Objectif :**
Ajouter les composants GenUI pour QCM, question ouverte et correction.

**Pourquoi maintenant :**
Les activités natives sont stables et peuvent servir de fallback.

**Périmètre inclus :**

- `McqQuestionCard`.
- `McqCorrectionPanel`.
- `ActivityResultCard`.
- `OpenQuestionCard`.
- `CorrectionPanel`.
- `RubricCard`.
- Tests validators.

**Non-objectifs :**

- Coach complet.
- Widgets arbitraires.
- Modification de scoring.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Étendre catalogue et validators.

**Genkit :**
Non concerné.

**GenUI :**
Composants activité bornés.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Chaque composant accepte payload valide.
- Chaque composant rejette payload invalide.
- Fallback natif conservé.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- GenUI peut rendre une activité sans casser le fallback.
- Aucun composant inconnu n'est rendu.

**Critère de stop :**
Ne pas construire la session coach si les composants activité ne sont pas isolés et testés.

**Risques :**

- Couplage fort au format backend.
- Validation incomplète.

### LOT-031 — Session de révision IA minimale

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Créer une session IA minimale qui orchestre des actions déjà existantes.

**Pourquoi maintenant :**
Les briques isolées existent : fiches, QCM, question ouverte, GenUI components.

**Périmètre inclus :**

- Modèle `RevisionSession`.
- Endpoint `POST /revision-sessions`.
- Endpoint message si nécessaire.
- Première action déterministe, sans coach libre.
- Historique minimal.

**Non-objectifs :**

- Orchestration LLM complète.
- Chatbot libre.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/revision`
- `api/src/modules/activities`
- `api/prisma/schema.prisma`

**Backend :**
Créer session et action initiale.

**Frontend :**
Non concerné dans ce lot.

**Genkit :**
Non concerné ou optionnel.

**GenUI :**
Payloads issus du catalogue existant seulement.

**Données / Prisma :**
Ajouter session si retenu.

**API :**

- `POST /revision-sessions`
- `POST /revision-sessions/:sessionId/message` si nécessaire.

**Tests futurs attendus :**

- Session appartient au student.
- Action initiale valide.
- Payload GenUI validé côté backend si stocké.

**Commandes de validation futures :**

- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Une session démarre et retourne une action existante.
- Aucune génération libre de widget.

**Critère de stop :**
Ne pas ajouter coach IA tant que la session déterministe ne fonctionne pas.

**Risques :**

- Modèle de session prématuré.
- Confusion entre session et activité.

### LOT-032 — Écran Révision IA minimal

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Afficher une session IA simple avec les composants GenUI validés.

**Pourquoi maintenant :**
Le backend fournit une session contrôlée.

**Périmètre inclus :**

- Route ou onglet si validé.
- Écran session.
- Chargement session.
- Rendu de blocs catalogue.
- Fallback bloc invalide.
- Historique simple.

**Non-objectifs :**

- Chat libre.
- Orchestration avancée.
- Nouvelle IA côté front.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/pages`
- `revision_app/test/app/router`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Créer data layer et page session.

**Genkit :**
Non concerné.

**GenUI :**
Rendre uniquement composants validés.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints LOT-031.

**Tests futurs attendus :**

- Session démarre.
- Bloc valide rendu.
- Bloc invalide fallback.
- Route protégée par auth.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- La session simple est démontrable.
- Le fallback fonctionne.
- Aucun widget arbitraire.

**Critère de stop :**
Ne pas ajouter orchestration IA si les blocs de session ne sont pas robustes.

**Risques :**

- Trop ressembler à un chatbot.
- Routes trop tôt modifiées.

### LOT-033 — Orchestration coach Genkit

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Ajouter un flow Genkit qui choisit la prochaine action parmi une enum bornée.

**Pourquoi maintenant :**
La session déterministe fonctionne et les composants sont validés.

**Périmètre inclus :**

- `generateCoachNextActionFlow`.
- Input contexte étudiant limité.
- Output intention enum.
- Le backend transforme l'intention en action validée.
- Fallback déterministe.

**Non-objectifs :**

- Widget libre.
- Classement TodayPlan par IA.
- Chat généraliste.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai`
- `api/src/modules/revision`
- `api/src/modules/activities`

**Backend :**
Brancher orchestration dans session.

**Frontend :**
Non concerné.

**Genkit :**
Créer flow coach.

**GenUI :**
Consommer uniquement composants existants.

**Données / Prisma :**
Éventuel stockage intention/action.

**API :**
Même endpoints session.

**Tests futurs attendus :**

- Intention valide.
- Intention inconnue rejetée.
- Fallback déterministe.
- Observabilité.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le coach propose une action valide.
- L'IA ne contrôle pas directement l'UI.
- Le fallback fonctionne sans provider.

**Critère de stop :**
Ne pas utiliser ce flow dans la démo si le fallback déterministe n'est pas prêt.

**Risques :**

- Orchestration trop vague.
- Perte de testabilité.

### LOT-034 — TodayPlan multi-actions backend

**Bloc :**
Bloc K — Plan du jour avancé.

**Objectif :**
Étendre le plan du jour à plusieurs types d'actions déterministes.

**Pourquoi maintenant :**
Les actions existent déjà : fiche, QCM, question ouverte, review faible.

**Périmètre inclus :**

- Ajouter types d'action.
- Ranking déterministe.
- Prendre en compte priority, mastery, lastPracticedAt, objectif.
- Raisons pédagogiques.
- Tests domain.

**Non-objectifs :**

- Ranking par IA.
- UI avancée.
- Notifications.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/revision/domain/adaptive-plan.service.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`
- `api/src/modules/revision/interfaces/today.controller.ts`
- `api/src/modules/revision/**/*.spec.ts`

**Backend :**
Étendre domain et DTO.

**Frontend :**
Non concerné.

**Genkit :**
Optionnel seulement pour phrase personnalisée, pas ranking.

**GenUI :**
Non concerné.

**Données / Prisma :**
Lire `MasteryEvent` ou résultats enrichis si ajoutés.

**API :**
Étendre `GET /today`.

**Tests futurs attendus :**

- Plan stable.
- Notions faibles prioritaires.
- Plusieurs actions.
- Cross-student impossible.

**Commandes de validation futures :**

- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- `GET /today` retourne plusieurs types d'actions.
- Les raisons sont explicites.
- Le résultat est déterministe.

**Critère de stop :**
Ne pas faire UI Today v2 si le ranking backend n'est pas stable.

**Risques :**

- Heuristique trop complexe.
- Raisons peu pédagogiques.

### LOT-035 — TodayPage v2 frontend

**Bloc :**
Bloc K — Plan du jour avancé.

**Objectif :**
Afficher les actions du plan du jour et permettre de les lancer.

**Pourquoi maintenant :**
Le backend expose des actions réellement exploitables.

**Périmètre inclus :**

- Adapter `TodayPlan` Flutter.
- Cartes d'actions.
- Boutons démarrer.
- État vide sans document READY.
- Progression quotidienne simple.

**Non-objectifs :**

- Notifications.
- Calendrier complet.
- Ranking côté front.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/today`
- `revision_app/lib/presentation/pages/today/today_page.dart`
- `revision_app/test/features/today`

**Backend :**
Non concerné.

**Frontend :**
Data/domain/UI Today v2.

**Genkit :**
Non concerné.

**GenUI :**
Optionnel uniquement pour cartes validées, pas nécessaire au fallback.

**Données / Prisma :**
Aucune.

**API :**
Consommer `GET /today` enrichi.

**Tests futurs attendus :**

- Plusieurs actions affichées.
- Démarrage QCM.
- Démarrage question ouverte.
- État vide.
- Erreur API.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/today`

**Critères d'acceptation :**

- L'utilisateur sait quoi faire aujourd'hui.
- Il peut lancer une action depuis la page.
- Le front ne recalcule pas le ranking.

**Critère de stop :**
Ne pas utiliser Today comme démo si les actions ne lancent rien.

**Risques :**

- UX confuse avec trop d'actions.
- Divergence des types d'action front/back.

### LOT-036 — Seed et fixtures de démo

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Rendre la démo reproductible avec des données connues.

**Pourquoi maintenant :**
Le golden path est complet et doit être rejouable.

**Périmètre inclus :**

- Seed matière.
- Seed document ou script d'import contrôlé.
- Seed mastery si utile.
- Données de test non sensibles.
- Documentation d'utilisation.

**Non-objectifs :**

- Seeder production.
- Contourner auth en production.
- Ajouter offline-first.

**Fichiers ou zones probablement concernés :**

- `api/prisma`
- `api/README.md`
- `revision_app/docs`

**Backend :**
Script ou documentation seed.

**Frontend :**
Non concerné sauf instructions demo.

**Genkit :**
Définir si les artefacts sont pré-générés ou générés pendant la démo.

**GenUI :**
Non concerné.

**Données / Prisma :**
Seed contrôlé.

**API :**
Aucun nouveau.

**Tests futurs attendus :**
Validation manuelle du seed.

**Commandes de validation futures :**
À confirmer après choix du mécanisme de seed.

**Critères d'acceptation :**

- Un développeur peut préparer la démo en suivant la documentation.
- Les données ne contiennent pas de secret.

**Critère de stop :**
Ne pas préparer captures ou scripts de présentation si le seed n'est pas reproductible.

**Risques :**

- Seed couplé à un utilisateur Firebase réel.
- Données de démo fragiles.

### LOT-037 — Tests e2e critiques et smoke checks

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Protéger le parcours principal par tests et smoke checks.

**Pourquoi maintenant :**
Le produit a assez de briques pour mériter une validation bout en bout.

**Périmètre inclus :**

- E2E backend sur endpoints critiques.
- Tests worker document.
- Smoke API `/health`.
- Smoke upload metadata ou upload fichier selon environnement.
- Checklist manuelle front.

**Non-objectifs :**

- Couvrir tous les edge cases.
- Remplacer les tests unitaires.
- Déployer automatiquement.

**Fichiers ou zones probablement concernés :**

- `api/test`
- `api/src/**/*.spec.ts`
- `revision_app/test`
- `revision_app/docs`

**Backend :**
Ajouter e2e et smoke.

**Frontend :**
Checklist ou tests widget complémentaires.

**Genkit :**
Mocks ou fakes pour éviter coûts en CI.

**GenUI :**
Tests payload/fallback.

**Données / Prisma :**
DB test.

**API :**
Parcours complet.

**Tests futurs attendus :**

- Auth mock.
- Création matière.
- Upload document.
- Processing contrôlé.
- Activité.
- Today.

**Commandes de validation futures :**

- `cd api && npm test`
- `cd api && npm run test:e2e`
- `cd api && npm run build`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les tests critiques passent localement.
- Les flows IA peuvent être mockés.
- La checklist manuelle est claire.

**Critère de stop :**
Ne pas déclarer la démo stable sans smoke checks.

**Risques :**

- Tests e2e lents.
- Dépendance à Firebase réelle.

### LOT-038 — Runbook démo et déploiement

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Documenter comment lancer, vérifier et présenter Revision App.

**Pourquoi maintenant :**
La valeur de la démo dépend autant de sa reproductibilité que du code.

**Périmètre inclus :**

- Variables d'environnement.
- Lancement API.
- Lancement worker.
- Redis/Postgres.
- Provider IA.
- Démarrage Flutter.
- Scénario de présentation.
- Troubleshooting erreurs IA et worker.

**Non-objectifs :**

- Ajouter infra nouvelle.
- Automatiser tous les déploiements.
- Modifier Dokploy.

**Fichiers ou zones probablement concernés :**

- `api/README.md`
- `revision_app/README.md`
- `revision_app/docs`

**Backend :**
Documentation runbook.

**Frontend :**
Documentation runbook.

**Genkit :**
Documenter provider, modèle, clés, timeouts.

**GenUI :**
Documenter catalogue et fallback.

**Données / Prisma :**
Documenter migrations et seed.

**API :**
Documenter smoke checks.

**Tests futurs attendus :**
Validation manuelle du runbook.

**Commandes de validation futures :**

- `cd api && npm run build`
- `cd revision_app && flutter build web`

**Critères d'acceptation :**

- Un développeur peut rejouer la démo.
- Les erreurs courantes sont documentées.
- Les commandes ne supposent pas de scripts inexistants.

**Critère de stop :**
Ne pas faire de présentation externe si le runbook n'a pas été rejoué.

**Risques :**

- Documentation obsolète.
- Variables sensibles exposées.

## 6. Ordre recommandé des 10 premiers lots

| Ordre | Lot | Justification |
| --- | --- | --- |
| 1 | LOT-001 | Il verrouille la vérité projet : routes, modèles, flows, tests. |
| 2 | LOT-001B | Il tranche le chemin officiel upload/lecture document avant de toucher au worker. |
| 3 | LOT-002 | Il tranche les décisions qui bloquent chunks, sources et artefacts IA. |
| 4 | LOT-002B | Il évite une rafale de migrations Prisma mal ordonnées. |
| 5 | LOT-003 | Il fixe le PDF et le scénario qui guideront les validations. |
| 6 | LOT-004 | L'observabilité Genkit doit exister avant les nouveaux flows. |
| 7 | LOT-005 | Les flows existants deviennent diagnostiquables avant enrichissement. |
| 8 | LOT-006 | Le design system doit être cadré avant d'ajouter de nouvelles pages. |
| 9 | LOT-009 | Le modèle documentaire cible doit précéder toute migration. |
| 10 | LOT-010 | La persistance chunks/sources débloque le worker et l'extraction v2. |

LOT-007 et LOT-008 peuvent être faits juste après LOT-006 si l'équipe veut améliorer vite le rendu visuel existant. Ils ne doivent pas bloquer les fondations documentaires si la priorité est l'IA sourcée.

### MVP Cut 1 — Démo minimale Genkit + GenUI

Objectif : obtenir rapidement une démo crédible sans attendre QCM v2, question ouverte complète, session coach et TodayPlan avancé.

À faire absolument :

- LOT-001 — Audit des contrats actuels.
- LOT-001B — Décision stratégie upload et lecture document.
- LOT-002 — Décisions fondations IA et documentaire.
- LOT-002B — Revue de schéma avant migrations.
- LOT-003 — Golden demo baseline.
- LOT-004 — Port d'observabilité Genkit.
- LOT-005 — Instrumentation des flows Genkit existants.
- LOT-009 — Modèle documentaire cible détaillé.
- LOT-010 — Persistance minimale des chunks et sources.
- LOT-011 — Chunking PDF dans le worker.
- LOT-012 — Extraction Genkit v2 basée sur chunks.
- LOT-013 — Persistance KnowledgeUnit enrichie.
- LOT-014 — API détail document et notions sourcées.
- LOT-015 — Data layer Flutter pour détail document.
- LOT-016 — Page détail document et notions.
- LOT-017 — Contrat artefacts générés.
- LOT-018 — Persistance Summary et RevisionSheet.
- LOT-019 — Flow Genkit résumé et fiche.
- LOT-020 — API résumés et fiches.
- LOT-021 — UI résumé et fiche.
- LOT-029 — GenUI composants lecture sourcée.

À reporter après ce cut :

- QCM enrichi complet.
- Question ouverte complète.
- Session coach complète.
- TodayPlan multi-actions.
- OCR/image/audio.

Ce cut montre déjà la valeur technique essentielle : PDF texte importé, chunks vérifiables, notions sourcées, fiche générée par Genkit, rendu GenUI borné pour fiche/source.

## 7. Matrice des dépendances

| Lot | Dépend de | Débloque | Risque principal | Validation clé |
| --- | --- | --- | --- | --- |
| LOT-001 | Aucun | LOT-001B, LOT-002, LOT-003 | Inventaire incomplet | Contrats réels listés |
| LOT-001B | LOT-001 | LOT-002, LOT-010, LOT-011 | Chemins upload divergents | Chemin officiel écrit |
| LOT-002 | LOT-001B | LOT-002B, LOT-009, LOT-017 | Décision trop générique | Options et recommandation écrites |
| LOT-002B | LOT-002 | LOT-010, LOT-018, LOT-024, LOT-026 | Trop de migrations successives | Périmètre migratoire validé |
| LOT-003 | LOT-001 | LOT-036, LOT-037 | PDF non représentatif | PDF texte validé |
| LOT-004 | LOT-002 | LOT-005 | Logs sensibles | Port testable sans provider |
| LOT-005 | LOT-004 | LOT-012, LOT-019, LOT-023 | Changement comportement IA | Logs sans texte complet |
| LOT-006 | LOT-001 | LOT-007 | Audit trop large | Composants manquants listés |
| LOT-007 | LOT-006 | LOT-008, LOT-016, LOT-021 | Sur-design | Tests widget |
| LOT-008 | LOT-007 | Démo visuelle | Régression UI | Tests pages existantes |
| LOT-009 | LOT-002B | LOT-010 | Overengineering | Modèle cible validé |
| LOT-010 | LOT-001B, LOT-002B, LOT-009 | LOT-011, LOT-013 | Migration fragile | Tests repository |
| LOT-011 | LOT-001B, LOT-010 | LOT-012 | Chunking pauvre | Tests chunker |
| LOT-012 | LOT-005, LOT-011 | LOT-013 | IDs source invalides | Output validé |
| LOT-013 | LOT-012 | LOT-014 | Transaction partielle | Worker tests |
| LOT-014 | LOT-013 | LOT-015 | Fuite source | Tests ownership |
| LOT-015 | LOT-014 | LOT-016 | DTO divergent | Tests parsing |
| LOT-016 | LOT-015, LOT-007 | LOT-021 | Page trop dense | Widget tests |
| LOT-017 | LOT-002B | LOT-018 | Modèle trop abstrait | Contrat choisi |
| LOT-018 | LOT-002B, LOT-017 | LOT-019 | Duplication modèle | Tests repository |
| LOT-019 | LOT-018, LOT-013 | LOT-020 | Hallucination sources | Sources validées |
| LOT-020 | LOT-019 | LOT-021 | Endpoint lent | Tests controller |
| LOT-021 | LOT-020, LOT-016 | LOT-029 | UX trop dense | Tests fiche |
| LOT-022 | LOT-001 | LOT-023, LOT-024 | Fuite correction | Contrat sans réponse |
| LOT-023 | LOT-022, LOT-013 | LOT-024 | Questions hors cours | Tests schema |
| LOT-024 | LOT-002B, LOT-023 | LOT-025, LOT-034 | Mastery opaque | Tests submit |
| LOT-025 | LOT-024 | LOT-030 | UI confuse | Widget tests |
| LOT-026 | LOT-002B, LOT-024 | LOT-027 | Modèle activité rigide | Tests endpoints |
| LOT-027 | LOT-026, LOT-013 | LOT-028 | Correction vague | Tests flow |
| LOT-028 | LOT-027 | LOT-030, LOT-034 | UX mobile | Widget tests |
| LOT-029 | LOT-021 | LOT-032 | Schéma permissif | Tests validator |
| LOT-030 | LOT-025, LOT-028 | LOT-032 | Payload invalide | Tests fallback |
| LOT-031 | LOT-029, LOT-030 | LOT-032, LOT-033 | Session prématurée | Session déterministe |
| LOT-032 | LOT-031 | LOT-033 | Chatbot générique | Fallback GenUI |
| LOT-033 | LOT-032 | Démo coach | Perte testabilité | Fallback déterministe |
| LOT-034 | LOT-024, LOT-028 | LOT-035 | Ranking opaque | Tests domain |
| LOT-035 | LOT-034 | Démo today | Divergence types | Widget tests |
| LOT-036 | LOT-003 | LOT-037, LOT-038 | Seed fragile | Rejeu manuel |
| LOT-037 | LOT-036 | Démo stable | Tests lents | E2E critiques |
| LOT-038 | LOT-036, LOT-037 | Présentation | Docs obsolètes | Runbook rejoué |

## 8. Lots à ne surtout pas lancer trop tôt

- Session GenUI complète : elle dépend de composants isolés, validation stricte et fallback natif.
- Plan du jour multi-actions avancé : il dépend de QCM enrichi, question ouverte, mastery events et actions lançables.
- Orchestration coach IA : elle doit venir après une session déterministe et des composants GenUI stables.
- Imports avancés OCR, image et audio : ils ajoutent un nouveau pipeline alors que le PDF texte doit d'abord être robuste.
- Génération libre de widgets : elle contredit le principe GenUI borné et crée un risque sécurité/UX.
- Refonte UI totale non bornée : elle consommerait du temps sans sécuriser la démo IA.
- Migration globale du modèle d'activité : elle risque de casser le QCM existant ; préférer extensions ciblées.
- Stockage générique de tous les artefacts sans cas d'usage validé : risque d'overengineering.
- Migrations Prisma en rafale sans revue de schéma : elles créent une dette difficile à corriger une fois les repositories et DTO branchés.

## 9. Golden demo path

| Étape | État initial | Action utilisateur | Résultat attendu | Preuve visuelle ou technique | Validation manuelle |
| --- | --- | --- | --- | --- | --- |
| 1. Login | App installée, backend disponible | Connexion Firebase | Routes privées accessibles | Profil affiché, token accepté | Se déconnecter puis vérifier `/sign-in` |
| 2. Création matière | Aucun sujet ou compte démo | Créer “Droit constitutionnel” | Matière persistée | Liste matières affiche la carte | Redémarrer app, matière présente |
| 3. Import PDF | Matière ouverte | Importer PDF texte de démo | Document `UPLOADED` puis `PROCESSING` | Carte document avec statut | Vérifier API liste documents |
| 4. Processing | Worker actif | Attendre traitement | Document `READY` | Statut prêt | Vérifier logs worker sans erreur |
| 5. Notions détectées | Document READY | Ouvrir détail document | Notions, difficulté, sources | Cartes notions + extraits | Comparer aux passages du PDF |
| 6. Fiche générée | Notions disponibles | Cliquer générer fiche | Fiche sourcée | Résumé, points clés, sources | Vérifier sources non inventées |
| 7. QCM enrichi | Notions prêtes | Lancer diagnostic | QCM sans correction visible | Questions et choix | Vérifier pas de bonne réponse exposée |
| 8. Question ouverte corrigée | Notion sélectionnée | Répondre en texte libre | Correction structurée | Score, points manquants, modèle | Vérifier feedback cohérent |
| 9. Plan du jour mis à jour | Activité soumise | Ouvrir Aujourd'hui | Recommandation adaptée | Carte action et raison | Comparer mastery avant/après |
| 10. Session GenUI simple | Composants validés | Démarrer Révision IA | Bloc dynamique rendu | Summary/QCM/correction dans AiSurface | Forcer payload invalide et voir fallback |

## 10. Stratégie de validation globale

### Backend

- Tests unitaires domain pour chunking, mastery, ranking Today.
- Tests application pour use cases documents, summaries, activities, revision sessions.
- Tests infrastructure Prisma pour ownership et persistance.
- Tests controller pour 401, 400, 404, 409, 422.
- Tests worker pour statuts `PROCESSING`, `READY`, `FAILED`.
- Commandes probables :
  - `cd api && npm run lint:check`
  - `cd api && npm test`
  - `cd api && npm run test:e2e`
  - `cd api && npm run build`

### Frontend

- Tests data pour parsing JSON et erreurs Dio.
- Tests controller/notifier Riverpod.
- Tests widget pour pages et composants.
- Tests router pour auth, onglets et deep links.
- Commandes probables :
  - `cd revision_app && dart analyze lib test`
  - `cd revision_app && flutter test`
  - `cd revision_app && flutter build web`

### Genkit

- Tests de schémas Zod.
- Tests de outputs invalides.
- Tests de source grounding.
- Tests d'observabilité succès/échec.
- Fakes ou mocks pour éviter les coûts IA en CI.
- Validation manuelle ponctuelle avec provider réel.

### GenUI

- Tests de catalogue.
- Tests de payload valide.
- Tests de payload invalide.
- Tests fallback.
- Interdiction de composant inconnu.
- Limites de longueur sur textes rendus.

### Validations manuelles

- Golden path complet.
- Import PDF réel.
- Worker réel.
- Fiche sourcée.
- QCM et correction.
- Question ouverte.
- Today après activité.
- Session GenUI simple.

### Contrôles sécurité

- Token obligatoire.
- Ownership par `studentId`.
- Aucun `storagePath` interne exposé.
- Pas de correction avant submit.
- Pas de source cross-document.

### Contrôles anti-hallucination

- Les sources affichées doivent venir de chunks stockés.
- Les outputs IA avec références inconnues doivent être rejetés.
- Les fiches et corrections doivent pointer vers des chunks ou notions.
- Les prompts doivent interdire le contenu externe.

### Contrôles coût et timeouts

- Limite taille input.
- Limite nombre chunks fournis.
- Timeout provider IA.
- Retry contrôlé.
- Rate limit génération si disponible.
- Observabilité durée et statut.

## 11. Risques transverses

| Risque | Probabilité | Impact | Mitigation | Lot traité |
| --- | --- | --- | --- | --- |
| Hallucination des sources | Élevée | Élevé | Chunks backend, validation IDs, rejet outputs invalides | LOT-009 à LOT-013 |
| PDF trop longs | Élevée | Moyen | Chunking, limite input, sélection chunks | LOT-011, LOT-012 |
| PDF scannés sans OCR | Moyenne | Moyen | Message erreur explicite, hors MVP | LOT-011, LOT-038 |
| Coût IA | Moyenne | Élevé | Observabilité, limites, fakes CI, rate limit | LOT-004, LOT-005, LOT-019 |
| Lenteur IA | Moyenne | Moyen | Timeouts, jobs async si retenu, UI loading | LOT-017, LOT-020, LOT-021 |
| Payload GenUI invalide | Élevée | Moyen | Catalogue strict, validators, fallback | LOT-029, LOT-030 |
| Fuite cross-student | Moyenne | Élevé | Tests ownership sur chaque endpoint | Tous lots API |
| Frontend trop Material-like | Moyenne | Moyen | Primitives premium ciblées | LOT-006 à LOT-008 |
| Overengineering documentaire | Moyenne | Élevé | Décision LOT-002, modèle minimal | LOT-009 |
| Dette si coach trop tôt | Élevée | Élevé | Retarder session complète | LOT-031 à LOT-033 |
| Correction ouverte trop vague | Moyenne | Élevé | Barème strict, sources, tests réponses types | LOT-027 |
| Ranking Today opaque | Moyenne | Moyen | Algorithme déterministe testé | LOT-034 |
| Logs contenant données sensibles | Moyenne | Élevé | Ne logger que tailles, IDs techniques et statuts | LOT-004, LOT-005 |
| Divergence upload/lecture document | Moyenne | Élevé | Choisir un chemin officiel MVP et documenter les chemins secondaires | LOT-001B |

## 12. Décisions à prendre avant implémentation

| Décision | Options | Recommandation | Impact | Moment où décider |
| --- | --- | --- | --- | --- |
| Quelle stratégie upload/lecture document officielle ? | Upload direct backend / Firebase Storage + reader backend / coexistence temporaire | Pour le MVP, garder `POST /documents/course-pdf` comme chemin officiel si le worker lit le stockage local ; garder `POST /documents` seulement comme compatibilité documentée ou futur Firebase Storage avec adapter backend dédié | Pipeline worker, sécurité stockage, tests d'import | LOT-001B |
| Faut-il ajouter `DocumentChunk` ? | Oui / Non / stockage temporaire | Oui, minimal, car nécessaire au grounding | Structure worker et Genkit | LOT-002 puis LOT-009 |
| Faut-il ajouter `SourceReference` ? | Table dédiée / JSON dans artefacts / relation directe | Table dédiée légère si plusieurs artefacts citent les mêmes chunks | API sources et anti-hallucination | LOT-002 puis LOT-009 |
| Faut-il ajouter `AiGenerationJob` ? | Non / logs seulement / table dédiée | Commencer par port observabilité, table si besoin de statuts async | Debug et coûts IA | LOT-002 puis LOT-004 |
| Faut-il ajouter `GeneratedArtifact` ? | Non / table générique / modèles spécialisés | Modèles métier spécialisés, avec métadonnées communes ; générique seulement si duplication forte | Simplicité Prisma | LOT-017 |
| Faut-il versionner les prompts en DB ? | Constantes code / DB / table config | Stocker `promptVersion` et `schemaVersion` sur artefacts générés | Reproductibilité | LOT-017, LOT-018 |
| Faut-il stocker les payloads GenUI ? | Non / oui pour session / oui partout | Stocker seulement en session si nécessaire ; reconstruire depuis objets métier pour fiches | Debug session | LOT-031 |
| Faut-il historiser les résumés ? | Écraser / versions multiples / latest + archived | Pour MVP, garder latest avec `regeneratedAt`, puis historiser si demandé | Coût et UX | LOT-018 |
| Faut-il faire les générations en job asynchrone ? | Synchrone / async par BullMQ / hybride | Synchrone pour résumé court MVP si timeout acceptable ; async pour traitements longs | UX et robustesse | LOT-017, LOT-020 |
| Quel est le premier PDF de démo ? | Cours droit constitutionnel / PDF synthétique / autre cours court | PDF texte court et maîtrisé, idéalement synthétique | Tests manuels | LOT-003 |
| Quels composants GenUI minimum ? | Summary + Source / QCM / Correction / all | SummaryCard, SourceExcerptCard, McqQuestionCard, CorrectionPanel | Démo GenUI réaliste | LOT-029, LOT-030 |

## 13. Définition de done pour les futurs lots

Un futur lot d'implémentation est terminé seulement si :

- le périmètre du lot est respecté ;
- aucun objectif hors lot n'a été ajouté ;
- les tests pertinents sont écrits ou explicitement justifiés ;
- les validations prévues sont lancées ;
- les erreurs sont gérées ;
- les données restent isolées par étudiant ;
- les outputs IA sont typés et validés si le lot touche Genkit ;
- les payloads GenUI sont validés et ont un fallback si le lot touche GenUI ;
- les états loading/error/empty sont présents si le lot touche le frontend ;
- les commandes lancées et leurs résultats sont rapportés ;
- aucun commit Git n'est effectué ;
- le rapport final mentionne fichiers modifiés, tests lancés, tests non lancés et risques restants.

## 14. Proposition de prochain lot concret

Le prochain lot à lancer après ce plan devrait être :

### LOT-001 — Audit des contrats actuels

Raison :

- Il est prudent.
- Il ne modifie pas le code.
- Il réduit le risque de construire sur une hypothèse fausse.
- Il prépare la décision upload/lecture document du LOT-001B.
- Il permettra ensuite de lancer LOT-002 avec des informations vérifiées.

Livrable attendu :

- Un court document d'audit ou une section ajoutée au plan avec les endpoints, modèles, flows, scripts et gaps confirmés.
- Aucune migration.
- Aucune dépendance.
- Aucun commit.

Le deuxième lot à lancer immédiatement après devrait être LOT-001B. Il doit trancher si le MVP utilise officiellement l'upload direct backend via `POST /documents/course-pdf`, Firebase Storage avec reader backend, ou une coexistence temporaire documentée. Sans cette décision, il ne faut pas toucher au worker, aux chunks ou aux migrations documentaires.

````````
