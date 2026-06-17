import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_question_card.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';

class RichClosedDateSliderWidget extends StatefulWidget {
  const RichClosedDateSliderWidget({
    required this.question,
    required this.onAnswerChanged,
    this.controller,
    this.enabled = true,
    super.key,
  });

  final RichClosedDateSliderQuestion question;
  final ValueChanged<RichClosedDateSliderAnswer> onAnswerChanged;
  final RichClosedCoreAnswerController? controller;
  final bool enabled;

  @override
  State<RichClosedDateSliderWidget> createState() =>
      _RichClosedDateSliderWidgetState();
}

class _RichClosedDateSliderWidgetState
    extends State<RichClosedDateSliderWidget> {
  late RichClosedCoreAnswerController _controller;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? RichClosedCoreAnswerController();
    _selectedYear = _controller.selectedYearFor(widget.question);
    _emitInitialAnswer();
  }

  @override
  void didUpdateWidget(covariant RichClosedDateSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.id != widget.question.id ||
        oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? RichClosedCoreAnswerController();
      _selectedYear = _controller.selectedYearFor(widget.question);
      _emitInitialAnswer();
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
        Text(
          'Année sélectionnée : $_selectedYear',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          key: ValueKey('date-slider-${widget.question.id}'),
          min: widget.question.minYear.toDouble(),
          max: widget.question.maxYear.toDouble(),
          divisions: _divisions(),
          label: '$_selectedYear',
          value: _selectedYear.toDouble(),
          onChanged: widget.enabled ? _onChanged : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.question.minYear}'),
            Text('${widget.question.maxYear}'),
          ],
        ),
      ],
    );
  }

  int? _divisions() {
    final range = widget.question.maxYear - widget.question.minYear;
    final divisions = (range / widget.question.step).round();

    return divisions <= 0 ? null : divisions;
  }

  void _onChanged(double value) {
    _controller.setDateSliderYear(
      question: widget.question,
      year: value.round(),
    );
    setState(() {
      _selectedYear = _controller.selectedYearFor(widget.question);
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
    if (answer is RichClosedDateSliderAnswer) {
      widget.onAnswerChanged(answer);
    }
  }
}
