# LOT-025B — QCM questionCount configurable et contrat média/multi-réponse

## 1. Résultat

Le backend QCM accepte maintenant un `questionCount` optionnel sur `POST /activities/next`.

Le comportement par défaut passe à 10 questions, avec un plafond strict à 20 questions. Les anciens clients restent compatibles : s'ils n'envoient pas `questionCount`, le backend résout la valeur par défaut.

Le générateur QCM reçoit le nombre cible, l'inscrit dans le prompt, accepte jusqu'à 20 questions dans le schéma Genkit, et rejette une sortie IA qui ne respecte pas le nombre explicitement demandé par le runtime.

Le lot ne crée aucun support média ou multi-réponse runtime. Il documente uniquement le contrat futur nécessaire pour images, graphiques, diagrammes et questions multi-réponses.

## 2. Sources inspectées

Documentation :

* `revision_app/docs/ROADMAP.md`
* `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_022.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_025.md`
* `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_024B_AI_MODEL_FALLBACK.md`
* `revision_app/AGENTS.md`

Backend :

* `api/package.json`
* `api/.env.example`
* `api/prisma/schema.prisma`
* `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
* `api/src/modules/activities/application/start-next-activity.use-case.ts`
* `api/src/modules/activities/application/start-next-activity.use-case.spec.ts`
* `api/src/modules/activities/application/activities.repository.ts`
* `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
* `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
* `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
* `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
* `api/src/modules/activities/interfaces/activities.controller.ts`
* `api/src/modules/activities/activities.module.spec.ts`
* `api/src/modules/ai/application/ai-generation-observer.ts`
* `api/src/modules/ai/infrastructure/mistral-model-fallback.ts`

Frontend en lecture seule :

* `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
* `revision_app/lib/presentation/pages/activities/diagnostic_quiz_page.dart`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_025.md`

## 3. Préflight Git / Prisma

État initial API :

* Branche : `main...origin/main`
* Aucun fichier modifié ou non suivi au début du lot.

État initial frontend/docs :

* Branche : `main...origin/main`
* Aucun fichier modifié ou non suivi au début du lot.

Préflight validé :

* `revision_app/docs/ROADMAP_EXECUTION_LOT_025.md` existe.
* `revision_app/docs/ROADMAP_EXECUTION_PLAN.md` existe.
* `cd api && npm run build` passe avant modification.
* `cd api && npx prisma validate` passe avant modification.
* `cd api && npm run prisma:generate` passe avant modification.

Décision sur fichiers hors scope :

* Aucun fichier Flutter applicatif n'a été modifié.
* Aucun fichier Prisma ou migration n'a été modifié.
* Aucun fichier GenUI n'a été modifié.

## 4. Problème initial

Le frontend enrichi de `LOT-025` sait afficher des QCM longs, y compris 15 questions en test, mais le runtime réel continuait souvent à produire seulement 2 ou 3 questions.

La limite ne venait pas de l'UI. Le backend/générateur QCM avait encore :

* une valeur par défaut interne de 3 questions ;
* un plafond de schéma à 5 questions ;
* un comportement de clamp silencieux si une demande dépassait le plafond.

Le produit a besoin de QCM plus gros, idéalement 10 à 20 questions quand le contenu le permet, sans sacrifier les sources, la qualité ni la protection anti-fuite.

## 5. questionCount configurable

Variables d'environnement ajoutées :

```env
DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT="10"
DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT="20"
```

Comportement :

* si `questionCount` est absent, le backend utilise `DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT` ;
* si l'env de défaut est absente ou invalide, le défaut code est `10` ;
* si l'env max est absente ou invalide, le max code est `20` ;
* le max est plafonné à `20`, même si l'env indique plus ;
* le minimum est `1` ;
* une valeur explicite invalide est rejetée en `400` ;
* il n'y a pas de clamp silencieux d'une demande utilisateur.

La valeur résolue est transmise par :

* `ActivitiesController` ;
* `StartNextActivityUseCase` ;
* `DiagnosticQuizGenerator` ;
* `GenkitDiagnosticQuizGenerator`.

Stratégie si le modèle renvoie moins que demandé :

* le runtime passe toujours un `questionCount` résolu au générateur ;
* si la sortie IA contient un nombre de questions différent, elle est rejetée avec `DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID` ;
* cette erreur est traitée comme une sortie IA invalide et peut déclencher le fallback modèle Mistral introduit par `HOTFIX-024B` ;
* on ne complète jamais artificiellement les questions manquantes ;
* on n'accepte jamais des questions hors cours pour atteindre un volume arbitraire.

## 6. Contrat API

Endpoint existant :

```http
POST /activities/next
```

Payload compatible :

```json
{
  "subjectId": "subject-1",
  "knowledgeUnitId": "unit-1"
}
```

Payload enrichi :

```json
{
  "subjectId": "subject-1",
  "knowledgeUnitId": "unit-1",
  "questionCount": 10
}
```

Règles :

* `subjectId` reste obligatoire ;
* `knowledgeUnitId` reste optionnel ;
* `questionCount` est optionnel ;
* `questionCount` doit être un entier ;
* `questionCount` doit être compris entre `1` et le max configuré, plafonné à `20` ;
* `0`, valeur négative, décimale, chaîne de caractères ou valeur trop haute retournent `400`.

Le DTO public pré-submit ne change pas et ne doit toujours pas exposer :

* `correctChoiceId` ;
* `isCorrect` ;
* `explanation` ;
* `feedback` ;
* texte complet des sources.

## 7. Prompt et schéma Genkit

Le prompt QCM v2 demande maintenant explicitement :

* exactement `questionCount` questions ;
* des questions variées ;
* aucune redondance volontaire ;
* plusieurs angles de la notion quand les sources le permettent ;
* aucune connaissance externe ;
* aucune source libre ;
* des questions strictement justifiables par le cours.

Le schéma Genkit accepte maintenant jusqu'à 20 questions.

Validation conservée :

* QCM mono-réponse ;
* 2 à 4 choix par question ;
* IDs de choix uniques ;
* `correctChoiceId` appartenant aux choix ;
* explication obligatoire ;
* sources obligatoires en mode v2 sourcé ;
* rejet des sources inconnues ;
* rejet des champs inconnus par schéma strict.

Fallback :

* `DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID` est inclus dans les erreurs de sortie IA invalides éligibles au fallback modèle ;
* le fallback ne rend jamais une sortie invalide valide ;
* si le fallback échoue aussi, l'erreur reste propagée.

## 8. Sécurité anti-fuite

Le lot ne modifie pas le contrat public pré-submit.

Garanties maintenues :

* pas de `correctChoiceId` pré-submit ;
* pas de `isCorrect` pré-submit ;
* pas d'explication pré-submit ;
* pas de feedback pré-submit ;
* pas de texte source complet pré-submit ;
* le frontend ne calcule pas la correction ;
* le backend reste source de vérité pour la correction ;
* les sources inconnues restent rejetées ;
* aucune source fictive n'est créée.

## 9. Contrat futur images/graphiques

Les médias ne sont pas implémentés dans ce lot.

Contrat conceptuel futur :

```ts
type QuestionVisual =
  | QuestionImageVisual
  | QuestionChartVisual
  | QuestionDiagramVisual;
```

Image :

```ts
type QuestionImageVisual = {
  type: 'image';
  imageUrl: string;
  altText: string;
  caption?: string;
  sourceChunkIds: string[];
};
```

Graphique :

```ts
type QuestionChartVisual = {
  type: 'chart';
  chartType: 'bar' | 'line' | 'pie' | 'scatter';
  title: string;
  description?: string;
  data: unknown;
  sourceChunkIds: string[];
};
```

Diagramme :

```ts
type QuestionDiagramVisual = {
  type: 'diagram';
  title: string;
  description?: string;
  steps: Array<{
    id: string;
    label: string;
  }>;
  sourceChunkIds: string[];
};
```

Contraintes futures :

* aucun média arbitraire généré sans validation ;
* aucune URL externe non contrôlée ;
* images issues du document ou du stockage applicatif validé ;
* `altText` obligatoire ;
* `sourceChunkIds` obligatoires ;
* chart specs bornés et typés ;
* pas de HTML libre ;
* pas de SVG libre généré par IA ;
* pas de base64 image dans un DTO QCM ;
* pas de payload GenUI arbitraire ;
* toutes les sources doivent venir de `DocumentChunk` ou d'un futur modèle de média documentaire validé.

## 10. Contrat futur multi-réponse

La multi-réponse n'est pas implémentée dans ce lot.

Contrat conceptuel futur :

```ts
type QuestionSelectionMode = 'single' | 'multiple';
```

Pré-submit futur :

```json
{
  "id": "question-1",
  "selectionMode": "multiple",
  "minSelections": 1,
  "maxSelections": 3,
  "choices": [
    {
      "id": "choice-1",
      "label": "Réponse A"
    }
  ]
}
```

Soumission future :

```json
{
  "answers": [
    {
      "questionId": "question-1",
      "choiceIds": ["choice-1", "choice-3"]
    }
  ]
}
```

Correction future :

```json
{
  "questionId": "question-1",
  "selectedChoiceIds": ["choice-1", "choice-3"],
  "correctChoiceIds": ["choice-1", "choice-2"],
  "isCorrect": false,
  "partialScore": 0.5,
  "explanation": "Explication pédagogique."
}
```

Contraintes futures :

* `correctChoiceIds` jamais pré-submit ;
* `isCorrect` jamais pré-submit ;
* scoring partiel à définir ;
* double submit interdit ;
* choix inconnus rejetés ;
* multi-réponse uniquement si backend, UI et correction sont cohérents ;
* pas de multi-réponse fake côté frontend.

## 11. Lots futurs proposés

### LOT-025C — QCM média et multi-réponse : contrat backend

Doit inclure :

* choix final des DTOs ;
* choix des modèles Prisma ;
* stratégie source ;
* stratégie média ;
* stratégie multi-réponse ;
* compatibilité avec le QCM v2 actuel.

### LOT-025D — QCM média et multi-réponse : backend

Doit inclure :

* migration ;
* Genkit ;
* validation ;
* persistance ;
* soumission multi-réponse ;
* correction partielle ;
* tests anti-fuite.

### LOT-025E — QCM média et multi-réponse : UI

Doit inclure :

* rendu images ;
* rendu graphiques ;
* sélection multiple ;
* correction partielle ;
* sources ;
* tests.

Alternative :

* reporter les rendus dynamiques GenUI à `LOT-030`, uniquement après un fallback natif sûr.

## 12. Tests créés ou modifiés

Tests modifiés :

* `api/src/modules/activities/activities.module.spec.ts`
* `api/src/modules/activities/application/start-next-activity.use-case.spec.ts`
* `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
* `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`

Tests couverts :

* `POST /activities/next` sans `questionCount` transmet le défaut `10` ;
* `questionCount: 20` est accepté ;
* `0`, négatif, `21`, décimal et chaîne sont rejetés en `400` ;
* `StartNextActivityUseCase` transmet `questionCount` en mode legacy ;
* `StartNextActivityUseCase` transmet `questionCount` en mode v2 sourcé ;
* le prompt contient le nombre demandé ;
* le schéma accepte 20 questions ;
* le schéma rejette plus de 20 questions ;
* une sortie plus courte que demandé est rejetée ;
* la persistance supporte un QCM de 10 questions ;
* les tests de non-régression activities passent.

## 13. Validations lancées

Validations déjà lancées pendant le lot :

```bash
cd api && npm run build
cd api && npx prisma validate
cd api && npm run prisma:generate
cd api && npm test -- genkit-diagnostic-quiz --runInBand
cd api && npm test -- activities --runInBand
cd api && npm test -- ai --runInBand
cd api && npm run lint:check
cd api && git diff --check
cd revision_app && git diff --check
```

Résultats :

* `npm run build` : succès en préflight et en validation finale.
* `npx prisma validate` : succès en préflight et en validation finale.
* `npm run prisma:generate` : succès en préflight et en validation finale.
* `npm test -- genkit-diagnostic-quiz --runInBand` : succès, 19 tests passés.
* `npm test -- activities --runInBand` : succès, 50 tests passés.
* `npm test -- ai --runInBand` : succès, 51 tests passés.
* `npm run lint:check` : succès après corrections manuelles de format et de mock.
* `cd api && git diff --check` : succès.
* `cd revision_app && git diff --check` : succès.

## 14. Validations non lancées

Non lancées volontairement :

* aucune migration : aucun changement Prisma ;
* `prisma migrate deploy` : interdit et hors scope ;
* tests Flutter : aucun code Flutter modifié ;
* `npm test -- revision --runInBand` : non lancé, aucune logique mastery ou module revision modifiée ;
* provider IA réel : interdit ;
* déploiement : interdit ;
* `npm run test:cov` : interdit ;
* `npm run lint` : interdit car peut appliquer des corrections selon configuration.

## 15. Risques restants

* Coût IA plus élevé avec 10 à 20 questions.
* Latence plus élevée.
* Le modèle peut échouer à produire exactement 20 questions fiables.
* Risque de questions redondantes sur des notions pauvres en contenu.
* Médias non implémentés.
* Multi-réponse non implémentée.
* UI 20 questions à valider sur vrais contenus et vrais appareils.
* Le nombre de questions demandé ne garantit pas que le cours contient assez de matière.
* Les migrations DB backend historiques restent à valider en runtime si cela n'a pas été fait côté infrastructure.

## 16. Recommandation prochain lot

Deux chemins sont possibles :

* `LOT-026 — Contrat question ouverte` si la priorité est d'avancer sur les activités ouvertes ;
* `LOT-025C — QCM média et multi-réponse : contrat backend` si la priorité produit est d'enrichir le QCM avant de passer aux questions ouvertes.

Recommandation pragmatique : lancer `LOT-026` si le QCM enrichi actuel suffit pour le MVP immédiat ; sinon lancer `LOT-025C` avant d'ajouter images, graphiques ou multi-réponse.

## 17. Annexe — Code fourni pour review

Cette annexe reprend le patch complet du code livré côté API pour `LOT-025B`. Source : `git show --format= --patch HEAD` sur le commit API `fbf47b4`.

```diff
diff --git a/.env.example b/.env.example
index 0f5b885..37c7d5a 100644
--- a/.env.example
+++ b/.env.example
@@ -13,3 +13,5 @@ MISTRAL_FALLBACK_MODEL=""
 MISTRAL_SUMMARY_FALLBACK_MODEL=""
 MISTRAL_REVISION_SHEET_FALLBACK_MODEL=""
 MISTRAL_DIAGNOSTIC_QUIZ_FALLBACK_MODEL=""
+DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT="10"
+DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT="20"
diff --git a/src/modules/activities/activities.module.spec.ts b/src/modules/activities/activities.module.spec.ts
index 950dbf5..26ce25c 100644
--- a/src/modules/activities/activities.module.spec.ts
+++ b/src/modules/activities/activities.module.spec.ts
@@ -11,6 +11,7 @@ import {
 } from './application/activities.repository';
 import {
   DIAGNOSTIC_QUIZ_GENERATOR,
+  type DiagnosticQuizGenerationInput,
   type GeneratedDiagnosticQuiz,
 } from './application/diagnostic-quiz-generator';
 import { KnowledgeUnit } from '../revision/domain/knowledge-unit.entity';
@@ -57,7 +58,7 @@ describe('ActivitiesModule', () => {
   let diagnosticQuizGenerator: {
     generate: jest.Mock<
       Promise<GeneratedDiagnosticQuiz>,
-      [{ knowledgeUnit: KnowledgeUnit }]
+      [DiagnosticQuizGenerationInput]
     >;
   };
   let revisionRepository: {
@@ -67,6 +68,8 @@ describe('ActivitiesModule', () => {
   };
 
   beforeEach(async () => {
+    delete process.env.DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT;
+    delete process.env.DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT;
     activitiesRepository = {
       findDiagnosticQuizGenerationContext: jest.fn().mockResolvedValue(null),
       createDiagnosticQuiz: jest.fn<
@@ -102,10 +105,7 @@ describe('ActivitiesModule', () => {
     };
     diagnosticQuizGenerator = {
       generate: jest
-        .fn<
-          Promise<GeneratedDiagnosticQuiz>,
-          [{ knowledgeUnit: KnowledgeUnit }]
-        >()
+        .fn<Promise<GeneratedDiagnosticQuiz>, [DiagnosticQuizGenerationInput]>()
         .mockResolvedValue({
           title: 'Diagnostic constitutionnel',
           questions: [
@@ -167,6 +167,8 @@ describe('ActivitiesModule', () => {
 
   afterEach(async () => {
     await app?.close();
+    delete process.env.DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT;
+    delete process.env.DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT;
   });
 
   it('registers activity routes through the app module', async () => {
@@ -186,6 +188,7 @@ describe('ActivitiesModule', () => {
     expect(generateInput?.knowledgeUnit.title).toBe(
       'Revision constitutionnelle',
     );
+    expect(generateInput?.questionCount).toBe(10);
 
     await request(app.getHttpServer())
       .post(`/activities/${nextBody.sessionId}/result`)
@@ -201,6 +204,41 @@ describe('ActivitiesModule', () => {
       });
   });
 
+  it('accepts an explicit activity question count up to the configured max', async () => {
+    await request(app.getHttpServer())
+      .post('/activities/next')
+      .send({
+        subjectId: 'subject-1',
+        knowledgeUnitId: 'unit-1',
+        questionCount: 20,
+      })
+      .expect(201);
+
+    const [generateInput] =
+      diagnosticQuizGenerator.generate.mock.calls[0] ?? [];
+    expect(generateInput?.questionCount).toBe(20);
+  });
+
+  it.each([
+    ['zero', 0],
+    ['negative', -1],
+    ['too high', 21],
+    ['decimal', 1.5],
+    ['string', '10'],
+  ])('rejects %s activity question counts with 400', async (_label, value) => {
+    await request(app.getHttpServer())
+      .post('/activities/next')
+      .send({
+        subjectId: 'subject-1',
+        knowledgeUnitId: 'unit-1',
+        questionCount: value,
+      })
+      .expect(400);
+
+    expect(activitiesRepository.createDiagnosticQuiz).not.toHaveBeenCalled();
+    expect(diagnosticQuizGenerator.generate).not.toHaveBeenCalled();
+  });
+
   it('rejects malformed activity start payloads with 400', async () => {
     await request(app.getHttpServer())
       .post('/activities/next')
diff --git a/src/modules/activities/application/diagnostic-quiz-question-count.ts b/src/modules/activities/application/diagnostic-quiz-question-count.ts
new file mode 100644
index 0000000..f5efa8b
--- /dev/null
+++ b/src/modules/activities/application/diagnostic-quiz-question-count.ts
@@ -0,0 +1,72 @@
+export const DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID =
+  'DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID';
+
+export const DEFAULT_DIAGNOSTIC_QUIZ_QUESTION_COUNT = 10;
+export const DEFAULT_DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT = 20;
+
+type DiagnosticQuizQuestionCountEnv = {
+  DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT?: string;
+  DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT?: string;
+};
+
+export function resolveDiagnosticQuizMaxQuestionCount(
+  env: DiagnosticQuizQuestionCountEnv = process.env,
+): number {
+  return Math.min(
+    parsePositiveInteger(env.DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT) ??
+      DEFAULT_DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT,
+    DEFAULT_DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT,
+  );
+}
+
+export function resolveDiagnosticQuizDefaultQuestionCount(
+  env: DiagnosticQuizQuestionCountEnv = process.env,
+): number {
+  const maxQuestionCount = resolveDiagnosticQuizMaxQuestionCount(env);
+  const configuredDefault = parsePositiveInteger(
+    env.DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT,
+  );
+
+  if (
+    configuredDefault !== null &&
+    configuredDefault >= 1 &&
+    configuredDefault <= maxQuestionCount
+  ) {
+    return configuredDefault;
+  }
+
+  return Math.min(DEFAULT_DIAGNOSTIC_QUIZ_QUESTION_COUNT, maxQuestionCount);
+}
+
+export function resolveDiagnosticQuizQuestionCount(
+  questionCount: number | undefined,
+  env: DiagnosticQuizQuestionCountEnv = process.env,
+): number {
+  const resolvedQuestionCount =
+    questionCount ?? resolveDiagnosticQuizDefaultQuestionCount(env);
+  const maxQuestionCount = resolveDiagnosticQuizMaxQuestionCount(env);
+
+  if (
+    !Number.isInteger(resolvedQuestionCount) ||
+    resolvedQuestionCount < 1 ||
+    resolvedQuestionCount > maxQuestionCount
+  ) {
+    throw new Error(DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID);
+  }
+
+  return resolvedQuestionCount;
+}
+
+function parsePositiveInteger(value: string | undefined): number | null {
+  if (value === undefined || value.trim().length === 0) {
+    return null;
+  }
+
+  const parsed = Number(value);
+
+  if (!Number.isInteger(parsed) || parsed < 1) {
+    return null;
+  }
+
+  return parsed;
+}
diff --git a/src/modules/activities/application/start-next-activity.use-case.spec.ts b/src/modules/activities/application/start-next-activity.use-case.spec.ts
index fec0a30..9e82fca 100644
--- a/src/modules/activities/application/start-next-activity.use-case.spec.ts
+++ b/src/modules/activities/application/start-next-activity.use-case.spec.ts
@@ -38,7 +38,10 @@ describe('StartNextActivityUseCase', () => {
       knowledgeUnitId: 'unit-1',
       quiz: generatedQuiz(),
     });
-    expect(generator.generate.mock.calls[0]?.[0]).toEqual({ knowledgeUnit });
+    expect(generator.generate.mock.calls[0]?.[0]).toEqual({
+      knowledgeUnit,
+      questionCount: 10,
+    });
     expect(repository.findDiagnosticQuizGenerationContext).toHaveBeenCalledWith(
       {
         studentId: 'student-1',
@@ -85,6 +88,7 @@ describe('StartNextActivityUseCase', () => {
       studentId: 'student-1',
       subjectId: 'subject-1',
       knowledgeUnitId: 'unit-1',
+      questionCount: 12,
     });
 
     const [generationInput] = generator.generate.mock.calls[0] ?? [];
@@ -100,6 +104,7 @@ describe('StartNextActivityUseCase', () => {
         pageNumber: null,
       },
     ]);
+    expect(generationInput?.questionCount).toBe(12);
     expect(repository.createDiagnosticQuiz).toHaveBeenCalledWith({
       studentId: 'student-1',
       subjectId: 'subject-1',
@@ -161,6 +166,37 @@ describe('StartNextActivityUseCase', () => {
     });
     expect(generator.generate.mock.calls[0]?.[0]).toEqual({
       knowledgeUnit: weakestUnit,
+      questionCount: 10,
+    });
+  });
+
+  it('passes an explicit legacy question count to the generator', async () => {
+    const repository = createActivitiesRepository();
+    const generator = createDiagnosticQuizGenerator();
+    const revisionRepository = createRevisionRepository();
+    const knowledgeUnit = new KnowledgeUnit({
+      id: 'unit-1',
+      subjectId: 'subject-1',
+      title: 'Controle de constitutionnalite',
+      summary: 'Le Conseil constitutionnel controle certaines normes.',
+    });
+    revisionRepository.findKnowledgeUnits.mockResolvedValue([knowledgeUnit]);
+
+    await new StartNextActivityUseCase(
+      new AdaptivePlanService(),
+      repository,
+      revisionRepository,
+      generator,
+    ).execute({
+      studentId: 'student-1',
+      subjectId: 'subject-1',
+      knowledgeUnitId: 'unit-1',
+      questionCount: 15,
+    });
+
+    expect(generator.generate.mock.calls[0]?.[0]).toEqual({
+      knowledgeUnit,
+      questionCount: 15,
     });
   });
 
diff --git a/src/modules/activities/application/start-next-activity.use-case.ts b/src/modules/activities/application/start-next-activity.use-case.ts
index de3e1dc..c384c5e 100644
--- a/src/modules/activities/application/start-next-activity.use-case.ts
+++ b/src/modules/activities/application/start-next-activity.use-case.ts
@@ -14,6 +14,7 @@ import {
   DIAGNOSTIC_QUIZ_GENERATOR,
   type DiagnosticQuizGenerator,
 } from './diagnostic-quiz-generator';
+import { resolveDiagnosticQuizQuestionCount } from './diagnostic-quiz-question-count';
 
 @Injectable()
 export class StartNextActivityUseCase {
@@ -31,8 +32,12 @@ export class StartNextActivityUseCase {
     studentId: string;
     subjectId: string;
     knowledgeUnitId?: string;
+    questionCount?: number;
   }): Promise<DiagnosticQuizActivity> {
     void this.adaptivePlanService;
+    const questionCount = resolveDiagnosticQuizQuestionCount(
+      input.questionCount,
+    );
     const knowledgeUnitId = input.knowledgeUnitId;
     const knowledgeUnit = knowledgeUnitId
       ? await this.findKnowledgeUnit({
@@ -55,8 +60,9 @@ export class StartNextActivityUseCase {
             documentId: generationContext.documentId,
             knowledgeUnit: generationContext.knowledgeUnit,
             chunks: generationContext.chunks,
+            questionCount,
           }
-        : { knowledgeUnit },
+        : { knowledgeUnit, questionCount },
     );
 
     return this.activitiesRepository.createDiagnosticQuiz({
diff --git a/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts b/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts
index 3450be2..38df66e 100644
--- a/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts
+++ b/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts
@@ -74,6 +74,10 @@ describe('GenkitDiagnosticQuizGenerator', () => {
   const originalGenkitModel = process.env.GENKIT_MODEL;
   const originalMaxChunks = process.env.DIAGNOSTIC_QUIZ_GENERATION_MAX_CHUNKS;
   const originalMaxChars = process.env.DIAGNOSTIC_QUIZ_GENERATION_MAX_CHARS;
+  const originalDefaultQuestionCount =
+    process.env.DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT;
+  const originalMaxQuestionCount =
+    process.env.DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT;
 
   afterEach(() => {
     restoreEnv('AI_PROVIDER', originalAiProvider);
@@ -87,6 +91,11 @@ describe('GenkitDiagnosticQuizGenerator', () => {
     restoreEnv('GENKIT_MODEL', originalGenkitModel);
     restoreEnv('DIAGNOSTIC_QUIZ_GENERATION_MAX_CHUNKS', originalMaxChunks);
     restoreEnv('DIAGNOSTIC_QUIZ_GENERATION_MAX_CHARS', originalMaxChars);
+    restoreEnv(
+      'DIAGNOSTIC_QUIZ_DEFAULT_QUESTION_COUNT',
+      originalDefaultQuestionCount,
+    );
+    restoreEnv('DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT', originalMaxQuestionCount);
     mockOpenAICompatible.mockClear();
     mockGoogleAI.mockClear();
     mockGenkit.mockClear();
@@ -134,10 +143,75 @@ describe('GenkitDiagnosticQuizGenerator', () => {
     expect(generateInput?.prompt).toContain('forme republicaine');
     expect(generateInput?.prompt).not.toContain('contraction cardiaque');
     expect(generateInput?.prompt).toContain('correctChoiceId');
+    expect(generateInput?.prompt).toContain('exactement 10 questions');
     expect(generateInput?.output.schema).toBeDefined();
     expect(quiz).toEqual(generatedQuiz());
   });
 
+  it('generates the requested number of quiz questions up to twenty', async () => {
+    process.env.AI_PROVIDER = 'google';
+    mockGenerate.mockResolvedValue({
+      output: generatedQuizWithQuestionCount(20),
+    });
+
+    const quiz = await new GenkitDiagnosticQuizGenerator().generate({
+      questionCount: 20,
+      knowledgeUnit: new KnowledgeUnit({
+        id: 'unit-1',
+        subjectId: 'subject-1',
+        title: 'Controle de constitutionnalite',
+        summary: 'Le Conseil constitutionnel controle certaines normes.',
+      }),
+    });
+
+    const [generateInput] = mockGenerate.mock.calls[0] ?? [];
+    expect(generateInput?.prompt).toContain('exactement 20 questions');
+    expect(quiz.questions).toHaveLength(20);
+  });
+
+  it('rejects quiz output with fewer questions than requested', async () => {
+    process.env.AI_PROVIDER = 'google';
+    mockGenerate.mockResolvedValue({
+      output: generatedQuizWithQuestionCount(3),
+    });
+    const observer = createObserver();
+
+    await expect(
+      new GenkitDiagnosticQuizGenerator(observer).generate({
+        questionCount: 10,
+        knowledgeUnit: new KnowledgeUnit({
+          id: 'unit-1',
+          subjectId: 'subject-1',
+          title: 'Controle de constitutionnalite',
+          summary: 'Le Conseil constitutionnel controle certaines normes.',
+        }),
+      }),
+    ).rejects.toThrow('DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID');
+
+    const observation = getObservedObservation(observer);
+    expect(observation.errorCode).toBe(
+      'DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID',
+    );
+  });
+
+  it('rejects quiz output with more than twenty questions', async () => {
+    process.env.AI_PROVIDER = 'google';
+    mockGenerate.mockResolvedValue({
+      output: generatedQuizWithQuestionCount(21),
+    });
+
+    await expect(
+      new GenkitDiagnosticQuizGenerator().generate({
+        knowledgeUnit: new KnowledgeUnit({
+          id: 'unit-1',
+          subjectId: 'subject-1',
+          title: 'Controle de constitutionnalite',
+          summary: 'Le Conseil constitutionnel controle certaines normes.',
+        }),
+      }),
+    ).rejects.toThrow();
+  });
+
   it('generates a sourced v2 quiz from the selected knowledge unit chunks', async () => {
     process.env.AI_PROVIDER = 'google';
     process.env.GENKIT_MODEL = 'googleai/custom-model';
@@ -151,7 +225,7 @@ describe('GenkitDiagnosticQuizGenerator', () => {
     const quiz = await new GenkitDiagnosticQuizGenerator(observer).generate({
       documentId: 'document-1',
       subjectId: 'subject-1',
-      questionCount: 2,
+      questionCount: 1,
       knowledgeUnit: sourcedKnowledgeUnit(),
       chunks: [
         {
@@ -680,6 +754,28 @@ function generatedQuiz() {
   };
 }
 
+function generatedQuizWithQuestionCount(questionCount: number) {
+  return {
+    title: 'Diagnostic constitutionnel',
+    questions: Array.from({ length: questionCount }, (_value, index) => ({
+      prompt: `Quelle limite materielle ${index + 1} encadre la revision constitutionnelle en France ?`,
+      choices: [
+        {
+          id: `correct-${index + 1}`,
+          label: 'La forme republicaine du gouvernement',
+        },
+        {
+          id: `wrong-${index + 1}`,
+          label: 'La suppression du Parlement',
+        },
+      ],
+      correctChoiceId: `correct-${index + 1}`,
+      explanation:
+        'La forme republicaine du gouvernement ne peut pas faire l objet d une revision.',
+    })),
+  };
+}
+
 function generatedSourcedQuiz() {
   return {
     title: 'Diagnostic constitutionnel source',
diff --git a/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts b/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts
index d3bf9fe..41bd78d 100644
--- a/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts
+++ b/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts
@@ -10,6 +10,11 @@ import type {
   GeneratedDiagnosticQuizChoice,
   GeneratedDiagnosticQuizQuestion,
 } from '../application/diagnostic-quiz-generator';
+import {
+  DEFAULT_DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT,
+  DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID,
+  resolveDiagnosticQuizQuestionCount,
+} from '../application/diagnostic-quiz-question-count';
 import {
   AI_GENERATION_OBSERVER,
   type AiGenerationObserver,
@@ -33,10 +38,11 @@ const SCHEMA_VERSION = 'diagnostic-quiz-v2';
 const GENERATION_FAILED_ERROR_CODE = 'GENKIT_GENERATION_FAILED';
 const EMPTY_OUTPUT_ERROR_CODE = 'GENKIT_EMPTY_OUTPUT';
 const SOURCE_INVALID_ERROR_CODE = 'DIAGNOSTIC_QUIZ_SOURCE_INVALID';
+const QUESTION_COUNT_INVALID_ERROR_CODE =
+  DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID;
 const DEFAULT_MAX_CHUNKS = 8;
 const DEFAULT_MAX_CHARS = 8000;
-const DEFAULT_QUESTION_COUNT = 3;
-const MAX_QUESTION_COUNT = 5;
+const MAX_QUESTION_COUNT = DEFAULT_DIAGNOSTIC_QUIZ_MAX_QUESTION_COUNT;
 
 const NonEmptyStringSchema = z.string().trim().min(1);
 const DiagnosticQuizDifficultySchema = z.enum(['LOW', 'MEDIUM', 'HIGH']);
@@ -73,7 +79,10 @@ const GeneratedDiagnosticQuizQuestionSchema = z
 const GeneratedDiagnosticQuizSchema = z
   .object({
     title: z.string().min(2),
-    questions: z.array(GeneratedDiagnosticQuizQuestionSchema).min(1).max(5),
+    questions: z
+      .array(GeneratedDiagnosticQuizQuestionSchema)
+      .min(1)
+      .max(MAX_QUESTION_COUNT),
   })
   .strict();
 
@@ -118,6 +127,7 @@ export class GenkitDiagnosticQuizGenerator implements DiagnosticQuizGenerator {
         const quiz = normalizeGeneratedQuiz({
           output: GeneratedDiagnosticQuizSchema.parse(output),
           chunks,
+          expectedQuestionCount: input.questionCount,
           metadata: {
             provider: metadata.provider,
             model: metadata.model,
@@ -161,6 +171,7 @@ export class GenkitDiagnosticQuizGenerator implements DiagnosticQuizGenerator {
           attempts.length > 1 &&
           isInvalidAiOutputError(error, [
             SOURCE_INVALID_ERROR_CODE,
+            QUESTION_COUNT_INVALID_ERROR_CODE,
             'Generated diagnostic quiz is empty',
           ])
         ) {
@@ -214,7 +225,7 @@ function buildPrompt(
   input: DiagnosticQuizGenerationInput,
   chunks: DiagnosticQuizPromptChunk[],
 ): string {
-  const questionCount = resolveQuestionCount(input.questionCount);
+  const questionCount = resolveDiagnosticQuizQuestionCount(input.questionCount);
   const basePrompt = [
     'Tu es un tuteur universitaire qui genere un QCM de revision en francais.',
     'Genere le QCM exclusivement a partir de l unite de connaissance et des chunks fournis.',
@@ -222,9 +233,11 @@ function buildPrompt(
     'Le QCM est mono-reponse: chaque question a un seul correctChoiceId.',
     'Les distracteurs doivent etre plausibles mais faux, distincts et non ambigus.',
     'Chaque explication doit rester fondee sur le cours fourni.',
+    `Genere exactement ${questionCount} questions.`,
+    'Les questions doivent etre variees, non redondantes et couvrir plusieurs angles de la notion quand les sources le permettent.',
+    'Si les sources ne permettent pas un QCM fiable, retourne uniquement des questions strictement justifiables par le cours.',
     'Retourne uniquement du JSON strict respectant le schema demande.',
     'Champs attendus: title, questions, prompt, difficulty, choices, correctChoiceId, explanation, sourceChunkIds.',
-    `Nombre de questions souhaite: ${questionCount}`,
     `Titre de l unite: ${input.knowledgeUnit.title}`,
     `Resume de l unite: ${input.knowledgeUnit.summary}`,
   ];
@@ -234,7 +247,7 @@ function buildPrompt(
       ...basePrompt,
       'Aucun chunk verifiable n est fourni pour ce mode legacy.',
       'Dans ce mode uniquement, sourceChunkIds peut etre omis.',
-      'Contraintes: 1 a 3 questions, 2 a 4 choix par question, une seule bonne reponse, explication concise.',
+      'Contraintes: 2 a 4 choix par question, une seule bonne reponse, explication concise.',
     ].join('\n\n');
   }
 
@@ -251,12 +264,20 @@ function buildPrompt(
 function normalizeGeneratedQuiz(input: {
   output: GeneratedDiagnosticQuiz;
   chunks: DiagnosticQuizPromptChunk[];
+  expectedQuestionCount?: number;
   metadata: {
     provider: string;
     model: string;
     inputSize: number;
   };
 }): GeneratedDiagnosticQuiz {
+  if (
+    input.expectedQuestionCount !== undefined &&
+    input.output.questions.length !== input.expectedQuestionCount
+  ) {
+    throw new Error(QUESTION_COUNT_INVALID_ERROR_CODE);
+  }
+
   if (input.chunks.length === 0) {
     return input.output;
   }
@@ -406,18 +427,6 @@ function toPromptPayload(
   };
 }
 
-function resolveQuestionCount(questionCount: number | undefined): number {
-  if (
-    questionCount === undefined ||
-    !Number.isInteger(questionCount) ||
-    questionCount <= 0
-  ) {
-    return DEFAULT_QUESTION_COUNT;
-  }
-
-  return Math.min(questionCount, MAX_QUESTION_COUNT);
-}
-
 function resolvePositiveInteger(value: string | undefined, fallback: number) {
   const parsed = Number(value);
 
@@ -535,5 +544,12 @@ function resolveDiagnosticQuizGenerationErrorCode(error: unknown): string {
     return SOURCE_INVALID_ERROR_CODE;
   }
 
+  if (
+    error instanceof Error &&
+    error.message === QUESTION_COUNT_INVALID_ERROR_CODE
+  ) {
+    return QUESTION_COUNT_INVALID_ERROR_CODE;
+  }
+
   return GENERATION_FAILED_ERROR_CODE;
 }
diff --git a/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts b/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts
index 7f99d89..4649e4a 100644
--- a/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts
+++ b/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts
@@ -226,6 +226,17 @@ describe('PrismaActivitiesRepository', () => {
     ...input,
   });
 
+  const generatedQuizQuestions = (questionCount: number) =>
+    Array.from({ length: questionCount }, (_value, index) => ({
+      prompt: `Question de revision ${index + 1}`,
+      choices: [
+        { id: `a-${index + 1}`, label: 'Bonne reponse' },
+        { id: `b-${index + 1}`, label: 'Distracteur' },
+      ],
+      correctChoiceId: `a-${index + 1}`,
+      explanation: 'Explication de correction.',
+    }));
+
   it('persists the generated diagnostic quiz after verifying ownership', async () => {
     const { prisma, repository } = createRepository();
     prisma.knowledgeUnit.findFirst.mockResolvedValue({
@@ -311,6 +322,39 @@ describe('PrismaActivitiesRepository', () => {
     });
   });
 
+  it('persists a generated diagnostic quiz with ten questions', async () => {
+    const { prisma, repository } = createRepository();
+    prisma.knowledgeUnit.findFirst.mockResolvedValue({
+      id: 'unit-1',
+      subjectId: 'subject-1',
+    });
+    prisma.activitySession.create.mockResolvedValue(sessionRecord());
+    prisma.question.create.mockImplementation(
+      ({ data }: QuestionCreatePayload) =>
+        questionRecord({
+          id: `question-${prisma.question.create.mock.calls.length}`,
+          prompt: data.prompt,
+          choices: data.choices,
+          correctChoiceId: data.correctChoiceId,
+          explanation: data.explanation,
+        }),
+    );
+
+    const activity = await repository.createDiagnosticQuiz({
+      studentId: 'student-1',
+      subjectId: 'subject-1',
+      knowledgeUnitId: 'unit-1',
+      quiz: {
+        title: 'Diagnostic constitutionnel',
+        questions: generatedQuizQuestions(10),
+      },
+    });
+
+    expect(prisma.question.create).toHaveBeenCalledTimes(10);
+    expect(activity.questions).toHaveLength(10);
+    expect(activity.questions[9]?.id).toBe('question-10');
+  });
+
   it('persists a sourced v2 diagnostic quiz without leaking correction fields before submit', async () => {
     const { prisma, repository } = createRepository();
     prisma.knowledgeUnit.findFirst.mockResolvedValue({
diff --git a/src/modules/activities/interfaces/activities.controller.ts b/src/modules/activities/interfaces/activities.controller.ts
index da28283..e76db94 100644
--- a/src/modules/activities/interfaces/activities.controller.ts
+++ b/src/modules/activities/interfaces/activities.controller.ts
@@ -11,12 +11,18 @@ import {
 } from '@nestjs/common';
 import { CurrentStudent } from '../../auth/interfaces/current-student.decorator';
 import { FirebaseAuthGuard } from '../../auth/interfaces/firebase-auth.guard';
+import {
+  DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID,
+  resolveDiagnosticQuizMaxQuestionCount,
+  resolveDiagnosticQuizQuestionCount,
+} from '../application/diagnostic-quiz-question-count';
 import { StartNextActivityUseCase } from '../application/start-next-activity.use-case';
 import { SubmitActivityResultUseCase } from '../application/submit-activity-result.use-case';
 
 class StartActivityDto {
   subjectId!: string;
   knowledgeUnitId?: string;
+  questionCount?: number;
 }
 
 class SubmitActivityDto {
@@ -48,6 +54,7 @@ export class ActivitiesController {
         studentId: student.id,
         subjectId: validatedBody.subjectId,
         knowledgeUnitId: validatedBody.knowledgeUnitId,
+        questionCount: validatedBody.questionCount,
       })
       .catch((error: unknown) => {
         normalizeActivityError(error);
@@ -85,6 +92,7 @@ function validateStartActivityBody(input: StartActivityDto): StartActivityDto {
       input?.knowledgeUnitId === undefined
         ? undefined
         : validateRequiredId(input.knowledgeUnitId, 'Knowledge unit id'),
+    questionCount: validateQuestionCount(input?.questionCount),
   };
 }
 
@@ -123,6 +131,35 @@ function validateRequiredId(input: unknown, label: string): string {
   return input.trim();
 }
 
+function validateQuestionCount(input: unknown): number | undefined {
+  if (input === undefined) {
+    return undefined;
+  }
+
+  if (typeof input !== 'number') {
+    throw questionCountBadRequest();
+  }
+
+  try {
+    return resolveDiagnosticQuizQuestionCount(input);
+  } catch (error) {
+    if (
+      error instanceof Error &&
+      error.message === DIAGNOSTIC_QUIZ_QUESTION_COUNT_INVALID
+    ) {
+      throw questionCountBadRequest();
+    }
+
+    throw error;
+  }
+}
+
+function questionCountBadRequest(): BadRequestException {
+  return new BadRequestException(
+    `Diagnostic quiz question count must be an integer between 1 and ${resolveDiagnosticQuizMaxQuestionCount()}`,
+  );
+}
+
 function normalizeActivityError(error: unknown): never {
   if (error instanceof Error) {
     if (error.message === 'Activity session not found') {
```
