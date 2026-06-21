import 'package:flutter/material.dart';
import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/application/rich_closed_exercise_flow_controller.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_correction_list.dart';
import 'package:Neralune/features/activities/presentation/rich_closed/rich_closed_question_renderer.dart';
import 'package:Neralune/presentation/theme/app_spacing.dart';
import 'package:Neralune/presentation/widgets/revision_button.dart';
import 'package:Neralune/presentation/widgets/revision_message.dart';
import 'package:Neralune/presentation/widgets/revision_page.dart';
import 'package:Neralune/presentation/widgets/revision_panel.dart';

class RichClosedExercisePage extends StatefulWidget {
  const RichClosedExercisePage({
    required this.controller,
    this.subjectId,
    this.knowledgeUnitId,
    this.documentId,
    this.sessionId,
    super.key,
  });

  final ActivityController controller;
  final String? subjectId;
  final String? knowledgeUnitId;
  final String? documentId;
  final String? sessionId;

  @override
  State<RichClosedExercisePage> createState() => _RichClosedExercisePageState();
}

class _RichClosedExercisePageState extends State<RichClosedExercisePage> {
  late RichClosedExerciseFlowController _flowController;
  late RichClosedCoreAnswerController _answerController;

  @override
  void initState() {
    super.initState();
    _resetControllers();
    _startOrLoadExercise();
  }

  @override
  void didUpdateWidget(covariant RichClosedExercisePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_normalized(oldWidget.sessionId) != _normalized(widget.sessionId) ||
        _normalized(oldWidget.subjectId) != _normalized(widget.subjectId) ||
        _normalized(oldWidget.knowledgeUnitId) !=
            _normalized(widget.knowledgeUnitId) ||
        _normalized(oldWidget.documentId) != _normalized(widget.documentId)) {
      _resetControllers();
      _startOrLoadExercise();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _flowController.state;

    return RevisionPage(
      title: 'Questions riches',
      subtitle: 'Un exercice fermé structuré, corrigé par le backend.',
      children: [
        if (!_hasLoadContext)
          _MissingContextPanel()
        else if (state.isLoading)
          const _LoadingPanel()
        else if (state.status == RichClosedExerciseFlowStatus.failed)
          _FailurePanel(
            message: _failureMessage(state),
            canRetrySubmit: state.exercise != null,
            onRetry: state.exercise == null ? _startOrLoadExercise : _submit,
          )
        else if (state.hasResult && state.exercise != null)
          _CompletedExercisePanel(
            exercise: state.exercise!,
            result: state.result!,
            onRestart: _startFreshExercise,
          )
        else if (state.exercise != null)
          _ReadyExercisePanel(
            exercise: state.exercise!,
            state: state,
            answerController: _answerController,
            onAnswerChanged: _recordAnswer,
            onSubmit: _submit,
          )
        else
          _MissingContextPanel(),
      ],
    );
  }

  bool get _hasLoadContext {
    return _normalized(widget.sessionId) != null ||
        (_normalized(widget.subjectId) != null &&
            _normalized(widget.knowledgeUnitId) != null);
  }

  void _resetControllers() {
    _answerController = RichClosedCoreAnswerController();
    _flowController = RichClosedExerciseFlowController(
      activityController: widget.controller,
    );
  }

  Future<void> _startOrLoadExercise() async {
    final sessionId = _normalized(widget.sessionId);
    final subjectId = _normalized(widget.subjectId);
    final knowledgeUnitId = _normalized(widget.knowledgeUnitId);

    if (sessionId == null && (subjectId == null || knowledgeUnitId == null)) {
      return;
    }

    final future = sessionId != null
        ? _flowController.load(sessionId: sessionId)
        : _flowController.start(
            subjectId: subjectId!,
            knowledgeUnitId: knowledgeUnitId!,
            documentId: _normalized(widget.documentId),
          );
    setState(() {});
    await future;

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startFreshExercise() async {
    _resetControllers();
    await _startOrLoadExercise();
  }

  void _recordAnswer(RichClosedQuestion question, RichClosedAnswer? answer) {
    setState(() {
      _flowController.recordAnswer(question, answer);
    });
  }

  Future<void> _submit() async {
    final future = _flowController.submit();
    setState(() {});
    await future;

    if (mounted) {
      setState(() {});
    }
  }

  String _failureMessage(RichClosedExerciseFlowState state) {
    if (state.exercise == null) {
      return 'Impossible de charger les questions riches. Réessaie dans un instant.';
    }

    return 'Impossible de corriger les réponses. Réessaie dans un instant.';
  }

  String? _normalized(String? value) {
    final trimmedValue = value?.trim();
    return trimmedValue == null || trimmedValue.isEmpty ? null : trimmedValue;
  }
}

class _ReadyExercisePanel extends StatelessWidget {
  const _ReadyExercisePanel({
    required this.exercise,
    required this.state,
    required this.answerController,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseFlowState state;
  final RichClosedCoreAnswerController answerController;
  final void Function(RichClosedQuestion question, RichClosedAnswer? answer)
  onAnswerChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.isSubmitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevisionPanel(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                '${state.answeredCount} / ${state.totalQuestions} répondues',
              ),
              if (!state.canSubmit) ...[
                const SizedBox(height: AppSpacing.s),
                RevisionMessage(
                  message: 'Réponds à toutes les questions avant de valider.',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.info_outline,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        for (final question in exercise.questions) ...[
          RichClosedQuestionRenderer(
            question: question,
            controller: answerController,
            enabled: !isSubmitting,
            onChanged: (answer) => onAnswerChanged(question, answer),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        _SubmitBar(
          canSubmit: state.canSubmit,
          isSubmitting: isSubmitting,
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSubmitting) ...[
            RevisionMessage(
              message: 'Correction en cours...',
              color: Theme.of(context).colorScheme.secondary,
              icon: Icons.hourglass_top,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
          RevisionButton(
            label: 'Valider mes réponses',
            icon: Icons.check_circle_outline,
            onPressed: canSubmit && !isSubmitting ? onSubmit : null,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _CompletedExercisePanel extends StatelessWidget {
  const _CompletedExercisePanel({
    required this.exercise,
    required this.result,
    required this.onRestart,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichClosedCorrectionList(exercise: exercise, result: result),
        RevisionButton(
          label: 'Recommencer un exercice',
          icon: Icons.refresh,
          onPressed: onRestart,
        ),
      ],
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const RevisionPanel(
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _FailurePanel extends StatelessWidget {
  const _FailurePanel({
    required this.message,
    required this.canRetrySubmit,
    required this.onRetry,
  });

  final String message;
  final bool canRetrySubmit;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevisionMessage(
            message: message,
            color: Theme.of(context).colorScheme.error,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: AppSpacing.m),
          RevisionButton(
            label: canRetrySubmit ? 'Relancer la correction' : 'Réessayer',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _MissingContextPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RevisionPanel(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: RevisionMessage(
        message:
            'Sélectionne une notion depuis une matière pour démarrer des questions riches.',
        color: Theme.of(context).colorScheme.secondary,
        icon: Icons.info_outline,
      ),
    );
  }
}
