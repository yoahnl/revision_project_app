import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_subject_visuals.dart';
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
        children: [RevisionLoadingState(label: 'Chargement du cours')],
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
    final visual = revisionSubjectVisualThemeFor(
      '${detail.subject.name} ${course.title}',
    );
    final progress = ref.watch(courseProgressProvider(course.id));
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return RevisionPageScaffold(
      children: [
        _CourseTopBar(
          detail: detail,
          visual: visual,
          hasReadySource: hasReadySource,
        ),
        _CourseHero(detail: detail, visual: visual),
        _StatsStrip(course: course, progress: progress, visual: visual),
        _CourseProgressSection(
          progress: progress,
          onRetry: () => ref.invalidate(courseProgressProvider(course.id)),
        ),
        _CourseModes(detail: detail, visual: visual),
        if (_pollTimedOut)
          RevisionGlassCard(
            child: Text(
              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
              style: RevisionTypography.body,
            ),
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
      ref.invalidate(courseProgressProvider(widget.detail.course.id));
      ref.invalidate(subjectProgressProvider(widget.detail.course.subjectId));
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

class _CourseTopBar extends ConsumerWidget {
  const _CourseTopBar({
    required this.detail,
    required this.visual,
    required this.hasReadySource,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final bool hasReadySource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Retour',
          onPressed: () => _popOrGo(context, AppRoutes.home),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Spacer(),
        RevisionHeaderActionPill(
          label: 'Fiche',
          icon: Icons.article_outlined,
          accent: visual.accent,
          selected: hasReadySource,
          onTap: hasReadySource
              ? () => context.push(AppRoutes.courseSheet(detail.course.id))
              : null,
        ),
        const SizedBox(width: RevisionSpacing.s),
        RevisionHeaderActionPill(
          label: 'Sources',
          icon: Icons.description_outlined,
          accent: visual.accent,
          onTap: () => _showSourcesSheet(context, ref, detail),
        ),
      ],
    );
  }
}

class _CourseHero extends StatelessWidget {
  const _CourseHero({required this.detail, required this.visual});

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final course = detail.course;

    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.l),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          visual.accent.withValues(alpha: 0.30),
          RevisionColors.glassStrong,
        ],
      ),
      borderColor: visual.accent.withValues(alpha: 0.36),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionIconTile(icon: visual.icon, accent: visual.accent, size: 64),
          const SizedBox(width: RevisionSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.subject.name,
                  style: RevisionTypography.caption.copyWith(
                    color: visual.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(course.title, style: RevisionTypography.pageTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(_courseMeta(course), style: RevisionTypography.body),
                if (course.description != null) ...[
                  const SizedBox(height: RevisionSpacing.m),
                  Text(course.description!, style: RevisionTypography.body),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.course,
    required this.progress,
    required this.visual,
  });

  final CourseListItem course;
  final AsyncValue<CourseProgress> progress;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final progressValue = progress.maybeWhen(
      data: (progress) => _percent(progress.estimatedGlobalMastery),
      orElse: () => 'En attente',
    );

    return RevisionStatTriplet(
      items: [
        RevisionStatItem(
          icon: Icons.track_changes_rounded,
          label: 'Progression',
          value: progressValue,
          color: visual.accent,
        ),
        RevisionStatItem(
          icon: Icons.schedule_rounded,
          label: 'Temps estimé',
          value: course.estimatedMinutes == null
              ? 'À préciser'
              : '${course.estimatedMinutes} min',
          color: RevisionColors.textMuted,
        ),
        RevisionStatItem(
          icon: Icons.star_border_rounded,
          label: 'Difficulté',
          value: _difficultyLabel(course.difficulty),
          color: RevisionColors.amber,
        ),
      ],
    );
  }
}

class _CourseProgressSection extends StatelessWidget {
  const _CourseProgressSection({required this.progress, required this.onRetry});

  final AsyncValue<CourseProgress> progress;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return progress.when(
      loading: () =>
          const RevisionLoadingState(label: 'Chargement de la progression'),
      error: (error, stackTrace) => RevisionErrorState(
        title: 'Progression indisponible',
        message: 'Les métriques réelles ne sont pas disponibles pour ce cours.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      ),
      data: (progress) => RevisionGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progression réelle', style: RevisionTypography.sectionTitle),
            const SizedBox(height: RevisionSpacing.m),
            Row(
              children: [
                RevisionMasteryRing(
                  value: progress.estimatedGlobalMastery,
                  label: _percent(progress.estimatedGlobalMastery),
                  caption: 'global',
                  color: _progressColor(progress.state),
                  size: 92,
                ),
                const SizedBox(width: RevisionSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress.practicedKnowledgeUnitCount}/${progress.knowledgeUnitCount} notions travaillées',
                        style: RevisionTypography.sectionTitle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: RevisionSpacing.s),
                      RevisionProgressLine(
                        value: progress.coverage,
                        color: _progressColor(progress.state),
                        height: 8,
                      ),
                      const SizedBox(height: RevisionSpacing.s),
                      Text(
                        _masteryLabel(progress),
                        style: RevisionTypography.caption,
                      ),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        'Estimation globale : ${_percent(progress.estimatedGlobalMastery)}',
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RevisionSpacing.m),
            Text(
              _progressStateLabel(progress.state),
              style: RevisionTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseModes extends ConsumerWidget {
  const _CourseModes({required this.detail, required this.visual});

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickRevisionState = ref.watch(
      startCourseQuickRevisionControllerProvider,
    );
    final isStartingQuickRevision = quickRevisionState.isLoading;
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Modes de révision', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: isStartingQuickRevision ? 'Démarrage...' : 'Révision rapide',
          description: _quickRevisionActionLabel(detail.sources),
          icon: Icons.flash_on_rounded,
          accent: RevisionColors.blue,
          trailingLabel: hasReadySource ? null : 'Bientôt',
          enabled: hasReadySource && !isStartingQuickRevision,
          onTap: () => _startQuickRevision(context, ref, detail),
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Révision approfondie',
          description: 'Cours complet et exemples détaillés.',
          icon: Icons.menu_book_rounded,
          accent: RevisionColors.violet,
          trailingLabel: 'MVP+',
          enabled: false,
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Préparation examen',
          description: 'Entraînements et sujets corrigés.',
          icon: Icons.gps_fixed_rounded,
          accent: RevisionColors.pink,
          trailingLabel: 'MVP+',
          enabled: false,
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
      ],
    );
  }

  Future<void> _startQuickRevision(
    BuildContext context,
    WidgetRef ref,
    CourseDetail detail,
  ) async {
    try {
      final response = await ref
          .read(startCourseQuickRevisionControllerProvider.notifier)
          .start(detail: detail);

      if (!context.mounted) {
        return;
      }

      context.go(AppRoutes.revisionSession(sessionId: response.session.id));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_quickRevisionErrorLabel(error))));
    }
  }
}

void _showSourcesSheet(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SourcesBottomSheet(detail: detail),
  );
}

class _SourcesBottomSheet extends ConsumerWidget {
  const _SourcesBottomSheet({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadCourseDocumentControllerProvider);
    final deleteState = ref.watch(deleteCourseDocumentControllerProvider);
    final isUploading = uploadState.isLoading;
    final isDeleting = deleteState.isLoading;
    final sources = detail.sources;

    return RevisionBottomSheetFrame(
      title: 'Sources',
      subtitle: detail.course.title,
      floatingAction: RevisionFloatingAddButton(
        onTap: isUploading ? () {} : () => _uploadSource(context, ref),
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
              statusLabel:
                  source.status == CourseDocumentStatus.failed &&
                      source.errorCode != null
                  ? '${_statusLabel(source.status)} · Code erreur : ${source.errorCode}'
                  : _statusLabel(source.status),
              statusColor: _statusColor(source.status),
              trailing: IconButton(
                tooltip: 'Supprimer la source ${source.fileName}',
                onPressed: isDeleting
                    ? null
                    : () => _deleteSource(context, ref, source),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: RevisionColors.textMuted,
                ),
              ),
            ),
        if (isUploading)
          const RevisionProcessingState(
            title: 'Upload en cours...',
            message: 'La source est envoyée au backend.',
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
            'Impossible de supprimer cette source.',
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

String _quickRevisionActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Synthèse essentielle depuis une source prête.';
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

String _masteryLabel(CourseProgress progress) {
  if (progress.mastery == null) {
    return 'Maîtrise sur notions travaillées : en attente';
  }

  return 'Maîtrise sur notions travaillées : ${_percent(progress.mastery!)}';
}

String _progressStateLabel(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.noSource => 'Ajoute une source pour commencer.',
    CourseProgressState.processing => 'Analyse du PDF en cours.',
    CourseProgressState.failedOnly =>
      'Les sources ont échoué. Ajoute ou corrige une source.',
    CourseProgressState.noKnowledgeUnits =>
      'Source prête, mais aucune notion exploitable.',
    CourseProgressState.readyNotPracticed =>
      'Notions prêtes, pas encore travaillées.',
    CourseProgressState.practiced =>
      'Progression réelle basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression réelle disponible.',
  };
}

Color _progressColor(CourseProgressState state) {
  return switch (state) {
    CourseProgressState.practiced => RevisionColors.green,
    CourseProgressState.readyNotPracticed => RevisionColors.blue,
    CourseProgressState.processing => RevisionColors.amber,
    CourseProgressState.failedOnly => RevisionColors.red,
    CourseProgressState.noKnowledgeUnits => RevisionColors.violet,
    CourseProgressState.noSource => RevisionColors.blue,
    CourseProgressState.unknown => RevisionColors.mint,
  };
}

String _courseMeta(CourseListItem course) {
  final parts = <String>[
    if (course.chapterLabel != null) course.chapterLabel!,
    if (course.estimatedMinutes != null) '${course.estimatedMinutes} min',
  ];

  return parts.isEmpty ? 'Cours sans durée estimée' : parts.join(' · ');
}

String _difficultyLabel(CourseDifficulty? difficulty) {
  return switch (difficulty) {
    CourseDifficulty.beginner => 'Débutant',
    CourseDifficulty.intermediate => 'Intermédiaire',
    CourseDifficulty.advanced => 'Avancé',
    null => 'À préciser',
  };
}

String _percent(double value) {
  return '${(value.clamp(0, 1) * 100).round()}%';
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

bool _isPendingSource(CourseDocument source) {
  return source.status == CourseDocumentStatus.uploaded ||
      source.status == CourseDocumentStatus.processing;
}

void _popOrGo(BuildContext context, String fallbackLocation) {
  // Detail pages are opened with push so system/back buttons must pop the stack.
  // The fallback keeps direct deep links usable when no parent route exists.
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackLocation);
}
