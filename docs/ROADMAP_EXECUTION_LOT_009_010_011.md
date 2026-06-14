# LOT-009 + LOT-010 + LOT-011 — Fondations documentaires et chunking

## 1. Résultat

Les lots `LOT-009`, `LOT-010` et `LOT-011` ont été réalisés ensemble, dans l'ordre demandé.

Résultat principal :

- le modèle documentaire minimal est validé ;
- `DocumentChunk` est ajouté au schéma Prisma ;
- `KnowledgeUnitSource` est ajouté au schéma Prisma ;
- `KnowledgeUnit` reçoit des champs optionnels d'enrichissement ;
- le repository documents sait remplacer les chunks d'un document de manière idempotente ;
- le repository documents prépare la persistance de liens `KnowledgeUnitSource` sans les alimenter automatiquement ;
- un chunker déterministe local découpe le texte extrait du PDF ;
- le worker persiste les chunks avant l'extraction Genkit ;
- le flow Genkit existant reste inchangé et reçoit encore le texte comme avant ;
- le plan global `ROADMAP_EXECUTION_PLAN.md` contient un tableau de suivi des lots réalisés et à faire.

Ce qui n'a pas été fait :

- aucun `LOT-012` ;
- aucune extraction Genkit v2 basée sur chunks ;
- aucun prompt Genkit modifié pour demander des `sourceChunkIds` ;
- aucun résumé ;
- aucune fiche ;
- aucun QCM v2 ;
- aucune question ouverte ;
- aucune session GenUI ;
- aucune modification frontend applicative ;
- aucune route API publique modifiée ;
- aucune migration appliquée à une base distante ou locale.

La migration Prisma `--create-only` a été tentée, mais n'a pas pu être créée dans l'environnement local à cause d'une erreur `Schema engine error`. Aucune migration manuelle fragile n'a été improvisée.

## 2. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_001_001B.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_002_002B_003.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_004_005.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`

Backend :

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/prisma.config.ts`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/application/document-text-extractor.ts`
- `api/src/modules/documents/application/upload-course-pdf.use-case.spec.ts`
- `api/src/modules/documents/application/register-document.use-case.spec.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`
- `api/src/modules/documents/infrastructure/pdf-parse-document-text.extractor.ts`
- `api/src/modules/jobs/jobs.module.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/infrastructure/structured-log-ai-generation.observer.ts`
- `api/src/modules/activities/**` par validation ciblée
- `api/src/shared/infrastructure/prisma/**` par validation ciblée

Audits séparés utilisés :

- Audit / Architecture : modèle Prisma, relations, cascades, ownership.
- Tests / Repositories : méthodes repository, mocks Jest, critères d'idempotence.
- Sécurité logs : absence de logs de texte complet, chunks, prompt ou completion.
- Implémentation : patchs Prisma, repository, worker, chunker.
- Build / Validation : tests ciblés, lint, build, diff check.
- Critique finale : scope, risques restants, contradictions de consignes.

## 3. Préflight Git

État initial côté API :

```text
git status --short --untracked-files=all
```

Résultat initial :

```text

```

État initial côté Flutter :

```text
git status --short --untracked-files=all
```

Résultat initial :

```text

```

Aucun fichier modifié ou non suivi n'était présent au démarrage du lot dans `api` ou `revision_app`.

Fichiers préexistants hors scope :

- aucun détecté au préflight.

Décision sur `AGENTS.md` :

- Le prompt demande de noter dans `AGENTS.md` que `ROADMAP_EXECUTION_PLAN.md` doit être mis à jour à chaque lot.
- Le même prompt interdit explicitement de modifier `revision_app/AGENTS.md` dans ce lot.
- Décision retenue : ne pas modifier `AGENTS.md` dans ce lot et inscrire la règle dans `ROADMAP_EXECUTION_PLAN.md` avec mention du report.

## 4. LOT-009 — Modèle documentaire cible

### DocumentChunk

Décision :

- ajouter `DocumentChunk` comme modèle Prisma minimal persisté.

Raison :

- les futurs résumés, fiches, corrections et blocs GenUI doivent pouvoir pointer vers un contenu stocké et vérifiable ;
- il ne faut pas demander à l'IA d'inventer librement des extraits sources ;
- un chunk persisté permet de rejeter plus tard tout `chunkId` inconnu.

Champs retenus :

- `id`
- `documentId`
- `subjectId`
- `index`
- `text`
- `charStart`
- `charEnd`
- `pageNumber`
- `createdAt`

Décisions associées :

- `pageNumber` reste optionnel, car `pdf-parse` ne fournit pas encore une pagination fiable dans le pipeline actuel ;
- `subjectId` est stocké pour faciliter l'ownership et les contraintes composites ;
- `@@unique([documentId, index])` protège l'idempotence ;
- `@@unique([id, subjectId])` permet aux sources de vérifier le sujet du chunk.

### KnowledgeUnitSource

Décision :

- ajouter une table dédiée `KnowledgeUnitSource`.

Raison :

- le lien notion-source est un besoin direct du MVP Cut 1 ;
- une table dédiée est plus claire qu'un champ JSON dans `KnowledgeUnit` ;
- une table globale `SourceReference` serait prématurée pour ce stade.

Champs retenus :

- `knowledgeUnitId`
- `subjectId`
- `chunkId`
- `relevanceScore`
- `createdAt`

Contraintes retenues :

- clé primaire composée `@@id([knowledgeUnitId, chunkId])` ;
- relation `KnowledgeUnitSource -> KnowledgeUnit` via `[knowledgeUnitId, subjectId]` ;
- relation `KnowledgeUnitSource -> DocumentChunk` via `[chunkId, subjectId]`.

### KnowledgeUnit enrichie

Champs optionnels ajoutés :

- `difficulty`
- `displayOrder`
- `confidence`
- `extractionPromptVersion`
- `extractionSchemaVersion`

Décision :

- ces champs sont optionnels pour préserver le flow actuel ;
- aucun enrichissement n'est exigé par Genkit dans ce lot ;
- `difficulty` utilise l'enum `KnowledgeUnitDifficulty` avec `LOW`, `MEDIUM`, `HIGH`.

### SourceReference reportée

Décision :

- ne pas créer de table globale `SourceReference`.

Raison :

- le MVP a d'abord besoin du lien direct notion-source ;
- un modèle polymorphe global serait plus difficile à tester et à faire évoluer ;
- les artefacts futurs pourront décider de leur propre stratégie une fois les chunks stabilisés.

### Summary / RevisionSheet reportés

Décision :

- ne pas créer `Summary` ;
- ne pas créer `RevisionSheet`.

Raison :

- ce batch prépare les sources ;
- les artefacts de génération seront traités après `LOT-012` et `LOT-013`.

### Genkit v2 reporté

Décision :

- ne pas modifier les flows Genkit ;
- ne pas demander de `sourceChunkIds` ;
- ne pas changer les schémas Genkit d'extraction.

Raison :

- il fallait d'abord persister des chunks déterministes ;
- la bascule vers une extraction sourcée appartient à `LOT-012`.

## 5. LOT-010 — Persistance minimale

### Changements Prisma

Modèles ajoutés :

- `DocumentChunk`
- `KnowledgeUnitSource`

Enum ajoutée :

- `KnowledgeUnitDifficulty`

Champs ajoutés à `KnowledgeUnit` :

- `difficulty`
- `displayOrder`
- `confidence`
- `extractionPromptVersion`
- `extractionSchemaVersion`

Relation ajoutée à `Document` :

- `chunks`

Relation ajoutée à `KnowledgeUnit` :

- `sources`

### Migration

Commande tentée :

```bash
npx prisma migrate dev --create-only --name document_chunks_sources
```

Résultat :

```text
Loaded Prisma config from prisma.config.ts.

Prisma schema loaded from prisma/schema.prisma.
Datasource "db": PostgreSQL database "revision", schema "public" at "localhost:5432"

Error: Schema engine error:
```

Décision :

- aucune migration n'a été créée ;
- aucune migration SQL manuelle n'a été improvisée ;
- `npm run prisma:generate` a été lancé avec succès pour aligner le client généré avec le schéma local.

### Méthodes repository ajoutées

Dans `DocumentsRepository` :

- `replaceChunks`
- `findChunksByDocumentId`
- `replaceKnowledgeUnitSources`

Dans `PrismaDocumentsRepository` :

- `replaceChunks` :
  - vérifie que le document existe ;
  - vérifie que le document est `PROCESSING` ;
  - supprime les chunks existants du document ;
  - recrée les chunks non vides triés par `index` ;
  - reste idempotent pour les retries.
- `findChunksByDocumentId` :
  - liste les chunks d'un document par `index` croissant.
- `replaceKnowledgeUnitSources` :
  - vérifie que la notion existe dans le `subjectId` demandé ;
  - vérifie que tous les chunks sources existent dans le même `subjectId` ;
  - remplace les liens sources ;
  - rejette un chunk inconnu.

### Compatibilité avec le flux actuel

`markReadyWithKnowledgeUnits` reste compatible avec les outputs actuels `{ title, summary }`.

Il accepte aussi des champs optionnels, mais ne crée pas de `KnowledgeUnitSource` automatiquement.

Les sources ne sont pas inférées depuis `sourceExcerpt`, car ce serait une source libre non vérifiée.

### Tests

Tests ajoutés ou modifiés :

- enrichissement optionnel de `KnowledgeUnit` ;
- remplacement de chunks en ordre déterministe ;
- remplacement de chunks avec liste vide ;
- refus de remplacement si le document n'est pas `PROCESSING` ;
- listing des chunks par index ;
- persistance de sources seulement pour chunks du même sujet ;
- rejet de source vers chunk inconnu ;
- absence de création automatique de sources lors du `markReadyWithKnowledgeUnits` actuel ;
- mocks `DocumentsRepository` mis à jour dans les tests d'upload/enregistrement.

## 6. LOT-011 — Chunking worker

### Stratégie de chunking

Service ajouté :

- `DeterministicDocumentTextChunker`

Port ajouté :

- `DocumentTextChunker`

Token Nest ajouté :

- `DOCUMENT_TEXT_CHUNKER`

Caractéristiques :

- découpe déterministe ;
- aucun appel IA ;
- aucune dépendance ajoutée ;
- aucun log ;
- supprime les chunks vides ;
- conserve `index`, `text`, `charStart`, `charEnd`, `pageNumber`.

### Tailles choisies

Configuration par défaut :

- `targetSize`: `1800` caractères ;
- `maxSize`: `2400` caractères ;
- `overlap`: `180` caractères.

Raison :

- ces valeurs limitent la taille des futures entrées IA ;
- elles restent assez larges pour garder le contexte pédagogique ;
- l'overlap est faible pour éviter de trop dupliquer le texte stocké.

### Intégration worker

`DocumentProcessingConsumer` fait maintenant :

1. validation du `documentId` ;
2. `markProcessing` au premier essai ;
3. lecture du document ;
4. validation MIME PDF ;
5. extraction texte via `DocumentTextExtractor` ;
6. rejet du texte vide ;
7. chunking déterministe ;
8. rejet d'une liste de chunks vide ;
9. `replaceChunks` ;
10. extraction Genkit existante avec le texte complet comme avant ;
11. rejet d'une liste de notions vide ;
12. `markReadyWithKnowledgeUnits`.

Le flow Genkit actuel n'a pas été basculé vers les chunks.

### Comportement retry / idempotence

Le repository remplace les chunks par `deleteMany` puis `createMany` dans une transaction.

Conséquence :

- un retry ne duplique pas les chunks ;
- les chunks restent associés au document par `documentId` et `subjectId` ;
- le worker peut rejouer la persistance des chunks sans accumuler d'anciennes lignes.

### Comportement si erreur Genkit après chunks

Dans ce lot, les chunks sont persistés avant l'appel Genkit.

Si Genkit échoue ensuite :

- l'erreur n'est pas masquée ;
- le document peut passer `FAILED` au dernier essai comme aujourd'hui ;
- les chunks déjà persistés restent présents ;
- ce choix est documenté comme risque restant, car la transaction globale chunks + notions + READY n'est pas encore introduite.

Raison :

- l'objectif était une intégration minimale sans modifier le contrat du flow Genkit actuel ;
- `LOT-012` et `LOT-013` devront décider si la finalisation doit devenir atomique avec les sources.

### Tests

Tests ajoutés :

- chunker avec texte vide ;
- chunker avec texte court ;
- chunker avec texte long ;
- chunker déterministe ;
- worker persiste les chunks avant Genkit ;
- worker garde l'appel Genkit existant avec le texte inchangé ;
- worker échoue sans appel Genkit si le chunker retourne `[]` ;
- worker marque `DOCUMENT_CHUNKS_EMPTY` au dernier essai.

## 7. Modèle Prisma final

Extrait documentaire des zones ajoutées ou modifiées :

```prisma
model Document {
  chunks DocumentChunk[]
}

model KnowledgeUnit {
  difficulty              KnowledgeUnitDifficulty?
  displayOrder            Int?
  confidence              Float?
  extractionPromptVersion String?
  extractionSchemaVersion String?
  sources                 KnowledgeUnitSource[]

  @@index([documentId])
}

model DocumentChunk {
  id         String   @id @default(cuid())
  documentId String
  subjectId  String
  index      Int
  text       String
  charStart  Int?
  charEnd    Int?
  pageNumber Int?
  createdAt  DateTime @default(now())

  document Document              @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources  KnowledgeUnitSource[]

  @@index([documentId])
  @@index([subjectId])
  @@unique([documentId, index])
  @@unique([id, subjectId])
}

model KnowledgeUnitSource {
  knowledgeUnitId String
  subjectId       String
  chunkId         String
  relevanceScore  Float?
  createdAt       DateTime @default(now())

  knowledgeUnit KnowledgeUnit @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk         DocumentChunk @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([knowledgeUnitId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}

enum KnowledgeUnitDifficulty {
  LOW
  MEDIUM
  HIGH
}
```

Cet extrait est documentaire. La source réelle est `api/prisma/schema.prisma`.

## 8. Données non logguées

Ce lot ne loggue pas :

- texte complet du cours ;
- chunks complets ;
- prompt complet ;
- completion complète ;
- réponse utilisateur complète ;
- `sourceExcerpt` libre ;
- `storagePath` ;
- contenu d'erreur provider ;
- stack complète d'erreur IA.

Le chunker n'a pas de logger.

Le worker n'ajoute pas de nouveau logger.

L'observabilité Genkit ajoutée dans `LOT-004 + LOT-005` reste inchangée.

## 9. Tests créés ou modifiés

Créés :

- `api/src/modules/documents/application/document-text-chunker.ts`
- `api/src/modules/documents/infrastructure/deterministic-document-text.chunker.ts`
- `api/src/modules/documents/infrastructure/deterministic-document-text.chunker.spec.ts`

Modifiés :

- `api/prisma/schema.prisma`
- `api/src/generated/prisma/**`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/application/register-document.use-case.spec.ts`
- `api/src/modules/documents/application/upload-course-pdf.use-case.spec.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`
- `api/src/modules/jobs/jobs.module.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_009_010_011.md`

Tests ajoutés ou modifiés :

- `DeterministicDocumentTextChunker` :
  - texte vide ;
  - texte court ;
  - texte long ;
  - sortie déterministe.
- `PrismaDocumentsRepository` :
  - champs optionnels de `KnowledgeUnit` ;
  - remplacement de chunks ;
  - remplacement vide ;
  - refus si document non `PROCESSING` ;
  - listing de chunks ;
  - sources valides ;
  - rejet source chunk inconnu ;
  - absence de source automatique.
- `DocumentProcessingConsumer` :
  - chunks persistés avant Genkit ;
  - Genkit conserve le texte actuel ;
  - échec sans Genkit si chunks vides.

## 10. Validations lancées

Cycle rouge initial :

```bash
npm test -- deterministic-document-text.chunker prisma-documents.repository document-processing.consumer
```

Résultat attendu avant implémentation :

```text
Test Suites: 3 failed, 3 total
Tests: 9 failed, 24 passed, 33 total
```

Validation ciblée après implémentation :

```bash
npm test -- deterministic-document-text.chunker prisma-documents.repository document-processing.consumer
```

Résultat :

```text
Test Suites: 3 passed, 3 total
Tests: 37 passed, 37 total
```

Génération Prisma :

```bash
npm run prisma:generate
```

Résultat :

```text
✔ Generated Prisma Client (7.8.0) to ./src/generated/prisma in 62ms
```

Migration locale create-only :

```bash
npx prisma migrate dev --create-only --name document_chunks_sources
```

Résultat :

```text
Error: Schema engine error:
```

Validation ciblée après `prisma:generate` :

```bash
npm test -- deterministic-document-text.chunker prisma-documents.repository document-processing.consumer upload-course-pdf register-document
```

Résultat :

```text
Test Suites: 5 passed, 5 total
Tests: 40 passed, 40 total
```

Validation demandée :

```bash
npm test -- documents
```

Résultat :

```text
Test Suites: 7 passed, 7 total
Tests: 47 passed, 47 total
```

Validation demandée :

```bash
npm test -- jobs
```

Résultat :

```text
Test Suites: 3 passed, 3 total
Tests: 10 passed, 10 total
```

Validation demandée :

```bash
npm test -- document-processing
```

Résultat :

```text
Test Suites: 2 passed, 2 total
Tests: 9 passed, 9 total
```

Validation demandée :

```bash
npm test -- ai
```

Résultat :

```text
Test Suites: 9 passed, 9 total
Tests: 30 passed, 30 total
```

Validation demandée :

```bash
npm test -- activities
```

Résultat :

```text
Test Suites: 5 passed, 5 total
Tests: 25 passed, 25 total
```

Lint non destructif :

```bash
npm run lint:check
```

Résultat initial :

```text
✖ 21 problems (21 errors, 0 warnings)
```

Cause :

- fichiers Prisma générés avec ligne vide initiale ;
- une signature TypeScript à reformater.

Correction :

- retouche manuelle de la signature ;
- suppression mécanique de la ligne vide initiale dans `api/src/generated/prisma/**`.

Relance :

```bash
npm run lint:check
```

Résultat :

```text
eslint "{src,apps,libs,test}/**/*.ts"
```

La commande est sortie avec le code `0`.

Build :

```bash
npm run build
```

Résultat :

```text
nest build
```

La commande est sortie avec le code `0`.

Diff check :

```bash
git diff --check
```

Résultat dans le dossier parent :

```text
warning: Not a git repository.
```

Relance dans les deux repos réels :

```bash
cd api && git diff --check
cd revision_app && git diff --check
```

Résultat :

```text

```

Les deux commandes sont sorties avec le code `0`.

## 11. Validations non lancées

Non lancées volontairement :

- `npm run lint` : interdit car il applique `--fix`.
- `npm run format` : interdit par le lot.
- `npm run test:cov` : interdit par le lot.
- `npm run prisma:migrate:deploy` : interdit par le lot.
- migration sur base distante ou production : interdit par le lot.
- tests Flutter : hors scope, aucun code frontend applicatif modifié.

Migration Prisma non créée :

- `npx prisma migrate dev --create-only --name document_chunks_sources` a échoué avec `Schema engine error`.
- Aucune migration manuelle n'a été créée, conformément à la consigne de ne pas improviser une migration fragile.

## 12. Corrections de chemins constatées

Chemins réels confirmés :

- backend : `/Users/karim/Project/app-révision/api`
- frontend et docs : `/Users/karim/Project/app-révision/revision_app`
- docs réelles : `/Users/karim/Project/app-révision/revision_app/docs`

Le dossier parent `/Users/karim/Project/app-révision` n'est pas un repo Git.

Il existe deux repos Git séparés :

- `/Users/karim/Project/app-révision/api`
- `/Users/karim/Project/app-révision/revision_app`

## 13. Risques restants

### Taille des chunks à ajuster

Probabilité : moyenne.

Impact : moyen.

Mitigation :

- les tailles actuelles sont déterministes et testées ;
- `LOT-012` devra mesurer la qualité avec le PDF golden demo.

### Pas encore de Genkit v2

Probabilité : certaine.

Impact : moyen.

Mitigation :

- `KnowledgeUnitSource` peut rester vide jusqu'à `LOT-012` / `LOT-013` ;
- ne pas afficher de source tant qu'elle n'est pas vérifiée.

### KnowledgeUnitSource vide jusqu'au prochain lot

Probabilité : certaine.

Impact : faible à court terme, fort pour les fiches sourcées.

Mitigation :

- ne pas vendre la source notionnelle tant que Genkit ne renvoie pas d'IDs valides ;
- `LOT-012` doit introduire la sélection de chunks et la validation IDs.

### Pas encore d'API publique chunks

Probabilité : certaine.

Impact : faible pour ce lot.

Mitigation :

- `LOT-014` devra exposer les notions et sources sans exposer `storagePath`.

### Stockage DB de texte de cours

Probabilité : certaine.

Impact : élevé.

Mitigation :

- ajouter plus tard une stratégie de rétention ;
- limiter la taille et le nombre de chunks ;
- ne jamais logger les chunks ;
- vérifier les règles d'accès par `studentId`.

### Stratégie de rétention non finalisée

Probabilité : certaine.

Impact : moyen.

Mitigation :

- décider avant déploiement public si les chunks sont conservés, purgés ou régénérables.

### Migration non créée

Probabilité : actuelle.

Impact : élevé avant déploiement.

Mitigation :

- relancer `prisma migrate dev --create-only` avec une base locale saine ;
- ne pas déployer tant que la migration n'existe pas et n'est pas relue.

### Chunks persistés avant échec Genkit

Probabilité : possible.

Impact : moyen.

Mitigation :

- documenter l'état `FAILED` avec chunks présents ;
- décider plus tard si le passage `READY` doit devenir une transaction atomique chunks + notions + sources.

## 14. Recommandation prochain lot

Prochain lot recommandé :

- `LOT-012 — Extraction Genkit v2 basée sur chunks`.

Justification :

- `DocumentChunk` existe maintenant ;
- les chunks sont persistés avant Genkit ;
- l'observabilité Genkit existe déjà ;
- il faut maintenant empêcher l'IA d'inventer des sources et lui faire pointer vers des chunks candidats vérifiables.

Ordre recommandé :

1. `LOT-012 — Extraction Genkit v2 basée sur chunks`
2. `LOT-013 — Persistance KnowledgeUnit enrichie et liens sources`
3. `LOT-014 — API détail document et notions sourcées`

Critère avant de lancer `LOT-012` :

- créer ou réparer la migration Prisma locale ;
- vérifier que la base locale applique bien `DocumentChunk` et `KnowledgeUnitSource` ;
- choisir la stratégie de sélection des chunks envoyés à Genkit pour éviter d'envoyer tout le texte si le PDF est long.
