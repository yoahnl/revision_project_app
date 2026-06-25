# V4-01A — Shell trois onglets — Evidence Pack

## 1. Objectif

Mettre en place le shell V4 avec trois destinations principales visibles :

- `Aujourd’hui`
- `Cours`
- `Progrès`

Le lot devait masquer les anciennes destinations principales `Réviser` et `Profil`, sans supprimer brutalement les routes legacy ni refaire les pages.

## 2. Résumé des changements

- L'application s'ouvre maintenant sur `AppRoutes.today`, sauf redirect auth/onboarding existant.
- La route racine `/` redirige vers `/today`.
- Le shell principal expose trois branches visibles : Today, Cours, Progrès.
- La bottom navigation et le rail desktop affichent uniquement `Aujourd’hui`, `Cours`, `Progrès`.
- Les routes legacy `/revisions`, `/activities` et `/profile` restent accessibles hors shell principal.
- Les routes cours, détail cours, fiche, sources de fiche, rich revision, deep revision, exam preparation, sessions et résultats restent déclarées.
- Les tests router/app ont été mis à jour pour refléter la navigation V4.

## 3. Fichiers modifiés

- `lib/app/router/app_router.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`

Fichier créé :

- `docs/roadmap/v4/evidence/V4-01A_shell_trois_onglets_EVIDENCE_PACK.md`

## 4. Comportement utilisateur obtenu

- La navigation principale visible contient exactement trois onglets.
- Les labels visibles sont `Aujourd’hui`, `Cours`, `Progrès`.
- `Aujourd’hui` pointe vers `TodayPage`.
- `Cours` pointe vers `CoursesHomePage`.
- `Progrès` pointe vers `SubjectProgressPage`.
- L'application s'ouvre prioritairement sur `Aujourd’hui`.
- `Réviser` n'est plus exposé comme onglet principal.
- `Profil` n'est plus exposé comme onglet principal.
- Le profil reste accessible via `/profile`, hors navigation principale.
- Les routes legacy sont préservées autant que possible et restent testées.

## 5. Tests exécutés

| Commande | Résultat | Cause probable si échec | Notes |
| --- | --- | --- | --- |
| `dart format lib/app/router/app_router.dart lib/presentation/shell/revision_home_shell.dart test/app/router/app_router_test.dart test/app/revision_app_test.dart` | Succès | Sans objet | 4 fichiers traités, 2 tests formatés. |
| `flutter test test/app/router/app_router_test.dart` | Succès | Sans objet | 23 tests passés. |
| `flutter test test/app/revision_app_test.dart` | Échec initial | Commandes Flutter lancées en parallèle, conflit sur `ios/Flutter/ephemeral/Packages/.packages`. | Relancé seul ensuite. |
| `flutter test test/app/revision_app_test.dart` | Succès | Sans objet | 10 tests passés. |
| `flutter analyze` | Échec outil | Crash de l'analysis server : `FormatException: Unexpected end of input`, sortie code 255. | Aucun warning du lot n'a été remonté avant le crash ; rapport Flutter écrit dans `flutter_03.log`. |
| `flutter analyze --no-pub` | Échec outil | Même crash analysis server : `FormatException: Unexpected end of input`, sortie code 255. | Deuxième essai non concluant ; rapport Flutter écrit dans `flutter_04.log`. |
| `git diff --check` | Succès | Sans objet | Aucun probleme whitespace detecte. |
| `git status --short --untracked-files=all` | Succès | Sans objet | Liste uniquement les fichiers frontend/docs du lot. |

## 6. Captures / vérifications manuelles

Aucune capture n'a été produite dans ce lot.

Vérification manuelle couverte par tests widgets :

- L'écran initial affiche `Plan du jour`.
- La bottom navigation mobile affiche `Aujourd’hui`, `Cours`, `Progrès`.
- Le rail desktop affiche la même navigation V4.
- Les textes `Réviser` et `Profil` ne sont plus présents dans la navigation principale.
- Les routes immersives de session restent sans bottom navigation.

## 7. Décisions prises

- `AppRoutes.today` devient l'emplacement initial de l'application.
- `AppRoutes.home` reste la route legacy de la bibliothèque de cours.
- `/revisions`, `/activities` et `/profile` restent accessibles mais sortent des branches visibles du shell.
- Les pages elles-mêmes ne sont pas refondues dans ce lot.
- Le profil n'a pas encore de nouveau point d'entrée secondaire visible ; ce point appartient au lot `V4-01B`.

## 8. Risques restants

- Le profil est accessible techniquement par `/profile`, mais pas encore exposé via une action secondaire dans l'UI.
- Certains liens internes historiques peuvent encore envoyer vers `/revisions` ou `/activities`, qui restent volontairement accessibles.
- `TodayPage` reste visuellement legacy et ne correspond pas encore à la cible V4.
- `CoursesHomePage` et `SubjectProgressPage` ne sont pas refondus dans ce lot.
- `flutter analyze` doit être relancé quand le crash analysis server est résolu.

## 9. Points à surveiller au prochain lot

- Ajouter un accès profil secondaire sans réintroduire `Profil` comme onglet principal.
- Vérifier les deep links `/profile`, `/revisions`, `/activities`, `/courses/:courseId` après le déplacement hors branches visibles.
- Décider si `/revisions` doit rester immersive ou recevoir une redirection produit plus douce plus tard.
- Conserver les routes legacy tant que les historiques et résultats existants en dépendent.

## 10. Autocritique finale

Le lot reste volontairement étroit : il change le shell et les tests associés, sans embellir les pages. C'est cohérent avec V4-01A, mais cela signifie que l'écran `Aujourd’hui` ouvert par défaut garde son UI legacy jusqu'au lot `V4-02A`.

Le choix de sortir `/profile` du shell plutôt que de créer immédiatement un bouton profil est prudent pour tenir le scope. Il rend cependant `V4-01B` important : sans lui, le profil existe techniquement mais n'a pas encore d'accès utilisateur secondaire propre.

## 11. Prochain lot recommandé

`V4-01B — Profil secondaire et routes legacy préservées`
