import 'package:flutter/material.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';

class RichClosedCalculationMcqWidget extends StatefulWidget {
  const RichClosedCalculationMcqWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedCalculationMcqQuestion question;
  final ValueChanged<RichClosedCalculationMcqAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedCalculationMcqWidget> createState() =>
      _RichClosedCalculationMcqWidgetState();
}

class _RichClosedCalculationMcqWidgetState
    extends State<RichClosedCalculationMcqWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedCalculationMcqWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedCalculationChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        if (widget.question.instruction != null) ...[
          Text(
            widget.question.instruction!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        _CalculationScenarioPanel(question: widget.question),
        const SizedBox(height: AppSpacing.m),
        for (final choice in widget.question.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _CalculationChoiceTile(
              key: ValueKey(
                'calculation-mcq-${widget.question.id}-${choice.id}',
              ),
              choice: choice,
              selected: selectedChoiceId == choice.id,
              enabled: widget.enabled,
              onTap: () => _selectChoice(choice.id),
            ),
          ),
      ],
    );
  }

  void _selectChoice(String? choiceId) {
    if (!widget.enabled || choiceId == null) {
      return;
    }

    setState(() {
      _controller.selectCalculationChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedCalculationMcqAnswer ? answer : null,
    );
  }
}

class _CalculationChoiceTile extends StatelessWidget {
  const _CalculationChoiceTile({
    required this.choice,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final RichClosedCalculationChoice choice;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : null,
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(choice.label),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Valeur : ${choice.value}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculationScenarioPanel extends StatelessWidget {
  const _CalculationScenarioPanel({required this.question});

  final RichClosedCalculationMcqQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.scenario, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.s),
          ..._calculationLines(question.calculation),
        ],
      ),
    );
  }

  List<Widget> _calculationLines(RichClosedCalculationData calculation) {
    return switch (calculation) {
      RichClosedAbsoluteMajorityThresholdCalculation(:final validVotes) => [
        Text('Suffrages exprimés : $validVotes'),
      ],
      RichClosedLargestRemainderTargetPartySeatsCalculation(
        :final totalSeats,
        :final targetPartyId,
        :final parties,
      ) =>
        [
          Text('Sièges à répartir : $totalSeats'),
          Text('Parti ciblé : ${_partyLabel(parties, targetPartyId)}'),
          const SizedBox(height: AppSpacing.xs),
          for (final party in parties)
            Text('${party.label} : ${party.votes} voix'),
        ],
    };
  }

  String _partyLabel(List<RichClosedCalculationParty> parties, String partyId) {
    for (final party in parties) {
      if (party.id == partyId) {
        return party.label;
      }
    }

    return partyId;
  }
}
