import 'package:flutter/material.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:Neralune/presentation/widgets/revision_choice_tile.dart';
import 'package:Neralune/presentation/widgets/revision_message.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';
import 'package:Neralune/presentation/widgets/revision_status_pill.dart';

class DiagnosticQuizPage extends StatefulWidget {
  const DiagnosticQuizPage({required this.activity, this.onSubmit, super.key});

  final DiagnosticQuizActivity activity;
  final DiagnosticQuizSubmitter? onSubmit;

  @override
  State<DiagnosticQuizPage> createState() => _DiagnosticQuizPageState();
}

class _DiagnosticQuizPageState extends State<DiagnosticQuizPage> {
  late DiagnosticQuizSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(covariant DiagnosticQuizPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activity != widget.activity ||
        oldWidget.onSubmit != widget.onSubmit) {
      _controller = _createController();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activity.questions.isEmpty) {
      return const Center(child: Text('Aucune question disponible'));
    }

    final result = _controller.result;
    final hasResult = result != null;

    return ListView(
      children: [
        _QuizHeader(activity: widget.activity, controller: _controller),
        const SizedBox(height: AppSpacing.l),
        if (_controller.submitError != null) ...[
          RevisionMessage(
            message: _submitErrorMessage(_controller.submitError),
            color: Theme.of(context).colorScheme.error,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        if (result != null) ...[
          _ResultSummary(result: result),
          const SizedBox(height: AppSpacing.l),
        ],
        for (final (index, question) in widget.activity.questions.indexed) ...[
          _QuestionPanel(
            questionNumber: index + 1,
            question: question,
            selectedChoiceIds: _controller.selectedChoiceIdsFor(question.id),
            correction: result?.correctionFor(question.id),
            enabled: !hasResult && !_controller.isSubmitting,
            onChoiceSelected: (choiceId) {
              setState(() {
                _controller.selectChoice(
                  questionId: question.id,
                  choiceId: choiceId,
                );
              });
            },
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: RevisionButton(
            onPressed: _controller.canSubmit ? _submit : null,
            icon: Icons.check,
            label: _controller.isSubmitting ? 'Validation...' : 'Valider',
          ),
        ),
      ],
    );
  }

  DiagnosticQuizSessionController _createController() {
    return DiagnosticQuizSessionController(
      activity: widget.activity,
      submitter: widget.onSubmit,
    );
  }

  Future<void> _submit() async {
    final submitFuture = _controller.submit();
    setState(() {});
    await submitFuture;

    if (mounted) {
      setState(() {});
    }
  }

  String _submitErrorMessage(Object? error) {
    if (error == null) {
      return 'Impossible de valider les réponses.';
    }

    return 'Impossible de valider les réponses. Réessaie dans un instant.';
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({required this.activity, required this.controller});

  final DiagnosticQuizActivity activity;
  final DiagnosticQuizSessionController controller;

  @override
  Widget build(BuildContext context) {
    final totalQuestions = activity.questions.length;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(activity.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: '$totalQuestions questions',
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.quiz_outlined,
              ),
              RevisionStatusPill(
                label: '${controller.answeredCount} / $totalQuestions réponses',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    required this.questionNumber,
    required this.question,
    required this.selectedChoiceIds,
    required this.correction,
    required this.enabled,
    required this.onChoiceSelected,
  });

  final int questionNumber;
  final DiagnosticQuizQuestion question;
  final List<String> selectedChoiceIds;
  final DiagnosticQuizCorrectionItem? correction;
  final bool enabled;
  final ValueChanged<String> onChoiceSelected;

  @override
  Widget build(BuildContext context) {
    final correction = this.correction;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Question $questionNumber',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              if (question.difficulty != null)
                RevisionStatusPill(
                  label: question.difficulty!,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              RevisionStatusPill(
                label:
                    question.selectionMode ==
                        DiagnosticQuizSelectionMode.multiple
                    ? 'Plusieurs réponses possibles'
                    : 'Une seule réponse',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (question.visuals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            _QuestionVisuals(visuals: question.visuals),
          ],
          if (correction == null && question.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Sources disponibles après correction',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          if (question.selectionMode == DiagnosticQuizSelectionMode.multiple)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Text(
                _multipleSelectionHint(question),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          for (final choice in question.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: RevisionChoiceTile(
                label: choice.label,
                selected: selectedChoiceIds.contains(choice.id),
                enabled: enabled,
                onTap: () => onChoiceSelected(choice.id),
              ),
            ),
          if (correction != null) ...[
            const SizedBox(height: AppSpacing.m),
            _CorrectionBlock(question: question, correction: correction),
          ],
        ],
      ),
    );
  }

  String _multipleSelectionHint(DiagnosticQuizQuestion question) {
    if (question.minSelections == question.maxSelections) {
      return 'Sélectionne ${question.minSelections} réponses.';
    }

    return 'Sélectionne entre ${question.minSelections} et ${question.maxSelections} réponses.';
  }
}

class _QuestionVisuals extends StatelessWidget {
  const _QuestionVisuals({required this.visuals});

  final List<DiagnosticQuizVisual> visuals;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSpacing.s,
      children: [for (final visual in visuals) _QuestionVisual(visual: visual)],
    );
  }
}

class _QuestionVisual extends StatelessWidget {
  const _QuestionVisual({required this.visual});

  final DiagnosticQuizVisual visual;

  @override
  Widget build(BuildContext context) {
    return switch (visual) {
      DiagnosticQuizChartVisual chart => _ChartVisual(chart: chart),
      DiagnosticQuizDiagramVisual diagram => _DiagramVisual(diagram: diagram),
      DiagnosticQuizUnsupportedVisual unsupported => _UnsupportedVisual(
        visual: unsupported,
      ),
    };
  }
}

class _VisualFrame extends StatelessWidget {
  const _VisualFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
      ),
      child: child,
    );
  }
}

class _ChartVisual extends StatelessWidget {
  const _ChartVisual({required this.chart});

  final DiagnosticQuizChartVisual chart;

  @override
  Widget build(BuildContext context) {
    return _VisualFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chart.title, style: Theme.of(context).textTheme.titleSmall),
          if (chart.description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(chart.description!),
          ],
          const SizedBox(height: AppSpacing.s),
          if (chart.chartType == DiagnosticQuizChartType.bar)
            _BarChartRows(chart: chart)
          else
            _ChartTable(chart: chart),
        ],
      ),
    );
  }
}

class _BarChartRows extends StatelessWidget {
  const _BarChartRows({required this.chart});

  final DiagnosticQuizChartVisual chart;

  @override
  Widget build(BuildContext context) {
    final xKey = chart.xKey;
    final yKey = chart.yKeys.isEmpty ? null : chart.yKeys.first;
    final maxValue = _maxNumericValue(yKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in chart.data)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_rowLabel(row, xKey)),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _rowFraction(row, yKey, maxValue),
                    minHeight: 8,
                  ),
                ),
                if (yKey != null && row[yKey] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '${row[yKey]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  double _maxNumericValue(String? key) {
    if (key == null) {
      return 1;
    }

    final values = chart.data
        .map((row) => row[key])
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList(growable: false);

    if (values.isEmpty) {
      return 1;
    }

    return values.reduce((left, right) => left > right ? left : right);
  }

  double _rowFraction(Map<String, Object?> row, String? key, double maxValue) {
    if (key == null || maxValue <= 0) {
      return 0;
    }

    final value = row[key];
    if (value is! num) {
      return 0;
    }

    return (value.toDouble() / maxValue).clamp(0, 1);
  }
}

class _ChartTable extends StatelessWidget {
  const _ChartTable({required this.chart});

  final DiagnosticQuizChartVisual chart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in chart.data)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              row.entries
                  .map((entry) => '${entry.key}: ${entry.value}')
                  .join(' | '),
            ),
          ),
      ],
    );
  }
}

class _DiagramVisual extends StatelessWidget {
  const _DiagramVisual({required this.diagram});

  final DiagnosticQuizDiagramVisual diagram;

  @override
  Widget build(BuildContext context) {
    return _VisualFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(diagram.title, style: Theme.of(context).textTheme.titleSmall),
          if (diagram.description != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(diagram.description!),
          ],
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              for (final node in diagram.nodes)
                _DiagramNodePill(label: node.label),
            ],
          ),
          if (diagram.edges.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            for (final edge in diagram.edges)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(_edgeLabel(edge)),
              ),
          ],
        ],
      ),
    );
  }

  String _edgeLabel(DiagnosticQuizDiagramEdge edge) {
    final from = _nodeLabel(edge.from);
    final to = _nodeLabel(edge.to);
    final label = edge.label;

    if (label == null || label.isEmpty) {
      return '$from -> $to';
    }

    return '$from -> $to: $label';
  }

  String _nodeLabel(String id) {
    for (final node in diagram.nodes) {
      if (node.id == id) {
        return node.label;
      }
    }

    return id;
  }
}

class _DiagramNodePill extends StatelessWidget {
  const _DiagramNodePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
        color: colorScheme.surface,
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _UnsupportedVisual extends StatelessWidget {
  const _UnsupportedVisual({required this.visual});

  final DiagnosticQuizUnsupportedVisual visual;

  @override
  Widget build(BuildContext context) {
    return _VisualFrame(
      child: Row(
        children: [
          Icon(
            Icons.hide_image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(child: Text('Visuel ${visual.type} indisponible')),
        ],
      ),
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.result});

  final DiagnosticQuizResult result;

  @override
  Widget build(BuildContext context) {
    final score = result.score;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Correction', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label:
                    'Score ${result.correctAnswers} / ${result.totalQuestions}',
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.verified_outlined,
              ),
              if (score != null)
                RevisionStatusPill(
                  label: '${(score * 100).round()} %',
                  color: Theme.of(context).colorScheme.secondary,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CorrectionBlock extends StatelessWidget {
  const _CorrectionBlock({required this.question, required this.correction});

  final DiagnosticQuizQuestion question;
  final DiagnosticQuizCorrectionItem correction;

  @override
  Widget build(BuildContext context) {
    final selectedLabels = _choiceLabels(_selectedChoiceIds());
    final correctLabels = _choiceLabels(_correctChoiceIds());
    final statusColor = correction.isCorrect
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final isMultiple =
        question.selectionMode == DiagnosticQuizSelectionMode.multiple ||
        correction.selectedChoiceIds.isNotEmpty ||
        correction.correctChoiceIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionStatusPill(
          label: correction.isCorrect ? 'Correct' : 'À revoir',
          color: statusColor,
          icon: correction.isCorrect
              ? Icons.check_circle_outline
              : Icons.cancel_outlined,
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          isMultiple
              ? 'Réponses sélectionnées: $selectedLabels'
              : 'Réponse sélectionnée: $selectedLabels',
        ),
        Text(
          isMultiple
              ? 'Réponses attendues: $correctLabels'
              : 'Réponse attendue: $correctLabels',
        ),
        if (correction.partialScore != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Score partiel ${(correction.partialScore! * 100).round()} %',
            ),
          ),
        const SizedBox(height: AppSpacing.s),
        Text(correction.explanation),
        if (correction.choiceFeedback.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          Text('Feedback', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          for (final feedback in correction.choiceFeedback)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '${_choiceLabel(feedback.choiceId)}: ${feedback.feedback}',
              ),
            ),
        ],
        if (correction.sources.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          Text('Sources', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          Column(
            spacing: AppSpacing.s,
            children: [
              for (final source in correction.sources)
                DocumentSourceExcerpt(
                  text: source.text,
                  index: source.index,
                  pageNumber: source.pageNumber,
                ),
            ],
          ),
        ],
      ],
    );
  }

  List<String> _selectedChoiceIds() {
    if (correction.selectedChoiceIds.isNotEmpty) {
      return correction.selectedChoiceIds;
    }

    final selectedChoiceId = correction.selectedChoiceId;
    return selectedChoiceId == null ? const [] : [selectedChoiceId];
  }

  List<String> _correctChoiceIds() {
    if (correction.correctChoiceIds.isNotEmpty) {
      return correction.correctChoiceIds;
    }

    final correctChoiceId = correction.correctChoiceId;
    return correctChoiceId == null ? const [] : [correctChoiceId];
  }

  String _choiceLabels(List<String> choiceIds) {
    if (choiceIds.isEmpty) {
      return 'Non renseigné';
    }

    return choiceIds.map(_choiceLabel).join(', ');
  }

  String _choiceLabel(String choiceId) {
    for (final choice in question.choices) {
      if (choice.id == choiceId) {
        return choice.label;
      }
    }

    return choiceId;
  }
}

String _rowLabel(Map<String, Object?> row, String? key) {
  if (key != null && row[key] != null) {
    return '${row[key]}';
  }

  if (row.isEmpty) {
    return 'Donnée';
  }

  return '${row.values.first}';
}

extension on DiagnosticQuizResult {
  DiagnosticQuizCorrectionItem? correctionFor(String questionId) {
    for (final item in items) {
      if (item.questionId == questionId) {
        return item;
      }
    }

    return null;
  }
}
