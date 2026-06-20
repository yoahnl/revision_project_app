# Roadmap V2 — Revision Project

Ce dossier contient la roadmap officielle V2 de Revision Project côté produit et Flutter.

La roadmap V2 existe pour remplacer mentalement les anciennes roadmaps dispersées sans les supprimer. Les rapports `docs/core/` et `docs/ui/` restent l'historique détaillé des lots déjà réalisés. La source de vérité stratégique devient ce dossier.

## Fichiers à lire

- `REVISION_PROJECT_ROADMAP_V2.md` : roadmap produit et technique canonique.
- `UX_UI_TARGET_V2.md` : cible UX/UI et règles d'interface.
- `LOT_TRACKER_V2.md` : statut vivant des lots.
- `ROADMAP_UPDATE_PROTOCOL.md` : protocole de mise à jour après chaque lot.

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
3. `UX_UI_TARGET_V2.md`
4. le rapport du dernier lot terminé

