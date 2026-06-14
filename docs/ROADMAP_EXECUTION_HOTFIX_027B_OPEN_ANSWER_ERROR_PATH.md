# HOTFIX-027B — Sécurisation du chemin d’erreur open answer evaluation

## 1. Résultat

Hotfix réalisé côté backend. Le `try/catch` de `SubmitOpenAnswerUseCase` ne couvre plus que l’appel à `OpenAnswerEvaluator.evaluate`. Les erreurs de persistance READY et de mise à jour de maîtrise sont désormais propagées et ne sont plus converties en évaluation `FAILED`. Les erreurs d’évaluation sont normalisées via une whitelist de codes publics.

## 2. Problème corrigé

Le chemin LOT-027 attrapait trop large : une erreur après sauvegarde READY pouvait provoquer une seconde tentative de sauvegarde `FAILED` sur une session déjà soumise. Le hotfix empêche cette double écriture et évite de persister des messages provider/Zod bruts dans `errorCode`.

## 3. Sources inspectées

- `revision_app/docs/ROADMAP_EXECUTION_LOT_027_OPEN_QUESTION_GENKIT_CORRECTION.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `api/src/modules/activities/application/submit-open-answer.use-case.ts`
- `api/src/modules/activities/application/submit-open-answer.use-case.spec.ts`
- `api/src/modules/activities/application/open-answer-evaluator.ts`
- `api/src/modules/activities/infrastructure/genkit-open-answer.evaluator.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/revision/domain/mastery-state.entity.ts`

## 4. Préflight Git

API initial : `main`, clean, dernier commit `ba5daba #27-1: ajoute évaluation des réponses ouvertes et génération de questions`.
Frontend initial : `main`, clean, dernier commit `5304d61 LOT_027_OPEN_QUESTION_GENKIT_CORRECTION - Mise à jour plan d’exécution et ajout rapport LOT_027 (Open Question Genkit Correction)`.

## 5. Décisions d’implémentation

- Le `try/catch` couvre uniquement `openAnswerEvaluator.evaluate(...)`.
- La sauvegarde READY est hors catch et propage ses erreurs.
- La mise à jour de maîtrise est hors catch et propage ses erreurs.
- Une erreur evaluator crée toujours une évaluation `FAILED` contrôlée.
- Les messages d’erreur non whitelistés deviennent `OPEN_ANSWER_EVALUATION_FAILED`.
- Les constantes d’erreur publiques sont centralisées dans `open-answer-evaluator.ts` et réutilisées par l’adapter Genkit.

## 6. Fichiers modifiés

- `api/src/modules/activities/application/open-answer-evaluator.ts`
- `api/src/modules/activities/application/submit-open-answer.use-case.ts`
- `api/src/modules/activities/application/submit-open-answer.use-case.spec.ts`
- `api/src/modules/activities/infrastructure/genkit-open-answer.evaluator.ts`

Aucun fichier Flutter, Prisma, migration, GenUI ou plan d’exécution modifié.

## 7. Tests ajoutés/modifiés

- `SubmitOpenAnswerUseCase` normalise une erreur evaluator inconnue en `OPEN_ANSWER_EVALUATION_FAILED`.
- Une erreur de sauvegarde READY est propagée et ne crée pas d’évaluation `FAILED`.
- Une erreur de mise à jour de maîtrise après sauvegarde READY est propagée et ne crée pas d’évaluation `FAILED`.
- Les tests existants de réponse vide/trop courte/trop longue restent inchangés.

## 8. Validations lancées

- `cd api && npm test -- submit-open-answer --runInBand` : RED observé avant correction, puis OK, 1 suite, 9 tests.
- `cd api && npm test -- activities --runInBand` : OK, 9 suites passées, 1 skipped, 86 tests passés, 1 skipped.
- `cd api && npm run lint:check` : OK après correction manuelle du formatage.
- `cd api && npm run build` : OK.
- `cd api && git diff --check` : OK.
- `cd revision_app && git diff --check` : OK.

## 9. Validations non lancées avec justification

- Tests Flutter : non lancés, aucun code Flutter modifié.
- Prisma validate/generate : non nécessaires, aucun schéma Prisma ni migration modifié.
- Provider IA réel : interdit.
- `npm run lint`, `npm run format`, `npm run test:cov` : interdits.
- Déploiement : interdit.

## 10. Risques restants

- Une erreur de maîtrise après sauvegarde READY laisse une évaluation prête mais peut remonter une erreur HTTP ; c’est volontaire pour éviter une double écriture, mais LOT-028 devra afficher un message générique propre si cela arrive.
- Les providers réels peuvent encore produire des sorties invalides ; elles restent traitées par le chemin `FAILED` contrôlé.
- Pas de modification de retry ou de file de job asynchrone dans ce hotfix.

## 11. Code complet créé/modifié/supprimé pour review

Aucun fichier supprimé. Aucun fichier créé hors ce rapport. Le contenu complet des fichiers TypeScript modifiés est inclus ci-dessous. Le présent rapport est le fichier courant.

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

export const OPEN_ANSWER_EVALUATION_SOURCE_INVALID =
  'OPEN_ANSWER_EVALUATION_SOURCE_INVALID';
export const OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT =
  'OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT';
export const OPEN_ANSWER_EVALUATION_INVALID = 'OPEN_ANSWER_EVALUATION_INVALID';
export const OPEN_ANSWER_EVALUATION_FAILED = 'OPEN_ANSWER_EVALUATION_FAILED';

export const OPEN_ANSWER_EVALUATOR = Symbol('OPEN_ANSWER_EVALUATOR');

export interface OpenAnswerEvaluator {
  evaluate(
    input: OpenAnswerEvaluationInput,
  ): Promise<GeneratedOpenAnswerEvaluation>;
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
  OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT,
  OPEN_ANSWER_EVALUATION_FAILED,
  OPEN_ANSWER_EVALUATION_INVALID,
  OPEN_ANSWER_EVALUATION_SOURCE_INVALID,
  type GeneratedOpenAnswerEvaluation,
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

    let evaluation: GeneratedOpenAnswerEvaluation;

    try {
      evaluation = await this.openAnswerEvaluator.evaluate({
        studentId: input.studentId,
        subjectId: context.subjectId,
        documentId: context.documentId,
        activitySessionId: context.sessionId,
        knowledgeUnit: context.knowledgeUnit,
        question: context.question,
        answerText,
        chunks: context.chunks,
      });
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
  if (
    error instanceof Error &&
    OPEN_ANSWER_EVALUATION_ERROR_CODES.has(error.message)
  ) {
    return error.message;
  }

  return OPEN_ANSWER_EVALUATION_FAILED;
}

const OPEN_ANSWER_EVALUATION_ERROR_CODES = new Set<string>([
  OPEN_ANSWER_EVALUATION_SOURCE_INVALID,
  OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT,
  OPEN_ANSWER_EVALUATION_INVALID,
  OPEN_ANSWER_EVALUATION_FAILED,
]);

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

  it('normalizes unknown evaluator errors before persisting FAILED evaluation', async () => {
    const activitiesRepository = createActivitiesRepository();
    const openAnswerEvaluator = createOpenAnswerEvaluator();
    const revisionRepository = createRevisionRepository();
    activitiesRepository.findOpenAnswerEvaluationContext.mockResolvedValue(
      evaluationContext(),
    );
    openAnswerEvaluator.evaluate.mockRejectedValue(
      new Error('Provider raw error with sensitive internals'),
    );
    activitiesRepository.saveOpenAnswerEvaluation.mockResolvedValue(
      failedEvaluationResult({
        errors: ['OPEN_ANSWER_EVALUATION_FAILED'],
      }),
    );

    await new SubmitOpenAnswerUseCase(
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
            errorCode: 'OPEN_ANSWER_EVALUATION_FAILED',
          },
        },
      ],
    ]);
    expect(
      JSON.stringify(activitiesRepository.saveOpenAnswerEvaluation.mock.calls),
    ).not.toContain('Provider raw error');
  });

  it('propagates READY persistence errors without creating a FAILED evaluation', async () => {
    const activitiesRepository = createActivitiesRepository();
    const openAnswerEvaluator = createOpenAnswerEvaluator();
    const revisionRepository = createRevisionRepository();
    activitiesRepository.findOpenAnswerEvaluationContext.mockResolvedValue(
      evaluationContext(),
    );
    openAnswerEvaluator.evaluate.mockResolvedValue(readyEvaluation());
    activitiesRepository.saveOpenAnswerEvaluation.mockRejectedValueOnce(
      new Error('Database unavailable'),
    );

    await expect(
      new SubmitOpenAnswerUseCase(
        activitiesRepository,
        openAnswerEvaluator,
        revisionRepository,
      ).execute({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText:
          'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
      }),
    ).rejects.toThrow('Database unavailable');

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
    expect(revisionRepository.upsertMastery.mock.calls).toHaveLength(0);
  });

  it('propagates mastery update errors after READY persistence without creating FAILED evaluation', async () => {
    const activitiesRepository = createActivitiesRepository();
    const openAnswerEvaluator = createOpenAnswerEvaluator();
    const revisionRepository = createRevisionRepository();
    activitiesRepository.findOpenAnswerEvaluationContext.mockResolvedValue(
      evaluationContext(),
    );
    openAnswerEvaluator.evaluate.mockResolvedValue(readyEvaluation());
    activitiesRepository.saveOpenAnswerEvaluation.mockResolvedValue(
      readyEvaluationResult(),
    );
    revisionRepository.upsertMastery.mockRejectedValue(
      new Error('Mastery unavailable'),
    );

    await expect(
      new SubmitOpenAnswerUseCase(
        activitiesRepository,
        openAnswerEvaluator,
        revisionRepository,
      ).execute({
        studentId: 'student-1',
        sessionId: 'session-1',
        answerText:
          'La séparation des pouvoirs organise les fonctions de l’État pour éviter leur concentration.',
      }),
    ).rejects.toThrow('Mastery unavailable');

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

function failedEvaluationResult(
  input: Partial<ReturnType<typeof baseFailedEvaluation>['evaluation']> = {},
) {
  const evaluation = {
    ...baseFailedEvaluation().evaluation,
    ...input,
  };

  return {
    ...baseFailedEvaluation(),
    evaluation,
  };
}

function baseFailedEvaluation() {
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
  OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT,
  OPEN_ANSWER_EVALUATION_INVALID,
  OPEN_ANSWER_EVALUATION_SOURCE_INVALID,
  type GeneratedOpenAnswerEvaluation,
  type OpenAnswerEvaluationInput,
  type OpenAnswerEvaluator,
} from '../application/open-answer-evaluator';

const FLOW_NAME = 'openAnswerEvaluation';
const PROMPT_VERSION = 'open-answer-evaluation-v1';
const SCHEMA_VERSION = 'open-answer-evaluation-v1';
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
        throw new Error(OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT);
      }

      const parsed = GeneratedOpenAnswerEvaluationSchema.parse(output);
      const sourceChunkIds = normalizeSourceChunkIds(
        parsed.sourceChunkIds,
        chunks,
        OPEN_ANSWER_EVALUATION_SOURCE_INVALID,
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
  if (
    error instanceof Error &&
    error.message === OPEN_ANSWER_EVALUATION_SOURCE_INVALID
  ) {
    return OPEN_ANSWER_EVALUATION_SOURCE_INVALID;
  }

  if (
    error instanceof Error &&
    error.message === OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT
  ) {
    return OPEN_ANSWER_EVALUATION_EMPTY_OUTPUT;
  }

  return OPEN_ANSWER_EVALUATION_INVALID;
}

```
