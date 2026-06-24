import '../../activities/domain/diagnostic_quiz_activity.dart';
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

  Future<RevisionSessionResponse> getExamPreparationSession({
    required String sessionId,
  });

  Future<RevisionSessionResult> submitExamPreparationSession({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  });

  Future<RevisionSessionResult> getExamPreparationSessionResult({
    required String sessionId,
  });

  Future<RevisionSessionResult> completeRevisionSession({
    required String sessionId,
  });

  Future<RevisionSessionResult> getRevisionSessionResult({
    required String sessionId,
  });

  Future<RevisionSessionResponse> saveDraftAnswer({
    required String sessionId,
    required String questionId,
    required List<String> selectedChoiceIds,
  });

  Future<RevisionSessionResponse> deleteDraftAnswer({
    required String sessionId,
    required String questionId,
  });

  Future<void> flagRevisionSessionQuestion({
    required String sessionId,
    required String questionId,
    String? reason,
  });
}

class RevisionSessionNotFoundException implements Exception {
  const RevisionSessionNotFoundException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RevisionSessionResultNotReadyException implements Exception {
  const RevisionSessionResultNotReadyException(this.message);

  final String message;

  @override
  String toString() => message;
}
