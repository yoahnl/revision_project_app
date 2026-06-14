import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_choice_tile.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

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
            selectedChoiceId: _controller.selectedChoiceIdFor(question.id),
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
    required this.selectedChoiceId,
    required this.correction,
    required this.enabled,
    required this.onChoiceSelected,
  });

  final int questionNumber;
  final DiagnosticQuizQuestion question;
  final String? selectedChoiceId;
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
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (correction == null && question.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Sources disponibles après correction',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          for (final choice in question.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: RevisionChoiceTile(
                label: choice.label,
                selected: selectedChoiceId == choice.id,
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
    final selectedLabel = _choiceLabel(correction.selectedChoiceId);
    final correctLabel = _choiceLabel(correction.correctChoiceId);
    final statusColor = correction.isCorrect
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

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
        Text('Réponse sélectionnée: $selectedLabel'),
        Text('Réponse attendue: $correctLabel'),
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

  String _choiceLabel(String choiceId) {
    for (final choice in question.choices) {
      if (choice.id == choiceId) {
        return choice.label;
      }
    }

    return choiceId;
  }
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
