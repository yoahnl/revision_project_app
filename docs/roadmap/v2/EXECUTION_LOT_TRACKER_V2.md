# Execution Lot Tracker V2

Ce tracker suit les lots réellement exécutables. Les macro-lots restent suivis dans `LOT_TRACKER_V2.md`.

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

Horizons autorisés : `FOUNDATION`, `MVP_STABLE`, `MVP_PLUS`, `POST_MVP`, `RELEASE`.

| Lot | Parent macro-lot | Horizon | Repo(s) | Statut | Dépend de | Travaux parallélisables | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00B | STAB-00 | FOUNDATION | App + API | DONE | STAB-00 | Aucun | Durcir la roadmap V2 et créer les lots exécutables. | Docs, trackers et protocole synchronisés. | `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` |
| QUALITY-00 | QUALITY-00 | FOUNDATION | App + API | DONE | STAB-00B | STAB-01A | Installer une baseline CI reproductible. | Flutter analyze/tests côté app ; Prisma/build/lint/tests/e2e côté API. | `docs/roadmap/v2/QUALITY_00_CI_BASELINE_REPORT.md` |
| STAB-01A | STAB-01 | MVP_STABLE | App | DONE | STAB-00B | QUALITY-00 | Corriger shell, navigation, scaffold et scrolls globaux. | Bottom nav 4 onglets, routes session immersives, routes legacy conservées, scaffolds top-aligned. | `docs/ui/STAB_01A_SHELL_NAVIGATION_SCAFFOLD_REPORT.md` |
| STAB-01B | STAB-01 | MVP_STABLE | App | DONE | STAB-01A | CORE-09A | Clarifier Home, Hub Révisions et hiérarchie des actions cours. | Home, hub Réviser et détail cours ont une action principale honnête, sans impasse ni wording technique. | `docs/ui/STAB_01B_HOME_REVISION_HUB_COURSE_ACTIONS_REPORT.md` |
| STAB-01C | STAB-01 | MVP_STABLE | App | DONE | STAB-01B | Aucun | Corriger fiche, progrès, wording et découvrabilité des matières. | Fiche sans faux onglets actifs, Progrès plus lisible, wording utilisateur nettoyé. | `docs/ui/STAB_01C_SHEET_PROGRESS_WORDING_SUBJECTS_REPORT.md` |
| STAB-02A | STAB-02 | MVP_STABLE | App | DONE | STAB-01C | CORE-10A si CORE-09A fait | Migrer Auth, Onboarding, Profil et Matières vers le design premium. | Une seule direction visuelle, sans faux état produit. | `docs/ui/STAB_02A_LEGACY_PREMIUM_ALIGNMENT_REPORT.md` |
| STAB-02B | STAB-02 | MVP_STABLE | App | DONE | STAB-02A | Aucun | Extraire les widgets feature, isoler ou déprécier le legacy. | Parcours canonique isolé du legacy, inventaire créé, microfixes review STAB-02B-bis intégrés. | `docs/ui/STAB_02B_CANONICAL_FLOW_LEGACY_ISOLATION_REPORT.md` |
| CORE-09A | CORE-09 | MVP_STABLE | App + API | DONE | STAB-01A | STAB-01B | Définir archive/delete des sources. | Une source utilisée n'est plus supprimée naïvement. | `docs/core/CORE_09A_SOURCE_LIFECYCLE_APP_REPORT.md` |
| CORE-09B | CORE-09 | MVP_STABLE | API | DONE | CORE-09A | CORE-09C | Durcir cleanup blob et abstraction storage. | Cleanup storage post-delete implémenté et testé côté API ; aucun changement UI. | `docs/core/CORE_09B_STORAGE_CLEANUP_APP_NOTE.md` |
| CORE-09C | CORE-09 | MVP_STABLE | App + API | DONE | CORE-09A | CORE-09B | Ajouter les APIs de lifecycle sujet/cours nécessaires à l'UX. | Renommer/archiver/supprimer safe disponibles via décisions backend, UI premium et hardening CORE-09C-bis. | `docs/core/CORE_09C_SUBJECT_COURSE_LIFECYCLE_APP_REPORT.md` |
| CORE-10A | CORE-10 | MVP_STABLE | App + API | DONE | CORE-09A | STAB-02A | Préparer la question bank en asynchrone. | Readiness affichée, preparation déclenchable, quick non bloquant, full Jest et full Flutter verts. | `docs/core/CORE_10A_ASYNC_QUESTION_BANK_READINESS_APP_REPORT.md` |
| CORE-10B | CORE-10 | MVP_STABLE | API | TODO | CORE-10A | CORE-11A | Sélection multi-KU et verrouillage concurrence. | Répartition robuste, pas de double réservation évidente. | À créer |
| CORE-10C | CORE-10 | MVP_STABLE | API | TODO | CORE-10B | ADAPT-01 | Découpler QuestionBankService et ajouter métriques qualité/coût. | Service testable, métriques exploitables. | À créer |
| CORE-11A | CORE-11 | MVP_STABLE | App + API | TODO | CORE-10A | CORE-10B, PLUS-01A | Sauvegarder brouillons de session et reprise. | Une session en cours peut être reprise après fermeture. | À créer |
| CORE-11B | CORE-11 | MVP_STABLE | App + API | TODO | CORE-11A | Aucun | Historique de sessions et détail des sessions terminées. | Historique utilisable sans rouvrir un quiz terminé. | À créer |
| PLUS-01A | PLUS-01 | MVP_PLUS | App + API | TODO | STAB-02A, CORE-10A, quick lifecycle stable | CORE-11A | Deep Revision course-level avec question ouverte V1. | Action open-question réelle, correction IA, pas de résultat deep complet si hors lot. | À créer |
| PLUS-01B | PLUS-01 | MVP_PLUS | App + API | TODO | PLUS-01A, CORE-11A | Aucun | Lifecycle, completion et résultat Deep. | Deep dispose d'un résultat cohérent et testable. | À créer |
| PLUS-02 | PLUS-02 | MVP_PLUS | App + API | TODO | STAB-02B, CORE-09A | PLUS-01A | Fiches complète et pré-examen réelles. | Les faux onglets ne mentent plus. | À créer |
| ADAPT-01 | ADAPT-01 | MVP_PLUS | App + API | TODO | CORE-10B | CORE-10C | Page Today et coach adaptatif. | Recommandation honnête basée sur données réelles. | À créer |
| PLUS-03 | PLUS-03 | POST_MVP | App + API | TODO | PLUS-01B, PLUS-02, CORE-11B | Aucun | Préparation examen V1. | Mode examen distinct, résultat distinct, sources adaptées. | À créer |
| GENUI-01 | GENUI-01 | POST_MVP | App + API | TODO | STAB-02B, ADAPT-01, PLUS-01A | Aucun | Surface GenUI contrôlée par catalogue. | Payloads validés, fallback sûr, aucun UI arbitraire. | À créer |
| RELEASE-01 | RELEASE-01 | RELEASE | App + API | TODO | QUALITY-00, lots MVP_STABLE requis | Aucun | Préparation production complète. | CI, stockage, secrets, monitoring, accessibilité et conformité prêts. | À créer |
