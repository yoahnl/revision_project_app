# Audit — Prisma, DTO et versioning rich closed questions

## 1. Inventaire des modèles Prisma actuels liés aux activités

### `ActivitySession`

Le modèle représente une activité démarrée par un étudiant.

Champs utiles :

- `studentId`
- `subjectId`
- `documentId`
- `knowledgeUnitId`
- `type`
- `status`
- metadata Genkit existante
- relation `questions`
- relation `result`
- relation `answers`
- relation `openQuestion`
- relation `openAnswerEvaluation`

Limite V1 : `type` ne connaît que `DIAGNOSTIC_QUIZ` et `OPEN_QUESTION`.

### `Question`

Le modèle est centré sur le QCM :

- `prompt`
- `choices Json`
- `selectionMode`
- `minSelections`
- `maxSelections`
- `correctChoiceId`
- `correctChoiceIds Json`
- `explanation`
- relations `sources`, `answers`, `visuals`

Réutilisable pour V1-A :

- `prompt`
- `difficulty`
- `displayOrder`
- `sources`
- `visuals` pour certains types futurs.

Manquant pour V1-A :

- `questionKind`
- `interactionPayload`
- `answerShape`
- `correctionPayload`
- paires matching ;
- ordre attendu ;
- mini-cas dédié ;
- error options dédiées.

### `QuestionAnswer`

Le modèle stocke :

- `selectedChoiceId`
- `isCorrect`
- relation `selectedChoices`

Limite V1 : il ne stocke pas des paires, un ordre, une erreur choisie ou une réponse structurée par type. La persistance de réponse est donc une décision centrale, pas un détail.

### `QuestionAnswerChoice`

Table join pour les choix sélectionnés en multi-réponse.

Réutilisable seulement pour `multiple_choice`.

### `ActivityResult`

Stocke un résultat agrégé :

- `correctAnswers`
- `totalQuestions`
- `score`

Réutilisable partiellement, mais V1 devra décider si `correctAnswers` suffit pour les scorings partiels.

### `QuestionVisual` et `QuestionVisualSource`

Supportent `IMAGE`, `CHART`, `DIAGRAM`, avec payload JSON et sources. `IMAGE` existe dans Prisma mais l'API publique QCM le refuse encore.

## 2. Inventaire des DTO publics pré-submit

Le QCM public expose aujourd'hui :

- `sessionId`
- `type: diagnostic_quiz`
- `version`
- `title`
- `documentId`
- `subjectId`
- `questions`
- par question :
  - `id`
  - `knowledgeUnitId`
  - `prompt`
  - `difficulty`
  - `selectionMode`
  - `minSelections`
  - `maxSelections`
  - `choices`
  - `sources`
  - `visuals`

Champs privés absents pré-submit :

- `correctChoiceId`
- `correctChoiceIds`
- `explanation`
- `choiceFeedback`
- texte complet de sources.

Limite V1 : le DTO public reste orienté “question + choix”.

## 3. Inventaire des DTO post-submit

La correction QCM expose :

- `correctAnswers`
- `totalQuestions`
- `score`
- `items`
- par item :
  - `questionId`
  - `knowledgeUnitId`
  - `prompt`
  - `selectedChoiceId`
  - `selectedChoiceIds`
  - `correctChoiceId`
  - `correctChoiceIds`
  - `isCorrect`
  - `partialScore`
  - `explanation`
  - `choiceFeedback`
  - sources textuelles post-submit.

Limite V1 : le DTO post-submit ne sait pas représenter paires, ordre, erreur détectée, ou correction par cellule.

## 4. Inventaire des champs privés de correction

Champs privés QCM existants :

- `correctChoiceId`
- `correctChoiceIds`
- `explanation`
- `feedback`
- `choiceFeedback`

Champs privés V1-A à prévoir :

- `correctChoiceId`
- `correctChoiceIds`
- `correctPairs`
- `correctOrder`
- `correctErrorId`
- `explanation`
- `partialScore` post-submit seulement.

## 5. Inventaire des mappings publics dans `PrismaActivitiesRepository`

Le repository :

- persiste les questions QCM ;
- mappe les choix et sources ;
- relit une activité pré-submit sans correction ;
- score single/multiple ;
- expose correction après submit.

Limite V1 : le scoring est branché sur `selectionMode`, pas `questionKind`.

## 6. Inventaire des modèles Flutter existants

`DiagnosticQuizActivity` contient :

- `DiagnosticQuizQuestion`
- `DiagnosticQuizSelectionMode`
- `DiagnosticQuizChoice`
- `DiagnosticQuizSourceRef`
- `DiagnosticQuizVisual`
- `DiagnosticQuizResult`
- `DiagnosticQuizCorrectionItem`

Le modèle Flutter sait gérer :

- choix unique ;
- choix multiple ;
- chart/diagram ;
- correction post-submit.

Il ne sait pas encore gérer :

- matching ;
- ordering ;
- case qualification comme type distinct ;
- error detection comme type distinct ;
- answer union discriminée ;
- correction union discriminée.

## 7. Inventaire des validators GenUI existants

Le catalogue GenUI contient :

- `McqQuestionCard`
- `McqCorrectionPanel`
- `ActivityResultCard`
- `QuestionChartCard`
- `QuestionDiagramCard`

Les validators interdisent déjà les champs de correction dans `McqQuestionCard`.

Limite V1 : aucun validator GenUI ne couvre les types V1-A riches. GenUI ne doit pas être utilisé pour définir le contrat.

## 8. Ce qui est réutilisable pour V1-A

- `ActivitySession` comme concept d'activité démarrée.
- Ownership `studentId`.
- Sources via `DocumentChunk`.
- Séparation pré-submit/post-submit.
- Logs metadata-only.
- Tests anti-fuite QCM.
- Concepts `selectionMode` pour `single_choice` et `multiple_choice`.
- Primitives UI Flutter pour choix.
- TodayPlan et revision sessions comme orchestrateurs futurs.

## 9. Ce qui manque pour V1-A

- `questionKind`.
- Type applicatif discriminé.
- Submit DTO discriminé.
- Stockage de réponses non choix.
- Stockage de corrections non choix.
- Mapper public riche fermé.
- Scoring par type.
- Quality gates pédagogiques.
- Widgets Flutter matching/ordering.
- Routing vers activité ciblée sans tomber automatiquement sur `open_question`.

## 10. Ce qui manque pour V1-B/C/D

- Grilles vrai/faux.
- Sliders accessibles.
- Frises chronologiques.
- Matrices institutionnelles.
- Schémas à slots.
- Calcul déterministe vérifiable.
- Chaîne d'assets image allowlistée.
- Tests d'accessibilité plus complets.

## 11. Risques si on surcharge `Question`

- Le modèle devient un fourre-tout.
- `QuestionAnswer` reste inadapté.
- Les DTO publics risquent de simuler matching/ordering avec des choix.
- Le scoring single/multiple pourrait absorber des types qui méritent une logique propre.
- Les migrations futures deviennent plus difficiles à raisonner.

## 12. Risques si on crée une activité nouvelle

- Migration enum future.
- Today et sessions à enrichir.
- Frontend à router explicitement.
- Plus de fichiers et tests.

Ce risque est acceptable car la frontière produit est plus claire.

## 13. Risques si on choisit JSON typé

- Moins de contraintes DB.
- Bugs possibles si validators insuffisants.
- Requêtage analytique plus limité.

Mitigation :

- validators applicatifs stricts ;
- tests fixture-backed ;
- versioning explicite ;
- quality gates avant persistance.

## 14. Risques si on choisit tables spécialisées

- Big bang Prisma.
- Beaucoup de tables avant validation produit.
- Coût de maintenance plus élevé.

Cette option est reportée tant que V1-A n'est pas validée produit.

## 15. Recommandation de versioning

Nom recommandé : `rich-closed-question-v1`.

Ce nom versionne le contrat applicatif, pas le type d'activité Prisma.

La version doit être présente sur l'exercice public et interne.

## 16. Recommandation de séparation des payloads

Séparation retenue :

- `interactionPayload` public conceptuel : données nécessaires au rendu.
- `answerShape` public conceptuel : forme de réponse attendue.
- `correctionPayload` privé : données de correction.
- `sourceChunkIds` : IDs validés contre les chunks connus.
- `qualitySignals` : metadata-only, jamais contenu sensible.

Dans V1-004, cette séparation est représentée par des champs typés explicites et par un mapper public.

## 17. Décision versioning pour le passage V1-002→V1-005

Le passage crée un contrat applicatif pur, pas une persistance.

La future V1-007 devra décider comment mapper `rich-closed-question-v1` vers la DB.

## 18. Points à vérifier avant V1-006

- Le générateur Genkit ne doit produire que V1-A.
- Les quality gates doivent rejeter une sortie 100 % `single_choice`.
- Les tests doivent vérifier les sorties pauvres, les sources inconnues et les corrections pré-submit.
- Le prompt doit dire “tu dois” et non “tu peux”.

## 19. Points à vérifier avant V1-007

- Modèle de stockage de réponse structurée.
- Migration enum compatible.
- Client Prisma régénéré.
- Fallback pour anciens clients.

## 20. Points à vérifier avant V1-009

- Parser Flutter discriminé.
- Sealed `RichClosedAnswer`.
- Sealed correction item.
- Validation locale de complétion par type.
- Accessibilité matching/ordering.
