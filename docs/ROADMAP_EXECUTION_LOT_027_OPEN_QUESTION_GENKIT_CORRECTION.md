# LOT-027 — Genkit question ouverte et correction

## 1. Résultat

LOT-027 est réalisé côté backend. Le contrat question ouverte de LOT-026 est maintenant alimenté par deux ports applicatifs et deux adaptateurs Genkit mockables : génération de question ouverte sourcée et évaluation structurée de réponse ouverte. La soumission produit une évaluation `READY` quand la sortie IA est valide, ou `FAILED` contrôlé quand l’évaluateur rejette la sortie. Aucun flow Genkit QCM, aucun frontend Flutter, aucun GenUI, aucune migration et aucun Prisma schema n’ont été modifiés.

## 2. Sources inspectées

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
- `api/src/modules/revision/application/revision.repository.ts`
- `api/src/modules/revision/domain/mastery-state.entity.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`

## 3. Préflight Git / DB

API initial : `main`, clean, dernier commit `93dad71 #26-1: ajoute gestion des questions ouvertes et soumissions d'activités`.
Frontend initial : `main`, clean, dernier commit `a208a72 LOT_026_OPEN_QUESTION_CONTRACT - Mise à jour plan d'exécution et ajout rapport LOT_026 (Open Question Contract)`.
DB locale jetable : container Docker `revision-lot027-postgres`, base `revision_open_question_validation`, URL locale masquée `postgresql://revision:***@localhost:55433/revision_open_question_validation?schema=public`.
Migration LOT-026 validée sur DB vide avec toute la chaîne de 6 migrations ; aucun `migrate reset`, aucun `db push`, aucun environnement distant utilisé.

## 4. Périmètre réalisé

- Port `OpenQuestionGenerator` et adaptateur `GenkitOpenQuestionGenerator`.
- Port `OpenAnswerEvaluator` et adaptateur `GenkitOpenAnswerEvaluator`.
- Schémas Zod stricts pour question ouverte et évaluation.
- Sélection bornée des chunks par variables `OPEN_QUESTION_*` et `OPEN_ANSWER_*`.
- Validation stricte des `sourceChunkIds` contre les chunks fournis.
- Intégration dans `StartOpenQuestionActivityUseCase` et `SubmitOpenAnswerUseCase`.
- Persistance `READY` / `FAILED` via repository Prisma existant, sans migration.
- Mise à jour de maîtrise uniquement après évaluation `READY`.
- Observabilité metadata-only via `AiGenerationObserver`.

## 5. Décisions d’architecture

Les controllers restent minces. Les use cases orchestrent les ports applicatifs. Les adaptateurs Genkit restent dans l’infrastructure activities, car l’activité question ouverte dépend du modèle métier activity et des contextes de chunks. Les métadonnées IA sont persistées sur `ActivitySession` pour la génération et sur `OpenAnswerEvaluation` pour l’évaluation, sans prompt, completion, chunks complets ni réponse complète en logs d’observabilité.

## 6. Contrat API question ouverte

Endpoints inchangés depuis LOT-026 :

- `POST /activities/open-question` démarre une activité `open_question` avec une question générée par Genkit.
- `POST /activities/:sessionId/open-answer` soumet une réponse, lance l’évaluation Genkit et retourne une évaluation `READY` ou `FAILED`.

Le pré-submit n’expose toujours pas `answerText`, `modelAnswer`, score, feedback, points attendus, correction, texte complet des chunks ou payload GenUI.

## 7. Modèles Prisma ajoutés ou modifiés

Aucun modèle Prisma modifié dans LOT-027. Les modèles LOT-026 (`OpenQuestion`, `OpenQuestionSource`, `OpenAnswerEvaluation`) sont réutilisés. Aucune migration créée.

## 8. Migration créée et méthode de génération

Aucune migration créée. La migration LOT-026 existante a été appliquée sur PostgreSQL local jetable pour vérifier le runtime avant implémentation.

## 9. Use cases ajoutés ou modifiés

- `StartOpenQuestionActivityUseCase` appelle `OpenQuestionGenerator` avec la notion, le document éventuel et les chunks sourcés.
- `SubmitOpenAnswerUseCase` lit le contexte, appelle `OpenAnswerEvaluator`, persiste `READY`, met à jour la maîtrise avec le ratio `score/maxScore`, ou persiste `FAILED` sans maîtrise si l’évaluation échoue.
- `MasteryState.applyOpenAnswerRatio` applique la même pondération 65/35 que le QCM, à partir du ratio de correction ouverte.

## 10. Repository et adapter Prisma

Le repository expose maintenant `findOpenAnswerEvaluationContext` et `saveOpenAnswerEvaluation`. Le premier relit le contexte sourcé, le second sauvegarde l’évaluation. Les sources d’évaluation sont validées contre les chunks de la question ouverte ou de la notion, et les extraits textuels ne sont renvoyés qu’après soumission.

## 11. Stratégie Genkit

Deux adaptateurs Genkit ont été ajoutés :

- `openQuestionGeneration`, `promptVersion=open-question-generation-v1`, `schemaVersion=open-question-generation-v1`.
- `openAnswerEvaluation`, `promptVersion=open-answer-evaluation-v1`, `schemaVersion=open-answer-evaluation-v1`.

Les tests mockent Genkit. Aucun provider IA réel n’a été lancé.

## 12. Stratégie anti-fuite

- Pas de prompt complet persisté.
- Pas de completion complète persistée.
- Pas de chunks complets dans l’observabilité.
- Pas de réponse utilisateur complète dans l’observabilité.
- Pas de correction pré-submit.
- Sources libres non acceptées ; `sourceChunkIds` doivent pointer vers des chunks connus.
- Une sortie avec source inconnue reste invalide.

## 13. Ownership et statuts

Les requêtes repository filtrent par `studentId` et session. Le double submit reste bloqué si la session n’est plus `STARTED` ou si une `OpenAnswerEvaluation` existe. Les évaluations peuvent être `READY` ou `FAILED` dans LOT-027 ; `PENDING` reste dans le modèle pour compatibilité et traitements futurs.

## 14. Tests créés ou modifiés

- `api/src/modules/activities/application/start-open-question-activity.use-case.spec.ts`
- `api/src/modules/activities/application/submit-open-answer.use-case.spec.ts`
- `api/src/modules/activities/infrastructure/genkit-open-question.generator.spec.ts`
- `api/src/modules/activities/infrastructure/genkit-open-answer.evaluator.spec.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `api/src/modules/activities/activities.module.spec.ts`
- `api/src/modules/revision/domain/mastery-state.entity.spec.ts`

## 15. Validations lancées avec résultats

- `cd api && docker rm -f revision-lot027-postgres || true && docker run --name revision-lot027-postgres -e POSTGRES_USER=revision -e POSTGRES_PASSWORD=revision -e POSTGRES_DB=revision_open_question_validation -p 55433:5432 -d postgres:16-alpine` : OK, container PostgreSQL local jetable créé: revision-lot027-postgres.
- `cd api && DATABASE_URL='postgresql://revision:***@localhost:55433/revision_open_question_validation?schema=public' npx prisma migrate status` : Avant deploy: 6 migrations pending sur DB vide, exit 1 attendu pour une DB non migrée.
- `cd api && DATABASE_URL='postgresql://revision:***@localhost:55433/revision_open_question_validation?schema=public' npx prisma migrate deploy` : OK, 6 migrations appliquées sur DB locale jetable.
- `cd api && DATABASE_URL='postgresql://revision:***@localhost:55433/revision_open_question_validation?schema=public' npx prisma migrate status` : OK, Database schema is up to date.
- `cd api && npm test -- genkit-open-question --runInBand` : OK, 1 suite, 4 tests.
- `cd api && npm test -- genkit-open-answer --runInBand` : OK, 1 suite, 3 tests.
- `cd api && npm test -- start-open-question --runInBand` : OK, 1 suite, 2 tests.
- `cd api && npm test -- submit-open-answer --runInBand` : OK, 1 suite, 6 tests.
- `cd api && npm test -- prisma-activities --runInBand` : OK, 1 suite passée, 1 suite skipped, 19 tests passés, 1 skipped.
- `cd api && npm test -- activities.module --runInBand` : OK, 1 suite, 18 tests.
- `cd api && npm test -- mastery-state --runInBand` : OK, 1 suite, 5 tests.
- `cd api && npx prisma validate` : OK, schema valide.
- `cd api && npm run prisma:generate` : OK, Prisma Client généré.
- `cd api && npm test -- ai --runInBand` : OK, 11 suites, 54 tests.
- `cd api && npm test -- activities --runInBand` : OK, 9 suites passées, 1 skipped, 83 tests passés, 1 skipped.
- `cd api && npm run lint:check` : OK.
- `cd api && npm run build` : OK.
- `cd api && git diff --check` : OK.
- `cd revision_app && git diff --check` : OK.

## 16. Validations non lancées avec justification

- Tests Flutter : non lancés, aucun code Flutter applicatif ou test Flutter modifié.
- Migration production/staging : interdite et hors scope.
- Provider IA réel : interdit, tous les tests Genkit sont mockés.
- `npm run test:cov`, `npm run format`, `npm run lint` : explicitement interdits.

## 17. Risques restants

- Provider réel non testé : les prompts doivent être validés avec un modèle réel dans un environnement contrôlé.
- Pas de table dédiée aux sources d’évaluation ouverte : la réponse immédiate expose les sources validées, mais la persistance fine par source d’évaluation pourra nécessiter un futur lot.
- Qualité pédagogique dépendante du modèle et du contenu sourcé.
- UI Flutter question ouverte non réalisée.
- GenUI question ouverte non réalisée.
- Le container PostgreSQL local jetable reste présent pour vérification locale ; il peut être supprimé manuellement quand il n’est plus utile.

## 18. Recommandation prochain lot

Recommandation : `LOT-028 — UI question ouverte corrigée`, après un smoke test backend local des deux endpoints avec auth/test harness si nécessaire. Les composants GenUI question ouverte pourront venir après le fallback natif.

## 19. Passes de review

- Backend/API : endpoints conservés, nouvelles erreurs mappées en `422` quand sortie IA invalide.
- Modèle de données : aucune migration ; réutilisation LOT-026.
- Anti-fuite : observabilité metadata-only et DTO pré-submit inchangé.
- Genkit : schémas stricts, sources validées, provider mocké en tests.
- Repository : ownership, double submit, statut `READY/FAILED`, sources post-submit validées.
- Critique finale : le manque de persistance fine des sources d’évaluation est acceptable pour LOT-027 mais doit être surveillé si un historique de correction détaillée est ajouté.

## 20. Code complet créé/modifié/supprimé pour review

Le contenu complet des fichiers de code et configuration créés/modifiés est inclus ci-dessous. Le présent rapport n’est pas recopié dans lui-même pour éviter une récursion infinie ; son contenu complet est le fichier courant. Le plan d’exécution est un document de suivi, modifié uniquement sur la ligne LOT-027.

### Fichiers supprimés

Aucun fichier supprimé.

### Fichiers documentaires modifiés

- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md` : ligne LOT-027 mise à jour uniquement.

### `api/.env.example`

```env
DATABASE_URL="postgresql://revision:revision@localhost:5432/revision?schema=public"
REDIS_HOST="localhost"
REDIS_PORT="6379"
FIREBASE_PROJECT_ID="revision-app-1b799"
FIREBASE_SERVICE_ACCOUNT_JSON=""
DOCUMENT_STORAGE_ROOT="storage/revision-documents"
AI_PROVIDER="genkit"
GOOGLE_GENAI_API_KEY="local-dev-key"
GENKIT_MODEL="googleai/gemini-2.5-flash"
MISTRAL_API_KEY=""
MISTRAL_MODEL="mistral-small-latest"
MISTRAL_FALLBACK_MODEL=""
MISTRAL_SUMMARY_FALLBACK_MODEL=""
MISTRAL_REVISION_SHEET_FALLBACK_MODEL=""
MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL=""
DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT="10"
DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT="20"
OPEN_QUESTION_GENERATION_MAX_CHUNKS="8"
OPEN_QUESTION_GENERATION_MAX_CHARS="8000"
OPEN_ANSWER_EVALUATION_MAX_CHUNKS="10"
OPEN_ANSWER_EVALUATION_MAX_CHARS="10000"

```

### `api/src/modules/activities/application/open-question-generator.ts`

```ts
import type {
  DiagnosticQuizGenerationChunk,
  DiagnosticQuizGenerationKnowledgeUnit,
} from './diagnostic-quiz-generator';

export interface OpenQuestionGenerationMetadata {
  flowName: string;
  provider: string;
  model: string;
  promptVersion: string;
  schemaVersion: string;
  inputSize: number;
}

export interface OpenQuestionGenerationInput {
  studentId?: string;
  subjectId: string;
  documentId?: string | null;
  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit;
  chunks?: DiagnosticQuizGenerationChunk[];
}

export interface GeneratedOpenQuestion {
  version: 1;
  prompt: string;
  instructions: string | null;
  maxAnswerLength: number;
  sourceChunkIds: string[];
  metadata?: OpenQuestionGenerationMetadata;
}

export const OPEN_QUESTION_GENERATOR = Symbol('OPEN_QUESTION_GENERATOR');

export interface OpenQuestionGenerator {
  generate(input: OpenQuestionGenerationInput): Promise<GeneratedOpenQuestion>;
}

```

### `api/src/modules/activities/application/open-answer-evaluator.ts`

```ts
import type {
  DiagnosticQuizGenerationChunk,
  DiagnosticQuizGenerationKnowledgeUnit,
} from './diagnostic-quiz-generator';
import type { OpenQuestionGenerationMetadata } from './open-question-generator';

export interface OpenAnswerEvaluationQuestion {
  id: string;
  prompt: string;
  instructions: string | null;
  sourceChunkIds: string[];
}

export interface OpenAnswerEvaluationInput {
  studentId?: string;
  subjectId: string;
  documentId?: string | null;
  activitySessionId: string;
  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit;
  question: OpenAnswerEvaluationQuestion;
  answerText: string;
  chunks?: DiagnosticQuizGenerationChunk[];
}

export interface GeneratedOpenAnswerEvaluation {
  status: 'READY';
  score: number;
  maxScore: number;
  feedback: string;
  presentPoints: string[];
  missingPoints: string[];
  errors: string[];
  modelAnswer: string;
  advice: string;
  sourceChunkIds: string[];
  metadata?: OpenQuestionGenerationMetadata;
}

export const OPEN_ANSWER_EVALUATOR = Symbol('OPEN_ANSWER_EVALUATOR');

export interface OpenAnswerEvaluator {
  evaluate(
    input: OpenAnswerEvaluationInput,
  ): Promise<GeneratedOpenAnswerEvaluation>;
}

```

### `api/src/modules/activities/application/activities.repository.ts`

```ts
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

```

### `api/src/modules/activities/application/start-open-question-activity.use-case.ts`

```ts
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
import {
  OPEN_QUESTION_GENERATOR,
  type OpenQuestionGenerator,
} from './open-question-generator';

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
    @Inject(OPEN_QUESTION_GENERATOR)
    private readonly openQuestionGenerator: OpenQuestionGenerator,
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
    const generatedQuestion = await this.openQuestionGenerator.generate(
      generationContext
        ? {
            studentId: input.studentId,
            subjectId: input.subjectId,
            documentId: generationContext.documentId,
            knowledgeUnit: generationContext.knowledgeUnit,
            chunks: generationContext.chunks,
          }
        : {
            studentId: input.studentId,
            subjectId: input.subjectId,
            documentId: null,
            knowledgeUnit: Object.assign(knowledgeUnit, {
              sourceChunkIds: [],
            }),
            chunks: [],
          },
    );

    return this.activitiesRepository.createOpenQuestionActivity({
      studentId: input.studentId,
      subjectId: input.subjectId,
      knowledgeUnitId: knowledgeUnit.id,
      documentId: generationContext?.documentId ?? null,
      question: generatedQuestion,
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

```

### `api/src/modules/activities/application/start-open-question-activity.use-case.spec.ts`

```ts
import type { RevisionRepository } from '../../revision/application/revision.repository';
import { KnowledgeUnit } from '../../revision/domain/knowledge-unit.entity';
import type { ActivitiesRepository } from './activities.repository';
import type { OpenQuestionGenerator } from './open-question-generator';
import { StartOpenQuestionActivityUseCase } from './start-open-question-activity.use-case';

describe('StartOpenQuestionActivityUseCase', () => {
  it('creates an open question activity for an owned knowledge unit', async () => {
    const activitiesRepository = createActivitiesRepository();
    const revisionRepository = createRevisionRepository();
    const openQuestionGenerator = createOpenQuestionGenerator();
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
    openQuestionGenerator.generate.mockResolvedValue({
      version: 1,
      prompt:
        'Explique pourquoi la séparation des pouvoirs protège contre la concentration du pouvoir.',
      instructions:
        'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
      maxAnswerLength: 2500,
      sourceChunkIds: ['chunk-1'],
      metadata: {
        flowName: 'openQuestionGeneration',
        provider: 'google-genai',
        model: 'googleai/gemini-2.5-flash',
        promptVersion: 'open-question-generation-v1',
        schemaVersion: 'open-question-generation-v1',
        inputSize: 1200,
      },
    });
    activitiesRepository.createOpenQuestionActivity.mockResolvedValue(
      openQuestionActivity(),
    );

    const activity = await new StartOpenQuestionActivityUseCase(
      activitiesRepository,
      revisionRepository,
      openQuestionGenerator,
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
    expect(openQuestionGenerator.generate.mock.calls).toEqual([
      [
        {
          studentId: 'student-1',
          subjectId: 'subject-1',
          documentId: 'document-1',
          knowledgeUnit: {
            id: 'unit-1',
            subjectId: 'subject-1',
            title: 'Séparation des pouvoirs',
            summary:
              'La séparation des pouvoirs distingue les fonctions législative, exécutive et juridictionnelle.',
            difficulty: 'MEDIUM',
            sourceChunkIds: ['chunk-1'],
          },
          chunks: [
            {
              id: 'chunk-1',
              index: 0,
              text: 'La séparation des pouvoirs organise les fonctions de l’État.',
              pageNumber: null,
            },
          ],
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
              'Explique pourquoi la séparation des pouvoirs protège contre la concentration du pouvoir.',
            instructions:
              'Réponds en quelques phrases structurées, en t’appuyant uniquement sur le cours.',
            maxAnswerLength: 2500,
            sourceChunkIds: ['chunk-1'],
            version: 1,
            metadata: {
              flowName: 'openQuestionGeneration',
              provider: 'google-genai',
              model: 'googleai/gemini-2.5-flash',
              promptVersion: 'open-question-generation-v1',
              schemaVersion: 'open-question-generation-v1',
              inputSize: 1200,
            },
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
        createOpenQuestionGenerator(),
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
    findOpenAnswerEvaluationContext: jest.fn(),
    saveOpenAnswerEvaluation: jest.fn(),
  };
}

function createOpenQuestionGenerator(): jest.Mocked<OpenQuestionGenerator> {
  return {
    generate: jest.fn(),
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

```

### `api/src/modules/activities/application/submit-open-answer.use-case.ts`

```ts
import { Inject, Injectable, Optional } from '@nestjs/common';
import {
  ACTIVITIES_REPOSITORY,
  type ActivitiesRepository,
  type OpenAnswerSubmissionResult,
} from './activities.repository';
import { OPEN_QUESTION_MAX_ANSWER_LENGTH } from './start-open-question-activity.use-case';
import {
  REVISION_REPOSITORY,
  type RevisionRepository,
} from '../../revision/application/revision.repository';
import { MasteryState } from '../../revision/domain/mastery-state.entity';
import {
  OPEN_ANSWER_EVALUATOR,
  type OpenAnswerEvaluator,
} from './open-answer-evaluator';
import {
  ACTIVITY_CLOCK,
  type ActivityClock,
} from './submit-activity-result.use-case';

export const OPEN_ANSWER_MIN_LENGTH = 12;

@Injectable()
export class SubmitOpenAnswerUseCase {
  constructor(
    @Inject(ACTIVITIES_REPOSITORY)
    private readonly activitiesRepository: ActivitiesRepository,
    @Inject(OPEN_ANSWER_EVALUATOR)
    private readonly openAnswerEvaluator: OpenAnswerEvaluator,
    @Inject(REVISION_REPOSITORY)
    private readonly revisionRepository: RevisionRepository,
    @Optional()
    @Inject(ACTIVITY_CLOCK)
    private readonly now: ActivityClock = () => new Date(),
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

    const context =
      await this.activitiesRepository.findOpenAnswerEvaluationContext({
        studentId: input.studentId,
        sessionId: input.sessionId,
      });

    try {
      const evaluation = await this.openAnswerEvaluator.evaluate({
        studentId: input.studentId,
        subjectId: context.subjectId,
        documentId: context.documentId,
        activitySessionId: context.sessionId,
        knowledgeUnit: context.knowledgeUnit,
        question: context.question,
        answerText,
        chunks: context.chunks,
      });
      const result = await this.activitiesRepository.saveOpenAnswerEvaluation({
        studentId: input.studentId,
        sessionId: input.sessionId,
        answerText,
        evaluation,
      });
      await this.updateMastery({
        studentId: input.studentId,
        knowledgeUnitId: context.knowledgeUnit.id,
        score: evaluation.score,
        maxScore: evaluation.maxScore,
      });

      return result;
    } catch (error) {
      return this.activitiesRepository.saveOpenAnswerEvaluation({
        studentId: input.studentId,
        sessionId: input.sessionId,
        answerText,
        evaluation: {
          status: 'FAILED',
          errorCode: resolveOpenAnswerEvaluationErrorCode(error),
        },
      });
    }
  }

  private async updateMastery(input: {
    studentId: string;
    knowledgeUnitId: string;
    score: number;
    maxScore: number;
  }): Promise<void> {
    const ratio = input.maxScore === 0 ? 0 : input.score / input.maxScore;
    const practicedAt = this.now();
    const masteryStates = await this.revisionRepository.findMasteryStates(
      input.studentId,
    );
    const currentMastery =
      masteryStates.find(
        (masteryState) =>
          masteryState.knowledgeUnitId === input.knowledgeUnitId,
      ) ??
      new MasteryState({
        studentId: input.studentId,
        knowledgeUnitId: input.knowledgeUnitId,
        score: 0,
        lastPracticedAt: null,
      });
    const nextMastery = currentMastery.applyOpenAnswerRatio(ratio, practicedAt);

    await this.revisionRepository.upsertMastery({
      studentId: nextMastery.studentId,
      knowledgeUnitId: nextMastery.knowledgeUnitId,
      score: nextMastery.score,
      lastPracticedAt: nextMastery.lastPracticedAt ?? practicedAt,
    });
  }
}

function resolveOpenAnswerEvaluationErrorCode(error: unknown): string {
  if (error instanceof Error && error.message.trim().length > 0) {
    return error.message;
  }

  return 'OPEN_ANSWER_EVALUATION_FAILED';
}

```

### `api/src/modules/activities/application/submit-open-answer.use-case.spec.ts`

```ts
import type { ActivitiesRepository } from './activities.repository';
import type { OpenAnswerEvaluator } from './open-answer-evaluator';
import type { RevisionRepository } from '../../revision/application/revision.repository';
import { MasteryState } from '../../revision/domain/mastery-state.entity';
import { SubmitOpenAnswerUseCase } from './submit-open-answer.use-case';

describe('SubmitOpenAnswerUseCase', () => {
  it('evaluates a valid open answer, persists READY evaluation and updates mastery', async () => {
    const activitiesRepository = createActivitiesRepository();
    const openAnswerEvaluator = createOpenAnswerEvaluator();
    const revisionRepository = createRevisionRepository();
    const practicedAt = new Date('2026-06-14T10:00:00.000Z');
    activitiesRepository.findOpenAnswerEvaluationContext.mockResolvedValue(
      evaluationContext(),
    );
    openAnswerEvaluator.evaluate.mockResolvedValue(readyEvaluation());
    activitiesRepository.saveOpenAnswerEvaluation.mockResolvedValue(
      readyEvaluationResult(),
    );
    revisionRepository.findMasteryStates.mockResolvedValue([
      new MasteryState({
        studentId: 'student-1',
        knowledgeUnitId: 'unit-1',
        score: 0.4,
        lastPracticedAt: null,
      }),
    ]);

    const result = await new SubmitOpenAnswerUseCase(
      activitiesRepository,
      openAnswerEvaluator,
      revisionRepository,
      () => practicedAt,
    ).execute({
      studentId: 'student-1',
      sessionId: 'session-1',
      answerText:
        'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
    });

    expect(
      activitiesRepository.findOpenAnswerEvaluationContext.mock.calls,
    ).toEqual([
      [
        {
          studentId: 'student-1',
          sessionId: 'session-1',
        },
      ],
    ]);
    expect(openAnswerEvaluator.evaluate.mock.calls).toEqual([
      [
        {
          studentId: 'student-1',
          subjectId: 'subject-1',
          documentId: 'document-1',
          activitySessionId: 'session-1',
          knowledgeUnit: evaluationContext().knowledgeUnit,
          question: evaluationContext().question,
          answerText:
            'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
          chunks: evaluationContext().chunks,
        },
      ],
    ]);
    expect(activitiesRepository.saveOpenAnswerEvaluation.mock.calls).toEqual([
      [
        {
          studentId: 'student-1',
          sessionId: 'session-1',
          answerText:
            'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
          evaluation: readyEvaluation(),
        },
      ],
    ]);
    expect(revisionRepository.upsertMastery.mock.calls).toEqual([
      [
        {
          studentId: 'student-1',
          knowledgeUnitId: 'unit-1',
          score: 0.54,
          lastPracticedAt: practicedAt,
        },
      ],
    ]);
    expect(result).toEqual(readyEvaluationResult());
  });

  it('persists FAILED evaluation without updating mastery when the evaluator fails', async () => {
    const activitiesRepository = createActivitiesRepository();
    const openAnswerEvaluator = createOpenAnswerEvaluator();
    const revisionRepository = createRevisionRepository();
    activitiesRepository.findOpenAnswerEvaluationContext.mockResolvedValue(
      evaluationContext(),
    );
    openAnswerEvaluator.evaluate.mockRejectedValue(
      new Error('OPEN_ANSWER_EVALUATION_SOURCE_INVALID'),
    );
    activitiesRepository.saveOpenAnswerEvaluation.mockResolvedValue(
      failedEvaluationResult(),
    );

    const result = await new SubmitOpenAnswerUseCase(
      activitiesRepository,
      openAnswerEvaluator,
      revisionRepository,
    ).execute({
      studentId: 'student-1',
      sessionId: 'session-1',
      answerText:
        'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
    });

    expect(activitiesRepository.saveOpenAnswerEvaluation.mock.calls).toEqual([
      [
        {
          studentId: 'student-1',
          sessionId: 'session-1',
          answerText:
            'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
          evaluation: {
            status: 'FAILED',
            errorCode: 'OPEN_ANSWER_EVALUATION_SOURCE_INVALID',
          },
        },
      ],
    ]);
    expect(revisionRepository.upsertMastery.mock.calls).toHaveLength(0);
    expect(result).toEqual(failedEvaluationResult());
  });

  it.each([
    ['empty', ''],
    ['blank', '     '],
    ['too short', 'trop court'],
  ])('rejects %s answers', async (_label, answerText) => {
    const activitiesRepository = createActivitiesRepository();

    await expect(
      new SubmitOpenAnswerUseCase(
        activitiesRepository,
        createOpenAnswerEvaluator(),
        createRevisionRepository(),
      ).execute({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText,
      }),
    ).rejects.toThrow('Open answer is too short');

    expect(
      activitiesRepository.saveOpenAnswerEvaluation.mock.calls,
    ).toHaveLength(0);
  });

  it('rejects answers longer than the contract limit', async () => {
    const activitiesRepository = createActivitiesRepository();

    await expect(
      new SubmitOpenAnswerUseCase(
        activitiesRepository,
        createOpenAnswerEvaluator(),
        createRevisionRepository(),
      ).execute({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText: 'a'.repeat(4001),
      }),
    ).rejects.toThrow('Open answer is too long');

    expect(
      activitiesRepository.saveOpenAnswerEvaluation.mock.calls,
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
    findOpenAnswerEvaluationContext: jest.fn(),
    saveOpenAnswerEvaluation: jest.fn(),
  };
}

function createOpenAnswerEvaluator(): jest.Mocked<OpenAnswerEvaluator> {
  return {
    evaluate: jest.fn(),
  };
}

function createRevisionRepository(): jest.Mocked<RevisionRepository> {
  return {
    getActiveGoal: jest.fn(),
    saveGoal: jest.fn(),
    findKnowledgeUnits: jest.fn(),
    findMasteryStates: jest.fn().mockResolvedValue([]),
    upsertMastery: jest.fn(),
  };
}

function evaluationContext() {
  return {
    sessionId: 'session-1',
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnit: {
      id: 'unit-1',
      subjectId: 'subject-1',
      title: 'Séparation des pouvoirs',
      summary: 'Résumé.',
      sourceChunkIds: ['chunk-1'],
    },
    question: {
      id: 'open-question-1',
      prompt: 'Explique la notion.',
      instructions: 'Réponds avec le cours.',
      sourceChunkIds: ['chunk-1'],
    },
    chunks: [
      {
        id: 'chunk-1',
        index: 0,
        text: 'La séparation des pouvoirs organise les fonctions de l’État.',
        pageNumber: null,
      },
    ],
  };
}

function readyEvaluation() {
  return {
    status: 'READY' as const,
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
  };
}

function readyEvaluationResult() {
  return {
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
          text: 'La séparation des pouvoirs organise les fonctions de l’État.',
          pageNumber: null,
          index: 0,
        },
      ],
    },
  };
}

function failedEvaluationResult() {
  return {
    sessionId: 'session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: {
      id: 'evaluation-1',
      status: 'FAILED',
      score: null,
      maxScore: null,
      feedback: null,
      presentPoints: [],
      missingPoints: [],
      errors: ['OPEN_ANSWER_EVALUATION_SOURCE_INVALID'],
      modelAnswer: null,
      advice: null,
      sources: [],
    },
  };
}

```

### `api/src/modules/activities/infrastructure/genkit-open-question.generator.ts`

```ts
import { Inject, Injectable } from '@nestjs/common';
import { genkit, z } from 'genkit';
import {
  AI_GENERATION_OBSERVER,
  type AiGenerationObserver,
  noopAiGenerationObserver,
} from '../../ai/application/ai-generation-observer';
import {
  resolveArtifactGenkitConfig,
  resolveArtifactGenkitMetadata,
  type ResolvedArtifactGenkitMetadata,
} from '../../ai/infrastructure/document-artifact-genkit-config';
import type {
  DiagnosticQuizGenerationChunk,
  DiagnosticQuizGenerationKnowledgeUnit,
} from '../application/diagnostic-quiz-generator';
import {
  type GeneratedOpenQuestion,
  type OpenQuestionGenerationInput,
  type OpenQuestionGenerator,
} from '../application/open-question-generator';
import { OPEN_QUESTION_MAX_ANSWER_LENGTH } from '../application/start-open-question-activity.use-case';

const FLOW_NAME = 'openQuestionGeneration';
const PROMPT_VERSION = 'open-question-generation-v1';
const SCHEMA_VERSION = 'open-question-generation-v1';
const SOURCE_INVALID_ERROR_CODE = 'OPEN_QUESTION_SOURCE_INVALID';
const EMPTY_OUTPUT_ERROR_CODE = 'OPEN_QUESTION_EMPTY_OUTPUT';
const DEFAULT_MAX_CHUNKS = 8;
const DEFAULT_MAX_CHARS = 8000;
const MIN_OPEN_QUESTION_MAX_ANSWER_LENGTH = 500;

const NonEmptyStringSchema = z.string().trim().min(1);

const GeneratedOpenQuestionSchema = z
  .object({
    prompt: z.string().trim().min(8).max(700),
    instructions: z.string().trim().min(8).max(500).nullable(),
    maxAnswerLength: z
      .number()
      .int()
      .min(MIN_OPEN_QUESTION_MAX_ANSWER_LENGTH)
      .max(OPEN_QUESTION_MAX_ANSWER_LENGTH),
    sourceChunkIds: z.array(NonEmptyStringSchema).max(8),
  })
  .strict();

type SelectedOpenQuestionChunk = DiagnosticQuizGenerationChunk & {
  text: string;
};

@Injectable()
export class GenkitOpenQuestionGenerator implements OpenQuestionGenerator {
  private readonly aiByModel = new Map<string, ReturnType<typeof genkit>>();
  private resolvedMetadata?: ResolvedArtifactGenkitMetadata;

  constructor(
    @Inject(AI_GENERATION_OBSERVER)
    private readonly observer: AiGenerationObserver = noopAiGenerationObserver,
  ) {}

  async generate(
    input: OpenQuestionGenerationInput,
  ): Promise<GeneratedOpenQuestion> {
    const metadata = this.resolveMetadata();
    const chunks = selectChunks({
      chunks: input.chunks ?? [],
      sourceChunkIds: input.knowledgeUnit.sourceChunkIds ?? [],
      maxChunksEnv: process.env.OPEN_QUESTION_GENERATION_MAX_CHUNKS,
      maxCharsEnv: process.env.OPEN_QUESTION_GENERATION_MAX_CHARS,
    });
    const prompt = buildOpenQuestionPrompt(input, chunks);
    const inputSize = prompt.length;
    const startedAt = Date.now();

    try {
      const { output } = await this.getAi(metadata).generate({
        prompt,
        output: {
          schema: GeneratedOpenQuestionSchema,
        },
      });

      if (!output) {
        throw new Error(EMPTY_OUTPUT_ERROR_CODE);
      }

      const parsed = GeneratedOpenQuestionSchema.parse(output);
      const sourceChunkIds = normalizeSourceChunkIds(
        parsed.sourceChunkIds,
        chunks,
        SOURCE_INVALID_ERROR_CODE,
      );
      const question: GeneratedOpenQuestion = {
        version: 1,
        prompt: parsed.prompt,
        instructions: parsed.instructions,
        maxAnswerLength: parsed.maxAnswerLength,
        sourceChunkIds,
        metadata: {
          flowName: FLOW_NAME,
          provider: metadata.provider,
          model: metadata.model,
          promptVersion: PROMPT_VERSION,
          schemaVersion: SCHEMA_VERSION,
          inputSize,
        },
      };

      this.observer.observe({
        flowName: FLOW_NAME,
        provider: metadata.provider,
        model: metadata.model,
        promptVersion: PROMPT_VERSION,
        schemaVersion: SCHEMA_VERSION,
        inputSize,
        durationMs: Date.now() - startedAt,
        status: 'success',
        documentId: input.documentId ?? undefined,
        subjectId: input.subjectId,
        knowledgeUnitId: input.knowledgeUnit.id,
        studentId: input.studentId,
      });

      return question;
    } catch (error) {
      this.observer.observe({
        flowName: FLOW_NAME,
        provider: metadata.provider,
        model: metadata.model,
        promptVersion: PROMPT_VERSION,
        schemaVersion: SCHEMA_VERSION,
        inputSize,
        durationMs: Date.now() - startedAt,
        status: 'error',
        errorCode: resolveOpenQuestionErrorCode(error),
        documentId: input.documentId ?? undefined,
        subjectId: input.subjectId,
        knowledgeUnitId: input.knowledgeUnit.id,
        studentId: input.studentId,
      });

      throw error;
    }
  }

  private getAi(
    metadata: ResolvedArtifactGenkitMetadata,
  ): ReturnType<typeof genkit> {
    const cacheKey = `${metadata.provider}:${metadata.model}`;
    const existingAi = this.aiByModel.get(cacheKey);

    if (existingAi) {
      return existingAi;
    }

    const ai = genkit(resolveArtifactGenkitConfig(metadata).config);
    this.aiByModel.set(cacheKey, ai);

    return ai;
  }

  private resolveMetadata(): ResolvedArtifactGenkitMetadata {
    this.resolvedMetadata ??= resolveArtifactGenkitMetadata();
    return this.resolvedMetadata;
  }
}

function buildOpenQuestionPrompt(
  input: OpenQuestionGenerationInput,
  chunks: SelectedOpenQuestionChunk[],
): string {
  const payload = {
    subjectId: input.subjectId,
    documentId: input.documentId ?? null,
    knowledgeUnit: toKnowledgeUnitPayload(input.knowledgeUnit),
    chunks: chunks.map((chunk) => ({
      id: chunk.id,
      index: chunk.index,
      pageNumber: chunk.pageNumber ?? null,
      text: chunk.text,
    })),
  };

  return [
    'Tu es un tuteur universitaire qui prépare une question ouverte de révision en français.',
    'Crée une seule question ouverte exigeant une réponse structurée, explicative et sourcée.',
    'La question doit évaluer la compréhension, l’argumentation ou l’application de la notion, pas une simple définition.',
    'N’utilise que la notion et les chunks fournis. N’ajoute aucune connaissance externe.',
    'Retourne uniquement du JSON strict avec prompt, instructions, maxAnswerLength et sourceChunkIds.',
    chunks.length > 0
      ? 'sourceChunkIds doit contenir au moins un ID exact parmi les chunks fournis.'
      : 'Aucun chunk vérifiable n’est fourni: sourceChunkIds doit être vide.',
    JSON.stringify(payload),
  ].join('\n\n');
}

function toKnowledgeUnitPayload(
  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit,
) {
  return {
    id: knowledgeUnit.id,
    subjectId: knowledgeUnit.subjectId,
    title: knowledgeUnit.title,
    summary: knowledgeUnit.summary,
    difficulty: knowledgeUnit.difficulty ?? null,
    sourceChunkIds: knowledgeUnit.sourceChunkIds ?? [],
  };
}

function selectChunks(input: {
  chunks: DiagnosticQuizGenerationChunk[];
  sourceChunkIds: string[];
  maxChunksEnv: string | undefined;
  maxCharsEnv: string | undefined;
}): SelectedOpenQuestionChunk[] {
  const chunks = deduplicateChunks(input.chunks);
  const sourceChunkIds = new Set(input.sourceChunkIds);
  const prioritizedChunks = [
    ...chunks.filter((chunk) => sourceChunkIds.has(chunk.id)),
    ...chunks.filter((chunk) => !sourceChunkIds.has(chunk.id)),
  ];
  const maxChunks = resolvePositiveInteger(
    input.maxChunksEnv,
    DEFAULT_MAX_CHUNKS,
  );
  const maxChars = resolvePositiveInteger(input.maxCharsEnv, DEFAULT_MAX_CHARS);
  let remainingChars = maxChars;

  return prioritizedChunks.slice(0, maxChunks).flatMap((chunk) => {
    if (remainingChars <= 0) {
      return [];
    }

    const text = chunk.text.slice(0, remainingChars);
    remainingChars -= text.length;

    if (text.trim().length === 0) {
      return [];
    }

    return [{ ...chunk, text }];
  });
}

function deduplicateChunks(
  chunks: DiagnosticQuizGenerationChunk[],
): SelectedOpenQuestionChunk[] {
  const chunksById = new Map<string, DiagnosticQuizGenerationChunk>();

  for (const chunk of chunks) {
    if (chunk.text.trim().length > 0 && !chunksById.has(chunk.id)) {
      chunksById.set(chunk.id, chunk);
    }
  }

  return [...chunksById.values()].sort(
    (left, right) => left.index - right.index,
  );
}

function normalizeSourceChunkIds(
  sourceChunkIds: string[],
  chunks: SelectedOpenQuestionChunk[],
  errorCode: string,
): string[] {
  if (chunks.length === 0) {
    if (sourceChunkIds.length > 0) {
      throw new Error(errorCode);
    }

    return [];
  }

  const knownChunkIds = new Set(chunks.map((chunk) => chunk.id));
  const normalized = [...new Set(sourceChunkIds)];

  if (
    normalized.length === 0 ||
    normalized.some((chunkId) => !knownChunkIds.has(chunkId))
  ) {
    throw new Error(errorCode);
  }

  return normalized;
}

function resolvePositiveInteger(value: string | undefined, fallback: number) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    return fallback;
  }

  return parsed;
}

function resolveOpenQuestionErrorCode(error: unknown): string {
  if (error instanceof Error && error.message === SOURCE_INVALID_ERROR_CODE) {
    return SOURCE_INVALID_ERROR_CODE;
  }

  if (error instanceof Error && error.message === EMPTY_OUTPUT_ERROR_CODE) {
    return EMPTY_OUTPUT_ERROR_CODE;
  }

  return 'OPEN_QUESTION_GENERATION_INVALID';
}

```

### `api/src/modules/activities/infrastructure/genkit-open-question.generator.spec.ts`

```ts
type GenerateInput = {
  prompt: string;
  output: {
    schema: unknown;
  };
};

type GenerateResult = {
  output?: {
    prompt?: string;
    instructions?: string;
    maxAnswerLength?: number;
    sourceChunkIds?: string[];
    unexpected?: string;
  };
};

type GenkitInput = {
  plugins: unknown[];
  model: string;
};

const mockGooglePlugin = { name: 'google-plugin' };
const mockGenerate = jest.fn<Promise<GenerateResult>, [GenerateInput]>();
const mockGenkit = jest.fn<{ generate: typeof mockGenerate }, [GenkitInput]>(
  () => ({ generate: mockGenerate }),
);
const mockGoogleAI = jest.fn<unknown, []>(() => mockGooglePlugin);

jest.mock('genkit', () => ({
  ...jest.requireActual<typeof import('genkit')>('genkit'),
  genkit: mockGenkit,
}));

jest.mock('@genkit-ai/google-genai', () => ({
  googleAI: mockGoogleAI,
}));

import type {
  AiGenerationObservation,
  AiGenerationObserver,
} from '../../ai/application/ai-generation-observer';
import { GenkitOpenQuestionGenerator } from './genkit-open-question.generator';

describe('GenkitOpenQuestionGenerator', () => {
  const originalAiProvider = process.env.AI_PROVIDER;
  const originalGenkitModel = process.env.GENKIT_MODEL;
  const originalMaxChunks = process.env.OPEN_QUESTION_GENERATION_MAX_CHUNKS;
  const originalMaxChars = process.env.OPEN_QUESTION_GENERATION_MAX_CHARS;

  afterEach(() => {
    restoreEnv('AI_PROVIDER', originalAiProvider);
    restoreEnv('GENKIT_MODEL', originalGenkitModel);
    restoreEnv('OPEN_QUESTION_GENERATION_MAX_CHUNKS', originalMaxChunks);
    restoreEnv('OPEN_QUESTION_GENERATION_MAX_CHARS', originalMaxChars);
    mockGoogleAI.mockClear();
    mockGenkit.mockClear();
    mockGenerate.mockReset();
  });

  it('generates a sourced open question and observes metadata only', async () => {
    process.env.AI_PROVIDER = 'google';
    mockGenerate.mockResolvedValue({
      output: {
        prompt:
          'Explique pourquoi la séparation des pouvoirs limite la concentration du pouvoir.',
        instructions:
          'Réponds en trois paragraphes courts en justifiant avec le cours.',
        maxAnswerLength: 2200,
        sourceChunkIds: ['chunk-1', 'chunk-1'],
      },
    });
    const observer = createObserver();

    const question = await new GenkitOpenQuestionGenerator(observer).generate({
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnit: {
        id: 'unit-1',
        subjectId: 'subject-1',
        title: 'Séparation des pouvoirs',
        summary: 'La notion distingue les fonctions étatiques.',
        difficulty: 'MEDIUM',
        sourceChunkIds: ['chunk-1'],
      },
      chunks: [
        {
          id: 'chunk-1',
          index: 0,
          text: 'SENTINEL_FULL_CHUNK_TEXT',
          pageNumber: null,
        },
      ],
    });

    expect(question).toMatchObject({
      version: 1,
      prompt:
        'Explique pourquoi la séparation des pouvoirs limite la concentration du pouvoir.',
      instructions:
        'Réponds en trois paragraphes courts en justifiant avec le cours.',
      maxAnswerLength: 2200,
      sourceChunkIds: ['chunk-1'],
      metadata: {
        flowName: 'openQuestionGeneration',
        provider: 'google-genai',
        model: 'googleai/gemini-2.5-flash',
        promptVersion: 'open-question-generation-v1',
        schemaVersion: 'open-question-generation-v1',
      },
    });
    const [generateInput] = mockGenerate.mock.calls[0] ?? [];
    expect(generateInput?.prompt).toContain('SENTINEL_FULL_CHUNK_TEXT');
    expect(generateInput?.prompt).toContain('Séparation des pouvoirs');
    expect(generateInput?.output.schema).toBeDefined();
    const observation = getObservedObservation(observer);
    expect(observation).toMatchObject({
      flowName: 'openQuestionGeneration',
      provider: 'google-genai',
      model: 'googleai/gemini-2.5-flash',
      promptVersion: 'open-question-generation-v1',
      schemaVersion: 'open-question-generation-v1',
      status: 'success',
      documentId: 'document-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
    });
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'SENTINEL_FULL_CHUNK_TEXT',
    );
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'limite la concentration',
    );
  });

  it('rejects unknown open question sources and observes an error', async () => {
    process.env.AI_PROVIDER = 'google';
    mockGenerate.mockResolvedValue({
      output: {
        prompt: 'Explique la notion avec le cours.',
        instructions: 'Réponds brièvement.',
        maxAnswerLength: 1000,
        sourceChunkIds: ['chunk-unknown'],
      },
    });
    const observer = createObserver();

    await expect(
      new GenkitOpenQuestionGenerator(observer).generate({
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnit: {
          id: 'unit-1',
          subjectId: 'subject-1',
          title: 'Séparation des pouvoirs',
          summary: 'Résumé.',
          sourceChunkIds: ['chunk-1'],
        },
        chunks: [
          {
            id: 'chunk-1',
            index: 0,
            text: 'SENTINEL_FULL_CHUNK_TEXT',
            pageNumber: null,
          },
        ],
      }),
    ).rejects.toThrow('OPEN_QUESTION_SOURCE_INVALID');

    const observation = getObservedObservation(observer);
    expect(observation.status).toBe('error');
    expect(observation.errorCode).toBe('OPEN_QUESTION_SOURCE_INVALID');
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'SENTINEL_FULL_CHUNK_TEXT',
    );
  });

  it('rejects unknown fields from open question output', async () => {
    process.env.AI_PROVIDER = 'google';
    mockGenerate.mockResolvedValue({
      output: {
        prompt: 'Explique la notion avec le cours.',
        instructions: 'Réponds brièvement.',
        maxAnswerLength: 1000,
        sourceChunkIds: ['chunk-1'],
        unexpected: 'forbidden',
      },
    });

    await expect(
      new GenkitOpenQuestionGenerator().generate({
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnit: {
          id: 'unit-1',
          subjectId: 'subject-1',
          title: 'Séparation des pouvoirs',
          summary: 'Résumé.',
          sourceChunkIds: ['chunk-1'],
        },
        chunks: [
          {
            id: 'chunk-1',
            index: 0,
            text: 'Texte source.',
            pageNumber: null,
          },
        ],
      }),
    ).rejects.toThrow();
  });

  it('limits open question generation chunks by configured count and chars', async () => {
    process.env.AI_PROVIDER = 'google';
    process.env.OPEN_QUESTION_GENERATION_MAX_CHUNKS = '1';
    process.env.OPEN_QUESTION_GENERATION_MAX_CHARS = '8';
    mockGenerate.mockResolvedValue({
      output: {
        prompt: 'Explique la notion avec le cours.',
        instructions: 'Réponds brièvement.',
        maxAnswerLength: 1000,
        sourceChunkIds: ['chunk-1'],
      },
    });

    await new GenkitOpenQuestionGenerator().generate({
      subjectId: 'subject-1',
      documentId: 'document-1',
      knowledgeUnit: {
        id: 'unit-1',
        subjectId: 'subject-1',
        title: 'Séparation des pouvoirs',
        summary: 'Résumé.',
        sourceChunkIds: ['chunk-1', 'chunk-2'],
      },
      chunks: [
        { id: 'chunk-2', index: 1, text: 'SECOND_SENTINEL', pageNumber: null },
        { id: 'chunk-1', index: 0, text: '1234567890', pageNumber: null },
      ],
    });

    const [generateInput] = mockGenerate.mock.calls[0] ?? [];
    expect(generateInput?.prompt).toContain('12345678');
    expect(generateInput?.prompt).not.toContain('90');
    expect(generateInput?.prompt).not.toContain('SECOND_SENTINEL');
  });
});

function createObserver(): jest.Mocked<AiGenerationObserver> {
  return {
    observe: jest.fn(),
  };
}

function getObservedObservation(
  observer: jest.Mocked<AiGenerationObserver>,
): AiGenerationObservation {
  const [[observation]] = observer.observe.mock.calls;

  if (!observation) {
    throw new Error('Expected observation');
  }

  return observation;
}

function restoreEnv(key: string, value: string | undefined): void {
  if (value === undefined) {
    delete process.env[key];
    return;
  }

  process.env[key] = value;
}

```

### `api/src/modules/activities/infrastructure/genkit-open-answer.evaluator.ts`

```ts
import { Inject, Injectable } from '@nestjs/common';
import { genkit, z } from 'genkit';
import {
  AI_GENERATION_OBSERVER,
  type AiGenerationObserver,
  noopAiGenerationObserver,
} from '../../ai/application/ai-generation-observer';
import {
  resolveArtifactGenkitConfig,
  resolveArtifactGenkitMetadata,
  type ResolvedArtifactGenkitMetadata,
} from '../../ai/infrastructure/document-artifact-genkit-config';
import type { DiagnosticQuizGenerationChunk } from '../application/diagnostic-quiz-generator';
import {
  type GeneratedOpenAnswerEvaluation,
  type OpenAnswerEvaluationInput,
  type OpenAnswerEvaluator,
} from '../application/open-answer-evaluator';

const FLOW_NAME = 'openAnswerEvaluation';
const PROMPT_VERSION = 'open-answer-evaluation-v1';
const SCHEMA_VERSION = 'open-answer-evaluation-v1';
const SOURCE_INVALID_ERROR_CODE = 'OPEN_ANSWER_EVALUATION_SOURCE_INVALID';
const EMPTY_OUTPUT_ERROR_CODE = 'OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT';
const DEFAULT_MAX_CHUNKS = 10;
const DEFAULT_MAX_CHARS = 10000;
const MAX_EVALUATION_SCORE = 20;

const NonEmptyStringSchema = z.string().trim().min(1);

const GeneratedOpenAnswerEvaluationSchema = z
  .object({
    score: z.number().min(0).max(MAX_EVALUATION_SCORE),
    maxScore: z.number().min(1).max(MAX_EVALUATION_SCORE),
    feedback: z.string().trim().min(8).max(1200),
    presentPoints: z.array(NonEmptyStringSchema.max(240)).max(8),
    missingPoints: z.array(NonEmptyStringSchema.max(240)).max(8),
    errors: z.array(NonEmptyStringSchema.max(240)).max(8),
    modelAnswer: z.string().trim().min(8).max(1200),
    advice: z.string().trim().min(4).max(600),
    sourceChunkIds: z.array(NonEmptyStringSchema).max(8),
  })
  .strict()
  .refine((output) => output.score <= output.maxScore, {
    message: 'Open answer score must be lower than maxScore',
  });

type SelectedOpenAnswerChunk = DiagnosticQuizGenerationChunk & {
  text: string;
};

@Injectable()
export class GenkitOpenAnswerEvaluator implements OpenAnswerEvaluator {
  private readonly aiByModel = new Map<string, ReturnType<typeof genkit>>();
  private resolvedMetadata?: ResolvedArtifactGenkitMetadata;

  constructor(
    @Inject(AI_GENERATION_OBSERVER)
    private readonly observer: AiGenerationObserver = noopAiGenerationObserver,
  ) {}

  async evaluate(
    input: OpenAnswerEvaluationInput,
  ): Promise<GeneratedOpenAnswerEvaluation> {
    const metadata = this.resolveMetadata();
    const chunks = selectChunks({
      chunks: input.chunks ?? [],
      sourceChunkIds: input.question.sourceChunkIds,
      maxChunksEnv: process.env.OPEN_ANSWER_EVALUATION_MAX_CHUNKS,
      maxCharsEnv: process.env.OPEN_ANSWER_EVALUATION_MAX_CHARS,
    });
    const prompt = buildOpenAnswerEvaluationPrompt(input, chunks);
    const inputSize = prompt.length;
    const startedAt = Date.now();

    try {
      const { output } = await this.getAi(metadata).generate({
        prompt,
        output: {
          schema: GeneratedOpenAnswerEvaluationSchema,
        },
      });

      if (!output) {
        throw new Error(EMPTY_OUTPUT_ERROR_CODE);
      }

      const parsed = GeneratedOpenAnswerEvaluationSchema.parse(output);
      const sourceChunkIds = normalizeSourceChunkIds(
        parsed.sourceChunkIds,
        chunks,
        SOURCE_INVALID_ERROR_CODE,
      );
      const evaluation: GeneratedOpenAnswerEvaluation = {
        status: 'READY',
        score: parsed.score,
        maxScore: parsed.maxScore,
        feedback: parsed.feedback,
        presentPoints: parsed.presentPoints,
        missingPoints: parsed.missingPoints,
        errors: parsed.errors,
        modelAnswer: parsed.modelAnswer,
        advice: parsed.advice,
        sourceChunkIds,
        metadata: {
          flowName: FLOW_NAME,
          provider: metadata.provider,
          model: metadata.model,
          promptVersion: PROMPT_VERSION,
          schemaVersion: SCHEMA_VERSION,
          inputSize,
        },
      };

      this.observer.observe({
        flowName: FLOW_NAME,
        provider: metadata.provider,
        model: metadata.model,
        promptVersion: PROMPT_VERSION,
        schemaVersion: SCHEMA_VERSION,
        inputSize,
        durationMs: Date.now() - startedAt,
        status: 'success',
        documentId: input.documentId ?? undefined,
        subjectId: input.subjectId,
        knowledgeUnitId: input.knowledgeUnit.id,
        activitySessionId: input.activitySessionId,
        studentId: input.studentId,
      });

      return evaluation;
    } catch (error) {
      this.observer.observe({
        flowName: FLOW_NAME,
        provider: metadata.provider,
        model: metadata.model,
        promptVersion: PROMPT_VERSION,
        schemaVersion: SCHEMA_VERSION,
        inputSize,
        durationMs: Date.now() - startedAt,
        status: 'error',
        errorCode: resolveOpenAnswerEvaluationErrorCode(error),
        documentId: input.documentId ?? undefined,
        subjectId: input.subjectId,
        knowledgeUnitId: input.knowledgeUnit.id,
        activitySessionId: input.activitySessionId,
        studentId: input.studentId,
      });

      throw error;
    }
  }

  private getAi(
    metadata: ResolvedArtifactGenkitMetadata,
  ): ReturnType<typeof genkit> {
    const cacheKey = `${metadata.provider}:${metadata.model}`;
    const existingAi = this.aiByModel.get(cacheKey);

    if (existingAi) {
      return existingAi;
    }

    const ai = genkit(resolveArtifactGenkitConfig(metadata).config);
    this.aiByModel.set(cacheKey, ai);

    return ai;
  }

  private resolveMetadata(): ResolvedArtifactGenkitMetadata {
    this.resolvedMetadata ??= resolveArtifactGenkitMetadata();
    return this.resolvedMetadata;
  }
}

function buildOpenAnswerEvaluationPrompt(
  input: OpenAnswerEvaluationInput,
  chunks: SelectedOpenAnswerChunk[],
): string {
  const payload = {
    subjectId: input.subjectId,
    documentId: input.documentId ?? null,
    activitySessionId: input.activitySessionId,
    knowledgeUnit: {
      id: input.knowledgeUnit.id,
      title: input.knowledgeUnit.title,
      summary: input.knowledgeUnit.summary,
      sourceChunkIds: input.knowledgeUnit.sourceChunkIds ?? [],
    },
    question: input.question,
    answerText: input.answerText,
    chunks: chunks.map((chunk) => ({
      id: chunk.id,
      index: chunk.index,
      pageNumber: chunk.pageNumber ?? null,
      text: chunk.text,
    })),
  };

  return [
    'Tu es un correcteur universitaire qui évalue une réponse ouverte en français.',
    'Évalue uniquement à partir de la question, de la réponse étudiante, de la notion et des chunks fournis.',
    'Ne récompense pas une affirmation non justifiée par le cours.',
    'Retourne uniquement du JSON strict avec score, maxScore, feedback, presentPoints, missingPoints, errors, modelAnswer, advice et sourceChunkIds.',
    'maxScore doit être 20. score doit être entre 0 et maxScore.',
    chunks.length > 0
      ? 'sourceChunkIds doit contenir au moins un ID exact parmi les chunks fournis.'
      : 'Aucun chunk vérifiable n’est fourni: sourceChunkIds doit être vide.',
    JSON.stringify(payload),
  ].join('\n\n');
}

function selectChunks(input: {
  chunks: DiagnosticQuizGenerationChunk[];
  sourceChunkIds: string[];
  maxChunksEnv: string | undefined;
  maxCharsEnv: string | undefined;
}): SelectedOpenAnswerChunk[] {
  const chunks = deduplicateChunks(input.chunks);
  const sourceChunkIds = new Set(input.sourceChunkIds);
  const prioritizedChunks = [
    ...chunks.filter((chunk) => sourceChunkIds.has(chunk.id)),
    ...chunks.filter((chunk) => !sourceChunkIds.has(chunk.id)),
  ];
  const maxChunks = resolvePositiveInteger(
    input.maxChunksEnv,
    DEFAULT_MAX_CHUNKS,
  );
  const maxChars = resolvePositiveInteger(input.maxCharsEnv, DEFAULT_MAX_CHARS);
  let remainingChars = maxChars;

  return prioritizedChunks.slice(0, maxChunks).flatMap((chunk) => {
    if (remainingChars <= 0) {
      return [];
    }

    const text = chunk.text.slice(0, remainingChars);
    remainingChars -= text.length;

    if (text.trim().length === 0) {
      return [];
    }

    return [{ ...chunk, text }];
  });
}

function deduplicateChunks(
  chunks: DiagnosticQuizGenerationChunk[],
): SelectedOpenAnswerChunk[] {
  const chunksById = new Map<string, DiagnosticQuizGenerationChunk>();

  for (const chunk of chunks) {
    if (chunk.text.trim().length > 0 && !chunksById.has(chunk.id)) {
      chunksById.set(chunk.id, chunk);
    }
  }

  return [...chunksById.values()].sort(
    (left, right) => left.index - right.index,
  );
}

function normalizeSourceChunkIds(
  sourceChunkIds: string[],
  chunks: SelectedOpenAnswerChunk[],
  errorCode: string,
): string[] {
  if (chunks.length === 0) {
    if (sourceChunkIds.length > 0) {
      throw new Error(errorCode);
    }

    return [];
  }

  const knownChunkIds = new Set(chunks.map((chunk) => chunk.id));
  const normalized = [...new Set(sourceChunkIds)];

  if (
    normalized.length === 0 ||
    normalized.some((chunkId) => !knownChunkIds.has(chunkId))
  ) {
    throw new Error(errorCode);
  }

  return normalized;
}

function resolvePositiveInteger(value: string | undefined, fallback: number) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    return fallback;
  }

  return parsed;
}

function resolveOpenAnswerEvaluationErrorCode(error: unknown): string {
  if (error instanceof Error && error.message === SOURCE_INVALID_ERROR_CODE) {
    return SOURCE_INVALID_ERROR_CODE;
  }

  if (error instanceof Error && error.message === EMPTY_OUTPUT_ERROR_CODE) {
    return EMPTY_OUTPUT_ERROR_CODE;
  }

  return 'OPEN_ANSWER_EVALUATION_INVALID';
}

```

### `api/src/modules/activities/infrastructure/genkit-open-answer.evaluator.spec.ts`

```ts
type GenerateInput = {
  prompt: string;
  output: {
    schema: unknown;
  };
};

type GenerateResult = {
  output?: {
    score?: number;
    maxScore?: number;
    feedback?: string;
    presentPoints?: string[];
    missingPoints?: string[];
    errors?: string[];
    modelAnswer?: string;
    advice?: string;
    sourceChunkIds?: string[];
    unexpected?: string;
  };
};

type GenkitInput = {
  plugins: unknown[];
  model: string;
};

const mockGooglePlugin = { name: 'google-plugin' };
const mockGenerate = jest.fn<Promise<GenerateResult>, [GenerateInput]>();
const mockGenkit = jest.fn<{ generate: typeof mockGenerate }, [GenkitInput]>(
  () => ({ generate: mockGenerate }),
);
const mockGoogleAI = jest.fn<unknown, []>(() => mockGooglePlugin);

jest.mock('genkit', () => ({
  ...jest.requireActual<typeof import('genkit')>('genkit'),
  genkit: mockGenkit,
}));

jest.mock('@genkit-ai/google-genai', () => ({
  googleAI: mockGoogleAI,
}));

import type {
  AiGenerationObservation,
  AiGenerationObserver,
} from '../../ai/application/ai-generation-observer';
import { GenkitOpenAnswerEvaluator } from './genkit-open-answer.evaluator';

describe('GenkitOpenAnswerEvaluator', () => {
  const originalAiProvider = process.env.AI_PROVIDER;
  const originalGenkitModel = process.env.GENKIT_MODEL;
  const originalMaxChunks = process.env.OPEN_ANSWER_EVALUATION_MAX_CHUNKS;
  const originalMaxChars = process.env.OPEN_ANSWER_EVALUATION_MAX_CHARS;

  afterEach(() => {
    restoreEnv('AI_PROVIDER', originalAiProvider);
    restoreEnv('GENKIT_MODEL', originalGenkitModel);
    restoreEnv('OPEN_ANSWER_EVALUATION_MAX_CHUNKS', originalMaxChunks);
    restoreEnv('OPEN_ANSWER_EVALUATION_MAX_CHARS', originalMaxChars);
    mockGoogleAI.mockClear();
    mockGenkit.mockClear();
    mockGenerate.mockReset();
  });

  it('evaluates an open answer and observes metadata only', async () => {
    process.env.AI_PROVIDER = 'google';
    mockGenerate.mockResolvedValue({
      output: {
        score: 16,
        maxScore: 20,
        feedback:
          'Réponse solide qui explique la limitation de la concentration du pouvoir.',
        presentPoints: ['Séparation des fonctions'],
        missingPoints: ['Exemple institutionnel plus précis'],
        errors: ['Confusion mineure sur le contrôle juridictionnel'],
        modelAnswer:
          'Une bonne réponse explique que la séparation distribue les fonctions entre organes.',
        advice: 'Relis le passage sur les fonctions législative et exécutive.',
        sourceChunkIds: ['chunk-1', 'chunk-1'],
      },
    });
    const observer = createObserver();

    const evaluation = await new GenkitOpenAnswerEvaluator(observer).evaluate({
      subjectId: 'subject-1',
      documentId: 'document-1',
      activitySessionId: 'session-1',
      knowledgeUnit: {
        id: 'unit-1',
        subjectId: 'subject-1',
        title: 'Séparation des pouvoirs',
        summary: 'La notion distingue les fonctions étatiques.',
        sourceChunkIds: ['chunk-1'],
      },
      question: {
        id: 'open-question-1',
        prompt:
          'Explique pourquoi la séparation des pouvoirs limite la concentration du pouvoir.',
        instructions: 'Réponds avec le cours.',
        sourceChunkIds: ['chunk-1'],
      },
      answerText: 'SENTINEL_FULL_STUDENT_ANSWER',
      chunks: [
        {
          id: 'chunk-1',
          index: 0,
          text: 'SENTINEL_FULL_CHUNK_TEXT',
          pageNumber: null,
        },
      ],
    });

    expect(evaluation).toMatchObject({
      status: 'READY',
      score: 16,
      maxScore: 20,
      feedback:
        'Réponse solide qui explique la limitation de la concentration du pouvoir.',
      presentPoints: ['Séparation des fonctions'],
      missingPoints: ['Exemple institutionnel plus précis'],
      errors: ['Confusion mineure sur le contrôle juridictionnel'],
      modelAnswer:
        'Une bonne réponse explique que la séparation distribue les fonctions entre organes.',
      advice: 'Relis le passage sur les fonctions législative et exécutive.',
      sourceChunkIds: ['chunk-1'],
      metadata: {
        flowName: 'openAnswerEvaluation',
        provider: 'google-genai',
        model: 'googleai/gemini-2.5-flash',
        promptVersion: 'open-answer-evaluation-v1',
        schemaVersion: 'open-answer-evaluation-v1',
      },
    });
    const [generateInput] = mockGenerate.mock.calls[0] ?? [];
    expect(generateInput?.prompt).toContain('SENTINEL_FULL_STUDENT_ANSWER');
    expect(generateInput?.prompt).toContain('SENTINEL_FULL_CHUNK_TEXT');
    expect(generateInput?.output.schema).toBeDefined();
    const observation = getObservedObservation(observer);
    expect(observation).toMatchObject({
      flowName: 'openAnswerEvaluation',
      provider: 'google-genai',
      model: 'googleai/gemini-2.5-flash',
      promptVersion: 'open-answer-evaluation-v1',
      schemaVersion: 'open-answer-evaluation-v1',
      status: 'success',
      documentId: 'document-1',
      subjectId: 'subject-1',
      knowledgeUnitId: 'unit-1',
      activitySessionId: 'session-1',
    });
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'SENTINEL_FULL_STUDENT_ANSWER',
    );
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'SENTINEL_FULL_CHUNK_TEXT',
    );
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'bonne réponse explique',
    );
  });

  it('rejects unknown evaluation sources and observes an error', async () => {
    process.env.AI_PROVIDER = 'google';
    mockGenerate.mockResolvedValue({
      output: {
        score: 12,
        maxScore: 20,
        feedback: 'Feedback structuré.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil.',
        sourceChunkIds: ['chunk-unknown'],
      },
    });
    const observer = createObserver();

    await expect(
      new GenkitOpenAnswerEvaluator(observer).evaluate(baseInput()),
    ).rejects.toThrow('OPEN_ANSWER_EVALUATION_SOURCE_INVALID');

    const observation = getObservedObservation(observer);
    expect(observation.status).toBe('error');
    expect(observation.errorCode).toBe('OPEN_ANSWER_EVALUATION_SOURCE_INVALID');
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'SENTINEL_FULL_STUDENT_ANSWER',
    );
  });

  it('rejects score values outside evaluation bounds', async () => {
    process.env.AI_PROVIDER = 'google';
    mockGenerate.mockResolvedValue({
      output: {
        score: 30,
        maxScore: 20,
        feedback: 'Feedback structuré.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil.',
        sourceChunkIds: ['chunk-1'],
      },
    });

    await expect(
      new GenkitOpenAnswerEvaluator().evaluate(baseInput()),
    ).rejects.toThrow();
  });
});

function baseInput() {
  return {
    subjectId: 'subject-1',
    documentId: 'document-1',
    activitySessionId: 'session-1',
    knowledgeUnit: {
      id: 'unit-1',
      subjectId: 'subject-1',
      title: 'Séparation des pouvoirs',
      summary: 'Résumé.',
      sourceChunkIds: ['chunk-1'],
    },
    question: {
      id: 'open-question-1',
      prompt: 'Explique la notion.',
      instructions: 'Réponds avec le cours.',
      sourceChunkIds: ['chunk-1'],
    },
    answerText: 'SENTINEL_FULL_STUDENT_ANSWER',
    chunks: [
      {
        id: 'chunk-1',
        index: 0,
        text: 'SENTINEL_FULL_CHUNK_TEXT',
        pageNumber: null,
      },
    ],
  };
}

function createObserver(): jest.Mocked<AiGenerationObserver> {
  return {
    observe: jest.fn(),
  };
}

function getObservedObservation(
  observer: jest.Mocked<AiGenerationObserver>,
): AiGenerationObservation {
  const [[observation]] = observer.observe.mock.calls;

  if (!observation) {
    throw new Error('Expected observation');
  }

  return observation;
}

function restoreEnv(key: string, value: string | undefined): void {
  if (value === undefined) {
    delete process.env[key];
    return;
  }

  process.env[key] = value;
}

```

### `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`

```ts
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

```

### `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`

```ts
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
});

```

### `api/src/modules/activities/activities.module.ts`

```ts
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
import { StartOpenQuestionActivityUseCase } from './application/start-open-question-activity.use-case';
import { StartNextActivityUseCase } from './application/start-next-activity.use-case';
import { SubmitOpenAnswerUseCase } from './application/submit-open-answer.use-case';
import { SubmitActivityResultUseCase } from './application/submit-activity-result.use-case';
import { GenkitDiagnosticQuizGenerator } from './infrastructure/genkit-diagnostic-quiz.generator';
import { GenkitOpenAnswerEvaluator } from './infrastructure/genkit-open-answer.evaluator';
import { GenkitOpenQuestionGenerator } from './infrastructure/genkit-open-question.generator';
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
    {
      provide: OPEN_QUESTION_GENERATOR,
      useClass: GenkitOpenQuestionGenerator,
    },
    {
      provide: OPEN_ANSWER_EVALUATOR,
      useClass: GenkitOpenAnswerEvaluator,
    },
  ],
})
export class ActivitiesModule {}

```

### `api/src/modules/activities/activities.module.spec.ts`

```ts
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
    findOpenAnswerEvaluationContext: jest.Mock;
    saveOpenAnswerEvaluation: jest.Mock;
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

```

### `api/src/modules/activities/interfaces/activities.controller.ts`

```ts
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
      error.message === 'Open question source chunk not found' ||
      error.message === 'OPEN_QUESTION_SOURCE_INVALID' ||
      error.message === 'OPEN_QUESTION_GENERATION_INVALID' ||
      error.message === 'OPEN_QUESTION_EMPTY_OUTPUT' ||
      error.message === 'OPEN_ANSWER_EVALUATION_SOURCE_INVALID' ||
      error.message === 'OPEN_ANSWER_EVALUATION_INVALID' ||
      error.message === 'OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT' ||
      error.message === 'OPEN_ANSWER_EVALUATION_FAILED'
    ) {
      throw new UnprocessableEntityException(error.message);
    }
  }

  throw error;
}

```

### `api/src/modules/revision/domain/mastery-state.entity.ts`

```ts
import { StudentId } from '../../../shared/domain/student-id';

export class MasteryState {
  readonly studentId: StudentId;
  readonly knowledgeUnitId: string;
  readonly score: number;
  readonly lastPracticedAt: Date | null;

  constructor(input: {
    studentId: StudentId;
    knowledgeUnitId: string;
    score: number;
    lastPracticedAt: Date | null;
  }) {
    if (!Number.isFinite(input.score) || input.score < 0 || input.score > 1) {
      throw new Error('Mastery score must be between 0 and 1');
    }

    this.studentId = input.studentId;
    this.knowledgeUnitId = input.knowledgeUnitId;
    this.score = input.score;
    this.lastPracticedAt = input.lastPracticedAt;
  }

  applyQuizResult(
    correctAnswers: number,
    totalQuestions: number,
    practicedAt: Date,
  ): MasteryState {
    if (!Number.isInteger(totalQuestions) || totalQuestions <= 0) {
      throw new Error('Quiz result must include at least one question');
    }
    if (
      !Number.isInteger(correctAnswers) ||
      correctAnswers < 0 ||
      correctAnswers > totalQuestions
    ) {
      throw new Error('Correct answers must be between 0 and total questions');
    }

    const ratio = correctAnswers / totalQuestions;
    const nextScore = Math.max(
      0,
      Math.min(1, this.score * 0.65 + ratio * 0.35),
    );

    return new MasteryState({
      studentId: this.studentId,
      knowledgeUnitId: this.knowledgeUnitId,
      score: Number(nextScore.toFixed(3)),
      lastPracticedAt: practicedAt,
    });
  }

  applyOpenAnswerRatio(ratio: number, practicedAt: Date): MasteryState {
    if (!Number.isFinite(ratio) || ratio < 0 || ratio > 1) {
      throw new Error('Open answer ratio must be between 0 and 1');
    }

    const nextScore = Math.max(
      0,
      Math.min(1, this.score * 0.65 + ratio * 0.35),
    );

    return new MasteryState({
      studentId: this.studentId,
      knowledgeUnitId: this.knowledgeUnitId,
      score: Number(nextScore.toFixed(3)),
      lastPracticedAt: practicedAt,
    });
  }
}

```

### `api/src/modules/revision/domain/mastery-state.entity.spec.ts`

```ts
import { MasteryState } from './mastery-state.entity';

describe('MasteryState', () => {
  it('returns a new state with a weighted quiz score and practiced timestamp', () => {
    const lastPracticedAt = new Date('2026-06-01T10:00:00.000Z');
    const practicedAt = new Date('2026-06-12T10:00:00.000Z');
    const mastery = new MasteryState({
      studentId: 'student-1',
      knowledgeUnitId: 'unit-1',
      score: 0.4,
      lastPracticedAt,
    });

    const next = mastery.applyQuizResult(8, 10, practicedAt);

    expect(next).not.toBe(mastery);
    expect(next).toMatchObject({
      studentId: 'student-1',
      knowledgeUnitId: 'unit-1',
      score: 0.54,
      lastPracticedAt: practicedAt,
    });
    expect(mastery.score).toBe(0.4);
    expect(mastery.lastPracticedAt).toBe(lastPracticedAt);
  });

  it('rounds weighted quiz scores to three decimals', () => {
    const mastery = new MasteryState({
      studentId: 'student-1',
      knowledgeUnitId: 'unit-1',
      score: 0.333,
      lastPracticedAt: null,
    });

    const next = mastery.applyQuizResult(
      2,
      3,
      new Date('2026-06-12T10:00:00.000Z'),
    );

    expect(next.score).toBe(0.45);
  });

  it('returns a new state with a weighted open answer ratio', () => {
    const practicedAt = new Date('2026-06-14T10:00:00.000Z');
    const mastery = new MasteryState({
      studentId: 'student-1',
      knowledgeUnitId: 'unit-1',
      score: 0.4,
      lastPracticedAt: null,
    });

    const next = mastery.applyOpenAnswerRatio(0.8, practicedAt);

    expect(next).not.toBe(mastery);
    expect(next).toMatchObject({
      studentId: 'student-1',
      knowledgeUnitId: 'unit-1',
      score: 0.54,
      lastPracticedAt: practicedAt,
    });
  });

  it('rejects non-finite mastery scores', () => {
    const invalidScores = [
      Number.NaN,
      Number.POSITIVE_INFINITY,
      Number.NEGATIVE_INFINITY,
    ];

    for (const score of invalidScores) {
      expect(
        () =>
          new MasteryState({
            studentId: 'student-1',
            knowledgeUnitId: 'unit-1',
            score,
            lastPracticedAt: null,
          }),
      ).toThrow('Mastery score must be between 0 and 1');
    }
  });

  it('rejects impossible quiz results', () => {
    const mastery = new MasteryState({
      studentId: 'student-1',
      knowledgeUnitId: 'unit-1',
      score: 0.5,
      lastPracticedAt: null,
    });
    const practicedAt = new Date('2026-06-12T10:00:00.000Z');
    const invalidTotalQuestions = [
      0,
      -1,
      1.5,
      Number.NaN,
      Number.POSITIVE_INFINITY,
    ];
    const invalidCorrectAnswers = [
      -1,
      1.5,
      Number.NaN,
      Number.POSITIVE_INFINITY,
      11,
    ];

    for (const totalQuestions of invalidTotalQuestions) {
      expect(() =>
        mastery.applyQuizResult(0, totalQuestions, practicedAt),
      ).toThrow('Quiz result must include at least one question');
    }

    for (const correctAnswers of invalidCorrectAnswers) {
      expect(() =>
        mastery.applyQuizResult(correctAnswers, 10, practicedAt),
      ).toThrow('Correct answers must be between 0 and total questions');
    }
  });
});

```
