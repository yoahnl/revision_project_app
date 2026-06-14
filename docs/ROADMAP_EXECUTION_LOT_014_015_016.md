# LOT-014 + LOT-015 + LOT-016 — Détail document et notions sourcées

## 1. Résultat

Les lots `LOT-014`, `LOT-015` et `LOT-016` ont été réalisés.

Le backend expose maintenant :

- `GET /documents/:documentId` avec un DTO public sans `storagePath` ;
- `GET /documents/:documentId/knowledge-units` avec les notions sourcées du document ;
- un use case applicatif dédié `ListDocumentKnowledgeUnitsUseCase` ;
- une méthode repository qui filtre par `studentId`, par `documentId`, et ne retourne que les chunks liés via `KnowledgeUnitSource`.

Le frontend Flutter peut maintenant :

- charger le détail public d'un document ;
- charger les notions sourcées d'un document `READY` ;
- gérer `UPLOADED`, `PROCESSING`, `READY`, `FAILED` ;
- ouvrir une page de détail document depuis la page matière ;
- afficher difficulté, confiance et extraits sources issus des chunks liés.

Aucune migration Prisma n'a été créée. Aucun endpoint Genkit, QCM, TodayPlan, résumé, fiche, question ouverte ou GenUI n'a été modifié.

## 2. Sources inspectées

Documentation :

- `revision_app/docs/ROADMAP_EXECUTION_PLAN.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_009_010_011.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_010B.md`
- `revision_app/docs/ROADMAP_EXECUTION_LOT_012_013.md`
- `revision_app/AGENTS.md`

Backend :

- `api/package.json`
- `api/prisma/schema.prisma`
- `api/prisma/migrations/20260614000000_document_chunks_sources/migration.sql`
- `api/src/modules/documents/interfaces/documents.controller.ts`
- `api/src/modules/documents/interfaces/documents.controller.spec.ts`
- `api/src/modules/documents/application/documents.repository.ts`
- `api/src/modules/documents/application/get-document.use-case.ts`
- `api/src/modules/documents/application/list-subject-documents.use-case.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`
- `api/src/modules/documents/domain/document.entity.ts`
- `api/src/modules/documents/documents.module.ts`
- `api/src/modules/revision/domain/knowledge-unit.entity.ts`
- `api/src/modules/revision/infrastructure/prisma-revision.repository.ts`
- `api/src/modules/auth/interfaces/firebase-auth.guard.ts`
- `api/src/modules/auth/interfaces/current-student.decorator.ts`

Frontend :

- `revision_app/pubspec.yaml`
- `revision_app/lib/app/router/app_router.dart`
- `revision_app/lib/app/router/app_routes.dart`
- `revision_app/lib/core/routing/route_paths.dart`
- `revision_app/lib/app/di/revision_providers.dart`
- `revision_app/lib/features/documents/domain/revision_document.dart`
- `revision_app/lib/features/documents/data/documents_api.dart`
- `revision_app/lib/features/documents/application/documents_controller.dart`
- `revision_app/lib/presentation/widgets/documents/document_import_button.dart`
- `revision_app/lib/presentation/pages/subjects/subject_detail_page.dart`
- `revision_app/test/features/documents/documents_api_test.dart`
- `revision_app/test/features/documents/documents_controller_test.dart`
- `revision_app/test/features/documents/document_import_button_test.dart`
- `revision_app/test/features/subjects/subject_detail_page_test.dart`
- `revision_app/test/fakes/in_memory_documents_api.dart`

## 3. Préflight Git

État initial API :

```text
## main...origin/main
```

État initial frontend :

```text
## main...origin/main
 M AGENTS.md
 M docs/ROADMAP_EXECUTION_PLAN.md
?? docs/ROADMAP_EXECUTION_LOT_012_013.md
```

Ces fichiers frontend étaient issus de lots précédents et compatibles avec ce lot. Ils n'ont pas été revert.

Préflight Prisma :

- `cd api && npx prisma validate` : succès.
- `cd api && npm run prisma:generate` : succès.
- `cd api && npx prisma migrate status` : échec `Schema engine error` sur `localhost:5432`.

Conclusion : PostgreSQL local n'est toujours pas disponible ou pas exploitable par Prisma dans cet environnement. Le lot s'appuie donc sur tests unitaires/mocks et ne prétend pas valider la migration en runtime DB.

## 4. LOT-014 — API détail document et notions sourcées

Endpoints ajoutés ou enrichis :

- `GET /documents/:documentId`
- `GET /documents/:documentId/knowledge-units`

DTO public document :

```json
{
  "id": "document-1",
  "subjectId": "subject-1",
  "kind": "COURSE_PDF",
  "fileName": "cours.pdf",
  "mimeType": "application/pdf",
  "status": "READY",
  "errorCode": null
}
```

DTO public notions sourcées :

```json
{
  "documentId": "document-1",
  "items": [
    {
      "id": "unit-1",
      "title": "Séparation des pouvoirs",
      "summary": "Résumé court.",
      "difficulty": "MEDIUM",
      "displayOrder": 1,
      "confidence": 0.84,
      "sources": [
        {
          "chunkId": "chunk-1",
          "text": "Extrait source issu du chunk.",
          "pageNumber": null,
          "index": 0
        }
      ]
    }
  ]
}
```

Ownership :

- `findKnowledgeUnitsByDocumentForStudent` vérifie d'abord que le document appartient au `studentId`.
- Les notions sont filtrées par `documentId` et par `subject.studentId`.
- Cross-student retourne `null` côté repository puis `404 Document not found` côté use case.

Document non `READY` :

- `GET /documents/:documentId/knowledge-units` retourne `409 Document is not ready`.
- Ce choix évite qu'une UI interprète un document en traitement comme un document sans notion.

Absence de `storagePath` :

- `GetDocumentUseCase` retourne maintenant un DTO public.
- `register`, `uploadCoursePdf` et `listForSubject` passent par `toPublicDocument`.
- Le endpoint notions ne retourne pas `storagePath`.

Tests backend ajoutés ou modifiés :

- controller : document public sans `storagePath`, notions sourcées, document id vide ;
- use case : `READY`, `404`, `409` ;
- repository : ownership, tri stable, sources liées seulement, absence de `storagePath`.

## 5. LOT-015 — Data layer Flutter

Modèles ajoutés :

- `DocumentKnowledgeUnitSource`
- `DocumentKnowledgeUnit`
- `DocumentKnowledgeUnitsResponse`
- `DocumentDetail`
- `DocumentDetailLoadState`
- `DocumentNotReadyException`

API Flutter ajoutée :

- `DocumentsApi.listDocumentKnowledgeUnits`
- `HttpDocumentsApi.listDocumentKnowledgeUnits`

Parsing :

- `pageNumber: null` est supporté.
- `confidence` accepte un `num` et devient `double`.
- JSON invalide déclenche `FormatException`.
- HTTP `409` devient `DocumentNotReadyException`.

Controller :

- `DocumentsController.loadDocumentDetail` charge le document.
- Il ne charge les notions que si le document est `READY`.
- Il expose `notReady`, `ready` ou `failed`.
- Il transforme un `409` tardif en état `notReady`.

Tests Flutter ajoutés ou modifiés :

- parsing document public ;
- parsing notions sourcées ;
- erreur `409` document non prêt ;
- JSON invalide ;
- document `READY` charge les notions ;
- document `PROCESSING` ne charge pas les notions ;
- document `FAILED` expose l'état d'erreur.

## 6. LOT-016 — Page détail document

Route ajoutée :

- `/subjects/:subjectId/documents/:documentId`

Navigation :

- La route est attachée à la branche `Accueil` du `StatefulShellRoute.indexedStack`.
- Depuis `SubjectDetailPage`, chaque document est cliquable via `RevisionPanel.onTap`.
- La page matière conserve son rôle de racine de branche.

États UI :

- loading : `LinearProgressIndicator`;
- erreur API : message `Impossible de charger le document` + bouton `Reessayer`;
- `UPLOADED` : état d'attente ;
- `PROCESSING` : état `Analyse en cours`;
- `FAILED` : état `Analyse echouee` avec libellé d'erreur ;
- `READY` : liste de notions extraites ;
- `READY` sans notion : `Aucune notion extraite`.

Affichage notions :

- titre ;
- résumé ;
- difficulté ;
- confiance ;
- sources sous forme d'extraits courts.

Tests widget :

- document `PROCESSING` affiche l'attente ;
- document `FAILED` affiche l'erreur ;
- document `READY` affiche notion, difficulté, confiance et source ;
- erreur API affiche retry ;
- tap depuis détail matière navigue vers le détail document.

## 7. Contrats API finaux

### `GET /documents/:documentId`

Réponse `200` :

```json
{
  "id": "document-1",
  "subjectId": "subject-1",
  "kind": "COURSE_PDF",
  "fileName": "cours.pdf",
  "mimeType": "application/pdf",
  "status": "READY",
  "errorCode": null
}
```

Erreurs :

- `400` si `documentId` vide.
- `401` via guard si token absent.
- `404` si document absent ou autre étudiant.

### `GET /documents/:documentId/knowledge-units`

Réponse `200` :

```json
{
  "documentId": "document-1",
  "items": [
    {
      "id": "unit-1",
      "title": "Séparation des pouvoirs",
      "summary": "Résumé court.",
      "difficulty": "MEDIUM",
      "displayOrder": 1,
      "confidence": 0.84,
      "sources": [
        {
          "chunkId": "chunk-1",
          "text": "Extrait source issu du chunk.",
          "pageNumber": null,
          "index": 0
        }
      ]
    }
  ]
}
```

Erreurs :

- `400` si `documentId` vide.
- `401` via guard si token absent.
- `404` si document absent ou autre étudiant.
- `409` si document non `READY`.

## 8. Données non exposées

Le lot confirme :

- pas de `storagePath`;
- pas de chemin disque interne ;
- pas de texte complet du document ;
- pas de chunks non liés ;
- pas de données cross-student ;
- pas de prompt Genkit ;
- pas de completion Genkit ;
- pas de source libre générée par l'IA.

## 9. Tests créés ou modifiés

Backend :

- `api/src/modules/documents/application/list-document-knowledge-units.use-case.spec.ts`
- `api/src/modules/documents/interfaces/documents.controller.spec.ts`
- `api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts`

Frontend :

- `revision_app/test/features/documents/documents_api_test.dart`
- `revision_app/test/features/documents/documents_controller_test.dart`
- `revision_app/test/features/documents/document_detail_page_test.dart`
- `revision_app/test/features/subjects/subject_detail_page_test.dart`
- `revision_app/test/features/documents/document_import_button_test.dart`
- `revision_app/test/fakes/in_memory_documents_api.dart`

## 10. Validations lancées

Backend :

```text
cd api && npx prisma validate
Résultat : succès
```

```text
cd api && npm run prisma:generate
Résultat : succès
```

```text
cd api && npx prisma migrate status
Résultat : échec attendu dans l'environnement local actuel
Erreur : Schema engine error
Datasource : PostgreSQL revision sur localhost:5432
```

```text
cd api && npm test -- documents --runInBand
Résultat : succès, 8 suites, 57 tests
```

```text
cd api && npm test -- jobs --runInBand
Résultat : succès, 3 suites, 12 tests
```

```text
cd api && npm test -- ai --runInBand
Résultat : succès, 9 suites, 38 tests
```

```text
cd api && npm test -- activities --runInBand
Résultat : succès, 5 suites, 25 tests
```

```text
cd api && npm run lint:check
Résultat : succès
```

```text
cd api && npm run build
Résultat : succès
```

```text
cd api && git diff --check
Résultat : succès
```

Frontend :

```text
cd revision_app && dart analyze lib test
Résultat : succès, No issues found
```

```text
cd revision_app && flutter test test/features/documents/document_detail_page_test.dart
Résultat : succès, 4 tests
```

```text
cd revision_app && flutter test test/features/subjects/subject_detail_page_test.dart
Résultat : succès, 2 tests
```

```text
cd revision_app && flutter test
Résultat : succès, 76 tests
```

```text
cd revision_app && git diff --check
Résultat : succès
```

Note : un premier lancement parallèle de tests Flutter ciblés a déclenché un crash outil Flutter `PathExistsException` dans `ios/Flutter/ephemeral/Packages/.packages/firebase_auth-6.5.2`. Le test relancé seul a réussi, puis la suite complète `flutter test` a réussi.

## 11. Validations non lancées

- Aucune migration n'a été appliquée.
- `prisma migrate deploy` n'a pas été lancé.
- Aucun test e2e réel avec PostgreSQL n'a été lancé, car `npx prisma migrate status` échoue encore sur `localhost:5432`.
- Aucun test manuel mobile n'a été lancé dans ce lot.
- Aucun test Genkit réel provider externe n'a été lancé, car ce lot ne modifie pas Genkit.

## 12. Migration / DB

Aucune nouvelle migration n'a été créée.

La migration existante `20260614000000_document_chunks_sources` existe toujours, mais elle n'a pas été validée sur une vraie DB locale dans ce lot.

La validation runtime DB reste à faire dès qu'une instance PostgreSQL locale propre est disponible.

## 13. Corrections de chemins constatées

- Les rapports et règles actifs sont dans `revision_app/docs` et `revision_app/AGENTS.md`.
- Le frontend actif est `/Users/karim/Project/app-révision/revision_app`.
- Le backend actif est `/Users/karim/Project/app-révision/api`.
- `revision_app/lib/app/di/revision_providers.dart` n'est pas le point principal observé pour ce lot ; les providers actifs utilisés par les tests sont dans `revision_app/lib/app/di/providers.dart`.

## 14. Risques restants

- La migration `20260614000000_document_chunks_sources` n'est pas validée runtime DB.
- Les sources peuvent être de mauvaise qualité si le chunking ou la sélection Genkit v2 produit des liens peu pertinents.
- La page détail document peut devenir dense sur petit écran avec beaucoup de sources.
- Il n'existe pas encore de résumé ou fiche générée.
- GenUI n'est pas encore utilisé pour ces notions sourcées.
- Il n'y a pas encore de ranking sémantique des chunks.
- Les chunks de cours sont stockés en DB ; la stratégie de rétention reste à décider.

## 15. Recommandation prochain lot

Prochain lot recommandé : `LOT-017 — Contrat artefacts générés`.

Justification :

- Les sources vérifiables sont maintenant exposées au produit.
- Avant de générer des fiches ou résumés, il faut décider comment représenter les artefacts IA : modèle spécialisé, métadonnées communes, versioning, éventuelle génération synchrone ou asynchrone.
- `LOT-018 + LOT-019 + LOT-020` peut ensuite ajouter les résumés/fiches sur une base plus stable.

Précondition recommandée : démarrer PostgreSQL local et valider `npx prisma migrate status`, puis appliquer la migration sur une DB locale de test uniquement.

## 16. Code créé ou modifié

Cette section existe pour respecter la règle du projet : le rapport doit inclure le code créé ou modifié.

### Fichiers créés — contenu complet

#### `api/src/modules/documents/application/list-document-knowledge-units.use-case.ts`

```ts
import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { DOCUMENTS_REPOSITORY } from './documents.repository';
import type { DocumentsRepository } from './documents.repository';

@Injectable()
export class ListDocumentKnowledgeUnitsUseCase {
  constructor(
    @Inject(DOCUMENTS_REPOSITORY)
    private readonly documentsRepository: DocumentsRepository,
  ) {}

  async execute(input: { studentId: string; documentId: string }) {
    const result =
      await this.documentsRepository.findKnowledgeUnitsByDocumentForStudent(
        input,
      );

    if (!result) {
      throw new NotFoundException('Document not found');
    }

    if (result.documentStatus !== 'READY') {
      throw new ConflictException('Document is not ready');
    }

    return {
      documentId: result.documentId,
      items: result.items,
    };
  }
}
```

#### `api/src/modules/documents/application/list-document-knowledge-units.use-case.spec.ts`

```ts
import { ConflictException, NotFoundException } from '@nestjs/common';
import type { DocumentsRepository } from './documents.repository';
import { ListDocumentKnowledgeUnitsUseCase } from './list-document-knowledge-units.use-case';

describe('ListDocumentKnowledgeUnitsUseCase', () => {
  type FindKnowledgeUnitsByDocumentForStudent =
    DocumentsRepository['findKnowledgeUnitsByDocumentForStudent'];

  function createUseCase(
    response: Awaited<ReturnType<FindKnowledgeUnitsByDocumentForStudent>>,
  ) {
    const findKnowledgeUnitsByDocumentForStudent = jest
      .fn()
      .mockResolvedValue(response);
    const repository = {
      findKnowledgeUnitsByDocumentForStudent,
    } as unknown as DocumentsRepository;

    return {
      useCase: new ListDocumentKnowledgeUnitsUseCase(repository),
      findKnowledgeUnitsByDocumentForStudent,
    };
  }

  it('returns sourced knowledge units for ready documents', async () => {
    const { useCase, findKnowledgeUnitsByDocumentForStudent } = createUseCase({
      documentId: 'document-1',
      documentStatus: 'READY',
      items: [
        {
          id: 'unit-1',
          title: 'Constitution',
          summary: 'Norme fondamentale.',
          difficulty: 'MEDIUM',
          displayOrder: 1,
          confidence: 0.8,
          sources: [
            {
              chunkId: 'chunk-1',
              text: 'Extrait source.',
              pageNumber: null,
              index: 0,
            },
          ],
        },
      ],
    });

    const response = await useCase.execute({
      studentId: 'student-1',
      documentId: 'document-1',
    });

    expect(findKnowledgeUnitsByDocumentForStudent).toHaveBeenCalledWith({
      studentId: 'student-1',
      documentId: 'document-1',
    });
    expect(response.items).toHaveLength(1);
  });

  it('throws 404 for missing or cross-student documents', async () => {
    const { useCase } = createUseCase(null);

    await expect(
      useCase.execute({
        studentId: 'student-2',
        documentId: 'document-1',
      }),
    ).rejects.toThrow(NotFoundException);
  });

  it('throws 409 for documents that are not ready', async () => {
    const { useCase } = createUseCase({
      documentId: 'document-1',
      documentStatus: 'PROCESSING',
      items: [],
    });

    await expect(
      useCase.execute({
        studentId: 'student-1',
        documentId: 'document-1',
      }),
    ).rejects.toThrow(ConflictException);
  });
});
```

#### `revision_app/lib/presentation/pages/documents/document_detail_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/presentation/theme/app_colors.dart';
import 'package:revision_app/presentation/theme/app_radius.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_page.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class DocumentDetailPage extends StatefulWidget {
  const DocumentDetailPage({
    required this.documentId,
    required this.controller,
    super.key,
  });

  final String documentId;
  final DocumentsController controller;

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  late Future<DocumentDetail> _detail;

  @override
  void initState() {
    super.initState();
    _detail = widget.controller.loadDocumentDetail(widget.documentId);
  }

  void _reload() {
    setState(() {
      _detail = widget.controller.loadDocumentDetail(widget.documentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentDetail>(
      future: _detail,
      builder: (context, snapshot) {
        final detail = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPage(
            title: 'Document',
            children: [LinearProgressIndicator()],
          );
        }

        if (snapshot.hasError || detail == null) {
          return RevisionPage(
            title: 'Document',
            children: [
              Text(
                'Impossible de charger le document',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              RevisionButton(
                onPressed: _reload,
                icon: Icons.refresh,
                label: 'Reessayer',
                style: RevisionButtonStyle.ghost,
              ),
            ],
          );
        }

        return RevisionPage(
          title: detail.document.fileName,
          subtitle: _documentKindLabel(detail.document.kind),
          children: [
            _DocumentHeader(document: detail.document, onRefresh: _reload),
            const SizedBox(height: AppSpacing.xl),
            _DocumentKnowledgeSection(detail: detail, onRefresh: _reload),
          ],
        );
      },
    );
  }
}

class _DocumentHeader extends StatelessWidget {
  const _DocumentHeader({required this.document, required this.onRefresh});

  final RevisionDocument document;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RevisionStatusPill(
                  label: _documentStatusLabel(document),
                  color: _documentStatusColor(context, document.status),
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  document.mimeType,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (document.status == 'FAILED' &&
                    document.errorCode != null) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    _failedDocumentLabel(document.errorCode),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recharger',
          ),
        ],
      ),
    );
  }
}

class _DocumentKnowledgeSection extends StatelessWidget {
  const _DocumentKnowledgeSection({
    required this.detail,
    required this.onRefresh,
  });

  final DocumentDetail detail;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return switch (detail.state) {
      DocumentDetailLoadState.ready => _ReadyKnowledgeUnits(
        units: detail.knowledgeUnits,
      ),
      DocumentDetailLoadState.notReady => _NotReadyState(
        status: detail.document.status,
      ),
      DocumentDetailLoadState.failed => _FailedState(
        errorCode: detail.document.errorCode,
        onRetry: onRefresh,
      ),
    };
  }
}

class _ReadyKnowledgeUnits extends StatelessWidget {
  const _ReadyKnowledgeUnits({required this.units});

  final List<DocumentKnowledgeUnit> units;

  @override
  Widget build(BuildContext context) {
    if (units.isEmpty) {
      return const Text('Aucune notion extraite');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.itemGap,
      children: [
        Text('Notions extraites', style: Theme.of(context).textTheme.titleLarge),
        for (final unit in units) _KnowledgeUnitPanel(unit: unit),
      ],
    );
  }
}

class _KnowledgeUnitPanel extends StatelessWidget {
  const _KnowledgeUnitPanel({required this.unit});

  final DocumentKnowledgeUnit unit;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              if (unit.difficulty != null)
                RevisionStatusPill(
                  label: _difficultyLabel(unit.difficulty),
                  color: _difficultyColor(context, unit.difficulty),
                ),
              if (unit.confidence != null)
                RevisionStatusPill(
                  label: 'Confiance ${(unit.confidence! * 100).round()}%',
                  color: AppColors.aqua,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(unit.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(unit.summary, style: Theme.of(context).textTheme.bodyMedium),
          if (unit.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Sources', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Column(
              spacing: AppSpacing.s,
              children: [
                for (final source in unit.sources)
                  _KnowledgeUnitSourceExcerpt(source: source),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _KnowledgeUnitSourceExcerpt extends StatelessWidget {
  const _KnowledgeUnitSourceExcerpt({required this.source});

  final DocumentKnowledgeUnitSource source;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.46),
        borderRadius: AppRadius.radiusM,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sourceLabel(source),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(source.text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _NotReadyState extends StatelessWidget {
  const _NotReadyState({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _notReadyTitle(status),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          const Text('Les notions apparaitront apres le traitement.'),
        ],
      ),
    );
  }
}

class _FailedState extends StatelessWidget {
  const _FailedState({required this.errorCode, required this.onRetry});

  final String? errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyse echouee',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            _failedDocumentLabel(errorCode),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            onPressed: onRetry,
            icon: Icons.refresh,
            label: 'Reessayer',
            style: RevisionButtonStyle.ghost,
          ),
        ],
      ),
    );
  }
}

String _documentKindLabel(String kind) {
  return switch (kind) {
    'COURSE_PDF' => 'PDF de cours',
    'EXAM_PDF' => 'PDF examen',
    'EXAM_IMAGE' => 'Image examen',
    _ => kind,
  };
}

String _documentStatusLabel(RevisionDocument document) {
  return switch (document.status) {
    'UPLOADED' => 'Importe',
    'PROCESSING' => 'Analyse en cours',
    'READY' => 'Pret',
    'FAILED' => 'Analyse echouee',
    _ => document.status,
  };
}

Color _documentStatusColor(BuildContext context, String status) {
  final colorScheme = Theme.of(context).colorScheme;

  return switch (status) {
    'UPLOADED' => colorScheme.secondary,
    'PROCESSING' => colorScheme.primary,
    'READY' => colorScheme.tertiary,
    'FAILED' => colorScheme.error,
    _ => colorScheme.outline,
  };
}

String _notReadyTitle(String status) {
  return switch (status) {
    'UPLOADED' => 'Import en attente',
    'PROCESSING' => 'Analyse en cours',
    _ => 'Document en attente',
  };
}

String _failedDocumentLabel(String? errorCode) {
  return switch (errorCode) {
    'DOCUMENT_TEXT_EMPTY' => 'PDF sans texte',
    'DOCUMENT_TEXT_EXTRACTION_FAILED' => 'Lecture PDF impossible',
    'KNOWLEDGE_EXTRACTION_EMPTY' => 'Aucune notion',
    'KNOWLEDGE_SOURCE_INVALID' => 'Sources invalides',
    'KNOWLEDGE_EXTRACTION_FAILED' => 'Erreur IA',
    'DOCUMENT_UNSUPPORTED_MIME_TYPE' => 'Format invalide',
    _ => 'Echec',
  };
}

String _difficultyLabel(String? difficulty) {
  return switch (difficulty) {
    'LOW' => 'Difficulte faible',
    'MEDIUM' => 'Difficulte moyenne',
    'HIGH' => 'Difficulte elevee',
    _ => 'Difficulte inconnue',
  };
}

Color _difficultyColor(BuildContext context, String? difficulty) {
  return switch (difficulty) {
    'LOW' => AppColors.aqua,
    'MEDIUM' => AppColors.amber,
    'HIGH' => AppColors.coral,
    _ => Theme.of(context).colorScheme.outline,
  };
}

String _sourceLabel(DocumentKnowledgeUnitSource source) {
  final pageLabel = source.pageNumber == null
      ? null
      : 'page ${source.pageNumber}';
  final chunkLabel = 'extrait ${source.index + 1}';

  if (pageLabel == null) {
    return chunkLabel;
  }

  return '$chunkLabel · $pageLabel';
}
```

#### `revision_app/test/features/documents/document_detail_page_test.dart`

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/documents/application/documents_controller.dart';
import 'package:revision_app/features/documents/domain/revision_document.dart';
import 'package:revision_app/presentation/pages/documents/document_detail_page.dart';

class DetailDocumentsApi implements DocumentsApi {
  DetailDocumentsApi({
    required this.document,
    this.knowledgeUnits = const [],
    this.error,
  });

  final RevisionDocument document;
  final List<DocumentKnowledgeUnit> knowledgeUnits;
  final Object? error;

  @override
  Future<RevisionDocument> getDocument({required String documentId}) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }

    return document;
  }

  @override
  Future<DocumentKnowledgeUnitsResponse> listDocumentKnowledgeUnits({
    required String documentId,
  }) async {
    return DocumentKnowledgeUnitsResponse(
      documentId: documentId,
      items: knowledgeUnits,
    );
  }

  @override
  Future<List<RevisionDocument>> listSubjectDocuments({
    required String subjectId,
  }) async {
    return [document];
  }

  @override
  Future<RevisionDocument> uploadCoursePdf({
    required String subjectId,
    required String fileName,
    required Uint8List bytes,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows a waiting state for processing documents', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'PROCESSING',
          mimeType: 'application/pdf',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('cours.pdf'), findsOneWidget);
    expect(find.text('Analyse en cours'), findsWidgets);
    expect(
      find.text('Les notions apparaitront apres le traitement.'),
      findsOneWidget,
    );
  });

  testWidgets('shows failed document errors', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'FAILED',
          mimeType: 'application/pdf',
          errorCode: 'KNOWLEDGE_EXTRACTION_FAILED',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Analyse echouee'), findsWidgets);
    expect(find.text('Erreur IA'), findsWidgets);
  });

  testWidgets('shows ready knowledge units and source excerpts', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        knowledgeUnits: const [
          DocumentKnowledgeUnit(
            id: 'unit-1',
            title: 'Séparation des pouvoirs',
            summary: 'Résumé court.',
            difficulty: 'MEDIUM',
            displayOrder: 1,
            confidence: 0.84,
            sources: [
              DocumentKnowledgeUnitSource(
                chunkId: 'chunk-1',
                text: 'Extrait source issu du chunk.',
                pageNumber: null,
                index: 0,
              ),
            ],
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Séparation des pouvoirs'), findsOneWidget);
    expect(find.text('Résumé court.'), findsOneWidget);
    expect(find.text('Difficulte moyenne'), findsOneWidget);
    expect(find.text('Confiance 84%'), findsOneWidget);
    expect(find.text('Extrait source issu du chunk.'), findsOneWidget);
  });

  testWidgets('shows API errors with retry action', (tester) async {
    await tester.pumpWidget(
      documentDetailApp(
        document: const RevisionDocument(
          id: 'document-1',
          subjectId: 'subject-1',
          kind: 'COURSE_PDF',
          fileName: 'cours.pdf',
          status: 'READY',
          mimeType: 'application/pdf',
        ),
        error: StateError('network failed'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impossible de charger le document'), findsOneWidget);
    expect(find.text('Reessayer'), findsOneWidget);
  });
}

Widget documentDetailApp({
  required RevisionDocument document,
  List<DocumentKnowledgeUnit> knowledgeUnits = const [],
  Object? error,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DocumentDetailPage(
        documentId: document.id,
        controller: DocumentsController(
          DetailDocumentsApi(
            document: document,
            knowledgeUnits: knowledgeUnits,
            error: error,
          ),
        ),
      ),
    ),
  );
}
```

### Fichiers modifiés — zones de code modifiées

Les fichiers modifiés ci-dessous sont représentés par extraits diff des zones changées.

#### Backend

```diff
api/src/modules/documents/application/documents.repository.ts
+ export interface PublicRevisionDocumentDto { ... }
+ export interface DocumentKnowledgeUnitSourceDto { ... }
+ export interface DocumentKnowledgeUnitDto { ... }
+ export interface DocumentKnowledgeUnitsDto { ... }
+ findKnowledgeUnitsByDocumentForStudent(input): Promise<DocumentKnowledgeUnitsDto | null>;
```

```diff
api/src/modules/documents/application/get-document.use-case.ts
+ execute(...): Promise<PublicRevisionDocumentDto>
+ export function toPublicDocument(document: RevisionDocumentDto): PublicRevisionDocumentDto
```

```diff
api/src/modules/documents/documents.module.ts
+ import { ListDocumentKnowledgeUnitsUseCase } ...
+ ListDocumentKnowledgeUnitsUseCase dans providers
```

```diff
api/src/modules/documents/infrastructure/prisma-documents.repository.ts
+ async findKnowledgeUnitsByDocumentForStudent(input) {
+   const document = await this.prisma.document.findFirst({ where: { id, studentId } });
+   if (!document) return null;
+   const knowledgeUnits = await this.prisma.knowledgeUnit.findMany({
+     where: { documentId, subject: { studentId } },
+     orderBy: [{ displayOrder: 'asc' }, { createdAt: 'asc' }],
+     include: { sources: { include: { chunk: true } } },
+   });
+   return { documentId, documentStatus, items };
+ }
```

```diff
api/src/modules/documents/interfaces/documents.controller.ts
+ register(...).then(toPublicDocument)
+ uploadCoursePdf(...).then(toPublicDocument)
+ listForSubject(...).then((documents) => documents.map(toPublicDocument))
+ get(...) valide documentId
+ @Get('documents/:documentId/knowledge-units')
+ listKnowledgeUnits(...)
```

```diff
api/src/modules/documents/interfaces/documents.controller.spec.ts
+ mock ListDocumentKnowledgeUnitsUseCase
+ test document public sans storagePath
+ test list sourced knowledge units
+ test rejet document id vide
```

```diff
api/src/modules/documents/infrastructure/prisma-documents.repository.spec.ts
+ mock knowledgeUnit.findMany
+ test liste notions sourcées triées
+ test cross-student retourne null
+ test chunks non liés exclus
```

#### Frontend

```diff
revision_app/lib/app/router/app_router.dart
+ import DocumentDetailPage
+ route imbriquée 'documents/:documentId'
```

```diff
revision_app/lib/app/router/app_routes.dart
+ static String documentDetail({ required subjectId, required documentId })
```

```diff
revision_app/lib/core/routing/route_paths.dart
+ documentDetailRoutePattern
+ documentDetailRoutePath(...)
```

```diff
revision_app/lib/features/documents/application/documents_controller.dart
+ DocumentsApi.listDocumentKnowledgeUnits
+ enum DocumentDetailLoadState
+ class DocumentDetail
+ loadDocumentDetail(...)
+ class DocumentNotReadyException
```

```diff
revision_app/lib/features/documents/data/documents_api.dart
+ HttpDocumentsApi.listDocumentKnowledgeUnits(...)
+ _KnowledgeUnitsJson
+ _KnowledgeUnitJson
+ _KnowledgeUnitSourceJson
```

```diff
revision_app/lib/features/documents/domain/revision_document.dart
+ class DocumentKnowledgeUnitSource
+ class DocumentKnowledgeUnit
+ class DocumentKnowledgeUnitsResponse
```

```diff
revision_app/lib/presentation/pages/subjects/subject_detail_page.dart
+ _DocumentListItem reçoit onTap
+ context.go(documentDetailRoutePath(...))
+ chevron_right sur les documents
```

```diff
revision_app/test/fakes/in_memory_documents_api.dart
+ listDocumentKnowledgeUnits retourne une réponse vide
```

```diff
revision_app/test/features/documents/document_import_button_test.dart
+ CompletingDocumentsApi implémente listDocumentKnowledgeUnits
```

```diff
revision_app/test/features/documents/documents_api_test.dart
+ tests parsing document public, notions sourcées, 409, JSON invalide
+ jsonResponse accepte statusCode
```

```diff
revision_app/test/features/documents/documents_controller_test.dart
+ FakeDocumentsApi.unitsByDocumentId
+ tests loadDocumentDetail READY / PROCESSING / FAILED
```

```diff
revision_app/test/features/subjects/subject_detail_page_test.dart
+ import go_router
+ StaticDocumentsApi.listDocumentKnowledgeUnits
+ test tap document vers détail document
```

## 17. Passes de review

Passe Audit / Architecture :

- Verdict : le lot respecte la séparation controller/use case/repository côté NestJS.
- Point surveillé : `GET /documents/:documentId` ne doit plus exposer `storagePath`, y compris sur register/upload/list.

Passe Implémentation :

- Verdict : endpoints, data layer et page sont cohérents avec les patterns existants.
- Point surveillé : la page document reste locale et n'amorce pas le design system complet.

Passe Tests :

- Verdict : tests backend, parsing Flutter, controller Flutter et widget Flutter couvrent les chemins attendus.
- Point surveillé : la validation DB réelle reste impossible tant que PostgreSQL local n'est pas disponible.

Passe Sécurité / Données :

- Verdict : le backend filtre par `studentId`, n'expose pas `storagePath`, ne retourne pas de chunks non liés.
- Point surveillé : les extraits sources sont du texte de chunks DB ; une future politique de rétention sera nécessaire.

Passe Review critique finale :

- Verdict : le lot peut être considéré terminé pour le périmètre demandé.
- Point surveillé : avant LOT-017 ou LOT-018, il faut valider la migration sur une DB locale réelle.
