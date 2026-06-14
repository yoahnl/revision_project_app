import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/documents/document_source_excerpt.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_message.dart';
import 'package:revision_app/presentation/widgets/revision_panel.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

class OpenQuestionPage extends StatefulWidget {
  const OpenQuestionPage({required this.activity, this.onSubmit, super.key});

  final OpenQuestionActivity activity;
  final OpenAnswerSubmitter? onSubmit;

  @override
  State<OpenQuestionPage> createState() => _OpenQuestionPageState();
}

class _OpenQuestionPageState extends State<OpenQuestionPage> {
  late OpenQuestionSessionController _controller;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
    _textController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant OpenQuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activity != widget.activity ||
        oldWidget.onSubmit != widget.onSubmit) {
      _controller = _createController();
      _textController.dispose();
      _textController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _controller.result;
    final evaluation = result?.evaluation;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OpenQuestionHeader(activity: widget.activity),
          const SizedBox(height: AppSpacing.l),
          if (_controller.submitErrorMessage != null) ...[
            RevisionMessage(
              message: _controller.submitErrorMessage!,
              color: Theme.of(context).colorScheme.error,
              icon: Icons.error_outline,
            ),
            const SizedBox(height: AppSpacing.l),
          ],
          _QuestionPanel(activity: widget.activity),
          const SizedBox(height: AppSpacing.l),
          if (evaluation == null)
            _AnswerPanel(
              activity: widget.activity,
              controller: _controller,
              textController: _textController,
              onChanged: _updateAnswer,
              onSubmit: _submit,
            ),
          if (_controller.isSubmitting) ...[
            const SizedBox(height: AppSpacing.l),
            const RevisionMessage(
              message: 'Correction en cours...',
              color: Colors.teal,
              icon: Icons.hourglass_top,
            ),
          ],
          if (evaluation != null) ...[
            _SubmittedAnswerPanel(answerText: _controller.answerText),
            const SizedBox(height: AppSpacing.l),
            _EvaluationPanel(evaluation: evaluation),
          ],
        ],
      ),
    );
  }

  OpenQuestionSessionController _createController() {
    return OpenQuestionSessionController(
      activity: widget.activity,
      submitter: widget.onSubmit,
    );
  }

  void _updateAnswer(String answerText) {
    setState(() {
      _controller.updateAnswer(answerText);
    });
  }

  Future<void> _submit() async {
    final submitFuture = _controller.submit();
    setState(() {});
    await submitFuture;

    if (mounted) {
      setState(() {});
    }
  }
}

class _OpenQuestionHeader extends StatelessWidget {
  const _OpenQuestionHeader({required this.activity});

  final OpenQuestionActivity activity;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ouverte', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              RevisionStatusPill(
                label: 'Correction sourcée',
                color: Theme.of(context).colorScheme.primary,
                icon: Icons.rate_review_outlined,
              ),
              RevisionStatusPill(
                label: '${activity.question.maxAnswerLength} caractères max',
                color: Theme.of(context).colorScheme.secondary,
                icon: Icons.edit_note,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.activity});

  final OpenQuestionActivity activity;

  @override
  Widget build(BuildContext context) {
    final question = activity.question;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          if (question.instructions != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(question.instructions!),
          ],
          if (question.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text(
              'Sources disponibles après correction',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                for (final source in question.sources)
                  _SourceReference(source: source),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceReference extends StatelessWidget {
  const _SourceReference({required this.source});

  final OpenQuestionSource source;

  @override
  Widget build(BuildContext context) {
    final pageLabel = source.pageNumber == null
        ? null
        : 'page ${source.pageNumber}';
    final label = pageLabel == null
        ? 'Source ${source.index + 1}'
        : 'Source ${source.index + 1} · $pageLabel';

    return RevisionStatusPill(
      label: label,
      color: Theme.of(context).colorScheme.secondary,
      icon: Icons.source_outlined,
    );
  }
}

class _AnswerPanel extends StatelessWidget {
  const _AnswerPanel({
    required this.activity,
    required this.controller,
    required this.textController,
    required this.onChanged,
    required this.onSubmit,
  });

  final OpenQuestionActivity activity;
  final OpenQuestionSessionController controller;
  final TextEditingController textController;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final validationMessage = controller.answerText.isEmpty
        ? null
        : controller.validationMessage;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ta réponse', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Material(
            color: Colors.transparent,
            child: TextField(
              controller: textController,
              enabled: !controller.isSubmitting,
              minLines: 6,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: 'Réponse',
                alignLabelWithHint: true,
                errorText: validationMessage,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${controller.answerText.length} / ${activity.question.maxAnswerLength}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.l),
          Align(
            alignment: Alignment.centerLeft,
            child: RevisionButton(
              onPressed: controller.canSubmit ? onSubmit : null,
              icon: Icons.check,
              label: controller.isSubmitting
                  ? 'Correction en cours...'
                  : 'Valider ma réponse',
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedAnswerPanel extends StatelessWidget {
  const _SubmittedAnswerPanel({required this.answerText});

  final String answerText;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Réponse envoyée', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          Text(answerText),
        ],
      ),
    );
  }
}

class _EvaluationPanel extends StatelessWidget {
  const _EvaluationPanel({required this.evaluation});

  final OpenAnswerEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    return switch (evaluation.status) {
      OpenAnswerEvaluationStatus.ready => _ReadyEvaluationPanel(
        evaluation: evaluation,
      ),
      OpenAnswerEvaluationStatus.failed => _FailedEvaluationPanel(
        evaluation: evaluation,
      ),
      OpenAnswerEvaluationStatus.pending => const RevisionMessage(
        message: 'La correction est en attente.',
        color: Colors.teal,
        icon: Icons.hourglass_empty,
      ),
    };
  }
}

class _ReadyEvaluationPanel extends StatelessWidget {
  const _ReadyEvaluationPanel({required this.evaluation});

  final OpenAnswerEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
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
              if (evaluation.score != null && evaluation.maxScore != null)
                RevisionStatusPill(
                  label:
                      'Score ${_formatNumber(evaluation.score!)} / ${_formatNumber(evaluation.maxScore!)}',
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.verified_outlined,
                ),
            ],
          ),
          if (evaluation.feedback != null) ...[
            const SizedBox(height: AppSpacing.l),
            Text(evaluation.feedback!),
          ],
          _PointSection(title: 'Points présents', items: evaluation.presentPoints),
          _PointSection(title: 'Points à compléter', items: evaluation.missingPoints),
          _PointSection(title: 'Erreurs ou confusions', items: evaluation.errors),
          if (evaluation.modelAnswer != null) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Réponse modèle', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(evaluation.modelAnswer!),
          ],
          if (evaluation.advice != null) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Conseil', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(evaluation.advice!),
          ],
          if (evaluation.sources.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.l),
            Text('Sources', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Column(
              spacing: AppSpacing.s,
              children: [
                for (final source in evaluation.sources)
                  DocumentSourceExcerpt(
                    text: source.text,
                    index: source.index,
                    pageNumber: source.pageNumber,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PointSection extends StatelessWidget {
  const _PointSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text('• $item'),
            ),
        ],
      ),
    );
  }
}

class _FailedEvaluationPanel extends StatelessWidget {
  const _FailedEvaluationPanel({required this.evaluation});

  final OpenAnswerEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;

    return RevisionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: color, size: 18),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  "La correction n'a pas pu être générée.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (evaluation.errors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            for (final error in evaluation.errors)
              Text(error, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

String _formatNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }

  return value.toStringAsFixed(1);
}
