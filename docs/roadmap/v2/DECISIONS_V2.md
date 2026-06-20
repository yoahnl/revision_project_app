# Decisions V2

Ce journal est canonique côté produit. Le repo API pointe vers ce fichier au lieu de maintenir un doublon.

Statuts autorisés : `PROPOSED`, `ACCEPTED`, `REJECTED`, `SUPERSEDED`.

| ID | Décision | Statut | Date | Motif | Impact | Lot |
| --- | --- | --- | --- | --- | --- | --- |
| DEC-001 | La roadmap produit canonique vit dans le repo app. | ACCEPTED | 2026-06-20 | La roadmap décrit aussi l'UX, les écrans et le wording produit. | Le repo API garde une roadmap backend alignée, sans dupliquer toute la vision. | STAB-00 |
| DEC-002 | L'application affiche une seule matière active à la fois. | ACCEPTED | 2026-06-20 | Le produit doit rester lisible et orienté "une matière, des cours, des sources". | Le shell et la home doivent éviter les dashboards multi-matières prématurés. | STAB-01A |
| DEC-003 | La navigation cible est de quatre onglets. | PROPOSED | 2026-06-20 | L'onglet Sources global est peu actionnable tant que les sources vivent dans les cours. | À valider avant STAB-01A pour éviter de refaire le shell deux fois. | STAB-01A |
| DEC-004 | Sources vit d'abord dans les cours. | ACCEPTED | 2026-06-20 | Les sources sont attachées à un cours et pilotent fiche, quick et progression. | La page Sources globale doit être informative ou devenir une vraie bibliothèque plus tard. | CORE-09A |
| DEC-005 | Today ne devient pas l'accueil avant une vraie recommandation. | PROPOSED | 2026-06-20 | Un "Aujourd'hui" sans moteur adaptatif deviendrait une façade trompeuse. | Today attend ADAPT-01 ou reste hors navigation principale. | ADAPT-01 |
| DEC-006 | Les modes non disponibles sont masqués ou clairement verrouillés. | ACCEPTED | 2026-06-20 | Un bouton visible doit avoir un contrat honnête. | Les labels utilisateur ne doivent plus dire `MVP+`. | STAB-01B |
| DEC-007 | Macro-lots et lots exécutables sont suivis séparément. | ACCEPTED | 2026-06-20 | Les macro-lots sont utiles stratégiquement mais trop gros pour un prompt unique. | Deux trackers sont maintenus : stratégique et exécutable. | STAB-00B |
| DEC-008 | La CI baseline arrive avant les gros refactors. | ACCEPTED | 2026-06-20 | Les refactors de shell/design/lifecycle ont besoin d'une preuve reproductible. | QUALITY-00 dépend seulement de STAB-00B et peut avancer en parallèle de STAB-01A. | QUALITY-00 |
| DEC-009 | Une source utilisée doit être archivée plutôt que supprimée naïvement. | PROPOSED | 2026-06-20 | Les sessions, questions, fiches et résultats doivent garder leur historique pédagogique. | CORE-09A doit trancher archive/delete avant d'élargir les flows. | CORE-09A |
| DEC-010 | La planche UI V2 est la référence visuelle canonique. | PROPOSED | 2026-06-20 | L'asset final n'est pas encore présent dans `docs/roadmap/v2/assets`. | Dès ajout de l'image, elle devient référence de direction visuelle sans autoriser de données fictives. | STAB-01A |
