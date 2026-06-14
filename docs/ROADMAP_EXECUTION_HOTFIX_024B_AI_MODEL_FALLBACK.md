# HOTFIX-024B — Fallback modèle IA pour artefacts sourcés

## 1. Résultat

Le hotfix ajoute un fallback de modèle Mistral contrôlé pour les générations IA sourcées.

Flows couverts :

- `documentRevisionSheetGeneration`;
- `documentSummaryGeneration`;
- `diagnosticQuizGeneration`.

Comportement ajouté :

- tentative primaire avec le modèle Mistral configuré;
- si la sortie IA est invalide, une seule tentative fallback peut être lancée;
- le fallback reste dans le même provider Mistral;
- le modèle final persisté dans les métadonnées est le modèle réellement utilisé;
- les validations de sources restent strictes;
- aucune source invalide n'est acceptée;
- aucun prompt, completion, chunk complet ou `correctChoiceId` n'est loggué.

Le hotfix ne modifie pas Prisma, Flutter, GenUI, les endpoints publics, les repositories de persistance, TodayPlan, les questions ouvertes ou Dokploy.

## 2. Incident initial

Incident observé par l'utilisateur :

```text
Quand l’utilisateur clique sur Générer la fiche, le frontend affiche :
La generation a produit un resultat invalide.
```

Log backend fourni :

```json
{
  "event": "ai.generation",
  "flowName": "documentRevisionSheetGeneration",
  "provider": "mistral",
  "model": "mistral/mistral-small-latest",
  "promptVersion": "generate-revision-sheet-v1",
  "schemaVersion": "revision-sheet-v1",
  "inputSize": 22081,
  "durationMs": 11278,
  "status": "error",
  "errorCode": "REVISION_SHEET_SOURCE_INVALID",
  "documentId": "cmqdw62m7000f01nqfcbebbee"
}
```

Analyse :

- le backend rejette correctement une fiche dont les `sourceChunkIds` sont inconnus ou invalides;
- ce rejet doit rester strict;
- le problème se situe probablement dans la fiabilité de sortie du modèle primaire Mistral sur un input long;
- le hotfix retente avec un autre modèle Mistral configuré, sans relâcher la validation.

## 3. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_019_020.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`

Backend :

- `api/package.json`
- `api/.env.example`
- `api/README.md`
- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/application/document-summary-generator.ts`
- `api/src/modules/ai/application/revision-sheet-generator.ts`
- `api/src/modules/ai/infrastructure/document-artifact-generation-input.ts`
- `api/src/modules/ai/infrastructure/document-artifact-genkit-config.ts`
- `api/src/modules/ai/infrastructure/document-artifact-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-summary.generator.ts`
- `api/src/modules/ai/infrastructure/genkit-document-summary.generator.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.ts`
- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.spec.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `api/src/modules/ai/ai.module.ts`

## 4. Préflight Git

État initial API :

```text
Branche: main
git status --short: propre
```

État initial frontend :

```text
Branche: main
git status --short: propre
```

Préflight :

```bash
cd api && npm run build
```

Résultat :

```text
> api@0.0.1 build
> nest build

Succès
```

Fichiers requis présents :

- `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`;
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`.

## 5. Stratégie retenue

Stratégie :

1. Le flow tente le modèle primaire configuré.
2. Si le provider est Mistral et qu'un fallback est configuré, le flow peut retenter une seule fois.
3. Le fallback est déclenché uniquement pour une sortie IA invalide.
4. Si le fallback réussit, le résultat retourné et les métadonnées utilisent le modèle fallback.
5. Si le fallback échoue, l'erreur finale reste remontée.
6. Si aucun fallback n'est configuré, le comportement reste identique.
7. Si le fallback résout vers le même modèle que le primaire, aucun retry n'est lancé.

Erreurs qui déclenchent fallback :

- `REVISION_SHEET_SOURCE_INVALID`;
- `SUMMARY_SOURCE_INVALID`;
- `DIAGNOSTIC_QUIZ_SOURCE_INVALID`;
- sortie Zod invalide;
- message d'erreur contenant `schema`, `json` ou `output`;
- sortie QCM vide.

Erreurs qui ne déclenchent pas fallback :

- document absent;
- document non `READY`;
- aucune notion;
- aucun chunk;
- ownership/cross-student;
- erreur Prisma;
- erreur DB;
- clé API absente;
- provider non configuré;
- erreur provider réseau générique non classée;
- erreur métier hors sortie IA invalide.

Maximum :

- deux tentatives : primaire puis fallback.

## 6. Configuration

Variables ajoutées :

```env
MISTRAL_FALLBACK_MODEL=""
MISTRAL_SUMMARY_FALLBACK_MODEL=""
MISTRAL_REVISION_SHEET_FALLBACK_MODEL=""
MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL=""
```

Priorité :

1. fallback spécifique du flow;
2. fallback global `MISTRAL_FALLBACK_MODEL`;
3. aucun fallback.

Résolution :

- `MISTRAL_SUMMARY_FALLBACK_MODEL` puis `MISTRAL_FALLBACK_MODEL`;
- `MISTRAL_REVISION_SHEET_FALLBACK_MODEL` puis `MISTRAL_FALLBACK_MODEL`;
- `MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL` puis `MISTRAL_FALLBACK_MODEL`.

Les noms de modèles ne sont pas figés dans le code. L'opérateur doit choisir un modèle Mistral plus capable et vérifier sa disponibilité côté Mistral ou environnement de déploiement.

## 7. Flows modifiés

### Fiche

`GenkitRevisionSheetGenerator` :

- utilise le modèle primaire;
- observe l'erreur primaire;
- retente avec `MISTRAL_REVISION_SHEET_FALLBACK_MODEL` ou `MISTRAL_FALLBACK_MODEL`;
- observe le succès ou l'erreur fallback;
- retourne `metadata.model` du modèle final.

### Résumé

`GenkitDocumentSummaryGenerator` :

- même stratégie;
- fallback spécifique `MISTRAL_SUMMARY_FALLBACK_MODEL`.

### QCM

`GenkitDiagnosticQuizGenerator` :

- même stratégie;
- fallback spécifique `MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL`;
- mode legacy conservé;
- aucune fuite de `correctChoiceId`, explication ou feedback dans l'observabilité.

## 8. Observabilité

Option retenue :

- un événement `ai.generation` par tentative.

Exemples :

- erreur primaire :
  - `status: error`;
  - `model: mistral/mistral-small-latest`;
  - `errorCode: REVISION_SHEET_SOURCE_INVALID`.
- succès fallback :
  - `status: success`;
  - `model: mistral/<fallback>`.

Données non observées :

- prompt complet;
- completion complète;
- chunks;
- textes sources;
- labels de choix générés;
- `correctChoiceId`;
- explication;
- feedback;
- réponse utilisateur.

## 9. Métadonnées persistées

Les objets retournés par les générateurs utilisent le modèle réellement producteur de la sortie valide.

Conséquence :

- si le primaire réussit, `metadata.model` vaut le modèle primaire;
- si le fallback réussit, `metadata.model` vaut le modèle fallback;
- l'échec primaire n'est pas stocké dans l'artefact;
- l'observabilité garde la trace de l'échec primaire.

## 10. Tests créés ou modifiés

Tests modifiés :

- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.spec.ts`;
- `api/src/modules/ai/infrastructure/genkit-document-summary.generator.spec.ts`;
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`.

Couverture ajoutée :

- fallback fiche sur `REVISION_SHEET_SOURCE_INVALID`;
- fallback résumé sur `SUMMARY_SOURCE_INVALID`;
- fallback QCM sur `DIAGNOSTIC_QUIZ_SOURCE_INVALID`;
- fallback spécifique prioritaire sur fallback global;
- fallback global utilisé pour résumé;
- pas de retry si fallback identique au primaire;
- modèle final propagé en metadata;
- observabilité primaire/fallback sans contenu sensible.

## 11. Code créé ou modifié

### Fichier créé complet : `api/src/modules/ai/infrastructure/mistral-model-fallback.ts`

```ts
const MISTRAL_PLUGIN_NAME = 'mistral';

export function normalizeMistralModelName(model: string): string {
  const trimmedModel = model.trim();

  if (trimmedModel.startsWith(`${MISTRAL_PLUGIN_NAME}/`)) {
    return trimmedModel;
  }

  return `${MISTRAL_PLUGIN_NAME}/${trimmedModel}`;
}

export function resolveMistralFallbackModel(input: {
  primaryModel: string;
  specificFallbackEnv: string;
}): string | null {
  const configuredFallback =
    process.env[input.specificFallbackEnv]?.trim() ||
    process.env.MISTRAL_FALLBACK_MODEL?.trim();

  if (!configuredFallback) {
    return null;
  }

  const fallbackModel = normalizeMistralModelName(configuredFallback);

  if (fallbackModel === input.primaryModel) {
    return null;
  }

  return fallbackModel;
}

export function isInvalidAiOutputError(
  error: unknown,
  sourceInvalidErrorCodes: readonly string[],
): boolean {
  if (!(error instanceof Error)) {
    return false;
  }

  if (sourceInvalidErrorCodes.includes(error.message)) {
    return true;
  }

  if (error.name === 'ZodError') {
    return true;
  }

  const normalizedMessage = error.message.toLowerCase();

  return (
    normalizedMessage.includes('schema') ||
    normalizedMessage.includes('json') ||
    normalizedMessage.includes('output')
  );
}
```

### Extrait modifié : `document-artifact-genkit-config.ts`

```ts
export function resolveArtifactMistralFallbackMetadata(
  metadata: ResolvedArtifactGenkitMetadata,
  specificFallbackEnv: string,
): ResolvedArtifactGenkitMetadata | null {
  if (!metadata.useMistral) {
    return null;
  }

  const fallbackModel = resolveMistralFallbackModel({
    primaryModel: metadata.model,
    specificFallbackEnv,
  });

  if (!fallbackModel) {
    return null;
  }

  return {
    ...metadata,
    model: fallbackModel,
  };
}
```

### Extrait modifié : `GenkitRevisionSheetGenerator`

```ts
const primaryMetadata = this.resolveMetadata();
const fallbackMetadata = resolveArtifactMistralFallbackMetadata(
  primaryMetadata,
  'MISTRAL_REVISION_SHEET_FALLBACK_MODEL',
);
const attempts = fallbackMetadata
  ? [primaryMetadata, fallbackMetadata]
  : [primaryMetadata];
```

```ts
if (
  index === 0 &&
  attempts.length > 1 &&
  isInvalidAiOutputError(error, [
    REVISION_SHEET_SOURCE_INVALID_ERROR_CODE,
  ])
) {
  continue;
}
```

### Extrait modifié : `GenkitDocumentSummaryGenerator`

```ts
const fallbackMetadata = resolveArtifactMistralFallbackMetadata(
  primaryMetadata,
  'MISTRAL_SUMMARY_FALLBACK_MODEL',
);
```

### Extrait modifié : `GenkitDiagnosticQuizGenerator`

```ts
function resolveDiagnosticQuizMistralFallbackMetadata(
  metadata: ResolvedGenkitMetadata,
): ResolvedGenkitMetadata | null {
  if (!metadata.useMistral) {
    return null;
  }

  const fallbackModel = resolveMistralFallbackModel({
    primaryModel: metadata.model,
    specificFallbackEnv: 'MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL',
  });

  if (!fallbackModel) {
    return null;
  }

  return {
    ...metadata,
    model: fallbackModel,
  };
}
```

### Extrait modifié : `.env.example`

```env
MISTRAL_FALLBACK_MODEL=""
MISTRAL_SUMMARY_FALLBACK_MODEL=""
MISTRAL_REVISION_SHEET_FALLBACK_MODEL=""
MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL=""
```

## 12. Validations lancées

Préflight :

```bash
cd api && npm run build
```

Résultat :

```text
succès
```

TDD RED :

```bash
cd api && npm test -- genkit-revision-sheet --runInBand
```

Résultat :

```text
échec attendu: REVISION_SHEET_SOURCE_INVALID sans fallback
```

Validations finales :

```bash
cd api && npm test -- genkit-revision-sheet --runInBand
```

Résultat :

```text
1 suite passed, 7 tests passed
```

```bash
cd api && npm test -- genkit-document-summary --runInBand
```

Résultat :

```text
1 suite passed, 6 tests passed
```

```bash
cd api && npm test -- genkit-diagnostic-quiz --runInBand
```

Résultat :

```text
1 suite passed, 16 tests passed
```

```bash
cd api && npm test -- ai --runInBand
```

Résultat :

```text
11 suites passed, 51 tests passed
```

```bash
cd api && npm test -- study-artifacts --runInBand
```

Résultat :

```text
5 suites passed, 34 tests passed
```

```bash
cd api && npm test -- activities --runInBand
```

Résultat :

```text
5 suites passed, 39 tests passed
```

```bash
cd api && npm run lint:check
```

Résultat :

```text
succès
```

```bash
cd api && npm run build
```

Résultat :

```text
succès
```

```bash
cd api && git diff --check
```

Résultat :

```text
succès
```

```bash
cd revision_app && git diff --check
```

Résultat :

```text
succès
```

## 13. Validations non lancées

Non lancées :

- migration Prisma : interdite et hors scope;
- `prisma migrate deploy` : interdit;
- provider IA réel : interdit;
- déploiement : interdit;
- `npm run lint` : non lancé pour éviter tout fix automatique;
- `npm run format` : interdit;
- `npm run test:cov` : interdit;
- tests Flutter : aucun code Flutter modifié.

## 14. Données non stockées / non exposées

Confirmé :

- pas de prompt stocké;
- pas de completion stockée;
- pas de chunks dans logs;
- pas de sources invalides acceptées;
- pas de source fictive;
- pas de `correctChoiceId` dans logs;
- pas de feedback ou explication dans logs;
- pas de migration;
- pas de Flutter;
- pas de GenUI.

## 15. Risques restants

- Le fallback peut augmenter la latence.
- Le fallback peut augmenter le coût IA.
- Le provider réel n'a pas été testé dans ce hotfix.
- Aucun modèle fallback n'est actif tant que les variables d'environnement ne sont pas configurées.
- Les noms de modèles doivent être vérifiés côté Mistral avant production.
- Le fallback ne remplace pas une meilleure sélection de chunks.
- Si le fallback produit aussi une sortie invalide, l'erreur reste visible côté produit.
- Les migrations DB des lots précédents restent à valider si ce n'est pas encore fait en environnement réel.

## 16. Recommandation prochain lot

Prochain lot recommandé :

```text
LOT-025 — UI QCM enrichi
```

Alternative si la priorité est la stabilité d'exploitation :

```text
mini-lot DB/runtime pour valider migrations et variables IA en production
```

## 17. Passes de review

Passe Audit / Architecture :

- verdict : fallback nécessaire côté générateurs, pas côté repository ou controller;
- aucun changement Prisma/API public requis.

Passe Implémentation :

- verdict : helper Mistral partagé et intégration dans trois flows;
- aucun changement de provider automatique.

Passe Tests :

- verdict : tests RED/GREEN ajoutés sur fiche, résumé et QCM;
- le cas prioritaire `REVISION_SHEET_SOURCE_INVALID` est couvert.

Passe Build / Validation :

- verdict : tests ciblés, lint, build et `git diff --check` passent.

Passe Critique finale :

- verdict : scope respecté;
- point d'attention : la détection par message `schema/json/output` reste volontairement bornée aux erreurs de sortie IA, mais dépend de messages Genkit/Zod.

## 18. Autocritique finale

- Le hotfix ne prouve pas qu'un modèle Mistral réel plus capable corrigera tous les cas.
- Le fallback est une mitigation, pas une amélioration de prompt ou de sélection de chunks.
- Les tests mockent Genkit et ne couvrent pas les erreurs réelles du provider.
- Le QCM reprend une logique fallback proche des artefacts, mais conserve sa config locale historique pour limiter le refactor.

## 19. Regard critique sur le prompt

- Le prompt est cohérent sur le point essentiel : ne jamais accepter des sources invalides.
- La demande de couvrir fiche, résumé et QCM dans un hotfix est un peu large, mais le code existant permettait une intégration bornée.
- La demande de fallback sur JSON/schema invalide est utile, mais les erreurs Genkit réelles peuvent varier selon provider; il faudra surveiller les logs de production.
- Le prompt ne demande pas de déployer ni de configurer le modèle fallback en production; cela reste une étape opérationnelle séparée.
