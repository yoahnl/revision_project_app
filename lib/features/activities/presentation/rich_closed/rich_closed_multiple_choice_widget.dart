import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';

class RichClosedMultipleChoiceWidget extends StatefulWidget {
  const RichClosedMultipleChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedMultipleChoiceQuestion question;
  final ValueChanged<RichClosedMultipleChoiceAnswer?> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedMultipleChoiceWidget> createState() =>
      _RichClosedMultipleChoiceWidgetState();
}

class _RichClosedMultipleChoiceWidgetState
    extends State<RichClosedMultipleChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedMultipleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          _selectionInstruction(widget.question),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        if (_controller.message != null) ...[
          RevisionMessage(
            message: _controller.message!,
            color: Theme.of(context).colorScheme.error,
            icon: Icons.info_outline,
          ),
          const SizedBox(height: AppSpacing.s),
        ],
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: _controller.selectedChoiceIdsFor(widget.question),
          enabled: widget.enabled,
          onChoiceSelected: _toggleChoice,
        ),
      ],
    );
  }

  void _toggleChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.toggleMultipleChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedMultipleChoiceAnswer ? answer : null,
    );
  }

  String _selectionInstruction(RichClosedMultipleChoiceQuestion question) {
    if (question.minSelections == question.maxSelections) {
      return 'Choisis ${question.minSelections} réponses.';
    }

    return 'Choisis entre ${question.minSelections} et ${question.maxSelections} réponses.';
  }
}
