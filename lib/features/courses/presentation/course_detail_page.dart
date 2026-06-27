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

    return _CourseDetailMobileScreen(
      detail: detail,
      visual: visual,
      learningPathState: learningPath,
      hasReadySource: hasReadySource,
      showContent: _showDetailContent,
      pollTimedOut: _pollTimedOut,
      questionPollTimedOut: _questionPollTimedOut,
      onBack: _exitToHome,
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

const _coursePrimaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [RevisionColors.blueDeep, Color(0xFF5638FF)],
);

class _CourseDetailMobileScreen extends StatelessWidget {
  const _CourseDetailMobileScreen({
    required this.detail,
    required this.visual,
    required this.learningPathState,
    required this.hasReadySource,
    required this.showContent,
    required this.pollTimedOut,
    required this.questionPollTimedOut,
    required this.onBack,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final AsyncValue<CourseLearningPath> learningPathState;
  final bool hasReadySource;
  final bool showContent;
  final bool pollTimedOut;
  final bool questionPollTimedOut;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.paddingOf(context);
    final topPadding = safePadding.top > 0 ? RevisionSpacing.s : 28.0;
    final bottomPadding = safePadding.bottom > 0
        ? safePadding.bottom + 8
        : 50.0;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: _CourseDetailReveal(
          visible: showContent,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    RevisionSpacing.pageX,
                    topPadding,
                    RevisionSpacing.pageX,
                    96 + bottomPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CourseTopBar(detail: detail, onBack: onBack),
                      const SizedBox(height: 6),
                      _CourseHeroControls(
                        detail: detail,
                        visual: visual,
                        learningPathState: learningPathState,
                        hasReadySource: hasReadySource,
                      ),
                      const SizedBox(height: 16),
                      _CourseLearningPath(
                        detail: detail,
                        visual: visual,
                        learningPathState: learningPathState,
                      ),
                      if (pollTimedOut) ...[
                        const SizedBox(height: RevisionSpacing.l),
                        _CourseInlineNotice(
                          message:
                              'Le traitement continue en arrière-plan. Tu peux revenir plus tard.',
                        ),
                      ],
                      if (questionPollTimedOut) ...[
                        const SizedBox(height: RevisionSpacing.l),
                        _CourseInlineNotice(
                          message:
                              'La préparation prend plus de temps que prévu. Tu peux réessayer ou revenir plus tard.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  RevisionSpacing.pageX,
                  0,
                  RevisionSpacing.pageX,
                  bottomPadding,
                ),
                child: _CourseBottomActions(
                  detail: detail,
                  hasReadySource: hasReadySource,
                  learningPathState: learningPathState,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseHeroControls extends ConsumerWidget {
  const _CourseHeroControls({
    required this.detail,
    required this.visual,
    required this.learningPathState,
    required this.hasReadySource,
  });

  final CourseDetail detail;
  final RevisionSubjectVisualTheme visual;
  final AsyncValue<CourseLearningPath> learningPathState;
  final bool hasReadySource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = learningPathState.asData?.value;
    final action = path?.primaryAction;
    final title = path?.course.title ?? detail.course.title;
    final mastery = _courseMasteryValue(path, detail);
    final estimatedMinutes = action?.estimatedMinutes ?? 8;
    final enabled = _canRunCoursePrimaryAction(action, hasReadySource);

    return Hero(
      tag: CourseHeroTags.subjectOverview(detail.subject.id),
      flightShuttleBuilder: buildCourseCardHeroFlightShuttle,
      transitionOnUserGestures: true,
      child: Material(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: RevisionTypography.sectionTitle.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 162),
                      child: _CourseActionButton(
                        label: 'Continuer · $estimatedMinutes min',
                        icon: Icons.play_arrow_rounded,
                        height: 38,
                        fontSize: 12,
                        onPressed: enabled
                            ? () => _runCoursePrimaryAction(
                                context,
                                ref,
                                detail,
                                action,
                              )
                            : null,
                        gradient: _coursePrimaryGradient,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            RevisionMasteryRing(
              value: mastery,
              label: _percent(mastery),
              caption: 'maîtrisé',
              color: visual.accent,
              size: 76,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseInlineNotice extends StatelessWidget {
  const _CourseInlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RevisionColors.glassSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RevisionColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(RevisionSpacing.m),
        child: Text(message, style: RevisionTypography.body),
      ),
    );
  }
}

class _CourseActionButton extends StatelessWidget {
  const _CourseActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.gradient,
    this.outlined = false,
    this.height = 42,
    this.fontSize = 13,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final bool outlined;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final borderRadius = BorderRadius.circular(8);
    final foreground = outlined ? RevisionColors.text : Colors.white;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : 0.48,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Ink(
              height: height,
              decoration: BoxDecoration(
                color: outlined
                    ? RevisionColors.ink2.withValues(alpha: 0.74)
                    : null,
                gradient: outlined ? null : gradient ?? _coursePrimaryGradient,
                borderRadius: borderRadius,
                border: Border.all(
                  color: outlined
                      ? RevisionColors.borderBright.withValues(alpha: 0.82)
                      : RevisionColors.blue.withValues(alpha: 0.36),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: foreground, size: outlined ? 17 : 18),
                    const SizedBox(width: 7),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            color: foreground,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                            height: 1,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseTopBar extends ConsumerWidget {
  const _CourseTopBar({required this.detail, required this.onBack});

  final CourseDetail detail;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Hero(
            tag: CourseHeroTags.navigationControl(),
            flightShuttleBuilder: buildCourseNavigationControlHeroFlightShuttle,
            transitionOnUserGestures: true,
            child: IconButton(
              tooltip: 'Retour',
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: RevisionColors.text,
                size: 24,
              ),
            ),
          ),
          const Spacer(),
          PopupMenuButton<_CourseMenuAction>(
            tooltip: 'Plus d’actions',
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: RevisionColors.text,
              size: 24,
            ),
            color: RevisionColors.ink2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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
              _CourseMenuAction.history => _showCourseHistory(context, detail),
              _CourseMenuAction.advanced => _showCourseAdvancedActions(
                context,
                detail,
                revisionSubjectVisualThemeFor(
                  '${detail.subject.name} ${detail.course.title}',
                ),
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
        ],
      ),
    );
  }
}

enum _CourseMenuAction { sources, manage, history, advanced }

class _CourseDetailReveal extends StatelessWidget {
  const _CourseDetailReveal({required this.visible, required this.child});

  static const _duration = Duration(milliseconds: 360);

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Opacity(opacity: visible ? 1 : 0, child: child);
    }

    final totalDuration = visible
        ? _duration
        : const Duration(milliseconds: 220);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: visible ? 1 : 0),
      duration: totalDuration,
      curve: Curves.linear,
      child: child,
      builder: (context, value, child) {
        final eased = Curves.easeOutCubic.transform(value);

        return Transform.translate(
          offset: Offset(0, (1 - eased) * 12),
          child: Opacity(opacity: eased, child: child),
        );
      },
    );
  }
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

      if (!context.mounted) {
        return;
      }

      if (resumable != null) {
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

Future<void> _runCoursePrimaryAction(
  BuildContext context,
  WidgetRef ref,
  CourseDetail detail,
  CourseLearningPathPrimaryAction? action,
) async {
  if (action != null) {
    await _runLearningPathPrimaryAction(context, ref, detail, action);
    return;
  }

  final hasReadySource = detail.sources.any(
    (source) => source.status == CourseDocumentStatus.ready,
  );

  if (hasReadySource) {
    await _showQuickRevisionSheet(context, ref, detail);
    return;
  }

  _showSourcesSheet(context, ref, detail);
}

bool _canRunCoursePrimaryAction(
  CourseLearningPathPrimaryAction? action,
  bool hasReadySource,
) {
  if (action != null) {
    return action.enabled;
  }

  return hasReadySource;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parcours',
          style: RevisionTypography.sectionTitle.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 10),
        if (learningPathState.isLoading && !learningPathState.hasValue)
          _CoursePathStateCard(
            child: Text(
              'Chargement du parcours',
              style: RevisionTypography.body,
            ),
          )
        else if (learningPathState.hasError && path == null)
          _CoursePathStateCard(
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
          _CoursePathStateCard(
            child: _LearningPathEmptyState(
              detail: detail,
              emptyState: path?.emptyState,
            ),
          )
        else
          Hero(
            tag: CourseHeroTags.learningPath(detail.course.id),
            flightShuttleBuilder: buildCourseCardHeroFlightShuttle,
            transitionOnUserGestures: true,
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  for (final indexed in path.nodes.indexed)
                    _LearningPathRow(
                      node: indexed.$2,
                      visual: visual,
                      selected: _isSelectedPathNode(path, indexed.$2),
                      first: indexed.$1 == 0,
                      last: indexed.$1 == path.nodes.length - 1,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CoursePathStateCard extends StatelessWidget {
  const _CoursePathStateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: const EdgeInsets.all(RevisionSpacing.m),
      radius: BorderRadius.circular(10),
      backgroundColor: RevisionColors.glassSoft,
      child: child,
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
    final completed = node.state == CourseLearningPathNodeState.solid;
    final markerColor = selected
        ? visual.accent
        : completed
        ? RevisionColors.green
        : RevisionColors.borderBright;
    final topLineColor = completed || selected
        ? RevisionColors.green.withValues(alpha: 0.68)
        : RevisionColors.borderBright.withValues(alpha: 0.55);
    final bottomLineColor = completed
        ? RevisionColors.green.withValues(alpha: 0.68)
        : RevisionColors.borderBright.withValues(alpha: 0.55);

    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        color: selected ? visual.accent.withValues(alpha: 0.13) : null,
        borderRadius: BorderRadius.circular(8),
        border: selected
            ? Border.all(color: visual.accent.withValues(alpha: 0.24))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 40,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 9,
                  color: first ? Colors.transparent : topLineColor,
                ),
                Container(
                  width: selected ? 22 : 18,
                  height: selected ? 22 : 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? visual.accent.withValues(alpha: 0.22)
                        : completed
                        ? RevisionColors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: markerColor,
                      width: selected ? 3 : 2,
                    ),
                  ),
                  child: completed
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
                  height: selected ? 9 : 13,
                  color: last ? Colors.transparent : bottomLineColor,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 11, right: 12),
              child: Text(
                node.display.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: RevisionTypography.body.copyWith(
                  color: completed || selected
                      ? RevisionColors.text
                      : RevisionColors.textMuted,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
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
    final quickReadinessState = ref.watch(
      courseQuestionBankReadinessProvider((
        courseId: detail.course.id,
        questionCount: 10,
      )),
    );
    final quickReadiness = quickReadinessState.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    final questionsPreparing =
        hasReadySource &&
        quickReadiness?.status == CourseQuestionBankReadinessStatus.preparing &&
        (quickReadiness?.readyQuestionCount ?? 0) < 5;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: RevisionColors.glassStrong.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RevisionColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox(
              width: 116,
              child: _CourseActionButton(
                label: 'Comprendre',
                icon: Icons.menu_book_rounded,
                onPressed: hasReadySource
                    ? () =>
                          context.push(AppRoutes.courseSheet(detail.course.id))
                    : null,
                outlined: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CourseActionButton(
                label: 'Réviser cette notion',
                icon: Icons.flash_on_rounded,
                onPressed: questionsPreparing
                    ? () =>
                          context.push(AppRoutes.courseSheet(detail.course.id))
                    : canReviewCourse
                    ? () =>
                          _runCoursePrimaryAction(context, ref, detail, action)
                    : null,
                gradient: _coursePrimaryGradient,
              ),
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

double _courseMasteryValue(CourseLearningPath? path, CourseDetail detail) {
  final pathMastery = path?.summary.estimatedGlobalMastery;
  if (pathMastery != null && pathMastery > 0) {
    return pathMastery;
  }

  return detail.progress?.estimatedGlobalMastery ?? 0;
}

bool _isSelectedPathNode(CourseLearningPath path, CourseLearningPathNode node) {
  final activeId = path.activeNodeId;
  if (activeId != null) {
    return node.id == activeId;
  }

  for (final candidate in path.nodes) {
    if (candidate.state != CourseLearningPathNodeState.solid) {
      return candidate.id == node.id;
    }
  }

  return path.nodes.isNotEmpty && path.nodes.last.id == node.id;
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
