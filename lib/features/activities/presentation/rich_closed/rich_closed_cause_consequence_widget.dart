import 'package:flutter/material.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';

class RichClosedCauseConsequenceWidget extends StatefulWidget {
  const RichClosedCauseConsequenceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedCauseConsequenceQuestion question;
  final ValueChanged<RichClosedCauseConsequenceAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedCauseConsequenceWidget> createState() =>
      _RichClosedCauseConsequenceWidgetState();
}

class _RichClosedCauseConsequenceWidgetState
    extends State<RichClosedCauseConsequenceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedCauseConsequenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        for (final cause in widget.question.causes)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _CauseConsequenceRow(
              question: widget.question,
              cause: cause,
              selectedConsequenceId: _controller.selectedConsequenceIdFor(
                widget.question.id,
                cause.id,
              ),
              enabled: widget.enabled,
              onChanged: (consequenceId) =>
                  _selectPair(cause.id, consequenceId),
            ),
          ),
      ],
    );
  }

  void _selectPair(String causeId, String? consequenceId) {
    if (!widget.enabled || consequenceId == null) {
      return;
    }

    setState(() {
      _controller.setCauseConsequencePair(
        question: widget.question,
        causeId: causeId,
        consequenceId: consequenceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedCauseConsequenceAnswer ? answer : null,
    );
  }
}

class _CauseConsequenceRow extends StatelessWidget {
  const _CauseConsequenceRow({
    required this.question,
    required this.cause,
    required this.selectedConsequenceId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedCauseConsequenceQuestion question;
  final RichClosedCauseConsequenceItem cause;
  final String? selectedConsequenceId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cause.label, style: Theme.of(context).textTheme.labelLarge),
          if (cause.description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              cause.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                key: ValueKey('cause-consequence-${question.id}-${cause.id}'),
                value: selectedConsequenceId,
                isExpanded: true,
                hint: const Text('Choisir une conséquence'),
                items: [
                  for (final consequence in question.consequences)
                    DropdownMenuItem<String>(
                      value: consequence.id,
                      child: Text(consequence.label),
                    ),
                ],
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
