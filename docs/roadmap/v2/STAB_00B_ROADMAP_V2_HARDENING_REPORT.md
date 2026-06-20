# STAB-00B — Roadmap V2 Hardening Report

## 1. Résumé

STAB-00B durcit la Roadmap V2 sans la réécrire depuis zéro. Le lot conserve les macro-lots stratégiques, ajoute une couche de lots exécutables, introduit les horizons produit, ajoute `QUALITY-00`, crée un journal de décisions canonique et clarifie la synchronisation App/API.

## 2. Audit initial

Fichiers relus côté app :

- `docs/roadmap/v2/README.md`
- `docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md`
- `docs/roadmap/v2/UX_UI_TARGET_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/ROADMAP_UPDATE_PROTOCOL.md`
- `docs/ui/UI_01_PREMIUM_VISUAL_FOUNDATION_REPORT.md`
- `docs/ui/UI_02_QUICK_REVISION_SESSION_RESULT_REPORT.md`
- `docs/ui/UI_02B_QUICK_REVISION_HARDENING_REPORT.md`
- `docs/ui/REVISION_PROJECT_UI_TARGET.md`

Fichiers relus côté API :

- `docs/roadmap/v2/README.md`
- `docs/roadmap/v2/API_ROADMAP_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/ROADMAP_UPDATE_PROTOCOL.md`
- `docs/core/CORE_06_REAL_PROGRESS_REPORT.md`
- `docs/core/CORE_07_QUICK_REVISION_LIFECYCLE_RESULT_REPORT.md`
- `docs/core/CORE_07B_QUICK_REVISION_HARDENING_REPORT.md`

Constats principaux :

- Les macro-lots étaient pertinents mais trop gros pour être exécutés directement.
- La CI apparaissait surtout dans `RELEASE-01`, trop tard pour protéger les refactors.
- `PLUS-01` dépendait trop strictement de tout `CORE-11`.
- Le statut `REPLACED` n'était pas assez défini.
- Les capacités UX nécessitant une API n'étaient pas assez explicites.
- La référence visuelle UI V2 n'avait pas de place canonique documentée.

## 3. Passes/sub-agents utilisées

- Roadmap Audit Agent : cohérence des deux dossiers, doublons, dépendances trop strictes.
- Execution Planning Agent : découpage des macro-lots en lots exécutables et graphe non linéaire.
- UX Governance Agent : matrice `AVAILABLE_NOW` / `NEEDS_API` / `FUTURE` et référence UI.
- Quality Governance Agent : introduction de `QUALITY-00` et preuves attendues.
- Reviewer Agent : vérification de périmètre documentaire et synchronisation App/API.

## 4. Problèmes corrigés

- Ajout d'une couche de lots exécutables.
- Ajout d'une colonne `Horizon`.
- Ajout de `QUALITY-00`.
- Clarification du `MVP_STABLE`.
- Définition de `REPLACED`.
- Ajout des règles d'agrégation macro-lots.
- Ajout d'un journal de décisions.
- Ajout d'une matrice de capacités UX/API.
- Documentation de l'asset UI V2 attendu.

## 5. Macro-lots conservés

Les macro-lots restent les parents stratégiques :

- `STAB-00`
- `STAB-01`
- `STAB-02`
- `CORE-09`
- `CORE-10`
- `CORE-11`
- `PLUS-01`
- `PLUS-02`
- `PLUS-03`
- `ADAPT-01`
- `GENUI-01`
- `RELEASE-01`

Ajouts :

- `STAB-00B`
- `QUALITY-00`

## 6. Lots exécutables créés

- `STAB-00B`
- `QUALITY-00`
- `STAB-01A`
- `STAB-01B`
- `STAB-01C`
- `STAB-02A`
- `STAB-02B`
- `CORE-09A`
- `CORE-09B`
- `CORE-09C`
- `CORE-10A`
- `CORE-10B`
- `CORE-10C`
- `CORE-11A`
- `CORE-11B`
- `PLUS-01A`
- `PLUS-01B`
- `PLUS-02`
- `ADAPT-01`
- `PLUS-03`
- `GENUI-01`
- `RELEASE-01`

## 7. Nouveau graphe de dépendances

Le graphe complet est dans `EXECUTION_PLAN_V2.md`. Les corrections clés :

- `QUALITY-00` dépend de `STAB-00B`, pas de `RELEASE-01`.
- `QUALITY-00` peut avancer en parallèle de `STAB-01A`.
- `PLUS-01A` dépend de `STAB-02A`, `CORE-10A` et du quick lifecycle stable.
- `PLUS-01A` ne dépend plus de tout `CORE-11`.
- `PLUS-02` peut avancer après `STAB-02B` et `CORE-09A`, sans attendre toute la Deep Revision.

## 8. Horizons

Horizons ajoutés :

- `FOUNDATION`
- `MVP_STABLE`
- `MVP_PLUS`
- `POST_MVP`
- `RELEASE`

## 9. QUALITY-00

`QUALITY-00 — CI baseline` est ajouté pour installer tôt une preuve automatisée minimale : analyse Flutter, tests Flutter, build/lint/tests API, e2e critiques, Prisma validate et vérification de diff.

## 10. Journal de décisions

`DECISIONS_V2.md` est créé côté app comme journal canonique.

Décisions initiales :

- `DEC-001` à `DEC-010`.
- Les décisions explicitement stables sont `ACCEPTED`.
- Les arbitrages encore produit sont `PROPOSED`.

## 11. Matrice de capacités UX

`UX_UI_TARGET_V2.md` contient maintenant une matrice :

- `AVAILABLE_NOW`
- `NEEDS_API`
- `FUTURE`

Elle empêche de créer une action utilisateur active sans contrat backend correspondant.

## 12. Gestion de la référence UI

Asset attendu :

```text
docs/roadmap/v2/assets/revision_project_ui_v2_board.png
```

Statut : manquant dans ce lot. Le fichier `docs/roadmap/v2/assets/README.md` documente l'attente. Aucune image n'a été inventée.

## 13. Synchronisation App/API

La vision produit canonique reste côté app. Le repo API possède :

- son plan exécutable backend ;
- son tracker synchronisé ;
- ses risques et validations backend ;
- un pointeur vers le journal de décisions côté app.

## 14. Fichiers créés

- `docs/roadmap/v2/EXECUTION_PLAN_V2.md`
- `docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md`
- `docs/roadmap/v2/DECISIONS_V2.md`
- `docs/roadmap/v2/assets/README.md`
- `docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md`

## 15. Fichiers modifiés

- `docs/roadmap/v2/README.md`
- `docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md`
- `docs/roadmap/v2/UX_UI_TARGET_V2.md`
- `docs/roadmap/v2/LOT_TRACKER_V2.md`
- `docs/roadmap/v2/ROADMAP_UPDATE_PROTOCOL.md`

## 16. Commandes exécutées

Commandes exécutées dans `/Users/karim/Project/app-révision/revision_app` :

```bash
git diff --check
git status --short --untracked-files=all
test -f docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md
test -f docs/roadmap/v2/UX_UI_TARGET_V2.md
test -f docs/roadmap/v2/LOT_TRACKER_V2.md
test -f docs/roadmap/v2/EXECUTION_PLAN_V2.md
test -f docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md
test -f docs/roadmap/v2/DECISIONS_V2.md
test -f docs/roadmap/v2/ROADMAP_UPDATE_PROTOCOL.md
rg -n "STAB-00B|QUALITY-00|STAB-01A|STAB-01B|STAB-01C|STAB-02A|STAB-02B|CORE-09A|CORE-10A|CORE-11A|PLUS-01A" docs/roadmap/v2
rg -n "FOUNDATION|MVP_STABLE|MVP_PLUS|POST_MVP|RELEASE" docs/roadmap/v2
rg -n "PROPOSED|ACCEPTED|REJECTED|SUPERSEDED" docs/roadmap/v2
```

Résultats :

- `git diff --check` : succès, aucune sortie.
- `git status --short --untracked-files=all` :

```text
 M docs/roadmap/v2/LOT_TRACKER_V2.md
 M docs/roadmap/v2/README.md
 M docs/roadmap/v2/REVISION_PROJECT_ROADMAP_V2.md
 M docs/roadmap/v2/ROADMAP_UPDATE_PROTOCOL.md
 M docs/roadmap/v2/UX_UI_TARGET_V2.md
?? docs/roadmap/v2/DECISIONS_V2.md
?? docs/roadmap/v2/EXECUTION_LOT_TRACKER_V2.md
?? docs/roadmap/v2/EXECUTION_PLAN_V2.md
?? docs/roadmap/v2/STAB_00B_ROADMAP_V2_HARDENING_REPORT.md
?? docs/roadmap/v2/assets/README.md
```

- Tous les `test -f` : succès, aucune sortie.
- `rg` IDs : succès, occurrences trouvées dans les trackers, la roadmap, le plan d'exécution, le protocole, la cible UX, le journal de décisions et le rapport.
- `rg` horizons : succès, occurrences trouvées dans les trackers, la roadmap, le plan d'exécution et le rapport.
- `rg` statuts de décisions : succès, occurrences trouvées dans `DECISIONS_V2.md` et le rapport.

Suites applicatives non lancées conformément au périmètre documentaire.

## 17. Limites

- La planche UI V2 n'est pas encore intégrée car l'asset n'était pas présent dans ce lot.
- Les décisions `PROPOSED` doivent être validées par Yoahn avant d'être considérées stables.
- Le plan d'exécution reste une base de pilotage ; chaque lot aura encore besoin d'un prompt précis.

## 18. Points restant à valider par Yoahn

- Navigation cible à quatre onglets ou maintien temporaire de cinq onglets.
- Statut final de l'onglet Sources global.
- Moment exact où Today peut devenir page principale.
- Politique finale archive vs suppression pour les sources utilisées.
- Intégration de la planche UI V2 comme asset canonique.

## 19. Auto-review

- STAB-00 reste `DONE`.
- STAB-00B est ajouté.
- QUALITY-00 existe.
- Les macro-lots sont conservés.
- Les lots exécutables sont séparés.
- Les horizons sont présents.
- Les dépendances ne sont plus strictement linéaires.
- `PLUS-01A` ne dépend plus de tout `CORE-11`.
- `REPLACED` et l'agrégation macro sont définis.
- La matrice UX/API existe.
- Aucun runtime n'a été modifié.

## 20. Confirmation runtime

Aucun code runtime n'a été modifié.

## 21. Confirmation Git

Aucun commit n'a été effectué.
