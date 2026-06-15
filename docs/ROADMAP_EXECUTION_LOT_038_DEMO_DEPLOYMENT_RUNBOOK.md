# LOT-038 — Runbook démo et déploiement

## 1. Résultat

LOT-038 est réalisé côté documentation. Un runbook global de démo et déploiement local/staging a été créé pour rendre la démo Revision App rejouable, prudente et vérifiable. Les runbooks seed et smoke pointent maintenant vers ce document central. Le plan d’exécution marque `LOT-038` comme réalisé.

Aucun runtime applicatif n’a été modifié. Aucun backend, Prisma, Genkit, Flutter applicatif, test ou script runtime n’a été changé.

## 2. Sources inspectées

Côté API :

- `api/package.json`
- `api/README.md`
- `api/.env.example`
- `api/Dockerfile`
- `api/prisma.config.ts`
- `api/prisma/schema.prisma`
- `api/prisma/demo-seed.ts`
- `api/src/main.ts`
- `api/src/app.module.ts`
- `api/src/cors.ts`
- `api/src/shared/infrastructure/prisma/database-url.ts`
- `api/src/shared/infrastructure/prisma/prisma.service.ts`
- `api/src/shared/infrastructure/firebase/firebase-admin-app.ts`
- `api/src/modules/jobs/**`
- `api/src/modules/ai/**`
- `api/src/modules/auth/**`
- `api/src/modules/students/**`
- `api/src/modules/documents/**`
- `api/src/modules/activities/**`
- `api/src/modules/revision/**`
- `api/src/modules/revision-sessions/**`
- `api/src/modules/demo-seed/**`
- `api/test/jest-e2e.json`
- `api/test/app.e2e-spec.ts`
- `api/test/critical-paths.e2e-spec.ts`

Côté Flutter/docs :

- `revision_app/pubspec.yaml`
- `revision_app/README.md`
- `revision_app/Dockerfile`
- `revision_app/lib/core/config/app_config.dart`
- `revision_app/lib/app/di/revision_providers.dart`
- `revision_app/lib/firebase_options.dart` inspecté pour confirmer les `--dart-define`, sans recopier de valeurs sensibles
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart` en lecture seule pour confirmer catalogue et fallback
- `revision_app/lib/features/activities/genui/activity_correction_component_validator.dart` en lecture seule
- `revision_app/lib/features/activities/genui/sourced_reading_component_validator.dart` en lecture seule
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/demo/DEMO_SEED_RUNBOOK.md`
- `revision_app/docs/demo/DEMO_SMOKE_CHECKS.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_036_DEMO_SEED_FIXTURES.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_037_E2E_SMOKE_CHECKS.md`

Éléments cherchés : scripts disponibles, variables d’environnement, fallback Prisma, ports locaux, stratégie Redis/BullMQ, configuration Firebase, configuration IA, configuration Flutter API, catalogue GenUI, runbooks existants et docs de smoke.

## 3. Préflight Git

API initial :

```text
/Users/karim/Project/app-révision/api
/Users/karim/Project/app-révision/api
main
## main...origin/main
e552c75 #36-1: ajoute tests e2e pour les chemins critiques
b1d2318 #35-1: ajoute script de démo et données de seed
a08fd4e #34-1: améliore planification adaptative et plan du jour
783a728 #33-1: ajoute coach de révision et sélection d'actions
5e71dde #31-1: ajoute module revision-sessions avec structure minimale
```

Frontend/docs initial :

```text
/Users/karim/Project/app-révision/revision_app
/Users/karim/Project/app-révision/revision_app
main
## main...origin/main
b31b17c LOT_037_E2E_SMOKE_CHECKS - Mise à jour plan d'exécution, ajout rapport LOT_037 et checks smoke démo
10fd329 LOT_036_DEMO_SEED_FIXTURES - Mise à jour plan d'exécution, ajout rapport LOT_036 et runbook de seed démo
f321d04 LOT_035_TODAY_PAGE_V2_FRONTEND - Mise à jour repository Today, domaine, page et tests, ajout rapport LOT_035
c814759 LOT_034_TODAY_PLAN_MULTI_ACTIONS_BACKEND - Mise à jour plan d'exécution et ajout rapport LOT_034 (Today Plan Multi-Actions Backend)
b8fc557 LOT_033_REVISION_COACH_GENKIT - Mise à jour plan d'exécution et ajout rapport LOT_033 (Revision Coach Genkit)
```

Les deux repos étaient propres avant LOT-038. LOT-037 était déjà réalisé dans l’historique local et dans le plan.

## 4. Périmètre réalisé

Créé :

- `revision_app/docs/demo/DEMO_DEPLOYMENT_RUNBOOK.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_038_DEMO_DEPLOYMENT_RUNBOOK.md`

Modifié :

- `revision_app/docs/demo/DEMO_SEED_RUNBOOK.md`
- `revision_app/docs/demo/DEMO_SMOKE_CHECKS.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

Non modifié :

- API runtime ;
- Prisma schema et migrations ;
- flows Genkit ;
- Flutter applicatif ;
- tests ;
- README principaux.

## 5. Décisions documentaires

Un runbook principal a été créé dans `docs/demo` pour centraliser le déroulé opérationnel complet : préparation environnement, DB, Redis, API, worker, Flutter, seed, smoke checks, scénario de présentation, GenUI/fallback et troubleshooting.

Les documents LOT-036 et LOT-037 restent spécialisés :

- `DEMO_SEED_RUNBOOK.md` garde le détail du seed ;
- `DEMO_SMOKE_CHECKS.md` garde la checklist de smoke ;
- `DEMO_DEPLOYMENT_RUNBOOK.md` les relie dans une procédure de démo complète.

Les README principaux n’ont pas été modifiés pour éviter un bruit documentaire hors périmètre. Ils contiennent déjà les commandes locales essentielles. Les petites incohérences README relevées en review sont notées dans les risques restants.

## 6. Variables et commandes confirmées

Commandes API confirmées par `api/package.json` :

- `npm run build`
- `npm run start`
- `npm run start:dev`
- `npm run start:prod`
- `npm run lint:check`
- `npm run prisma:generate`
- `npm run prisma:migrate:deploy`
- `npm run demo:seed`
- `npm run test:e2e`

Commandes Flutter confirmées par `revision_app/README.md` et `pubspec.yaml` :

- `flutter pub get`
- `flutter run -d macos`
- `dart analyze lib test`
- `flutter test`
- `flutter build macos --debug`
- `flutter build web` via le Dockerfile front et l’outil Flutter standard

Configuration confirmée :

- API locale par défaut sur `PORT=3000` si `PORT` absent ;
- conteneur API sur `PORT=8080` ;
- Dockerfile API avec `RUN_PRISMA_MIGRATIONS=true` déclenchant `prisma migrate deploy` ;
- fallback Prisma local/test : `postgresql://revision:revision@localhost:5432/revision?schema=public` ;
- Redis via `REDIS_URL` ou `REDIS_HOST`/`REDIS_PORT` ;
- worker documentaire activé par `DOCUMENT_PROCESSING_WORKER_ENABLED=true` dans le module Jobs ;
- queue désactivable par `DOCUMENT_PROCESSING_QUEUE_DISABLED=true` ;
- Firebase Admin via `FIREBASE_PROJECT_ID` ou `FIREBASE_SERVICE_ACCOUNT_JSON` ;
- Flutter API via `--dart-define=API_BASE_URL=...` ;
- seed demo via `DEMO_SEED_CONFIRM`, `DEMO_FIREBASE_UID` ou `DEMO_STUDENT_FIREBASE_UID` ;
- catalogue GenUI `com.revision.activity_catalog`, avec composants bornés et validators.

## 7. Variables et commandes à confirmer

À confirmer selon l’environnement :

- commande exacte de lancement PostgreSQL local, car aucun `docker-compose.yml` n’est présent ;
- commande exacte de lancement Redis local, car aucun `docker-compose.yml` n’est présent ;
- stratégie split API/worker en staging, car aucun script npm `worker` séparé n’existe ;
- versions locales Node/npm/Flutter au-delà des indices Dockerfile et `pubspec.yaml` ;
- valeurs finales des clés IA et Firebase par environnement ;
- timeouts IA côté infra, car aucun env de timeout provider n’a été trouvé dans le code audité ;
- politique d’application automatique des migrations en staging ;
- URL finale du front staging/démo.

Le runbook marque ces points comme dépendants de l’environnement plutôt que de les inventer.

## 8. Seed réel lancé ou non lancé

Seed réel non lancé. Aucune base locale/staging explicitement désignée par l’utilisateur n’a été fournie pour LOT-038.

Dry-run lancé et validé :

```text
DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
```

Résultat : succès, aucune écriture DB, URL DB masquée, UID masqué, 6 chunks, 6 notions, 4 mastery states, résumé et fiche de démo.

## 9. Validations lancées avec résultats

```text
cd api && npm run lint:check
Résultat : succès.
```

```text
cd api && npm run test:e2e -- --runInBand
Résultat : succès, 2 suites, 16 tests.
```

```text
cd api && npm run build
Résultat : succès.
```

```text
cd api && DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
Résultat : succès, sortie JSON dry-run, aucune écriture DB.
```

```text
cd api && git diff --check
Résultat : succès.
```

```text
cd revision_app && git diff --check
Résultat : succès.
```

## 10. Validations non lancées avec justification

Non lancé :

- `npm run lint` : interdit, applique `--fix`.
- `npm run format` : interdit.
- `npm run test:cov` : hors lot.
- `npx prisma db push` : interdit.
- `npx prisma migrate reset` : interdit.
- `npx prisma migrate deploy` : documenté seulement, non exécuté sans cible DB explicite.
- Seed réel : non lancé sans DB locale/staging explicitement désignée.
- `dart analyze lib test` : non lancé, aucun fichier Dart/Flutter applicatif modifié.
- `flutter test` : non lancé, aucun fichier Dart/Flutter applicatif modifié.
- `flutter build web --release --dart-define=API_BASE_URL=<api-base-url-demo>` : documenté comme validation recommandée avant présentation externe, non lancé car LOT-038 ne modifie pas le front et aucune cible démo externe n’a été désignée.
- Déploiement Docker/Dokploy : hors lot documentaire.

## 11. Risques restants

- Le runbook n’a pas encore été rejoué sur une vraie staging.
- La stratégie split API/worker dépendra de l’environnement de déploiement réel.
- Les commandes PostgreSQL/Redis locales restent à confirmer selon machine, car le repo ne fournit pas de compose.
- Les clés IA et Firebase doivent être vérifiées hors Git avant une démo réelle.
- Le seed réel reste à exécuter uniquement sur une base locale/staging explicitement désignée.
- `api/README.md` ne liste pas encore `MISTRAL_OPEN_ANSWER_EVALUATION_FALLBACK_MODEL`, alors que le runbook global et `.env.example` le couvrent.
- `revision_app/README.md` ne liste pas encore `FIREBASE_IOS_BUNDLE_ID`, alors que le runbook global le couvre.
- Les captures ou supports de présentation ne sont pas créés dans ce lot.

## 12. Recommandation prochain lot

Suite logique recommandée : un lot optionnel `LOT-039 — Rejeu staging réel et captures de démonstration`, limité à une base staging explicitement désignée, avec seed réel contrôlé, smoke complet, build web, captures écran et checklist signée.

Si la roadmap démo est considérée suffisante, la suite peut revenir aux lots UI/visuels pour améliorer la présentation produit.

## 13. Passes de review

- Audit doc manuel : le runbook couvre API, DB, Redis/worker, Firebase, Genkit, Flutter, seed, smoke, scénario, GenUI/fallback et troubleshooting.
- Sécurité secrets par sub-agent : aucun token, UID réel, service account, clé IA ou URL privée ajouté.
- Cohérence commandes par sub-agent : commandes npm confirmées, caveat worker/HTTP ajouté, caveat Docker Flutter/Firebase ajouté, port seed 3000/8080 clarifié.
- Cohérence runbook/smoke/seed : les documents seed et smoke pointent vers le runbook global sans dupliquer leur contenu complet.
- Corrections après review : GenUI/fallback documenté, timeouts IA clarifiés, validation web documentée, stop criterion “runbook rejoué” ajouté.
- Scope : aucune modification runtime, Prisma, Genkit, Flutter applicatif ou test.
- Plan : ligne LOT-038 mise à jour uniquement dans le tableau de suivi.
- Git : aucun commit effectué.

## 14. Critique honnête du prompt initial

Le prompt était clair sur l’objectif documentaire, les interdits de production et la nécessité de ne pas inventer de commandes. La demande était volontairement large, mais pertinente pour sécuriser une démo transversale.

Les points les plus ambigus :

- le niveau de détail attendu sur les commandes PostgreSQL/Redis alors que le repo ne fournit pas de compose ;
- la frontière entre runbook local et staging réel ;
- la mention “déploiement” sans outil infra exécutable à valider dans ce lot ;
- le statut des README principaux : utiles à harmoniser, mais le prompt demandait de ne pas les modifier sauf point d’entrée doc nécessaire.

Choix retenu : documenter seulement ce qui est confirmé, marquer le reste “à confirmer selon environnement”, et ne lancer aucune action staging/production.

## 15. Code complet créé/modifié/supprimé pour review

Fichiers supprimés : aucun.

### revision_app/docs/demo/DEMO_DEPLOYMENT_RUNBOOK.md

``````markdown
# Runbook — Démo et déploiement Revision App

## 1. Objectif

Ce document explique comment préparer, lancer, vérifier et présenter une démo Revision App en local ou sur un environnement staging/démo explicitement prévu pour cet usage.

Il sert de point d’entrée opérationnel pour rejouer une démo sans dépendre d’un document réel, sans stocker de secret dans Git et sans confondre dry-run, seed réel, staging et production.

## 2. Périmètre

Ce runbook couvre :

- environnement local ;
- environnement staging ou démo ;
- API NestJS ;
- worker documentaire si activé ;
- PostgreSQL ;
- Redis et BullMQ ;
- Firebase Auth ;
- Genkit et provider IA ;
- Flutter ;
- seed de démo ;
- smoke checks.

Ce runbook exclut explicitement :

- lancement production ;
- reset destructif ;
- déploiement infra complet non documenté dans le repo ;
- création réelle de compte Firebase ;
- stockage de secrets ;
- migration destructive ;
- seed sur une base non dédiée à la démo.

## 3. Architecture de démo

Flux technique attendu :

```text
Flutter -> Firebase Auth -> API NestJS -> Prisma/PostgreSQL -> BullMQ/Redis -> Genkit/provider IA -> artefacts de révision
```

Le front Flutter récupère un token Firebase, appelle l’API NestJS, puis l’API vérifie le token via Firebase Admin et charge le profil étudiant. Les données persistantes passent par Prisma/PostgreSQL. Les traitements documentaires peuvent utiliser BullMQ/Redis et le worker documentaire. Les générations réelles de notions, QCM, questions ouvertes, corrections, résumés et fiches passent par Genkit/provider IA selon les variables d’environnement.

Parcours produit de démo :

```text
Connexion -> Today -> Matière -> Document READY -> Notions -> Résumé/Fiche -> QCM -> Question ouverte -> Session IA
```

Le seed LOT-036 prépare un document logique READY, des chunks, des notions, un objectif actif, des mastery states, un résumé READY et une fiche READY. Il ne seed pas directement les QCM, questions ouvertes ou sessions IA : ces actions sont lancées par les endpoints existants.

### GenUI, catalogue borné et fallback

GenUI n’est pas un interpréteur libre dans Revision App. Le catalogue Flutter audité est `com.revision.activity_catalog`, construit par `buildRevisionActivityCatalog`.

Composants catalogués confirmés :

- `QuestionCard`
- `SummaryCard`
- `KeyPointsList`
- `SourceExcerptCard`
- `McqQuestionCard`
- `McqCorrectionPanel`
- `ActivityResultCard`
- `QuestionChartCard`
- `QuestionDiagramCard`

Frontière de validation :

- les composants QCM/correction passent par `activity_correction_component_validator.dart` ;
- les composants de lecture sourcée passent par `sourced_reading_component_validator.dart` ;
- les schémas refusent les propriétés inconnues quand le composant le permet ;
- les payloads invalides basculent vers un fallback sûr qui n’affiche pas le JSON brut ;
- le rendu produit principal reste le fallback natif Flutter pour QCM et question ouverte.

Interdits à vérifier pendant la démo :

- pas de widget arbitraire ;
- pas de HTML, SVG, Mermaid ou JavaScript rendu depuis un payload ;
- pas de correction QCM avant submit ;
- pas de `modelAnswer` question ouverte avant submit.

## 4. Prérequis locaux

Prérequis confirmés ou déduits du repo :

- Node.js : le Dockerfile API utilise `node:22-alpine`; la version locale exacte est à confirmer avec `node --version`.
- npm : version locale à confirmer avec `npm --version`.
- Flutter/Dart : `pubspec.yaml` déclare `environment.sdk: ^3.12.0`; la version Flutter locale est à confirmer avec `flutter --version`.
- PostgreSQL : attendu par défaut sur `localhost:5432` en local.
- Redis : attendu par défaut sur `localhost:6379` en local si la queue documentaire n’est pas désactivée.
- Compte Firebase de démo déjà créé côté Firebase Auth.
- UID Firebase du compte de démo connu par l’opérateur, mais jamais commité.
- Clé IA uniquement si la démo lance des générations réelles.
- Repos API et app disponibles localement.
- Migrations appliquées sur la base locale/staging avant seed réel.

Commandes de vérification utiles :

```bash
node --version
npm --version
flutter --version
psql --version
redis-server --version
```

Aucun `docker-compose.yml` n’a été trouvé dans le workspace audité. Le lancement exact de PostgreSQL et Redis dépend donc de l’environnement local ou staging.

## 5. Variables d’environnement API

### Obligatoires en local selon usage

- `DATABASE_URL` : URL PostgreSQL. Si absente en `development` ou `test`, le code Prisma utilise le fallback local `postgresql://revision:revision@localhost:5432/revision?schema=public`. Ce fallback est local uniquement et ne doit pas être traité comme une valeur staging/prod.
- `PORT` : port API. `src/main.ts` utilise `3000` par défaut ; le Dockerfile définit `8080` dans le conteneur.
- `DOCUMENT_STORAGE_ROOT` : racine de stockage documentaire. `.env.example` utilise `storage/revision-documents`.
- `CORS_ORIGINS` : liste optionnelle d’origins autorisées séparées par virgules. Le code autorise aussi `localhost` et `127.0.0.1`.

### Obligatoires pour Genkit/provider IA

Selon provider réel choisi :

- `AI_PROVIDER` : `genkit`, `google`, ou `mistral` selon le chemin configuré. Le code bascule vers Mistral si seule la clé Mistral est disponible.
- `GOOGLE_GENAI_API_KEY` : requis pour Google GenAI.
- `GENKIT_MODEL` : modèle Google GenAI, optionnel avec défaut côté code.
- `MISTRAL_API_KEY` : requis pour Mistral.
- `MISTRAL_MODEL` : modèle Mistral, optionnel avec défaut côté code.
- `MISTRAL_FALLBACK_MODEL` : fallback global Mistral.
- `MISTRAL_SUMMARY_FALLBACK_MODEL` : fallback résumé.
- `MISTRAL_REVISION_SHEET_FALLBACK_MODEL` : fallback fiche.
- `MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL` : fallback QCM.
- `MISTRAL_OPEN_ANSWER_EVALUATION_FALLBACK_MODEL` : fallback correction question ouverte.

Bornes IA confirmées ou visibles dans le code/tests :

- `DOCUMENT_KNOWLEDGE_MAX_CHUNKS`
- `DOCUMENT_KNOWLEDGE_MAX_CHARS`
- `SUMMARY_GENERATION_MAX_CHUNKS`
- `SUMMARY_GENERATION_MAX_CHARS`
- `REVISION_SHEET_GENERATION_MAX_CHUNKS`
- `REVISION_SHEET_GENERATION_MAX_CHARS`
- `DIAGNOSTIC_QUIZ_GENERATION_MAX_CHUNKS`
- `DIAGNOSTIC_QUIZ_GENERATION_MAX_CHARS`
- `DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT`
- `DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT`
- `OPEN_QUESTION_GENERATION_MAX_CHUNKS`
- `OPEN_QUESTION_GENERATION_MAX_CHARS`
- `OPEN_ANSWER_EVALUATION_MAX_CHUNKS`
- `OPEN_ANSWER_EVALUATION_MAX_CHARS`

Timeouts IA :

- aucun paramètre d’environnement de timeout Genkit/provider n’a été trouvé dans le code audité ;
- les logs structurés exposent `durationMs`, ce qui permet de détecter les lenteurs ;
- la mitigation démo est de limiter les inputs par les variables `*_MAX_CHUNKS` et `*_MAX_CHARS`, de lancer les smoke checks avant présentation, et de définir tout timeout infra côté reverse proxy/plateforme si l’environnement l’exige.

### Obligatoires pour Firebase Auth

- `FIREBASE_PROJECT_ID` : projet Firebase cible.
- `FIREBASE_SERVICE_ACCOUNT_JSON` : JSON de service account si l’environnement ne peut pas utiliser les identifiants Firebase Admin par défaut.

Le code initialise Firebase Admin avec `FIREBASE_SERVICE_ACCOUNT_JSON` si fourni, sinon avec `FIREBASE_PROJECT_ID`. Ne jamais stocker le JSON de service account dans Git.

### Obligatoires pour Redis/BullMQ

- `REDIS_URL` : URL Redis complète si disponible.
- ou `REDIS_HOST` et `REDIS_PORT` : fallback local par défaut `127.0.0.1:6379` côté code.
- `DOCUMENT_PROCESSING_QUEUE_DISABLED=true` : désactive la queue documentaire, notamment utile pour certains contextes de test/local.
- `DOCUMENT_PROCESSING_WORKER_ENABLED=true` : active le consumer documentaire dans le module Jobs.

### Optionnelles

- `RUN_PRISMA_MIGRATIONS=true` : le Dockerfile API exécute `prisma migrate deploy` au démarrage si cette variable vaut `true`. À réserver aux environnements où cette stratégie est explicitement validée.
- `NODE_ENV` : `production`, `development`, `test`. Le fallback local `DATABASE_URL` est refusé hors local/test.

### Démo/seed

- `DEMO_SEED_CONFIRM=revision-demo`
- `DEMO_FIREBASE_UID=<uid-firebase-demo>`
- `DEMO_STUDENT_FIREBASE_UID=<uid-firebase-demo>` : alias accepté.
- `DEMO_STUDENT_EMAIL=demo-revision@example.test`
- `DEMO_STUDENT_DISPLAY_NAME="Demo Revision"`
- `DEMO_SEED_DRY_RUN=1`

Ne jamais remplacer ces exemples par de vraies valeurs dans Git.

## 6. Variables d’environnement Flutter

Configuration API confirmée :

- `API_BASE_URL` : `--dart-define` lu par `AppConfig.apiBaseUrl`.
- Valeur par défaut actuelle côté app : URL API déployée indiquée dans le README Flutter.
- Pour une API locale : `--dart-define=API_BASE_URL=http://localhost:3000`.

Configuration Firebase confirmée par le README et `firebase_options.dart` :

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_MEASUREMENT_ID`
- `FIREBASE_IOS_BUNDLE_ID`

Exemple local avec placeholders :

```bash
cd revision_app
flutter run -d macos \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=FIREBASE_PROJECT_ID=<firebase-project-id>
```

Ne pas ajouter de valeur Firebase réelle dans la documentation ou les scripts.

## 7. Préparation base de données

Commandes non destructives confirmées :

```bash
cd api
npx prisma validate
npm run prisma:generate
```

Script de migration confirmé dans `package.json` :

```bash
cd api
DATABASE_URL=<database-url-local-ou-staging> npm run prisma:migrate:deploy
```

Cette commande est documentée mais ne doit être exécutée que sur une base locale/staging explicitement choisie. Ne jamais la lancer sans vérifier la cible.

À ne jamais utiliser dans ce runbook de démo :

```bash
npx prisma db push
npx prisma migrate reset
```

En conteneur, le Dockerfile API lance automatiquement `prisma migrate deploy` au démarrage si `RUN_PRISMA_MIGRATIONS=true`. Cette stratégie doit être validée par l’exploitation de l’environnement cible.

## 8. Lancement services locaux

### PostgreSQL

Aucun script PostgreSQL dédié ni `docker-compose.yml` n’a été trouvé dans le repo. La commande exacte dépend donc de la machine ou de l’environnement staging.

Attendu local confirmé par README/code :

```text
host: localhost
port: 5432
database: revision
schema: public
```

### Redis

Aucun script Redis dédié ni `docker-compose.yml` n’a été trouvé dans le repo.

Attendu local confirmé par README/code :

```text
host: localhost ou 127.0.0.1
port: 6379
```

Si Redis n’est pas disponible et que le worker documentaire n’est pas testé, utiliser un environnement où la queue est explicitement désactivée avec `DOCUMENT_PROCESSING_QUEUE_DISABLED=true`.

### API NestJS

Commandes confirmées dans `api/package.json` :

```bash
cd api
npm install
npm run prisma:generate
npm run start:dev
```

API production build local :

```bash
cd api
npm run build
npm run start:prod
```

Port local par défaut : `3000`. Port conteneur par défaut : `8080`.

### Worker documentaire

Aucun script npm séparé `worker` n’a été trouvé. Le module Jobs active le consumer documentaire dans le même runtime NestJS quand :

```bash
DOCUMENT_PROCESSING_WORKER_ENABLED=true
```

Lancement local possible avec le script confirmé :

```bash
cd api
DOCUMENT_PROCESSING_WORKER_ENABLED=true npm run start:dev
```

Attention : cette commande démarre aussi le serveur HTTP NestJS. Elle peut donc entrer en conflit avec une API déjà lancée sur le même `PORT` local. Pour un test local split, choisir un `PORT` différent ou ne pas lancer deux processus HTTP simultanément. Il ne s’agit pas d’un binaire worker-only.

Pour un déploiement split API/worker, utiliser la même application buildée avec la même base, le même Redis et le même volume documentaire, mais activer `DOCUMENT_PROCESSING_WORKER_ENABLED=true` sur le process worker. La commande exacte de split est à confirmer selon l’environnement de déploiement.

### Flutter

Commandes confirmées dans le README Flutter :

```bash
cd revision_app
flutter pub get
flutter run -d macos --dart-define=API_BASE_URL=http://localhost:3000
```

Build web Docker confirmé par `revision_app/Dockerfile` :

```bash
cd revision_app
docker build \
  --build-arg API_BASE_URL=<api-base-url-demo> \
  -t revision-app:demo .
```

Le Dockerfile front sert le build web via nginx et expose le port `80`. Le Dockerfile audité ne transmet que `API_BASE_URL` à `flutter build web`. Les `--dart-define` Firebase listés plus haut ne sont pas configurables par cette commande Docker tant que le Dockerfile n’est pas étendu.

## 9. Seed de démonstration

Le seed LOT-036 prépare les données synthétiques de démo. Il ne crée pas de compte Firebase, ne lit pas de PDF physique, n’appelle pas Genkit, ne lance pas BullMQ et ne seed pas les QCM/questions ouvertes/sessions.

Dry-run non destructif :

```bash
cd api
DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
```

Seed réel, uniquement sur DB locale/staging explicitement prévue :

```bash
cd api
DEMO_SEED_CONFIRM=revision-demo \
DEMO_FIREBASE_UID=<uid-firebase-demo> \
DEMO_STUDENT_EMAIL=demo-revision@example.test \
DEMO_STUDENT_DISPLAY_NAME="Demo Revision" \
npm run demo:seed
```

Garde-fous confirmés :

- refus si `NODE_ENV=production` ;
- refus sans `DEMO_SEED_CONFIRM=revision-demo` ;
- refus sans UID Firebase ;
- résumé de sortie avec URL DB et UID masqués ;
- aucune suppression hors namespace démo.

Le compte Firebase doit exister avant la démo. Le seed crée seulement les lignes DB reliées à l’UID fourni.

## 10. Vérifications automatisées avant démo

Côté API :

```bash
cd api
npm run lint:check
npm test -- demo-seed --runInBand
npm test -- activities --runInBand
npm test -- revision --runInBand
npm test -- documents --runInBand
npm run test:e2e -- --runInBand
npm run build
git diff --check
```

Côté app/docs :

```bash
cd revision_app
git diff --check
```

Validation web recommandée avant une présentation externe :

```bash
cd revision_app
flutter build web --release --dart-define=API_BASE_URL=<api-base-url-demo>
```

Si la démo web doit viser un projet Firebase différent des valeurs par défaut de l’app, passer aussi les `--dart-define=FIREBASE_*` nécessaires ou étendre le Dockerfile front pour les recevoir en `ARG`.

Si du code Flutter est modifié dans un futur lot :

```bash
cd revision_app
dart analyze lib test
flutter test
```

Ne pas lancer `npm run lint`, `npm run format`, `npm run test:cov`, `dart fix --apply` ou `dart format .` dans ce runbook.

## 11. Smoke checks API

Checklist complète : [DEMO_SMOKE_CHECKS.md](./DEMO_SMOKE_CHECKS.md).

Résumé minimal :

- `GET /health` ;
- `GET /today` avec `<token-firebase-demo>` ;
- documents et notions ;
- résumé et fiche ;
- QCM ;
- question ouverte ;
- session IA.

Exemple sans vrai token :

```bash
API_URL=http://localhost:3000
TOKEN=<token-firebase-demo>
curl -sS "$API_URL/health"
curl -sS -H "Authorization: Bearer $TOKEN" "$API_URL/today"
```

Ne jamais coller un token Firebase réel dans Git, dans une capture publique ou dans une issue.

## 12. Scénario de présentation

### Démo courte 3 minutes

1. Présenter Revision App : “on transforme un cours en parcours de révision”.
2. Se connecter avec le compte Firebase de démo.
3. Ouvrir Today et montrer les actions recommandées.
4. Lancer une action de révision IA ou une question ouverte depuis Today.
5. Montrer une correction sourcée ou une action suivante.
6. Conclure : les données viennent des fichiers de cours et le plan s’adapte aux notions faibles.

### Démo complète 8-10 minutes

1. Présenter Revision App : “Duolingo, mais avec ses propres fichiers de cours”.
2. Se connecter avec le compte Firebase de démo.
3. Ouvrir Today.
4. Montrer les actions recommandées : QCM, question ouverte, session IA.
5. Ouvrir la matière de démo.
6. Ouvrir le document READY.
7. Montrer les notions sourcées.
8. Ouvrir résumé et fiche.
9. Lancer un QCM.
10. Montrer que la correction n’est pas visible avant submit.
11. Soumettre le QCM et montrer correction/sources.
12. Lancer une question ouverte depuis une notion.
13. Soumettre une réponse.
14. Montrer correction IA, points présents, points manquants, conseil et sources.
15. Lancer une session de révision IA.
16. Montrer que la session orchestre des actions existantes et ne rend pas de widget arbitraire.
17. Conclure sur Genkit borné, TodayPlan déterministe et fallback natif Flutter.

## 13. Données de démonstration attendues

Selon le seed LOT-036, la base de démo doit contenir :

- matière `Droit constitutionnel — Ve République` ;
- document logique READY `demo-droit-constitutionnel-veme-republique.pdf` ;
- six chunks synthétiques ;
- six notions sourcées ;
- quatre mastery states ;
- un objectif actif à `now + 30 jours` ;
- un résumé READY ;
- une fiche READY.

Le document est logique : son `storagePath` est en namespace `demo://...` et ne correspond pas à un PDF physique uploadé.

## 14. Troubleshooting

### API ne démarre pas

- Vérifier `npm install`.
- Vérifier `npm run prisma:generate`.
- Vérifier `DATABASE_URL` ou le fallback local.
- Vérifier que le port `3000` ou `PORT` est libre.
- Lancer `npm run build` pour isoler les erreurs TypeScript.

### Prisma / DB

- `DATABASE_URL` absent hors local/test : le code refuse le démarrage.
- DB inaccessible : vérifier host, port, database et credentials.
- Migrations non appliquées : appliquer uniquement sur DB locale/staging confirmée.
- Fallback local : utilisable seulement en local/test.

### Redis / BullMQ / worker

- Redis absent : vérifier `REDIS_URL` ou `REDIS_HOST`/`REDIS_PORT`.
- Queue non nécessaire : désactiver explicitement avec `DOCUMENT_PROCESSING_QUEUE_DISABLED=true`.
- Worker non lancé : vérifier `DOCUMENT_PROCESSING_WORKER_ENABLED=true`.
- Job bloqué : vérifier que le process worker partage DB, Redis et volume documentaire avec l’API.

### Firebase Auth

- Token absent : les routes protégées renvoient 401.
- UID seedé différent du compte connecté : Today peut être vide.
- Compte Firebase absent : créer le compte dans Firebase, hors seed.
- `FIREBASE_SERVICE_ACCOUNT_JSON` invalide : le code lève `FIREBASE_SERVICE_ACCOUNT_JSON must be valid JSON`.

### Seed

- Confirmation absente : définir `DEMO_SEED_CONFIRM=revision-demo`.
- UID absent : définir `DEMO_FIREBASE_UID` ou `DEMO_STUDENT_FIREBASE_UID`.
- Production refusée : comportement attendu.
- Namespace déjà utilisé par un autre étudiant : choisir une base de démo propre ou nettoyer uniquement les objets démo après validation.

### Genkit / IA

- Clé provider absente : les générations réelles échouent.
- Provider indisponible : retenter plus tard ou vérifier le provider choisi.
- Timeout : vérifier logs structurés `ai.generation` et limites de chunks.
- Output invalide : vérifier fallbacks Mistral configurés et prompts/schema versions.
- Coûts : limiter les tests réels avant présentation.

### Frontend Flutter

- Mauvaise API : vérifier `--dart-define=API_BASE_URL=...`.
- CORS : vérifier `CORS_ORIGINS` si l’origine n’est ni default ni localhost.
- Auth : vérifier que l’utilisateur est bien connecté au compte Firebase de démo.
- Today sans actions : vérifier seed réel, UID, objectif actif et mastery states.
- Route vide : vérifier que l’app pointe vers la bonne API et que le token est accepté.

## 15. Signaux rouges

Arrêter immédiatement la démo si :

- le seed est lancé sur la mauvaise base ;
- un token, secret, UID réel ou `DATABASE_URL` réel apparaît dans Git ;
- `/today` renvoie 500 ;
- Today est vide malgré seed réel ;
- une correction QCM est visible avant submit ;
- `modelAnswer` est visible avant submit ;
- `storagePath` est exposé dans une réponse publique ;
- une stack trace provider est exposée au frontend ;
- GenUI rend un widget non catalogué ou arbitraire.

## 16. Production safety

Ce document ne sert pas à lancer la production.

Interdits :

- seed production ;
- reset DB ;
- secrets dans Git ;
- migration destructive ;
- dry-run confondu avec seed réel ;
- appel IA massif sans limites ;
- `prisma db push` ;
- `prisma migrate reset` ;
- copie de token Firebase réel dans une doc ou un rapport.

Avant toute action staging, vérifier explicitement la cible DB, l’UID Firebase de démo et les variables IA.

## 17. Checklist finale avant présentation

- [ ] API démarrée.
- [ ] DB locale/staging confirmée.
- [ ] Migrations appliquées sur la bonne cible.
- [ ] Redis disponible ou queue désactivée explicitement.
- [ ] Worker disponible si le parcours documentaire réel est montré.
- [ ] Compte Firebase démo existant.
- [ ] UID seedé correspond au compte connecté.
- [ ] Seed réel lancé uniquement sur local/staging.
- [ ] `GET /health` OK.
- [ ] `GET /today` OK avec token de démo.
- [ ] Flutter pointe vers la bonne API.
- [ ] Runbook rejoué intégralement sur l’environnement cible avant toute présentation externe.
- [ ] Parcours court testé.
- [ ] Parcours complet testé si nécessaire.
- [ ] `git diff --check` OK côté API et docs.
- [ ] Aucun secret dans `git diff`.
``````

### revision_app/docs/demo/DEMO_SEED_RUNBOOK.md

``````markdown
# Runbook — Seed démo Revision App

Voir aussi le runbook global : [DEMO_DEPLOYMENT_RUNBOOK.md](./DEMO_DEPLOYMENT_RUNBOOK.md).

## 1. Objectif

Ce runbook explique comment préparer une base locale ou de démonstration avec un scénario reproductible pour Revision App.

Le seed permet de tester :

* une matière réaliste ;
* un document logique `READY` ;
* des chunks sourcés ;
* des notions extraites ;
* un objectif de révision actif ;
* des mastery states variés ;
* un résumé et une fiche prêts ;
* un TodayPlan multi-actions exploitable.

## 2. Ce que le seed crée

Le seed crée un scénario synthétique autour de :

```text
Droit constitutionnel — Ve République
```

Il crée :

* un `StudentProfile` lié au Firebase UID fourni ;
* une matière de démo ;
* un document logique `READY` ;
* six chunks courts et synthétiques ;
* six notions sourcées ;
* un objectif de révision à `now + 30 jours` ;
* quatre mastery states réalistes ;
* un résumé `READY` ;
* une fiche `READY`.

## 3. Ce que le seed ne fait pas

Le seed ne fait pas :

* création de compte Firebase ;
* bypass Firebase Auth ;
* upload réel de PDF ;
* lecture de fichier PDF ;
* appel Genkit ;
* appel provider IA ;
* lancement worker PDF ;
* lancement BullMQ ;
* création de QCM ;
* création de question ouverte ;
* création de session de révision.

## 4. Prérequis

* Avoir une base PostgreSQL locale ou de démonstration prévue pour cet usage.
* Avoir appliqué les migrations avant d’exécuter le seed.
* Avoir un compte Firebase de démonstration existant.
* Récupérer l’UID Firebase de ce compte.

Ne jamais utiliser ce seed sur production.

## 5. Firebase UID de démo

Le seed ne crée pas de compte Firebase.

L’utilisateur devra se connecter dans l’app avec un compte Firebase dont l’UID correspond à la variable fournie au seed.

Ne jamais commiter un UID Firebase réel dans Git.

## 6. Variables d’environnement

Variables obligatoires :

```bash
DEMO_SEED_CONFIRM=revision-demo
DEMO_FIREBASE_UID=<firebase uid du compte demo>
```

Alias accepté :

```bash
DEMO_STUDENT_FIREBASE_UID=<firebase uid du compte demo>
```

Variables optionnelles :

```bash
DEMO_STUDENT_EMAIL=demo-revision@example.test
DEMO_STUDENT_DISPLAY_NAME="Demo Revision"
DEMO_SEED_DRY_RUN=1
```

## 7. Dry-run

Depuis `api` :

```bash
DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
```

Le dry-run :

* valide les garde-fous ;
* construit les fixtures ;
* affiche les IDs prévus ;
* masque l’URL DB et l’UID ;
* n’écrit rien en base.

## 8. Seed réel

Depuis `api`, uniquement sur une DB locale ou une DB de démonstration explicitement prévue :

```bash
DEMO_SEED_CONFIRM=revision-demo \
DEMO_FIREBASE_UID=<firebase uid du compte demo> \
DEMO_STUDENT_EMAIL=demo-revision@example.test \
DEMO_STUDENT_DISPLAY_NAME="Demo Revision" \
npm run demo:seed
```

Si `DATABASE_URL` est absent en environnement local, le backend utilise son fallback local documenté :

```text
postgresql://revision:revision@localhost:5432/revision?schema=public
```

## 9. Vérifier dans l’app

1. Se connecter avec le compte Firebase correspondant à l’UID seedé.
2. Ouvrir `Tes matières`.
3. Vérifier la matière `Droit constitutionnel — Ve République`.
4. Ouvrir le document de démo.
5. Vérifier les notions, le résumé et la fiche.
6. Ouvrir `Aujourd’hui`.
7. Vérifier que plusieurs actions sont proposées.

## 10. Vérifier via API

Avec un token Firebase valide du compte de démo :

```bash
API_URL=http://localhost:3000
curl -H "Authorization: Bearer <firebase id token>" "$API_URL/today"
```

Le plan doit contenir des actions `diagnostic_quiz`, `open_question` et `revision_session` si les données sont intactes.

Si l’API tourne dans le conteneur Docker exposé en local, adapter `API_URL` vers le port publié, par exemple `http://localhost:8080`.

## 11. Relancer le seed

Le seed est idempotent.

Il peut être relancé avec les mêmes variables. Les données de démo connues sont mises à jour sans créer de doublons.

## 12. Nettoyage

Le script ne propose pas de commande globale de nettoyage.

Il ne supprime pas les données utilisateur hors namespace démo. Les seules suppressions automatiques concernent des liens ou sections identifiés par des IDs `demo-*` pendant la remise en place des fixtures.

Pour nettoyer manuellement, cibler uniquement les IDs `demo-*` listés dans la sortie dry-run.

## 13. Limites connues

* Le document est logique : aucun PDF physique n’est stocké.
* Les chunks sont synthétiques.
* Les QCM et questions ouvertes ne sont pas seedés.
* Le seed réel n’a pas vocation à tourner en production.

## 14. Troubleshooting

### `DEMO_SEED_CONFIRM=revision-demo is required`

Ajouter la variable de confirmation explicite.

### `DEMO_FIREBASE_UID or DEMO_STUDENT_FIREBASE_UID is required`

Fournir l’UID Firebase du compte de démo.

### `Demo seed is not allowed with NODE_ENV=production`

Ne pas exécuter ce seed en production.

### `Demo namespace already belongs to another student profile`

Le namespace `demo-*` existe déjà pour un autre `StudentProfile`. Utiliser le même UID de démo ou nettoyer explicitement les données de démo concernées sur une base non production.
``````

### revision_app/docs/demo/DEMO_SMOKE_CHECKS.md

``````markdown
# Smoke checks — Revision App

Voir aussi le runbook global : [DEMO_DEPLOYMENT_RUNBOOK.md](./DEMO_DEPLOYMENT_RUNBOOK.md).

## 1. Objectif

Cette checklist sert à vérifier rapidement que la démo Revision App reste présentable après un changement backend, frontend ou infra.

Elle cible uniquement les chemins critiques :

- disponibilité API ;
- seed de démo ;
- plan du jour ;
- documents et notions ;
- résumé et fiche ;
- QCM ;
- question ouverte ;
- session de révision IA ;
- écran Flutter principal.

Elle ne remplace pas les tests automatisés ni une recette complète.

## 2. Prérequis

- API démarrée sur l’environnement à tester.
- Application Flutter pointée vers cette API.
- Un compte Firebase de démonstration existe déjà.
- L’UID Firebase de ce compte est connu par la personne qui exécute le smoke.
- Les migrations nécessaires ont déjà été appliquées sur la base cible.
- Ne jamais utiliser une base de production pour le seed.

Valeurs factices utilisées dans les exemples :

```bash
DEMO_FIREBASE_UID=demo-local-uid
DEMO_STUDENT_EMAIL=demo-revision@example.test
```

Ne pas remplacer ces exemples par un vrai UID ou un vrai token dans Git.

## 3. Commandes API non destructives

Depuis le dossier API :

```bash
npx prisma validate
npm run prisma:generate
npm run lint:check
npm test -- demo-seed --runInBand
npm run test:e2e -- --runInBand
```

Ne pas lancer :

```bash
npm run lint
npm run format
npm run test:cov
npx prisma db push
npx prisma migrate reset
```

## 4. Validation du seed dry-run

Le dry-run valide les garde-fous et affiche les objets prévus sans écrire en base.

```bash
cd api
DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
```

Attendu :

- sortie JSON ;
- `mode` vaut `dry-run` ;
- l’URL DB est masquée ;
- l’UID Firebase est masqué ;
- 1 matière ;
- 1 document ;
- plusieurs chunks ;
- plusieurs notions ;
- plusieurs mastery states ;
- aucun appel Genkit ;
- aucune écriture DB.

## 5. Validation optionnelle du seed réel sur DB locale/staging

Le seed réel est autorisé uniquement sur une base locale ou staging explicitement prévue pour la démo.

Exemple :

```bash
cd api
DEMO_SEED_CONFIRM=revision-demo \
DEMO_FIREBASE_UID=<uid-firebase-demo> \
DEMO_STUDENT_EMAIL=demo-revision@example.test \
DEMO_STUDENT_DISPLAY_NAME="Demo Revision" \
npm run demo:seed
```

Attendu :

- refus si `NODE_ENV=production` ;
- refus sans confirmation ;
- refus sans UID Firebase ;
- résumé des données créées ;
- aucune donnée hors namespace démo supprimée.

Le seed ne crée pas de compte Firebase. Il crée uniquement les lignes DB associées à l’UID fourni.

## 6. Smoke API `/health`

```bash
curl -sS "$API_URL/health"
```

Attendu :

```json
{"status":"ok"}
```

## 7. Smoke API `/today` avec token Firebase de démo

Récupérer un token Firebase depuis l’app ou un outil local sécurisé, sans le coller dans Git.

```bash
curl -sS "$API_URL/today" \
  -H "Authorization: Bearer <token-firebase-demo>"
```

Attendu :

- `generatedAt` présent ;
- `items` est une liste ;
- actions possibles : `diagnostic_quiz`, `open_question`, `revision_session` ;
- pas de contenu source complet inattendu ;
- pas de secret.

## 8. Smoke documents et notions

```bash
curl -sS "$API_URL/subjects/<subject-id>/documents" \
  -H "Authorization: Bearer <token-firebase-demo>"

curl -sS "$API_URL/documents/<document-id>" \
  -H "Authorization: Bearer <token-firebase-demo>"

curl -sS "$API_URL/documents/<document-id>/knowledge-units" \
  -H "Authorization: Bearer <token-firebase-demo>"
```

Attendu :

- document READY visible ;
- notions visibles ;
- sources visibles sous forme bornée ;
- pas de `storagePath` dans les réponses publiques.

Le document seedé est un document logique READY. Il ne correspond pas à un PDF physique importé.

## 9. Smoke résumé / fiche

```bash
curl -sS "$API_URL/documents/<document-id>/summary" \
  -H "Authorization: Bearer <token-firebase-demo>"

curl -sS "$API_URL/documents/<document-id>/revision-sheet" \
  -H "Authorization: Bearer <token-firebase-demo>"
```

Attendu :

- résumé READY ;
- fiche READY ;
- sources bornées ;
- pas de `promptVersion`, `provider`, `model`, `storagePath` dans la réponse publique.

## 10. Smoke QCM

```bash
curl -sS "$API_URL/activities/next" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"subjectId":"<subject-id>","knowledgeUnitId":"<knowledge-unit-id>","questionCount":10}'
```

Attendu pré-submit :

- type `diagnostic_quiz` ;
- questions visibles ;
- choix visibles ;
- pas de `correctChoiceId` ;
- pas de `correctChoiceIds` ;
- pas de feedback/correction.

Les QCM ne sont pas seedés directement. Ils sont générés ou lancés par les use cases existants.

## 11. Smoke question ouverte

```bash
curl -sS "$API_URL/activities/open-question" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"subjectId":"<subject-id>","knowledgeUnitId":"<knowledge-unit-id>"}'
```

Attendu pré-submit :

- type `open_question` ;
- prompt visible ;
- sources sans texte complet ;
- pas de `modelAnswer` ;
- pas de score ;
- pas de feedback.

Soumission :

```bash
curl -sS "$API_URL/activities/<session-id>/open-answer" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"answerText":"Réponse de démonstration structurée, sans donnée personnelle."}'
```

Attendu post-submit :

- évaluation `READY` ou `FAILED` contrôlé ;
- pas de stack trace ;
- pas de message provider brut.

## 12. Smoke session de révision IA

```bash
curl -sS "$API_URL/revision-sessions" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -H "Content-Type: application/json" \
  -d '{"subjectId":"<subject-id>","knowledgeUnitId":"<knowledge-unit-id>"}'
```

Attendu :

- session STARTED ;
- action initiale déterministe ;
- payload métier public ;
- pas de widget arbitraire ;
- pas de correction pré-submit.

Action suivante :

```bash
curl -sS "$API_URL/revision-sessions/<session-id>/next-action" \
  -H "Authorization: Bearer <token-firebase-demo>" \
  -X POST
```

Attendu :

- action bornée ;
- pas de chatbot libre ;
- pas de payload arbitraire.

## 13. Smoke frontend manuel

Dans l’app Flutter :

1. Se connecter avec le compte Firebase de démonstration.
2. Ouvrir `Aujourd'hui`.
3. Vérifier plusieurs actions dans le plan du jour.
4. Lancer un QCM depuis Today.
5. Lancer une question ouverte depuis Today.
6. Lancer une session de révision IA depuis Today.
7. Ouvrir la matière de démo.
8. Ouvrir le document de démo.
9. Vérifier les notions sourcées.
10. Vérifier le résumé et la fiche si l’UI les expose.

Attendu :

- pas d’écran vide inattendu ;
- pas de correction QCM avant submit ;
- pas de source complète pré-submit ;
- messages d’erreur propres en cas d’échec IA.

## 14. Signaux rouges / rollback

Arrêter la démo et investiguer si :

- `/health` échoue ;
- `/today` retourne une erreur 500 ;
- le seed réel a été lancé sur une mauvaise base ;
- la page Today affiche zéro action malgré le seed ;
- un payload pré-submit contient `correctChoiceId`, `correctChoiceIds` ou `modelAnswer` ;
- un endpoint renvoie une stack trace ;
- un token réel, UID réel ou secret a été copié dans un fichier du repo.

## 15. Ce qui ne doit jamais être fait en production

- Ne jamais lancer le seed réel en production.
- Ne jamais lancer `prisma migrate reset`.
- Ne jamais lancer `prisma db push --force-reset`.
- Ne jamais écrire un token Firebase réel dans Git.
- Ne jamais écrire un UID personnel dans Git.
- Ne jamais exposer `DATABASE_URL`, clés IA ou secrets Redis dans une doc.
- Ne jamais utiliser le dry-run comme preuve que les données ont été écrites.
``````

### revision_app/docs/ROADMAP_EXECUTION_PLAN.md

``````markdown
# Roadmap Execution Plan — Revision App

## 1. But du document

Ce fichier transforme `docs/ROADMAP.md` en lots d'exécution atomiques, ordonnés et validables.

La roadmap existante donne une bonne direction produit et technique. Ce plan ajoute l'ordre d'attaque, les dépendances, les critères de stop, les validations futures et les zones probables à inspecter ou modifier. Il ne remplace pas la roadmap stratégique : il la rend exécutable par petits lots de 0,5 à 2 jours.

Ce document ne prescrit aucune implémentation immédiate. Les lots ci-dessous décrivent le travail futur à réaliser en conservant :

- la Clean Architecture NestJS ;
- les patterns Flutter, Riverpod et GoRouter existants ;
- Genkit côté backend comme moteur IA typé et validé ;
- GenUI côté frontend comme catalogue borné de composants, jamais comme interpréteur libre ;
- l'isolation stricte par `studentId`.

## 2. Lecture critique de la roadmap actuelle

### Ce qui est solide

- La vision produit est claire : importer un cours, extraire des notions, générer des supports, entraîner l'étudiant, corriger et adapter le plan.
- Le pipeline actuel existe déjà : upload PDF, job BullMQ, extraction texte, extraction Genkit, `KnowledgeUnit`, QCM, mastery, `GET /today`.
- L'architecture backend a déjà des ports applicatifs et adapters : repositories Prisma, `DocumentTextExtractor`, `DocumentKnowledgeExtractor`, `DiagnosticQuizGenerator`.
- Le frontend a déjà GoRouter, Riverpod, un shell par onglets persistants, des pages principales et des repositories HTTP.
- Genkit est déjà réellement utilisé, pas seulement installé.
- GenUI est déjà amorcé via un catalogue d'activité, même s'il reste très limité.
- La roadmap identifie bien les grandes fonctionnalités produit : fiches, QCM enrichi, question ouverte, session IA, plan du jour avancé.

### Ce qui est trop large

- Les phases de la roadmap sont trop grosses pour être exécutées telles quelles. Par exemple, “Documents et knowledge units enrichis” mélange extraction, schéma, persistance, API, UI et anti-hallucination.
- “Résumés et fiches” suppose des sources fiables, mais les sources ne sont pas encore stabilisées.
- “Session de révision IA avec GenUI” dépend de composants isolés qui ne sont pas encore conçus, validés ni testés.
- “Plan du jour adaptatif avancé” dépend de nouveaux types d'activités et d'un historique de maîtrise plus riche.
- La phase “Démo, qualité, sécurité et déploiement” arrive trop tard pour l'observabilité Genkit et les limites de coûts.

### Ce qui doit être déplacé plus tôt

- Les fondations documentaires doivent précéder les résumés : `DocumentChunk`, `SourceReference`, liens entre chunks et notions, stratégie anti-hallucination.
- L'observabilité Genkit doit arriver avant les nouveaux flows : nom du flow, provider, modèle, durée, taille input, statut, erreur, version de prompt, version de schéma.
- Le versioning des outputs IA doit être défini avant les nouvelles tables et les nouveaux endpoints.
- La stratégie des artefacts générés doit être décidée tôt : modèles spécialisés (`Summary`, `RevisionSheet`, `OpenAnswerEvaluation`) ou modèle transversal (`GeneratedArtifact`, `AiGenerationJob`) avec relations typées.
- Le golden demo path doit être préparé tôt, car il conditionne le PDF de test, les seeds, les validations manuelles et le récit de démonstration.

### Ce qui doit être repoussé

- La session coach complète doit être retardée. Elle ne doit venir qu'après stabilisation des composants isolés : résumé, source excerpt, QCM, correction et question ouverte.
- Le plan du jour multi-actions avancé doit attendre que les activités et mastery events soient plus riches.
- Les imports OCR, image et audio doivent rester hors MVP tant que les PDF texte ne sont pas robustes.
- La génération libre de widgets doit rester interdite.
- Une refonte UI totale non bornée doit être évitée : il faut avancer par primitives réutilisables et surfaces prioritaires.

### Ce qui manque pour sécuriser la démo

- Un PDF de démonstration connu, texte et stable.
- Un scénario reproductible avec états attendus.
- Des données de seed contrôlées.
- Des contrôles d'ownership sur chaque nouveau endpoint.
- Des tests anti-hallucination sur les références sources.
- Une validation GenUI stricte et testée.
- Des erreurs IA affichables côté produit.
- Des limites de coût, timeout et taille input dès les premiers flows enrichis.

### Points critiques à corriger dans l'ordre d'exécution

- Ne pas demander à l'IA de produire librement des `sourceExcerpt`. Le backend doit découper ou référencer des chunks existants, puis Genkit doit pointer vers ces références quand c'est possible.
- Ne pas laisser coexister deux chemins documentaires flous. Le plan doit trancher tôt entre upload direct backend, Firebase Storage lu par le backend, ou coexistence temporaire documentée.
- Ne pas construire `generateCoachNextActionFlow` avant d'avoir des contrats d'activité stables.
- Ne pas enrichir le QCM sans protéger la non-fuite de `correctChoiceId` avant submit.
- Ne pas rendre des payloads GenUI sans validation stricte côté Flutter.
- Ne pas exposer des contenus générés sans version de schéma et de prompt.

## 3. Principes d'exécution

- Chaque lot doit rester réalisable en environ 0,5 à 2 jours.
- Aucun lot ne doit contenir un refactor massif.
- Aucun commit Git ne doit être fait par défaut.
- Aucun `git commit`, `git amend`, `git merge`, `git rebase`, `git push`, `git tag` ou autre écriture Git ne doit être lancé sans demande explicite.
- Aucun objectif hors lot ne doit être ajouté pendant l'implémentation future.
- Toute modification de code future doit être accompagnée de tests pertinents ou d'une justification explicite.
- Le backend doit continuer à suivre la Clean Architecture NestJS : controller mince, use case applicatif, port, adapter.
- Le frontend doit continuer à utiliser Riverpod pour les états et GoRouter pour la navigation.
- Genkit doit produire des outputs typés, validés et versionnés.
- GenUI doit rester borné par un catalogue strict.
- L'ownership `studentId` doit être vérifié dans chaque nouveau chemin backend.
- Une UI de fallback doit exister quand GenUI ou l'IA échoue.
- Les erreurs IA doivent être explicites, journalisées et traduisibles côté produit.
- Aucun widget arbitraire ne doit être généré par l'IA.
- Les validations doivent être lancées depuis les racines réelles : `api` pour NestJS et `revision_app` pour Flutter.
- Les scripts qui écrivent automatiquement, comme `npm run lint` côté API avec `--fix`, ne doivent pas être utilisés comme validation non destructive ; préférer `npm run lint:check`.

## 4. Découpage macro recommandé

### Bloc A — Audit et vérité projet

Objectif : connaître précisément l'existant avant d'ajouter.

Ce bloc verrouille les contrats actuels, les scripts disponibles, les gaps entre roadmap et code réel, et les décisions structurantes.

### Bloc B — Design system minimal et surfaces premium

Objectif : sortir du Material brut sans refaire toute l'app.

Ce bloc stabilise les primitives Flutter réutilisables, puis les applique seulement aux surfaces prioritaires de la démo.

### Bloc C — Fondations documentaires et sources

Objectif : chunks, source references, knowledge units enrichies, anti-hallucination.

Ce bloc rend possible la génération de fiches et corrections sourcées sans demander à l'IA d'inventer des extraits.

### Bloc D — Détail document et notions côté front

Objectif : rendre le processing IA visible et utile.

Ce bloc expose les notions, statuts, erreurs et sources à l'utilisateur avant d'ajouter des artefacts avancés.

### Bloc E — Observabilité et versioning Genkit

Objectif : rendre les flows IA diagnostiquables dès les premières générations.

Ce bloc doit arriver tôt pour éviter de debuguer les fiches, QCM et corrections à l'aveugle.

### Bloc F — Résumés et fiches

Objectif : premier artefact IA exploitable.

Ce bloc ajoute les résumés et fiches après stabilisation des sources.

### Bloc G — QCM enrichi

Objectif : correction détaillée, feedback, maîtrise.

Ce bloc améliore l'activité existante sans changer tout le modèle d'activité d'un coup.

### Bloc H — Question ouverte corrigée

Objectif : fonctionnalité forte de démonstration.

Ce bloc ajoute l'activité la plus différenciante, mais seulement après les sources et l'observabilité.

### Bloc I — GenUI catalog isolé

Objectif : composants bornés avant la session coach.

Ce bloc stabilise les composants dynamiques un par un.

### Bloc J — Session de révision IA

Objectif : orchestration seulement après stabilisation des briques.

Ce bloc assemble les artefacts et activités existants dans une session coach contrôlée.

### Bloc K — Plan du jour avancé

Objectif : recommandations multi-actions déterministes.

Ce bloc élargit `TodayPlan` quand les actions existent déjà.

### Bloc L — Golden demo, qualité et déploiement

Objectif : rendre la démo reproductible.

Ce bloc ajoute seed, scénario, validations manuelles, runbooks et checks critiques.

## 5. Lots d'exécution ordonnés

### Suivi d'exécution des lots

Ce tableau doit être mis à jour à chaque lot réalisé. Cette règle est également inscrite dans `revision_app/AGENTS.md`.

| Lot | Titre | Statut | Rapport |
| --- | --- | --- | --- |
| LOT-001 | Audit des contrats actuels | Réalisé | `docs/ROADMAP_EXECUTION_LOT_001_001B.md` |
| LOT-001B | Décision stratégie upload et lecture document | Réalisé | `docs/ROADMAP_EXECUTION_LOT_001_001B.md` |
| LOT-002 | Décisions fondations IA et documentaire | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-002B | Revue de schéma avant migrations | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-003 | Golden demo baseline | Réalisé | `docs/ROADMAP_EXECUTION_LOT_002_002B_003.md` |
| LOT-004 | Port d'observabilité Genkit | Réalisé | `docs/ROADMAP_EXECUTION_LOT_004_005.md` |
| LOT-005 | Instrumentation des flows Genkit existants | Réalisé | `docs/ROADMAP_EXECUTION_LOT_004_005.md` |
| LOT-006 | Inventaire design system et surfaces prioritaires | À faire | À créer |
| LOT-007 | Primitives UI minimales pour la démo | À faire | À créer |
| LOT-008 | Application UI ciblée aux pages existantes | À faire | À créer |
| LOT-009 | Modèle documentaire cible détaillé | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-010 | Persistance minimale des chunks et sources | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-010B | Réparation migration Prisma DocumentChunk / KnowledgeUnitSource | Réalisé | `docs/ROADMAP_EXECUTION_LOT_010B.md` |
| LOT-011 | Chunking PDF dans le worker | Réalisé | `docs/ROADMAP_EXECUTION_LOT_009_010_011.md` |
| LOT-012 | Extraction Genkit v2 basée sur chunks | Réalisé | `docs/ROADMAP_EXECUTION_LOT_012_013.md` |
| LOT-013 | Persistance KnowledgeUnit enrichie | Réalisé | `docs/ROADMAP_EXECUTION_LOT_012_013.md` |
| LOT-014 | API détail document et notions sourcées | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-015 | Data layer Flutter pour détail document | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-016 | Page détail document et notions | Réalisé | `docs/ROADMAP_EXECUTION_LOT_014_015_016.md` |
| LOT-017 | Contrat artefacts générés | Réalisé | `docs/ROADMAP_EXECUTION_LOT_017.md` |
| LOT-018 | Persistance Summary et RevisionSheet | Réalisé | `docs/ROADMAP_EXECUTION_LOT_018.md` |
| LOT-019 | Flow Genkit résumé et fiche | Réalisé | `docs/ROADMAP_EXECUTION_LOT_019_020.md` |
| LOT-020 | API résumés et fiches | Réalisé | `docs/ROADMAP_EXECUTION_LOT_019_020.md` |
| LOT-021 | UI résumé et fiche | Réalisé | `docs/ROADMAP_EXECUTION_LOT_021_029.md` |
| LOT-022 | Contrat QCM v2 | Réalisé | `docs/ROADMAP_EXECUTION_LOT_022.md` |
| LOT-023 | Genkit QCM enrichi | Réalisé | `docs/ROADMAP_EXECUTION_LOT_023.md` |
| LOT-024 | Persistance et soumission QCM enrichies | Réalisé | `docs/ROADMAP_EXECUTION_LOT_024.md` |
| LOT-025 | UI QCM enrichi | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025.md` |
| LOT-025B | QCM questionCount configurable et contrat média/multi-réponse | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md` |
| LOT-025C | QCM média et multi-réponse : contrat backend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md` |
| LOT-025D | QCM média et multi-réponse : backend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md` |
| LOT-025E | QCM média et multi-réponse : UI | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md` |
| LOT-025F | Validation DB/runtime QCM v3 | Réalisé | `docs/ROADMAP_EXECUTION_LOT_025F_QCM_V3_DB_RUNTIME_VALIDATION.md` |
| LOT-026 | Contrat question ouverte | Réalisé | `docs/ROADMAP_EXECUTION_LOT_026_OPEN_QUESTION_CONTRACT.md` |
| LOT-027 | Genkit question ouverte et correction | Réalisé | `docs/ROADMAP_EXECUTION_LOT_027_OPEN_QUESTION_GENKIT_CORRECTION.md` |
| LOT-028 | UI question ouverte corrigée | Réalisé | `docs/ROADMAP_EXECUTION_LOT_028_OPEN_QUESTION_UI.md` |
| LOT-029 | GenUI composants lecture sourcée | Réalisé | `docs/ROADMAP_EXECUTION_LOT_021_029.md` |
| LOT-030 | GenUI composants activité et correction | Réalisé | `docs/ROADMAP_EXECUTION_LOT_030_GENUI_ACTIVITY_CORRECTION.md` |
| LOT-031 | Session de révision IA minimale | Réalisé | `docs/ROADMAP_EXECUTION_LOT_031_REVISION_SESSION_MINIMAL.md` |
| LOT-032 | Écran Révision IA minimal | Réalisé | `docs/ROADMAP_EXECUTION_LOT_032_REVISION_SESSION_SCREEN.md` |
| LOT-033 | Orchestration coach Genkit | Réalisé | `docs/ROADMAP_EXECUTION_LOT_033_REVISION_COACH_GENKIT.md` |
| LOT-034 | TodayPlan multi-actions backend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_034_TODAY_PLAN_MULTI_ACTIONS_BACKEND.md` |
| LOT-035 | TodayPage v2 frontend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_035_TODAY_PAGE_V2_FRONTEND.md` |
| LOT-036 | Seed et fixtures de démo | Réalisé | `docs/ROADMAP_EXECUTION_LOT_036_DEMO_SEED_FIXTURES.md` |
| LOT-037 | Tests e2e critiques et smoke checks | Réalisé | `docs/ROADMAP_EXECUTION_LOT_037_E2E_SMOKE_CHECKS.md` |
| LOT-038 | Runbook démo et déploiement | Réalisé | `docs/ROADMAP_EXECUTION_LOT_038_DEMO_DEPLOYMENT_RUNBOOK.md` |

### LOT-001 — Audit des contrats actuels

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Établir l'inventaire exact des routes, use cases, modèles, providers et tests existants.

**Pourquoi maintenant :**
Le plan doit partir du code réel, pas de la roadmap idéale.

**Périmètre inclus :**

- Cartographier les endpoints backend existants.
- Cartographier les pages et routes Flutter existantes.
- Cartographier les flows Genkit existants.
- Cartographier le catalogue GenUI actuel.
- Lister les tests déjà présents.

**Non-objectifs :**

- Modifier du code.
- Modifier Prisma.
- Ajouter des endpoints.
- Ajouter des composants UI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/**`
- `api/prisma/schema.prisma`
- `api/package.json`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/features/**`
- `revision_app/lib/presentation/**`
- `revision_app/test/**`

**Backend :**
Lecture des modules `documents`, `jobs`, `ai`, `activities`, `revision`, `subjects`, `auth`.

**Frontend :**
Lecture des routes, providers, pages, APIs HTTP et composants partagés.

**Genkit :**
Identifier extraction de notions et génération QCM.

**GenUI :**
Identifier le catalogue `revision_activity_catalog.dart` et son validateur.

**Données / Prisma :**
Lecture seule du schéma.

**API :**
Inventaire uniquement.

**Tests futurs attendus :**
Validation documentaire par checklist.

**Commandes de validation futures :**

- `cd api && npm run lint:check`
- `cd api && npm test`
- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les endpoints actuels sont listés.
- Les modèles Prisma actuels sont listés.
- Les flows Genkit actuels sont listés.
- Les composants GenUI actuels sont listés.

**Critère de stop :**
Ne pas passer au lot suivant si le schéma Prisma réel ou les routes actuelles n'ont pas été inspectés.

**Risques :**

- Partir sur des noms de modèles qui n'existent pas.
- Écrire un plan incompatible avec les providers actuels.

### LOT-001B — Décision stratégie upload et lecture document

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Choisir le chemin officiel de stockage et lecture des documents pour le MVP.

**Pourquoi maintenant :**
Le worker de chunks et d'extraction doit lire le PDF au bon endroit. Si le front upload dans Firebase Storage mais que le worker lit le stockage local backend, le pipeline échoue silencieusement ou part dans deux directions.

**Périmètre inclus :**

- Comparer upload direct backend via `POST /documents/course-pdf`.
- Comparer upload Firebase Storage puis `POST /documents` metadata.
- Vérifier l'implémentation actuelle `LocalDocumentFileStorage`.
- Vérifier le comportement actuel du front multipart.
- Choisir le chemin officiel MVP.
- Documenter le chemin secondaire si on le garde temporairement.

**Non-objectifs :**

- Modifier l'upload.
- Ajouter un adapter Firebase Storage backend.
- Supprimer un endpoint existant.
- Migrer les documents déjà uploadés.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/infrastructure/local-document-file-storage.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/presentation/document_import_button.dart`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

**Backend :**
Décider quel `DocumentContentReader` est source de vérité pour le worker MVP.

**Frontend :**
Décider si l'upload officiel reste multipart backend ou redevient Firebase Storage.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Décider le statut de :

- `POST /documents/course-pdf`
- `POST /documents`

**Tests futurs attendus :**
Validation manuelle ou test d'intégration du chemin choisi.

**Commandes de validation futures :**

- `cd api && npm test -- documents`
- `cd revision_app && flutter test test/features/documents`

**Critères d'acceptation :**

- Le chemin officiel MVP est écrit.
- Le worker sait où lire le PDF.
- Le chemin non officiel est explicitement marqué comme legacy, secondaire ou futur.
- Aucun futur lot chunk/worker ne dépend d'une hypothèse implicite.

**Critère de stop :**
Ne pas modifier le pipeline chunks/worker tant que la stratégie de lecture document n'est pas tranchée.

**Risques :**

- Deux chemins d'upload divergents.
- Worker qui lit un fichier absent.
- Documentation contradictoire entre front et back.

### LOT-002 — Décisions fondations IA et documentaire

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Décider les options structurantes avant d'ajouter les résumés, fiches et corrections.

**Pourquoi maintenant :**
Les choix `DocumentChunk`, `SourceReference`, `GeneratedArtifact` et `AiGenerationJob` influencent presque tous les lots suivants.

**Périmètre inclus :**

- Comparer modèle spécialisé et modèle transversal pour les artefacts IA.
- Décider si `DocumentChunk` est nécessaire en MVP.
- Décider comment stocker ou référencer les sources.
- Décider si les générations sont synchrones ou asynchrones.
- Documenter les versions de prompt et de schéma.

**Non-objectifs :**

- Écrire la migration Prisma.
- Implémenter les modèles.
- Changer les flows existants.

**Fichiers ou zones probablement concernés :**

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- Futur document ADR dans `docs/` si demandé.

**Backend :**
Définir les options d'architecture.

**Frontend :**
Identifier l'impact sur les DTO affichés.

**Genkit :**
Définir `promptVersion`, `schemaVersion`, provider et modèle comme métadonnées obligatoires.

**GenUI :**
Décider si les payloads GenUI sont stockés comme artefacts ou reconstruits depuis les données métier.

**Données / Prisma :**
Options à comparer :

- modèles spécialisés uniquement ;
- `GeneratedArtifact` transversal ;
- `AiGenerationJob` pour statut et observabilité ;
- combinaison légère : modèles métier + table d'observabilité.

**API :**
Aucun contrat public à ajouter.

**Tests futurs attendus :**
Revue d'architecture.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Une recommandation est écrite pour chunks, sources et artefacts IA.
- Les décisions reportées sont explicites.
- Les lots suivants savent quelle option suivre.

**Critère de stop :**
Ne pas créer de résumé ou correction IA avant d'avoir choisi une stratégie source et versioning.

**Risques :**

- Sur-modéliser trop tôt.
- Sous-modéliser et rendre les sources impossibles à vérifier.

### LOT-002B — Revue de schéma avant migrations

**Bloc :**
Bloc A — Audit et vérité projet.

**Objectif :**
Regrouper les décisions de schéma avant la première migration documentaire.

**Pourquoi maintenant :**
Les lots futurs peuvent sinon produire une suite de migrations Prisma trop nombreuses : chunks, sources, knowledge units enrichies, summaries, QCM v2, questions ouvertes et sessions.

**Périmètre inclus :**

- Relire les décisions du LOT-001B et du LOT-002.
- Lister les migrations indispensables au MVP Cut 1.
- Lister les migrations à reporter.
- Définir un découpage de migrations cohérent et réversible.
- Vérifier les impacts sur tests Prisma et repositories.

**Non-objectifs :**

- Écrire une migration.
- Modifier `schema.prisma`.
- Générer le client Prisma.
- Ajouter des modèles applicatifs.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents`
- `api/src/modules/revision`
- `api/src/modules/activities`
- `api/src/modules/ai`

**Backend :**
Préparer une séquence de migrations, sans l'exécuter.

**Frontend :**
Identifier les DTO qui dépendront des champs nouveaux.

**Genkit :**
Vérifier que les schémas IA peuvent évoluer sans migration inutile.

**GenUI :**
Non concerné.

**Données / Prisma :**
Décider le minimum migratoire pour le premier cut :

- `DocumentChunk`
- lien notion-source
- champs enrichis `KnowledgeUnit`
- artefacts de fiche si inclus dans MVP Cut 1

**API :**
Aucun.

**Tests futurs attendus :**
Revue de schéma documentée.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- La première migration future a un périmètre clair.
- Les migrations non indispensables sont reportées.
- Les dépendances entre modèles sont explicites.

**Critère de stop :**
Ne pas lancer LOT-010 tant que cette revue n'a pas validé le périmètre migratoire.

**Risques :**

- Trop de migrations successives.
- Coupler le MVP à des modèles de session ou open question trop tôt.

### LOT-003 — Golden demo baseline

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Définir le PDF de démo, le scénario et les états attendus avant les fonctionnalités avancées.

**Pourquoi maintenant :**
Le PDF de démonstration pilote les tests manuels, les prompts et les exemples de sources.

**Périmètre inclus :**

- Choisir un PDF texte, court, légalement utilisable.
- Définir la matière de démo.
- Définir les états attendus du document.
- Définir les notions attendues approximatives.
- Définir la checklist de démonstration.

**Non-objectifs :**

- Ajouter un seed automatisé.
- Ajouter OCR ou support image.
- Ajouter des fixtures dans le code.

**Fichiers ou zones probablement concernés :**

- `revision_app/docs/`
- `api/README.md`
- Futurs fichiers de seed dans `api/prisma` si validé plus tard.

**Backend :**
Non concerné.

**Frontend :**
Non concerné.

**Genkit :**
Préparer les attentes de sortie pour tests manuels.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**
Checklist manuelle.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le PDF de démo est identifié.
- Le scénario de démo initial est écrit.
- Les preuves visuelles attendues sont listées.

**Critère de stop :**
Ne pas écrire de seed ou test e2e de démo sans PDF cible.

**Risques :**

- PDF trop long.
- PDF scanné sans texte.
- Contenu difficile à valider.

### LOT-004 — Port d'observabilité Genkit

**Bloc :**
Bloc E — Observabilité et versioning Genkit.

**Objectif :**
Introduire une interface backend pour tracer les générations IA sans coupler les use cases à un provider.

**Pourquoi maintenant :**
Les prochains flows doivent être observables dès leur création.

**Périmètre inclus :**

- Définir un port applicatif d'observabilité IA.
- Définir les champs obligatoires : flow, provider, model, duration, inputSize, status, error, promptVersion, schemaVersion.
- Ajouter un adapter minimal de log structuré si aucune persistance n'est décidée.
- Préparer les tests unitaires du port.

**Non-objectifs :**

- Ajouter une table Prisma si la décision n'est pas prise.
- Changer tous les flows IA avancés.
- Ajouter un dashboard.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/ai/ai.module.ts`

**Backend :**
Créer le port et l'adapter d'observabilité.

**Frontend :**
Non concerné.

**Genkit :**
Préparer l'enveloppe de mesure autour des appels `ai.generate`.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune au départ, sauf décision contraire du LOT-002.

**API :**
Aucun.

**Tests futurs attendus :**

- Test unitaire de l'adapter.
- Test que les champs obligatoires sont acceptés.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le backend a un port d'observabilité IA injectable.
- Les champs obligatoires sont documentés.
- Le port interdit explicitement de logger le texte complet du cours, le prompt complet ou la réponse complète du modèle.
- Aucun flow existant n'est cassé.

**Critère de stop :**
Ne pas instrumenter les flows si le port n'est pas testable sans provider externe.

**Risques :**

- Logger des contenus de cours sensibles.
- Rendre le port trop spécifique à Genkit.

### LOT-005 — Instrumentation des flows Genkit existants

**Bloc :**
Bloc E — Observabilité et versioning Genkit.

**Objectif :**
Tracer l'extraction de notions et la génération QCM existantes.

**Pourquoi maintenant :**
Ces flows sont déjà critiques et servent de base aux futures générations.

**Périmètre inclus :**

- Instrumenter `GenkitDocumentKnowledgeExtractor`.
- Instrumenter `GenkitDiagnosticQuizGenerator`.
- Ajouter `promptVersion` et `schemaVersion` constants.
- Mesurer durée et taille d'input.
- Capturer statut succès/échec.

**Non-objectifs :**

- Changer les prompts métier.
- Changer les modèles Prisma.
- Ajouter des nouveaux flows.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/ai/infrastructure/*.spec.ts`
- `api/src/modules/activities/infrastructure/*.spec.ts`

**Backend :**
Ajouter l'injection du port d'observabilité.

**Frontend :**
Non concerné.

**Genkit :**
Ajouter l'enveloppe de mesure autour de `generate`.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Flow success loggé.
- Flow error loggé.
- Taille input calculée sans stocker le texte complet.

**Commandes de validation futures :**

- `cd api && npm test -- genkit`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les deux flows existants produisent une trace.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.
- Les erreurs restent propagées comme avant.

**Critère de stop :**
Ne pas ajouter de nouveaux flows IA sans observabilité minimale.

**Risques :**

- Exposer des données personnelles dans les logs.
- Modifier involontairement le comportement IA.

### LOT-006 — Inventaire design system et surfaces prioritaires

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Identifier les primitives UI manquantes et les pages à traiter en priorité.

**Pourquoi maintenant :**
L'application a déjà des primitives, mais certaines surfaces restent trop Material-like.

**Périmètre inclus :**

- Auditer `presentation/widgets`.
- Auditer `presentation/pages`.
- Lister les usages restants de `Card`, `LinearProgressIndicator`, `CircularProgressIndicator`, états texte bruts.
- Définir les composants manquants prioritaires.

**Non-objectifs :**

- Refaire toutes les pages.
- Changer la navigation.
- Modifier les flows métier.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/widgets`
- `revision_app/lib/presentation/pages`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`

**Backend :**
Non concerné.

**Frontend :**
Audit des composants et pages.

**Genkit :**
Non concerné.

**GenUI :**
Identifier les composants qui doivent réutiliser les primitives.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**
Tests widget à prévoir par composant modifié.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- La liste des composants manquants est claire.
- Les pages prioritaires sont ordonnées.
- Aucun changement visuel massif n'est lancé.

**Critère de stop :**
Ne pas modifier les pages si les composants réutilisables cibles ne sont pas définis.

**Risques :**

- Recréer des composants redondants.
- Transformer ce lot en refonte complète.

### LOT-007 — Primitives UI minimales pour la démo

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Ajouter les composants UI réutilisables nécessaires au golden path.

**Pourquoi maintenant :**
Les futures pages document, fiche, QCM et correction doivent partager une identité visuelle.

**Périmètre inclus :**

- `DocumentStatusCard`.
- `StudyActionCard`.
- `MasteryRing`.
- `AiSurface`.
- États loading/error/empty premium.
- Tests widget des composants non triviaux.

**Non-objectifs :**

- Refaire toutes les pages existantes.
- Ajouter logique métier.
- Modifier les routes.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/widgets`
- `revision_app/test/presentation/widgets`

**Backend :**
Non concerné.

**Frontend :**
Créer les primitives et tests.

**Genkit :**
Non concerné.

**GenUI :**
Préparer les composants GenUI à réutiliser ces primitives plus tard.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Rendu light/dark.
- Texte long ne déborde pas.
- États erreur et retry.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les composants sont disponibles sous `presentation/widgets`.
- Les pages futures peuvent les réutiliser.
- Les tests widget passent.

**Critère de stop :**
Ne pas refactorer les pages avant que les primitives soient stables.

**Risques :**

- Sur-design de composants avant usage réel.
- Tokens visuels incohérents.

### LOT-008 — Application UI ciblée aux pages existantes

**Bloc :**
Bloc B — Design system minimal et surfaces premium.

**Objectif :**
Remplacer les surfaces brutes dans les pages du golden path sans changer la logique.

**Pourquoi maintenant :**
Les pages existantes doivent être présentables avant d'ajouter plus de contenu IA.

**Périmètre inclus :**

- Page matières.
- Page détail matière.
- Page activités.
- Page aujourd'hui.
- États vides, loading et erreurs.

**Non-objectifs :**

- Modifier les DTO.
- Ajouter détail document.
- Ajouter résumés ou questions ouvertes.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/presentation/pages/subjects`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/lib/presentation/pages/today`
- `revision_app/test/features/**`

**Backend :**
Non concerné.

**Frontend :**
Refactor UI ciblé vers primitives.

**Genkit :**
Non concerné.

**GenUI :**
Ne modifier que le rendu fallback si nécessaire.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Tests widget pages existantes.
- Tests navigation inchangée.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les pages principales utilisent les primitives.
- Les routes publiques restent identiques.
- Aucun comportement métier n'a changé.

**Critère de stop :**
Ne pas continuer si un test de navigation ou page existante casse.

**Risques :**

- Régression visuelle mobile.
- Changement involontaire de comportement.

### LOT-009 — Modèle documentaire cible détaillé

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Définir précisément `DocumentChunk`, `SourceReference` et les liens vers `KnowledgeUnit`.

**Pourquoi maintenant :**
Les sources doivent être stables avant de générer des résumés, fiches et corrections.

**Périmètre inclus :**

- Définir champs de `DocumentChunk`.
- Définir champs de `SourceReference`.
- Définir relations avec `Document`, `KnowledgeUnit`, futurs artefacts.
- Définir règles de chunking.
- Définir stratégie anti-hallucination : l'IA pointe vers des chunks existants.

**Non-objectifs :**

- Écrire migration.
- Modifier worker.
- Modifier prompts.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/domain`
- `api/src/modules/revision/domain`
- `api/src/modules/ai/application`

**Backend :**
Préparer le modèle cible.

**Frontend :**
Identifier les champs nécessaires à l'affichage.

**Genkit :**
Définir que les outputs retournent des `chunkId` ou références, pas des extraits libres seuls.

**GenUI :**
Préparer le futur `SourceExcerptCard`.

**Données / Prisma :**
Planifier un modèle minimal plutôt qu'un modèle documentaire trop générique.

Recommandation MVP :

- `DocumentChunk(id, documentId, index, text, charStart?, charEnd?, pageNumber?)`
- `KnowledgeUnitSource(knowledgeUnitId, chunkId, relevanceScore?)`
- `ArtifactSource(artifactId, chunkId, quoteStart?, quoteEnd?)` seulement si un modèle `GeneratedArtifact` est retenu

À éviter au départ :

- modèle polymorphe trop générique ;
- citations libres non vérifiées ;
- `pageNumber` obligatoire si l'extraction PDF ne le fournit pas proprement ;
- structure pensée pour OCR/image/audio avant que le PDF texte soit robuste.

**API :**
Planifier les DTO de notions sourcées.

**Tests futurs attendus :**
Revue de schéma avant migration.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le modèle documentaire cible est validé.
- Les relations minimales sont connues.
- Les champs trop ambitieux sont reportés.
- Le modèle retenu permet de vérifier qu'une citation vient d'un chunk stocké.

**Critère de stop :**
Ne pas écrire de migration avant validation du modèle.

**Risques :**

- Overengineering.
- Relations trop polymorphes difficiles à maintenir.

### LOT-010 — Persistance minimale des chunks et sources

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Ajouter la persistance minimale nécessaire aux chunks et références sources.

**Pourquoi maintenant :**
Le worker doit pouvoir stocker des références vérifiables avant extraction IA v2.

**Périmètre inclus :**

- Migration Prisma pour `DocumentChunk`.
- Migration Prisma pour `SourceReference` si retenu.
- Mise à jour du client Prisma.
- Repositories minimaux.
- Tests repository.

**Non-objectifs :**

- Générer des résumés.
- Exposer l'UI.
- Ajouter GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/revision/infrastructure`

**Backend :**
Ajouter ports et adapters minimaux.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter les modèles retenus.

**API :**
Aucun public.

**Tests futurs attendus :**

- Repository create/list chunks.
- Ownership par document.
- Suppression cascade si document supprimé.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les chunks sont persistables.
- Les chunks restent liés à un document étudiant.
- Les tests repository passent.

**Critère de stop :**
Ne pas changer le worker si la persistance chunk n'est pas testée.

**Risques :**

- Migration incorrecte.
- Cascade de suppression mal définie.

### LOT-011 — Chunking PDF dans le worker

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Découper le texte extrait en chunks stables avant appel Genkit.

**Pourquoi maintenant :**
Les flows IA doivent recevoir des références de chunks existants.

**Périmètre inclus :**

- Ajouter un service de chunking déterministe.
- Stocker les chunks dans le worker.
- Limiter taille chunk et nombre de chunks.
- Conserver ordre et offsets si possible.
- Tests unitaires du chunker.

**Non-objectifs :**

- Page number parfaite.
- OCR.
- Résumés.
- Correction IA.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`

**Backend :**
Créer et appeler le chunker.

**Frontend :**
Non concerné.

**Genkit :**
Préparer l'input chunké.

**GenUI :**
Non concerné.

**Données / Prisma :**
Utiliser `DocumentChunk`.

**API :**
Aucun public.

**Tests futurs attendus :**

- Texte court.
- Texte long.
- Texte avec paragraphes.
- Limites de taille.
- Worker stocke chunks avant extraction.

**Commandes de validation futures :**

- `cd api && npm test -- document-processing`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Chaque document texte produit des chunks ordonnés.
- Le worker échoue proprement si aucun chunk utile n'est produit.
- Les chunks ne dupliquent pas tout le document dans les logs.

**Critère de stop :**
Ne pas faire extraction v2 si les chunks ne sont pas stables.

**Risques :**

- Découpage trop naïf.
- Explosion du nombre de chunks.
- Perte de contexte.

### LOT-012 — Extraction Genkit v2 basée sur chunks

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Faire produire à Genkit des notions qui référencent des chunks existants.

**Pourquoi maintenant :**
Les notions enrichies doivent être sourcées sans hallucination d'extraits libres.

**Périmètre inclus :**

- Adapter le port `DocumentKnowledgeExtractor`.
- Fournir à Genkit une liste de chunks avec IDs courts.
- Demander des `sourceChunkIds`.
- Ajouter `difficulty`, `order`, `confidence`.
- Valider strictement les IDs retournés.
- Fallback si les IDs sont invalides.

**Non-objectifs :**

- Résumés.
- Fiches.
- Questions ouvertes.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`

**Backend :**
Adapter les DTO et validations.

**Frontend :**
Non concerné.

**Genkit :**
Créer extraction v2 sourcée.

**GenUI :**
Non concerné.

**Données / Prisma :**
Préparer les champs enrichis sur `KnowledgeUnit`.

**API :**
Aucun public.

**Tests futurs attendus :**

- Output avec chunks valides.
- Output avec chunk inconnu rejeté.
- Output sans notions.
- Document trop long.
- Provider Google et Mistral si supporté.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- document-processing`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les notions retournées référencent des chunks existants.
- Les sorties invalides sont rejetées.
- Les erreurs sont observées via le port Genkit.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas persister les notions enrichies si les références chunks ne sont pas validées.

**Risques :**

- Le modèle retourne des IDs invalides.
- Prompt trop complexe.
- Trop de chunks fournis au modèle.

### LOT-013 — Persistance KnowledgeUnit enrichie

**Bloc :**
Bloc C — Fondations documentaires et sources.

**Objectif :**
Persister les notions enrichies et leurs références sources.

**Pourquoi maintenant :**
Le frontend et les futurs artefacts IA doivent lire des notions sourcées.

**Périmètre inclus :**

- Ajouter champs enrichis à `KnowledgeUnit`.
- Persister `difficulty`, `order`, `confidence`.
- Créer les liens sources vers chunks.
- Mettre à jour `markReadyWithKnowledgeUnits`.
- Tests repository et worker.

**Non-objectifs :**

- UI détail document.
- Résumés.
- QCM enrichi.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`

**Backend :**
Mettre à jour domain, repository, worker.

**Frontend :**
Non concerné.

**Genkit :**
Consommer l'output v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Évolutions de `KnowledgeUnit` et liens source.

**API :**
Aucun public.

**Tests futurs attendus :**

- Persistence des champs enrichis.
- Liens sources créés.
- Document READY avec notions.
- Failure si source invalide.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- documents`
- `cd api && npm test -- jobs`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les notions enrichies sont persistées.
- Les références sources restent liées au bon document.
- Le worker conserve les statuts `READY` et `FAILED` correctement.

**Critère de stop :**
Ne pas exposer l'API notions tant que la persistance n'est pas fiable.

**Risques :**

- Incompatibilité avec tests existants.
- Données partielles si transaction mal découpée.

### LOT-014 — API détail document et notions sourcées

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Exposer un contrat backend stable pour lire un document, ses notions et leurs sources.

**Pourquoi maintenant :**
Le frontend doit rendre visible le processing IA avant fiches et QCM avancés.

**Périmètre inclus :**

- Ajouter `GET /documents/:documentId/knowledge-units`.
- Enrichir `GET /documents/:documentId` si nécessaire.
- Retourner sources sans exposer `storagePath`.
- Trier les notions par `order` puis création.
- Tests controller et repository.

**Non-objectifs :**

- Génération de fiche.
- Modification upload.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/application`
- `api/src/modules/documents/infrastructure`
- `api/src/modules/revision/infrastructure`

**Backend :**
Créer use case et DTO.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Lecture des modèles ajoutés.

**API :**

- `GET /documents/:documentId/knowledge-units`
- `GET /documents/:documentId`

**Tests futurs attendus :**

- 401 sans token.
- 404 cross-student.
- Document non READY.
- Réponse triée.
- Sources filtrées.

**Commandes de validation futures :**

- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le frontend peut charger les notions d'un document.
- Aucun chemin interne de stockage n'est exposé.
- L'ownership est vérifié.

**Critère de stop :**
Ne pas construire la page détail document si le contrat API n'est pas stable.

**Risques :**

- Réponse trop volumineuse.
- Fuite de données source.

### LOT-015 — Data layer Flutter pour détail document

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Ajouter les modèles et repository HTTP Flutter pour lire le détail document et les notions.

**Pourquoi maintenant :**
La page UI doit dépendre d'un controller propre, pas de Dio directement.

**Périmètre inclus :**

- Modèle `KnowledgeUnit` côté Flutter.
- Modèle source reference léger.
- Méthodes dans `DocumentsApi` ou repository dédié.
- Controller/notifier Riverpod.
- Tests parsing JSON et erreurs.

**Non-objectifs :**

- Page complète.
- Résumés.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/documents/domain`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/application`
- `revision_app/test/features/documents`

**Backend :**
Non concerné.

**Frontend :**
Ajouter domain, API et état.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Consommer `GET /documents/:documentId/knowledge-units`.

**Tests futurs attendus :**

- JSON valide.
- JSON invalide.
- Token manquant.
- Erreur API.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/documents`

**Critères d'acceptation :**

- Le frontend parse les notions sourcées.
- Les erreurs sont remontées au controller.
- Les tests data passent.

**Critère de stop :**
Ne pas créer l'écran si le modèle front ne correspond pas au contrat API.

**Risques :**

- Divergence DTO backend/frontend.
- Gestion insuffisante des champs optionnels.

### LOT-016 — Page détail document et notions

**Bloc :**
Bloc D — Détail document et notions côté front.

**Objectif :**
Afficher un document READY, ses notions, difficultés et sources.

**Pourquoi maintenant :**
C'est la première preuve utilisateur que l'IA a analysé le cours.

**Périmètre inclus :**

- Route ou navigation vers détail document.
- Page détail document.
- Cartes notions.
- Extraits sources.
- États upload, processing, ready, failed.
- Retry visuel si supporté par API.

**Non-objectifs :**

- Générer une fiche.
- Lancer QCM depuis chaque notion si non prévu.
- Session GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/core/routing/route_paths.dart`
- `revision_app/lib/presentation/pages/subjects`
- `revision_app/lib/presentation/pages/documents`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/documents`
- `revision_app/test/app/router`

**Backend :**
Non concerné.

**Frontend :**
Créer la page et brancher la navigation.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune.

**API :**
Consommer les endpoints du LOT-014.

**Tests futurs attendus :**

- Tap document ouvre détail.
- Document READY affiche notions.
- Document FAILED affiche erreur.
- Document PROCESSING affiche attente.
- Cross-platform layout raisonnable.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Un étudiant voit les notions extraites d'un document.
- Les sources sont affichées quand disponibles.
- Les états sont lisibles.

**Critère de stop :**
Ne pas lancer les fiches si l'utilisateur ne peut pas inspecter les notions sources.

**Risques :**

- Page trop chargée.
- Navigation profonde mal intégrée aux onglets.

### LOT-017 — Contrat artefacts générés

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Définir comment stocker et exposer les artefacts IA générés.

**Pourquoi maintenant :**
Résumé, fiche, correction et blocs GenUI ont des besoins communs de versioning, statut et sources.

**Périmètre inclus :**

- Choisir entre modèles spécialisés et `GeneratedArtifact`.
- Définir statuts : pending, processing, ready, failed si asynchrone.
- Définir métadonnées : flow, provider, model, promptVersion, schemaVersion.
- Définir relation aux sources.

**Non-objectifs :**

- Écrire migration.
- Implémenter génération.
- Ajouter UI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/ai`
- `api/src/modules/documents`
- `api/src/modules/activities`

**Backend :**
Architecture du contrat.

**Frontend :**
Identifier les DTO à afficher.

**Genkit :**
Définir métadonnées communes.

**GenUI :**
Décider si les blocs GenUI sont persistés comme artefacts.

**Données / Prisma :**
Options :

- `Summary` + `RevisionSheet` + `OpenAnswerEvaluation`.
- `GeneratedArtifact` transversal avec `type`.
- `AiGenerationJob` séparé pour statut et observabilité.

**API :**
Aucun public.

**Tests futurs attendus :**
Revue de contrat.

**Commandes de validation futures :**
Aucune commande obligatoire.

**Critères d'acceptation :**

- Le stockage des artefacts est décidé.
- Les lots résumé et fiche peuvent avancer sans ambiguïté.

**Critère de stop :**
Ne pas créer `Summary` sans décider s'il dépend d'un artifact commun.

**Risques :**

- Modèle générique trop vague.
- Modèles spécialisés trop répétitifs.

### LOT-018 — Persistance Summary et RevisionSheet

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Ajouter les modèles et repositories nécessaires aux fiches.

**Pourquoi maintenant :**
La génération doit persister des objets métier relisibles après redémarrage.

**Périmètre inclus :**

- Modèles `Summary` et `RevisionSheet` ou artefact retenu.
- Repository.
- Use cases `GetSummary` et stockage minimal.
- Ownership par `studentId`.

**Non-objectifs :**

- Flow Genkit.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/summaries` ou `api/src/modules/documents`
- `api/src/modules/ai`

**Backend :**
Créer module/use cases/repository.

**Frontend :**
Non concerné.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter les modèles retenus.

**API :**
Aucun ou endpoints de lecture si séparés.

**Tests futurs attendus :**

- Création.
- Lecture.
- Ownership.
- Source references liées.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- summaries`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les fiches sont persistables.
- Les sources sont associables.
- Aucun cross-student leak.

**Critère de stop :**
Ne pas appeler Genkit pour résumés si la persistance n'est pas prête.

**Risques :**

- Nouveau module mal intégré à `AppModule`.
- Duplication entre Summary et RevisionSheet.

### LOT-019 — Flow Genkit résumé et fiche

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Créer des flows Genkit typés pour résumé et fiche, basés sur chunks et notions.

**Pourquoi maintenant :**
Le premier artefact IA visible doit être fiable et sourcé.

**Périmètre inclus :**

- `generateSummaryFlow`.
- `generateRevisionSheetFlow`.
- Schémas Zod stricts.
- Inputs avec chunks sélectionnés.
- Outputs avec références sources.
- Observabilité.

**Non-objectifs :**

- UI.
- GenUI.
- Question ouverte.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/summaries`

**Backend :**
Ajouter ports et adapters Genkit.

**Frontend :**
Non concerné.

**Genkit :**
Créer flows et tests.

**GenUI :**
Non concerné.

**Données / Prisma :**
Consommer les sources et produire artefacts.

**API :**
Aucun public dans ce lot si isolé.

**Tests futurs attendus :**

- Output valide.
- Source inconnue rejetée.
- Document sans notion refusé.
- Erreur provider gérée.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- summaries`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Les flows retournent des DTO validés.
- Les sources pointent vers des chunks existants.
- Les erreurs sont observées.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas exposer endpoint génération si le flow peut halluciner des sources non validées.

**Risques :**

- Prompt trop long.
- Sortie trop verbeuse.
- Coût IA.

### LOT-020 — API résumés et fiches

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Exposer la génération et la lecture des fiches depuis un document READY.

**Pourquoi maintenant :**
Le frontend a besoin d'un contrat stable pour afficher le premier artefact IA.

**Périmètre inclus :**

- `POST /documents/:documentId/summaries`.
- `GET /documents/:documentId/summaries`.
- Endpoint fiche si séparé.
- Validation document READY.
- Rate limit ou garde-fou minimal si disponible.
- Tests controller.

**Non-objectifs :**

- Génération asynchrone complexe si non décidée.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/documents/interfaces`
- `api/src/modules/summaries`
- `api/src/modules/ai`

**Backend :**
Brancher use case, repository et flow.

**Frontend :**
Non concerné.

**Genkit :**
Appelé via use case.

**GenUI :**
Non concerné.

**Données / Prisma :**
Persisted summaries.

**API :**

- `POST /documents/:documentId/summaries`
- `GET /documents/:documentId/summaries`

**Tests futurs attendus :**

- 409 si document non READY.
- 404 cross-student.
- 422 output invalide.
- Résumé persisté.

**Commandes de validation futures :**

- `cd api && npm test -- summaries`
- `cd api && npm test -- documents`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Un résumé peut être généré depuis un document READY.
- Le résumé est relisible.
- Les sources sont présentes si disponibles.

**Critère de stop :**
Ne pas construire l'écran fiche si les endpoints ne protègent pas l'ownership.

**Risques :**

- Endpoint trop lent si génération synchrone.
- Générations répétées coûteuses.

### LOT-021 — UI résumé et fiche

**Bloc :**
Bloc F — Résumés et fiches.

**Objectif :**
Permettre à l'utilisateur de générer et lire une fiche sourcée.

**Pourquoi maintenant :**
C'est le premier usage IA visible après l'import.

**Périmètre inclus :**

- Data layer Flutter pour summaries.
- CTA générer une fiche.
- Affichage résumé express, points clés, pièges.
- Affichage sources.
- États loading/error/empty.

**Non-objectifs :**

- GenUI dynamique.
- Question ouverte.
- Session coach.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/documents`
- `revision_app/lib/presentation/pages/documents`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/documents`

**Backend :**
Non concerné.

**Frontend :**
Créer repository, controller et UI.

**Genkit :**
Non concerné côté front.

**GenUI :**
Non concerné dans ce lot.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints LOT-020.

**Tests futurs attendus :**

- CTA appelle endpoint.
- Fiche existante affichée.
- Erreur génération affichée.
- Sources affichées.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Depuis un document READY, l'utilisateur lit une fiche.
- La fiche reste visible après reload.
- Les erreurs sont compréhensibles.

**Critère de stop :**
Ne pas passer au QCM enrichi si le premier artefact IA n'est pas démontrable.

**Risques :**

- UI trop dense sur mobile.
- Confusion entre notion et fiche.

### LOT-022 — Contrat QCM v2

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Définir le contrat QCM enrichi sans fuite de correction avant submit.

**Pourquoi maintenant :**
Le QCM existe déjà, il faut l'améliorer sans casser l'activité actuelle.

**Périmètre inclus :**

- DTO QCM public sans `correctChoiceId`.
- DTO correction après submit.
- Nombre de questions configurable.
- Difficulty.
- Feedback par question.
- Compatibilité temporaire avec `/activities/next`.

**Non-objectifs :**

- Question ouverte.
- GenUI.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/activities/application`
- `api/src/modules/activities/interfaces`
- `api/src/modules/activities/domain`
- `revision_app/lib/features/activities/domain`

**Backend :**
Définir use cases et DTO.

**Frontend :**
Préparer modèles.

**Genkit :**
Adapter output cible.

**GenUI :**
Préparer composant futur.

**Données / Prisma :**
Préparer extensions `Question` et `ActivityResult`.

**API :**

- `POST /activities/diagnostic-quiz`
- `POST /activities/:sessionId/result`

**Tests futurs attendus :**
Contrat de non-fuite de correction.

**Commandes de validation futures :**

- `cd api && npm test -- activities`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- Le contrat public ne révèle pas la bonne réponse avant submit.
- La correction après submit est structurée.

**Critère de stop :**
Ne pas changer le flow Genkit QCM sans contrat clair.

**Risques :**

- Régression de l'activité existante.
- Incompatibilité DTO front/back.

### LOT-023 — Genkit QCM enrichi

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Améliorer la génération QCM avec feedback et grounding sur sources.

**Pourquoi maintenant :**
Le contrat QCM v2 exige des explications et distracteurs plus fiables.

**Périmètre inclus :**

- Schéma QCM v2.
- Prompt basé sur notion et chunks.
- Feedback par choix si retenu.
- Difficulté.
- Observabilité.
- Validation de distracteurs.

**Non-objectifs :**

- UI.
- Question ouverte.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/*.spec.ts`

**Backend :**
Adapter le generator.

**Frontend :**
Non concerné.

**Genkit :**
Flow QCM v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Aucune directe, sauf champs du LOT-024.

**API :**
Aucun nouveau.

**Tests futurs attendus :**

- Une seule bonne réponse.
- Choix uniques.
- Feedback présent.
- Sources valides.

**Commandes de validation futures :**

- `cd api && npm test -- genkit-diagnostic-quiz`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le flow produit un QCM v2 valide.
- Le QCM reste basé sur le cours.
- Les outputs invalides sont rejetés.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas persister les corrections si le flow ne garantit pas les invariants.

**Risques :**

- Questions hors sujet.
- Distracteurs absurdes.

### LOT-024 — Persistance et soumission QCM enrichies

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Persister les métadonnées QCM v2 et renvoyer une correction détaillée après submit.

**Pourquoi maintenant :**
La maîtrise et la correction doivent être fiables côté backend avant UI avancée.

**Périmètre inclus :**

- Étendre `Question` et `ActivityResult`.
- Ajouter feedback par question.
- Ajouter score par notion.
- Ajouter `MasteryEvent` si retenu.
- Tests double submit, réponses inconnues, mastery.

**Non-objectifs :**

- UI correction.
- GenUI.
- Question ouverte.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/activities/application`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/revision`

**Backend :**
Mettre à jour repository et use cases.

**Frontend :**
Non concerné.

**Genkit :**
Consommer output QCM v2.

**GenUI :**
Non concerné.

**Données / Prisma :**
Extensions activité/résultat/maîtrise.

**API :**
Réponse enrichie de `POST /activities/:sessionId/result`.

**Tests futurs attendus :**

- Correction détaillée.
- Mastery update.
- Double submit 409.
- Réponse inconnue 400.
- Cross-student interdit.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- activities`
- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- La correction détaillée est renvoyée après submit.
- La maîtrise est mise à jour.
- Les protections existantes restent actives.

**Critère de stop :**
Ne pas refaire l'UI QCM tant que la correction backend n'est pas stable.

**Risques :**

- Calcul mastery opaque.
- Migration qui casse les sessions existantes.

### LOT-025 — UI QCM enrichi

**Bloc :**
Bloc G — QCM enrichi.

**Objectif :**
Afficher un QCM enrichi avec correction détaillée et feedback.

**Pourquoi maintenant :**
L'utilisateur doit comprendre pourquoi il a réussi ou échoué.

**Périmètre inclus :**

- Adapter `HttpActivitiesApi`.
- Adapter modèles domain Flutter.
- Refaire `DiagnosticQuizPage`.
- Afficher correction par question.
- Afficher score et feedback.

**Non-objectifs :**

- GenUI.
- Question ouverte.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Mettre à jour data/domain/UI.

**Genkit :**
Non concerné.

**GenUI :**
Non concerné, fallback natif seulement.

**Données / Prisma :**
Aucune.

**API :**
Consommer les contrats LOT-022/024.

**Tests futurs attendus :**

- Parsing correction.
- Correction affichée après submit.
- Pas de correction avant submit.
- État erreur submit.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- L'utilisateur voit la correction détaillée.
- Les réponses correctes ne sont pas visibles avant validation.
- Le score est clair.

**Critère de stop :**
Ne pas ajouter GenUI QCM tant que le fallback natif n'est pas stable.

**Risques :**

- Régression mobile.
- UI trop longue pour plusieurs questions.

### LOT-026 — Contrat question ouverte

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Ajouter les modèles et contrats pour une question ouverte corrigée.

**Pourquoi maintenant :**
C'est la feature démo forte, mais elle doit reposer sur sources et QCM/mastery stabilisés.

**Périmètre inclus :**

- Nouveau type activité `OPEN_QUESTION`.
- Modèle question ouverte.
- Modèle évaluation.
- Endpoints de démarrage et soumission.
- Ownership et statuts.

**Non-objectifs :**

- Flow Genkit complet.
- UI.
- GenUI.

**Fichiers ou zones probablement concernés :**

- `api/prisma/schema.prisma`
- `api/src/modules/activities`
- `api/src/modules/revision`

**Backend :**
Ajouter domain, use cases, repository.

**Frontend :**
Préparer DTO plus tard.

**Genkit :**
Définir interfaces seulement.

**GenUI :**
Non concerné.

**Données / Prisma :**
Ajouter modèles retenus.

**API :**

- `POST /activities/open-question`
- `POST /activities/:sessionId/open-answer`

**Tests futurs attendus :**

- Session créée.
- Réponse vide refusée.
- Double correction bloquée.
- Cross-student interdit.

**Commandes de validation futures :**

- `cd api && npm run prisma:generate`
- `cd api && npm test -- activities`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le backend peut représenter une question ouverte.
- Les endpoints sont protégés.
- Aucun flow IA non validé n'est requis pour les tests de contrat.

**Critère de stop :**
Ne pas brancher l'évaluation IA tant que les statuts et ownership ne sont pas testés.

**Risques :**

- Mélange trop fort avec QCM.
- Modèle d'activité trop rigide.

### LOT-027 — Genkit question ouverte et correction

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Créer les flows de génération et correction de question ouverte.

**Pourquoi maintenant :**
Les contrats backend sont prêts et les sources sont vérifiables.

**Périmètre inclus :**

- `generateOpenQuestionFlow`.
- `evaluateOpenAnswerFlow`.
- Schémas stricts.
- Barème.
- Points présents/manquants.
- Erreurs.
- Réponse modèle.
- Conseils.
- Sources.
- Observabilité.

**Non-objectifs :**

- UI.
- GenUI.
- Session coach.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai/application`
- `api/src/modules/ai/infrastructure`
- `api/src/modules/activities/application`
- `api/src/modules/activities/infrastructure`

**Backend :**
Brancher flows aux use cases.

**Frontend :**
Non concerné.

**Genkit :**
Créer et tester les flows.

**GenUI :**
Non concerné.

**Données / Prisma :**
Persisted evaluation.

**API :**
Utiliser endpoints LOT-026.

**Tests futurs attendus :**

- Bonne réponse.
- Réponse partielle.
- Réponse hors sujet.
- Sources invalides rejetées.
- Erreur IA explicite.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- activities`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- L'évaluation est structurée.
- Le score est séparé du feedback.
- Les sources sont référencées.
- Les traces ne contiennent pas le texte complet du cours, le prompt complet ou la completion complète.

**Critère de stop :**
Ne pas créer l'UI si la correction n'est pas stable et testée.

**Risques :**

- Correction trop vague.
- Coût IA.
- Hallucination de points non présents dans le cours.

### LOT-028 — UI question ouverte corrigée

**Bloc :**
Bloc H — Question ouverte corrigée.

**Objectif :**
Permettre à l'étudiant de répondre à une question ouverte et lire la correction.

**Pourquoi maintenant :**
Le backend peut générer et corriger l'activité.

**Périmètre inclus :**

- Modèles Flutter.
- Méthodes `HttpActivitiesApi`.
- Page ou mode d'activité question ouverte.
- Champ réponse long.
- État correction en cours.
- Affichage score, points manquants, réponse modèle.

**Non-objectifs :**

- GenUI.
- Coach.
- Plan du jour multi-actions.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities`
- `revision_app/lib/presentation/pages/activities`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Ajouter data/domain/UI.

**Genkit :**
Non concerné côté front.

**GenUI :**
Non concerné dans ce lot.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints question ouverte.

**Tests futurs attendus :**

- Réponse vide non soumise.
- Correction affichée.
- Erreur correction affichée.
- Champ long utilisable.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- L'étudiant reçoit une correction argumentée.
- Le fallback natif est complet.
- Les erreurs sont lisibles.

**Critère de stop :**
Ne pas construire GenUI question ouverte avant fallback natif stable.

**Risques :**

- UX de rédaction pénible sur mobile.
- Correction trop longue à afficher.

### LOT-029 — GenUI composants lecture sourcée

**Bloc :**
Bloc I — GenUI catalog isolé.

**Objectif :**
Ajouter des composants GenUI isolés pour résumé et sources.

**Pourquoi maintenant :**
GenUI doit être validé composant par composant avant la session.

**Périmètre inclus :**

- `SummaryCard`.
- `KeyPointsList`.
- `SourceExcerptCard`.
- Schémas JSON.
- Validateur.
- Fallback natif.
- Tests catalogue.

**Non-objectifs :**

- Session coach.
- Génération libre de widgets.
- QCM GenUI.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Étendre catalogue et validators.

**Genkit :**
Non concerné.

**GenUI :**
Ajouter composants lecture sourcée.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Payload valide rendu.
- Payload invalide rejeté.
- Fallback affiché.
- Longueur texte limitée.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities/revision_activity_catalog_test.dart`

**Critères d'acceptation :**

- Les composants sont bornés.
- Le catalogue refuse les payloads inconnus.
- Les composants réutilisent les primitives UI.

**Critère de stop :**
Ne pas ajouter la session GenUI tant que les composants source/résumé ne sont pas testés.

**Risques :**

- Schémas trop permissifs.
- Retour à des widgets Material bruts.

### LOT-030 — GenUI composants activité et correction

**Bloc :**
Bloc I — GenUI catalog isolé.

**Objectif :**
Ajouter les composants GenUI pour QCM, question ouverte et correction.

**Pourquoi maintenant :**
Les activités natives sont stables et peuvent servir de fallback.

**Périmètre inclus :**

- `McqQuestionCard`.
- `McqCorrectionPanel`.
- `ActivityResultCard`.
- `OpenQuestionCard`.
- `CorrectionPanel`.
- `RubricCard`.
- Tests validators.

**Non-objectifs :**

- Coach complet.
- Widgets arbitraires.
- Modification de scoring.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/widgets`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Étendre catalogue et validators.

**Genkit :**
Non concerné.

**GenUI :**
Composants activité bornés.

**Données / Prisma :**
Aucune.

**API :**
Aucun.

**Tests futurs attendus :**

- Chaque composant accepte payload valide.
- Chaque composant rejette payload invalide.
- Fallback natif conservé.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/activities`

**Critères d'acceptation :**

- GenUI peut rendre une activité sans casser le fallback.
- Aucun composant inconnu n'est rendu.

**Critère de stop :**
Ne pas construire la session coach si les composants activité ne sont pas isolés et testés.

**Risques :**

- Couplage fort au format backend.
- Validation incomplète.

### LOT-031 — Session de révision IA minimale

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Créer une session IA minimale qui orchestre des actions déjà existantes.

**Pourquoi maintenant :**
Les briques isolées existent : fiches, QCM, question ouverte, GenUI components.

**Périmètre inclus :**

- Modèle `RevisionSession`.
- Endpoint `POST /revision-sessions`.
- Endpoint message si nécessaire.
- Première action déterministe, sans coach libre.
- Historique minimal.

**Non-objectifs :**

- Orchestration LLM complète.
- Chatbot libre.
- Plan du jour avancé.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/revision`
- `api/src/modules/activities`
- `api/prisma/schema.prisma`

**Backend :**
Créer session et action initiale.

**Frontend :**
Non concerné dans ce lot.

**Genkit :**
Non concerné ou optionnel.

**GenUI :**
Payloads issus du catalogue existant seulement.

**Données / Prisma :**
Ajouter session si retenu.

**API :**

- `POST /revision-sessions`
- `POST /revision-sessions/:sessionId/message` si nécessaire.

**Tests futurs attendus :**

- Session appartient au student.
- Action initiale valide.
- Payload GenUI validé côté backend si stocké.

**Commandes de validation futures :**

- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Une session démarre et retourne une action existante.
- Aucune génération libre de widget.

**Critère de stop :**
Ne pas ajouter coach IA tant que la session déterministe ne fonctionne pas.

**Risques :**

- Modèle de session prématuré.
- Confusion entre session et activité.

### LOT-032 — Écran Révision IA minimal

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Afficher une session IA simple avec les composants GenUI validés.

**Pourquoi maintenant :**
Le backend fournit une session contrôlée.

**Périmètre inclus :**

- Route ou onglet si validé.
- Écran session.
- Chargement session.
- Rendu de blocs catalogue.
- Fallback bloc invalide.
- Historique simple.

**Non-objectifs :**

- Chat libre.
- Orchestration avancée.
- Nouvelle IA côté front.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/features/activities/genui`
- `revision_app/lib/presentation/pages`
- `revision_app/test/app/router`
- `revision_app/test/features/activities`

**Backend :**
Non concerné.

**Frontend :**
Créer data layer et page session.

**Genkit :**
Non concerné.

**GenUI :**
Rendre uniquement composants validés.

**Données / Prisma :**
Aucune.

**API :**
Consommer endpoints LOT-031.

**Tests futurs attendus :**

- Session démarre.
- Bloc valide rendu.
- Bloc invalide fallback.
- Route protégée par auth.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- La session simple est démontrable.
- Le fallback fonctionne.
- Aucun widget arbitraire.

**Critère de stop :**
Ne pas ajouter orchestration IA si les blocs de session ne sont pas robustes.

**Risques :**

- Trop ressembler à un chatbot.
- Routes trop tôt modifiées.

### LOT-033 — Orchestration coach Genkit

**Bloc :**
Bloc J — Session de révision IA.

**Objectif :**
Ajouter un flow Genkit qui choisit la prochaine action parmi une enum bornée.

**Pourquoi maintenant :**
La session déterministe fonctionne et les composants sont validés.

**Périmètre inclus :**

- `generateCoachNextActionFlow`.
- Input contexte étudiant limité.
- Output intention enum.
- Le backend transforme l'intention en action validée.
- Fallback déterministe.

**Non-objectifs :**

- Widget libre.
- Classement TodayPlan par IA.
- Chat généraliste.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/ai`
- `api/src/modules/revision`
- `api/src/modules/activities`

**Backend :**
Brancher orchestration dans session.

**Frontend :**
Non concerné.

**Genkit :**
Créer flow coach.

**GenUI :**
Consommer uniquement composants existants.

**Données / Prisma :**
Éventuel stockage intention/action.

**API :**
Même endpoints session.

**Tests futurs attendus :**

- Intention valide.
- Intention inconnue rejetée.
- Fallback déterministe.
- Observabilité.

**Commandes de validation futures :**

- `cd api && npm test -- ai`
- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- Le coach propose une action valide.
- L'IA ne contrôle pas directement l'UI.
- Le fallback fonctionne sans provider.

**Critère de stop :**
Ne pas utiliser ce flow dans la démo si le fallback déterministe n'est pas prêt.

**Risques :**

- Orchestration trop vague.
- Perte de testabilité.

### LOT-034 — TodayPlan multi-actions backend

**Bloc :**
Bloc K — Plan du jour avancé.

**Objectif :**
Étendre le plan du jour à plusieurs types d'actions déterministes.

**Pourquoi maintenant :**
Les actions existent déjà : fiche, QCM, question ouverte, review faible.

**Périmètre inclus :**

- Ajouter types d'action.
- Ranking déterministe.
- Prendre en compte priority, mastery, lastPracticedAt, objectif.
- Raisons pédagogiques.
- Tests domain.

**Non-objectifs :**

- Ranking par IA.
- UI avancée.
- Notifications.

**Fichiers ou zones probablement concernés :**

- `api/src/modules/revision/domain/adaptive-plan.service.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`
- `api/src/modules/revision/interfaces/today.controller.ts`
- `api/src/modules/revision/**/*.spec.ts`

**Backend :**
Étendre domain et DTO.

**Frontend :**
Non concerné.

**Genkit :**
Optionnel seulement pour phrase personnalisée, pas ranking.

**GenUI :**
Non concerné.

**Données / Prisma :**
Lire `MasteryEvent` ou résultats enrichis si ajoutés.

**API :**
Étendre `GET /today`.

**Tests futurs attendus :**

- Plan stable.
- Notions faibles prioritaires.
- Plusieurs actions.
- Cross-student impossible.

**Commandes de validation futures :**

- `cd api && npm test -- revision`
- `cd api && npm run lint:check`

**Critères d'acceptation :**

- `GET /today` retourne plusieurs types d'actions.
- Les raisons sont explicites.
- Le résultat est déterministe.

**Critère de stop :**
Ne pas faire UI Today v2 si le ranking backend n'est pas stable.

**Risques :**

- Heuristique trop complexe.
- Raisons peu pédagogiques.

### LOT-035 — TodayPage v2 frontend

**Bloc :**
Bloc K — Plan du jour avancé.

**Objectif :**
Afficher les actions du plan du jour et permettre de les lancer.

**Pourquoi maintenant :**
Le backend expose des actions réellement exploitables.

**Périmètre inclus :**

- Adapter `TodayPlan` Flutter.
- Cartes d'actions.
- Boutons démarrer.
- État vide sans document READY.
- Progression quotidienne simple.

**Non-objectifs :**

- Notifications.
- Calendrier complet.
- Ranking côté front.

**Fichiers ou zones probablement concernés :**

- `revision_app/lib/features/today`
- `revision_app/lib/presentation/pages/today/today_page.dart`
- `revision_app/test/features/today`

**Backend :**
Non concerné.

**Frontend :**
Data/domain/UI Today v2.

**Genkit :**
Non concerné.

**GenUI :**
Optionnel uniquement pour cartes validées, pas nécessaire au fallback.

**Données / Prisma :**
Aucune.

**API :**
Consommer `GET /today` enrichi.

**Tests futurs attendus :**

- Plusieurs actions affichées.
- Démarrage QCM.
- Démarrage question ouverte.
- État vide.
- Erreur API.

**Commandes de validation futures :**

- `cd revision_app && dart analyze lib test`
- `cd revision_app && flutter test test/features/today`

**Critères d'acceptation :**

- L'utilisateur sait quoi faire aujourd'hui.
- Il peut lancer une action depuis la page.
- Le front ne recalcule pas le ranking.

**Critère de stop :**
Ne pas utiliser Today comme démo si les actions ne lancent rien.

**Risques :**

- UX confuse avec trop d'actions.
- Divergence des types d'action front/back.

### LOT-036 — Seed et fixtures de démo

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Rendre la démo reproductible avec des données connues.

**Pourquoi maintenant :**
Le golden path est complet et doit être rejouable.

**Périmètre inclus :**

- Seed matière.
- Seed document ou script d'import contrôlé.
- Seed mastery si utile.
- Données de test non sensibles.
- Documentation d'utilisation.

**Non-objectifs :**

- Seeder production.
- Contourner auth en production.
- Ajouter offline-first.

**Fichiers ou zones probablement concernés :**

- `api/prisma`
- `api/README.md`
- `revision_app/docs`

**Backend :**
Script ou documentation seed.

**Frontend :**
Non concerné sauf instructions demo.

**Genkit :**
Définir si les artefacts sont pré-générés ou générés pendant la démo.

**GenUI :**
Non concerné.

**Données / Prisma :**
Seed contrôlé.

**API :**
Aucun nouveau.

**Tests futurs attendus :**
Validation manuelle du seed.

**Commandes de validation futures :**
À confirmer après choix du mécanisme de seed.

**Critères d'acceptation :**

- Un développeur peut préparer la démo en suivant la documentation.
- Les données ne contiennent pas de secret.

**Critère de stop :**
Ne pas préparer captures ou scripts de présentation si le seed n'est pas reproductible.

**Risques :**

- Seed couplé à un utilisateur Firebase réel.
- Données de démo fragiles.

### LOT-037 — Tests e2e critiques et smoke checks

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Protéger le parcours principal par tests et smoke checks.

**Pourquoi maintenant :**
Le produit a assez de briques pour mériter une validation bout en bout.

**Périmètre inclus :**

- E2E backend sur endpoints critiques.
- Tests worker document.
- Smoke API `/health`.
- Smoke upload metadata ou upload fichier selon environnement.
- Checklist manuelle front.

**Non-objectifs :**

- Couvrir tous les edge cases.
- Remplacer les tests unitaires.
- Déployer automatiquement.

**Fichiers ou zones probablement concernés :**

- `api/test`
- `api/src/**/*.spec.ts`
- `revision_app/test`
- `revision_app/docs`

**Backend :**
Ajouter e2e et smoke.

**Frontend :**
Checklist ou tests widget complémentaires.

**Genkit :**
Mocks ou fakes pour éviter coûts en CI.

**GenUI :**
Tests payload/fallback.

**Données / Prisma :**
DB test.

**API :**
Parcours complet.

**Tests futurs attendus :**

- Auth mock.
- Création matière.
- Upload document.
- Processing contrôlé.
- Activité.
- Today.

**Commandes de validation futures :**

- `cd api && npm test`
- `cd api && npm run test:e2e`
- `cd api && npm run build`
- `cd revision_app && flutter test`

**Critères d'acceptation :**

- Les tests critiques passent localement.
- Les flows IA peuvent être mockés.
- La checklist manuelle est claire.

**Critère de stop :**
Ne pas déclarer la démo stable sans smoke checks.

**Risques :**

- Tests e2e lents.
- Dépendance à Firebase réelle.

### LOT-038 — Runbook démo et déploiement

**Bloc :**
Bloc L — Golden demo, qualité et déploiement.

**Objectif :**
Documenter comment lancer, vérifier et présenter Revision App.

**Pourquoi maintenant :**
La valeur de la démo dépend autant de sa reproductibilité que du code.

**Périmètre inclus :**

- Variables d'environnement.
- Lancement API.
- Lancement worker.
- Redis/Postgres.
- Provider IA.
- Démarrage Flutter.
- Scénario de présentation.
- Troubleshooting erreurs IA et worker.

**Non-objectifs :**

- Ajouter infra nouvelle.
- Automatiser tous les déploiements.
- Modifier Dokploy.

**Fichiers ou zones probablement concernés :**

- `api/README.md`
- `revision_app/README.md`
- `revision_app/docs`

**Backend :**
Documentation runbook.

**Frontend :**
Documentation runbook.

**Genkit :**
Documenter provider, modèle, clés, timeouts.

**GenUI :**
Documenter catalogue et fallback.

**Données / Prisma :**
Documenter migrations et seed.

**API :**
Documenter smoke checks.

**Tests futurs attendus :**
Validation manuelle du runbook.

**Commandes de validation futures :**

- `cd api && npm run build`
- `cd revision_app && flutter build web`

**Critères d'acceptation :**

- Un développeur peut rejouer la démo.
- Les erreurs courantes sont documentées.
- Les commandes ne supposent pas de scripts inexistants.

**Critère de stop :**
Ne pas faire de présentation externe si le runbook n'a pas été rejoué.

**Risques :**

- Documentation obsolète.
- Variables sensibles exposées.

## 6. Ordre recommandé des 10 premiers lots

| Ordre | Lot | Justification |
| --- | --- | --- |
| 1 | LOT-001 | Il verrouille la vérité projet : routes, modèles, flows, tests. |
| 2 | LOT-001B | Il tranche le chemin officiel upload/lecture document avant de toucher au worker. |
| 3 | LOT-002 | Il tranche les décisions qui bloquent chunks, sources et artefacts IA. |
| 4 | LOT-002B | Il évite une rafale de migrations Prisma mal ordonnées. |
| 5 | LOT-003 | Il fixe le PDF et le scénario qui guideront les validations. |
| 6 | LOT-004 | L'observabilité Genkit doit exister avant les nouveaux flows. |
| 7 | LOT-005 | Les flows existants deviennent diagnostiquables avant enrichissement. |
| 8 | LOT-006 | Le design system doit être cadré avant d'ajouter de nouvelles pages. |
| 9 | LOT-009 | Le modèle documentaire cible doit précéder toute migration. |
| 10 | LOT-010 | La persistance chunks/sources débloque le worker et l'extraction v2. |

LOT-007 et LOT-008 peuvent être faits juste après LOT-006 si l'équipe veut améliorer vite le rendu visuel existant. Ils ne doivent pas bloquer les fondations documentaires si la priorité est l'IA sourcée.

### MVP Cut 1 — Démo minimale Genkit + GenUI

Objectif : obtenir rapidement une démo crédible sans attendre QCM v2, question ouverte complète, session coach et TodayPlan avancé.

À faire absolument :

- LOT-001 — Audit des contrats actuels.
- LOT-001B — Décision stratégie upload et lecture document.
- LOT-002 — Décisions fondations IA et documentaire.
- LOT-002B — Revue de schéma avant migrations.
- LOT-003 — Golden demo baseline.
- LOT-004 — Port d'observabilité Genkit.
- LOT-005 — Instrumentation des flows Genkit existants.
- LOT-009 — Modèle documentaire cible détaillé.
- LOT-010 — Persistance minimale des chunks et sources.
- LOT-011 — Chunking PDF dans le worker.
- LOT-012 — Extraction Genkit v2 basée sur chunks.
- LOT-013 — Persistance KnowledgeUnit enrichie.
- LOT-014 — API détail document et notions sourcées.
- LOT-015 — Data layer Flutter pour détail document.
- LOT-016 — Page détail document et notions.
- LOT-017 — Contrat artefacts générés.
- LOT-018 — Persistance Summary et RevisionSheet.
- LOT-019 — Flow Genkit résumé et fiche.
- LOT-020 — API résumés et fiches.
- LOT-021 — UI résumé et fiche.
- LOT-029 — GenUI composants lecture sourcée.

À reporter après ce cut :

- QCM enrichi complet.
- Question ouverte complète.
- Session coach complète.
- TodayPlan multi-actions.
- OCR/image/audio.

Ce cut montre déjà la valeur technique essentielle : PDF texte importé, chunks vérifiables, notions sourcées, fiche générée par Genkit, rendu GenUI borné pour fiche/source.

## 7. Matrice des dépendances

| Lot | Dépend de | Débloque | Risque principal | Validation clé |
| --- | --- | --- | --- | --- |
| LOT-001 | Aucun | LOT-001B, LOT-002, LOT-003 | Inventaire incomplet | Contrats réels listés |
| LOT-001B | LOT-001 | LOT-002, LOT-010, LOT-011 | Chemins upload divergents | Chemin officiel écrit |
| LOT-002 | LOT-001B | LOT-002B, LOT-009, LOT-017 | Décision trop générique | Options et recommandation écrites |
| LOT-002B | LOT-002 | LOT-010, LOT-018, LOT-024, LOT-026 | Trop de migrations successives | Périmètre migratoire validé |
| LOT-003 | LOT-001 | LOT-036, LOT-037 | PDF non représentatif | PDF texte validé |
| LOT-004 | LOT-002 | LOT-005 | Logs sensibles | Port testable sans provider |
| LOT-005 | LOT-004 | LOT-012, LOT-019, LOT-023 | Changement comportement IA | Logs sans texte complet |
| LOT-006 | LOT-001 | LOT-007 | Audit trop large | Composants manquants listés |
| LOT-007 | LOT-006 | LOT-008, LOT-016, LOT-021 | Sur-design | Tests widget |
| LOT-008 | LOT-007 | Démo visuelle | Régression UI | Tests pages existantes |
| LOT-009 | LOT-002B | LOT-010 | Overengineering | Modèle cible validé |
| LOT-010 | LOT-001B, LOT-002B, LOT-009 | LOT-011, LOT-013 | Migration fragile | Tests repository |
| LOT-011 | LOT-001B, LOT-010 | LOT-012 | Chunking pauvre | Tests chunker |
| LOT-012 | LOT-005, LOT-011 | LOT-013 | IDs source invalides | Output validé |
| LOT-013 | LOT-012 | LOT-014 | Transaction partielle | Worker tests |
| LOT-014 | LOT-013 | LOT-015 | Fuite source | Tests ownership |
| LOT-015 | LOT-014 | LOT-016 | DTO divergent | Tests parsing |
| LOT-016 | LOT-015, LOT-007 | LOT-021 | Page trop dense | Widget tests |
| LOT-017 | LOT-002B | LOT-018 | Modèle trop abstrait | Contrat choisi |
| LOT-018 | LOT-002B, LOT-017 | LOT-019 | Duplication modèle | Tests repository |
| LOT-019 | LOT-018, LOT-013 | LOT-020 | Hallucination sources | Sources validées |
| LOT-020 | LOT-019 | LOT-021 | Endpoint lent | Tests controller |
| LOT-021 | LOT-020, LOT-016 | LOT-029 | UX trop dense | Tests fiche |
| LOT-022 | LOT-001 | LOT-023, LOT-024 | Fuite correction | Contrat sans réponse |
| LOT-023 | LOT-022, LOT-013 | LOT-024 | Questions hors cours | Tests schema |
| LOT-024 | LOT-002B, LOT-023 | LOT-025, LOT-034 | Mastery opaque | Tests submit |
| LOT-025 | LOT-024 | LOT-030 | UI confuse | Widget tests |
| LOT-026 | LOT-002B, LOT-024 | LOT-027 | Modèle activité rigide | Tests endpoints |
| LOT-027 | LOT-026, LOT-013 | LOT-028 | Correction vague | Tests flow |
| LOT-028 | LOT-027 | LOT-030, LOT-034 | UX mobile | Widget tests |
| LOT-029 | LOT-021 | LOT-032 | Schéma permissif | Tests validator |
| LOT-030 | LOT-025, LOT-028 | LOT-032 | Payload invalide | Tests fallback |
| LOT-031 | LOT-029, LOT-030 | LOT-032, LOT-033 | Session prématurée | Session déterministe |
| LOT-032 | LOT-031 | LOT-033 | Chatbot générique | Fallback GenUI |
| LOT-033 | LOT-032 | Démo coach | Perte testabilité | Fallback déterministe |
| LOT-034 | LOT-024, LOT-028 | LOT-035 | Ranking opaque | Tests domain |
| LOT-035 | LOT-034 | Démo today | Divergence types | Widget tests |
| LOT-036 | LOT-003 | LOT-037, LOT-038 | Seed fragile | Rejeu manuel |
| LOT-037 | LOT-036 | Démo stable | Tests lents | E2E critiques |
| LOT-038 | LOT-036, LOT-037 | Présentation | Docs obsolètes | Runbook rejoué |

## 8. Lots à ne surtout pas lancer trop tôt

- Session GenUI complète : elle dépend de composants isolés, validation stricte et fallback natif.
- Plan du jour multi-actions avancé : il dépend de QCM enrichi, question ouverte, mastery events et actions lançables.
- Orchestration coach IA : elle doit venir après une session déterministe et des composants GenUI stables.
- Imports avancés OCR, image et audio : ils ajoutent un nouveau pipeline alors que le PDF texte doit d'abord être robuste.
- Génération libre de widgets : elle contredit le principe GenUI borné et crée un risque sécurité/UX.
- Refonte UI totale non bornée : elle consommerait du temps sans sécuriser la démo IA.
- Migration globale du modèle d'activité : elle risque de casser le QCM existant ; préférer extensions ciblées.
- Stockage générique de tous les artefacts sans cas d'usage validé : risque d'overengineering.
- Migrations Prisma en rafale sans revue de schéma : elles créent une dette difficile à corriger une fois les repositories et DTO branchés.

## 9. Golden demo path

| Étape | État initial | Action utilisateur | Résultat attendu | Preuve visuelle ou technique | Validation manuelle |
| --- | --- | --- | --- | --- | --- |
| 1. Login | App installée, backend disponible | Connexion Firebase | Routes privées accessibles | Profil affiché, token accepté | Se déconnecter puis vérifier `/sign-in` |
| 2. Création matière | Aucun sujet ou compte démo | Créer “Droit constitutionnel” | Matière persistée | Liste matières affiche la carte | Redémarrer app, matière présente |
| 3. Import PDF | Matière ouverte | Importer PDF texte de démo | Document `UPLOADED` puis `PROCESSING` | Carte document avec statut | Vérifier API liste documents |
| 4. Processing | Worker actif | Attendre traitement | Document `READY` | Statut prêt | Vérifier logs worker sans erreur |
| 5. Notions détectées | Document READY | Ouvrir détail document | Notions, difficulté, sources | Cartes notions + extraits | Comparer aux passages du PDF |
| 6. Fiche générée | Notions disponibles | Cliquer générer fiche | Fiche sourcée | Résumé, points clés, sources | Vérifier sources non inventées |
| 7. QCM enrichi | Notions prêtes | Lancer diagnostic | QCM sans correction visible | Questions et choix | Vérifier pas de bonne réponse exposée |
| 8. Question ouverte corrigée | Notion sélectionnée | Répondre en texte libre | Correction structurée | Score, points manquants, modèle | Vérifier feedback cohérent |
| 9. Plan du jour mis à jour | Activité soumise | Ouvrir Aujourd'hui | Recommandation adaptée | Carte action et raison | Comparer mastery avant/après |
| 10. Session GenUI simple | Composants validés | Démarrer Révision IA | Bloc dynamique rendu | Summary/QCM/correction dans AiSurface | Forcer payload invalide et voir fallback |

## 10. Stratégie de validation globale

### Backend

- Tests unitaires domain pour chunking, mastery, ranking Today.
- Tests application pour use cases documents, summaries, activities, revision sessions.
- Tests infrastructure Prisma pour ownership et persistance.
- Tests controller pour 401, 400, 404, 409, 422.
- Tests worker pour statuts `PROCESSING`, `READY`, `FAILED`.
- Commandes probables :
  - `cd api && npm run lint:check`
  - `cd api && npm test`
  - `cd api && npm run test:e2e`
  - `cd api && npm run build`

### Frontend

- Tests data pour parsing JSON et erreurs Dio.
- Tests controller/notifier Riverpod.
- Tests widget pour pages et composants.
- Tests router pour auth, onglets et deep links.
- Commandes probables :
  - `cd revision_app && dart analyze lib test`
  - `cd revision_app && flutter test`
  - `cd revision_app && flutter build web`

### Genkit

- Tests de schémas Zod.
- Tests de outputs invalides.
- Tests de source grounding.
- Tests d'observabilité succès/échec.
- Fakes ou mocks pour éviter les coûts IA en CI.
- Validation manuelle ponctuelle avec provider réel.

### GenUI

- Tests de catalogue.
- Tests de payload valide.
- Tests de payload invalide.
- Tests fallback.
- Interdiction de composant inconnu.
- Limites de longueur sur textes rendus.

### Validations manuelles

- Golden path complet.
- Import PDF réel.
- Worker réel.
- Fiche sourcée.
- QCM et correction.
- Question ouverte.
- Today après activité.
- Session GenUI simple.

### Contrôles sécurité

- Token obligatoire.
- Ownership par `studentId`.
- Aucun `storagePath` interne exposé.
- Pas de correction avant submit.
- Pas de source cross-document.

### Contrôles anti-hallucination

- Les sources affichées doivent venir de chunks stockés.
- Les outputs IA avec références inconnues doivent être rejetés.
- Les fiches et corrections doivent pointer vers des chunks ou notions.
- Les prompts doivent interdire le contenu externe.

### Contrôles coût et timeouts

- Limite taille input.
- Limite nombre chunks fournis.
- Timeout provider IA.
- Retry contrôlé.
- Rate limit génération si disponible.
- Observabilité durée et statut.

## 11. Risques transverses

| Risque | Probabilité | Impact | Mitigation | Lot traité |
| --- | --- | --- | --- | --- |
| Hallucination des sources | Élevée | Élevé | Chunks backend, validation IDs, rejet outputs invalides | LOT-009 à LOT-013 |
| PDF trop longs | Élevée | Moyen | Chunking, limite input, sélection chunks | LOT-011, LOT-012 |
| PDF scannés sans OCR | Moyenne | Moyen | Message erreur explicite, hors MVP | LOT-011, LOT-038 |
| Coût IA | Moyenne | Élevé | Observabilité, limites, fakes CI, rate limit | LOT-004, LOT-005, LOT-019 |
| Lenteur IA | Moyenne | Moyen | Timeouts, jobs async si retenu, UI loading | LOT-017, LOT-020, LOT-021 |
| Payload GenUI invalide | Élevée | Moyen | Catalogue strict, validators, fallback | LOT-029, LOT-030 |
| Fuite cross-student | Moyenne | Élevé | Tests ownership sur chaque endpoint | Tous lots API |
| Frontend trop Material-like | Moyenne | Moyen | Primitives premium ciblées | LOT-006 à LOT-008 |
| Overengineering documentaire | Moyenne | Élevé | Décision LOT-002, modèle minimal | LOT-009 |
| Dette si coach trop tôt | Élevée | Élevé | Retarder session complète | LOT-031 à LOT-033 |
| Correction ouverte trop vague | Moyenne | Élevé | Barème strict, sources, tests réponses types | LOT-027 |
| Ranking Today opaque | Moyenne | Moyen | Algorithme déterministe testé | LOT-034 |
| Logs contenant données sensibles | Moyenne | Élevé | Ne logger que tailles, IDs techniques et statuts | LOT-004, LOT-005 |
| Divergence upload/lecture document | Moyenne | Élevé | Choisir un chemin officiel MVP et documenter les chemins secondaires | LOT-001B |

## 12. Décisions à prendre avant implémentation

| Décision | Options | Recommandation | Impact | Moment où décider |
| --- | --- | --- | --- | --- |
| Quelle stratégie upload/lecture document officielle ? | Upload direct backend / Firebase Storage + reader backend / coexistence temporaire | Pour le MVP, garder `POST /documents/course-pdf` comme chemin officiel si le worker lit le stockage local ; garder `POST /documents` seulement comme compatibilité documentée ou futur Firebase Storage avec adapter backend dédié | Pipeline worker, sécurité stockage, tests d'import | LOT-001B |
| Faut-il ajouter `DocumentChunk` ? | Oui / Non / stockage temporaire | Oui, minimal, car nécessaire au grounding | Structure worker et Genkit | LOT-002 puis LOT-009 |
| Faut-il ajouter `SourceReference` ? | Table dédiée / JSON dans artefacts / relation directe | Table dédiée légère si plusieurs artefacts citent les mêmes chunks | API sources et anti-hallucination | LOT-002 puis LOT-009 |
| Faut-il ajouter `AiGenerationJob` ? | Non / logs seulement / table dédiée | Commencer par port observabilité, table si besoin de statuts async | Debug et coûts IA | LOT-002 puis LOT-004 |
| Faut-il ajouter `GeneratedArtifact` ? | Non / table générique / modèles spécialisés | Modèles métier spécialisés, avec métadonnées communes ; générique seulement si duplication forte | Simplicité Prisma | LOT-017 |
| Faut-il versionner les prompts en DB ? | Constantes code / DB / table config | Stocker `promptVersion` et `schemaVersion` sur artefacts générés | Reproductibilité | LOT-017, LOT-018 |
| Faut-il stocker les payloads GenUI ? | Non / oui pour session / oui partout | Stocker seulement en session si nécessaire ; reconstruire depuis objets métier pour fiches | Debug session | LOT-031 |
| Faut-il historiser les résumés ? | Écraser / versions multiples / latest + archived | Pour MVP, garder latest avec `regeneratedAt`, puis historiser si demandé | Coût et UX | LOT-018 |
| Faut-il faire les générations en job asynchrone ? | Synchrone / async par BullMQ / hybride | Synchrone pour résumé court MVP si timeout acceptable ; async pour traitements longs | UX et robustesse | LOT-017, LOT-020 |
| Quel est le premier PDF de démo ? | Cours droit constitutionnel / PDF synthétique / autre cours court | PDF texte court et maîtrisé, idéalement synthétique | Tests manuels | LOT-003 |
| Quels composants GenUI minimum ? | Summary + Source / QCM / Correction / all | SummaryCard, SourceExcerptCard, McqQuestionCard, CorrectionPanel | Démo GenUI réaliste | LOT-029, LOT-030 |

## 13. Définition de done pour les futurs lots

Un futur lot d'implémentation est terminé seulement si :

- le périmètre du lot est respecté ;
- aucun objectif hors lot n'a été ajouté ;
- les tests pertinents sont écrits ou explicitement justifiés ;
- les validations prévues sont lancées ;
- les erreurs sont gérées ;
- les données restent isolées par étudiant ;
- les outputs IA sont typés et validés si le lot touche Genkit ;
- les payloads GenUI sont validés et ont un fallback si le lot touche GenUI ;
- les états loading/error/empty sont présents si le lot touche le frontend ;
- les commandes lancées et leurs résultats sont rapportés ;
- aucun commit Git n'est effectué ;
- le rapport final mentionne fichiers modifiés, tests lancés, tests non lancés et risques restants.

## 14. Proposition de prochain lot concret

Le prochain lot à lancer après ce plan devrait être :

### LOT-001 — Audit des contrats actuels

Raison :

- Il est prudent.
- Il ne modifie pas le code.
- Il réduit le risque de construire sur une hypothèse fausse.
- Il prépare la décision upload/lecture document du LOT-001B.
- Il permettra ensuite de lancer LOT-002 avec des informations vérifiées.

Livrable attendu :

- Un court document d'audit ou une section ajoutée au plan avec les endpoints, modèles, flows, scripts et gaps confirmés.
- Aucune migration.
- Aucune dépendance.
- Aucun commit.

Le deuxième lot à lancer immédiatement après devrait être LOT-001B. Il doit trancher si le MVP utilise officiellement l'upload direct backend via `POST /documents/course-pdf`, Firebase Storage avec reader backend, ou une coexistence temporaire documentée. Sans cette décision, il ne faut pas toucher au worker, aux chunks ou aux migrations documentaires.
``````

### revision_app/docs/ROADMAP_EXECUTION_LOT_038_DEMO_DEPLOYMENT_RUNBOOK.md

Le présent fichier est le rapport de lot. Son contenu complet est directement consultable dans ce document.
