import 'package:flutter/material.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/presentation/theme/app_spacing.dart';
import 'package:revision_app/presentation/widgets/revision_button.dart';
import 'package:revision_app/presentation/widgets/revision_choice_tile.dart';
import 'package:revision_app/presentation/widgets/revision_status_pill.dart';

typedef DiagnosticQuizSubmitter =
    Future<DiagnosticQuizResult> Function(List<DiagnosticQuizAnswer> answers);

class DiagnosticQuizPage extends StatefulWidget {
  const DiagnosticQuizPage({required this.activity, this.onSubmit, super.key});

  final DiagnosticQuizActivity activity;
  final DiagnosticQuizSubmitter? onSubmit;

  @override
  State<DiagnosticQuizPage> createState() => _DiagnosticQuizPageState();
}

class _DiagnosticQuizPageState extends State<DiagnosticQuizPage> {
  final Map<String, String> _selectedChoiceIdsByQuestion = {};
  DiagnosticQuizResult? _result;
  bool _isSubmitting = false;
  bool get _canSubmit {
    return widget.onSubmit != null &&
        !_isSubmitting &&
        widget.activity.questions.isNotEmpty &&
        _selectedChoiceIdsByQuestion.length == widget.activity.questions.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activity.questions.isEmpty) {
      return const Center(child: Text('Aucune question disponible'));
    }

    final result = _result;

    return ListView(
      children: [
        Text(
          widget.activity.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.l),
        for (final question in widget.activity.questions) ...[
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.m),
          for (final choice in question.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: RevisionChoiceTile(
                label: choice.label,
                selected:
                    _selectedChoiceIdsByQuestion[question.id] == choice.id,
                enabled: result == null,
                onTap: () => _selectChoice(question.id, choice.id),
              ),
            ),
          const SizedBox(height: AppSpacing.l),
        ],
        if (result != null) ...[
          RevisionStatusPill(
            label: 'Score ${result.correctAnswers} / ${result.totalQuestions}',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: RevisionButton(
            onPressed: _canSubmit ? _submit : null,
            icon: Icons.check,
            label: _isSubmitting ? 'Validation...' : 'Valider',
          ),
        ),
      ],
    );
  }

  void _selectChoice(String questionId, String choiceId) {
    setState(() {
      _selectedChoiceIdsByQuestion[questionId] = choiceId;
    });
  }

  Future<void> _submit() async {
    final submitter = widget.onSubmit;
    if (submitter == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final answers = widget.activity.questions
          .map((question) {
            return DiagnosticQuizAnswer(
              questionId: question.id,
              choiceId: _selectedChoiceIdsByQuestion[question.id]!,
            );
          })
          .toList(growable: false);
      final result = await submitter(answers);

      if (mounted) {
        setState(() {
          _result = result;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
