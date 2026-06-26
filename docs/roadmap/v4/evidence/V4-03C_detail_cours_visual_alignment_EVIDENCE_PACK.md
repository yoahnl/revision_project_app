# V4-03C — Détail cours visual alignment — Evidence Pack

## 1. Objectif

Rapprocher `CourseDetailPage` de la reference V4 : un cours, une progression fiable, un CTA principal, un parcours de notions si les donnees existent, deux actions en bas, Luna discrete, sans dashboard visible.

## 2. Référence visuelle

Reference mobile sombre : top bar retour/ellipsis, titre du cours, anneau de progression, CTA `Continuer`, parcours vertical sobre et actions `Comprendre` / `Réviser cette notion`.

## 3. Résumé des changements

- Remplacement du header charge par une top bar minimale avec `Retour` et menu `Plus d’actions`.
- Ajout d'un header cours plus sobre avec titre, matiere, Luna statique et anneau de maitrise uniquement si la progression est fiable.
- Remplacement de la carte "Action recommandee", des stats, de l'historique et des modes visibles par un CTA unique et un parcours.
- Affichage d'un parcours vertical depuis les vrais `CourseRichRevisionScopeOption` quand ils existent.
- Affichage d'un etat honnete quand aucun vrai libelle de notion n'est disponible.
- Ajout d'actions basses `Comprendre` et `Réviser cette notion` ou `Réviser ce cours` selon les donnees disponibles.
- Deplacement des sources, gestion, historique et actions avancees dans le menu `...`.

## 4. Fichiers modifiés

- `lib/features/courses/presentation/course_detail_page.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/app/router/app_router_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`

## 5. Comportement utilisateur obtenu

- Page detail cours simplifiee : titre, progression fiable, CTA, parcours, actions basses.
- CTA principal honnete : `Reprendre`, `Continuer`, `Ajouter une source`, `Voir les sources`, `Préparation en cours` selon l'etat reel.
- Progression circulaire affichee seulement quand le progress provider donne une progression pratiquee.
- Parcours vertical affiche les vrais libelles de notions disponibles via les options de revision riche.
- Si les notions ne sont pas disponibles, l'ecran dit que le parcours sera affiche quand il sera disponible.
- `Comprendre` ouvre la fiche existante si une source est prete.
- `Réviser cette notion` ouvre le flux existant de revision riche quand une notion reelle est disponible.
- `Réviser ce cours` reste le fallback honnete quand aucune notion specifique n'est exploitable.
- Luna utilise `assets/brand/neralune_cat.svg` en statique.
- Historique et modes ne sont plus visibles dans le flux principal.
- Sources et gestion restent accessibles via le menu secondaire.

## 6. Données utilisées et données masquées

Donnees utilisees :

- `CourseDetail.course.title`
- `CourseDetail.subject.name`
- `CourseDetail.sources`
- `CourseProgress.estimatedGlobalMastery` uniquement si `CourseProgressState.practiced`
- `CourseRichRevisionOptions.scopeOptions` pour les vrais libelles de notions
- `CourseRichRevisionOptions.defaultConfig.scopeId` pour choisir la notion active si disponible
- `CourseQuestionBankReadiness` et `ResumableCourseRevisionSession` pour le CTA

Donnees masquees ou non inventees :

- Pas de faux titres de notions.
- Pas de faux etats `solide` / `a renforcer`.
- Pas de faux `8 min` quand `estimatedMinutes` est absent.
- Pas de stat principale `Temps estime : A preciser` ou `Difficulte : A preciser`.
- Pas de faux historique.

## 7. Choix sur le parcours

Le parcours utilise les vrais `scopeOptions` de `CourseRichRevisionOptions`, car c'est la seule source frontend deja branchee qui expose des libelles de notions. La notion active est le `defaultConfig.scopeId`, sinon la premiere option selectionnable, sinon la premiere option reelle.

Les etats pedagogiques par notion ne sont pas affiches, car le frontend ne dispose pas encore d'un contrat fiable de maitrise par notion. Les checks verts de la reference ne sont donc pas copies pour eviter le fake.

## 8. Choix sur Luna

Luna est affichee via `assets/brand/neralune_cat.svg`, en statique, avec une petite presence dans le header. Aucun asset n'a ete modifie et aucune animation infinie n'a ete ajoutee, ce qui garde les tests `pumpAndSettle` stables.

## 9. Tests exécutés

| Commande | Resultat | Notes |
| --- | --- | --- |
| `flutter test test/features/courses/course_detail_page_test.dart` | PASS | 29 tests passent. |
| `flutter test test/features/courses/courses_home_page_test.dart` | PASS | Relance sequentielle OK apres un crash de commande parallele. |
| `flutter test test/app/revision_app_test.dart` | PASS | 12 tests passent. |
| `flutter test test/app/router/app_router_test.dart` | PASS | 23 tests passent apres adaptation menu `...`. |
| `flutter analyze` | FAIL outil | Crash connu de l'analysis server : `FormatException: Unexpected end of input`, exit 255, log `flutter_12.log`. |
| `git diff --check` | PASS | Aucun whitespace error. |
| `git status --short` | PASS | Fichiers modifies/crees attendus uniquement. |

## 10. Décisions prises

- Le detail cours V4 devient une page de parcours, pas une page de modes.
- Les modes legacy restent accessibles dans `Actions avancées`.
- L'historique reste accessible dans le menu, mais sort du flux principal.
- Les vraies options de revision riche servent de source provisoire de libelles de notions.
- Les etats de notion ne sont pas affiches tant que le backend ne fournit pas un learning path fiable.

## 11. Risques restants

- Le vrai learning path backend manque encore : pas d'etat fiable par notion.
- L'action notion-specific route vers le flux riche existant, pas encore vers une Study Session V4.
- Le menu `...` est fonctionnel mais merite un polish futur.
- Le duration picker n'existe toujours pas.

## 12. Autocritique finale

Le lot simplifie nettement l'ecran et respecte l'honnetete des donnees. La principale limite est que le parcours n'a pas encore les etats pedagogiques de la reference ; les afficher maintenant aurait ete mensonger. Les anciennes surfaces restent accessibles, mais leur UX secondaire pourra etre mieux unifiee plus tard.

## 13. Prochain lot recommandé

`V4-04A — Learning path backend contract`

Raison : le detail cours a maintenant la structure V4, mais il manque le contrat backend fiable pour afficher les etats de notion, la notion active et les checks de progression sans fake data.
