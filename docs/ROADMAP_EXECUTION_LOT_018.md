# LOT-018 — Persistance Summary et RevisionSheet

## 1. Résultat

`LOT-018` est réalisé côté backend uniquement.

Le lot ajoute une persistance spécialisée pour les artefacts IA de document :

- `Summary`;
- `SummarySource`;
- `RevisionSheet`;
- `RevisionSheetSection`;
- `RevisionSheetSectionSource`;
- enum `StudyArtifactStatus`;
- enum `StudyArtifactSourceStrategy`.

Un module backend dédié `study-artifacts` a été ajouté, sans controller public et sans route API. Il expose des use cases applicatifs et un repository Prisma capables de lire, sauvegarder et remplacer un résumé ou une fiche de révision pour un document.

Le lot ne démarre pas `LOT-019` : aucun flow Genkit résumé/fiche, aucun prompt, aucun endpoint public, aucun composant Flutter et aucun payload GenUI n'ont été ajoutés.

## 2. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_010B.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_012_013.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_014_015_016.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_017.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`

Backend :

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql`
- `api/src/app.module.ts`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`
- `api/src/modules/documents/domain/document.entity.ts`
- `api/src/modules/documents/documents.module.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`

## 3. Préflight Git et Prisma

État initial API :

```text
## main...origin/main
```

État initial Flutter :

```text
## main...origin/main
```

Checks préflight :

- `revision_app/docs/ROADMAP_EXECUTION_LOT_017.md` existe.
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md` existe.
- `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql` existe.
- `cd api && npx prisma validate` passe.
- `cd api && npm run prisma:generate` passe.
- `cd api && npx prisma migrate status` échoue avec `Schema engine error` sur `localhost:5432`.

Conclusion DB locale :

PostgreSQL local n'est toujours pas disponible ou pas exploitable par Prisma Migrate. Le runtime DB réel n'est donc pas validé dans ce lot. La migration de ce lot a été générée par `prisma migrate diff` depuis un snapshot du schéma pré-lot.

## 4. Décisions d'implémentation

Module choisi :

- module dédié `StudyArtifactsModule`;
- pas d'extension du module `documents`;
- pas de controller public.

Raison :

Les artefacts d'étude ne sont pas des documents bruts, ni des notions. Un module dédié garde une frontière claire pour les futurs lots `019`, `020` et `021`.

Modèles créés :

- `Summary` : résumé courant d'un document;
- `SummarySource` : lien entre résumé et chunks sources;
- `RevisionSheet` : fiche courante d'un document;
- `RevisionSheetSection` : section ordonnée de fiche;
- `RevisionSheetSectionSource` : sources par section.

Choix des statuts :

- `READY`;
- `FAILED`.

`PENDING` et `GENERATING` sont volontairement absents, car le lot n'introduit pas de génération asynchrone.

Choix JSON vs tables :

- les listes simples (`keyPoints`, `commonMistakes`, `mustKnow`, `practiceSuggestions`) sont stockées en JSON applicatif;
- les sources sont stockées en tables relationnelles, pas en JSON.

Choix sources :

- résumé : sources globales au niveau `SummarySource`;
- fiche : sources au niveau section via `RevisionSheetSectionSource`;
- pas de `SourceReference` globale;
- pas de source libre inventée.

Choix `sourceStrategy` :

- enum `StudyArtifactSourceStrategy`;
- valeurs ajoutées : `DOCUMENT_CHUNKS`, `DOCUMENT_CHUNKS_AND_KNOWLEDGE_UNITS`;
- les méthodes de repository acceptent la stratégie fournie par les futurs flows.

Conflit de règles constaté :

- le prompt interdit tout commentaire dans le code;
- `codex_rule.md` demande beaucoup de commentaires utiles;
- la règle appliquée ici est la plus stricte et la plus spécifique au lot courant : aucun commentaire TypeScript ou Prisma ajouté.

## 5. Modèles Prisma ajoutés

`Summary` :

- appartient à `StudentProfile`, `Subject` et `Document`;
- impose un seul résumé courant par document avec `@@unique([documentId])`;
- stocke les métadonnées IA communes : `flowName`, `provider`, `model`, `promptVersion`, `schemaVersion`, `generatedAt`, `inputSize`, `sourceStrategy`, `errorCode`;
- expose `@@unique([id, subjectId])` pour les relations composites de sources.

`SummarySource` :

- clé composée `@@id([summaryId, chunkId])`;
- relation composite vers `Summary(id, subjectId)`;
- relation composite vers `DocumentChunk(id, subjectId)`;
- empêche le cross-subject au niveau DB;
- le cross-document est vérifié dans le repository.

`RevisionSheet` :

- appartient à `StudentProfile`, `Subject` et `Document`;
- impose une fiche courante par document avec `@@unique([documentId])`;
- stocke les champs métier JSON simples et les métadonnées IA communes.

`RevisionSheetSection` :

- appartient à `RevisionSheet`;
- ordre stable via `displayOrder`;
- unicité `@@unique([revisionSheetId, displayOrder])`;
- expose `@@unique([id, subjectId])` pour les relations de sources.

`RevisionSheetSectionSource` :

- clé composée `@@id([sectionId, chunkId])`;
- relation composite vers `RevisionSheetSection(id, subjectId)`;
- relation composite vers `DocumentChunk(id, subjectId)`;
- empêche le cross-subject au niveau DB;
- le cross-document est vérifié dans le repository.

## 6. Repository et use cases

Port créé :

- `StudyArtifactsRepository`.

Use cases ajoutés :

- `GetDocumentSummaryUseCase`;
- `SaveDocumentSummaryUseCase`;
- `GetRevisionSheetUseCase`;
- `SaveRevisionSheetUseCase`.

Adapter Prisma ajouté :

- `PrismaStudyArtifactsRepository`.

Méthodes résumé :

- `findSummaryByDocumentForStudent`;
- `saveReadySummary`;
- `saveFailedSummary`.

Méthodes fiche :

- `findRevisionSheetByDocumentForStudent`;
- `saveReadyRevisionSheet`;
- `saveFailedRevisionSheet`.

Validations repository :

- document existant;
- ownership via `studentId`;
- document `READY` obligatoire pour `saveReadySummary` et `saveReadyRevisionSheet`;
- sources obligatoires pour artefacts `READY`;
- sections obligatoires pour fiche `READY`;
- chaque section `READY` doit avoir au moins une source;
- chunks sources existants;
- chunks sources appartenant au même document;
- chunks sources appartenant au même sujet;
- remplacement de l'artefact courant via `upsert`;
- remplacement des sources/sections existantes avant recréation;
- sauvegarde `FAILED` autorisée sans sources avec `errorCode`.

Données non exposées par les DTO repository :

- pas de `storagePath`;
- pas de chunks non liés;
- pas de prompt;
- pas de completion;
- pas de payload GenUI.

## 7. Migration

Migration créée :

```text
api/prisma/migrations/20260614141000_summary_revision_sheet_artifacts/migration.sql
```

Méthode de création :

1. snapshot du schéma pré-lot :

```bash
cp prisma/schema.prisma /tmp/revision_schema_before_lot018.prisma
```

2. tentative préférée :

```bash
npx prisma migrate dev --create-only --name summary_revision_sheet_artifacts
```

Résultat : échec avec `Schema engine error`, comme `migrate status`.

3. génération SQL Prisma par diff :

```bash
npx prisma migrate diff --from-schema /tmp/revision_schema_before_lot018.prisma --to-schema prisma/schema.prisma --script > prisma/migrations/20260614141000_summary_revision_sheet_artifacts/migration.sql
```

Note : une première tentative avec l'ancien flag `--from-schema-datamodel` a échoué car Prisma 7.8.0 l'a retiré. La commande corrigée utilise `--from-schema` et `--to-schema`.

Résumé SQL :

- création de `StudyArtifactStatus`;
- création de `StudyArtifactSourceStrategy`;
- création de `Summary`;
- création de `SummarySource`;
- création de `RevisionSheet`;
- création de `RevisionSheetSection`;
- création de `RevisionSheetSectionSource`;
- index et uniques associés;
- foreign keys vers `StudentProfile`, `Subject`, `Document`, `DocumentChunk`.

Migration appliquée :

- non.

Limite :

Le SQL est généré par Prisma et relu, mais il n'a pas été appliqué sur une DB locale réelle car PostgreSQL local reste indisponible pour Prisma Migrate.

## 8. Données explicitement non stockées

Le lot ne stocke pas :

- prompt complet;
- completion complète;
- texte complet du cours dans un artefact;
- chunks complets dans un payload JSON d'artefact;
- payload GenUI;
- source libre générée par IA;
- historique multi-version;
- job IA persistant.

Les chunks existent déjà dans `DocumentChunk`; les artefacts ne stockent que des liens vers ces chunks via tables de sources.

## 9. Tests créés ou modifiés

Tests créés :

- `api/src/modules/study-artifacts/application/study-artifacts.use-cases.spec.ts`
- `api/src/modules/study-artifacts/infrastructure/prisma-study-artifacts.repository.spec.ts`

Couverture ajoutée :

- lecture résumé via use case;
- sauvegarde résumé `READY`;
- sauvegarde résumé `FAILED`;
- lecture fiche via use case;
- sauvegarde fiche `READY`;
- sauvegarde fiche `FAILED`;
- résumé `READY` avec sources validées;
- rejet résumé sans source;
- rejet résumé si document non `READY`;
- rejet résumé avec chunk hors document;
- fiche `READY` avec sections et sources;
- rejet fiche si section sans source;
- rejet fiche si document non `READY`;
- fiche `FAILED` sans sections;
- tri des sections;
- tri des sources;
- absence de `storagePath` dans les DTO retournés.

## 10. Validations lancées

Préflight :

```bash
cd api && npx prisma validate
```

Résultat : succès.

```bash
cd api && npm run prisma:generate
```

Résultat : succès.

```bash
cd api && npx prisma migrate status
```

Résultat : échec `Schema engine error` sur PostgreSQL local.

Migration :

```bash
cd api && npx prisma migrate dev --create-only --name summary_revision_sheet_artifacts
```

Résultat : échec `Schema engine error`.

```bash
cd api && npx prisma migrate diff --from-schema /tmp/revision_schema_before_lot018.prisma --to-schema prisma/schema.prisma --script
```

Résultat : succès, SQL généré dans la migration.

Tests :

```bash
cd api && npm test -- study-artifacts --runInBand
```

Résultat final : 2 suites passées, 17 tests passés.

```bash
cd api && npm test -- study-artifacts documents ai activities --runInBand
```

Résultat final : 24 suites passées, 137 tests passés.

Analyse :

```bash
cd api && npm run lint:check
```

Résultat final : succès.

Build :

```bash
cd api && npm run build
```

Résultat final : succès.

Diff checks :

```bash
cd api && git diff --check
```

Résultat : succès.

```bash
cd revision_app && git diff --check
```

Résultat : succès.

## 11. Validations non lancées

Non lancé :

```bash
cd api && npx prisma migrate deploy
```

Justification : interdit par le lot.

Non lancé :

```bash
cd api && npm run lint
cd api && npm run format
cd api && npm run test:cov
```

Justification : commandes interdites ou non nécessaires.

Non lancé :

```bash
cd revision_app && flutter test
cd revision_app && dart analyze lib test
```

Justification : aucun code Flutter applicatif modifié.

Non validé :

- application des migrations sur une DB locale réelle.

Justification : `migrate status` et `migrate dev --create-only` échouent avec `Schema engine error` sur PostgreSQL local.

## 12. Corrections de chemins constatées

Chemins réels utilisés :

- API : `/Users/karim/Project/app-révision/api`
- Flutter : `/Users/karim/Project/app-révision/revision_app`
- rapport : `revision_app/docs/ROADMAP_EXECUTION_LOT_018.md`
- plan : `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

Le rapport de lot est stocké côté `revision_app/docs`, comme les lots précédents.

## 13. Risques restants

- La migration `20260614000000_document_chunks_sources` n'a toujours pas été validée runtime DB locale.
- La nouvelle migration `20260614141000_summary_revision_sheet_artifacts` n'a pas été appliquée sur DB locale.
- Les champs JSON restent validés applicativement par les futurs flows et use cases, pas par la DB.
- Aucun flow Genkit résumé/fiche n'existe encore.
- Aucun endpoint public résumé/fiche n'existe encore.
- Aucune UI résumé/fiche n'existe encore.
- La stratégie de régénération est encore minimale : un artefact courant par document, remplacé.
- La rétention des chunks n'est pas décidée.
- Les méthodes `saveReady...` retournent l'artefact sauvegardé sans recharger les sources complètes; les futurs endpoints peuvent relire via `find...` après génération si le DTO complet est nécessaire.

## 14. Recommandation prochain lot

Si une DB locale peut être démarrée rapidement, recommander d'abord un mini-lot de validation DB :

- appliquer les migrations sur une DB locale propre;
- vérifier `migrate status`;
- lancer les tests Prisma repository sur DB réelle si le projet dispose d'une suite adaptée.

Si la validation DB locale reste bloquée mais que les tests mocks suffisent temporairement, le prochain lot fonctionnel peut être :

- `LOT-019 — Flow Genkit résumé et fiche`.

`LOT-019 + LOT-020` peuvent être envisagés en batch seulement si :

- les migrations sont considérées prêtes;
- le flow Genkit reste borné;
- les sources pointent exclusivement vers `DocumentChunk`;
- aucun endpoint n'expose de source libre.

## 15. Sub-agents ou passes locales

Sub-agent Audit / Architecture :

- verdict : le module dédié `study-artifacts` est cohérent avec `LOT-017` et évite de gonfler `documents`.

Sub-agent Implémentation :

- verdict : le lot reste dans le périmètre persistance; aucun controller, aucun Genkit, aucun front.

Sub-agent Tests :

- verdict : les tests couvrent cas positifs, négatifs, garde-fous sources et non-régression d'absence de `storagePath`.

Sub-agent Build / Validation :

- verdict : Prisma validate, generate, tests ciblés, lint, build et diff checks passent; DB locale indisponible.

Sub-agent Critique finale :

- verdict : la plus grosse limite est l'absence de validation runtime DB; il faut la traiter avant une démonstration qui dépend des tables artefacts.

## 16. Fichiers créés, modifiés ou supprimés

Créés :

- `api/prisma/migrations/20260614141000_summary_revision_sheet_artifacts/migration.sql`
- `api/src/modules/study-artifacts/application/get-document-summary.use-case.ts`
- `api/src/modules/study-artifacts/application/get-revision-sheet.use-case.ts`
- `api/src/modules/study-artifacts/application/save-document-summary.use-case.ts`
- `api/src/modules/study-artifacts/application/save-revision-sheet.use-case.ts`
- `api/src/modules/study-artifacts/application/study-artifacts.repository.ts`
- `api/src/modules/study-artifacts/application/study-artifacts.use-cases.spec.ts`
- `api/src/modules/study-artifacts/infrastructure/prisma-study-artifacts.repository.ts`
- `api/src/modules/study-artifacts/infrastructure/prisma-study-artifacts.repository.spec.ts`
- `api/src/modules/study-artifacts/study-artifacts.module.ts`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_018.md`

Modifiés :

- `api/prisma/schema.prisma`
- `api/src/app.module.ts`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

Supprimés :

- aucun.

## 17. Annexe code généré ou modifié

Cette section respecte la règle projet imposant d'inclure le code créé ou modifié dans le rapport.

### `api/prisma/schema.prisma` — zones modifiées

```diff
+  summaries Summary[]
+  revisionSheets RevisionSheet[]
```

Ajouté sur `StudentProfile`, `Subject` et `Document`.

```diff
+  summarySources SummarySource[]
+  revisionSheetSectionSources RevisionSheetSectionSource[]
```

Ajouté sur `DocumentChunk`.

```prisma
model Summary {
  id              String                      @id @default(cuid())
  documentId      String
  subjectId       String
  studentId       String
  status          StudyArtifactStatus
  title           String?
  content         String?
  keyPoints       Json?
  limits          String?
  createdAt       DateTime                    @default(now())
  updatedAt       DateTime                    @updatedAt
  generatedAt     DateTime
  flowName        String
  provider        String
  model           String
  promptVersion   String
  schemaVersion   String
  inputSize       Int?
  sourceStrategy  StudyArtifactSourceStrategy
  errorCode       String?

  student StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  document Document      @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources SummarySource[]

  @@index([studentId])
  @@index([subjectId])
  @@unique([documentId])
  @@unique([id, subjectId])
}

model SummarySource {
  summaryId      String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  summary Summary       @relation(fields: [summaryId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk   DocumentChunk @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([summaryId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

model RevisionSheet {
  id                  String                      @id @default(cuid())
  documentId          String
  subjectId           String
  studentId           String
  status              StudyArtifactStatus
  title               String?
  introduction        String?
  keyPoints           Json?
  commonMistakes      Json?
  mustKnow            Json?
  practiceSuggestions Json?
  createdAt           DateTime                    @default(now())
  updatedAt           DateTime                    @updatedAt
  generatedAt         DateTime
  flowName            String
  provider            String
  model               String
  promptVersion       String
  schemaVersion       String
  inputSize           Int?
  sourceStrategy      StudyArtifactSourceStrategy
  errorCode           String?

  student StudentProfile @relation(fields: [studentId], references: [id], onDelete: Cascade)
  subject Subject        @relation(fields: [subjectId, studentId], references: [id, studentId], onDelete: Cascade)
  document Document      @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sections RevisionSheetSection[]

  @@index([studentId])
  @@index([subjectId])
  @@unique([documentId])
  @@unique([id, subjectId])
}

model RevisionSheetSection {
  id              String   @id @default(cuid())
  revisionSheetId String
  subjectId       String
  displayOrder    Int
  title           String
  content         String
  createdAt       DateTime @default(now())

  revisionSheet RevisionSheet @relation(fields: [revisionSheetId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources RevisionSheetSectionSource[]

  @@index([subjectId])
  @@unique([revisionSheetId, displayOrder])
  @@unique([id, subjectId])
}

model RevisionSheetSectionSource {
  sectionId      String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  section RevisionSheetSection @relation(fields: [sectionId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk   DocumentChunk        @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([sectionId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}
```

```prisma
enum StudyArtifactStatus {
  READY
  FAILED
}

enum StudyArtifactSourceStrategy {
  DOCUMENT_CHUNKS
  DOCUMENT_CHUNKS_AND_KNOWLEDGE_UNITS
}
```

### `api/src/app.module.ts` — zone modifiée

```diff
+import { StudyArtifactsModule } from './modules/study-artifacts/study-artifacts.module';
```

```diff
     DocumentsModule,
     ActivitiesModule,
+    StudyArtifactsModule,
```

### `api/prisma/migrations/20260614141000_summary_revision_sheet_artifacts/migration.sql`

```sql
-- CreateEnum
CREATE TYPE "StudyArtifactStatus" AS ENUM ('READY', 'FAILED');

-- CreateEnum
CREATE TYPE "StudyArtifactSourceStrategy" AS ENUM ('DOCUMENT_CHUNKS', 'DOCUMENT_CHUNKS_AND_KNOWLEDGE_UNITS');

-- CreateTable
CREATE TABLE "Summary" (
    "id" TEXT NOT NULL,
    "documentId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "status" "StudyArtifactStatus" NOT NULL,
    "title" TEXT,
    "content" TEXT,
    "keyPoints" JSONB,
    "limits" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "generatedAt" TIMESTAMP(3) NOT NULL,
    "flowName" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "promptVersion" TEXT NOT NULL,
    "schemaVersion" TEXT NOT NULL,
    "inputSize" INTEGER,
    "sourceStrategy" "StudyArtifactSourceStrategy" NOT NULL,
    "errorCode" TEXT,

    CONSTRAINT "Summary_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SummarySource" (
    "summaryId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "chunkId" TEXT NOT NULL,
    "relevanceScore" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SummarySource_pkey" PRIMARY KEY ("summaryId","chunkId")
);

-- CreateTable
CREATE TABLE "RevisionSheet" (
    "id" TEXT NOT NULL,
    "documentId" TEXT NOT NULL,
    "subjectId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "status" "StudyArtifactStatus" NOT NULL,
    "title" TEXT,
    "introduction" TEXT,
    "keyPoints" JSONB,
    "commonMistakes" JSONB,
    "mustKnow" JSONB,
    "practiceSuggestions" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "generatedAt" TIMESTAMP(3) NOT NULL,
    "flowName" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "promptVersion" TEXT NOT NULL,
    "schemaVersion" TEXT NOT NULL,
    "inputSize" INTEGER,
    "sourceStrategy" "StudyArtifactSourceStrategy" NOT NULL,
    "errorCode" TEXT,

    CONSTRAINT "RevisionSheet_pkey" PRIMARY KEY ("id")
);
```

Le fichier SQL complet contient aussi les tables `RevisionSheetSection`, `RevisionSheetSectionSource`, tous les index et les foreign keys. Il a été généré par Prisma, pas écrit à la main.

### `api/src/modules/study-artifacts/application/study-artifacts.repository.ts`

```ts
export const STUDY_ARTIFACTS_REPOSITORY = Symbol('StudyArtifactsRepository');

export type StudyArtifactStatus = 'READY' | 'FAILED';

export type StudyArtifactSourceStrategy =
  | 'DOCUMENT_CHUNKS'
  | 'DOCUMENT_CHUNKS_AND_KNOWLEDGE_UNITS';

export type StudyArtifactMetadata = {
  flowName: string;
  provider: string;
  model: string;
  promptVersion: string;
  schemaVersion: string;
  generatedAt: Date;
  inputSize?: number | null;
  sourceStrategy: StudyArtifactSourceStrategy;
};

export type StudyArtifactSourceInput = {
  chunkId: string;
  relevanceScore?: number | null;
};

export type StudyArtifactSourceDto = {
  chunkId: string;
  text: string;
  pageNumber: number | null;
  index: number;
  relevanceScore: number | null;
};

export type SummaryDto = {
  id: string;
  documentId: string;
  subjectId: string;
  status: StudyArtifactStatus;
  title: string | null;
  content: string | null;
  keyPoints: string[];
  limits: string | null;
  metadata: StudyArtifactMetadata;
  errorCode: string | null;
  sources: StudyArtifactSourceDto[];
};

export type ReadySummaryInput = {
  studentId: string;
  documentId: string;
  title: string;
  content: string;
  keyPoints: string[];
  limits: string | null;
  metadata: StudyArtifactMetadata;
  sources: StudyArtifactSourceInput[];
};

export type FailedSummaryInput = {
  studentId: string;
  documentId: string;
  metadata: StudyArtifactMetadata;
  errorCode: string;
};

export type RevisionSheetSectionInput = {
  displayOrder: number;
  title: string;
  content: string;
  sources: StudyArtifactSourceInput[];
};

export type RevisionSheetSectionDto = {
  id: string;
  displayOrder: number;
  title: string;
  content: string;
  sources: StudyArtifactSourceDto[];
};

export type RevisionSheetDto = {
  id: string;
  documentId: string;
  subjectId: string;
  status: StudyArtifactStatus;
  title: string | null;
  introduction: string | null;
  keyPoints: string[];
  commonMistakes: string[];
  mustKnow: string[];
  practiceSuggestions: string[];
  metadata: StudyArtifactMetadata;
  errorCode: string | null;
  sections: RevisionSheetSectionDto[];
};
```

Le fichier continue avec les inputs `ReadyRevisionSheetInput`, `FailedRevisionSheetInput`, `DocumentArtifactLookupInput` et l'interface `StudyArtifactsRepository`.

### Use cases créés

`GetDocumentSummaryUseCase`, `GetRevisionSheetUseCase`, `SaveDocumentSummaryUseCase` et `SaveRevisionSheetUseCase` sont des classes applicatives minces. Elles injectent `STUDY_ARTIFACTS_REPOSITORY` et délèguent au port, sans Genkit, sans HTTP et sans logique de controller.

### `api/src/modules/study-artifacts/infrastructure/prisma-study-artifacts.repository.ts`

Zones principales créées :

```ts
@Injectable()
export class PrismaStudyArtifactsRepository implements StudyArtifactsRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findSummaryByDocumentForStudent(input: {
    studentId: string;
    documentId: string;
  }): Promise<SummaryDto | null> {
    const summary = await this.prisma.summary.findFirst({
      where: {
        documentId: input.documentId,
        studentId: input.studentId,
      },
      include: {
        sources: {
          include: {
            chunk: true,
          },
        },
      },
    });

    if (!summary) {
      return null;
    }

    return this.toSummaryDto(summary);
  }
}
```

L'adapter contient aussi :

- `saveReadySummary`;
- `saveFailedSummary`;
- `findRevisionSheetByDocumentForStudent`;
- `saveReadyRevisionSheet`;
- `saveFailedRevisionSheet`;
- validation document ownership;
- validation document `READY`;
- validation sources;
- validation chunks par `documentId` et `subjectId`;
- mapping DTO sans `storagePath`.

Le code complet est dans le fichier source, avec tests couvrant les chemins critiques. Aucun commentaire TS n'a été ajouté pour respecter le prompt du lot.

### `api/src/modules/study-artifacts/study-artifacts.module.ts`

```ts
import { Module } from '@nestjs/common';
import { PrismaModule } from '../../shared/infrastructure/prisma/prisma.module';
import { GetDocumentSummaryUseCase } from './application/get-document-summary.use-case';
import { GetRevisionSheetUseCase } from './application/get-revision-sheet.use-case';
import { SaveDocumentSummaryUseCase } from './application/save-document-summary.use-case';
import { SaveRevisionSheetUseCase } from './application/save-revision-sheet.use-case';
import { STUDY_ARTIFACTS_REPOSITORY } from './application/study-artifacts.repository';
import { PrismaStudyArtifactsRepository } from './infrastructure/prisma-study-artifacts.repository';

@Module({
  imports: [PrismaModule],
  providers: [
    GetDocumentSummaryUseCase,
    SaveDocumentSummaryUseCase,
    GetRevisionSheetUseCase,
    SaveRevisionSheetUseCase,
    {
      provide: STUDY_ARTIFACTS_REPOSITORY,
      useClass: PrismaStudyArtifactsRepository,
    },
  ],
  exports: [
    GetDocumentSummaryUseCase,
    SaveDocumentSummaryUseCase,
    GetRevisionSheetUseCase,
    SaveRevisionSheetUseCase,
  ],
})
export class StudyArtifactsModule {}
```

### Tests créés

Les tests créés couvrent le port applicatif et l'adapter Prisma mocké. Le contenu complet se trouve dans :

- `api/src/modules/study-artifacts/application/study-artifacts.use-cases.spec.ts`
- `api/src/modules/study-artifacts/infrastructure/prisma-study-artifacts.repository.spec.ts`

Exemples de garde-fous testés :

```ts
await expect(
  repository.saveReadySummary({
    studentId: 'student-1',
    documentId: 'document-1',
    title: 'Résumé',
    content: 'Contenu',
    keyPoints: [],
    limits: null,
    metadata,
    sources: [],
  }),
).rejects.toThrow('Summary sources are required');
```

```ts
await expect(
  repository.saveReadyRevisionSheet({
    studentId: 'student-1',
    documentId: 'document-1',
    title: 'Fiche',
    introduction: null,
    keyPoints: [],
    commonMistakes: [],
    mustKnow: [],
    practiceSuggestions: [],
    metadata,
    sections: [
      {
        displayOrder: 0,
        title: 'Section',
        content: 'Contenu',
        sources: [],
      },
    ],
  }),
).rejects.toThrow('Revision sheet section sources are required');
```

### `revision_app/docs/ROADMAP_EXECUTION_PLAN.md` — zone modifiée

```diff
-| LOT-018 | Persistance Summary et RevisionSheet | À faire | À créer |
+| LOT-018 | Persistance Summary et RevisionSheet | Réalisé | `docs/ROADMAP_EXECUTION_LOT_018.md` |
```
