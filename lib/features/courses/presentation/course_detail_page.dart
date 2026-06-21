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
import 'course_quick_revision_launcher.dart';
import 'widgets/course_sources_bottom_sheet.dart';
import 'widgets/quick_revision_question_count_sheet.dart';

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
                  'Réessaie ou retourne à l’accueil pour choisir un autre cours.',
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
      headerChildren: [
        _CourseTopBar(
          detail: detail,
          visual: visual,
          hasReadySource: hasReadySource,
        ),
        _CourseHero(detail: detail, visual: visual),
      ],
      children: [
        _CoursePrimaryAction(detail: detail, visual: visual),
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

class _CoursePrimaryAction extends ConsumerWidget {
  const _CoursePrimaryAction({required this.detail, required this.visual});

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = _primaryActionFor(detail.sources);

    return RevisionGlassCard(
      borderColor: action.accent.withValues(alpha: 0.34),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          action.accent.withValues(alpha: 0.20),
          RevisionColors.glassStrong,
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionIconTile(icon: action.icon, accent: action.accent, size: 48),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Action recommandée',
                  style: RevisionTypography.caption.copyWith(
                    color: visual.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(action.title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(action.message, style: RevisionTypography.body),
                const SizedBox(height: RevisionSpacing.m),
                RevisionGradientButton(
                  label: action.buttonLabel,
                  icon: action.buttonIcon,
                  onPressed: () => action.run(context, ref, detail),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCourseAction {
  const _PrimaryCourseAction({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.icon,
    required this.buttonIcon,
    required this.accent,
    required this.run,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final IconData icon;
  final IconData buttonIcon;
  final Color accent;
  final void Function(BuildContext context, WidgetRef ref, CourseDetail detail)
  run;
}

_PrimaryCourseAction _primaryActionFor(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return _PrimaryCourseAction(
      title: 'Réviser maintenant',
      message: 'Une source est prête pour lancer des questions rapides.',
      buttonLabel: 'Commencer une session rapide',
      icon: Icons.flash_on_rounded,
      buttonIcon: Icons.play_arrow_rounded,
      accent: RevisionColors.blue,
      run: (context, ref, detail) =>
          _showQuickRevisionSheet(context, ref, detail),
    );
  }

  if (sources.any(_isPendingSource)) {
    return _PrimaryCourseAction(
      title: 'Source en analyse',
      message: 'La révision sera disponible quand le PDF sera prêt.',
      buttonLabel: 'Voir les sources',
      icon: Icons.hourglass_top_rounded,
      buttonIcon: Icons.description_outlined,
      accent: RevisionColors.amber,
      run: (context, ref, detail) => _showSourcesSheet(context, ref, detail),
    );
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return _PrimaryCourseAction(
      title: 'Source à corriger',
      message:
          'Ouvre les sources pour remplacer ou supprimer le PDF en erreur.',
      buttonLabel: 'Voir les sources',
      icon: Icons.error_outline_rounded,
      buttonIcon: Icons.description_outlined,
      accent: RevisionColors.red,
      run: (context, ref, detail) => _showSourcesSheet(context, ref, detail),
    );
  }

  return _PrimaryCourseAction(
    title: 'Ajoute une source',
    message: 'Ajoute un PDF pour préparer la fiche et les révisions.',
    buttonLabel: 'Ajouter une source',
    icon: Icons.upload_file_rounded,
    buttonIcon: Icons.add_rounded,
    accent: RevisionColors.blue,
    run: (context, ref, detail) => _showSourcesSheet(context, ref, detail),
  );
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
        message: 'Les métriques ne sont pas disponibles pour ce cours.',
        actionLabel: 'Réessayer',
        onAction: onRetry,
      ),
      data: (progress) => RevisionGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progression', style: RevisionTypography.sectionTitle),
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
          trailingLabel: hasReadySource
              ? null
              : _quickRevisionBlockedLabel(detail.sources),
          enabled: hasReadySource && !isStartingQuickRevision,
          onTap: () => _showQuickRevisionSheet(context, ref, detail),
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Révision approfondie',
          description: 'Cours complet et exemples détaillés.',
          icon: Icons.menu_book_rounded,
          accent: RevisionColors.violet,
          trailingLabel: 'Bientôt disponible',
          enabled: false,
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Préparation examen',
          description: 'Entraînements et sujets corrigés.',
          icon: Icons.gps_fixed_rounded,
          accent: RevisionColors.pink,
          trailingLabel: 'Bientôt disponible',
          enabled: false,
        ),
        if (quickRevisionState.hasError) ...[
          const SizedBox(height: RevisionSpacing.s),
          Text(
            'Les questions sont en préparation. Réessaie dans un instant.',
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> _showQuickRevisionSheet(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final questionCount = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const QuickRevisionQuestionCountSheet(),
  );

  if (!context.mounted || questionCount == null) {
    return;
  }

  await startCourseQuickRevisionFlow(
    context: context,
    ref: ref,
    courseId: detail.course.id,
    questionCount: questionCount,
  );
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
    builder: (context) => CourseSourcesBottomSheet(detail: detail),
  );
}

String _quickRevisionActionLabel(List<CourseDocument> sources) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    return 'Questions rapides depuis une source prête.';
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

String _quickRevisionBlockedLabel(List<CourseDocument> sources) {
  if (sources.any(_isPendingSource)) {
    return 'Analyse en cours';
  }

  if (sources.isNotEmpty &&
      sources.every((source) => source.status == CourseDocumentStatus.failed)) {
    return 'Source à corriger';
  }

  return 'Source requise';
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
    CourseProgressState.practiced => 'Progression basée sur tes réponses.',
    CourseProgressState.unknown => 'Progression disponible.',
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
