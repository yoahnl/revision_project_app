import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';

class RichClosedOrderingWidget extends StatefulWidget {
  const RichClosedOrderingWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedOrderingQuestion question;
  final ValueChanged<RichClosedOrderingAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedOrderingWidget> createState() =>
      _RichClosedOrderingWidgetState();
}

class _RichClosedOrderingWidgetState extends State<RichClosedOrderingWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
  }

  @override
  void didUpdateWidget(covariant RichClosedOrderingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderedIds = _controller.orderedIdsFor(widget.question);
    final itemsById = {for (final item in widget.question.items) item.id: item};

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          'Réorganise les étapes avec les boutons monter et descendre.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final indexedItem in orderedIds.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _OrderingRow(
              item: itemsById[indexedItem.$2]!,
              position: indexedItem.$1 + 1,
              canMoveUp: widget.enabled && indexedItem.$1 > 0,
              canMoveDown:
                  widget.enabled && indexedItem.$1 < orderedIds.length - 1,
              onMoveUp: () => _moveUp(indexedItem.$2),
              onMoveDown: () => _moveDown(indexedItem.$2),
            ),
          ),
      ],
    );
  }

  void _moveUp(String itemId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveOrderingItemUp(question: widget.question, itemId: itemId);
    });
    _emitAnswer();
  }

  void _moveDown(String itemId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveOrderingItemDown(
        question: widget.question,
        itemId: itemId,
      );
    });
    _emitAnswer();
  }

  void _emitAnswer() {
    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedOrderingAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _OrderingRow extends StatelessWidget {
  const _OrderingRow({
    required this.item,
    required this.position,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final RichClosedLabelItem item;
  final int position;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position.',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text(item.label)),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            key: ValueKey('ordering-up-${item.id}'),
            tooltip: 'Monter ${item.label}',
            onPressed: canMoveUp ? onMoveUp : null,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            key: ValueKey('ordering-down-${item.id}'),
            tooltip: 'Descendre ${item.label}',
            onPressed: canMoveDown ? onMoveDown : null,
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}
