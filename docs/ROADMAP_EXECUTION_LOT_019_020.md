# LOT-019 + LOT-020 — Flows Genkit et API résumés/fiches

## 1. Résultat

`LOT-019 + LOT-020` est réalisé côté backend uniquement.

Le lot ajoute :

- deux ports applicatifs IA :
  - `DocumentSummaryGenerator`;
  - `RevisionSheetGenerator`;
- deux adapters Genkit typés :
  - `GenkitDocumentSummaryGenerator`;
  - `GenkitRevisionSheetGenerator`;
- des schémas Zod stricts pour les sorties résumé et fiche;
- une sélection bornée des chunks envoyés au modèle;
- une validation stricte des `sourceChunkIds`;
- l'observabilité `AiGenerationObserver` sur les deux nouveaux flows;
- deux use cases applicatifs de génération :
  - `GenerateDocumentSummaryUseCase`;
  - `GenerateRevisionSheetUseCase`;
- quatre endpoints backend :
  - `GET /documents/:documentId/summary`;
  - `POST /documents/:documentId/summary`;
  - `GET /documents/:documentId/revision-sheet`;
  - `POST /documents/:documentId/revision-sheet`.

Le lot ne modifie pas le frontend applicatif, ne crée aucune migration Prisma, ne démarre pas `LOT-021`, ne crée pas GenUI, ne modifie pas le QCM et ne crée pas `GeneratedArtifact` ou `AiGenerationJob`.

## 2. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_017.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_018.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`

Backend :

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/src/app.module.ts`
- `api/src/modules/ai/ai.module.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/application/get-document.use-case.ts`
- `api/src/modules/documents/application/list-document-knowledge-units.use-case.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/interfaces/documents.controller.spec.ts`
- `api/src/modules/documents/documents.module.ts`
- `api/src/modules/study-artifacts/application/study-artifacts.repository.ts`
- `api/src/modules/study-artifacts/application/get-document-summary.use-case.ts`
- `api/src/modules/study-artifacts/application/save-document-summary.use-case.ts`
- `api/src/modules/study-artifacts/application/get-revision-sheet.use-case.ts`
- `api/src/modules/study-artifacts/application/save-revision-sheet.use-case.ts`
- `api/src/modules/study-artifacts/infrastructure/prisma-study-artifacts.repository.ts`
- `api/src/modules/study-artifacts/study-artifacts.module.ts`

## 3. Préflight Git et Prisma

État initial API :

```text
## main...origin/main
 M src/modules/ai/ai.module.ts
 M src/modules/documents/documents.module.ts
 M src/modules/study-artifacts/study-artifacts.module.ts
?? src/modules/ai/application/document-summary-generator.ts
?? src/modules/ai/application/revision-sheet-generator.ts
?? src/modules/ai/infrastructure/document-artifact-generation-input.ts
?? src/modules/ai/infrastructure/document-artifact-genkit-config.ts
?? src/modules/ai/infrastructure/document-artifact-output.schema.ts
?? src/modules/ai/infrastructure/genkit-document-summary.generator.spec.ts
?? src/modules/ai/infrastructure/genkit-document-summary.generator.ts
?? src/modules/ai/infrastructure/genkit-revision-sheet.generator.spec.ts
?? src/modules/ai/infrastructure/genkit-revision-sheet.generator.ts
?? src/modules/study-artifacts/application/generate-document-summary.use-case.spec.ts
?? src/modules/study-artifacts/application/generate-document-summary.use-case.ts
?? src/modules/study-artifacts/application/generate-revision-sheet.use-case.spec.ts
?? src/modules/study-artifacts/application/generate-revision-sheet.use-case.ts
```

État initial frontend :

```text
## main...origin/main
```

Fichiers requis présents :

- `revision_app/docs/ROADMAP_EXECUTION_LOT_018.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql`
- `api/prisma/migrations/20260614141000_summary_revision_sheet_artifacts/migration.sql`

Préflight Prisma :

- `cd api && npx prisma validate` : succès.
- `cd api && npm run prisma:generate` : succès.
- `cd api && npx prisma migrate status` : échec avec `Schema engine error` sur PostgreSQL local `localhost:5432`.

Décision :

- aucune migration nouvelle n'est créée;
- les tests et validations de ce lot restent unitaires/mocks;
- le runtime DB local reste non validé.

## 4. LOT-019 — Flow Genkit résumé et fiche

Ports créés :

- `DocumentSummaryGenerator`;
- `RevisionSheetGenerator`.

Adapters créés :

- `GenkitDocumentSummaryGenerator`;
- `GenkitRevisionSheetGenerator`.

Schémas Zod :

- `GeneratedDocumentSummarySchema`;
- `GeneratedRevisionSheetSchema`;
- `GeneratedRevisionSheetSectionSchema`.

Contraintes de schéma :

- objets `.strict()`;
- chaînes trimées non vides;
- `keyPoints` non vide;
- résumé avec `sourceChunkIds` non vide;
- fiche avec au moins une section;
- chaque section de fiche avec `sourceChunkIds` non vide.

Sélection de chunks :

- résumé :
  - `SUMMARY_GENERATION_MAX_CHUNKS`, défaut `12`;
  - `SUMMARY_GENERATION_MAX_CHARS`, défaut `12000`;
- fiche :
  - `REVISION_SHEET_GENERATION_MAX_CHUNKS`, défaut `16`;
  - `REVISION_SHEET_GENERATION_MAX_CHARS`, défaut `16000`.

Les chunks sont triés par `index`, tronqués par nombre puis par taille cumulée. Le prompt peut contenir les textes nécessaires au modèle, mais l'observabilité ne les reçoit jamais.

Validation sources :

- les `sourceChunkIds` sont dédupliqués;
- un `sourceChunkId` inconnu provoque :
  - `SUMMARY_SOURCE_INVALID`;
  - `REVISION_SHEET_SOURCE_INVALID`;
- un résumé sans source est rejeté;
- une section de fiche sans source est rejetée;
- aucune source libre n'est acceptée comme autorité.

Observabilité :

- `flowName`;
- `provider`;
- `model`;
- `promptVersion`;
- `schemaVersion`;
- `inputSize`;
- `durationMs`;
- `status`;
- `errorCode`;
- `documentId`.

Versions :

| Flow | Provider | Model | promptVersion | schemaVersion |
| --- | --- | --- | --- | --- |
| Résumé | `google-genai` ou `mistral` | `GENKIT_MODEL` ou `MISTRAL_MODEL` | `generate-summary-v1` | `summary-v1` |
| Fiche | `google-genai` ou `mistral` | `GENKIT_MODEL` ou `MISTRAL_MODEL` | `generate-revision-sheet-v1` | `revision-sheet-v1` |

Provider :

- Google reste le défaut via `@genkit-ai/google-genai`;
- Mistral est supporté via `@genkit-ai/compat-oai`, en cohérence avec les extractors existants;
- les tests mockent Genkit et le plugin OpenAI-compatible, sans appel provider réel.

## 5. LOT-020 — API résumés et fiches

Endpoints ajoutés :

- `GET /documents/:documentId/summary`;
- `POST /documents/:documentId/summary`;
- `GET /documents/:documentId/revision-sheet`;
- `POST /documents/:documentId/revision-sheet`.

Controller :

- `StudyArtifactsController`;
- base route `documents`;
- protégé par `FirebaseAuthGuard`;
- utilise `CurrentStudent`;
- validate `documentId` vide en `400`.

Use cases de génération :

- `GenerateDocumentSummaryUseCase`;
- `GenerateRevisionSheetUseCase`.

Comportement :

- `GET` lit uniquement, ne génère jamais;
- `GET` retourne `404` si l'artefact n'existe pas;
- `POST` retourne l'artefact `READY` existant sans régénérer;
- `POST` charge document, chunks, notions sourcées;
- `POST` rejette document absent, document non `READY`, chunks absents ou notions sourcées absentes;
- `POST` appelle Genkit seulement si aucun artefact `READY` n'existe;
- `POST` persiste via les use cases `SaveDocumentSummaryUseCase` et `SaveRevisionSheetUseCase`;
- après sauvegarde, le use case relit l'artefact pour retourner les sources/sections complètes.

DTOs publics :

- les métadonnées IA internes ne sont pas exposées par défaut;
- `errorCode` est exposé;
- les sources exposent uniquement `chunkId`, `text`, `pageNumber`, `index`;
- `relevanceScore` n'est pas exposé;
- `storagePath` n'est pas exposé.

Erreurs :

- `400` : `documentId` vide;
- `404` : document ou artefact absent via use cases;
- `409` : document non `READY`, chunks absents, notions sourcées absentes;
- `422` : source générée invalide;
- `502` : erreur provider/génération non contrôlée.

## 6. Données non stockées / non exposées

Confirmé :

- pas de prompt complet stocké;
- pas de completion complète stockée;
- pas de texte complet du cours stocké dans un artefact;
- pas de chunks complets stockés dans un payload JSON d'artefact;
- pas de chunks non liés exposés;
- pas de source libre acceptée;
- pas de `storagePath` exposé;
- pas de payload GenUI;
- pas de réponse utilisateur.

## 7. Validations lancées

Depuis `api` :

```bash
npx prisma validate
```

Résultat : succès.

```bash
npm run prisma:generate
```

Résultat : succès, Prisma Client 7.8.0 généré dans `./src/generated/prisma`.

```bash
npx prisma migrate status
```

Résultat : échec connu, `Schema engine error` sur PostgreSQL local `localhost:5432`.

```bash
npm test -- genkit-document-summary genkit-revision-sheet --runInBand
```

Résultat initial RED : échec car les generators n'existaient pas encore.

```bash
npm test -- generate-document-summary generate-revision-sheet --runInBand
```

Résultat initial RED : échec car les use cases n'existaient pas encore.

```bash
npm test -- study-artifacts.controller --runInBand
```

Résultat initial RED : échec car le controller n'existait pas encore.

```bash
npm test -- ai --runInBand
```

Résultat : 11 suites passées, 48 tests passés.

```bash
npm test -- study-artifacts --runInBand
```

Résultat : 5 suites passées, 34 tests passés.

```bash
npm test -- documents --runInBand
```

Résultat : 8 suites passées, 57 tests passés.

```bash
npm test -- jobs --runInBand
```

Résultat : 3 suites passées, 12 tests passés.

```bash
npm test -- activities --runInBand
```

Résultat : 5 suites passées, 25 tests passés.

```bash
npm run lint:check
```

Résultat : succès après corrections manuelles de format et de règles `unbound-method`.

```bash
npm run build
```

Résultat : succès.

```bash
git diff --check
```

Résultat API : succès.

```bash
git diff --check
```

Résultat frontend : succès.

## 8. Validations non lancées

Non lancé :

- `npm run lint`, car ce script peut appliquer `--fix` selon les règles du lot.
- `npm run format`, explicitement interdit.
- `npm run test:cov`, explicitement interdit.
- `npx prisma migrate deploy`, explicitement interdit.
- migration sur production/staging, explicitement interdite.
- tests Flutter, car aucun code Flutter applicatif n'est modifié.
- provider IA réel, car les tests doivent mocker Genkit.

## 9. Migration / DB

Aucune migration Prisma créée dans ce lot.

Migrations existantes :

- `20260614000000_document_chunks_sources`;
- `20260614141000_summary_revision_sheet_artifacts`.

État runtime DB :

- non validé;
- `npx prisma migrate status` échoue encore avec `Schema engine error` sur PostgreSQL local;
- il faudra valider les migrations sur une DB locale fonctionnelle avant un test bout-en-bout réel.

## 10. Tests créés ou modifiés

Créés :

- `api/src/modules/ai/infrastructure/genkit-document-summary.generator.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.spec.ts`
- `api/src/modules/study-artifacts/application/generate-document-summary.use-case.spec.ts`
- `api/src/modules/study-artifacts/application/generate-revision-sheet.use-case.spec.ts`
- `api/src/modules/study-artifacts/interfaces/study-artifacts.controller.spec.ts`

Couverture ajoutée :

- génération résumé avec sources valides;
- génération fiche avec sections sourcées;
- rejet source inconnue;
- rejet absence de source;
- limitation d'input;
- observabilité sans chunks, prompt, completion ou sortie générée;
- support Mistral mocké;
- short-circuit si artefact `READY` existe déjà;
- document absent;
- document non `READY`;
- chunks absents;
- notions sourcées absentes;
- mapping source invalide en `422`;
- mapping provider en `502`;
- DTO public sans métadonnées internes, `storagePath` ou `relevanceScore`.

## 11. Risques restants

- DB locale toujours non validée.
- Les prompts doivent encore être testés avec providers réels.
- La sélection de chunks reste naïve : ordre documentaire et limite taille/nombre.
- Le coût IA et les timeouts réels ne sont pas validés.
- Pas encore d'UI Flutter pour lire ou générer les artefacts.
- Pas encore de rendu GenUI.
- Pas de régénération explicite.
- Pas de génération asynchrone.
- Les erreurs provider ne créent pas encore d'artefact `FAILED` persistant.

## 12. Recommandation prochain lot

Le prochain lot recommandé est `LOT-021 — UI résumé et fiche`, seulement si l'équipe accepte que la validation DB locale reste à faire en parallèle.

Si l'objectif est une validation bout-en-bout avant UI, le prochain mini-lot devrait être une réparation environnement DB locale pour appliquer et vérifier :

- `20260614000000_document_chunks_sources`;
- `20260614141000_summary_revision_sheet_artifacts`.

## 13. Code créé ou modifié

Le lot a créé ou modifié les fichiers suivants.

Fichiers créés :

- `api/src/modules/ai/application/document-summary-generator.ts`
- `api/src/modules/ai/application/revision-sheet-generator.ts`
- `api/src/modules/ai/infrastructure/document-artifact-generation-input.ts`
- `api/src/modules/ai/infrastructure/document-artifact-genkit-config.ts`
- `api/src/modules/ai/infrastructure/document-artifact-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-summary.generator.ts`
- `api/src/modules/ai/infrastructure/genkit-document-summary.generator.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.ts`
- `api/src/modules/ai/infrastructure/genkit-revision-sheet.generator.spec.ts`
- `api/src/modules/study-artifacts/application/generate-document-summary.use-case.ts`
- `api/src/modules/study-artifacts/application/generate-document-summary.use-case.spec.ts`
- `api/src/modules/study-artifacts/application/generate-revision-sheet.use-case.ts`
- `api/src/modules/study-artifacts/application/generate-revision-sheet.use-case.spec.ts`
- `api/src/modules/study-artifacts/interfaces/study-artifacts.controller.ts`
- `api/src/modules/study-artifacts/interfaces/study-artifacts.controller.spec.ts`

Fichiers modifiés :

- `api/src/modules/ai/ai.module.ts`
- `api/src/modules/documents/documents.module.ts`
- `api/src/modules/study-artifacts/study-artifacts.module.ts`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_019_020.md`

Extraits de code clés :

```ts
export const DOCUMENT_SUMMARY_GENERATOR = Symbol('DOCUMENT_SUMMARY_GENERATOR');

export const DOCUMENT_SUMMARY_FLOW_NAME = 'documentSummaryGeneration';
export const DOCUMENT_SUMMARY_PROMPT_VERSION = 'generate-summary-v1';
export const DOCUMENT_SUMMARY_SCHEMA_VERSION = 'summary-v1';

export interface DocumentSummaryGenerator {
  generate(input: {
    documentId: string;
    chunks: DocumentArtifactChunk[];
    knowledgeUnits: DocumentArtifactKnowledgeUnit[];
  }): Promise<GeneratedDocumentSummary>;
}
```

```ts
export const REVISION_SHEET_GENERATOR = Symbol('REVISION_SHEET_GENERATOR');

export const REVISION_SHEET_FLOW_NAME = 'documentRevisionSheetGeneration';
export const REVISION_SHEET_PROMPT_VERSION = 'generate-revision-sheet-v1';
export const REVISION_SHEET_SCHEMA_VERSION = 'revision-sheet-v1';

export interface RevisionSheetGenerator {
  generate(input: {
    documentId: string;
    chunks: DocumentArtifactChunk[];
    knowledgeUnits: DocumentArtifactKnowledgeUnit[];
  }): Promise<GeneratedRevisionSheet>;
}
```

```ts
export const GeneratedDocumentSummarySchema = z
  .object({
    title: NonEmptyStringSchema,
    content: NonEmptyStringSchema,
    keyPoints: z.array(NonEmptyStringSchema).min(1),
    limits: NonEmptyStringSchema.nullish(),
    sourceChunkIds: z.array(NonEmptyStringSchema).min(1),
  })
  .strict();
```

```ts
export const GeneratedRevisionSheetSchema = z
  .object({
    title: NonEmptyStringSchema,
    introduction: NonEmptyStringSchema.nullish(),
    sections: z.array(GeneratedRevisionSheetSectionSchema).min(1),
    keyPoints: z.array(NonEmptyStringSchema).min(1),
    commonMistakes: z.array(NonEmptyStringSchema).optional(),
    mustKnow: z.array(NonEmptyStringSchema).optional(),
    practiceSuggestions: z.array(NonEmptyStringSchema).optional(),
  })
  .strict();
```

```ts
@Controller('documents')
@UseGuards(FirebaseAuthGuard)
export class StudyArtifactsController {
  constructor(
    private readonly getDocumentSummary: GetDocumentSummaryUseCase,
    private readonly generateDocumentSummary: GenerateDocumentSummaryUseCase,
    private readonly getDocumentRevisionSheet: GetRevisionSheetUseCase,
    private readonly generateDocumentRevisionSheet: GenerateRevisionSheetUseCase,
  ) {}
}
```

```ts
function toPublicSource(source: StudyArtifactSourceDto) {
  return {
    chunkId: source.chunkId,
    text: source.text,
    pageNumber: source.pageNumber,
    index: source.index,
  };
}
```

Diffs de wiring :

```diff
+ import { DOCUMENT_SUMMARY_GENERATOR } from './application/document-summary-generator';
+ import { REVISION_SHEET_GENERATOR } from './application/revision-sheet-generator';
+ import { GenkitDocumentSummaryGenerator } from './infrastructure/genkit-document-summary.generator';
+ import { GenkitRevisionSheetGenerator } from './infrastructure/genkit-revision-sheet.generator';
```

```diff
+ exports: [DOCUMENTS_REPOSITORY],
```

```diff
+ imports: [AiModule, AuthModule, DocumentsModule, PrismaModule],
+ controllers: [StudyArtifactsController],
+ providers: [
+   GenerateDocumentSummaryUseCase,
+   GenerateRevisionSheetUseCase,
+   ...
+ ],
```

## 14. Passes de revue

Sub-agent Audit / Architecture :

- verdict : séparer le controller `study-artifacts` sous `@Controller('documents')` évite d'alourdir `DocumentsController`;
- point retenu : DTOs publics allowlistés, pas de spread d'artefacts Prisma/domain.

Sub-agent Implémentation :

- verdict : les nouveaux flows suivent les patterns Genkit existants;
- point retenu : un helper partagé limite les chunks et construit les prompts sans exposer de contenu à l'observer.

Sub-agent Tests :

- verdict : les tests couvrent RED/GREEN, cas positifs, sources invalides, provider failure et non-exposition de données internes.

Sub-agent Build / Validation :

- verdict : validations backend ciblées, lint et build passent;
- réserve : `migrate status` reste bloqué par l'environnement DB local.

Sub-agent Critique finale :

- verdict : scope respecté;
- risques : pas d'artefact `FAILED` persistant sur erreur provider, pas de DB runtime validée, prompts non testés contre provider réel.

## 15. Autocritique

Le lot respecte le périmètre backend et ne crée ni frontend, ni GenUI, ni migration. La couverture de tests est bonne pour les contrats, mais reste entièrement mockée côté IA. Le choix de ne pas persister un artefact `FAILED` lors d'une erreur provider simplifie le lot mais laisse une amélioration future. Le rapport inclut des extraits de code clés plutôt qu'un dump complet de tous les fichiers, pour rester lisible; les fichiers créés sont listés explicitement.

## 16. Regard critique sur le prompt

Le prompt est précis, mais large pour un seul batch : il mélange flows Genkit, orchestration applicative, API, tests, documentation et validations. Le découpage reste faisable parce que la persistance `LOT-018` était déjà prête. La demande “aucun commentaire dans le code” contredit `codex_rule.md`, qui demande beaucoup de commentaires utiles; la règle spécifique du prompt a été suivie. La demande de supporter Google et Mistral est pertinente, mais les tests provider réel restent volontairement hors scope.
