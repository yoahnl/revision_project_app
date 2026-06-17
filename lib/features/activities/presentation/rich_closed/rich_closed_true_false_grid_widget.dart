import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedTrueFalseGridWidget extends StatefulWidget {
  const RichClosedTrueFalseGridWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedTrueFalseGridQuestion question;
  final ValueChanged<RichClosedTrueFalseGridAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedTrueFalseGridWidget> createState() =>
      _RichClosedTrueFalseGridWidgetState();
}

class _RichClosedTrueFalseGridWidgetState
    extends State<RichClosedTrueFalseGridWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedTrueFalseGridWidget oldWidget) {
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
        for (final row in widget.question.rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _TrueFalseGridRow(
              row: row,
              selectedValue: _controller.selectedTrueFalseValueFor(
                widget.question.id,
                row.id,
              ),
              enabled: widget.enabled,
              onChanged: (value) => _selectValue(row.id, value),
            ),
          ),
      ],
    );
  }

  void _selectValue(String rowId, bool value) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.setTrueFalseValue(
        question: widget.question,
        rowId: rowId,
        value: value,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedTrueFalseGridAnswer ? answer : null,
    );
  }
}

class _TrueFalseGridRow extends StatelessWidget {
  const _TrueFalseGridRow({
    required this.row,
    required this.selectedValue,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedTrueFalseRow row;
  final bool? selectedValue;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(row.statement, style: Theme.of(context).textTheme.bodyMedium),
          if (row.context != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(row.context!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _BooleanButton(
                key: ValueKey('true-false-${row.id}-true'),
                label: 'Vrai',
                selected: selectedValue == true,
                enabled: enabled,
                onPressed: () => onChanged(true),
              ),
              _BooleanButton(
                key: ValueKey('true-false-${row.id}-false'),
                label: 'Faux',
                selected: selectedValue == false,
                enabled: enabled,
                onPressed: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BooleanButton extends StatelessWidget {
  const _BooleanButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return FilledButton.tonal(
        onPressed: enabled ? onPressed : null,
        child: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      child: Text(label),
    );
  }
}
