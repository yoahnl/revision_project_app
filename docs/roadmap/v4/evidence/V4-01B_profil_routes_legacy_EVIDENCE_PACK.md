# V4-01B — Profil secondaire et routes legacy préservées — Evidence Pack

## 1. Objectif

Rendre le profil accessible depuis le shell V4 sans le réintroduire comme destination principale, tout en confirmant que les routes historiques restent joignables.

Le lot devait conserver la navigation principale visible à trois entrées :

- `Aujourd’hui`
- `Cours`
- `Progrès`

Et garder hors navigation principale :

- `Profil`
- `Réviser`
- `Sources`
- `Activités`

## 2. Résumé des changements

- Ajout d'un raccourci profil secondaire dans le shell V4.
- Le raccourci profil utilise `context.push(AppRoutes.profile)` pour conserver une pile de retour.
- Le mobile affiche une icône profil flottante au-dessus de la bottom navigation.
- Le layout large affiche la même action secondaire sous le rail de navigation.
- Les trois destinations principales restent inchangées : `Aujourd’hui`, `Cours`, `Progrès`.
- `/profile`, `/revisions`, `/activities` et `/sources` restent déclarées hors shell principal.
- Les tests router et app couvrent maintenant explicitement l'accès profil secondaire et les routes legacy.
- Aucun fichier backend ou Prisma n'a été modifié.

## 3. Fichiers modifiés

- `lib/presentation/shell/revision_home_shell.dart`
- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`

Fichier créé :

- `docs/roadmap/v4/evidence/V4-01B_profil_routes_legacy_EVIDENCE_PACK.md`

Aucun fichier backend ou Prisma modifié.

## 4. Comportement utilisateur obtenu

- La navigation principale visible contient toujours exactement trois onglets.
- Les labels visibles de navigation principale sont `Aujourd’hui`, `Cours`, `Progrès`.
- `Profil` n'est pas exposé comme onglet principal.
- `Réviser` n'est pas exposé comme onglet principal.
- `Sources` et `Activités` ne sont pas exposés comme destinations principales.
- Le profil reste accessible depuis le shell via une action secondaire à icône.
- La route `/profile` reste accessible directement.
- Les routes legacy `/revisions`, `/activities` et `/sources` restent accessibles hors shell.
- Les routes legacy testées n'affichent pas la bottom navigation ni le rail principal.

## 5. Tests exécutés

| Commande | Résultat | Cause probable si échec | Notes |
| --- | --- | --- | --- |
| `dart format lib/presentation/shell/revision_home_shell.dart test/app/revision_app_test.dart test/app/router/app_router_test.dart` | Succès | Sans objet | 3 fichiers traités, 0 changement après formatage. |
| `flutter test test/app/router/app_router_test.dart` | Succès | Sans objet | 23 tests passés. |
| `flutter test test/app/revision_app_test.dart` | Succès | Sans objet | 11 tests passés. |
| `flutter analyze` | Échec outil | Crash de l'analysis server : `FormatException: Unexpected end of input`, sortie code 255. | Aucun diagnostic projet n'a été produit avant le crash ; rapport Flutter écrit dans `flutter_05.log`. |
| `git diff --check` | Succès | Sans objet | Aucun problème whitespace détecté. |
| `git status --short` | Succès | Sans objet | Liste uniquement les fichiers frontend/docs du lot dans `revision_app`; sortie vide côté `api`. |

## 6. Captures / vérifications manuelles

Aucune capture n'a été produite dans ce lot.

Vérifications couvertes par tests widgets :

- L'écran initial reste `Aujourd’hui`.
- La bottom navigation mobile affiche `Aujourd’hui`, `Cours`, `Progrès`.
- Le raccourci profil existe mais le texte `Profil` n'est pas visible dans la navigation principale.
- Le raccourci profil ouvre la page profil hors shell.
- Le rail desktop reste limité aux trois destinations principales.
- Les routes `/profile`, `/revisions`, `/activities` et `/sources` restent joignables.

## 7. Décisions prises

- Le profil devient une action secondaire du shell plutôt qu'une branche de navigation.
- Le raccourci utilise une icône `person_outline_rounded` avec tooltip `Profil`, sans label visible dans la navigation principale.
- Les routes legacy restent top-level et immersives afin de ne pas casser les deep links existants.
- Aucune page métier n'a été refondue dans ce lot.
- Aucun nouveau système de navigation ni design system n'a été créé.

## 8. Risques restants

- Le raccourci profil est volontairement discret ; un futur polish pourra le remplacer par un avatar ou un menu de compte plus explicite.
- La page profil n'a pas reçu de refonte dédiée dans ce lot.
- Les routes legacy restent accessibles et pourront encore être atteintes par anciens liens internes.
- `flutter analyze` reste bloqué par un crash outil indépendant du changement fonctionnel.

## 9. Points à surveiller au prochain lot

- Ne pas réintroduire `Profil` comme onglet principal pendant la refonte Today.
- Vérifier que les nouvelles surfaces Today pointent vers les routes legacy uniquement quand c'est intentionnel.
- Garder `Aujourd’hui` calme et orienté action, sans refaire un dashboard.
- Relancer `flutter analyze` quand le crash de l'analysis server sera résolu.

## 10. Autocritique finale

Le lot respecte le périmètre : il ajoute seulement l'accès profil secondaire et renforce les tests de compatibilité. Le compromis est sobre mais pas définitif côté UX : l'action profil existe, elle est testée, mais elle n'a pas encore la richesse d'un vrai menu de compte.

Le choix de conserver `/revisions`, `/activities` et `/sources` hors shell est cohérent avec la migration progressive V4. Il faudra cependant éviter que ces routes redeviennent des destinations visibles par accident dans les lots Today ou Cours.

## 11. Prochain lot recommandé

`V4-02A — Aujourd’hui V4 frontend-first`
