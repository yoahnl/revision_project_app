import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedMatchingWidget extends StatefulWidget {
  const RichClosedMatchingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedMatchingQuestion question;
  final ValueChanged<RichClosedMatchingAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedMatchingWidget> createState() =>
      _RichClosedMatchingWidgetState();
}

class _RichClosedMatchingWidgetState extends State<RichClosedMatchingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedMatchingWidget oldWidget) {
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
        Text(
          'Associe chaque élément de gauche à une proposition de droite.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final leftItem in widget.question.leftItems)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _MatchingRow(
              question: widget.question,
              leftItem: leftItem,
              selectedRightId: _controller.selectedRightIdFor(
                widget.question.id,
                leftItem.id,
              ),
              enabled: widget.enabled,
              onChanged: (rightId) => _selectPair(leftItem.id, rightId),
            ),
          ),
      ],
    );
  }

  void _selectPair(String leftId, String? rightId) {
    if (!widget.enabled || rightId == null) {
      return;
    }

    setState(() {
      _controller.setMatchingPair(
        question: widget.question,
        leftId: leftId,
        rightId: rightId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(answer is RichClosedMatchingAnswer ? answer : null);
  }
}

class _MatchingRow extends StatelessWidget {
  const _MatchingRow({
    required this.question,
    required this.leftItem,
    required this.selectedRightId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedMatchingQuestion question;
  final RichClosedLabelItem leftItem;
  final String? selectedRightId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(leftItem.label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.s),
          InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                key: ValueKey('matching-${question.id}-${leftItem.id}'),
                value: selectedRightId,
                isExpanded: true,
                hint: const Text('Choisir une association'),
                items: [
                  for (final rightItem in question.rightItems)
                    DropdownMenuItem<String>(
                      value: rightItem.id,
                      child: Text(rightItem.label),
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
