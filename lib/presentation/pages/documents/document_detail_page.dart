import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/presentation/theme/app_colors.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:Neralune/presentation/widgets/revision_page.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';
import 'package:Neralune/presentation/widgets/revision_status_pill.dart';

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
            if (detail.state == DocumentDetailLoadState.ready) ...[
              const SizedBox(height: AppSpacing.xl),
              _DocumentArtifactsSection(
                documentId: detail.document.id,
                controller: widget.controller,
              ),
            ],
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
        subjectId: detail.document.subjectId,
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
  const _ReadyKnowledgeUnits({
    required this.subjectId,
    required this.units,
  });

  final String subjectId;
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
        Text(
          'Notions extraites',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        for (final unit in units)
          _KnowledgeUnitPanel(subjectId: subjectId, unit: unit),
      ],
    );
  }
}

class _KnowledgeUnitPanel extends StatelessWidget {
  const _KnowledgeUnitPanel({
    required this.subjectId,
    required this.unit,
  });

  final String subjectId;
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
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: RevisionButton(
              onPressed: () => context.go(
                Uri(
                  path: activitiesRoutePath,
                  queryParameters: {
                    'subjectId': subjectId,
                    'knowledgeUnitId': unit.id,
                  },
                ).toString(),
              ),
              icon: Icons.edit_note,
              label: 'Question ouverte',
              style: RevisionButtonStyle.ghost,
            ),
          ),
          if (unit.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Sources', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Column(
              spacing: AppSpacing.s,
              children: [
                for (final source in unit.sources)
                  DocumentSourceExcerpt(
                    text: source.text,
                    index: source.index,
                    pageNumber: source.pageNumber,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentArtifactsSection extends StatefulWidget {
  const _DocumentArtifactsSection({
    required this.documentId,
    required this.controller,
  });

  final String documentId;
  final DocumentsController controller;

  @override
  State<_DocumentArtifactsSection> createState() =>
      _DocumentArtifactsSectionState();
}

class _DocumentArtifactsSectionState extends State<_DocumentArtifactsSection> {
  var _isLoading = true;
  var _isGeneratingSummary = false;
  var _isGeneratingRevisionSheet = false;
  DocumentArtifacts? _artifacts;
  String? _loadError;
  String? _summaryError;
  String? _revisionSheetError;

  @override
  void initState() {
    super.initState();
    _loadArtifacts();
  }

  @override
  void didUpdateWidget(_DocumentArtifactsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentId != widget.documentId) {
      _loadArtifacts();
    }
  }

  Future<void> _loadArtifacts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final artifacts = await widget.controller.loadDocumentArtifacts(
        widget.documentId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _artifacts = artifacts;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = _artifactErrorLabel(error);
        _isLoading = false;
      });
    }
  }

  Future<void> _generateSummary() async {
    if (_isGeneratingSummary) {
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
      _summaryError = null;
    });

    try {
      final summary = await widget.controller.generateDocumentSummary(
        widget.documentId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _artifacts =
            (_artifacts ??
                    const DocumentArtifacts(summary: null, revisionSheet: null))
                .copyWith(summary: summary);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _summaryError = _artifactErrorLabel(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    }
  }

  Future<void> _generateRevisionSheet() async {
    if (_isGeneratingRevisionSheet) {
      return;
    }

    setState(() {
      _isGeneratingRevisionSheet = true;
      _revisionSheetError = null;
    });

    try {
      final revisionSheet = await widget.controller.generateRevisionSheet(
        widget.documentId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _artifacts =
            (_artifacts ??
                    const DocumentArtifacts(summary: null, revisionSheet: null))
                .copyWith(revisionSheet: revisionSheet);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _revisionSheetError = _artifactErrorLabel(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingRevisionSheet = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artifacts = _artifacts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.itemGap,
      children: [
        Text('Supports IA', style: Theme.of(context).textTheme.titleLarge),
        if (_isLoading)
          const RevisionPanel(child: LinearProgressIndicator())
        else if (_loadError != null)
          RevisionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impossible de charger les supports IA',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(_loadError!),
                const SizedBox(height: AppSpacing.m),
                RevisionButton(
                  onPressed: _loadArtifacts,
                  icon: Icons.refresh,
                  label: 'Reessayer',
                  style: RevisionButtonStyle.ghost,
                ),
              ],
            ),
          )
        else ...[
          _SummaryArtifactPanel(
            summary: artifacts?.summary,
            isGenerating: _isGeneratingSummary,
            errorMessage: _summaryError,
            onGenerate: _generateSummary,
          ),
          _RevisionSheetArtifactPanel(
            revisionSheet: artifacts?.revisionSheet,
            isGenerating: _isGeneratingRevisionSheet,
            errorMessage: _revisionSheetError,
            onGenerate: _generateRevisionSheet,
          ),
        ],
      ],
    );
  }
}

class _SummaryArtifactPanel extends StatelessWidget {
  const _SummaryArtifactPanel({
    required this.summary,
    required this.isGenerating,
    required this.errorMessage,
    required this.onGenerate,
  });

  final DocumentSummary? summary;
  final bool isGenerating;
  final String? errorMessage;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resume', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          if (isGenerating) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.m),
            const Text('Generation du resume en cours'),
          ] else if (summary == null) ...[
            const Text('Aucun resume genere pour ce document.'),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.auto_awesome,
              label: 'Generer le resume',
            ),
          ] else if (summary.status == 'FAILED') ...[
            Text(_artifactFailedLabel(summary.errorCode)),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.refresh,
              label: 'Reessayer',
              style: RevisionButtonStyle.ghost,
            ),
          ] else ...[
            Text(summary.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(summary.content),
            if (summary.keyPoints.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(title: 'Points cles', items: summary.keyPoints),
            ],
            if (summary.limits != null &&
                summary.limits!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              Text('Limites', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.s),
              Text(summary.limits!),
            ],
            if (summary.sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _ArtifactSources(sources: summary.sources),
            ],
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevisionSheetArtifactPanel extends StatelessWidget {
  const _RevisionSheetArtifactPanel({
    required this.revisionSheet,
    required this.isGenerating,
    required this.errorMessage,
    required this.onGenerate,
  });

  final RevisionSheet? revisionSheet;
  final bool isGenerating;
  final String? errorMessage;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final revisionSheet = this.revisionSheet;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fiche de revision',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          if (isGenerating) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpacing.m),
            const Text('Generation de la fiche en cours'),
          ] else if (revisionSheet == null) ...[
            const Text('Aucune fiche generee pour ce document.'),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.auto_stories,
              label: 'Generer la fiche',
            ),
          ] else if (revisionSheet.status == 'FAILED') ...[
            Text(_artifactFailedLabel(revisionSheet.errorCode)),
            const SizedBox(height: AppSpacing.m),
            RevisionButton(
              onPressed: onGenerate,
              icon: Icons.refresh,
              label: 'Reessayer',
              style: RevisionButtonStyle.ghost,
            ),
          ] else ...[
            Text(
              revisionSheet.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (revisionSheet.introduction != null &&
                revisionSheet.introduction!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text(revisionSheet.introduction!),
            ],
            if (revisionSheet.sections.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              Column(
                spacing: AppSpacing.l,
                children: [
                  for (final section in revisionSheet.sections)
                    _RevisionSheetSectionBlock(section: section),
                ],
              ),
            ],
            if (revisionSheet.keyPoints.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(title: 'A retenir', items: revisionSheet.keyPoints),
            ],
            if (revisionSheet.commonMistakes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(
                title: 'Pieges classiques',
                items: revisionSheet.commonMistakes,
              ),
            ],
            if (revisionSheet.mustKnow.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(title: 'Indispensables', items: revisionSheet.mustKnow),
            ],
            if (revisionSheet.practiceSuggestions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.l),
              _TextList(
                title: 'Suggestions de pratique',
                items: revisionSheet.practiceSuggestions,
              ),
            ],
          ],
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.m),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RevisionSheetSectionBlock extends StatelessWidget {
  const _RevisionSheetSectionBlock({required this.section});

  final RevisionSheetSection section;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.18),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(section.content),
            if (section.sources.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.m),
              _ArtifactSources(sources: section.sources),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextList extends StatelessWidget {
  const _TextList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.xs,
          children: [
            for (final item in items)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(child: Text(item)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _ArtifactSources extends StatelessWidget {
  const _ArtifactSources({required this.sources});

  final List<DocumentArtifactSource> sources;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sources', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        Column(
          spacing: AppSpacing.s,
          children: [
            for (final source in sources)
              DocumentSourceExcerpt(
                text: source.text,
                index: source.index,
                pageNumber: source.pageNumber,
              ),
          ],
        ),
      ],
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

String _artifactFailedLabel(String? errorCode) {
  return switch (errorCode) {
    'SUMMARY_SOURCE_INVALID' => 'Sources du resume invalides',
    'REVISION_SHEET_SOURCE_INVALID' => 'Sources de la fiche invalides',
    'GENERATION_FAILED' => 'Generation impossible',
    _ => 'Support IA indisponible',
  };
}

String _artifactErrorLabel(Object error) {
  if (error is DocumentNotReadyException) {
    return 'Le document doit etre pret avant de generer un support.';
  }

  if (error is DocumentArtifactRequestException) {
    return switch (error.statusCode) {
      409 => 'Le document n est pas encore pret.',
      422 => 'La generation a produit un resultat invalide.',
      502 => 'Le service IA est indisponible.',
      _ => 'Erreur API ${error.statusCode}',
    };
  }

  return 'Erreur inattendue';
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
