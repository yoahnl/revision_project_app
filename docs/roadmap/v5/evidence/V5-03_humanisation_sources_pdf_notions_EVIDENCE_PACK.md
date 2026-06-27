# V5-03 — Humanisation sources / PDF / notions — Evidence Pack

## 1. Objectif

Retirer l'effet pipeline technique des surfaces coeur : les parcours, fiches, sources, matieres et details document doivent afficher des labels humains comme `Support 1`, pas des noms de fichiers bruts comme `1782570835662-support01.pdf`.

Verdict fonctionnel : `VALIDÉ`.

## 2. Maquette utilisée

Maquette source :

- `/Users/karim/.codex/attachments/6a4186fc-da51-4acc-b201-ff0cde524df6/image-1.png`

Copie d'evidence :

- `docs/roadmap/v5/evidence/screenshots/V5-03/target/mockup-reference.png`

Verification :

- SHA-256 identique entre la maquette source et la copie d'evidence.
- Dimensions de la copie cible : `1672 x 941`.

Ecrans de reference concernes :

- Detail cours
- Fiche
- Sources fiche
- Detail matiere
- Detail document

## 3. Rappel du problème

L'audit V5 montrait des noms de PDF utilises comme titres, metadata ou libelles de parcours :

- `1782570835662-support01.pdf`
- `support01.pdf`
- timestamps visibles
- extensions `.pdf` dans des titres principaux
- impression d'un pipeline technique au lieu d'un objet pedagogique

Le produit attendu doit dire : support, extrait, notion, fiche. Il ne doit pas exposer les artefacts d'import comme surface principale.

## 4. Stratégie de label humain

La logique centralisee vit dans :

- `lib/features/courses/presentation/utils/course_source_display_label.dart`

Ordre de decision :

1. Utiliser un titre humain existant quand il est disponible et non technique.
2. Nettoyer un nom exploitable sans inventer de sens pedagogique : `intro-droit.pdf` devient `Intro droit`.
3. Transformer les noms techniques en label neutre : `1782570835662-support01.pdf` devient `Support 1`.
4. Garder le nom original uniquement en secondaire via `Fichier original : ...`.

La logique refuse les tokens techniques cote utilisateur principal : `documentId`, `sourceId`, `chunkId`, `backend`, `payload`, `uuid`, `legacy`, `GenUI`, `Prisma`.

Aucun titre pedagogique n'est invente : si la donnee ne dit pas qu'un support parle d'un sujet, le fallback reste neutre.

## 5. Résumé des changements

- Ajout d'un helper central `SourceDisplayLabel`.
- Humanisation des sources dans le detail cours, la fiche, les sources de fiche, le detail matiere, le detail document et les bottom sheets de sources.
- Conservation du fichier original uniquement dans une ligne secondaire explicite.
- Humanisation des labels de source sur les pages de revision approfondie/rich revision quand elles affichent une provenance.
- Renforcement des tests pour verifier l'absence de filename brut dans les titres principaux et la presence controlee du fichier original.
- Regeneration des captures mobiles dark before/after/target pour V5-03.

## 6. Fichiers modifiés

Production :

- `lib/features/courses/presentation/course_deep_revision_page.dart`
- `lib/features/courses/presentation/course_deep_revision_result_page.dart`
- `lib/features/courses/presentation/course_detail_page.dart`
- `lib/features/courses/presentation/course_revision_sheet_page.dart`
- `lib/features/courses/presentation/course_rich_revision_page.dart`
- `lib/features/courses/presentation/widgets/course_sources_bottom_sheet.dart`
- `lib/presentation/pages/documents/document_detail_page.dart`
- `lib/presentation/pages/subjects/subject_detail_page.dart`
- `lib/presentation/pages/subjects/widgets/subject_document_list_item.dart`

Tests :

- `test/app/revision_app_test.dart`
- `test/app/router/app_router_test.dart`
- `test/features/courses/course_deep_revision_page_test.dart`
- `test/features/courses/course_deep_revision_result_page_test.dart`
- `test/features/courses/course_detail_page_test.dart`
- `test/features/courses/course_revision_sheet_page_test.dart`
- `test/features/courses/course_rich_revision_page_test.dart`
- `test/features/documents/document_detail_page_test.dart`
- `test/features/subjects/subject_detail_page_test.dart`

## 7. Fichiers créés

- `lib/features/courses/presentation/utils/course_source_display_label.dart`
- `test/features/courses/course_source_display_label_test.dart`
- `docs/roadmap/v5/evidence/V5-03_humanisation_sources_pdf_notions_EVIDENCE_PACK.md`
- `docs/roadmap/v5/evidence/screenshots/V5-03/`

## 8. Surfaces couvertes

| Surface | Couverture |
|---|---|
| Detail cours | Le parcours de notions humanise les labels issus d'un filename technique. |
| Fiche | Le hero/source de fiche affiche `Support 1`, avec le fichier original en secondaire. |
| Sources fiche | Les cartes de sources utilisent un label humain et gardent `Fichier original` en detail. |
| Detail matiere | Les documents listes utilisent `Support N` ou un titre nettoye. |
| Detail document | Le titre principal est humanise ; le filename reste secondaire. |
| Bottom sheets sources | Les actions gerer/supprimer/archiver utilisent le label humain. |
| Revision approfondie/rich | Les libelles de provenance courts passent par le helper humanisant. |

## 9. Captures visuelles

Toutes les captures `before` et `after` sont en dark mode mobile `390 x 844`.

Before :

- `docs/roadmap/v5/evidence/screenshots/V5-03/before/course-detail-filename.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/before/course-sheet-source-filename.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/before/course-sheet-sources-filename.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/before/subject-detail-filename.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/before/document-detail-filename.png`

After :

- `docs/roadmap/v5/evidence/screenshots/V5-03/after/course-detail-human-source.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/after/course-sheet-human-source.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/after/course-sheet-sources-human-source.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/after/subject-detail-human-source.png`
- `docs/roadmap/v5/evidence/screenshots/V5-03/after/document-detail-human-source.png`

Target :

- `docs/roadmap/v5/evidence/screenshots/V5-03/target/mockup-reference.png`

Note QA :

- Le serveur local `http://localhost:60164/` n'etait plus disponible pendant la verification finale.
- Les variables locales `NERALUNE_EMAIL` et `NERALUNE_PASSWORD` etaient absentes ; aucune valeur secrete n'a ete affichee.
- Les captures `after` lisibles ont donc ete regenerees avec Playwright sur un rendu statique mobile dark qui represente les surfaces et labels du lot.
- Les routes reelles sont couvertes par les tests Flutter/router listes plus bas.

## 10. Comparaison avec la maquette

| Surface | Maquette cible | Avant | Après | Écart restant | Verdict |
|---|---|---|---|---|---|
| Detail cours | Parcours mobile sombre, notions lisibles, pas de filename technique | `course-detail-filename.png` montrait un filename brut dans la metadata | `course-detail-human-source.png` affiche `À découvrir · Support 1` | La refonte complete du detail gamifie reste V5-05 | `VALIDÉ` |
| Fiche | Fiche sombre, source compréhensible, CTA revision | `course-sheet-source-filename.png` exposait le nom de PDF comme source | `course-sheet-human-source.png` affiche `Support 1` et `Fichier original` | Fiche premium complete reportee en V5-06 | `VALIDÉ` |
| Sources fiche | Liste de sources/extraits, pas de gros filename en titre | `course-sheet-sources-filename.png` exposait le fichier source | `course-sheet-sources-human-source.png` affiche `Support 1` | Les extraits restent simples hors V5-06 | `VALIDÉ` |
| Detail matiere | Documents lisibles dans une liste mobile | `subject-detail-filename.png` utilisait le filename en titre | `subject-detail-human-source.png` affiche `Support 1` | Certains documents propres restent nettoyes, pas renommes | `VALIDÉ` |
| Detail document | Titre principal humain, technique secondaire | `document-detail-filename.png` avait le PDF en titre | `document-detail-human-source.png` affiche `Support 1` en titre | Un vrai titre pedagogique backend futur serait preferable | `VALIDÉ` |

## 11. Tests exécutés

| Commande | Résultat |
|---|---|
| `dart format ...` sur les 20 fichiers Dart touches | `Formatted 20 files (0 changed)` |
| `flutter test test/features/courses/course_source_display_label_test.dart test/features/courses/course_detail_page_test.dart test/features/courses/course_revision_sheet_page_test.dart test/features/documents/document_detail_page_test.dart test/features/subjects/subject_detail_page_test.dart test/app/router/app_router_test.dart` | `All tests passed!` (`82` tests) |
| `flutter test test/app/revision_app_test.dart test/features/courses/course_deep_revision_page_test.dart test/features/courses/course_rich_revision_page_test.dart test/features/courses/course_deep_revision_result_page_test.dart` | `All tests passed!` (`18` tests) |
| `flutter analyze` | Échec outil : crash analysis server `FormatException: Unexpected end of input`, rapport `flutter_29.log` |
| `dart analyze ...` sur les fichiers modifies | `No issues found!` |
| `test -f test/features/courses/course_sheet_sources_page_test.dart` | Fichier absent ; couverture renforcee dans `course_revision_sheet_page_test.dart` car la page sources est dans `course_revision_sheet_page.dart`. |
| `test -f test/features/courses/course_sources_bottom_sheet_test.dart` | Fichier absent ; couverture renforcee dans `course_detail_page_test.dart` via la bottom sheet sources. |
| `sips -g pixelWidth -g pixelHeight .../after/*.png` | Les cinq captures after sont `390 x 844`. |
| `curl -I --max-time 3 http://localhost:60164/` | Échec connexion : serveur local indisponible. |
| `NODE_PATH=/tmp/neralune-playwright-v503/node_modules node <runner>` | Cinq captures Playwright statiques ecrites. |

## 12. Compte de test

Compte de test prevu :

- `yoahn.l@me.com`

Mot de passe :

- attendu via variable locale `NERALUNE_PASSWORD`
- non stocke
- non committe
- non affiche

Écart de protocole :

- `NERALUNE_EMAIL` et `NERALUNE_PASSWORD` etaient absentes de l'environnement local pendant cette passe.
- Le serveur live `http://localhost:60164/` etait indisponible.
- Aucune connexion reelle n'a donc ete effectuee pour les captures finales.

## 13. Non-objectifs respectés

- Pas de backend.
- Pas de Prisma.
- Pas de Genkit.
- Pas de GenUI.
- Pas de nouvel asset applicatif.
- Pas de dependance projet ajoutee.
- Pas de modification `pubspec.yaml`.
- Pas de modification `pubspec.lock`.
- Pas de generation IA de titres.
- Pas de systeme de renommage utilisateur.
- Pas de refonte globale Today/session/feedback/bilan.
- Pas de commit, amend, merge, rebase, push, tag ou changement de branche.

## 14. Risques restants

- Un vrai titre intelligent stable demandera probablement un champ backend futur (`displayName`, `humanTitle` ou equivalent).
- Certains documents resteront volontairement generiques en `Support N`.
- La fiche premium complete reste V5-06.
- Le detail cours gamifie reste V5-05.
- La verification visuelle live avec compte test devra etre rejouee quand le serveur local et les variables de secret seront disponibles.

## 15. Verdict visuel

`VALIDÉ`

Reserve : verdict visuel valide sur captures before/after/target et labels lisibles ; la connexion Playwright live n'a pas pu etre executee dans l'environnement local courant.

## 16. Prochain lot recommandé

`V5-04 — Aujourd'hui coach`
