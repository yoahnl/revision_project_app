# Frontend Canonical / Legacy Inventory V2

Ce document classe les routes et surfaces Flutter après STAB-02B. Il ne supprime pas l'historique : il précise ce qui compose le parcours produit actuel, ce qui reste utile en support, et ce qui est conservé comme legacy accessible.

## Parcours Canonique

```text
Accueil
-> cours
-> sources du cours / fiche / revision rapide
-> session quick
-> resultat quick
-> cours ou fiche
-> progres
```

```text
Reviser
-> quick direct
-> session quick
-> resultat quick
```

```text
Progres
-> cours
-> quick / fiche / sources
```

## Classification

| Element | Type | Statut | Accessible depuis | Destination cible | Decision |
| --- | --- | --- | --- | --- | --- |
| `/home` | Route shell | CANONICAL | Bottom nav Accueil | Accueil matiere active | Conserve comme entree principale. |
| `/progress` | Route shell | CANONICAL | Bottom nav Progres | Progression matiere active | Conserve comme entree principale. |
| `/revisions` | Route shell | CANONICAL | Bottom nav Reviser, detail matiere | Hub Reviser canonique | Conserve comme entree principale. |
| `/profile` | Route shell | CANONICAL | Bottom nav Profil | Profil utilisateur | Conserve comme entree principale. |
| `/courses/:courseId` | Route shell | CANONICAL | Accueil, Progres, Reviser | Detail cours | Conserve. |
| `/courses/:courseId/sheet` | Route shell | CANONICAL | Detail cours, resultat | Fiche rapide de cours | Conserve. |
| `/courses/:courseId/sheet/sources` | Route shell | CANONICAL | Fiche | Sources de fiche | Conserve. |
| `/revision-sessions/:sessionId` | Route immersive | CANONICAL | Quick course-level | Session quick | Conserve hors shell. |
| `/revision-sessions/:sessionId/result` | Route immersive | CANONICAL | Fin de session quick | Resultat quick | Conserve hors shell. |
| `/` | Route redirect | SUPPORT | Deep link racine | `/home` | Conserve. |
| `/sign-in` | Route hors shell | SUPPORT | Auth | Connexion Neralune | Conserve. |
| `/onboarding` | Route hors shell | SUPPORT | Premier lancement / creation matiere | Onboarding | Conserve. |
| `/subjects` | Route shell | SUPPORT | Profil / deep link | Gestion matieres | Conserve, mais pas dans la bottom nav. |
| `/subjects/:subjectId` | Route shell | SUPPORT | Gestion matieres | Detail matiere | Conserve. CTA `Reviser` redirige maintenant vers `/revisions`. |
| `/subjects/:subjectId/documents/:documentId` | Route shell | LEGACY_ACCESSIBLE | Detail matiere / deep link | Detail document subject-level | Conserve pour compatibilite ; ne fait pas partie du parcours principal cours. |
| `/sources` | Route immersive placeholder | SUPPORT | Deep link | Message d'orientation vers cours | Conserve comme transition ; la source principale vit dans le cours. |
| `/today` | Route shell | LEGACY_ACCESSIBLE | Deep link | Today historique | Conserve hors navigation principale ; ADAPT-01 decidera sa cible. |
| `/activities` | Route shell | LEGACY_ACCESSIBLE | Deep link | Activites historiques | Conserve hors navigation principale. |
| `/activities/session` | Route immersive legacy | LEGACY_ACCESSIBLE | Deep link historique | Ancienne session activities | Conserve pour compatibilite. |
| `/activities/rich-closed` | Route immersive legacy | LEGACY_ACCESSIBLE | Deep link historique | Rich closed historique | Conserve pour compatibilite. |
| `AppRoutes.revisionSessionSegment` | Constante | DEAD_CANDIDATE | Aucune reference trouvee | Aucune | Candidate a suppression ulterieure ; non supprimee dans STAB-02B. |

## Legacy Components Still Referenced

| Composant | References | Motif de conservation | Lot de suppression / migration |
| --- | --- | --- | --- |
| `presentation/theme/*` | Activities, Today, RichClosed, certains widgets historiques | Encore requis par les routes legacy conservees. | STAB-02B+ ou lot dedie legacy cleanup. |
| `RevisionPanel` / `RevisionPage` | Routes Activities / Today / RichClosed et tests associes | Composants historiques encore compiles et testes. | Migration legacy ulterieure si ces routes restent visibles. |
| `presentation/widgets/documents/DocumentImportButton` | Detail matiere | Widget support existant, non canonique course-level mais utile a la gestion matiere. | CORE-09C ou STAB-02B+ selon evolution matieres/documents. |
| `core/routing/route_paths.dart` | Compatibility layer pour anciennes pages | Evite un rewrite global et garde les routes historiques stables. | Suppression possible apres migration complete des callers. |

## Assets

| Asset | Statut | Decision |
| --- | --- | --- |
| `assets/brand/neralune_cat_body.svg` | Utilise | Conserve par `NeraluneAnimatedLogo`. |
| `assets/brand/neralune_cat_tail.svg` | Utilise | Conserve par `NeraluneAnimatedLogo`. |
| `assets/brand/google_g.svg` | Utilise | Conserve par le bouton Google. |
| `assets/brand/neralune_cat.svg` | BRAND_SOURCE | Non reference par le code, mais conserve comme source complete de marque. |

## Decisions STAB-02B

- Le parcours canonique ne navigue plus accidentellement vers `/activities` depuis le detail matiere.
- Les routes legacy restent accessibles directement.
- Les liens juridiques de la page de connexion restent inchanges, conformement a la decision produit.
- Aucun backend, contrat HTTP, identifiant natif, CocoaPods ou Xcode Cloud n'a ete modifie.
