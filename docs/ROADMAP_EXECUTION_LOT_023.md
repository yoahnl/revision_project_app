# LOT-023 — Genkit QCM enrichi

## 1. Résultat

Le générateur QCM Genkit supporte maintenant un mode interne v2 sourcé, sans changer les endpoints publics, la persistance QCM actuelle, Prisma, Flutter ou GenUI.

Le mode v2 accepte une `KnowledgeUnit`, des chunks documentaires optionnels, un `documentId` optionnel et un `questionCount` optionnel. Quand des chunks sont fournis, la sortie Genkit est validée strictement :

- QCM mono-réponse;
- `correctChoiceId` interne obligatoire;
- explication pédagogique obligatoire;
- difficulté bornée à `LOW | MEDIUM | HIGH` si présente;
- feedback par choix optionnel;
- `sourceChunkIds` obligatoires par question;
- source inconnue rejetée;
- sources dédupliquées.

Le mode legacy reste compatible : `StartNextActivityUseCase` continue d'appeler le générateur avec seulement `{ knowledgeUnit }`, et le DTO public actuel ne reçoit toujours pas `correctChoiceId`.

## 2. Sources inspectées

- `docs/ROADMAP.md`
- `docs/ROADMAP_EXECUTION_PLAN.md`
- `docs/ROADMAP_EXECUTION_LOT_022.md`
- `docs/ROADMAP_EXECUTION_LOT_019_020.md`
- `docs/ROADMAP_EXECUTION_LOT_012_013.md`
- `AGENTS.md`
- `codex_rule.md`
- `../api/package.json`
- `../api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `../api/src/modules/activities/application/start-next-activity.use-case.ts`
- `../api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `../api/src/modules/activities/application/activities.repository.ts`
- `../api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `../api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `../api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `../api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `../api/src/modules/activities/interfaces/activities.controller.ts`
- `../api/src/modules/ai/application/ai-generation-observer.ts`
- `../api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `../api/src/modules/ai/infrastructure/genkit-document-summary.generator.ts`
- `../api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.ts`
- `../api/src/modules/ai/infrastructure/document-artifact-generation-input.ts`
- `../api/src/modules/ai/infrastructure/document-artifact-genkit-config.ts`
- `../api/src/modules/revision/domain/knowledge-unit.entity.ts`
- `../api/src/modules/documents/application/documents.repository.ts`
- `../api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `../api/prisma/schema.prisma`

Chemin demandé mais absent dans le repo réel :

- `../api/src/modules/activities/interfaces/activities.controller.spec.ts`

## 3. Préflight Git

État initial API :

```text
repo: /Users/karim/Project/app-révision/api
branch: main
git status --short: aucun fichier listé
```

État initial frontend/docs :

```text
repo: /Users/karim/Project/app-révision/revision_app
branch: main
git status --short: aucun fichier listé
```

Préflight build backend :

```bash
cd /Users/karim/Project/app-révision/api && npm run build
```

Résultat :

```text
> api@0.0.1 build
> nest build

Succès
```

Décision sur fichiers hors scope :

- aucune modification frontend applicative;
- aucune modification Prisma;
- aucune migration;
- aucun endpoint public modifié;
- aucun controller public modifié;
- aucun GenUI QCM;
- aucune commande Git d'écriture.

## 4. Générateur QCM actuel

Avant ce lot, `DiagnosticQuizGenerator.generate` recevait uniquement :

```ts
{
  knowledgeUnit: KnowledgeUnit;
}
```

La sortie interne contenait :

- `title`;
- `questions`;
- `prompt`;
- `choices`;
- `correctChoiceId`;
- `explanation`.

Le prompt utilisait seulement le titre et le résumé de la notion. Il ne recevait aucun chunk et ne produisait aucun `sourceChunkIds`.

La persistance actuelle stocke déjà `correctChoiceId` et `explanation` dans `Question`, mais `PrismaActivitiesRepository.toActivityQuestion` renvoie publiquement seulement :

- `id`;
- `prompt`;
- `choices`.

Le DTO public actuel ne fuit donc pas `correctChoiceId` avant soumission. Ce lot conserve cette propriété.

Limites avant le lot :

- pas de grounding sur `DocumentChunk`;
- pas de difficulté générée;
- pas de feedback par choix;
- pas de validation de sources;
- prompt/schema versionnés en `diagnostic-quiz-v1`.

## 5. Contrat Genkit QCM v2

Input final du port :

```ts
export interface DiagnosticQuizGenerationInput {
  subjectId?: string;
  documentId?: string | null;
  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit;
  chunks?: DiagnosticQuizGenerationChunk[];
  questionCount?: number;
}
```

Output interne final :

```ts
export interface GeneratedDiagnosticQuiz {
  title: string;
  version?: 2;
  questions: GeneratedDiagnosticQuizQuestion[];
  metadata?: GeneratedDiagnosticQuizMetadata;
}
```

Mode legacy :

- actif quand aucun chunk exploitable n'est fourni;
- `sourceChunkIds` peut être omis;
- la sortie reste compatible avec `PrismaActivitiesRepository`;
- `/activities/next` conserve son comportement public actuel.

Mode v2 sourcé :

- actif quand au moins un chunk exploitable est fourni;
- `sourceChunkIds` est obligatoire par question;
- le résultat reçoit `version: 2`;
- le résultat reçoit des métadonnées internes `flowName`, `provider`, `model`, `promptVersion`, `schemaVersion`, `inputSize`;
- aucune donnée v2 n'est exposée publiquement dans ce lot.

Champs internes jamais exposés publiquement par ce lot :

- `correctChoiceId`;
- `explanation`;
- `feedback`;
- `metadata`;
- `sourceChunkIds`.

## 6. Schéma Zod

Le schéma Genkit est strict :

- objet racine `.strict()`;
- questions `.strict()`;
- choix `.strict()`;
- titre non vide;
- 1 à 5 questions;
- prompt non vide et suffisamment long;
- 2 à 4 choix;
- ids de choix non vides;
- labels non vides;
- ids de choix uniques;
- `correctChoiceId` présent dans les choix;
- explication non vide;
- difficulté optionnelle `LOW | MEDIUM | HIGH`;
- feedback par choix optionnel;
- champs inconnus rejetés.

Les `sourceChunkIds` restent validés applicativement afin de conserver le mode legacy sans chunks, mais deviennent obligatoires dès que le générateur est appelé avec chunks.

## 7. Prompt QCM v2

Le prompt demande :

- QCM en français;
- mono-réponse;
- un seul `correctChoiceId`;
- distracteurs plausibles mais faux;
- explication fondée sur le cours fourni;
- difficulté si possible;
- `sourceChunkIds` choisis uniquement parmi les chunks fournis;
- aucune connaissance externe;
- aucune source libre;
- aucun `chunkId` inventé;
- JSON strict conforme au schéma.

Versions retenues :

```text
flowName: diagnosticQuizGeneration
promptVersion: diagnostic-quiz-v2
schemaVersion: diagnostic-quiz-v2
```

## 8. Sélection chunks

Stratégie MVP :

- dédupliquer par `chunk.id`;
- ignorer les chunks sans texte utile;
- trier les chunks par `index`;
- prioriser les chunks référencés par `knowledgeUnit.sourceChunkIds`;
- compléter avec les autres chunks dans l'ordre documentaire;
- limiter par nombre de chunks;
- limiter par taille totale de texte;
- tronquer le dernier chunk si la limite de caractères est atteinte.

Variables d'environnement :

```text
DIAGNOSTIC_QUIZ_GENERATION_MAX_CHUNKS
DIAGNOSTIC_QUIZ_GENERATION_MAX_CHARS
```

Valeurs par défaut :

```text
maxChunks: 8
maxChars: 8000
```

## 9. Validation sources

En mode v2 sourcé :

- chaque question doit avoir au moins un `sourceChunkId`;
- les sources sont dédupliquées;
- chaque `sourceChunkId` doit exister parmi les chunks fournis au modèle;
- toute source inconnue rejette l'output complet;
- aucune source fictive n'est créée;
- aucune source libre n'est acceptée comme autoritaire.

Erreur contrôlée :

```text
DIAGNOSTIC_QUIZ_SOURCE_INVALID
```

## 10. Observabilité

Champs observés :

- `flowName`;
- `provider`;
- `model`;
- `promptVersion`;
- `schemaVersion`;
- `inputSize`;
- `durationMs`;
- `status`;
- `errorCode`;
- `subjectId`;
- `documentId` si fourni;
- `knowledgeUnitId`.

Données explicitement non observées :

- prompt complet;
- completion complète;
- chunks;
- labels de choix;
- `correctChoiceId`;
- explication;
- feedback;
- réponse utilisateur.

## 11. Compatibilité runtime

Le runtime actuel est inchangé pour les endpoints publics :

- `POST /activities/next` appelle toujours le générateur en mode legacy via `StartNextActivityUseCase`;
- `POST /activities/:sessionId/result` n'est pas modifié;
- aucun DTO public n'a été modifié;
- `correctChoiceId` reste absent du payload pré-submit;
- la persistance QCM v2 reste reportée à `LOT-024`.

Le repository actuel ignore toujours le feedback dans `choices` lorsqu'il persiste le QCM legacy. C'est volontaire : la persistance enrichie et le feedback après submit relèvent de `LOT-024`.

## 12. Tests créés ou modifiés

Fichier modifié :

- `../api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`

Tests ajoutés ou adaptés :

- succès QCM v2 avec sources valides;
- priorité aux chunks liés à `KnowledgeUnit.sourceChunkIds`;
- limitation par nombre de chunks et taille;
- observability success sans texte de chunk, choix, `correctChoiceId`, explication ou feedback;
- rejet source inconnue;
- rejet question sans source en mode v2;
- rejet `correctChoiceId` absent des choix;
- rejet ids de choix dupliqués;
- rejet choix insuffisants;
- rejet explication absente;
- rejet champs inconnus;
- conservation du mode legacy;
- conservation du support Mistral mocké;
- versions `diagnostic-quiz-v2`;
- non-régression `activities`.

## 13. Validations lancées

Préflight :

```bash
cd /Users/karim/Project/app-révision/api && npm run build
```

Résultat : succès.

TDD RED :

```bash
cd /Users/karim/Project/app-révision/api && npm test -- genkit-diagnostic-quiz --runInBand
```

Résultat attendu avant implémentation : échec sur les nouveaux contrats v2.

Après implémentation :

```bash
cd /Users/karim/Project/app-révision/api && npm test -- genkit-diagnostic-quiz --runInBand
```

Résultat :

```text
Test Suites: 1 passed, 1 total
Tests:       15 passed, 15 total
```

```bash
cd /Users/karim/Project/app-révision/api && npm test -- activities --runInBand
```

Résultat :

```text
Test Suites: 5 passed, 5 total
Tests:       33 passed, 33 total
```

```bash
cd /Users/karim/Project/app-révision/api && npm test -- ai --runInBand
```

Résultat :

```text
Test Suites: 11 passed, 11 total
Tests:       48 passed, 48 total
```

```bash
cd /Users/karim/Project/app-révision/api && npm run lint:check
```

Résultat : succès.

```bash
cd /Users/karim/Project/app-révision/api && npm run build
```

Résultat : succès.

```bash
cd /Users/karim/Project/app-révision/api && git diff --check
```

Résultat : succès.

```bash
cd /Users/karim/Project/app-révision/revision_app && git diff --check
```

Résultat : succès.

## 14. Validations non lancées

Non lancées volontairement :

- migrations Prisma : interdites et hors scope;
- provider IA réel : interdit;
- déploiement : interdit;
- tests Flutter : aucun code Flutter modifié;
- `npm run test:cov` : interdit;
- `npm run lint` : interdit si fix automatique;
- `npm run format` : interdit.

## 15. Données non stockées / non exposées

Confirmé :

- pas de prompt stocké;
- pas de completion stockée;
- pas de chunks dans les logs d'observabilité;
- pas de correction exposée avant submit;
- pas de source libre;
- pas de migration;
- pas de Prisma modifié;
- pas de GenUI QCM;
- pas de frontend modifié;
- pas de `GeneratedArtifact`;
- pas de `AiGenerationJob`.

## 16. Risques restants

- `QuestionSource` n'existe pas encore : les sources QCM v2 ne sont pas persistées avant `LOT-024`.
- La soumission enrichie et la correction détaillée ne sont pas encore implémentées.
- L'UI QCM v2 n'est pas encore faite.
- Le provider réel n'a pas été testé dans ce lot.
- La sélection de chunks est simple et peut manquer de pertinence sur longs documents.
- Le feedback par choix est optionnel et non persisté dans le flux actuel.
- Les sources pré-submit restent à cadrer définitivement dans `LOT-024/025`.

## 17. Recommandation prochain lot

Prochain lot recommandé :

```text
LOT-024 — Persistance et soumission QCM enrichies
```

Justification :

- le générateur produit maintenant un output interne v2 sourcé;
- il faut persister les choix, la bonne réponse interne, les sources par question et le feedback;
- il faut définir le DTO de correction post-submit;
- il faut empêcher les doubles soumissions et brancher la maîtrise de manière traçable.

Ne pas commencer `LOT-025` avant stabilisation du contrat API post-submit.

## 18. Passes de review

Passe Audit / Architecture :

- verdict : OK;
- le QCM actuel masque déjà `correctChoiceId` côté DTO public;
- le meilleur compromis est un port enrichi compatible plutôt qu'un deuxième générateur parallèle.

Passe Implémentation :

- verdict : OK;
- modifications limitées au port QCM, au générateur Genkit QCM, aux tests QCM et à la documentation;
- aucune persistance enrichie introduite.

Passe Tests :

- verdict : OK;
- tests positifs, négatifs, garde-fous source, observabilité et non-régression ajoutés.

Passe Build / Validation :

- verdict : OK;
- tests ciblés, `activities`, `ai`, lint et build backend passent.

Passe Critique finale :

- verdict : OK avec réserve;
- réserve principale : le mode v2 est prêt côté générateur mais pas encore consommé par un flux persistant, ce qui est volontaire pour respecter l'isolation de `LOT-023`.

## 19. Code modifié

### `../api/src/modules/activities/application/diagnostic-quiz-generator.ts`

Zone ajoutée :

```ts
export type DiagnosticQuizDifficulty = 'LOW' | 'MEDIUM' | 'HIGH';

export interface DiagnosticQuizGenerationChunk {
  id: string;
  index: number;
  text: string;
  pageNumber?: number | null;
}

export interface DiagnosticQuizGenerationKnowledgeUnit extends KnowledgeUnit {
  difficulty?: DiagnosticQuizDifficulty | null;
  sourceChunkIds?: string[];
}

export interface DiagnosticQuizGenerationInput {
  subjectId?: string;
  documentId?: string | null;
  knowledgeUnit: DiagnosticQuizGenerationKnowledgeUnit;
  chunks?: DiagnosticQuizGenerationChunk[];
  questionCount?: number;
}
```

Zone modifiée :

```ts
export interface GeneratedDiagnosticQuizChoice {
  id: string;
  label: string;
  feedback?: string | null;
}

export interface GeneratedDiagnosticQuizQuestion {
  prompt: string;
  difficulty?: DiagnosticQuizDifficulty | null;
  choices: GeneratedDiagnosticQuizChoice[];
  correctChoiceId: string;
  explanation: string;
  sourceChunkIds?: string[];
}

export interface GeneratedDiagnosticQuizMetadata {
  flowName: string;
  provider: string;
  model: string;
  promptVersion: string;
  schemaVersion: string;
  inputSize: number;
}

export interface GeneratedDiagnosticQuiz {
  title: string;
  version?: 2;
  questions: GeneratedDiagnosticQuizQuestion[];
  metadata?: GeneratedDiagnosticQuizMetadata;
}
```

Zone modifiée :

```ts
export interface DiagnosticQuizGenerator {
  generate(
    input: DiagnosticQuizGenerationInput,
  ): Promise<GeneratedDiagnosticQuiz>;
}
```

### `../api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`

Zones principales modifiées :

```ts
const PROMPT_VERSION = 'diagnostic-quiz-v2';
const SCHEMA_VERSION = 'diagnostic-quiz-v2';
const SOURCE_INVALID_ERROR_CODE = 'DIAGNOSTIC_QUIZ_SOURCE_INVALID';
const DEFAULT_MAX_CHUNKS = 8;
const DEFAULT_MAX_CHARS = 8000;
const DEFAULT_QUESTION_COUNT = 3;
const MAX_QUESTION_COUNT = 5;
```

```ts
const GeneratedDiagnosticQuizChoiceSchema = z
  .object({
    id: NonEmptyStringSchema,
    label: NonEmptyStringSchema,
    feedback: NonEmptyStringSchema.nullish(),
  })
  .strict();
```

```ts
const GeneratedDiagnosticQuizQuestionSchema = z
  .object({
    prompt: z.string().min(8),
    difficulty: DiagnosticQuizDifficultySchema.nullish(),
    choices: z.array(GeneratedDiagnosticQuizChoiceSchema).min(2).max(4),
    correctChoiceId: NonEmptyStringSchema,
    explanation: z.string().min(8),
    sourceChunkIds: z.array(NonEmptyStringSchema).optional(),
  })
  .strict()
  .refine(
    (question) =>
      new Set(question.choices.map((choice) => choice.id)).size ===
        question.choices.length &&
      question.choices.some((choice) => choice.id === question.correctChoiceId),
    {
      message:
        'Question choices must be unique and include the correct choice id',
    },
  );
```

```ts
async generate(
  input: DiagnosticQuizGenerationInput,
): Promise<GeneratedDiagnosticQuiz> {
  const metadata = this.resolveMetadata();
  const chunks = selectDiagnosticQuizChunks(input);
  const prompt = buildPrompt(input, chunks);
  const inputSize = prompt.length;
  const startedAt = Date.now();
```

```ts
const quiz = normalizeGeneratedQuiz({
  output: GeneratedDiagnosticQuizSchema.parse(output),
  chunks,
  metadata: {
    provider: metadata.provider,
    model: metadata.model,
    inputSize,
  },
});
```

```ts
function normalizeSourceChunkIds(
  sourceChunkIds: string[] | undefined,
  knownChunkIds: Set<string>,
): string[] {
  const normalized = [...new Set(sourceChunkIds ?? [])];

  if (
    normalized.length === 0 ||
    normalized.some((chunkId) => !knownChunkIds.has(chunkId))
  ) {
    throw new Error(SOURCE_INVALID_ERROR_CODE);
  }

  return normalized;
}
```

```ts
function selectDiagnosticQuizChunks(
  input: DiagnosticQuizGenerationInput,
): DiagnosticQuizPromptChunk[] {
  const chunks = deduplicateChunks(input.chunks ?? []);
  const sourceChunkIds = new Set(input.knowledgeUnit.sourceChunkIds ?? []);
  const prioritizedChunks = [
    ...chunks.filter((chunk) => sourceChunkIds.has(chunk.id)),
    ...chunks.filter((chunk) => !sourceChunkIds.has(chunk.id)),
  ];
  const maxChunks = resolvePositiveInteger(
    process.env.DIAGNOSTIC_QUIZ_GENERATION_MAX_CHUNKS,
    DEFAULT_MAX_CHUNKS,
  );
  const maxChars = resolvePositiveInteger(
    process.env.DIAGNOSTIC_QUIZ_GENERATION_MAX_CHARS,
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
```

### `../api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`

Zones de tests ajoutées :

```ts
it('generates a sourced v2 quiz from the selected knowledge unit chunks', async () => {
  process.env.AI_PROVIDER = 'google';
  process.env.GENKIT_MODEL = 'googleai/custom-model';
  process.env.DIAGNOSTIC_QUIZ_GENERATION_MAX_CHUNKS = '1';
  process.env.DIAGNOSTIC_QUIZ_GENERATION_MAX_CHARS = '300';
  mockGenerate.mockResolvedValue({
    output: generatedSourcedQuiz(),
  });
  const observer = createObserver();

  const quiz = await new GenkitDiagnosticQuizGenerator(observer).generate({
    documentId: 'document-1',
    subjectId: 'subject-1',
    questionCount: 2,
    knowledgeUnit: sourcedKnowledgeUnit(),
    chunks: [
      {
        id: 'chunk-unused',
        index: 0,
        text: 'SENTINEL_UNUSED_CHUNK_TEXT',
        pageNumber: null,
      },
      {
        id: 'chunk-source',
        index: 1,
        text: 'SENTINEL_SOURCE_CHUNK_TEXT Article 89 organise la revision.',
        pageNumber: 2,
      },
    ],
  });

  const [generateInput] = mockGenerate.mock.calls[0] ?? [];
  expect(generateInput?.prompt).toContain('chunk-source');
  expect(generateInput?.prompt).toContain('SENTINEL_SOURCE_CHUNK_TEXT');
  expect(generateInput?.prompt).not.toContain('SENTINEL_UNUSED_CHUNK_TEXT');
  expect(quiz).toEqual({
    ...generatedSourcedQuiz(),
    version: 2,
    metadata: {
      flowName: 'diagnosticQuizGeneration',
      provider: 'google-genai',
      model: 'googleai/custom-model',
      promptVersion: 'diagnostic-quiz-v2',
      schemaVersion: 'diagnostic-quiz-v2',
      inputSize: generateInput?.prompt.length,
    },
  });
});
```

Autres tests ajoutés :

- rejet source inconnue;
- rejet absence de sources;
- rejet `correctChoiceId` invalide;
- rejet ids de choix dupliqués;
- rejet choix insuffisants;
- rejet explication vide;
- rejet champ inconnu;
- observabilité sans contenu sensible.

## 20. Contradictions ou choix critiques du prompt

- Le prompt LOT-023 interdit les commentaires dans le code.
- `codex_rule.md` demande beaucoup de commentaires utiles.
- Décision : respecter l'interdiction stricte du prompt de lot pour le code TypeScript, et documenter les décisions dans ce rapport Markdown.

Autre point :

- Le prompt demande `sourceChunkIds` obligatoire en v2, mais la compatibilité legacy impose de ne pas l'exiger quand `StartNextActivityUseCase` appelle encore le générateur sans chunks. Décision : validation obligatoire seulement en mode chunks.
