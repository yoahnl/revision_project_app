class DiagnosticQuizActivity {
  const DiagnosticQuizActivity({
    required this.sessionId,
    required this.title,
    required this.questions,
    this.type = 'diagnostic_quiz',
    this.version,
    this.documentId,
    this.subjectId,
  });

  final String sessionId;
  final String type;
  final int? version;
  final String title;
  final String? documentId;
  final String? subjectId;
  final List<DiagnosticQuizQuestion> questions;
}

class DiagnosticQuizQuestion {
  const DiagnosticQuizQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
    this.knowledgeUnitId,
    this.difficulty,
    this.sources = const [],
  });

  final String id;
  final String? knowledgeUnitId;
  final String prompt;
  final String? difficulty;
  final List<DiagnosticQuizChoice> choices;
  final List<DiagnosticQuizSourceRef> sources;
}

class DiagnosticQuizChoice {
  const DiagnosticQuizChoice({required this.id, required this.label});

  final String id;
  final String label;
}

class DiagnosticQuizSourceRef {
  const DiagnosticQuizSourceRef({
    required this.chunkId,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final int? pageNumber;
  final int index;
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
    this.score,
    this.items = const [],
  });

  final int correctAnswers;
  final int totalQuestions;
  final double? score;
  final List<DiagnosticQuizCorrectionItem> items;
}

class DiagnosticQuizCorrectionItem {
  const DiagnosticQuizCorrectionItem({
    required this.questionId,
    required this.knowledgeUnitId,
    required this.prompt,
    required this.selectedChoiceId,
    required this.correctChoiceId,
    required this.isCorrect,
    required this.explanation,
    this.choiceFeedback = const [],
    this.sources = const [],
  });

  final String questionId;
  final String? knowledgeUnitId;
  final String prompt;
  final String selectedChoiceId;
  final String correctChoiceId;
  final bool isCorrect;
  final String explanation;
  final List<DiagnosticQuizChoiceFeedback> choiceFeedback;
  final List<DiagnosticQuizCorrectionSource> sources;
}

class DiagnosticQuizChoiceFeedback {
  const DiagnosticQuizChoiceFeedback({
    required this.choiceId,
    required this.feedback,
  });

  final String choiceId;
  final String feedback;
}

class DiagnosticQuizCorrectionSource {
  const DiagnosticQuizCorrectionSource({
    required this.chunkId,
    required this.text,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final String text;
  final int? pageNumber;
  final int index;
}
