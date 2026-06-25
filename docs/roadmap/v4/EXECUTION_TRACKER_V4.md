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
| Documentation / governance | `DONE` | `V4-DOC-02` | `V4-02A` | Tracker non maintenu apres les lots | Roadmap et tracker existent. |
| Shell & navigation | `DONE` | `V4-01B` | `V4-02A` | Raccourci profil encore discret | Trois onglets visibles livres ; profil accessible en action secondaire. |
| Aujourd'hui | `NOT_STARTED` | Aucun | `V4-02A` | Refaire trop tot le planner backend | Commencer frontend-first avec donnees existantes. |
| Cours | `NOT_STARTED` | Aucun | `V4-03A` | Garder trop de gestion/source en surface | S'appuyer sur `CoursesHomePage` et subject picker. |
| Learning path | `NOT_STARTED` | Aucun | `V4-04A` | Etats pedagogiques mal calibres | Contrat backend avant timeline finale. |
| Study Session V4 | `NOT_STARTED` | Aucun | `V4-05A` | `questionCount` encore trop central | Duree/perimetre d'abord, facade ensuite. |
| Feedback & result | `NOT_STARTED` | Aucun | `V4-06A` | Feedback IA trop lent si synchrone | Normaliser feedback avant polish result. |
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
| Phase 2 | Aujourd’hui V4 | `NOT_STARTED` | Montrer quoi travailler, combien de temps et pourquoi. | Today V4 avec action principale, objectif semaine, continuation discrete. | Phase 1 | Captures, tests Today, contrat Today documente si modifie. | Frontend-first avant nouveau planner. |
| Phase 3 | Cours V4 et sélecteur matière | `NOT_STARTED` | Transformer Cours en bibliotheque vivante. | Matiere active, reviser toute la matiere, liste compacte, selecteur. | Phase 1 | Captures 0/1/n cours, tests subject picker. | Sources et gestion en secondaire. |
| Phase 4 | Learning path du cours | `NOT_STARTED` | Montrer le parcours de notions du cours. | Endpoint ou contrat learning path, timeline verticale. | Phase 3 | Contrat API, fixtures, captures, tests. | Utiliser `KnowledgeUnit` et `MasteryState` d'abord. |
| Phase 5 | Study Session V4 | `NOT_STARTED` | Reviser en 5/15/30 min sans mode technique visible. | Duration picker, facade session, planner multi-types. | Phase 4 | Traces de session, tests backend/frontend, captures. | Sujet long et epreuve blanche hors scope. |
| Phase 6 | Feedback immédiat et bilan V4 | `NOT_STARTED` | Apprendre au moment de l'erreur. | Answer endpoint, feedback panel, result progression-first. | Phase 5 | Tests par type de question, captures feedback/result. | Ne pas attendre tous les renderers pour demarrer. |
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
| `V4-02A` | Aujourd’hui V4 frontend-first | Frontend | `NOT_STARTED` | Frontend | UI Today V4 avec donnees existantes | `V4-01B` | `TodayPage`, widgets Today, states | Widget tests loading/error/empty/data | `docs/roadmap/v4/evidence/V4-02A_aujourdhui_frontend_first_EVIDENCE_PACK.md` | À confirmer | Pas de nouveau planner backend. |
| `V4-02B` | Today backend enrichment | Backend | `NOT_STARTED` | API | Enrichir Today pour recommendation/weekly/continue | `V4-02A` | Revision module, Today use case/controller | Unit/controller tests | `docs/roadmap/v4/evidence/V4-02B_today_backend_enrichment_EVIDENCE_PACK.md` | À confirmer | Garder compat avec Today existant. |
| `V4-03A` | Cours V4 frontend | Frontend | `NOT_STARTED` | Frontend | Bibliotheque cours compacte et premium | `V4-01B` | `CoursesHomePage`, course cards | Widget tests 0/1/n cours | `docs/roadmap/v4/evidence/V4-03A_cours_v4_frontend_EVIDENCE_PACK.md` | À confirmer | Eviter le dashboard de modes. |
| `V4-03B` | Sélecteur matière et action “Réviser toute la matière” | Frontend | `NOT_STARTED` | Frontend | Subject picker V4 et CTA matiere | `V4-03A` | Subject picker, bottom sheet, CTA | Widget tests picker/CTA | `docs/roadmap/v4/evidence/V4-03B_selecteur_matiere_reviser_EVIDENCE_PACK.md` | À confirmer | Ouvre duration picker quand disponible. |
| `V4-04A` | Learning path backend contract | Backend | `NOT_STARTED` | API | Contrat notions et etats de parcours | `V4-DOC-02` | Courses module, progress use case | Unit/controller tests | `docs/roadmap/v4/evidence/V4-04A_learning_path_backend_contract_EVIDENCE_PACK.md` | À confirmer | Decider si `MasteryState` suffit. |
| `V4-04B` | Learning path frontend timeline | Frontend | `NOT_STARTED` | Frontend | Timeline verticale de notions | `V4-04A` | Course detail, timeline widget, repository | Widget/repository tests | `docs/roadmap/v4/evidence/V4-04B_learning_path_frontend_timeline_EVIDENCE_PACK.md` | À confirmer | Sources en menu secondaire. |
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

1. `V4-02A` — Aujourd’hui V4 frontend-first
   - Pourquoi maintenant : la valeur V4 commence par la recommandation quotidienne.
   - Ne doit pas faire : attendre un nouveau planner backend complet.
   - Risque principal : construire une UI trop ambitieuse pour les donnees existantes.

2. `V4-02B` — Today backend enrichment
   - Pourquoi maintenant : completer les champs manquants apres avoir stabilise la surface Today.
   - Ne doit pas faire : transformer `/today` en moteur de session complet.
   - Risque principal : introduire un contrat backend trop specifique a une premiere maquette.

3. `V4-03A` — Cours V4 frontend
   - Pourquoi maintenant : l'onglet Cours existe maintenant comme destination principale.
   - Ne doit pas faire : ajouter learning path ou duration picker.
   - Risque principal : refaire trop largement la bibliotheque au lieu de la simplifier.

4. `V4-03B` — Sélecteur matière et action “Réviser toute la matière”
   - Pourquoi maintenant : completer la surface Cours avant les sessions V4.
   - Ne doit pas faire : brancher Study Session V4.
   - Risque principal : exposer trop tot des actions qui dependent du duration picker.

5. `V4-04A` — Learning path backend contract
   - Pourquoi maintenant : preparer le parcours de notions une fois Cours recadre.
   - Ne doit pas faire : imposer une timeline frontend avant le contrat.
   - Risque principal : surexposer des etats pedagogiques non fiables.

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
| `R-V4-013` | Weekly objective fragile sans event log. | Medium | API | Utiliser donnees existantes d'abord, justifier `MasteryEvent` si necessaire. | `V4-02B`, `V4-07A` | Open |
| `R-V4-014` | Nettoyage legacy trop tot. | Medium | Frontend + API | Cleanup uniquement apres evidence de compatibilite. | `V4-11A` | Open |
| `R-V4-015` | Raccourci profil trop discret. | Low | UX | Surveiller en usage ; avatar ou menu de compte possible pendant le polish. | `V4-10A`, `V4-11A` | Open |

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
- La Phase 1 est terminee.
- Le prochain lot recommande est `V4-02A`.
- Les phases produit apres Phase 1 restent `NOT_STARTED`.
- Aucun fichier backend ou Prisma n'a ete modifie par `V4-01A` ou `V4-01B`.

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
- `V4-01A` et `V4-01B` sont marques `DONE`, mais `flutter analyze` a crashe cote outil et devra etre relance.
- L'acces profil secondaire de `V4-01B` est volontairement minimal ; il pourra etre rendu plus explicite en polish.
- Les lots backend API sont references meme si le repository concerne par ce fichier est le frontend ; cela reste necessaire car la roadmap V4 depend explicitement du backend.
- Le decoupage `V4-01A`, `V4-01B`, etc. simplifie le pilotage par rapport aux IDs bruts du backlog canonique ; il ne doit pas faire oublier les tickets detailles de la roadmap source.
