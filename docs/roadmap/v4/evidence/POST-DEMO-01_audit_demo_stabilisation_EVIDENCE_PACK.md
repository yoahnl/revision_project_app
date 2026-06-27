# POST-DEMO-01 — Audit démo et stabilisation post-MVP — Evidence Pack

## 1. Objectif

Auditer strictement le couloir MVP démo de Neralune après `DEMO-05`, sans lancer de nouvelle grosse feature, afin de savoir si le flow peut être montré en revue manuelle.

Flow audité :

```text
Aujourd'hui → Cours → Détail cours → Durée → Session quick immersive → Bilan → Retour cours / fiche
```

## 2. Rappel du verrou MVP démo

Le verrou MVP démo limite le travail à la stabilisation du couloir livré :

- pas de nouveau backend ;
- pas de Prisma ;
- pas de Genkit ;
- pas de GenUI ;
- pas de `/study-sessions` ;
- pas de sujet long ;
- pas d'épreuve blanche ;
- pas de progrès avancé ;
- pas de nouveau mode de révision ;
- pas de nouvelle navigation ;
- pas de nouvel asset.

`POST-DEMO-01` est donc docs-first. Les corrections code ne sont autorisées que si elles sont minuscules et bloquantes pour la démo.

## 3. Résumé de l’audit

Verdict : `READY_WITH_MINOR_RESERVATIONS`.

Le flow démo est cohérent et couvert par les tests ciblés. Les écrans principaux existent, les routes du flow sont branchées, la bottom nav reste à trois onglets, le profil reste secondaire, la session quick est immersive et le bilan utilise les corrections existantes sans inventer de données.

Aucune correction code n'a été appliquée : aucun blocage démo trivial n'a été identifié.

## 4. Fichiers lus

Docs :

- `docs/roadmap/v4/MVP_DEMO_LOCK.md`
- `docs/roadmap/v4/MVP_DEMO_RUNBOOK.md`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/evidence/LOCK-01_mvp_demo_lock_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-02_choix_duree_simple_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-03_session_immersive_quick_only_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-04_feedback_bilan_propre_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-05_polish_demo_luna_legere_EVIDENCE_PACK.md`

Code audité :

- `lib/presentation/pages/today/today_page.dart`
- `lib/features/courses/presentation/courses_home_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/widgets/quick_revision_question_count_sheet.dart`
- `lib/features/revision_sessions/presentation/quick_revision_quiz_flow.dart`
- `lib/presentation/pages/revision_sessions/revision_session_result_page.dart`
- `lib/presentation/shell/revision_home_shell.dart`
- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`

Tests audités/exécutés :

- `test/features/courses/course_detail_page_test.dart`
- `test/features/revision_sessions/quick_revision_quiz_flow_test.dart`
- `test/features/revision_sessions/revision_session_page_test.dart`
- `test/features/revision_sessions/revision_session_result_page_test.dart`
- `test/app/router/app_router_test.dart`
- `test/app/revision_app_test.dart`

## 5. Fichiers modifiés

Créés :

- `docs/roadmap/v4/POST_DEMO_AUDIT.md`
- `docs/roadmap/v4/evidence/POST-DEMO-01_audit_demo_stabilisation_EVIDENCE_PACK.md`

Modifiés :

- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`

Aucun fichier code modifié.

## 6. Corrections appliquées

Aucune correction code appliquée.

Justification : l'audit n'a pas trouvé de bouton mort, route retour cassée, jargon technique visible, overflow évident, test ciblé cassé ou problème Luna justifiant une correction dans le périmètre strict du lot.

## 7. Tests exécutés

| Commande | Résultat | Notes |
| --- | --- | --- |
| `flutter test test/features/courses/course_detail_page_test.dart` | OK | 31 tests passent. |
| `flutter test test/features/revision_sessions/quick_revision_quiz_flow_test.dart` | OK | 5 tests passent. |
| `flutter test test/features/revision_sessions/revision_session_page_test.dart` | OK | 20 tests passent. |
| `flutter test test/features/revision_sessions/revision_session_result_page_test.dart` | OK | 9 tests passent. |
| `flutter test test/app/router/app_router_test.dart` | OK | 23 tests passent. |
| `flutter test test/app/revision_app_test.dart` | OK | 12 tests passent. |
| `flutter analyze` | Échec outil | Crash analysis server : `FormatException: Unexpected end of input`, puis `analysis server exited with code 255`. `flutter_22.log` généré puis supprimé. |
| `git diff --check` | OK | Aucun whitespace error. |
| `git status --short` | OK | Fichiers attendus uniquement : tracker, audit post-demo et evidence pack. |

## 8. Verdict

`READY_WITH_MINOR_RESERVATIONS`

Le couloir démo est prêt pour revue manuelle, avec réserves mineures documentées :

- durée encore mappée au moteur quick ;
- feedback immédiat entre questions absent ;
- modes/historiques legacy encore accessibles en secondaire ;
- `flutter analyze` bloqué par crash outil ;
- données de démo réelles à préparer.

## 9. Risques restants

- Le moteur quick reste interne sous le flow de démo.
- `questionCount` reste un détail technique interne du mapping durée.
- Le vrai contrat Study Session V4 n'est pas livré.
- Le feedback immédiat étape par étape n'est pas livré.
- Les surfaces legacy doivent rester hors narration de démo.
- Luna reste légère ; le mascot system complet est toujours reporté.

## 10. Prochaine action recommandée

`PAUSE — Démo manuelle, captures, retours utilisateur`

Si la revue manuelle détecte un vrai blocage, le seul lot recommandé doit être :

`POST-DEMO-02 — Mini-fixes bloquants uniquement`

Ne pas enchaîner directement sur une grosse feature.

## 11. Autocritique finale

L'audit est volontairement prudent : il valide les routes, tests et libellés visibles, mais ne remplace pas une vraie capture vidéo manuelle du flow avec données réelles. Le bon prochain geste n'est pas de coder plus, c'est de regarder la démo tourner et noter les frictions observées.
