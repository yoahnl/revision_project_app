# Roadmap Update Protocol V2

Ce protocole doit être appliqué après chaque lot futur. Il sert à empêcher la roadmap de redevenir un cimetière de plans périmés.

## Checklist obligatoire

Après chaque lot, Codex doit :

1. Mettre à jour `LOT_TRACKER_V2.md`.
2. Marquer le lot `DONE`, `BLOCKED`, `DEFERRED` ou le laisser `IN_PROGRESS` si une partie est incomplète.
3. Ajouter le lien vers le rapport de lot.
4. Mettre à jour l'état réel actuel dans `REVISION_PROJECT_ROADMAP_V2.md`.
5. Mettre à jour les risques et limites.
6. Mettre à jour les dépendances entre lots si elles ont changé.
7. Ajouter ou confirmer le prochain lot recommandé.
8. Mettre à jour les documents spécifiques au repo concerné.
9. Ne jamais prétendre qu'un lot est fini sans commandes de validation documentées.
10. Ne jamais supprimer l'historique ou réécrire les anciens rapports.

## Règle sur les lots partiels

Le tracker n'a pas de statut `PARTIAL` pour rester simple. Si un lot est partiellement livré :

- garder `IN_PROGRESS` si la suite est immédiate ;
- utiliser `BLOCKED` si un blocage externe empêche de finir ;
- utiliser `DEFERRED` si une partie est volontairement repoussée ;
- documenter précisément ce qui est vrai et ce qui reste faux.

## Définition de `REPLACED`

`REPLACED` signifie :

- le lot ne sera pas exécuté sous sa forme initiale ;
- il est remplacé par un ou plusieurs lots identifiés ;
- l'entrée historique reste dans le tracker ;
- les IDs remplaçants sont indiqués ;
- le motif du remplacement est documenté ;
- aucun travail réellement livré n'est effacé.

Exemple :

```text
STAB-01 macro
-> reste le parent stratégique
-> ses travaux sont exécutés par STAB-01A, STAB-01B et STAB-01C
```

Un macro-lot ne doit pas être automatiquement marqué `REPLACED` quand il reçoit des enfants exécutables. Il reste un parent stratégique.

## Agrégation des macro-lots

- `TODO` : aucun lot enfant commencé.
- `IN_PROGRESS` : au moins un enfant commencé et au moins un enfant requis non terminé.
- `DONE` : tous les enfants requis sont `DONE`.
- `BLOCKED` : l'ensemble du macro-lot est bloqué par une dépendance externe.
- `DEFERRED` : le macro-lot est volontairement repoussé.
- `REPLACED` : réservé aux lots abandonnés au profit d'une autre structure.

Les macro-lots doivent pointer vers `EXECUTION_LOT_TRACKER_V2.md` plutôt que dupliquer tout le détail exécutable.

## Template de mise à jour

```md
## Update après LOT-XXX

### Résumé du lot

### Statut réel

### Fichiers principaux modifiés

### Tests exécutés

### Ce qui est maintenant vrai

### Ce qui reste faux ou partiel

### Risques ajoutés

### Dette créée

### Prochain lot recommandé
```

## Règles de preuve

- Une fonctionnalité est `DONE` seulement si le code, les tests et le rapport existent.
- Une validation manuelle doit être décrite avec contexte, appareil, environnement et résultat.
- Une commande échouée doit rester visible avec sa cause probable.
- Un lot documentation ne doit pas lancer de suites applicatives lourdes s'il ne modifie aucun code runtime.
- Après chaque lot exécutable, mettre à jour `LOT_TRACKER_V2.md` seulement si le statut agrégé du macro-lot change.
- Après chaque lot exécutable, mettre à jour `EXECUTION_LOT_TRACKER_V2.md` dans tous les repos concernés.
- Les deux repos doivent conserver les mêmes IDs et statuts pour les lots communs.
- Un lot app-only peut être référencé côté API avec `Impact API : Aucun`, sans rapport backend artificiel.
