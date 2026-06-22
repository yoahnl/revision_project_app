# CORE-09B Storage Cleanup App Note

## Résumé

CORE-09B est un lot API interne. Le backend ajoute une abstraction de cleanup storage et une intention transactionnelle de suppression physique de fichier après suppression DB safe.

## Impact app

Aucun code Flutter n'a été modifié.

Le contrat utilisateur visible reste celui de CORE-09A :

- une source utilisée est archivée ;
- une source supprimable peut être supprimée ;
- les sources archivées ne sont plus affichées dans les listes actives ;
- aucun chemin storage interne n'est exposé à l'utilisateur.

## Synchronisation roadmap

- `CORE-09B` passe à `DONE` dans `EXECUTION_LOT_TRACKER_V2.md`.
- `CORE-09` reste `IN_PROGRESS` tant que `CORE-09C` n'est pas terminé.
- `DEC-011` documente la décision canonique : le cleanup physique passe par une intention transactionnelle backend.

## Tests app

Aucun test Flutter n'a été lancé pour ce lot, car aucun fichier runtime Flutter n'a été modifié.

Les validations app effectuées sont documentaires :

- `git diff --check`
- `git status --short --untracked-files=all`

## Dette restante

- `CORE-09C` doit traiter le lifecycle matière/cours.
- L'app ne possède pas encore d'historique utilisateur des sources archivées.
- Le storage cloud reste une dette backend future, sans changement de contrat app attendu en V0.
