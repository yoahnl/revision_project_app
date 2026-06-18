import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_not_found_page.dart';

class CourseDetailPage extends ConsumerWidget {
  const CourseDetailPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(courseDetailProvider(courseId));

    return detail.when(
      loading: () => const RevisionPageScaffold(
        children: [RevisionLoadingState(label: 'Chargement du cours réel')],
      ),
      error: (error, stackTrace) {
        if (error is CourseNotFoundException) {
          return CourseNotFoundPage(courseId: courseId);
        }

        return RevisionPageScaffold(
          children: [
            Text('Cours indisponible', style: RevisionTypography.pageTitle),
            RevisionErrorState(
              title: 'Impossible de charger ce cours',
              message:
                  'Aucune fixture ne remplacera ce cours. Réessaie ou retourne à l’accueil.',
              actionLabel: 'Retour à l’accueil',
              onAction: () => context.go(AppRoutes.home),
            ),
          ],
        );
      },
      data: (detail) => _CourseDetailContent(detail: detail),
    );
  }
}

class _CourseDetailContent extends ConsumerStatefulWidget {
  const _CourseDetailContent({required this.detail});

  final CourseDetail detail;

  @override
  ConsumerState<_CourseDetailContent> createState() =>
      _CourseDetailContentState();
}

class _CourseDetailContentState extends ConsumerState<_CourseDetailContent> {
  static const _pollInterval = Duration(seconds: 2);
  static const _pollTimeout = Duration(minutes: 2);

  Timer? _pollTimer;
  DateTime? _pollStartedAt;
  bool _pollTimedOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPolling());
  }

  @override
  void didUpdateWidget(covariant _CourseDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPolling();
  }

  @override
  void dispose() {
    _stopPolling(resetTimeout: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final course = detail.course;

    return RevisionPageScaffold(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour',
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Spacer(),
          ],
        ),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.subject.name, style: RevisionTypography.caption),
              const SizedBox(height: RevisionSpacing.xs),
              Text(course.title, style: RevisionTypography.pageTitle),
              if (course.description != null) ...[
                const SizedBox(height: RevisionSpacing.s),
                Text(course.description!, style: RevisionTypography.body),
              ],
              const SizedBox(height: RevisionSpacing.l),
              Wrap(
                spacing: RevisionSpacing.s,
                runSpacing: RevisionSpacing.s,
                children: [
                  _InfoPill(label: _courseMeta(course)),
                  _InfoPill(label: _sourceMeta(course)),
                ],
              ),
            ],
          ),
        ),
        _CourseActions(detail: detail),
        if (_pollTimedOut)
          RevisionGlassCard(
            child: Text(
              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
              style: RevisionTypography.body,
            ),
          ),
        _SourcesSection(
          sources: detail.sources,
          onRefresh: () => ref.invalidate(courseDetailProvider(course.id)),
        ),
      ],
    );
  }

  void _syncPolling() {
    if (!mounted) {
      return;
    }

    final hasPendingSource = widget.detail.sources.any(_isPendingSource);

    if (!hasPendingSource) {
      _stopPolling(resetTimeout: true);
      return;
    }

    _pollStartedAt ??= DateTime.now();
    _pollTimer ??= Timer.periodic(_pollInterval, (_) {
      final startedAt = _pollStartedAt;
      if (startedAt != null &&
          DateTime.now().difference(startedAt) >= _pollTimeout) {
        if (mounted) {
          setState(() => _pollTimedOut = true);
        }
        _stopPolling(resetTimeout: false);
        return;
      }

      ref.invalidate(courseDetailProvider(widget.detail.course.id));
    });
  }

  void _stopPolling({required bool resetTimeout}) {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollStartedAt = null;
    if (resetTimeout && _pollTimedOut && mounted) {
      setState(() => _pollTimedOut = false);
    }
  }
}

class _CourseActions extends ConsumerWidget {
  const _CourseActions({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadCourseDocumentControllerProvider);
    final quickRevisionState = ref.watch(
      startCourseQuickRevisionControllerProvider,
    );
    final isUploading = uploadState.isLoading;
    final isStartingQuickRevision = quickRevisionState.isLoading;
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Actions', style: RevisionTypography.sectionTitle),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: isUploading ? 'Upload en cours...' : 'Ajouter une source',
            icon: Icons.upload_file_rounded,
            expanded: true,
            onPressed: isUploading
                ? null
                : () async {
                    try {
                      final uploaded = await ref
                          .read(uploadCourseDocumentControllerProvider.notifier)
                          .upload(detail: detail);

                      if (!context.mounted || uploaded == null) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Source ajoutée')),
                      );
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Impossible d’ajouter cette source PDF.',
                          ),
                        ),
                      );
                    }
                  },
          ),
          if (uploadState.hasError) ...[
            const SizedBox(height: RevisionSpacing.s),
            Text(
              'Upload impossible pour le moment.',
              style: RevisionTypography.caption.copyWith(
                color: RevisionColors.red,
              ),
            ),
          ],
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: _sheetActionLabel(detail.sources),
            icon: Icons.article_outlined,
            expanded: true,
            onPressed: hasReadySource
                ? () => context.go(AppRoutes.courseSheet(detail.course.id))
                : null,
          ),
          const SizedBox(height: RevisionSpacing.m),
          RevisionGradientButton(
            label: isStartingQuickRevision
                ? 'Démarrage...'
                : _quickRevisionActionLabel(detail.sources),
            icon: Icons.flash_on_rounded,
            expanded: true,
            onPressed: hasReadySource && !isStartingQuickRevision
                ? () async {
                    try {
                      final response = await ref
                          .read(
                            startCourseQuickRevisionControllerProvider.notifier,
                          )
                          .start(detail: detail);

                      if (!context.mounted) {
                        return;
                      }

                      context.go(
                        AppRoutes.revisionSession(
                          sessionId: response.session.id,
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_quickRevisionErrorLabel(error)),
                        ),
                      );
                    }
                  }
                : null,
          ),
          if (quickRevisionState.hasError) ...[
            const SizedBox(height: RevisionSpacing.s),
            Text(
              'Révision rapide indisponible pour ce cours.',
              style: RevisionTypography.caption.copyWith(
                color: RevisionColors.red,
              ),
            ),
          ],
          const SizedBox(height: RevisionSpacing.s),
          Text(
            'Révision approfondie et préparation examen restent MVP+.',
            style: RevisionTypography.caption,
          ),
        ],
      ),
    );
  }
}

String _sheetActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Fiche de cours';
  }

  if (sources.any(_isPendingSource)) {
    return 'Fiche disponible après traitement';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Aucune source prête';
  }

  return 'Ajoute une source pour créer une fiche';
}

String _quickRevisionActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Révision rapide';
  }

  if (sources.any(_isPendingSource)) {
    return 'Révision disponible après traitement';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Aucune source prête';
  }

  return 'Ajoute une source pour réviser';
}

String _quickRevisionErrorLabel(Object error) {
  if (error is CourseQuickRevisionUnavailableException) {
    return error.message;
  }

  if (error is CourseNotFoundException) {
    return 'Cours introuvable.';
  }

  return 'Impossible de démarrer la révision rapide.';
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.sources, required this.onRefresh});

  final List<CourseDocument> sources;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const RevisionEmptyState(
        title: 'Aucune source attachée',
        message:
            'Ajoute un PDF réel pour lancer le traitement documentaire de ce cours.',
        icon: Icons.source_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sources', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Rafraîchir'),
          ),
        ),
        const SizedBox(height: RevisionSpacing.s),
        for (final source in sources) ...[
          RevisionGlassCard(
            child: Row(
              children: [
                RevisionIconTile(
                  icon: Icons.picture_as_pdf_rounded,
                  accent: _statusColor(source.status),
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(source.fileName, style: RevisionTypography.body),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        _statusLabel(source.status),
                        style: RevisionTypography.caption,
                      ),
                      if (source.status == CourseDocumentStatus.failed &&
                          source.errorCode != null) ...[
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          'Code erreur : ${source.errorCode}',
                          style: RevisionTypography.caption.copyWith(
                            color: RevisionColors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
      ],
    );
  }
}

bool _isPendingSource(CourseDocument source) {
  return source.status == CourseDocumentStatus.uploaded ||
      source.status == CourseDocumentStatus.processing;
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RevisionColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.m,
          vertical: RevisionSpacing.s,
        ),
        child: Text(label, style: RevisionTypography.caption),
      ),
    );
  }
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Cours réel' : parts.join(' · ');
}

String _sourceMeta(CourseListItem course) {
  final sourceLabel = course.sourceCount <= 1 ? 'source' : 'sources';
  final readyLabel = course.readySourceCount <= 1 ? 'prête' : 'prêtes';

  return '${course.sourceCount} $sourceLabel · ${course.readySourceCount} $readyLabel';
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

Color _statusColor(CourseDocumentStatus status) {
  return switch (status) {
    CourseDocumentStatus.ready => RevisionColors.mint,
    CourseDocumentStatus.processing => RevisionColors.blue,
    CourseDocumentStatus.failed => RevisionColors.red,
    CourseDocumentStatus.uploaded => RevisionColors.amber,
    CourseDocumentStatus.unknown => RevisionColors.violet,
  };
}
