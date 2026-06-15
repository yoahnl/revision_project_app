import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:revision_app/features/revision_sessions/domain/revision_session.dart';

class InMemoryRevisionSessionsApi implements RevisionSessionsApi {
  String? startedSubjectId;
  String? startedDocumentId;
  String? startedKnowledgeUnitId;
  RevisionSessionPreferredAction? startedPreferredAction;
  String? loadedSessionId;
  int startCount = 0;
  int loadCount = 0;
  Object? startError;
  Object? loadError;
  RevisionSessionResponse startResponse = openQuestionRevisionSessionResponse();
  RevisionSessionResponse loadResponse = minimalRevisionSessionResponse();

  @override
  Future<RevisionSessionResponse> startRevisionSession({
    required String subjectId,
    String? documentId,
    String? knowledgeUnitId,
    RevisionSessionPreferredAction? preferredAction,
  }) async {
    startCount += 1;
    startedSubjectId = subjectId;
    startedDocumentId = documentId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedPreferredAction = preferredAction;
    final error = startError;
    if (error != null) {
      throw error;
    }
    return startResponse;
  }

  @override
  Future<RevisionSessionResponse> getRevisionSession({
    required String sessionId,
  }) async {
    loadCount += 1;
    loadedSessionId = sessionId;
    final error = loadError;
    if (error != null) {
      throw error;
    }
    return loadResponse;
  }
}

RevisionSessionResponse diagnosticQuizRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: null,
      knowledgeUnitId: null,
      payload: const RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'QCM de session',
          subjectId: 'subject-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Question test',
              choices: [
                DiagnosticQuizChoice(id: 'choice-1', label: 'Réponse A'),
                DiagnosticQuizChoice(id: 'choice-2', label: 'Réponse B'),
              ],
            ),
          ],
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-quiz-1',
        kind: RevisionSessionActionKind.diagnosticQuiz,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'quiz-session-1',
        documentId: null,
        knowledgeUnitId: null,
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse openQuestionRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: RevisionSessionAction(
      id: 'action-open-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: const RevisionSessionOpenQuestionPayload(
        OpenQuestionActivity(
          sessionId: 'open-session-1',
          type: 'open_question',
          version: 1,
          subjectId: 'subject-1',
          documentId: null,
          knowledgeUnitId: 'unit-1',
          question: OpenQuestion(
            id: 'open-question-1',
            prompt: 'Question ouverte test',
            instructions: 'Réponds en quelques phrases.',
            maxAnswerLength: 4000,
          ),
        ),
      ),
    ),
    history: [
      RevisionSessionAction(
        id: 'action-open-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse minimalRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(),
    currentAction: const RevisionSessionAction(
      id: 'action-minimal-1',
      kind: RevisionSessionActionKind.openQuestion,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'open-session-1',
      documentId: null,
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionMinimalPayload(
        type: 'open_question',
        sessionId: 'open-session-1',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-minimal-1',
        kind: RevisionSessionActionKind.openQuestion,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'open-session-1',
        documentId: null,
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSession revisionSession({String? knowledgeUnitId}) {
  return RevisionSession(
    id: 'revision-session-1',
    status: RevisionSessionStatus.started,
    subjectId: 'subject-1',
    documentId: null,
    knowledgeUnitId: knowledgeUnitId,
    createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
    completedAt: null,
  );
}
