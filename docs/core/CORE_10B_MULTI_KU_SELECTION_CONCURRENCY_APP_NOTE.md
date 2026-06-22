# CORE-10B — App note

Date: 2026-06-22

## Résumé

CORE-10B est un lot API. L'application Flutter n'a pas nécessité de changement runtime.

## Compatibilité

Le contrat public introduit par CORE-10A reste stable :

- les statuts de readiness ne changent pas ;
- l'erreur quick `COURSE_QUICK_REVISION_QUESTIONS_PREPARING` reste la même ;
- l'app continue d'afficher `Questions en préparation` / `À préparer` / `Questions prêtes` selon le statut existant ;
- aucun nouveau champ n'est requis côté Flutter.

## Effet produit

Quand la banque est prête, le backend peut désormais sélectionner les questions quick sur plusieurs notions du cours. Côté UI, cela reste une révision rapide course-level : aucune nouvelle page ou interaction n'est nécessaire.

## Validation côté app

Aucun code Flutter modifié. Validation documentaire :

```bash
git diff --check
# PASS — aucune erreur

git status --short --untracked-files=all
# Docs/trackers CORE-10B uniquement
```

## Dette restante

CORE-10C pourra exposer plus tard des métriques qualité/coût ou une granularité plus riche si l'UX en a besoin. Pour CORE-10B, l'app reste volontairement inchangée.
