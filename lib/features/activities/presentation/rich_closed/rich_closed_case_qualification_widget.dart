import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedCaseQualificationWidget extends StatefulWidget {
  const RichClosedCaseQualificationWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedCaseQualificationQuestion question;
  final ValueChanged<RichClosedCaseQualificationAnswer> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedCaseQualificationWidget> createState() =>
      _RichClosedCaseQualificationWidgetState();
}

class _RichClosedCaseQualificationWidgetState
    extends State<RichClosedCaseQualificationWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedCaseQualificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChoiceId = _controller.selectedChoiceIdFor(
      widget.question.id,
    );

    return RichClosedQuestionCard(
      question: widget.question,
      leading: _RichClosedContextBlock(
        label: 'Cas',
        text: widget.question.caseText,
      ),
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
      _controller.selectCaseQualification(
        question: widget.question,
        choiceId: choiceId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedCaseQualificationAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _RichClosedContextBlock extends StatelessWidget {
  const _RichClosedContextBlock({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(text),
        ],
      ),
    );
  }
}
