# HOTFIX-025D-BIS — Versioning Genkit QCM v3

## 1. Résultat

Le générateur QCM distingue maintenant les générations IA `diagnostic-quiz-v2` et `diagnostic-quiz-v3` dans ses métadonnées retournées et dans l'observabilité Genkit.

Le hotfix ne modifie ni Prisma, ni migrations, ni API publique, ni Flutter, ni GenUI.

## 2. Problème initial

`LOT-025D` a ajouté le backend QCM v3 avec multi-réponse et visuels bornés `CHART` / `DIAGRAM`, mais `GenkitDiagnosticQuizGenerator` continuait à utiliser des constantes globales :

- `promptVersion = diagnostic-quiz-v2`
- `schemaVersion = diagnostic-quiz-v2`

Conséquence : une génération v3 pouvait être persistée ou observée comme si elle utilisait le contrat IA v2, ce qui rendait les logs et diagnostics IA ambigus.

## 3. Sources inspectées

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_023.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_024.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025B_QCM_QUESTION_COUNT_MEDIA_MULTI_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025C_QCM_MEDIA_MULTI_BACKEND_CONTRACT.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md`
- `revision_app/docs/ROADMAP_EXECUTION_HOTFIX_024B_AI_MODEL_FALLBACK.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`
- `api/package.json`
- `api/src/modules/activities/application/diagnostic-quiz-generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`
- `api/src/modules/activities/application/start-next-activity.use-case.ts`
- `api/src/modules/activities/application/submit-activity-result.use-case.ts`
- `api/src/modules/activities/application/activities.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`
- `api/src/modules/activities/interfaces/activities.controller.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/infrastructure/mistral-model-fallback.ts`

## 4. Préflight Git / Prisma

État initial API :

```text
## main...origin/main
```

État initial frontend/docs :

```text
## main...origin/main
```

Fichiers modifiés ou non suivis au préflight : aucun.

Validations préflight :

- `cd api && npm run build` : passé.
- `cd api && npx prisma validate` : passé.
- `cd api && npm run prisma:generate` : passé.

Documents vérifiés :

- `revision_app/docs/ROADMAP_EXECUTION_LOT_025D_QCM_MEDIA_MULTI_BACKEND.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

## 5. Règle de versioning retenue

Le générateur résout une version IA avant l'appel Genkit :

- `diagnostic-quiz-v2` si aucune capacité v3 n'est demandée ;
- `diagnostic-quiz-v3` si au moins une capacité v3 est demandée.

Capacités v3 :

- `visualsEnabled === true` ;
- `visualTypes` non vide ;
- `selectionModes` contient `multiple`.

La sortie est ensuite validée comme avant :

- une sortie avec visuels non autorisés reste invalide ;
- une sortie avec source inconnue reste invalide ;
- une sortie multiple incohérente reste invalide ;
- aucune source fictive n'est créée.

## 6. Changements réalisés

Dans `GenkitDiagnosticQuizGenerator` :

- remplacement des constantes globales `PROMPT_VERSION` / `SCHEMA_VERSION` par une résolution dynamique ;
- ajout de `resolveDiagnosticQuizGenerationVersion(input)` ;
- utilisation de la version résolue pour :
  - `AiGenerationObserver.observe`;
  - `GeneratedDiagnosticQuiz.metadata.promptVersion`;
  - `GeneratedDiagnosticQuiz.metadata.schemaVersion`.

Le contenu fonctionnel du prompt n'a pas été refondu.

## 7. Observabilité

Confirmations couvertes par tests :

- le chemin v2 observe `promptVersion: diagnostic-quiz-v2`;
- le chemin v2 observe `schemaVersion: diagnostic-quiz-v2`;
- le chemin v3 avec multi-réponse/visuels observe `diagnostic-quiz-v3`;
- une erreur v3 observe `diagnostic-quiz-v3`;
- un fallback Mistral v3 conserve `diagnostic-quiz-v3` sur la tentative primaire et la tentative fallback.

Données non observées :

- prompt complet ;
- completion complète ;
- chunks complets ;
- `correctChoiceId` ;
- `correctChoiceIds` ;
- labels de choix ;
- explication ;
- feedback ;
- réponses utilisateur.

## 8. Compatibilité

- Aucun changement API.
- Aucun changement Prisma.
- Aucune migration.
- Aucun changement Flutter.
- Aucun changement GenUI.
- Le chemin QCM v2 mono-réponse reste `diagnostic-quiz-v2`.
- Le DTO public pré-submit reste inchangé.

## 9. Tests créés ou modifiés

Fichier modifié :

- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.spec.ts`

Tests ajoutés ou renforcés :

- succès v3 avec multi-réponse et visuels : metadata et observation en `diagnostic-quiz-v3`;
- erreur v3 sur source visuelle inconnue : observation en `diagnostic-quiz-v3`;
- fallback Mistral v3 après sortie invalide : les deux observations et les métadonnées finales restent en `diagnostic-quiz-v3`;
- non-régression v2 : les tests existants continuent d'attendre `diagnostic-quiz-v2`.

## 10. Validations lancées

- `cd api && npm run build` : passé.
- `cd api && npx prisma validate` : passé.
- `cd api && npm run prisma:generate` : passé.
- `cd api && npm test -- genkit-diagnostic-quiz --runInBand` : passé, 22 tests.
- `cd api && npm test -- activities --runInBand` : passé, 59 tests.
- `cd api && npm run lint:check` : passé.
- `cd api && git diff --check` : passé.
- `cd revision_app && git diff --check` : passé.

## 11. Validations non lancées

- migration ;
- `prisma migrate deploy` ;
- provider IA réel ;
- déploiement ;
- tests Flutter ;
- `cd api && npm test -- ai --runInBand`, non lancé car aucun port d'observabilité partagé ni fallback commun n'a été modifié ;
- `npm run test:cov` ;
- `npm run format` ;
- `npm run lint`.

## 12. Risques restants

- La migration `LOT-025D` doit toujours être validée sur une DB réelle si ce n'est pas déjà fait hors de ce hotfix.
- Flutter ne consomme pas encore le QCM v3 média/multi-réponse.
- Le provider réel n'a pas été appelé dans ce hotfix.

## 13. Recommandation prochain lot

Le prochain lot recommandé reste `LOT-025E — QCM média et multi-réponse : UI`, idéalement après validation DB/runtime de `LOT-025D`.
