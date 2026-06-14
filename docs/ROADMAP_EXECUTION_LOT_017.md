# LOT-017 — Contrat artefacts générés

## 1. Résultat

Le contrat cible des artefacts générés est décidé pour le MVP.

Décision retenue : approche hybride métier + métadonnées IA communes.

Pour les prochains lots, Revision App doit commencer avec des modèles métier spécialisés :

- `Summary`
- `RevisionSheet`

Ces modèles devront porter directement les métadonnées IA communes nécessaires à la traçabilité :

- `flowName`
- `provider`
- `model`
- `promptVersion`
- `schemaVersion`
- `generatedAt`
- `inputSize`
- `sourceStrategy`
- `errorCode`

Le MVP ne doit pas créer maintenant :

- `GeneratedArtifact`
- `AiGenerationJob`
- payload GenUI persistant
- `SourceReference` globale

Les sources affichées par les artefacts doivent pointer vers `DocumentChunk`. Les sources libres générées par IA ne sont jamais une autorité. GenUI pourra rendre plus tard des composants construits depuis ces objets métier validés, mais GenUI ne devient pas la source de vérité.

Ce lot est documentaire. Il ne modifie pas le backend applicatif, le frontend applicatif, Prisma, Genkit, GenUI ou les routes API.

## 2. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_002_002B_003.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_009_010_011.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_010B.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_012_013.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_014_015_016.md`
- `revision_app/AGENTS.md`
- `revision_app/codex_rule.md`

Backend :

- `api/prisma/schema.prisma`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/ai/application/ai-generation-observer.ts`
- `api/src/modules/ai/application/document-knowledge-extractor.ts`
- `api/src/modules/ai/infrastructure/document-knowledge-output.schema.ts`
- `api/src/modules/ai/infrastructure/genkit-document-knowledge.extractor.ts`
- `api/src/modules/ai/infrastructure/genkit-mistral-document-knowledge.extractor.ts`
- `api/src/modules/activities/infrastructure/genkit-diagnostic-quiz.generator.ts`
- `api/src/modules/jobs/infrastructure/document-processing.consumer.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `api/src/modules/activities/infrastructure/prisma-activities.repository.ts`

Frontend :

- `revision_app/lib/features/documents/domain/revision_document.dart`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/application/documents_controller.dart`
- `revision_app/lib/presentation/pages/documents/document_detail_page.dart`
- `revision_app/lib/features/activities/genui/revision_activity_catalog.dart`
- `revision_app/lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `revision_app/lib/presentation/widgets`

## 3. Préflight Git

État initial API :

```text
## main...origin/main
```

État initial frontend :

```text
## main...origin/main
```

Les deux worktrees étaient propres au début de ce lot.

Fichiers requis vérifiés :

- `revision_app/docs/ROADMAP_EXECUTION_LOT_014_015_016.md` existe.
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md` existe.
- `revision_app/codex_rule.md` existe.

Décision sur les fichiers hors scope :

- aucun fichier applicatif backend n'est modifié ;
- aucun fichier applicatif frontend n'est modifié ;
- aucun fichier Prisma n'est modifié ;
- aucun fichier généré n'est modifié ;
- seul le rapport `LOT-017` est créé ;
- `ROADMAP_EXECUTION_PLAN.md` est modifié uniquement pour marquer `LOT-017` comme réalisé dans le tableau de suivi.

## 4. Problème à résoudre

Les sources vérifiables existent maintenant dans le produit :

- `DocumentChunk` stocke le texte découpé du document ;
- `KnowledgeUnitSource` relie les notions à ces chunks ;
- `GET /documents/:documentId/knowledge-units` expose des notions sourcées.

Avant d'ajouter `Summary` et `RevisionSheet`, il faut décider comment représenter les artefacts IA. Sans ce contrat, les prochains lots risquent de dupliquer des choix incompatibles ou de créer un modèle trop générique qui deviendrait un fourre-tout.

Un artefact généré est un objet métier produit par l'IA à partir d'un document, de notions, de chunks ou d'une réponse utilisateur. Il doit être relisible après redémarrage, vérifiable, versionné et affichable sans réinterpréter du texte libre.

Différences métier :

| Objet | Rôle | Source de vérité |
| --- | --- | --- |
| `KnowledgeUnit` | Notion extraite du cours | Genkit v2 + `DocumentChunk` |
| `Summary` | Résumé synthétique d'un document | Artefact métier persistant |
| `RevisionSheet` | Fiche structurée de révision | Artefact métier persistant |
| Correction | Évaluation d'une réponse utilisateur | Modèle futur dédié |
| Bloc GenUI | Rendu dynamique validé | Vue reconstruite depuis objets métier |

Ce qui doit être persisté :

- les artefacts métier que l'utilisateur relira ;
- leur statut ;
- leur version de prompt et de schéma ;
- le provider et modèle utilisés ;
- la stratégie de source ;
- les liens vers `DocumentChunk` ;
- les erreurs contrôlées si la génération échoue et que l'objet métier est créé.

Ce qui doit être reconstruit :

- les blocs GenUI ;
- les DTO publics ;
- les extraits sources affichés, à partir de `DocumentChunk`;
- les composants Flutter.

Ce qui ne doit pas être stocké :

- prompt complet ;
- completion complète ;
- texte complet du cours dans un champ JSON d'artefact ;
- chunks complets dans un payload d'artefact ;
- payload GenUI arbitraire ;
- source libre inventée par IA.

Versioning :

- `promptVersion` et `schemaVersion` doivent être stockés sur l'artefact.
- Les lots futurs doivent utiliser des constantes stables côté Genkit.
- Les DTO publics doivent pouvoir exposer ces versions seulement si utile au debug produit ; par défaut elles peuvent rester backend.

Régénération :

- le MVP doit éviter la génération inutile en retournant l'artefact existant quand il est `READY` ;
- une régénération explicite pourra écraser l'artefact existant ou créer une nouvelle version plus tard ;
- l'historique multi-version est reporté.

Erreurs IA :

- les erreurs doivent être transformées en `errorCode` contrôlé ;
- l'observabilité Genkit garde les durées, tailles et statuts ;
- le contenu sensible ne traverse pas les logs.

## 5. Options étudiées

### Option A — Modèles spécialisés uniquement

Exemples :

- `Summary`
- `RevisionSheet`
- plus tard `OpenAnswerEvaluation`

Avantages :

- typage métier clair ;
- DTOs simples ;
- queries Prisma lisibles ;
- UI plus facile à construire ;
- moins de polymorphisme ;
- validations par objet plus simples.

Inconvénients :

- duplication de métadonnées IA ;
- duplication de relations sources ;
- migrations multiples ;
- conventions à maintenir manuellement entre modèles.

Analyse :

Cette option est solide pour démarrer, mais elle peut dupliquer trop vite les champs IA et les stratégies de sources. Elle reste préférable à un modèle générique si le nombre d'artefacts reste faible.

### Option B — `GeneratedArtifact` transversal

Exemple :

- `GeneratedArtifact(type, status, payloadJson, metadata...)`

Avantages :

- modèle générique ;
- moins de tables initiales ;
- flexible pour ajouter de nouveaux types ;
- peut centraliser statut et métadonnées.

Inconvénients :

- payload JSON moins typé ;
- risque de fourre-tout ;
- validations plus fragiles ;
- UI plus difficile à raisonner ;
- risque de réinventer GenUI libre ;
- Prisma ne protège pas bien la cohérence métier interne du payload ;
- les migrations sont simples au début mais la dette se déplace dans le code applicatif.

Analyse :

Cette option est trop abstraite pour le MVP. Le projet veut démontrer Genkit et GenUI proprement, pas stocker des blobs IA. Un `payloadJson` transversal rendrait plus facile l'exposition d'un contenu non validé ou trop couplé au rendu.

### Option C — Hybride métier + métadonnées communes

Exemples :

- modèles spécialisés `Summary` et `RevisionSheet` ;
- champs IA communs répétés ;
- tables sources dédiées par artefact ou stratégie commune limitée ;
- pas de modèle transversal pour le MVP.

Avantages :

- métier lisible ;
- versioning commun ;
- compatible avec la Clean Architecture ;
- évite le modèle fourre-tout ;
- DTOs frontend stables ;
- GenUI peut rester un rendu alternatif ;
- permet de factoriser les conventions sans imposer une table générique.

Inconvénients :

- un peu de duplication ;
- discipline nécessaire sur les champs communs ;
- plusieurs migrations si de nouveaux artefacts arrivent.

Analyse :

Cette option correspond le mieux à l'état du code. Le backend a déjà des modules métier nets, les sources vérifiables sont documentaires, et le frontend affiche des modèles explicites. Le coût de duplication est acceptable pour le MVP.

## 6. Décision recommandée

Décision : retenir l'option C.

Le MVP doit utiliser :

- modèles spécialisés `Summary` et `RevisionSheet` ;
- métadonnées IA communes répétées sur chaque artefact ;
- sources vérifiables vers `DocumentChunk` ;
- pas de `GeneratedArtifact` maintenant ;
- pas de `AiGenerationJob` maintenant ;
- pas de payload GenUI arbitraire ;
- pas de `SourceReference` globale maintenant.

Raison principale :

Le produit a besoin d'objets métier compréhensibles et testables. Les résumés et fiches ne sont pas seulement des payloads IA : ce sont des contenus pédagogiques relus par l'étudiant, avec sources, statut, versions et erreurs contrôlées.

Décision complémentaire :

Les blocs GenUI futurs doivent être reconstruits depuis `Summary`, `RevisionSheet`, leurs sources et les DTO publics validés. GenUI n'est pas un format de persistance.

## 7. Contrat cible `Summary`

Modèle conceptuel cible, non appliqué dans Prisma :

| Champ | Type conceptuel | Décision |
| --- | --- | --- |
| `id` | string | obligatoire |
| `documentId` | string | obligatoire |
| `subjectId` | string | obligatoire pour ownership et relations composites |
| `studentId` | string | recommandé pour requêtes directes et ownership simple |
| `status` | `READY` ou `FAILED` | obligatoire |
| `title` | string | obligatoire si `READY` |
| `content` | string | obligatoire si `READY` |
| `keyPoints` | JSON typé applicativement ou table future | MVP : JSON validé par use case |
| `limits` | string ou JSON simple | optionnel |
| `createdAt` | DateTime | obligatoire |
| `updatedAt` | DateTime | obligatoire |
| `generatedAt` | DateTime | obligatoire si génération tentée |
| `flowName` | string | obligatoire |
| `provider` | string | obligatoire |
| `model` | string | obligatoire |
| `promptVersion` | string | obligatoire |
| `schemaVersion` | string | obligatoire |
| `sourceStrategy` | string | obligatoire |
| `inputSize` | number | recommandé |
| `errorCode` | string nullable | utile si `FAILED` |

Sources :

- créer une table dédiée `SummarySource` dans `LOT-018` si le résumé est persisté ;
- `SummarySource` doit pointer vers `DocumentChunk` ;
- les sources doivent être obligatoires pour un résumé `READY` ;
- un résumé sans source ne doit pas être affiché comme sourcé ;
- un résumé `FAILED` peut exister sans source, avec `errorCode`.

Granularité MVP :

- sources au niveau global du résumé ;
- pas de source par phrase ;
- pas de `SourceReference` globale.

Comportement recommandé :

- `GET` retourne le résumé existant ;
- `POST` génère le résumé si absent ou si une option de régénération est explicitement prévue ;
- un output Genkit avec `chunkId` inconnu est rejeté.

## 8. Contrat cible `RevisionSheet`

Modèle conceptuel cible, non appliqué dans Prisma :

| Champ | Type conceptuel | Décision |
| --- | --- | --- |
| `id` | string | obligatoire |
| `documentId` | string | obligatoire |
| `subjectId` | string | obligatoire |
| `studentId` | string | recommandé pour ownership direct |
| `status` | `READY` ou `FAILED` | obligatoire |
| `title` | string | obligatoire si `READY` |
| `introduction` | string | optionnel mais recommandé |
| `sections` | JSON validé ou table dédiée | MVP : table dédiée recommandée si migration acceptable |
| `keyPoints` | JSON validé | obligatoire si `READY` |
| `commonMistakes` | JSON validé | optionnel |
| `mustKnow` | JSON validé | optionnel |
| `practiceSuggestions` | JSON validé | optionnel |
| `createdAt` | DateTime | obligatoire |
| `updatedAt` | DateTime | obligatoire |
| `generatedAt` | DateTime | obligatoire si génération tentée |
| `flowName` | string | obligatoire |
| `provider` | string | obligatoire |
| `model` | string | obligatoire |
| `promptVersion` | string | obligatoire |
| `schemaVersion` | string | obligatoire |
| `sourceStrategy` | string | obligatoire |
| `inputSize` | number | recommandé |
| `errorCode` | string nullable | utile si `FAILED` |

Sources :

- pour le MVP, préférer les sources au niveau section si `RevisionSheetSection` existe ;
- sinon, accepter temporairement des sources globales au niveau fiche ;
- la stratégie recommandée pour une fiche pédagogique est `RevisionSheetSectionSource`, car chaque section peut citer des chunks différents ;
- chaque section `READY` doit avoir au moins une source ;
- les sources doivent pointer vers `DocumentChunk`.

Granularité MVP recommandée :

- `RevisionSheet` porte le statut, les métadonnées IA et les champs globaux ;
- `RevisionSheetSection` porte `title`, `content`, `displayOrder` ;
- `RevisionSheetSectionSource` relie chaque section à `DocumentChunk`.

Si `LOT-018` doit rester plus petit :

- commencer avec sources globales `RevisionSheetSource` ;
- documenter que le passage section-source viendra avant GenUI avancé.

## 9. Statuts et cycle de vie

Options :

| Option | Analyse |
| --- | --- |
| Génération synchrone | Simple pour document court, compatible MVP, mais attention aux timeouts. |
| Génération asynchrone via job | Plus robuste pour coûts et latence, mais demande queue, statuts et UI plus complexes. |
| Hybride | Synchrone au départ, évolution async quand les limites réelles sont mesurées. |

Décision MVP :

- génération synchrone possible pour résumé et fiche de document court ;
- persister un statut simple sur chaque artefact ;
- éviter `AiGenerationJob` tant que la génération n'est pas longue ou orchestrée ;
- prévoir une évolution vers async si les timeouts ou coûts deviennent bloquants.

Statuts recommandés :

- `READY`
- `FAILED`

Statuts à éviter maintenant :

- `PENDING`, si aucune file async n'existe ;
- `GENERATING`, sauf si le lot implémente réellement une génération asynchrone.

Cycle de vie recommandé pour `POST` :

1. vérifier ownership document ;
2. vérifier document `READY` ;
3. vérifier chunks et notions sourcées disponibles ;
4. si artefact `READY` existe et pas de régénération demandée, retourner l'existant ;
5. appeler Genkit ;
6. valider schéma et sources ;
7. persister artefact + sources ;
8. retourner DTO public ;
9. en cas d'erreur IA contrôlée, persister ou retourner `FAILED` selon décision du lot 020.

## 10. Métadonnées IA communes

À persister sur les artefacts :

| Champ | Décision |
| --- | --- |
| `flowName` | persister |
| `provider` | persister |
| `model` | persister |
| `promptVersion` | persister |
| `schemaVersion` | persister |
| `generatedAt` | persister |
| `inputSize` | persister si disponible sans contenu sensible |
| `sourceStrategy` | persister |
| `errorCode` | persister si échec contrôlé |

À garder seulement dans l'observabilité Genkit pour le MVP :

| Champ | Décision |
| --- | --- |
| `durationMs` | observer, ne pas persister au début |
| statut d'appel provider | observer |
| nom d'erreur technique détaillé | observer sous `errorCode` contrôlé |

Interdits :

- prompt complet ;
- completion complète ;
- texte complet du cours ;
- chunks complets dans un champ JSON d'artefact ;
- réponse utilisateur complète hors modèle dédié ;
- payload GenUI arbitraire.

Versions recommandées pour les prochains lots :

- `generate-summary-v1`
- `summary-v1`
- `generate-revision-sheet-v1`
- `revision-sheet-v1`

Ces noms pourront être ajustés en `LOT-019`, mais ils doivent rester constants et testés.

## 11. Sources et anti-hallucination

Décisions :

- Les sources doivent pointer vers `DocumentChunk`.
- Une source libre générée par IA n'est jamais autoritaire.
- Le backend valide chaque `chunkId`.
- Un `chunkId` inconnu doit faire rejeter l'output.
- Une source d'un autre document ou étudiant doit être rejetée.
- Les sources doivent être obligatoires pour un artefact `READY`.
- Les sources ne doivent pas réutiliser directement `KnowledgeUnitSource`, car une fiche peut couvrir plusieurs notions et une section peut s'appuyer sur des chunks différents.

Options sources :

| Option | Décision |
| --- | --- |
| Réutiliser `KnowledgeUnitSource` | rejeté pour artefacts, car la granularité notion n'est pas suffisante |
| `SummarySource` | recommandé |
| `RevisionSheetSource` global | acceptable si lot 018 doit rester minimal |
| `RevisionSheetSectionSource` | recommandé si `RevisionSheetSection` existe |
| `SourceReference` globale | reporté |

Recommandation MVP :

- `SummarySource` au niveau résumé global ;
- `RevisionSheetSectionSource` au niveau section si possible ;
- fallback acceptable : `RevisionSheetSource` global pour réduire la migration ;
- ne pas créer `SourceReference` globale maintenant.

Que faire si Genkit renvoie une source inconnue :

- rejeter l'output complet ;
- ne pas persister un artefact `READY` ;
- retourner une erreur contrôlée ;
- observer l'échec via `AiGenerationObserver` sans contenu sensible.

## 12. API cible future

Décision sur le style :

- utiliser le singulier pour le MVP, car on expose un artefact courant par document ;
- reporter l'historique multi-version et donc les collections pluriels.

Endpoints recommandés :

- `POST /documents/:documentId/summary`
- `GET /documents/:documentId/summary`
- `POST /documents/:documentId/revision-sheet`
- `GET /documents/:documentId/revision-sheet`

Comportement si artefact déjà existant :

- `GET` retourne l'existant ;
- `POST` retourne l'existant si `READY` et aucune régénération explicite n'est demandée ;
- une régénération future peut être déclenchée par query ou endpoint dédié, mais pas nécessaire en premier MVP.

Erreurs à prévoir :

| Cas | Statut recommandé |
| --- | --- |
| document absent ou cross-student | `404` |
| document non `READY` | `409` |
| aucune notion sourcée | `409` |
| sources insuffisantes | `409` ou `422` |
| output IA invalide | `502` ou `422` selon convention backend |
| provider IA échoue | `502` |
| artefact absent sur `GET` | `404` |
| token absent | `401` via guard |

Contraintes API :

- ownership obligatoire ;
- pas de `storagePath` ;
- pas de chunks non liés ;
- pas de prompt ou completion ;
- sources retournées depuis `DocumentChunk`.

DTO conceptuel `Summary` :

```json
{
  "id": "summary-1",
  "documentId": "document-1",
  "subjectId": "subject-1",
  "status": "READY",
  "title": "Résumé du cours",
  "content": "Texte synthétique.",
  "keyPoints": ["Point clé"],
  "limits": "Ce résumé ne remplace pas le cours complet.",
  "sources": [
    {
      "chunkId": "chunk-1",
      "text": "Extrait issu du chunk.",
      "pageNumber": null,
      "index": 0
    }
  ]
}
```

DTO conceptuel `RevisionSheet` :

```json
{
  "id": "sheet-1",
  "documentId": "document-1",
  "subjectId": "subject-1",
  "status": "READY",
  "title": "Fiche de révision",
  "introduction": "Vue d'ensemble.",
  "sections": [
    {
      "id": "section-1",
      "title": "Principe clé",
      "content": "Explication structurée.",
      "sources": [
        {
          "chunkId": "chunk-1",
          "text": "Extrait issu du chunk.",
          "pageNumber": null,
          "index": 0
        }
      ]
    }
  ],
  "keyPoints": ["À retenir"],
  "commonMistakes": ["Piège classique"],
  "mustKnow": ["Indispensable"],
  "practiceSuggestions": ["Relire la section 1"]
}
```

## 13. Contrats frontend futurs

Modèles Flutter futurs :

- `DocumentSummary`
- `DocumentSummarySource`
- `RevisionSheet`
- `RevisionSheetSection`
- `RevisionSheetSource` ou `RevisionSheetSectionSource`

États à gérer :

- loading ;
- empty si aucun artefact sur `GET` ;
- generating pendant le `POST` synchrone côté UI ;
- ready ;
- failed ;
- retry.

CTA depuis page détail document :

- afficher `Générer un résumé` si aucun résumé ;
- afficher `Voir le résumé` si résumé existant ;
- afficher `Générer une fiche` si aucune fiche ;
- afficher `Voir la fiche` si fiche existante ;
- ne pas afficher de CTA si document non `READY`.

Fallback :

- si génération échoue, afficher une erreur explicite ;
- ne jamais afficher de source si le backend ne la fournit pas ;
- ne pas rendre GenUI obligatoire au début.

Contraintes :

- pas d'appel HTTP direct dans les pages ;
- data layer dans `lib/features/documents/data` ou future feature dédiée ;
- controllers dans `lib/features/documents/application` ou future feature `study_artifacts/application` ;
- UI sous `lib/presentation/pages/documents` ou sous une zone dédiée si les pages grossissent.

## 14. Relation avec GenUI

Décisions :

- GenUI ne reçoit pas de payload libre généré par IA.
- Les composants GenUI futurs sont reconstruits depuis des artefacts métier validés.
- Aucun arbre widget arbitraire ne doit être stocké.
- Aucun `payloadJson` GenUI n'est source de vérité.
- `SummaryCard`, `KeyPointsList`, `SourceExcerptCard` et composants similaires viendront plus tard.
- GenUI est un rendu alternatif ou enrichi, pas un modèle de persistance.

Implication pour `LOT-029` :

- les schémas GenUI devront être dérivés de `DocumentSummary`, `RevisionSheet` et sources DTO ;
- les validateurs doivent refuser tout composant inconnu ;
- le fallback natif doit rester disponible.

## 15. Découpage recommandé des lots suivants

### LOT-018 — Persistance Summary et RevisionSheet

Inclure :

- migration Prisma ;
- modèles spécialisés `Summary` et `RevisionSheet` ;
- source tables dédiées ;
- repository ;
- use cases de lecture/persistance ;
- ownership ;
- tests repository ;
- validation des liens vers chunks.

Ne pas inclure :

- appel Genkit ;
- routes publiques ;
- UI ;
- GenUI.

### LOT-019 — Flow Genkit résumé et fiche

Inclure :

- ports applicatifs ;
- adapters Genkit ;
- schémas Zod ;
- validation des `sourceChunkIds` ;
- observabilité ;
- tests outputs invalides ;
- limites input.

Ne pas inclure :

- UI ;
- GenUI ;
- TodayPlan ;
- questions ouvertes.

### LOT-020 — API résumés et fiches

Inclure :

- endpoints `POST` et `GET` ;
- mapping DTO public ;
- ownership ;
- erreurs document non prêt, artefact absent, output invalide ;
- tests controller/use case.

Ne pas inclure :

- composants Flutter ;
- GenUI.

### LOT-021 — UI résumé et fiche

Inclure :

- data layer Flutter ;
- controller ;
- CTA depuis détail document ;
- affichage résumé et fiche ;
- affichage sources ;
- tests widget.

Ne pas inclure :

- catalogue GenUI ;
- session coach ;
- QCM v2.

Regroupement possible :

- `LOT-018` doit rester seul si la migration est complexe ou si la DB locale n'est toujours pas validée.
- `LOT-019 + LOT-020` peuvent être groupés si la persistance est prête et testée.
- `LOT-021` peut venir après `LOT-020`, ou être groupé avec lui seulement si le contrat API ne bouge plus.
- Ne pas faire `LOT-018 + LOT-019 + LOT-020 + LOT-021` en un seul batch.

## 16. Risques et décisions reportées

Risques :

| Risque | Impact | Mitigation |
| --- | --- | --- |
| Overengineering `GeneratedArtifact` | élevé | ne pas le créer maintenant |
| Duplication de métadonnées | moyen | convention stricte sur champs IA communs |
| Artefacts sans sources | élevé | sources obligatoires pour `READY` |
| Coût IA | moyen | retour artefact existant, observabilité, limites input |
| Génération trop lente | moyen | synchrone MVP, évolution async plus tard |
| Absence de DB locale validée | élevé | valider migration avant `LOT-018` si possible |
| Régénération mal définie | moyen | `POST` retourne l'existant par défaut |
| Historique multi-version | faible MVP | reporté |
| Rétention des chunks | moyen | décision future sécurité/données |
| UI trop dense | moyen | afficher sources progressivement |

Décisions reportées :

- historique multi-version ;
- jobs asynchrones ;
- `AiGenerationJob` ;
- `GeneratedArtifact` ;
- GenUI persistant ;
- granularité fine des sources par phrase ;
- ranking sémantique des chunks ;
- stratégie complète de régénération ;
- politique de rétention des chunks.

## 17. Critères d'acceptation pour LOT-018

`LOT-018` peut démarrer seulement si :

- le contrat `Summary` et `RevisionSheet` de ce document est accepté ;
- la migration `20260614000000_document_chunks_sources` est idéalement validée sur DB locale ;
- la future migration ne crée pas `GeneratedArtifact` ;
- la future migration ne crée pas `AiGenerationJob` ;
- les sources pointent vers `DocumentChunk` ;
- aucune source libre n'est stockée comme autorité ;
- aucun payload GenUI n'est stocké ;
- les modèles permettent l'ownership par `studentId` ou relation dérivable robuste ;
- les tests repository couvrent ownership et sources invalides ;
- aucun prompt ou completion complet n'est stocké.

Critères de validation de `LOT-018` :

- `npx prisma validate` ;
- `npm run prisma:generate` ;
- migration créée et relue ;
- tests repository ;
- `npm run lint:check` ;
- `npm run build` ;
- `git diff --check`.

## 18. Validations lancées

Commandes de vérification documentaire et préflight :

```text
cd api && git status --short --branch
Résultat : clean, ## main...origin/main
```

```text
cd revision_app && git status --short --branch
Résultat : clean, ## main...origin/main
```

```text
cd revision_app && test -f docs/ROADMAP_EXECUTION_LOT_014_015_016.md
Résultat : fichier présent
```

```text
cd revision_app && test -f docs/ROADMAP_EXECUTION_PLAN.md
Résultat : fichier présent
```

```text
cd revision_app && test -f codex_rule.md
Résultat : fichier présent
```

Validation finale après écriture :

```text
cd revision_app && git diff --check
Résultat : succès
```

## 19. Validations non lancées

Tests backend non lancés :

- aucun code backend n'a été modifié ;
- aucun contrat runtime n'a été ajouté ;
- aucun flow Genkit n'a été touché.

Tests frontend non lancés :

- aucun code Flutter n'a été modifié ;
- aucune route, page, data layer ou widget n'a été touché.

Prisma non lancé :

- aucun changement de schéma ;
- aucune migration créée ;
- aucune migration autorisée dans ce lot.

Provider IA réel non lancé :

- explicitement hors scope ;
- aucune génération n'était nécessaire.

## 20. Recommandation finale

Option retenue :

- Option C — hybride métier + métadonnées communes.

Prochain lot recommandé :

- `LOT-018 — Persistance Summary et RevisionSheet`.

Précondition forte :

- valider autant que possible la migration `20260614000000_document_chunks_sources` sur une DB locale avant d'ajouter une nouvelle migration artefacts.

À ne pas faire trop tôt :

- ne pas créer `GeneratedArtifact` ;
- ne pas créer `AiGenerationJob` ;
- ne pas stocker de payload GenUI ;
- ne pas démarrer `LOT-019` avant que la persistance des artefacts et sources soit claire ;
- ne pas lancer une session coach IA ;
- ne pas ajouter Summary/RevisionSheet UI avant contrat API stable.

## 21. Passes de review

Passe Architecture backend :

- Verdict : modèles spécialisés `Summary` et `RevisionSheet` respectent mieux la Clean Architecture qu'un `GeneratedArtifact` transversal.
- Point d'attention : éviter de créer un module trop large ; un module `study-artifacts` ou `summaries` devra être choisi en `LOT-018`.

Passe Modèle de données :

- Verdict : sources vers `DocumentChunk` doivent rester obligatoires pour artefacts `READY`.
- Point d'attention : `RevisionSheetSectionSource` est plus propre que `RevisionSheetSource`, mais peut rendre la migration plus lourde.

Passe Genkit / Observabilité :

- Verdict : les métadonnées IA existantes peuvent être reprises directement sur les artefacts.
- Point d'attention : `durationMs` peut rester en observabilité pour éviter de transformer les artefacts en table de monitoring.

Passe API / Frontend :

- Verdict : singulier par document est plus simple pour le MVP.
- Point d'attention : si l'historique de régénération arrive, les endpoints pluriels devront être réévalués.

Passe Sécurité / Anti-fuite :

- Verdict : aucune source libre ni payload GenUI arbitraire ne doit être stocké.
- Point d'attention : les chunks sont du contenu de cours en DB ; la rétention reste une décision sécurité future.

Passe Critique finale :

- Verdict : le lot reste dans le périmètre documentaire.
- Point d'attention : le contrat est assez précis pour `LOT-018`, mais la validation DB locale reste le vrai préalable technique.

## 22. Code créé ou modifié

Aucun code applicatif n'a été créé ou modifié.

Fichiers Markdown créés ou modifiés par ce lot :

- `revision_app/docs/ROADMAP_EXECUTION_LOT_017.md`
- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`

Le contenu complet du fichier créé est ce rapport.

La modification prévue dans `ROADMAP_EXECUTION_PLAN.md` est uniquement le passage du statut `LOT-017` à `Réalisé` avec le rapport associé.
