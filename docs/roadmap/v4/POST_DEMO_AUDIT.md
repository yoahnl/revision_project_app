# POST-DEMO-01 — Audit démo et stabilisation post-MVP

## 1. Résumé exécutif

Verdict : `READY_WITH_MINOR_RESERVATIONS`.

Le couloir MVP démo peut être montré en revue manuelle. Les écrans et routes du flow canonique sont présents, les tests ciblés passent, la navigation principale reste limitée à `Aujourd'hui`, `Cours`, `Progrès`, et la session quick/resultat restent hors shell.

Les réserves sont mineures et connues : la durée reste mappée au moteur quick existant, le feedback immédiat entre les questions n'est pas encore livré, les modes/historiques legacy restent accessibles depuis le menu secondaire, et `flutter analyze` échoue sur un crash analysis server déjà observé.

## 2. Flow audité

Flow audité :

```text
Aujourd'hui → Cours → Détail cours → Durée → Session → Bilan → Retour cours / fiche
```

Ce flow correspond au runbook de démo et au verrou MVP démo. Aucun nouvel écran principal, mode de révision, backend ou contrat de session n'a été ajouté pendant cet audit.

## 3. Grille d’audit UX

| Étape | Statut | Fichiers | Observation | Priorité | Action recommandée |
| --- | --- | --- | --- | --- | --- |
| 1. Arrivée sur Aujourd'hui | OK | `today_page.dart`, `revision_home_shell.dart`, `app_router.dart` | L'app s'ouvre sur Today, avec action principale et profil secondaire. | P2 | Revue manuelle mobile/desktop avant présentation. |
| 2. Compréhension de l'action principale | OK | `today_page.dart`, `today_page_test.dart` | Le wording reste produit : `Ta session du jour`, `Réviser maintenant`, `Changer de cours`. | P2 | Ne pas ajouter de choix de durée sur Today avant un vrai branchement. |
| 3. Accès à Cours | OK | `revision_home_shell.dart`, `courses_home_page.dart` | La bottom nav expose uniquement `Aujourd'hui`, `Cours`, `Progrès`. | P2 | Garder le profil hors onglet principal. |
| 4. Accès au détail cours | OK | `courses_home_page.dart`, `app_router.dart` | Les cartes cours poussent vers `AppRoutes.course(course.id)` sans fixture fallback. | P2 | Valider avec un jeu de données réel avant la démo. |
| 5. Lecture du parcours de notions | OK | `course_detail_page.dart`, `course_models.dart` | Le détail consomme le learning path backend et affiche un état honnête si vide. | P2 | Préparer un cours avec nodes réels pour la démo. |
| 6. Lancement d'une révision | OK | `course_detail_page.dart`, `quick_revision_question_count_sheet.dart` | Le CTA principal ouvre le choix de durée ou reprend une session existante selon l'état. | P2 | Éviter de présenter cela comme une vraie session V4 complète. |
| 7. Choix durée 5 / 15 / 30 | OK | `quick_revision_question_count_sheet.dart` | L'utilisateur voit des durées, pas le champ interne `questionCount`. | P2 | Garder le mapping documenté jusqu'à la future façade session. |
| 8. Session quick immersive | OK | `quick_revision_quiz_flow.dart`, `revision_session_page_test.dart` | Une question à la fois, pas de dashboard, pas de bottom nav. | P2 | Vérifier manuellement le confort de lecture sur petit écran. |
| 9. Réponse à une question | OK | `quick_revision_quiz_flow.dart` | Les réponses sélectionnées restent visibles et les brouillons sont conservés. | P2 | Feedback immédiat à traiter plus tard, hors démo. |
| 10. Fin de session | OK | `quick_revision_quiz_flow.dart`, `app_routes.dart` | La finalisation route vers `AppRoutes.revisionSessionResultV2`. | P2 | Garder le moteur quick interne masqué. |
| 11. Bilan | OK | `revision_session_result_page.dart` | Score secondaire, corrections utiles, Luna statique légère, pas de donnée inventée. | P2 | Revoir le ton après retours utilisateurs. |
| 12. Retour cours / fiche | OK | `revision_session_result_page.dart`, `app_router_test.dart` | `Retour au cours` et `Voir la fiche` utilisent les routes existantes quand `courseId` existe. | P2 | Tester en manuel avec un résultat réel issu du backend. |

## 4. Wording et jargon

Termes techniques cherchés dans le flow démo visible :

```text
MVP, MVP+, backend, legacy, fixture, payload, ActivitySession, QuestionBank,
questionCount, diagnostic_quiz, open_question, rich_closed_exercise, GenUI,
Prisma, mode technique
```

Résultat :

- Aucun terme interdit n'a été identifié comme libellé utilisateur visible dans le couloir démo.
- Des occurrences restent dans le code, les routes, les tests et les mappers internes. Elles sont acceptables car elles ne sont pas exposées dans l'UI utilisateur du flow.
- `questionCount` reste présent dans le nom du fichier historique `quick_revision_question_count_sheet.dart` et dans le mapping interne durée → moteur quick. Le libellé utilisateur reste une durée.
- `Révision rapide` et `QCM complet` existent encore dans des zones avancées/menu legacy, mais les tests du détail cours vérifient que les modes ne polluent plus le flux principal.

Termes corrigés pendant ce lot :

Aucun. Aucune correction code appliquée.

## 5. Navigation et routes

Routes validées :

- `AppRoutes.today`
- `AppRoutes.home`
- `AppRoutes.course(courseId)`
- `AppRoutes.courseSheet(courseId)`
- `AppRoutes.revisionSessionV2(sessionId, courseId)`
- `AppRoutes.revisionSessionResultV2(sessionId, courseId)`
- routes legacy `/profile`, `/revisions`, `/activities`, `/sources` hors shell

Points validés :

- La session ne montre pas `RevisionBottomNavigation` ni `RevisionNavigationRail`.
- Le résultat ne montre pas `RevisionBottomNavigation` ni `RevisionNavigationRail`.
- Le profil reste secondaire et n'est visible que depuis Aujourd'hui.
- Aucun onglet principal `Réviser`, `Profil`, `Sources` ou `Activités` n'est réintroduit.
- Les routes legacy restent accessibles sans redevenir des destinations principales.

Routes à surveiller :

- Les routes legacy de modes avancés restent utiles pour compatibilité, mais ne doivent pas redevenir un flux de démo.
- Le retour fiche dépend de `courseId`; sans `courseId`, le bilan utilise un fallback honnête.

Routes legacy non incluses dans la démo :

- `rich closed`
- `deep revision`
- `exam preparation`
- `sources` globales
- `activities`
- `revisions` legacy

## 6. Luna et identité

Où Luna apparaît dans le couloir démo :

- Aujourd'hui : présence statique dans le header.
- Cours : silhouette discrète dans la hero card.
- Détail cours : présence statique discrète.
- Bilan : présence statique ajoutée par `DEMO-05`.

Pourquoi c'est acceptable :

- Aucun nouvel asset n'a été ajouté.
- La présence reste ponctuelle, pas sur chaque question.
- La session question reste concentrée sur la tâche.
- Aucune animation infinie ne bloque les tests.

Limites :

- Il n'existe pas encore de vrai mascot system.
- La cohérence fine de Luna devra être traitée après retours démo.

Ce qu'il ne faut pas faire avant V1 :

- Ajouter Luna partout.
- Ajouter une animation permanente.
- Générer de nouveaux assets sans direction identité.
- Faire de Luna un écran ou un système à part avant validation produit.

## 7. Tests exécutés

| Commande | Résultat | Remarque |
| --- | --- | --- |
| `flutter test test/features/courses/course_detail_page_test.dart` | OK | 31 tests passent. Détail cours, parcours, durée, menu et routes avancées stables. |
| `flutter test test/features/revision_sessions/quick_revision_quiz_flow_test.dart` | OK | 5 tests passent. Session quick immersive et finalisation stables. |
| `flutter test test/features/revision_sessions/revision_session_page_test.dart` | OK | 20 tests passent. Session V2, quick, brouillons, completion et routes stables. |
| `flutter test test/features/revision_sessions/revision_session_result_page_test.dart` | OK | 9 tests passent. Bilan, corrections, Luna statique, loading/error et actions stables. |
| `flutter test test/app/router/app_router_test.dart` | OK | 23 tests passent. Shell trois onglets, routes legacy, session/result hors shell validés. |
| `flutter test test/app/revision_app_test.dart` | OK | 12 tests passent. App shell, profil secondaire, pages réelles et navigation responsive validés. |
| `flutter analyze` | Échec outil | Crash analysis server : `FormatException: Unexpected end of input`, puis `analysis server exited with code 255`. Rapport `flutter_22.log` généré puis supprimé. |
| `git diff --check` | OK | Aucun whitespace error. |
| `git status --short` | OK | Fichiers attendus uniquement : tracker, audit post-demo et evidence pack. |

## 8. Corrections appliquées

Aucune correction code appliquée.

L'audit n'a pas trouvé de bouton mort évident, route cassée, overflow bloquant, wording technique visible ou problème Luna justifiant une modification code dans le cadre strict de `POST-DEMO-01`.

## 9. Problèmes détectés non corrigés

| Problème | Impact | Raison de non-correction | Lot futur recommandé |
| --- | --- | --- | --- |
| La durée reste mappée au moteur quick existant. | L'utilisateur voit une durée, mais le backend raisonne encore en nombre de questions. | Corriger cela nécessite une vraie façade/planner session, hors scope post-démo. | Future façade Study Session, après revue manuelle. |
| Feedback immédiat entre questions absent. | Le feedback pédagogique arrive surtout au bilan final. | Ajouter un feedback step-by-step nécessite un contrat backend/frontend dédié. | Futur `V4-06A/V4-06B`, pas avant validation démo. |
| Modes/historiques legacy encore accessibles depuis menu secondaire. | Risque de détourner la démo si on les ouvre. | Compatibilité à préserver ; cleanup plus large hors scope. | Hardening post-démo ciblé. |
| `flutter analyze` crash côté outil. | Pas de signal lint complet. | Crash analysis server récurrent, pas un diagnostic projet exploitable. | Suivi tooling séparé. |
| Données démo nécessaires. | Sans cours prêt/nodes/questions, l'app affichera des états honnêtes mais moins démonstratifs. | Préparation de données manuelle, pas un bug code. | Préparer un jeu de démo avant présentation. |

## 10. Verdict démo

`READY_WITH_MINOR_RESERVATIONS`

La démo est prête pour une revue manuelle, sous réserve de préparer un jeu de données réel et de ne pas ouvrir les surfaces legacy/hors scope pendant la présentation.

## 11. Recommandation immédiate

`PAUSE — Démo manuelle, captures, retours utilisateur`

Ne pas enchaîner directement sur `V4-05B`, `V4-06A`, Sujet long, Épreuve blanche, Progrès avancé ou GenUI avant cette revue.
