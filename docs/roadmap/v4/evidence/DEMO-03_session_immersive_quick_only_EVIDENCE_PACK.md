# DEMO-03 — Session immersive quick-only — Evidence Pack

## 1. Objectif

Livrer une session courte montrable pour le MVP demo : une question visible a la fois, sans bottom navigation, sans dashboard technique et sans creer de nouveau backend.

## 2. Reference visuelle

Reference utilisee : montage mobile V4 Neralune du 25 juin 2026, en particulier les ecrans `Session (question)` et la direction sombre premium avec progression courte, choix lisibles et action principale claire.

## 3. Resume des changements

- `QuickRevisionQuizFlow` devient un ecran immersif centre sur la question courante.
- Ajout d'un top bar compact `Session courte`, sous-titre cours, compteur `x / y` et barre de progression.
- Suppression de la grosse carte header de session dans le flux quick.
- Ajout d'une transition douce entre les questions via `AnimatedSwitcher`.
- Conservation des mecanismes existants : brouillon, signalement, submit diagnostic, completion session, route resultat.
- Ajout d'un test dedie au flux quick-only.

## 4. Fichiers modifies

- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`
- `test/features/revision_sessions/quick_revision_quiz_flow_test.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/DEMO-03_session_immersive_quick_only_EVIDENCE_PACK.md`

## 5. Comportement utilisateur obtenu

- Une seule question est visible a la fois.
- La session n'affiche pas la bottom navigation `Aujourd'hui / Cours / Progres`.
- Le wording utilisateur visible privilegie `Session courte`, `Suivant`, `Terminer`, `Précédent`, `Signaler`.
- Les reponses restent de grandes zones tactiles, avec selection claire et sans feedback rouge/vert premature.
- La sortie ouvre une confirmation : `Quitter la session ?`.
- Les reponses selectionnees sont sauvegardees en brouillon via le controleur existant.
- La finalisation route vers le resultat existant `AppRoutes.revisionSessionResultV2`.

## 6. Donnees et moteur utilises

- Moteur conserve : diagnostic quick existant.
- Donnees conservees : `RevisionSessionResponse`, `DiagnosticQuizActivity`, `draftAnswers`, `flagQuestion`, `submitResult`, `completeSession`.
- Aucun nouveau backend.
- Aucune route `/study-sessions`.
- Aucun changement Prisma.
- Aucun changement GenUI.
- Aucun asset modifie.

## 7. Tests executes

| Commande | Resultat |
| --- | --- |
| `flutter test test/features/revision_sessions/quick_revision_quiz_flow_test.dart` | Passe, 5 tests. |
| `flutter test test/features/courses/course_detail_page_test.dart` | Passe, 31 tests. |
| `flutter test test/app/router/app_router_test.dart` | Passe, 23 tests. |
| `flutter test test/app/revision_app_test.dart` | Passe, 12 tests. |
| `flutter test test/features/revision_sessions/revision_session_page_test.dart` | Passe, 20 tests. Test supplementaire execute car une attente quick a ete alignee sur `Session courte`. |
| `flutter analyze` | Echec outil : crash analysis server `FormatException: Unexpected end of input`; rapport genere `flutter_21.log`. Meme famille de crash deja observee, pas un diagnostic lint du lot. |
| `git diff --check` | Passe, aucune erreur whitespace. |
| `git status --short` | Modifications attendues uniquement : quick flow, tests, tracker, evidence pack. |

## 8. Captures / verifications manuelles

Verification par tests widget/router :

- absence de bottom nav pendant la session ;
- absence de termes techniques interdits dans le flux quick ;
- affichage question par question ;
- sortie confirmee ;
- erreur de soumission non destructive ;
- navigation resultat existante.

Pas de capture supplementaire generee dans ce lot.

## 9. Decisions prises

- Utiliser le libelle produit `Session courte` plutot que `Révision rapide` dans le flux quick immersif.
- Garder `Précédent` visible pour la demo afin de ne pas bloquer l'utilisateur qui veut corriger une reponse avant soumission.
- Ne pas ajouter de feedback immediat dans DEMO-03 pour eviter de chevaucher DEMO-04.
- Ne pas creer de facade `/study-sessions` : le quick engine reste interne.

## 10. Risques restants

- La session demo reste quick-only et ne represente pas encore la future facade Study Session V4.
- La duree 5/15/30 reste mappee indirectement au nombre de questions.
- Le feedback immediat et le bilan propre restent a livrer dans DEMO-04.
- `flutter analyze` reste bloque par un crash de l'analysis server dans cet environnement.

## 11. Autocritique finale

Le lot ameliore fortement la perception de session immersive sans casser la mecanique existante. Il reste volontairement prudent : pas de nouveau moteur, pas de feedback premature, pas de planner local. Le principal compromis est que l'UX est plus V4 que le contrat sous-jacent, qui reste le moteur quick legacy masque.

## 12. Prochain lot recommande

`DEMO-04 — Feedback + bilan propre`
