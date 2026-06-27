# V5-02 — Anti-spinner + surfaces legacy — Evidence Pack

## 1. Objectif

Objectif du lot :

```text
Aucun utilisateur ne doit tomber sur un spinner infini, une page parking ou une surface legacy sans action utile.
```

Phrase produit verifiee :

```text
Quand Neralune n'a rien a afficher, elle explique clairement quoi faire ensuite.
```

## 2. Maquette utilisee

Maquette principale fournie :

```text
/Users/karim/Downloads/ChatGPT Image Jun 25, 2026, 10_54_01 PM.png
```

Copie stable dans le repo :

```text
docs/roadmap/v5/evidence/screenshots/V5-02/target/mockup-reference.png
```

Ecrans de reference concernes :

- Ecran 3, `Cours` : destination utile quand une surface legacy n'a pas de contexte.
- Ecran 4, `Detail cours` : les activites partent d'une notion du parcours.
- Ecran 6, `Reviser (choix duree)` : l'action de revision doit etre fiable ou expliquer l'etat reel.
- Ecran 7, `Session (question)` : aucun QCM ne doit rester en chargement permanent.

Remarque : les pages `Activites`, `Reviser` legacy et `Sources globales` ne sont pas des ecrans coeur de la maquette. Le critere V5-02 est donc la suppression des impasses visibles, pas l'alignement visuel complet de ces surfaces.

## 3. Rappel du probleme

Problemes issus de l'audit mobile dark du 27 juin 2026 :

- `Activites` sans contexte affichait des modes mais pas d'action utile.
- `Activites` avec sujet pouvait rester en spinner apres 10 secondes.
- `Reviser` pouvait donner l'impression d'etre le hub principal alors que le flow V5 part d'un cours.
- `Sources globales` ressemblait a une page parking.
- `QCM complet` avait encore un etat de chargement non borne sur la route legacy.

## 4. Resume des changements

- `Activites` sans sujet affiche maintenant `Choisis une notion depuis un cours` et `Ouvrir les cours`.
- Les actions de modes ne sont plus affichees sur `Activites` sans contexte.
- Les chargements `Activites` sont bornes a 9 secondes avec un etat `Cette activite prend plus de temps que prevu`.
- Les erreurs d'activite deviennent un etat `Activite indisponible pour le moment`, avec `Reessayer` et `Ouvrir les cours`.
- `QCM complet` legacy a aussi un timeout visible de 9 secondes et une action `Ouvrir les cours`.
- `QCM complet` sans notion propose maintenant `Ouvrir les cours`.
- `Reviser` explique que les sessions partent d'un cours et propose `Ouvrir les cours` quand aucun cours n'est pret.
- `Sources` globale explique que les sources se gerent depuis les cours et propose `Ouvrir les cours`.

## 5. Fichiers modifies

Code Flutter :

- `lib/presentation/pages/activities/activities_page.dart`
- `lib/presentation/pages/activities/rich_closed_exercise_page.dart`
- `lib/features/courses/presentation/revisions_pending_page.dart`
- `lib/features/courses/presentation/sources_pending_page.dart`

Tests :

- `test/features/activities/activities_page_test.dart`
- `test/features/activities/rich_closed_exercise_page_test.dart`
- `test/features/courses/revisions_pending_page_test.dart`
- `test/app/router/app_router_test.dart`

Documentation :

- `docs/roadmap/v5/EXECUTION_TRACKER_V5.md`

Fichiers crees :

- `docs/roadmap/v5/evidence/V5-02_anti_spinner_surfaces_legacy_EVIDENCE_PACK.md`
- `docs/roadmap/v5/evidence/screenshots/V5-02/before/activities-no-context.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/before/activities-spinner.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/before/reviser-legacy.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/before/sources-parking.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/activities-no-context-actionable.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/activities-timeout.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/reviser-actionable.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/sources-actionable.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/rich-closed-timeout.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/target/mockup-reference.png`

## 6. Surfaces couvertes

| Surface | Avant | Apres |
|---|---|---|
| Activites sans contexte | Modes visibles mais aucun contenu utile. | Message clair, pas de grille morte, CTA `Ouvrir les cours`. |
| Activites avec contexte long | Spinner persistant possible. | Timeout apres 9 s, `Reessayer`, `Ouvrir les cours`. |
| Activite indisponible | Erreur ou texte generique. | Etat utilisateur sans jargon, action retry et retour cours. |
| QCM complet legacy | Chargement non borne. | Timeout apres 9 s, retry et retour cours. |
| QCM complet sans notion | Message seul. | Message + `Ouvrir les cours`. |
| Reviser | Page pouvant sembler hub principal. | Explique le lancement depuis un cours et garde seulement les actions fiables. |
| Sources globales | Page parking. | Explique que les PDF se gerent depuis les cours, CTA utile. |

## 7. Captures visuelles

Viewport :

```text
390 x 844
dark mode
```

Captures before :

- `docs/roadmap/v5/evidence/screenshots/V5-02/before/activities-no-context.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/before/activities-spinner.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/before/reviser-legacy.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/before/sources-parking.png`

Captures after :

- `docs/roadmap/v5/evidence/screenshots/V5-02/after/activities-no-context-actionable.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/activities-timeout.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/reviser-actionable.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/sources-actionable.png`
- `docs/roadmap/v5/evidence/screenshots/V5-02/after/rich-closed-timeout.png`

Capture target :

- `docs/roadmap/v5/evidence/screenshots/V5-02/target/mockup-reference.png`

Notes de production :

- Les captures `before` viennent de l'audit mobile dark du 27 juin 2026.
- Les captures `after` ont ete regenerees via un harness Flutter widget temporaire en theme dark 390 x 844, puis le harness a ete supprime.
- Playwright a ete tente avec le compte de test fourni. Les premieres passes ont permis de piloter le navigateur, mais les relances headless sur Flutter Web debug ont fini sur une page blanche : DDC chargeait les scripts, mais l'app ne montait pas le widget tree apres 25 secondes. L'echec est documente dans la section tests.

Dimensions verifiees :

```text
after/activities-no-context-actionable.png: 390 x 844
after/activities-timeout.png: 390 x 844
after/reviser-actionable.png: 390 x 844
after/sources-actionable.png: 390 x 844
after/rich-closed-timeout.png: 390 x 844
before/activities-no-context.png: 390 x 844
before/activities-spinner.png: 390 x 844
before/reviser-legacy.png: 390 x 844
before/sources-parking.png: 390 x 844
target/mockup-reference.png: 1672 x 941
```

## 8. Comparaison avec la maquette

| Surface | Maquette cible | Avant | Apres | Ecart restant | Verdict |
|---|---|---|---|---|---|
| Activites / QCM | Ecran 7 : question claire, tactile, sans chargement infini. | Spinner persistant ou page sans contenu utile. | Timeout visible, retry, retour cours ; sans contexte, la page explique le depart depuis un cours. | La session question visuelle complete reste V5-08. | VALIDE pour V5-02 |
| Reviser | Ecran 6 : l'utilisateur choisit une session seulement si elle est fiable. | Page legacy pouvait sembler etre le hub principal. | Wording `Reviser depuis un cours`, action `Ouvrir les cours`, modes non prets secondaires. | Le choix duree maquette reste V5-07. | VALIDE |
| Sources globales | Pas dans la maquette coeur ; les sources doivent soutenir cours/fiche. | Page parking. | Etat clair : les sources se gerent depuis les cours. | V5-03 doit humaniser les labels et PDF. | VALIDE |
| Route legacy QCM complet | Les modes avancés ne doivent pas bloquer. | Loading non borne possible. | Timeout 9 s + retry + retour cours. | Le QCM complet n'est pas la boucle Duolingo principale ; V5-08/V5-09 traiteront la session coeur. | VALIDE |

## 9. Tests executes

| Commande | Resultat |
|---|---|
| `flutter test test/features/activities/activities_page_test.dart --plain-name "does not load an activity without subject"` | RED d'abord : l'ancien ecran ne montrait pas `Choisis une notion depuis un cours`. |
| `flutter test test/features/activities/activities_page_test.dart --plain-name "shows an actionable timeout when activity loading is too long"` | RED d'abord : le timeout n'etait pas affiche. |
| `flutter test test/features/activities/rich_closed_exercise_page_test.dart --plain-name "page affiche un timeout actionnable au chargement trop long"` | RED d'abord : le `QCM complet` restait en chargement. |
| `dart format lib/presentation/pages/activities/activities_page.dart lib/presentation/pages/activities/rich_closed_exercise_page.dart lib/features/courses/presentation/revisions_pending_page.dart lib/features/courses/presentation/sources_pending_page.dart test/features/activities/activities_page_test.dart test/features/activities/rich_closed_exercise_page_test.dart test/features/courses/revisions_pending_page_test.dart test/app/router/app_router_test.dart` | PASS. |
| `flutter test test/features/activities/activities_page_test.dart` | PASS, 7 tests. |
| `flutter test test/features/activities/rich_closed_exercise_page_test.dart --plain-name "page affiche un timeout actionnable au chargement trop long"` | PASS. |
| `flutter test test/features/activities/rich_closed_exercise_page_test.dart` | PASS, 20 tests. |
| `flutter test test/features/courses/revisions_pending_page_test.dart` | PASS, 3 tests. |
| `flutter test test/features/courses/course_detail_page_test.dart` | PASS, 33 tests. |
| `flutter test test/app/router/app_router_test.dart` | PASS, 23 tests. |
| `flutter test test/app/revision_app_test.dart` | PASS, 12 tests. |
| `flutter test --update-goldens test/features/activities/v5_02_visual_evidence_test.dart` | PASS, captures after regenerees en 390 x 844 dark mode. Le fichier de test etait temporaire et a ete supprime. |
| `flutter analyze` | ECHEC OUTIL : crash de l'analysis server, `FormatException: Unexpected end of input`, crash log `flutter_26.log`. Aucun diagnostic projet exploitable n'a ete produit. |
| `/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin/dart analyze lib/presentation/pages/activities/activities_page.dart lib/presentation/pages/activities/rich_closed_exercise_page.dart lib/features/courses/presentation/revisions_pending_page.dart lib/features/courses/presentation/sources_pending_page.dart test/features/activities/activities_page_test.dart test/features/activities/rich_closed_exercise_page_test.dart test/features/courses/revisions_pending_page_test.dart test/app/router/app_router_test.dart` | PASS, `No issues found!` apres suppression d'un import inutilise dans `app_router_test.dart`. |
| `flutter test test/app/router/app_router_test.dart` | PASS, 23 tests apres suppression de l'import inutilise. |
| `git diff --check` | PASS, aucun whitespace error. |
| `git status --short` | OK, uniquement fichiers du lot V5-02 et captures evidence. |
| `NERALUNE_BASE_URL='http://127.0.0.1:52422/' NERALUNE_AUDIT_OUT='output/visual-qa/v5/V5-02/playwright' NERALUNE_EMAIL='yoahn.l@me.com' NERALUNE_PASSWORD='***' npx -y -p playwright node output/product-audit/neralune-full-app-2026-06-27/mobile_dark_audit_runner.mjs` | ECHEC OUTIL : `ERR_MODULE_NOT_FOUND` pour le package `playwright` avec Node 26 et module ESM. |
| `NODE_PATH='.../node_modules' ... node output/product-audit/.../mobile_dark_audit_runner.mjs` | ECHEC OUTIL : ESM ne resolvait pas `NODE_PATH` pour `playwright`. |
| `NODE_PATH='.../node_modules' ... node <runner CommonJS inline>` | PARTIEL puis non retenu : Chrome systeme a ete pilote, mais les relances Flutter Web debug ont produit des captures blanches ; logs : DDC chargeait les scripts, `body.innerText` restait vide apres 25 s. |

## 10. Compte de test

Compte de test utilise pour les tentatives Playwright :

```text
yoahn.l@me.com
```

Mot de passe utilise uniquement via variable d'environnement locale. Mot de passe non stocke, non commite, non affiche dans ce pack.

## 11. Non-objectifs respectes

- Pas de backend modifie.
- Pas de Prisma modifie.
- Pas de Genkit modifie.
- Pas de GenUI modifie.
- Pas de nouvelle dependance.
- Pas de modification `pubspec.yaml`.
- Pas de modification `pubspec.lock`.
- Pas de catalogue global de sources.
- Pas de refonte Today.
- Pas de refonte Cours.
- Pas de refonte Detail cours.
- Pas de refonte session question, feedback ou bilan.
- Pas de Study Session V4 complete.
- Pas de route `/study-sessions`.
- Aucun commit, merge, rebase, tag ou push effectue.

## 12. Risques restants

- Les routes legacy restent accessibles pour compatibilite ; elles sont stabilisees mais ne doivent pas redevenir le flow principal.
- Playwright Flutter Web debug est instable en headless sur cette session ; les captures finales after viennent donc d'un harness Flutter widget controle.
- Certains modes restent visibles comme secondaires (`Revision approfondie`, `Preparation examen - QCM`) mais avec etat `Bientot` ou preconditions.
- V5-03 doit encore humaniser les sources, PDF et notions.
- V5-04 doit encore refaire `Aujourd'hui` en cockpit coach.
- V5-07/V5-08 traiteront la boucle de revision visuelle cible.

## 13. Verdict visuel

```text
VALIDÉ
```

Justification :

- captures `before`, `after` et `target` presentes ;
- captures `after` en mobile dark 390 x 844 ;
- `Activites` sans contexte n'affiche plus une grille morte ;
- `Activites` et `QCM complet` disposent d'un timeout visible ;
- `Reviser` et `Sources` proposent une action utile ;
- aucun jargon technique n'est visible dans les etats ajoutes.

## 14. Prochain lot recommande

```text
V5-03 — Humanisation sources / PDF / notions
```
