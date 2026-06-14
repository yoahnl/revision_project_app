# LOT-025C — QCM média et multi-réponse : contrat backend

## 1. Résultat

Le contrat cible recommandé pour les prochains QCM enrichis est une évolution prudente du QCM v2 actuel :

* conserver le QCM textuel mono-réponse actuel comme fallback stable ;
* ajouter plus tard une capacité média via une table dédiée `QuestionVisual` ;
* sourcer chaque visuel via une table dédiée `QuestionVisualSource` pointant vers `DocumentChunk` ;
* ajouter la multi-réponse via `selectionMode`, `minSelections`, `maxSelections` et un stockage interne des réponses correctes multiples ;
* ne jamais exposer `correctChoiceId` ou `correctChoiceIds` avant soumission ;
* ne pas stocker de payload GenUI arbitraire ;
* ne pas créer de média artificiel non sourcé.

Ce lot ne modifie aucun runtime. Il ne crée ni migration, ni code applicatif, ni modèle Flutter, ni prompt Genkit.

## 2. Sources inspectées

Documentation :

* `revision_app/docs/ROADMAP.md`
* `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_022.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_025.md`
* `revision_app/docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md`
* `revision_app/AGENTS.md`
* `revision_app/codex_rule.md`

Backend en lecture seule :

* `api/prisma/schema.prisma`
* `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
* `api/src/modules/activities/application/start-next-activity.use-case.ts`
* `api/src/modules/activities/application/submit-activity-result.use-case.ts`
* `api/src/modules/activities/application/activities.repository.ts`
* `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
* `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
* `api/src/modules/activities/interfaces/activities.controller.ts`
* `api/src/modules/documents/**`
* `api/src/modules/ai/**`

Frontend en lecture seule :

* `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
* `revision_app/lib/features/activities/data/http_activities_api.dart`
* `revision_app/lib/presentation/pages/activities/diagnostic_quiz_page.dart`
* `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`
* `revision_app/lib/features/activities/genui/**`

## 3. Préflight Git

État initial API :

* branche `main...origin/main` ;
* aucun fichier modifié ou non suivi.

État initial frontend/docs :

* branche `main...origin/main` ;
* aucun fichier modifié ou non suivi.

Fichiers requis vérifiés :

* `revision_app/docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md` existe ;
* `revision_app/docs/ROADMAP_EXECUTION_PLAN.md` existe.

Décision sur fichiers hors scope :

* aucun fichier backend runtime n'est modifié ;
* aucun fichier Prisma n'est modifié ;
* aucun fichier Flutter applicatif n'est modifié ;
* aucun fichier Genkit ou GenUI n'est modifié ;
* seules la documentation du lot et la ligne de suivi du plan sont dans le scope.

## 4. Problème à résoudre

Le QCM actuel est utile pour vérifier une notion textuelle, mais il reste limité :

* il est mono-réponse ;
* les questions sont principalement textuelles ;
* il ne peut pas représenter une image issue d'un document ;
* il ne peut pas représenter un graphique de données ;
* il ne peut pas représenter un diagramme simple de processus ou de relations ;
* il ne peut pas représenter des questions dont plusieurs choix sont corrects.

Certains apprentissages nécessitent un visuel. Un cours d'économie peut nécessiter un graphique, un cours de biologie une image annotée, un cours de droit ou d'histoire un diagramme de procédure ou de chronologie.

Ces ajouts augmentent aussi les risques :

* un média généré librement peut devenir halluciné ;
* un graphique peut présenter des données inventées ;
* un diagramme peut simplifier à tort une relation ;
* la multi-réponse multiplie les possibilités de fuite de correction ;
* un payload arbitraire pourrait contourner les validations UI et GenUI.

Le contrat doit donc précéder l'implémentation.

## 5. Options média étudiées

### Option A — Champs directs sur `Question`

Exemples :

* `imageUrl`
* `imageAltText`
* `chartJson`
* `diagramJson`

Avantages :

* très simple à migrer ;
* peu de tables ;
* lecture Prisma directe ;
* suffisant si une question a au maximum un visuel.

Inconvénients :

* mélange la question et ses médias ;
* devient vite rigide si plusieurs visuels sont nécessaires ;
* pousse vers des colonnes JSON fourre-tout ;
* rend la validation par type moins claire ;
* rend l'évolution GenUI plus confuse.

### Option B — Table dédiée `QuestionVisual`

Exemple conceptuel :

```prisma
model QuestionVisual {
  id           String
  questionId   String
  type         QuestionVisualType
  displayOrder Int
  payload      Json
}
```

Avantages :

* séparation claire entre question et visuels ;
* plusieurs visuels possibles par question ;
* ordre d'affichage stable ;
* compatible fallback UI et GenUI ;
* un seul point d'extension pour image, chart et diagram ;
* migration plus simple que trois tables spécialisées.

Inconvénients :

* `payload` JSON exige une validation applicative stricte ;
* le repository doit empêcher les payloads arbitraires ;
* les tests doivent couvrir chaque type visuel ;
* la migration est plus lourde qu'une simple colonne.

### Option C — Modèles spécialisés par type

Exemples :

* `QuestionImageVisual`
* `QuestionChartVisual`
* `QuestionDiagramVisual`

Avantages :

* typage DB plus fort ;
* validation structurelle plus lisible ;
* moins de JSON libre ;
* requêtes explicites par type.

Inconvénients :

* plus de tables ;
* plus de migrations ;
* plus de code repository ;
* moins flexible pour le MVP ;
* évolution plus coûteuse si un nouveau type visuel apparaît.

## 6. Décision média recommandée

Décision recommandée : **Option B — table dédiée `QuestionVisual` avec payload strictement borné**.

Le MVP média doit éviter les deux extrêmes :

* pas de champs directs sur `Question`, trop rigides ;
* pas de tables spécialisées par type dès le départ, trop lourdes.

Le compromis retenu :

* `QuestionVisual` porte `type`, `displayOrder` et `payload` ;
* `type` est un enum borné : `IMAGE`, `CHART`, `DIAGRAM` ;
* le backend valide `payload` avec des schémas applicatifs stricts ;
* `QuestionVisualSource` source chaque visuel vers des `DocumentChunk` ;
* aucun payload GenUI persistant ;
* aucun HTML, SVG libre, base64 ou URL externe arbitraire.

## 7. Contrat visuels

### Type commun

```ts
type QuestionVisualType = 'IMAGE' | 'CHART' | 'DIAGRAM';
```

Chaque visuel futur doit avoir :

* `id` ;
* `type` ;
* `displayOrder` ;
* `sourceChunkIds` ;
* un payload validé selon son type.

### Image

DTO conceptuel :

```ts
type QuestionImageVisual = {
  id: string;
  type: 'IMAGE';
  displayOrder: number;
  imageUrl: string;
  altText: string;
  caption?: string;
  sourceChunkIds: string[];
};
```

Contraintes :

* `imageUrl` doit être une URL contrôlée ou une référence storage applicative ;
* pas d'URL externe arbitraire ;
* pas de base64 ;
* `altText` obligatoire ;
* `caption` optionnel ;
* `sourceChunkIds` obligatoires ;
* image issue du document ou d'un asset validé ;
* ownership vérifié ;
* pas de contenu généré non sourcé.

### Chart

DTO conceptuel :

```ts
type QuestionChartVisual = {
  id: string;
  type: 'CHART';
  displayOrder: number;
  chartType: 'bar' | 'line' | 'pie' | 'scatter';
  title: string;
  description?: string;
  data: Array<Record<string, string | number | null>>;
  xKey?: string;
  yKeys?: string[];
  sourceChunkIds: string[];
};
```

Contraintes :

* `chartType` borné ;
* `data` limité en nombre de lignes et colonnes ;
* clés simples, sans chemins dynamiques ;
* pas de JavaScript ;
* pas de HTML ;
* pas de fonctions ;
* pas de configuration Recharts libre ;
* pas de payload widget arbitraire ;
* `sourceChunkIds` obligatoires ;
* données dérivées du document ou des chunks ;
* backend valide la structure ;
* frontend rend via composant natif ou GenUI borné plus tard.

### Diagram

DTO conceptuel :

```ts
type QuestionDiagramVisual = {
  id: string;
  type: 'DIAGRAM';
  displayOrder: number;
  title: string;
  description?: string;
  nodes: Array<{
    id: string;
    label: string;
  }>;
  edges?: Array<{
    from: string;
    to: string;
    label?: string;
  }>;
  sourceChunkIds: string[];
};
```

Contraintes :

* nombre de nodes borné ;
* labels courts ;
* edges bornés ;
* `edges.from` et `edges.to` doivent référencer des nodes existants ;
* pas de Mermaid libre ;
* pas de SVG libre ;
* pas de HTML ;
* `sourceChunkIds` obligatoires.

## 8. Sources des visuels

Décision recommandée :

* conserver `QuestionSource` pour la question textuelle ;
* créer plus tard `QuestionVisualSource` pour les sources propres à chaque visuel ;
* faire pointer `QuestionVisualSource` vers `DocumentChunk` ;
* prévoir `DocumentMedia` seulement quand un vrai pipeline d'extraction média PDF existera.

Pourquoi ne pas réutiliser uniquement `QuestionSource` :

* une question peut être sourcée par un chunk textuel, mais son graphique peut être dérivé d'un autre passage ;
* une image issue du document peut nécessiter une source différente ;
* un diagramme peut synthétiser plusieurs chunks ;
* les sources du visuel doivent rester auditables indépendamment.

Contrat source conceptuel :

```ts
type QuestionVisualSource = {
  visualId: string;
  chunkId: string;
  subjectId: string;
  relevanceScore?: number | null;
};
```

Règles :

* chaque visuel doit avoir au moins une source ;
* chaque `chunkId` doit exister ;
* chaque chunk doit appartenir au même document/sujet que la question ;
* cross-student interdit ;
* aucune source libre générée par IA ne fait autorité ;
* aucun extrait source libre n'est stocké comme preuve.

## 9. Contrat multi-réponse

### Pré-submit

DTO conceptuel :

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

Contraintes :

* `selectionMode` devient obligatoire dans la future version ;
* valeurs autorisées : `single`, `multiple` ;
* `correctChoiceId` jamais pré-submit ;
* `correctChoiceIds` jamais pré-submit ;
* `isCorrect` jamais pré-submit ;
* feedback jamais pré-submit ;
* explication jamais pré-submit ;
* `minSelections >= 1` ;
* `maxSelections <= choices.length` ;
* `minSelections <= maxSelections` ;
* pour `single`, `minSelections = 1` et `maxSelections = 1`.

### Soumission

Décision recommandée :

* préserver `choiceId` pour les questions `single` ;
* ajouter `choiceIds` pour les questions `multiple` ;
* rejeter les payloads incohérents.

DTO conceptuel :

```json
{
  "answers": [
    {
      "questionId": "question-single",
      "choiceId": "choice-1"
    },
    {
      "questionId": "question-multiple",
      "choiceIds": ["choice-1", "choice-3"]
    }
  ]
}
```

Règles :

* question `single` : `choiceId` requis, `choiceIds` rejeté ;
* question `multiple` : `choiceIds` requis, `choiceId` rejeté ;
* choix inconnus rejetés ;
* choix dupliqués rejetés ;
* nombre de choix sélectionnés entre `minSelections` et `maxSelections` ;
* double submit interdit.

### Correction

DTO conceptuel :

```json
{
  "questionId": "question-1",
  "selectedChoiceIds": ["choice-1", "choice-3"],
  "correctChoiceIds": ["choice-1", "choice-2"],
  "isCorrect": false,
  "partialScore": 0.5,
  "explanation": "Explication pédagogique.",
  "choiceFeedback": [
    {
      "choiceId": "choice-1",
      "feedback": "Ce choix est bien relié au cours."
    }
  ]
}
```

Contraintes :

* `correctChoiceIds` seulement post-submit ;
* `partialScore` entre 0 et 1 ;
* l'ordre des choix ne compte pas ;
* feedback par choix post-submit seulement ;
* sources textuelles et visuelles post-submit seulement si elles ne révèlent rien avant submit.

## 10. Scoring multi-réponse

### Option A — Tout ou rien

La réponse est correcte uniquement si :

* toutes les bonnes réponses sont sélectionnées ;
* aucune mauvaise réponse n'est sélectionnée.

Avantages :

* simple ;
* facile à expliquer ;
* facile à tester ;
* réduit les débats sur le score.

Inconvénients :

* punit fortement les réponses partiellement bonnes.

### Option B — Score partiel simple

Exemple :

* +1 par bonne réponse sélectionnée ;
* -1 par mauvaise réponse sélectionnée ;
* score normalisé entre 0 et 1.

Avantages :

* plus pédagogique ;
* reflète mieux la compréhension partielle.

Inconvénients :

* plus complexe ;
* nécessite une explication UX claire ;
* peut surprendre l'utilisateur.

### Option C — Score partiel sans pénalité

Exemple :

* bonnes réponses sélectionnées / total bonnes réponses ;
* mauvais choix ignorés ou seulement signalés.

Avantages :

* simple ;
* moins punitif.

Inconvénients :

* encourage potentiellement à tout cocher.

Décision recommandée pour le MVP multi-réponse : **Option A — tout ou rien**.

Raison :

* le QCM actuel est déjà centré sur la maîtrise et la correction claire ;
* le score partiel demande une vraie UX pédagogique ;
* il vaut mieux livrer une multi-réponse fiable et compréhensible avant d'introduire un scoring plus subtil.

Le contrat peut toutefois prévoir `partialScore` post-submit pour compatibilité future, avec `0` ou `1` au départ.

## 11. Contrat Prisma futur

### Enum `QuestionSelectionMode`

Concept :

```prisma
enum QuestionSelectionMode {
  SINGLE
  MULTIPLE
}
```

### Enum `QuestionVisualType`

Concept :

```prisma
enum QuestionVisualType {
  IMAGE
  CHART
  DIAGRAM
}
```

### `Question`

Champs conceptuels à ajouter :

```prisma
selectionMode    QuestionSelectionMode @default(SINGLE)
minSelections    Int?
maxSelections    Int?
correctChoiceIds Json?
```

Décision :

* garder `correctChoiceId` pour compatibilité single ;
* ajouter `correctChoiceIds` pour multiple ;
* ne jamais exposer ces champs pré-submit ;
* valider applicativement la cohérence entre `selectionMode` et les champs corrects.

### `QuestionVisual`

Modèle conceptuel recommandé :

```prisma
model QuestionVisual {
  id           String             @id @default(cuid())
  questionId   String
  type         QuestionVisualType
  displayOrder Int                @default(0)
  payload      Json
  createdAt    DateTime           @default(now())

  question Question @relation(fields: [questionId], references: [id], onDelete: Cascade)
  sources  QuestionVisualSource[]

  @@index([questionId])
  @@unique([questionId, displayOrder])
}
```

### `QuestionVisualSource`

Modèle conceptuel recommandé :

```prisma
model QuestionVisualSource {
  visualId       String
  subjectId      String
  chunkId        String
  relevanceScore Float?
  createdAt      DateTime @default(now())

  visual QuestionVisual @relation(fields: [visualId], references: [id], onDelete: Cascade)
  chunk  DocumentChunk   @relation(fields: [chunkId, subjectId], references: [id, subjectId], onDelete: Cascade)

  @@id([visualId, chunkId])
  @@index([chunkId])
  @@index([subjectId])
}
```

### `QuestionAnswer`

Options étudiées :

* `selectedChoiceIds Json?` dans `QuestionAnswer` ;
* table dédiée `QuestionAnswerChoice`.

Recommandation :

* MVP court : `selectedChoiceIds Json?` est acceptable si validé strictement ;
* solution robuste : `QuestionAnswerChoice` est préférable à moyen terme.

Contrat robuste conceptuel :

```prisma
model QuestionAnswerChoice {
  answerId String
  choiceId String

  answer QuestionAnswer @relation(fields: [answerId], references: [id], onDelete: Cascade)

  @@id([answerId, choiceId])
}
```

## 12. Contrat Genkit futur

Input conceptuel :

```ts
type DiagnosticQuizMediaGenerationInput = {
  subjectId: string;
  documentId?: string | null;
  knowledgeUnit: {
    id: string;
    title: string;
    summary: string;
    difficulty?: 'LOW' | 'MEDIUM' | 'HIGH' | null;
    sourceChunkIds?: string[];
  };
  chunks: Array<{
    id: string;
    index: number;
    text: string;
    pageNumber?: number | null;
  }>;
  questionCount: number;
  visualAllowed: boolean;
  visualTypesAllowed: Array<'IMAGE' | 'CHART' | 'DIAGRAM'>;
  selectionModesAllowed: Array<'single' | 'multiple'>;
};
```

Output conceptuel :

```ts
type DiagnosticQuizMediaGenerationOutput = {
  title: string;
  version: 3;
  questions: Array<{
    prompt: string;
    difficulty?: 'LOW' | 'MEDIUM' | 'HIGH' | null;
    selectionMode: 'single' | 'multiple';
    minSelections: number;
    maxSelections: number;
    choices: Array<{
      id: string;
      label: string;
      feedback?: string | null;
    }>;
    correctChoiceId?: string;
    correctChoiceIds?: string[];
    explanation: string;
    sourceChunkIds: string[];
    visuals?: QuestionVisualPayload[];
  }>;
};
```

Validation obligatoire :

* JSON strict ;
* pas de source libre ;
* pas d'image inventée ;
* pas d'URL externe inventée ;
* pas de chart data non sourcée ;
* pas de diagramme non sourcé ;
* `sourceChunkIds` valides pour chaque question ;
* `sourceChunkIds` valides pour chaque visuel ;
* `selectionMode` cohérent avec `correctChoiceId` ou `correctChoiceIds` ;
* `correctChoiceIds` min 1 en multi-réponse ;
* choix uniques ;
* feedback jamais exposé pré-submit.

Observabilité :

* observer flow, modèle, versions, tailles, statut, errorCode ;
* ne jamais logger prompt complet, chunks complets, `correctChoiceId`, `correctChoiceIds`, feedback ou explications.

## 13. Contrat Flutter futur

Modèles à prévoir :

* `DiagnosticQuizQuestion.selectionMode`
* `DiagnosticQuizQuestion.minSelections`
* `DiagnosticQuizQuestion.maxSelections`
* `DiagnosticQuizQuestion.visuals`
* `DiagnosticQuizAnswer.choiceIds`
* `DiagnosticQuizCorrectionItem.selectedChoiceIds`
* `DiagnosticQuizCorrectionItem.correctChoiceIds`
* `DiagnosticQuizCorrectionItem.partialScore`
* `QuestionVisual`
* `QuestionImageVisual`
* `QuestionChartVisual`
* `QuestionDiagramVisual`

Rendu attendu :

* image accessible avec `altText` ;
* chart renderer borné ;
* diagram renderer borné ;
* fallback si visuel invalide ;
* pas de rendu HTML ;
* pas de widget arbitraire ;
* sélection multiple uniquement si backend indique `selectionMode: multiple` ;
* correction détaillée post-submit seulement.

Anti-fuite :

* aucun `correctChoiceId` ou `correctChoiceIds` pré-submit ;
* aucun `isCorrect` pré-submit ;
* aucune explication pré-submit ;
* aucun feedback pré-submit ;
* pas de texte source complet pré-submit si risque de révélation.

## 14. Contrat GenUI futur

GenUI peut servir de rendu alternatif, jamais de source de vérité.

Composants potentiels :

* `McqQuestionCard`
* `McqCorrectionPanel`
* `ActivityResultCard`
* `QuestionImageCard`
* `QuestionChartCard`
* `QuestionDiagramCard`

Contraintes :

* payloads bornés ;
* validation stricte ;
* pas de payload arbitraire ;
* pas de correction dans un composant pré-submit ;
* pas de HTML libre ;
* pas de SVG libre ;
* pas de chart spec libre ;
* fallback natif obligatoire ;
* données reconstruites depuis objets métier validés.

Articulation recommandée :

* implémenter d'abord le backend et le fallback natif ;
* ajouter GenUI seulement après stabilisation du contrat API.

## 15. Sécurité anti-fuite

Règles non négociables :

* pas de `correctChoiceId` pré-submit ;
* pas de `correctChoiceIds` pré-submit ;
* pas de `isCorrect` pré-submit ;
* pas de feedback pré-submit ;
* pas d'explication pré-submit ;
* pas de source textuelle complète pré-submit si elle révèle la réponse ;
* pas de payload visuel arbitraire ;
* pas de média non sourcé ;
* pas de source libre IA comme autorité ;
* backend source de vérité pour correction ;
* frontend ne calcule jamais la correction.

La multi-réponse augmente le risque de fuite, car la structure interne doit gérer plusieurs bons choix. Les DTOs publics doivent donc être testés explicitement avec des payloads accidentellement enrichis pour vérifier que rien n'est exposé avant soumission.

## 16. Lots suivants recommandés

### LOT-025D — QCM média et multi-réponse : backend

À inclure :

* migration Prisma ;
* `QuestionVisual` ;
* `QuestionVisualSource` ;
* `QuestionSelectionMode` ;
* `QuestionVisualType` ;
* stockage correct choices multiples ;
* validation repository ;
* génération Genkit ;
* soumission multi-réponse ;
* correction ;
* tests anti-fuite.

### LOT-025E — QCM média et multi-réponse : UI

À inclure :

* modèles Flutter ;
* parsing DTOs futurs ;
* rendu image ;
* rendu chart ;
* rendu diagram ;
* sélection multiple ;
* correction multi ;
* sources visuelles ;
* tests widget anti-overflow et anti-fuite.

### LOT-030 — GenUI composants activité et correction

À faire après `LOT-025D` et après un fallback natif stable.

Décision :

* oui, `LOT-025D` doit venir avant `LOT-030` pour éviter que GenUI ne devienne une source de vérité ou un contournement du contrat métier.

## 17. Tests attendus pour LOT-025D

Tests Prisma/repository :

* persiste une question `SINGLE` existante sans régression ;
* persiste une question `MULTIPLE` avec plusieurs correct choices ;
* rejette `MULTIPLE` sans `correctChoiceIds` ;
* rejette `SINGLE` avec plusieurs correct choices ;
* persiste `QuestionVisual IMAGE` avec source ;
* persiste `QuestionVisual CHART` avec source ;
* persiste `QuestionVisual DIAGRAM` avec source ;
* rejette un visuel sans source ;
* rejette une source chunk inconnue ;
* rejette une source d'un autre document/sujet/student ;
* trie les visuels par `displayOrder`.

Tests Genkit :

* accepte output média valide ;
* rejette image URL externe arbitraire ;
* rejette base64 ;
* rejette chart data trop large ;
* rejette diagram edge vers node inconnu ;
* rejette source visuelle inconnue ;
* rejette multi-réponse sans `correctChoiceIds` ;
* rejette `correctChoiceIds` ne correspondant pas aux choix ;
* observabilité sans prompt/chunks/correct choices.

Tests API/use case :

* pré-submit ne fuit pas `correctChoiceId` ;
* pré-submit ne fuit pas `correctChoiceIds` ;
* pré-submit ne fuit pas feedback ;
* pré-submit ne fuit pas explication ;
* submit single compatible ;
* submit multiple accepte `choiceIds` ;
* submit multiple rejette doublons ;
* submit multiple rejette choix inconnus ;
* double submit interdit ;
* correction post-submit expose les bons champs.

## 18. Tests attendus pour LOT-025E

Tests data :

* parse `selectionMode: single` ;
* parse `selectionMode: multiple` ;
* parse visuel image ;
* parse visuel chart ;
* parse visuel diagram ;
* rejette visuel inconnu ;
* ignore toute correction accidentelle pré-submit ;
* parse correction multi-réponse post-submit.

Tests controller :

* sélection single inchangée ;
* sélection multiple ajoute et retire un choix ;
* respecte `minSelections` ;
* respecte `maxSelections` ;
* submit envoie `choiceId` pour single ;
* submit envoie `choiceIds` pour multiple ;
* correction conservée après submit.

Tests widget :

* image affiche `altText` et caption ;
* chart rendu sans overflow ;
* diagram rendu sans overflow ;
* multi-réponse affiche cases/toggles appropriés ;
* aucune correction visible avant submit ;
* correction multi-réponse visible après submit ;
* sources visuelles affichées après correction ;
* fallback visuel invalide lisible.

## 19. Validations lancées

Comme ce lot est documentaire, validations prévues :

```bash
cd revision_app && git diff --check
cd api && git diff --check
```

Résultats à compléter après validation finale.

Résultats :

* `cd revision_app && git diff --check` : succès ;
* `cd api && git diff --check` : succès.

## 20. Validations non lancées

Non lancées volontairement :

* tests backend complets : aucun code backend modifié ;
* tests Flutter : aucun code Flutter modifié ;
* Prisma validate/generate : aucun changement Prisma ;
* migration : interdite et hors scope ;
* provider IA réel : interdit ;
* déploiement : interdit ;
* `npm run format` : interdit ;
* `npm run test:cov` : interdit.

## 21. Risques restants

* Complexité média importante.
* Extraction image PDF non prête.
* Risque de chart data halluciné.
* Risque de diagramme trop simplifié.
* Multi-réponse plus complexe à expliquer.
* Score partiel reporté.
* UI plus dense.
* Coût IA plus élevé si médias et multi-réponse sont générés.
* Validation DB/migrations toujours à surveiller dans les lots backend suivants.
* GenUI ne doit pas être introduit avant un fallback natif fiable.

## 22. Recommandation finale

Prochain lot recommandé si la priorité reste le QCM riche :

* `LOT-025D — QCM média et multi-réponse : backend`.

Prochain lot recommandé si la priorité est d'élargir les types d'activités :

* `LOT-026 — Contrat question ouverte`.

Décision produit proposée : faire `LOT-025D` avant `LOT-030`, et ne commencer GenUI QCM qu'une fois le backend et le fallback natif stables.
