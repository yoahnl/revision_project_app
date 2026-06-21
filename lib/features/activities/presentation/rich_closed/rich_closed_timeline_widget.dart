import 'package:flutter/material.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';

class RichClosedTimelineWidget extends StatefulWidget {
  const RichClosedTimelineWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedTimelineQuestion question;
  final ValueChanged<RichClosedTimelineAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedTimelineWidget> createState() =>
      _RichClosedTimelineWidgetState();
}

class _RichClosedTimelineWidgetState extends State<RichClosedTimelineWidget> {
  late RichClosedCoreAnswerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
    _emitInitialAnswer();
  }

  @override
  void didUpdateWidget(covariant RichClosedTimelineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
      _emitInitialAnswer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderedEventIds = _controller.orderedEventIdsFor(widget.question);
    final eventsById = {
      for (final event in widget.question.events) event.id: event,
    };

    return RichClosedQuestionCard(
      question: widget.question,
      children: [
        Text(
          widget.question.instruction ??
              'Réorganise les événements avec les boutons monter et descendre.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.s),
        for (final indexedEvent in orderedEventIds.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: _TimelineRow(
              event: eventsById[indexedEvent.$2]!,
              position: indexedEvent.$1 + 1,
              canMoveUp: widget.enabled && indexedEvent.$1 > 0,
              canMoveDown:
                  widget.enabled &&
                  indexedEvent.$1 < orderedEventIds.length - 1,
              onMoveUp: () => _moveUp(indexedEvent.$2),
              onMoveDown: () => _moveDown(indexedEvent.$2),
            ),
          ),
      ],
    );
  }

  void _moveUp(String eventId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveTimelineEventUp(
        question: widget.question,
        eventId: eventId,
      );
    });
    _emitAnswer();
  }

  void _moveDown(String eventId) {
    if (!widget.enabled) {
      return;
    }

    setState(() {
      _controller.moveTimelineEventDown(
        question: widget.question,
        eventId: eventId,
      );
    });
    _emitAnswer();
  }

  void _emitInitialAnswer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.enabled) {
        return;
      }
      _emitAnswer();
    });
  }

  void _emitAnswer() {
    final answer = _controller.answerFor(widget.question);
    if (answer is RichClosedTimelineAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.position,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final RichClosedTimelineEvent event;
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.label),
                if (event.description != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    event.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            key: ValueKey('timeline-up-${event.id}'),
            tooltip: 'Monter ${event.label}',
            onPressed: canMoveUp ? onMoveUp : null,
            icon: const Icon(Icons.arrow_upward),
          ),
          IconButton(
            key: ValueKey('timeline-down-${event.id}'),
            tooltip: 'Descendre ${event.label}',
            onPressed: canMoveDown ? onMoveDown : null,
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}
