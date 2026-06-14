# LOT-022 — Contrat QCM v2

## 1. Résultat

Le contrat QCM v2 retient une évolution compatible de l'activité `diagnostic_quiz` actuelle.

Décision principale :

- le QCM v2 reste mono-réponse pour le MVP;
- le DTO public pré-submit ne contient jamais `correctChoiceId`, `isCorrect`, explication de correction ou feedback révélateur;
- le backend reste la seule source de vérité pour corriger;
- la correction détaillée est exposée uniquement après submit;
- chaque question v2 doit être reliée à une `KnowledgeUnit` et à au moins un `DocumentChunk`;
- les sources libres générées par IA ne sont jamais autoritaires;
- le QCM actuel doit rester compatible jusqu'à ce que `LOT-023`, `LOT-024` et `LOT-025` soient terminés.

Ce lot ne modifie pas le backend applicatif, le frontend, Prisma, Genkit, GenUI ou les routes runtime. Il produit uniquement ce contrat et met à jour le tableau de suivi.

## 2. Sources inspectées

Documentation :

- `docs/ROADMAP.md`
- `docs/ROADMAP_EXECUTION_PLAN.md`
- `docs/ROADMAP_EXECUTION_LOT_014_015_016.md`
- `docs/ROADMAP_EXECUTION_LOT_017.md`
- `docs/ROADMAP_EXECUTION_LOT_018.md`
- `docs/ROADMAP_EXECUTION_LOT_019_020.md`
- `docs/ROADMAP_EXECUTION_LOT_021_029.md`
- `AGENTS.md`
- `codex_rule.md`

Backend :

- `../api/prisma/schema.prisma`
- `../api/src/modules/activities/interfaces/activities.controller.ts`
- `../api/src/modules/activities/application/activities.repository.ts`
- `../api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `../api/src/modules/activities/application/start-next-activity.use-case.ts`
- `../api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `../api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `../api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `../api/src/modules/revision/domain/mastery-state.entity.ts`
- `../api/src/modules/documents/**` par recherche ciblée sources/chunks
- `../api/src/modules/study-artifacts/**` par recherche ciblée conventions sources

Frontend :

- `lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `lib/features/activities/application/activity_controller.dart`
- `lib/features/activities/data/http_activities_api.dart`
- `lib/features/activities/data/demo_activity_api.dart`
- `lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `lib/features/activities/genui/revision_activity_catalog.dart`
- `lib/presentation/pages/activities/activities_page.dart`
- `lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `test/features/activities/**`
- `lib/features/documents/**`
- `lib/presentation/pages/documents/**`

## 3. Préflight Git

API initial :

- racine : `/Users/karim/Project/app-révision/api`
- HEAD : `83f80ec #124: ajoute générateurs de résumés et fiches de révision avec GenKit`
- état : clean

Frontend initial :

- racine : `/Users/karim/Project/app-révision/revision_app`
- HEAD : `318030b LOT_019_020_021_029 - Mise à jour catalogue GenUI, validateur de composants, widgets documents et rapports LOT_019_020 et LOT_021_029`
- état : clean

Fichiers hors scope :

- aucun fichier modifié ou non suivi au démarrage;
- aucun fichier runtime backend/frontend n'a été modifié;
- seules modifications prévues : ce rapport et le tableau de suivi de `docs/ROADMAP_EXECUTION_PLAN.md`.

## 4. QCM actuel

### Endpoints existants

Le backend expose actuellement :

```text
POST /activities/next
POST /activities/:sessionId/result
```

`POST /activities/next` reçoit :

```json
{
  "subjectId": "subject-1",
  "knowledgeUnitId": "unit-1"
}
```

`knowledgeUnitId` est optionnel. Si absent, `StartNextActivityUseCase` choisit une notion via les mastery states existants.

`POST /activities/:sessionId/result` reçoit :

```json
{
  "answers": [
    {
      "questionId": "question-1",
      "choiceId": "choice-1"
    }
  ]
}
```

### Modèles Prisma actuels

`ActivitySession` :

- `id`
- `studentId`
- `subjectId`
- `knowledgeUnitId`
- `type`
- `status`
- `createdAt`
- `completedAt`
- relation vers `Question[]`
- relation vers `ActivityResult?`

`Question` :

- `id`
- `sessionId`
- `knowledgeUnitId`
- `prompt`
- `choices` en JSON
- `correctChoiceId`
- `explanation`

`ActivityResult` :

- `id`
- `sessionId`
- `correctAnswers`
- `totalQuestions`
- `createdAt`

### Générateur Genkit actuel

`GenkitDiagnosticQuizGenerator` prend une seule `KnowledgeUnit` en input.

Le schéma actuel produit :

- `title`
- `questions[]`
  - `prompt`
  - `choices[]`
    - `id`
    - `label`
  - `correctChoiceId`
  - `explanation`

Le flow actuel :

- limite à 1 à 3 questions;
- limite à 2 à 4 choix;
- impose un seul `correctChoiceId`;
- vérifie que le `correctChoiceId` appartient aux choix;
- observe le flow avec `AiGenerationObserver`;
- ne stocke pas prompt/completion.

Limite majeure : le flow ne reçoit pas encore les chunks et ne peut pas produire de `sourceChunkIds`.

### DTO public actuel

Le DTO public de démarrage renvoyé au frontend contient :

```json
{
  "sessionId": "session-1",
  "type": "diagnostic_quiz",
  "title": "Diagnostic",
  "questions": [
    {
      "id": "question-1",
      "prompt": "Question ?",
      "choices": [
        {
          "id": "a",
          "label": "Réponse A"
        }
      ]
    }
  ]
}
```

Le repository mappe les questions via `toActivityQuestion`, qui ne retourne pas `correctChoiceId` ni `explanation`. C'est un point sain à préserver.

### Soumission actuelle

Le backend :

- vérifie que la session appartient au `studentId`;
- rejette une session absente;
- rejette une session déjà complétée;
- rejette les réponses dupliquées;
- rejette une question inconnue pour la session;
- rejette un choix qui n'appartient pas à la question;
- calcule `correctAnswers`;
- crée `ActivityResult`;
- marque `ActivitySession` en `COMPLETED`;
- met à jour `MasteryState` via `applyQuizResult`.

### Correction actuelle

La réponse après submit est limitée à :

```json
{
  "correctAnswers": 1,
  "totalQuestions": 2
}
```

Il n'y a pas encore :

- correction par question;
- `selectedChoiceId`;
- `correctChoiceId` post-submit;
- explication visible;
- feedback par choix;
- sources affichées;
- score par notion;
- détail de mastery delta.

### Frontend actuel

Le frontend :

- charge l'activité via `ActivityController.startNextActivity`;
- parse `DiagnosticQuizActivity`;
- affiche `DiagnosticQuizPage`;
- envoie une réponse par question;
- affiche uniquement `Score X / Y`;
- ne connaît pas la bonne réponse avant submit;
- ne reçoit pas de correction détaillée après submit.

### Limites actuelles

- Le QCM est lié à une seule `KnowledgeUnit` au niveau session.
- Les questions ne sont pas sourcées par `DocumentChunk`.
- La difficulté n'est pas exposée.
- L'explication existe en base mais n'est pas exposée après submit.
- La correction n'est pas persistée de manière exploitable par question.
- Les réponses utilisateur ne sont pas historisées question par question.
- Le mastery update est global sur la notion de session, pas par question.

## 5. Problème à résoudre

Le QCM v2 est nécessaire pour transformer le diagnostic actuel en activité pédagogique exploitable.

Objectifs :

- empêcher toute fuite de `correctChoiceId` avant submit;
- ajouter une correction détaillée après submit;
- afficher une explication pédagogique;
- relier chaque question à une notion;
- relier chaque question à des chunks sources vérifiables;
- préparer le feedback par question et éventuellement par choix;
- préparer une mise à jour de maîtrise plus fine;
- garder un fallback Flutter natif robuste;
- préparer plus tard GenUI QCM sans rendre de payload arbitraire.

Le risque principal est de modifier le DTO public de démarrage en y exposant des champs internes, ou de stocker une correction dans un payload GenUI réutilisable avant submit. Le contrat interdit ces deux chemins.

## 6. Principes non négociables du QCM v2

- Le DTO public pré-submit ne contient jamais `correctChoiceId`.
- Le DTO public pré-submit ne contient jamais `isCorrect`.
- Le DTO public pré-submit ne contient jamais d'explication révélant la bonne réponse.
- Le DTO public pré-submit ne contient jamais de feedback par choix.
- Le backend reste source de vérité pour la correction.
- Le frontend ne calcule jamais la correction.
- La correction détaillée est disponible uniquement après submit réussi.
- Le QCM MVP reste mono-réponse.
- Les choix peuvent être stockés dans un ordre serveur stable; si randomisation il y a, elle doit être faite côté serveur avant persistance, jamais côté client.
- Les choix doivent avoir des IDs opaques, non dérivables du contenu correct.
- `correctChoiceId` peut être stocké en DB mais ne doit jamais être mappé dans un DTO pré-submit.
- Cross-student doit se comporter comme une absence de session ou une erreur non révélatrice.
- Une réponse inconnue est rejetée.
- Une question inconnue est rejetée.
- Un choix qui n'appartient pas à la question est rejeté.
- Les réponses dupliquées pour une même question sont rejetées.
- Le double submit est interdit pour le MVP : `409 Activity session already completed`.
- Aucune correction ne doit être stockée dans un payload GenUI arbitraire.
- Les sources libres générées par IA ne sont jamais autoritaires.

## 7. Contrat public QCM pré-submit

DTO recommandé :

```json
{
  "sessionId": "activity-session-1",
  "type": "diagnostic_quiz",
  "version": 2,
  "documentId": "document-1",
  "subjectId": "subject-1",
  "title": "Quiz de diagnostic",
  "questions": [
    {
      "id": "question-1",
      "knowledgeUnitId": "unit-1",
      "prompt": "Question ?",
      "difficulty": "MEDIUM",
      "choices": [
        {
          "id": "choice-1",
          "label": "Réponse A"
        },
        {
          "id": "choice-2",
          "label": "Réponse B"
        }
      ],
      "sources": [
        {
          "chunkId": "chunk-1",
          "pageNumber": null,
          "index": 0
        }
      ]
    }
  ]
}
```

Champs obligatoires :

- `sessionId`;
- `type`;
- `version`;
- `subjectId`;
- `title`;
- `questions`;
- `questions[].id`;
- `questions[].knowledgeUnitId`;
- `questions[].prompt`;
- `questions[].choices`;
- `questions[].choices[].id`;
- `questions[].choices[].label`.

Champs recommandés :

- `documentId` si le QCM est généré depuis un document sourcé;
- `questions[].difficulty`;
- `questions[].sources[]` sans texte source.

Décisions :

- `documentId` n'est pas obligatoire pour préserver la compatibilité avec des notions sans document historique, mais il doit être présent dès que la notion vient d'un document.
- `knowledgeUnitId` est obligatoire par question en v2.
- MVP mono-réponse uniquement.
- Les sources sont présentes avant submit sous forme de références légères (`chunkId`, `pageNumber`, `index`) si elles ne révèlent pas la réponse.
- Le texte des sources est reporté après submit pour éviter qu'un extrait trop explicite révèle la bonne réponse.
- `difficulty` est recommandé mais peut rester optionnel si les anciennes questions cohabitent.
- `correctChoiceId`, `isCorrect`, `explanation`, `choiceFeedback`, `masteryDelta` sont interdits avant submit.

## 8. Stockage interne recommandé

Le stockage interne doit séparer strictement :

- le contenu affichable avant submit;
- la correction interne;
- la correction publique après submit;
- les réponses de l'étudiant.

Extensions conceptuelles possibles, sans modification Prisma dans ce lot :

### `Question`

Champs à ajouter ou confirmer :

- `documentId String?`
- `subjectId String`
- `difficulty KnowledgeUnitDifficulty?`
- `displayOrder Int`
- `promptVersion String?`
- `schemaVersion String?`
- `sourceStrategy String?`

Champs internes à conserver :

- `correctChoiceId`
- `explanation`

### `QuestionChoice`

Option recommandée pour `LOT-024` : sortir progressivement `choices` du JSON vers une table dédiée si la migration reste raisonnable.

Modèle conceptuel :

- `id`
- `questionId`
- `label`
- `displayOrder`
- `feedback`
- `createdAt`

Alternative compatible MVP : garder `choices` en JSON et ajouter `choiceFeedback` en JSON contrôlé. Cette option est moins typée et moins robuste.

Recommandation : table dédiée `QuestionChoice` si `LOT-024` accepte une migration claire; sinon JSON temporaire avec validation stricte.

### `QuestionSource`

Modèle recommandé :

- `questionId`
- `subjectId`
- `chunkId`
- `relevanceScore`
- `createdAt`

Contraintes :

- `@@id([questionId, chunkId])`;
- relation vers `Question`;
- relation composite vers `DocumentChunk(id, subjectId)`;
- vérification repository que le chunk appartient au document attendu si `documentId` est présent.

### `QuestionAnswer`

Modèle recommandé :

- `id`
- `sessionId`
- `questionId`
- `selectedChoiceId`
- `isCorrect`
- `createdAt`

Contraintes :

- `@@unique([sessionId, questionId])`;
- session ownership vérifié au repository;
- `selectedChoiceId` doit appartenir à la question.

### `ActivityResult`

Champs à ajouter ou DTO dérivé :

- `score Float`
- `completedAt DateTime`
- éventuellement `masteryDelta Float?` si la stratégie de maîtrise devient explicite.

Les métadonnées IA peuvent rester au niveau `ActivitySession` ou `Question` :

- `flowName`
- `provider`
- `model`
- `promptVersion`
- `schemaVersion`
- `inputSize`

Ne pas stocker :

- prompt complet;
- completion complète;
- chunk complet dans un JSON de question;
- correction dans un payload GenUI.

## 9. Contrat de soumission

Endpoint recommandé en compatibilité :

```text
POST /activities/:sessionId/result
```

DTO :

```json
{
  "answers": [
    {
      "questionId": "question-1",
      "choiceId": "choice-2"
    }
  ]
}
```

Décisions :

- une réponse par question pour le MVP;
- un `questionId` manquant ou vide : `400`;
- un `choiceId` manquant ou vide : `400`;
- une question absente de la session : `400` ou `404` selon convention retenue, avec préférence `400` pour compatibilité actuelle;
- un choix qui n'appartient pas à la question : `400`;
- une réponse dupliquée : `400`;
- un submit incomplet peut être rejeté en `400` si le MVP exige toutes les questions;
- une session déjà complétée : `409`;
- une session expirée future : `409`;
- une session appartenant à un autre étudiant : `404`;
- le backend calcule toute la correction dans une transaction.

Point à trancher en `LOT-024` :

- conserver la convention actuelle `400` pour question/choix invalides;
- ou passer à `404` pour question absente et `422` pour choix invalide.

Pour compatibilité, conserver `400` au départ est recommandé.

## 10. Contrat de correction après submit

DTO recommandé :

```json
{
  "sessionId": "activity-session-1",
  "score": 0.75,
  "correctCount": 3,
  "totalCount": 4,
  "items": [
    {
      "questionId": "question-1",
      "knowledgeUnitId": "unit-1",
      "prompt": "Question ?",
      "selectedChoiceId": "choice-2",
      "correctChoiceId": "choice-1",
      "isCorrect": false,
      "explanation": "Explication pédagogique.",
      "choiceFeedback": [
        {
          "choiceId": "choice-1",
          "feedback": "Pourquoi c'était correct."
        },
        {
          "choiceId": "choice-2",
          "feedback": "Pourquoi c'était incorrect."
        }
      ],
      "sources": [
        {
          "chunkId": "chunk-1",
          "text": "Extrait source.",
          "pageNumber": null,
          "index": 0
        }
      ],
      "masteryDelta": -0.1
    }
  ]
}
```

Décisions :

- `correctChoiceId` est exposé après submit;
- `selectedChoiceId` est exposé après submit;
- `isCorrect` est exposé après submit;
- `explanation` par question est obligatoire;
- sources avec texte exposées après submit;
- `choiceFeedback` est recommandé mais peut être optionnel pour le premier MVP si le flow Genkit v2 et la migration deviennent trop gros;
- `score` est un ratio entre 0 et 1;
- `correctCount` et `totalCount` remplacent progressivement `correctAnswers` et `totalQuestions` côté v2;
- pour compatibilité, le backend peut aussi garder `correctAnswers` et `totalQuestions` pendant une période transitoire;
- `masteryDelta` peut être exposé si le calcul est stable, sinon rester interne au MVP.

Multi-réponse :

- reporté;
- pas de correction partielle dans le MVP;
- le schéma doit rester mono-réponse pour éviter les ambiguïtés de score.

## 11. Sources et anti-hallucination

Stratégie retenue :

- le QCM v2 est généré depuis `KnowledgeUnit` + `DocumentChunk`;
- chaque question doit référencer au moins une `KnowledgeUnit`;
- chaque question doit référencer au moins un `DocumentChunk` quand la notion est sourcée;
- source par question pour le MVP;
- source par feedback ou par choix reportée;
- les sources affichées après submit viennent uniquement de `DocumentChunk`;
- aucune source libre IA n'est autoritaire;
- `sourceChunkIds` inconnus sont rejetés;
- `sourceChunkIds` d'un autre document, sujet ou étudiant sont rejetés;
- ne pas créer de `SourceReference` globale.

Réutilisation de `KnowledgeUnitSource` :

- utile comme contexte de génération;
- insuffisant comme preuve pour chaque question;
- le QCM v2 doit avoir ses propres `QuestionSource`, car une question peut ne couvrir qu'une partie des sources d'une notion.

## 12. Genkit QCM v2 — contrat futur

`LOT-023` devra créer ou faire évoluer le port Genkit QCM.

Input recommandé :

- `documentId?`
- `subjectId`
- `knowledgeUnit`
  - `id`
  - `title`
  - `summary`
  - `difficulty?`
- `chunks[]`
  - `id`
  - `index`
  - `text`
  - `pageNumber?`

Output attendu :

- `title`
- `questions[]`
  - `prompt`
  - `difficulty`
  - `choices[]`
    - `id`
    - `label`
    - `feedback?`
  - `correctChoiceId`
  - `explanation`
  - `sourceChunkIds`

Schéma Zod attendu :

- `.strict()` partout;
- 1 à 5 questions selon paramètre;
- 2 à 4 choix par question;
- un seul `correctChoiceId`;
- IDs de choix uniques;
- `correctChoiceId` inclus dans les choix;
- `sourceChunkIds` min 1;
- `sourceChunkIds` tous connus;
- `difficulty` bornée `LOW | MEDIUM | HIGH`;
- `explanation` non vide;
- feedback par choix optionnel au MVP, mais si présent : un feedback par choix connu.

Versions recommandées :

- `flowName = diagnosticQuizGeneration`
- `promptVersion = diagnostic-quiz-v2`
- `schemaVersion = diagnostic-quiz-v2`

Observabilité :

- observer `flowName`, `provider`, `model`, `promptVersion`, `schemaVersion`, `inputSize`, `durationMs`, `status`, `errorCode`, `documentId`, `knowledgeUnitId`, `subjectId`;
- ne jamais observer prompt complet, completion complète, chunks, réponses utilisateur ou correction.

## 13. Persistance et soumission QCM v2 — contrat futur

`LOT-024` devra produire :

- migration Prisma;
- repository enrichi;
- use cases de création/soumission;
- correction détaillée;
- mastery update;
- tests de non-fuite.

Périmètre Prisma futur recommandé :

- `Question.documentId?`;
- `Question.subjectId`;
- `Question.difficulty?`;
- `Question.displayOrder`;
- `Question.promptVersion?`;
- `Question.schemaVersion?`;
- `QuestionSource`;
- `QuestionAnswer`;
- éventuellement `QuestionChoice`;
- éventuels champs `ActivityResult.score`, `ActivityResult.completedAt`.

Use cases :

- création QCM v2 depuis une notion et ses chunks;
- soumission transactionnelle;
- persistance des réponses;
- calcul correction;
- création résultat;
- update mastery.

Tests obligatoires :

- le DTO pré-submit ne contient pas `correctChoiceId`;
- `correctChoiceId` reste accessible seulement en interne;
- submit happy path retourne correction détaillée;
- question inconnue rejetée;
- choix inconnu rejeté;
- choix d'une autre question rejeté;
- double submit rejeté;
- cross-student rejeté;
- sources inconnues rejetées;
- sources cross-document rejetées;
- mastery update stable.

## 14. UI QCM v2 — contrat futur

`LOT-025` devra produire :

- modèles Flutter v2;
- parsing du DTO pré-submit;
- parsing du DTO correction;
- controller d'activité avec états `loading`, `submitting`, `submitted`, `error`;
- refactor de `DiagnosticQuizPage` ou nouvelle page compatible;
- aucune correction visible avant submit;
- sélection mono-réponse;
- bouton submit désactivé tant que toutes les questions obligatoires n'ont pas une réponse;
- correction détaillée après submit;
- affichage `correctChoiceId` uniquement après submit;
- sources avec texte affichées après submit;
- gestion double submit côté UI;
- fallback natif complet.

Modèles Flutter conceptuels :

- `DiagnosticQuizActivityV2`
- `DiagnosticQuizQuestionV2`
- `DiagnosticQuizChoiceV2`
- `DiagnosticQuizQuestionSourceRef`
- `DiagnosticQuizAnswer`
- `DiagnosticQuizCorrection`
- `DiagnosticQuizCorrectionItem`
- `DiagnosticQuizChoiceFeedback`
- `DiagnosticQuizCorrectionSource`

Tests widget :

- pas de bonne réponse avant submit;
- submit envoie les réponses;
- correction affiche sélection, bonne réponse et explication;
- sources affichées après submit;
- erreur API affichée;
- double tap submit ne double-submit pas.

## 15. GenUI QCM futur

À réserver pour `LOT-030`.

Composants futurs :

- `McqQuestionCard`;
- `McqCorrectionPanel`;
- `ActivityResultCard`.

Principes :

- payloads bornés;
- validation stricte;
- pas de `correctChoiceId` dans `McqQuestionCard` pré-submit;
- `McqCorrectionPanel` autorisé seulement après correction;
- fallback natif obligatoire;
- aucun widget arbitraire;
- aucun payload GenUI persistant comme source de vérité.

## 16. Erreurs API futures

Statuts recommandés :

- `400` : payload invalide, réponse dupliquée, question/choix incohérent si compatibilité actuelle conservée;
- `401` : auth guard;
- `404` : session absente ou cross-student;
- `409` : session déjà terminée, double submit, session expirée future;
- `422` : output IA invalide ou source IA inconnue pendant génération;
- `502` : provider IA indisponible;
- `500` : erreur inattendue non classée.

Convention à préserver :

- ne pas révéler si une session existe chez un autre étudiant;
- ne pas révéler les IDs internes de correction dans les erreurs pré-submit;
- garder les messages courts et non sensibles.

## 17. Compatibilité avec l'existant

Recommandation :

- préserver `POST /activities/next` et `POST /activities/:sessionId/result` pendant la transition;
- ajouter `version: 2` dans le DTO v2;
- ne pas casser les champs existants `sessionId`, `type`, `title`, `questions`, `choices`;
- enrichir progressivement les DTOs sans obliger le frontend actuel à consommer les nouveaux champs;
- conserver l'ancien QCM en fallback tant que le v2 n'est pas complet;
- éviter un endpoint public séparé tant que le type reste `diagnostic_quiz`;
- introduire un endpoint dédié seulement si le v2 nécessite un workflow incompatible.

Option alternative :

```text
POST /activities/diagnostic-quiz
POST /activities/:sessionId/answers
```

Cette option est plus explicite, mais elle risque de dupliquer le parcours actuel. Elle peut être retenue plus tard si les activités deviennent multi-types.

Décision MVP :

- évolution compatible des endpoints existants;
- DTO v2 détectable via `version: 2`;
- tests de non-régression sur les DTOs actuels.

## 18. Découpage recommandé des lots suivants

### LOT-023 — Genkit QCM enrichi

Doit inclure :

- port ou extension de `DiagnosticQuizGenerator`;
- input basé sur `KnowledgeUnit` + chunks;
- sélection bornée des chunks;
- schéma Zod v2;
- prompt v2;
- validation source;
- validation mono-réponse;
- observabilité;
- tests Genkit mockés.

Ne doit pas inclure :

- migration;
- persistance réponses;
- UI;
- GenUI QCM.

### LOT-024 — Persistance et soumission QCM enrichies

Doit inclure :

- migration Prisma;
- repository;
- use cases;
- DTO public pré-submit;
- DTO correction post-submit;
- endpoints compatibles;
- `QuestionSource`;
- réponses persistées;
- correction détaillée;
- mastery update;
- tests controller/use case/repository.

Ne doit pas inclure :

- UI Flutter;
- GenUI QCM;
- question ouverte.

### LOT-025 — UI QCM enrichi

Doit inclure :

- data layer Flutter;
- modèles v2;
- controller;
- UI de réponse;
- UI de correction;
- sources après submit;
- états loading/submitting/submitted/error;
- tests widget.

Recommandation de regroupement :

- `LOT-023` doit rester seul, car le contrat Genkit est sensible et les risques de sources invalides sont élevés;
- `LOT-024` doit rester seul si la migration introduit `QuestionSource`, `QuestionAnswer` et potentiellement `QuestionChoice`;
- `LOT-025` doit venir après stabilisation API;
- ne pas regrouper `023 + 024 + 025` dans un seul batch.

## 19. Risques et décisions reportées

Risques :

- fuite `correctChoiceId` dans le DTO pré-submit;
- feedback trop verbeux ou trop révélateur;
- mauvaise source ou source trop explicite avant submit;
- QCM hors sujet si Genkit reçoit trop peu de contexte;
- coût IA plus élevé avec chunks;
- migration QCM plus complexe que prévu;
- scoring/mastery trop arbitraire;
- double submit en concurrence;
- compatibilité ancien QCM;
- UI correction trop longue sur mobile;
- GenUI trop permissif.

Décisions reportées :

- multi-réponse;
- timer;
- randomisation serveur avancée;
- historique complet des tentatives;
- plusieurs tentatives par session;
- analyse fine par compétence;
- feedback par choix obligatoire ou optionnel;
- GenUI QCM;
- intégration coach session.

## 20. Critères d'acceptation pour LOT-023

`LOT-023` peut être considéré terminé seulement si :

- le schéma Genkit v2 ne produit que des données internes contrôlées;
- chaque question a une seule bonne réponse;
- chaque question a au moins deux choix;
- chaque question a au moins une source connue;
- chaque source inconnue est rejetée;
- chaque output sans source est rejeté;
- les choix ont des IDs uniques;
- `correctChoiceId` est validé mais jamais exposé par un DTO public dans ce lot;
- les tests provider mockés couvrent succès et erreurs;
- l'observabilité ne contient ni prompt, ni completion, ni chunks complets;
- aucune persistance QCM v2 n'est introduite si `LOT-023` reste isolé.

## 21. Validations lancées

Ce lot est documentaire. Validations prévues :

```text
cd /Users/karim/Project/app-révision/revision_app && git diff --check
cd /Users/karim/Project/app-révision/api && git diff --check
```

## 22. Validations non lancées

- Tests backend non lancés : aucun code backend modifié.
- Tests Flutter non lancés : aucun code Flutter modifié.
- Migrations non lancées : aucun schéma Prisma modifié.
- Provider IA réel non lancé : interdit et hors périmètre.
- Déploiement non lancé : interdit et hors périmètre.

## 23. Recommandation finale

Contrat retenu :

- QCM v2 mono-réponse;
- DTO pré-submit sans fuite de correction;
- correction détaillée uniquement après submit;
- sources par question vers `DocumentChunk`;
- `QuestionSource` dédié dans le futur modèle;
- endpoints existants préservés au départ avec `version: 2`;
- GenUI QCM reporté à `LOT-030`.

Prochain lot recommandé :

- `LOT-023 — Genkit QCM enrichi`.

À ne pas faire trop tôt :

- ne pas modifier l'UI QCM avant le DTO correction stable;
- ne pas créer GenUI QCM avant fallback natif;
- ne pas ajouter multi-réponse avant mono-réponse stable;
- ne pas stocker correction dans payload GenUI;
- ne pas exposer le texte des sources avant submit si cela révèle la réponse.

## 24. Passes de review

Passe backend/API :

- l'existant expose seulement questions et choix avant submit;
- la correction actuelle est trop pauvre;
- les endpoints existants peuvent être conservés.

Passe modèle de données :

- `Question.correctChoiceId` existe déjà et doit rester interne;
- il manque `QuestionSource`, réponses persistées et sources par question;
- `QuestionChoice` dédié est recommandé si la migration reste raisonnable.

Passe anti-fuite correction :

- interdiction explicite de `correctChoiceId`, `isCorrect`, `explanation` et `choiceFeedback` avant submit;
- correction détaillée après submit seulement;
- texte source complet reporté après submit pour limiter les révélations.

Passe Genkit :

- v2 doit recevoir chunks et notion;
- v2 doit produire `sourceChunkIds`;
- output invalide ou non sourcé rejeté;
- observabilité sans contenu sensible.

Passe frontend :

- modèles v2 nécessaires;
- fallback natif prioritaire;
- aucune correction côté client;
- GenUI QCM reporté.

Passe critique finale :

- le contrat garde la compatibilité;
- le périmètre est découpé en trois lots réalistes;
- le point critique de non-fuite est explicite;
- les décisions plus ambitieuses sont reportées.
