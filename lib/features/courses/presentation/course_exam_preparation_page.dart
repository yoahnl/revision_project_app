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

class CourseExamPreparationPage extends ConsumerWidget {
  const CourseExamPreparationPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(courseExamPreparationOptionsProvider(courseId));

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
        Text('Préparation examen', style: RevisionTypography.hero),
        Text(
          'Construis un entraînement plus proche d’un sujet d’examen, à partir de ce cours.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        options.when(
          loading: () => const RevisionLoadingState(
            label: 'Chargement de la préparation examen',
          ),
          error: (error, stackTrace) {
            if (error is CourseNotFoundException) {
              return CourseNotFoundPage(courseId: courseId);
            }

            return RevisionErrorState(
              title: 'Préparation indisponible',
              message:
                  'Impossible de charger cette préparation pour le moment.',
              actionLabel: 'Réessayer',
              onAction: () => ref.invalidate(
                courseExamPreparationOptionsProvider(courseId),
              ),
            );
          },
          data: (options) => _ExamPreparationContent(options: options),
        ),
      ],
    );
  }
}

class _ExamPreparationContent extends ConsumerStatefulWidget {
  const _ExamPreparationContent({required this.options});

  final CourseExamPreparationOptions options;

  @override
  ConsumerState<_ExamPreparationContent> createState() =>
      _ExamPreparationContentState();
}

class _ExamPreparationContentState
    extends ConsumerState<_ExamPreparationContent> {
  String? _selectedScopeId;
  int? _selectedQuestionCount;
  bool _isStarting = false;
  Object? _startError;

  @override
  void initState() {
    super.initState();
    _selectedScopeId = widget.options.defaultConfig?.scopeId;
    _selectedQuestionCount = widget.options.defaultQuestionCount;
  }

  @override
  void didUpdateWidget(covariant _ExamPreparationContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.course.id != widget.options.course.id) {
      _selectedScopeId = widget.options.defaultConfig?.scopeId;
      _selectedQuestionCount = widget.options.defaultQuestionCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final selectedScope = _selectedScope(options);
    final canStart =
        options.readiness.canPrepare &&
        selectedScope != null &&
        selectedScope.canSelect &&
        _selectedQuestionCount != null &&
        selectedScope.kind != CourseExamPreparationScopeKind.unknown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReadinessCard(readiness: options.readiness),
        const SizedBox(height: RevisionSpacing.m),
        if (options.scopeOptions.isNotEmpty) ...[
          _SectionTitle(
            title: 'Périmètre',
            subtitle: 'Choisis la partie du cours à travailler.',
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
        if (options.questionCountOptions.isNotEmpty) ...[
          _SectionTitle(
            title: 'Nombre de questions',
            subtitle: 'Garde une configuration réaliste pour ce cours.',
          ),
          const SizedBox(height: RevisionSpacing.s),
          Material(
            type: MaterialType.transparency,
            child: Wrap(
              spacing: RevisionSpacing.s,
              runSpacing: RevisionSpacing.s,
              children: [
                for (final count in options.questionCountOptions)
                  ChoiceChip(
                    label: Text('$count questions'),
                    selected: _selectedQuestionCount == count,
                    onSelected: (_) {
                      setState(() {
                        _selectedQuestionCount = count;
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
        if (options.supportedQuestionKinds.isNotEmpty) ...[
          _SectionTitle(
            title: 'Types de questions',
            subtitle: _questionKindsLabel(options.supportedQuestionKinds),
          ),
          const SizedBox(height: RevisionSpacing.m),
        ],
        RevisionGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RevisionIconTile(
                    icon: Icons.flag_rounded,
                    accent: RevisionColors.pink,
                    size: 44,
                  ),
                  const SizedBox(width: RevisionSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          options.readiness.canPrepare
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
                      ? 'Préparation...'
                      : 'Démarrer l’entraînement',
                  icon: Icons.play_arrow_rounded,
                  expanded: true,
                  onPressed: _isStarting ? null : () => _start(selectedScope),
                ),
              ],
              if (_startError != null) ...[
                const SizedBox(height: RevisionSpacing.m),
                Text(
                  'Impossible de démarrer cette préparation pour le moment.',
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

  CourseExamPreparationScopeOption? _selectedScope(
    CourseExamPreparationOptions options,
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

  Future<void> _start(CourseExamPreparationScopeOption scope) async {
    final questionCount = _selectedQuestionCount;
    if (questionCount == null) {
      return;
    }

    setState(() {
      _isStarting = true;
      _startError = null;
    });

    try {
      final response = await ref
          .read(coursesRepositoryProvider)
          .startCourseExamPreparation(
            courseId: widget.options.course.id,
            config: CourseExamPreparationConfig(
              scopeKind: scope.kind,
              scopeId: scope.id,
              questionCount: questionCount,
              complexityProfile: 'exam',
            ),
          );

      ref.invalidate(
        courseExamPreparationOptionsProvider(widget.options.course.id),
      );

      if (!mounted) {
        return;
      }

      context.go(
        AppRoutes.revisionSessionV2(
          sessionId: response.session.id,
          courseId: widget.options.course.id,
          mode: 'exam',
        ),
      );
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
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.readiness});

  final CourseExamPreparationReadiness readiness;

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
                  '${readiness.readySourceCount} source(s) prête(s) · '
                  '${readiness.readyKnowledgeUnitCount} notion(s) · '
                  '${readiness.availableQuestionCount} question(s)',
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

  final List<CourseExamPreparationScopeOption> options;
  final String? selectedScopeId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in options) ...[
          RevisionGlassCard(
            onTap: option.canSelect ? () => onSelected(option.id) : null,
            child: Row(
              children: [
                Icon(
                  selectedScopeId == option.id
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: option.canSelect
                      ? RevisionColors.pink
                      : RevisionColors.textMuted,
                ),
                const SizedBox(width: RevisionSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: RevisionTypography.sectionTitle,
                      ),
                      const SizedBox(height: RevisionSpacing.xs),
                      Text(
                        '${option.readyQuestionCount} question(s) · ${option.readyKnowledgeUnitCount} notion(s)',
                        style: RevisionTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RevisionSpacing.s),
        ],
      ],
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

String _readinessLabel(CourseExamPreparationReadinessState state) {
  return switch (state) {
    CourseExamPreparationReadinessState.ready => 'Prêt',
    CourseExamPreparationReadinessState.partiallyReady => 'Partiellement prêt',
    CourseExamPreparationReadinessState.notReady => 'Pas encore prêt',
    CourseExamPreparationReadinessState.blocked => 'Action nécessaire',
    CourseExamPreparationReadinessState.unknown => 'État indisponible',
  };
}

IconData _readinessIcon(CourseExamPreparationReadinessState state) {
  return switch (state) {
    CourseExamPreparationReadinessState.ready => Icons.check_circle_rounded,
    CourseExamPreparationReadinessState.partiallyReady => Icons.tune_rounded,
    CourseExamPreparationReadinessState.notReady => Icons.hourglass_empty,
    CourseExamPreparationReadinessState.blocked => Icons.error_outline_rounded,
    CourseExamPreparationReadinessState.unknown => Icons.help_outline_rounded,
  };
}

Color _readinessColor(CourseExamPreparationReadinessState state) {
  return switch (state) {
    CourseExamPreparationReadinessState.ready => RevisionColors.mint,
    CourseExamPreparationReadinessState.partiallyReady => RevisionColors.blue,
    CourseExamPreparationReadinessState.notReady => RevisionColors.amber,
    CourseExamPreparationReadinessState.blocked => RevisionColors.red,
    CourseExamPreparationReadinessState.unknown => RevisionColors.textMuted,
  };
}

String _questionKindsLabel(List<String> kinds) {
  final labels = kinds.map((kind) {
    return switch (kind) {
      'single_choice' => 'choix simple',
      'multiple_choice' => 'choix multiple',
      'matching' => 'association',
      'ordering' => 'ordre',
      'date_slider' => 'dates',
      _ => null,
    };
  }).whereType<String>();

  return labels.isEmpty ? 'Formats disponibles' : labels.join(', ');
}

void _popOrGo(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackRoute);
}
