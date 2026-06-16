import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_choice_group.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedErrorDetectionWidget extends StatefulWidget {
  const RichClosedErrorDetectionWidget({
    required this.question,
    required this.onAnswerChanged,
    this.enabled = true,
    super.key,
  });

  final RichClosedErrorDetectionQuestion question;
  final ValueChanged<RichClosedErrorDetectionAnswer> onAnswerChanged;
  final bool enabled;

  @override
  State<RichClosedErrorDetectionWidget> createState() =>
      _RichClosedErrorDetectionWidgetState();
}

class _RichClosedErrorDetectionWidgetState
    extends State<RichClosedErrorDetectionWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedErrorDetectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id) {
      _controller = RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedErrorId = _controller.selectedChoiceIdFor(widget.question.id);

    return RichClosedQuestionCard(
      question: widget.question,
      leading: _RichClosedStatementBlock(text: widget.question.statement),
      children: [
        RichClosedChoiceGroup(
          choices: widget.question.errorOptions,
          selectedChoiceIds: selectedErrorId == null
              ? const []
              : [selectedErrorId],
          enabled: widget.enabled,
          onChoiceSelected: _selectError,
        ),
      ],
    );
  }

  void _selectError(String errorId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.selectErrorDetection(
        question: widget.question,
        errorId: errorId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedErrorDetectionAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _RichClosedStatementBlock extends StatelessWidget {
  const _RichClosedStatementBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Énoncé à vérifier',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(text),
        ],
      ),
    );
  }
}
