# LOT-025F — Validation DB/runtime QCM v3

## 1. Résultat

Les migrations Prisma complètes de Revision API ont été validées sur une base PostgreSQL locale jetable.

La migration QCM v3 `20260614190000_qcm_media_multi_backend` s'applique proprement après les migrations précédentes, et le runtime réel Prisma valide le scénario attendu :

* persistance d'un QCM v3 avec une question `single`, une question `multiple`, un visuel `CHART`, un visuel `DIAGRAM`, des sources de questions et des sources de visuels ;
* relecture pré-submit sans fuite de correction ;
* soumission avec `choiceId` et `choiceIds` ;
* correction post-submit cohérente ;
* rejet du double submit ;
* conservation DB des liens `QuestionVisual`, `QuestionVisualSource` et `QuestionAnswerChoice`.

Aucune correction de migration ou de logique runtime n'a été nécessaire.

## 2. Sources inspectées

Documentation :

* `revision_app/docs/ROADMAP.md`
* `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_010B.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_012_013.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_018.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md`
* `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_025D_BIS_QCM_V3_VERSIONING.md`
* `revision_app/AGENTS.md`
* `revision_app/codex_rule.md`

Backend :

* `api/package.json`
* `api/.env.example`
* `api/prisma/schema.prisma`
* `api/prisma/migrations/20260612000000_init/migration.sql`
* `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql`
* `api/prisma/migrations/20260614141000_summary_revision_sheet_artifacts/migration.sql`
* `api/prisma/migrations/20260614170000_qcm_v2_persistence_submission/migration.sql`
* `api/prisma/migrations/20260614190000_qcm_media_multi_backend/migration.sql`
* `api/src/modules/activities/application/activities.repository.ts`
* `api/src/modules/activities/application/start-next-activity.use-case.ts`
* `api/src/modules/activities/application/submit-activity-result.use-case.ts`
* `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
* `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
* `api/src/modules/activities/interfaces/activities.controller.ts`
* `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
* `api/src/shared/infrastructure/prisma/prisma.service.ts`
* `api/src/shared/infrastructure/prisma/database-url.ts`

## 3. Préflight Git / Prisma

État Git initial API :

```text
## main...origin/main
```

État Git initial frontend :

```text
## main...origin/main
```

Fichiers requis vérifiés :

* `revision_app/docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md` : présent ;
* `revision_app/docs/ROADMAP_EXECUTION_LOT_025E_QCM_MEDIA_MULTI_UI.md` : présent ;
* `revision_app/docs/ROADMAP_EXECUTION_PLAN.md` : présent ;
* `api/prisma/migrations/20260614190000_qcm_media_multi_backend/migration.sql` : présent.

Validations préflight :

```bash
cd api
npx prisma validate
```

Résultat : schéma valide.

```bash
cd api
npm run prisma:generate
```

Résultat : Prisma Client 7.8.0 généré.

La commande `npx prisma migrate status` avec la configuration locale par défaut pointait vers `localhost:5432` et échouait avec `Schema engine error`, ce qui confirmait le problème déjà documenté dans les lots précédents. La suite du lot a donc utilisé une DB locale jetable explicite sur `localhost:55432`.

## 4. DB locale utilisée

Type : PostgreSQL local jetable via Docker.

Container :

```text
revision-lot025f-postgres
```

Image :

```text
postgres:16-alpine
```

Port local :

```text
localhost:55432 -> container:5432
```

Base :

```text
revision_runtime_validation
```

`DATABASE_URL` masqué :

```text
postgresql://revision:***@localhost:55432/revision_runtime_validation?schema=public
```

La DB a été créée uniquement pour ce lot. Docker a été fermé accidentellement pendant la validation, puis le container jetable a été recréé et les migrations ont été réappliquées depuis une DB vide.

## 5. Migrations validées

Commande avant application sur DB vide :

```bash
cd api
DATABASE_URL='postgresql://revision:revision@localhost:55432/revision_runtime_validation?schema=public' npx prisma migrate status
```

Résultat : 5 migrations trouvées et pending sur DB vide.

Commande d'application sur DB jetable :

```bash
cd api
DATABASE_URL='postgresql://revision:revision@localhost:55432/revision_runtime_validation?schema=public' npx prisma migrate deploy
```

Migrations appliquées :

* `20260612000000_init`
* `20260614000000_document_chunks_sources`
* `20260614141000_summary_revision_sheet_artifacts`
* `20260614170000_qcm_v2_persistence_submission`
* `20260614190000_qcm_media_multi_backend`

Commande après application :

```bash
cd api
DATABASE_URL='postgresql://revision:revision@localhost:55432/revision_runtime_validation?schema=public' npx prisma migrate status
```

Résultat :

```text
Database schema is up to date!
```

La chaîne complète de migrations s'applique donc correctement sur une base PostgreSQL vide.

## 6. Validation runtime QCM v3

Un test d'intégration Prisma réel a été ajouté :

```text
api/src/modules/activities/infrastructure/prisma-activities.repository.integration.spec.ts
```

Il est désactivé par défaut et ne s'exécute que si :

```text
RUN_PRISMA_INTEGRATION_TESTS=true
DATABASE_URL contient localhost:55432 et revision_runtime_validation
```

Cette garde empêche l'exécution accidentelle contre une DB non jetable.

Scénario validé :

1. Création des données minimales : `StudentProfile`, `Subject`, `Document`, `DocumentChunk`, `KnowledgeUnit`, `KnowledgeUnitSource`.
2. Persistance d'un QCM v3 avec :
   * une question `selectionMode: single` ;
   * une question `selectionMode: multiple` ;
   * un visuel `CHART` sourcé ;
   * un visuel `DIAGRAM` sourcé ;
   * des sources de questions ;
   * des sources de visuels.
3. Relecture pré-submit via `createDiagnosticQuiz` :
   * `version = 3` ;
   * visuels présents ;
   * question multiple présente ;
   * pas de `correctChoiceId` ;
   * pas de `correctChoiceIds` ;
   * pas de `isCorrect` ;
   * pas de `explanation` ;
   * pas de `feedback` ;
   * pas de texte complet des sources.
4. Vérification DB :
   * `QuestionVisual` : 2 entrées ;
   * `QuestionVisualSource` : 2 entrées.
5. Soumission :
   * question single via `choiceId` ;
   * question multiple via `choiceIds`.
6. Correction :
   * `correctAnswers = 2` ;
   * `totalQuestions = 2` ;
   * `score = 1` ;
   * `selectedChoiceId` et `correctChoiceId` présents pour la question single ;
   * `selectedChoiceIds` et `correctChoiceIds` présents pour la question multiple ;
   * `partialScore = 1` ;
   * sources textuelles post-submit présentes.
7. Double submit :
   * rejet avec `Activity session already completed`.
8. Vérification DB :
   * `QuestionAnswerChoice` : 2 entrées pour la réponse multiple.

## 7. Corrections réalisées

Aucune correction de migration n'a été nécessaire.

Aucune correction de logique métier QCM v3 n'a été nécessaire.

Modification réalisée dans le scope du lot :

* ajout d'un test d'intégration Prisma réel, désactivé par défaut et protégé contre les DB non jetables ;
* ajout de ce rapport ;
* ajout de la ligne `LOT-025F` au tableau de suivi.

## 8. Anti-fuite

Le test runtime vérifie explicitement que le DTO pré-submit sérialisé ne contient pas :

* `correctChoiceId` ;
* `correctChoiceIds` ;
* `isCorrect` ;
* `explanation` ;
* `feedback` ;
* texte source complet des chunks.

La correction post-submit expose les champs attendus uniquement après soumission.

## 9. Tests créés ou modifiés

Créé :

* `api/src/modules/activities/infrastructure/prisma-activities.repository.integration.spec.ts`

Le test est hors suite par défaut via `describe.skip` quand `RUN_PRISMA_INTEGRATION_TESTS` n'est pas `true`.

## 10. Validations lancées

Préflight Prisma :

```bash
cd api
npx prisma validate
```

Résultat : exit 0.

```bash
cd api
npm run prisma:generate
```

Résultat : exit 0, Prisma Client 7.8.0 généré.

Migrations sur DB jetable :

```bash
cd api
DATABASE_URL='postgresql://revision:revision@localhost:55432/revision_runtime_validation?schema=public' npx prisma migrate status
```

Résultat avant deploy : 5 migrations pending sur DB vide.

```bash
cd api
DATABASE_URL='postgresql://revision:revision@localhost:55432/revision_runtime_validation?schema=public' npx prisma migrate deploy
```

Résultat : exit 0, les 5 migrations appliquées.

```bash
cd api
DATABASE_URL='postgresql://revision:revision@localhost:55432/revision_runtime_validation?schema=public' npx prisma migrate status
```

Résultat : exit 0, `Database schema is up to date!`.

Test runtime DB QCM v3 :

```bash
cd api
NODE_OPTIONS='--experimental-vm-modules' RUN_PRISMA_INTEGRATION_TESTS=true DATABASE_URL='postgresql://revision:revision@localhost:55432/revision_runtime_validation?schema=public' npm test -- prisma-activities.repository.integration --runInBand
```

Résultat : exit 0, 1 test passé.

Note : la même commande sans `NODE_OPTIONS='--experimental-vm-modules'` a échoué sous Jest avec Prisma 7 sur `A dynamic import callback was invoked without --experimental-vm-modules`. La relance avec cette option Node a validé le runtime réel.

Suites ciblées :

```bash
cd api
npm test -- activities --runInBand
```

Résultat : exit 0, 5 suites passées, 1 suite d'intégration skip par défaut, 60 tests passés, 1 test skip.

```bash
cd api
npm test -- genkit-diagnostic-quiz --runInBand
```

Résultat : exit 0, 23 tests passés.

```bash
cd api
npm test -- ai --runInBand
```

Résultat : exit 0, 11 suites passées, 51 tests passés.

Qualité et build :

```bash
cd api
npm run lint:check
```

Résultat : exit 0.

```bash
cd api
npm run build
```

Résultat : exit 0.

Diff checks :

```bash
cd api
git diff --check
```

Résultat : exit 0.

```bash
cd revision_app
git diff --check
```

Résultat : exit 0.

## 11. Validations non lancées

Non lancé :

* `flutter test` : aucun code Flutter modifié ;
* migration production/staging : explicitement hors scope ;
* provider IA réel : explicitement hors scope ;
* déploiement : explicitement hors scope ;
* `npm run format` : interdit par le lot ;
* `npm run test:cov` : interdit par le lot.

## 12. Risques restants

* La validation a été faite sur une DB PostgreSQL locale jetable, pas sur production ou staging.
* Les providers IA réels ne sont pas testés dans ce lot.
* GenUI QCM n'est pas encore implémenté.
* Flutter n'a pas été modifié dans ce lot.
* Le test d'intégration Prisma réel nécessite `NODE_OPTIONS='--experimental-vm-modules'` sous Jest avec Prisma 7.
* La migration runtime est validée sur DB vide ; les environnements déjà partiellement migrés doivent encore suivre la procédure normale de `migrate deploy` avec sauvegarde/contrôle.

## 13. Recommandation prochain lot

Le prochain lot recommandé est :

```text
LOT-030 — GenUI composants activité et correction
```

Cette recommandation tient parce que la chaîne de migrations et le runtime Prisma QCM v3 sont désormais validés localement sur PostgreSQL jetable.

## 14. Passes de review

Passe Audit / Architecture :

* migrations récentes identifiées ;
* repository Prisma QCM v3 inspecté ;
* absence de convention DB intégration existante robuste confirmée ;
* décision : ajouter un test d'intégration opt-in et protégé.

Passe Implémentation :

* test Prisma réel ajouté ;
* aucune migration ni logique runtime modifiée.

Passe Tests :

* migration deploy réelle validée ;
* test runtime DB QCM v3 exécuté ;
* suites `activities`, `genkit-diagnostic-quiz` et `ai` exécutées.

Passe Build / Validation :

* `prisma validate`, `prisma:generate`, `lint:check` et `build` exécutés avec succès.

Passe Critique finale :

* le test d'intégration est volontairement opt-in pour éviter de casser les environnements sans DB ;
* le garde-fou `localhost:55432` + `revision_runtime_validation` limite le risque de DB non jetable ;
* le lot ne prouve pas un provider IA réel ni un déploiement.

## 15. Code créé

### `api/src/modules/activities/infrastructure/prisma-activities.repository.integration.spec.ts`

```ts
import { PrismaService } from '../../../shared/infrastructure/prisma/prisma.service';
import { PrismaActivitiesRepository } from './prisma-activities.repository';
import type { GeneratedDiagnosticQuiz } from '../application/diagnostic-quiz-generator';

const describeIntegration =
  process.env.RUN_PRISMA_INTEGRATION_TESTS === 'true'
    ? describe
    : describe.skip;

describeIntegration('PrismaActivitiesRepository integration', () => {
  let prisma: PrismaService;
  let repository: PrismaActivitiesRepository;
  const createdStudentIds: string[] = [];

  beforeAll(async () => {
    assertDisposableDatabaseUrl();
    prisma = new PrismaService();
    await prisma.$connect();
    repository = new PrismaActivitiesRepository(prisma);
  });

  afterEach(async () => {
    await prisma.studentProfile.deleteMany({
      where: {
        id: {
          in: createdStudentIds.splice(0),
        },
      },
    });
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('persists, reads and submits a sourced QCM v3 with visuals and multiple answers', async () => {
    const suffix = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    const studentId = `student-${suffix}`;
    const subjectId = `subject-${suffix}`;
    const documentId = `document-${suffix}`;
    const chunkOneId = `chunk-one-${suffix}`;
    const chunkTwoId = `chunk-two-${suffix}`;
    const knowledgeUnitId = `unit-${suffix}`;
    createdStudentIds.push(studentId);

    await prisma.studentProfile.create({
      data: {
        id: studentId,
        firebaseUid: `firebase-${suffix}`,
        email: `student-${suffix}@example.test`,
      },
    });
    await prisma.subject.create({
      data: {
        id: subjectId,
        studentId,
        name: 'Droit constitutionnel',
        priority: 4,
      },
    });
    await prisma.document.create({
      data: {
        id: documentId,
        studentId,
        subjectId,
        kind: 'COURSE_PDF',
        fileName: 'cours.pdf',
        storagePath: `students/${studentId}/subjects/${subjectId}/cours.pdf`,
        mimeType: 'application/pdf',
        status: 'READY',
      },
    });
    await prisma.documentChunk.createMany({
      data: [
        {
          id: chunkOneId,
          documentId,
          subjectId,
          index: 0,
          text: 'Le regime parlementaire implique une responsabilite politique du gouvernement devant le Parlement.',
          pageNumber: 3,
        },
        {
          id: chunkTwoId,
          documentId,
          subjectId,
          index: 1,
          text: 'Le regime presidentiel repose sur une separation plus stricte des pouvoirs et une election distincte des organes.',
          pageNumber: 4,
        },
      ],
    });
    await prisma.knowledgeUnit.create({
      data: {
        id: knowledgeUnitId,
        subjectId,
        documentId,
        title: 'Regimes parlementaire et presidentiel',
        summary: 'Comparer les criteres de distinction entre les deux regimes.',
        difficulty: 'HIGH',
      },
    });
    await prisma.knowledgeUnitSource.createMany({
      data: [
        {
          knowledgeUnitId,
          subjectId,
          chunkId: chunkOneId,
        },
        {
          knowledgeUnitId,
          subjectId,
          chunkId: chunkTwoId,
        },
      ],
    });

    const quiz: GeneratedDiagnosticQuiz = {
      title: 'Quiz regimes politiques',
      version: 3,
      metadata: {
        flowName: 'diagnosticQuizGeneration',
        provider: 'test',
        model: 'test-model',
        promptVersion: 'diagnostic-quiz-v3',
        schemaVersion: 'diagnostic-quiz-v3',
        inputSize: 1234,
      },
      questions: [
        {
          prompt:
            'Quel critere distingue principalement le regime parlementaire ?',
          difficulty: 'MEDIUM',
          selectionMode: 'single',
          choices: [
            {
              id: 'single-good',
              label: 'La responsabilite politique du gouvernement.',
              feedback: 'Ce critere correspond au regime parlementaire.',
            },
            {
              id: 'single-bad',
              label: 'Une election totalement separee de tous les organes.',
              feedback: 'Ce critere renvoie plutot au regime presidentiel.',
            },
          ],
          correctChoiceId: 'single-good',
          explanation:
            'Le regime parlementaire se reconnait a la responsabilite du gouvernement devant le Parlement.',
          sourceChunkIds: [chunkOneId],
          visuals: [
            {
              type: 'CHART',
              displayOrder: 0,
              chartType: 'bar',
              title: 'Criteres compares',
              data: [
                {
                  critere: 'Responsabilite politique',
                  parlementaire: 1,
                  presidentiel: 0,
                },
              ],
              xKey: 'critere',
              yKeys: ['parlementaire', 'presidentiel'],
              sourceChunkIds: [chunkOneId],
            },
          ],
        },
        {
          prompt:
            'Quels elements caracterisent le regime presidentiel dans le cours ?',
          difficulty: 'HIGH',
          selectionMode: 'multiple',
          minSelections: 2,
          maxSelections: 2,
          choices: [
            {
              id: 'multi-good-1',
              label: 'Une separation plus stricte des pouvoirs.',
              feedback:
                'La separation stricte est un marqueur du regime presidentiel.',
            },
            {
              id: 'multi-bad',
              label: 'La responsabilite politique devant le Parlement.',
              feedback:
                'Cette responsabilite est associee au regime parlementaire.',
            },
            {
              id: 'multi-good-2',
              label: 'Une election distincte des organes.',
              feedback:
                'Le cours relie cette election distincte au regime presidentiel.',
            },
          ],
          correctChoiceIds: ['multi-good-1', 'multi-good-2'],
          explanation:
            'Le regime presidentiel combine separation plus stricte et election distincte des organes.',
          sourceChunkIds: [chunkTwoId],
          visuals: [
            {
              type: 'DIAGRAM',
              displayOrder: 0,
              title: 'Separation des pouvoirs',
              nodes: [
                { id: 'president', label: 'President' },
                { id: 'congres', label: 'Congres' },
              ],
              edges: [
                {
                  from: 'president',
                  to: 'congres',
                  label: 'organes distincts',
                },
              ],
              sourceChunkIds: [chunkTwoId],
            },
          ],
        },
      ],
    };

    const activity = await repository.createDiagnosticQuiz({
      studentId,
      subjectId,
      knowledgeUnitId,
      documentId,
      quiz,
    });

    const publicActivityJson = JSON.stringify(activity);
    expect(activity.version).toBe(3);
    expect(activity.questions).toHaveLength(2);
    expect(activity.questions[0].visuals?.[0].type).toBe('CHART');
    expect(activity.questions[1].selectionMode).toBe('multiple');
    expect(activity.questions[1].visuals?.[0].type).toBe('DIAGRAM');
    expect(publicActivityJson).not.toContain('correctChoiceId');
    expect(publicActivityJson).not.toContain('correctChoiceIds');
    expect(publicActivityJson).not.toContain('isCorrect');
    expect(publicActivityJson).not.toContain('explanation');
    expect(publicActivityJson).not.toContain('feedback');
    expect(publicActivityJson).not.toContain(
      'responsabilite politique du gouvernement devant le Parlement',
    );
    expect(publicActivityJson).not.toContain(
      'separation plus stricte des pouvoirs et une election distincte',
    );

    const visualCount = await prisma.questionVisual.count({
      where: {
        question: {
          sessionId: activity.sessionId,
        },
      },
    });
    const visualSourceCount = await prisma.questionVisualSource.count({
      where: {
        visual: {
          question: {
            sessionId: activity.sessionId,
          },
        },
      },
    });

    expect(visualCount).toBe(2);
    expect(visualSourceCount).toBe(2);

    const result = await repository.submitResult({
      studentId,
      sessionId: activity.sessionId,
      answers: [
        {
          questionId: activity.questions[0].id,
          choiceId: 'single-good',
        },
        {
          questionId: activity.questions[1].id,
          choiceIds: ['multi-good-1', 'multi-good-2'],
        },
      ],
    });

    expect(result.correctAnswers).toBe(2);
    expect(result.totalQuestions).toBe(2);
    expect(result.score).toBe(1);
    expect(result.items[0].selectedChoiceId).toBe('single-good');
    expect(result.items[0].correctChoiceId).toBe('single-good');
    expect(result.items[0].sources[0].text).toContain('regime parlementaire');
    expect(result.items[1].selectedChoiceIds).toEqual([
      'multi-good-1',
      'multi-good-2',
    ]);
    expect(result.items[1].correctChoiceIds).toEqual([
      'multi-good-1',
      'multi-good-2',
    ]);
    expect(result.items[1].partialScore).toBe(1);
    expect(result.items[1].sources[0].text).toContain('regime presidentiel');

    await expect(
      repository.submitResult({
        studentId,
        sessionId: activity.sessionId,
        answers: [
          {
            questionId: activity.questions[0].id,
            choiceId: 'single-good',
          },
          {
            questionId: activity.questions[1].id,
            choiceIds: ['multi-good-1', 'multi-good-2'],
          },
        ],
      }),
    ).rejects.toThrow('Activity session already completed');

    await expect(
      prisma.questionAnswerChoice.count({
        where: {
          answer: {
            sessionId: activity.sessionId,
          },
        },
      }),
    ).resolves.toBe(2);
  });
});

function assertDisposableDatabaseUrl(): void {
  const databaseUrl = process.env.DATABASE_URL ?? '';

  if (
    !databaseUrl.includes('localhost:55432') ||
    !databaseUrl.includes('revision_runtime_validation')
  ) {
    throw new Error(
      'RUN_PRISMA_INTEGRATION_TESTS requires the LOT-025F disposable local database',
    );
  }
}
```
