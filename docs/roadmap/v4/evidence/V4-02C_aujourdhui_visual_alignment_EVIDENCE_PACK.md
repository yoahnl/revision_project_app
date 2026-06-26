# V4-02C — Aujourd’hui visual alignment — Evidence Pack

## 1. Objectif

Rapprocher la page `Aujourd’hui` de la reference mobile fournie : une page plus chaleureuse, guidee, centree sur une session du jour, sans dashboard technique ni donnees inventees.

## 2. Reference visuelle

La reference montre un ecran mobile sombre premium avec greeting en haut, Luna a droite, sous-titre `Ta session du jour`, une carte hero compacte, un CTA clair `Réviser maintenant`, un objectif semaine et une continuation compacte.

Le lot reprend la hierarchie, la presence Luna, le CTA clair et la compacite generale, sans copier les donnees fictives de l'image.

## 3. Resume des changements

- Remplacement du titre page `Aujourd’hui` par un greeting local `Bonjour` / `Bonsoir`.
- Ajout de Luna statique via l'asset existant `assets/brand/neralune_cat.svg`.
- Recomposition de la carte principale : badge matiere, icone matiere, titre, meta duree, recommandation et CTA clair.
- CTA principal blanc/clair, toujours branche sur les routes existantes.
- Ajout de `Changer de cours` comme action secondaire fiable vers Cours.
- Objectif semaine affiche uniquement si le backend fournit `weeklyObjective`.
- Objectif target-only affiche sous forme sobre, sans `3 / 4` ni dots inventes.
- Section `Continuer` limitee a une seule continuation fiable.
- Lecture optionnelle des champs backend enrichis V4-02B avec fallback legacy.
- Aucun backend, Prisma, GenUI, asset ou shell modifie.

## 4. Fichiers modifies

- `lib/presentation/pages/today/today_page.dart`
- `lib/features/today/domain/today_plan.dart`
- `lib/features/today/data/http_today_repository.dart`
- `test/features/today/today_page_test.dart`
- `test/features/today/http_today_repository_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/V4-02C_aujourdhui_visual_alignment_EVIDENCE_PACK.md`

## 5. Comportement utilisateur obtenu

- Greeting en haut : `Bonjour` ou `Bonsoir`.
- Luna discrete en haut a droite, sans animation infinie.
- Carte session du jour plus proche de la reference : badge, icone, titre, duree, raison et CTA clair.
- CTA `Réviser maintenant` lisible et contraste.
- Objectif semaine sans fake data : affichage target-only seulement quand disponible.
- Continuation compacte : un seul item secondaire maximum.
- Pas de jargon technique visible.
- Pas de modification backend.
- Bottom nav conservee : `Aujourd’hui`, `Cours`, `Progrès`.

## 6. Compatibilite Today backend enrichment

Les champs V4-02B sont consommes en option :

- `primaryItemId`
- `continuationItemIds`
- `weeklyObjective`
- `emptyState`
- `items[].role`
- `items[].display`

La retrocompatibilite est assuree parce que tous ces champs sont optionnels dans le modele Flutter. Si l'ancien contrat `/today` est retourne, la page retombe sur les champs existants : premier item, items suivants, `estimatedMinutes`, `reasonCode`, `reason` et `startPayload`.

## 7. Tests executes

| Commande | Resultat | Notes |
| --- | --- | --- |
| `flutter test test/features/today/http_today_repository_test.dart` | PASS — 8 tests | Couvre contrat enrichi et ancien contrat legacy sans nouveaux champs. |
| `flutter test test/features/today/today_page_test.dart` | PASS — 10 tests | Couvre greeting, Luna statique, hero, CTA, empty, absence de jargon, routes et continuation unique. |
| `flutter test test/app/revision_app_test.dart` | PASS — 11 tests | Confirme ouverture Today et navigation principale V4. |
| `flutter test test/app/router/app_router_test.dart` | PASS — 24 tests | Confirme routes legacy et shell trois onglets. |
| `flutter analyze` | FAIL — analysis server crash | Crash outil connu : `FormatException: Unexpected end of input`, analysis server exit code 255, rapport `flutter_07.log`. Aucun diagnostic projet exploitable n'a ete emis. |
| `git diff --check` | PASS | Aucun probleme whitespace detecte. |
| `git status --short` | PASS — perimetre attendu | Modifications limitees aux fichiers Today frontend, tests Today et docs V4. Aucun backend, Prisma, GenUI ou asset modifie. |

## 8. Captures / verifications manuelles

Reference visuelle ouverte localement et comparee pendant l'implementation.

Verification manuelle de structure :

- header greeting + Luna ;
- hero card compacte ;
- CTA clair ;
- objectif semaine sobre ;
- continuation unique ;
- absence de faux `3 / 4` ;
- absence de nombre de questions invente.

Aucune capture finale n'a ete produite dans ce lot.

## 9. Decisions prises

- Utiliser Luna statique plutot que `NeraluneAnimatedLogo`, afin de ne pas reintroduire une animation infinie dans les tests.
- Afficher `Bonjour` / `Bonsoir` sans prenom, car le prenom n'est pas disponible dans `TodayPage` sans dependance auth reactive plus large.
- Consommer `display` quand present, mais conserver les mappings locaux par `reasonCode` pour compatibilite.
- Forcer le CTA hero a `Réviser maintenant`, meme si un item fixture porte un label secondaire.
- Afficher seulement `Changer de cours` comme action secondaire fiable.
- Reporter `Choisir une autre duree` au lot duration picker.

## 10. Risques restants

- `Changer de cours` est branche, mais `Choisir une autre duree` est reporte car le duration picker n'existe pas encore.
- Le frontend conserve encore des mappings locaux Today pour les anciens contrats.
- Luna reste statique ; le mascot system complet est reserve a la phase Luna/polish.
- Les routes lancees restent les routes legacy jusqu'a Study Session V4.

## 11. Autocritique finale

Le lot rapproche nettement Today de la reference sans inventer de progression ni de nombre de questions. La limite principale est assumee : il s'agit d'un alignement visuel et contractuel leger, pas d'un nouveau flow de session ni d'un duration picker.

## 12. Prochain lot recommande

`V4-03A — Cours V4 frontend`
