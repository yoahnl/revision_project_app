import '../domain/revision_session.dart';

enum RevisionSessionPreferredAction {
  diagnosticQuiz,
  openQuestion,
  richClosedExercise,
}

abstract interface class RevisionSessionsApi {
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  });

  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  });
}
