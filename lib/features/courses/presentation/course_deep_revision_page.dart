import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../activities/domain/open_question_activity.dart';
import '../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../presentation/design_system/components/revision_states.dart';
import '../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../presentation/design_system/tokens/revision_typography.dart';
import '../../../presentation/pages/activities/open_question_page.dart';
import '../../../presentation/widgets/revision_button.dart';
import '../application/courses_providers.dart';
import '../domain/course_models.dart';
import '../domain/courses_repository.dart';
import 'course_not_found_page.dart';

class CourseDeepRevisionPage extends ConsumerWidget {
  const CourseDeepRevisionPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(courseDeepRevisionOptionsProvider(courseId));

    return RevisionPageScaffold(
      headerChildren: [
        Row(
          children: [
            IconButton(
              tooltip: 'Retour au cours',
              onPressed: () => _popOrGo(context, AppRoutes.course(courseId)),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ],
        ),
        Text('Révision approfondie', style: RevisionTypography.hero),
        Text(
          'Rédige une réponse et reçois une correction détaillée.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        options.when(
          loading: () => const RevisionLoadingState(
            label: 'Chargement de la révision approfondie...',
          ),
          error: (error, stackTrace) {
            if (error is CourseNotFoundException) {
              return CourseNotFoundPage(courseId: courseId);
            }

            return RevisionErrorState(
              title: 'Révision approfondie indisponible',
              message:
                  'Impossible de préparer cette révision approfondie pour le moment.',
              actionLabel: 'Réessayer',
              onAction: () =>
                  ref.invalidate(courseDeepRevisionOptionsProvider(courseId)),
            );
          },
          data: (options) => _CourseDeepRevisionContent(options: options),
        ),
      ],
    );
  }
}

class _CourseDeepRevisionContent extends ConsumerStatefulWidget {
  const _CourseDeepRevisionContent({required this.options});

  final CourseDeepRevisionOptions options;

  @override
  ConsumerState<_CourseDeepRevisionContent> createState() =>
      _CourseDeepRevisionContentState();
}

class _CourseDeepRevisionContentState
    extends ConsumerState<_CourseDeepRevisionContent> {
  String? _selectedScopeId;
  CourseDeepRevisionSession? _session;
  bool _isStarting = false;
  Object? _startError;

  @override
  void initState() {
    super.initState();
    _selectedScopeId = widget.options.defaultConfig?.scopeId;
  }

  @override
  void didUpdateWidget(covariant _CourseDeepRevisionContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.course.id != widget.options.course.id) {
      _selectedScopeId = widget.options.defaultConfig?.scopeId;
      _session = null;
      _startError = null;
      _isStarting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session != null) {
      return _OpenQuestionRevision(
        options: widget.options,
        session: session,
        onSubmit: _submitAnswer,
      );
    }

    final options = widget.options;
    final selectedScope = _selectedScope(options);
    final canStart =
        options.readiness.canStart &&
        selectedScope != null &&
        selectedScope.canSelect &&
        selectedScope.kind == CourseDeepRevisionScopeKind.knowledgeUnit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadinessCard(readiness: options.readiness),
        const SizedBox(height: RevisionSpacing.m),
        if (options.scopeOptions.isNotEmpty) ...[
          const _SectionTitle(
            title: 'Notion',
            subtitle: 'Choisis la notion qui servira de point de départ.',
          ),
          const SizedBox(height: RevisionSpacing.s),
          _ScopeSelector(
            options: options.scopeOptions,
            selectedScopeId: _selectedScopeId,
            onSelected: (scopeId) {
              setState(() {
                _selectedScopeId = scopeId;
              });
            },
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
        _GuidelinesCard(guidelines: options.answerGuidelines),
        const SizedBox(height: RevisionSpacing.m),
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          options.readiness.canStart
                              ? 'Configuration prête'
                              : 'Configuration indisponible',
                          style: RevisionTypography.sectionTitle,
                        ),
                        const SizedBox(height: RevisionSpacing.xs),
                        Text(
                          options.nextStep.userMessage,
                          style: RevisionTypography.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (canStart) ...[
                const SizedBox(height: RevisionSpacing.m),
                RevisionGradientButton(
                  label: _isStarting
                      ? 'Préparation de la question...'
                      : 'Démarrer la question ouverte',
                  icon: Icons.play_arrow_rounded,
                  expanded: true,
                  onPressed: _isStarting ? null : () => _start(selectedScope),
                  gradient: const LinearGradient(
                    colors: [RevisionColors.violet, RevisionColors.blueDeep],
                  ),
                ),
              ],
              if (_startError != null) ...[
                const SizedBox(height: RevisionSpacing.m),
                Text(
                  'Impossible de préparer cette révision approfondie pour le moment.',
                  style: RevisionTypography.caption.copyWith(
                    color: RevisionColors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  CourseDeepRevisionScopeOption? _selectedScope(
    CourseDeepRevisionOptions options,
  ) {
    final scopeId = _selectedScopeId;
    if (scopeId == null) {
      return null;
    }

    for (final option in options.scopeOptions) {
      if (option.id == scopeId) {
        return option;
      }
    }

    return null;
  }

  Future<void> _start(CourseDeepRevisionScopeOption scope) async {
    setState(() {
      _isStarting = true;
      _startError = null;
    });

    try {
      final session = await ref
          .read(coursesRepositoryProvider)
          .startCourseDeepRevision(
            courseId: widget.options.course.id,
            config: CourseDeepRevisionConfig(
              scopeKind: scope.kind,
              scopeId: scope.id,
            ),
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _session = session;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _startError = error;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  Future<OpenAnswerSubmissionResult> _submitAnswer(String answer) async {
    final session = _session;
    if (session == null) {
      throw StateError('Aucune question ouverte en cours.');
    }

    final response = await ref
        .read(coursesRepositoryProvider)
        .submitCourseDeepRevisionAnswer(
          courseId: widget.options.course.id,
          sessionId: session.session.id,
          answer: answer,
        );

    ref.invalidate(courseDeepRevisionHistoryProvider(widget.options.course.id));
    ref.invalidate(
      courseDeepRevisionResultProvider((
        courseId: widget.options.course.id,
        sessionId: session.session.id,
      )),
    );

    return response.toOpenAnswerSubmissionResult();
  }
}

class _OpenQuestionRevision extends StatelessWidget {
  const _OpenQuestionRevision({
    required this.options,
    required this.session,
    required this.onSubmit,
  });

  final CourseDeepRevisionOptions options;
  final CourseDeepRevisionSession session;
  final Future<OpenAnswerSubmissionResult> Function(String answer) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevisionGlassCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RevisionIconTile(
                icon: Icons.edit_note_rounded,
                accent: RevisionColors.violet,
                size: 44,
              ),
              const SizedBox(width: RevisionSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.scope.label,
                      style: RevisionTypography.sectionTitle,
                    ),
                    const SizedBox(height: RevisionSpacing.xs),
                    Text(
                      session.scope.sourceLabel,
                      style: RevisionTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RevisionSpacing.m),
        OpenQuestionPage(
          activity: session.toOpenQuestionActivity(course: options.course),
          onSubmit: onSubmit,
          afterEvaluationBuilder: (context, result) =>
              _DeepRevisionCompletionActions(
                courseId: options.course.id,
                sessionId: session.session.id,
              ),
        ),
      ],
    );
  }
}

class _DeepRevisionCompletionActions extends StatelessWidget {
  const _DeepRevisionCompletionActions({
    required this.courseId,
    required this.sessionId,
  });

  final String courseId;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Wrap(
        spacing: RevisionSpacing.s,
        runSpacing: RevisionSpacing.s,
        children: [
          RevisionButton(
            label: 'Voir le résultat',
            icon: Icons.open_in_new_rounded,
            onPressed: () => context.push(
              AppRoutes.courseDeepRevisionResult(
                courseId: courseId,
                sessionId: sessionId,
              ),
            ),
          ),
          RevisionButton(
            label: 'Retour au cours',
            icon: Icons.arrow_back_rounded,
            style: RevisionButtonStyle.ghost,
            onPressed: () => _popOrGo(context, AppRoutes.course(courseId)),
          ),
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.readiness});

  final CourseDeepRevisionReadiness readiness;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionIconTile(
            icon: _readinessIcon(readiness.state),
            accent: _readinessColor(readiness.state),
            size: 44,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _readinessLabel(readiness.state),
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(readiness.userMessage, style: RevisionTypography.body),
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  '${_countLabel(readiness.readySourceCount, 'source prête', 'sources prêtes')} · '
                  '${_countLabel(readiness.readyKnowledgeUnitCount, 'notion', 'notions')}',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeSelector extends StatelessWidget {
  const _ScopeSelector({
    required this.options,
    required this.selectedScopeId,
    required this.onSelected,
  });

  final List<CourseDeepRevisionScopeOption> options;
  final String? selectedScopeId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      padding: EdgeInsets.zero,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (final indexed in options.indexed) ...[
              ListTile(
                enabled: indexed.$2.canSelect,
                onTap: indexed.$2.canSelect
                    ? () => onSelected(indexed.$2.id)
                    : null,
                leading: Icon(
                  selectedScopeId == indexed.$2.id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: indexed.$2.canSelect
                      ? RevisionColors.violet
                      : RevisionColors.textMuted,
                ),
                title: Text(indexed.$2.label),
                subtitle: Text(indexed.$2.sourceLabel),
              ),
              if (indexed.$1 != options.length - 1)
                const Divider(height: 1, color: RevisionColors.border),
            ],
          ],
        ),
      ),
    );
  }
}

class _GuidelinesCard extends StatelessWidget {
  const _GuidelinesCard({required this.guidelines});

  final CourseDeepRevisionAnswerGuidelines guidelines;

  @override
  Widget build(BuildContext context) {
    return RevisionGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RevisionIconTile(
            icon: Icons.tips_and_updates_rounded,
            accent: RevisionColors.amber,
            size: 44,
          ),
          const SizedBox(width: RevisionSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conseil de rédaction',
                  style: RevisionTypography.sectionTitle,
                ),
                const SizedBox(height: RevisionSpacing.xs),
                Text(guidelines.userMessage, style: RevisionTypography.body),
                const SizedBox(height: RevisionSpacing.s),
                Text(
                  'Minimum ${guidelines.minLength} caractères · maximum ${guidelines.maxLength} caractères',
                  style: RevisionTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: RevisionTypography.sectionTitle),
        const SizedBox(height: RevisionSpacing.xs),
        Text(subtitle, style: RevisionTypography.caption),
      ],
    );
  }
}

String _readinessLabel(CourseDeepRevisionReadinessState state) {
  return switch (state) {
    CourseDeepRevisionReadinessState.ready => 'Prêt',
    CourseDeepRevisionReadinessState.notReady => 'Pas encore prêt',
    CourseDeepRevisionReadinessState.blocked => 'Action nécessaire',
    CourseDeepRevisionReadinessState.unknown => 'État indisponible',
  };
}

IconData _readinessIcon(CourseDeepRevisionReadinessState state) {
  return switch (state) {
    CourseDeepRevisionReadinessState.ready => Icons.check_circle_rounded,
    CourseDeepRevisionReadinessState.notReady => Icons.hourglass_empty,
    CourseDeepRevisionReadinessState.blocked => Icons.error_outline_rounded,
    CourseDeepRevisionReadinessState.unknown => Icons.help_outline_rounded,
  };
}

Color _readinessColor(CourseDeepRevisionReadinessState state) {
  return switch (state) {
    CourseDeepRevisionReadinessState.ready => RevisionColors.violet,
    CourseDeepRevisionReadinessState.notReady => RevisionColors.amber,
    CourseDeepRevisionReadinessState.blocked => RevisionColors.red,
    CourseDeepRevisionReadinessState.unknown => RevisionColors.textMuted,
  };
}

String _countLabel(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}

void _popOrGo(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackRoute);
}
