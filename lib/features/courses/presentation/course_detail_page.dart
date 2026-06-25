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
import '../../revision_sessions/domain/revision_session.dart';
import 'course_not_found_page.dart';
import 'course_quick_revision_launcher.dart';
import 'widgets/course_management_sheet.dart';
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
  Timer? _questionPollTimer;
  DateTime? _questionPollStartedAt;
  int? _questionPollTarget;
  bool _questionPollTimedOut = false;

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
    _stopQuestionPolling(resetTimeout: false);
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
    final primaryReadinessState = ref.watch(
      courseQuestionBankReadinessProvider((
        courseId: course.id,
        questionCount: 10,
      )),
    );
    final primaryReadiness = primaryReadinessState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final preparationReadiness = ref
        .watch(prepareQuestionBankControllerProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final isPreparationPolling =
        preparationReadiness?.status ==
        CourseQuestionBankReadinessStatus.preparing;
    final preparationTarget = isPreparationPolling
        ? preparationReadiness!.targetQuestionCount
        : null;
    final preparationTargetReadiness =
        preparationTarget != null && preparationTarget != 10
        ? ref
              .watch(
                courseQuestionBankReadinessProvider((
                  courseId: course.id,
                  questionCount: preparationTarget,
                )),
              )
              .maybeWhen(data: (value) => value, orElse: () => null)
        : null;
    final pollingReadiness =
        preparationTargetReadiness ??
        (isPreparationPolling ? preparationReadiness : primaryReadiness);
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncQuestionPolling(pollingReadiness),
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
        _CourseRevisionHistorySection(detail: detail),
        _CourseModes(detail: detail, visual: visual),
        if (_pollTimedOut)
          RevisionGlassCard(
            child: Text(
              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
              style: RevisionTypography.body,
            ),
          ),
        if (_questionPollTimedOut)
          RevisionGlassCard(
            child: Text(
              'La préparation prend plus de temps que prévu. Tu peux réessayer ou revenir plus tard.',
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

  void _syncQuestionPolling(CourseQuestionBankReadiness? readiness) {
    if (!mounted) {
      return;
    }

    if (readiness?.status != CourseQuestionBankReadinessStatus.preparing) {
      _stopQuestionPolling(resetTimeout: true);
      return;
    }

    final target = readiness!.targetQuestionCount;
    if (_questionPollTarget != null && _questionPollTarget != target) {
      _stopQuestionPolling(resetTimeout: true);
    }

    _questionPollTarget = target;
    _questionPollStartedAt ??= DateTime.now();
    _questionPollTimer ??= Timer.periodic(_pollInterval, (_) {
      final startedAt = _questionPollStartedAt;
      if (startedAt != null &&
          DateTime.now().difference(startedAt) >= _pollTimeout) {
        if (mounted) {
          setState(() => _questionPollTimedOut = true);
        }
        _stopQuestionPolling(resetTimeout: false);
        return;
      }

      final target = _questionPollTarget;
      if (target == null) {
        return;
      }

      ref.invalidate(
        courseQuestionBankReadinessProvider((
          courseId: widget.detail.course.id,
          questionCount: target,
        )),
      );
    });
  }

  void _stopQuestionPolling({required bool resetTimeout}) {
    _questionPollTimer?.cancel();
    _questionPollTimer = null;
    _questionPollStartedAt = null;
    _questionPollTarget = null;
    if (resetTimeout && _questionPollTimedOut && mounted) {
      setState(() => _questionPollTimedOut = false);
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
        const SizedBox(width: RevisionSpacing.s),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: RevisionSpacing.s,
              runSpacing: RevisionSpacing.s,
              children: [
                RevisionHeaderActionPill(
                  label: 'Fiche',
                  icon: Icons.article_outlined,
                  accent: visual.accent,
                  selected: hasReadySource,
                  onTap: hasReadySource
                      ? () => context.push(
                          AppRoutes.courseSheet(detail.course.id),
                        )
                      : null,
                ),
                RevisionHeaderActionPill(
                  label: 'Sources',
                  icon: Icons.description_outlined,
                  accent: visual.accent,
                  onTap: () => _showSourcesSheet(context, ref, detail),
                ),
                RevisionHeaderActionPill(
                  label: 'Gérer',
                  icon: Icons.more_horiz_rounded,
                  accent: visual.accent,
                  onTap: () => _showCourseManagement(context, ref, detail),
                ),
              ],
            ),
          ),
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
    final readinessState = ref.watch(
      courseQuestionBankReadinessProvider((
        courseId: detail.course.id,
        questionCount: 10,
      )),
    );
    final readiness = readinessState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final resumable = ref
        .watch(resumableCourseRevisionSessionProvider(detail.course.id))
        .maybeWhen(data: (value) => value, orElse: () => null);
    final action = _primaryActionFor(
      detail.sources,
      readiness,
      readinessState.isLoading,
      resumable,
    );

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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RevisionIconTile(
                icon: action.icon,
                accent: action.accent,
                size: 48,
              ),
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
                  ],
                ),
              ),
            ],
          ),
          RevisionGradientButton(
            label: action.buttonLabel,
            icon: action.buttonIcon,
            onPressed: action.run == null
                ? null
                : () => action.run!(context, ref, detail),
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
  final void Function(BuildContext context, WidgetRef ref, CourseDetail detail)?
  run;
}

_PrimaryCourseAction _primaryActionFor(
  List<CourseDocument> sources,
  CourseQuestionBankReadiness? readiness,
  bool isLoadingReadiness,
  ResumableCourseRevisionSession? resumable,
) {
  if (resumable != null) {
    final progress = resumable.progress.totalQuestionCount > 0
        ? '${resumable.progress.answeredQuestionCount}/${resumable.progress.totalQuestionCount} réponses sauvegardées.'
        : 'Tu as une session en cours.';
    return _PrimaryCourseAction(
      title: 'Reprendre la session',
      message: progress,
      buttonLabel: 'Reprendre',
      icon: Icons.play_circle_outline_rounded,
      buttonIcon: Icons.play_arrow_rounded,
      accent: RevisionColors.green,
      run: (context, ref, detail) {
        context.go(
          AppRoutes.revisionSessionV2(
            sessionId: resumable.session.id,
            courseId: detail.course.id,
            mode: 'quick',
          ),
        );
      },
    );
  }

  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    if (isLoadingReadiness || readiness == null) {
      return const _PrimaryCourseAction(
        title: 'Questions du cours',
        message: 'Vérification des questions disponibles.',
        buttonLabel: 'Vérification...',
        icon: Icons.flash_on_rounded,
        buttonIcon: Icons.hourglass_top_rounded,
        accent: RevisionColors.blue,
        run: null,
      );
    }

    if (readiness.readyQuestionCount >= 5) {
      final suffix =
          readiness.status == CourseQuestionBankReadinessStatus.preparing
          ? " D'autres questions sont en préparation."
          : '';
      return _PrimaryCourseAction(
        title: 'Réviser maintenant',
        message: 'Une session rapide peut démarrer maintenant.$suffix',
        buttonLabel: 'Réviser maintenant',
        icon: Icons.flash_on_rounded,
        buttonIcon: Icons.play_arrow_rounded,
        accent: RevisionColors.blue,
        run: (context, ref, detail) =>
            _showQuickRevisionSheet(context, ref, detail),
      );
    }

    if (readiness.status ==
        CourseQuestionBankReadinessStatus.noKnowledgeUnits) {
      return _PrimaryCourseAction(
        title: 'Questions indisponibles',
        message: readiness.userMessage,
        buttonLabel: 'Voir la fiche',
        icon: Icons.info_outline_rounded,
        buttonIcon: Icons.description_outlined,
        accent: RevisionColors.amber,
        run: null,
      );
    }

    if (readiness.status == CourseQuestionBankReadinessStatus.preparing) {
      return const _PrimaryCourseAction(
        title: 'Préparation en cours',
        message: 'Les questions rapides sont en préparation.',
        buttonLabel: 'Préparation en cours',
        icon: Icons.auto_awesome_rounded,
        buttonIcon: Icons.hourglass_top_rounded,
        accent: RevisionColors.amber,
        run: null,
      );
    }

    return _PrimaryCourseAction(
      title: 'Préparer les questions',
      message: readiness.userMessage,
      buttonLabel: 'Préparer les questions',
      icon: Icons.auto_awesome_rounded,
      buttonIcon: Icons.auto_awesome_rounded,
      accent: RevisionColors.blue,
      run: (context, ref, detail) async {
        final prepared = await ref
            .read(prepareQuestionBankControllerProvider.notifier)
            .prepare(courseId: detail.course.id);

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(prepared.userMessage)));
      },
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

class _CourseRevisionHistorySection extends ConsumerWidget {
  const _CourseRevisionHistorySection({required this.detail});

  final CourseDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickHistory = ref.watch(
      courseRevisionSessionHistoryProvider(detail.course.id),
    );
    final richClosedHistory = ref.watch(
      courseRichClosedHistoryProvider(detail.course.id),
    );
    final deepHistory = ref.watch(
      courseDeepRevisionHistoryProvider(detail.course.id),
    );
    final examHistory = ref.watch(
      courseExamPreparationHistoryProvider(detail.course.id),
    );

    return RevisionGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: RevisionColors.textMuted,
              ),
              const SizedBox(width: RevisionSpacing.s),
              Text('Historique', style: RevisionTypography.sectionTitle),
            ],
          ),
          const SizedBox(height: RevisionSpacing.m),
          _CourseHistoryContent(
            quickHistory: quickHistory,
            richClosedHistory: richClosedHistory,
            deepHistory: deepHistory,
            examHistory: examHistory,
            onRetry: () {
              ref.invalidate(
                courseRevisionSessionHistoryProvider(detail.course.id),
              );
              ref.invalidate(courseRichClosedHistoryProvider(detail.course.id));
              ref.invalidate(
                courseDeepRevisionHistoryProvider(detail.course.id),
              );
              ref.invalidate(
                courseExamPreparationHistoryProvider(detail.course.id),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CourseHistoryContent extends StatelessWidget {
  const _CourseHistoryContent({
    required this.quickHistory,
    required this.richClosedHistory,
    required this.deepHistory,
    required this.examHistory,
    required this.onRetry,
  });

  final AsyncValue<RevisionSessionHistoryResponse> quickHistory;
  final AsyncValue<CourseRichClosedHistoryResponse> richClosedHistory;
  final AsyncValue<CourseDeepRevisionHistoryResponse> deepHistory;
  final AsyncValue<RevisionSessionHistoryResponse> examHistory;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final quickItems = quickHistory.asData?.value.items ?? const [];
    final richClosedItems = richClosedHistory.asData?.value.items ?? const [];
    final deepItems = deepHistory.asData?.value.items ?? const [];
    final examItems = examHistory.asData?.value.items ?? const [];
    final hasAnyData =
        quickHistory.hasValue ||
        richClosedHistory.hasValue ||
        deepHistory.hasValue ||
        examHistory.hasValue;
    final isLoading =
        quickHistory.isLoading ||
        richClosedHistory.isLoading ||
        deepHistory.isLoading ||
        examHistory.isLoading;
    final hasError =
        quickHistory.hasError ||
        richClosedHistory.hasError ||
        deepHistory.hasError ||
        examHistory.hasError;

    if (isLoading && !hasAnyData) {
      return Text(
        'Chargement des sessions terminées.',
        style: RevisionTypography.body,
      );
    }

    if (hasError && !hasAnyData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historique indisponible pour le moment.',
            style: RevisionTypography.body,
          ),
          const SizedBox(height: RevisionSpacing.s),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
          ),
        ],
      );
    }

    if (quickItems.isEmpty &&
        richClosedItems.isEmpty &&
        deepItems.isEmpty &&
        examItems.isEmpty) {
      return Text(
        'Aucune session terminée pour ce cours.',
        style: RevisionTypography.body,
      );
    }

    final rows = <Widget>[
      for (final item in examItems) _CourseExamHistoryTile(item: item),
      for (final item in quickItems) _CourseRevisionHistoryTile(item: item),
      for (final item in richClosedItems)
        _CourseRichClosedHistoryTile(item: item),
      for (final item in deepItems) _CourseDeepRevisionHistoryTile(item: item),
    ];

    return Column(
      children: [
        for (final indexed in rows.indexed) ...[
          indexed.$2,
          if (indexed.$1 != rows.length - 1)
            const Divider(color: RevisionColors.border),
        ],
      ],
    );
  }
}

class _CourseExamHistoryTile extends StatelessWidget {
  const _CourseExamHistoryTile({required this.item});

  final RevisionSessionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final summary = item.summary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RevisionSpacing.xs),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.gps_fixed_rounded,
            accent: RevisionColors.pink,
            size: 44,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.correctAnswers}/${summary.totalQuestions}',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '${_scorePercent(summary.score)} · Préparation examen - QCM · ${_historyDate(item.session.completedAt)}',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(
              AppRoutes.revisionSessionResultV2(
                sessionId: item.session.id,
                courseId: item.course.id,
                mode: 'exam',
              ),
            ),
            child: const Text('Voir le résultat'),
          ),
        ],
      ),
    );
  }
}

class _CourseRevisionHistoryTile extends StatelessWidget {
  const _CourseRevisionHistoryTile({required this.item});

  final RevisionSessionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final summary = item.summary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RevisionSpacing.xs),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.check_circle_outline_rounded,
            accent: RevisionColors.green,
            size: 44,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${summary.correctAnswers}/${summary.totalQuestions}',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '${_scorePercent(summary.score)} · Révision rapide · ${_historyDate(item.session.completedAt)}',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(
              AppRoutes.revisionSessionResultV2(
                sessionId: item.session.id,
                courseId: item.course.id,
                mode: 'quick',
              ),
            ),
            child: const Text('Voir le résultat'),
          ),
        ],
      ),
    );
  }
}

class _CourseRichClosedHistoryTile extends StatelessWidget {
  const _CourseRichClosedHistoryTile({required this.item});

  final CourseRichClosedHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RevisionSpacing.xs),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.extension_rounded,
            accent: RevisionColors.blue,
            size: 44,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.correctAnswers}/${item.totalQuestions}',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '${_scorePercent(item.score)} · QCM complet · ${_historyDate(item.completedAt)}',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(
              AppRoutes.richClosedExerciseResult(
                sessionId: item.sessionId,
                courseId: item.course.id,
              ),
            ),
            child: const Text('Voir le résultat'),
          ),
        ],
      ),
    );
  }
}

class _CourseDeepRevisionHistoryTile extends StatelessWidget {
  const _CourseDeepRevisionHistoryTile({required this.item});

  final CourseDeepRevisionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RevisionSpacing.xs),
      child: Row(
        children: [
          const RevisionIconTile(
            icon: Icons.menu_book_rounded,
            accent: RevisionColors.violet,
            size: 44,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: RevisionTypography.sectionTitle),
                const SizedBox(height: RevisionSpacing.xs),
                Text(
                  '${_deepScoreLabel(item.score)} · ${item.knowledgeUnit.title} · ${_historyDate(item.submittedAt)}',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(
              AppRoutes.courseDeepRevisionResult(
                courseId: item.course.id,
                sessionId: item.sessionId,
              ),
            ),
            child: const Text('Voir le résultat'),
          ),
        ],
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
    final preparationState = ref.watch(prepareQuestionBankControllerProvider);
    final readinessState = ref.watch(
      courseQuestionBankReadinessProvider((
        courseId: detail.course.id,
        questionCount: 10,
      )),
    );
    final readiness = readinessState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final richRevisionState = ref.watch(
      courseRichRevisionOptionsProvider(detail.course.id),
    );
    final richRevisionAction = _richRevisionActionFor(
      detail.sources,
      richRevisionState,
    );
    final deepRevisionState = ref.watch(
      courseDeepRevisionOptionsProvider(detail.course.id),
    );
    final deepRevisionAction = _deepRevisionActionFor(
      detail.sources,
      deepRevisionState,
    );
    final isStartingQuickRevision = quickRevisionState.isLoading;
    final isPreparingQuestions = preparationState.isLoading;
    final hasPartialReadyQuestions = (readiness?.readyQuestionCount ?? 0) >= 5;
    final hasReadySource = detail.sources.any(
      (source) => source.status == CourseDocumentStatus.ready,
    );
    final quickEnabled =
        hasReadySource &&
        !isStartingQuickRevision &&
        !isPreparingQuestions &&
        (readiness == null ||
            hasPartialReadyQuestions ||
            readiness.canStartQuickRevision ||
            readiness.canPrepare ||
            readiness.status == CourseQuestionBankReadinessStatus.notPrepared);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Modes de révision', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: isStartingQuickRevision || isPreparingQuestions
              ? 'Préparation...'
              : 'Révision rapide',
          description: _quickRevisionActionLabel(
            detail.sources,
            readiness,
            readinessState.isLoading,
          ),
          icon: Icons.flash_on_rounded,
          accent: RevisionColors.blue,
          trailingLabel: hasReadySource
              ? _quickRevisionReadinessLabel(readiness)
              : _quickRevisionBlockedLabel(detail.sources),
          enabled: quickEnabled,
          onTap: () => _handleQuickRevisionTap(context, ref, detail, readiness),
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'QCM complet',
          description: richRevisionAction.description,
          icon: Icons.extension_rounded,
          accent: RevisionColors.green,
          trailingLabel: richRevisionAction.trailingLabel,
          enabled: richRevisionAction.enabled,
          onTap: richRevisionAction.enabled
              ? () =>
                    context.push(AppRoutes.courseRichRevision(detail.course.id))
              : null,
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Révision approfondie',
          description: deepRevisionAction.description,
          icon: Icons.menu_book_rounded,
          accent: RevisionColors.violet,
          trailingLabel: deepRevisionAction.trailingLabel,
          enabled: deepRevisionAction.enabled,
          onTap: deepRevisionAction.enabled
              ? () =>
                    context.push(AppRoutes.courseDeepRevision(detail.course.id))
              : null,
        ),
        const SizedBox(height: RevisionSpacing.m),
        RevisionModeCard(
          title: 'Préparation examen - QCM',
          description:
              'Construis un entraînement QCM court, proche d’un sujet d’examen.',
          icon: Icons.gps_fixed_rounded,
          accent: RevisionColors.pink,
          trailingLabel: 'Configurer',
          enabled: true,
          onTap: () =>
              context.push(AppRoutes.courseExamPreparation(detail.course.id)),
        ),
        if (quickRevisionState.hasError || preparationState.hasError) ...[
          const SizedBox(height: RevisionSpacing.s),
          Text(
            quickRevisionErrorLabel(
              quickRevisionState.error ?? preparationState.error!,
            ),
            style: RevisionTypography.caption.copyWith(
              color: RevisionColors.red,
            ),
          ),
        ],
      ],
    );
  }
}

class _RichRevisionCardAction {
  const _RichRevisionCardAction({
    required this.description,
    required this.trailingLabel,
    required this.enabled,
  });

  final String description;
  final String trailingLabel;
  final bool enabled;
}

class _DeepRevisionCardAction {
  const _DeepRevisionCardAction({
    required this.description,
    required this.trailingLabel,
    required this.enabled,
  });

  final String description;
  final String trailingLabel;
  final bool enabled;
}

_RichRevisionCardAction _richRevisionActionFor(
  List<CourseDocument> sources,
  AsyncValue<CourseRichRevisionOptions> optionsState,
) {
  final hasReadySource = sources.any(
    (source) => source.status == CourseDocumentStatus.ready,
  );

  if (!hasReadySource) {
    if (sources.any(_isPendingSource)) {
      return const _RichRevisionCardAction(
        description: 'Disponible après traitement.',
        trailingLabel: 'En analyse',
        enabled: false,
      );
    }

    return const _RichRevisionCardAction(
      description: 'Ajoute une source pour t’entraîner.',
      trailingLabel: 'Source requise',
      enabled: false,
    );
  }

  if (optionsState.isLoading && !optionsState.hasValue) {
    return const _RichRevisionCardAction(
      description: 'Vérification des notions disponibles.',
      trailingLabel: 'Vérification...',
      enabled: false,
    );
  }

  final options = optionsState.asData?.value;
  if (options == null) {
    return const _RichRevisionCardAction(
      description: 'Questions variées pour t’entraîner plus sérieusement.',
      trailingLabel: 'Indisponible',
      enabled: false,
    );
  }

  if (options.readiness.canStart && options.scopeOptions.isNotEmpty) {
    return const _RichRevisionCardAction(
      description: 'Questions variées pour t’entraîner plus sérieusement.',
      trailingLabel: 'Configurer',
      enabled: true,
    );
  }

  if (options.readiness.blockers.contains('NO_KNOWLEDGE_UNITS')) {
    return const _RichRevisionCardAction(
      description: 'Aucune notion exploitable.',
      trailingLabel: 'Indisponible',
      enabled: false,
    );
  }

  return _RichRevisionCardAction(
    description: options.readiness.userMessage,
    trailingLabel: 'Indisponible',
    enabled: false,
  );
}

_DeepRevisionCardAction _deepRevisionActionFor(
  List<CourseDocument> sources,
  AsyncValue<CourseDeepRevisionOptions> optionsState,
) {
  final hasReadySource = sources.any(
    (source) => source.status == CourseDocumentStatus.ready,
  );

  if (!hasReadySource) {
    if (sources.any(_isPendingSource)) {
      return const _DeepRevisionCardAction(
        description: 'Disponible après traitement.',
        trailingLabel: 'En analyse',
        enabled: false,
      );
    }

    return const _DeepRevisionCardAction(
      description: 'Ajoute une source pour rédiger une réponse.',
      trailingLabel: 'Source requise',
      enabled: false,
    );
  }

  if (optionsState.isLoading && !optionsState.hasValue) {
    return const _DeepRevisionCardAction(
      description: 'Vérification des notions disponibles.',
      trailingLabel: 'Vérification...',
      enabled: false,
    );
  }

  final options = optionsState.asData?.value;
  if (options == null) {
    return const _DeepRevisionCardAction(
      description: 'Rédige une réponse et reçois une correction détaillée.',
      trailingLabel: 'Indisponible',
      enabled: false,
    );
  }

  if (options.readiness.canStart && options.scopeOptions.isNotEmpty) {
    return const _DeepRevisionCardAction(
      description: 'Rédige une réponse et reçois une correction détaillée.',
      trailingLabel: 'Configurer',
      enabled: true,
    );
  }

  if (options.readiness.blockers.contains('NO_KNOWLEDGE_UNITS')) {
    return const _DeepRevisionCardAction(
      description: 'Aucune notion exploitable.',
      trailingLabel: 'Indisponible',
      enabled: false,
    );
  }

  return _DeepRevisionCardAction(
    description: options.readiness.userMessage,
    trailingLabel: 'Indisponible',
    enabled: false,
  );
}

Future<void> _handleQuickRevisionTap(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
  CourseQuestionBankReadiness? readiness,
) async {
  if ((readiness?.canStartQuickRevision ?? false) ||
      (readiness?.readyQuestionCount ?? 0) >= 5) {
    await _showQuickRevisionSheet(context, ref, detail);
    return;
  }

  if (readiness?.canPrepare ?? true) {
    try {
      final prepared = await ref
          .read(prepareQuestionBankControllerProvider.notifier)
          .prepare(courseId: detail.course.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(prepared.userMessage)));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(quickRevisionErrorLabel(error))));
    }
    return;
  }

  final message =
      readiness?.userMessage ??
      'Les questions sont en préparation. Réessaie dans un instant.';
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _showQuickRevisionSheet(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final selection =
      await showModalBottomSheet<QuickRevisionQuestionCountSelection>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) =>
            QuickRevisionQuestionCountSheet(courseId: detail.course.id),
      );

  if (!context.mounted || selection == null) {
    return;
  }

  switch (selection.action) {
    case QuickRevisionQuestionCountAction.start:
      await startCourseQuickRevisionFlow(
        context: context,
        ref: ref,
        courseId: detail.course.id,
        questionCount: selection.questionCount,
      );
    case QuickRevisionQuestionCountAction.prepare:
      try {
        final prepared = await ref
            .read(prepareQuestionBankControllerProvider.notifier)
            .prepare(
              courseId: detail.course.id,
              questionCount: selection.questionCount,
            );

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(prepared.userMessage)));
      } catch (error) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(quickRevisionErrorLabel(error))));
      }
    case QuickRevisionQuestionCountAction.wait:
      break;
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
    builder: (context) => CourseSourcesBottomSheet(detail: detail),
  );
}

Future<void> _showCourseManagement(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final result = await showCourseManagementSheet(
    context: context,
    detail: detail,
  );

  if (!context.mounted || result == null) {
    return;
  }

  if (result == CourseManagementResult.removed) {
    context.go(AppRoutes.home);
    return;
  }

  ref.invalidate(courseDetailProvider(detail.course.id));
  ref.invalidate(courseProgressProvider(detail.course.id));
  ref.invalidate(courseRevisionSessionHistoryProvider(detail.course.id));
  ref.invalidate(courseRichClosedHistoryProvider(detail.course.id));
  ref.invalidate(subjectProgressProvider(detail.course.subjectId));
}

String _quickRevisionActionLabel(
  List<CourseDocument> sources,
  CourseQuestionBankReadiness? readiness,
  bool isLoadingReadiness,
) {
  if (sources.any((source) => source.status == CourseDocumentStatus.ready)) {
    if (isLoadingReadiness) {
      return 'Vérification des questions du cours.';
    }

    if (readiness == null) {
      return 'Questions rapides depuis une source prête.';
    }

    return switch (readiness.status) {
      CourseQuestionBankReadinessStatus.ready =>
        'Prêt pour une révision rapide.',
      CourseQuestionBankReadinessStatus.preparing =>
        readiness.readyQuestionCount >= 5
            ? "Prêt pour une révision rapide. D'autres questions sont en préparation."
            : 'Les questions sont en préparation.',
      CourseQuestionBankReadinessStatus.notPrepared =>
        'Prépare les questions avant de commencer.',
      CourseQuestionBankReadinessStatus.failed =>
        "Les questions n'ont pas pu être préparées.",
      CourseQuestionBankReadinessStatus.noKnowledgeUnits =>
        "Aucune notion exploitable n'a encore été trouvée.",
      CourseQuestionBankReadinessStatus.noReadySource =>
        'Ajoute une source prête pour commencer.',
      CourseQuestionBankReadinessStatus.unknown =>
        'Questions rapides depuis une source prête.',
    };
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

String? _quickRevisionReadinessLabel(CourseQuestionBankReadiness? readiness) {
  if (readiness == null) {
    return null;
  }

  if (readiness.readyQuestionCount >= 5) {
    return 'Prêt';
  }

  return switch (readiness.status) {
    CourseQuestionBankReadinessStatus.ready => null,
    CourseQuestionBankReadinessStatus.preparing => 'En préparation',
    CourseQuestionBankReadinessStatus.notPrepared => 'À préparer',
    CourseQuestionBankReadinessStatus.failed => 'À relancer',
    CourseQuestionBankReadinessStatus.noKnowledgeUnits => 'Indisponible',
    CourseQuestionBankReadinessStatus.noReadySource => 'Source requise',
    CourseQuestionBankReadinessStatus.unknown => null,
  };
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

String _scorePercent(double value) {
  return '${(value.clamp(0, 1) * 100).round()} %';
}

String _deepScoreLabel(double? value) {
  if (value == null) {
    return 'Correction détaillée';
  }

  return _scorePercent(value);
}

String _historyDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
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
