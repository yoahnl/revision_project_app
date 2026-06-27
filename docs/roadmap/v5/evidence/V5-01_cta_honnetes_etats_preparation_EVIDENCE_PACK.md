# V5-01 — CTA honnetes + etats de preparation — Evidence Pack

## 1. Objectif

Objectif du lot :

```text
Aucun bouton principal ne doit promettre une revision qui ne peut pas demarrer.
```

Phrase produit verifiee :

```text
Quand Neralune dit "Commencer", soit la session demarre, soit l'app explique clairement ce qui se prepare et propose une action utile.
```

Le lot reste volontairement front-only et cible uniquement le P0 de revision rapide.

## 2. Maquette utilisee

Maquette principale fournie :

```text
/Users/karim/Downloads/ChatGPT Image Jun 25, 2026, 10_54_01 PM.png
```

Copie stable dans le repo :

```text
docs/roadmap/v5/evidence/screenshots/V5-01/target/mockup-reference.png
```

Ecrans de reference utilises :

- Ecran 4, `Detail cours` : actions bas d'ecran, parcours, indicateur de progression.
- Ecran 6, `Reviser (choix duree)` : action primaire seulement quand le demarrage est possible.
- Ecran 8, `Feedback (reponse)` : langage clair, etat pedagogique, pas de jargon technique.
- Ecran 3, `Cours` et ecran 10, `Progres` : style dark premium, cartes lisibles, statut explicite.

Remarque : V5-01 n'est pas un lot de refonte visuelle. La maquette sert ici a cadrer l'honnetete du CTA, la clarte de l'etat et le fallback vers la fiche, pas a refaire tous les ecrans.

## 3. Rappel du probleme P0

Probleme issu de l'audit :

```text
La revision rapide annonce "Commencer 5 questions", mais l'API peut repondre 409 COURSE_QUICK_REVISION_QUESTIONS_PREPARING sans feedback visible.
```

Effets utilisateur avant ce lot :

- le bouton principal promet une session ;
- l'etat loading peut se fermer sans explication stable ;
- le jargon technique peut rester la seule information exploitable cote dev ;
- l'utilisateur ne sait pas quoi faire pendant que les questions sont preparees.

## 4. Resume des changements

- Le lanceur quick revision intercepte maintenant `COURSE_QUICK_REVISION_QUESTIONS_PREPARING`.
- Le snackbar d'erreur est remplace par une bottom sheet stable `Questions en preparation`.
- La bottom sheet propose `Lire la fiche` et `Voir le parcours` pour l'etat preparation.
- Les erreurs temporaires inconnues affichent `Session indisponible`, avec `Reessayer`, `Lire la fiche` et `Voir le parcours`.
- Le detail cours lit l'etat `courseQuestionBankReadinessProvider(... questionCount: 10)`.
- Quand moins de cinq questions sont pretes et que l'etat est `preparing`, le CTA principal devient `Lire la fiche` au lieu de `Reviser ce cours`.
- Un guard `context.mounted` a ete ajoute avant d'ouvrir le choix duree apres une attente async.
- Les tests couvrent le detail cours, la page Reviser, le cas nominal ready et l'absence de jargon technique.

## 5. Fichiers modifies

Code Flutter :

- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_quick_revision_launcher.dart`

Tests :

- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/revisions_pending_page_test.dart`

Documentation :

- `docs/roadmap/v5/EXECUTION_TRACKER_V5.md`

Fichiers crees :

- `docs/roadmap/v5/evidence/V5-01_cta_honnetes_etats_preparation_EVIDENCE_PACK.md`
- `docs/roadmap/v5/evidence/screenshots/V5-01/before/course-detail-cta.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/before/duration-picker-or-reviser.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/course-detail-preparing.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/questions-preparing-message.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/fallback-read-sheet.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/revision-hub-preparing-message.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/session-ready-if-reproducible.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/target/mockup-reference.png`

## 6. Etats couverts

| Etat | Surface | Comportement valide |
|---|---|---|
| Source prete | Detail cours, Reviser | La fiche et le parcours restent accessibles. |
| Fiche prete | Bottom sheet fallback | `Lire la fiche` est propose comme action principale quand les questions ne sont pas pretes. |
| Notions pretes | Detail cours | Le parcours reste visible et l'action `Comprendre` reste disponible. |
| Questions en preparation | Detail cours, choix duree, Reviser | `Questions en preparation` est visible, sans code `409` ni code backend. |
| Session prete | Detail cours, Reviser | Le cas nominal conserve `Reviser ce cours`, `Commencer` ou `Commencer 5 questions` et les tests de session passent. |
| Erreur temporaire | Quick launcher | `Session indisponible`, `Reessayer`, `Lire la fiche`, `Voir le parcours`. |
| Fallback fiche | Detail cours, bottom sheet | Navigation vers `AppRoutes.courseSheet(courseId)`. |
| Fallback parcours | Bottom sheet | Navigation vers `AppRoutes.course(courseId)`. |

## 7. Captures visuelles

Viewport :

```text
390 x 844
dark mode
```

Captures before :

- `docs/roadmap/v5/evidence/screenshots/V5-01/before/course-detail-cta.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/before/duration-picker-or-reviser.png`

Captures after :

- `docs/roadmap/v5/evidence/screenshots/V5-01/after/course-detail-preparing.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/questions-preparing-message.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/fallback-read-sheet.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/revision-hub-preparing-message.png`
- `docs/roadmap/v5/evidence/screenshots/V5-01/after/session-ready-if-reproducible.png`

Capture target :

- `docs/roadmap/v5/evidence/screenshots/V5-01/target/mockup-reference.png`

Notes de production :

- Les captures `before` viennent de l'audit mobile dark du 27 juin 2026.
- Les captures `after/course-detail-preparing.png`, `after/questions-preparing-message.png`, `after/fallback-read-sheet.png` et `after/revision-hub-preparing-message.png` ont ete generees via un harness widget temporaire en dark mode, puis le harness a ete supprime.
- La capture `after/session-ready-if-reproducible.png` archive le cas nominal ready existant depuis l'audit : `Commencer 5 questions` reste disponible quand la session peut etre lancee. Ce lot ne refait pas la session.

Dimensions verifiees :

```text
after/course-detail-preparing.png: 390 x 844
after/fallback-read-sheet.png: 390 x 844
after/questions-preparing-message.png: 390 x 844
after/revision-hub-preparing-message.png: 390 x 844
after/session-ready-if-reproducible.png: 390 x 844
before/course-detail-cta.png: 390 x 844
before/duration-picker-or-reviser.png: 390 x 844
target/mockup-reference.png: 1672 x 941
```

## 8. Comparaison avec la maquette

| Surface | Maquette cible | Avant | Apres | Ecart restant | Verdict |
|---|---|---|---|---|---|
| Detail cours | Ecran 4 : action principale contextualisee, parcours visible, progression claire. | Le CTA `Reviser ce cours` pouvait rester primaire meme si les questions n'etaient pas pretes. | Badge `Questions en preparation`, CTA principal `Lire la fiche`, action secondaire `Comprendre`, parcours conserve. | Le detail cours n'est pas encore totalement gamifie comme la maquette ; ce sera V5-05. | VALIDE pour V5-01 |
| Choix duree | Ecran 6 : l'utilisateur choisit une duree seulement si le flow gere l'issue. | Le demarrage pouvait echouer avec un 409 silencieux apres `Commencer`. | Le loading se ferme, puis une sheet stable explique `Questions en preparation`. | Le choix duree n'est pas encore visuellement aligne a 100 % ; V5-07 reste dedie. | VALIDE pour V5-01 |
| Etat session non prete | Maquette : etat clair, rassurant, action utile. | Erreur metier invisible ou insuffisamment actionnable. | Bottom sheet : message clair, `Lire la fiche`, `Voir le parcours`, absence de `409`, `backend`, `payload`, `questionCount`. | Pas de planification temporelle fine ; le contrat API ne donne pas toujours l'etat avant tentative. | VALIDE |
| Session ready | Maquette : `Commencer` reste un CTA primaire quand le lancement est reel. | Le cas ready existait deja. | Tests ready conserves ; capture ready archivee avec `Commencer 5 questions`. | Pas de refonte session, hors scope V5-01. | VALIDE |

## 9. Tests executes

| Commande | Resultat |
|---|---|
| `flutter test test/features/courses/course_detail_page_test.dart --plain-name "quick revision preparing error shows stable fallbacks without technical jargon"` | RED d'abord : le test ne trouvait pas `Questions en preparation`; GREEN apres implementation. |
| `flutter test test/features/courses/course_detail_page_test.dart --plain-name "course detail prioritizes reading the sheet when questions are preparing"` | RED d'abord : le CTA `Reviser ce cours` restait visible; GREEN apres implementation. |
| `flutter test --update-goldens test/features/courses/v5_01_visual_evidence_test.dart` | PASS, 3 tests, captures after regenerees en 390 x 844 dark mode. Le fichier de test etait temporaire et a ete supprime. |
| `flutter test test/features/courses/course_detail_page_test.dart` | PASS, 33 tests. |
| `flutter test test/features/courses/revisions_pending_page_test.dart` | PASS, 3 tests. |
| `flutter test test/features/revision_sessions/quick_revision_quiz_flow_test.dart` | PASS, 5 tests. |
| `flutter test test/features/revision_sessions/revision_session_page_test.dart` | PASS, 20 tests. |
| `flutter test test/app/router/app_router_test.dart` | PASS, 23 tests. |
| `flutter test test/app/revision_app_test.dart` | PASS, 12 tests. |
| `flutter analyze` | ECHEC OUTIL : crash de l'analysis server, `FormatException: Unexpected end of input`, crash log `flutter_25.log`. Aucun diagnostic projet n'a ete produit par Flutter. |
| `/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin/dart analyze` | ECHEC non exploitable en analyse globale : le dossier `build/ios/SourcePackages/firebase_auth-6.5.2/example` et `build/macos/...` est analyse et remonte des erreurs externes de dependances d'exemple. |
| `/opt/homebrew/share/flutter/bin/cache/dart-sdk/bin/dart analyze lib/features/courses/presentation/course_detail_page.dart lib/features/courses/presentation/course_quick_revision_launcher.dart test/features/courses/course_detail_page_test.dart test/features/courses/revisions_pending_page_test.dart` | PASS, `No issues found!` apres correction du guard `context.mounted`. |

Note : une tentative parallele Flutter anterieure a produit un crash de copie `NativeAssetsManifest.json`. Les tests ont ensuite ete relances sequentiellement avec succes.

## 10. Non-objectifs respectes

- Pas de backend modifie.
- Pas de Prisma modifie.
- Pas de Genkit modifie.
- Pas de GenUI modifie.
- Pas de nouvelle dependance.
- Pas de modification `pubspec.yaml`.
- Pas de modification `pubspec.lock`.
- Pas de refonte globale de Today.
- Pas de refonte globale de Cours.
- Pas de refonte de la session question.
- Pas de refonte feedback.
- Pas de refonte bilan.
- Pas de Study Session V4 complete.
- Pas de route `/study-sessions`.
- Pas de fake data ajoutee.
- Aucun commit, merge, rebase, tag ou push effectue.

## 11. Risques restants

- L'etat reel peut rester partiellement deduit si le contrat API ne l'expose pas avant tentative ; le fallback sur l'erreur metier reste donc indispensable.
- La vraie planification temporelle reste hors scope : `5 / 15 / 30 min` mappe encore vers des volumes internes.
- Today coach complet reste V5-04.
- Anti-spinner global reste V5-02.
- Le detail cours n'est pas encore pleinement aligne a la maquette parcours gamifie ; V5-05 couvre ce sujet.
- La fiche premium actionnable reste V5-06.

## 12. Verdict visuel

```text
VALIDÉ
```

Justification :

- captures `before`, `after` et `target` presentes ;
- captures mobile dark 390 x 844 verifiees ;
- l'etat `Questions en preparation` est visible ;
- le fallback `Lire la fiche` est principal quand la revision ne peut pas demarrer ;
- le fallback `Voir le parcours` existe ;
- aucun jargon technique n'est visible dans les tests d'UI.

## 13. Prochain lot recommande

```text
V5-02 — Anti-spinner + surfaces legacy
```
