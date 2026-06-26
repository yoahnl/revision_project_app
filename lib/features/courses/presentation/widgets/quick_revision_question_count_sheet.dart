import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../../presentation/design_system/tokens/revision_radius.dart';
import '../../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../../presentation/design_system/tokens/revision_typography.dart';
import '../../application/courses_providers.dart';
import '../../domain/course_models.dart';

enum CourseRevisionDurationAction { start, prepare, wait }

class CourseRevisionDurationSelection {
  const CourseRevisionDurationSelection({
    required this.durationMinutes,
    required this.questionCount,
    required this.action,
  });

  final int durationMinutes;
  final int questionCount;
  final CourseRevisionDurationAction action;
}

class CourseRevisionDurationSheet extends ConsumerStatefulWidget {
  const CourseRevisionDurationSheet({required this.courseId, super.key});

  final String courseId;

  @override
  ConsumerState<CourseRevisionDurationSheet> createState() =>
      _CourseRevisionDurationSheetState();
}

class _CourseRevisionDurationSheetState
    extends ConsumerState<CourseRevisionDurationSheet> {
  static const _durations = [
    _RevisionDurationOption(minutes: 5, label: 'Métro', questionCount: 5),
    _RevisionDurationOption(minutes: 15, label: 'Standard', questionCount: 10),
    _RevisionDurationOption(
      minutes: 30,
      label: 'Approfondi',
      questionCount: 30,
    ),
  ];

  int _selectedDurationMinutes = 5;

  @override
  Widget build(BuildContext context) {
    final readinessByChoice = {
      for (final option in _durations)
        option.minutes: ref.watch(
          courseQuestionBankReadinessProvider((
            courseId: widget.courseId,
            questionCount: option.questionCount,
          )),
        ),
    };
    final selectedOption = _durations.firstWhere(
      (option) => option.minutes == _selectedDurationMinutes,
    );
    final selectedState = _durationState(
      selectedOption,
      readinessByChoice[selectedOption.minutes],
    );

    return RevisionBottomSheetFrame(
      title: 'Combien de temps as-tu ?',
      subtitle: 'Choisis une session courte, on s’occupe du reste.',
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final useColumn = constraints.maxWidth < 430;
            final tiles = [
              for (final option in _durations)
                _DurationTile(
                  option: option,
                  state: _durationState(
                    option,
                    readinessByChoice[option.minutes],
                  ),
                  selected: option.minutes == _selectedDurationMinutes,
                  compact: useColumn,
                  onTap: () => setState(() {
                    _selectedDurationMinutes = option.minutes;
                  }),
                ),
            ];

            if (useColumn) {
              return Column(
                children: [
                  for (final tile in tiles) ...[
                    tile,
                    if (tile != tiles.last)
                      const SizedBox(height: RevisionSpacing.s),
                  ],
                ],
              );
            }

            return Row(
              children: [
                for (final tile in tiles) ...[
                  Expanded(child: tile),
                  if (tile != tiles.last)
                    const SizedBox(width: RevisionSpacing.s),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: RevisionSpacing.l),
        RevisionGradientButton(
          label: 'Commencer',
          icon: Icons.play_arrow_rounded,
          expanded: true,
          onPressed: selectedState.action == CourseRevisionDurationAction.wait
              ? null
              : () => Navigator.of(context).pop(
                  CourseRevisionDurationSelection(
                    durationMinutes: selectedOption.minutes,
                    questionCount: selectedOption.questionCount,
                    action: selectedState.action,
                  ),
                ),
        ),
        const SizedBox(height: RevisionSpacing.s),
        Text(
          'La durée règle seulement le rythme de la session. Les détails restent internes.',
          style: RevisionTypography.caption,
        ),
      ],
    );
  }
}

class _RevisionDurationOption {
  const _RevisionDurationOption({
    required this.minutes,
    required this.label,
    required this.questionCount,
  });

  final int minutes;
  final String label;
  final int questionCount;
}

class _DurationTile extends StatelessWidget {
  const _DurationTile({
    required this.option,
    required this.state,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _RevisionDurationOption option;
  final _DurationChoiceState state;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('course-revision-duration-${option.minutes}'),
      borderRadius: RevisionRadius.radiusM,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: compact ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: RevisionSpacing.m,
          vertical: compact ? RevisionSpacing.m : RevisionSpacing.s,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [RevisionColors.violet, RevisionColors.blueDeep],
                )
              : null,
          color: selected ? null : RevisionColors.glassSoft,
          borderRadius: RevisionRadius.radiusM,
          border: Border.all(
            color: selected ? RevisionColors.violet : RevisionColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Text(
                    '${option.minutes} min',
                    style: RevisionTypography.body.copyWith(
                      color: RevisionColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: compact ? TextAlign.start : TextAlign.center,
                  ),
                  const SizedBox(height: RevisionSpacing.xs),
                  Text(
                    option.label,
                    style: RevisionTypography.caption.copyWith(
                      color: selected
                          ? RevisionColors.text
                          : RevisionColors.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: compact ? TextAlign.start : TextAlign.center,
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                key: ValueKey(
                  'course-revision-duration-${option.minutes}-selected',
                ),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: RevisionColors.text.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: RevisionColors.text,
                  size: 16,
                ),
              ),
            if (!selected && state.action == CourseRevisionDurationAction.wait)
              const Icon(
                Icons.hourglass_top_rounded,
                color: RevisionColors.textMuted,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}

class _DurationChoiceState {
  const _DurationChoiceState({required this.action});

  final CourseRevisionDurationAction action;
}

_DurationChoiceState _durationState(
  _RevisionDurationOption option,
  AsyncValue<CourseQuestionBankReadiness>? readinessState,
) {
  final readiness = readinessState?.maybeWhen(
    data: (value) => value,
    orElse: () => null,
  );

  if (readiness != null &&
      (readiness.canStartQuickRevision ||
          readiness.readyQuestionCount >= option.questionCount)) {
    return const _DurationChoiceState(
      action: CourseRevisionDurationAction.start,
    );
  }

  if (readinessState?.isLoading ?? false) {
    return const _DurationChoiceState(
      action: CourseRevisionDurationAction.wait,
    );
  }

  if (readiness?.status == CourseQuestionBankReadinessStatus.preparing) {
    return const _DurationChoiceState(
      action: CourseRevisionDurationAction.wait,
    );
  }

  if (readiness?.canPrepare ?? true) {
    return const _DurationChoiceState(
      action: CourseRevisionDurationAction.prepare,
    );
  }

  return const _DurationChoiceState(action: CourseRevisionDurationAction.wait);
}
