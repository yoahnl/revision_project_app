# LOT-025D — QCM média et multi-réponse : backend

## 1. Résultat

Le backend QCM v2 est étendu en QCM v3 pour supporter, côté serveur, les questions multi-réponses et les visuels bornés `CHART` / `DIAGRAM`, sans modifier Flutter, GenUI, les flows hors QCM, TodayPlan, l'upload ou les questions ouvertes.

Le chemin mono-réponse existant reste compatible. Le DTO public pré-submit ne contient toujours pas `correctChoiceId`, `correctChoiceIds`, `isCorrect`, `explanation`, `feedback` ni texte source complet. La correction post-submit peut exposer les champs de correction et les sources textuelles.

## 2. Sources inspectées

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_022.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_024B_AI_MODEL_FALLBACK.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`
- `api/package.json`
- `api/prisma/schema.prisma`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/activities.module.spec.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/infrastructure/mistral-model-fallback.ts`
- `revision_app/lib/features/activities/domain/diagnostic_quiz_activity.dart`
- `revision_app/lib/presentation/pages/activities/diagnostic_quiz_page.dart`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`

## 3. Préflight Git / Prisma

État initial API :

```text
## main...origin/main
```

État initial frontend/docs :

```text
## main...origin/main
```

Fichiers modifiés ou non suivis au préflight : aucun. Les modifications constatées ensuite correspondent au lot.

Validations préflight :

- `cd api && npm run build` : passé.
- `cd api && npx prisma validate` : passé.
- `cd api && npm run prisma:generate` : passé.
- `cd api && npx prisma migrate status` : échec avec `Schema engine error` sur `localhost:5432`, donc aucune validation runtime DB locale n'a été revendiquée.

Décision migration :

- La DB locale n'étant pas disponible pour `migrate dev`, la migration a été générée via `prisma migrate diff` depuis le snapshot `/tmp/revision_schema_before_lot025d.prisma`.
- La migration n'a pas été appliquée.
- Aucune commande destructive ou `migrate deploy` n'a été lancée.

## 4. Modèles Prisma ajoutés ou modifiés

Champs ajoutés à `Question` :

- `selectionMode QuestionSelectionMode @default(SINGLE)`
- `minSelections Int?`
- `maxSelections Int?`
- `correctChoiceId String?`
- `correctChoiceIds Json?`
- relation `visuals QuestionVisual[]`

Nouveaux enums :

- `QuestionSelectionMode`: `SINGLE`, `MULTIPLE`
- `QuestionVisualType`: `IMAGE`, `CHART`, `DIAGRAM`

Nouveaux modèles :

- `QuestionVisual`: visuel borné lié à une question, avec `type`, `displayOrder`, `payload` JSON validé applicativement.
- `QuestionVisualSource`: source d'un visuel vers `DocumentChunk`, avec relation composite `(chunkId, subjectId)`.
- `QuestionAnswerChoice`: table join pour les choix sélectionnés d'une réponse multiple.

Champs modifiés :

- `QuestionAnswer.selectedChoiceId` devient nullable pour les réponses multiples.
- `DocumentChunk` reçoit la relation inverse `questionVisualSources`.

## 5. Migration

Migration créée :

- `api/prisma/migrations/20260614190000_qcm_media_multi_backend/migration.sql`

Méthode :

```bash
cd api
npx prisma migrate diff --from-schema /tmp/revision_schema_before_lot025d.prisma --to-schema prisma/schema.prisma --script -o prisma/migrations/20260614190000_qcm_media_multi_backend/migration.sql
```

Résumé SQL :

- création des enums `QuestionSelectionMode` et `QuestionVisualType`;
- ajout des champs multi-réponse à `Question`;
- nullable sur `QuestionAnswer.selectedChoiceId`;
- création des tables `QuestionVisual`, `QuestionVisualSource`, `QuestionAnswerChoice`;
- indexes et clés étrangères vers `Question`, `DocumentChunk` et `QuestionAnswer`.

Limites :

- migration non appliquée localement ;
- runtime DB non validé ;
- `prisma migrate deploy` devra être lancé prudemment dans l'environnement prévu, après vérification des pending migrations et de la DB cible.

## 6. Contrat API

`POST /activities/next` accepte maintenant, en plus du contrat existant :

```json
{
  "subjectId": "subject-1",
  "knowledgeUnitId": "unit-1",
  "questionCount": 10,
  "visualsEnabled": true,
  "visualTypes": ["CHART", "DIAGRAM"],
  "selectionModes": ["single", "multiple"]
}
```

Décisions :

- `questionCount` reste compatible avec `LOT-025B`.
- `visualsEnabled` est optionnel.
- `visualTypes` accepte `CHART` et `DIAGRAM`.
- `IMAGE` est explicitement refusé en `400` tant que le pipeline média documentaire n'existe pas.
- `selectionModes` accepte `single` et `multiple`.
- les anciens clients qui n'envoient aucun de ces champs restent compatibles.

`POST /activities/:sessionId/result` accepte maintenant :

```json
{
  "answers": [
    {
      "questionId": "question-1",
      "choiceId": "choice-a"
    },
    {
      "questionId": "question-2",
      "choiceIds": ["choice-a", "choice-c"]
    }
  ]
}
```

Décisions :

- `choiceId` reste obligatoire pour une question single.
- `choiceIds` est obligatoire pour une question multiple.
- un payload qui fournit les deux ou aucun des deux est rejeté.
- les doublons sont rejetés.
- les choix inconnus sont rejetés.
- le double submit reste rejeté.

## 7. Contrat Genkit

Le port `DiagnosticQuizGenerator` accepte :

- `visualsEnabled`;
- `visualTypes`;
- `selectionModes`;
- `questionCount`;
- contexte sourcé existant : `KnowledgeUnit` + `DocumentChunk`.

Le générateur produit désormais un QCM v3 quand une question multiple ou un visuel est demandé ou présent. Sinon le mode v2 sourcé reste inchangé.

Sortie interne question :

- `selectionMode?: 'single' | 'multiple'`;
- `correctChoiceId?: string | null`;
- `correctChoiceIds?: string[]`;
- `minSelections?: number | null`;
- `maxSelections?: number | null`;
- `visuals?: GeneratedDiagnosticQuizVisual[]`.

Le prompt demande :

- les modes de sélection autorisés ;
- les types visuels autorisés ;
- des questions exclusivement sourcées ;
- aucun visuel si `visualsEnabled` n'est pas actif ;
- aucun `IMAGE` si non autorisé ;
- des sources exactes via `sourceChunkIds`.

Les validations rejettent :

- source de question inconnue ;
- question sourcée sans source ;
- `correctChoiceId` absent ou invalide en single ;
- `correctChoiceIds` absent, dupliqué ou invalide en multiple ;
- `minSelections/maxSelections` incohérents ;
- visuel non autorisé ;
- visuel sans source ;
- source de visuel inconnue ;
- chart avec clés invalides ;
- diagramme avec edge vers node inconnu.

## 8. Contrat repository

Création QCM :

- vérifie ownership via `studentId`, `subjectId`, `knowledgeUnitId`;
- vérifie les chunks sources de questions et de visuels ;
- persiste `Question.selectionMode`, `minSelections`, `maxSelections`, `correctChoiceId` ou `correctChoiceIds`;
- persiste `QuestionVisual` et `QuestionVisualSource`;
- retourne un DTO public pré-submit sans correction ;
- expose les visuels avec sources pré-submit mais sans texte source complet.

Soumission :

- single : compare `choiceId` à `correctChoiceId`;
- multiple : compare l'ensemble `choiceIds` à `correctChoiceIds`;
- scoring multiple MVP : tout ou rien ;
- persiste les choix multiples dans `QuestionAnswerChoice`;
- retourne `selectedChoiceIds`, `correctChoiceIds`, `partialScore` après submit pour les questions multiples ;
- conserve le résultat legacy pour les questions single.

## 9. Sécurité anti-fuite

Pré-submit, le DTO public ne contient pas :

- `correctChoiceId`;
- `correctChoiceIds`;
- `isCorrect`;
- `explanation`;
- `feedback`;
- texte complet des sources.

Post-submit, la correction peut contenir :

- réponse sélectionnée ;
- bonne réponse ;
- `isCorrect`;
- explication ;
- feedback ;
- sources textuelles ;
- score.

Le frontend ne calcule pas la correction : elle reste produite par le backend.

## 10. Visuels supportés

Support backend réel ajouté :

- `CHART`;
- `DIAGRAM`.

`IMAGE` reste dans l'enum conceptuel et Prisma pour éviter une migration cassante plus tard, mais le controller et le générateur ne l'activent pas encore. Le backend refuse `IMAGE` via l'API tant que l'extraction ou le stockage média contrôlé n'existe pas.

Charts :

- `chartType`: `bar`, `line`, `pie`, `scatter`;
- `title`;
- `description?`;
- `data` borné ;
- `xKey?`;
- `yKeys?`;
- sources obligatoires.

Diagrammes :

- `title`;
- `description?`;
- `nodes`;
- `edges?`;
- sources obligatoires.

Pas de HTML, SVG libre, Mermaid libre, JavaScript, base64 image, URL externe inventée ou payload GenUI arbitraire.

## 11. Multi-réponse

Le MVP multi-réponse est activé côté backend avec :

- `selectionMode = MULTIPLE`;
- `minSelections`;
- `maxSelections`;
- `correctChoiceIds`;
- soumission via `choiceIds`;
- scoring tout-ou-rien ;
- correction post-submit avec `selectedChoiceIds`, `correctChoiceIds`, `partialScore`.

Le score partiel fin est reporté.

## 12. Tests créés ou modifiés

- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
  - génération QCM v3 multi-réponse avec chart/diagram ;
  - rejet source visuelle inconnue ;
  - prompt avec capacités média/multi ;
  - non-régression v2, fallback, questionCount.
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
  - persistance QCM v3 avec réponse multiple et visuel sourcé ;
  - anti-fuite pré-submit ;
  - soumission multiple ;
  - scoring tout-ou-rien ;
  - rejet doublons.
- `api/src/modules/activities/activities.module.spec.ts`
  - `POST /activities/next` transmet visuels et modes de sélection ;
  - `IMAGE` rejeté ;
  - submit avec `choiceIds`.

## 13. Validations lancées

Préflight :

- `cd api && npm run build` : passé.
- `cd api && npx prisma validate` : passé.
- `cd api && npm run prisma:generate` : passé.
- `cd api && npx prisma migrate status` : échec `Schema engine error`, DB locale non validée.

Après implémentation :

- `cd api && npm run prisma:generate` : passé.
- `cd api && npm test -- genkit-diagnostic-quiz --runInBand` : passé, 21 tests.
- `cd api && npm test -- activities --runInBand` : passé, 58 tests.
- `cd api && npx prisma validate` : passé.
- `cd api && npm test -- ai --runInBand` : passé, 51 tests.
- `cd api && npm test -- revision --runInBand` : passé, 32 tests.
- `cd api && npm run lint:check` : passé après corrections manuelles.
- `cd api && npm run build` : passé.

## 14. Validations non lancées

- `prisma migrate deploy` : interdit et non nécessaire dans ce lot.
- `prisma migrate reset` / `db push --force-reset` : interdit.
- provider IA réel : interdit.
- déploiement : interdit.
- tests Flutter : non lancés, aucun code Flutter modifié.
- `npm run test:cov` : interdit.
- `npm run format` : interdit.
- `npm run lint` : non lancé car potentiellement fix automatique selon consigne.

## 15. Données non stockées / non exposées

Le lot ne stocke pas et n'expose pas :

- prompt complet ;
- completion complète ;
- chunks complets en logs ;
- `correctChoiceId(s)` pré-submit ;
- feedback pré-submit ;
- explication pré-submit ;
- texte source complet pré-submit ;
- payload GenUI ;
- média externe arbitraire ;
- source libre inventée.

## 16. Risques restants

- La migration n'a pas été appliquée sur une DB locale réelle.
- Les visuels `IMAGE` ne sont pas utilisables tant que le pipeline média n'est pas construit.
- Les charts générés par IA doivent être surveillés en provider réel pour éviter les données redondantes ou peu pédagogiques.
- Le score multi-réponse est tout-ou-rien ; le score partiel fin reste à concevoir.
- Le frontend ne consomme pas encore les visuels ou la sélection multiple.
- GenUI QCM reste hors scope.
- Coût et latence IA peuvent augmenter avec médias et 10-20 questions.

## 17. Recommandation prochain lot

Le prochain lot recommandé est `LOT-025E — QCM média et multi-réponse : UI`, uniquement après validation de la migration sur une DB réelle ou environnement de staging.

Si la priorité est la stabilité infra, faire d'abord un mini-lot DB/runtime pour appliquer et vérifier les migrations `LOT-024`, `HOTFIX-024B`, `LOT-025B` et `LOT-025D`.

## 18. Code modifié pour review

Le code complet du lot est présent dans le workspace. Pour review locale :

```bash
cd /Users/karim/Project/app-révision/api
git diff -- prisma/schema.prisma prisma/migrations/20260614190000_qcm_media_multi_backend/migration.sql src/modules/activities
```

Fichiers backend modifiés :

- `api/prisma/schema.prisma`
- `api/prisma/migrations/20260614190000_qcm_media_multi_backend/migration.sql`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.spec.ts`
- `api/src/modules/activities/activities.module.spec.ts`

## 19. Review critique finale

La solution privilégie la compatibilité et la sécurité : le mono-réponse reste intact, la multi-réponse est explicite, les visuels sont bornés et sourcés, et les images restent bloquées faute de pipeline contrôlé.

La dette principale est la migration non validée runtime DB. Le second point de vigilance est l'écart temporaire avec Flutter : le backend peut produire des questions multiples et des visuels, mais l'UI native ne les rendra correctement qu'après `LOT-025E`.
