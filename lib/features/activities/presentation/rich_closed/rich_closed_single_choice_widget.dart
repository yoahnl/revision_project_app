import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';

class RichClosedSingleChoiceWidget extends StatefulWidget {
  const RichClosedSingleChoiceWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedSingleChoiceQuestion question;
  final ValueChanged<RichClosedSingleChoiceAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedSingleChoiceWidget> createState() =>
      _RichClosedSingleChoiceWidgetState();
}

class _RichClosedSingleChoiceWidgetState
    extends State<RichClosedSingleChoiceWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedSingleChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.choices,
          selectedChoiceIds: selectedChoiceId == null
              ? const []
              : [selectedChoiceId],
          enabled: widget.enabled,
          onChoiceSelected: _selectChoice,
        ),
      ],
    );
  }

  void _selectChoice(String choiceId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectSingleChoice(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedSingleChoiceAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}
