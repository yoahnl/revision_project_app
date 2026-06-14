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
