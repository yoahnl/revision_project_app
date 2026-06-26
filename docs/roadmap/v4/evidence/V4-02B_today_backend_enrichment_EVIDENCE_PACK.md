# V4-02B — Today backend enrichment — Evidence Pack

## 1. Objectif

Enrichir le endpoint backend `/today` pour fournir une reponse plus exploitable par l'UX V4, tout en conservant les champs historiques consommes par le frontend Flutter actuel.

## 2. Resume des changements

- Ajout d'un presenter applicatif pur pour la copy produit et les metadonnees d'affichage Today.
- Ajout de champs top-level retrocompatibles : `primaryItemId`, `continuationItemIds`, `weeklyObjective`, `emptyState`.
- Ajout de champs par item : `role` et `display`.
- Remplacement du champ legacy `reason` par une copy product-safe.
- Conservation de `action`, `reasonCode` et `startPayload` sans changement de valeurs.
- Objectif hebdomadaire expose uniquement en target-only, sans progression inventee.
- Aucun changement Prisma, aucune migration, aucun appel IA, aucun fichier Flutter modifie.

## 3. Contrat /today avant / apres

Avant, `/today` retournait :

```json
{
  "generatedAt": "2026-06-15T10:00:00.000Z",
  "items": []
}
```

Apres, les champs existants restent presents et de nouveaux champs optionnels sont ajoutes :

```json
{
  "generatedAt": "2026-06-15T10:00:00.000Z",
  "primaryItemId": "subject-1:unit-1:diagnostic_quiz",
  "continuationItemIds": ["subject-1:unit-1:rich_closed_exercise"],
  "weeklyObjective": {
    "targetMinutes": 240,
    "completedMinutes": null,
    "progressRatio": null,
    "label": "Objectif : 4 h cette semaine",
    "status": "TARGET_ONLY"
  },
  "emptyState": {
    "title": "Rien de prêt pour aujourd’hui",
    "message": "Ajoute un cours ou une source pour que Neralune prépare ta prochaine session.",
    "actionLabel": "Voir mes cours",
    "actionKind": "OPEN_COURSES"
  },
  "items": [
    {
      "id": "subject-1:unit-1:diagnostic_quiz",
      "subjectId": "subject-1",
      "subjectName": "Droit constitutionnel",
      "documentId": "document-1",
      "knowledgeUnitId": "unit-1",
      "knowledgeUnitTitle": "Séparation",
      "masteryScore": 0.2,
      "action": "diagnostic_quiz",
      "estimatedMinutes": 12,
      "priority": 560,
      "reasonCode": "LOW_MASTERY",
      "reason": "Cette notion semble fragile : la revoir maintenant aidera à consolider tes bases.",
      "startPayload": {
        "subjectId": "subject-1",
        "knowledgeUnitId": "unit-1",
        "preferredAction": "diagnostic_quiz"
      },
      "role": "PRIMARY",
      "display": {
        "title": "Séparation",
        "subjectLabel": "Droit constitutionnel",
        "badgeLabel": "DROIT CONSTITUTIONNEL",
        "durationLabel": "12 min",
        "metaLabel": "12 min · session guidée",
        "recommendation": "Cette notion semble fragile : la revoir maintenant aidera à consolider tes bases.",
        "actionLabel": "Réviser maintenant",
        "unavailableReason": null
      }
    }
  ]
}
```

## 4. Fichiers modifies

Backend API :

- `src/modules/revision/application/get-today-plan.use-case.ts`
- `src/modules/revision/application/get-today-plan.use-case.spec.ts`
- `src/modules/revision/application/today-plan-display.presenter.ts`
- `src/modules/revision/interfaces/today.controller.spec.ts`

Documentation V4 :

- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/V4-02B_today_backend_enrichment_EVIDENCE_PACK.md`

## 5. Compatibilite frontend

Champs existants conserves :

- `generatedAt`
- `items`
- `items[].id`
- `items[].subjectId`
- `items[].subjectName`
- `items[].documentId`
- `items[].knowledgeUnitId`
- `items[].knowledgeUnitTitle`
- `items[].masteryScore`
- `items[].action`
- `items[].estimatedMinutes`
- `items[].priority`
- `items[].reasonCode`
- `items[].reason`
- `items[].startPayload`

Champs ajoutes :

- `primaryItemId`
- `continuationItemIds`
- `weeklyObjective`
- `emptyState`
- `items[].role`
- `items[].display`

Le front actuel ne casse pas car aucun champ existant n'est renomme ou supprime. Les valeurs techniques `action`, `reasonCode` et `startPayload` restent stables. Le frontend pourra consommer plus tard `display`, `primaryItemId`, `continuationItemIds`, `weeklyObjective` et `emptyState` pour supprimer ses mappings locaux.

## 6. Comportement backend obtenu

- Primary item explicite : premier item si disponible, sinon `null`.
- Continuation explicite : deux items maximum apres le premier.
- `role` present sur chaque item.
- `display` present sur chaque item avec copy product-safe.
- `reason` devient product-safe.
- `weeklyObjective` n'expose que le target fiable, sans `completedMinutes` ni `progressRatio` inventes.
- `emptyState` toujours present avec intention `OPEN_COURSES`.
- Pas de planner frontend ajoute.
- Pas de session engine ajoute.
- Pas de questions, corrections ou donnees de session generees dans `/today`.

## 7. Tests executes

| Commande | Resultat | Notes |
| --- | --- | --- |
| `npm test -- get-today-plan.use-case.spec.ts` | PASS — 6 tests | Couvre champs legacy, primary, continuation, roles, display, copy product-safe, weekly target-only, empty state, indisponibilite prudente. |
| `npm test -- today.controller.spec.ts` | PASS — 1 test | Verifie que le controleur relaie le plan enrichi du use case. |
| `npm run lint:check` | PASS | Une premiere passe a signale du formatage et un narrowing TypeScript ; corrige avant le resultat final. |
| `npm run build` | PASS | Une premiere passe a signale le narrowing `weeklyMinutes` ; corrige avant le resultat final. |
| `git diff --check` dans `api` | PASS | Aucun whitespace error. |
| `git diff --check` dans `revision_app` | PASS | Aucun whitespace error. |
| `git status --short` dans `api` | PASS | Montre uniquement les fichiers backend attendus. |
| `git status --short` dans `revision_app` | PASS | Montre uniquement tracker + evidence pack. |

`adaptive-plan.service.spec.ts` n'a pas ete relance separement car le service de ranking n'a pas ete modifie.

## 8. Decisions prises

- Le ranking reste dans `AdaptivePlanService`.
- Les textes utilisateur et les metadonnees d'affichage vivent dans un presenter application.
- `reason` est garde pour compatibilite mais devient product-safe.
- `weeklyObjective` reste en `TARGET_ONLY` tant qu'aucune progression fiable n'existe.
- Un item non lancable reste dans le plan mais expose `display.unavailableReason` et `Session indisponible`.

## 9. Risques restants

- Le frontend Today ne consomme peut-etre pas encore les champs enrichis.
- Les routes lancees par `startPayload` restent legacy jusqu'a Study Session V4.
- Weekly progress reste incomplet sans event log fiable.

## 10. Points a surveiller au prochain lot

- Ne pas lancer `V4-02C` sauf besoin reel de synchroniser le frontend sur `display`.
- Garder `Cours V4` centre sur la bibliotheque, pas sur les moteurs de session.
- Ne pas supprimer les champs legacy de `/today` tant que le frontend n'a pas migre.

## 11. Autocritique finale

Le lot enrichit proprement `/today` sans big bang et sans changer Prisma. La limite principale est volontaire : le frontend peut continuer a utiliser ses mappings locaux, donc les nouveaux champs backend ne produisent pas encore automatiquement une UI plus simple tant qu'ils ne sont pas consommes.

## 12. Prochain lot recommande

`V4-03A — Cours V4 frontend`
