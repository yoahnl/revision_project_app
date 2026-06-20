# Lot Tracker V2

Statuts autorisés : `TODO`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `DEFERRED`, `REPLACED`.

| Lot | Titre | Repo(s) | Statut | Dépend de | Objectif | Validation | Rapport |
| --- | --- | --- | --- | --- | --- | --- | --- |
| STAB-00 | Roadmap V2 canonicalisation | App + API | DONE | Aucun | Créer la source de vérité V2 et le protocole de mise à jour | Documents V2 créés dans les deux repos | `docs/roadmap/v2/` |
| STAB-01 | Product navigation & UX coherence | App | TODO | STAB-00 | Corriger la navigation, les faux affordances et les parcours confus | Tests router/widget + smoke visuel | À créer |
| STAB-02 | Frontend design system unification | App | TODO | STAB-01 | Unifier les écrans legacy et premium | Tests UI ciblés + anti-régression | À créer |
| CORE-09 | Source lifecycle & storage policy | API + App | TODO | STAB-01 | Sécuriser archive/suppression de sources et préparer le stockage production | Tests Prisma + API + UI | À créer |
| CORE-10 | Question bank production hardening | API + App | TODO | CORE-09 | Rendre la banque de questions robuste et moins synchrone | Tests génération, sélection, concurrence | À créer |
| CORE-11 | Session resume & history | API + App | TODO | CORE-10 | Reprise de session et historique utilisateur | Tests lifecycle + navigation | À créer |
| PLUS-01 | Deep Revision course-level | API + App | TODO | STAB-02, CORE-11 | Activer la révision approfondie réelle | Tests open question + correction IA | À créer |
| PLUS-02 | Revision sheet complete / exam modes | API + App | TODO | PLUS-01 | Remplacer les faux onglets fiche par de vrais contenus | Tests fiche complète/examen | À créer |
| PLUS-03 | Exam preparation V1 | API + App | TODO | PLUS-02 | Créer un vrai mode préparation examen | Tests session exam + résultat | À créer |
| ADAPT-01 | Today / adaptive coach | API + App | TODO | CORE-11 | Guider l'utilisateur vers la prochaine action utile | Tests recommandation + UI Today | À créer |
| GENUI-01 | Controlled GenUI surface | API + App | TODO | STAB-02, ADAPT-01 | Réintroduire GenUI avec widgets strictement contrôlés | Validation payload + fallback | À créer |
| RELEASE-01 | Production readiness | API + App + Infra | TODO | Lots MVP validés | Préparer CI, monitoring, stockage et exploitation | Checklist release complète | À créer |

