# LOT-001 + LOT-001B — Audit contrats et stratégie document

## 1. Résultat

LOT-001 et LOT-001B sont des lots de cadrage. Ils ne nécessitent pas de changement applicatif.

Résultat de ce checkpoint :

- les contrats actuels front/back sont cartographiés ;
- les modules backend critiques sont identifiés ;
- les routes Flutter et providers runtime sont identifiés ;
- les flows Genkit existants sont identifiés ;
- le catalogue GenUI existant est identifié ;
- la stratégie officielle d'upload et de lecture document pour le MVP est tranchée.

Décision LOT-001B :

Pour le MVP, le chemin officiel est :

```text
Flutter file_picker
→ multipart POST /documents/course-pdf
→ UploadCoursePdfUseCase
→ LocalDocumentFileStorage
→ Document + DocumentProcessingJob
→ BullMQ
→ DocumentProcessingConsumer
→ LocalDocumentFileStorage.read(storagePath)
→ pdf-parse
→ Genkit
→ KnowledgeUnit
```

Firebase Storage n'est pas le chemin runtime officiel du MVP. Il reste une option future, uniquement si un adapter backend explicite sait lire les fichiers Firebase Storage.

## 2. Sources inspectées

Frontend Flutter :

- `revision_app/pubspec.yaml`
- `revision_app/README.md`
- `revision_app/AGENTS.md`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/app/di/revision_providers.dart`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/application/documents_controller.dart`
- `revision_app/lib/presentation/widgets/documents/document_import_button.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/lib/features/today/data/http_today_repository.dart`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`
- `revision_app/lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `revision_app/test/**`

Backend NestJS :

- `api/package.json`
- `api/README.md`
- `api/prisma/schema.prisma`
- `api/src/app.module.ts`
- `api/src/modules/auth/**`
- `api/src/modules/students/**`
- `api/src/modules/subjects/**`
- `api/src/modules/documents/**`
- `api/src/modules/jobs/**`
- `api/src/modules/ai/**`
- `api/src/modules/activities/**`
- `api/src/modules/revision/**`
- `api/test/**`

## 3. LOT-001 — Audit des contrats actuels

### 3.1 Backend : modules actifs

| Module | Rôle actuel | Observations |
| --- | --- | --- |
| `auth` | Guard Firebase, token verifier, export du guard | Dépend de `StudentsModule` pour exposer l'étudiant courant. |
| `students` | `GET /students/me`, bootstrap profil serveur | Retourne l'étudiant authentifié injecté par le guard. |
| `subjects` | Création, lecture, listing de matières | Ownership via `studentId`. |
| `documents` | Register metadata, upload PDF multipart, liste et détail document | Importe `JobsModule`, `PrismaModule`, `AuthModule`. |
| `jobs` | Queue BullMQ, worker document optionnel | Worker activé avec `DOCUMENT_PROCESSING_WORKER_ENABLED=true`. |
| `ai` | Port `DOCUMENT_KNOWLEDGE_EXTRACTOR`, adapters Genkit Google/Mistral | Choix provider via env. |
| `activities` | QCM diagnostic et soumission | Activité unique `DIAGNOSTIC_QUIZ`. |
| `revision` | Objectif de révision, plan du jour, mastery | `TodayPlan` déterministe et limité à `diagnostic_quiz`. |

### 3.2 Backend : endpoints actuels

Endpoints publics simples :

| Méthode | Route | Statut |
| --- | --- | --- |
| `GET` | `/` | Actif |
| `GET` | `/health` | Actif |

Endpoints protégés par `FirebaseAuthGuard` :

| Méthode | Route | Module | Statut |
| --- | --- | --- | --- |
| `GET` | `/students/me` | `students` | Actif |
| `GET` | `/subjects` | `subjects` | Actif |
| `GET` | `/subjects/:id` | `subjects` | Actif |
| `POST` | `/subjects` | `subjects` | Actif |
| `POST` | `/revision-goals` | `revision` | Actif |
| `GET` | `/today` | `revision` | Actif |
| `POST` | `/documents` | `documents` | Actif, chemin metadata/storagePath |
| `POST` | `/documents/course-pdf` | `documents` | Actif, upload multipart officiel MVP |
| `GET` | `/subjects/:subjectId/documents` | `documents` | Actif |
| `GET` | `/documents/:documentId` | `documents` | Actif |
| `POST` | `/activities/next` | `activities` | Actif |
| `POST` | `/activities/:sessionId/result` | `activities` | Actif |

Endpoints absents mais prévus par la roadmap :

- `GET /documents/:documentId/knowledge-units`
- `POST /documents/:documentId/summaries`
- `GET /documents/:documentId/summaries`
- `POST /activities/diagnostic-quiz`
- `POST /activities/open-question`
- `POST /activities/:sessionId/open-answer`
- `POST /revision-sessions`
- `POST /revision-sessions/:sessionId/message`

### 3.3 Backend : Prisma actuel

Modèles présents :

- `StudentProfile`
- `RevisionGoal`
- `Subject`
- `Document`
- `DocumentProcessingJob`
- `KnowledgeUnit`
- `MasteryState`
- `ActivitySession`
- `Question`
- `ActivityResult`

Enums présents :

- `DocumentKind`: `COURSE_PDF`, `EXAM_PDF`, `EXAM_IMAGE`
- `DocumentStatus`: `UPLOADED`, `PROCESSING`, `READY`, `FAILED`
- `JobStatus`: `PENDING`, `RUNNING`, `COMPLETED`, `FAILED`
- `ActivityType`: `DIAGNOSTIC_QUIZ`
- `ActivityStatus`: `STARTED`, `COMPLETED`

Points solides :

- `Subject` porte `@@unique([id, studentId])`.
- `Document` référence `Subject` via `(subjectId, studentId)`.
- `MasteryState` est isolé par `(studentId, knowledgeUnitId)`.
- `ActivitySession` référence `studentId`, `subjectId` et `knowledgeUnitId`.

Gaps pour la roadmap :

- `KnowledgeUnit` ne persiste que `title` et `summary`.
- `sourceExcerpt` et `difficulty` existent côté schéma IA, mais ne sont pas persistés.
- Aucun `DocumentChunk`.
- Aucun `SourceReference`.
- Aucun `Summary`.
- Aucun `RevisionSheet`.
- Aucun `OpenQuestion`.
- Aucun `OpenAnswerEvaluation`.
- Aucun `MasteryEvent`.
- `DocumentProcessingJob.attempts` existe mais n'est pas alimenté par le worker actuel.
- `ActivityResult` ne stocke que `correctAnswers` et `totalQuestions`.

### 3.4 Backend : pipeline document actuel

Pipeline actif pour `POST /documents/course-pdf` :

1. `DocumentsController.uploadCoursePdf` reçoit `subjectId` + fichier multipart.
2. Le controller valide :
   - fichier présent ;
   - extension `.pdf` ;
   - mime type `application/pdf` ;
   - contenu non vide ;
   - taille maximale 20 MB.
3. `UploadCoursePdfUseCase` appelle `DocumentFileStorage.saveCoursePdf`.
4. `LocalDocumentFileStorage` écrit le fichier sous `DOCUMENT_STORAGE_ROOT` ou `storage/revision-documents`.
5. `DocumentsRepository.create` crée `Document` et `DocumentProcessingJob`.
6. `DocumentProcessingQueue.enqueue` ajoute le job BullMQ.
7. `DocumentProcessingConsumer` lit le document.
8. Le worker utilise `DocumentContentReader.read(storagePath)`.
9. `PdfParseDocumentTextExtractor` extrait le texte.
10. `DocumentKnowledgeExtractor.extract` appelle Genkit.
11. `PrismaDocumentsRepository.markReadyWithKnowledgeUnits` crée les notions et marque le document `READY`.
12. En cas d'erreur finale, le document passe à `FAILED` avec `errorCode`.

Pipeline actif pour `POST /documents` :

1. Le client fournit `subjectId`, `kind`, `fileName`, `storagePath`, `mimeType`.
2. Le controller vérifie que `storagePath` suit `students/{firebaseUid}/subjects/{subjectId}/{fileName}`.
3. `RegisterDocumentUseCase` crée le document et enqueue le processing.
4. Le worker lit ensuite `storagePath` avec `LocalDocumentFileStorage`.

Problème du second chemin :

- Il suppose que le fichier existe déjà dans le stockage lisible par le backend.
- Il n'y a pas actuellement d'adapter backend Firebase Storage.
- Si un front uploadait vers Firebase Storage puis appelait `POST /documents`, le worker local ne saurait pas lire ce fichier.

### 3.5 Backend : Genkit actuel

Extraction de notions :

- Port : `DocumentKnowledgeExtractor`.
- Provider factory : `createDocumentKnowledgeExtractor`.
- Adapters :
  - `GenkitDocumentKnowledgeExtractor` avec `@genkit-ai/google-genai`.
  - `GenkitMistralDocumentKnowledgeExtractor` avec `@genkit-ai/compat-oai`.
- Modèle Google par défaut : `googleai/gemini-2.5-flash`.
- Modèle Mistral par défaut : `mistral-small-latest`.
- Limite texte : `DOCUMENT_TEXT_MAX_CHARS`, défaut 12 000.
- Output schema : `ExtractedKnowledgeSchema`.

Limites :

- Les classes appellent `ai.generate`, mais il n'y a pas encore de flow nommé/versionné avec `defineFlow`.
- Pas d'observabilité Genkit structurée.
- Pas de `promptVersion`.
- Pas de `schemaVersion`.
- L'input envoyé au modèle est un slice du texte complet, pas une liste de chunks référencés.

Génération QCM :

- Port : `DiagnosticQuizGenerator`.
- Adapter : `GenkitDiagnosticQuizGenerator`.
- Provider Google ou Mistral selon env.
- Output : `title`, `questions`, `choices`, `correctChoiceId`, `explanation`.
- Schéma strict avec validation de l'unicité des choix et de la présence de `correctChoiceId`.

Limites :

- Le QCM est basé sur `KnowledgeUnit.title` et `KnowledgeUnit.summary`, pas sur des chunks.
- La correction détaillée n'est pas encore modélisée.
- Le backend stocke `correctChoiceId` dans `Question`, mais le DTO public actuel ne l'expose pas côté Flutter.

### 3.6 Backend : points d'architecture à surveiller

- Les controllers restent globalement fins, mais plusieurs validations HTTP sont directement dans les controllers.
- `GetDocumentUseCase` importe `NotFoundException` depuis NestJS dans la couche application.
- `JobsModule` ré-instancie `PrismaDocumentsRepository` et `LocalDocumentFileStorage` au lieu de consommer un export du `DocumentsModule`.
- `EXAM_IMAGE` est accepté par `POST /documents`, mais le worker refuse tout ce qui n'est pas `application/pdf`.
- `GET /documents/:documentId` retourne le DTO repository, qui contient `storagePath`. Ce point contredit l'objectif roadmap de ne pas exposer les chemins internes.
- Le plan du jour et le choix de prochaine activité utilisent deux logiques différentes : `AdaptivePlanService` côté today, tri local dans `StartNextActivityUseCase` côté activity.

### 3.7 Frontend : navigation et pages

Routes publiques :

- `/`
- `/sign-in`
- `/onboarding`

Routes privées dans `StatefulShellRoute.indexedStack` :

- `/subjects`
- `/subjects/:subjectId`
- `/today`
- `/activities`
- `/profile`

Points solides :

- Auth gate via `executeRevisionRedirect`.
- Onglets persistants via `StatefulShellRoute.indexedStack`.
- `RevisionHomeShell` garde une navigation responsive mobile/desktop.
- Les pages réelles sont sous `lib/presentation/pages`.
- Les fichiers `features/*/presentation` sont surtout des exports de compatibilité.

### 3.8 Frontend : DI Riverpod et HTTP runtime

Providers runtime :

- `authRepositoryProvider` -> `FirebaseAuthRepository`.
- `authProfileBootstrapperProvider` -> `HttpStudentProfileBootstrapper`.
- `subjectsRepositoryProvider` -> `HttpSubjectsRepository`.
- `revisionGoalsRepositoryProvider` -> `HttpRevisionGoalsApi`.
- `documentsApiProvider` -> `HttpDocumentsApi`.
- `activityApiProvider` -> `HttpActivitiesApi`.
- `todayRepositoryProvider` -> `HttpTodayRepository`.

Tous les repositories HTTP récupèrent un Firebase ID token et envoient :

```text
Authorization: Bearer <firebase-id-token>
```

### 3.9 Frontend : documents actuels

Modèle `RevisionDocument` :

- `id`
- `subjectId`
- `kind`
- `fileName`
- `status`
- `mimeType`
- `errorCode`

API Flutter :

- `uploadCoursePdf` -> `POST /documents/course-pdf`
- `listSubjectDocuments` -> `GET /subjects/:subjectId/documents`
- `getDocument` -> `GET /documents/:documentId`

Import UI :

- `DocumentImportButton` utilise `file_picker`.
- Extensions autorisées côté picker : `pdf`.
- Le fichier est lu côté plateforme.
- Les bytes sont envoyés à `DocumentsController.uploadCoursePdf`.
- Il n'y a pas d'upload Firebase Storage dans le runtime actuel.

Limites :

- Pas de détail document.
- Pas de modèle Flutter `KnowledgeUnit`.
- Pas d'affichage de sources.
- Pas de retry processing.
- Erreur import affichée via `SnackBar` encore très basique.

### 3.10 Frontend : activités actuelles

API Flutter :

- `POST /activities/next`
- `POST /activities/:sessionId/result`

Modèle actuel :

- `DiagnosticQuizActivity`
- `DiagnosticQuizQuestion`
- `DiagnosticQuizChoice`
- `DiagnosticQuizAnswer`
- `DiagnosticQuizResult`

Limites :

- Pas d'endpoint `/activities/diagnostic-quiz`.
- Pas de question ouverte.
- Pas de correction détaillée.
- Pas de score par notion.
- Pas de feedback par choix.

### 3.11 Frontend : Today actuel

API Flutter :

- `GET /today`

Modèle actuel :

- `TodayPlan`
- `TodayPlanItem`

Champs item :

- `subjectId`
- `subjectName`
- `knowledgeUnitId`
- `knowledgeUnitTitle`
- `masteryScore`
- `action`
- `estimatedMinutes`

Limites :

- Pas d'`id` d'item.
- Pas de `reason` côté modèle Flutter.
- L'action reste une chaîne libre.
- La page lance surtout `/activities?subjectId=...`.

### 3.12 Frontend : GenUI actuel

Catalogue :

- `revisionActivityCatalogId = com.revision.activity_catalog`
- `BasicCatalogItems.asNoAssetCatalog`
- `QuestionCard`

Validateur :

- Vérifie `sessionId`, `title`, questions non vides.
- Limite questions à 20.
- Limite choix par question à 6.
- Vérifie IDs non vides et uniques.

Limites :

- Pas encore de contrat bloc GenUI avec `component`, `schemaVersion`, `payload`.
- `QuestionCard` utilise encore un `Card` Material brut.
- GenUI n'est pas encore utilisé comme surface centrale de session.

### 3.13 Scripts et validations disponibles

Backend :

- `npm run lint:check`
- `npm run test`
- `npm run test:e2e`
- `npm run build`
- `npm run prisma:generate`
- `npm run start:dev`

Commandes backend à éviter comme validation non destructive :

- `npm run lint` car il lance ESLint avec `--fix`.
- `npm run format` car il écrit avec Prettier.
- `npm run test:cov` car il écrit `coverage`.
- `npm run prisma:migrate:deploy` car il modifie la base cible.

Frontend :

- `flutter test`
- `dart analyze lib test`
- `flutter build macos --debug`
- `flutter build web`

Commandes à ne pas inventer :

- pas de `npm run typecheck` côté backend ;
- pas de `npm run test:unit` côté backend ;
- pas de `npm run seed` côté backend ;
- pas de `npm run worker` côté backend ;
- pas de `npm run test` côté Flutter ;
- pas de `melos` ;
- pas de `flutter drive` détecté ;
- pas d'`integration_test` détecté.

### 3.14 Tests existants

Backend :

- Tests root : app controller, health.
- Auth : Firebase guard.
- Students : bootstrap et controller.
- Subjects : domain, create use case, repository, controller.
- Documents : register, upload, local storage, PDF extractor, Prisma repository, controller.
- Jobs : BullMQ queue, jobs module, document processing consumer.
- AI : provider, Google extractor, Mistral extractor.
- Activities : module, start, submit, Genkit quiz generator, Prisma repository.
- Revision : goal, mastery, adaptive plan, today, repository.
- E2E : `test/app.e2e-spec.ts`.

Frontend :

- App/root/router/DI.
- Auth.
- Subjects.
- Documents.
- Activities.
- Today.
- Theme.
- GenUI catalog/validator.
- Widgets.

## 4. LOT-001B — Décision stratégie upload et lecture document

### 4.1 Options comparées

| Option | Description | Avantages | Inconvénients | Décision |
| --- | --- | --- | --- | --- |
| Upload direct backend | Flutter envoie le PDF à `POST /documents/course-pdf`; backend stocke le fichier et le worker le relit | Déjà implémenté front/back/worker ; simple ; cohérent avec Dokploy volume ; pas de Firebase Storage payant | Nécessite un volume persistant partagé API/worker ; upload passe par API | Retenue pour MVP |
| Firebase Storage + metadata | Flutter upload dans Firebase Storage puis appelle `POST /documents` | Décharge l'API pour upload ; chemin envisagé dans roadmap initiale | Pas d'adapter backend actuel pour lire Firebase Storage ; Firebase Storage payant dans le projet ; worker local ne sait pas lire ce fichier | Reportée |
| Coexistence temporaire | Garder les deux chemins actifs | Permet compatibilité | Risque fort de confusion ; worker peut chercher au mauvais endroit ; double documentation | À éviter comme runtime officiel |

### 4.2 Décision officielle MVP

Pour le MVP, le chemin officiel est l'upload direct backend via :

```text
POST /documents/course-pdf
```

Conséquences :

- Le frontend garde `HttpDocumentsApi.uploadCoursePdf`.
- `DocumentImportButton` continue d'envoyer les bytes à l'API.
- `LocalDocumentFileStorage` reste l'implémentation officielle MVP.
- `DOCUMENT_STORAGE_ROOT` doit pointer vers un volume persistant.
- Si API et worker sont séparés, ils doivent monter le même volume au même chemin.
- `POST /documents` reste disponible, mais ne doit pas être utilisé par le frontend MVP.
- Firebase Storage n'est pas requis pour importer les cours MVP.

### 4.3 Statut de `POST /documents`

`POST /documents` doit être considéré comme :

- compatibilité technique existante ;
- chemin futur possible pour stockage externe ;
- non officiel pour le MVP tant qu'il n'existe pas d'adapter backend capable de lire le stockage externe.

Règle pour les prochains lots :

Ne pas construire chunks, sources ou worker v2 en supposant que `POST /documents` reçoit un fichier déjà lisible. Le seul chemin officiel de fichier lisible est celui produit par `POST /documents/course-pdf`.

### 4.4 Conditions de déploiement

Pour que ce choix fonctionne en local et sur Dokploy :

- `DOCUMENT_STORAGE_ROOT` doit être configuré.
- Le répertoire doit être persistant.
- L'API doit pouvoir écrire dans ce répertoire.
- Le worker doit pouvoir lire dans ce même répertoire.
- Si API et worker sont deux containers différents, le même volume doit être monté dans les deux.
- Le volume ne doit pas être supprimé entre upload et processing.

### 4.5 Tests à renforcer dans les lots futurs

Backend :

- Upload multipart écrit bien le fichier.
- Document créé avec `storagePath` canonique.
- Job enqueue après upload.
- Si création DB échoue, fichier supprimé.
- Worker lit le fichier depuis le même `storagePath`.
- Worker échoue proprement si fichier absent.
- `POST /documents` ne doit pas être utilisé comme chemin Firebase tant qu'aucun reader Firebase n'existe.

Frontend :

- `DocumentImportButton` appelle `uploadCoursePdf`.
- `HttpDocumentsApi` envoie `multipart/form-data`.
- Aucun test runtime ne doit attendre Firebase Storage pour les PDF.

### 4.6 Critère de stop LOT-001B

Le passage vers LOT-002 est autorisé avec cette décision.

Le passage vers LOT-010 ou LOT-011 reste interdit tant que le futur lot d'implémentation n'a pas vérifié :

- le volume `DOCUMENT_STORAGE_ROOT` en environnement cible ;
- la capacité API à écrire ;
- la capacité worker à lire ;
- l'absence d'usage Firebase Storage dans le chemin MVP.

## 5. Gaps à traiter avant les lots suivants

### Avant LOT-002

- Valider que le choix upload direct backend est accepté.
- Décider si `POST /documents` doit être documenté comme legacy, internal ou future external storage path.

### Avant LOT-010 et LOT-011

- Vérifier le volume partagé API/worker.
- Préparer une stratégie de migration Prisma groupée.
- Ne pas ajouter `DocumentChunk` avant revue de schéma.

### Avant LOT-014

- Ne pas exposer `storagePath` dans les DTO publics enrichis.
- Créer un DTO document public séparé du DTO repository si nécessaire.

### Avant support image/OCR

- Ne pas activer `EXAM_IMAGE` côté produit.
- Le worker actuel ne supporte que `application/pdf`.

## 6. Statut des critères d'acceptation

LOT-001 :

- Endpoints actuels listés : oui.
- Modèles Prisma actuels listés : oui.
- Flows Genkit actuels listés : oui.
- Composants GenUI actuels listés : oui.

LOT-001B :

- Chemin officiel MVP écrit : oui.
- Worker sait où lire le PDF : oui, `LocalDocumentFileStorage.read(storagePath)`.
- Chemin non officiel documenté : oui, `POST /documents` reste compatibilité/futur stockage externe.
- Aucun futur lot chunk/worker ne dépend d'une hypothèse implicite : oui, le stop est explicite.

## 7. Recommandation pour le prochain lot

Prochain lot recommandé :

```text
LOT-002 — Décisions fondations IA et documentaire
```

Décisions à prendre dans LOT-002 :

- Ajouter `DocumentChunk` : recommandé oui.
- Ajouter une table de lien notion-source : recommandé oui, sous forme minimale.
- Éviter `SourceReference` trop polymorphe au départ.
- Définir si `GeneratedArtifact` est nécessaire dès le MVP Cut 1.
- Définir les métadonnées IA communes : `flowName`, `provider`, `model`, `promptVersion`, `schemaVersion`, `inputSize`, `durationMs`, `status`, `errorCode`.

Le LOT-002 ne doit pas encore modifier Prisma. Il doit préparer LOT-002B, la revue de schéma avant migrations.
