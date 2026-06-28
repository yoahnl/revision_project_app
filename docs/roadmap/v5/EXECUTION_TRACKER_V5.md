# Neralune V5 — Execution Tracker

## 1. Statut global

Statut : `IN_PROGRESS`

Source canonique :

- `docs/roadmap/v5/NERALUNE_MOCKUP_FIRST_ROADMAP_V5.md`
- `docs/roadmap/v5/VISUAL_QA_PROTOCOL_V5.md`
- `docs/roadmap/v5/SCREEN_TARGET_MATRIX_V5.md`

Contexte :

- Le couloir V4 DEMO est termine.
- `POST-DEMO-01` donne le verdict `READY_WITH_MINOR_RESERVATIONS`.
- L'audit mobile dark du 27 juin 2026 montre que l'application n'est pas encore assez alignee avec la maquette cible.
- V5 devient la roadmap canonique pour la suite produit.

Regle directrice :

```text
Aucun lot n'est valide sans preuve visuelle.
```

Statuts utilises :

| Statut | Definition |
|---|---|
| `NOT_STARTED` | Lot planifie mais non lance. |
| `READY` | Lot pret a etre implemente. |
| `IN_PROGRESS` | Travail en cours. |
| `BLOCKED` | Decision, contrat ou donnees manquantes. |
| `DONE` | Lot livre, teste et prouve visuellement. |
| `NEEDS_BIS` | Lot livre mais insuffisant visuellement ou fonctionnellement. |
| `DEFERRED` | Report volontaire. |

## 2. Table des phases

| Phase | Titre | Statut | Objectif utilisateur | Ecrans concernes | Lots | Critere de sortie |
|---|---|---|---|---|---|---|
| Phase 0 | Fiabilite visible | `DONE` | Je ne tombe jamais sur un bouton qui ment, un spinner infini ou une page morte. | Aujourd'hui, Reviser, Activites, QCM, Sources, Detail cours | V5-01, V5-02, V5-03 | CTA honnetes, timeouts visibles, filenames humanises, captures before/after. |
| Phase 1 | Cockpit et parcours | `IN_PROGRESS` | Je sais quoi faire aujourd'hui et je vois mon parcours de cours. | Aujourd'hui, Cours, Detail cours, Fiche | V5-04, V5-05, V5-06 | Today coach, checkpoints, fiche premium, captures alignees. |
| Phase 2 | Boucle de revision | `NOT_STARTED` | Je choisis une duree, je reponds, je comprends, je continue. | Choix duree, Session, Feedback, Bilan | V5-07, V5-08, V5-09, V5-10 | Flow question court, tactile, avec feedback et bilan visibles. |
| Phase 3 | Motivation et premiere impression | `NOT_STARTED` | Je comprends Neralune au premier ecran et je vois mes progres. | Progres, Onboarding, Profil | V5-11, V5-12 | Progres motivant low-data, onboarding emotionnel dark. |

## 3. Table des lots

| ID | Titre | Statut | Type | Objectif utilisateur | Ecrans concernes | Dependance | Fichiers probables | Tests obligatoires | Captures obligatoires | Evidence pack attendu | Risque principal | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| V5-01 | CTA honnetes + etats de preparation | `DONE` | Je sais si je peux reviser maintenant ou quoi faire en attendant. | Detail cours, Reviser, Fiche | Audit V5 cree | Course detail, quick launcher | Widget preparing/ready/error, route fiche fallback, absence CTA mensonger | CTA before, questions preparing, session ready, fallback fiche | `docs/roadmap/v5/evidence/V5-01_cta_honnetes_etats_preparation_EVIDENCE_PACK.md` | Etat reel non expose par le contrat | Livre le 2026-06-27 : CTA detail cours honnete et fallback stable du quick launcher. |
| V5-02 | Anti-spinner + surfaces legacy | `DONE` | Je ne reste jamais bloque sur une page qui charge ou ne sert a rien. | Activites, QCM, Reviser, Sources globales | V5-01 recommande | Routes legacy, pages Activites/Reviser/Sources, timeout UI | Tests timeout, retry, redirection, router legacy | Activites spinner before/after, Sources parking, Reviser legacy | `docs/roadmap/v5/evidence/V5-02_anti_spinner_surfaces_legacy_EVIDENCE_PACK.md` | Cacher une route sans alternative utile | Livre le 2026-06-27 : Activites sans contexte actionnable, timeouts 9 s sur activite et QCM complet, Reviser/Sources globales clarifies. |
| V5-03 | Humanisation sources / PDF / notions | `DONE` | Je vois des noms de cours et supports humains, pas des fichiers techniques. | Detail cours, Fiche, Sources fiche, Documents, Subject detail | V5-01 | Source label helpers, document models, course sheet/detail | Tests label fallback, absence filename brut, source originale secondaire | Filenames before/after, source originale secondaire | `docs/roadmap/v5/evidence/V5-03_humanisation_sources_pdf_notions_EVIDENCE_PACK.md` | Libelle humain trompeur ou incomplet | Livre le 2026-06-27 : helper central de labels humains, surfaces cours/fiche/sources/matiere/document humanisees, fichier original relaye en secondaire. |
| V5-04 | Aujourd'hui coach | `DONE` | J'ouvre l'app et je comprends ma prochaine mission. | Aujourd'hui | V5-01, V5-03 | Today page, Today models/repository | Widget empty/ready/preparing, CTA fallback, wording | Today empty, fiche ready, questions preparing, session ready | `docs/roadmap/v5/evidence/V5-04_aujourdhui_coach_EVIDENCE_PACK.md` | Recommandation inventee | Livre le 2026-06-28 : Today affiche une mission utile, fallback fiche/cours/no-course, erreur actionnable, sans fake progression ni detail cours modifie. |
| V5-05 | Detail cours parcours gamifie | `DONE` | Je vois mon parcours et le prochain checkpoint. | Detail cours, Cours | V5-03, V5-04 | Course detail, learning path widgets/models | Path empty/filled, CTA contextuel, absence filename, router actions | Detail before/after, checkpoint actif, etats notion | `docs/roadmap/v5/evidence/V5-05_detail_cours_parcours_gamifie_EVIDENCE_PACK.md` | Progression simulee | Livre le 2026-06-28 : detail cours en timeline checkpoint, CTA contextuel, actions bas d'ecran et captures dark mobile. |
| V5-06 | Fiche premium actionnable | `NOT_STARTED` | Je peux vraiment reviser depuis une belle fiche. | Fiche, Sources fiche | V5-03 | Course sheet, source widgets, fiche sections | Sections, sources collapsed/expanded, CTA, overflow mobile | Fiche before/after, sources before/after, CTA fiche | `docs/roadmap/v5/evidence/V5-06_fiche_premium_actionnable_EVIDENCE_PACK.md` | Fiche belle mais trop longue | Lot cle pour la demande "belles fiches". |
| V5-07 | Choix duree aligne maquette | `NOT_STARTED` | Je choisis une duree seulement si la revision est possible. | Choix duree | V5-01 | Duration sheet/page, quick launcher | Options, disabled/preparing, mapping interne non visible | Choix duree ready/preparing, comparaison maquette | `docs/roadmap/v5/evidence/V5-07_choix_duree_aligne_maquette_EVIDENCE_PACK.md` | Confusion temps reel vs nombre de questions | Peut garder moteur quick interne. |
| V5-08 | Session question alignee maquette | `NOT_STARTED` | Je reponds a une question claire et tactile. | Session question | V5-07 | Quick revision quiz flow, session widgets | Selection, validation, mobile sans nav, overflow, submit error | Session question, reponse selectionnee, loading/error | `docs/roadmap/v5/evidence/V5-08_session_question_alignee_maquette_EVIDENCE_PACK.md` | Erreur backend cachee | Pas de multi-type complet. |
| V5-09 | Feedback reponse | `NOT_STARTED` | Je comprends tout de suite pourquoi j'ai juste ou faux. | Feedback reponse | V5-08 | Feedback widgets, corrections/result data | Correct/incorrect/no explanation, continuer, source fallback | Feedback juste, feedback faux, source liee | `docs/roadmap/v5/evidence/V5-09_feedback_reponse_EVIDENCE_PACK.md` | Feedback trop long ou lent | Garder court. |
| V5-10 | Bilan resultat | `NOT_STARTED` | Je vois ma victoire, mes erreurs et la prochaine action. | Bilan resultat | V5-09 | Result page, result widgets/models | Variants result, route cours/fiche, absence fake data | Bilan erreurs, bilan sans erreurs, prochaine action | `docs/roadmap/v5/evidence/V5-10_bilan_resultat_EVIDENCE_PACK.md` | Progression inventee | Score secondaire. |
| V5-11 | Progres maquette | `NOT_STARTED` | Je vois une progression motivante meme avec peu de donnees. | Progres | V5-10 recommande | Progress page/models | Empty/low-data/data, wording, dark mode | Progres before/after, low-data, data | `docs/roadmap/v5/evidence/V5-11_progres_maquette_EVIDENCE_PACK.md` | Trop de metriques fragiles | Low-data first. |
| V5-12 | Onboarding emotionnel | `NOT_STARTED` | Ma premiere impression ressemble a Neralune. | Onboarding, Login, Setup matiere | V5-01 minimum, idealement apres flow coeur | Sign-in, onboarding/setup routes, auth/profile tests | Sign-in initial/email, setup route, semantics/autofill, dark mode | Login before/after, onboarding route, email form | `docs/roadmap/v5/evidence/V5-12_onboarding_emotionnel_EVIDENCE_PACK.md` | Auth plus belle mais moins accessible | Pas de refonte backend auth. |

## 4. Lots immediats recommandes

1. V5-06 — Fiche premium actionnable
2. V5-07 — Choix duree aligne maquette
3. V5-08 — Session question alignee maquette
4. V5-09 — Feedback reponse
5. V5-10 — Bilan resultat
6. V5-11 — Progres maquette
7. V5-12 — Onboarding emotionnel

Lots termines :

```text
V5-01 — CTA honnetes + etats de preparation
V5-02 — Anti-spinner + surfaces legacy
V5-03 — Humanisation sources / PDF / notions
V5-04 — Aujourd'hui coach
V5-05 — Detail cours parcours gamifie
```

Prochain lot a lancer :

```text
V5-06 — Fiche premium actionnable
```

## 5. Regles de validation

- Aucun lot valide sans screenshot.
- Aucun lot valide sans comparaison maquette.
- Aucun lot valide si un CTA principal echoue silencieusement.
- Aucun lot valide si un spinner peut rester infini.
- Aucun lot valide si du jargon technique apparait dans l'UI critique.
- Aucun lot valide si un filename brut apparait dans un ecran coeur.
- Aucun lot valide si le dark mode mobile 390 x 844 n'a pas ete capture.
- Aucun lot valide sans evidence pack.
- Aucun lot valide sans verdict : `valide`, `a reprendre` ou `bloque`.

## 6. Decisions produit

| Date | Decision | Statut | Raison | Impact |
|---|---|---|---|---|
| 2026-06-27 | V5 devient la suite canonique apres le couloir V4 DEMO. | Accepted | L'audit visuel montre que le produit doit devenir maquette-first. | Les prochains prompts partent de V5, pas des grosses features V4 reportees. |
| 2026-06-27 | Le dark mode mobile est la reference de verification V5. | Accepted | La demande utilisateur se concentre sur mobile dark mode. | Captures minimales en 390 x 844 dark. |
| 2026-06-27 | Aucun lot n'est termine sans preuve visuelle. | Accepted | L'ecart principal est perceptif autant que fonctionnel. | Evidence packs obligatoires avec captures. |
| 2026-06-27 | Les CTA honnetes passent avant les refontes belles. | Accepted | Le CTA quick a echoue silencieusement dans l'audit. | V5-01 avant Today/detail/session polish. |
| 2026-06-27 | Un etat questions en preparation doit donner une action utile, pas un snackbar technique. | Accepted | `COURSE_QUICK_REVISION_QUESTIONS_PREPARING` bloquait le demarrage sans alternative stable. | Le lanceur quick ouvre une sheet avec `Lire la fiche` et `Voir le parcours`; le detail cours remplace le CTA revision par `Lire la fiche` quand moins de 5 questions sont pretes. |
| 2026-06-27 | La fiche est un axe produit central, pas un fallback pauvre. | Accepted | L'utilisateur demande de belles fiches de revision et l'audit la classe comme meilleur morceau actuel. | V5-06 reste prioritaire dans Phase 1. |
| 2026-06-27 | Les grosses features V4 restent reportees. | Accepted | Elles risquent de masquer les P0 visuels et fonctionnels. | Pas de Study Session complete, sujet long, epreuve blanche ou GenUI avant P0/P1. |
| 2026-06-27 | Les sources sans titre backend stable restent neutres cote UI. | Accepted | Inventer un titre pedagogique serait plus trompeur qu'un label `Support N`. | V5-03 humanise l'affichage sans modifier le contrat backend. |
| 2026-06-28 | Today doit toujours proposer une action honnete avant de se declarer vide. | Accepted | Un cours ou une fiche exploitable suffit pour guider l'utilisateur, meme sans session prete. | V5-04 ajoute des fallbacks front-only `Lire la fiche`, `Voir le cours` et `Ouvrir les cours`. |
| 2026-06-28 | Le detail cours reste une gamification legere fondee sur le LearningPath. | Accepted | La maquette demande des checkpoints, mais la roadmap interdit XP, badges et progression inventee. | V5-05 affiche une timeline et une notion active sans ajouter de mecanique fictive. |

## 7. Risques ouverts

| ID | Risque | Severite | Mitigation | Lot |
|---|---|---|---|---|
| R-V5-001 | CTA principal non fiable si le contrat ne distingue pas les etats. | High | UI fallback + clarification contrat minimal si necessaire. | V5-01 |
| R-V5-002 | Spinners persistants dans Activites/QCM. | High | Timeout UI, retry, fallback fiche/question ouverte. | V5-02 |
| R-V5-003 | Filenames bruts oublies dans une surface secondaire. | High | Helper central + tests absence filename sur ecrans critiques. | V5-03 |
| R-V5-004 | Today invente une mission non fondee. | Medium | Etats qualifies et wording honnete. | V5-04 |
| R-V5-005 | Gamification simulee. | Medium | Checkpoints bases sur donnees reelles ou etats explicitement approximatifs. | V5-05 |
| R-V5-006 | Fiche trop longue sur mobile. | Medium | Sections compactes, sources pliables, CTA visible. | V5-06 |
| R-V5-007 | Feedback IA lent ou absent. | High | Feedback court depuis corrections existantes, fallback sans IA. | V5-09 |
| R-V5-008 | Captures non comparables. | Medium | Protocole viewport 390 x 844, dark mode force, noms de fichiers stables. | Tous |
| R-V5-009 | Onboarding auth moins accessible apres polish. | Medium | Tests autofill/semantics, email/password toujours accessible. | V5-12 |
| R-V5-010 | Titres de sources vraiment intelligents absents du backend. | Medium | Garder `Support N` maintenant ; envisager un champ backend futur si le produit veut des titres editoriaux stables. | V5-03 / futur |
| R-V5-011 | Contrat Today encore trop pauvre pour prioriser finement les missions. | Medium | Fallback front-only depuis cours/sources ; documenter un contrat Today futur avec etat fiche/questions. | V5-04 / futur |
| R-V5-012 | Etat parcours vide difficile a reproduire visuellement sans donnees backend dediees. | Medium | Couverture widget test et documentation dans l'evidence pack ; prevoir un fixture visuel si cet etat devient critique. | V5-05 |

## 8. Journal de mise a jour

| Date | Entree | Fichiers | Auteur |
|---|---|---|---|
| 2026-06-27 | Creation du tracker V5 maquette-first apres audit mobile dark. | `EXECUTION_TRACKER_V5.md` | Codex |
| 2026-06-27 | Premier lot recommande fixe a `V5-01 — CTA honnetes + etats de preparation`. | `EXECUTION_TRACKER_V5.md` | Codex |
| 2026-06-27 | Lot `V5-01 — CTA honnetes + etats de preparation` livre avec tests, captures mobile dark 390 x 844 et evidence pack. | `EXECUTION_TRACKER_V5.md`, `V5-01_cta_honnetes_etats_preparation_EVIDENCE_PACK.md` | Codex |
| 2026-06-27 | Lot `V5-02 — Anti-spinner + surfaces legacy` livre avec timeouts visibles, surfaces legacy actionnables, captures mobile dark et evidence pack. | `EXECUTION_TRACKER_V5.md`, `V5-02_anti_spinner_surfaces_legacy_EVIDENCE_PACK.md` | Codex |
| 2026-06-27 | Lot `V5-03 — Humanisation sources / PDF / notions` livre avec helper de labels humains, tests d'absence de filename brut et captures mobile dark. | `EXECUTION_TRACKER_V5.md`, `V5-03_humanisation_sources_pdf_notions_EVIDENCE_PACK.md` | Codex |
| 2026-06-28 | Lot `V5-04 — Aujourd'hui coach` livre avec mission principale, fallbacks fiche/cours/no-course, tests Today/app/router et captures mobile dark. | `EXECUTION_TRACKER_V5.md`, `V5-04_aujourdhui_coach_EVIDENCE_PACK.md` | Codex |
