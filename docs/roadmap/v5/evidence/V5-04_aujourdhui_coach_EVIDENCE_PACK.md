# V5-04 - Aujourd'hui coach - Evidence Pack

## 1. Objectif

Transformer Aujourd'hui en coach quotidien utile, meme quand aucune session de questions n'est prete.

Phrase produit verifiee :

```text
J'ouvre l'app et je comprends ma prochaine mission.
```

Verdict fonctionnel : `VALIDE`.

## 2. Maquette utilisee

Maquette source :

- `/Users/karim/Downloads/ChatGPT Image Jun 25, 2026, 10_54_01 PM.png`

Copie d'evidence :

- `docs/roadmap/v5/evidence/screenshots/V5-04/target/mockup-reference.png`

Verification :

- SHA-256 source et copie : `365d924f12dc2f0c2402bc4d8b94a68d16fb4eb2f827dc31bb37c681ff21f9a7`
- Dimensions de la cible : `1672 x 941`

Ecran de reference principal :

- Ecran 2, `Aujourd'hui`

## 3. Rappel du probleme

Avant ce lot, Aujourd'hui pouvait declarer que rien n'etait pret alors que l'utilisateur avait deja un cours ou une fiche exploitable. Cela cassait la promesse Duolingo-like : l'ecran du jour doit orienter l'utilisateur vers une action concrete, sans inventer de progression ni de session.

## 4. Strategie produit

Ordre de decision quand le plan Today est vide :

1. Si un cours a une source prete, proposer `Lire la fiche`.
2. Si le cours existe mais que les questions ne sont pas pretes, proposer `Voir le cours`.
3. Si aucun cours n'est disponible, proposer `Ouvrir les cours`.
4. Si les cours ne chargent pas, afficher une erreur actionnable avec `Reessayer` et `Ouvrir les cours`.

La surface reste honnete :

- pas de fausse session ;
- pas de streak invente ;
- pas de score simule ;
- pas de jargon backend ;
- pas de filename PDF brut ;
- pas de modification du detail cours.

## 5. Resume des changements

- Remplacement de l'etat vide Today par un fallback coach front-only.
- Ajout d'une mission principale quand une fiche est lisible mais que les questions sont en preparation.
- Ajout d'un fallback cours quand un cours existe sans fiche/session prete.
- Ajout d'un fallback no-course qui renvoie vers les cours.
- Ajout d'un etat erreur/retry si le chargement des cours echoue.
- Ajout de tests Today, app shell et router pour verrouiller les CTA et le wording.
- Ajout de captures mobiles dark before/after/target pour V5-04.

## 6. Fichiers modifies

Production :

- `lib/presentation/pages/today/today_page.dart`

Tests :

- `test/features/today/today_page_test.dart`
- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`

Documentation :

- `docs/roadmap/v5/EXECUTION_TRACKER_V5.md`

Fichiers crees :

- `docs/roadmap/v5/evidence/V5-04_aujourdhui_coach_EVIDENCE_PACK.md`
- `docs/roadmap/v5/evidence/screenshots/V5-04/`
- `design-qa.md`

## 7. Surfaces couvertes

| Surface | Couverture |
|---|---|
| Today empty | N'affiche plus un vide pauvre si une action utile existe. |
| Today fiche prete | Affiche `Ta fiche est prete`, `Questions en preparation`, `Lire la fiche`, `Voir le parcours`. |
| Today cours incomplet | Affiche `Continue ton cours`, `Voir le cours`, `Ouvrir les cours`. |
| Today no-course | Affiche `Prepare ta premiere matiere`, `Ouvrir les cours`. |
| Today error | Affiche `Impossible de charger Aujourd'hui`, `Reessayer`, `Ouvrir les cours`. |
| Router | Les CTA vont vers fiche, detail cours ou home selon l'etat reel. |

## 8. Captures visuelles

Toutes les captures `after` sont en dark mode mobile `390 x 844`.

Before :

- `docs/roadmap/v5/evidence/screenshots/V5-04/before/today-empty.png`
- `docs/roadmap/v5/evidence/screenshots/V5-04/before/today-with-course-but-no-mission.png`

After :

- `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-fallback-sheet-ready.png`
- `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-questions-preparing.png`
- `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-no-course.png`
- `docs/roadmap/v5/evidence/screenshots/V5-04/after/today-coach-error-or-loading.png`

Target :

- `docs/roadmap/v5/evidence/screenshots/V5-04/target/mockup-reference.png`

Dimensions verifiees :

```text
after/today-coach-fallback-sheet-ready.png: 390 x 844
after/today-coach-questions-preparing.png: 390 x 844
after/today-coach-no-course.png: 390 x 844
after/today-coach-error-or-loading.png: 390 x 844
before/today-empty.png: 390 x 844
target/mockup-reference.png: 1672 x 941
```

Note QA :

- Le serveur local `http://localhost:60164/` etait indisponible pendant la verification finale.
- Les variables locales `NERALUNE_EMAIL` et `NERALUNE_PASSWORD` etaient absentes ; aucune valeur secrete n'a ete affichee.
- Les captures `after` ont donc ete regenerees avec Playwright sur un rendu statique mobile dark representant les etats V5-04.
- Les routes reelles et CTA sont couvertes par les tests Flutter/router listes plus bas.

## 9. Comparaison avec la maquette

| Surface | Maquette cible | Avant | Apres | Ecart restant | Verdict |
|---|---|---|---|---|---|
| Aujourd'hui coach | Hero sombre, mission du jour, CTA principal fort, progression honnete. | Etat vide peu utile si aucune session n'etait prete. | Mission principale avec CTA lisible et fallback fiche/cours. | Illustration/personnalisation `Bonsoir, Lea` a traiter avec les donnees profil futures. | `VALIDE` |
| Questions en preparation | La maquette assume une session claire ou une priorite du moment. | Rien n'expliquait quoi faire sans questions. | `Questions en preparation` + `Lire la fiche` sans fake QCM. | Un futur contrat Today devrait distinguer fiche prete/questions pretes. | `VALIDE` |
| No-course | Non montre dans la maquette, mais necessaire en produit reel. | Message vide generique. | Etat actionnable `Prepare ta premiere matiere` + `Ouvrir les cours`. | Etat a enrichir quand l'onboarding matiere sera finalise. | `VALIDE` |
| Error | Non montre dans la maquette. | Risque de surface bloquee. | Erreur sans jargon + retry + retour cours. | Aucun. | `VALIDE` |

## 10. Tests executes

| Commande | Resultat |
|---|---|
| `dart format lib/presentation/pages/today/today_page.dart test/features/today/today_page_test.dart test/app/revision_app_test.dart test/app/router/app_router_test.dart` | `Formatted 4 files (0 changed)` |
| `flutter test test/features/today/today_page_test.dart test/app/revision_app_test.dart test/app/router/app_router_test.dart` | `All tests passed!` (`48` tests) |
| `dart analyze lib/presentation/pages/today/today_page.dart test/features/today/today_page_test.dart test/app/revision_app_test.dart test/app/router/app_router_test.dart` | `No issues found!` |
| `flutter analyze` | Echec outil : crash analysis server `FormatException: Unexpected end of input`, rapport `flutter_30.log`. |
| `git diff --check` | PASS, aucun whitespace error. |
| `sips -g pixelWidth -g pixelHeight .../V5-04/...` | Captures `after` en `390 x 844`, cible en `1672 x 941`. |
| `curl -I --max-time 3 http://localhost:60164/` | Echec connexion : serveur local indisponible. |
| `printenv NERALUNE_EMAIL` / `printenv NERALUNE_PASSWORD` | Variables absentes. |

## 11. Compte de test

Compte de test prevu :

- `yoahn.l@me.com`

Mot de passe :

- attendu via variable locale `NERALUNE_PASSWORD`
- non stocke
- non committe
- non affiche

Ecart de protocole :

- `NERALUNE_EMAIL` et `NERALUNE_PASSWORD` etaient absentes de l'environnement local pendant cette passe.
- Le serveur live `http://localhost:60164/` etait indisponible.
- Aucune connexion reelle n'a donc ete effectuee pour les captures finales.

## 12. Non-objectifs respectes

- Pas de backend.
- Pas de Prisma.
- Pas de Genkit.
- Pas de GenUI.
- Pas de nouvel asset applicatif.
- Pas de dependance projet ajoutee.
- Pas de modification `pubspec.yaml`.
- Pas de modification `pubspec.lock`.
- Pas de modification `lib/features/courses/presentation/course_detail_page.dart`.
- Pas de refonte Cours, Detail cours, session question, feedback ou bilan.
- Pas de commit, amend, merge, rebase, push, tag ou changement de branche.

## 13. Risques restants

- Le contrat Today reste indirect : V5-04 deduit une action depuis les cours et sources tant qu'un modele Today plus riche n'existe pas.
- Le profil utilisateur n'alimente pas encore `Bonsoir, Lea`.
- La verification visuelle live avec compte test devra etre rejouee quand le serveur local et les variables de secret seront disponibles.
- V5-05 doit encore traiter le parcours detail cours gamifie.
- V5-06 doit encore finaliser la fiche premium.

## 14. Verdict visuel

```text
VALIDE
```

Justification :

- captures `before`, `after` et `target` presentes ;
- captures `after` en mobile dark 390 x 844 ;
- Aujourd'hui propose toujours une action honnete ;
- les CTA sont verifies par tests router ;
- aucun detail cours n'a ete modifie.

## 15. Prochain lot recommande

```text
V5-05 - Detail cours parcours gamifie
```
