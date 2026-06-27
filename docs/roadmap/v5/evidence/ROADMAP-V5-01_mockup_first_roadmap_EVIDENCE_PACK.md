# ROADMAP-V5-01 — Mockup-first roadmap — Evidence Pack

## 1. Objectif

Creer la roadmap canonique Neralune V5 maquette-first, son tracker, son protocole de verification visuelle et sa matrice d'ecrans, sans implementer de feature.

Objectif produit :

```text
Transformer la suite de Neralune en une execution visual-first, ou chaque lot doit prouver son alignement mobile dark avec la maquette cible.
```

## 2. Documents lus

Mission :

- `/Users/karim/.codex/attachments/fbe41cbc-babe-405c-b685-c94a5f3ed510/pasted-text.txt`

Docs V4 :

- `docs/roadmap/v4/MVP_DEMO_LOCK.md`
- `docs/roadmap/v4/MVP_DEMO_RUNBOOK.md`
- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`
- `docs/roadmap/v4/POST_DEMO_AUDIT.md`

Evidence packs V4 :

- `docs/roadmap/v4/evidence/LOCK-01_mvp_demo_lock_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-02_choix_duree_simple_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-03_session_immersive_quick_only_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-04_feedback_bilan_propre_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/DEMO-05_polish_demo_luna_legere_EVIDENCE_PACK.md`
- `docs/roadmap/v4/evidence/POST-DEMO-01_audit_demo_stabilisation_EVIDENCE_PACK.md`

Audit produit :

- `output/product-audit/neralune-full-app-2026-06-27/report.md`
- `output/product-audit/neralune-full-app-2026-06-27/screenshots/`

## 3. Constats repris de l'audit

Constats integres dans la roadmap V5 :

- la base dark mode est interessante ;
- la fiche de revision est le meilleur morceau actuel ;
- Aujourd'hui ne joue pas encore son role de coach ;
- la revision rapide promet une session mais peut echouer avec `COURSE_QUICK_REVISION_QUESTIONS_PREPARING` ;
- Activites/QCM peuvent rester bloques en spinner ;
- les noms de PDF bruts apparaissent encore dans l'experience ;
- le detail cours est encore trop technique et pas assez parcours gamifie ;
- la fiche doit devenir plus premium et actionnable ;
- les pages parking ou legacy doivent etre masquees ou stabilisees ;
- la maquette cible devient la reference visuelle principale ;
- le dark mode mobile 390 x 844 est le viewport de controle prioritaire.

Captures d'audit citees dans les documents V5 :

- `01-sign-in-initial.png`
- `02-sign-in-email-form.png`
- `10-dark-today.png`
- `11-dark-courses-home.png`
- `12-dark-course-detail.png`
- `13-dark-course-sheet.png`
- `14-dark-course-sheet-sources.png`
- `15-dark-progress.png`
- `16-dark-profile.png`
- `19-dark-sources-pending.png`
- `20-dark-revisions-pending.png`
- `21-dark-activities.png`
- `26-dark-revisions-before-start.png`
- `27-dark-session-after-start.png`
- `28-dark-activities-subject-waited.png`
- `29-dark-course-subject-selector.png`
- `34-dark-document-detail-chevron.png`
- `36-dark-open-question-from-document.png`
- `42-dark-open-question-correction-after-wait.png`
- `47-dark-onboarding-route.png`

## 4. Fichiers crees

- `docs/roadmap/v5/NERALUNE_MOCKUP_FIRST_ROADMAP_V5.md`
- `docs/roadmap/v5/EXECUTION_TRACKER_V5.md`
- `docs/roadmap/v5/VISUAL_QA_PROTOCOL_V5.md`
- `docs/roadmap/v5/SCREEN_TARGET_MATRIX_V5.md`
- `docs/roadmap/v5/evidence/ROADMAP-V5-01_mockup_first_roadmap_EVIDENCE_PACK.md`

## 5. Fichiers modifies

- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`

Modification prevue :

```text
Note courte de transition indiquant que le couloir V4 DEMO est termine et que la suite canonique devient la roadmap V5 maquette-first.
```

Aucun fichier Dart, backend, asset, `pubspec.yaml` ou `pubspec.lock` ne doit etre modifie par cette mission.

## 6. Roadmap creee

Roadmap creee :

```text
docs/roadmap/v5/NERALUNE_MOCKUP_FIRST_ROADMAP_V5.md
```

Elle contient :

- pourquoi une V5 ;
- vision produit ;
- reference visuelle des 10 ecrans ;
- etat actuel resume ;
- principes V5 ;
- phases ;
- lots V5-01 a V5-12 ;
- ordre recommande ;
- reports explicites ;
- definition de `maquette-aligned` ;
- definition de `ready for demo` ;
- risques ;
- prochaine action immediate.

Prochaine action immediate fixee :

```text
V5-01 — CTA honnetes + etats de preparation
```

## 7. Protocole visual QA cree

Protocole cree :

```text
docs/roadmap/v5/VISUAL_QA_PROTOCOL_V5.md
```

Il impose :

- captures before ;
- captures after ;
- reference cible ;
- notes d'ecart ;
- viewport mobile 390 x 844 ;
- dark mode ;
- format evidence pack visuel ;
- checklist avant validation ;
- cas de rejet automatique.

Le protocole reference le runner existant :

```text
output/product-audit/neralune-full-app-2026-06-27/mobile_dark_audit_runner.mjs
```

## 8. Prochaine action recommandee

Premier lot d'implementation recommande :

```text
V5-01 — CTA honnetes + etats de preparation
```

Objectif :

```text
Aucun bouton principal ne promet une revision qui ne peut pas demarrer.
```

Ce lot doit traiter en premier :

- `COURSE_QUICK_REVISION_QUESTIONS_PREPARING` ;
- questions en preparation ;
- session prete ;
- fiche prete ;
- source prete ;
- fallback `Lire la fiche` ;
- fallback `Question ouverte` seulement si fiable.

## 9. Non-objectifs respectes

Non-objectifs respectes pendant cette mission :

- aucune feature implementee ;
- aucun code Flutter modifie ;
- aucun backend modifie ;
- aucun Prisma modifie ;
- aucun Genkit modifie ;
- aucun GenUI modifie ;
- aucun asset modifie ;
- aucune dependance ajoutee ;
- aucun ecran corrige ;
- aucune route supprimee ;
- aucune page refaite ;
- `pubspec.yaml` non modifie ;
- `pubspec.lock` non modifie ;
- aucune commande Flutter lancee.

## 10. Risques restants

- La maquette cible est referencee depuis une piece jointe locale ; si elle doit devenir archive canonique, elle devra etre copiee ou documentee dans un emplacement stable.
- L'ordre impose par le brief met le choix duree en position 6, alors que la fiche premium est un besoin fort. La roadmap note donc V5-06 comme lot `5 bis` dans l'ordre visuel.
- Les captures after n'existent pas encore, car cette mission est docs-only.
- V5-01 peut reveler un manque de contrat pour connaitre l'etat reel des questions.
- Le runner Playwright existe, mais chaque futur lot devra produire ses propres captures ciblees.

## 11. Autocritique finale

Le cadrage V5 est volontairement plus strict que V4 : il refuse de valider un lot sans preuve visuelle. C'est adapte au probleme observe, car l'ecart principal n'est plus seulement le code mais la perception mobile dark.

Le point a surveiller est l'equilibre entre fiabilite et desirabilite. V5-01 a raison de passer avant le polish, mais il faudra vite enchainer sur V5-03 et V5-06 pour tenir la demande de belles fiches de revision. Une app peut etre honnete et rester froide ; la V5 doit eviter cette issue.
