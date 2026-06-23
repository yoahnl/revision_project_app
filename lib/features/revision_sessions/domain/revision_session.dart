import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';

class RevisionSession {
  const RevisionSession({
    required this.id,
    required this.status,
    required this.mode,
    required this.subjectId,
    required this.courseId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final RevisionSessionStatus status;
  final RevisionSessionMode mode;
  final String subjectId;
  final String? courseId;
  final String? documentId;
  final String? knowledgeUnitId;
  final DateTime createdAt;
  final DateTime? completedAt;
}

enum RevisionSessionStatus { started, completed, abandoned, unknown }

enum RevisionSessionMode { quick, deep, exam, unknown }

class RevisionSessionAction {
  const RevisionSessionAction({
    required this.id,
    required this.kind,
    required this.status,
    required this.displayOrder,
    required this.activitySessionId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.payload,
  });

  final String id;
  final RevisionSessionActionKind kind;
  final RevisionSessionActionStatus status;
  final int displayOrder;
  final String? activitySessionId;
  final String? documentId;
  final String? knowledgeUnitId;
  final RevisionSessionActionPayload? payload;
}

enum RevisionSessionActionKind {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
  unknown,
}

enum RevisionSessionActionStatus { ready, completed, failed, unknown }

class RevisionSessionResponse {
  const RevisionSessionResponse({
    required this.session,
    required this.currentAction,
    required this.history,
    this.draftAnswers = const [],
  });

  final RevisionSession session;
  final RevisionSessionAction? currentAction;
  final List<RevisionSessionAction> history;
  final List<RevisionSessionDraftAnswer> draftAnswers;
}

class RevisionSessionDraftAnswer {
  const RevisionSessionDraftAnswer({
    required this.questionId,
    required this.selectedChoiceIds,
    required this.updatedAt,
  });

  final String questionId;
  final List<String> selectedChoiceIds;
  final DateTime updatedAt;
}

class ResumableCourseRevisionSession {
  const ResumableCourseRevisionSession({
    required this.session,
    required this.currentAction,
    required this.progress,
    required this.userMessage,
  });

  final RevisionSession session;
  final RevisionSessionAction? currentAction;
  final ResumableCourseRevisionProgress progress;
  final String userMessage;
}

class ResumableCourseRevisionProgress {
  const ResumableCourseRevisionProgress({
    required this.answeredQuestionCount,
    required this.totalQuestionCount,
  });

  final int answeredQuestionCount;
  final int totalQuestionCount;
}

sealed class RevisionSessionActionPayload {
  const RevisionSessionActionPayload();
}

class RevisionSessionDiagnosticQuizPayload
    extends RevisionSessionActionPayload {
  const RevisionSessionDiagnosticQuizPayload(this.activity);

  final DiagnosticQuizActivity activity;
}

class RevisionSessionOpenQuestionPayload extends RevisionSessionActionPayload {
  const RevisionSessionOpenQuestionPayload(this.activity);

  final OpenQuestionActivity activity;
}

class RevisionSessionRichClosedExercisePayload
    extends RevisionSessionActionPayload {
  const RevisionSessionRichClosedExercisePayload({
    required this.subjectId,
    required this.knowledgeUnitId,
    required this.reason,
    required this.estimatedMinutes,
    this.documentId,
    this.knowledgeUnitTitle,
    this.preferredAction,
  });

  final String subjectId;
  final String? documentId;
  final String knowledgeUnitId;
  final String? knowledgeUnitTitle;
  final String reason;
  final int estimatedMinutes;
  final String? preferredAction;
}

class RevisionSessionMinimalPayload extends RevisionSessionActionPayload {
  const RevisionSessionMinimalPayload({required this.type, this.sessionId});

  final String type;
  final String? sessionId;
}

class RevisionSessionUnknownPayload extends RevisionSessionActionPayload {
  const RevisionSessionUnknownPayload();
}

class RevisionSessionResult {
  const RevisionSessionResult({
    required this.session,
    required this.summary,
    required this.knowledgeUnits,
    this.corrections = const [],
  });

  final RevisionSessionResultSession session;
  final RevisionSessionResultSummary summary;
  final List<RevisionSessionKnowledgeUnitResult> knowledgeUnits;
  final List<RevisionSessionQuestionCorrection> corrections;
}

class RevisionSessionHistoryResponse {
  const RevisionSessionHistoryResponse({required this.items});

  final List<RevisionSessionHistoryItem> items;
}

class RevisionSessionHistoryItem {
  const RevisionSessionHistoryItem({
    required this.session,
    required this.summary,
    required this.course,
  });

  final RevisionSessionResultSession session;
  final RevisionSessionResultSummary summary;
  final RevisionSessionHistoryCourse course;
}

class RevisionSessionHistoryCourse {
  const RevisionSessionHistoryCourse({required this.id, required this.title});

  final String id;
  final String title;
}

class RevisionSessionQuestionCorrection {
  const RevisionSessionQuestionCorrection({
    required this.prompt,
    required this.isCorrect,
    required this.selectedAnswers,
    required this.correctAnswers,
    required this.explanation,
  });

  final String prompt;
  final bool isCorrect;
  final List<String> selectedAnswers;
  final List<String> correctAnswers;
  final String? explanation;
}

class RevisionSessionResultSession {
  const RevisionSessionResultSession({
    required this.id,
    required this.subjectId,
    required this.mode,
    required this.status,
    required this.createdAt,
    required this.completedAt,
    this.courseId,
  });

  final String id;
  final String subjectId;
  final String? courseId;
  final RevisionSessionMode mode;
  final RevisionSessionStatus status;
  final DateTime createdAt;
  final DateTime completedAt;
}

class RevisionSessionResultSummary {
  const RevisionSessionResultSummary({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.durationSeconds,
  });

  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final int durationSeconds;
}

class RevisionSessionKnowledgeUnitResult {
  const RevisionSessionKnowledgeUnitResult({
    required this.knowledgeUnitId,
    required this.title,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.state,
  });

  final String knowledgeUnitId;
  final String title;
  final int correctAnswers;
  final int totalQuestions;
  final double score;
  final RevisionSessionKnowledgeUnitResultState state;
}

enum RevisionSessionKnowledgeUnitResultState { mastered, toReview, unknown }
