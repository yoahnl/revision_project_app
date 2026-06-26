# V4-03A — Cours V4 frontend — Evidence Pack

## 1. Objectif

Transformer l'onglet `Cours` en bibliotheque V4 compacte, premium et data-driven, proche de la reference mobile, sans backend nouveau et sans fausse donnee.

## 2. Reference visuelle

La reference montre un ecran mobile sombre avec header `Cours`, bouton `+`, selector matiere, resume court, hero card `Reviser toute la matiere`, liste compacte de cours et rings de progression.

Le lot reprend la hierarchie, le selector, la hero card, la liste compacte et la silhouette Luna discrete, sans copier les chiffres fictifs.

## 3. Resume des changements

- Recomposition de `CoursesHomePage` avec `RevisionPageScaffold`.
- Header `Cours` avec bouton `+` en haut a droite.
- Bouton `+` branche sur creation de cours si une matiere existe, sinon creation de matiere.
- Selector matiere conserve avec bottom sheet existante.
- Resume matiere base sur `courses.length` et `course.progress?.knowledgeUnitCount`.
- Hero card V4 `Reviser cette matiere`, avec silhouette Luna via asset existant.
- CTA hero `Commencer` qui ouvre le cours prioritaire existant.
- Liste de cours compacte avec titre, statut lisible, ring uniquement si `CourseProgress` existe.
- Empty states sans matiere et sans cours reecrits.
- Tests dedies `CoursesHomePage` crees.

## 4. Fichiers modifies

- `lib/features/courses/presentation/courses_home_page.dart`
- `test/features/courses/courses_home_page_test.dart`
- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/V4-03A_cours_v4_frontend_EVIDENCE_PACK.md`

## 5. Comportement utilisateur obtenu

- Header `Cours`.
- Bouton `+`.
- Subject selector avec bottom sheet matiere.
- Resume matiere honnete : nombre reel de cours, notions seulement si calculees depuis `CourseProgress`.
- Hero card V4 avec CTA clair.
- Liste compacte des cours.
- Empty states :
  - aucun sujet : `Cree ta premiere matiere`;
  - sujet sans cours : `Aucun cours pour le moment`.
- No fake data : pas de faux `28 notions`, pas de faux `12 min`, pas de faux pourcentage.
- No backend : aucun endpoint, contrat API ou repository backend modifie.

## 6. Donnees utilisees et donnees masquees

Donnees utilisees :

- `subjectsNotifierProvider` pour les matieres.
- `activeSubjectIdProvider` pour la matiere active.
- `coursesProvider(subject.id)` pour les cours.
- `courses.length` pour le nombre de cours.
- `course.progress?.knowledgeUnitCount` pour les notions quand disponible.
- `course.progress?.estimatedGlobalMastery` pour le ring et le pourcentage.
- `course.progress?.practicedKnowledgeUnitCount` pour le libelle compact de progression.
- `sourceCount`, `readySourceCount`, `processingSourceCount` pour les statuts sans progression.

Donnees masquees faute de source fiable :

- duree subject-level ;
- nombre de questions ;
- vraie session matiere ;
- progression semaine ;
- solides/a renforcer par notion lorsque le backend ne fournit pas `CourseProgress`.

## 7. Action de la hero card

Le bouton affiche `Commencer`.

Il ouvre le cours prioritaire via `AppRoutes.course(priorityCourse.id)`.

Le comportement est honnete parce que le backend ne fournit pas encore de vraie session matiere V4. La carte dit donc `Reviser cette matiere` et precise `On commence par <cours prioritaire>`, au lieu de promettre une revision de toute la matiere.

Le cours prioritaire est choisi simplement :

1. cours avec source prete et progression la plus basse ;
2. sinon premier cours avec source prete ;
3. sinon premier cours.

`V4-03B` devra renforcer le selector/action matiere. `V4-05A` devra apporter le duration picker.

## 8. Tests executes

| Commande | Resultat | Notes |
| --- | --- | --- |
| `flutter test test/features/courses/courses_home_page_test.dart` | PASS — 3 tests | Couvre data, picker matiere, bouton `+`, hero, CTA, empty states, no fake data. |
| `flutter test test/app/revision_app_test.dart` | PASS — 11 tests | Confirme navigation V4 et scenarios app existants apres refonte Cours. |
| `flutter test test/app/router/app_router_test.dart` | PASS — 23 tests | Confirme routes legacy et home route sans fixture fallback. |
| `flutter analyze` | FAIL — analysis server crash | Crash outil connu : `FormatException: Unexpected end of input`, analysis server exit code 255, rapport `flutter_08.log`. Aucun diagnostic projet exploitable n'a ete emis. |
| `git diff --check` | PASS | Aucun probleme whitespace detecte. |
| `git status --short` | PASS — perimetre attendu | Modifications limitees a Cours frontend, tests app/router/cours et docs V4. |

## 9. Captures / verifications manuelles

Verification mobile par comparaison avec l'image fournie :

- header `Cours` + bouton rond `+` ;
- selector matiere sous le header ;
- resume court ;
- hero card sombre/violette avec CTA clair ;
- liste compacte ;
- bottom nav conservee hors page.

Aucune capture finale automatisee n'a ete produite dans ce lot.

## 10. Decisions prises

- Hero card en option navigation fiable : elle ouvre le cours prioritaire, pas une session matiere fictive.
- Pas de `12 min` ni nombre de questions, car non disponibles pour une matiere.
- Pas de ring si `CourseProgress` est absent.
- Utilisation de la silhouette Luna via `neralune_cat.svg` en faible opacite, sans nouvel asset ni animation.
- Conservation du subject picker existant.
- Conservation des sheets de creation existantes.

## 11. Risques restants

- La revision subject-level n'est pas encore reelle.
- Le duration picker n'est pas disponible.
- Le learning path n'est pas inclus.
- Les donnees `solides` / `a renforcer` dependent du contrat `CourseProgress` existant.
- Les notions ne sont affichees que lorsque `CourseProgress` les expose.

## 12. Autocritique finale

Le lot rapproche nettement `Cours` de la reference sans inventer de metriques. La limite principale est assumee : la hero card est une entree vers un cours prioritaire, pas une vraie session matiere. La prochaine iteration doit traiter explicitement l'action matiere et le selector plus avance.

## 13. Prochain lot recommande

`V4-03B — Sélecteur matière et action “Réviser toute la matière”`
