import '../../activities/domain/diagnostic_quiz_activity.dart';
import '../../activities/domain/open_question_activity.dart';

class RevisionSession {
  const RevisionSession({
    required this.id,
    required this.status,
    required this.subjectId,
    required this.documentId,
    required this.knowledgeUnitId,
    required this.createdAt,
    required this.completedAt,
  });

  final String id;
  final RevisionSessionStatus status;
  final String subjectId;
  final String? documentId;
  final String? knowledgeUnitId;
  final DateTime createdAt;
  final DateTime? completedAt;
}

enum RevisionSessionStatus { started, completed, abandoned, unknown }

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
  });

  final RevisionSession session;
  final RevisionSessionAction? currentAction;
  final List<RevisionSessionAction> history;
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
