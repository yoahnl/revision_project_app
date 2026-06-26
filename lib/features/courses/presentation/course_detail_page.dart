import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'course_hero_tags.dart';
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
  static const _entryRevealDelay = Duration(milliseconds: 220);
  static const _exitRevealDelay = Duration(milliseconds: 220);

  Timer? _pollTimer;
  DateTime? _pollStartedAt;
  bool _pollTimedOut = false;
  Timer? _questionPollTimer;
  DateTime? _questionPollStartedAt;
  int? _questionPollTarget;
  bool _questionPollTimedOut = false;
  Timer? _entryRevealTimer;
  bool _isExiting = false;
  bool _showDetailContent = false;

  @override
  void initState() {
    super.initState();
    _startEntryReveal();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPolling());
  }

  @override
  void didUpdateWidget(covariant _CourseDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.detail.course.id != widget.detail.course.id) {
      _startEntryReveal();
    }
    _syncPolling();
  }

  @override
  void dispose() {
    _stopPolling(resetTimeout: false);
    _stopQuestionPolling(resetTimeout: false);
    _entryRevealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final course = detail.course;
    final visual = revisionSubjectVisualThemeFor(
      '${detail.subject.name} ${course.title}',
    );
    final learningPath = ref.watch(courseLearningPathProvider(course.id));
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
        _CourseTopBar(detail: detail, visual: visual, onBack: _exitToHome),
        _CourseHeader(
          detail: detail,
          visual: visual,
          learningPathState: learningPath,
          showContent: _showDetailContent,
          revealDelay: const Duration(milliseconds: 40),
        ),
      ],
      children: [
        _CourseDetailReveal(
          visible: _showDetailContent,
          delay: const Duration(milliseconds: 70),
          child: _CoursePrimaryAction(
            detail: detail,
            visual: visual,
            learningPathState: learningPath,
          ),
        ),
        _CourseDetailReveal(
          visible: _showDetailContent,
          delay: const Duration(milliseconds: 130),
          child: _CourseLearningPath(
            detail: detail,
            visual: visual,
            learningPathState: learningPath,
          ),
        ),
        _CourseDetailReveal(
          visible: _showDetailContent,
          delay: const Duration(milliseconds: 190),
          child: _CourseBottomActions(
            detail: detail,
            hasReadySource: hasReadySource,
            learningPathState: learningPath,
          ),
        ),
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

  void _startEntryReveal() {
    _entryRevealTimer?.cancel();
    _isExiting = false;
    _showDetailContent = false;
    _entryRevealTimer = Timer(_entryRevealDelay, () {
      if (mounted) {
        setState(() => _showDetailContent = true);
      }
    });
  }

  Future<void> _exitToHome() async {
    if (_isExiting) {
      return;
    }

    _entryRevealTimer?.cancel();
    setState(() {
      _isExiting = true;
      _showDetailContent = false;
    });

    await Future<void>.delayed(_exitRevealDelay);

    if (mounted) {
      _popOrGo(context, AppRoutes.home);
    }
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
      ref.invalidate(courseLearningPathProvider(widget.detail.course.id));
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
    required this.onBack,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Hero(
          tag: CourseHeroTags.navigationControl(),
          flightShuttleBuilder: buildCourseNavigationControlHeroFlightShuttle,
          transitionOnUserGestures: true,
          child: RevisionHeaderIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Retour',
            onPressed: onBack,
            size: 44,
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<_CourseMenuAction>(
              tooltip: 'Plus d’actions',
              icon: const Icon(Icons.more_horiz_rounded),
              color: RevisionColors.ink2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: RevisionColors.border),
              ),
              onSelected: (action) => switch (action) {
                _CourseMenuAction.sources => _showSourcesSheet(
                  context,
                  ref,
                  detail,
                ),
                _CourseMenuAction.manage => _showCourseManagement(
                  context,
                  ref,
                  detail,
                ),
                _CourseMenuAction.history => _showCourseHistory(
                  context,
                  detail,
                ),
                _CourseMenuAction.advanced => _showCourseAdvancedActions(
                  context,
                  detail,
                  visual,
                ),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _CourseMenuAction.sources,
                  child: Text('Sources'),
                ),
                PopupMenuItem(
                  value: _CourseMenuAction.manage,
                  child: Text('Gérer le cours'),
                ),
                PopupMenuItem(
                  value: _CourseMenuAction.history,
                  child: Text('Historique'),
                ),
                PopupMenuItem(
                  value: _CourseMenuAction.advanced,
                  child: Text('Actions avancées'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _CourseMenuAction { sources, manage, history, advanced }

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({
    required this.detail,
    required this.visual,
    required this.learningPathState,
    required this.showContent,
    required this.revealDelay,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final AsyncValue<CourseLearningPath> learningPathState;
  final bool showContent;
  final Duration revealDelay;

  @override
  Widget build(BuildContext context) {
    final path = learningPathState.asData?.value;
    final title = path?.course.title ?? detail.course.title;
    final subjectName = path?.course.subjectName ?? detail.subject.name;
    final hasReliableProgress =
        path != null && path.summary.knowledgeUnitCount > 0;

    return Hero(
      tag: CourseHeroTags.subjectOverview(detail.subject.id),
      flightShuttleBuilder: buildCourseCardHeroFlightShuttle,
      transitionOnUserGestures: true,
      child: RevisionGlassCard(
        padding: const EdgeInsets.all(RevisionSpacing.l),
        backgroundColor: RevisionColors.glassSoft,
        child: _CourseDetailReveal(
          visible: showContent,
          delay: revealDelay,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RevisionTypography.pageTitle,
                    ),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text(
                      subjectName,
                      style: RevisionTypography.caption.copyWith(
                        color: RevisionColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RevisionSpacing.m),
              _CourseLuna(visual: visual),
              if (path != null && hasReliableProgress) ...[
                const SizedBox(width: RevisionSpacing.m),
                RevisionMasteryRing(
                  value: path.summary.estimatedGlobalMastery,
                  label: _percent(path.summary.estimatedGlobalMastery),
                  caption: 'maîtrisé',
                  color: _learningPathStateColor(path.activeNode?.state),
                  size: 78,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseDetailReveal extends StatelessWidget {
  const _CourseDetailReveal({
    required this.visible,
    required this.child,
    this.delay = Duration.zero,
  });

  static const _duration = Duration(milliseconds: 360);

  final bool visible;
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Opacity(opacity: visible ? 1 : 0, child: child);
    }

    final totalDuration = visible
        ? _duration + delay
        : const Duration(milliseconds: 220);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: visible ? 1 : 0),
      duration: totalDuration,
      curve: Curves.linear,
      child: child,
      builder: (context, value, child) {
        final progress = visible
            ? _delayedProgress(value, delay, totalDuration, _duration)
            : value;
        final eased = Curves.easeOutCubic.transform(progress);

        return Transform.translate(
          offset: Offset(0, (1 - eased) * 12),
          child: Opacity(opacity: eased, child: child),
        );
      },
    );
  }
}

double _delayedProgress(
  double value,
  Duration delay,
  Duration totalDuration,
  Duration duration,
) {
  if (delay == Duration.zero) {
    return value;
  }

  final elapsed = value * totalDuration.inMilliseconds;
  return ((elapsed - delay.inMilliseconds) / duration.inMilliseconds)
      .clamp(0.0, 1.0)
      .toDouble();
}

class _CourseLuna extends StatelessWidget {
  const _CourseLuna({required this.visual});

  final RevisionSubjectVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Luna',
      image: true,
      child: SizedBox.square(
        key: const ValueKey('course-detail-luna'),
        dimension: 58,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: visual.accent.withValues(alpha: 0.10),
            boxShadow: [
              BoxShadow(
                color: visual.accent.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(RevisionSpacing.xs),
            child: SvgPicture.asset(
              'assets/brand/neralune_cat.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoursePrimaryAction extends ConsumerWidget {
  const _CoursePrimaryAction({
    required this.detail,
    required this.visual,
    required this.learningPathState,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final AsyncValue<CourseLearningPath> learningPathState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = learningPathState.asData?.value;
    final action = path?.primaryAction;
    final presentation =
        learningPathState.hasError && !learningPathState.hasValue
        ? const _LearningPathPrimaryActionPresentation(
            title: 'Parcours indisponible',
            message: 'Impossible de charger l’action recommandée.',
            buttonLabel: 'Réessayer',
            buttonIcon: Icons.refresh_rounded,
            accent: RevisionColors.red,
            canRun: false,
            retry: true,
          )
        : _learningPathPrimaryActionPresentation(action);

    return RevisionGlassCard(
      borderColor: presentation.accent.withValues(alpha: 0.34),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          presentation.accent.withValues(alpha: 0.20),
          RevisionColors.glassStrong,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      presentation.title,
                      style: RevisionTypography.caption.copyWith(
                        color: visual.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text(presentation.message, style: RevisionTypography.body),
                    const SizedBox(height: RevisionSpacing.m),
                  ],
                ),
              ),
            ],
          ),
          RevisionGradientButton(
            label: presentation.buttonLabel,
            icon: presentation.buttonIcon,
            expanded: true,
            onPressed: presentation.canRun
                ? () => _runLearningPathPrimaryAction(
                    context,
                    ref,
                    detail,
                    action,
                  )
                : presentation.retry
                ? () => ref.invalidate(
                    courseLearningPathProvider(detail.course.id),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _LearningPathPrimaryActionPresentation {
  const _LearningPathPrimaryActionPresentation({
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.accent,
    required this.canRun,
    this.retry = false,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final IconData buttonIcon;
  final Color accent;
  final bool canRun;
  final bool retry;
}

_LearningPathPrimaryActionPresentation _learningPathPrimaryActionPresentation(
  CourseLearningPathPrimaryAction? action,
) {
  if (action == null) {
    return const _LearningPathPrimaryActionPresentation(
      title: 'Chargement du parcours',
      message: 'Neralune récupère les notions de ce cours.',
      buttonLabel: 'Chargement...',
      buttonIcon: Icons.hourglass_top_rounded,
      accent: RevisionColors.blue,
      canRun: false,
    );
  }

  final isEnabled = action.enabled;
  final icon = switch (action.kind) {
    CourseLearningPathPrimaryActionKind.addSource => Icons.add_rounded,
    CourseLearningPathPrimaryActionKind.waitForAnalysis =>
      Icons.hourglass_top_rounded,
    CourseLearningPathPrimaryActionKind.prepareQuestions =>
      Icons.auto_awesome_rounded,
    CourseLearningPathPrimaryActionKind.reviewActiveNode ||
    CourseLearningPathPrimaryActionKind.continueCourse =>
      Icons.play_arrow_rounded,
    CourseLearningPathPrimaryActionKind.unavailable =>
      Icons.description_outlined,
    CourseLearningPathPrimaryActionKind.unknown => Icons.play_arrow_rounded,
  };
  final accent = switch (action.kind) {
    CourseLearningPathPrimaryActionKind.addSource => RevisionColors.blue,
    CourseLearningPathPrimaryActionKind.waitForAnalysis => RevisionColors.amber,
    CourseLearningPathPrimaryActionKind.prepareQuestions => RevisionColors.blue,
    CourseLearningPathPrimaryActionKind.reviewActiveNode ||
    CourseLearningPathPrimaryActionKind.continueCourse => RevisionColors.green,
    CourseLearningPathPrimaryActionKind.unavailable =>
      isEnabled ? RevisionColors.amber : RevisionColors.red,
    CourseLearningPathPrimaryActionKind.unknown => RevisionColors.blue,
  };

  return _LearningPathPrimaryActionPresentation(
    title: action.label,
    message: action.unavailableReason ?? action.description,
    buttonLabel: action.label,
    buttonIcon: icon,
    accent: accent,
    canRun: isEnabled,
  );
}

Future<void> _runLearningPathPrimaryAction(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
  CourseLearningPathPrimaryAction? action,
) async {
  if (action == null || !action.enabled) {
    return;
  }

  switch (action.kind) {
    case CourseLearningPathPrimaryActionKind.addSource:
      _showSourcesSheet(context, ref, detail);
    case CourseLearningPathPrimaryActionKind.waitForAnalysis:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action.unavailableReason ?? action.description)),
      );
    case CourseLearningPathPrimaryActionKind.reviewActiveNode:
    case CourseLearningPathPrimaryActionKind.continueCourse:
      final resumable = await ref.read(
        resumableCourseRevisionSessionProvider(detail.course.id).future,
      );
      if (resumable != null) {
        if (!context.mounted) {
          return;
        }

        context.go(
          AppRoutes.revisionSessionV2(
            sessionId: resumable.session.id,
            courseId: detail.course.id,
            mode: 'quick',
          ),
        );
        return;
      }

      await _showQuickRevisionSheet(context, ref, detail);
    case CourseLearningPathPrimaryActionKind.prepareQuestions:
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
    case CourseLearningPathPrimaryActionKind.unavailable:
      _showSourcesSheet(context, ref, detail);
    case CourseLearningPathPrimaryActionKind.unknown:
      await _showQuickRevisionSheet(context, ref, detail);
  }
}

class _CourseLearningPath extends ConsumerWidget {
  const _CourseLearningPath({
    required this.detail,
    required this.visual,
    required this.learningPathState,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final AsyncValue<CourseLearningPath> learningPathState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = learningPathState.asData?.value;
    Widget pathHeroCard({required Widget child, EdgeInsetsGeometry? padding}) {
      return Hero(
        tag: CourseHeroTags.learningPath(detail.course.id),
        flightShuttleBuilder: buildCourseCardHeroFlightShuttle,
        transitionOnUserGestures: true,
        child: padding == null
            ? RevisionGlassCard(child: child)
            : RevisionGlassCard(padding: padding, child: child),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Parcours', style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.m),
        if (learningPathState.isLoading && !learningPathState.hasValue)
          pathHeroCard(
            child: Text(
              'Chargement du parcours',
              style: RevisionTypography.body,
            ),
          )
        else if (learningPathState.hasError && path == null)
          pathHeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impossible de charger le parcours',
                  style: RevisionTypography.sectionTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  'Réessaie dans un instant ou consulte les sources du cours.',
                  style: RevisionTypography.body,
                ),
                const SizedBox(height: RevisionSpacing.s),
                TextButton.icon(
                  onPressed: () => ref.invalidate(
                    courseLearningPathProvider(detail.course.id),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          )
        else if (path == null || path.nodes.isEmpty)
          pathHeroCard(
            child: _LearningPathEmptyState(
              detail: detail,
              emptyState: path?.emptyState,
            ),
          )
        else
          pathHeroCard(
            padding: const EdgeInsets.symmetric(
              horizontal: RevisionSpacing.m,
              vertical: RevisionSpacing.s,
            ),
            child: Column(
              children: [
                for (final indexed in path.nodes.indexed)
                  _LearningPathRow(
                    node: indexed.$2,
                    visual: visual,
                    selected: indexed.$2.id == path.activeNodeId,
                    first: indexed.$1 == 0,
                    last: indexed.$1 == path.nodes.length - 1,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LearningPathRow extends StatelessWidget {
  const _LearningPathRow({
    required this.node,
    required this.visual,
    required this.selected,
    required this.first,
    required this.last,
  });

  final CourseLearningPathNode node;
  final RevisionSubjectVisualTheme visual;
  final bool selected;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final stateColor = _learningPathStateColor(node.state);
    final color = selected ? visual.accent : stateColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 34,
          height: 64,
          child: Column(
            children: [
              Container(
                width: 2,
                height: 18,
                color: first
                    ? Colors.transparent
                    : RevisionColors.borderBright.withValues(alpha: 0.55),
              ),
              Container(
                width: selected ? 22 : 18,
                height: selected ? 22 : 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? visual.accent.withValues(alpha: 0.22)
                      : node.state == CourseLearningPathNodeState.solid
                      ? stateColor
                      : Colors.transparent,
                  border: Border.all(color: color, width: selected ? 3 : 2),
                ),
                child: node.state == CourseLearningPathNodeState.solid
                    ? const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: RevisionColors.ink,
                      )
                    : selected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: visual.accent,
                          ),
                        ),
                      )
                    : null,
              ),
              Container(
                width: 2,
                height: selected ? 24 : 28,
                color: last
                    ? Colors.transparent
                    : RevisionColors.borderBright.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
        const SizedBox(width: RevisionSpacing.s),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: RevisionSpacing.xs),
            padding: const EdgeInsets.symmetric(
              horizontal: RevisionSpacing.m,
              vertical: RevisionSpacing.s,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? visual.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? Border.all(color: visual.accent.withValues(alpha: 0.22))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.display.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: RevisionTypography.body.copyWith(
                    color: RevisionColors.text,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _nodeMeta(node),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RevisionTypography.caption.copyWith(
                    color: selected
                        ? RevisionColors.text
                        : RevisionColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LearningPathEmptyState extends ConsumerWidget {
  const _LearningPathEmptyState({required this.detail, this.emptyState});

  final CourseDetail detail;
  final CourseLearningPathEmptyState? emptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = emptyState;
    final title = state?.title ?? 'Parcours du cours';
    final message =
        state?.message ??
        'Les notions détaillées seront affichées dès que le parcours sera disponible.';
    final canAct =
        state?.actionKind == CourseLearningPathEmptyActionKind.addSource ||
        state?.actionKind == CourseLearningPathEmptyActionKind.retrySource;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: RevisionTypography.sectionTitle.copyWith(fontSize: 17),
        ),
        const SizedBox(height: RevisionSpacing.s),
        Text(message, style: RevisionTypography.body),
        if (state != null) ...[
          const SizedBox(height: RevisionSpacing.s),
          TextButton.icon(
            onPressed: canAct
                ? () => _showSourcesSheet(context, ref, detail)
                : null,
            icon: const Icon(Icons.description_outlined),
            label: Text(state.actionLabel),
          ),
        ],
      ],
    );
  }
}

class _CourseBottomActions extends ConsumerWidget {
  const _CourseBottomActions({
    required this.detail,
    required this.hasReadySource,
    required this.learningPathState,
  });

  final CourseDetail detail;
  final bool hasReadySource;
  final AsyncValue<CourseLearningPath> learningPathState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = learningPathState.asData?.value;
    final action = path?.primaryAction;
    final canReviewCourse =
        hasReadySource &&
        action?.kind != CourseLearningPathPrimaryActionKind.waitForAnalysis;

    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.s),
      backgroundColor: RevisionColors.glassStrong,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: hasReadySource
                  ? () => context.push(AppRoutes.courseSheet(detail.course.id))
                  : null,
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Comprendre'),
              style: OutlinedButton.styleFrom(
                foregroundColor: RevisionColors.text,
                side: const BorderSide(color: RevisionColors.borderBright),
                padding: const EdgeInsets.symmetric(
                  vertical: RevisionSpacing.m,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: RevisionSpacing.s),
          Expanded(
            child: RevisionGradientButton(
              label: 'Réviser ce cours',
              icon: Icons.flash_on_rounded,
              expanded: true,
              onPressed: canReviewCourse
                  ? () => _showQuickRevisionSheet(context, ref, detail)
                  : null,
            ),
          ),
        ],
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
      await ref
          .read(prepareQuestionBankControllerProvider.notifier)
          .prepare(courseId: detail.course.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La session se prépare. Réessaie dans un instant.'),
        ),
      );
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

  final message = switch (readiness?.status) {
    CourseQuestionBankReadinessStatus.noKnowledgeUnits =>
      "Aucune notion exploitable n'a encore été trouvée.",
    CourseQuestionBankReadinessStatus.noReadySource =>
      'Ajoute une source prête pour commencer.',
    CourseQuestionBankReadinessStatus.failed =>
      "La session n'a pas pu être préparée.",
    _ => 'La session se prépare. Réessaie dans un instant.',
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _showQuickRevisionSheet(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
) async {
  final selection = await showModalBottomSheet<CourseRevisionDurationSelection>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        CourseRevisionDurationSheet(courseId: detail.course.id),
  );

  if (!context.mounted || selection == null) {
    return;
  }

  switch (selection.action) {
    case CourseRevisionDurationAction.start:
      await startCourseQuickRevisionFlow(
        context: context,
        ref: ref,
        courseId: detail.course.id,
        questionCount: selection.questionCount,
      );
    case CourseRevisionDurationAction.prepare:
      try {
        await ref
            .read(prepareQuestionBankControllerProvider.notifier)
            .prepare(
              courseId: detail.course.id,
              questionCount: selection.questionCount,
            );

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selection.durationMinutes} min se prépare. Réessaie dans un instant.',
            ),
          ),
        );
      } catch (error) {
        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de lancer la session pour le moment.'),
          ),
        );
      }
    case CourseRevisionDurationAction.wait:
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

void _showCourseHistory(BuildContext context, CourseDetail detail) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RevisionBottomSheetFrame(
      title: 'Historique',
      subtitle: 'Les sessions terminées restent accessibles ici.',
      children: [_CourseRevisionHistorySection(detail: detail)],
    ),
  );
}

void _showCourseAdvancedActions(
  BuildContext context,
  CourseDetail detail,
  RevisionSubjectVisualTheme visual,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RevisionBottomSheetFrame(
      title: 'Actions avancées',
      subtitle:
          'Les anciens modes restent disponibles sans encombrer le parcours.',
      children: [_CourseModes(detail: detail, visual: visual)],
    ),
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
  ref.invalidate(courseLearningPathProvider(detail.course.id));
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
      return 'Vérification de la session courte.';
    }

    if (readiness == null) {
      return 'Session courte depuis une source prête.';
    }

    return switch (readiness.status) {
      CourseQuestionBankReadinessStatus.ready => 'Session courte prête.',
      CourseQuestionBankReadinessStatus.preparing =>
        readiness.readyQuestionCount >= 5
            ? "Session courte prête. D'autres formats se préparent."
            : 'La session se prépare.',
      CourseQuestionBankReadinessStatus.notPrepared =>
        'Prépare la session avant de commencer.',
      CourseQuestionBankReadinessStatus.failed =>
        "La session n'a pas pu être préparée.",
      CourseQuestionBankReadinessStatus.noKnowledgeUnits =>
        "Aucune notion exploitable n'a encore été trouvée.",
      CourseQuestionBankReadinessStatus.noReadySource =>
        'Ajoute une source prête pour commencer.',
      CourseQuestionBankReadinessStatus.unknown =>
        'Session courte depuis une source prête.',
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

Color _learningPathStateColor(CourseLearningPathNodeState? state) {
  return switch (state) {
    CourseLearningPathNodeState.solid => RevisionColors.green,
    CourseLearningPathNodeState.inProgress => RevisionColors.blue,
    CourseLearningPathNodeState.toStrengthen => RevisionColors.amber,
    CourseLearningPathNodeState.undiscovered => RevisionColors.borderBright,
    CourseLearningPathNodeState.unknown || null => RevisionColors.borderBright,
  };
}

String _nodeMeta(CourseLearningPathNode node) {
  final meta = node.display.metaLabel;
  if (meta == null || meta.trim().isEmpty) {
    return node.display.statusLabel;
  }

  return '${node.display.statusLabel} · ${meta.trim()}';
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
