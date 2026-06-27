# DEMO-05 — Polish démo + Luna légère — Evidence Pack

## 1. Objectif

Clore le couloir MVP demo avec un polish tres limite : rendre le flow demo plus coherent, renforcer legerement la presence de Luna et documenter comment presenter Neralune sans exposer les coutures techniques.

Phrase produit du lot :

> Je peux montrer Neralune de bout en bout sans expliquer les coutures techniques.

## 2. Rappel du verrou MVP démo

Le lot respecte `docs/roadmap/v4/MVP_DEMO_LOCK.md` :

- pas de backend ;
- pas de Prisma ;
- pas de GenUI ;
- pas de nouvelle dependance ;
- pas de nouvel asset ;
- pas de `/study-sessions` ;
- pas de nouveau mode ;
- pas de sujet long ;
- pas d'epreuve blanche ;
- pas de mascot system complet.

## 3. Résumé des changements

- Ajout d'une presence Luna statique et discrete sur le bilan de session.
- Ajout d'un test qui verifie cette presence sans animation infinie.
- Creation du runbook de demo `MVP_DEMO_RUNBOOK.md`.
- Mise a jour du tracker : `DEMO-05` passe a `DONE`, le couloir `DEMO-01` a `DEMO-05` est considere termine, et le prochain jalon recommande devient une revue manuelle / stabilisation post-demo.

## 4. Fichiers modifiés

- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `test/features/revision_sessions/revision_session_result_page_test.dart`
- `docs/roadmap/v4/MVP_DEMO_RUNBOOK.md`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/DEMO-05_polish_demo_luna_legere_EVIDENCE_PACK.md`

## 5. Parcours démo validé

Le parcours demo attendu reste :

```text
Aujourd'hui → Cours → Détail cours → Choix durée → Session quick immersive → Bilan propre → Retour cours / fiche
```

Validation par tests et audit :

- `Aujourd'hui` reste la route d'ouverture avec une action principale.
- `Cours` reste une bibliotheque compacte accessible depuis la bottom nav.
- Le detail cours conserve le parcours de notions et l'action de revision.
- Le choix duree `5 / 15 / 30` reste branche sur le moteur quick existant.
- La session quick immersive reste sans bottom nav.
- Le bilan propre affiche score, corrections utiles, prochaine etape et Luna discrete.
- Le retour cours / fiche reste branche via les routes existantes.

## 6. Luna légère

Emplacements Luna confirmes dans le flow demo :

- Today header : presence statique existante.
- Cours : silhouette discrete existante dans la hero card.
- Detail cours : presence statique existante.
- Bilan : nouvelle presence statique ajoutee dans le header.

Pourquoi ces emplacements :

- ils jalonnent le flow sans mettre Luna sur chaque carte ou chaque question ;
- ils renforcent l'identite Neralune aux moments de transition ;
- ils ne creent pas de nouveau systeme mascotte.

Aucun nouvel asset n'a ete ajoute. Le bilan utilise `assets/brand/neralune_cat.svg`, deja declare dans `pubspec.yaml`.

Animations :

- la Luna du bilan est statique ;
- aucun `NeraluneAnimatedLogo` n'a ete ajoute au flow demo ;
- les tests `pumpAndSettle` restent stables.

## 7. Wording nettoyé

Termes techniques confirmes absents du parcours quick/result via tests visibles :

- `MVP`
- `backend`
- `legacy`
- `fixture`
- `payload`
- `ActivitySession`
- `QuestionBank`
- `questionCount`
- `diagnostic_quiz`
- `open_question`
- `rich_closed_exercise`
- `GenUI`
- `Prisma`

Notes :

- Les termes peuvent rester dans le code, les routes legacy et certains tests techniques.
- `QCM complet` reste accessible dans les actions legacy avancees du detail cours, mais n'est pas le flow demo recommande dans le runbook.

## 8. Ce qui reste volontairement hors scope

- Backend.
- Prisma.
- GenUI.
- Study Session V4 complete.
- Facade `/study-sessions`.
- Sujet long.
- Epreuve blanche.
- Progres avance.
- Mascot system complet.
- Nouveaux assets.
- Nouvelle dependance.
- Feedback immediat per-question complet.

## 9. Tests exécutés

| Commande | Résultat | Notes |
| --- | --- | --- |
| `flutter test test/features/revision_sessions/revision_session_result_page_test.dart` | OK | 9 tests passent ; verifie aussi `result-luna-static`. |
| `flutter test test/features/revision_sessions/quick_revision_quiz_flow_test.dart` | OK | 5 tests passent ; session quick immersive stable. |
| `flutter test test/features/revision_sessions/revision_session_page_test.dart` | OK | 20 tests passent ; routes/session quick stables. |
| `flutter test test/features/courses/course_detail_page_test.dart` | OK | 31 tests passent ; detail cours, duree et parcours stables. |
| `flutter test test/app/router/app_router_test.dart` | OK | 23 tests passent ; shell, routes legacy et routes session/result stables. |
| `flutter test test/app/revision_app_test.dart` | OK | 12 tests passent ; bottom nav, profil secondaire et app shell stables. |
| `flutter analyze` | Echec outil | Crash analysis server : `FormatException: Unexpected end of input`, exit code 1, crash report `flutter_22.log` genere puis supprime. Aucun diagnostic Dart exploitable. |
| `git diff --check` | OK | Aucun whitespace error. |
| `git status --short` | OK | Fichiers attendus uniquement : result page, test result, tracker, runbook et evidence pack. |

## 10. Risques restants

- Le moteur reste quick legacy sous le capot.
- La duree reste mappee vers un nombre de questions.
- Le feedback immediat per-question reste futur.
- Luna reste volontairement legere.
- La vraie V1 reste apres la demo.
- Les actions legacy avancees existent encore pour compatibilite.

## 11. Autocritique finale

Le lot reste volontairement sobre : une seule touche code visible, de la documentation demo, et un tracker recadre vers la revue manuelle. C'est le bon niveau pour un dernier polish avant demo. Le principal manque reste le feedback immediat reel, mais l'ajouter ici aurait casse le verrou MVP.

## 12. Prochain lot recommandé

`PAUSE — Démo manuelle, captures, retours utilisateur`

Alternative si un lot formel est necessaire :

`POST-DEMO-01 — Audit démo et stabilisation post-MVP`

Ne pas repartir directement sur `V4-05B`, `V4-06A`, Sujet long, Epreuve blanche, Progres avance ou GenUI avant cette revue.
