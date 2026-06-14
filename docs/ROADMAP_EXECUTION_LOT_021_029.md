# LOT-021 + LOT-029 — UI résumé/fiche et GenUI lecture sourcée

## 1. Résultat

Le frontend permet maintenant de lire et générer un résumé et une fiche de révision depuis la page détail document.

Le batch ajoute :

- les modèles Flutter `DocumentSummary`, `RevisionSheet`, `RevisionSheetSection` et `DocumentArtifactSource`;
- les appels HTTP vers les endpoints backend résumé/fiche;
- les méthodes de contrôleur nécessaires à la page document;
- une section `Supports IA` sur `DocumentDetailPage`;
- les états de lecture, génération, absence, erreur et échec;
- l'affichage des sources issues des chunks;
- les composants GenUI bornés `SummaryCard`, `KeyPointsList` et `SourceExcerptCard`;
- un validateur GenUI dédié aux payloads de lecture sourcée.

Aucun backend, Prisma, Genkit, QCM, TodayPlan, auth, upload document ou déploiement n'a été modifié.

## 2. Sources inspectées

- `docs/ROADMAP.md`
- `docs/ROADMAP_EXECUTION_PLAN.md`
- `docs/ROADMAP_EXECUTION_LOT_014_015_016.md`
- `docs/ROADMAP_EXECUTION_LOT_017.md`
- `docs/ROADMAP_EXECUTION_LOT_018.md`
- `docs/ROADMAP_EXECUTION_LOT_019_020.md`
- `AGENTS.md`
- `codex_rule.md`
- `pubspec.yaml`
- `lib/features/documents/domain/revision_document.dart`
- `lib/features/documents/data/documents_api.dart`
- `lib/features/documents/application/documents_controller.dart`
- `lib/presentation/pages/documents/document_detail_page.dart`
- `lib/presentation/pages/subjects/subject_detail_page.dart`
- `lib/app/router/app_router.dart`
- `lib/app/router/app_routes.dart`
- `lib/core/routing/route_paths.dart`
- `lib/features/activities/genui/revision_activity_catalog.dart`
- `lib/features/activities/genui/diagnostic_quiz_activity_validator.dart`
- `test/features/documents/documents_api_test.dart`
- `test/features/documents/documents_controller_test.dart`
- `test/features/documents/document_detail_page_test.dart`
- `test/features/documents/document_import_button_test.dart`
- `test/features/subjects/subject_detail_page_test.dart`
- `test/features/activities/revision_activity_catalog_test.dart`
- `test/features/activities/diagnostic_quiz_activity_validator_test.dart`
- `test/fakes/in_memory_documents_api.dart`
- `../api/src/modules/study-artifacts/interfaces/study-artifacts.controller.ts`
- `../api/src/modules/study-artifacts/application/generate-document-summary.use-case.ts`
- `../api/src/modules/study-artifacts/application/generate-revision-sheet.use-case.ts`
- `../api/src/modules/study-artifacts/application/study-artifacts.repository.ts`

## 3. Préflight Git

API initial :

- racine : `/Users/karim/Project/app-révision/api`
- HEAD : `83f80ec #124: ajoute générateurs de résumés et fiches de révision avec GenKit`
- état : clean

Frontend initial :

- racine : `/Users/karim/Project/app-révision/revision_app`
- HEAD : `5c3765d LOT_018 - Mise à jour du plan d'exécution et ajout du rapport LOT_018`
- fichiers préexistants :
  - `M docs/ROADMAP_EXECUTION_PLAN.md`
  - `?? docs/ROADMAP_EXECUTION_LOT_019_020.md`

Décision :

- le fichier `docs/ROADMAP_EXECUTION_PLAN.md` est dans le périmètre de ce lot pour le tableau de suivi;
- `docs/ROADMAP_EXECUTION_LOT_019_020.md` était déjà non suivi et n'a pas été modifié;
- aucun fichier backend n'a été modifié.

## 4. LOT-021 — UI résumé et fiche

Modèles Flutter ajoutés :

- `DocumentArtifactSource`
- `DocumentSummary`
- `RevisionSheet`
- `RevisionSheetSection`

API Flutter :

- `getDocumentSummary`
- `generateDocumentSummary`
- `getRevisionSheet`
- `generateRevisionSheet`

Comportement :

- `GET` résumé ou fiche en `404` devient `null`, donc état vide;
- `409` devient `DocumentNotReadyException`;
- les autres statuts HTTP d'artefacts deviennent `DocumentArtifactRequestException`;
- `POST` résumé et fiche parse les DTOs publics backend;
- aucun champ interne (`storagePath`, prompt, completion, métadonnées IA internes) n'est attendu.

Controller/state :

- `DocumentsController.loadDocumentArtifacts` charge résumé et fiche existants;
- `generateDocumentSummary` et `generateRevisionSheet` déclenchent explicitement les `POST`;
- la page ne fait aucun appel HTTP direct.

Page document :

- la section `Supports IA` s'affiche uniquement si le document est `READY`;
- un document `PROCESSING`, `UPLOADED` ou `FAILED` ne montre pas les CTA de génération;
- résumé absent : CTA `Generer le resume`;
- fiche absente : CTA `Generer la fiche`;
- génération en cours : état loading local;
- artefact prêt : titre, contenu, listes et sources;
- erreur de chargement : panneau d'erreur sans masquer les notions;
- erreur de génération : message affiché dans le panneau concerné.

Widgets :

- création de `DocumentSourceExcerpt` pour partager le rendu des extraits entre notions, artefacts et GenUI.

## 5. LOT-029 — GenUI composants lecture sourcée

Composants ajoutés au catalogue :

- `SummaryCard`
- `KeyPointsList`
- `SourceExcerptCard`

Payloads :

- `SummaryCard` accepte `title`, `content`, `keyPoints`, `sources`;
- `KeyPointsList` accepte `title`, `items`;
- `SourceExcerptCard` accepte `text`, `pageNumber`, `index`, `label`;
- les champs inconnus sont interdits dans les schémas des nouveaux composants;
- les tailles de texte, nombres d'items et nombres de sources sont bornés par constantes.

Validation :

- `sourced_reading_component_validator.dart` refuse les composants inconnus;
- les payloads avec champs inconnus sont refusés;
- les sources vides, index négatifs et listes trop longues sont refusés;
- le rendu GenUI ne rend aucun HTML et ne construit aucun widget arbitraire.

Rendu :

- les nouveaux composants utilisent les primitives visuelles existantes : `RevisionPanel`, `DocumentSourceExcerpt`, `AppSpacing`;
- GenUI reste un rendu borné et alternatif;
- aucun payload GenUI n'est stocké.

## 6. Contrats API consommés

Résumé :

```text
GET /documents/:documentId/summary
POST /documents/:documentId/summary
```

Fiche :

```text
GET /documents/:documentId/revision-sheet
POST /documents/:documentId/revision-sheet
```

DTO résumé consommé :

```json
{
  "id": "summary-1",
  "documentId": "document-1",
  "subjectId": "subject-1",
  "status": "READY",
  "title": "Résumé du cours",
  "content": "Texte synthétique.",
  "keyPoints": ["Point clé"],
  "limits": "Limite.",
  "errorCode": null,
  "sources": [
    {
      "chunkId": "chunk-1",
      "text": "Extrait source.",
      "pageNumber": null,
      "index": 0
    }
  ]
}
```

DTO fiche consommé :

```json
{
  "id": "sheet-1",
  "documentId": "document-1",
  "subjectId": "subject-1",
  "status": "READY",
  "title": "Fiche de révision",
  "introduction": "Vue d'ensemble.",
  "keyPoints": ["À retenir"],
  "commonMistakes": [],
  "mustKnow": ["Indispensable"],
  "practiceSuggestions": ["Relire la section."],
  "errorCode": null,
  "sections": [
    {
      "id": "section-1",
      "displayOrder": 0,
      "title": "Principe clé",
      "content": "Explication structurée.",
      "sources": [
        {
          "chunkId": "chunk-1",
          "text": "Extrait source.",
          "pageNumber": null,
          "index": 0
        }
      ]
    }
  ]
}
```

## 7. Données non stockées / non exposées

Confirmé :

- pas de `storagePath`;
- pas de prompt;
- pas de completion;
- pas de payload GenUI persistant;
- pas de source libre;
- pas de widget arbitraire;
- pas de modification backend;
- pas de migration.

## 8. Tests créés ou modifiés

Créés :

- `test/features/activities/sourced_reading_component_validator_test.dart`

Modifiés :

- `test/features/documents/documents_api_test.dart`
- `test/features/documents/documents_controller_test.dart`
- `test/features/documents/document_detail_page_test.dart`
- `test/features/documents/document_import_button_test.dart`
- `test/features/subjects/subject_detail_page_test.dart`
- `test/fakes/in_memory_documents_api.dart`
- `test/features/activities/revision_activity_catalog_test.dart`

Couverture ajoutée :

- parsing `DocumentSummary`;
- parsing `RevisionSheet`;
- sources avec `pageNumber: null`;
- `GET` résumé/fiche en `404` comme état absent;
- `POST` résumé/fiche;
- JSON résumé invalide;
- chargement des artefacts via contrôleur;
- génération explicite via contrôleur;
- page document avec CTA résumé/fiche;
- clic CTA résumé;
- clic CTA fiche;
- sources affichées;
- absence de CTA si document non `READY`;
- erreur artefact visible sans masquer les notions;
- catalogue GenUI avec les trois nouveaux composants;
- validation des payloads GenUI bornés;
- rendu widget des composants GenUI.

## 9. Validations lancées

Frontend :

```text
dart analyze lib test
Résultat : succès, No issues found.
```

```text
flutter test test/features/documents
Résultat : succès, All tests passed.
```

```text
flutter test test/features/activities
Résultat : succès, All tests passed.
```

```text
flutter test
Résultat : succès, All tests passed.
```

```text
git diff --check
Résultat : succès.
```

API :

```text
git diff --check
Résultat : succès.
```

## 10. Validations non lancées

- Tests backend complets non lancés : aucun code backend n'a été modifié.
- Migrations non lancées : aucun schéma Prisma n'a été modifié.
- Déploiement non lancé : hors périmètre.
- Provider IA réel non lancé : interdit et hors périmètre.

## 11. Risques restants

- Le runtime DB backend reste à valider si les migrations précédentes n'ont pas encore été appliquées sur une vraie base.
- Le provider IA réel des résumés/fiches n'est pas validé par ce lot frontend.
- La section `Supports IA` peut devenir dense sur mobile quand une fiche contient beaucoup de sections.
- GenUI n'est pas encore branché à une session IA.
- La régénération explicite n'est pas encore exposée côté UI.
- Le QCM enrichi n'est pas encore traité.

## 12. Recommandation prochain lot

Le prochain lot recommandé est `LOT-022 — Contrat QCM v2`, sauf si la validation runtime DB des migrations backend reste bloquante. Dans ce cas, il faut lancer un mini-lot DB/runtime avant de continuer les fonctionnalités.
