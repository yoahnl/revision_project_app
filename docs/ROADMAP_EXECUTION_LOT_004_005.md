# LOT-004 + LOT-005 — Observabilité Genkit

## 1. Résultat

Les lots `LOT-004` et `LOT-005` ajoutent une observabilité Genkit minimale côté backend, sans migration Prisma, sans changement de contrat API public, sans modification frontend et sans changement métier des flows IA.

Ce qui a été fait :

- Création du port applicatif `AiGenerationObserver`.
- Création du token Nest `AI_GENERATION_OBSERVER`.
- Création du fallback `NoopAiGenerationObserver`.
- Création de l’adapter `StructuredLogAiGenerationObserver`.
- Enregistrement du port dans `AiModule`.
- Export du port depuis `AiModule`.
- Injection du port dans le générateur QCM via `ActivitiesModule`.
- Instrumentation des trois flows existants :
  - extraction documentaire Google GenAI ;
  - extraction documentaire Mistral via OpenAI-compatible ;
  - génération de QCM diagnostic.
- Ajout de tests unitaires et de tests anti-fuite de contenu sensible.

Ce qui n’a pas été fait :

- Aucun `DocumentChunk`.
- Aucun `KnowledgeUnitSource`.
- Aucun résumé.
- Aucune fiche de révision.
- Aucun QCM enrichi.
- Aucune question ouverte.
- Aucun GenUI.
- Aucune migration Prisma.
- Aucune persistance DB des événements IA.

## 2. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_001_001B.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_002_002B_003.md`

Backend :

- `api/package.json`
- `api/src/app.module.ts`
- `api/src/modules/ai/ai.module.ts`
- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-extractor.provider.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-extractor.provider.spec.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts`
- `api/src/modules/activities/activities.module.ts`
- `api/src/modules/activities/activities.module.spec.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `api/src/modules/documents/documents.module.ts`
- `api/src/modules/jobs/jobs.module.ts`

Audits subagents utilisés :

- Audit architecture NestJS/DI.
- Audit tests Jest existants.
- Audit sécurité logs.

Correction de chemin constatée :

- Les docs sont dans `revision_app/docs`.
- L’API n’est pas sous `revision_app/api`, mais dans le dossier sibling `api`.
- Le root projet réel est `/Users/karim/Project/app-révision`.

## 3. Décisions d’implémentation

### Port

Nom retenu :

- `AiGenerationObserver`

Emplacement :

- `api/src/modules/ai/application/ai-generation-observer.ts`

Token Nest :

- `AI_GENERATION_OBSERVER`

Le port expose une seule méthode :

- `observe(observation: AiGenerationObservation): void`

L’observation est strictement métadonnée. Elle ne transporte pas de contenu de cours, prompt, completion, réponse utilisateur ou output IA.

### Adapter

Nom retenu :

- `StructuredLogAiGenerationObserver`

Emplacement :

- `api/src/modules/ai/infrastructure/structured-log-ai-generation.observer.ts`

Comportement :

- Produit une ligne JSON stable via `Logger`.
- Utilise `logger.log` pour `status: success`.
- Utilise `logger.warn` pour `status: error`.
- N’inclut que les champs explicitement allowlistés.
- Ignore tout champ arbitraire passé par erreur à l’objet d’observation.

### No-op / fallback

Nom retenu :

- `NoopAiGenerationObserver`
- `noopAiGenerationObserver`

Objectif :

- Préserver les tests et constructions directes via `new`.
- Éviter de rendre Nest obligatoire pour instancier les extractors Genkit dans les tests unitaires.

### Champs observés

Champs autorisés :

- `flowName`
- `provider`
- `model`
- `promptVersion`
- `schemaVersion`
- `inputSize`
- `durationMs`
- `status`
- `errorCode`
- `documentId`
- `knowledgeUnitId`
- `subjectId`
- `activitySessionId`
- `studentId`

### Champs interdits

Champs explicitement interdits :

- prompt complet ;
- completion complète ;
- texte complet du document ;
- chunks complets ;
- réponse complète utilisateur ;
- titre de notion si considéré comme contenu de cours ;
- résumé de notion ;
- `sourceExcerpt` ;
- questions générées ;
- choix générés ;
- explications générées ;
- nom de fichier brut ;
- message provider complet ;
- stack trace complète.

### Injection

`AiModule` fournit :

- `AI_GENERATION_OBSERVER` via `StructuredLogAiGenerationObserver`.
- `DOCUMENT_KNOWLEDGE_EXTRACTOR` via la factory existante.

`AiModule` exporte :

- `AI_GENERATION_OBSERVER`.
- `DOCUMENT_KNOWLEDGE_EXTRACTOR`.

La factory `createDocumentKnowledgeExtractor` garde son API env-first :

- `createDocumentKnowledgeExtractor(env, observer)`

Cela préserve les tests existants qui appellent directement la factory avec un objet d’environnement.

`ActivitiesModule` importe maintenant `AiModule` pour permettre à `GenkitDiagnosticQuizGenerator` de recevoir `AI_GENERATION_OBSERVER` sans cycle de module.

### Instrumentation

Chaque flow instrumenté :

- calcule un `startedAt` avant l’appel Genkit ;
- calcule `durationMs` après succès ou erreur ;
- calcule `inputSize` sans stocker le contenu ;
- observe `success` après output accepté ;
- observe `error` avant de propager l’exception ;
- conserve la propagation d’erreur existante.

Les prompts n’ont pas été modifiés, sauf extraction de constantes de version et métadonnées.

## 4. Flows instrumentés

| Flow | Provider | Model | promptVersion | schemaVersion | inputSize | IDs techniques |
| --- | --- | --- | --- | --- | --- | --- |
| `documentKnowledgeExtraction` | `google-genai` | `GENKIT_MODEL` ou `googleai/gemini-2.5-flash` | `document-knowledge-v1` | `extracted-knowledge-v1` | Longueur du texte effectivement envoyé après limite `DOCUMENT_TEXT_MAX_CHARS` | `documentId` |
| `documentKnowledgeExtraction` | `mistral` | `MISTRAL_MODEL` normalisé ou `mistral/mistral-small-latest` | `document-knowledge-v1` | `extracted-knowledge-v1` | Longueur du texte effectivement envoyé après limite `DOCUMENT_TEXT_MAX_CHARS` | `documentId` |
| `diagnosticQuizGeneration` | `google-genai` ou `mistral` selon env | `GENKIT_MODEL`, `MISTRAL_MODEL`, ou défaut provider | `diagnostic-quiz-v1` | `diagnostic-quiz-v1` | `KnowledgeUnit.title.length + KnowledgeUnit.summary.length` | `knowledgeUnitId`, `subjectId` |

Codes d’erreur utilisés :

- `GENKIT_GENERATION_FAILED`
- `GENKIT_EMPTY_OUTPUT`

## 5. Données explicitement non logguées

L’observabilité ajoutée ne loggue pas :

- prompt complet ;
- completion complète ;
- texte complet du cours ;
- chunks complets ;
- réponse complète utilisateur ;
- nom de fichier brut ;
- clé API ;
- `KnowledgeUnit.title` ;
- `KnowledgeUnit.summary` ;
- `sourceExcerpt` ;
- questions générées ;
- choix de QCM générés ;
- explications générées ;
- message d’erreur provider complet ;
- stack trace complète.

Les tests utilisent des sentinelles textuelles pour vérifier que ces contenus ne partent pas dans l’observer ou dans le log structuré.

## 6. Tests ajoutés ou modifiés

Tests ajoutés :

- `api/src/modules/ai/application/ai-generation-observer.spec.ts`
- `api/src/modules/ai/infrastructure/structured-log-ai-generation.observer.spec.ts`

Tests modifiés :

- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`

Couverture ajoutée :

- No-op observer.
- Log structuré success.
- Log structuré error.
- Allowlist stricte des champs loggés.
- Extraction Google observée en succès.
- Extraction Google observée en erreur.
- Extraction Mistral observée en succès.
- Extraction Mistral observée en erreur.
- Génération QCM observée en succès.
- Génération QCM observée en erreur.
- Erreur de configuration provider QCM observée avant propagation.
- Absence de texte de cours dans l’observer.
- Absence de nom de fichier dans l’observer.
- Absence de clé API dans l’observer.
- Absence de contenu de notion dans l’observer.
- Absence de message provider complet dans l’observer.

## 7. Validations lancées

Depuis `api` :

```bash
npm test -- --runTestsByPath src/modules/ai/application/ai-generation-observer.spec.ts src/modules/ai/infrastructure/structured-log-ai-generation.observer.spec.ts
```

Résultat :

- 2 suites passed.
- 3 tests passed.

```bash
npm test -- --runTestsByPath src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts
```

Résultat :

- RED avant implémentation : 3 suites failed, 6 tests failed, 11 passed.
- GREEN après implémentation : 3 suites passed, 17 tests passed.

```bash
npm test -- --runTestsByPath src/modules/ai/application/ai-generation-observer.spec.ts src/modules/ai/infrastructure/structured-log-ai-generation.observer.spec.ts src/modules/ai/infrastructure/document-knowledge-extractor.provider.spec.ts src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts src/modules/activities/activities.module.spec.ts
```

Résultat :

- 7 suites passed.
- 30 tests passed.

```bash
npm test -- ai
```

Résultat :

- 9 suites passed.
- 30 tests passed.

```bash
npm test -- genkit-document-knowledge
```

Résultat :

- 1 suite passed.
- 5 tests passed.

```bash
npm test -- genkit-mistral-document-knowledge
```

Résultat :

- 1 suite passed.
- 7 tests passed.

```bash
npm test -- genkit-diagnostic-quiz
```

Résultat :

- 1 suite passed.
- 6 tests passed.

```bash
npm test -- activities
```

Résultat :

- 5 suites passed.
- 25 tests passed.

```bash
npm run lint:check
```

Résultat :

- OK après corrections manuelles.

```bash
npm run build
```

Résultat :

- OK.

## 8. Validations non lancées

Non lancé :

```bash
npm run lint
```

Justification :

- Script interdit dans ce lot car il exécute ESLint avec `--fix` et écrit automatiquement.

Non lancé :

```bash
npm run format
```

Justification :

- Script interdit dans ce lot car il écrit automatiquement.

Non lancé :

```bash
npm run test:cov
```

Justification :

- Explicitement exclu sauf demande, et écrit un dossier de couverture.

Non lancé :

```bash
npm run prisma:migrate:deploy
```

Justification :

- Les migrations Prisma sont hors périmètre et explicitement interdites.

Non lancé :

```bash
npm run test:e2e
```

Justification :

- Le lot ne modifie aucun contrat HTTP public.
- Les validations ciblées couvrent les modules et providers touchés.
- Les tests e2e pourront être relancés avant un regroupement plus large.

## 9. Risques restants

### Logs trop verbeux

Risque :

- Les événements IA peuvent devenir nombreux en production.

Mitigation actuelle :

- Une seule ligne par succès ou erreur.
- Pas de contenu lourd.

À traiter plus tard :

- Niveau de log configurable.
- Sampling éventuel.
- Dashboard ou agrégation.

### Absence de persistance DB

Risque :

- Les événements sont uniquement dans les logs.
- Il n’y a pas d’historique requêtable par document ou activité.

Mitigation actuelle :

- Décision alignée avec `LOT-002`.
- Pas de table `AiGenerationJob` prématurée.

À traiter plus tard :

- Réévaluer `AiGenerationJob` si les générations deviennent asynchrones ou si le support produit en a besoin.

### Absence de dashboard

Risque :

- Les logs structurés existent, mais ne sont pas encore visualisés.

Mitigation actuelle :

- Format JSON stable.

À traiter plus tard :

- Observabilité Dokploy/Cloud logs.
- Dashboard par flow/provider/model.

### Provider réel non testé

Risque :

- Les tests mockent Genkit et ne vérifient pas un appel réel Google ou Mistral.

Mitigation actuelle :

- C’est volontaire pour éviter coûts, latence et instabilité CI.
- Les tests vérifient le branchement, le modèle, le provider et l’absence de fuite.

À traiter plus tard :

- Smoke test manuel ou staging avec clé réelle.

### Codes d’erreur encore simples

Risque :

- `GENKIT_GENERATION_FAILED` ne distingue pas encore timeout, rate limit ou schema invalid.

Mitigation actuelle :

- Code sûr, non sensible.
- Suffisant pour LOT-004/005.

À traiter plus tard :

- Enum plus fine avec erreurs contrôlées.

## 10. Recommandation prochain lot

Prochain lot recommandé : `LOT-009 — Modèle documentaire cible détaillé`.

Justification :

- Les flows Genkit existants sont maintenant observables.
- La prochaine étape critique pour la fiabilité IA est de préparer précisément `DocumentChunk` et `KnowledgeUnitSource`.
- Il faut détailler la migration documentaire avant d’implémenter le chunking réel.

Lot parallèle possible :

- `LOT-006 — Inventaire design system`.

Justification :

- Il peut avancer indépendamment côté Flutter.
- Il ne débloque pas les fondations IA autant que `LOT-009`, mais prépare les futures surfaces premium.

## 11. Rapport corrigé conforme `codex_rule.md`

### 11.1 Nom exact du lot

`LOT-004 — Port d’observabilité Genkit` + `LOT-005 — Instrumentation des flows Genkit existants`.

### 11.2 Résumé exécutif

Le backend dispose maintenant d’un port d’observabilité IA découplé des providers Genkit. Les flows Google, Mistral et QCM diagnostic émettent des événements structurés contenant uniquement des métadonnées techniques : flow, provider, modèle, versions, taille d’entrée, durée, statut, code d’erreur et IDs internes.

Le lot reste borné : pas de chunking, pas de résumé, pas de migration, pas de nouveau contrat API public et pas de frontend.

### 11.3 Confirmation du scope

Scope inclus :

- Port `AiGenerationObserver`.
- Adapter `StructuredLogAiGenerationObserver`.
- Fallback `NoopAiGenerationObserver`.
- Injection Nest via `AiModule`.
- Injection du port dans `GenkitDiagnosticQuizGenerator`.
- Instrumentation des trois flows existants.
- Tests positifs, négatifs et garde-fous anti-fuite.
- Documentation du lot.

Scope explicitement exclu :

- `DocumentChunk`.
- `KnowledgeUnitSource`.
- `Summary`.
- `RevisionSheet`.
- QCM enrichi.
- `OpenQuestion`.
- GenUI.
- Prisma.
- Migration.
- Frontend.
- Persistance DB de l’observabilité.

### 11.4 Audit initial

Fichiers et contrats inspectés :

- `api/package.json` : scripts disponibles, `lint:check` sans écriture, `lint` interdit car `--fix`.
- `api/src/modules/ai/ai.module.ts` : module IA initialement limité à `DOCUMENT_KNOWLEDGE_EXTRACTOR`.
- `api/src/modules/ai/application/document-knowledge-extractor.ts` : contrat d’extraction documentaire.
- `api/src/modules/ai/infrastructure/document-knowledge-extractor.provider.ts` : factory provider Google/Mistral.
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts` : flow Google.
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts` : flow Mistral.
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts` : contrat QCM.
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts` : flow QCM.
- Specs existantes des trois flows : mocks Genkit déjà en place.
- `api/src/modules/activities/activities.module.ts` : module nécessitant l’import minimal de `AiModule`.
- Rapports `LOT-001/001B` et `LOT-002/002B/003` : limites documentaires et anti-hallucination.

Risques identifiés avant modification :

- Fuite de texte de cours dans les logs.
- Fuite de prompt ou completion provider.
- Couplage direct des use cases à une infrastructure de logs.
- Cycle NestJS si l’observer était placé dans un module trop large.
- Tests existants construisant les classes Genkit directement avec `new`.

Décision d’audit :

- Garder le port dans `ai/application`.
- Garder l’adapter dans `ai/infrastructure`.
- Exporter le token depuis `AiModule`.
- Importer `AiModule` dans `ActivitiesModule`.
- Garder un no-op par défaut pour préserver les constructions directes.

### 11.5 État Git initial

État initial réellement observé avant le lot, côté API :

```text
?? src/generate_project_overview.sh
?? src/project_overview.txt
```

Ces deux fichiers étaient préexistants et hors périmètre. Ils n’ont pas été modifiés.

État initial côté `revision_app` au moment de la correction de rapport :

```text
A  codex_rule.md
?? docs/ROADMAP_EXECUTION_LOT_004_005.md
```

`codex_rule.md` était fourni par l’utilisateur et n’a pas été modifié.

### 11.6 Verdicts des sub-agents et passes

| Passe | Verdict |
| --- | --- |
| Sub-agent Audit / Architecture | Valide la stratégie : port dans `AiModule`, factory documentaire avec observer, import minimal de `AiModule` dans `ActivitiesModule`, pas de cycle détecté. |
| Sub-agent Tests | Valide les patterns Jest existants : mocks `genkit`, `compat-oai`, `google-genai`, tests directs via `new`, filtres Jest disponibles. |
| Sub-agent Sécurité logs | Valide l’allowlist stricte et recommande de ne jamais logger prompt, completion, texte, nom de fichier, sortie IA, message provider ou stack. |
| Passe Implémentation | Port, adapter, no-op, DI et instrumentation ajoutés sans changement métier. |
| Passe Tests | RED vérifié avant implémentation, puis GREEN sur tests ciblés. |
| Passe Build / Validation | `lint:check`, tests ciblés, build et `diff --check` lancés. |
| Passe Critique finale | Ajout de commentaires utiles sur l’invariant “métadonnées seulement”. Ajout d’un test pour l’erreur de configuration provider QCM. |

### 11.7 Fichiers créés, contenu complet

#### `api/src/modules/ai/application/ai-generation-observer.ts`

```ts
export const AI_GENERATION_OBSERVER = Symbol('AI_GENERATION_OBSERVER');

export type AiGenerationStatus = 'success' | 'error';

// This DTO is intentionally metadata-only: no prompt, completion, course text,
// user answer, generated question, or source excerpt should cross this port.
export interface AiGenerationObservation {
  flowName: string;
  provider: string;
  model: string;
  promptVersion: string;
  schemaVersion: string;
  inputSize: number;
  durationMs: number;
  status: AiGenerationStatus;
  errorCode?: string;
  documentId?: string;
  knowledgeUnitId?: string;
  subjectId?: string;
  activitySessionId?: string;
  studentId?: string;
}

export interface AiGenerationObserver {
  observe(observation: AiGenerationObservation): void;
}

// Direct unit tests and provider factories can instantiate AI adapters without
// Nest. This fallback preserves that boundary while keeping instrumentation opt-in.
export class NoopAiGenerationObserver implements AiGenerationObserver {
  observe(observation: AiGenerationObservation): void {
    void observation;
  }
}

export const noopAiGenerationObserver = new NoopAiGenerationObserver();
```

#### `api/src/modules/ai/application/ai-generation-observer.spec.ts`

```ts
import {
  type AiGenerationObservation,
  NoopAiGenerationObserver,
} from './ai-generation-observer';

describe('NoopAiGenerationObserver', () => {
  it('accepts a complete observation without side effect', () => {
    const observer = new NoopAiGenerationObserver();
    const observation: AiGenerationObservation = {
      flowName: 'documentKnowledgeExtraction',
      provider: 'google-genai',
      model: 'googleai/gemini-2.5-flash',
      promptVersion: 'document-knowledge-v1',
      schemaVersion: 'extracted-knowledge-v1',
      inputSize: 1200,
      durationMs: 42,
      status: 'success',
      documentId: 'document-1',
    };

    expect(() => observer.observe(observation)).not.toThrow();
  });
});
```

#### `api/src/modules/ai/infrastructure/structured-log-ai-generation.observer.ts`

```ts
import { Injectable, Logger } from '@nestjs/common';
import type {
  AiGenerationObservation,
  AiGenerationObserver,
} from '../application/ai-generation-observer';

const AI_GENERATION_EVENT = 'ai.generation';

@Injectable()
export class StructuredLogAiGenerationObserver implements AiGenerationObserver {
  private readonly logger = new Logger(StructuredLogAiGenerationObserver.name);

  observe(observation: AiGenerationObservation): void {
    // Keep this payload as an allowlist. Spreading the observation would make it
    // too easy to leak prompts, completions, source excerpts, or course content.
    const payload = JSON.stringify({
      event: AI_GENERATION_EVENT,
      flowName: observation.flowName,
      provider: observation.provider,
      model: observation.model,
      promptVersion: observation.promptVersion,
      schemaVersion: observation.schemaVersion,
      inputSize: observation.inputSize,
      durationMs: observation.durationMs,
      status: observation.status,
      errorCode: observation.errorCode,
      documentId: observation.documentId,
      knowledgeUnitId: observation.knowledgeUnitId,
      subjectId: observation.subjectId,
      activitySessionId: observation.activitySessionId,
      studentId: observation.studentId,
    });

    if (observation.status === 'error') {
      this.logger.warn(payload);
      return;
    }

    this.logger.log(payload);
  }
}
```

#### `api/src/modules/ai/infrastructure/structured-log-ai-generation.observer.spec.ts`

```ts
import { Logger } from '@nestjs/common';
import { StructuredLogAiGenerationObserver } from './structured-log-ai-generation.observer';

describe('StructuredLogAiGenerationObserver', () => {
  let logSpy: jest.SpyInstance;
  let warnSpy: jest.SpyInstance;

  beforeEach(() => {
    logSpy = jest.spyOn(Logger.prototype, 'log').mockImplementation();
    warnSpy = jest.spyOn(Logger.prototype, 'warn').mockImplementation();
  });

  afterEach(() => {
    logSpy.mockRestore();
    warnSpy.mockRestore();
  });

  it('logs a stable structured success event', () => {
    new StructuredLogAiGenerationObserver().observe({
      flowName: 'documentKnowledgeExtraction',
      provider: 'google-genai',
      model: 'googleai/gemini-2.5-flash',
      promptVersion: 'document-knowledge-v1',
      schemaVersion: 'extracted-knowledge-v1',
      inputSize: 128,
      durationMs: 17,
      status: 'success',
      documentId: 'document-1',
    });

    expect(logSpy).toHaveBeenCalledTimes(1);
    expect(warnSpy).not.toHaveBeenCalled();
    const [[messageInput]] = logSpy.mock.calls as [[unknown]];
    const message = String(messageInput);
    expect(JSON.parse(message)).toEqual({
      event: 'ai.generation',
      flowName: 'documentKnowledgeExtraction',
      provider: 'google-genai',
      model: 'googleai/gemini-2.5-flash',
      promptVersion: 'document-knowledge-v1',
      schemaVersion: 'extracted-knowledge-v1',
      inputSize: 128,
      durationMs: 17,
      status: 'success',
      documentId: 'document-1',
    });
  });

  it('logs errors as warnings without arbitrary sensitive fields', () => {
    new StructuredLogAiGenerationObserver().observe({
      flowName: 'diagnosticQuizGeneration',
      provider: 'mistral',
      model: 'mistral/mistral-small-latest',
      promptVersion: 'diagnostic-quiz-v1',
      schemaVersion: 'diagnostic-quiz-v1',
      inputSize: 52,
      durationMs: 31,
      status: 'error',
      errorCode: 'Error',
      knowledgeUnitId: 'unit-1',
      subjectId: 'subject-1',
      prompt: 'TEXTE COMPLET DU PROMPT',
      completion: 'COMPLETION COMPLETE',
      documentText: 'TEXTE COMPLET DU COURS',
      userAnswer: 'REPONSE UTILISATEUR COMPLETE',
    } as never);

    expect(warnSpy).toHaveBeenCalledTimes(1);
    expect(logSpy).not.toHaveBeenCalled();
    const [[messageInput]] = warnSpy.mock.calls as [[unknown]];
    const message = String(messageInput);
    expect(message).toContain('"event":"ai.generation"');
    expect(message).toContain('"errorCode":"Error"');
    expect(message).not.toContain('TEXTE COMPLET DU PROMPT');
    expect(message).not.toContain('COMPLETION COMPLETE');
    expect(message).not.toContain('TEXTE COMPLET DU COURS');
    expect(message).not.toContain('REPONSE UTILISATEUR COMPLETE');
  });
});
```

### 11.8 Fichiers modifiés, zones changées

#### `api/src/modules/ai/ai.module.ts`

Raison :

- Fournir et exporter l’observer.
- Injecter l’observer dans la factory documentaire sans refactor massif.

Zone modifiée :

```diff
 import { Module } from '@nestjs/common';
+import {
+  AI_GENERATION_OBSERVER,
+  type AiGenerationObserver,
+} from './application/ai-generation-observer';
 import { DOCUMENT_KNOWLEDGE_EXTRACTOR } from './application/document-knowledge-extractor';
 import { createDocumentKnowledgeExtractor } from './infrastructure/document-knowledge-extractor.provider';
+import { StructuredLogAiGenerationObserver } from './infrastructure/structured-log-ai-generation.observer';
 
 @Module({
   providers: [
+    {
+      provide: AI_GENERATION_OBSERVER,
+      useClass: StructuredLogAiGenerationObserver,
+    },
     {
       provide: DOCUMENT_KNOWLEDGE_EXTRACTOR,
-      useFactory: createDocumentKnowledgeExtractor,
+      useFactory: (observer: AiGenerationObserver) =>
+        createDocumentKnowledgeExtractor(process.env, observer),
+      inject: [AI_GENERATION_OBSERVER],
     },
   ],
-  exports: [DOCUMENT_KNOWLEDGE_EXTRACTOR],
+  exports: [AI_GENERATION_OBSERVER, DOCUMENT_KNOWLEDGE_EXTRACTOR],
 })
 export class AiModule {}
```

#### `api/src/modules/ai/infrastructure/document-knowledge-extractor.provider.ts`

Raison :

- Transmettre l’observer aux extractors créés par factory.
- Garder le fallback no-op pour préserver les tests et constructions directes.

Zone modifiée :

```diff
+import {
+  type AiGenerationObserver,
+  noopAiGenerationObserver,
+} from '../application/ai-generation-observer';
 import type { DocumentKnowledgeExtractor } from '../application/document-knowledge-extractor';
 import { GenkitDocumentKnowledgeExtractor } from './genkit-document-knowledge.extractor';
 import { GenkitMistralDocumentKnowledgeExtractor } from './genkit-mistral-document-knowledge.extractor';
@@
 export function createDocumentKnowledgeExtractor(
   env: AiProviderEnv = process.env,
+  observer: AiGenerationObserver = noopAiGenerationObserver,
 ): DocumentKnowledgeExtractor {
@@
   if (configuredProvider === 'mistral') {
-    return new GenkitMistralDocumentKnowledgeExtractor();
+    return new GenkitMistralDocumentKnowledgeExtractor(observer);
   }
@@
-  return new GenkitDocumentKnowledgeExtractor();
+  return new GenkitDocumentKnowledgeExtractor(observer);
 }
```

#### `api/src/modules/activities/activities.module.ts`

Raison :

- Permettre l’injection du token `AI_GENERATION_OBSERVER` dans `GenkitDiagnosticQuizGenerator`.

Zone modifiée :

```diff
 import { Module } from '@nestjs/common';
+import { AiModule } from '../ai/ai.module';
@@
 @Module({
-  imports: [AuthModule, PrismaModule, RevisionModule],
+  imports: [AiModule, AuthModule, PrismaModule, RevisionModule],
```

#### `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`

Raison :

- Instrumenter le flow Google.
- Mesurer durée et taille d’entrée bornée.
- Logger uniquement les métadonnées.

Code ajouté principal :

```ts
const FLOW_NAME = 'documentKnowledgeExtraction';
const PROVIDER = 'google-genai';
const PROMPT_VERSION = 'document-knowledge-v1';
const SCHEMA_VERSION = 'extracted-knowledge-v1';
const GENERATION_FAILED_ERROR_CODE = 'GENKIT_GENERATION_FAILED';

constructor(
  private readonly observer: AiGenerationObserver = noopAiGenerationObserver,
) {}

const textInput = input.text.slice(0, resolveTextInputLimit());
const model = this.resolveModel();
const startedAt = Date.now();

// Only record the bounded input length and stable technical metadata. The
// raw document text and generated units remain outside the observer.
this.observer.observe({
  flowName: FLOW_NAME,
  provider: PROVIDER,
  model,
  promptVersion: PROMPT_VERSION,
  schemaVersion: SCHEMA_VERSION,
  inputSize: textInput.length,
  durationMs: Date.now() - startedAt,
  status: 'success',
  documentId: input.documentId,
});

// Provider errors may contain prompt fragments, so the observer receives a
// controlled error code and the original exception is rethrown unchanged.
this.observer.observe({
  flowName: FLOW_NAME,
  provider: PROVIDER,
  model,
  promptVersion: PROMPT_VERSION,
  schemaVersion: SCHEMA_VERSION,
  inputSize: textInput.length,
  durationMs: Date.now() - startedAt,
  status: 'error',
  errorCode: GENERATION_FAILED_ERROR_CODE,
  documentId: input.documentId,
});
```

#### `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`

Raison :

- Instrumenter le flow Mistral.
- Exclure explicitement texte, nom de fichier, clé API et sorties IA de l’observer.

Code ajouté principal :

```ts
const FLOW_NAME = 'documentKnowledgeExtraction';
const PROVIDER = 'mistral';
const PROMPT_VERSION = 'document-knowledge-v1';
const SCHEMA_VERSION = 'extracted-knowledge-v1';
const GENERATION_FAILED_ERROR_CODE = 'GENKIT_GENERATION_FAILED';

constructor(
  private readonly observer: AiGenerationObserver = noopAiGenerationObserver,
) {}

// Only record the bounded input length and stable technical metadata. The
// raw document text, file name, API key, and generated units are excluded.
this.observer.observe({
  flowName: FLOW_NAME,
  provider: PROVIDER,
  model,
  promptVersion: PROMPT_VERSION,
  schemaVersion: SCHEMA_VERSION,
  inputSize: textInput.length,
  durationMs: Date.now() - startedAt,
  status: 'success',
  documentId: input.documentId,
});
```

#### `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`

Raison :

- Instrumenter le flow QCM.
- Permettre l’observation des erreurs de génération et des erreurs de configuration provider sans logger le titre/résumé de la notion.

Code ajouté principal :

```ts
constructor(
  @Inject(AI_GENERATION_OBSERVER)
  private readonly observer: AiGenerationObserver = noopAiGenerationObserver,
) {}

const metadata = this.resolveMetadata();
const inputSize =
  input.knowledgeUnit.title.length + input.knowledgeUnit.summary.length;
const startedAt = Date.now();

// The quiz prompt contains the unit title and summary, so observability is
// limited to their combined length and stable IDs.
this.observer.observe({
  flowName: FLOW_NAME,
  provider: metadata.provider,
  model: metadata.model,
  promptVersion: PROMPT_VERSION,
  schemaVersion: SCHEMA_VERSION,
  inputSize,
  durationMs: Date.now() - startedAt,
  status: 'success',
  knowledgeUnitId: input.knowledgeUnit.id,
  subjectId: input.knowledgeUnit.subjectId,
});
```

#### Tests modifiés

Fichiers :

- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`

Raison :

- Vérifier les événements `success`.
- Vérifier les événements `error`.
- Vérifier `inputSize`.
- Vérifier provider/model.
- Vérifier que les sentinelles de contenu sensible ne sont pas dans l’observer.

Exemple de garde-fou ajouté :

```ts
const observedPayload = JSON.stringify(observer.observe.mock.calls);
expect(observedPayload).not.toContain('SENTINEL_FULL_DOCUMENT_TEXT');
expect(observedPayload).not.toContain('secret-file-name.pdf');
expect(observedPayload).not.toContain('secret-test-key');
expect(observedPayload).not.toContain(
  'SENTINEL_PROVIDER_ERROR_WITH_COURSE_TEXT',
);
```

#### `revision_app/AGENTS.md`

Raison :

- Rendre `codex_rule.md` explicitement obligatoire pour les futurs rapports de lots.

Zone ajoutée :

```md
## 10. Codex Lot Reports

When a task references `codex_rule.md`, that file is mandatory for the lot report. Apply it as a strict reporting contract for both this Flutter app and the sibling NestJS API when the requested work spans both repositories.

Required report shape:

- Audit the prompt before implementation and explicitly challenge unsafe, contradictory, or repo-inaccurate instructions.
- Audit existing files, contracts, tests, prior reports, risks, and scope boundaries before editing.
- Use sub-agents when available; otherwise run clearly named local passes for Audit / Architecture, Implementation, Tests, Build / Validation, and Critical Review.
- Include the verdict of each sub-agent or named pass in the final report.
- Include the initial and final Git state.
- List every modified, created, or deleted file.
- Include the complete content of every created file.
- For modified files, include the exact changed zones or a diff-style excerpt.
- Include tests created or modified, exact commands run, and exact results.
- Include analysis commands, build commands, exact results, preserved scope limits, remaining risks, next steps, and final self-critique.

For code lots, useful comments are expected where they protect an invariant, explain a lot boundary, or prevent a future false behavior. Comments should clarify why the code exists; they must not decorate obvious statements.
```

### 11.9 Tests créés ou modifiés

Tests créés :

- `ai-generation-observer.spec.ts`
- `structured-log-ai-generation.observer.spec.ts`

Tests modifiés :

- `genkit-document-knowledge.extractor.spec.ts`
- `genkit-mistral-document-knowledge.extractor.spec.ts`
- `genkit-diagnostic-quiz.generator.spec.ts`

Couverture :

- Cas positif no-op.
- Cas positif log structuré.
- Cas négatif log structuré avec champs arbitraires sensibles.
- Succès Google observé.
- Erreur Google observée.
- Succès Mistral observé.
- Erreur Mistral observée.
- Succès QCM observé.
- Erreur QCM observée.
- Erreur de configuration provider QCM observée.
- Non-régression : pas de texte de document, pas de nom de fichier, pas de clé API, pas de titre/résumé de notion, pas de message provider dans l’observer.

### 11.10 Commandes lancées et résultats exacts

Tests RED :

```bash
npm test -- --runTestsByPath src/modules/ai/application/ai-generation-observer.spec.ts src/modules/ai/infrastructure/structured-log-ai-generation.observer.spec.ts
```

Résultat initial :

```text
Test Suites: 2 failed, 2 total
Tests: 0 total
Cause: modules manquants, attendu avant création du port/adapteur.
```

Tests RED instrumentation :

```bash
npm test -- --runTestsByPath src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts
```

Résultat initial :

```text
Test Suites: 3 failed, 3 total
Tests: 6 failed, 11 passed, 17 total
Cause: observer non appelé, attendu avant instrumentation.
```

Validations finales :

```bash
npm run lint:check
```

Résultat :

```text
eslint "{src,apps,libs,test}/**/*.ts"
Exit code: 0
```

```bash
npm test -- ai
```

Résultat :

```text
Test Suites: 9 passed, 9 total
Tests: 30 passed, 30 total
```

```bash
npm test -- genkit-document-knowledge
```

Résultat :

```text
Test Suites: 1 passed, 1 total
Tests: 5 passed, 5 total
```

```bash
npm test -- genkit-mistral-document-knowledge
```

Résultat :

```text
Test Suites: 1 passed, 1 total
Tests: 6 passed, 6 total
```

```bash
npm test -- genkit-diagnostic-quiz
```

Résultat :

```text
Test Suites: 1 passed, 1 total
Tests: 7 passed, 7 total
```

```bash
npm test -- activities
```

Résultat :

```text
Test Suites: 5 passed, 5 total
Tests: 25 passed, 25 total
```

```bash
npm test -- --runTestsByPath src/modules/ai/application/ai-generation-observer.spec.ts src/modules/ai/infrastructure/structured-log-ai-generation.observer.spec.ts src/modules/ai/infrastructure/document-knowledge-extractor.provider.spec.ts src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts src/modules/activities/activities.module.spec.ts
```

Résultat :

```text
Test Suites: 7 passed, 7 total
Tests: 30 passed, 30 total
```

```bash
npm run build
```

Résultat :

```text
nest build
Exit code: 0
```

```bash
git diff --check
```

Résultat :

```text
Exit code: 0 côté api
Exit code: 0 côté revision_app
```

### 11.11 Commandes non lancées

Non lancé :

- `npm run lint`
- `npm run format`
- `npm run test:cov`
- `npm run prisma:migrate:*`
- `git commit`
- `git push`

Justification :

- Ces commandes écrivent, sont explicitement interdites, ou sortent du scope du lot.

### 11.12 État Git final

Côté API :

```text
 M src/modules/activities/activities.module.ts
 M src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts
 M src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts
 M src/modules/ai/ai.module.ts
 M src/modules/ai/infrastructure/document-knowledge-extractor.provider.ts
 M src/modules/ai/infrastructure/genkit-document-knowledge.extractor.spec.ts
 M src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts
 M src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.spec.ts
 M src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts
?? src/modules/ai/application/ai-generation-observer.spec.ts
?? src/modules/ai/application/ai-generation-observer.ts
?? src/modules/ai/infrastructure/structured-log-ai-generation.observer.spec.ts
?? src/modules/ai/infrastructure/structured-log-ai-generation.observer.ts
```

Côté `revision_app` :

```text
 M AGENTS.md
A  codex_rule.md
?? docs/ROADMAP_EXECUTION_LOT_004_005.md
```

Note :

- `codex_rule.md` était déjà présent/fourni par l’utilisateur et n’a pas été modifié.

### 11.13 Limites conservées

- Aucun changement Prisma.
- Aucune migration.
- Aucun changement frontend.
- Aucun changement API public.
- Aucun chunking.
- Aucun nouveau flow IA.
- Aucun résumé ou fiche.
- Aucun GenUI.
- Aucun commit.

### 11.14 Risques restants

- Les logs structurés ne sont pas encore persistés en DB.
- Il n’y a pas encore de dashboard.
- Les codes d’erreur restent volontairement peu détaillés.
- Les tests mockent les providers IA réels.
- Les logs peuvent devenir nombreux en production si le volume augmente.

### 11.15 Prochaines étapes proposées

1. `LOT-009 — Modèle documentaire cible détaillé`.
2. `LOT-010 — Migration DocumentChunk + KnowledgeUnitSource`.
3. `LOT-006 — Inventaire design system` en parallèle si priorité UI.

### 11.16 Auto-critique finale

Points solides :

- Le scope est resté strict.
- Les erreurs continuent à être propagées.
- Les tests prouvent que l’observer ne reçoit pas les sentinelles sensibles.
- La DI Nest reste simple.
- Les constructions directes avec `new` restent possibles.

Points perfectibles :

- Le rapport initial était trop court au regard de `codex_rule.md`.
- Le lot a dû être complété après coup avec des commentaires utiles.
- Les tests de sécurité prouvent l’absence de sentinelles dans l’observer, mais pas encore une politique d’observabilité centralisée à l’échelle de tout le backend.
- Il y a une duplication assumée entre extractors Google et Mistral pour éviter un refactor hors scope.

### 11.17 Regard critique sur le prompt

Demande pertinente :

- Imposer un rapport plus strict est utile pour un projet découpé en lots.
- Exiger le code généré évite les rapports vagues.

Points discutables :

- Demander le contenu complet de tous les fichiers créés peut rendre les rapports très longs.
- Le fichier `codex_rule.md` demande “un maximum de commentaires”, alors que trop de commentaires peuvent réduire la lisibilité. La bonne interprétation retenue est : commentaires utiles sur invariants, frontières de lot et garde-fous, pas commentaires décoratifs.
- La règle de sub-agents est bonne pour les audits, mais déléguer l’implémentation de fichiers très couplés aurait augmenté le risque de conflits. J’ai donc utilisé des sub-agents pour les audits et gardé l’implémentation localement.
