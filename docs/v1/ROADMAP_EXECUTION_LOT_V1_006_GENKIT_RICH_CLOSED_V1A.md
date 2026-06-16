# LOT V1-006 — Génération Genkit rich closed questions V1-A

## 1. Résultat

Le lot V1-006 est réalisé. Un port applicatif de génération rich closed questions V1-A a été ajouté, avec un générateur Genkit isolé et mockable qui produit un `RichClosedExercise` `rich-closed-question-v1` sans persistance, sans endpoint public et sans branchement runtime public.

Le générateur :

- construit un prompt V1-A strict ;
- utilise un schema Zod strict ;
- refuse les types hors V1-A ;
- refuse les champs inconnus comme `feedback` dans les choix de sortie IA ;
- applique `validateRichClosedExercise` ;
- applique `evaluateRichClosedExerciseQuality` ;
- attache des métadonnées metadata-only ;
- observe les succès/erreurs sans prompt complet, completion complète ni chunk complet ;
- utilise des tests mockés qui n'appellent aucun provider réel.

## 2. Sources inspectées

### Contrat rich closed

- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.fixtures.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.spec.ts`

### Génération actuelle QCM

- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`

### Infra IA

- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/infrastructure/document-artifact-genkit-config.ts`
- `api/src/modules/ai/infrastructure/mistral-model-fallback.ts`
- `api/src/modules/ai/infrastructure/structured-log-ai-generation.observer.ts`
- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.ts`
- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.spec.ts`

### Documentation

- `revision_app/docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`
- `revision_app/docs/v1/RICH_CLOSED_QUESTIONS_PRISMA_DTO_VERSIONING_AUDIT.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md`

## 3. Préflight Git

### API

- Repo : `/Users/karim/Project/app-révision/api`
- Branche : `main`
- Statut initial : `## main...origin/main`
- Fichiers modifiés/non suivis initiaux : aucun.
- Derniers commits initiaux :
  - `206905b #37-2: corrige et améliore la gestion des questions fermées enrichies`
  - `8c402a7 #37-1: ajoute gestion des questions fermées enrichies`
  - `e552c75 #36-1: ajoute tests e2e pour les chemins critiques`
  - `b1d2318 #35-1: ajoute script de démo et données de seed`
  - `a08fd4e #34-1: améliore planification adaptative et plan du jour`

### revision_app

- Repo : `/Users/karim/Project/app-révision/revision_app`
- Branche : `main`
- Statut initial : `## main...origin/main`
- Fichiers modifiés/non suivis initiaux : aucun.
- Derniers commits initiaux :
  - `31cdf95 LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING - Mise à jour plan V1 et ajout rapport LOT_V1_005B (Rich Closed Contract Hardening)`
  - `75bda98 LOT_V1_002_005 - Ajout ADR, audit DTO Prisma, roadmap V1 (lots 002 à 005 : rich questions, backend, qualité pédagogique)`
  - `2667c30 LOT_038_V1 - Ajout documentation V1 (README, catalogues de questions, roadmap et exemples)`
  - `b45b6ab LOT_038_DEMO_DEPLOYMENT_RUNBOOK - Mise à jour runbooks démo et ajout rapport LOT_038`
  - `b31b17c LOT_037_E2E_SMOKE_CHECKS - Mise à jour plan d'exécution, ajout rapport LOT_037 et checks smoke démo`

## 4. Périmètre réalisé

- Création du port applicatif `RichClosedQuestionGenerator`.
- Création de `resolveRichClosedQuestionTypeMix`.
- Création du générateur `GenkitRichClosedQuestionGenerator`.
- Création d'un prompt V1-A strict et versionné.
- Création d'un schema Zod strict pour les six types V1-A.
- Application de `validateRichClosedExercise`.
- Application de `evaluateRichClosedExerciseQuality`.
- Ajout d'erreurs contrôlées whitelistées.
- Ajout de tests unitaires Genkit mockés, déterministes et CI-safe.
- Mise à jour du plan V1 pour marquer V1-006 réalisé.
- Création du rapport V1-006 dans `docs/v1`.

## 5. Architecture retenue

### Port applicatif

Le port `RichClosedQuestionGenerator` vit dans `application/rich-closed-questions`. Il ne dépend pas de Prisma, Flutter, Nest controller ou persistance. Il prend une notion, des chunks, un `questionCount`, un `questionTypeMix` et un `complexityProfile`, puis retourne un `GeneratedRichClosedExercise`.

### Générateur infrastructure

`GenkitRichClosedQuestionGenerator` vit dans `infrastructure`. Il suit le pattern du générateur QCM : résolution paresseuse du provider Genkit, support Google/Mistral via la config IA existante, fallback Mistral optionnel, logs metadata-only et observer metadata-only.

### Schema

Le schema Zod accepte uniquement les champs V1-A nécessaires et utilise `.strict()` sur chaque objet. Les choix IA ne permettent pas `feedback`. Les types hors V1-A sont rejetés par `z.discriminatedUnion('questionKind', ...)`.

### Prompt

Le prompt impose explicitement `rich-closed-question-v1`, les six `questionKind` V1-A, `questionTypeMix`, les sources existantes, les contraintes par type, l'absence de réponse libre et l'absence de widget libre.

### Validation

Après parse schema :

1. le nombre de questions est vérifié ;
2. `validateRichClosedExercise` est appliqué avec les `knownSourceChunkIds` ;
3. `evaluateRichClosedExerciseQuality` est appliqué ;
4. la conformité exacte au `questionTypeMix` demandé est vérifiée.

### Erreurs

Les erreurs exposées par le générateur sont contrôlées :

- `RICH_CLOSED_GENERATION_FAILED`
- `RICH_CLOSED_GENERATION_SCHEMA_INVALID`
- `RICH_CLOSED_GENERATION_CONTRACT_INVALID`
- `RICH_CLOSED_GENERATION_QUALITY_REJECTED`
- `RICH_CLOSED_GENERATION_SOURCE_INVALID`

## 6. Prompt et schema

- Flow name : `richClosedQuestionGeneration`
- Prompt version : `rich-closed-v1a-001`
- Schema version : `rich-closed-question-v1`

Le schema interdit les champs inconnus, les types hors V1-A, les réponses libres, les images, charts, diagrams, matrix, timeline et payloads de widget libre.

## 7. Question type mix

La fonction `resolveRichClosedQuestionTypeMix` produit :

- 6 questions : 1 `single_choice`, 1 `multiple_choice`, 1 `matching`, 1 `ordering`, 1 `case_qualification`, 1 `error_detection`.
- 10 questions : 2 `case_qualification`, 2 `error_detection`, 2 `matching`, 1 `ordering`, 2 `multiple_choice`, 1 `single_choice`.
- petits exercices : types riches d'abord, sans défaut `single_choice`.
- autres tailles : distribution déterministe, somme exacte, aucun type hors V1-A, pas de domination `single_choice`.

## 8. Anti-fuite et sécurité

- Aucun prompt ou chunk complet n'est transmis à l'observer.
- Les logs de contexte ne contiennent que des compteurs, IDs et métadonnées.
- Les logs de sortie ne contiennent que des métriques.
- Les erreurs ne contiennent que des codes whitelisted.
- Les tests vérifient que le texte de chunk sentinelle et la clé Mistral factice ne passent pas dans l'observation.
- Le schema ne permet pas `feedback` dans les choix de sortie IA.
- Aucune réponse libre, aucun widget libre, aucun HTML/SVG/Mermaid n'est accepté.
- Aucun provider réel n'est appelé en test : `genkit`, `googleAI` et `openAICompatible` sont mockés.

## 9. Fichiers créés/modifiés/supprimés

### Créés

- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generation-profile.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generation-profile.spec.ts`
- `api/src/modules/activities/infrastructure/genkit-rich-closed-question.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-rich-closed-question.generator.spec.ts`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md`

### Modifiés

- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

### Supprimés

- Aucun fichier supprimé.

## 10. Tests ajoutés ou renforcés

- Profil de mix : exact 6 questions.
- Profil de mix : exact 10 questions.
- Profil de mix : somme exacte.
- Profil de mix : aucun type hors V1-A.
- Profil de mix : pas de domination `single_choice`.
- Profil de mix : petit exercice sans défaut `single_choice`.
- Profil de mix : rejet des tailles hors bornes.
- Générateur : import/constructeur sans initialisation Genkit.
- Générateur : succès Mistral mocké, prompt strict et metadata-only.
- Générateur : rejet type hors V1-A.
- Générateur : rejet 100 % `single_choice` par quality gate.
- Générateur : rejet `feedback` dans les choix IA.
- Générateur : rejet source inconnue.
- Générateur : rejet `cognitiveSkill` invalide.
- Générateur : rejet `multiple_choice` mal borné.
- Générateur : erreurs contrôlées sans fuite de payload.

## 11. Validations lancées avec résultats

- `npm test -- rich-closed-question-generation-profile --runInBand` : OK, 7 tests.
- `npm test -- genkit-rich-closed --runInBand` : OK, 9 tests.
- `npm test -- rich-closed --runInBand` : OK, 5 suites, 61 tests.
- `npm test -- activities --runInBand` : OK, 14 suites passées, 1 suite skipped, 148 tests passés, 1 test skipped.
- `npm run lint:check` : OK après correction manuelle de style, sans `--fix`.
- `npm run build` : OK.
- `git diff --check` depuis `api` : OK.
- `git diff --check` depuis `revision_app` : OK.

## 12. Validations non lancées avec justification

- `npm run lint` : interdit, applique `--fix`.
- `npm run format` : interdit.
- `npm run test:cov` : interdit et hors périmètre.
- `npx prisma db push`, `npx prisma migrate reset`, `npx prisma migrate deploy` : interdits, aucune modification Prisma.
- Tests Flutter : non lancés, aucun code Flutter modifié.
- Provider IA réel : non lancé, tests mockés.
- Seed réel : non lancé, hors périmètre.

## 13. Risques restants

- Le générateur n'est pas encore branché à un use case public : V1-007/V1-008 devront décider où persister et exposer le résultat.
- Le prompt est strict mais devra être éprouvé sur un provider réel contrôlé avant démo V1.
- La conformité au `questionTypeMix` est vérifiée après les quality gates ; c'est volontaire pour que les gates attrapent les sorties pédagogiquement pauvres, mais V1-007/V1-008 devront conserver cette séquence.
- Les futurs types V1-B/C restent exclus du schema et devront être ajoutés explicitement.

## 14. Recommandation prochain lot

Poursuivre avec `V1-007 — Persistance minimale V1-A`. Je ne recommande pas de micro-bis immédiat : le générateur est isolé, mocké, validé, et les gates attrapent les dérives principales. Le lot suivant devra rester attentif au stockage séparé des corrections privées et au mapping public pré-submit.

## 15. Passes de review

- Architecture backend : port applicatif séparé, générateur infrastructure isolé, aucun controller ou repository modifié.
- Genkit/prompt/schema : prompt versionné, schema strict, provider mocké en tests, fallback configuré mais non testé contre un provider réel.
- Quality gates : `validateRichClosedExercise` et `evaluateRichClosedExerciseQuality` appliqués avant retour.
- Anti-fuite : logs/observer metadata-only, erreurs contrôlées, pas de payload public avec correction.
- Scope : aucune modification Prisma, endpoint public, Flutter, Today, revision sessions ou seed.

Tentative sub-agent réalisée dans ce lot : `spawn_agent` a échoué avec `agent thread limit reached`. Les passes ci-dessus ont donc été réalisées manuellement.

## 16. Critique honnête du prompt initial

Le prompt est bien découpé : séparer Genkit de la persistance évite de mélanger qualité de génération et stockage. Les exigences sont fortes mais cohérentes avec le risque du prochain branchement IA. Le seul point légèrement tendu est la demande de rapport avec contenu complet, qui gonfle fortement la doc ; pour un lot de contrat/prompt/schema, c'est néanmoins utile pour review autonome.

## 17. Contenu complet des fichiers créés/modifiés/supprimés pour review

### `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_006_GENKIT_RICH_CLOSED_V1A.md`

Le présent document est le rapport créé. Son contenu complet correspond à ce fichier.

### `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generator.ts`

```ts
import type {
  RichClosedExercise,
  RichClosedQuestionKind,
} from './rich-closed-question.types';

export type RichClosedComplexityProfile = 'standard' | 'exam' | 'advanced';

export interface RichClosedQuestionGenerationInput {
  studentId: string;
  subjectId: string;
  documentId?: string | null;
  knowledgeUnit: {
    id: string;
    subjectId: string;
    title: string;
    summary: string;
    difficulty?: 'LOW' | 'MEDIUM' | 'HIGH' | null;
    sourceChunkIds?: string[];
  };
  chunks: Array<{
    id: string;
    index: number;
    text: string;
    pageNumber: number | null;
  }>;
  questionCount: number;
  questionTypeMix: Partial<Record<RichClosedQuestionKind, number>>;
  complexityProfile: RichClosedComplexityProfile;
}

export interface RichClosedQuestionGenerationMetadata {
  flowName: string;
  provider: string;
  model: string;
  promptVersion: string;
  schemaVersion: string;
  inputSize: number;
}

export type GeneratedRichClosedExercise = RichClosedExercise & {
  metadata?: RichClosedQuestionGenerationMetadata;
};

export const RICH_CLOSED_QUESTION_GENERATOR = Symbol(
  'RICH_CLOSED_QUESTION_GENERATOR',
);

export interface RichClosedQuestionGenerator {
  generate(
    input: RichClosedQuestionGenerationInput,
  ): Promise<GeneratedRichClosedExercise>;
}
```

### `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generation-profile.ts`

```ts
import {
  RICH_CLOSED_QUESTION_KINDS,
  type RichClosedQuestionKind,
} from './rich-closed-question.types';
import type { RichClosedComplexityProfile } from './rich-closed-question-generator';

export const RICH_CLOSED_QUESTION_COUNT_INVALID =
  'RICH_CLOSED_QUESTION_COUNT_INVALID';

const MIN_QUESTION_COUNT = 1;
const MAX_QUESTION_COUNT = 20;
const MAX_SINGLE_CHOICE_RATIO = 0.4;

const SMALL_EXERCISE_KIND_ORDER: RichClosedQuestionKind[] = [
  'case_qualification',
  'error_detection',
  'matching',
  'ordering',
  'multiple_choice',
];

const FULL_EXERCISE_BASE_MIX: Record<RichClosedQuestionKind, number> = {
  single_choice: 1,
  multiple_choice: 1,
  matching: 1,
  ordering: 1,
  case_qualification: 1,
  error_detection: 1,
};

const DISTRIBUTION_ORDER_BY_PROFILE: Record<
  RichClosedComplexityProfile,
  RichClosedQuestionKind[]
> = {
  standard: [
    'case_qualification',
    'error_detection',
    'matching',
    'multiple_choice',
    'ordering',
    'single_choice',
  ],
  exam: [
    'case_qualification',
    'error_detection',
    'matching',
    'multiple_choice',
    'ordering',
    'single_choice',
  ],
  advanced: [
    'case_qualification',
    'error_detection',
    'ordering',
    'matching',
    'multiple_choice',
    'single_choice',
  ],
};

export interface RichClosedQuestionTypeMixInput {
  questionCount: number;
  complexityProfile?: RichClosedComplexityProfile;
}

export function resolveRichClosedQuestionTypeMix(
  input: RichClosedQuestionTypeMixInput,
): Record<RichClosedQuestionKind, number> {
  if (
    !Number.isInteger(input.questionCount) ||
    input.questionCount < MIN_QUESTION_COUNT ||
    input.questionCount > MAX_QUESTION_COUNT
  ) {
    throw new Error(RICH_CLOSED_QUESTION_COUNT_INVALID);
  }

  if (input.questionCount < RICH_CLOSED_QUESTION_KINDS.length) {
    return buildSmallExerciseMix(input.questionCount);
  }

  const mix = { ...FULL_EXERCISE_BASE_MIX };
  const profile = input.complexityProfile ?? 'standard';
  let remaining = input.questionCount - RICH_CLOSED_QUESTION_KINDS.length;
  let cursor = 0;

  while (remaining > 0) {
    const kind = DISTRIBUTION_ORDER_BY_PROFILE[profile][cursor];
    if (
      kind !== 'single_choice' ||
      (mix.single_choice + 1) / input.questionCount <= MAX_SINGLE_CHOICE_RATIO
    ) {
      mix[kind] += 1;
      remaining -= 1;
    }
    cursor = (cursor + 1) % DISTRIBUTION_ORDER_BY_PROFILE[profile].length;
  }

  return mix;
}

function buildSmallExerciseMix(
  questionCount: number,
): Record<RichClosedQuestionKind, number> {
  const mix = emptyMix();

  for (let index = 0; index < questionCount; index += 1) {
    mix[SMALL_EXERCISE_KIND_ORDER[index]] += 1;
  }

  return mix;
}

function emptyMix(): Record<RichClosedQuestionKind, number> {
  return {
    single_choice: 0,
    multiple_choice: 0,
    matching: 0,
    ordering: 0,
    case_qualification: 0,
    error_detection: 0,
  };
}
```

### `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-generation-profile.spec.ts`

```ts
import {
  RICH_CLOSED_QUESTION_KINDS,
  type RichClosedQuestionKind,
} from './rich-closed-question.types';
import {
  RICH_CLOSED_QUESTION_COUNT_INVALID,
  resolveRichClosedQuestionTypeMix,
} from './rich-closed-question-generation-profile';

describe('rich closed question generation profile', () => {
  it('returns the exact balanced V1-A mix for six questions', () => {
    expect(resolveRichClosedQuestionTypeMix({ questionCount: 6 })).toEqual({
      single_choice: 1,
      multiple_choice: 1,
      matching: 1,
      ordering: 1,
      case_qualification: 1,
      error_detection: 1,
    });
  });

  it('returns the expected exam-style mix for ten questions', () => {
    expect(
      resolveRichClosedQuestionTypeMix({
        questionCount: 10,
        complexityProfile: 'exam',
      }),
    ).toEqual({
      case_qualification: 2,
      error_detection: 2,
      matching: 2,
      ordering: 1,
      multiple_choice: 2,
      single_choice: 1,
    });
  });

  it('always sums exactly to the requested question count', () => {
    for (const questionCount of [1, 3, 6, 7, 10, 13, 20]) {
      const mix = resolveRichClosedQuestionTypeMix({ questionCount });

      expect(sumMix(mix)).toBe(questionCount);
    }
  });

  it('never returns a type outside V1-A', () => {
    const mix = resolveRichClosedQuestionTypeMix({ questionCount: 12 });
    const allowedKinds = new Set<string>(RICH_CLOSED_QUESTION_KINDS);

    expect(Object.keys(mix).every((kind) => allowedKinds.has(kind))).toBe(true);
  });

  it('does not let single_choice dominate generated exercises', () => {
    const mix = resolveRichClosedQuestionTypeMix({ questionCount: 12 });

    expect((mix.single_choice ?? 0) / 12).toBeLessThanOrEqual(0.4);
  });

  it('treats small question counts as rich closed exercises without defaulting to single_choice', () => {
    const mix = resolveRichClosedQuestionTypeMix({ questionCount: 3 });

    expect(sumMix(mix)).toBe(3);
    expect(mix.single_choice ?? 0).toBe(0);
    expect((mix.case_qualification ?? 0) + (mix.error_detection ?? 0)).toBe(2);
  });

  it('rejects unsupported question counts explicitly', () => {
    expect(() =>
      resolveRichClosedQuestionTypeMix({ questionCount: 0 }),
    ).toThrow(RICH_CLOSED_QUESTION_COUNT_INVALID);
    expect(() =>
      resolveRichClosedQuestionTypeMix({ questionCount: 21 }),
    ).toThrow(RICH_CLOSED_QUESTION_COUNT_INVALID);
  });
});

function sumMix(mix: Partial<Record<RichClosedQuestionKind, number>>): number {
  return Object.values(mix).reduce((total, count) => total + count, 0);
}
```

### `api/src/modules/activities/infrastructure/genkit-rich-closed-question.generator.ts`

```ts
import { Inject, Injectable, Logger } from '@nestjs/common';
import { genkit, z } from 'genkit';
import {
  AI_GENERATION_OBSERVER,
  type AiGenerationObserver,
  noopAiGenerationObserver,
} from '../../ai/application/ai-generation-observer';
import {
  type ResolvedArtifactGenkitMetadata,
  resolveArtifactGenkitConfig,
  resolveArtifactGenkitMetadata,
  resolveArtifactMistralFallbackMetadata,
} from '../../ai/infrastructure/document-artifact-genkit-config';
import { isInvalidAiOutputError } from '../../ai/infrastructure/mistral-model-fallback';
import { evaluateRichClosedExerciseQuality } from '../application/rich-closed-questions/rich-closed-question-quality-gate';
import {
  validateRichClosedExercise,
  type RichClosedQuestionValidationOptions,
} from '../application/rich-closed-questions/rich-closed-question.validator';
import {
  RICH_CLOSED_EXERCISE_VERSION,
  RICH_CLOSED_QUESTION_KINDS,
  type RichClosedExercise,
  type RichClosedExerciseValidationIssue,
  type RichClosedQuestionKind,
} from '../application/rich-closed-questions/rich-closed-question.types';
import type {
  GeneratedRichClosedExercise,
  RichClosedQuestionGenerationInput,
  RichClosedQuestionGenerator,
} from '../application/rich-closed-questions/rich-closed-question-generator';
import {
  RICH_CLOSED_QUESTION_COUNT_INVALID,
  resolveRichClosedQuestionTypeMix,
} from '../application/rich-closed-questions/rich-closed-question-generation-profile';

export const RICH_CLOSED_FLOW_NAME = 'richClosedQuestionGeneration';
export const RICH_CLOSED_PROMPT_VERSION = 'rich-closed-v1a-001';
export const RICH_CLOSED_SCHEMA_VERSION = RICH_CLOSED_EXERCISE_VERSION;
export const RICH_CLOSED_GENERATION_FAILED = 'RICH_CLOSED_GENERATION_FAILED';
export const RICH_CLOSED_GENERATION_SCHEMA_INVALID =
  'RICH_CLOSED_GENERATION_SCHEMA_INVALID';
export const RICH_CLOSED_GENERATION_CONTRACT_INVALID =
  'RICH_CLOSED_GENERATION_CONTRACT_INVALID';
export const RICH_CLOSED_GENERATION_QUALITY_REJECTED =
  'RICH_CLOSED_GENERATION_QUALITY_REJECTED';
export const RICH_CLOSED_GENERATION_SOURCE_INVALID =
  'RICH_CLOSED_GENERATION_SOURCE_INVALID';

const DEFAULT_MAX_CHUNKS = 8;
const DEFAULT_MAX_CHARS = 8000;
const MAX_QUESTION_COUNT = 20;

const NonEmptyStringSchema = z.string().trim().min(1);
const DifficultySchema = z.enum(['LOW', 'MEDIUM', 'HIGH']);
const SourceChunkIdsSchema = z.array(NonEmptyStringSchema).min(1);

const ChoiceSchema = z
  .object({
    id: NonEmptyStringSchema,
    label: NonEmptyStringSchema,
  })
  .strict();

const LabelItemSchema = z
  .object({
    id: NonEmptyStringSchema,
    label: NonEmptyStringSchema,
  })
  .strict();

const PairSchema = z
  .object({
    leftId: NonEmptyStringSchema,
    rightId: NonEmptyStringSchema,
  })
  .strict();

const QuestionBaseSchema = {
  id: NonEmptyStringSchema,
  prompt: z.string().trim().min(8),
  difficulty: DifficultySchema,
  cognitiveSkill: NonEmptyStringSchema,
  sourceChunkIds: SourceChunkIdsSchema,
};

const SingleChoiceQuestionSchema = z
  .object({
    ...QuestionBaseSchema,
    questionKind: z.literal('single_choice'),
    choices: z.array(ChoiceSchema).min(2).max(6),
    correctChoiceId: NonEmptyStringSchema,
    explanation: z.string().trim().min(8),
  })
  .strict();

const MultipleChoiceQuestionSchema = z
  .object({
    ...QuestionBaseSchema,
    questionKind: z.literal('multiple_choice'),
    choices: z.array(ChoiceSchema).min(2).max(6),
    minSelections: z.number().int().min(1),
    maxSelections: z.number().int().min(1),
    correctChoiceIds: z.array(NonEmptyStringSchema).min(2),
    explanation: z.string().trim().min(8),
  })
  .strict();

const MatchingQuestionSchema = z
  .object({
    ...QuestionBaseSchema,
    questionKind: z.literal('matching'),
    leftItems: z.array(LabelItemSchema).min(3),
    rightItems: z.array(LabelItemSchema).min(3),
    correctPairs: z.array(PairSchema).min(3),
    explanation: z.string().trim().min(8),
  })
  .strict();

const OrderingQuestionSchema = z
  .object({
    ...QuestionBaseSchema,
    questionKind: z.literal('ordering'),
    items: z.array(LabelItemSchema).min(3),
    correctOrder: z.array(NonEmptyStringSchema).min(3),
    explanation: z.string().trim().min(8),
  })
  .strict();

const CaseQualificationQuestionSchema = z
  .object({
    ...QuestionBaseSchema,
    questionKind: z.literal('case_qualification'),
    caseText: z.string().trim().min(8).max(900),
    choices: z.array(ChoiceSchema).min(2).max(6),
    correctChoiceId: NonEmptyStringSchema,
    explanation: z.string().trim().min(8),
  })
  .strict();

const ErrorDetectionQuestionSchema = z
  .object({
    ...QuestionBaseSchema,
    questionKind: z.literal('error_detection'),
    statement: z.string().trim().min(8).max(900),
    errorOptions: z.array(ChoiceSchema).min(2).max(6),
    correctErrorId: NonEmptyStringSchema,
    explanation: z.string().trim().min(8),
  })
  .strict();

const RichClosedQuestionSchema = z.discriminatedUnion('questionKind', [
  SingleChoiceQuestionSchema,
  MultipleChoiceQuestionSchema,
  MatchingQuestionSchema,
  OrderingQuestionSchema,
  CaseQualificationQuestionSchema,
  ErrorDetectionQuestionSchema,
]);

const GeneratedRichClosedExerciseSchema = z
  .object({
    id: NonEmptyStringSchema,
    version: z.literal(RICH_CLOSED_EXERCISE_VERSION),
    title: NonEmptyStringSchema,
    subjectId: NonEmptyStringSchema,
    documentId: NonEmptyStringSchema.nullable(),
    knowledgeUnitId: NonEmptyStringSchema,
    questions: z.array(RichClosedQuestionSchema).min(1).max(MAX_QUESTION_COUNT),
  })
  .strict();

type RichClosedPromptChunk = {
  id: string;
  index: number;
  text: string;
  pageNumber: number | null;
};

@Injectable()
export class GenkitRichClosedQuestionGenerator implements RichClosedQuestionGenerator {
  private readonly logger = new Logger(GenkitRichClosedQuestionGenerator.name);
  private readonly aiByModel = new Map<string, ReturnType<typeof genkit>>();
  private resolvedMetadata?: ResolvedArtifactGenkitMetadata;

  constructor(
    @Inject(AI_GENERATION_OBSERVER)
    private readonly observer: AiGenerationObserver = noopAiGenerationObserver,
  ) {}

  async generate(
    input: RichClosedQuestionGenerationInput,
  ): Promise<GeneratedRichClosedExercise> {
    const primaryMetadata = this.resolveMetadata();
    const fallbackMetadata = resolveArtifactMistralFallbackMetadata(
      primaryMetadata,
      'MISTRAL_RICH_CLOSED_FALLBACK_MODEL',
    );
    const attempts = fallbackMetadata
      ? [primaryMetadata, fallbackMetadata]
      : [primaryMetadata];
    const chunks = selectRichClosedChunks(input);
    const questionTypeMix = resolveRequestedQuestionTypeMix(input);
    const prompt = buildRichClosedPrompt({
      input,
      chunks,
      questionTypeMix,
    });
    const inputSize = prompt.length;

    this.logger.log(
      JSON.stringify(
        buildRichClosedContextLog({
          input,
          chunks,
          metadata: primaryMetadata,
          inputSize,
          questionTypeMix,
        }),
      ),
    );

    for (const [index, metadata] of attempts.entries()) {
      const startedAt = Date.now();

      try {
        const { output } = await this.getAi(metadata).generate({
          prompt,
          output: {
            schema: GeneratedRichClosedExerciseSchema,
          },
        });
        const exercise = normalizeGeneratedRichClosedExercise({
          output,
          input,
          chunks,
          metadata,
          inputSize,
          questionTypeMix,
        });

        this.logger.log(
          JSON.stringify(
            buildRichClosedOutputLog({ input, exercise, metadata }),
          ),
        );

        this.observer.observe({
          flowName: RICH_CLOSED_FLOW_NAME,
          provider: metadata.provider,
          model: metadata.model,
          promptVersion: RICH_CLOSED_PROMPT_VERSION,
          schemaVersion: RICH_CLOSED_SCHEMA_VERSION,
          inputSize,
          durationMs: Date.now() - startedAt,
          status: 'success',
          documentId: input.documentId ?? undefined,
          knowledgeUnitId: input.knowledgeUnit.id,
          subjectId: input.subjectId,
          studentId: input.studentId,
        });

        return exercise;
      } catch (error) {
        const controlledError = toRichClosedGenerationError(error);

        this.logger.warn(
          JSON.stringify(
            buildRichClosedErrorLog({
              input,
              metadata,
              errorCode: controlledError.code,
            }),
          ),
        );

        this.observer.observe({
          flowName: RICH_CLOSED_FLOW_NAME,
          provider: metadata.provider,
          model: metadata.model,
          promptVersion: RICH_CLOSED_PROMPT_VERSION,
          schemaVersion: RICH_CLOSED_SCHEMA_VERSION,
          inputSize,
          durationMs: Date.now() - startedAt,
          status: 'error',
          errorCode: controlledError.code,
          documentId: input.documentId ?? undefined,
          knowledgeUnitId: input.knowledgeUnit.id,
          subjectId: input.subjectId,
          studentId: input.studentId,
        });

        if (
          index === 0 &&
          attempts.length > 1 &&
          isInvalidAiOutputError(controlledError, [
            RICH_CLOSED_GENERATION_SCHEMA_INVALID,
            RICH_CLOSED_GENERATION_CONTRACT_INVALID,
            RICH_CLOSED_GENERATION_QUALITY_REJECTED,
            RICH_CLOSED_GENERATION_SOURCE_INVALID,
          ])
        ) {
          continue;
        }

        throw controlledError;
      }
    }

    throw new RichClosedQuestionGenerationError(RICH_CLOSED_GENERATION_FAILED);
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

export class RichClosedQuestionGenerationError extends Error {
  constructor(readonly code: string) {
    super(code);
    this.name = 'RichClosedQuestionGenerationError';
  }
}

function normalizeGeneratedRichClosedExercise(input: {
  output: unknown;
  input: RichClosedQuestionGenerationInput;
  chunks: RichClosedPromptChunk[];
  metadata: ResolvedArtifactGenkitMetadata;
  inputSize: number;
  questionTypeMix: Record<RichClosedQuestionKind, number>;
}): GeneratedRichClosedExercise {
  const parsed = parseRichClosedGenerationOutput(input.output);
  const exercise: RichClosedExercise = {
    id: parsed.id,
    version: parsed.version,
    title: parsed.title,
    subjectId: input.input.subjectId,
    documentId: input.input.documentId ?? null,
    knowledgeUnitId: input.input.knowledgeUnit.id,
    questions: parsed.questions,
  };
  const knownSourceChunkIds = new Set(input.chunks.map((chunk) => chunk.id));

  if (exercise.questions.length !== input.input.questionCount) {
    throw new RichClosedQuestionGenerationError(
      RICH_CLOSED_GENERATION_CONTRACT_INVALID,
    );
  }

  assertValidContract(exercise, { knownSourceChunkIds });
  assertAcceptedQuality(exercise, { knownSourceChunkIds });

  if (!matchesQuestionTypeMix(exercise, input.questionTypeMix)) {
    throw new RichClosedQuestionGenerationError(
      RICH_CLOSED_GENERATION_CONTRACT_INVALID,
    );
  }

  return {
    ...exercise,
    metadata: {
      flowName: RICH_CLOSED_FLOW_NAME,
      provider: input.metadata.provider,
      model: input.metadata.model,
      promptVersion: RICH_CLOSED_PROMPT_VERSION,
      schemaVersion: RICH_CLOSED_SCHEMA_VERSION,
      inputSize: input.inputSize,
    },
  };
}

function parseRichClosedGenerationOutput(output: unknown): RichClosedExercise {
  if (output === undefined || output === null) {
    throw new RichClosedQuestionGenerationError(
      RICH_CLOSED_GENERATION_SCHEMA_INVALID,
    );
  }

  try {
    return GeneratedRichClosedExerciseSchema.parse(
      output,
    ) as RichClosedExercise;
  } catch {
    throw new RichClosedQuestionGenerationError(
      RICH_CLOSED_GENERATION_SCHEMA_INVALID,
    );
  }
}

function assertValidContract(
  exercise: RichClosedExercise,
  options: RichClosedQuestionValidationOptions,
) {
  const validation = validateRichClosedExercise(exercise, options);

  if (validation.accepted) {
    return;
  }

  throw new RichClosedQuestionGenerationError(
    hasSourceIssue(validation.issues)
      ? RICH_CLOSED_GENERATION_SOURCE_INVALID
      : RICH_CLOSED_GENERATION_CONTRACT_INVALID,
  );
}

function assertAcceptedQuality(
  exercise: RichClosedExercise,
  options: RichClosedQuestionValidationOptions,
) {
  const quality = evaluateRichClosedExerciseQuality(exercise, options);

  if (quality.accepted) {
    return;
  }

  throw new RichClosedQuestionGenerationError(
    hasSourceIssue(quality.issues)
      ? RICH_CLOSED_GENERATION_SOURCE_INVALID
      : RICH_CLOSED_GENERATION_QUALITY_REJECTED,
  );
}

function hasSourceIssue(issues: RichClosedExerciseValidationIssue[]): boolean {
  return issues.some((issue) => issue.code.includes('SOURCE'));
}

function matchesQuestionTypeMix(
  exercise: RichClosedExercise,
  questionTypeMix: Record<RichClosedQuestionKind, number>,
): boolean {
  const actualCounts = Object.fromEntries(
    RICH_CLOSED_QUESTION_KINDS.map((kind) => [kind, 0]),
  ) as Record<RichClosedQuestionKind, number>;

  for (const question of exercise.questions) {
    actualCounts[question.questionKind] += 1;
  }

  return RICH_CLOSED_QUESTION_KINDS.every(
    (kind) => actualCounts[kind] === questionTypeMix[kind],
  );
}

function resolveRequestedQuestionTypeMix(
  input: RichClosedQuestionGenerationInput,
): Record<RichClosedQuestionKind, number> {
  const fallbackMix = resolveRichClosedQuestionTypeMix({
    questionCount: input.questionCount,
    complexityProfile: input.complexityProfile,
  });
  const requestedEntries = Object.entries(input.questionTypeMix);

  if (requestedEntries.length === 0) {
    return fallbackMix;
  }

  const mix = { ...fallbackMix };
  for (const kind of RICH_CLOSED_QUESTION_KINDS) {
    mix[kind] = input.questionTypeMix[kind] ?? 0;
  }

  if (
    Object.values(mix).some((count) => !Number.isInteger(count) || count < 0) ||
    Object.values(mix).reduce((total, count) => total + count, 0) !==
      input.questionCount
  ) {
    throw new RichClosedQuestionGenerationError(
      RICH_CLOSED_GENERATION_CONTRACT_INVALID,
    );
  }

  return mix;
}

function buildRichClosedPrompt(input: {
  input: RichClosedQuestionGenerationInput;
  chunks: RichClosedPromptChunk[];
  questionTypeMix: Record<RichClosedQuestionKind, number>;
}): string {
  return [
    'Tu es un tuteur universitaire qui génère un exercice de questions fermées riches en français.',
    `Tu dois générer un exercice rich closed ${RICH_CLOSED_EXERCISE_VERSION}.`,
    'Tu dois respecter exactement les questionKind demandés.',
    'Tu dois respecter questionTypeMix.',
    `questionTypeMix: ${JSON.stringify(input.questionTypeMix)}`,
    'Tu dois produire uniquement les types V1-A: single_choice, multiple_choice, matching, ordering, case_qualification, error_detection.',
    'Tu dois produire des questions fermées.',
    'Tu dois interdire toute réponse libre.',
    'Tu dois utiliser les chunks fournis comme seule source de vérité.',
    'Tu dois référencer uniquement des sourceChunkIds existants.',
    'Tu dois inclure au moins une source par question quand des chunks existent.',
    'Tu dois produire des distracteurs plausibles mais non ambigus.',
    'Tu dois produire case_qualification avec un cas court et qualifiable.',
    'Tu dois produire error_detection avec une erreur dominante unique.',
    'Tu dois produire matching avec au moins 3 paires univoques.',
    'Tu dois produire ordering avec au moins 3 items et un ordre complet.',
    'Tu dois produire multiple_choice avec au moins 2 bonnes réponses.',
    'Tu dois éviter les questions de pure restitution.',
    'Tu dois éviter les prompts commençant par “Qui”, “Quand”, “Quelle date”, “Quelle est la définition”, sauf nécessité exceptionnelle.',
    'Tu dois produire des explications privées de correction.',
    'Tu ne dois jamais inclure de modelAnswer, answerText, freeTextAnswer, textAnswer, HTML, SVG, Mermaid, markdown rendu libre ou widget libre.',
    'Tu ne dois jamais produire de widget libre.',
    'Tu ne dois jamais produire true_false, true_false_grid, timeline, date_slider, image_choice, diagram_labeling, institution_matrix, cause_consequence, calculation_mcq ou fill_blank_dropdown.',
    'Tu dois retourner uniquement du JSON strict conforme au schema demandé.',
    `Prompt version: ${RICH_CLOSED_PROMPT_VERSION}.`,
    `Schema version: ${RICH_CLOSED_SCHEMA_VERSION}.`,
    `Question count: ${input.input.questionCount}.`,
    `Complexity profile: ${input.input.complexityProfile}.`,
    `Titre de la notion: ${input.input.knowledgeUnit.title}`,
    `Résumé de la notion: ${input.input.knowledgeUnit.summary}`,
    JSON.stringify(toPromptPayload(input.input, input.chunks)),
  ].join('\n\n');
}

function toPromptPayload(
  input: RichClosedQuestionGenerationInput,
  chunks: RichClosedPromptChunk[],
) {
  return {
    subjectId: input.subjectId,
    documentId: input.documentId ?? null,
    knowledgeUnit: {
      id: input.knowledgeUnit.id,
      subjectId: input.knowledgeUnit.subjectId,
      title: input.knowledgeUnit.title,
      summary: input.knowledgeUnit.summary,
      difficulty: input.knowledgeUnit.difficulty ?? null,
      sourceChunkIds: input.knowledgeUnit.sourceChunkIds ?? [],
    },
    allowedSourceChunkIds: chunks.map((chunk) => chunk.id),
    chunks: chunks.map((chunk) => ({
      id: chunk.id,
      index: chunk.index,
      pageNumber: chunk.pageNumber,
      text: chunk.text,
    })),
  };
}

function selectRichClosedChunks(
  input: RichClosedQuestionGenerationInput,
): RichClosedPromptChunk[] {
  const chunks = deduplicateChunks(input.chunks);
  const sourceChunkIds = new Set(input.knowledgeUnit.sourceChunkIds ?? []);
  const prioritizedChunks = [
    ...chunks.filter((chunk) => sourceChunkIds.has(chunk.id)),
    ...chunks.filter((chunk) => !sourceChunkIds.has(chunk.id)),
  ];
  const maxChunks = resolvePositiveInteger(
    process.env.RICH_CLOSED_GENERATION_MAX_CHUNKS,
    DEFAULT_MAX_CHUNKS,
  );
  const maxChars = resolvePositiveInteger(
    process.env.RICH_CLOSED_GENERATION_MAX_CHARS,
    DEFAULT_MAX_CHARS,
  );
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
  chunks: RichClosedQuestionGenerationInput['chunks'],
): RichClosedPromptChunk[] {
  const chunksById = new Map<
    string,
    RichClosedQuestionGenerationInput['chunks'][number]
  >();

  for (const chunk of chunks) {
    if (chunk.text.trim().length > 0 && !chunksById.has(chunk.id)) {
      chunksById.set(chunk.id, chunk);
    }
  }

  return [...chunksById.values()].sort(
    (left, right) => left.index - right.index,
  );
}

function buildRichClosedContextLog(input: {
  input: RichClosedQuestionGenerationInput;
  chunks: RichClosedPromptChunk[];
  metadata: ResolvedArtifactGenkitMetadata;
  inputSize: number;
  questionTypeMix: Record<RichClosedQuestionKind, number>;
}) {
  return {
    event: 'rich.closed.generation.context',
    flowName: RICH_CLOSED_FLOW_NAME,
    provider: input.metadata.provider,
    model: input.metadata.model,
    requestedQuestionCount: input.input.questionCount,
    questionTypeMix: input.questionTypeMix,
    complexityProfile: input.input.complexityProfile,
    providedChunkCount: input.input.chunks.length,
    selectedChunkCount: input.chunks.length,
    selectedChunkCharCount: input.chunks.reduce(
      (total, chunk) => total + chunk.text.length,
      0,
    ),
    inputSize: input.inputSize,
    documentId: input.input.documentId ?? undefined,
    subjectId: input.input.subjectId,
    knowledgeUnitId: input.input.knowledgeUnit.id,
    studentId: input.input.studentId,
  };
}

function buildRichClosedOutputLog(input: {
  input: RichClosedQuestionGenerationInput;
  exercise: GeneratedRichClosedExercise;
  metadata: ResolvedArtifactGenkitMetadata;
}) {
  const quality = evaluateRichClosedExerciseQuality(input.exercise);

  return {
    event: 'rich.closed.generation.output',
    flowName: RICH_CLOSED_FLOW_NAME,
    provider: input.metadata.provider,
    model: input.metadata.model,
    outputQuestionCount: input.exercise.questions.length,
    questionKindCounts: quality.metrics.questionKindCounts,
    difficultyCounts: quality.metrics.difficultyCounts,
    cognitiveSkillCounts: quality.metrics.cognitiveSkillCounts,
    sourcedQuestionCount: quality.metrics.sourcedQuestionCount,
    documentId: input.input.documentId ?? undefined,
    subjectId: input.input.subjectId,
    knowledgeUnitId: input.input.knowledgeUnit.id,
    studentId: input.input.studentId,
  };
}

function buildRichClosedErrorLog(input: {
  input: RichClosedQuestionGenerationInput;
  metadata: ResolvedArtifactGenkitMetadata;
  errorCode: string;
}) {
  return {
    event: 'rich.closed.generation.error',
    flowName: RICH_CLOSED_FLOW_NAME,
    provider: input.metadata.provider,
    model: input.metadata.model,
    errorCode: input.errorCode,
    documentId: input.input.documentId ?? undefined,
    subjectId: input.input.subjectId,
    knowledgeUnitId: input.input.knowledgeUnit.id,
    studentId: input.input.studentId,
  };
}

function resolvePositiveInteger(value: string | undefined, fallback: number) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    return fallback;
  }

  return parsed;
}

function toRichClosedGenerationError(
  error: unknown,
): RichClosedQuestionGenerationError {
  if (error instanceof RichClosedQuestionGenerationError) {
    return error;
  }

  if (
    error instanceof Error &&
    error.message === RICH_CLOSED_QUESTION_COUNT_INVALID
  ) {
    return new RichClosedQuestionGenerationError(
      RICH_CLOSED_GENERATION_CONTRACT_INVALID,
    );
  }

  if (
    error instanceof Error &&
    (error.name === 'ZodError' ||
      error.message.toLowerCase().includes('schema') ||
      error.message.toLowerCase().includes('json') ||
      error.message.toLowerCase().includes('output'))
  ) {
    return new RichClosedQuestionGenerationError(
      RICH_CLOSED_GENERATION_SCHEMA_INVALID,
    );
  }

  return new RichClosedQuestionGenerationError(RICH_CLOSED_GENERATION_FAILED);
}
```

### `api/src/modules/activities/infrastructure/genkit-rich-closed-question.generator.spec.ts`

```ts
type GenerateInput = {
  prompt: string;
  output: {
    schema: unknown;
  };
};

type GenkitInput = {
  plugins: unknown[];
  model: string;
};

type OpenAICompatibleInput = {
  name: string;
  apiKey?: string;
  baseURL?: string;
};

const mockMistralPlugin = { name: 'mistral-plugin' };
const mockGooglePlugin = { name: 'google-plugin' };
const mockGenerate = jest.fn<Promise<{ output?: unknown }>, [GenerateInput]>();
const mockGenkit = jest.fn<{ generate: typeof mockGenerate }, [GenkitInput]>(
  () => ({ generate: mockGenerate }),
);
const mockOpenAICompatible = jest.fn<unknown, [OpenAICompatibleInput]>(
  () => mockMistralPlugin,
);
const mockGoogleAI = jest.fn<unknown, []>(() => mockGooglePlugin);

jest.mock('genkit', () => ({
  ...jest.requireActual<typeof import('genkit')>('genkit'),
  genkit: mockGenkit,
}));

jest.mock('@genkit-ai/compat-oai', () => ({
  __esModule: true,
  default: mockOpenAICompatible,
  openAICompatible: mockOpenAICompatible,
}));

jest.mock('@genkit-ai/google-genai', () => ({
  googleAI: mockGoogleAI,
}));

import { Logger } from '@nestjs/common';
import {
  GenkitRichClosedQuestionGenerator,
  RICH_CLOSED_GENERATION_CONTRACT_INVALID,
  RICH_CLOSED_GENERATION_QUALITY_REJECTED,
  RICH_CLOSED_GENERATION_SCHEMA_INVALID,
  RICH_CLOSED_GENERATION_SOURCE_INVALID,
  RICH_CLOSED_PROMPT_VERSION,
} from './genkit-rich-closed-question.generator';
import {
  richClosedExerciseFixture,
  richClosedQuestionFixture,
} from '../application/rich-closed-questions/rich-closed-question.fixtures';
import type {
  AiGenerationObservation,
  AiGenerationObserver,
} from '../../ai/application/ai-generation-observer';
import type { RichClosedExercise } from '../application/rich-closed-questions/rich-closed-question.types';

describe('GenkitRichClosedQuestionGenerator', () => {
  const originalAiProvider = process.env.AI_PROVIDER;
  const originalMistralApiKey = process.env.MISTRAL_API_KEY;
  const originalMistralModel = process.env.MISTRAL_MODEL;
  const originalMistralFallbackModel = process.env.MISTRAL_FALLBACK_MODEL;
  const originalMistralRichClosedFallbackModel =
    process.env.MISTRAL_RICH_CLOSED_FALLBACK_MODEL;
  const originalGenkitModel = process.env.GENKIT_MODEL;
  const originalMaxChunks = process.env.RICH_CLOSED_GENERATION_MAX_CHUNKS;
  const originalMaxChars = process.env.RICH_CLOSED_GENERATION_MAX_CHARS;
  let loggerLogSpy: jest.SpyInstance;
  let loggerWarnSpy: jest.SpyInstance;

  beforeEach(() => {
    loggerLogSpy = jest
      .spyOn(Logger.prototype, 'log')
      .mockImplementation(() => undefined);
    loggerWarnSpy = jest
      .spyOn(Logger.prototype, 'warn')
      .mockImplementation(() => undefined);
  });

  afterEach(() => {
    restoreEnv('AI_PROVIDER', originalAiProvider);
    restoreEnv('MISTRAL_API_KEY', originalMistralApiKey);
    restoreEnv('MISTRAL_MODEL', originalMistralModel);
    restoreEnv('MISTRAL_FALLBACK_MODEL', originalMistralFallbackModel);
    restoreEnv(
      'MISTRAL_RICH_CLOSED_FALLBACK_MODEL',
      originalMistralRichClosedFallbackModel,
    );
    restoreEnv('GENKIT_MODEL', originalGenkitModel);
    restoreEnv('RICH_CLOSED_GENERATION_MAX_CHUNKS', originalMaxChunks);
    restoreEnv('RICH_CLOSED_GENERATION_MAX_CHARS', originalMaxChars);
    mockOpenAICompatible.mockClear();
    mockGoogleAI.mockClear();
    mockGenkit.mockClear();
    mockGenerate.mockReset();
    loggerLogSpy.mockRestore();
    loggerWarnSpy.mockRestore();
  });

  it('does not initialize Genkit when imported or constructed', () => {
    new GenkitRichClosedQuestionGenerator();

    expect(mockOpenAICompatible).not.toHaveBeenCalled();
    expect(mockGoogleAI).not.toHaveBeenCalled();
    expect(mockGenkit).not.toHaveBeenCalled();
    expect(mockGenerate).not.toHaveBeenCalled();
  });

  it('generates a validated V1-A rich closed exercise with metadata only observations', async () => {
    process.env.AI_PROVIDER = 'mistral';
    process.env.MISTRAL_API_KEY = 'test-mistral-key';
    mockGenerate.mockResolvedValue({ output: generatedExercise() });
    const observer = createObserver();

    const exercise = await new GenkitRichClosedQuestionGenerator(
      observer,
    ).generate(generationInput());

    expect(mockOpenAICompatible).toHaveBeenCalledWith({
      name: 'mistral',
      apiKey: 'test-mistral-key',
      baseURL: 'https://api.mistral.ai/v1',
    });
    expect(mockGenkit).toHaveBeenCalledWith({
      plugins: [mockMistralPlugin],
      model: 'mistral/mistral-small-latest',
    });
    const [generateInput] = mockGenerate.mock.calls[0] ?? [];
    expect(generateInput?.prompt).toContain('rich-closed-question-v1');
    expect(generateInput?.prompt).toContain('questionTypeMix');
    expect(generateInput?.prompt).toContain('single_choice');
    expect(generateInput?.prompt).toContain('case_qualification');
    expect(generateInput?.prompt).toContain('error_detection');
    expect(generateInput?.prompt).toContain(
      'Tu dois produire des questions fermées.',
    );
    expect(generateInput?.prompt).toContain(
      'Tu ne dois jamais inclure de modelAnswer',
    );
    expect(generateInput?.prompt).toContain(
      'Tu ne dois jamais produire de widget libre',
    );
    expect(generateInput?.output.schema).toBeDefined();
    expect(exercise).toMatchObject({
      id: 'rich-exercise-1',
      version: 'rich-closed-question-v1',
      metadata: {
        flowName: 'richClosedQuestionGeneration',
        provider: 'mistral',
        model: 'mistral/mistral-small-latest',
        promptVersion: RICH_CLOSED_PROMPT_VERSION,
        schemaVersion: 'rich-closed-question-v1',
      },
    });
    const observation = getObservedObservation(observer);
    expect(observation.status).toBe('success');
    expect(observation.flowName).toBe('richClosedQuestionGeneration');
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'SENTINEL_FULL_CHUNK_TEXT',
    );
    expect(JSON.stringify(observer.observe.mock.calls)).not.toContain(
      'test-mistral-key',
    );
  });

  it('rejects output with a question kind outside V1-A', async () => {
    mockGenerate.mockResolvedValue({
      output: {
        ...generatedExercise(),
        questions: [
          {
            ...richClosedQuestionFixture('single_choice'),
            questionKind: 'timeline',
          },
        ],
      },
    });
    const observer = createObserver();

    await expect(
      new GenkitRichClosedQuestionGenerator(observer).generate(
        generationInput(),
      ),
    ).rejects.toMatchObject({ code: RICH_CLOSED_GENERATION_SCHEMA_INVALID });

    expect(getObservedObservation(observer).errorCode).toBe(
      RICH_CLOSED_GENERATION_SCHEMA_INVALID,
    );
  });

  it('rejects output dominated by single_choice through the quality gate', async () => {
    mockGenerate.mockResolvedValue({
      output: {
        ...generatedExercise(),
        questions: Array.from({ length: 6 }, (_value, index) => ({
          ...richClosedQuestionFixture('single_choice'),
          id: `single-${index + 1}`,
          prompt: `Question de choix unique ${index + 1}`,
        })),
      },
    });

    await expect(
      new GenkitRichClosedQuestionGenerator().generate(generationInput()),
    ).rejects.toMatchObject({ code: RICH_CLOSED_GENERATION_QUALITY_REJECTED });
  });

  it('rejects output containing feedback on choices', async () => {
    const exercise = generatedExercise();
    const firstQuestion = exercise.questions[0];
    if (firstQuestion.questionKind !== 'single_choice') {
      throw new Error('Fixture first question must be single_choice');
    }
    mockGenerate.mockResolvedValue({
      output: {
        ...exercise,
        questions: [
          {
            ...firstQuestion,
            choices: [
              {
                ...firstQuestion.choices[0],
                feedback: 'Feedback privé interdit dans la sortie Genkit V1-A.',
              },
              ...firstQuestion.choices.slice(1),
            ],
          },
          ...exercise.questions.slice(1),
        ],
      },
    });

    await expect(
      new GenkitRichClosedQuestionGenerator().generate(generationInput()),
    ).rejects.toMatchObject({ code: RICH_CLOSED_GENERATION_SCHEMA_INVALID });
  });

  it('rejects output with unknown source chunks', async () => {
    mockGenerate.mockResolvedValue({
      output: {
        ...generatedExercise(),
        questions: [
          {
            ...richClosedQuestionFixture('single_choice'),
            sourceChunkIds: ['chunk-unknown'],
          },
          ...generatedExercise().questions.slice(1),
        ],
      },
    });

    await expect(
      new GenkitRichClosedQuestionGenerator().generate(generationInput()),
    ).rejects.toMatchObject({ code: RICH_CLOSED_GENERATION_SOURCE_INVALID });
  });

  it('rejects output with invalid cognitiveSkill through contract validation', async () => {
    mockGenerate.mockResolvedValue({
      output: {
        ...generatedExercise(),
        questions: [
          {
            ...richClosedQuestionFixture('single_choice'),
            cognitiveSkill: 'creative_writing',
          },
          ...generatedExercise().questions.slice(1),
        ],
      },
    });

    await expect(
      new GenkitRichClosedQuestionGenerator().generate(generationInput()),
    ).rejects.toMatchObject({ code: RICH_CLOSED_GENERATION_CONTRACT_INVALID });
  });

  it('rejects output with invalid multiple_choice bounds through contract validation', async () => {
    mockGenerate.mockResolvedValue({
      output: {
        ...generatedExercise(),
        questions: [
          richClosedQuestionFixture('single_choice'),
          {
            ...richClosedQuestionFixture('multiple_choice'),
            minSelections: 1,
            maxSelections: 1,
            correctChoiceIds: ['choice-a', 'choice-b'],
          },
          ...generatedExercise().questions.slice(2),
        ],
      },
    });

    await expect(
      new GenkitRichClosedQuestionGenerator().generate(generationInput()),
    ).rejects.toMatchObject({ code: RICH_CLOSED_GENERATION_CONTRACT_INVALID });
  });

  it('returns controlled errors without leaking generated payloads', async () => {
    mockGenerate.mockResolvedValue({
      output: {
        ...generatedExercise(),
        questions: [
          {
            ...richClosedQuestionFixture('single_choice'),
            sourceChunkIds: ['SENTINEL_SECRET_CHUNK'],
          },
          ...generatedExercise().questions.slice(1),
        ],
      },
    });

    await expect(
      new GenkitRichClosedQuestionGenerator().generate(generationInput()),
    ).rejects.toMatchObject({
      code: RICH_CLOSED_GENERATION_SOURCE_INVALID,
      message: RICH_CLOSED_GENERATION_SOURCE_INVALID,
    });

    await expect(
      new GenkitRichClosedQuestionGenerator().generate(generationInput()),
    ).rejects.not.toThrow('SENTINEL_SECRET_CHUNK');
  });
});

function generatedExercise(): RichClosedExercise {
  return richClosedExerciseFixture();
}

function generationInput() {
  return {
    studentId: 'student-1',
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnit: {
      id: 'unit-1',
      subjectId: 'subject-1',
      title: 'Régime parlementaire rationalisé',
      summary:
        'La responsabilité politique du gouvernement et les mécanismes de rationalisation encadrent les rapports entre Parlement et exécutif.',
      difficulty: 'MEDIUM' as const,
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
    questionCount: 6,
    questionTypeMix: {
      single_choice: 1,
      multiple_choice: 1,
      matching: 1,
      ordering: 1,
      case_qualification: 1,
      error_detection: 1,
    },
    complexityProfile: 'exam' as const,
  };
}

function createObserver() {
  return {
    observe: jest.fn<void, [AiGenerationObservation]>(),
  } satisfies AiGenerationObserver & {
    observe: jest.Mock<void, [AiGenerationObservation]>;
  };
}

function getObservedObservation(
  observer: ReturnType<typeof createObserver>,
): AiGenerationObservation {
  expect(observer.observe).toHaveBeenCalledTimes(1);

  return observer.observe.mock.calls[0][0];
}

function restoreEnv(key: string, value: string | undefined) {
  if (value === undefined) {
    delete process.env[key];
    return;
  }

  process.env[key] = value;
}
```

### `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

```md
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
| V1-007 | Persistance minimale V1-A | À faire | À créer |
| V1-008 | API publique pré-submit/post-submit V1-A | À faire | À créer |
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

Le contenu complet du plan est conservé dans le fichier. La modification V1-006 est limitée à la ligne du tableau ci-dessus et à la note suivante dans la section détaillée V1-006 :

`- Note V1-006 réalisé : le générateur reste non public, non persisté et non branché API.`
```
