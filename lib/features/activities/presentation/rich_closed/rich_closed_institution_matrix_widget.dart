import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

class RichClosedInstitutionMatrixWidget extends StatefulWidget {
  const RichClosedInstitutionMatrixWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedInstitutionMatrixQuestion question;
  final ValueChanged<RichClosedInstitutionMatrixAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedInstitutionMatrixWidget> createState() =>
      _RichClosedInstitutionMatrixWidgetState();
}

class _RichClosedInstitutionMatrixWidgetState
    extends State<RichClosedInstitutionMatrixWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedInstitutionMatrixWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellsByRowId = <String, List<RichClosedInstitutionMatrixCell>>{};
    for (final cell in widget.question.cells) {
      cellsByRowId.putIfAbsent(cell.rowId, () => []).add(cell);
    }

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
          if ((cellsByRowId[row.id] ?? const []).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: _MatrixRowPanel(
                question: widget.question,
                row: row,
                cells: cellsByRowId[row.id] ?? const [],
                selectedOptionIdFor: (cellId) =>
                    _controller.selectedInstitutionMatrixOptionIdFor(
                      widget.question.id,
                      cellId,
                    ),
                enabled: widget.enabled,
                onChanged: _selectValue,
              ),
            ),
      ],
    );
  }

  void _selectValue({required String cellId, required String? optionId}) {
    if (!widget.enabled || optionId == null) {
      return;
    }

    setState(() {
      _controller.setInstitutionMatrixValue(
        question: widget.question,
        cellId: cellId,
        optionId: optionId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedInstitutionMatrixAnswer ? answer : null,
    );
  }
}

class _MatrixRowPanel extends StatelessWidget {
  const _MatrixRowPanel({
    required this.question,
    required this.row,
    required this.cells,
    required this.selectedOptionIdFor,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedInstitutionMatrixQuestion question;
  final RichClosedInstitutionMatrixAxisItem row;
  final List<RichClosedInstitutionMatrixCell> cells;
  final String? Function(String cellId) selectedOptionIdFor;
  final bool enabled;
  final void Function({required String cellId, required String? optionId})
  onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(row.label, style: theme.textTheme.labelLarge),
            if (row.description != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(row.description!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.s),
            for (final cell in cells)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: _MatrixCellSelector(
                  question: question,
                  cell: cell,
                  column: _columnFor(question, cell.columnId),
                  selectedOptionId: selectedOptionIdFor(cell.id),
                  enabled: enabled,
                  onChanged: (optionId) =>
                      onChanged(cellId: cell.id, optionId: optionId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MatrixCellSelector extends StatelessWidget {
  const _MatrixCellSelector({
    required this.question,
    required this.cell,
    required this.column,
    required this.selectedOptionId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedInstitutionMatrixQuestion question;
  final RichClosedInstitutionMatrixCell cell;
  final RichClosedInstitutionMatrixAxisItem column;
  final String? selectedOptionId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(column.label, style: Theme.of(context).textTheme.labelMedium),
        if (cell.prompt != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(cell.prompt!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: AppSpacing.xs),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey('institution-matrix-${question.id}-${cell.id}'),
              value: selectedOptionId,
              isExpanded: true,
              hint: const Text('Choisir une option'),
              items: [
                for (final option in cell.options)
                  DropdownMenuItem<String>(
                    value: option.id,
                    child: _DropdownOptionLabel(label: option.label),
                  ),
              ],
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownOptionLabel extends StatelessWidget {
  const _DropdownOptionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

RichClosedInstitutionMatrixAxisItem _columnFor(
  RichClosedInstitutionMatrixQuestion question,
  String columnId,
) {
  for (final column in question.columns) {
    if (column.id == columnId) {
      return column;
    }
  }

  throw StateError('Unknown institution matrix column $columnId');
}
