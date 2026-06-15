# LOT V1-005B — Hardening contrat public et validators rich closed questions

## 1. Résultat

Le mini-lot V1-005B est réalisé. Le contrat applicatif rich closed questions V1-A a été durci avant V1-006 : les choix publics ne peuvent plus porter de `feedback`, le mapper public reste explicite, le quality gate bloque davantage de champs privés dans les payloads pré-submit, `cognitiveSkill` est validé contre une allowlist fermée, `multiple_choice` vérifie des bornes entières cohérentes, et l'heuristique des prompts basiques normalise maintenant les accents.

Aucun endpoint public, contrôleur, repository Prisma, flow Genkit, Prisma schema, migration, UI Flutter, Today, revision session ou seed n'a été modifié.

## 2. Sources inspectées

### API

- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.fixtures.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.spec.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`

### Documentation

- `revision_app/docs/v1/ADR_RICH_CLOSED_QUESTIONS_CONTRACT.md`
- `revision_app/docs/v1/RICH_CLOSED_QUESTIONS_PRISMA_DTO_VERSIONING_AUDIT.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_004_BACKEND_RICH_QUESTION_KINDS.md`
- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_005_PEDAGOGICAL_QUALITY_GATES.md`

## 3. Préflight Git

### API

- Repo : `/Users/karim/Project/app-révision/api`
- Branche : `main`
- Statut initial : `## main...origin/main`
- Fichiers modifiés/non suivis initiaux : aucun fichier listé par `git status --short --branch --untracked-files=all`.
- Derniers commits initiaux :
  - `8c402a7 #37-1: ajoute gestion des questions fermées enrichies`
  - `e552c75 #36-1: ajoute tests e2e pour les chemins critiques`
  - `b1d2318 #35-1: ajoute script de démo et données de seed`
  - `a08fd4e #34-1: améliore planification adaptative et plan du jour`
  - `783a728 #33-1: ajoute coach de révision et sélection d'actions`

### revision_app

- Repo : `/Users/karim/Project/app-révision/revision_app`
- Branche : `main`
- Statut initial : `## main...origin/main`
- Fichiers modifiés/non suivis initiaux : aucun fichier listé par `git status --short --branch --untracked-files=all`.
- Derniers commits initiaux :
  - `75bda98 LOT_V1_002_005 - Ajout ADR, audit DTO Prisma, roadmap V1 (lots 002 à 005 : rich questions, backend, qualité pédagogique)`
  - `2667c30 LOT_038_V1 - Ajout documentation V1 (README, catalogues de questions, roadmap et exemples)`
  - `b45b6ab LOT_038_DEMO_DEPLOYMENT_RUNBOOK - Mise à jour runbooks démo et ajout rapport LOT_038`
  - `b31b17c LOT_037_E2E_SMOKE_CHECKS - Mise à jour plan d'exécution, ajout rapport LOT_037 et checks smoke démo`
  - `10fd329 LOT_036_DEMO_SEED_FIXTURES - Mise à jour plan d'exécution, ajout rapport LOT_036 et runbook de seed démo`

## 4. Périmètre réalisé

- Ajout de `RichClosedPublicChoice` pour séparer explicitement les choix publics des choix internes.
- Remplacement du type public à base de `Omit<...>` par des interfaces publiques explicites par `questionKind`.
- Typage explicite de `publicChoices()` en `RichClosedPublicChoice[]`.
- Ajout de `RICH_CLOSED_COGNITIVE_SKILLS` et validation stricte de `cognitiveSkill`.
- Durcissement des bornes `minSelections` / `maxSelections` de `multiple_choice`.
- Enrichissement du scan anti-fuite public pré-submit.
- Normalisation accent-insensible de l'heuristique des prompts basiques.
- Renforcement des tests unitaires rich closed.
- Ajout de la ligne et de la section V1-005B dans le plan V1.
- Création du présent rapport dans `docs/v1`.

## 5. Problèmes corrigés

### Public choices sans feedback

Les choix internes peuvent toujours porter `feedback` pour la correction post-submit future. Les choix publics utilisent désormais `RichClosedPublicChoice`, limité à `id` et `label`. Le type `RichClosedPublicQuestion` n'autorise plus structurellement `choices: RichClosedChoice[]`.

### Scan anti-fuite enrichi

Le quality gate bloque récursivement les clés privées ou semi-privées suivantes dans un payload public pré-submit : toute clé commençant par `correct`, `correctionPayload`, `explanation`, `feedback`, `choiceFeedback`, `modelAnswer`, `answerText`, `freeTextAnswer`, `textAnswer`, `score`, `partialScore`, `workedSteps`, `expectedAnswer`, `expectedAnswers`.

### cognitiveSkill strict

`cognitiveSkill` n'est plus une simple string non vide. Le validator accepte uniquement l'allowlist V1-A : `memorization`, `comprehension`, `comparison`, `classification`, `case_application`, `procedure`, `error_detection`, `causality`.

### multiple_choice bounds

`multiple_choice` vérifie maintenant que `minSelections` et `maxSelections` sont des entiers, que `minSelections >= 1`, que `maxSelections >= minSelections`, que `maxSelections <= choices.length`, que le nombre de corrections est au moins 2, sans doublon, et compris entre `minSelections` et `maxSelections`.

### Normalisation de l'heuristique basique

Le détecteur de prompts basiques normalise en lowercase français, retire les diacritiques, normalise les apostrophes et compacte les espaces. Il détecte donc `définition` et `definition` sans rendre la règle plus agressive.

## 6. Fichiers créés/modifiés/supprimés

### Créé

- `revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md`

### Modifiés

- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.spec.ts`
- `api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.spec.ts`
- `revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md`

### Supprimés

- Aucun fichier supprimé.

## 7. Tests ajoutés ou renforcés

- Mapper public : vérification qu'un choix interne avec `feedback` est sérialisé sans `feedback` ni texte de feedback.
- Mapper public : les six kinds V1-A restent mappés sans correction privée.
- Validator : rejet d'un `cognitiveSkill` hors allowlist.
- Validator : acceptation d'un `cognitiveSkill` autorisé.
- Validator : rejet des bornes `multiple_choice` décimales.
- Validator : rejet des bornes `multiple_choice` incompatibles avec le nombre de réponses correctes.
- Validator : acceptation des bornes `multiple_choice` cohérentes.
- Quality gate : rejet de `feedback`, `choiceFeedback`, `modelAnswer`, `answerText`, `workedSteps` dans un payload public nested.
- Quality gate : détection des prompts `définition` et `definition`.

## 8. Validations lancées avec résultats

- `npm test -- rich-closed --runInBand` depuis `api` : OK, 3 suites passées, 45 tests passés.
- `npm test -- activities --runInBand` depuis `api` : OK, 12 suites passées, 1 suite skipped, 132 tests passés, 1 test skipped.
- `npm run lint:check` depuis `api` : OK.
- `npm run build` depuis `api` : OK.
- `git diff --check` depuis `api` : OK avant et après création du rapport.
- `git diff --check` depuis `revision_app` : OK avant et après création du rapport.

## 9. Validations non lancées avec justification

- `npm run lint` : interdit, car ce script applique `--fix`.
- `npm run format` : interdit.
- `npm run test:cov` : hors périmètre et interdit.
- `npx prisma db push`, `npx prisma migrate reset`, `npx prisma migrate deploy` : interdits, aucune modification Prisma.
- Tests Flutter : non lancés, aucun code Flutter applicatif ni test Flutter n'a été modifié.
- Seed réel : non lancé, hors périmètre et interdit.
- Provider IA / Genkit réel : non lancé, hors périmètre.

## 10. Risques restants

- Le contrat reste purement applicatif et non branché à Genkit, Prisma ou API publique ; V1-006 devra respecter strictement cette allowlist et ces gates.
- Le scan anti-fuite reste une défense récursive par noms de clés ; il doit rester accompagné de types publics explicites et de tests.
- L'heuristique de prompt basique est volontairement simple : elle signale les prompts trop restitutionnels sans prétendre juger toute la qualité pédagogique.
- Les futurs types V1-B/C devront étendre l'allowlist et les gates avec la même rigueur, sans réintroduire des champs semi-privés dans le public.

## 11. Recommandation prochain lot

Poursuivre avec `V1-006 — Génération Genkit rich closed questions V1-A`, en branchant Genkit uniquement sur le contrat durci et en appliquant les quality gates avant toute sortie persistée ou exposée.

## 12. Passes de review

- Anti-fuite : vérifié que les types publics, mapper et quality gate bloquent `feedback`, `correct*`, `modelAnswer`, `answerText`, `workedSteps` et champs assimilés.
- Typing public : vérifié que `RichClosedPublicChoice` remplace les choix internes dans tous les types publics pré-submit.
- Validator : vérifié allowlist `cognitiveSkill` et bornes `multiple_choice`.
- Quality gate : vérifié scan récursif, métriques existantes et normalisation accent-insensible.
- Scope : vérifié aucune modification Prisma, Genkit runtime, endpoint public, Flutter UI, Today, revision sessions ou seed.

Tentative sub-agent : l'outil multi-agent est disponible, mais `spawn_agent` a échoué avec `agent thread limit reached`. Les passes ci-dessus ont donc été simulées manuellement, conformément au fallback prévu par le prompt.

## 13. Critique honnête du prompt initial

Le prompt était précis et utile pour fermer les ambiguïtés avant V1-006. Les points les plus importants étaient bien identifiés : `feedback` dans le type public, validation trop permissive de `cognitiveSkill`, et bornes `multiple_choice` insuffisantes. La seule tension est la demande de contenu complet des fichiers dans le rapport, qui rend le Markdown très long ; elle reste cohérente avec l'objectif de review autonome.

## 14. Contenu complet des fichiers créés/modifiés/supprimés pour review

### revision_app/docs/v1/ROADMAP_EXECUTION_LOT_V1_005B_RICH_CLOSED_CONTRACT_HARDENING.md

Ce fichier est le rapport courant. Son contenu complet est donc le présent document.

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question.types.ts

~~~ts
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
      questionKind: 'single_choice' | 'case_qualification';
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
~~~

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.ts

~~~ts
import {
  RICH_CLOSED_EXERCISE_VERSION,
  RICH_CLOSED_COGNITIVE_SKILLS,
  RICH_CLOSED_QUESTION_KINDS,
  type RichClosedChoice,
  type RichClosedExerciseValidationIssue,
  type RichClosedExerciseValidationResult,
  type RichClosedPair,
  type RichClosedQuestionKind,
} from './rich-closed-question.types';

const MAX_PROMPT_LENGTH = 700;
const MAX_CASE_TEXT_LENGTH = 900;
const MAX_STATEMENT_LENGTH = 900;
const MAX_EXPLANATION_LENGTH = 1200;
const MIN_CHOICES = 2;
const MAX_CHOICES = 6;
const MIN_STRUCTURED_ITEMS = 3;

export interface RichClosedQuestionValidationOptions {
  knownSourceChunkIds?: readonly string[] | ReadonlySet<string>;
}

export function validateRichClosedExercise(
  exercise: unknown,
  options: RichClosedQuestionValidationOptions = {},
): RichClosedExerciseValidationResult {
  const issues: RichClosedExerciseValidationIssue[] = [];

  if (!isRecord(exercise)) {
    return rejected([
      issue('RICH_CLOSED_EXERCISE_INVALID', 'Exercise must be an object'),
    ]);
  }

  if (exercise.version !== RICH_CLOSED_EXERCISE_VERSION) {
    issues.push(
      issue(
        'RICH_CLOSED_VERSION_INVALID',
        'Exercise version must be rich-closed-question-v1',
        'version',
      ),
    );
  }

  if (!plainString(exercise.id)) {
    issues.push(
      issue('RICH_CLOSED_ID_INVALID', 'Exercise id is required', 'id'),
    );
  }

  if (!boundedString(exercise.title, 1, 160)) {
    issues.push(
      issue('RICH_CLOSED_TITLE_INVALID', 'Exercise title is invalid', 'title'),
    );
  }

  if (!Array.isArray(exercise.questions) || exercise.questions.length === 0) {
    issues.push(
      issue(
        'RICH_CLOSED_QUESTIONS_INVALID',
        'Exercise must contain at least one question',
        'questions',
      ),
    );
  } else {
    exercise.questions.forEach((question, index) => {
      const result = validateRichClosedQuestion(question, options);
      issues.push(
        ...result.issues.map((questionIssue) => ({
          ...questionIssue,
          path: `questions.${index}${
            questionIssue.path === undefined ? '' : `.${questionIssue.path}`
          }`,
        })),
      );
    });
  }

  return {
    accepted: issues.length === 0,
    issues,
  };
}

export function validateRichClosedQuestion(
  question: unknown,
  options: RichClosedQuestionValidationOptions = {},
): RichClosedExerciseValidationResult {
  const issues: RichClosedExerciseValidationIssue[] = [];

  if (!isRecord(question)) {
    return rejected([
      issue('RICH_CLOSED_QUESTION_INVALID', 'Question must be an object'),
    ]);
  }

  if (containsFreeAnswerField(question)) {
    issues.push(
      issue(
        'RICH_CLOSED_FREE_ANSWER_FORBIDDEN',
        'Rich closed questions cannot contain free-answer fields',
      ),
    );
  }

  const questionKind = question.questionKind;
  if (!isRichClosedQuestionKind(questionKind)) {
    issues.push(
      issue(
        'RICH_CLOSED_KIND_UNSUPPORTED',
        'Question kind is not part of V1-A',
        'questionKind',
      ),
    );
    return {
      accepted: false,
      issues,
    };
  }

  validateCommonQuestionFields(question, issues, options);

  switch (questionKind) {
    case 'single_choice':
      validateSingleChoiceQuestion(question, issues);
      break;
    case 'multiple_choice':
      validateMultipleChoiceQuestion(question, issues);
      break;
    case 'matching':
      validateMatchingQuestion(question, issues);
      break;
    case 'ordering':
      validateOrderingQuestion(question, issues);
      break;
    case 'case_qualification':
      validateCaseQualificationQuestion(question, issues);
      break;
    case 'error_detection':
      validateErrorDetectionQuestion(question, issues);
      break;
  }

  return {
    accepted: issues.length === 0,
    issues,
  };
}

function validateCommonQuestionFields(
  question: Record<string, unknown>,
  issues: RichClosedExerciseValidationIssue[],
  options: RichClosedQuestionValidationOptions,
) {
  if (!plainString(question.id)) {
    issues.push(
      issue('RICH_CLOSED_ID_INVALID', 'Question id is required', 'id'),
    );
  }

  if (!boundedString(question.prompt, 1, MAX_PROMPT_LENGTH)) {
    issues.push(
      issue(
        'RICH_CLOSED_PROMPT_INVALID',
        'Question prompt is invalid',
        'prompt',
      ),
    );
  }

  if (
    question.difficulty !== 'LOW' &&
    question.difficulty !== 'MEDIUM' &&
    question.difficulty !== 'HIGH'
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_DIFFICULTY_INVALID',
        'Question difficulty is invalid',
        'difficulty',
      ),
    );
  }

  if (!isRichClosedCognitiveSkill(question.cognitiveSkill)) {
    issues.push(
      issue(
        'RICH_CLOSED_COGNITIVE_SKILL_INVALID',
        'Question cognitive skill is not part of the V1-A allowlist',
        'cognitiveSkill',
      ),
    );
  }

  validateSources(question.sourceChunkIds, issues, options);
}

function validateSingleChoiceQuestion(
  question: Record<string, unknown>,
  issues: RichClosedExerciseValidationIssue[],
) {
  const choices = readChoices(question.choices, issues, 'choices');

  if (!choiceIds(choices).has(readString(question.correctChoiceId))) {
    issues.push(
      issue(
        'RICH_CLOSED_CORRECTION_INVALID',
        'Single choice correction must target one existing choice',
        'correctChoiceId',
      ),
    );
  }

  validateExplanation(question.explanation, issues);
}

function validateMultipleChoiceQuestion(
  question: Record<string, unknown>,
  issues: RichClosedExerciseValidationIssue[],
) {
  const choices = readChoices(question.choices, issues, 'choices');
  const knownChoiceIds = choiceIds(choices);
  const correctChoiceIds = readStringArray(question.correctChoiceIds);
  const minSelections = question.minSelections;
  const maxSelections = question.maxSelections;

  if (correctChoiceIds.length < 2) {
    issues.push(
      issue(
        'RICH_CLOSED_MULTIPLE_TOO_FEW_CORRECT',
        'Multiple choice requires at least two correct answers',
        'correctChoiceIds',
      ),
    );
  }

  if (
    hasDuplicates(correctChoiceIds) ||
    correctChoiceIds.some((choiceId) => !knownChoiceIds.has(choiceId))
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_CORRECTION_INVALID',
        'Multiple choice correction must reference existing choices once',
        'correctChoiceIds',
      ),
    );
  }

  if (
    typeof minSelections !== 'number' ||
    typeof maxSelections !== 'number' ||
    !Number.isInteger(minSelections) ||
    !Number.isInteger(maxSelections) ||
    minSelections < 1 ||
    maxSelections < minSelections ||
    maxSelections > choices.length ||
    correctChoiceIds.length < minSelections ||
    correctChoiceIds.length > maxSelections
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_SELECTION_BOUNDS_INVALID',
        'Multiple choice selection bounds are invalid',
      ),
    );
  }

  validateExplanation(question.explanation, issues);
}

function validateMatchingQuestion(
  question: Record<string, unknown>,
  issues: RichClosedExerciseValidationIssue[],
) {
  const leftItems = readLabelItems(question.leftItems, issues, 'leftItems');
  const rightItems = readLabelItems(question.rightItems, issues, 'rightItems');
  const pairs = readPairs(question.correctPairs);

  if (
    leftItems.length < MIN_STRUCTURED_ITEMS ||
    rightItems.length < MIN_STRUCTURED_ITEMS ||
    pairs.length < MIN_STRUCTURED_ITEMS
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_MATCHING_TOO_SMALL',
        'Matching requires at least three pairs',
      ),
    );
  }

  const leftIds = idSet(leftItems);
  const rightIds = idSet(rightItems);
  const pairedLeftIds = pairs.map((pair) => pair.leftId);
  const pairedRightIds = pairs.map((pair) => pair.rightId);

  if (hasDuplicates(pairedLeftIds) || hasDuplicates(pairedRightIds)) {
    issues.push(
      issue(
        'RICH_CLOSED_MATCHING_DUPLICATE_PAIR',
        'Matching pairs cannot reuse a side',
        'correctPairs',
      ),
    );
  }

  if (
    pairs.some(
      (pair) => !leftIds.has(pair.leftId) || !rightIds.has(pair.rightId),
    )
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_CORRECTION_INVALID',
        'Matching correction must reference existing items',
        'correctPairs',
      ),
    );
  }

  validateExplanation(question.explanation, issues);
}

function validateOrderingQuestion(
  question: Record<string, unknown>,
  issues: RichClosedExerciseValidationIssue[],
) {
  const items = readLabelItems(question.items, issues, 'items');
  const itemIds = [...idSet(items)];
  const correctOrder = readStringArray(question.correctOrder);

  if (items.length < MIN_STRUCTURED_ITEMS) {
    issues.push(
      issue(
        'RICH_CLOSED_ORDERING_TOO_SMALL',
        'Ordering requires at least three items',
        'items',
      ),
    );
  }

  if (
    correctOrder.length !== itemIds.length ||
    hasDuplicates(correctOrder) ||
    correctOrder.some((itemId) => !itemIds.includes(itemId))
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_ORDERING_INCOMPLETE',
        'Ordering correction must contain each item exactly once',
        'correctOrder',
      ),
    );
  }

  validateExplanation(question.explanation, issues);
}

function validateCaseQualificationQuestion(
  question: Record<string, unknown>,
  issues: RichClosedExerciseValidationIssue[],
) {
  const choices = readChoices(question.choices, issues, 'choices');

  if (!boundedString(question.caseText, 1, MAX_CASE_TEXT_LENGTH)) {
    issues.push(
      issue(
        'RICH_CLOSED_CASE_TEXT_INVALID',
        'Case qualification requires a short case text',
        'caseText',
      ),
    );
  }

  if (!choiceIds(choices).has(readString(question.correctChoiceId))) {
    issues.push(
      issue(
        'RICH_CLOSED_CORRECTION_INVALID',
        'Case qualification correction must target one existing choice',
        'correctChoiceId',
      ),
    );
  }

  validateExplanation(question.explanation, issues);
}

function validateErrorDetectionQuestion(
  question: Record<string, unknown>,
  issues: RichClosedExerciseValidationIssue[],
) {
  const errorOptions = readChoices(
    question.errorOptions,
    issues,
    'errorOptions',
  );

  if (!boundedString(question.statement, 1, MAX_STATEMENT_LENGTH)) {
    issues.push(
      issue(
        'RICH_CLOSED_STATEMENT_INVALID',
        'Error detection requires a bounded statement',
        'statement',
      ),
    );
  }

  if (!choiceIds(errorOptions).has(readString(question.correctErrorId))) {
    issues.push(
      issue(
        'RICH_CLOSED_CORRECTION_INVALID',
        'Error detection correction must target one existing error option',
        'correctErrorId',
      ),
    );
  }

  validateExplanation(question.explanation, issues);
}

function validateSources(
  sourceChunkIds: unknown,
  issues: RichClosedExerciseValidationIssue[],
  options: RichClosedQuestionValidationOptions,
) {
  const sourceIds = readStringArray(sourceChunkIds);

  if (
    !Array.isArray(sourceChunkIds) ||
    sourceIds.length !== sourceChunkIds.length
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_SOURCES_INVALID',
        'Question sources must be an array of non-empty chunk ids',
        'sourceChunkIds',
      ),
    );
    return;
  }

  if (hasDuplicates(sourceIds)) {
    issues.push(
      issue(
        'RICH_CLOSED_SOURCES_DUPLICATE',
        'Question sources cannot contain duplicates',
        'sourceChunkIds',
      ),
    );
  }

  const knownSourceChunkIds = toStringSet(options.knownSourceChunkIds);
  if (
    knownSourceChunkIds !== null &&
    sourceIds.some((sourceChunkId) => !knownSourceChunkIds.has(sourceChunkId))
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_SOURCE_UNKNOWN',
        'Question references a source chunk outside the known source set',
        'sourceChunkIds',
      ),
    );
  }
}

function readChoices(
  value: unknown,
  issues: RichClosedExerciseValidationIssue[],
  path: string,
): RichClosedChoice[] {
  if (
    !Array.isArray(value) ||
    value.length < MIN_CHOICES ||
    value.length > MAX_CHOICES
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_CHOICES_INVALID',
        'Question choices must contain between two and six items',
        path,
      ),
    );
    return [];
  }

  const choices = value.filter(isChoice);
  if (
    choices.length !== value.length ||
    hasDuplicates(choices.map((choice) => choice.id))
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_CHOICES_INVALID',
        'Question choices must have unique non-empty ids and labels',
        path,
      ),
    );
  }

  return choices;
}

function readLabelItems(
  value: unknown,
  issues: RichClosedExerciseValidationIssue[],
  path: string,
) {
  if (!Array.isArray(value)) {
    issues.push(
      issue(
        'RICH_CLOSED_ITEMS_INVALID',
        'Structured items must be an array',
        path,
      ),
    );
    return [];
  }

  const items = value.filter(isLabelItem);
  if (
    items.length !== value.length ||
    hasDuplicates(items.map((item) => item.id))
  ) {
    issues.push(
      issue(
        'RICH_CLOSED_ITEMS_INVALID',
        'Structured items must have unique non-empty ids and labels',
        path,
      ),
    );
  }

  return items;
}

function readPairs(value: unknown): RichClosedPair[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.filter(
    (pair): pair is RichClosedPair =>
      isRecord(pair) && plainString(pair.leftId) && plainString(pair.rightId),
  );
}

function validateExplanation(
  explanation: unknown,
  issues: RichClosedExerciseValidationIssue[],
) {
  if (!boundedString(explanation, 1, MAX_EXPLANATION_LENGTH)) {
    issues.push(
      issue(
        'RICH_CLOSED_EXPLANATION_INVALID',
        'Private correction explanation is required and bounded',
        'explanation',
      ),
    );
  }
}

function isRichClosedQuestionKind(
  value: unknown,
): value is RichClosedQuestionKind {
  return (
    typeof value === 'string' &&
    RICH_CLOSED_QUESTION_KINDS.includes(value as RichClosedQuestionKind)
  );
}

function isRichClosedCognitiveSkill(
  value: unknown,
): value is (typeof RICH_CLOSED_COGNITIVE_SKILLS)[number] {
  return (
    typeof value === 'string' &&
    RICH_CLOSED_COGNITIVE_SKILLS.includes(
      value as (typeof RICH_CLOSED_COGNITIVE_SKILLS)[number],
    )
  );
}

function isChoice(value: unknown): value is RichClosedChoice {
  return (
    isRecord(value) &&
    plainString(value.id) &&
    boundedString(value.label, 1, 220)
  );
}

function isLabelItem(value: unknown): value is { id: string; label: string } {
  return (
    isRecord(value) &&
    plainString(value.id) &&
    boundedString(value.label, 1, 220)
  );
}

function containsFreeAnswerField(value: Record<string, unknown>): boolean {
  // Closed questions may contain private corrections, but never text-answer
  // shaped fields. This keeps V1-A separate from the open_question activity.
  return ['answerText', 'freeTextAnswer', 'textAnswer', 'modelAnswer'].some(
    (key) => Object.prototype.hasOwnProperty.call(value, key),
  );
}

function choiceIds(choices: RichClosedChoice[]): Set<string> {
  return new Set(choices.map((choice) => choice.id));
}

function idSet(items: Array<{ id: string }>): Set<string> {
  return new Set(items.map((item) => item.id));
}

function readString(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

function readStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.filter(plainString);
}

function toStringSet(
  value: readonly string[] | ReadonlySet<string> | undefined,
): ReadonlySet<string> | null {
  if (value === undefined) {
    return null;
  }

  return value instanceof Set ? value : new Set(value);
}

function hasDuplicates(values: readonly string[]): boolean {
  return new Set(values).size !== values.length;
}

function plainString(value: unknown): value is string {
  return typeof value === 'string' && value.trim().length > 0;
}

function boundedString(value: unknown, minLength: number, maxLength: number) {
  return (
    typeof value === 'string' &&
    value.trim().length >= minLength &&
    value.length <= maxLength
  );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function issue(
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

function rejected(
  issues: RichClosedExerciseValidationIssue[],
): RichClosedExerciseValidationResult {
  return {
    accepted: false,
    issues,
  };
}
~~~

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.ts

~~~ts
import type {
  RichClosedExercise,
  RichClosedPublicChoice,
  RichClosedPublicExercise,
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
~~~

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.ts

~~~ts
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
  const normalized = normalizePromptForHeuristic(prompt);

  return (
    normalized.startsWith('qui ') ||
    normalized.startsWith('quand ') ||
    normalized.startsWith('quelle date') ||
    normalized.startsWith('quelle est la definition') ||
    normalized.startsWith('quel terme designe')
  );
}

function normalizePromptForHeuristic(prompt: string): string {
  return prompt
    .trim()
    .toLocaleLowerCase('fr-FR')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[’']/g, ' ')
    .replace(/\s+/g, ' ');
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
~~~

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question.validator.spec.ts

~~~ts
import {
  validateRichClosedExercise,
  validateRichClosedQuestion,
} from './rich-closed-question.validator';
import {
  richClosedExerciseFixture,
  richClosedQuestionFixture,
} from './rich-closed-question.fixtures';
import type { RichClosedQuestion } from './rich-closed-question.types';

describe('rich closed question validator', () => {
  it.each([
    'single_choice',
    'multiple_choice',
    'matching',
    'ordering',
    'case_qualification',
    'error_detection',
  ] as const)('accepts a valid V1-A %s question', (questionKind) => {
    const result = validateRichClosedQuestion(
      richClosedQuestionFixture(questionKind),
      { knownSourceChunkIds: ['chunk-1', 'chunk-2', 'chunk-3'] },
    );

    expect(result.accepted).toBe(true);
    expect(result.issues).toEqual([]);
  });

  it('rejects a kind outside V1-A', () => {
    const question = {
      ...richClosedQuestionFixture('single_choice'),
      questionKind: 'timeline',
    } as unknown as RichClosedQuestion;

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_KIND_UNSUPPORTED' }),
    );
  });

  it('rejects free answer shaped payloads', () => {
    const question = {
      ...richClosedQuestionFixture('single_choice'),
      answerText: 'Réponse libre interdite',
    } as unknown as RichClosedQuestion;

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_FREE_ANSWER_FORBIDDEN' }),
    );
  });

  it('rejects cognitive skills outside the V1-A allowlist', () => {
    const question = {
      ...richClosedQuestionFixture('single_choice'),
      cognitiveSkill: 'creative_writing',
    } as unknown as RichClosedQuestion;

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_COGNITIVE_SKILL_INVALID',
      }),
    );
  });

  it('accepts a cognitive skill from the V1-A allowlist', () => {
    const question = {
      ...richClosedQuestionFixture('single_choice'),
      cognitiveSkill: 'comparison',
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(true);
  });

  it('requires single_choice to have exactly one valid correct choice', () => {
    const question = {
      ...richClosedQuestionFixture('single_choice'),
      correctChoiceId: 'missing-choice',
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_CORRECTION_INVALID' }),
    );
  });

  it('requires multiple_choice to have at least two valid correct answers', () => {
    const question = {
      ...richClosedQuestionFixture('multiple_choice'),
      correctChoiceIds: ['choice-a'],
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_MULTIPLE_TOO_FEW_CORRECT' }),
    );
  });

  it('rejects decimal multiple_choice selection bounds', () => {
    const question = {
      ...richClosedQuestionFixture('multiple_choice'),
      minSelections: 1.5,
      maxSelections: 2.5,
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_SELECTION_BOUNDS_INVALID',
      }),
    );
  });

  it('rejects multiple_choice bounds that exclude the correct answer count', () => {
    const question = {
      ...richClosedQuestionFixture('multiple_choice'),
      minSelections: 1,
      maxSelections: 1,
      correctChoiceIds: ['choice-a', 'choice-b'],
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_SELECTION_BOUNDS_INVALID',
      }),
    );
  });

  it('accepts multiple_choice bounds that include the correct answer count', () => {
    const question = {
      ...richClosedQuestionFixture('multiple_choice'),
      minSelections: 1,
      maxSelections: 3,
      correctChoiceIds: ['choice-a', 'choice-b'],
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(true);
  });

  it('rejects matching questions with fewer than three pairs', () => {
    const question = {
      ...richClosedQuestionFixture('matching'),
      leftItems: [
        { id: 'left-1', label: 'Motion de censure' },
        { id: 'left-2', label: 'Dissolution' },
      ],
      rightItems: [
        { id: 'right-1', label: 'Responsabilité politique' },
        { id: 'right-2', label: 'Fin anticipée' },
      ],
      correctPairs: [
        { leftId: 'left-1', rightId: 'right-1' },
        { leftId: 'left-2', rightId: 'right-2' },
      ],
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_MATCHING_TOO_SMALL' }),
    );
  });

  it('rejects matching questions with duplicate pair sides', () => {
    const question = {
      ...richClosedQuestionFixture('matching'),
      correctPairs: [
        { leftId: 'left-1', rightId: 'right-1' },
        { leftId: 'left-1', rightId: 'right-2' },
        { leftId: 'left-3', rightId: 'right-3' },
      ],
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_MATCHING_DUPLICATE_PAIR' }),
    );
  });

  it('requires ordering questions to have at least three items and a complete order', () => {
    const question = {
      ...richClosedQuestionFixture('ordering'),
      correctOrder: ['item-1', 'item-2'],
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_ORDERING_INCOMPLETE' }),
    );
  });

  it('requires case_qualification to have a short case and a unique correction', () => {
    const question = {
      ...richClosedQuestionFixture('case_qualification'),
      caseText: 'x'.repeat(901),
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_CASE_TEXT_INVALID' }),
    );
  });

  it('requires error_detection to have one dominant valid error', () => {
    const question = {
      ...richClosedQuestionFixture('error_detection'),
      correctErrorId: 'missing-error',
    };

    const result = validateRichClosedQuestion(question);

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_CORRECTION_INVALID' }),
    );
  });

  it('rejects unknown source chunks when a known source set is provided', () => {
    const question = {
      ...richClosedQuestionFixture('single_choice'),
      sourceChunkIds: ['chunk-unknown'],
    };

    const result = validateRichClosedQuestion(question, {
      knownSourceChunkIds: ['chunk-1'],
    });

    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({ code: 'RICH_CLOSED_SOURCE_UNKNOWN' }),
    );
  });

  it('validates a complete V1-A exercise', () => {
    const result = validateRichClosedExercise(richClosedExerciseFixture(), {
      knownSourceChunkIds: ['chunk-1', 'chunk-2', 'chunk-3'],
    });

    expect(result.accepted).toBe(true);
    expect(result.issues).toEqual([]);
  });
});
~~~

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-public.mapper.spec.ts

~~~ts
import {
  toRichClosedPublicExercise,
  toRichClosedPublicQuestion,
} from './rich-closed-question-public.mapper';
import {
  richClosedExerciseFixture,
  richClosedQuestionFixture,
} from './rich-closed-question.fixtures';

describe('rich closed question public mapper', () => {
  it.each([
    'single_choice',
    'multiple_choice',
    'matching',
    'ordering',
    'case_qualification',
    'error_detection',
  ] as const)('maps %s without leaking correction fields', (questionKind) => {
    const publicQuestion = toRichClosedPublicQuestion(
      richClosedQuestionFixture(questionKind),
    );
    const serialized = JSON.stringify(publicQuestion);

    expect(publicQuestion.questionKind).toBe(questionKind);
    expect(serialized).not.toContain('correctChoiceId');
    expect(serialized).not.toContain('correctChoiceIds');
    expect(serialized).not.toContain('correctPairs');
    expect(serialized).not.toContain('correctOrder');
    expect(serialized).not.toContain('correctErrorId');
    expect(serialized).not.toContain('correctionPayload');
    expect(serialized).not.toContain('explanation');
  });

  it('maps a full exercise without leaking private correction data', () => {
    const publicExercise = toRichClosedPublicExercise(
      richClosedExerciseFixture(),
    );
    const serialized = JSON.stringify(publicExercise);

    expect(publicExercise.version).toBe('rich-closed-question-v1');
    expect(publicExercise.questions).toHaveLength(6);
    expect(serialized).not.toContain('correct');
    expect(serialized).not.toContain('correctionPayload');
    expect(serialized).not.toContain('explanation');
    expect(serialized).not.toContain('score');
  });

  it('removes internal choice feedback from public choice payloads', () => {
    const question = {
      ...richClosedQuestionFixture('single_choice'),
      choices: [
        {
          id: 'choice-a',
          label: 'La responsabilité politique',
          feedback: 'Ce feedback reste privé avant submit.',
        },
        {
          id: 'choice-b',
          label: 'La séparation totalement étanche',
          feedback: 'Feedback privé également.',
        },
      ],
    };

    const publicQuestion = toRichClosedPublicQuestion(question);
    const serialized = JSON.stringify(publicQuestion);

    expect(serialized).not.toContain('feedback');
    expect(serialized).not.toContain('Ce feedback reste privé avant submit.');
    expect(serialized).not.toContain('Feedback privé également.');
  });
});
~~~

### api/src/modules/activities/application/rich-closed-questions/rich-closed-question-quality-gate.spec.ts

~~~ts
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

  it.each([
    ['feedback', 'Feedback pré-submit interdit'],
    ['choiceFeedback', 'Feedback de choix interdit'],
    ['modelAnswer', 'Réponse modèle interdite'],
    ['answerText', 'Réponse libre interdite'],
    ['workedSteps', ['Étape révélatrice interdite']],
  ])('rejects public pre-submit payloads containing %s', (key, value) => {
    const exercise = richClosedExerciseFixture();
    const publicExercise = {
      ...toRichClosedPublicExercise(exercise),
      questions: [
        {
          ...toRichClosedPublicExercise(exercise).questions[0],
          metadata: {
            nested: {
              [key]: value,
            },
          },
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

  it('detects basic definition prompts with or without accents', () => {
    const exercise = {
      ...richClosedExerciseFixture(),
      questions: richClosedExerciseFixture().questions.map(
        (question, index) => ({
          ...question,
          prompt:
            index < 2
              ? `Quelle est la définition de la notion ${index + 1} ?`
              : index < 4
                ? `Quelle est la definition de la notion ${index + 1} ?`
                : question.prompt,
        }),
      ),
    };

    const result = evaluateRichClosedExerciseQuality(exercise);

    expect(result.metrics.basicQuestionCount).toBe(4);
    expect(result.accepted).toBe(false);
    expect(result.issues).toContainEqual(
      expect.objectContaining({
        code: 'RICH_CLOSED_GATE_TOO_MANY_BASIC_QUESTIONS',
      }),
    );
  });
});
~~~

### revision_app/docs/v1/ROADMAP_EXECUTION_PLAN_V1.md

~~~md
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
| V1-006 | Génération Genkit rich closed questions V1-A | À faire | À créer |
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
~~~
