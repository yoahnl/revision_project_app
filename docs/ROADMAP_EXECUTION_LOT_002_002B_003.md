# LOT-002 + LOT-002B + LOT-003 — Fondations IA/documentaire, schéma cible et golden demo

## 1. Résultat

Ces lots sont des lots de cadrage. Ils ne modifient pas le code applicatif, ne modifient pas le schéma Prisma, ne créent aucune migration et ne changent aucune configuration runtime.

Décisions principales :

- Le MVP doit introduire une fondation documentaire vérifiable avant les résumés, QCM enrichis et corrections ouvertes.
- `DocumentChunk` est nécessaire pour le MVP Cut 1, sous forme minimale et persistée.
- Les citations et sources affichées ne doivent pas venir d’extraits libres inventés par l’IA, mais de chunks stockés.
- Le lien initial entre une notion et ses sources doit être porté par une table dédiée `KnowledgeUnitSource`, pas par un JSON libre et pas par un modèle polymorphe trop générique.
- Une table globale `SourceReference` n’est pas recommandée pour la première migration.
- Les artefacts IA doivent d’abord rester spécialisés (`Summary`, `RevisionSheet` plus tard), avec des métadonnées IA communes, avant d’introduire un éventuel `GeneratedArtifact`.
- `AiGenerationJob` n’est pas nécessaire immédiatement. Un port d’observabilité Genkit avec logs structurés doit arriver avant les nouveaux flows IA.
- Le golden demo path doit partir d’un PDF texte synthétique, court, légalement réutilisable, idéalement en droit constitutionnel.

Rappel du chemin officiel issu de `LOT-001B` :

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

Firebase Storage n’est pas le chemin runtime officiel du MVP. Il reste une option future seulement si un adapter backend explicite sait lire les fichiers Firebase Storage.

## 2. Sources inspectées

Sources roadmap et lots précédents :

- `docs/ROADMAP.md`
- `docs/ROADMAP_EXECUTION_PLAN.md`
- `docs/ROADMAP_EXECUTION_LOT_001_001B.md`

Backend :

- `api/prisma/schema.prisma`
- `api/package.json`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/application/upload-course-pdf.use-case.ts`
- `api/src/modules/documents/domain/document-file-storage.ts`
- `api/src/modules/documents/domain/document-text-extractor.ts`
- `api/src/modules/documents/infrastructure/local-document-file-storage.ts`
- `api/src/modules/documents/infrastructure/pdf-parse-document-text.extractor.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/jobs/interfaces/document-processing-queue.ts`
- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/application/diagnostic-quiz-generator.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/domain/activity-session.ts`
- `api/src/modules/activities/domain/diagnostic-quiz.ts`
- `api/src/modules/activities/domain/mastery-state.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`
- `api/src/modules/revision/domain/adaptive-plan.service.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `api/src/modules/subjects/interfaces/subjects.controller.ts`

Frontend :

- `revision_app/pubspec.yaml`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/features/documents/application/documents_controller.dart`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/domain/revision_document.dart`
- `revision_app/lib/presentation/widgets/documents/document_import_button.dart`
- `revision_app/lib/features/activities/application/activity_controller.dart`
- `revision_app/lib/features/activities/data/http_activities_api.dart`
- `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `revision_app/lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`
- `revision_app/lib/features/today/application/today_plan_controller.dart`
- `revision_app/lib/features/today/data/http_today_repository.dart`
- `revision_app/lib/features/today/domain/today_plan.dart`

## 3. LOT-002 — Décisions fondations IA et documentaire

### 3.1 `DocumentChunk`

#### Option A — Pas de chunks

Avantages :

- Aucun changement de schéma.
- Pipeline actuel plus simple.
- Moins de données textuelles stockées en base.

Limites :

- Les notions, fiches et corrections ne peuvent pas pointer vers une source stable.
- Le backend ne peut pas vérifier qu’un `sourceExcerpt` proposé par l’IA vient réellement du cours.
- Les futures corrections ouvertes risquent de citer des passages inventés ou approximatifs.
- Une régénération de résumé ou de QCM ne peut pas réutiliser des unités de contexte contrôlées.

Conclusion : option insuffisante pour une démo Genkit sérieuse.

#### Option B — Chunks temporaires non persistés

Avantages :

- Moins de migration initiale.
- Permet de donner à Genkit un contexte découpé au moment du processing.
- Réduit la taille de la base.

Limites :

- Les `chunkId` ne survivent pas au job de processing.
- Une fiche ou une correction générée plus tard ne peut plus prouver ses sources.
- L’UI ne peut pas afficher un extrait fiable à partir d’un identifiant stable.
- Les tests anti-hallucination sont plus faibles, car la source disparaît après exécution.

Conclusion : acceptable pour un prototype jetable, pas pour le MVP.

#### Option C — Chunks persistés en DB

Avantages :

- Chaque citation peut pointer vers un `chunkId` connu.
- Les notions peuvent être reliées à des morceaux de cours vérifiables.
- Les résumés, fiches, QCM et corrections peuvent être sourcés sans demander à l’IA d’inventer des extraits.
- Les tests peuvent vérifier qu’un output IA ne référence que des chunks appartenant au bon document et au bon étudiant.
- Le futur GenUI peut afficher des `SourceExcerptCard` à partir de données serveur validées.

Limites :

- Première migration nécessaire.
- Stockage de texte de cours en DB, donc vigilance sur confidentialité et volumétrie.
- Il faut définir une stratégie de chunking simple et stable.

Recommandation :

Introduire un `DocumentChunk` minimal persisté pour le MVP Cut 1.

Le chunk doit être produit côté backend après extraction PDF, avant l’appel Genkit d’extraction des notions. Il doit rester simple :

- `id`
- `documentId`
- `subjectId`
- `index`
- `text`
- `charStart`
- `charEnd`
- `pageNumber` optionnel
- `createdAt`

Le champ `pageNumber` ne doit pas être obligatoire tant que `pdf-parse` ne fournit pas une pagination suffisamment fiable dans le pipeline actuel.

Le texte complet du cours ne doit jamais être écrit dans les logs. Le stockage DB des chunks est acceptable pour le MVP, car il est nécessaire à la vérifiabilité des sources, mais il doit rester borné par des limites de taille.

### 3.2 Lien notion-source

#### Option A — Champ JSON dans `KnowledgeUnit`

Avantages :

- Migration simple.
- Permet de stocker rapidement une liste de références.

Limites :

- Pas d’intégrité référentielle vers les chunks.
- Requêtes plus fragiles.
- Plus difficile de garantir l’ownership `studentId` via relations.
- Validation plus complexe dans les repositories.

Conclusion : trop fragile pour une fondation documentaire.

#### Option B — Table dédiée `KnowledgeUnitSource`

Avantages :

- Relation explicite entre une notion et ses chunks sources.
- Intégrité référentielle côté DB.
- Modèle simple et lisible.
- Requêtes faciles pour afficher les sources d’une notion.
- Bon compromis entre robustesse et simplicité.

Limites :

- Migration supplémentaire.
- Spécifique aux notions, donc il faudra peut-être une autre table pour les sources de fiches plus tard.

Conclusion : meilleure option pour le MVP.

#### Option C — Table générique `SourceReference`

Avantages :

- Peut servir à plusieurs objets : notion, résumé, fiche, correction, bloc GenUI.
- Centralise la logique de sources.

Limites :

- Modèle polymorphe plus difficile à maintenir avec Prisma.
- Risque d’abstraction prématurée.
- Plus de validations applicatives pour éviter les références incohérentes.
- Peut ralentir l’exécution des premiers lots.

Conclusion : intéressant plus tard, trop large maintenant.

Recommandation :

Créer plus tard une table dédiée `KnowledgeUnitSource` pour relier `KnowledgeUnit` à `DocumentChunk`.

Forme cible minimale :

- `knowledgeUnitId`
- `subjectId`
- `chunkId`
- `relevanceScore` optionnel
- `createdAt`

La relation avec `KnowledgeUnit` doit idéalement utiliser `knowledgeUnitId + subjectId`, car `KnowledgeUnit` possède déjà `@@unique([id, subjectId])`. Cela aide à maintenir l’alignement avec le périmètre matière.

### 3.3 `SourceReference`

#### Option A — Pas de `SourceReference` globale

Avantages :

- Modèle plus simple.
- Chaque usage garde une relation lisible.
- Moins de risques de polymorphisme fragile.

Limites :

- Duplication possible plus tard entre `KnowledgeUnitSource`, `SummarySource`, `RevisionSheetSource` ou `CorrectionSource`.

Conclusion : bon choix initial.

#### Option B — Table dédiée par usage

Avantages :

- Très explicite.
- Chaque artefact peut imposer ses propres contraintes.
- Simple à tester.

Limites :

- Peut créer plusieurs tables proches.

Conclusion : bonne trajectoire progressive.

#### Option C — Table globale générique

Avantages :

- Centralisation.
- Potentiellement utile si de nombreux artefacts différents doivent citer les mêmes chunks.

Limites :

- Trop générique pour le Cut 1.
- Moins naturel avec Prisma.
- Risque de devoir gérer des couples `targetType` / `targetId` sans vraie clé étrangère.

Conclusion : à reporter.

Recommandation :

Ne pas créer de table `SourceReference` globale dans la première migration.

Pour le MVP Cut 1 :

- `KnowledgeUnitSource` pour les notions.
- Sources de fiches et résumés à décider au moment de `Summary` / `RevisionSheet`.
- Si les artefacts deviennent nombreux et homogènes, réévaluer un modèle `ArtifactSource` ou `SourceReference` plus tard.

### 3.4 Artefacts générés

Artefacts concernés :

- `Summary`
- `RevisionSheet`
- Correction ouverte future
- Blocs GenUI éventuels

#### Option A — Modèles spécialisés uniquement

Avantages :

- Contrats métier clairs.
- Requêtes et API lisibles.
- Validation plus simple.
- Évite une table générique fourre-tout.

Limites :

- Certaines métadonnées IA seront répétées.
- Les sources devront être modélisées par artefact ou dupliquées.

Conclusion : solide pour démarrer.

#### Option B — Modèle transversal `GeneratedArtifact`

Avantages :

- Unifie les artefacts IA.
- Centralise status, metadata, versioning et sources.
- Peut simplifier l’observabilité persistée.

Limites :

- Risque de masquer les différences métier entre résumé, fiche, QCM et correction.
- Peut devenir une table JSON trop permissive.
- Plus dur à exposer proprement côté API et GenUI.

Conclusion : trop ambitieux pour le premier passage.

#### Option C — Modèle hybride

Avantages :

- Modèles métier spécialisés.
- Métadonnées communes partagées ou répétées volontairement.
- Possibilité d’ajouter un `GeneratedArtifact` plus tard si le besoin devient réel.

Limites :

- Demande une discipline de nommage des métadonnées IA.
- Peut nécessiter une consolidation future.

Conclusion : meilleure trajectoire.

Recommandation :

Adopter un modèle hybride progressif :

- Ne pas créer `GeneratedArtifact` dans la première migration.
- Garder `Summary` et `RevisionSheet` comme modèles spécialisés lors du lot dédié aux fiches.
- Répéter les métadonnées IA communes sur les artefacts générés.
- Ne pas stocker de payload GenUI arbitraire dans le MVP Cut 1.
- Construire les blocs GenUI depuis des objets métier validés par le backend et un catalogue frontend borné.

La correction ouverte devra probablement avoir son propre modèle plus tard, car elle porte un barème, des points présents, des points manquants, un score et une réponse modèle.

### 3.5 `AiGenerationJob`

#### Option A — Simple port d’observabilité avec logs structurés

Avantages :

- Aucun changement DB immédiat.
- Permet de tracer rapidement les flows Genkit.
- Suffisant pour diagnostiquer les échecs initiaux.
- Compatible avec les flows synchrones existants.

Limites :

- Pas d’historique requêtable en DB.
- Les données d’observabilité dépendent du système de logs.

Conclusion : meilleur premier pas.

#### Option B — Table persistée d’observabilité

Avantages :

- Historique consultable.
- Utile pour support et analytics.
- Peut lier précisément un artefact à une génération.

Limites :

- Migration supplémentaire.
- Il faut définir une politique de rétention.
- Risque de stocker trop d’informations sensibles si le cadre n’est pas strict.

Conclusion : utile plus tard, pas nécessaire avant les premières fondations.

#### Option C — Vraie queue/job de génération IA

Avantages :

- Adapté aux générations longues.
- Meilleure robustesse face aux timeouts.
- Permet un statut consultable côté UI.

Limites :

- Complexifie le MVP.
- BullMQ existe déjà pour le processing document, mais l’orchestration des artefacts IA demanderait de nouveaux jobs, endpoints et statuts.

Conclusion : à garder pour les générations longues, pas pour le cadrage immédiat.

Recommandation :

Ne pas créer `AiGenerationJob` maintenant.

Créer d’abord, dans le lot d’observabilité Genkit, un port applicatif du type conceptuel `AiGenerationObserver` :

- début de flow ;
- succès ;
- erreur ;
- durée ;
- provider ;
- modèle ;
- versions de prompt et de schéma ;
- taille d’entrée approximative.

La table `AiGenerationJob` pourra être réévaluée quand les résumés, fiches et corrections ouvertes auront un besoin clair de statut persistant ou de génération asynchrone.

### 3.6 Générations synchrones ou asynchrones

#### Résumé / fiche

Options :

- Synchrone pour résumé court.
- Asynchrone via BullMQ.
- Hybride selon taille du document.

Recommandation :

Adopter une stratégie hybride, mais commencer simple :

- Synchrone pour un résumé ou une fiche généré depuis un document court et déjà chunké.
- Refus ou bascule future vers async si le nombre de chunks ou la taille d’entrée dépasse un seuil.
- Timeout strict côté backend.
- Erreur explicite côté frontend si le document est trop long.

Pour le MVP Cut 1, le PDF de démo doit rester court pour éviter de construire une orchestration de génération trop tôt.

#### QCM

Options :

- Synchrone comme aujourd’hui.
- Async via job.

Recommandation :

Conserver la génération synchrone pour le QCM.

Le QCM est une activité interactive attendue immédiatement. Le flow actuel existe déjà et peut être enrichi progressivement avec sources, difficulté et feedback.

#### Correction ouverte future

Options :

- Synchrone avec réponse courte.
- Async avec statut de correction.
- Hybride.

Recommandation :

Prévoir un démarrage synchrone pour le premier effet démo, avec limites strictes :

- longueur maximale de réponse étudiant ;
- timeout ;
- correction basée sur chunks autorisés ;
- erreur explicite si le modèle ne répond pas dans le délai.

Si la correction devient lente ou coûteuse, ajouter un job asynchrone plus tard.

### 3.7 Métadonnées IA communes

Métadonnées communes à tous les outputs IA :

- `flowName`
- `provider`
- `model`
- `promptVersion`
- `schemaVersion`
- `inputSize`
- `durationMs`
- `status`
- `errorCode`

Recommandation de persistance :

À persister sur les artefacts générés quand ils existeront :

- `flowName`
- `provider`
- `model`
- `promptVersion`
- `schemaVersion`
- `status`
- `errorCode`
- `generatedAt`

À garder dans les logs structurés :

- `inputSize`
- `durationMs`
- `status`
- `errorCode`
- identifiants techniques : `studentId`, `subjectId`, `documentId`, `activitySessionId` si applicable.

À ne jamais logger :

- texte complet du cours ;
- prompt complet ;
- completion complète ;
- réponse complète de l’étudiant si elle peut contenir des données personnelles.

Le champ `inputSize` doit mesurer une taille non sensible : nombre de caractères, nombre de chunks ou nombre de tokens estimé, pas le contenu.

### 3.8 Règles anti-hallucination

Règles non négociables :

- L’IA ne doit pas produire librement des sources non vérifiables.
- Les outputs IA qui référencent un `chunkId` inconnu doivent être rejetés.
- Les outputs IA qui référencent un chunk d’un autre document, d’une autre matière ou d’un autre étudiant doivent être rejetés.
- Les citations affichées côté frontend doivent venir du texte stocké dans `DocumentChunk`, pas d’un champ libre `sourceExcerpt` généré par l’IA.
- Les prompts doivent interdire explicitement l’usage de connaissances externes quand la réponse est censée venir d’un document.
- Les flows Genkit doivent produire des DTO structurés et validés par Zod.
- Les schémas IA doivent être versionnés.
- Le frontend ne doit pas interpréter du texte IA libre comme UI.
- GenUI doit uniquement afficher des composants du catalogue validé.
- Les logs ne doivent jamais contenir le texte complet du cours, le prompt complet ou la completion complète.
- Les erreurs IA doivent être explicites pour l’utilisateur, mais sans exposer les détails internes du provider.

## 4. LOT-002B — Revue de schéma avant migrations

### 4.1 Schéma actuel résumé

#### `Document`

Champs pertinents :

- `id`
- `studentId`
- `subjectId`
- `kind`
- `fileName`
- `storagePath`
- `mimeType`
- `status`
- `errorCode`
- `createdAt`
- `updatedAt`

Relations :

- `subject`
- `knowledgeUnits`
- `jobs`

Constat :

- `Document` porte le chemin de stockage local.
- Le modèle ne contient pas encore d’information de chunking.
- Le DTO repository actuel expose encore `storagePath`, ce qui devra être corrigé avant exposition produit plus large.

#### `DocumentProcessingJob`

Champs pertinents :

- `id`
- `documentId`
- `status`
- `attempts`
- `createdAt`
- `updatedAt`

Constat :

- Le job document existe déjà.
- Il sert au processing PDF et à l’extraction Genkit.
- Le champ `attempts` existe, mais il faudra vérifier dans un lot futur s’il est correctement maintenu par le worker.

#### `KnowledgeUnit`

Champs pertinents :

- `id`
- `subjectId`
- `documentId`
- `title`
- `summary`
- `createdAt`
- `updatedAt`

Relations :

- `subject`
- `document`
- `mastery`
- `questions`
- `sessions`

Constat :

- Le modèle est très minimal.
- Il ne persiste pas encore `difficulty`, `confidence`, ordre d’apparition, version de prompt ou sources.
- L’interface IA contient déjà `sourceExcerpt` et `difficulty`, mais le repository ne persiste actuellement que `title` et `summary`.

#### `ActivitySession`

Champs pertinents :

- `id`
- `studentId`
- `subjectId`
- `knowledgeUnitId`
- `type`
- `status`
- `createdAt`
- `completedAt`

Constat :

- Le modèle supporte actuellement le diagnostic quiz.
- L’enum `ActivityType` ne contient que `DIAGNOSTIC_QUIZ`.
- Les questions ouvertes et sessions coach devront attendre une migration dédiée.

#### `Question`

Champs pertinents :

- `id`
- `sessionId`
- `knowledgeUnitId`
- `prompt`
- `choices`
- `correctChoiceId`
- `explanation`

Constat :

- Le modèle est orienté QCM.
- Les choix sont en JSON.
- Les explications existent déjà mais doivent être mieux exploitées après soumission.

#### `ActivityResult`

Champs pertinents :

- `id`
- `sessionId`
- `correctAnswers`
- `totalQuestions`
- `createdAt`

Constat :

- Résultat global simple.
- Pas encore de détail par question.
- Pas encore de feedback fin par notion ou par source.

#### `MasteryState`

Champs pertinents :

- `studentId`
- `subjectId`
- `knowledgeUnitId`
- `score`
- `lastPracticedAt`
- `updatedAt`

Constat :

- Modèle utile pour le plan du jour actuel.
- Suffisant pour un premier ranking.
- Les futurs événements de maîtrise pourront être ajoutés plus tard si besoin d’historique.

### 4.2 Migration MVP Cut 1 recommandée

Périmètre exact recommandé pour la première migration future :

1. Ajouter `DocumentChunk`.
2. Ajouter `KnowledgeUnitSource`.
3. Enrichir `KnowledgeUnit` avec des champs minimaux utiles au grounding :
   - `difficulty`
   - `displayOrder`
   - `confidence`
   - `extractionPromptVersion`
   - `extractionSchemaVersion`

Ne pas inclure `Summary` et `RevisionSheet` dans cette première migration.

Justification :

- La première migration doit stabiliser les sources avant de créer des artefacts qui les utilisent.
- Les fiches et résumés auront une meilleure base si les chunks et liens notion-source sont déjà testés.
- Cela limite le risque de migrations successives trop grosses et difficiles à corriger.

`Summary` et `RevisionSheet` doivent être traités dans une migration suivante, au moment du lot dédié aux fiches.

### 4.3 Migrations à reporter

À reporter explicitement :

- `Summary`
- `RevisionSheet`
- `OpenQuestion`
- `OpenAnswerEvaluation`
- `RevisionSession`
- `GeneratedUiBlock`
- `AiGenerationJob`
- `GeneratedArtifact`
- `TodayPlan` avancé persistant
- imports OCR
- imports image
- imports audio
- modèle `SourceReference` global générique
- stockage de payload GenUI arbitraire

Nuance :

`Summary` et `RevisionSheet` sont prioritaires pour le MVP, mais ne doivent pas être dans la première migration de fondation documentaire. Ils doivent venir juste après validation de `DocumentChunk` et `KnowledgeUnitSource`.

### 4.4 Proposition de modèle cible minimal

Proposition documentaire uniquement. Ce pseudo-schema n’est pas appliqué et ne doit pas être copié tel quel sans revue Prisma complète.

```prisma
// Proposition non appliquée
enum KnowledgeUnitDifficulty {
  LOW
  MEDIUM
  HIGH
}

// Proposition non appliquée
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

  document Document @relation(fields: [documentId, subjectId], references: [id, subjectId], onDelete: Cascade)
  sources  KnowledgeUnitSource[]

  @@unique([documentId, index])
  @@index([documentId])
  @@index([subjectId])
}

// Proposition non appliquée
model KnowledgeUnit {
  id                      String   @id @default(cuid())
  subjectId               String
  documentId              String?
  title                   String
  summary                 String
  difficulty              KnowledgeUnitDifficulty?
  displayOrder            Int?
  confidence              Float?
  extractionPromptVersion String?
  extractionSchemaVersion String?
  createdAt               DateTime @default(now())
  updatedAt               DateTime @updatedAt

  sources KnowledgeUnitSource[]

  @@unique([id, subjectId])
  @@index([documentId])
  @@index([subjectId])
}

// Proposition non appliquée
model KnowledgeUnitSource {
  knowledgeUnitId String
  subjectId       String
  chunkId         String
  relevanceScore  Float?
  createdAt       DateTime @default(now())

  knowledgeUnit KnowledgeUnit @relation(fields: [knowledgeUnitId, subjectId], references: [id, subjectId], onDelete: Cascade)
  chunk         DocumentChunk @relation(fields: [chunkId], references: [id], onDelete: Cascade)

  @@id([knowledgeUnitId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}
```

Points à valider avant application :

- Nom exact de l’enum `KnowledgeUnitDifficulty`.
- Valeurs exactes de difficulté.
- Nécessité ou non de stocker `subjectId` dans `DocumentChunk`.
- Longueur maximale de `text`.
- Index nécessaires pour les endpoints document/detail et notion/detail.
- Politique de suppression en cascade.

### 4.5 Impacts repositories/use cases

Backend probablement impacté plus tard :

- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/documents/domain/document-text-extractor.ts`
- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`

Use cases probablement impactés :

- `UploadCoursePdfUseCase`, indirectement, si le document detail doit exposer une préparation au chunking.
- `DocumentProcessingConsumer`, directement, car il devra :
  - extraire le texte ;
  - produire les chunks ;
  - appeler Genkit avec des chunks identifiés ;
  - valider les `chunkId` retournés ;
  - persister les notions et liens sources.
- Les futurs use cases de résumé et fiche.
- Les futurs use cases de question ouverte corrigée.

Frontend probablement impacté plus tard :

- `revision_app/lib/features/documents/domain/revision_document.dart`
- `revision_app/lib/features/documents/data/documents_api.dart`
- futures pages de détail document et notion ;
- futurs widgets `SourceExcerptCard` et `SummaryCard`.

### 4.6 Critères de stop avant LOT-010

Ne pas lancer une vraie migration de chunking tant que les points suivants ne sont pas validés :

- Le chemin d’upload officiel reste `POST /documents/course-pdf`.
- L’API et le worker partagent bien le même stockage local persistant en environnement déployé.
- Le nom et le périmètre de `DocumentChunk` sont validés.
- Le choix `KnowledgeUnitSource` est validé.
- Le modèle global `SourceReference` est explicitement reporté.
- La taille cible des chunks est décidée.
- Le comportement sur PDF trop long est décidé.
- Le niveau de fiabilité de `pageNumber` avec `pdf-parse` est accepté comme optionnel.
- Les DTO publics ne doivent pas exposer `storagePath`.
- Les règles de logs anti-fuite sont validées.
- Les tests attendus de repository, worker, ownership et extraction invalide sont listés avant implémentation.

## 5. LOT-003 — Golden demo baseline

### 5.1 Choix du document de démo

Document recommandé :

Un PDF synthétique créé pour la démo, texte natif, de 4 à 6 pages, intitulé par exemple :

`Droit constitutionnel — contrôle de constitutionnalité et séparation des pouvoirs`

Critères :

- PDF texte, pas scanné.
- Court.
- Légalement utilisable, car créé pour le projet.
- Sans données personnelles.
- Structuré avec titres, sous-titres et paragraphes courts.
- Contenu suffisamment riche pour générer notions, fiche, QCM et question ouverte.
- Réutilisable plusieurs fois en démo sans dépendre d’un document tiers.

Ne pas utiliser comme golden PDF un cours utilisateur réel, même si l’import fonctionne, car il peut contenir des données personnelles, des droits d’auteur ou une structure imprévisible.

### 5.2 Matière de démo

Matière recommandée :

`Droit constitutionnel`

Pourquoi :

- Cohérent avec les tests manuels déjà réalisés par l’utilisateur.
- Les notions sont abstraites mais structurées.
- Les erreurs de sujet sont faciles à détecter : une question d’anatomie dans cette matière est immédiatement visible.
- Les sources textuelles sont importantes, ce qui valorise bien le grounding par chunks.
- Le contenu permet des QCM et des questions ouvertes pertinentes.

Alternatives possibles :

- Histoire : facile à comprendre, mais peut encourager le modèle à compléter avec des connaissances externes.
- Biologie : bon pour QCM, mais moins aligné avec le problème constaté d’anatomie hors sujet.
- Informatique : intéressant techniquement, mais moins universel pour une démo étudiante généraliste.

### 5.3 Notions attendues

Le PDF de démo devrait permettre d’extraire 5 à 10 notions parmi :

1. Constitution et hiérarchie des normes.
2. Séparation des pouvoirs.
3. Pouvoir constituant et pouvoir constitué.
4. Bloc de constitutionnalité.
5. Conseil constitutionnel.
6. Contrôle de constitutionnalité a priori.
7. Question prioritaire de constitutionnalité.
8. Contrôle de constitutionnalité a posteriori.
9. Effets d’une décision d’inconstitutionnalité.
10. Limites de la révision constitutionnelle.

Chaque notion devrait pouvoir pointer vers au moins un chunk source du PDF.

### 5.4 Résultats attendus du golden path

#### Import PDF

Résultat attendu :

- L’utilisateur choisit un PDF via `file_picker`.
- Le frontend envoie un multipart `POST /documents/course-pdf`.
- Le backend crée un `Document` en `UPLOADED` ou `PROCESSING`.
- Le document apparaît dans la matière.

Preuve attendue :

- Statut visible côté UI.
- Entrée `Document` en base.
- Fichier présent dans le stockage local backend.

#### Processing

Résultat attendu :

- BullMQ lance `DocumentProcessingConsumer`.
- Le worker lit le fichier via `LocalDocumentFileStorage.read(storagePath)`.
- Le PDF est extrait par `pdf-parse`.
- Le document passe en `READY` si tout réussit.

Preuve attendue :

- Statut `READY`.
- Job `COMPLETED`.
- Absence d’erreur `FAILED`.

#### Chunks

Résultat attendu futur :

- Le backend crée des chunks stables.
- Les chunks ont un index déterministe.
- Les chunks restent liés au document et à la matière.

Preuve attendue :

- Liste de chunks consultable via logs de test ou endpoint interne futur.
- Aucun texte complet du PDF dans les logs.

#### Notions

Résultat attendu :

- 5 à 10 notions sont extraites.
- Chaque notion possède un titre clair, un résumé court, une difficulté et une confiance si disponibles.
- Chaque notion pointe vers au moins un chunk source.

Preuve attendue :

- Notions affichées dans le détail document ou matière.
- Sources affichables depuis les chunks.
- Aucune notion hors sujet.

#### Fiche générée

Résultat attendu futur :

- Depuis un document `READY`, l’utilisateur génère une fiche.
- La fiche contient :
  - résumé express ;
  - points clés ;
  - pièges classiques ;
  - références aux notions ;
  - sources vérifiables.

Preuve attendue :

- Fiche visible côté UI.
- Sources affichées depuis les chunks stockés.
- Métadonnées IA enregistrées ou loggées.

#### Sources affichées

Résultat attendu futur :

- Les citations visibles viennent du backend.
- Le frontend ne reçoit pas un extrait libre non vérifié comme source d’autorité.
- Les cartes de source affichent un passage tiré d’un `DocumentChunk`.

Preuve attendue :

- `chunkId` connu.
- Chunk appartenant au document courant.
- Aucun affichage de source si le `chunkId` est invalide.

#### GenUI source/summary plus tard

Résultat attendu futur :

- GenUI affiche un `SummaryCard` et un `SourceExcerptCard` via le catalogue validé.
- Le payload GenUI ne peut pas créer de widget arbitraire.
- En cas de payload invalide, l’UI native prend le relais.

Preuve attendue :

- Validation du payload.
- Fallback visible en test.
- Catalogue borné.

### 5.5 Checklist manuelle de démo

Checklist cible :

1. Lancer l’API, le worker, Postgres et Redis.
2. Vérifier que `DOCUMENT_STORAGE_ROOT` pointe vers un stockage persistant partagé par API et worker.
3. Lancer l’app Flutter.
4. Se connecter avec un compte de test.
5. Créer une matière `Droit constitutionnel`.
6. Importer le PDF synthétique de démo.
7. Vérifier que le document apparaît avec un statut non final.
8. Attendre le passage en `READY`.
9. Ouvrir le détail de la matière ou du document.
10. Vérifier que les notions détectées sont liées au droit constitutionnel.
11. Vérifier qu’aucune question ou notion hors sujet n’apparaît.
12. Vérifier que chaque notion affichée possède au moins une source quand les chunks seront implémentés.
13. Générer une fiche quand le lot correspondant existera.
14. Vérifier que les extraits affichés correspondent au PDF.
15. Lancer un QCM.
16. Vérifier que les questions portent sur le droit constitutionnel.
17. Répondre au QCM.
18. Vérifier que le score met à jour la maîtrise.
19. Lancer une question ouverte quand le lot correspondant existera.
20. Vérifier que la correction mentionne les points présents, les points manquants et une réponse modèle.
21. Ouvrir `Aujourd’hui`.
22. Vérifier que le plan reflète les notions faibles.
23. Lancer une session GenUI simple quand le catalogue sera prêt.
24. Vérifier que les composants affichés sont uniquement ceux du catalogue.

### 5.6 Données seed futures

Données à prévoir plus tard, sans création de seed maintenant :

- Un étudiant de démonstration avec `firebaseUid` de test.
- Une matière `Droit constitutionnel`.
- Un PDF synthétique placé dans le stockage local de démo.
- Un document `READY`.
- Des chunks déterministes associés au document.
- 5 à 10 notions attendues.
- Des liens `KnowledgeUnitSource`.
- Une fiche générée stable pour présentation.
- Un QCM de démonstration stable.
- Un état de maîtrise partiellement faible pour rendre `Aujourd’hui` intéressant.

Le seed doit rester optionnel et séparé des migrations. Il ne doit pas masquer le vrai golden path d’import et processing.

## 6. Synthèse des décisions

| Décision | Options comparées | Recommandation | Impact | Lot futur concerné |
| --- | --- | --- | --- | --- |
| `DocumentChunk` | Aucun chunk, chunks temporaires, chunks persistés | Créer des chunks persistés minimaux | Fondation anti-hallucination, sources vérifiables | LOT-010 |
| Lien notion-source | JSON, `KnowledgeUnitSource`, `SourceReference` globale | Utiliser `KnowledgeUnitSource` | Intégrité référentielle et requêtes simples | LOT-010 |
| `SourceReference` globale | Pas de table, table par usage, table globale | Reporter la table globale | Évite polymorphisme prématuré | LOT-018+ |
| Artefacts IA | Modèles spécialisés, `GeneratedArtifact`, hybride | Hybride progressif sans `GeneratedArtifact` immédiat | Résumés/fiches spécialisés, GenUI dérivé de données validées | LOT-018, LOT-029 |
| `AiGenerationJob` | Logs structurés, table observabilité, queue IA | Commencer par logs structurés via port d’observabilité | Diagnostic IA sans migration immédiate | LOT-004 |
| Génération résumé/fiche | Synchrone, async, hybride | Hybride, synchrone pour document court au départ | Démo rapide, async reporté si besoin | LOT-018 |
| Génération QCM | Synchrone, async | Garder synchrone | Activité interactive immédiate | LOT-022 |
| Correction ouverte | Synchrone, async, hybride | Synchrone borné au départ | Effet démo sans orchestration lourde | LOT-026 |
| Métadonnées IA | Tout en DB, tout en logs, mix | Persister versions et modèle sur artefacts, logs pour durée et input size | Observabilité sans fuite de contenu | LOT-004, LOT-018 |
| Golden PDF | Document réel, document tiers, PDF synthétique | PDF synthétique de droit constitutionnel | Démo légale, stable et vérifiable | LOT-003, LOT-037 |

## 7. Gaps restants

Gaps techniques :

- Taille exacte des chunks à décider.
- Stratégie de chevauchement entre chunks à décider.
- Fiabilité de `pageNumber` avec `pdf-parse` à vérifier.
- Politique de suppression des chunks si un document est supprimé.
- Politique de rétention du texte stocké en DB.
- Vérification que l’API et le worker partagent bien le même volume en déploiement Dokploy.
- Correction future du DTO document pour ne pas exposer `storagePath`.
- Comportement exact si Genkit renvoie une notion sans `chunkId`.
- Format définitif des versions `promptVersion` et `schemaVersion`.
- Seuils de taille pour génération synchrone.

Gaps produit :

- Contenu exact du PDF synthétique de démo à rédiger.
- Nombre optimal de notions à afficher dans la première UI.
- Design final des cartes source, résumé et notion.
- Choix des premiers composants GenUI à rendre visuellement premium.

Gaps tests :

- Fixtures PDF à créer.
- Tests d’ownership chunk/source à définir.
- Tests anti-source inventée à écrire.
- Tests de non-log du texte complet à cadrer.

## 8. Recommandation pour le prochain lot

Prochain lot recommandé : `LOT-004 — Port d’observabilité Genkit`.

Justification :

- Les prochains changements IA et documentaires doivent être diagnostiquables avant d’élargir les flows.
- Le problème déjà observé de QCM hors sujet montre qu’il faut voir quel flow, modèle, provider, prompt et schéma produisent chaque output.
- L’observabilité doit arriver avant la migration de chunks et avant les résumés, sinon les échecs seront difficiles à comprendre.
- Le lot peut rester petit et sans refactor massif.

Ordre conseillé ensuite :

1. `LOT-004 — Port d’observabilité Genkit`.
2. `LOT-005 — Instrumentation des flows IA existants`.
3. `LOT-006 — Inventaire design system`.
4. `LOT-009 — Design final de la migration documentaire`.
5. `LOT-010 — Migration DocumentChunk et KnowledgeUnitSource`.

`LOT-006` peut être travaillé en parallèle par une autre personne, car il touche surtout le frontend, mais il ne débloque pas la fiabilité IA autant que l’observabilité Genkit.
