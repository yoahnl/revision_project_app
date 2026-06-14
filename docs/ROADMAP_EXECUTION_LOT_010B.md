# LOT-010B — Réparation migration Prisma DocumentChunk / KnowledgeUnitSource

## 1. Résultat

Le lot correctif `LOT-010B` répare l'état Prisma après `LOT-009 + LOT-010 + LOT-011`.

Résultat :

- le schéma Prisma est confirmé valide ;
- la cause du `Schema engine error` est diagnostiquée ;
- la structure Prisma Migrate est complétée avec `migration_lock.toml` ;
- une migration SQL `document_chunks_sources` est ajoutée ;
- le SQL de migration est généré par Prisma via `prisma migrate diff`, pas écrit à la main ;
- le client Prisma est régénéré ;
- le lint ne dépend plus de retouches manuelles dans `src/generated/prisma/**` ;
- les validations backend demandées passent, sauf `migrate dev --create-only` qui reste bloqué par l'absence de PostgreSQL local.

Ce lot ne commence pas `LOT-012`.

## 2. Problème initial

La commande suivante échouait :

```bash
npx prisma migrate dev --create-only --name document_chunks_sources
```

Erreur observée :

```text
Error: Schema engine error:
```

État avant correction :

- `api/prisma/schema.prisma` contenait déjà `DocumentChunk`, `KnowledgeUnitSource` et les champs optionnels sur `KnowledgeUnit`.
- `npm run prisma:generate` fonctionnait.
- Aucune migration `document_chunks_sources` n'existait.
- Le dossier `api/prisma/migrations` ne contenait que `20260612000000_init/migration.sql`.
- Le fichier standard `api/prisma/migrations/migration_lock.toml` était absent.
- La base locale par défaut `postgresql://revision:revision@localhost:5432/revision?schema=public` n'était pas disponible.
- `src/generated/prisma/**` était inclus dans `lint:check`, ce qui forçait une retouche manuelle fragile après chaque `prisma:generate`.

## 3. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP_EXECUTION_LOT_009_010_011.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/AGENTS.md`

Backend :

- `api/package.json`
- `api/README.md`
- `api/eslint.config.mjs`
- `api/prisma/schema.prisma`
- `api/prisma.config.ts`
- `api/prisma/migrations/20260612000000_init/migration.sql`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.spec.ts`
- `api/src/modules/documents/infrastructure/deterministic-document-text.chunker.ts`
- `api/src/modules/documents/infrastructure/deterministic-document-text.chunker.spec.ts`
- `api/src/generated/prisma/**` uniquement via `prisma:generate`, `git status` et `lint:check`

## 4. Préflight Git

État initial API :

```text
git status --short --untracked-files=all
```

Résultat :

```text

```

Interprétation :

- le code backend du lot précédent était déjà dans le commit `10b2903 feat(documents): ajoute chunker de texte et améliore gestion des documents` ;
- il manquait toutefois la migration Prisma correspondante.

État initial `revision_app` :

```text
 M docs/ROADMAP_EXECUTION_PLAN.md
?? docs/ROADMAP_EXECUTION_LOT_009_010_011.md
```

Interprétation :

- les docs du lot précédent étaient encore modifiées ou non suivies ;
- elles ont été préservées ;
- aucun fichier frontend applicatif n'a été modifié.

Migration partielle :

```text
prisma/migrations/20260612000000_init/migration.sql
```

Il n'existait pas de migration partielle `document_chunks_sources`.

## 5. Diagnostic

### Schéma Prisma

Commande :

```bash
npx prisma validate
```

Résultat :

```text
The schema at prisma/schema.prisma is valid 🚀
```

Conclusion :

- la syntaxe Prisma est valide ;
- les relations composites sont acceptées ;
- l'enum `KnowledgeUnitDifficulty` est valide ;
- les `@@unique([id, subjectId])` nécessaires aux relations composites sont présents.

### Base locale

Commande :

```bash
nc -zv localhost 5432
```

Résultat :

```text
nc: connectx to localhost port 5432 (tcp) failed: Connection refused
```

Conclusion :

- PostgreSQL local n'écoute pas sur `localhost:5432` ;
- `DATABASE_URL` n'est pas défini ;
- `prisma.config.ts` retombe donc sur la valeur locale par défaut ;
- `migrate dev --create-only` ne peut pas fonctionner sans base locale ni shadow DB.

### Docker local

Commande :

```bash
docker --version && docker ps --format '{{.Names}} {{.Image}} {{.Ports}}'
```

Résultat :

```text
Docker version 29.4.0, build 9d7ad9f
failed to connect to the docker API at unix:///Users/karim/.orbstack/run/docker.sock
```

Conclusion :

- Docker CLI est installé ;
- le daemon Docker/OrbStack n'est pas disponible ;
- impossible de démarrer un PostgreSQL local en container dans ce lot.

### Structure Prisma Migrate

Commande :

```bash
npx prisma migrate diff --from-migrations prisma/migrations --to-schema prisma/schema.prisma --script
```

Résultat avant correction :

```text
Error: Could not determine the connector from the migrations directory (missing migration_lock.toml).
```

Cause réelle complémentaire :

- `prisma/migrations/migration_lock.toml` était absent ;
- Prisma ne pouvait pas déterminer le connecteur depuis le dossier de migrations ;
- même avec le fichier lock restauré, `--from-migrations` demande une shadow DB avec Prisma 7.8.0.

### SQL générable sans DB

Commande :

```bash
npx prisma migrate diff --from-schema /tmp/revision-api-schema-before-document-chunks.prisma --to-schema prisma/schema.prisma --script
```

Résultat :

- Prisma génère un SQL cohérent pour les différences entre l'ancien schéma et le schéma actuel.

Conclusion :

- le schéma n'est pas la cause du `Schema engine error` ;
- le blocage de `migrate dev` vient de l'environnement DB local indisponible ;
- la structure Migrate était en plus incomplète à cause du lock absent.

## 6. Correction appliquée

### Changements Prisma

Ajout :

- `api/prisma/migrations/migration_lock.toml`
- `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql`

Le schéma `api/prisma/schema.prisma` n'a pas eu besoin d'être modifié dans ce lot.

### Migration SQL

La migration a été générée par Prisma avec :

```bash
git show a19122a:prisma/schema.prisma > /tmp/revision-api-schema-before-document-chunks.prisma
npx prisma migrate diff --from-schema /tmp/revision-api-schema-before-document-chunks.prisma --to-schema prisma/schema.prisma --script
```

Le commit `a19122a` correspond à l'état du schéma avant l'ajout des chunks.

La comparaison avec le fichier ajouté ne diffère que par une ligne blanche finale émise par Prisma sur stdout.

### Repository / tests

Aucun changement repository ou test fonctionnel n'a été nécessaire.

Les tests ajoutés dans `LOT-009 + LOT-010 + LOT-011` restent valides.

### Configuration ESLint

Changement :

- `api/eslint.config.mjs`

Correction :

- ajout de `src/generated/prisma/**` dans `ignores`.

Raison :

- `src/generated/prisma/**` est du code généré ;
- `npm run prisma:generate` régénère des fichiers que Prettier signale ensuite ;
- retoucher manuellement les fichiers générés après chaque génération est fragile ;
- l'exclusion ESLint est durable et explicite.

### Stratégie `src/generated/prisma`

Décision :

- ne pas modifier manuellement `api/src/generated/prisma/**`.

Résultat :

- `npm run prisma:generate` ne laisse pas de diff Git dans le généré ;
- `npm run lint:check` passe grâce à l'exclusion du généré.

## 7. Migration créée

Nom du dossier :

```text
api/prisma/migrations/20260614000000_document_chunks_sources
```

Fichier :

```text
api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql
```

Résumé SQL :

- crée l'enum `KnowledgeUnitDifficulty` ;
- ajoute les colonnes optionnelles à `KnowledgeUnit` :
  - `confidence`
  - `difficulty`
  - `displayOrder`
  - `extractionPromptVersion`
  - `extractionSchemaVersion`
- crée la table `DocumentChunk` ;
- crée la table `KnowledgeUnitSource` ;
- crée les index de lookup sur `DocumentChunk` ;
- crée les index de lookup sur `KnowledgeUnitSource` ;
- crée l'index `KnowledgeUnit_documentId_idx` ;
- ajoute les contraintes de clé étrangère composites :
  - `DocumentChunk(documentId, subjectId)` vers `Document(id, subjectId)` ;
  - `KnowledgeUnitSource(knowledgeUnitId, subjectId)` vers `KnowledgeUnit(id, subjectId)` ;
  - `KnowledgeUnitSource(chunkId, subjectId)` vers `DocumentChunk(id, subjectId)`.

Pourquoi elle est sûre :

- elle ne touche qu'au périmètre chunks, sources et champs optionnels de notion ;
- elle ne modifie pas les tables d'auth, subjects, activities ou mastery ;
- elle n'introduit aucun champ obligatoire sur une table existante ;
- elle ne supprime aucune donnée existante ;
- elle renforce les liens cross-subject via des relations composites.

Application :

- la migration est créée dans le repo ;
- elle n'a pas été appliquée localement car PostgreSQL local n'est pas disponible ;
- elle n'a pas été appliquée en production ou sur une base distante.

## 8. Validations lancées

Validation Prisma :

```bash
npx prisma validate
```

Résultat :

```text
The schema at prisma/schema.prisma is valid 🚀
```

Génération Prisma :

```bash
npm run prisma:generate
```

Résultat :

```text
✔ Generated Prisma Client (7.8.0) to ./src/generated/prisma in 91ms
```

Création migration create-only demandée :

```bash
npx prisma migrate dev --create-only --name document_chunks_sources
```

Résultat :

```text
Datasource "db": PostgreSQL database "revision", schema "public" at "localhost:5432"
Error: Schema engine error:
```

Diagnostic connexion locale :

```bash
nc -zv localhost 5432
```

Résultat :

```text
connection refused
```

Test ciblé :

```bash
npm test -- deterministic-document-text.chunker prisma-documents.repository document-processing.consumer upload-course-pdf register-document
```

Résultat :

```text
Test Suites: 5 passed, 5 total
Tests: 40 passed, 40 total
```

Documents :

```bash
npm test -- documents
```

Résultat :

```text
Test Suites: 7 passed, 7 total
Tests: 47 passed, 47 total
```

Jobs :

```bash
npm test -- jobs
```

Résultat :

```text
Test Suites: 3 passed, 3 total
Tests: 10 passed, 10 total
```

AI :

```bash
npm test -- ai
```

Résultat :

```text
Test Suites: 9 passed, 9 total
Tests: 30 passed, 30 total
```

Activities :

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

Diff check API :

```bash
git diff --check
```

Résultat :

```text

```

La commande est sortie avec le code `0`.

## 9. Validations non lancées

Non lancées :

- `npm run lint` : interdit, car le script applique `--fix`.
- `npm run format` : interdit par le lot.
- `npm run test:cov` : interdit par le lot.
- `npm run prisma:migrate:deploy` : interdit par le lot.
- application de migration sur base distante ou production : interdite.
- tests Flutter : hors scope, aucun code frontend applicatif modifié.

`migrate dev --create-only` a été relancé mais ne peut toujours pas fonctionner tant que PostgreSQL local n'écoute pas sur `localhost:5432`.

## 10. Fichiers créés/modifiés/supprimés

Créés :

- `api/prisma/migrations/migration_lock.toml`
- `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_010B.md`

Modifiés :

- `api/eslint.config.mjs`
- `revision_app/AGENTS.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

Supprimés :

- aucun.

## 11. Risques restants

### Migration non appliquée en production

La migration existe mais n'a pas été appliquée à une base réelle dans ce lot.

Mitigation :

- appliquer via `prisma migrate deploy` uniquement dans l'environnement prévu ;
- ne pas lancer `LOT-012` en runtime réel tant que la DB cible n'a pas la migration.

### Nécessité de tester avec une DB locale propre

PostgreSQL local était indisponible.

Mitigation :

- démarrer PostgreSQL local ou Docker/OrbStack ;
- relancer `npx prisma migrate dev --create-only --name document_chunks_sources` seulement si une nouvelle migration est nécessaire ;
- lancer surtout `prisma migrate deploy` ou `prisma migrate status` contre une DB locale de test.

### Stockage DB de chunks de cours

Les chunks contiennent du texte de cours.

Mitigation :

- pas de logs de chunks ;
- stratégie de rétention à définir avant production large ;
- accès strict par `studentId` dans les futurs endpoints.

### Stratégie de rétention non décidée

Le stockage long terme des chunks n'est pas arbitré.

Mitigation :

- décider si les chunks sont conservés, purgés après génération, ou régénérables.

### KnowledgeUnitSource vide jusqu'à LOT-012/013

La table existe mais n'est pas encore alimentée.

Mitigation :

- `LOT-012` doit faire produire des références chunk validables ;
- `LOT-013` doit persister les liens source sans source fictive.

## 12. Recommandation prochain lot

On peut préparer `LOT-012 — Extraction Genkit v2 basée sur chunks`, avec une condition opérationnelle :

- avant tout test runtime DB, appliquer la migration sur une base locale ou staging ;
- ne pas passer en production tant que `prisma migrate status` ou `prisma migrate deploy` n'a pas été validé sur l'environnement cible.

Prochain ordre recommandé :

1. Démarrer une DB locale ou staging de test.
2. Appliquer la migration `20260614000000_document_chunks_sources`.
3. Vérifier `prisma migrate status`.
4. Lancer `LOT-012`.
