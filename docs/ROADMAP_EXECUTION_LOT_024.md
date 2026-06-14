# LOT-024 — Persistance et soumission QCM enrichies

## 1. Résultat

`LOT-024` ajoute la persistance minimale du QCM v2 et la soumission enrichie côté backend.

Le lot introduit :

- une migration Prisma `20260614170000_qcm_v2_persistence_submission`;
- les champs de session nécessaires au versioning QCM v2;
- `QuestionSource` pour relier une question à des `DocumentChunk`;
- `QuestionAnswer` pour stocker les réponses soumises;
- `score` sur `ActivityResult`;
- un contexte de génération QCM sourcé côté repository;
- la création de quiz v2 sourcés sans fuite pré-submit;
- la soumission détaillée après submit avec correction, feedback et sources textuelles;
- les tests repository, use case et module.

Le lot ne modifie pas Flutter, GenUI, Genkit, les prompts, TodayPlan, les questions ouvertes, Firebase Storage ou le chemin d'upload document.

## 2. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_022.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`

Backend :

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.spec.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.spec.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/activities.module.ts`
- `api/src/modules/activities/activities.module.spec.ts`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/revision/application/revision.repository.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`
- `api/src/modules/revision/domain/mastery-state.entity.ts`

## 3. Préflight Git et Prisma

État initial API :

```text
Branche: main
Git status: propre
```

État initial frontend :

```text
Branche: main
Git status: propre
```

Contrôles initiaux :

```text
revision_app/docs/ROADMAP_EXECUTION_LOT_023.md: présent
revision_app/docs/ROADMAP_EXECUTION_PLAN.md: présent
api build initial: succès
npx prisma validate: succès
npm run prisma:generate: succès
npx prisma migrate status: échec Schema engine error sur localhost:5432
```

Décision DB :

- PostgreSQL local n'est toujours pas validé via `migrate status`.
- La migration a donc été créée par diff Prisma depuis un snapshot local du schéma avant modification.
- Aucune migration n'a été appliquée.
- `prisma migrate deploy` n'a pas été lancé.

## 4. Schéma Prisma ajouté

Décisions :

- Pas de table `QuestionChoice` pour le MVP : les choix restent dans `Question.choices` JSON, comme dans l'existant.
- Ajout de `QuestionSource` pour garantir que les sources des questions pointent vers `DocumentChunk`.
- Ajout de `QuestionAnswer` pour empêcher les doubles réponses par question via `@@unique([sessionId, questionId])`.
- Ajout de métadonnées de génération sur `ActivitySession` pour tracer le QCM v2 sans créer `AiGenerationJob`.
- Ajout de `score` sur `ActivityResult`.
- `correctChoiceId`, `explanation` et `feedback` restent internes avant submit.

Extrait diff Prisma :

```diff
model DocumentChunk {
  sources  KnowledgeUnitSource[]
  summarySources SummarySource[]
  revisionSheetSectionSources RevisionSheetSectionSource[]
+ questionSources QuestionSource[]
}

model ActivitySession {
  studentId       String
  subjectId       String
  knowledgeUnitId String
+ version         Int            @default(1)
+ documentId      String?
+ generationFlowName      String?
+ generationProvider      String?
+ generationModel         String?
+ generationPromptVersion String?
+ generationSchemaVersion String?
+ generationInputSize     Int?
  type            ActivityType
  status          ActivityStatus @default(STARTED)
  questions       Question[]
  result          ActivityResult?
+ answers         QuestionAnswer[]

+ @@index([documentId])
}

model Question {
  id              String @id @default(cuid())
  sessionId       String
+ subjectId       String?
+ documentId      String?
  knowledgeUnitId String
  prompt          String
+ difficulty      KnowledgeUnitDifficulty?
+ displayOrder    Int    @default(0)
  choices         Json
  correctChoiceId String
  explanation     String
+ sources         QuestionSource[]
+ answers         QuestionAnswer[]

+ @@index([sessionId])
+ @@index([subjectId])
+ @@index([documentId])
+ @@unique([id, subjectId])
}

+model QuestionSource {
+  questionId     String
+  subjectId      String
+  chunkId        String
+  relevanceScore Float?
+  createdAt      DateTime @default(now())
+
+  question Question @relation(fields: [questionId], references: [id], onDelete: Cascade)
+  chunk    DocumentChunk @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)
+
+  @@id([questionId, chunkId])
+  @@index([chunkId])
+  @@index([subjectId])
+}
+
+model QuestionAnswer {
+  id               String   @id @default(cuid())
+  sessionId        String
+  questionId       String
+  selectedChoiceId String
+  isCorrect        Boolean
+  createdAt        DateTime @default(now())
+
+  session  ActivitySession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
+  question Question        @relation(fields: [questionId], references: [id], onDelete: Cascade)
+
+  @@unique([sessionId, questionId])
+  @@index([questionId])
+}

model ActivityResult {
  correctAnswers Int
  totalQuestions Int
+ score          Float?
}
```

## 5. Migration

Migration créée :

```text
api/prisma/migrations/20260614170000_qcm_v2_persistence_submission/migration.sql
```

Méthode de génération :

```bash
cp prisma/schema.prisma /tmp/revision-schema-before-lot024.prisma
npx prisma migrate diff --from-schema /tmp/revision-schema-before-lot024.prisma --to-schema prisma/schema.prisma --script --output prisma/migrations/20260614170000_qcm_v2_persistence_submission/migration.sql
```

SQL généré par Prisma :

```sql
-- AlterTable
ALTER TABLE "ActivitySession" ADD COLUMN     "documentId" TEXT,
ADD COLUMN     "generationFlowName" TEXT,
ADD COLUMN     "generationInputSize" INTEGER,
ADD COLUMN     "generationModel" TEXT,
ADD COLUMN     "generationPromptVersion" TEXT,
ADD COLUMN     "generationProvider" TEXT,
ADD COLUMN     "generationSchemaVersion" TEXT,
ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 1;

-- AlterTable
ALTER TABLE "Question" ADD COLUMN     "difficulty" "KnowledgeUnitDifficulty",
ADD COLUMN     "displayOrder" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "documentId" TEXT,
ADD COLUMN     "subjectId" TEXT;

-- AlterTable
ALTER TABLE "ActivityResult" ADD COLUMN     "score" DOUBLE PRECISION;

-- CreateTable
CREATE TABLE "QuestionSource" (
    "questionId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "chunkId" TEXT NOT NULL,
    "relevanceScore" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QuestionSource_pkey" PRIMARY KEY ("questionId","chunkId")
);

-- CreateTable
CREATE TABLE "QuestionAnswer" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "selectedChoiceId" TEXT NOT NULL,
    "isCorrect" BOOLEAN NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "QuestionAnswer_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "QuestionSource_chunkId_idx" ON "QuestionSource"("chunkId");

-- CreateIndex
CREATE INDEX "QuestionSource_subjectId_idx" ON "QuestionSource"("subjectId");

-- CreateIndex
CREATE INDEX "QuestionAnswer_questionId_idx" ON "QuestionAnswer"("questionId");

-- CreateIndex
CREATE UNIQUE INDEX "QuestionAnswer_sessionId_questionId_key" ON "QuestionAnswer"("sessionId", "questionId");

-- CreateIndex
CREATE INDEX "ActivitySession_documentId_idx" ON "ActivitySession"("documentId");

-- CreateIndex
CREATE INDEX "Question_sessionId_idx" ON "Question"("sessionId");

-- CreateIndex
CREATE INDEX "Question_subjectId_idx" ON "Question"("subjectId");

-- CreateIndex
CREATE INDEX "Question_documentId_idx" ON "Question"("documentId");

-- CreateIndex
CREATE UNIQUE INDEX "Question_id_subjectId_key" ON "Question"("id", "subjectId");

-- AddForeignKey
ALTER TABLE "QuestionSource" ADD CONSTRAINT "QuestionSource_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "Question"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuestionSource" ADD CONSTRAINT "QuestionSource_chunkId_subjectId_fkey" FOREIGN KEY ("chunkId", "subjectId") REFERENCES "DocumentChunk"("id", "subjectId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuestionAnswer" ADD CONSTRAINT "QuestionAnswer_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "ActivitySession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuestionAnswer" ADD CONSTRAINT "QuestionAnswer_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "Question"("id") ON DELETE CASCADE ON UPDATE CASCADE;
```

La migration ne contient que le périmètre QCM v2. Elle n'a pas été appliquée.

## 6. Repository et use cases

Port `ActivitiesRepository` enrichi :

```diff
+export interface DiagnosticQuizGenerationContext {
+  documentId: string | null;
+  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit;
+  chunks: DiagnosticQuizGenerationChunk[];
+}
+
+export interface DiagnosticQuizSubmissionResult {
+  correctAnswers: number;
+  totalQuestions: number;
+  score: number;
+  knowledgeUnitId: string;
+  items: ActivityQuestionCorrectionItem[];
+}
+
 export interface ActivitiesRepository {
+  findDiagnosticQuizGenerationContext(input: {
+    studentId: string;
+    subjectId: string;
+    knowledgeUnitId: string;
+  }): Promise<DiagnosticQuizGenerationContext | null>;
+
   createDiagnosticQuiz(input: {
     studentId: string;
     subjectId: string;
     knowledgeUnitId: string;
+    documentId?: string | null;
     quiz: GeneratedDiagnosticQuiz;
   }): Promise<DiagnosticQuizActivity>;
```

`StartNextActivityUseCase` consomme le contexte sourcé quand il existe, sinon conserve le mode legacy :

```ts
const generationContext =
  await this.activitiesRepository.findDiagnosticQuizGenerationContext({
    studentId: input.studentId,
    subjectId: input.subjectId,
    knowledgeUnitId: knowledgeUnit.id,
  });
const hasSourcedContext =
  generationContext !== null && generationContext.chunks.length > 0;
const quiz = await this.diagnosticQuizGenerator.generate(
  hasSourcedContext
    ? {
        subjectId: input.subjectId,
        documentId: generationContext.documentId,
        knowledgeUnit: generationContext.knowledgeUnit,
        chunks: generationContext.chunks,
      }
    : { knowledgeUnit },
);
```

`SubmitActivityResultUseCase` retourne désormais la correction enrichie, mais retire `knowledgeUnitId` du DTO public :

```ts
const { knowledgeUnitId, ...publicResult } = result;
void knowledgeUnitId;

return publicResult;
```

Adapter Prisma : zones clés créées/modifiées.

```ts
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
```

```ts
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
```

```ts
function parsePublicQuestionChoices(input: unknown) {
  return parseInternalQuestionChoices(input).map((choice) => ({
    id: choice.id,
    label: choice.label,
  }));
}
```

Ce mapping public conserve `id` et `label`, mais retire `feedback`. Le `correctChoiceId`, l'explication et les feedbacks ne sont disponibles qu'après soumission.

```ts
await tx.questionAnswer.createMany({
  data: result.items.map((item) => ({
    sessionId: session.id,
    questionId: item.questionId,
    selectedChoiceId: item.selectedChoiceId,
    isCorrect: item.isCorrect,
  })),
});

await tx.activityResult.create({
  data: {
    sessionId: session.id,
    correctAnswers: result.correctAnswers,
    totalQuestions: result.totalQuestions,
    score: result.score,
  },
});
```

## 7. API et DTOs

Endpoints existants conservés :

- `POST /activities/next`
- `POST /activities/:sessionId/result`

Pré-submit :

- pas de `correctChoiceId`;
- pas de `isCorrect`;
- pas d'explication;
- pas de feedback;
- sources exposées uniquement sous forme non textuelle : `chunkId`, `pageNumber`, `index`.

Après submit :

- `correctChoiceId` est exposé;
- `isCorrect` est exposé;
- `explanation` est exposée;
- `choiceFeedback` est exposé si disponible;
- les sources textuelles liées sont exposées.

Erreurs ajoutées dans le controller :

```ts
if (
  error.message === 'Generated diagnostic quiz is invalid' ||
  error.message === 'Question source chunk not found'
) {
  throw new UnprocessableEntityException(error.message);
}
```

## 8. Sécurité anti-fuite

Garanties implémentées :

- `Question.choices` peut contenir du feedback interne, mais `parsePublicQuestionChoices` le retire du DTO pré-submit.
- `correctChoiceId` reste dans la persistance interne et n'est pas retourné par `POST /activities/next`.
- `explanation` reste interne avant submit.
- les sources textuelles ne sont retournées qu'après submit.
- une réponse inconnue est rejetée.
- une question inconnue est rejetée.
- une réponse manquante est rejetée.
- une double réponse dans un payload est rejetée par validation applicative.
- une double soumission est rejetée si la session est déjà complétée ou si un résultat existe.
- `QuestionAnswer` empêche une double réponse persistée pour une même question dans une même session.

## 9. Données non stockées / non exposées

Non stocké :

- prompt complet;
- completion complète;
- chunks complets dans un payload QCM;
- source libre IA;
- payload GenUI;
- `GeneratedArtifact`;
- `AiGenerationJob`.

Non exposé avant submit :

- `correctChoiceId`;
- `isCorrect`;
- explication;
- feedback de choix;
- texte source complet.

## 10. Tests créés ou modifiés

Tests modifiés :

- `api/src/modules/activities/application/start-next-activity.use-case.spec.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.spec.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `api/src/modules/activities/activities.module.spec.ts`

Couvertures ajoutées :

- contexte de génération sourcé depuis `KnowledgeUnitSource` + `DocumentChunk`;
- création d'un QCM v2 avec sources;
- absence de fuite de correction dans le DTO pré-submit;
- rejet d'une source inconnue ou cross-document;
- persistance `QuestionAnswer`;
- score persistant;
- correction détaillée après submit;
- sources textuelles après submit;
- rejet des questions inconnues;
- rejet des choix inconnus;
- rejet des réponses manquantes;
- double submit conservé;
- compatibilité mode legacy.

## 11. Validations lancées

Préflight :

```bash
cd api && npm run build
```

Résultat :

```text
succès
```

```bash
cd api && npx prisma validate
```

Résultat :

```text
The schema at prisma/schema.prisma is valid
```

```bash
cd api && npm run prisma:generate
```

Résultat :

```text
Generated Prisma Client (7.8.0) to ./src/generated/prisma
```

```bash
cd api && npx prisma migrate status
```

Résultat :

```text
échec: Schema engine error sur PostgreSQL localhost:5432
```

TDD RED :

```bash
cd api && npm test -- activities --runInBand
```

Résultat :

```text
échec attendu avant implémentation: 2 suites failed, 5 tests failed
```

Validations finales :

```bash
cd api && npx prisma validate
```

Résultat :

```text
succès
```

```bash
cd api && npm run prisma:generate
```

Résultat :

```text
succès
```

```bash
cd api && npm test -- genkit-diagnostic-quiz --runInBand
```

Résultat :

```text
1 suite passed, 15 tests passed
```

```bash
cd api && npm test -- activities --runInBand
```

Résultat :

```text
5 suites passed, 38 tests passed
```

```bash
cd api && npm test -- ai --runInBand
```

Résultat :

```text
11 suites passed, 48 tests passed
```

```bash
cd api && npm test -- revision --runInBand
```

Résultat :

```text
8 suites passed, 30 tests passed
```

```bash
cd api && npm test -- documents --runInBand
```

Résultat :

```text
8 suites passed, 57 tests passed
```

```bash
cd api && npm run lint:check
```

Résultat :

```text
succès après corrections manuelles; aucun --fix lancé
```

```bash
cd api && npm run build
```

Résultat :

```text
succès
```

## 12. Validations non lancées

Non lancées :

- `npm run test:cov` : interdit par le prompt.
- `npm run lint` : non lancé pour éviter tout `--fix` automatique.
- `npm run format` : interdit par le prompt.
- `npx prisma migrate deploy` : interdit sans validation DB et non nécessaire à la création de migration.
- migration sur DB distante ou production : interdite.
- tests Flutter : aucun code Flutter modifié.
- provider IA réel : interdit.
- déploiement : interdit.

## 13. Migration / DB

Migrations existantes non appliquées localement via DB réelle :

- `20260614000000_document_chunks_sources`
- `20260614141000_summary_revision_sheet_artifacts`
- `20260614170000_qcm_v2_persistence_submission`

État runtime DB :

- non validé localement, car `npx prisma migrate status` échoue avec `Schema engine error`;
- la migration SQL a été créée par Prisma via `migrate diff`;
- aucune commande destructive n'a été lancée;
- aucune migration n'a été appliquée.

## 14. Compatibilité runtime

Compatibilité conservée :

- `POST /activities/next` reste disponible;
- `POST /activities/:sessionId/result` reste disponible;
- mode legacy conservé si aucun chunk sourcé n'est disponible;
- `StartNextActivityUseCase` n'impose pas un document sourcé pour tous les QCM;
- aucun DTO pré-submit ne fuit `correctChoiceId`;
- l'ancien modèle JSON `choices` reste utilisé.

Changement public volontaire :

- après soumission, le résultat contient désormais `score` et `items` de correction détaillée.

## 15. Corrections de chemins constatées

- `api/src/modules/activities/interfaces/activities.controller.spec.ts` n'existe pas dans l'arborescence actuelle.
- Les tests controller sont couverts par `api/src/modules/activities/activities.module.spec.ts`.

## 16. Passes de review

Passe Audit / Architecture :

- Verdict : le lot peut rester dans `activities`; importer `documents` aurait créé un couplage inutile.
- Décision : ajouter une méthode de contexte dans `ActivitiesRepository` plutôt qu'un nouveau repository transversal.

Passe Modèle de données :

- Verdict : `QuestionSource` + `QuestionAnswer` suffisent au MVP.
- Décision : ne pas créer `QuestionChoice`, `QuestionResult` séparé, `SourceReference`, `GeneratedArtifact` ou `AiGenerationJob`.

Passe Anti-fuite correction :

- Verdict : le pré-submit retire `correctChoiceId`, `explanation` et `feedback`.
- Point restant : les choix restent dans JSON interne; il faudra rester vigilant si un mapper public futur réutilise directement `choices`.

Passe Tests :

- Verdict : tests positifs, négatifs et non-régression ajoutés.
- Point restant : tests E2E DB réelle impossibles tant que PostgreSQL local n'est pas disponible.

Passe Build / Validation :

- Verdict : Prisma, tests ciblés, lint et build passent.
- Point restant : migrations non appliquées sur DB réelle.

Passe Critique finale :

- Verdict : scope respecté; pas de frontend, pas de Genkit, pas de migration appliquée.
- Point critique : `Question.subjectId` est optionnel pour compatibilité legacy; les questions v2 le renseignent toujours via repository.

## 17. Risques restants

- Migrations non validées sur une vraie DB locale.
- `Question.choices` reste JSON; la validation forte des choix est applicative, pas relationnelle.
- `Question.subjectId` reste optionnel pour compatibilité legacy.
- Le QCM v2 n'a pas encore de page Flutter dédiée.
- Le frontend actuel peut ne pas consommer toute la correction détaillée tant que `LOT-025` n'est pas fait.
- Les sources pré-submit restent volontairement minimales.
- Pas d'historique complet des tentatives.
- Pas de timer ou expiration de session.
- Le provider réel n'a pas été testé.

## 18. Recommandation prochain lot

Prochain lot recommandé :

```text
LOT-025 — UI QCM enrichi
```

Justification :

- Le backend sait maintenant persister et soumettre un QCM enrichi.
- Le DTO pré-submit reste protégé.
- Le DTO post-submit contient la correction utile.
- Le prochain bloc logique est l'adaptation Flutter pour afficher la soumission, la correction détaillée et les sources.

Alternative avant `LOT-025` :

- mini-lot DB/runtime si l'objectif prioritaire est de valider toutes les migrations sur PostgreSQL avant d'avancer UI.

## 19. Autocritique finale

- Le lot reste plus large qu'un micro-lot, car il touche Prisma, repository, use cases et tests.
- Le choix de conserver `choices` en JSON réduit la migration mais garde une validation relationnelle incomplète.
- La migration par diff est propre, mais moins rassurante qu'un `migrate dev --create-only` avec DB locale disponible.
- Les tests mock Prisma prouvent les appels et mappings, pas le comportement sur une vraie base.
- Le mapping public anti-fuite est couvert, mais il faudra le protéger encore dans `LOT-025` côté Flutter.

## 20. Regard critique sur le prompt

- Le prompt demandait de ne pas créer `QuestionChoice` sauf justification forte : cette contrainte est saine, mais elle impose d'accepter temporairement du JSON pour les choix.
- Le prompt autorisait une migration malgré une DB locale historiquement indisponible : la méthode par snapshot + `migrate diff` est la bonne alternative, mais elle doit rester une solution de secours.
- Le prompt mélange persistance et soumission en un seul lot; c'est faisable ici, mais cela augmente la taille des tests et du rapport.
- La demande de mise à jour de maîtrise reste partiellement couverte par l'existant; le lot ne crée pas encore de mastery event détaillé par question.
- Le prompt est strict sur la non-fuite, ce qui est nécessaire et non discutable pour un QCM.
