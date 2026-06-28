# V5-05 — Detail cours parcours gamifie — Evidence Pack

## 1. Objectif

Finaliser le detail cours pour qu'il ressemble a un parcours de progression, pas a une liste technique. Le lot doit rendre visibles le prochain checkpoint, le CTA principal et les actions bas d'ecran, sans inventer de progression.

## 2. Maquette utilisee

- Chemin maquette : `docs/roadmap/v5/evidence/screenshots/V5-05/target/mockup-reference.png`
- Ecran de reference : maquette ecran 4, `Detail cours`.
- Remarques de comparaison : la cible montre un header compact, un CTA `Continuer · 8 min`, un indicateur de maitrise, une timeline verticale et deux actions bas d'ecran.

## 3. Rappel du probleme

- Le detail cours etait trop proche d'une liste.
- La progression etait froide et peu lisible.
- Le CTA n'etait pas assez contextuel.
- Le parcours manquait de checkpoints visuels.
- La notion active devait etre plus clairement mise en avant.

## 4. Audit de l'etat existant

Avant V5-05, V5-01 et V5-03 avaient deja stabilise les CTA honnetes et les labels de sources humains. Le commit intermediaire `2ee5dfd` a ensuite restaure des cards responsives, elargi la page aux formats mobile/tablette/web et synchronise la navigation principale du detail cours.

Conserve :
- design system sombre existant ;
- source de verite `CourseLearningPath` ;
- fallback fiche quand les questions ne sont pas pretes ;
- absence de filenames bruts dans le parcours principal.

Corrige par le lot :
- parcours mis en scene comme timeline de checkpoints ;
- notion active visuellement distincte ;
- CTA principal contextuel ;
- actions bas d'ecran visibles en mobile ;
- surface detail cours immersive, sans bottom navigation parasite.

## 5. Strategie produit

La strategie est une gamification legere fondee sur les donnees reelles :

- checkpoints issus de `CourseLearningPathNode` ;
- notion active depuis `activeNodeId` et l'action primaire ;
- CTA principal depuis `CourseLearningPathPrimaryAction` ;
- actions bas d'ecran `Comprendre` et `Reviser cette notion` ;
- progression affichee seulement quand une valeur de maitrise exploitable existe ;
- pas de badge, XP, streak ou recompense inventee.

## 6. Resume des changements

- Ajout d'une mise en page responsive pour le detail cours.
- Remise en cards du hero/CTA et du parcours.
- Timeline verticale plus lisible avec checkpoint actif.
- Actions bas d'ecran maintenues en sticky mobile.
- Harness Flutter Web `dev/playwright_main.dart` pour verifier le parcours en dark mode.
- Captures V5-05 ajoutees dans le dossier evidence.
- Tracker V5 mis a jour.

## 7. Fichiers modifies

Implementation deja livree dans `2ee5dfd` :

- `dev/playwright_main.dart`
- `lib/app/router/app_router.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/courses_home_page.dart`

Finalisation documentaire de ce tour :

- `docs/roadmap/v5/EXECUTION_TRACKER_V5.md`
- `docs/roadmap/v5/evidence/V5-05_detail_cours_parcours_gamifie_EVIDENCE_PACK.md`
- `docs/roadmap/v5/evidence/screenshots/V5-05/`

Note de scope : le working tree contient aussi une correction separee post-V5-05 sur le retour `Aujourd'hui -> fiche`. Elle n'est pas comptabilisee comme changement produit V5-05.

## 8. Surfaces couvertes

- Header : retour, menu discret, titre cours.
- CTA principal : `Continuer · 8 min` dans l'etat pret.
- Parcours : timeline verticale.
- Notion active : checkpoint violet et ligne active.
- Bottom actions : `Comprendre` et `Reviser cette notion`.
- Loading/error : route `/courses/unknown` capturee comme etat loading controle dans le harness.
- Empty : couvert par test widget, non reproduit dans les donnees du harness Playwright.

## 9. Captures visuelles

Target :

- `docs/roadmap/v5/evidence/screenshots/V5-05/target/mockup-reference.png`

Before :

- `docs/roadmap/v5/evidence/screenshots/V5-05/before/course-detail-current.png`
- `docs/roadmap/v5/evidence/screenshots/V5-05/before/course-detail-bottom-actions-current.png`

After :

- `docs/roadmap/v5/evidence/screenshots/V5-05/after/course-detail-hero-and-cta.png`
- `docs/roadmap/v5/evidence/screenshots/V5-05/after/course-detail-path-checkpoints.png`
- `docs/roadmap/v5/evidence/screenshots/V5-05/after/course-detail-active-node.png`
- `docs/roadmap/v5/evidence/screenshots/V5-05/after/course-detail-bottom-actions.png`
- `docs/roadmap/v5/evidence/screenshots/V5-05/after/course-detail-error-or-loading.png`

Network :

- `docs/roadmap/v5/evidence/screenshots/V5-05/network-issues.json`

Etat non capture :

- `after/course-detail-empty-path.png` n'a pas ete produit : le harness Playwright V5-05 dispose de deux cours avec parcours, pas d'un cours source-prete/parcours-vide. L'etat reste couvert par `course detail displays backend learning path empty state`.

## 10. Comparaison avec la maquette

| Surface | Maquette cible | Avant | Apres | Ecart restant | Verdict |
|---|---|---|---|---|---|
| Header | Retour, titre cours, menu discret | Header plus charge, bottom nav visible | Header compact, retour/menu visibles | Pas de barre iOS native dans Flutter Web | VALIDE |
| CTA principal | `Continuer · 8 min` | CTA separe et moins parcours | CTA dans card hero, libelle contextuel | Libelle depend des donnees backend | VALIDE |
| Progression | Anneau si fiable | 0% pouvait paraitre froid | 7% affiche dans le harness depuis donnee de maitrise | Fiabilite depend du LearningPath | VALIDE |
| Parcours | Timeline de checkpoints | Liste dense avec metadata technique | Timeline verticale, checkpoint actif | Long parcours necessite scroll | VALIDE |
| Notion active | Ligne active marquee | Notion moins mise en avant | Carte active violette | Aucun | VALIDE |
| Actions bas | Deux actions en bas | Bottom nav polluait l'ecran | Barre actions sticky `Comprendre` / `Reviser cette notion` | Aucun | VALIDE |
| Jargon/fichiers | Aucun jargon, pas de filename principal | Filename visible dans le parcours | Aucun filename brut dans le parcours principal | Fichier original reste seulement dans la fiche/sources | VALIDE |

## 11. Tests executes

| Commande | Resultat | Notes |
|---|---|---|
| `dart analyze lib/app/router/app_routes.dart lib/core/routing/route_paths.dart lib/app/router/app_router.dart lib/presentation/pages/today/today_page.dart lib/features/courses/presentation/course_revision_sheet_page.dart test/features/today/today_page_test.dart test/app/router/app_router_test.dart` | OK | Analyse des changements de navigation presents dans le working tree. |
| `flutter test --no-pub test/features/today/today_page_test.dart` | OK | Verification du retour Today -> fiche separee du lot V5-05. |
| `flutter test --no-pub test/app/router/app_router_test.dart` | OK | Inclut le nouveau cas Today -> fiche -> Today et les routes detail/fiche existantes. |
| `flutter test --no-pub test/features/courses/course_detail_page_test.dart` | OK | Couvre detail cours, path, CTA, etats, absence jargon. |
| `flutter test --no-pub test/features/revision_sessions/revision_session_result_page_test.dart` | OK | Verifie que les autres entrees vers fiche restent stables. |
| `flutter test --no-pub test/features/courses/revisions_pending_page_test.dart` | OK | Verifie le fallback fiche depuis le hub revisions. |
| `NODE_PATH=/tmp/neralune-playwright-v503/node_modules node <runner>` | OK | Captures dark mobile 390 x 844 via harness Flutter Web. |

## 12. Compte de test

- Compte de test autorise : `yoahn.l@me.com`
- Mot de passe : utilise uniquement via variable d'environnement locale si le runner live Firebase est utilise.
- Pour ce lot, les captures finales ont ete faites via harness Flutter Web local controle, sans stocker ni afficher le mot de passe.
- Aucun mot de passe n'est stocke, committe ou affiche.

Commande documentee si runner live necessaire :

```bash
NERALUNE_EMAIL='yoahn.l@me.com' \
NERALUNE_PASSWORD='***' \
npx -y -p playwright node <runner>
```

## 13. Non-objectifs respectes

- Pas de backend.
- Pas de Prisma.
- Pas de GenUI.
- Pas de Today dans le scope V5-05.
- Pas de fiche premium.
- Pas de session question.
- Pas de fake XP.
- Pas de fake progression.
- Pas de refonte globale.

## 14. Risques restants

- La progression depend de la qualite du `LearningPath` et des champs de maitrise fournis.
- Certains etats peuvent rester approximatifs si le backend ne fournit pas assez de details.
- L'etat parcours vide n'a pas ete reproduit dans le harness Playwright local.
- La fiche premium reste V5-06.
- Le choix duree reste V5-07.
- La session question reste V5-08.

## 15. Verdict visuel

`VALIDÉ`

Le detail cours correspond maintenant a la direction maquette : parcours vertical, checkpoint actif, CTA contextuel, action bar mobile et absence de jargon technique visible.

## 16. Prochain lot recommande

```text
V5-06 — Fiche premium actionnable
```
