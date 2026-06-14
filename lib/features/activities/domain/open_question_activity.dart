class OpenQuestionActivity {
  const OpenQuestionActivity({
    required this.sessionId,
    required this.type,
    required this.version,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.question,
  });

  final String sessionId;
  final String type;
  final int? version;
  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final OpenQuestion question;
}

class OpenQuestion {
  const OpenQuestion({
    required this.id,
    required this.prompt,
    required this.instructions,
    required this.maxAnswerLength,
    this.sources = const [],
  });

  final String id;
  final String prompt;
  final String? instructions;
  final int maxAnswerLength;
  final List<OpenQuestionSource> sources;
}

class OpenQuestionSource {
  const OpenQuestionSource({
    required this.chunkId,
    required this.pageNumber,
    required this.index,
  });

  final String chunkId;
  final int? pageNumber;
  final int index;
}

class OpenAnswerSubmissionResult {
  const OpenAnswerSubmissionResult({
    required this.sessionId,
    required this.type,
    required this.status,
    required this.evaluation,
  });

  final String sessionId;
  final String type;
  final String status;
  final OpenAnswerEvaluation evaluation;
}

enum OpenAnswerEvaluationStatus { pending, ready, failed }

class OpenAnswerEvaluation {
  const OpenAnswerEvaluation({
    required this.id,
    required this.status,
    required this.score,
    required this.maxScore,
    required this.feedback,
    required this.modelAnswer,
    required this.advice,
    this.presentPoints = const [],
    this.missingPoints = const [],
    this.errors = const [],
    this.sources = const [],
  });

  final String id;
  final OpenAnswerEvaluationStatus status;
  final double? score;
  final double? maxScore;
  final String? feedback;
  final List<String> presentPoints;
  final List<String> missingPoints;
  final List<String> errors;
  final String? modelAnswer;
  final String? advice;
  final List<OpenAnswerCorrectionSource> sources;
}

class OpenAnswerCorrectionSource {
  const OpenAnswerCorrectionSource({
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
