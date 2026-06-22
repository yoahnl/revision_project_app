import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../../presentation/design_system/components/revision_states.dart';
import '../../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../../presentation/design_system/tokens/revision_typography.dart';
import '../../../documents/domain/source_lifecycle.dart';
import '../../application/courses_providers.dart';
import '../../domain/course_models.dart';

class CourseSourcesBottomSheet extends ConsumerWidget {
  const CourseSourcesBottomSheet({required this.detail, super.key});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadCourseDocumentControllerProvider);
    final deleteState = ref.watch(deleteCourseDocumentControllerProvider);
    final archiveState = ref.watch(archiveCourseDocumentControllerProvider);
    final isUploading = uploadState.isLoading;
    final isUpdatingSource = deleteState.isLoading || archiveState.isLoading;
    final sources = detail.sources;

    return RevisionBottomSheetFrame(
      title: 'Sources',
      subtitle: detail.course.title,
      floatingAction: RevisionFloatingAddButton(
        onTap: isUploading ? null : () => _uploadSource(context, ref),
      ),
      children: [
        if (sources.isEmpty)
          RevisionEmptyState(
            title: 'Aucune source attachée',
            message:
                'Ajoute un PDF pour lancer le traitement documentaire de ce cours.',
            icon: Icons.source_outlined,
          )
        else
          for (final source in sources)
            RevisionSourceFileCard(
              fileName: source.fileName,
              statusLabel: _sourceStatusLabel(source),
              statusColor: _statusColor(source.status),
              trailing: IconButton(
                tooltip: 'Gérer la source ${source.fileName}',
                onPressed: isUpdatingSource
                    ? null
                    : () => _manageSource(context, ref, source),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: RevisionColors.textMuted,
                ),
              ),
            ),
        if (isUploading)
          const RevisionProcessingState(
            title: 'Upload en cours...',
            message: 'La source est envoyée pour analyse.',
          ),
        if (uploadState.hasError)
          Text(
            'Upload impossible pour le moment.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        if (deleteState.hasError)
          Text(
            'Impossible de modifier cette source.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        if (archiveState.hasError)
          Text(
            'Impossible d’archiver cette source.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              ref.invalidate(courseDetailProvider(detail.course.id));
              ref.invalidate(courseProgressProvider(detail.course.id));
              ref.invalidate(subjectProgressProvider(detail.course.subjectId));
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Rafraîchir'),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadSource(BuildContext context, WidgetRef ref) async {
    try {
      final uploaded = await ref
          .read(uploadCourseDocumentControllerProvider.notifier)
          .upload(detail: detail);

      if (!context.mounted || uploaded == null) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source ajoutée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ajouter cette source PDF.')),
      );
    }
  }

  Future<void> _manageSource(
    BuildContext context,
    WidgetRef ref,
    CourseDocument source,
  ) async {
    SourceLifecycleDecision decision;
    try {
      decision = await ref
          .read(coursesRepositoryProvider)
          .getCourseDocumentLifecycle(
            courseId: detail.course.id,
            documentId: source.documentId,
          );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de vérifier cette source.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    switch (decision.recommendedAction) {
      case SourceLifecycleAction.delete:
        await _deleteSource(context, ref, source);
        break;
      case SourceLifecycleAction.archive:
        await _archiveSource(context, ref, source);
        break;
      case SourceLifecycleAction.block:
      case SourceLifecycleAction.unknown:
        await _showLifecycleBlockedDialog(context, decision);
        break;
    }
  }

  Future<void> _deleteSource(
    BuildContext context,
    WidgetRef ref,
    CourseDocument source,
  ) async {
    final confirmed = await _confirmDeleteSource(context, source.fileName);
    if (!confirmed || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(deleteCourseDocumentControllerProvider.notifier)
          .delete(detail: detail, documentId: source.documentId);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source supprimée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer cette source.')),
      );
    }
  }

  Future<void> _archiveSource(
    BuildContext context,
    WidgetRef ref,
    CourseDocument source,
  ) async {
    final confirmed = await _confirmArchiveSource(context, source.fileName);
    if (!confirmed || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(archiveCourseDocumentControllerProvider.notifier)
          .archive(detail: detail, documentId: source.documentId);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Source archivée')));
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’archiver cette source.')),
      );
    }
  }
}

Future<bool> _confirmDeleteSource(BuildContext context, String fileName) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer cette source ?'),
      content: Text(
        'Le PDF "$fileName" sera retiré de ce cours. Tu pourras le rajouter plus tard si besoin.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

Future<bool> _confirmArchiveSource(
  BuildContext context,
  String fileName,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Archiver cette source ?'),
      content: Text(
        'Le PDF "$fileName" ne sera plus utilisé pour préparer de nouvelles révisions, mais l’historique déjà créé sera conservé.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Archiver'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

Future<void> _showLifecycleBlockedDialog(
  BuildContext context,
  SourceLifecycleDecision decision,
) {
  final message = decision.blockingReasons.contains('SOURCE_PROCESSING')
      ? 'Cette source est encore en cours d’analyse. Réessaie quand elle sera prête.'
      : 'Cette source ne peut pas être modifiée pour le moment.';

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Action indisponible'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Compris'),
        ),
      ],
    ),
  );
}

String _statusLabel(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.uploaded => 'Téléversée',
    CourseDocumentStatus.processing => 'Traitement en cours',
    CourseDocumentStatus.ready => 'Prête',
    CourseDocumentStatus.failed => 'Erreur',
    CourseDocumentStatus.unknown => 'Statut inconnu',
  };
}

String _sourceStatusLabel(CourseDocument source) {
  if (source.status != CourseDocumentStatus.failed) {
    return _statusLabel(source.status);
  }

  return '${_statusLabel(source.status)} · ${_analysisErrorLabel(source.errorCode)}';
}

String _analysisErrorLabel(String? errorCode) {
  return switch (errorCode) {
    'KNOWLEDGE_EXTRACTION_FAILED' => 'Analyse du PDF impossible',
    'KNOWLEDGE_EXTRACTION_EMPTY' => 'Aucune notion trouvée',
    'DOCUMENT_TEXT_EMPTY' => 'PDF sans texte exploitable',
    _ => 'Erreur d’analyse',
  };
}

Color _statusColor(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.ready => RevisionColors.mint,
    CourseDocumentStatus.processing => RevisionColors.blue,
    CourseDocumentStatus.failed => RevisionColors.red,
    CourseDocumentStatus.uploaded => RevisionColors.amber,
    CourseDocumentStatus.unknown => RevisionColors.violet,
  };
}
