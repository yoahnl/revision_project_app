class DiagnosticQuizActivity {
  const DiagnosticQuizActivity({
    required this.sessionId,
    required this.title,
    required this.questions,
  });

  final String sessionId;
  final String title;
  final List<DiagnosticQuizQuestion> questions;
}

class DiagnosticQuizQuestion {
  const DiagnosticQuizQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
  });

  final String id;
  final String prompt;
  final List<DiagnosticQuizChoice> choices;
}

class DiagnosticQuizChoice {
  const DiagnosticQuizChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class DiagnosticQuizAnswer {
  const DiagnosticQuizAnswer({
    required this.questionId,
    required this.choiceId,
  });

  final String questionId;
  final String choiceId;
}

class DiagnosticQuizResult {
  const DiagnosticQuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
  });

  final int correctAnswers;
  final int totalQuestions;
}
