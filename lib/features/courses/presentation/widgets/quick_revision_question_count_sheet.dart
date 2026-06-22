import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/design_system/components/revision_mvp_components.dart';
import '../../../../presentation/design_system/tokens/revision_colors.dart';
import '../../../../presentation/design_system/tokens/revision_radius.dart';
import '../../../../presentation/design_system/tokens/revision_spacing.dart';
import '../../../../presentation/design_system/tokens/revision_typography.dart';
import '../../application/courses_providers.dart';
import '../../domain/course_models.dart';

enum QuickRevisionQuestionCountAction { start, prepare, wait }

class QuickRevisionQuestionCountSelection {
  const QuickRevisionQuestionCountSelection({
    required this.questionCount,
    required this.action,
  });

  final int questionCount;
  final QuickRevisionQuestionCountAction action;
}

class QuickRevisionQuestionCountSheet extends ConsumerStatefulWidget {
  const QuickRevisionQuestionCountSheet({required this.courseId, super.key});

  final String courseId;

  @override
  ConsumerState<QuickRevisionQuestionCountSheet> createState() =>
      _QuickRevisionQuestionCountSheetState();
}

class _QuickRevisionQuestionCountSheetState
    extends ConsumerState<QuickRevisionQuestionCountSheet> {
  static const _choices = [5, 10, 20, 30];

  int? _selectedQuestionCount;

  @override
  Widget build(BuildContext context) {
    final readinessByChoice = {
      for (final choice in _choices)
        choice: ref.watch(
          courseQuestionBankReadinessProvider((
            courseId: widget.courseId,
            questionCount: choice,
          )),
        ),
    };
    final selectedQuestionCount =
        _selectedQuestionCount ?? _defaultQuestionCount(readinessByChoice);
    final selectedState = _choiceState(
      selectedQuestionCount,
      readinessByChoice[selectedQuestionCount],
    );

    return RevisionBottomSheetFrame(
      title: 'Révision rapide',
      subtitle: 'Choisis une quantité disponible ou prépare la suite.',
      children: [
        Wrap(
          spacing: RevisionSpacing.s,
          runSpacing: RevisionSpacing.s,
          children: [
            for (final choice in _choices)
              _QuestionCountChip(
                count: choice,
                state: _choiceState(choice, readinessByChoice[choice]),
                selected: choice == selectedQuestionCount,
                onTap: () => setState(() {
                  _selectedQuestionCount = choice;
                }),
              ),
          ],
        ),
        const SizedBox(height: RevisionSpacing.l),
        RevisionGradientButton(
          label: _buttonLabel(selectedQuestionCount, selectedState),
          icon: selectedState.action == QuickRevisionQuestionCountAction.start
              ? Icons.play_arrow_rounded
              : Icons.auto_awesome_rounded,
          expanded: true,
          onPressed:
              selectedState.action == QuickRevisionQuestionCountAction.wait
              ? null
              : () => Navigator.of(context).pop(
                  QuickRevisionQuestionCountSelection(
                    questionCount: selectedQuestionCount,
                    action: selectedState.action,
                  ),
                ),
        ),
        const SizedBox(height: RevisionSpacing.s),
        Text(
          'Tu peux démarrer avec les questions prêtes pendant que le reste se prépare.',
          style: RevisionTypography.caption,
        ),
      ],
    );
  }
}

class _QuestionCountChip extends StatelessWidget {
  const _QuestionCountChip({
    required this.count,
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final _QuestionCountChoiceState state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: RevisionRadius.radiusM,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 132,
        padding: const EdgeInsets.symmetric(
          horizontal: RevisionSpacing.m,
          vertical: RevisionSpacing.s,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [RevisionColors.blue, RevisionColors.blueDeep],
                )
              : null,
          color: selected ? null : RevisionColors.glassSoft,
          borderRadius: RevisionRadius.radiusM,
          border: Border.all(
            color: selected ? RevisionColors.blue : RevisionColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count questions',
              style: RevisionTypography.body.copyWith(
                color: selected
                    ? RevisionColors.text
                    : RevisionColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: RevisionSpacing.xs),
            Text(
              state.label,
              style: RevisionTypography.caption.copyWith(
                color: selected ? RevisionColors.text : state.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCountChoiceState {
  const _QuestionCountChoiceState({
    required this.label,
    required this.action,
    required this.color,
  });

  final String label;
  final QuickRevisionQuestionCountAction action;
  final Color color;
}

int _defaultQuestionCount(
  Map<int, AsyncValue<CourseQuestionBankReadiness>> readinessByChoice,
) {
  final readyChoices = _QuickRevisionQuestionCountSheetState._choices.where((
    choice,
  ) {
    final readiness = readinessByChoice[choice]?.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    return readiness != null && readiness.readyQuestionCount >= choice;
  });

  return readyChoices.isEmpty
      ? 5
      : readyChoices.reduce((a, b) => a > b ? a : b);
}

_QuestionCountChoiceState _choiceState(
  int choice,
  AsyncValue<CourseQuestionBankReadiness>? readinessState,
) {
  final readiness = readinessState?.maybeWhen(
    data: (value) => value,
    orElse: () => null,
  );

  if (readiness != null && readiness.readyQuestionCount >= choice) {
    return const _QuestionCountChoiceState(
      label: 'Prêt',
      action: QuickRevisionQuestionCountAction.start,
      color: RevisionColors.green,
    );
  }

  if (readinessState?.isLoading ?? false) {
    return const _QuestionCountChoiceState(
      label: 'Vérification',
      action: QuickRevisionQuestionCountAction.wait,
      color: RevisionColors.textMuted,
    );
  }

  if (readiness?.status == CourseQuestionBankReadinessStatus.preparing) {
    return const _QuestionCountChoiceState(
      label: 'En préparation',
      action: QuickRevisionQuestionCountAction.wait,
      color: RevisionColors.amber,
    );
  }

  if (readiness?.status == CourseQuestionBankReadinessStatus.failed) {
    return const _QuestionCountChoiceState(
      label: 'À relancer',
      action: QuickRevisionQuestionCountAction.prepare,
      color: RevisionColors.red,
    );
  }

  return const _QuestionCountChoiceState(
    label: 'À préparer',
    action: QuickRevisionQuestionCountAction.prepare,
    color: RevisionColors.textMuted,
  );
}

String _buttonLabel(int questionCount, _QuestionCountChoiceState state) {
  return switch (state.action) {
    QuickRevisionQuestionCountAction.start => 'Démarrer',
    QuickRevisionQuestionCountAction.prepare =>
      'Préparer $questionCount questions',
    QuickRevisionQuestionCountAction.wait => 'Préparation en cours',
  };
}
