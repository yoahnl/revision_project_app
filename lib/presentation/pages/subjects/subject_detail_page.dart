import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/core/routing/route_paths.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/application/subject_documents_notifier.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/theme/app_colors.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:Neralune/presentation/widgets/revision_icon_badge.dart';
import 'package:Neralune/presentation/widgets/revision_page.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';
import 'package:Neralune/presentation/widgets/revision_status_pill.dart';
import 'package:Neralune/presentation/widgets/documents/document_import_button.dart';

class SubjectDetailPage extends ConsumerStatefulWidget {
  const SubjectDetailPage({
    required this.subjectId,
    required this.controller,
    required this.documentsController,
    super.key,
  });

  final String subjectId;
  final SubjectsController controller;
  final DocumentsController documentsController;

  @override
  ConsumerState<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends ConsumerState<SubjectDetailPage> {
  late Future<Subject> _subject;

  @override
  void initState() {
    super.initState();
    _subject = widget.controller.getSubject(widget.subjectId);
  }

  void _reloadSubject() {
    setState(() {
      _subject = widget.controller.getSubject(widget.subjectId);
    });
    _reloadDocuments();
  }

  void _reloadDocuments() {
    ref
        .read(subjectDocumentsNotifierProvider(widget.subjectId).notifier)
        .reload();
  }

  Future<void> _deleteDocument(RevisionDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le cours ?'),
        content: const Text(
          'Cette action supprimera les notions et supports lies a ce cours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref
          .read(subjectDocumentsNotifierProvider(widget.subjectId).notifier)
          .deleteDocument(document.id);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer le cours')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Subject>(
      future: _subject,
      builder: (context, snapshot) {
        final subject = snapshot.data;

        if (snapshot.connectionState != ConnectionState.done) {
          return const RevisionPage(
            title: 'Chargement',
            children: [LinearProgressIndicator()],
          );
        }

        if (snapshot.hasError || subject == null) {
          return RevisionPage(
            title: 'Matiere indisponible',
            children: [
              Text(
                'Impossible de charger la matiere',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Align(
                alignment: Alignment.centerLeft,
                child: RevisionButton(
                  onPressed: _reloadSubject,
                  icon: Icons.refresh,
                  label: 'Reessayer',
                  style: RevisionButtonStyle.ghost,
                ),
              ),
            ],
          );
        }

        final documents = ref.watch(
          subjectDocumentsNotifierProvider(widget.subjectId),
        );

        return RevisionPage(
          title: subject.name,
          subtitle: 'Priorite ${subject.priority}',
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: RevisionButton(
                onPressed: () => context.go(
                  Uri(
                    path: activitiesRoutePath,
                    queryParameters: {'subjectId': widget.subjectId},
                  ).toString(),
                ),
                icon: Icons.play_arrow,
                label: 'Lancer un diagnostic',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cours',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _reloadSubject,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recharger',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.centerLeft,
              child: DocumentImportButton(
                subjectId: widget.subjectId,
                controller: widget.documentsController,
                onImported: _reloadDocuments,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            documents.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) =>
                  _DocumentsErrorState(onRetry: _reloadDocuments),
              data: (documents) {
                if (documents.isEmpty) {
                  return const Text('Aucun cours importe');
                }

                return Column(
                  spacing: AppSpacing.itemGap,
                  children: [
                    for (final document in documents)
                      _DocumentListItem(
                        document: document,
                        onTap: () => context.go(
                          documentDetailRoutePath(
                            subjectId: widget.subjectId,
                            documentId: document.id,
                          ),
                        ),
                        onDelete: () => _deleteDocument(document),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _DocumentsErrorState extends StatelessWidget {
  const _DocumentsErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impossible de charger les cours',
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
    );
  }
}

class _DocumentListItem extends StatelessWidget {
  const _DocumentListItem({
    required this.document,
    required this.onTap,
    required this.onDelete,
  });

  final RevisionDocument document;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      onTap: onTap,
      child: Row(
        children: [
          const _DocumentIcon(),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.fileName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _documentKindLabel(document.kind),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          _DocumentStatusChip(
            status: document.status,
            errorCode: document.errorCode,
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer le cours',
          ),
          const SizedBox(width: AppSpacing.s),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _DocumentIcon extends StatelessWidget {
  const _DocumentIcon();

  @override
  Widget build(BuildContext context) {
    return const RevisionIconBadge(
      icon: Icons.picture_as_pdf_outlined,
      color: AppColors.aqua,
    );
  }
}

class _DocumentStatusChip extends StatelessWidget {
  const _DocumentStatusChip({required this.status, this.errorCode});

  final String status;
  final String? errorCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (:label, :color) = switch (status) {
      'UPLOADED' => (label: 'Importe', color: colorScheme.secondary),
      'PROCESSING' => (label: 'Analyse', color: colorScheme.primary),
      'READY' => (label: 'Pret', color: colorScheme.tertiary),
      'FAILED' => (
        label: _failedDocumentLabel(errorCode),
        color: colorScheme.error,
      ),
      _ => (label: status, color: colorScheme.outline),
    };

    return RevisionStatusPill(label: label, color: color);
  }
}

String _failedDocumentLabel(String? errorCode) {
  return switch (errorCode) {
    'DOCUMENT_TEXT_EMPTY' => 'PDF sans texte',
    'DOCUMENT_TEXT_EXTRACTION_FAILED' => 'Lecture PDF impossible',
    'KNOWLEDGE_EXTRACTION_EMPTY' => 'Aucune notion',
    'KNOWLEDGE_EXTRACTION_FAILED' => 'Erreur IA',
    'DOCUMENT_UNSUPPORTED_MIME_TYPE' => 'Format invalide',
    _ => 'Echec',
  };
}

String _documentKindLabel(String kind) {
  return switch (kind) {
    'COURSE_PDF' => 'PDF de cours',
    'EXAM_PDF' => 'PDF examen',
    'EXAM_IMAGE' => 'Image examen',
    _ => kind,
  };
}
