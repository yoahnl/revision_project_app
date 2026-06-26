# LOCK-01 — MVP Demo Lock — Evidence Pack

## 1. Objectif

Créer un document de cadrage court et autoritaire pour verrouiller le MVP démo Neralune V4, réduire le scope creep et guider les prochains lots Codex vers un seul flow montrable.

## 2. Pourquoi ce lock était nécessaire

La V4 a déjà une direction produit solide : Aujourd'hui, Cours, Détail cours et learning path convergent vers une boucle de révision guidée. Le risque principal est maintenant de rouvrir trop de chantiers avant d'avoir une démo simple, fluide et convaincante.

Le lock évite que les prochains lots ajoutent sujet long, épreuve blanche, nouveau backend, nouveaux modes ou surfaces secondaires avant que la boucle principale soit stable.

## 3. Fichiers créés

- `docs/roadmap/v4/MVP_DEMO_LOCK.md`
- `docs/roadmap/v4/evidence/LOCK-01_mvp_demo_lock_EVIDENCE_PACK.md`

## 4. Fichiers modifiés

- `docs/roadmap/v4/EXECUTION_TRACKER_V4.md`

## 5. Décisions prises

- Le flow démo canonique devient : Aujourd'hui → Cours → Détail cours → choix durée → session courte → feedback → bilan.
- Les prochains lots autorisés sont limités à `DEMO-01` à `DEMO-05`.
- `DEMO-01` correspond à `V4-04B` et est déjà livré au moment du lock.
- Les lots avant démo doivent refuser les nouvelles surfaces principales, les modes avancés et les backends "au cas où".
- Un lot qui dépasse 8 fichiers de code modifiés doit justifier le volume ou proposer un découpage plus petit.

## 6. Lots autorisés avant démo

1. `DEMO-01 — Brancher le learning path dans le détail cours`
2. `DEMO-02 — Choix durée simple 5 / 15 / 30`
3. `DEMO-03 — Session immersive quick-only`
4. `DEMO-04 — Feedback + bilan propre`
5. `DEMO-05 — Polish démo + Luna légère`

## 7. Fonctionnalités reportées

- Sujet long
- Épreuve blanche
- Préparation examen complète
- Fiche complète multi-source
- Mode examen
- Bibliothèque globale des sources
- Page GenUI dédiée
- Historique complet
- Progrès avancé
- Mascot system complet
- Paramètres avancés
- Gestion avancée des matières
- Répétition espacée
- Hardening production

## 8. Tests / vérifications

| Commande | Résultat | Notes |
| --- | --- | --- |
| `git diff --check` | PASS | Aucun whitespace error. |
| `git status --short` | PASS | Uniquement `EXECUTION_TRACKER_V4.md`, `MVP_DEMO_LOCK.md` et cet evidence pack. |

Markdown lint : aucune commande Markdown lint existante n'a été trouvée dans le repo, et aucune dépendance de lint n'a été ajoutée.

## 9. Risques restants

- Le tracker conserve la roadmap V4 complète ; il faudra continuer à rappeler que le lock prime pour les lots avant démo.
- `DEMO-01` est déjà livré sous l'identifiant `V4-04B`, ce qui peut créer une double nomenclature si les prompts ne mentionnent pas explicitement la correspondance.
- Le prochain lot exécutable est `DEMO-02`, même si le lock liste `DEMO-01` comme premier lot autorisé.

## 10. Prochain lot recommandé

`DEMO-01 — Brancher le learning path dans le détail cours`

Correspondance : `V4-04B — Learning path frontend timeline`.

Statut réel au moment du lock : livré. Le prochain lot exécutable devient donc `DEMO-02 — Choix durée simple 5 / 15 / 30`.
