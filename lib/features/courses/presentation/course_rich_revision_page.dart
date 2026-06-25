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

class CourseRichRevisionPage extends ConsumerWidget {
  const CourseRichRevisionPage({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(courseRichRevisionOptionsProvider(courseId));

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
        Text('QCM complet', style: RevisionTypography.hero),
        Text(
          'Entraîne-toi avec des questions variées à partir d’une notion du cours.',
          style: RevisionTypography.body,
        ),
      ],
      children: [
        options.when(
          loading: () => const RevisionLoadingState(
            label: 'Préparation du QCM complet...',
          ),
          error: (error, stackTrace) {
            if (error is CourseNotFoundException) {
              return CourseNotFoundPage(courseId: courseId);
            }

            return RevisionErrorState(
              title: 'QCM complet indisponible',
              message: 'Impossible de préparer ce QCM complet pour le moment.',
              actionLabel: 'Réessayer',
              onAction: () =>
                  ref.invalidate(courseRichRevisionOptionsProvider(courseId)),
            );
          },
          data: (options) => _CourseRichRevisionContent(options: options),
        ),
      ],
    );
  }
}

class _CourseRichRevisionContent extends ConsumerStatefulWidget {
  const _CourseRichRevisionContent({required this.options});

  final CourseRichRevisionOptions options;

  @override
  ConsumerState<_CourseRichRevisionContent> createState() =>
      _CourseRichRevisionContentState();
}

class _CourseRichRevisionContentState
    extends ConsumerState<_CourseRichRevisionContent> {
  String? _selectedScopeId;
  int? _selectedQuestionCount;
  String? _selectedProfile;

  @override
  void initState() {
    super.initState();
    _resetSelection();
  }

  @override
  void didUpdateWidget(covariant _CourseRichRevisionContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.course.id != widget.options.course.id) {
      _resetSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final startState = ref.watch(startCourseRichRevisionControllerProvider);
    final selectedScope = _selectedScope(options);
    final selectedProfile = _selectedProfile;
    final canStart =
        options.readiness.canStart &&
        selectedScope != null &&
        selectedScope.canSelect &&
        selectedScope.kind == CourseRichRevisionScopeKind.knowledgeUnit &&
        _selectedQuestionCount != null &&
        selectedProfile != null;

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
        if (options.questionCountOptions.isNotEmpty) ...[
          const _SectionTitle(
            title: 'Nombre de questions',
            subtitle:
                'Les quantités disponibles restent bornées pour ce cours.',
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
        if (options.complexityProfiles.length > 1) ...[
          const _SectionTitle(
            title: 'Profil',
            subtitle: 'Ajuste le niveau de variété des questions.',
          ),
          const SizedBox(height: RevisionSpacing.s),
          Material(
            type: MaterialType.transparency,
            child: Wrap(
              spacing: RevisionSpacing.s,
              runSpacing: RevisionSpacing.s,
              children: [
                for (final profile in options.complexityProfiles)
                  ChoiceChip(
                    label: Text(_profileLabel(profile)),
                    selected: selectedProfile == profile,
                    onSelected: (_) {
                      setState(() {
                        _selectedProfile = profile;
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
            title: 'Types inclus',
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
                    icon: Icons.extension_rounded,
                    accent: RevisionColors.green,
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
                  label: startState.isLoading
                      ? 'Préparation du QCM complet...'
                      : 'Démarrer le QCM complet',
                  icon: Icons.play_arrow_rounded,
                  expanded: true,
                  onPressed: startState.isLoading
                      ? null
                      : () => _start(selectedScope, selectedProfile),
                ),
              ],
              if (startState.hasError) ...[
                const SizedBox(height: RevisionSpacing.m),
                Text(
                  'Impossible de préparer ce QCM complet pour le moment.',
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

  void _resetSelection() {
    _selectedScopeId = widget.options.defaultConfig?.scopeId;
    _selectedQuestionCount = widget.options.defaultQuestionCount;
    _selectedProfile = widget.options.defaultConfig?.complexityProfile;
  }

  CourseRichRevisionScopeOption? _selectedScope(
    CourseRichRevisionOptions options,
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

  Future<void> _start(
    CourseRichRevisionScopeOption scope,
    String profile,
  ) async {
    final questionCount = _selectedQuestionCount;
    if (questionCount == null) {
      return;
    }

    try {
      final exercise = await ref
          .read(startCourseRichRevisionControllerProvider.notifier)
          .start(
            courseId: widget.options.course.id,
            config: CourseRichRevisionConfig(
              scopeKind: scope.kind,
              scopeId: scope.id,
              questionCount: questionCount,
              complexityProfile: profile,
            ),
          );

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.richClosedExercise(sessionId: exercise.sessionId));
    } catch (_) {
      // The controller state displays a user-facing message.
    }
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.readiness});

  final CourseRichRevisionReadiness readiness;

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

  final List<CourseRichRevisionScopeOption> options;
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
                      ? RevisionColors.blue
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

IconData _readinessIcon(CourseRichRevisionReadinessState state) {
  return switch (state) {
    CourseRichRevisionReadinessState.ready => Icons.check_circle_rounded,
    CourseRichRevisionReadinessState.partiallyReady =>
      Icons.check_circle_outline_rounded,
    CourseRichRevisionReadinessState.notReady => Icons.info_outline_rounded,
    CourseRichRevisionReadinessState.blocked => Icons.lock_outline_rounded,
    CourseRichRevisionReadinessState.unknown => Icons.help_outline_rounded,
  };
}

Color _readinessColor(CourseRichRevisionReadinessState state) {
  return switch (state) {
    CourseRichRevisionReadinessState.ready => RevisionColors.green,
    CourseRichRevisionReadinessState.partiallyReady => RevisionColors.amber,
    CourseRichRevisionReadinessState.notReady => RevisionColors.amber,
    CourseRichRevisionReadinessState.blocked => RevisionColors.red,
    CourseRichRevisionReadinessState.unknown => RevisionColors.textMuted,
  };
}

String _readinessLabel(CourseRichRevisionReadinessState state) {
  return switch (state) {
    CourseRichRevisionReadinessState.ready => 'Prêt',
    CourseRichRevisionReadinessState.partiallyReady => 'Partiellement prêt',
    CourseRichRevisionReadinessState.notReady => 'Pas encore prêt',
    CourseRichRevisionReadinessState.blocked => 'Action nécessaire',
    CourseRichRevisionReadinessState.unknown => 'État à vérifier',
  };
}

String _profileLabel(String profile) {
  return switch (profile) {
    'standard' => 'Standard',
    'advanced' => 'Avancé',
    _ => profile,
  };
}

String _questionKindsLabel(List<String> kinds) {
  final labels = kinds.map(_questionKindLabel).whereType<String>().toList();
  if (labels.isEmpty) {
    return 'Questions variées';
  }

  return labels.take(5).join(', ');
}

String _countLabel(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}

String? _questionKindLabel(String kind) {
  return switch (kind) {
    'single_choice' => 'choix simple',
    'multiple_choice' => 'choix multiple',
    'matching' => 'associations',
    'ordering' => 'classement',
    'case_qualification' => 'cas pratique',
    'error_detection' => 'erreurs à repérer',
    'timeline' => 'chronologie',
    'date_slider' => 'dates',
    'true_false_grid' => 'vrai/faux',
    'cause_consequence' => 'causes et conséquences',
    'institution_matrix' => 'tableaux',
    'diagram_labeling' => 'schémas',
    'calculation_mcq' => 'calculs guidés',
    _ => null,
  };
}

void _popOrGo(BuildContext context, String fallbackLocation) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackLocation);
  }
}
