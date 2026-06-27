# Neralune Roadmap V4 — Execution Tracker

## 1. Purpose

Ce fichier suit l'execution de la roadmap canonique V4 de Neralune.

Roadmap source :

- `docs/roadmap/v4/NERALUNE_PRODUCT_TECH_ROADMAP_V4.md`

Role du tracker :

- Donner une vue operationnelle des phases, lots, dependances et statuts.
- Garder la trace des evidence packs attendus apres chaque lot.
- Centraliser les decisions prises pendant l'execution.
- Maintenir les risques ouverts et les prochains prompts a lancer.
- Respecter le verrou MVP demo defini dans `docs/roadmap/v4/MVP_DEMO_LOCK.md`.

Regle de mise a jour :

- Ce tracker doit etre mis a jour apres chaque lot Codex.
- Un lot ne passe pas `DONE` sans tests executes ou justification explicite.
- Les changements de strategie doivent etre ajoutes dans le decision log.

Difference entre roadmap canonique et tracker :

- La roadmap canonique fixe la direction produit et technique.
- Le tracker suit l'execution concrete de cette direction.
- La roadmap ne doit pas etre reecrite a chaque lot.
- Le tracker peut evoluer souvent, tant qu'il ne contredit pas la roadmap.

## 2. Status legend

| Status | Definition | Quand l'utiliser | Exemple |
| --- | --- | --- | --- |
| `NOT_STARTED` | Aucun travail n'a commence. | Lot ou phase planifiee mais non lancee. | `V4-03A` avant tout travail sur Cours V4. |
| `READY` | Le lot peut demarrer sans blocage connu. | Les dependances sont terminees ou suffisantes. | `V4-01A` apres validation du tracker. |
| `IN_PROGRESS` | Travail en cours. | Un agent ou le user travaille activement sur le lot. | `V4-DOC-02` pendant la creation de ce fichier. |
| `BLOCKED` | Le lot ne peut pas avancer sans decision ou correction externe. | Contrat manquant, bug bloquant, acces indisponible. | Backend Today bloque par une decision de schema. |
| `DONE` | Le lot est termine et verifie. | Tests/evidence fournis ou justification documentee. | Roadmap canonique creee et relue. |
| `NEEDS_BIS` | Le lot a ete livre mais reste incomplet ou insuffisant. | Une reprise ciblee est necessaire. | UI livree sans etats empty/error. |
| `DEFERRED` | Le lot est reporte volontairement. | Il reste utile mais n'est pas prioritaire maintenant. | Epreuve blanche avant stabilisation du sujet long. |
| `CANCELLED` | Le lot est abandonne. | La decision produit ou technique rend le lot inutile. | Un endpoint prevu remplace par une facade existante. |

## 3. Global execution summary

| Area | Status | Last completed lot | Current / next lot | Main risk | Notes |
| --- | --- | --- | --- | --- | --- |
| Documentation / governance | `DONE` | `V4-DOC-02` | `DEMO-05` | Tracker non maintenu apres les lots demo | Roadmap, tracker, lock MVP demo et evidence packs restent a jour. |
| Shell & navigation | `DONE` | `V4-01B` | `DEMO-05` | Raccourci profil encore discret | Trois onglets visibles livres ; profil accessible en action secondaire. |
| Aujourd'hui | `DONE` | `V4-02C` | `DEMO-05` | Actions secondaires de duree encore reportees | UI V4 alignee visuellement, display backend consomme en option, enrichment backend livre. |
| Cours | `IN_PROGRESS` | `V4-03C` | `DEMO-05` | Revision matiere encore partiellement branchee | Bibliotheque V4 livree et detail cours simplifie ; selector/action matiere restent a renforcer apres la demo. |
| Learning path | `DONE` | `V4-04B` | `DEMO-05` | Action notion-specific encore limitee par les routes legacy | Contrat backend consomme par Flutter ; timeline detail cours branchee sur les nodes reels. |
| Study Session V4 | `IN_PROGRESS` | `DEMO-03` | `DEMO-05` | Session encore limitee au moteur quick legacy | Choix duree 5/15/30 et session courte immersive livres en demo ; facade `/study-sessions` non creee. |
| Feedback & result | `IN_PROGRESS` | `DEMO-04` | `DEMO-05` | Feedback immediat per-question encore absent | Bilan final demo nettoye avec score secondaire, corrections utiles et prochaine action. |
| Progres | `NOT_STARTED` | Aucun | `V4-07A` | Trop de metriques ou donnees fragiles | Trois categories max : solides, a renforcer, a decouvrir. |
| Sujet long | `NOT_STARTED` | Aucun | `V4-08A` | Cout et qualite de correction | A garder separe des sessions normales. |
| Epreuve blanche | `NOT_STARTED` | Aucun | `V4-09A` | Produit trop lourd trop tot | A demarrer apres sujet long stabilise. |
| Luna / identity | `NOT_STARTED` | Aucun | `V4-10A` | Mascotte trop envahissante | Presence sobre, moments choisis, reduced motion. |
| Cleanup / hardening | `NOT_STARTED` | Aucun | `V4-11A` | Nettoyer avant compatibilite | Audit avant suppression ou masquage durable. |

## 4. Canonical phase tracker

| Phase | Title | Status | Product goal | Main deliverable | Depends on | Evidence expected | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Phase 0 | Roadmap, contrats produit et inventaire vérité | `DONE` | Eviter des lots contradictoires. | Roadmap canonique, tracker, conventions evidence. | Aucune | Diff documentation, commandes de lecture, tracker relu. | Roadmap et tracker crees. |
| Phase 1 | Shell V4 et navigation simplifiée | `DONE` | Rendre l'app comprehensible en deux secondes. | Navigation visible Aujourd'hui, Cours, Progres ; profil secondaire. | Phase 0 | Captures mobile/desktop, router/widget tests. | Shell trois onglets livre ; profil accessible en secondaire, routes legacy preservees. |
| Phase 2 | Aujourd’hui V4 | `DONE` | Montrer quoi travailler, combien de temps et pourquoi. | Today V4 avec action principale, objectif semaine, continuation discrete. | Phase 1 | Captures, tests Today, contrat Today documente si modifie. | Frontend-first, backend enrichment et alignement visuel livres ; objectif hebdo expose en target-only sans fake progress. |
| Phase 3 | Cours V4 et sélecteur matière | `IN_PROGRESS` | Transformer Cours en bibliotheque vivante. | Matiere active, reviser toute la matiere, liste compacte, selecteur. | Phase 1 | Captures 0/1/n cours, tests subject picker. | Frontend Cours V4 livre ; detail cours simplifie ; `V4-03B` reste a renforcer. |
| Phase 4 | Learning path du cours | `DONE` | Montrer le parcours de notions du cours. | Endpoint ou contrat learning path, timeline verticale. | Phase 3 | Contrat API, fixtures, captures, tests. | Backend et frontend branches sur `/courses/:courseId/learning-path`; la timeline utilise les nodes, states, active node, primary action et empty state backend. |
| Phase 5 | Study Session V4 | `IN_PROGRESS` | Reviser en 5/15/30 min sans mode technique visible. | Duration picker, facade session, planner multi-types. | Phase 4 | Traces de session, tests backend/frontend, captures. | `DEMO-02` livre le choix duree course-level mappe au moteur quick existant ; `DEMO-03` livre une session courte immersive quick-only. Facade et planner restent hors scope demo. |
| Phase 6 | Feedback immédiat et bilan V4 | `IN_PROGRESS` | Apprendre au moment de l'erreur. | Answer endpoint, feedback panel, result progression-first. | Phase 5 | Tests par type de question, captures feedback/result. | `DEMO-04` livre un bilan final propre avec corrections existantes ; le feedback immediat reste hors scope demo. |
| Phase 7 | Progrès V4 | `NOT_STARTED` | Rendre la progression actionnable. | Resume matiere, semaine, cours, a revoir maintenant. | Phase 4, Phase 6 | Captures, tests progress, decision event log. | Eviter les metriques trop proches du backend. |
| Phase 8 | Sujet long cours | `NOT_STARTED` | S'entrainer a une vraie reponse d'examen depuis un cours. | Contrat long-form, draft, workspace, correction structuree. | Phase 5, Phase 6 | Sample correction, captures mobile/desktop, tests. | Experience separee des sessions normales. |
| Phase 9 | Épreuve blanche matière | `NOT_STARTED` | Evaluer une matiere de facon transversale. | Scope matiere, sujet transversal, correction globale, historique. | Phase 8 | Fixtures multi-cours, tests, captures. | Ne pas la lancer trop tot. |
| Phase 10 | Luna / identité / polish | `NOT_STARTED` | Donner une presence feline sobre sans surcharger. | Integration Today/result/progress/empty states, reduced motion. | Phases UI principales | Captures, verification reduced motion, tests widgets. | Luna n'est pas une priorite avant la boucle quotidienne. |
| Phase 11 | Cleanup technique et hardening | `NOT_STARTED` | Stabiliser l'experience V4 et isoler le legacy. | Audit routes, cleanup visible, deprecations documentees, tests. | Phases 1 a 10 selon scope | Test report, build report, route audit. | Aucun moteur backend encore utile ne doit etre supprime trop tot. |

## 5. Lot tracker

| Lot ID | Title | Type | Status | Repository | Scope | Depends on | Files / areas expected | Tests expected | Evidence pack path | Completion date | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `V4-DOC-01` | Roadmap canonique V4 | Docs | `DONE` | Frontend doc + API audit | Source canonique produit/tech | Aucune | `docs/roadmap/v4/NERALUNE_PRODUCT_TECH_ROADMAP_V4.md` | Relecture documentaire | À confirmer | 2026-06-25 | Roadmap presente et coherent avec l'audit. Evidence pack non cree avant convention. |
| `V4-DOC-02` | Execution tracker V4 | Docs | `DONE` | Frontend doc | Tracker phases/lots/risques/decisions | `V4-DOC-01` | `docs/roadmap/v4/EXECUTION_TRACKER_V4.md` | Relecture, `git diff --check` | À confirmer | 2026-06-25 | Tracker cree et utilise pour piloter `V4-01A`. |
| `V4-01A` | Shell trois onglets | Frontend | `DONE` | Frontend | Navigation Aujourd'hui, Cours, Progres | `V4-DOC-02` | Shell, router, navigation widgets | Router tests, widget shell, responsive | `docs/roadmap/v4/evidence/V4-01A_shell_trois_onglets_EVIDENCE_PACK.md` | 2026-06-25 | Trois onglets visibles livres ; profil secondaire reporte a `V4-01B`. |
| `V4-01B` | Profil secondaire et routes legacy préservées | Frontend | `DONE` | Frontend | Sortir Profil de la nav principale sans casser les deep links | `V4-01A` | Shell, router, routes profil/legacy | Router tests, smoke legacy | `docs/roadmap/v4/evidence/V4-01B_profil_routes_legacy_EVIDENCE_PACK.md` | 2026-06-26 | Profil accessible via action secondaire ; routes `/profile`, `/revisions`, `/activities`, `/sources` testees hors shell. |
| `V4-02A` | Aujourd’hui V4 frontend-first | Frontend | `DONE` | Frontend | UI Today V4 avec donnees existantes | `V4-01B` | `TodayPage`, widgets Today, states | Widget tests loading/error/empty/data | `docs/roadmap/v4/evidence/V4-02A_aujourdhui_frontend_first_EVIDENCE_PACK.md` | 2026-06-26 | Page orientee action principale, sans faux mode ni fake data ; pas de nouveau planner backend. |
| `V4-02B` | Today backend enrichment | Backend | `DONE` | API | Enrichir Today pour recommendation/weekly/continue | `V4-02A` | Revision module, Today use case/controller | Unit/controller tests | `docs/roadmap/v4/evidence/V4-02B_today_backend_enrichment_EVIDENCE_PACK.md` | 2026-06-26 | Contrat `/today` enrichi avec primary/continuation/display/empty/weekly target-only, sans rupture legacy. |
| `V4-02C` | Aujourd’hui visual alignment | Frontend | `DONE` | Frontend | Rapprocher Today de la reference mobile sans fake data | `V4-02B` | `TodayPage`, modele Today, repository Today | Widget/repository/app/router tests | `docs/roadmap/v4/evidence/V4-02C_aujourdhui_visual_alignment_EVIDENCE_PACK.md` | 2026-06-26 | Greeting, Luna statique, hero compacte, CTA clair, weekly target-only et continuation unique. |
| `V4-03A` | Cours V4 frontend | Frontend | `DONE` | Frontend | Bibliotheque cours compacte et premium | `V4-01B` | `CoursesHomePage`, course cards | Widget tests 0/1/n cours | `docs/roadmap/v4/evidence/V4-03A_cours_v4_frontend_EVIDENCE_PACK.md` | 2026-06-26 | Header `Cours`, bouton `+`, selector, resume honnete, hero et liste compacte livres sans fake data. |
| `V4-03B` | Sélecteur matière et action “Réviser toute la matière” | Frontend | `NOT_STARTED` | Frontend | Subject picker V4 et CTA matiere | `V4-03A` | Subject picker, bottom sheet, CTA | Widget tests picker/CTA | `docs/roadmap/v4/evidence/V4-03B_selecteur_matiere_reviser_EVIDENCE_PACK.md` | À confirmer | Ouvre duration picker quand disponible. |
| `V4-03C` | Détail cours visual alignment | Frontend | `DONE` | Frontend | Simplifier le detail cours en page parcours | `V4-03A` | `CourseDetailPage`, tests detail/router | Widget/router tests detail cours | `docs/roadmap/v4/evidence/V4-03C_detail_cours_visual_alignment_EVIDENCE_PACK.md` | 2026-06-26 | Header sobre, Luna statique, CTA unique, parcours depuis vrais libelles si disponibles, historique/modes en menu secondaire. |
| `V4-04A` | Learning path backend contract | Backend | `DONE` | API | Contrat notions et etats de parcours | `V4-DOC-02` | Courses module, progress use case | Unit/controller tests | `docs/roadmap/v4/evidence/V4-04A_learning_path_backend_contract_EVIDENCE_PACK.md` | 2026-06-26 | Endpoint `/courses/:courseId/learning-path` livre avec nodes reels, states `MasteryState`, active node, primary action et empty states. |
| `V4-04B` | Learning path frontend timeline | Frontend | `DONE` | Frontend | Timeline verticale de notions | `V4-04A` | Course detail, timeline widget, repository | Widget/repository tests | `docs/roadmap/v4/evidence/V4-04B_learning_path_frontend_timeline_EVIDENCE_PACK.md` | 2026-06-26 | Flutter consomme `/courses/:courseId/learning-path`; nodes, states backend, active node, primary action et empty state affiches sans timeline provisoire. |
| `DEMO-02` | Choix durée simple 5 / 15 / 30 | Frontend demo | `DONE` | Frontend | Bottom sheet duree depuis detail cours, mappee au moteur quick existant | `DEMO-01` / `V4-04B` | `CourseDetailPage`, sheet duree, launcher quick | Detail/router/app tests, analyze tente | `docs/roadmap/v4/evidence/DEMO-02_choix_duree_simple_EVIDENCE_PACK.md` | 2026-06-26 | Correspondance demo de `V4-05A` ; `5/15/30 min` mappe en interne vers `questionCount` 5/10/30 sans exposer ce champ en UI. |
| `DEMO-03` | Session immersive quick-only | Frontend demo | `DONE` | Frontend | Session courte immersive sans dashboard | `DEMO-02` | `QuickRevisionQuizFlow`, revision session tests | Quick widget/detail/router/app tests, analyze tente | `docs/roadmap/v4/evidence/DEMO-03_session_immersive_quick_only_EVIDENCE_PACK.md` | 2026-06-26 | Une question a la fois, brouillons/signalement/sortie/finalisation conserves ; aucun nouveau backend ni `/study-sessions`. |
| `DEMO-04` | Feedback + bilan propre | Frontend demo | `DONE` | Frontend | Bilan final lisible, corrections utiles et prochaine action | `DEMO-03` | `RevisionSessionResultPage`, result/router/app tests | Result/quick/session/router/app tests, analyze tente | `docs/roadmap/v4/evidence/DEMO-04_feedback_bilan_propre_EVIDENCE_PACK.md` | 2026-06-27 | Utilise uniquement `RevisionSessionResult` et les corrections existantes ; score secondaire, pas de feedback IA, pas de backend. |
| `V4-05A` | Duration picker 5/15/30 | Frontend | `NOT_STARTED` | Frontend | Choix duree et perimetre | `V4-03B` | Bottom sheet, course/subject entry points | Widget tests | `docs/roadmap/v4/evidence/V4-05A_duration_picker_5_15_30_EVIDENCE_PACK.md` | À confirmer | Aucun `questionCount` visible. |
| `V4-05B` | Study Session V4 backend façade | Backend | `NOT_STARTED` | API | Facade `/study-sessions`, planner duration/scope | `V4-05A`, `V4-04A` | Revision sessions, adapters, planner | Unit/controller tests | `docs/roadmap/v4/evidence/V4-05B_study_session_backend_facade_EVIDENCE_PACK.md` | À confirmer | Reutiliser moteurs existants sans big bang. |
| `V4-05C` | Study Session V4 frontend shell | Frontend | `NOT_STARTED` | Frontend | Route immersive et renderer step | `V4-05B` | Session page, router, step renderer | Router/widget tests | `docs/roadmap/v4/evidence/V4-05C_study_session_frontend_shell_EVIDENCE_PACK.md` | À confirmer | Bottom nav masquee pendant la session. |
| `V4-06A` | Feedback immédiat backend | Backend | `NOT_STARTED` | API | Endpoint answer step et feedback normalise | `V4-05B` | Revision sessions, scorers, adapters | Unit/controller tests | `docs/roadmap/v4/evidence/V4-06A_feedback_immediat_backend_EVIDENCE_PACK.md` | À confirmer | Prevoir fallback non IA si possible. |
| `V4-06B` | Feedback immédiat frontend | Frontend | `NOT_STARTED` | Frontend | Panel feedback avant continuer | `V4-06A`, `V4-05C` | Session widgets, feedback panel | Widget tests | `docs/roadmap/v4/evidence/V4-06B_feedback_immediat_frontend_EVIDENCE_PACK.md` | À confirmer | Ton encourageant, pas culpabilisant. |
| `V4-06C` | Bilan V4 | Frontend + Backend | `NOT_STARTED` | Frontend + API | Result progression-first | `V4-06A`, `V4-06B` | Result mapper, result page | Unit/widget tests | `docs/roadmap/v4/evidence/V4-06C_bilan_v4_EVIDENCE_PACK.md` | À confirmer | Score secondaire, notions/action d'abord. |
| `V4-07A` | Progrès V4 backend summary | Backend | `NOT_STARTED` | API | Solides, a renforcer, a decouvrir | `V4-04A`, `V4-06C` | Progress use cases | Unit/controller tests | `docs/roadmap/v4/evidence/V4-07A_progres_backend_summary_EVIDENCE_PACK.md` | À confirmer | `MasteryEvent` seulement si justifie. |
| `V4-07B` | Progrès V4 frontend | Frontend | `NOT_STARTED` | Frontend | Vue progression simple et actionnable | `V4-07A` | Subject progress page, widgets | Widget tests | `docs/roadmap/v4/evidence/V4-07B_progres_frontend_EVIDENCE_PACK.md` | À confirmer | Pas de sur-affichage de metriques. |
| `V4-08A` | Sujet long contract | Backend + Product | `NOT_STARTED` | API | Contrat long-form cours | `V4-05B`, `V4-06C` | API contract, use case design | Unit/golden contract tests | `docs/roadmap/v4/evidence/V4-08A_sujet_long_contract_EVIDENCE_PACK.md` | À confirmer | Refuser si sources insuffisantes. |
| `V4-08B` | Sujet long backend | Backend | `NOT_STARTED` | API | Generation, draft, submit, evaluation | `V4-08A` | Long-form/deep revision modules, AI | Unit/controller/golden tests | `docs/roadmap/v4/evidence/V4-08B_sujet_long_backend_EVIDENCE_PACK.md` | À confirmer | Cout et latence a borner. |
| `V4-08C` | Sujet long frontend mobile | Frontend | `NOT_STARTED` | Frontend | Workspace mobile simple | `V4-08B` | Long-form page, draft UI | Widget tests mobile | `docs/roadmap/v4/evidence/V4-08C_sujet_long_frontend_mobile_EVIDENCE_PACK.md` | À confirmer | Pas d'editeur avance au debut. |
| `V4-08D` | Sujet long desktop workspace | Frontend | `NOT_STARTED` | Frontend | Layout desktop trois panneaux | `V4-08C` | Responsive workspace, sources, editor | Widget responsive/manual | `docs/roadmap/v4/evidence/V4-08D_sujet_long_desktop_workspace_EVIDENCE_PACK.md` | À confirmer | Desktop n'est pas un mobile etire. |
| `V4-08E` | Correction détaillée et barème | Frontend + Backend + IA | `NOT_STARTED` | Frontend + API | Rubric, modele de reponse, sources, remediation | `V4-08B`, `V4-08C` | Evaluator, result page | Golden/unit/widget tests | `docs/roadmap/v4/evidence/V4-08E_correction_detaillee_bareme_EVIDENCE_PACK.md` | À confirmer | Grounding obligatoire. |
| `V4-09A` | Épreuve blanche contract | Backend + Product | `NOT_STARTED` | API | Contrat subject-scope transversal | `V4-08A`, `V4-08E` | API contract, subject scope design | Contract tests | `docs/roadmap/v4/evidence/V4-09A_epreuve_blanche_contract_EVIDENCE_PACK.md` | À confirmer | Plus tardif que sujet long. |
| `V4-09B` | Épreuve blanche backend | Backend | `NOT_STARTED` | API | Sujet transversal multi-cours, correction globale | `V4-09A` | Long-form, subjects, AI | Unit/controller/golden tests | `docs/roadmap/v4/evidence/V4-09B_epreuve_blanche_backend_EVIDENCE_PACK.md` | À confirmer | Attention sources insuffisantes. |
| `V4-09C` | Épreuve blanche frontend | Frontend | `NOT_STARTED` | Frontend | Entry matiere/progress, workspace, result | `V4-09B` | Courses/progress/long-form UI | Widget responsive tests | `docs/roadmap/v4/evidence/V4-09C_epreuve_blanche_frontend_EVIDENCE_PACK.md` | À confirmer | Ne remplace pas les sessions normales. |
| `V4-10A` | Luna integration pass | Frontend | `NOT_STARTED` | Frontend | Presence discrete Today/result/progress/empty states | Phases 2, 6, 7 | Brand widgets, pages V4 | Widget tests, screenshots | `docs/roadmap/v4/evidence/V4-10A_luna_integration_pass_EVIDENCE_PACK.md` | À confirmer | Pas de mascotte partout. |
| `V4-10B` | Motion / accessibility polish | Frontend | `NOT_STARTED` | Frontend | Reduced motion, text scaling, semantics | `V4-10A` | Motion widgets, semantics, responsive checks | Accessibility/widget/manual | `docs/roadmap/v4/evidence/V4-10B_motion_accessibility_polish_EVIDENCE_PACK.md` | À confirmer | Respecter `MediaQuery.disableAnimationsOf`. |
| `V4-11A` | Legacy route audit | Frontend + Backend | `NOT_STARTED` | Frontend + API | Inventaire routes/endpoints visibles ou historiques | Phases 1 a 7 | Router docs, API docs | Router/API smoke | `docs/roadmap/v4/evidence/V4-11A_legacy_route_audit_EVIDENCE_PACK.md` | À confirmer | Audit avant suppression. |
| `V4-11B` | Legacy cleanup | Frontend + Backend | `NOT_STARTED` | Frontend + API | Masquer ou retirer legacy visible sans casser historique | `V4-11A` | Routes, pages legacy, wording, deprecations | Regression tests | `docs/roadmap/v4/evidence/V4-11B_legacy_cleanup_EVIDENCE_PACK.md` | À confirmer | Aucun endpoint historique supprime sans remplacant. |
| `V4-11C` | Hardening final | Frontend + Backend | `NOT_STARTED` | Frontend + API | Tests, build, docs, polish final | `V4-11B` | Suites ciblees, docs, evidence packs | Flutter/API tests, analyze/lint/build selon contexte | `docs/roadmap/v4/evidence/V4-11C_hardening_final_EVIDENCE_PACK.md` | À confirmer | Dernier passage avant considerer V4 stabilisee. |

## 6. Next recommended lots

Verrou `LOCK-01` : jusqu'a la demo, les prochains lots autorises sont limites au couloir `DEMO-01` a `DEMO-05` de `docs/roadmap/v4/MVP_DEMO_LOCK.md`.

1. `DEMO-01` — Brancher le learning path dans le détail cours
   - Correspondance : `V4-04B — Learning path frontend timeline`.
   - Statut : deja livre au moment du lock ; ce lot devient le premier jalon demo verrouille.
   - Ne doit pas faire : ajouter session V4, duration picker, backend ou refonte Cours.

2. `DEMO-02` — Choix durée simple 5 / 15 / 30
   - Correspondance : `V4-05A — Duration picker 5/15/30`.
   - Statut : livre le 2026-06-26.
   - Resultat : bottom sheet `5 min / 15 min / 30 min` depuis le detail cours, mappee au moteur quick existant.
   - Ne doit pas faire : creer la facade `/study-sessions`.
   - Risque principal : le mapping duree reste interne au moteur quick existant jusqu'a la vraie facade Study Session.

3. `DEMO-03` — Session immersive quick-only
   - Correspondance : version reduite de `V4-05C — Study Session V4 frontend shell`.
   - Statut : livre le 2026-06-26.
   - Resultat : flux quick immersif, une question a la fois, sans bottom nav ni dashboard technique.
   - Ne doit pas faire : QCM complet, question ouverte, mode examen, nouveau backend sauf blocage reel.

4. `DEMO-04` — Feedback + bilan propre
   - Correspondance : version reduite de `V4-06B / V4-06C`.
   - Statut : livre le 2026-06-27.
   - Resultat : bilan final clarifie, score secondaire, corrections utiles et prochaine action branchee sur les routes existantes.
   - Ne doit pas faire : feedback IA complexe si les corrections existantes suffisent.

5. `DEMO-05` — Polish démo + Luna légère
   - Correspondance : `V4-10A-lite / V4-11A-lite`.
   - Statut : prochain lot recommande.
   - Pourquoi ensuite : stabiliser le couloir demo sans rouvrir de grands chantiers.
   - Ne doit pas faire : mascot system complet, nouvel asset, animation infinie.

## 7. Evidence pack convention

Convention de nommage :

```text
docs/roadmap/v4/evidence/V4-XX_<slug>_EVIDENCE_PACK.md
```

Exemples :

- `docs/roadmap/v4/evidence/V4-01A_shell_trois_onglets_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/V4-05B_study_session_backend_facade_EVIDENCE_PACK.md`

Chaque evidence pack futur doit contenir :

- Objectif du lot.
- Fichiers modifies.
- Resume des changements.
- Tests executes.
- Resultats des tests.
- Captures si UI.
- Decisions produit prises.
- Risques restants.
- Autocritique.
- Prochaines etapes.

Ne pas creer les evidence packs en avance. Ils sont crees uniquement a la fin du lot correspondant.

## 8. Decision log

| Date | Decision | Status | Rationale | Impact | Revisit when |
| --- | --- | --- | --- | --- | --- |
| 2026-06-25 | Navigation cible a trois onglets : Aujourd'hui, Cours, Progres. | Accepted | Simplifie la comprehension immediate de l'app. | Shell et router a recadrer. | Phase 1. |
| 2026-06-25 | Suppression de l'onglet principal Reviser. | Accepted | La revision doit partir du contexte Today ou Cours. | Routes legacy conservees mais masquees. | Phase 1 et Phase 11. |
| 2026-06-25 | Plus de distinction visible QCM simple / QCM complet. | Accepted | L'utilisateur ne doit pas choisir un moteur technique. | Les moteurs restent internes. | Phase 5. |
| 2026-06-25 | Toutes les sessions normales utilisent des questions variees. | Accepted | Cible pedagogique plus riche et plus simple a expliquer. | Necessite facade et planner. | Phase 5 et Phase 6. |
| 2026-06-25 | Duree + perimetre remplacent le choix de mode. | Accepted | L'utilisateur choisit le temps et le contexte, pas le type d'exercice. | `questionCount` doit devenir interne. | Phase 5. |
| 2026-06-25 | Sujet long separe des sessions normales. | Accepted | Une reponse longue est une experience differente. | Workspace, draft et correction dedies. | Phase 8. |
| 2026-06-25 | Epreuve blanche separee et plus tardive. | Accepted | Produit transversal plus lourd, a ne pas melanger aux sessions. | Dependance forte au sujet long. | Phase 9. |
| 2026-06-25 | Luna est une presence sobre, pas une mascotte envahissante. | Accepted | Garder un ton premium et serieux. | Integration limitee aux moments utiles. | Phase 10. |
| 2026-06-25 | Login non prioritaire. | Accepted | La page login est deja satisfaisante. | Les premiers lots doivent viser la boucle de revision. | Si incoherence visuelle majeure apparait. |
| 2026-06-25 | La roadmap canonique reste la source de verite, le tracker suit l'execution. | Accepted | Evite de dupliquer la strategie. | Les changements strategiques passent par le decision log. | Apres chaque lot. |
| 2026-06-25 | `Aujourd'hui` devient la route initiale signee-in. | Accepted | La V4 doit ouvrir sur la priorite du jour. | `AppRoutes.today` remplace `AppRoutes.home` comme initial location. | Si Today V4 bloque l'usage avant `V4-02A`. |
| 2026-06-25 | `/home` reste la route Cours legacy. | Accepted | Evite de casser les liens existants vers la bibliotheque de cours. | L'onglet `Cours` pointe vers l'existant `CoursesHomePage`. | Phase 3. |
| 2026-06-25 | `/revisions`, `/activities` et `/profile` sortent du shell visible. | Accepted | Masquer les destinations techniques sans supprimer les routes. | Ces routes restent accessibles hors navigation principale. | `V4-01B` et `V4-11A`. |
| 2026-06-26 | Le profil devient une action secondaire du shell. | Accepted | Garder les trois onglets principaux sans perdre l'acces aux reglages. | Raccourci profil par icone, route `/profile` preservee hors shell. | Phase 10 ou audit `V4-11A`. |
| 2026-06-26 | Today V4 prend le premier item `TodayPlan` comme action principale. | Accepted | Le backend fournit deja un ordre de priorite ; le frontend ne doit pas inventer un planner. | La carte principale affiche une seule action et les items suivants restent en continuation discrete. | `V4-02B`. |
| 2026-06-26 | Today V4 mappe les `reasonCode` vers un wording produit. | Accepted | Les raisons brutes peuvent encore exposer les anciens modes techniques. | L'UI evite le jargon sans changer le contrat API. | `V4-02B`. |
| 2026-06-26 | Luna animee n'est pas integree a Today dans `V4-02A`. | Accepted | Une animation permanente rend les tests `pumpAndSettle` instables et grossit le lot. | Presence visuelle remplacee par une icone sobre existante. | Phase 10. |
| 2026-06-26 | `/today` expose un contrat `display` retrocompatible. | Accepted | Le backend doit fournir une copy produit propre sans supprimer les champs legacy consommes par le frontend actuel. | Ajout de `primaryItemId`, `continuationItemIds`, `role`, `display`, `weeklyObjective` target-only et `emptyState`. | Si le frontend a besoin d'un sync contractuel dedie. |
| 2026-06-26 | Today consomme `display` en option et utilise Luna statique. | Accepted | Rapprocher l'ecran de la reference sans casser l'ancien contrat ni reintroduire une animation infinie. | `TodayPage` lit les champs enrichis si presents, garde les fallbacks legacy et affiche `neralune_cat.svg` sans animation. | Phase 10 pour le mascot system complet. |
| 2026-06-26 | La hero card Cours ouvre le cours prioritaire plutot qu'une session matiere fictive. | Accepted | La vraie revision subject-level et le duration picker n'existent pas encore ; l'UI doit rester honnete. | `CoursesHomePage` affiche `Reviser cette matiere`, precise le cours choisi et pousse `AppRoutes.course(course.id)`. | `V4-03B` et `V4-05A`. |
| 2026-06-26 | Le detail cours V4 devient une page de parcours, pas une page de modes. | Accepted | La reference cible un ecran tres simple : un cours, une progression, un parcours, deux actions. | `CourseDetailPage` masque historique et modes du flux principal et les conserve dans le menu `...`. | `V4-04A` et `V4-11A`. |
| 2026-06-26 | Le parcours detail cours utilise seulement des libelles de notions reels. | Accepted | Le frontend n'a pas encore de maitrise par notion fiable ; copier les checks de la maquette serait du fake data. | Timeline provisoire basee sur `CourseRichRevisionScopeOption`, sans etat pedagogique invente. | `V4-04A`. |
| 2026-06-26 | Le learning path devient un endpoint dedie `/courses/:courseId/learning-path`. | Accepted | `/progress` reste agrege et ne doit pas etre casse ; la timeline a besoin d'un contrat par notion. | Ajout d'un contrat backend avec nodes reels, states issus de `MasteryState`, active node, primary action et empty states. | `V4-04B`. |
| 2026-06-26 | Le frontend ne recalcule pas les etats du learning path. | Accepted | Le backend `V4-04A` fournit deja `node.state`; recalculer cote Flutter risquerait des incoherences produit. | Flutter parse les enums avec fallback `unknown` et mappe seulement les couleurs/icones. | `V4-04B`. |
| 2026-06-26 | Le CTA principal du detail cours utilise `primaryAction` backend. | Accepted | La page doit refleter l'action recommandee par le contrat learning path, sans recreer un planner local. | `CourseDetailPage` affiche `primaryAction.label/description` et branche les actions existantes fiables. | `V4-03B`, `V4-05A`. |
| 2026-06-26 | `LOCK-01` verrouille le MVP demo autour de cinq lots maximum. | Accepted | La V4 risque de s'etendre vers trop de surfaces avant une demo convaincante. | Creation de `MVP_DEMO_LOCK.md`; les prochains prompts doivent suivre `DEMO-01` a `DEMO-05` et refuser le scope creep. | Apres demo MVP. |
| 2026-06-26 | `DEMO-02` mappe les durees 5/15/30 min vers le moteur quick existant. | Accepted | La facade Study Session V4 n'existe pas encore, mais le choix utilisateur doit deja parler en duree. | `5 min` -> `questionCount 5`, `15 min` -> `questionCount 10`, `30 min` -> `questionCount 30`; le champ technique reste invisible en UI. | `DEMO-03`, puis vraie facade Study Session. |
| 2026-06-26 | `DEMO-03` transforme le flux quick en session courte immersive sans nouveau moteur. | Accepted | La demo a besoin d'une experience montrable maintenant, sans attendre `/study-sessions` ni un planner multi-types. | `QuickRevisionQuizFlow` affiche une question a la fois, masque la bottom nav, conserve brouillons/signalement/finalisation et garde les moteurs techniques internes. | `DEMO-04`, puis vraie facade Study Session. |
| 2026-06-27 | `DEMO-04` utilise le resultat de session existant comme feedback final de demo. | Accepted | Les corrections existent deja dans `RevisionSessionResult`; generer du feedback IA ou ouvrir `V4-06A` serait trop lourd pour le verrou demo. | `RevisionSessionResultPage` affiche score secondaire, corrections utiles, notions disponibles uniquement si reelles et prochaine action fiable. | `DEMO-05`, puis vrai feedback immediat `V4-06A/V4-06B`. |

## 9. Open risks

| Risk ID | Risk | Severity | Area | Mitigation | Owner / next lot | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `R-V4-001` | Big bang frontend. | High | Frontend | Decouper shell, Today, Cours, sessions. | `V4-02A` | Mitigated |
| `R-V4-002` | Confusion entre quick/rich/deep/exam dans le code. | High | Frontend + API | Creer une facade Study Session et garder les moteurs internes. | `V4-05B` | Open |
| `R-V4-003` | `questionCount` encore trop central. | High | API + Frontend | Masquer cote UI, mapper temporairement si necessaire, puis planner duration. | `V4-05A`, `V4-05B` | Open |
| `R-V4-004` | Cout IA des sessions variees. | Medium | IA + API | Budget par duree, cache question bank, fallback questions pretes. | `V4-05B` | Open |
| `R-V4-005` | Latence des questions variees. | Medium | IA + API | Preparation asynchrone et reutilisation question bank. | `V4-05B` | Open |
| `R-V4-006` | Feedback immediat trop lent si IA synchrone. | High | API + IA | Feedback court, scoring local quand possible, fallback non IA. | `V4-06A` | Open |
| `R-V4-007` | Sujet long couteux et difficile a corriger. | High | API + IA | Rubric bornee, source grounding, golden tests. | `V4-08A` | Open |
| `R-V4-008` | Hallucination si sources insuffisantes. | High | IA | Refus ou indisponibilite si sources trop faibles, references obligatoires. | `V4-08A`, `V4-09A` | Open |
| `R-V4-009` | Epreuve blanche trop lourde trop tot. | Medium | Product | La demarrer apres sujet long stabilise. | `V4-09A` | Open |
| `R-V4-010` | Luna trop envahissante. | Medium | UX | Moments limites, revue design, reduced motion. | `V4-10A` | Open |
| `R-V4-011` | Routes legacy cassees. | High | Frontend | Conserver routes, router tests, audit avant cleanup ; `V4-01B` couvre `/profile`, `/revisions`, `/activities` et `/sources`. | `V4-11A` | Mitigated |
| `R-V4-012` | Double design system. | High | Frontend | Utiliser `Revision*`, migrer Today, ne pas creer nouvelle palette. | `V4-02A` | Open |
| `R-V4-013` | Weekly objective fragile sans event log. | Medium | API | Exposer seulement `targetMinutes` en target-only ; justifier `MasteryEvent` si une progression fiable devient necessaire. | `V4-07A` | Open |
| `R-V4-014` | Nettoyage legacy trop tot. | Medium | Frontend + API | Cleanup uniquement apres evidence de compatibilite. | `V4-11A` | Open |
| `R-V4-015` | Raccourci profil trop discret. | Low | UX | Surveiller en usage ; avatar ou menu de compte possible pendant le polish. | `V4-10A`, `V4-11A` | Open |
| `R-V4-016` | Today V4 depend encore d'un contrat backend minimal. | Medium | Frontend + API | `V4-02B` ajoute primary/continuation/display/empty/weekly target-only sans rupture legacy. | `V4-02B` | Mitigated |
| `R-V4-017` | Le frontend Today ne consomme pas encore les champs `display` enrichis. | Low | Frontend + API | `V4-02C` lit `display`, `weeklyObjective`, `emptyState`, `primaryItemId` et `continuationItemIds` en option avec fallback legacy. | `V4-02C` | Mitigated |
| `R-V4-018` | Les actions secondaires `Choisir une duree` et selecteur dedie Today ne sont pas encore branchees. | Low | Frontend | Afficher seulement `Changer de cours` vers Cours ; garder la duree pour `V4-05A`. | `V4-05A` | Open |
| `R-V4-019` | La hero Cours peut etre comprise comme une vraie revision matiere alors qu'elle ouvre un cours prioritaire. | Medium | Frontend + Product | Wording `On commence par <cours>` et decision documentee ; renforcer l'action dans `V4-03B`. | `V4-03B` | Open |
| `R-V4-020` | Le detail cours n'a pas encore de vrai learning path avec etats par notion. | High | Frontend + API | Contrat backend livre en `V4-04A` et timeline frontend branchee en `V4-04B`. | `V4-04B` | Mitigated |
| `R-V4-021` | Les modes et historiques sont accessibles en menu secondaire mais restent legacy dans leur presentation. | Medium | Frontend | Garder l'acces pour compatibilite, puis auditer/masquer proprement au hardening. | `V4-11A` | Open |
| `R-V4-022` | Le frontend ne consomme pas encore `/courses/:courseId/learning-path`. | Medium | Frontend + API | Repository, model, provider et `CourseDetailPage` branches en `V4-04B`. | `V4-04B` | Mitigated |
| `R-V4-023` | Scope creep V4 avant demo. | High | Product + Frontend + API | `LOCK-01` limite les prochains lots a `DEMO-01`...`DEMO-05` et reporte sujet long, epreuve blanche, progres avance et mascot system complet. | `MVP_DEMO_LOCK.md` | Mitigated |
| `R-V4-024` | La duree demo ne represente pas encore une vraie planification temporelle. | Medium | Frontend + API | `DEMO-02` masque `questionCount` en UI et documente le mapping ; `DEMO-03` doit garder la session quick-only honnete. | `DEMO-03`, future facade Study Session | Open |
| `R-V4-025` | La session immersive demo n'a pas encore de feedback immediat entre les questions. | Medium | Frontend + Product | `DEMO-04` couvre le bilan final avec corrections existantes ; le feedback immediat reste a traiter dans le vrai contrat answer/feedback. | `V4-06A`, `V4-06B` | Open |

## 10. Update protocol

Apres chaque lot Codex :

1. Mettre a jour le statut du lot.
2. Ajouter la date de completion si le lot est termine.
3. Renseigner le chemin de l'evidence pack.
4. Deplacer le prochain lot recommande si necessaire.
5. Ajouter les decisions prises.
6. Ajouter les risques nouveaux.
7. Marquer `NEEDS_BIS` si le lot est incomplet.
8. Ne jamais marquer `DONE` sans tests ou justification explicite.

Regles pratiques :

- Si les tests n'ont pas ete executes, expliquer pourquoi dans le lot et dans l'evidence pack.
- Si un lot modifie le scope prevu, ajouter une decision.
- Si un lot decouvre un blocage produit, ajouter un risque ou passer le lot `BLOCKED`.
- Si un lot est fractionne, creer un sous-lot lisible plutot que gonfler le scope.

## 11. Tracker maintenance rules

- Le tracker doit rester court et exploitable.
- La roadmap canonique ne doit pas etre reecrite a chaque lot.
- Les changements de strategie doivent etre documentes dans Decision log.
- Les lots peuvent etre decoupes si trop gros.
- Les lots peuvent etre fusionnes seulement si le perimetre reste tres sur.
- Aucun lot backend lourd ne doit etre fusionne avec un lot UI majeur sans raison forte.
- Sujet long et Epreuve blanche doivent rester separes.
- Les migrations Prisma doivent etre explicitement justifiees.
- Les evidence packs ne doivent pas contenir de promesses non verifiees.
- Le statut `DONE` doit rester rare et defendable.

## 12. Initial state

Etat initial au 2026-06-26 :

- `V4-DOC-01` est realise parce que la roadmap canonique existe, couvre frontend et API, et contient phases, backlog, risques et ordre recommande.
- `V4-DOC-02` est realise parce que ce tracker existe et sert deja au suivi des lots.
- `V4-01A` est realise : le shell visible contient `Aujourd'hui`, `Cours`, `Progres`.
- `V4-01B` est realise : le profil est accessible par action secondaire et les routes legacy principales sont testees hors shell.
- `V4-02A` est realise : la page Aujourd'hui V4 frontend-first affiche une action principale depuis les donnees Today existantes.
- `V4-02B` est realise : `/today` conserve les champs existants et ajoute un contrat display/primary/continuation/empty/weekly target-only.
- `V4-02C` est realise : la page Aujourd'hui est visuellement rapprochee de la reference et consomme le contrat Today enrichi en option.
- `V4-03A` est realise : l'onglet Cours affiche une bibliotheque V4 avec header, bouton `+`, selector, resume honnete, hero et liste compacte.
- `V4-03C` est realise : le detail cours est simplifie autour d'un CTA, d'un parcours honnete et d'actions basses ; historique et modes sont deplaces dans le menu secondaire.
- `V4-04A` est realise : l'API expose `/courses/:courseId/learning-path` avec nodes reels, states par notion, active node, primary action et empty states.
- `V4-04B` est realise : Flutter consomme `/courses/:courseId/learning-path`, remplace la timeline provisoire et utilise les nodes/states/active node/primary action/empty state backend.
- `LOCK-01` est realise : `MVP_DEMO_LOCK.md` verrouille le couloir de demo et limite les prochains lots autorises a `DEMO-01`...`DEMO-05`.
- `DEMO-02` est realise : le choix duree 5/15/30 min est branche sur le moteur quick existant sans exposer `questionCount`.
- `DEMO-03` est realise : la session quick demo devient immersive, une question a la fois, sans bottom nav.
- `DEMO-04` est realise : le bilan final affiche score secondaire, corrections utiles et prochaine action sans nouveau backend.
- La Phase 1 est terminee.
- La Phase 2 est terminee.
- La Phase 3 est `IN_PROGRESS`.
- Le prochain lot recommande sous verrou demo est `DEMO-05`, dernier polish avant demo.
- La Phase 4 est terminee ; les Phases 5 et 6 avancent en version demo, tandis que les phases 7+ restent `NOT_STARTED`.
- Aucun fichier Prisma n'a ete modifie par les lots V4 livres ; `V4-02B` modifie uniquement le backend Today, `V4-02C` uniquement le frontend Today/documentation et `V4-04A` uniquement le backend Courses/documentation.

Controles de coherence effectues pour creer ce tracker :

- Lecture de la roadmap canonique.
- Extraction des phases V4.
- Extraction du backlog detaille.
- Extraction des premiers lots recommandes.
- Reprise des decisions canoniques et risques majeurs.
- Verification que le tracker ne lance pas Sujet long ou Epreuve blanche avant la boucle quotidienne.

## 13. Autocritique finale

Points solides :

- Le tracker suit la roadmap sans la remplacer.
- Les statuts initiaux restent prudents.
- Les lots sont assez decoupes pour eviter un big bang.
- Les risques principaux de la roadmap sont presents et assignes a des prochains lots.

Points a surveiller :

- `V4-DOC-02` est marque `DONE` sans evidence pack dedie ; la preuve reste le fichier tracker committe au lot precedent.
- `V4-01A`, `V4-01B` et `V4-02A` sont marques `DONE`, mais `flutter analyze` a crashe cote outil et devra etre relance.
- L'acces profil secondaire de `V4-01B` est volontairement minimal ; il pourra etre rendu plus explicite en polish.
- `V4-02C` consomme les champs enrichis en option, mais conserve des fallbacks locaux pour rester compatible avec l'ancien contrat.
- Les actions secondaires Today restent volontairement partielles : `Changer de cours` est branche, le choix de duree attend `V4-05A`.
- `V4-03A` livre la bibliotheque Cours V4, mais l'action matiere reste une navigation vers le cours prioritaire tant que le duration picker et la session subject-level n'existent pas.
- `V4-03C` rapproche le detail cours de la reference, mais le vrai statut par notion manque encore ; la timeline reste donc volontairement prudente.
- `V4-04B` consomme le contrat learning path, mais l'action notion-specific reste limitee par les routes legacy tant que Study Session V4 n'existe pas.
- `LOCK-01` introduit une double nomenclature temporaire `DEMO-*` / `V4-*` ; les prompts doivent toujours citer la correspondance pour eviter la confusion.
- Les lots backend API sont references meme si le repository concerne par ce fichier est le frontend ; cela reste necessaire car la roadmap V4 depend explicitement du backend.
- Le decoupage `V4-01A`, `V4-01B`, etc. simplifie le pilotage par rapport aux IDs bruts du backlog canonique ; il ne doit pas faire oublier les tickets detailles de la roadmap source.
