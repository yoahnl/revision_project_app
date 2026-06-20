# Roadmap V2 — Revision Project

Ce dossier contient la roadmap officielle V2 de Revision Project côté produit et Flutter.

La roadmap V2 existe pour remplacer mentalement les anciennes roadmaps dispersées sans les supprimer. Les rapports `docs/core/` et `docs/ui/` restent l'historique détaillé des lots déjà réalisés. La source de vérité stratégique devient ce dossier.

## Fichiers à lire

- `REVISION_PROJECT_ROADMAP_V2.md` : roadmap produit et technique canonique.
- `LOT_TRACKER_V2.md` : statut vivant des macro-lots.
- `EXECUTION_PLAN_V2.md` : découpage opérationnel des macro-lots en lots exécutables.
- `EXECUTION_LOT_TRACKER_V2.md` : statut vivant des lots exécutables.
- `UX_UI_TARGET_V2.md` : cible UX/UI, matrice de capacités et règles d'interface.
- `DECISIONS_V2.md` : journal canonique des décisions produit.
- `ROADMAP_UPDATE_PROTOCOL.md` : protocole de mise à jour après chaque lot.
- `STAB_00B_ROADMAP_V2_HARDENING_REPORT.md` : rapport du durcissement de la roadmap.

Le backend possède une roadmap alignée dans `revision_project_api/docs/roadmap/v2/`, mais la vision produit complète vit ici pour éviter deux narrations divergentes.

## Règle de maintenance

Après chaque lot, Codex doit mettre à jour au minimum :

- le tracker ;
- l'état réel actuel ;
- les risques ;
- les dépendances ;
- le prochain lot recommandé ;
- les liens vers les rapports créés.

Les anciennes roadmaps ne doivent pas être réécrites pour faire semblant que le projet a toujours suivi ce chemin. Elles restent des traces historiques.

## Source de vérité

Pour décider du prochain lot, lire dans cet ordre :

1. `REVISION_PROJECT_ROADMAP_V2.md`
2. `LOT_TRACKER_V2.md`
3. `EXECUTION_PLAN_V2.md`
4. `EXECUTION_LOT_TRACKER_V2.md`
5. `UX_UI_TARGET_V2.md`
6. `DECISIONS_V2.md`
7. `ROADMAP_UPDATE_PROTOCOL.md`
8. le rapport du dernier lot terminé

## Référence visuelle V2

La planche visuelle canonique doit vivre à terme dans :

```text
docs/roadmap/v2/assets/revision_project_ui_v2_board.png
```

Si elle n'est pas encore présente, `docs/roadmap/v2/assets/README.md` reste la source de vérité sur son statut. Aucune image de remplacement ne doit être inventée.
