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
