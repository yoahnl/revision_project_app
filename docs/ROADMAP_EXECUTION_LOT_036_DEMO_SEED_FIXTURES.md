# LOT-036 — Seed et fixtures de démo

## 1. Résultat

LOT-036 ajoute un seed de démonstration reproductible et idempotent côté API. Le seed prépare un scénario non sensible de droit constitutionnel avec étudiant de démonstration relié à un UID Firebase fourni, matière, document logique READY, chunks, notions sourcées, objectif actif, mastery states, résumé READY et fiche READY. Le script refuse la production, exige une confirmation explicite, supporte un dry-run sans écriture et n’appelle ni Genkit, ni Firebase Admin, ni worker PDF.

## 2. Sources inspectées

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_031_REVISION_SESSION_MINIMAL.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_032_REVISION_SESSION_SCREEN.md`
- `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_032B_REVISION_SESSION_ROUTE_ISOLATION.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_033_REVISION_COACH_GENKIT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_034_TODAY_PLAN_MULTI_ACTIONS_BACKEND.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_035_TODAY_PAGE_V2_FRONTEND.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`
- `api/package.json`
- `api/README.md`
- `revision_app/README.md`
- `api/prisma/schema.prisma`
- `api/src/shared/infrastructure/prisma/prisma.service.ts`
- `api/src/shared/infrastructure/prisma/database-url.ts`
- `api/src/generated/prisma/client`
- `api/src/generated/prisma/enums`
- `api/src/modules/students/application/bootstrap-student.use-case.ts`
- `api/src/modules/students/infrastructure/prisma-students.repository.ts`
- `api/src/modules/subjects/domain/subject.entity.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`
- `api/src/modules/revision/domain/mastery-state.entity.ts`
- `api/src/modules/revision/domain/revision-goal.entity.ts`
- `api/src/modules/revision/domain/adaptive-plan.service.ts`
- `api/src/modules/revision/application/get-today-plan.use-case.ts`
- `api/src/modules/documents/**`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/revision-sessions/domain/revision-session.entity.ts`
- `revision_app/lib/features/today/**` lecture seule
- `revision_app/lib/presentation/pages/today/today_page.dart` lecture seule
- `revision_app/lib/features/documents/**` lecture seule
- `revision_app/lib/presentation/pages/documents/**` lecture seule
- `revision_app/lib/features/revision_sessions/**` lecture seule
- `revision_app/lib/app/router/app_routes.dart` lecture seule

## 3. Préflight Git

API initial :

```text
/Users/karim/Project/app-révision/api
/Users/karim/Project/app-révision/api
main
## main...origin/main
a08fd4e #34-1...
783a728 #33-1...
5e71dde #31-1...
0f25fed #27-3...
0cf3f17 #27-2...
```

Frontend/docs initial :

```text
/Users/karim/Project/app-révision/revision_app
/Users/karim/Project/app-révision/revision_app
main
## main...origin/main
f321d04 LOT_035_TODAY_PAGE_V2_FRONTEND...
31a13ea LOT_034_TODAY_PLAN_MULTI_ACTIONS_BACKEND...
50bbd96 LOT_033_REVISION_COACH_GENKIT...
83b233c HOTFIX_032B_REVISION_SESSION_ROUTE_ISOLATION...
51a80a7 LOT_032_REVISION_SESSION_SCREEN...
```

Aucun fichier modifié ou non suivi n’était présent avant le lot. Les modifications existantes étaient donc compatibles avec un lot de seed/documentation.

## 4. Périmètre réalisé

- Fixtures pures de démo dans `api/src/modules/demo-seed`.
- Tests unitaires des fixtures, garde-fous et dry-run.
- Script `api/prisma/demo-seed.ts`.
- Script npm `demo:seed`.
- Runbook de démo dans `revision_app/docs/demo/DEMO_SEED_RUNBOOK.md`.
- Mise à jour de la ligne LOT-036 dans le plan.

Aucun frontend applicatif, GenUI, Genkit, Prisma schema ou migration n’a été modifié.

## 5. Décision du mécanisme de seed

Le seed est un script TypeScript lancé via npm, appuyé par un module de fixtures pur et testable. Le script utilise le Prisma Client généré uniquement en mode écriture. Le mode dry-run ne charge pas Prisma et ne fait aucune écriture, ce qui permet de valider la configuration même sans base locale disponible.

## 6. Garde-fous anti-production

- Refus si `NODE_ENV=production`.
- Refus si `DEMO_SEED_CONFIRM` n’est pas exactement `revision-demo`.
- Refus sans `DEMO_FIREBASE_UID` ou `DEMO_STUDENT_FIREBASE_UID`.
- Pas d’UID Firebase hardcodé.
- Pas de secret hardcodé.
- Pas de suppression globale.
- Namespace démo vérifié avant écriture pour éviter de reprendre des IDs appartenant à un autre étudiant.

## 7. Variables d’environnement

Variables obligatoires :

```bash
DEMO_SEED_CONFIRM=revision-demo
DEMO_FIREBASE_UID=<uid firebase du compte de démonstration>
```

Variables optionnelles :

```bash
DEMO_STUDENT_EMAIL=demo-revision@example.test
DEMO_STUDENT_DISPLAY_NAME="Demo Revision"
DEMO_SEED_DRY_RUN=1
```

## 8. Données créées

- StudentProfile lié à l’UID Firebase fourni.
- Matière `Droit constitutionnel — Ve République`.
- Document logique READY `demo-droit-constitutionnel-veme-republique.pdf`.
- 6 chunks synthétiques.
- 6 notions sourcées.
- 1 objectif actif à J+30.
- 4 mastery states variés.
- 1 résumé READY.
- 1 fiche READY avec 3 sections.

## 9. Fixtures documentaires

Les chunks sont synthétiques, courts, non sensibles et non copiés d’un ouvrage. Le document est logique : `storagePath` vaut `demo://droit-constitutionnel-veme-republique`. Aucun PDF réel n’est importé et le script ne lance pas le worker documentaire.

## 10. Mastery et TodayPlan

Les mastery states créent un profil utile pour TodayPlan : une notion faible à 0.20, une moyenne à 0.55, une solide à 0.75 et une autre fragile à 0.35. Deux notions restent sans mastery pour permettre au plan du jour d’afficher des notions non mesurées selon les règles LOT-034/LOT-035.

## 11. Résumé / fiche si créés

Le seed crée un `Summary` READY et une `RevisionSheet` READY avec métadonnées `demo-seed` : provider `demo-seed`, model `demo-fixture`, versions `demo-seed-v1`. Ces artefacts sont courts, sourcés aux chunks et ne proviennent pas de Genkit.

## 12. Ce qui est explicitement non seedé

- Pas d’ActivitySession QCM.
- Pas d’OpenQuestion.
- Pas d’OpenAnswerEvaluation.
- Pas de RevisionSession.
- Pas de compte Firebase.
- Pas de fichier PDF physique.
- Pas d’appel Genkit.
- Pas d’appel provider IA.
- Pas de worker PDF/BullMQ.

## 13. Idempotence

Les IDs de démo sont stables. Les entités principales sont `upsert`. Les relations sources et sections de fiche du namespace démo sont recréées de manière ciblée. Le script ne supprime aucune donnée hors IDs `demo-*` connus et vérifie que les IDs majeurs existants appartiennent au même étudiant avant écriture.

## 14. Dry-run

Dry-run disponible via :

```bash
DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
```

Résultat validé : le script affiche un résumé JSON, masque `DATABASE_URL`, masque l’UID Firebase et ne charge pas Prisma.

## 15. Documentation d’utilisation

Runbook créé : `revision_app/docs/demo/DEMO_SEED_RUNBOOK.md`. Il couvre objectif, prérequis, variables, dry-run, seed réel, vérifications app/API, relance, nettoyage limité, limites et troubleshooting.

## 16. Sécurité et absence de secrets

Les tests vérifient que les fixtures ne contiennent pas de secret évident ni d’UID Firebase réel hardcodé. Le script masque l’URL DB et l’UID dans son résumé. Le seed ne crée pas de compte Firebase et ne contourne pas l’auth : l’utilisateur doit se connecter avec le compte Firebase dont l’UID correspond à la variable fournie.

## 17. Prisma / migration : créé ou non créé

Aucune migration n’a été créée. `api/prisma/schema.prisma` n’a pas été modifié. Les modèles existants suffisent pour le scénario.

## 18. Tests créés ou modifiés

Créé : `api/src/modules/demo-seed/demo-seed.fixtures.spec.ts`.

Couverture : IDs stables, absence de secrets, matière/document/chunks/notions, sources valides, mastery, objectif futur, plan de suppression borné, garde-fous runtime et masquage des secrets.

## 19. Validations lancées avec résultats

```text
cd api && npx prisma validate
Résultat : succès, schema valid.

cd api && npm run prisma:generate
Résultat : succès, Prisma Client 7.8.0 généré.

cd api && npm test -- demo-seed --runInBand
Résultat : succès, 1 suite, 5 tests.

cd api && npm test -- revision --runInBand
Résultat : succès, 15 suites, 74 tests.

cd api && npm test -- documents --runInBand
Résultat : succès, 9 suites, 63 tests.

cd api && npm run lint:check
Résultat : succès.

cd api && npm run build
Résultat : succès.

cd api && DEMO_SEED_CONFIRM=revision-demo DEMO_FIREBASE_UID=demo-local-uid npm run demo:seed -- --dry-run
Résultat : succès, résumé JSON sans écriture DB.

cd api && git diff --check
Résultat : succès.

cd revision_app && git diff --check
Résultat : succès.
```

## 20. Validations non lancées avec justification

- Seed réel non lancé : aucune DB locale ou staging de démo n’a été explicitement désignée pour ce lot, et le dry-run suffit à vérifier le mécanisme sans écriture.
- `npm run lint` non lancé : interdit car peut appliquer `--fix`.
- `npm run format` non lancé : interdit.
- `npm run test:cov` non lancé : interdit.
- `npx prisma db push`, `migrate reset`, `migrate deploy` non lancés : interdits pour ce lot.
- Aucun test Flutter : aucun code Flutter applicatif modifié.

## 21. Risques restants

- Le seed réel doit encore être rejoué sur une DB locale/staging explicitement prévue pour la démo.
- Le document est logique, sans fichier PDF physique ; les écrans qui attendent un téléchargement du PDF doivent s’appuyer sur les chunks/artefacts seedés.
- Le script charge le client Prisma uniquement en mode écriture via le client généré interne afin de rester compatible avec `ts-node`; ce point devra être surveillé si la génération Prisma change.
- La suppression reste bornée aux IDs démo, mais il faut éviter de réutiliser ces IDs pour des données non démo.

## 22. Recommandation prochain lot

Recommander LOT-037 — tests e2e critiques et smoke checks, avec rejeu du seed sur une DB locale ou staging de démo explicitement validée, puis parcours app Today / documents / activités / session.

## 23. Passes de review

- Audit architecture : le schéma existant couvre le scénario, aucune migration nécessaire.
- TDD : tests fixtures écrits d’abord, échec RED constaté, puis implémentation.
- Sécurité : garde-fous production, confirmation, UID obligatoire, secrets masqués.
- Scope : aucun frontend, Genkit, Prisma schema ou migration.
- Critique finale : le seed réel n’a volontairement pas été lancé sans DB cible explicite ; c’est plus sûr que de toucher une base inconnue.

Note de conflit d’instructions : `revision_app/codex_rule.md` demande des commentaires abondants, tandis que le prompt LOT-036 interdit les commentaires dans le code. Le prompt utilisateur plus spécifique a été suivi : aucun commentaire TypeScript n’a été ajouté.

## 24. Code complet créé/modifié/supprimé pour review

### api/package.json

````json
{
  "name": "api",
  "version": "0.0.1",
  "description": "",
  "author": "",
  "private": true,
  "license": "UNLICENSED",
  "scripts": {
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/src/main.js",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "lint:check": "eslint \"{src,apps,libs,test}/**/*.ts\"",
    "prisma:generate": "prisma generate",
    "prisma:migrate:deploy": "prisma migrate deploy",
    "demo:seed": "ts-node -r tsconfig-paths/register prisma/demo-seed.ts",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.json"
  },
  "dependencies": {
    "@genkit-ai/compat-oai": "^1.37.0",
    "@genkit-ai/google-genai": "^1.37.0",
    "@nestjs/bullmq": "^11.0.4",
    "@nestjs/common": "^11.0.1",
    "@nestjs/core": "^11.0.1",
    "@nestjs/platform-express": "^11.0.1",
    "@prisma/adapter-pg": "^7.8.0",
    "@prisma/client": "^7.8.0",
    "bullmq": "^5.78.0",
    "dotenv": "^17.4.2",
    "firebase-admin": "^14.0.0",
    "genkit": "^1.37.0",
    "ioredis": "^5.11.1",
    "pdf-parse": "^2.4.5",
    "pg": "^8.21.0",
    "prisma": "^7.8.0",
    "reflect-metadata": "^0.2.2",
    "rxjs": "^7.8.1"
  },
  "devDependencies": {
    "@eslint/eslintrc": "^3.2.0",
    "@eslint/js": "^9.18.0",
    "@nestjs/cli": "^11.0.0",
    "@nestjs/schematics": "^11.0.0",
    "@nestjs/testing": "^11.0.1",
    "@types/express": "^5.0.0",
    "@types/jest": "^30.0.0",
    "@types/node": "^24.0.0",
    "@types/pg": "^8.20.0",
    "@types/supertest": "^7.0.0",
    "eslint": "^9.18.0",
    "eslint-config-prettier": "^10.0.1",
    "eslint-plugin-prettier": "^5.2.2",
    "globals": "^17.0.0",
    "jest": "^30.0.0",
    "prettier": "^3.4.2",
    "source-map-support": "^0.5.21",
    "supertest": "^7.0.0",
    "ts-jest": "^29.2.5",
    "ts-loader": "^9.5.2",
    "ts-node": "^10.9.2",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.7.3",
    "typescript-eslint": "^8.20.0"
  },
  "jest": {
    "moduleFileExtensions": [
      "js",
      "json",
      "ts"
    ],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": {
      "^.+\\.(t|j)s$": "ts-jest"
    },
    "moduleNameMapper": {
      "^(\\.{1,2}/.*)\\.js$": "$1"
    },
    "collectCoverageFrom": [
      "**/*.(t|j)s"
    ],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node"
  }
}

````

### api/prisma/demo-seed.ts

````ts
import 'dotenv/config';
import { resolvePrismaDatabaseUrl } from '../src/shared/infrastructure/prisma/database-url';
import {
  buildDemoSeedFixtures,
  buildDemoSeedPlan,
  buildDemoSeedRuntimeOptions,
  demoSeedIds,
  maskDatabaseUrl,
  type DemoSeedFixtures,
} from '../src/modules/demo-seed/demo-seed.fixtures';

async function main(): Promise<void> {
  const options = buildDemoSeedRuntimeOptions({
    env: process.env,
    argv: process.argv.slice(2),
  });
  const databaseUrl = resolvePrismaDatabaseUrl();
  const now = new Date();

  if (options.dryRun) {
    const fixtures = buildDemoSeedFixtures({
      studentId: 'demo-student-profile',
      now,
    });
    const plan = buildDemoSeedPlan(fixtures);

    printSeedSummary({
      mode: 'dry-run',
      databaseUrl,
      firebaseUid: options.firebaseUid,
      fixtures,
      deletePlan: plan.deletePlan,
    });
    return;
  }

  const [{ PrismaPg }, { getPrismaClientClass }] = await Promise.all([
    import('@prisma/adapter-pg'),
    Promise.resolve(require('../src/generated/prisma/internal/class')),
  ]);
  const PrismaClient = getPrismaClientClass();
  const prisma = new PrismaClient({
    adapter: new PrismaPg({ connectionString: databaseUrl }),
  });

  try {
    await prisma.$connect();

    const student = await prisma.studentProfile.upsert({
      where: { firebaseUid: options.firebaseUid },
      create: {
        id: 'demo-student-profile',
        firebaseUid: options.firebaseUid,
        email: options.email,
        displayName: options.displayName,
      },
      update: {
        email: options.email,
        displayName: options.displayName,
      },
    });
    const fixtures = buildDemoSeedFixtures({
      studentId: student.id,
      now,
    });
    const plan = buildDemoSeedPlan(fixtures);

    await prisma.$transaction(async (tx) => {
      await assertDemoNamespaceAvailable(tx, student.id);
      await seedFixtures(tx, fixtures);
    });

    printSeedSummary({
      mode: 'write',
      databaseUrl,
      firebaseUid: options.firebaseUid,
      fixtures,
      deletePlan: plan.deletePlan,
    });
  } finally {
    await prisma.$disconnect();
  }
}

async function assertDemoNamespaceAvailable(
  tx: TransactionClient,
  studentId: string,
): Promise<void> {
  const [subject, document, goal] = await Promise.all([
    tx.subject.findUnique({
      where: { id: demoSeedIds.subjectId },
      select: { studentId: true },
    }),
    tx.document.findUnique({
      where: { id: demoSeedIds.documentId },
      select: { studentId: true },
    }),
    tx.revisionGoal.findUnique({
      where: { id: demoSeedIds.goalId },
      select: { studentId: true },
    }),
  ]);

  for (const record of [subject, document, goal]) {
    if (record && record.studentId !== studentId) {
      throw new Error(
        'Demo namespace already belongs to another student profile',
      );
    }
  }
}

async function seedFixtures(
  tx: TransactionClient,
  fixtures: DemoSeedFixtures,
): Promise<void> {
  await tx.subject.upsert({
    where: { id: fixtures.subject.id },
    create: fixtures.subject,
    update: {
      studentId: fixtures.subject.studentId,
      name: fixtures.subject.name,
      priority: fixtures.subject.priority,
    },
  });

  await tx.document.upsert({
    where: { id: fixtures.document.id },
    create: fixtures.document,
    update: {
      studentId: fixtures.document.studentId,
      subjectId: fixtures.document.subjectId,
      kind: fixtures.document.kind,
      fileName: fixtures.document.fileName,
      storagePath: fixtures.document.storagePath,
      mimeType: fixtures.document.mimeType,
      status: fixtures.document.status,
      errorCode: null,
    },
  });

  for (const chunk of fixtures.chunks) {
    await tx.documentChunk.upsert({
      where: { id: chunk.id },
      create: chunk,
      update: {
        documentId: chunk.documentId,
        subjectId: chunk.subjectId,
        index: chunk.index,
        text: chunk.text,
        charStart: chunk.charStart,
        charEnd: chunk.charEnd,
        pageNumber: chunk.pageNumber,
      },
    });
  }

  for (const unit of fixtures.knowledgeUnits) {
    await tx.knowledgeUnit.upsert({
      where: { id: unit.id },
      create: unit,
      update: unit,
    });
  }

  await tx.knowledgeUnitSource.deleteMany({
    where: {
      knowledgeUnitId: {
        in: fixtures.knowledgeUnits.map((unit) => unit.id),
      },
      chunkId: {
        in: fixtures.chunks.map((chunk) => chunk.id),
      },
    },
  });
  await tx.knowledgeUnitSource.createMany({
    data: fixtures.knowledgeUnitSources,
  });

  await tx.revisionGoal.upsert({
    where: { id: fixtures.goal.id },
    create: fixtures.goal,
    update: {
      studentId: fixtures.goal.studentId,
      targetDate: fixtures.goal.targetDate,
      weeklyMinutes: fixtures.goal.weeklyMinutes,
    },
  });

  for (const mastery of fixtures.masteryStates) {
    await tx.masteryState.upsert({
      where: {
        studentId_knowledgeUnitId: {
          studentId: mastery.studentId,
          knowledgeUnitId: mastery.knowledgeUnitId,
        },
      },
      create: mastery,
      update: {
        subjectId: mastery.subjectId,
        score: mastery.score,
        lastPracticedAt: mastery.lastPracticedAt,
      },
    });
  }

  const summary = await tx.summary.upsert({
    where: { documentId: fixtures.summary.documentId },
    create: fixtures.summary,
    update: {
      subjectId: fixtures.summary.subjectId,
      studentId: fixtures.summary.studentId,
      status: fixtures.summary.status,
      title: fixtures.summary.title,
      content: fixtures.summary.content,
      keyPoints: fixtures.summary.keyPoints,
      limits: fixtures.summary.limits,
      generatedAt: fixtures.summary.generatedAt,
      flowName: fixtures.summary.flowName,
      provider: fixtures.summary.provider,
      model: fixtures.summary.model,
      promptVersion: fixtures.summary.promptVersion,
      schemaVersion: fixtures.summary.schemaVersion,
      inputSize: fixtures.summary.inputSize,
      sourceStrategy: fixtures.summary.sourceStrategy,
      errorCode: fixtures.summary.errorCode,
    },
  });
  await tx.summarySource.deleteMany({
    where: { summaryId: summary.id },
  });
  await tx.summarySource.createMany({
    data: fixtures.summarySources.map((source) => ({
      ...source,
      summaryId: summary.id,
    })),
  });

  const revisionSheet = await tx.revisionSheet.upsert({
    where: { documentId: fixtures.revisionSheet.documentId },
    create: fixtures.revisionSheet,
    update: {
      subjectId: fixtures.revisionSheet.subjectId,
      studentId: fixtures.revisionSheet.studentId,
      status: fixtures.revisionSheet.status,
      title: fixtures.revisionSheet.title,
      introduction: fixtures.revisionSheet.introduction,
      keyPoints: fixtures.revisionSheet.keyPoints,
      commonMistakes: fixtures.revisionSheet.commonMistakes,
      mustKnow: fixtures.revisionSheet.mustKnow,
      practiceSuggestions: fixtures.revisionSheet.practiceSuggestions,
      generatedAt: fixtures.revisionSheet.generatedAt,
      flowName: fixtures.revisionSheet.flowName,
      provider: fixtures.revisionSheet.provider,
      model: fixtures.revisionSheet.model,
      promptVersion: fixtures.revisionSheet.promptVersion,
      schemaVersion: fixtures.revisionSheet.schemaVersion,
      inputSize: fixtures.revisionSheet.inputSize,
      sourceStrategy: fixtures.revisionSheet.sourceStrategy,
      errorCode: fixtures.revisionSheet.errorCode,
    },
  });
  const sectionIds = fixtures.revisionSheetSections.map(
    (section) => section.id,
  );
  await tx.revisionSheetSectionSource.deleteMany({
    where: { sectionId: { in: sectionIds } },
  });
  await tx.revisionSheetSection.deleteMany({
    where: {
      OR: [{ revisionSheetId: revisionSheet.id }, { id: { in: sectionIds } }],
    },
  });
  await tx.revisionSheetSection.createMany({
    data: fixtures.revisionSheetSections.map((section) => ({
      ...section,
      revisionSheetId: revisionSheet.id,
    })),
  });
  await tx.revisionSheetSectionSource.createMany({
    data: fixtures.revisionSheetSectionSources,
  });
}

function printSeedSummary(input: {
  mode: 'dry-run' | 'write';
  databaseUrl: string;
  firebaseUid: string;
  fixtures: DemoSeedFixtures;
  deletePlan: ReturnType<typeof buildDemoSeedPlan>['deletePlan'];
}): void {
  const summary = {
    mode: input.mode,
    databaseUrl: maskDatabaseUrl(input.databaseUrl),
    firebaseUid: maskFirebaseUid(input.firebaseUid),
    subjectId: input.fixtures.subject.id,
    documentId: input.fixtures.document.id,
    chunks: input.fixtures.chunks.length,
    knowledgeUnits: input.fixtures.knowledgeUnits.length,
    masteryStates: input.fixtures.masteryStates.length,
    summaryId: input.fixtures.summary.id,
    revisionSheetId: input.fixtures.revisionSheet.id,
    deletePlan: input.deletePlan,
  };

  console.log(JSON.stringify(summary, null, 2));
}

function maskFirebaseUid(firebaseUid: string): string {
  if (firebaseUid.length <= 8) {
    return '***';
  }

  return `${firebaseUid.slice(0, 4)}***${firebaseUid.slice(-4)}`;
}

type TransactionClient = any;

main().catch((error: unknown) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`Demo seed failed: ${message}`);
  process.exitCode = 1;
});

````

### api/src/modules/demo-seed/demo-seed.fixtures.ts

````ts
type DemoSeedEnv = {
  NODE_ENV?: string;
  DEMO_SEED_CONFIRM?: string;
  DEMO_FIREBASE_UID?: string;
  DEMO_STUDENT_FIREBASE_UID?: string;
  DEMO_STUDENT_EMAIL?: string;
  DEMO_STUDENT_DISPLAY_NAME?: string;
  DEMO_SEED_DRY_RUN?: string;
};

export type DemoSeedRuntimeOptions = {
  firebaseUid: string;
  email: string | null;
  displayName: string | null;
  dryRun: boolean;
};

export type DemoSeedSubjectFixture = {
  id: string;
  studentId: string;
  name: string;
  priority: number;
};

export type DemoSeedDocumentFixture = {
  id: string;
  studentId: string;
  subjectId: string;
  kind: 'COURSE_PDF';
  fileName: string;
  storagePath: string;
  mimeType: 'application/pdf';
  status: 'READY';
};

export type DemoSeedChunkFixture = {
  id: string;
  documentId: string;
  subjectId: string;
  index: number;
  text: string;
  charStart: number;
  charEnd: number;
  pageNumber: number;
};

export type DemoSeedKnowledgeUnitFixture = {
  id: string;
  subjectId: string;
  documentId: string;
  title: string;
  summary: string;
  difficulty: 'LOW' | 'MEDIUM' | 'HIGH';
  displayOrder: number;
  confidence: number;
  extractionPromptVersion: string;
  extractionSchemaVersion: string;
};

export type DemoSeedKnowledgeUnitSourceFixture = {
  knowledgeUnitId: string;
  subjectId: string;
  chunkId: string;
  relevanceScore: number;
};

export type DemoSeedRevisionGoalFixture = {
  id: string;
  studentId: string;
  targetDate: Date;
  weeklyMinutes: number;
};

export type DemoSeedMasteryStateFixture = {
  studentId: string;
  subjectId: string;
  knowledgeUnitId: string;
  score: number;
  lastPracticedAt: Date | null;
};

export type DemoSeedSummaryFixture = {
  id: string;
  documentId: string;
  subjectId: string;
  studentId: string;
  status: 'READY';
  title: string;
  content: string;
  keyPoints: string[];
  limits: string;
  generatedAt: Date;
  flowName: string;
  provider: string;
  model: string;
  promptVersion: string;
  schemaVersion: string;
  inputSize: number;
  sourceStrategy: 'DOCUMENT_CHUNKS';
  errorCode: null;
};

export type DemoSeedSummarySourceFixture = {
  summaryId: string;
  subjectId: string;
  chunkId: string;
  relevanceScore: number;
};

export type DemoSeedRevisionSheetFixture = {
  id: string;
  documentId: string;
  subjectId: string;
  studentId: string;
  status: 'READY';
  title: string;
  introduction: string;
  keyPoints: string[];
  commonMistakes: string[];
  mustKnow: string[];
  practiceSuggestions: string[];
  generatedAt: Date;
  flowName: string;
  provider: string;
  model: string;
  promptVersion: string;
  schemaVersion: string;
  inputSize: number;
  sourceStrategy: 'DOCUMENT_CHUNKS';
  errorCode: null;
};

export type DemoSeedRevisionSheetSectionFixture = {
  id: string;
  revisionSheetId: string;
  subjectId: string;
  displayOrder: number;
  title: string;
  content: string;
};

export type DemoSeedRevisionSheetSectionSourceFixture = {
  sectionId: string;
  subjectId: string;
  chunkId: string;
  relevanceScore: number;
};

export type DemoSeedFixtures = {
  subject: DemoSeedSubjectFixture;
  document: DemoSeedDocumentFixture;
  chunks: DemoSeedChunkFixture[];
  knowledgeUnits: DemoSeedKnowledgeUnitFixture[];
  knowledgeUnitSources: DemoSeedKnowledgeUnitSourceFixture[];
  goal: DemoSeedRevisionGoalFixture;
  masteryStates: DemoSeedMasteryStateFixture[];
  summary: DemoSeedSummaryFixture;
  summarySources: DemoSeedSummarySourceFixture[];
  revisionSheet: DemoSeedRevisionSheetFixture;
  revisionSheetSections: DemoSeedRevisionSheetSectionFixture[];
  revisionSheetSectionSources: DemoSeedRevisionSheetSectionSourceFixture[];
};

export const demoSeedIds = {
  subjectId: 'demo-subject-droit-constitutionnel',
  documentId: 'demo-document-constitution-veme',
  goalId: 'demo-revision-goal-constitution',
  summaryId: 'demo-summary-constitution',
  revisionSheetId: 'demo-sheet-constitution',
  chunkIds: [
    'demo-chunk-constitution-001',
    'demo-chunk-constitution-002',
    'demo-chunk-constitution-003',
    'demo-chunk-constitution-004',
    'demo-chunk-constitution-005',
    'demo-chunk-constitution-006',
  ],
  knowledgeUnitIds: {
    separationPowers: 'demo-ku-separation-pouvoirs',
    constitutionalReview: 'demo-ku-controle-constitutionnalite',
    rationalizedParliamentary: 'demo-ku-regime-parlementaire',
    governmentResponsibility: 'demo-ku-responsabilite-gouvernement',
    nationalSovereignty: 'demo-ku-souverainete-nationale',
    presidentialPowers: 'demo-ku-pouvoirs-president',
  },
};

const demoSeedVersion = 'demo-seed-v1';

export function buildDemoSeedRuntimeOptions(input: {
  env: DemoSeedEnv;
  argv: string[];
}): DemoSeedRuntimeOptions {
  if (input.env.NODE_ENV === 'production') {
    throw new Error('Demo seed is not allowed with NODE_ENV=production');
  }

  if (input.env.DEMO_SEED_CONFIRM !== 'revision-demo') {
    throw new Error('DEMO_SEED_CONFIRM=revision-demo is required');
  }

  const firebaseUid = (
    input.env.DEMO_FIREBASE_UID ??
    input.env.DEMO_STUDENT_FIREBASE_UID ??
    ''
  ).trim();

  if (!firebaseUid) {
    throw new Error(
      'DEMO_FIREBASE_UID or DEMO_STUDENT_FIREBASE_UID is required',
    );
  }

  return {
    firebaseUid,
    email: trimOptional(input.env.DEMO_STUDENT_EMAIL),
    displayName: trimOptional(input.env.DEMO_STUDENT_DISPLAY_NAME),
    dryRun:
      input.argv.includes('--dry-run') || input.env.DEMO_SEED_DRY_RUN === '1',
  };
}

export function buildDemoSeedFixtures(input: {
  studentId: string;
  now: Date;
}): DemoSeedFixtures {
  const chunks = buildChunks();
  const knowledgeUnits = buildKnowledgeUnits();
  const generatedAt = new Date(input.now);

  return {
    subject: {
      id: demoSeedIds.subjectId,
      studentId: input.studentId,
      name: 'Droit constitutionnel — Ve République',
      priority: 5,
    },
    document: {
      id: demoSeedIds.documentId,
      studentId: input.studentId,
      subjectId: demoSeedIds.subjectId,
      kind: 'COURSE_PDF',
      fileName: 'demo-droit-constitutionnel-veme-republique.pdf',
      storagePath: 'demo://droit-constitutionnel-veme-republique',
      mimeType: 'application/pdf',
      status: 'READY',
    },
    chunks,
    knowledgeUnits,
    knowledgeUnitSources: buildKnowledgeUnitSources(),
    goal: {
      id: demoSeedIds.goalId,
      studentId: input.studentId,
      targetDate: daysAfter(input.now, 30),
      weeklyMinutes: 240,
    },
    masteryStates: buildMasteryStates(input.studentId, input.now),
    summary: buildSummary(input.studentId, generatedAt),
    summarySources: [
      summarySource(0, 0.92),
      summarySource(1, 0.88),
      summarySource(2, 0.86),
      summarySource(3, 0.82),
    ],
    revisionSheet: buildRevisionSheet(input.studentId, generatedAt),
    revisionSheetSections: buildRevisionSheetSections(),
    revisionSheetSectionSources: buildRevisionSheetSectionSources(),
  };
}

export function buildDemoSeedPlan(fixtures: DemoSeedFixtures) {
  return {
    fixtures,
    deletePlan: {
      revisionSheetSectionIds: fixtures.revisionSheetSections.map(
        (section) => section.id,
      ),
      revisionSheetIds: [fixtures.revisionSheet.id],
      summaryIds: [fixtures.summary.id],
      revisionGoalIds: [fixtures.goal.id],
      knowledgeUnitIds: fixtures.knowledgeUnits.map((unit) => unit.id),
      chunkIds: fixtures.chunks.map((chunk) => chunk.id),
      documentIds: [fixtures.document.id],
      subjectIds: [fixtures.subject.id],
    },
  };
}

export function maskDatabaseUrl(databaseUrl: string): string {
  try {
    const url = new URL(databaseUrl);
    if (url.password) {
      url.password = '***';
    }
    return url.toString();
  } catch {
    return '<invalid-database-url>';
  }
}

function trimOptional(value: string | undefined): string | null {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function daysAfter(date: Date, days: number): Date {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000);
}

function daysBefore(date: Date, days: number): Date {
  return new Date(date.getTime() - days * 24 * 60 * 60 * 1000);
}

function buildChunks(): DemoSeedChunkFixture[] {
  const texts = [
    'La séparation des pouvoirs distingue les fonctions législative, exécutive et juridictionnelle. Dans la Ve République, cette séparation est organisée mais reste souple afin de permettre la coopération entre institutions.',
    'Le gouvernement est politiquement responsable devant l’Assemblée nationale. La motion de censure et la question de confiance encadrent cette responsabilité et structurent les rapports entre exécutif et Parlement.',
    'Le Conseil constitutionnel contrôle la conformité des lois à la Constitution. Ce contrôle protège la hiérarchie des normes et limite les atteintes aux droits et libertés constitutionnellement garantis.',
    'La rationalisation du parlementarisme encadre la procédure législative et les moyens de contrôle du Parlement. Elle vise à stabiliser l’action gouvernementale tout en maintenant une responsabilité politique.',
    'La souveraineté nationale s’exprime par le suffrage et par la représentation. Le peuple délègue l’exercice du pouvoir à des représentants, tout en conservant une place centrale dans la légitimité des institutions.',
    'Le Président de la République dispose de pouvoirs propres et de pouvoirs partagés. Son rôle varie selon la majorité parlementaire et l’équilibre politique entre le chef de l’État, le gouvernement et le Parlement.',
  ];

  let cursor = 0;

  return texts.map((text, index) => {
    const charStart = cursor;
    const charEnd = cursor + text.length;
    cursor = charEnd + 1;

    return {
      id: demoSeedIds.chunkIds[index],
      documentId: demoSeedIds.documentId,
      subjectId: demoSeedIds.subjectId,
      index,
      text,
      charStart,
      charEnd,
      pageNumber: index + 1,
    };
  });
}

function buildKnowledgeUnits(): DemoSeedKnowledgeUnitFixture[] {
  return [
    unit({
      id: demoSeedIds.knowledgeUnitIds.separationPowers,
      title: 'Séparation des pouvoirs',
      summary:
        'Principe d’organisation qui distingue les fonctions de l’État tout en permettant leur collaboration.',
      difficulty: 'LOW',
      displayOrder: 0,
      confidence: 0.96,
    }),
    unit({
      id: demoSeedIds.knowledgeUnitIds.constitutionalReview,
      title: 'Contrôle de constitutionnalité',
      summary:
        'Contrôle exercé pour vérifier qu’une loi respecte la Constitution et les droits protégés.',
      difficulty: 'MEDIUM',
      displayOrder: 1,
      confidence: 0.93,
    }),
    unit({
      id: demoSeedIds.knowledgeUnitIds.rationalizedParliamentary,
      title: 'Régime parlementaire rationalisé',
      summary:
        'Ensemble de mécanismes qui stabilisent le gouvernement et organisent les rapports avec le Parlement.',
      difficulty: 'HIGH',
      displayOrder: 2,
      confidence: 0.91,
    }),
    unit({
      id: demoSeedIds.knowledgeUnitIds.governmentResponsibility,
      title: 'Responsabilité politique du gouvernement',
      summary:
        'Principe selon lequel le gouvernement peut être renversé par l’Assemblée nationale selon des procédures encadrées.',
      difficulty: 'MEDIUM',
      displayOrder: 3,
      confidence: 0.9,
    }),
    unit({
      id: demoSeedIds.knowledgeUnitIds.nationalSovereignty,
      title: 'Souveraineté nationale',
      summary:
        'Fondement de la légitimité démocratique exercée par le suffrage et la représentation.',
      difficulty: 'LOW',
      displayOrder: 4,
      confidence: 0.94,
    }),
    unit({
      id: demoSeedIds.knowledgeUnitIds.presidentialPowers,
      title: 'Pouvoirs du Président',
      summary:
        'Compétences propres et partagées du Président, variables selon le contexte majoritaire.',
      difficulty: 'MEDIUM',
      displayOrder: 5,
      confidence: 0.92,
    }),
  ];
}

function unit(input: {
  id: string;
  title: string;
  summary: string;
  difficulty: 'LOW' | 'MEDIUM' | 'HIGH';
  displayOrder: number;
  confidence: number;
}): DemoSeedKnowledgeUnitFixture {
  return {
    id: input.id,
    subjectId: demoSeedIds.subjectId,
    documentId: demoSeedIds.documentId,
    title: input.title,
    summary: input.summary,
    difficulty: input.difficulty,
    displayOrder: input.displayOrder,
    confidence: input.confidence,
    extractionPromptVersion: demoSeedVersion,
    extractionSchemaVersion: demoSeedVersion,
  };
}

function buildKnowledgeUnitSources(): DemoSeedKnowledgeUnitSourceFixture[] {
  return [
    source(demoSeedIds.knowledgeUnitIds.separationPowers, 0, 0.95),
    source(demoSeedIds.knowledgeUnitIds.governmentResponsibility, 1, 0.94),
    source(demoSeedIds.knowledgeUnitIds.constitutionalReview, 2, 0.96),
    source(demoSeedIds.knowledgeUnitIds.rationalizedParliamentary, 3, 0.93),
    source(demoSeedIds.knowledgeUnitIds.nationalSovereignty, 4, 0.94),
    source(demoSeedIds.knowledgeUnitIds.presidentialPowers, 5, 0.92),
    source(demoSeedIds.knowledgeUnitIds.rationalizedParliamentary, 1, 0.81),
  ];
}

function source(
  knowledgeUnitId: string,
  chunkIndex: number,
  relevanceScore: number,
): DemoSeedKnowledgeUnitSourceFixture {
  return {
    knowledgeUnitId,
    subjectId: demoSeedIds.subjectId,
    chunkId: demoSeedIds.chunkIds[chunkIndex],
    relevanceScore,
  };
}

function buildMasteryStates(
  studentId: string,
  now: Date,
): DemoSeedMasteryStateFixture[] {
  return [
    mastery(
      studentId,
      demoSeedIds.knowledgeUnitIds.separationPowers,
      0.2,
      daysBefore(now, 16),
    ),
    mastery(
      studentId,
      demoSeedIds.knowledgeUnitIds.constitutionalReview,
      0.55,
      daysBefore(now, 8),
    ),
    mastery(
      studentId,
      demoSeedIds.knowledgeUnitIds.rationalizedParliamentary,
      0.75,
      daysBefore(now, 2),
    ),
    mastery(
      studentId,
      demoSeedIds.knowledgeUnitIds.governmentResponsibility,
      0.35,
      null,
    ),
  ];
}

function mastery(
  studentId: string,
  knowledgeUnitId: string,
  score: number,
  lastPracticedAt: Date | null,
): DemoSeedMasteryStateFixture {
  return {
    studentId,
    subjectId: demoSeedIds.subjectId,
    knowledgeUnitId,
    score,
    lastPracticedAt,
  };
}

function buildSummary(
  studentId: string,
  generatedAt: Date,
): DemoSeedSummaryFixture {
  return {
    id: demoSeedIds.summaryId,
    documentId: demoSeedIds.documentId,
    subjectId: demoSeedIds.subjectId,
    studentId,
    status: 'READY',
    title: 'Synthèse demo — Ve République',
    content:
      'La Ve République combine un exécutif fort, un Parlement encadré et des mécanismes de contrôle constitutionnel. La séparation des pouvoirs reste centrale, mais elle s’exprime dans un régime parlementaire rationalisé.',
    keyPoints: [
      'Séparation des pouvoirs organisée et souple.',
      'Responsabilité politique du gouvernement devant l’Assemblée nationale.',
      'Contrôle de constitutionnalité comme garantie normative.',
      'Président renforcé selon le contexte majoritaire.',
    ],
    limits:
      'Fixture synthétique de démonstration, sans appel IA et sans document PDF réel.',
    generatedAt,
    flowName: 'demoSeedSummary',
    provider: 'demo-seed',
    model: 'demo-fixture',
    promptVersion: demoSeedVersion,
    schemaVersion: demoSeedVersion,
    inputSize: 0,
    sourceStrategy: 'DOCUMENT_CHUNKS',
    errorCode: null,
  };
}

function summarySource(
  chunkIndex: number,
  relevanceScore: number,
): DemoSeedSummarySourceFixture {
  return {
    summaryId: demoSeedIds.summaryId,
    subjectId: demoSeedIds.subjectId,
    chunkId: demoSeedIds.chunkIds[chunkIndex],
    relevanceScore,
  };
}

function buildRevisionSheet(
  studentId: string,
  generatedAt: Date,
): DemoSeedRevisionSheetFixture {
  return {
    id: demoSeedIds.revisionSheetId,
    documentId: demoSeedIds.documentId,
    subjectId: demoSeedIds.subjectId,
    studentId,
    status: 'READY',
    title: 'Fiche demo — Droit constitutionnel',
    introduction:
      'Cette fiche de démonstration résume les notions clés pour tester les parcours de révision sans IA.',
    keyPoints: [
      'Identifier les fonctions de l’État.',
      'Relier responsabilité gouvernementale et parlementarisme.',
      'Comprendre le rôle du Conseil constitutionnel.',
    ],
    commonMistakes: [
      'Confondre séparation stricte et séparation souple des pouvoirs.',
      'Oublier que le gouvernement reste responsable devant l’Assemblée nationale.',
    ],
    mustKnow: [
      'Motion de censure.',
      'Contrôle de constitutionnalité.',
      'Rationalisation du parlementarisme.',
    ],
    practiceSuggestions: [
      'Faire un QCM ciblé sur les pouvoirs.',
      'Répondre à une question ouverte sur la responsabilité politique.',
    ],
    generatedAt,
    flowName: 'demoSeedRevisionSheet',
    provider: 'demo-seed',
    model: 'demo-fixture',
    promptVersion: demoSeedVersion,
    schemaVersion: demoSeedVersion,
    inputSize: 0,
    sourceStrategy: 'DOCUMENT_CHUNKS',
    errorCode: null,
  };
}

function buildRevisionSheetSections(): DemoSeedRevisionSheetSectionFixture[] {
  return [
    {
      id: 'demo-sheet-section-constitution-001',
      revisionSheetId: demoSeedIds.revisionSheetId,
      subjectId: demoSeedIds.subjectId,
      displayOrder: 0,
      title: 'Institutions et séparation des pouvoirs',
      content:
        'La Ve République distingue les fonctions institutionnelles tout en prévoyant des interactions constantes entre exécutif, Parlement et juge constitutionnel.',
    },
    {
      id: 'demo-sheet-section-constitution-002',
      revisionSheetId: demoSeedIds.revisionSheetId,
      subjectId: demoSeedIds.subjectId,
      displayOrder: 1,
      title: 'Parlementarisme rationalisé',
      content:
        'Les mécanismes de responsabilité et de procédure cherchent à éviter l’instabilité gouvernementale tout en conservant un contrôle parlementaire.',
    },
    {
      id: 'demo-sheet-section-constitution-003',
      revisionSheetId: demoSeedIds.revisionSheetId,
      subjectId: demoSeedIds.subjectId,
      displayOrder: 2,
      title: 'Contrôle constitutionnel',
      content:
        'Le Conseil constitutionnel garantit la conformité des lois aux normes constitutionnelles et protège les libertés fondamentales.',
    },
  ];
}

function buildRevisionSheetSectionSources(): DemoSeedRevisionSheetSectionSourceFixture[] {
  return [
    sectionSource('demo-sheet-section-constitution-001', 0, 0.94),
    sectionSource('demo-sheet-section-constitution-002', 3, 0.92),
    sectionSource('demo-sheet-section-constitution-003', 2, 0.93),
  ];
}

function sectionSource(
  sectionId: string,
  chunkIndex: number,
  relevanceScore: number,
): DemoSeedRevisionSheetSectionSourceFixture {
  return {
    sectionId,
    subjectId: demoSeedIds.subjectId,
    chunkId: demoSeedIds.chunkIds[chunkIndex],
    relevanceScore,
  };
}

````

### api/src/modules/demo-seed/demo-seed.fixtures.spec.ts

````ts
import {
  buildDemoSeedFixtures,
  buildDemoSeedPlan,
  buildDemoSeedRuntimeOptions,
  demoSeedIds,
  maskDatabaseUrl,
} from './demo-seed.fixtures';

describe('demo seed fixtures', () => {
  it('builds stable non-sensitive fixtures for the demo scenario', () => {
    const now = new Date('2026-06-15T12:00:00.000Z');
    const fixtures = buildDemoSeedFixtures({
      studentId: 'demo-student-profile',
      now,
    });

    expect(fixtures.subject.id).toBe(demoSeedIds.subjectId);
    expect(fixtures.subject.name).toBe('Droit constitutionnel — Ve République');
    expect(fixtures.document.id).toBe(demoSeedIds.documentId);
    expect(fixtures.document.status).toBe('READY');
    expect(fixtures.document.storagePath).toBe(
      'demo://droit-constitutionnel-veme-republique',
    );
    expect(fixtures.chunks).toHaveLength(6);
    expect(fixtures.knowledgeUnits.length).toBeGreaterThanOrEqual(5);
    expect(fixtures.goal.targetDate.getTime()).toBeGreaterThan(now.getTime());
    expect(fixtures.masteryStates.map((state) => state.score)).toEqual([
      0.2, 0.55, 0.75, 0.35,
    ]);

    const serialized = JSON.stringify(fixtures);
    expect(serialized).not.toContain('firebase');
    expect(serialized).not.toContain('MISTRAL');
    expect(serialized).not.toContain('AIza');
    expect(serialized).not.toContain('701YN');
  });

  it('keeps every knowledge unit source linked to an existing demo chunk', () => {
    const fixtures = buildDemoSeedFixtures({
      studentId: 'demo-student-profile',
      now: new Date('2026-06-15T12:00:00.000Z'),
    });
    const chunkIds = new Set(fixtures.chunks.map((chunk) => chunk.id));
    const knowledgeUnitIds = new Set(
      fixtures.knowledgeUnits.map((unit) => unit.id),
    );

    for (const source of fixtures.knowledgeUnitSources) {
      expect(knowledgeUnitIds.has(source.knowledgeUnitId)).toBe(true);
      expect(chunkIds.has(source.chunkId)).toBe(true);
      expect(source.subjectId).toBe(fixtures.subject.id);
    }
  });

  it('builds a deletion plan constrained to demo identifiers', () => {
    const fixtures = buildDemoSeedFixtures({
      studentId: 'demo-student-profile',
      now: new Date('2026-06-15T12:00:00.000Z'),
    });
    const plan = buildDemoSeedPlan(fixtures);
    const serialized = JSON.stringify(plan.deletePlan);

    expect(plan.deletePlan.documentIds).toEqual([demoSeedIds.documentId]);
    expect(plan.deletePlan.subjectIds).toEqual([demoSeedIds.subjectId]);
    expect(plan.deletePlan.revisionGoalIds).toEqual([demoSeedIds.goalId]);
    expect(serialized).toContain('demo-');
    expect(serialized).not.toContain('deleteManyStudent');
  });

  it('requires production guard, explicit confirmation and Firebase UID', () => {
    expect(() =>
      buildDemoSeedRuntimeOptions({
        env: {
          NODE_ENV: 'production',
          DEMO_SEED_CONFIRM: 'revision-demo',
          DEMO_FIREBASE_UID: 'demo-local-uid',
        },
        argv: [],
      }),
    ).toThrow('Demo seed is not allowed with NODE_ENV=production');

    expect(() =>
      buildDemoSeedRuntimeOptions({
        env: {
          NODE_ENV: 'development',
          DEMO_FIREBASE_UID: 'demo-local-uid',
        },
        argv: [],
      }),
    ).toThrow('DEMO_SEED_CONFIRM=revision-demo is required');

    expect(() =>
      buildDemoSeedRuntimeOptions({
        env: {
          NODE_ENV: 'development',
          DEMO_SEED_CONFIRM: 'revision-demo',
        },
        argv: [],
      }),
    ).toThrow('DEMO_FIREBASE_UID or DEMO_STUDENT_FIREBASE_UID is required');
  });

  it('resolves dry-run mode and masks database URLs', () => {
    const options = buildDemoSeedRuntimeOptions({
      env: {
        NODE_ENV: 'development',
        DEMO_SEED_CONFIRM: 'revision-demo',
        DEMO_STUDENT_FIREBASE_UID: 'demo-local-uid',
        DEMO_STUDENT_EMAIL: 'demo-revision@example.test',
        DEMO_STUDENT_DISPLAY_NAME: 'Demo Revision',
        DEMO_SEED_DRY_RUN: '1',
      },
      argv: ['--dry-run'],
    });

    expect(options.dryRun).toBe(true);
    expect(options.firebaseUid).toBe('demo-local-uid');
    expect(options.email).toBe('demo-revision@example.test');
    expect(options.displayName).toBe('Demo Revision');
    expect(maskDatabaseUrl('postgresql://user:secret@localhost:5432/db')).toBe(
      'postgresql://user:***@localhost:5432/db',
    );
  });
});

````

### revision_app/docs/demo/DEMO_SEED_RUNBOOK.md

````md
# Runbook — Seed démo Revision App

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
curl -H "Authorization: Bearer <firebase id token>" http://localhost:8080/today
```

Le plan doit contenir des actions `diagnostic_quiz`, `open_question` et `revision_session` si les données sont intactes.

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

````

### revision_app/docs/ROADMAP_EXECUTION_PLAN.md

Le fichier complet contient 3563 lignes. Pour éviter de dupliquer tout le plan dans ce rapport déjà volumineux, voici la ligne modifiée avec contexte immédiat, conformément à l’exception prévue par le prompt pour ce fichier long.

````markdown
| LOT-035 | TodayPage v2 frontend | Réalisé | `docs/ROADMAP_EXECUTION_LOT_035_TODAY_PAGE_V2_FRONTEND.md` |
| LOT-036 | Seed et fixtures de démo | Réalisé | `docs/ROADMAP_EXECUTION_LOT_036_DEMO_SEED_FIXTURES.md` |
| LOT-037 | Tests e2e critiques et smoke checks | À faire | À créer |
````

### revision_app/docs/ROADMAP_EXECUTION_LOT_036_DEMO_SEED_FIXTURES.md

Le présent fichier est le rapport de lot. Son contenu complet est donc directement consultable dans ce document.
