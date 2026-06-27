# Screen Target Matrix V5

Reference audit :

```text
output/product-audit/neralune-full-app-2026-06-27/report.md
output/product-audit/neralune-full-app-2026-06-27/screenshots/
```

Reference maquette :

```text
/Users/karim/.codex/attachments/6a4186fc-da51-4acc-b201-ff0cde524df6/image-1.png
```

| Ecran cible | Etat actuel | Ecart principal | Priorite | Lot recommande | Capture actuelle | Capture cible | Statut |
|---|---|---|---|---|---|---|---|
| Onboarding | Alignement actuel : moyen/faible. Login initial corrige, mais route onboarding utilitaire. | La maquette attend une introduction emotionnelle Neralune avant le setup matiere. | P3 | V5-12 | `01-sign-in-initial.png`, `02-sign-in-email-form.png`, `47-dark-onboarding-route.png` | Maquette ecran 1 | `NOT_STARTED` |
| Aujourd'hui | Alignement actuel : faible. Dark propre, mais "rien de pret" alors qu'un cours/fiche existe. | Ne joue pas encore le role de coach quotidien avec mission, fallback et objectif. | P1 | V5-04 apres V5-01 | `10-dark-today.png` | Maquette ecran 2 | `BLOCKED_BY_V5-01` |
| Cours | Alignement actuel : moyen/bon. Structure proche avec selecteur, carte globale et liste. | Contenu trop pauvre et pas assez oriente progression/action. | P1 | V5-05 | `11-dark-courses-home.png` | Maquette ecran 3 | `NOT_STARTED` |
| Detail cours | Alignement actuel : moyen. Parcours visible mais froid, technique, progression 0%. | Doit devenir un parcours gamifie avec checkpoints, CTA contextuel et labels humains. | P1 | V5-05 | `12-dark-course-detail.png` | Maquette ecran 4 | `NOT_STARTED` |
| Selecteur matiere | Alignement actuel : bon. Bottom sheet clair et proche. | Reste a verifier dans le flow V5 avec etats et dark QA. | P2 | V5-04/V5-05 selon entree | `29-dark-course-subject-selector.png` | Maquette ecran 5 | `WATCH` |
| Choix duree | Alignement actuel : faible dans l'audit, car le flow quick a bloque avant session. | Doit respecter l'etat questions pretes/preparing et ne pas exposer `questionCount`. | P1 | V5-07 apres V5-01 | `26-dark-revisions-before-start.png`, `27-dark-session-after-start.png` | Maquette ecran 6 | `BLOCKED_BY_V5-01` |
| Session question | Alignement actuel : partiel. Session quick existe en V4, mais audit atteint surtout QCM bloque/question ouverte. | Doit etre accessible depuis le flow principal et proche de la maquette tactile. | P1 | V5-08 | `28-dark-activities-subject-waited.png`, `36-dark-open-question-from-document.png`, `46-dark-qcm-notion-attempt.png` | Maquette ecran 7 | `NOT_STARTED` |
| Feedback reponse | Alignement actuel : moyen. Correction ouverte existe mais longue et lente. | Doit devenir court, immediat, structure et relie a la fiche/source. | P1 | V5-09 | `42-dark-open-question-correction-after-wait.png`, `43-dark-open-question-correction-scrolled.png`, `44-dark-open-question-correction-bottom.png`, `45-dark-open-question-correction-end.png` | Maquette ecran 8 | `NOT_STARTED` |
| Bilan resultat | Alignement actuel : non verifie dans l'audit visuel, mais bilan V4 existe via tests. | Doit etre atteignable depuis le flow et montrer victoire/prochaine action. | P1 | V5-10 | Audit : non atteint via quick bloque ; V4 result a verifier en nouvelle capture | Maquette ecran 9 | `NEEDS_CAPTURE` |
| Progres | Alignement actuel : moyen. Structure presente, tout a 0%. | Doit etre motivant meme low-data et expliquer le depart. | P2 | V5-11 | `15-dark-progress.png` | Maquette ecran 10 | `NOT_STARTED` |
| Fiche | Alignement actuel : bon potentiel. Meilleur morceau actuel. | Doit devenir premium, sectionnee, actionnable, avec CTA et sources mieux integrees. | P1 | V5-06 | `13-dark-course-sheet.png` | Reference fiche V5 interne + maquette flow | `NOT_STARTED` |
| Sources fiche | Alignement actuel : faible/moyen. Sources longues, lisibilite faible. | Doivent etre pliables, citees, humaines, sans dump brut. | P1 | V5-03 puis V5-06 | `14-dark-course-sheet-sources.png` | Reference fiche V5 interne | `NOT_STARTED` |
| Profil | Alignement actuel : moyen. Propre, mais theme "Systeme". | Dark mode cible doit etre explicite ou force pendant V5. | P2 | V5-11/V5-12 | `16-dark-profile.png` | Maquette dark systeme | `WATCH` |
| Pages legacy / parking | Alignement actuel : bloquant/faible. Sources globales parking, Activites spinner, Reviser CTA fragile. | Doivent etre masquees, stabilisees ou redirigees vers une action utile. | P0 | V5-02 | `19-dark-sources-pending.png`, `20-dark-revisions-pending.png`, `21-dark-activities.png`, `28-dark-activities-subject-waited.png` | Pas dans la maquette coeur | `READY_FOR_FIX` |

## Lecture rapide

Priorite P0 :

- V5-01 pour les CTA honnetes et etats de preparation.
- V5-02 pour les spinners et pages legacy.
- V5-03 pour les noms de sources/PDF.

Priorite P1 :

- V5-04 Today coach.
- V5-05 detail cours gamifie.
- V5-06 fiche premium.
- V5-07 a V5-10 boucle revision.

Priorite P2/P3 :

- V5-11 Progres.
- V5-12 Onboarding emotionnel.

Ecran le plus solide aujourd'hui :

```text
Fiche de revision
```

Ecran le plus urgent pour la confiance :

```text
CTA revision rapide / questions en preparation
```
