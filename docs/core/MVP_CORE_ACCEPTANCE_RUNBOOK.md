# MVP Core acceptance runbook

Ce runbook vérifie le parcours MVP Core réel côté Flutter, sans fixtures MVP dans le routing réel.

## Parcours utilisateur

1. Ouvrir l'app avec un utilisateur authentifié.
2. Voir les matières réelles.
3. Créer ou ouvrir un cours réel.
4. Ouvrir le détail du cours.
5. Cliquer sur `Ajouter une source`.
6. Choisir un PDF réel.
7. Attendre le traitement jusqu'au statut `Prête`.
8. Ouvrir `Fiche de cours`.
9. Revenir au cours.
10. Démarrer `Révision rapide`.
11. Répondre au QCM.
12. Revenir sur le cours ou l'onglet `Progrès`.
13. Vérifier la progression réelle.

## Vérifications UI attendues

- Le détail cours affiche uniquement les sources réelles de l'API.
- Une source `UPLOADED` ou `PROCESSING` déclenche un polling borné.
- Pendant ce polling, le détail et la progression sont rafraîchis.
- La fiche n'est activée que si une source `READY` existe.
- La révision rapide n'est activée que si une source `READY` existe.
- `/progress` affiche `SubjectProgressPage`, pas une page pending CORE-06.
- Les compteurs fake `78%`, `870`, `7 jours` et `Loi normale` ne doivent pas apparaître dans le parcours réel.

## Commandes de validation

```bash
dart analyze lib test
flutter test test/features/courses --reporter compact
flutter test test/features/revision_sessions --reporter compact
flutter test test/app/router/app_router_test.dart --reporter compact
flutter test test/app/revision_app_test.dart --reporter compact
flutter test test/app --reporter compact
flutter test --reporter compact
git diff --check
```

## Hors MVP Core

- Révision approfondie.
- Préparation examen.
- Résultat final dédié de session.
- Gamification durable.
- Multi-source avancé.
- `CourseSource`.
- WebSocket/SSE de progression.

## Notes de cohérence

- L'upload réussi invalide le détail, la liste de cours, la progression du cours et la progression matière.
- L'annulation du picker ne déclenche aucun upload ni refresh artificiel.
- L'échec d'upload ne simule pas une source réelle.
- Le démarrage d'une révision rapide ne rafraîchit pas la progression : la mastery change après submit, pas au start.
- La génération d'une fiche ne rafraîchit pas la progression : elle ne modifie ni `MasteryState` ni `Document.status`.
