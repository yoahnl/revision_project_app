import '../data/revision_sessions_api.dart';
import '../domain/revision_session.dart';

class RevisionSessionController {
  const RevisionSessionController(this._api);

  final RevisionSessionsApi _api;

  Future<RevisionSessionResponse> startSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) {
    final trimmedSubjectId = subjectId.trim();
    final trimmedDocumentId = _trimOptionalId(documentId);
    final trimmedKnowledgeUnitId = _trimOptionalId(knowledgeUnitId);

    if (trimmedSubjectId.isEmpty) {
      throw ArgumentError('Subject id is required');
    }

    return _api.startRevisionSession(
      subjectId: trimmedSubjectId,
      documentId: trimmedDocumentId,
      knowledgeUnitId: trimmedKnowledgeUnitId,
      preferredAction: preferredAction,
    );
  }

  Future<RevisionSessionResponse> loadSession({required String sessionId}) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Revision session id is required');
    }

    return _api.getRevisionSession(sessionId: trimmedSessionId);
  }

  Future<RevisionSessionResult> completeSession({required String sessionId}) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Revision session id is required');
    }

    return _api.completeRevisionSession(sessionId: trimmedSessionId);
  }

  Future<RevisionSessionResult> loadResult({required String sessionId}) {
    final trimmedSessionId = sessionId.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Revision session id is required');
    }

    return _api.getRevisionSessionResult(sessionId: trimmedSessionId);
  }

  Future<void> flagQuestion({
    required String sessionId,
    required String questionId,
    String? reason,
  }) {
    final trimmedSessionId = sessionId.trim();
    final trimmedQuestionId = questionId.trim();
    final trimmedReason = reason?.trim();

    if (trimmedSessionId.isEmpty) {
      throw ArgumentError('Revision session id is required');
    }

    if (trimmedQuestionId.isEmpty) {
      throw ArgumentError('Question id is required');
    }

    return _api.flagRevisionSessionQuestion(
      sessionId: trimmedSessionId,
      questionId: trimmedQuestionId,
      reason: trimmedReason == null || trimmedReason.isEmpty
          ? null
          : trimmedReason,
    );
  }

  String? _trimOptionalId(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
