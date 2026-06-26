# V4-04A — Learning path backend contract — Evidence Pack

## 1. Objectif

Créer le contrat backend déterministe permettant au frontend d'afficher un parcours réel de notions pour un cours via `GET /courses/:courseId/learning-path`, sans migration Prisma, sans frontend Flutter, sans Genkit et sans GenUI.

## 2. Problème résolu

`CourseDetailPage` avait besoin d'un contrat par notion pour afficher une timeline honnête. L'endpoint existant `/courses/:courseId/progress` donnait une progression agrégée du cours, mais pas les KnowledgeUnits réelles, leur état, leur ordre, leur source ni la notion active.

## 3. Contrat ajouté

Route ajoutée :

```http
GET /courses/:courseId/learning-path
```

Exemple JSON minimal :

```json
{
  "generatedAt": "2026-06-26T12:00:00.000Z",
  "course": {
    "id": "course-1",
    "subjectId": "subject-1",
    "subjectName": "Droits",
    "title": "Droit constitutionnel"
  },
  "summary": {
    "knowledgeUnitCount": 1,
    "solidCount": 0,
    "inProgressCount": 0,
    "toStrengthenCount": 1,
    "undiscoveredCount": 0,
    "estimatedGlobalMastery": 0.24,
    "mastery": 0.24,
    "coverage": 1,
    "readySourceCount": 1
  },
  "activeNodeId": "unit-1",
  "primaryAction": {
    "kind": "REVIEW_ACTIVE_NODE",
    "label": "Continuer",
    "description": "Reprendre le parcours à la notion recommandée.",
    "estimatedMinutes": 20,
    "targetKnowledgeUnitId": "unit-1",
    "targetNodeId": "unit-1",
    "enabled": true,
    "unavailableReason": null
  },
  "nodes": [
    {
      "id": "unit-1",
      "knowledgeUnitId": "unit-1",
      "title": "Le contrôle de constitutionnalité",
      "order": 0,
      "state": "TO_STRENGTHEN",
      "masteryScore": 0.24,
      "lastPracticedAt": "2026-06-14T09:00:00.000Z",
      "display": {
        "title": "Le contrôle de constitutionnalité",
        "statusLabel": "À renforcer",
        "metaLabel": "Cours.pdf",
        "actionLabel": "Renforcer",
        "unavailableReason": null
      }
    }
  ],
  "emptyState": null
}
```

Champs principaux :

- `summary` donne les compteurs par état et la progression agrégée alignée avec la règle existante `coverage * mastery`.
- `nodes` expose uniquement des notions réelles issues des documents `COURSE_PDF` prêts du cours.
- `activeNodeId` pointe vers la notion prioritaire déterministe.
- `primaryAction` décrit l'action honnête à afficher.
- `emptyState` décrit les cas sans parcours exploitable.

## 4. Règles de calcul

- `SOLID` : `masteryScore >= 0.80`.
- `IN_PROGRESS` : `0.50 <= masteryScore < 0.80`.
- `TO_STRENGTHEN` : `masteryScore < 0.50`.
- `UNDISCOVERED` : absence de `MasteryState`.
- `activeNodeId` choisit la première notion `TO_STRENGTHEN`, puis `IN_PROGRESS`, puis `UNDISCOVERED`, puis `SOLID`.
- L'ordre est stable : document par `createdAt/id`, puis `displayOrder` null-last, puis `createdAt/id` de la notion.
- `mastery` est la moyenne des scores existants, ou `null`.
- `coverage` est le ratio notions avec score / total notions.
- `estimatedGlobalMastery` suit la règle existante du repo : `0` si `mastery` est `null`, sinon `coverage * mastery` arrondi.
- `primaryAction` devient `ADD_SOURCE`, `WAIT_FOR_ANALYSIS`, `UNAVAILABLE` ou `REVIEW_ACTIVE_NODE` selon l'état réel des sources et des notions.
- `emptyState` reste `null` dès qu'au moins une notion réelle existe.

## 5. Fichiers modifiés

API :

- `src/modules/courses/application/courses.repository.ts`
- `src/modules/courses/application/get-course-learning-path.use-case.ts`
- `src/modules/courses/application/get-course-learning-path.use-case.spec.ts`
- `src/modules/courses/infrastructure/prisma-courses.repository.ts`
- `src/modules/courses/infrastructure/prisma-courses.repository.spec.ts`
- `src/modules/courses/interfaces/course-learning-path-response.dto.ts`
- `src/modules/courses/interfaces/courses.controller.ts`
- `src/modules/courses/interfaces/courses.controller.spec.ts`
- `src/modules/courses/courses.module.ts`
- `src/modules/courses/application/course-progress.use-case.spec.ts`
- `src/modules/courses/application/course-read-use-cases.spec.ts`
- `src/modules/courses/application/course-use-cases.spec.ts`

Documentation :

- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/V4-04A_learning_path_backend_contract_EVIDENCE_PACK.md`

## 6. Compatibilité

- Les endpoints existants sont conservés : `/courses/:courseId`, `/courses/:courseId/progress`, rich/deep/exam options et sessions.
- Le nouveau endpoint est additionnel.
- Aucun changement Prisma schema.
- Aucune migration.
- Aucun changement frontend Flutter.
- Aucun Genkit.
- Aucun GenUI.
- Aucun contrat public existant n'est renommé ou supprimé.

## 7. Sécurité / ownership

- Le repository filtre le cours par `studentId`, `courseId`, `archivedAt: null` et `subject.archivedAt: null`.
- Les documents utilisés sont filtrés par `studentId`, `courseId`, `kind: COURSE_PDF` et `archivedAt: null`.
- Les nodes ne sont construits qu'à partir de documents `READY`.
- Les documents `EXAM_PDF` et `EXAM_IMAGE` sont exclus.
- Les KnowledgeUnits doivent appartenir au sujet de l'étudiant et au document du cours.
- Aucun champ interne Prisma inutile ne sort dans le DTO public.

## 8. Tests exécutés

| Commande | Résultat | Notes |
| --- | --- | --- |
| `npm test -- get-course-learning-path.use-case.spec.ts` | PASS | 6 tests : not found, empty states, states, summary, active node, copy safe. |
| `npm test -- courses.controller.spec.ts` | PASS | 51 tests : route learning path, mapping ISO, 404 et régressions controller. |
| `npm test -- prisma-courses.repository.spec.ts` | PASS | 30 tests : lecture Prisma, ownership, filtres documents/notions et régressions repository. |
| `npm run lint:check` | PASS | ESLint OK. |
| `npm run build` | PASS | Build Nest OK. |
| `git diff --check` | À exécuter en fin de tour | Voir rapport final. |
| `git status --short` | À exécuter en fin de tour | Voir rapport final. |

## 9. Décisions prises

- Endpoint dédié `/courses/:courseId/learning-path` plutôt qu'enrichissement brutal de `/progress`.
- Les états pédagogiques viennent uniquement de `MasteryState`.
- Aucune notion sans score ne devient `SOLID` ou `TO_STRENGTHEN` par déduction.
- Aucun score n'est déduit du nombre de sources.
- Pas de migration Prisma : les tables `KnowledgeUnit`, `Document`, `Course` et `MasteryState` suffisent pour ce contrat.
- Les copies utilisateur sont construites côté application, pas dans Prisma.

## 10. Risques restants

- Les états restent basés sur le `MasteryState` actuel.
- Pas encore de répétition espacée.
- Pas encore de notion active basée sur erreur récente ou récence fine.
- Le frontend `V4-04B` doit consommer ce contrat.
- Les actions restent branchées vers les routes legacy jusqu'à Study Session V4.

## 11. Autocritique finale

Le contrat fournit une base fiable, testée et rétrocompatible pour la timeline V4. Il reste volontairement simple : pas de planner IA, pas de scoring inventé, pas de session engine. La limite principale est que la recommandation active ne tient pas encore compte d'un historique riche d'erreurs ou de spaced repetition.

## 12. Prochain lot recommandé

`V4-04B — Learning path frontend timeline`
