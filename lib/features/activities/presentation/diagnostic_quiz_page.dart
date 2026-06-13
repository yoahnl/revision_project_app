import 'package:flutter/material.dart';

import '../domain/diagnostic_quiz_activity.dart';

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
        const SizedBox(height: 16),
        for (final question in widget.activity.questions) ...[
          Text(question.prompt, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final choice in question.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton.icon(
                onPressed: result == null
                    ? () => _selectChoice(question.id, choice.id)
                    : null,
                icon: Icon(
                  _selectedChoiceIdsByQuestion[question.id] == choice.id
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                ),
                label: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(choice.label),
                ),
              ),
            ),
          const SizedBox(height: 16),
        ],
        if (result != null) ...[
          Text(
            'Score ${result.correctAnswers} / ${result.totalQuestions}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _canSubmit ? _submit : null,
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Valider'),
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
