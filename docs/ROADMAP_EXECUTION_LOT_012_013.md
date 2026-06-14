# LOT-012 + LOT-013 — Extraction Genkit v2 basée sur chunks et persistance des sources

## 1. Résultat

Les lots `LOT-012` et `LOT-013` sont réalisés côté backend.

L'extraction documentaire ne s'appuie plus sur un texte complet passé directement au flow. Le worker persiste les chunks, relit les chunks persistés avec leurs vrais identifiants Prisma, puis appelle le port `DocumentKnowledgeExtractor` avec ces chunks identifiés.

Les extractors Genkit Google et Mistral utilisent désormais le contrat v2 :

- entrée : `documentId` et `chunks[]` avec `id`, `index`, `text` ;
- sortie : notions avec `sourceChunkIds` obligatoires, difficulté optionnelle, ordre optionnel, confiance optionnelle et versions de prompt/schéma ;
- validation stricte : un `sourceChunkId` absent, vide ou inconnu fait échouer l'extraction ;
- observabilité : seuls les métadonnées techniques, tailles et statuts sont observés.

Le repository documents peut maintenant persister les notions enrichies et créer les liens `KnowledgeUnitSource`. Le mode legacy sans sources reste disponible pour les tests et chemins anciens, mais le worker v2 refuse de marquer un document `READY` si une notion extraite n'a pas de source validée.

Aucune route publique, aucun frontend, aucun prompt QCM, aucun modèle Prisma et aucune migration supplémentaire n'ont été modifiés.

## 2. Sources inspectées

- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_009_010_011.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_010B.md`
- `revision_app/codex_rule.md`
- `revision_app/AGENTS.md`
- `api/package.json`
- `api/prisma/schema.prisma`
- `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql`
- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`
- `api/src/modules/documents/application/document-text-chunker.ts`
- `api/src/modules/documents/infrastructure/deterministic-document-text.chunker.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`

## 3. Préflight Git

État initial API :

```text
## main...origin/main
```

État initial frontend :

```text
## main...origin/main
```

La migration `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql` existe bien.

Validations préflight :

- `npx prisma validate` : succès ;
- `npm run prisma:generate` : succès ;
- `npx prisma migrate status` : échec `Schema engine error` ;
- `nc -zv localhost 5432` : échec, connexion refusée.

Décision : continuer avec validations unitaires et mocks, sans prétendre que la migration est appliquée ou validée sur une DB runtime locale.

## 4. LOT-012 — Extraction Genkit v2 basée sur chunks

### Contrat applicatif final

Le port `DocumentKnowledgeExtractor` accepte maintenant :

- `documentId`;
- `chunks[]` :
  - `id`;
  - `index`;
  - `text`.

Il retourne des `ExtractedKnowledgeUnit` enrichies :

- `title`;
- `summary`;
- `sourceChunkIds`;
- `difficulty`;
- `displayOrder`;
- `confidence`;
- `extractionPromptVersion`;
- `extractionSchemaVersion`.

### Stratégie de sélection de chunks

Un helper dédié sélectionne les chunks dans l'ordre du document.

Limites par défaut :

- `DOCUMENT_KNOWLEDGE_MAX_CHUNKS` : défaut `12`;
- `DOCUMENT_KNOWLEDGE_MAX_CHARS` : défaut `12000`.

Si les variables d'environnement sont invalides, les valeurs par défaut sont utilisées. Le texte envoyé au modèle peut être tronqué, mais les chunks envoyés conservent leurs identifiants persistés.

### Prompt et versions de schéma

Versions appliquées :

| Élément | Valeur |
| --- | --- |
| `promptVersion` | `document-knowledge-v2` |
| `schemaVersion` | `extracted-knowledge-v2` |
| Google provider | `google-genai` |
| Mistral provider | `mistral` |

Les prompts demandent :

- titres et résumés en français ;
- usage exclusif des chunks fournis ;
- au moins un `sourceChunkId` par notion ;
- aucune connaissance externe ;
- aucune citation libre comme source d'autorité ;
- JSON conforme au schéma.

### Validation de `sourceChunkIds`

Le schéma Zod impose :

- `sourceChunkIds: string[]` ;
- au moins un élément ;
- `confidence` entre `0` et `1` si présent ;
- `displayOrder` entier positif ou nul si présent ;
- `title` et `summary` obligatoires.

Après parsing, le backend :

- déduplique les `sourceChunkIds` par notion ;
- vérifie que chaque id existe dans les chunks fournis au modèle ;
- rejette l'output complet si un id est inconnu ;
- ajoute les versions de prompt et schéma à chaque notion.

Erreur contrôlée principale :

```text
Generated knowledge references unknown chunk
```

### Observabilité

L'observabilité conserve :

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

`inputSize` correspond à la taille du prompt construit, sans contenu observé.

## 5. LOT-013 — Persistance notions enrichies et sources

### Repository

`KnowledgeUnitPersistenceInput` accepte maintenant `sourceChunkIds`.

`PrismaDocumentsRepository.markReadyWithKnowledgeUnits` conserve deux chemins :

- sans sources : `createMany`, pour compatibilité legacy ;
- avec sources : création unitaire des `KnowledgeUnit`, puis `KnowledgeUnitSource.createMany`.

Avant de créer des sources, le repository vérifie que tous les chunks :

- existent ;
- appartiennent au même `subjectId` ;
- appartiennent au même `documentId`.

Une source vers un chunk absent ou appartenant à un autre document est rejetée avec :

```text
Knowledge unit source chunk not found
```

### Worker

Le flux worker est maintenant :

1. lire le PDF ;
2. extraire le texte ;
3. chunker le texte ;
4. persister les chunks via `replaceChunks`;
5. relire les chunks persistés via `findChunksByDocumentId`;
6. appeler `DocumentKnowledgeExtractor.extract` avec les chunks persistés ;
7. vérifier que chaque notion a au moins une source ;
8. vérifier que chaque source appartient aux chunks du document ;
9. persister notions et sources ;
10. marquer le document `READY`.

Le worker refuse :

- notion sans source ;
- source inconnue ;
- absence de chunks persistés.

Codes d'erreur worker ajoutés :

| Cas | `errorCode` |
| --- | --- |
| Notion sans source | `KNOWLEDGE_SOURCE_INVALID` |
| Source inconnue | `KNOWLEDGE_SOURCE_INVALID` |

### Atomicité et retry

Les chunks sont remplacés avant Genkit de manière idempotente. En cas de retry, `replaceChunks` supprime puis recrée les chunks du document, ce qui évite la duplication.

La persistance des notions, sources, statut document et statut job reste encapsulée dans `markReadyWithKnowledgeUnits`.

Si Genkit échoue après création des chunks, les chunks restent présents et le document peut passer `FAILED` au dernier essai, comme dans le comportement worker existant. Ce choix est documenté mais la stratégie de rétention reste à définir.

## 6. Modèles et contrats finaux

Types backend modifiés :

- `DocumentKnowledgeChunk`;
- `ExtractedKnowledgeUnit`;
- `DocumentKnowledgeExtractor.extract`;
- `KnowledgeUnitPersistenceInput`.

Helper ajouté :

- `selectDocumentKnowledgeChunks`;
- `buildDocumentKnowledgePrompt`;
- `normalizeExtractedKnowledgeOutput`.

Le schéma Prisma existant du lot `LOT-010B` suffit. Aucune nouvelle migration n'a été créée.

## 7. Données non logguées

Le lot confirme explicitement que les données suivantes ne sont pas transmises à l'observer :

- texte complet du cours ;
- chunks complets ;
- prompt complet ;
- completion complète ;
- source libre ;
- réponse utilisateur.

Les tests vérifient notamment que des sentinelles de texte chunk ne sont pas présentes dans les événements d'observabilité.

## 8. Tests créés ou modifiés

Tests modifiés :

- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts`

Couvertures ajoutées :

- extraction Google avec chunks valides ;
- extraction Mistral avec chunks valides ;
- rejet source inconnue ;
- rejet `sourceChunkIds` absent ;
- rejet `sourceChunkIds: []` ;
- rejet `confidence` hors bornes ;
- limitation du nombre et de la taille de chunks envoyés ;
- observabilité succès/erreur sans texte de chunk ;
- persistance de `difficulty`, `displayOrder`, `confidence`, versions ;
- création de `KnowledgeUnitSource`;
- rejet d'une source vers un autre document ;
- worker utilisant les chunks persistés ;
- worker rejetant notions sans source ;
- worker rejetant source inconnue ;
- non-régression QCM via suite `activities`.

## 9. Validations lancées

Depuis `api` :

```text
npm test -- genkit-document-knowledge --runInBand --silent
Résultat : échec attendu avant implémentation, ancien contrat `input.text`.
```

```text
npm test -- genkit-document-knowledge genkit-mistral-document-knowledge prisma-documents.repository document-processing.consumer --runInBand
Résultat : succès, 4 suites, 56 tests.
```

```text
npm test -- ai --runInBand
Résultat : succès, 9 suites, 38 tests.
```

```text
npm test -- documents jobs activities --runInBand
Résultat : succès, 15 suites, 86 tests.
```

```text
npx prisma validate
Résultat : succès.
```

```text
npm run prisma:generate
Résultat : succès, Prisma Client 7.8.0 généré.
```

```text
npm test -- genkit-document-knowledge --runInBand
Résultat : succès, 1 suite, 10 tests.
```

```text
npm test -- genkit-mistral-document-knowledge --runInBand
Résultat : succès, 1 suite, 9 tests.
```

```text
npm test -- document-processing --runInBand
Résultat : succès, 2 suites, 11 tests.
```

```text
npm test -- documents --runInBand
Résultat : succès, 7 suites, 49 tests.
```

```text
npm test -- jobs --runInBand
Résultat : succès, 3 suites, 12 tests.
```

```text
npm test -- activities --runInBand
Résultat : succès, 5 suites, 25 tests.
```

```text
npm run lint:check
Résultat : succès.
```

```text
npm run build
Résultat : succès.
```

```text
npx prisma migrate status
Résultat : échec, `Schema engine error`.
```

```text
nc -zv localhost 5432
Résultat : échec, connexion refusée.
```

```text
git diff --check
Résultat : succès.
```

## 10. Validations non lancées

- `npm run lint` : interdit, car peut appliquer `--fix` selon les règles du lot.
- `npm run format` : interdit.
- `npm run test:cov` : interdit.
- `npx prisma migrate deploy` : interdit.
- Migration appliquée sur DB locale : non lancée, car PostgreSQL local n'écoute pas sur `localhost:5432`.
- Migration sur staging/production : interdite et hors scope.
- Validations frontend : non lancées, aucun code frontend applicatif modifié.

## 11. Migration / DB

La migration `20260614000000_document_chunks_sources` existe déjà et aucune nouvelle migration n'a été créée.

Elle n'a pas été appliquée localement dans ce lot. `npx prisma migrate status` échoue car la datasource cible `localhost:5432` n'est pas disponible.

Les tests repository et worker sont validés avec mocks, mais la validation runtime sur une vraie base PostgreSQL propre reste à faire avant une démo complète du pipeline.

## 12. Corrections de chemins constatées

Aucune correction bloquante de chemin n'a été nécessaire pour ce lot.

Les docs de suivi sont dans :

- `revision_app/docs`

Le backend actif est dans :

- `api`

## 13. Risques restants

- Qualité des chunks : la sélection actuelle est déterministe mais naïve.
- Modèle IA : il peut choisir des sources peu pertinentes même si les IDs sont valides.
- Sélection de chunks : elle prend les premiers chunks dans l'ordre du document, sans ranking sémantique.
- Pas encore d'API publique pour exposer les notions sourcées.
- Pas encore d'UI pour afficher les sources.
- Migration non validée sur DB runtime locale.
- Stockage DB de chunks de cours : stratégie de rétention non finalisée.
- `KnowledgeUnitSource` est maintenant alimenté par le worker v2, mais aucun écran ne l'exploite encore.

## 14. Recommandation prochain lot

Prochain lot recommandé :

```text
LOT-014 — API détail document et notions sourcées
```

Justification :

- les chunks et sources sont maintenant persistés ;
- le frontend ne peut pas encore afficher les notions sourcées ;
- il faut exposer un contrat API contrôlé sans fuite de `storagePath` ;
- les tests ownership doivent confirmer qu'un étudiant ne peut pas accéder aux notions ou chunks d'un autre étudiant.

Avant ou au début de `LOT-014`, il reste prudent de lancer une validation DB locale dès qu'un PostgreSQL local est disponible :

```text
npx prisma migrate status
npx prisma migrate dev
```

sur une base de développement uniquement.

## 15. Code créé ou modifié

Cette section est ajoutée explicitement pour respecter `codex_rule.md` et `AGENTS.md` : le rapport doit contenir le code créé ou modifié, pas seulement une description.

### 15.1 Fichier créé complet — `api/src/modules/ai/infrastructure/document-knowledge-chunk-input.ts`

```ts
import {
  DOCUMENT_KNOWLEDGE_PROMPT_VERSION,
  DOCUMENT_KNOWLEDGE_SCHEMA_VERSION,
  type DocumentKnowledgeChunk,
  type ExtractedKnowledgeUnit,
} from '../application/document-knowledge-extractor';
import { ExtractedKnowledgeSchema } from './document-knowledge-output.schema';

const DEFAULT_MAX_CHUNKS = 12;
const DEFAULT_MAX_CHARS = 12000;

export function selectDocumentKnowledgeChunks(
  chunks: DocumentKnowledgeChunk[],
): DocumentKnowledgeChunk[] {
  const maxChunks = resolvePositiveInteger(
    process.env.DOCUMENT_KNOWLEDGE_MAX_CHUNKS,
    DEFAULT_MAX_CHUNKS,
  );
  const maxChars = resolvePositiveInteger(
    process.env.DOCUMENT_KNOWLEDGE_MAX_CHARS,
    DEFAULT_MAX_CHARS,
  );
  let remainingChars = maxChars;

  return [...chunks]
    .sort((left, right) => left.index - right.index)
    .filter((chunk) => chunk.text.trim().length > 0)
    .slice(0, maxChunks)
    .flatMap((chunk) => {
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

export function buildDocumentKnowledgePrompt(input: {
  documentId: string;
  chunks: DocumentKnowledgeChunk[];
}): string {
  return [
    'Analyse les extraits de cours fournis et extrais les notions principales.',
    'Réponds en français avec des titres courts et des résumés concis.',
    'Utilise uniquement les chunks fournis. N’utilise aucune connaissance externe.',
    'Chaque notion doit référencer au moins un sourceChunkId choisi uniquement parmi les ids fournis.',
    'Ne crée aucune citation libre et ne renvoie que du JSON conforme au schéma demandé.',
    `Document id: ${input.documentId}`,
    JSON.stringify({
      chunks: input.chunks.map((chunk) => ({
        id: chunk.id,
        index: chunk.index,
        text: chunk.text,
      })),
    }),
  ].join('\n\n');
}

export function normalizeExtractedKnowledgeOutput(
  output: unknown,
  chunks: DocumentKnowledgeChunk[],
): ExtractedKnowledgeUnit[] {
  const parsed = ExtractedKnowledgeSchema.parse(output ?? { units: [] });
  const knownChunkIds = new Set(chunks.map((chunk) => chunk.id));

  return parsed.units.map((unit, index) => {
    const sourceChunkIds = [...new Set(unit.sourceChunkIds)];

    if (
      sourceChunkIds.length === 0 ||
      sourceChunkIds.some((chunkId) => !knownChunkIds.has(chunkId))
    ) {
      throw new Error('Generated knowledge references unknown chunk');
    }

    return {
      title: unit.title,
      summary: unit.summary,
      sourceChunkIds,
      difficulty: unit.difficulty,
      displayOrder: unit.displayOrder ?? index,
      confidence: unit.confidence,
      extractionPromptVersion: DOCUMENT_KNOWLEDGE_PROMPT_VERSION,
      extractionSchemaVersion: DOCUMENT_KNOWLEDGE_SCHEMA_VERSION,
    };
  });
}

function resolvePositiveInteger(value: string | undefined, fallback: number) {
  const parsed = Number(value);

  if (!Number.isInteger(parsed) || parsed <= 0) {
    return fallback;
  }

  return parsed;
}
```

### 15.2 Zones modifiées — `api/src/modules/ai/application/document-knowledge-extractor.ts`

```diff
 export interface ExtractedKnowledgeUnit {
   title: string;
   summary: string;
-  sourceExcerpt?: string;
+  sourceChunkIds: string[];
   difficulty?: 'LOW' | 'MEDIUM' | 'HIGH';
+  displayOrder?: number;
+  confidence?: number;
+  extractionPromptVersion: string;
+  extractionSchemaVersion: string;
 }
 
+export interface DocumentKnowledgeChunk {
+  id: string;
+  index: number;
+  text: string;
+}
+
+export const DOCUMENT_KNOWLEDGE_PROMPT_VERSION = 'document-knowledge-v2';
+export const DOCUMENT_KNOWLEDGE_SCHEMA_VERSION = 'extracted-knowledge-v2';
+
 export interface DocumentKnowledgeExtractor {
   extract(input: {
     documentId: string;
-    fileName: string;
-    text: string;
+    chunks: DocumentKnowledgeChunk[];
   }): Promise<ExtractedKnowledgeUnit[]>;
 }
```

### 15.3 Zones modifiées — `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`

```diff
 export const ExtractedKnowledgeUnitSchema = z
   .object({
     title: z.string(),
     summary: z.string(),
-    sourceExcerpt: z.string().optional(),
+    sourceChunkIds: z.array(z.string().min(1)).min(1),
     difficulty: z.enum(['LOW', 'MEDIUM', 'HIGH']).optional(),
+    displayOrder: z.number().int().min(0).optional(),
+    confidence: z.number().min(0).max(1).optional(),
   })
   .strict();
```

### 15.4 Zones modifiées — `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`

```diff
 import {
+  DOCUMENT_KNOWLEDGE_PROMPT_VERSION,
+  DOCUMENT_KNOWLEDGE_SCHEMA_VERSION,
+  type DocumentKnowledgeChunk,
   type DocumentKnowledgeExtractor,
   type ExtractedKnowledgeUnit,
 } from '../application/document-knowledge-extractor';
 import { ExtractedKnowledgeSchema } from './document-knowledge-output.schema';
+import {
+  buildDocumentKnowledgePrompt,
+  normalizeExtractedKnowledgeOutput,
+  selectDocumentKnowledgeChunks,
+} from './document-knowledge-chunk-input';
 
 const DEFAULT_GENKIT_MODEL = 'googleai/gemini-2.5-flash';
-const DEFAULT_TEXT_INPUT_LIMIT = 12000;
 const FLOW_NAME = 'documentKnowledgeExtraction';
 const PROVIDER = 'google-genai';
-const PROMPT_VERSION = 'document-knowledge-v1';
-const SCHEMA_VERSION = 'extracted-knowledge-v1';
 const GENERATION_FAILED_ERROR_CODE = 'GENKIT_GENERATION_FAILED';
 
   async extract(input: {
     documentId: string;
-    fileName: string;
-    text: string;
+    chunks: DocumentKnowledgeChunk[];
   }): Promise<ExtractedKnowledgeUnit[]> {
-    const textInput = input.text.slice(0, resolveTextInputLimit());
+    const chunks = selectDocumentKnowledgeChunks(input.chunks);
+    const prompt = buildDocumentKnowledgePrompt({
+      documentId: input.documentId,
+      chunks,
+    });
     const model = this.resolveModel();
     const startedAt = Date.now();
 
     try {
       const { output } = await this.getAi().generate({
-        prompt: [
-          'Extract the main knowledge units from this student revision document.',
-          'Return concise French titles and summaries.',
-          'Return JSON only using the requested schema.',
-          `Document id: ${input.documentId}`,
-          `File name: ${input.fileName}`,
-          textInput,
-        ].join('\n\n'),
+        prompt,
         output: {
           schema: ExtractedKnowledgeSchema,
         },
       });
+      const units = normalizeExtractedKnowledgeOutput(output, chunks);
 
       this.observer.observe({
         flowName: FLOW_NAME,
         provider: PROVIDER,
         model,
-        promptVersion: PROMPT_VERSION,
-        schemaVersion: SCHEMA_VERSION,
-        inputSize: textInput.length,
+        promptVersion: DOCUMENT_KNOWLEDGE_PROMPT_VERSION,
+        schemaVersion: DOCUMENT_KNOWLEDGE_SCHEMA_VERSION,
+        inputSize: prompt.length,
         durationMs: Date.now() - startedAt,
         status: 'success',
         documentId: input.documentId,
       });
 
-      return output?.units ?? [];
+      return units;
     } catch (error) {
       this.observer.observe({
         flowName: FLOW_NAME,
         provider: PROVIDER,
         model,
-        promptVersion: PROMPT_VERSION,
-        schemaVersion: SCHEMA_VERSION,
-        inputSize: textInput.length,
+        promptVersion: DOCUMENT_KNOWLEDGE_PROMPT_VERSION,
+        schemaVersion: DOCUMENT_KNOWLEDGE_SCHEMA_VERSION,
+        inputSize: prompt.length,
         durationMs: Date.now() - startedAt,
         status: 'error',
         errorCode: GENERATION_FAILED_ERROR_CODE,
```

### 15.5 Zones modifiées — `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`

```diff
 import {
+  DOCUMENT_KNOWLEDGE_PROMPT_VERSION,
+  DOCUMENT_KNOWLEDGE_SCHEMA_VERSION,
+  type DocumentKnowledgeChunk,
   type DocumentKnowledgeExtractor,
   type ExtractedKnowledgeUnit,
 } from '../application/document-knowledge-extractor';
 import { ExtractedKnowledgeSchema } from './document-knowledge-output.schema';
+import {
+  buildDocumentKnowledgePrompt,
+  normalizeExtractedKnowledgeOutput,
+  selectDocumentKnowledgeChunks,
+} from './document-knowledge-chunk-input';
 
 const MISTRAL_PLUGIN_NAME = 'mistral';
 const MISTRAL_BASE_URL = 'https://api.mistral.ai/v1';
 const DEFAULT_MISTRAL_MODEL = 'mistral-small-latest';
-const DEFAULT_TEXT_INPUT_LIMIT = 12000;
 const FLOW_NAME = 'documentKnowledgeExtraction';
 const PROVIDER = 'mistral';
-const PROMPT_VERSION = 'document-knowledge-v1';
-const SCHEMA_VERSION = 'extracted-knowledge-v1';
 const GENERATION_FAILED_ERROR_CODE = 'GENKIT_GENERATION_FAILED';
 
   async extract(input: {
     documentId: string;
-    fileName: string;
-    text: string;
+    chunks: DocumentKnowledgeChunk[];
   }): Promise<ExtractedKnowledgeUnit[]> {
-    const textInput = input.text.slice(0, resolveTextInputLimit());
+    const chunks = selectDocumentKnowledgeChunks(input.chunks);
+    const prompt = buildDocumentKnowledgePrompt({
+      documentId: input.documentId,
+      chunks,
+    });
     const model = this.resolveModel();
     const startedAt = Date.now();
 
     try {
       const { output } = await this.getAi().generate({
-        prompt: [
-          'Extract the main knowledge units from this student revision document.',
-          'Return concise French titles and summaries.',
-          'Return JSON only using the requested schema.',
-          `Document id: ${input.documentId}`,
-          `File name: ${input.fileName}`,
-          textInput,
-        ].join('\n\n'),
+        prompt,
         output: {
           schema: ExtractedKnowledgeSchema,
         },
       });
+      const units = normalizeExtractedKnowledgeOutput(output, chunks);
 
       this.observer.observe({
         flowName: FLOW_NAME,
         provider: PROVIDER,
         model,
-        promptVersion: PROMPT_VERSION,
-        schemaVersion: SCHEMA_VERSION,
-        inputSize: textInput.length,
+        promptVersion: DOCUMENT_KNOWLEDGE_PROMPT_VERSION,
+        schemaVersion: DOCUMENT_KNOWLEDGE_SCHEMA_VERSION,
+        inputSize: prompt.length,
         durationMs: Date.now() - startedAt,
         status: 'success',
         documentId: input.documentId,
       });
 
-      return output?.units ?? [];
+      return units;
```

### 15.6 Zones modifiées — `api/src/modules/documents/application/documents.repository.ts`

```diff
 export interface KnowledgeUnitPersistenceInput {
   title: string;
   summary: string;
   difficulty?: KnowledgeUnitDifficulty | null;
   displayOrder?: number | null;
   confidence?: number | null;
   extractionPromptVersion?: string | null;
   extractionSchemaVersion?: string | null;
+  sourceChunkIds?: string[] | null;
 }
```

### 15.7 Zones modifiées — `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`

```diff
       if (input.units.length > 0) {
-        await tx.knowledgeUnit.createMany({
-          data: input.units.map((unit) => {
-            const knowledgeUnit = new KnowledgeUnit({
-              id: 'validation-knowledge-unit',
-              subjectId: document.subjectId,
-              title: unit.title,
-              summary: unit.summary,
-            });
-
-            return {
-              documentId: input.documentId,
-              subjectId: knowledgeUnit.subjectId,
-              title: knowledgeUnit.title,
-              summary: knowledgeUnit.summary,
-              difficulty: unit.difficulty ?? undefined,
-              displayOrder: unit.displayOrder ?? undefined,
-              confidence: unit.confidence ?? undefined,
-              extractionPromptVersion:
-                unit.extractionPromptVersion ?? undefined,
-              extractionSchemaVersion:
-                unit.extractionSchemaVersion ?? undefined,
-            };
-          }),
-        });
+        const allSourceChunkIds = [
+          ...new Set(input.units.flatMap((unit) => unit.sourceChunkIds ?? [])),
+        ];
+
+        if (allSourceChunkIds.length === 0) {
+          await tx.knowledgeUnit.createMany({
+            data: input.units.map((unit) =>
+              this.toKnowledgeUnitCreateData({
+                documentId: input.documentId,
+                subjectId: document.subjectId,
+                unit,
+              }),
+            ),
+          });
+        } else {
+          const chunks = await tx.documentChunk.findMany({
+            where: {
+              id: { in: allSourceChunkIds },
+              subjectId: document.subjectId,
+              documentId: input.documentId,
+            },
+            select: { id: true },
+          });
+          const existingChunkIds = new Set(chunks.map((chunk) => chunk.id));
+
+          if (
+            allSourceChunkIds.some((chunkId) => !existingChunkIds.has(chunkId))
+          ) {
+            throw new Error('Knowledge unit source chunk not found');
+          }
+
+          for (const unit of input.units) {
+            const sourceChunkIds = [...new Set(unit.sourceChunkIds ?? [])];
+            const createdKnowledgeUnit = await tx.knowledgeUnit.create({
+              data: this.toKnowledgeUnitCreateData({
+                documentId: input.documentId,
+                subjectId: document.subjectId,
+                unit,
+              }),
+            });
+
+            if (sourceChunkIds.length > 0) {
+              await tx.knowledgeUnitSource.createMany({
+                data: sourceChunkIds.map((chunkId) => ({
+                  knowledgeUnitId: createdKnowledgeUnit.id,
+                  subjectId: document.subjectId,
+                  chunkId,
+                  relevanceScore: null,
+                })),
+              });
+            }
+          }
+        }
       }
```

```ts
  private toKnowledgeUnitCreateData(input: {
    documentId: string;
    subjectId: string;
    unit: KnowledgeUnitPersistenceInput;
  }) {
    const knowledgeUnit = new KnowledgeUnit({
      id: 'validation-knowledge-unit',
      subjectId: input.subjectId,
      title: input.unit.title,
      summary: input.unit.summary,
    });

    return {
      documentId: input.documentId,
      subjectId: knowledgeUnit.subjectId,
      title: knowledgeUnit.title,
      summary: knowledgeUnit.summary,
      difficulty: input.unit.difficulty ?? undefined,
      displayOrder: input.unit.displayOrder ?? undefined,
      confidence: input.unit.confidence ?? undefined,
      extractionPromptVersion: input.unit.extractionPromptVersion ?? undefined,
      extractionSchemaVersion: input.unit.extractionSchemaVersion ?? undefined,
    };
  }
```

### 15.8 Zones modifiées — `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`

```diff
       await this.documentsRepository.replaceChunks({
         documentId,
         chunks,
       });
 
+      const persistedChunks =
+        await this.documentsRepository.findChunksByDocumentId(documentId);
+
+      if (persistedChunks.length === 0) {
+        throw new EmptyDocumentChunksError();
+      }
+
       units = await this.extractor.extract({
         documentId,
-        fileName: document.fileName,
-        text,
+        chunks: persistedChunks.map((chunk) => ({
+          id: chunk.id,
+          index: chunk.index,
+          text: chunk.text,
+        })),
       });
 
       if (units.length === 0) {
         throw new EmptyExtractedKnowledgeUnitsError();
       }
+
+      validateExtractedKnowledgeUnitSources(
+        units,
+        persistedChunks.map((chunk) => chunk.id),
+      );
```

```ts
class UnsourcedExtractedKnowledgeUnitsError extends Error {
  constructor() {
    super('Document knowledge extraction returned unsourced units');
  }
}

class UnknownExtractedKnowledgeSourceError extends Error {
  constructor() {
    super('Document knowledge extraction referenced unknown chunk');
  }
}
```

```diff
   if (error instanceof EmptyExtractedKnowledgeUnitsError) {
     return 'KNOWLEDGE_EXTRACTION_EMPTY';
   }
 
+  if (
+    error instanceof UnsourcedExtractedKnowledgeUnitsError ||
+    error instanceof UnknownExtractedKnowledgeSourceError
+  ) {
+    return 'KNOWLEDGE_SOURCE_INVALID';
+  }
+
   return 'KNOWLEDGE_EXTRACTION_FAILED';
 }
```

```ts
function validateExtractedKnowledgeUnitSources(
  units: Awaited<ReturnType<DocumentKnowledgeExtractor['extract']>>,
  chunkIds: string[],
): void {
  const knownChunkIds = new Set(chunkIds);

  for (const unit of units) {
    if (unit.sourceChunkIds.length === 0) {
      throw new UnsourcedExtractedKnowledgeUnitsError();
    }

    if (unit.sourceChunkIds.some((chunkId) => !knownChunkIds.has(chunkId))) {
      throw new UnknownExtractedKnowledgeSourceError();
    }
  }
}
```

### 15.9 Tests modifiés

Les tests modifiés sont listés en section 8. Ils contiennent les cas positifs, négatifs et non-régression ajoutés pendant ce lot.

```diff
diff --git a/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts b/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts
index aadddc4..30bc827 100644
--- a/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts
+++ b/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts
@@ -7,7 +7,14 @@ type GenerateInput = {
 
 type GenerateResult = {
   output?: {
-    units: Array<{ title: string; summary: string }>;
+    units: Array<{
+      title: string;
+      summary: string;
+      sourceChunkIds?: string[];
+      difficulty?: 'LOW' | 'MEDIUM' | 'HIGH';
+      displayOrder?: number;
+      confidence?: number;
+    }>;
   };
 };
 
@@ -59,6 +66,10 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
           {
             title: 'Cycle cardiaque',
             summary: 'Phases principales du cycle cardiaque.',
+            sourceChunkIds: ['chunk-1'],
+            difficulty: 'MEDIUM',
+            displayOrder: 1,
+            confidence: 0.8,
           },
         ],
       },
@@ -68,8 +79,13 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
 
     const units = await extractor.extract({
       documentId: 'document-1',
-      fileName: 'cours.pdf',
-      text: 'Contenu du document.',
+      chunks: [
+        {
+          id: 'chunk-1',
+          index: 0,
+          text: 'Contenu du document.',
+        },
+      ],
     });
 
     expect(mockGenkit).toHaveBeenCalledTimes(1);
@@ -87,11 +103,18 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
     }
     const [generateInput] = generateCall;
     expect(generateInput.prompt).toContain('Contenu du document.');
+    expect(generateInput.prompt).toContain('chunk-1');
     expect(generateInput.output.schema).toBeDefined();
     expect(units).toEqual([
       {
         title: 'Cycle cardiaque',
         summary: 'Phases principales du cycle cardiaque.',
+        sourceChunkIds: ['chunk-1'],
+        difficulty: 'MEDIUM',
+        displayOrder: 1,
+        confidence: 0.8,
+        extractionPromptVersion: 'document-knowledge-v2',
+        extractionSchemaVersion: 'extracted-knowledge-v2',
       },
     ]);
   });
@@ -106,8 +129,13 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
 
     await extractor.extract({
       documentId: 'document-1',
-      fileName: 'cours.pdf',
-      text: 'Contenu du document.',
+      chunks: [
+        {
+          id: 'chunk-1',
+          index: 0,
+          text: 'Contenu du document.',
+        },
+      ],
     });
 
     expect(mockGenkit).toHaveBeenCalledWith(
@@ -124,6 +152,7 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
           {
             title: 'SENTINEL_OUTPUT_TITLE',
             summary: 'SENTINEL_OUTPUT_SUMMARY',
+            sourceChunkIds: ['chunk-1'],
           },
         ],
       },
@@ -132,30 +161,176 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
 
     await new GenkitDocumentKnowledgeExtractor(observer).extract({
       documentId: 'document-1',
-      fileName: 'secret-file-name.pdf',
-      text: 'SENTINEL_FULL_DOCUMENT_TEXT',
+      chunks: [
+        {
+          id: 'chunk-1',
+          index: 0,
+          text: 'SENTINEL_FULL_CHUNK_TEXT',
+        },
+      ],
     });
 
     const observation = getObservedObservation(observer);
     expect(observation.durationMs).toEqual(expect.any(Number));
+    expect(observation.inputSize).toEqual(expect.any(Number));
     expect(observation).toEqual({
       flowName: 'documentKnowledgeExtraction',
       provider: 'google-genai',
       model: 'googleai/gemini-2.5-flash',
-      promptVersion: 'document-knowledge-v1',
-      schemaVersion: 'extracted-knowledge-v1',
-      inputSize: 'SENTINEL_FULL_DOCUMENT_TEXT'.length,
+      promptVersion: 'document-knowledge-v2',
+      schemaVersion: 'extracted-knowledge-v2',
+      inputSize: observation.inputSize,
       durationMs: observation.durationMs,
       status: 'success',
       documentId: 'document-1',
     });
     const observedPayload = JSON.stringify(observer.observe.mock.calls);
-    expect(observedPayload).not.toContain('SENTINEL_FULL_DOCUMENT_TEXT');
-    expect(observedPayload).not.toContain('secret-file-name.pdf');
+    expect(observedPayload).not.toContain('SENTINEL_FULL_CHUNK_TEXT');
     expect(observedPayload).not.toContain('SENTINEL_OUTPUT_TITLE');
     expect(observedPayload).not.toContain('SENTINEL_OUTPUT_SUMMARY');
   });
 
+  it('rejects generated sources that do not match provided chunks', async () => {
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+            sourceChunkIds: ['chunk-unknown'],
+          },
+        ],
+      },
+    });
+
+    await expect(
+      new GenkitDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Texte source.' }],
+      }),
+    ).rejects.toThrow('Generated knowledge references unknown chunk');
+  });
+
+  it('rejects generated units without source chunk ids', async () => {
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+          },
+        ],
+      },
+    });
+
+    await expect(
+      new GenkitDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Texte source.' }],
+      }),
+    ).rejects.toThrow();
+  });
+
+  it('rejects generated units with empty source chunk ids', async () => {
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+            sourceChunkIds: [],
+          },
+        ],
+      },
+    });
+
+    await expect(
+      new GenkitDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Texte source.' }],
+      }),
+    ).rejects.toThrow();
+  });
+
+  it('rejects generated confidence outside allowed bounds', async () => {
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+            sourceChunkIds: ['chunk-1'],
+            confidence: 1.2,
+          },
+        ],
+      },
+    });
+
+    await expect(
+      new GenkitDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Texte source.' }],
+      }),
+    ).rejects.toThrow();
+  });
+
+  it('limits chunk input sent to Genkit', async () => {
+    const originalMaxChunks = process.env.DOCUMENT_KNOWLEDGE_MAX_CHUNKS;
+    const originalMaxChars = process.env.DOCUMENT_KNOWLEDGE_MAX_CHARS;
+    process.env.DOCUMENT_KNOWLEDGE_MAX_CHUNKS = '1';
+    process.env.DOCUMENT_KNOWLEDGE_MAX_CHARS = '20';
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+            sourceChunkIds: ['chunk-1'],
+          },
+        ],
+      },
+    });
+
+    try {
+      await new GenkitDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [
+          {
+            id: 'chunk-1',
+            index: 0,
+            text: 'Premier chunk avec beaucoup de contenu.',
+          },
+          {
+            id: 'chunk-2',
+            index: 1,
+            text: 'Deuxieme chunk qui ne doit pas etre envoye.',
+          },
+        ],
+      });
+    } finally {
+      restoreEnv('DOCUMENT_KNOWLEDGE_MAX_CHUNKS', originalMaxChunks);
+      restoreEnv('DOCUMENT_KNOWLEDGE_MAX_CHARS', originalMaxChars);
+    }
+
+    const [generateInput] = mockGenerate.mock.calls[0] ?? [];
+    if (!generateInput) {
+      throw new Error('Expected generate to be called');
+    }
+    expect(generateInput.prompt).toContain('chunk-1');
+    expect(generateInput.prompt).not.toContain('chunk-2');
+    expect(generateInput.prompt).not.toContain('Deuxieme chunk');
+  });
+
   it('observes extraction errors without logging provider error messages', async () => {
     mockGenkit.mockClear();
     mockGenerate.mockReset();
@@ -167,8 +342,13 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
     await expect(
       new GenkitDocumentKnowledgeExtractor(observer).extract({
         documentId: 'document-1',
-        fileName: 'secret-file-name.pdf',
-        text: 'SENTINEL_FULL_DOCUMENT_TEXT',
+        chunks: [
+          {
+            id: 'chunk-1',
+            index: 0,
+            text: 'SENTINEL_FULL_CHUNK_TEXT',
+          },
+        ],
       }),
     ).rejects.toThrow('SENTINEL_PROVIDER_ERROR_WITH_COURSE_TEXT');
 
@@ -178,17 +358,16 @@ describe('GenkitDocumentKnowledgeExtractor', () => {
       flowName: 'documentKnowledgeExtraction',
       provider: 'google-genai',
       model: 'googleai/gemini-2.5-flash',
-      promptVersion: 'document-knowledge-v1',
-      schemaVersion: 'extracted-knowledge-v1',
-      inputSize: 'SENTINEL_FULL_DOCUMENT_TEXT'.length,
+      promptVersion: 'document-knowledge-v2',
+      schemaVersion: 'extracted-knowledge-v2',
+      inputSize: observation.inputSize,
       durationMs: observation.durationMs,
       status: 'error',
       errorCode: 'GENKIT_GENERATION_FAILED',
       documentId: 'document-1',
     });
     const observedPayload = JSON.stringify(observer.observe.mock.calls);
-    expect(observedPayload).not.toContain('SENTINEL_FULL_DOCUMENT_TEXT');
-    expect(observedPayload).not.toContain('secret-file-name.pdf');
+    expect(observedPayload).not.toContain('SENTINEL_FULL_CHUNK_TEXT');
     expect(observedPayload).not.toContain(
       'SENTINEL_PROVIDER_ERROR_WITH_COURSE_TEXT',
     );
@@ -205,6 +384,14 @@ function createObserver(): TestAiGenerationObserver {
   };
 }
 
+function restoreEnv(name: string, value: string | undefined): void {
+  if (value === undefined) {
+    delete process.env[name];
+  } else {
+    process.env[name] = value;
+  }
+}
+
 function getObservedObservation(
   observer: TestAiGenerationObserver,
 ): AiGenerationObservation {
```

```diff
diff --git a/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts b/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts
index d30cc6b..c646a12 100644
--- a/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts
+++ b/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts
@@ -7,7 +7,14 @@ type GenerateInput = {
 
 type GenerateResult = {
   output?: {
-    units: Array<{ title: string; summary: string }>;
+    units: Array<{
+      title: string;
+      summary: string;
+      sourceChunkIds?: string[];
+      difficulty?: 'LOW' | 'MEDIUM' | 'HIGH';
+      displayOrder?: number;
+      confidence?: number;
+    }>;
   };
 };
 
@@ -77,6 +84,10 @@ describe('GenkitMistralDocumentKnowledgeExtractor', () => {
           {
             title: 'Cycle cardiaque',
             summary: 'Phases principales du cycle cardiaque.',
+            sourceChunkIds: ['chunk-1'],
+            difficulty: 'MEDIUM',
+            displayOrder: 1,
+            confidence: 0.8,
           },
         ],
       },
@@ -84,8 +95,7 @@ describe('GenkitMistralDocumentKnowledgeExtractor', () => {
 
     const units = await new GenkitMistralDocumentKnowledgeExtractor().extract({
       documentId: 'document-1',
-      fileName: 'cours.pdf',
-      text: 'Contenu du document.',
+      chunks: [{ id: 'chunk-1', index: 0, text: 'Contenu du document.' }],
     });
 
     expect(mockOpenAICompatible).toHaveBeenCalledWith({
@@ -102,6 +112,12 @@ describe('GenkitMistralDocumentKnowledgeExtractor', () => {
       {
         title: 'Cycle cardiaque',
         summary: 'Phases principales du cycle cardiaque.',
+        sourceChunkIds: ['chunk-1'],
+        difficulty: 'MEDIUM',
+        displayOrder: 1,
+        confidence: 0.8,
+        extractionPromptVersion: 'document-knowledge-v2',
+        extractionSchemaVersion: 'extracted-knowledge-v2',
       },
     ]);
   });
@@ -115,8 +131,7 @@ describe('GenkitMistralDocumentKnowledgeExtractor', () => {
 
     await new GenkitMistralDocumentKnowledgeExtractor().extract({
       documentId: 'document-1',
-      fileName: 'cours.pdf',
-      text: 'Contenu du document.',
+      chunks: [{ id: 'chunk-1', index: 0, text: 'Contenu du document.' }],
     });
 
     expect(mockGenkit).toHaveBeenCalledWith(
@@ -132,8 +147,7 @@ describe('GenkitMistralDocumentKnowledgeExtractor', () => {
     await expect(
       new GenkitMistralDocumentKnowledgeExtractor().extract({
         documentId: 'document-1',
-        fileName: 'cours.pdf',
-        text: 'Contenu du document.',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Contenu du document.' }],
       }),
     ).rejects.toThrow('MISTRAL_API_KEY is required');
     expect(mockOpenAICompatible).not.toHaveBeenCalled();
@@ -152,6 +166,7 @@ describe('GenkitMistralDocumentKnowledgeExtractor', () => {
           {
             title: 'SENTINEL_OUTPUT_TITLE',
             summary: 'SENTINEL_OUTPUT_SUMMARY',
+            sourceChunkIds: ['chunk-1'],
           },
         ],
       },
@@ -160,31 +175,111 @@ describe('GenkitMistralDocumentKnowledgeExtractor', () => {
 
     await new GenkitMistralDocumentKnowledgeExtractor(observer).extract({
       documentId: 'document-1',
-      fileName: 'secret-file-name.pdf',
-      text: 'SENTINEL_FULL_DOCUMENT_TEXT',
+      chunks: [
+        {
+          id: 'chunk-1',
+          index: 0,
+          text: 'SENTINEL_FULL_CHUNK_TEXT',
+        },
+      ],
     });
 
     const observation = getObservedObservation(observer);
     expect(observation.durationMs).toEqual(expect.any(Number));
+    expect(observation.inputSize).toEqual(expect.any(Number));
     expect(observation).toEqual({
       flowName: 'documentKnowledgeExtraction',
       provider: 'mistral',
       model: 'mistral/mistral-small-latest',
-      promptVersion: 'document-knowledge-v1',
-      schemaVersion: 'extracted-knowledge-v1',
-      inputSize: 'SENTINEL_FULL_DOCUMENT_TEXT'.length,
+      promptVersion: 'document-knowledge-v2',
+      schemaVersion: 'extracted-knowledge-v2',
+      inputSize: observation.inputSize,
       durationMs: observation.durationMs,
       status: 'success',
       documentId: 'document-1',
     });
     const observedPayload = JSON.stringify(observer.observe.mock.calls);
-    expect(observedPayload).not.toContain('SENTINEL_FULL_DOCUMENT_TEXT');
-    expect(observedPayload).not.toContain('secret-file-name.pdf');
+    expect(observedPayload).not.toContain('SENTINEL_FULL_CHUNK_TEXT');
     expect(observedPayload).not.toContain('secret-test-key');
     expect(observedPayload).not.toContain('SENTINEL_OUTPUT_TITLE');
     expect(observedPayload).not.toContain('SENTINEL_OUTPUT_SUMMARY');
   });
 
+  it('rejects generated sources that do not match provided chunks', async () => {
+    process.env.MISTRAL_API_KEY = 'secret-test-key';
+    mockOpenAICompatible.mockClear();
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+            sourceChunkIds: ['chunk-unknown'],
+          },
+        ],
+      },
+    });
+
+    await expect(
+      new GenkitMistralDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Texte source.' }],
+      }),
+    ).rejects.toThrow('Generated knowledge references unknown chunk');
+  });
+
+  it('rejects generated units without source chunk ids', async () => {
+    process.env.MISTRAL_API_KEY = 'secret-test-key';
+    mockOpenAICompatible.mockClear();
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+          },
+        ],
+      },
+    });
+
+    await expect(
+      new GenkitMistralDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Texte source.' }],
+      }),
+    ).rejects.toThrow();
+  });
+
+  it('rejects generated confidence outside allowed bounds', async () => {
+    process.env.MISTRAL_API_KEY = 'secret-test-key';
+    mockOpenAICompatible.mockClear();
+    mockGenkit.mockClear();
+    mockGenerate.mockReset();
+    mockGenerate.mockResolvedValue({
+      output: {
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+            sourceChunkIds: ['chunk-1'],
+            confidence: -0.1,
+          },
+        ],
+      },
+    });
+
+    await expect(
+      new GenkitMistralDocumentKnowledgeExtractor().extract({
+        documentId: 'document-1',
+        chunks: [{ id: 'chunk-1', index: 0, text: 'Texte source.' }],
+      }),
+    ).rejects.toThrow();
+  });
```

```diff
diff --git a/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts b/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts
index 01e7a5d..624d1b7 100644
--- a/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts
+++ b/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts
@@ -30,6 +30,7 @@ type PrismaDocumentsMock = {
   };
   knowledgeUnit: {
     findUnique: jest.Mock;
+    create: jest.Mock;
     createMany: jest.Mock;
   };
   documentChunk: {
@@ -66,6 +67,7 @@ describe('PrismaDocumentsRepository', () => {
       },
       knowledgeUnit: {
         findUnique: jest.fn(),
+        create: jest.fn(),
         createMany: jest.fn(),
       },
       documentChunk: {
@@ -376,6 +378,103 @@ describe('PrismaDocumentsRepository', () => {
     });
   });
 
+  it('creates knowledge unit sources when marking sourced units ready', async () => {
+    const { prisma, repository } = createRepository();
+    prisma.document.findUnique.mockResolvedValue(
+      record({ status: 'PROCESSING' }),
+    );
+    prisma.documentChunk.findMany.mockResolvedValue([
+      { id: 'chunk-1' },
+      { id: 'chunk-2' },
+    ]);
+    prisma.knowledgeUnit.create.mockResolvedValue({
+      id: 'knowledge-unit-1',
+      subjectId: 'subject-1',
+    });
+    prisma.document.updateMany.mockResolvedValue({ count: 1 });
+    prisma.documentProcessingJob.updateMany.mockResolvedValue({ count: 1 });
+
+    await repository.markReadyWithKnowledgeUnits({
+      documentId: 'document-1',
+      units: [
+        {
+          title: 'Séparation des pouvoirs',
+          summary: 'Principe structurant les institutions.',
+          sourceChunkIds: ['chunk-2', 'chunk-1', 'chunk-2'],
+          difficulty: 'MEDIUM',
+          displayOrder: 2,
+          confidence: 0.84,
+          extractionPromptVersion: 'document-knowledge-v2',
+          extractionSchemaVersion: 'extracted-knowledge-v2',
+        },
+      ],
+    });
+
+    expect(prisma.documentChunk.findMany).toHaveBeenCalledWith({
+      where: {
+        id: { in: ['chunk-2', 'chunk-1'] },
+        subjectId: 'subject-1',
+        documentId: 'document-1',
+      },
+      select: { id: true },
+    });
+    expect(prisma.knowledgeUnit.create).toHaveBeenCalledWith({
+      data: {
+        documentId: 'document-1',
+        subjectId: 'subject-1',
+        title: 'Séparation des pouvoirs',
+        summary: 'Principe structurant les institutions.',
+        difficulty: 'MEDIUM',
+        displayOrder: 2,
+        confidence: 0.84,
+        extractionPromptVersion: 'document-knowledge-v2',
+        extractionSchemaVersion: 'extracted-knowledge-v2',
+      },
+    });
+    expect(prisma.knowledgeUnitSource.createMany).toHaveBeenCalledWith({
+      data: [
+        {
+          knowledgeUnitId: 'knowledge-unit-1',
+          subjectId: 'subject-1',
+          chunkId: 'chunk-2',
+          relevanceScore: null,
+        },
+        {
+          knowledgeUnitId: 'knowledge-unit-1',
+          subjectId: 'subject-1',
+          chunkId: 'chunk-1',
+          relevanceScore: null,
+        },
+      ],
+    });
+    expect(prisma.knowledgeUnit.createMany).not.toHaveBeenCalled();
+  });
+
+  it('rejects sourced ready transitions when a source chunk belongs to another document', async () => {
+    const { prisma, repository } = createRepository();
+    prisma.document.findUnique.mockResolvedValue(
+      record({ status: 'PROCESSING' }),
+    );
+    prisma.documentChunk.findMany.mockResolvedValue([{ id: 'chunk-1' }]);
+
+    await expect(
+      repository.markReadyWithKnowledgeUnits({
+        documentId: 'document-1',
+        units: [
+          {
+            title: 'Constitution',
+            summary: 'Norme fondamentale.',
+            sourceChunkIds: ['chunk-1', 'chunk-other-document'],
+          },
+        ],
+      }),
+    ).rejects.toThrow('Knowledge unit source chunk not found');
+
+    expect(prisma.knowledgeUnit.create).not.toHaveBeenCalled();
+    expect(prisma.knowledgeUnitSource.createMany).not.toHaveBeenCalled();
+    expect(prisma.document.updateMany).not.toHaveBeenCalled();
+  });
```

```diff
diff --git a/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts b/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts
index f6c918a..6ab294b 100644
--- a/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts
+++ b/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts
@@ -55,6 +55,12 @@ describe('DocumentProcessingConsumer', () => {
       {
         title: 'Cycle cardiaque',
         summary: 'Phases principales du cycle cardiaque.',
+        sourceChunkIds: ['chunk-1'],
+        difficulty: 'MEDIUM',
+        displayOrder: 1,
+        confidence: 0.75,
+        extractionPromptVersion: 'document-knowledge-v2',
+        extractionSchemaVersion: 'extracted-knowledge-v2',
       },
     ]);
 
@@ -84,8 +90,13 @@ describe('DocumentProcessingConsumer', () => {
     });
     expect(extractor.extract).toHaveBeenCalledWith({
       documentId: 'document-1',
-      fileName: 'cours.pdf',
-      text: 'Contenu PDF exploitable.',
+      chunks: [
+        {
+          id: 'chunk-1',
+          index: 0,
+          text: 'Contenu PDF exploitable.',
+        },
+      ],
     });
@@ -102,6 +113,9 @@ describe('DocumentProcessingConsumer', () => {
     expect(
       documentsRepository.replaceChunks.mock.invocationCallOrder[0],
     ).toBeLessThan(extractor.extract.mock.invocationCallOrder[0]);
+    expect(documentsRepository.findChunksByDocumentId).toHaveBeenCalledWith(
+      'document-1',
+    );
     expect(
       documentsRepository.markReadyWithKnowledgeUnits,
     ).toHaveBeenCalledWith({
@@ -110,6 +124,12 @@ describe('DocumentProcessingConsumer', () => {
         {
           title: 'Cycle cardiaque',
           summary: 'Phases principales du cycle cardiaque.',
+          sourceChunkIds: ['chunk-1'],
+          difficulty: 'MEDIUM',
+          displayOrder: 1,
+          confidence: 0.75,
+          extractionPromptVersion: 'document-knowledge-v2',
+          extractionSchemaVersion: 'extracted-knowledge-v2',
         },
       ],
     });
@@ -280,6 +300,84 @@ describe('DocumentProcessingConsumer', () => {
     ).not.toHaveBeenCalled();
   });
 
+  it('fails sourced extraction when a generated unit has no source', async () => {
+    const documentsRepository = createDocumentsRepository();
+    const extractor = createExtractor();
+    const contentReader = createContentReader();
+    const textExtractor = createTextExtractor();
+    const chunker = createChunker();
+    extractor.extract.mockResolvedValue([
+      {
+        title: 'Constitution',
+        summary: 'Norme fondamentale.',
+        sourceChunkIds: [],
+      },
+    ]);
+
+    const consumer = new DocumentProcessingConsumer(
+      documentsRepository.service,
+      extractor.service,
+      contentReader.service,
+      textExtractor.service,
+      chunker.service,
+    );
+
+    await expect(
+      consumer.process({
+        data: { documentId: 'document-1' },
+        attemptsMade: 2,
+        opts: { attempts: 3 },
+      } as Job<{ documentId: string }>),
+    ).rejects.toThrow('Document knowledge extraction returned unsourced units');
+
+    expect(documentsRepository.markFailed).toHaveBeenCalledWith({
+      documentId: 'document-1',
+      errorCode: 'KNOWLEDGE_SOURCE_INVALID',
+    });
+    expect(
+      documentsRepository.markReadyWithKnowledgeUnits,
+    ).not.toHaveBeenCalled();
+  });
+
+  it('fails sourced extraction when a generated source is not a persisted chunk', async () => {
+    const documentsRepository = createDocumentsRepository();
+    const extractor = createExtractor();
+    const contentReader = createContentReader();
+    const textExtractor = createTextExtractor();
+    const chunker = createChunker();
+    extractor.extract.mockResolvedValue([
+      {
+        title: 'Constitution',
+        summary: 'Norme fondamentale.',
+        sourceChunkIds: ['chunk-unknown'],
+      },
+    ]);
+
+    const consumer = new DocumentProcessingConsumer(
+      documentsRepository.service,
+      extractor.service,
+      contentReader.service,
+      textExtractor.service,
+      chunker.service,
+    );
+
+    await expect(
+      consumer.process({
+        data: { documentId: 'document-1' },
+        attemptsMade: 2,
+        opts: { attempts: 3 },
+      } as Job<{ documentId: string }>),
+    ).rejects.toThrow('Document knowledge extraction referenced unknown chunk');
+
+    expect(documentsRepository.markFailed).toHaveBeenCalledWith({
+      documentId: 'document-1',
+      errorCode: 'KNOWLEDGE_SOURCE_INVALID',
+    });
+    expect(
+      documentsRepository.markReadyWithKnowledgeUnits,
+    ).not.toHaveBeenCalled();
+  });
@@ -319,12 +417,26 @@ function createDocumentsRepository(): {
   markFailed: jest.Mock;
   findById: jest.Mock;
   replaceChunks: jest.Mock;
+  findChunksByDocumentId: jest.Mock;
 } {
   const markProcessing = jest.fn().mockResolvedValue(undefined);
   const markReadyWithKnowledgeUnits = jest.fn().mockResolvedValue(undefined);
   const markFailed = jest.fn().mockResolvedValue(undefined);
   const findById = jest.fn().mockResolvedValue(documentRecord());
   const replaceChunks = jest.fn().mockResolvedValue(undefined);
+  const findChunksByDocumentId = jest.fn().mockResolvedValue([
+    {
+      id: 'chunk-1',
+      documentId: 'document-1',
+      subjectId: 'subject-1',
+      index: 0,
+      text: 'Contenu PDF exploitable.',
+      charStart: 0,
+      charEnd: 23,
+      pageNumber: null,
+      createdAt: new Date('2026-06-14T12:00:00.000Z'),
+    },
+  ]);
 
   return {
     service: {
@@ -336,7 +448,7 @@ function createDocumentsRepository(): {
       markReadyWithKnowledgeUnits,
       markFailed,
       replaceChunks,
-      findChunksByDocumentId: jest.fn(),
+      findChunksByDocumentId,
       replaceKnowledgeUnitSources: jest.fn(),
     },
     markProcessing,
@@ -344,6 +456,7 @@ function createDocumentsRepository(): {
     markFailed,
     findById,
     replaceChunks,
+    findChunksByDocumentId,
   };
 }
```
