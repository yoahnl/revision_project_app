# LOT V1-005 — Quality gates pédagogiques backend

## 1. Résultat

Quality gate pédagogique pur ajouté côté API. Il évalue un `RichClosedExercise`, calcule des métriques déterministes et rejette les exercices pauvres, trop dominés par `single_choice`, non sourcés ou contenant des fuites de correction dans un payload public.

## 2. Sources inspectées

- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.ts`
- `revision_app/docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`
- `revision_app/docs/v1/RICH_CLOSED_QUESTIONS_PRISMA_DTO_VERSIONING_AUDIT.md`

## 3. Préflight Git

Préflight identique aux rapports V1-002 à V1-004 : deux repos sur `main`, propres au départ, sans fichier modifié ou non suivi.

## 4. Périmètre réalisé

- Ajout de `rich-closed-question-quality-gate.ts`.
- Ajout de `rich-closed-question-quality-gate.spec.ts`.
- Règles de diversité pour exercices de six questions ou plus.
- Règles sources connues.
- Heuristique bornée de questions trop basiques.
- Détection de fuites dans payload public pré-submit.
- Mise à jour de la ligne V1-005 du plan V1.

## 5. Décisions prises

- Le gate reste pur et sans DB.
- Les petits exercices de moins de six questions ont des règles de diversité assouplies.
- Le seuil de questions sourcées est de 80 % quand un contexte source connu est fourni.
- Un exercice V1-A complet doit contenir `case_qualification`, `error_detection` et au moins `matching` ou `ordering`.
- Le gate réutilise le validator V1-004 pour éviter deux sources de vérité.

## 6. Fichiers créés/modifiés/supprimés

Créés :

- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.spec.ts`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md`

Modifiés :

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

Supprimés : aucun.

## 7. Tests ajoutés

- Acceptation d'un exercice riche V1-A.
- Rejet d'un exercice 100 % `single_choice`.
- Rejet sans `case_qualification`.
- Rejet sans `error_detection`.
- Rejet source inconnue.
- Rejet ratio sourcé insuffisant.
- Rejet questions basiques excessives.
- Assouplissement sur petit exercice de trois questions.
- Rejet fuite de correction dans payload public.

## 8. Validations lancées avec résultats

- `npm test -- rich-closed --runInBand` : passé (`3 passed`, `33 passed`).
- `npm test -- activities --runInBand` : passé (`12 passed`, `1 skipped`, `120 passed`, `1 skipped`).
- `npm run lint:check` : passé.
- `npm run build` : passé après correction du helper de fixture.
- `git diff --check` API : passé.
- `git diff --check` revision_app : passé.

## 9. Validations non lancées avec justification

- Tests Flutter : non lancés, aucun code Flutter modifié.
- Prisma migrate/validate/generate : non lancés, aucun schema modifié.
- Genkit réel : non lancé, aucun flow modifié.
- Seed réel : non lancé.

## 10. Risques restants

- Les seuils pédagogiques peuvent nécessiter un ajustement après premiers exercices générés par V1-006.
- L'heuristique de prompts basiques reste volontairement simple.
- Les métriques ne sont pas encore persistées.

## 11. Recommandation prochain lot

`V1-006 — Génération Genkit rich closed questions V1-A`, avec sortie strictement validée par le validator V1-004 puis le gate V1-005.

## 12. Passes de review

- Pédagogie : diversité de types et cas/erreur obligatoires.
- Anti-fuite : scan récursif des clés privées dans payload public.
- Scope : pas de Genkit réel, pas de Prisma, pas d'API publique.
- Non-régression : tests activities existants verts.

## 13. Critique honnête du prompt initial

Le prompt est strict et utile. Le point subtil est le seuil `single_choice` à 40 % : pour six questions, deux `single_choice` passent, trois échouent, ce qui est cohérent mais devra être surveillé sur des exercices très courts ou documents pauvres.

## 14. Contenu complet des fichiers créés/modifiés/supprimés pour review

### `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.ts`

```ts
import { toRichClosedPublicExercise } from './rich-closed-question-public.mapper';
import {
  validateRichClosedExercise,
  type RichClosedQuestionValidationOptions,
} from './rich-closed-question.validator';
import {
  RICH_CLOSED_QUESTION_KINDS,
  type RichClosedCognitiveSkill,
  type RichClosedDifficulty,
  type RichClosedExercise,
  type RichClosedExerciseValidationIssue,
  type RichClosedQuestionKind,
} from './rich-closed-question.types';

export interface RichClosedQuestionQualityGateOptions extends RichClosedQuestionValidationOptions {
  publicExercise?: unknown;
}

export interface RichClosedQuestionQualityGateMetrics {
  questionCount: number;
  questionKindCounts: Record<RichClosedQuestionKind, number>;
  distinctQuestionKindCount: number;
  advancedQuestionCount: number;
  basicQuestionCount: number;
  sourcedQuestionCount: number;
  cognitiveSkillCounts: Partial<Record<RichClosedCognitiveSkill, number>>;
  difficultyCounts: Partial<Record<RichClosedDifficulty, number>>;
  qualityGateStatus: 'accepted' | 'rejected';
}

export interface RichClosedQuestionQualityGateResult {
  accepted: boolean;
  issues: RichClosedExerciseValidationIssue[];
  warnings: RichClosedExerciseValidationIssue[];
  metrics: RichClosedQuestionQualityGateMetrics;
}

const MIN_FULL_GATE_QUESTION_COUNT = 6;
const MIN_DISTINCT_KINDS_FOR_FULL_GATE = 3;
const MAX_SINGLE_CHOICE_RATIO = 0.4;
const MIN_SOURCED_RATIO = 0.8;
const MAX_BASIC_PROMPT_RATIO = 0.4;

export function evaluateRichClosedExerciseQuality(
  exercise: RichClosedExercise,
  options: RichClosedQuestionQualityGateOptions = {},
): RichClosedQuestionQualityGateResult {
  const issues: RichClosedExerciseValidationIssue[] = [
    ...validateRichClosedExercise(exercise, options).issues,
  ];
  const warnings: RichClosedExerciseValidationIssue[] = [];
  const metrics = buildMetrics(exercise);

  if (options.publicExercise !== undefined) {
    const publicLeakIssues = validatePublicPayloadHasNoCorrection(
      options.publicExercise,
    );
    issues.push(...publicLeakIssues);
  } else {
    const mappedPublicPayload = toRichClosedPublicExercise(exercise);
    issues.push(...validatePublicPayloadHasNoCorrection(mappedPublicPayload));
  }

  if (metrics.questionCount < MIN_FULL_GATE_QUESTION_COUNT) {
    warnings.push(
      warning(
        'RICH_CLOSED_GATE_SMALL_EXERCISE_RELAXED_RULES',
        'Diversity gates are relaxed below six questions',
      ),
    );
  } else {
    applyFullExerciseGates(metrics, issues);
  }

  applySourceGates(metrics, issues, options);
  applyBasicPromptGate(metrics, issues);

  metrics.qualityGateStatus = issues.length === 0 ? 'accepted' : 'rejected';

  return {
    accepted: issues.length === 0,
    issues,
    warnings,
    metrics,
  };
}

function applyFullExerciseGates(
  metrics: RichClosedQuestionQualityGateMetrics,
  issues: RichClosedExerciseValidationIssue[],
) {
  if (metrics.distinctQuestionKindCount < MIN_DISTINCT_KINDS_FOR_FULL_GATE) {
    issues.push(
      error(
        'RICH_CLOSED_GATE_NOT_ENOUGH_KIND_DIVERSITY',
        'A full rich closed exercise must contain at least three question kinds',
      ),
    );
  }

  if (
    metrics.questionKindCounts.single_choice / metrics.questionCount >
    MAX_SINGLE_CHOICE_RATIO
  ) {
    issues.push(
      error(
        'RICH_CLOSED_GATE_TOO_MANY_SINGLE_CHOICE',
        'A full rich closed exercise cannot be dominated by single choice questions',
      ),
    );
  }

  if (metrics.questionKindCounts.case_qualification === 0) {
    issues.push(
      error(
        'RICH_CLOSED_GATE_CASE_QUALIFICATION_REQUIRED',
        'A full rich closed exercise must contain a case qualification question',
      ),
    );
  }

  if (metrics.questionKindCounts.error_detection === 0) {
    issues.push(
      error(
        'RICH_CLOSED_GATE_ERROR_DETECTION_REQUIRED',
        'A full rich closed exercise must contain an error detection question',
      ),
    );
  }

  if (
    metrics.questionKindCounts.matching === 0 &&
    metrics.questionKindCounts.ordering === 0
  ) {
    issues.push(
      error(
        'RICH_CLOSED_GATE_STRUCTURED_INTERACTION_REQUIRED',
        'A full rich closed exercise must contain matching or ordering',
      ),
    );
  }
}

function applySourceGates(
  metrics: RichClosedQuestionQualityGateMetrics,
  issues: RichClosedExerciseValidationIssue[],
  options: RichClosedQuestionQualityGateOptions,
) {
  if (
    options.knownSourceChunkIds === undefined ||
    metrics.questionCount === 0
  ) {
    return;
  }

  if (
    metrics.sourcedQuestionCount / metrics.questionCount <
    MIN_SOURCED_RATIO
  ) {
    issues.push(
      error(
        'RICH_CLOSED_GATE_NOT_ENOUGH_SOURCED_QUESTIONS',
        'At least 80% of rich closed questions must be sourced when source context is known',
      ),
    );
  }
}

function applyBasicPromptGate(
  metrics: RichClosedQuestionQualityGateMetrics,
  issues: RichClosedExerciseValidationIssue[],
) {
  if (metrics.questionCount === 0) {
    return;
  }

  if (
    metrics.basicQuestionCount / metrics.questionCount >
    MAX_BASIC_PROMPT_RATIO
  ) {
    issues.push(
      error(
        'RICH_CLOSED_GATE_TOO_MANY_BASIC_QUESTIONS',
        'The exercise contains too many likely restitution prompts',
      ),
    );
  }
}

function buildMetrics(
  exercise: RichClosedExercise,
): RichClosedQuestionQualityGateMetrics {
  const questionKindCounts = emptyQuestionKindCounts();
  const cognitiveSkillCounts: Partial<
    Record<RichClosedCognitiveSkill, number>
  > = {};
  const difficultyCounts: Partial<Record<RichClosedDifficulty, number>> = {};
  let sourcedQuestionCount = 0;
  let basicQuestionCount = 0;

  for (const question of exercise.questions) {
    questionKindCounts[question.questionKind] += 1;
    cognitiveSkillCounts[question.cognitiveSkill] =
      (cognitiveSkillCounts[question.cognitiveSkill] ?? 0) + 1;
    difficultyCounts[question.difficulty] =
      (difficultyCounts[question.difficulty] ?? 0) + 1;

    if (question.sourceChunkIds.length > 0) {
      sourcedQuestionCount += 1;
    }

    if (isLikelyBasicPrompt(question.prompt)) {
      basicQuestionCount += 1;
    }
  }

  return {
    questionCount: exercise.questions.length,
    questionKindCounts,
    distinctQuestionKindCount: Object.values(questionKindCounts).filter(
      (count) => count > 0,
    ).length,
    advancedQuestionCount: exercise.questions.length - basicQuestionCount,
    basicQuestionCount,
    sourcedQuestionCount,
    cognitiveSkillCounts,
    difficultyCounts,
    qualityGateStatus: 'rejected',
  };
}

function emptyQuestionKindCounts(): Record<RichClosedQuestionKind, number> {
  return Object.fromEntries(
    RICH_CLOSED_QUESTION_KINDS.map((kind) => [kind, 0]),
  ) as Record<RichClosedQuestionKind, number>;
}

function isLikelyBasicPrompt(prompt: string): boolean {
  const normalized = prompt.trim().toLocaleLowerCase('fr-FR');

  return (
    normalized.startsWith('qui ') ||
    normalized.startsWith('quand ') ||
    normalized.startsWith('quelle date') ||
    normalized.startsWith('quelle est la définition') ||
    normalized.startsWith('quel terme désigne')
  );
}

function validatePublicPayloadHasNoCorrection(
  value: unknown,
): RichClosedExerciseValidationIssue[] {
  const leakingPaths = privateFieldPaths(value);

  return leakingPaths.map((path) =>
    error(
      'RICH_CLOSED_PUBLIC_CORRECTION_LEAK',
      'Public pre-submit payload contains private correction data',
      path,
    ),
  );
}

function privateFieldPaths(value: unknown, path = '$'): string[] {
  if (Array.isArray(value)) {
    return value.flatMap((item, index) =>
      privateFieldPaths(item, `${path}.${index}`),
    );
  }

  if (typeof value !== 'object' || value === null) {
    return [];
  }

  const paths: string[] = [];
  for (const [key, nestedValue] of Object.entries(value)) {
    const nestedPath = `${path}.${key}`;
    if (isPrivatePublicPayloadKey(key)) {
      paths.push(nestedPath);
      continue;
    }

    paths.push(...privateFieldPaths(nestedValue, nestedPath));
  }

  return paths;
}

function isPrivatePublicPayloadKey(key: string): boolean {
  return (
    key.startsWith('correct') ||
    key === 'correctionPayload' ||
    key === 'explanation' ||
    key === 'score' ||
    key === 'partialScore'
  );
}

function error(
  code: string,
  message: string,
  path?: string,
): RichClosedExerciseValidationIssue {
  return {
    code,
    message,
    ...(path === undefined ? {} : { path }),
    severity: 'error',
  };
}

function warning(
  code: string,
  message: string,
): RichClosedExerciseValidationIssue {
  return {
    code,
    message,
    severity: 'warning',
  };
}
```

### `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.spec.ts`

```ts
import { evaluateRichClosedExerciseQuality } from './rich-closed-question-quality-gate';
import {
  richClosedExerciseFixture,
  richClosedQuestionFixture,
} from './rich-closed-question.fixtures';
import { toRichClosedPublicExercise } from './rich-closed-question-public.mapper';

describe('rich closed question quality gate', () => {
  it('accepts a rich V1-A exercise and exposes deterministic metrics', () => {
    const exercise = richClosedExerciseFixture();

    const result = evaluateRichClosedExerciseQuality(exercise, {
      knownSourceChunkIds: ['chunk-1', 'chunk-2', 'chunk-3'],
      publicExercise: toRichClosedPublicExercise(exercise),
    });

    expect(result.accepted).toBe(true);
    expect(result.issues).toEqual([]);
    expect(result.metrics).toMatchObject({
      questionCount: 6,
      distinctQuestionKindCount: 6,
      advancedQuestionCount: 6,
      basicQuestionCount: 0,
      sourcedQuestionCount: 6,
      qualityGateStatus: 'accepted',
    });
    expect(result.metrics.questionKindCounts).toMatchObject({
      single_choice: 1,
      multiple_choice: 1,
      matching: 1,
      ordering: 1,
      case_qualification: 1,
      error_detection: 1,
    });
  });

  it('rejects a six-question exercise made only of single choice questions', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: Array.from({ length: 6 }, (_value, index) => ({
        ...richClosedQuestionFixture('single_choice'),
        id: `single-${index + 1}`,
        prompt: `Question de choix unique ${index + 1}`,
      })),
    };

    const result = evaluateRichClosedExerciseQuality(exercise);

    expect(result.accepted).toBe(false);
    expect(result.issues).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          code: 'RICH_CLOSED_GATE_NOT_ENOUGH_KIND_DIVERSITY',
        }),
        expect.objectContaining({
          code: 'RICH_CLOSED_GATE_TOO_MANY_SINGLE_CHOICE',
        }),
      ]),
    );
  });

  it('rejects a six-question exercise without case qualification', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: [
        richClosedQuestionFixture('single_choice'),
        richClosedQuestionFixture('multiple_choice'),
        richClosedQuestionFixture('matching'),
        richClosedQuestionFixture('ordering'),
        richClosedQuestionFixture('error_detection'),
        { ...richClosedQuestionFixture('matching'), id: 'matching-extra' },
      ],
    };

    const result = evaluateRichClosedExerciseQuality(exercise);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_GATE_CASE_QUALIFICATION_REQUIRED',
      }),
    );
  });

  it('rejects a six-question exercise without error detection', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: [
        richClosedQuestionFixture('single_choice'),
        richClosedQuestionFixture('multiple_choice'),
        richClosedQuestionFixture('matching'),
        richClosedQuestionFixture('ordering'),
        richClosedQuestionFixture('case_qualification'),
        { ...richClosedQuestionFixture('ordering'), id: 'ordering-extra' },
      ],
    };

    const result = evaluateRichClosedExerciseQuality(exercise);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_GATE_ERROR_DETECTION_REQUIRED',
      }),
    );
  });

  it('rejects unknown sources', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: [
        {
          ...richClosedQuestionFixture('single_choice'),
          sourceChunkIds: ['chunk-unknown'],
        },
        ...richClosedExerciseFixture().questions.slice(1),
      ],
    };

    const result = evaluateRichClosedExerciseQuality(exercise, {
      knownSourceChunkIds: ['chunk-1', 'chunk-2', 'chunk-3'],
    });

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_SOURCE_UNKNOWN' }),
    );
  });

  it('rejects an insufficient sourced ratio when source context is known', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: richClosedExerciseFixture().questions.map((question, index) =>
        index < 2 ? question : { ...question, sourceChunkIds: [] },
      ),
    };

    const result = evaluateRichClosedExerciseQuality(exercise, {
      knownSourceChunkIds: ['chunk-1', 'chunk-2', 'chunk-3'],
    });

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_GATE_NOT_ENOUGH_SOURCED_QUESTIONS',
      }),
    );
  });

  it('rejects excessive basic prompts while keeping the heuristic bounded', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: richClosedExerciseFixture().questions.map(
        (question, index) => ({
          ...question,
          prompt:
            index < 4
              ? `Qui est associé à la notion ${index + 1} ?`
              : question.prompt,
        }),
      ),
    };

    const result = evaluateRichClosedExerciseQuality(exercise);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_GATE_TOO_MANY_BASIC_QUESTIONS',
      }),
    );
  });

  it('uses relaxed diversity rules for a small three-question exercise', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: [
        richClosedQuestionFixture('single_choice'),
        richClosedQuestionFixture('multiple_choice'),
        richClosedQuestionFixture('case_qualification'),
      ],
    };

    const result = evaluateRichClosedExerciseQuality(exercise);

    expect(result.accepted).toBe(true);
    expect(result.warnings).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_GATE_SMALL_EXERCISE_RELAXED_RULES',
      }),
    );
  });

  it('rejects public pre-submit payloads that contain private correction fields', () => {
    const exercise = richClosedExerciseFixture();
    const publicExercise = {
      ...toRichClosedPublicExercise(exercise),
      questions: [
        {
          ...toRichClosedPublicExercise(exercise).questions[0],
          correctChoiceId: 'choice-a',
        },
      ],
    };

    const result = evaluateRichClosedExerciseQuality(exercise, {
      publicExercise,
    });

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_PUBLIC_CORRECTION_LEAK',
      }),
    );
  });
});
```

### `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

Fichier partagé entre les quatre lots. Les lignes V1-002 à V1-005 pointent maintenant vers leurs rapports réalisés.

### Fichiers supprimés

Aucun fichier supprimé.
