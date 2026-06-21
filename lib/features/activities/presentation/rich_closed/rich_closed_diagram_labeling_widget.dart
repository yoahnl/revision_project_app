import 'package:flutter/material.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';

class RichClosedDiagramLabelingWidget extends StatefulWidget {
  const RichClosedDiagramLabelingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedDiagramLabelingQuestion question;
  final ValueChanged<RichClosedDiagramLabelingAnswer?> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedDiagramLabelingWidget> createState() =>
      _RichClosedDiagramLabelingWidgetState();
}

class _RichClosedDiagramLabelingWidgetState
    extends State<RichClosedDiagramLabelingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedDiagramLabelingWidget oldWidget) {
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
        _DiagramSummary(question: widget.question),
        const SizedBox(height: AppSpacing.m),
        for (final slot in widget.question.slots)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _DiagramSlotSelector(
              question: widget.question,
              slot: slot,
              selectedOptionId: _controller.selectedDiagramLabelingOptionIdFor(
                widget.question.id,
                slot.id,
              ),
              enabled: widget.enabled,
              onChanged: (optionId) =>
                  _selectValue(slotId: slot.id, optionId: optionId),
            ),
          ),
      ],
    );
  }

  void _selectValue({required String slotId, required String? optionId}) {
    if (!widget.enabled || optionId == null) {
      return;
    }

    setState(() {
      _controller.setDiagramLabelingValue(
        question: widget.question,
        slotId: slotId,
        optionId: optionId,
      );
    });

    final answer = _controller.answerFor(widget.question);
    widget.onAnswerChanged(
      answer is RichClosedDiagramLabelingAnswer ? answer : null,
    );
  }
}

class _DiagramSummary extends StatelessWidget {
  const _DiagramSummary({required this.question});

  final RichClosedDiagramLabelingQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = question.diagram.title;

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
            if (title != null) ...[
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (question.diagram.description != null) ...[
              Text(
                question.diagram.description!,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.s),
            ],
            Text('Noeuds', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.xs),
            for (final node in question.diagram.nodes)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(_nodeLine(node)),
              ),
            if (question.diagram.edges.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s),
              Text('Relations', style: theme.textTheme.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              for (final edge in question.diagram.edges)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _EdgeLine(question: question, edge: edge),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EdgeLine extends StatelessWidget {
  const _EdgeLine({required this.question, required this.edge});

  final RichClosedDiagramLabelingQuestion question;
  final RichClosedDiagramEdge edge;

  @override
  Widget build(BuildContext context) {
    final label = edge.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_edgeEndpoints(question, edge)),
        if (label != null)
          Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _DiagramSlotSelector extends StatelessWidget {
  const _DiagramSlotSelector({
    required this.question,
    required this.slot,
    required this.selectedOptionId,
    required this.enabled,
    required this.onChanged,
  });

  final RichClosedDiagramLabelingQuestion question;
  final RichClosedDiagramLabelingSlot slot;
  final String? selectedOptionId;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_anchorLine(question, slot), style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(slot.prompt, style: theme.textTheme.bodySmall),
        const SizedBox(height: AppSpacing.xs),
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: ValueKey('diagram-labeling-${question.id}-${slot.id}'),
              value: selectedOptionId,
              isExpanded: true,
              hint: const Text('Choisir une option'),
              items: [
                for (final option in slot.options)
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

String _nodeLine(RichClosedDiagramNode node) => node.label;

String _anchorLine(
  RichClosedDiagramLabelingQuestion question,
  RichClosedDiagramLabelingSlot slot,
) {
  return switch (slot.anchorType) {
    RichClosedDiagramAnchorType.node => _nodeFor(question, slot.anchorId).label,
    RichClosedDiagramAnchorType.edge => _edgeLineWithLabel(
      question,
      _edgeFor(question, slot.anchorId),
    ),
  };
}

String _edgeLineWithLabel(
  RichClosedDiagramLabelingQuestion question,
  RichClosedDiagramEdge edge,
) {
  final endpoints = _edgeEndpoints(question, edge);
  final label = edge.label;
  if (label == null) {
    return endpoints;
  }

  return '$endpoints / $label';
}

String _edgeEndpoints(
  RichClosedDiagramLabelingQuestion question,
  RichClosedDiagramEdge edge,
) {
  final from = _nodeFor(question, edge.fromNodeId);
  final to = _nodeFor(question, edge.toNodeId);
  return '${from.label} -> ${to.label}';
}

RichClosedDiagramNode _nodeFor(
  RichClosedDiagramLabelingQuestion question,
  String nodeId,
) {
  for (final node in question.diagram.nodes) {
    if (node.id == nodeId) {
      return node;
    }
  }

  throw StateError('Unknown diagram node $nodeId');
}

RichClosedDiagramEdge _edgeFor(
  RichClosedDiagramLabelingQuestion question,
  String edgeId,
) {
  for (final edge in question.diagram.edges) {
    if (edge.id == edgeId) {
      return edge;
    }
  }

  throw StateError('Unknown diagram edge $edgeId');
}
