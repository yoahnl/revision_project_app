import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Neralune/app/router/app_routes.dart';
import 'package:Neralune/features/documents/application/documents_controller.dart';
import 'package:Neralune/features/documents/application/subject_documents_notifier.dart';
import 'package:Neralune/features/documents/domain/revision_document.dart';
import 'package:Neralune/features/subjects/application/subjects_controller.dart';
import 'package:Neralune/features/subjects/domain/subject.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/components/revision_states.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_colors.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_spacing.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_subject_visuals.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';
import 'package:Neralune/presentation/pages/subjects/widgets/subject_document_list_item.dart';
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
        title: const Text('Supprimer la source ?'),
        content: Text(
          'Cette action supprimera les notions et supports liés à ${document.fileName}.',
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
        const SnackBar(content: Text('Impossible de supprimer la source')),
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
          return const RevisionPageScaffold(
            children: [RevisionLoadingState(label: 'Chargement de la matière')],
          );
        }

        if (snapshot.hasError || subject == null) {
          return RevisionPageScaffold(
            children: [
              RevisionErrorState(
                title: 'Matière indisponible',
                message: 'Impossible de charger cette matière pour le moment.',
                actionLabel: 'Réessayer',
                onAction: _reloadSubject,
              ),
            ],
          );
        }

        final visualTheme = revisionSubjectVisualThemeFor(subject.name);
        final documents = ref.watch(
          subjectDocumentsNotifierProvider(widget.subjectId),
        );

        return RevisionPageScaffold(
          headerChildren: [
            RevisionGlassCard(
              gradient: visualTheme.gradient,
              borderColor: visualTheme.accent.withValues(alpha: 0.40),
              child: Row(
                children: [
                  RevisionIconTile(
                    icon: visualTheme.icon,
                    accent: visualTheme.accent,
                    size: 58,
                  ),
                  const SizedBox(width: RevisionSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: RevisionTypography.pageTitle,
                        ),
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          'Priorité ${subject.priority} · ${_subjectRhythmLabel(subject)}',
                          style: RevisionTypography.body.copyWith(
                            color: RevisionColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: RevisionSpacing.s,
              runSpacing: RevisionSpacing.s,
              children: [
                RevisionHeaderActionPill(
                  label: 'Réviser',
                  icon: Icons.play_arrow_rounded,
                  accent: visualTheme.accent,
                  onTap: () => context.go(AppRoutes.revisions),
                ),
                RevisionHeaderActionPill(
                  label: 'Rafraîchir',
                  icon: Icons.refresh_rounded,
                  accent: RevisionColors.cyan,
                  onTap: _reloadSubject,
                ),
              ],
            ),
          ],
          children: [
            RevisionSectionHeader(
              title: 'Sources importées',
              subtitle:
                  'Ajoute des PDF pour préparer les notions et les fiches.',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: DocumentImportButton(
                subjectId: widget.subjectId,
                controller: widget.documentsController,
                onImported: _reloadDocuments,
              ),
            ),
            documents.when(
              loading: () =>
                  const RevisionLoadingState(label: 'Chargement des sources'),
              error: (error, stackTrace) => RevisionErrorState(
                title: 'Sources indisponibles',
                message: 'Impossible de charger les sources de cette matière.',
                actionLabel: 'Réessayer',
                onAction: _reloadDocuments,
              ),
              data: (documents) {
                if (documents.isEmpty) {
                  return RevisionEmptyState(
                    icon: Icons.upload_file_rounded,
                    title: 'Aucune source importée',
                    message:
                        'Importe un PDF de cours pour commencer à structurer cette matière.',
                    actionLabel: 'Réessayer',
                    onAction: _reloadDocuments,
                  );
                }

                return Column(
                  children: [
                    for (final (index, document) in documents.indexed) ...[
                      if (index > 0) const SizedBox(height: RevisionSpacing.m),
                      SubjectDocumentListItem(
                        document: document,
                        onTap: () => context.go(
                          '/subjects/${widget.subjectId}/documents/${document.id}',
                        ),
                        onDelete: () => _deleteDocument(document),
                      ),
                    ],
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

String _subjectRhythmLabel(Subject subject) {
  if (subject.weeklyMinutes <= 0) {
    return 'rythme à préciser';
  }

  final hours = subject.weeklyMinutes ~/ 60;
  final minutes = subject.weeklyMinutes % 60;

  if (minutes == 0) {
    return '$hours h par semaine';
  }

  if (hours == 0) {
    return '$minutes min par semaine';
  }

  return '$hours h $minutes min par semaine';
}
