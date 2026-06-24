import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/activities/domain/open_question_activity.dart';
import 'package:Neralune/features/revision_sessions/data/revision_sessions_api.dart';
import 'package:Neralune/features/revision_sessions/domain/revision_session.dart';

class InMemoryRevisionSessionsApi implements RevisionSessionsApi {
  String? startedSubjectId;
  String? startedDocumentId;
  String? startedKnowledgeUnitId;
  RevisionSessionPreferredAction? startedPreferredAction;
  String? loadedSessionId;
  String? loadedExamSessionId;
  String? completedSessionId;
  String? submittedExamSessionId;
  String? loadedResultSessionId;
  String? loadedExamResultSessionId;
  List<DiagnosticQuizAnswer>? submittedExamAnswers;
  String? flaggedSessionId;
  String? flaggedQuestionId;
  String? flaggedReason;
  String? savedDraftSessionId;
  String? savedDraftQuestionId;
  List<String>? savedDraftChoiceIds;
  String? deletedDraftSessionId;
  String? deletedDraftQuestionId;
  int startCount = 0;
  int loadCount = 0;
  int loadExamCount = 0;
  int completeCount = 0;
  int submitExamCount = 0;
  int loadResultCount = 0;
  int loadExamResultCount = 0;
  int flagCount = 0;
  int saveDraftCount = 0;
  int deleteDraftCount = 0;
  Object? startError;
  Object? loadError;
  Object? loadExamError;
  Object? completeError;
  Object? submitExamError;
  Object? loadResultError;
  Object? loadExamResultError;
  Object? flagError;
  Object? saveDraftError;
  Object? deleteDraftError;
  RevisionSessionResponse startResponse = openQuestionRevisionSessionResponse();
  RevisionSessionResponse loadResponse = minimalRevisionSessionResponse();
  RevisionSessionResponse examLoadResponse = examRevisionSessionResponse();
  RevisionSessionResponse? saveDraftResponse;
  RevisionSessionResponse? deleteDraftResponse;
  RevisionSessionResult completeResponse = revisionSessionResult();
  RevisionSessionResult submitExamResponse = examRevisionSessionResult();
  RevisionSessionResult resultResponse = revisionSessionResult();
  RevisionSessionResult examResultResponse = examRevisionSessionResult();

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

  @override
  Future<RevisionSessionResponse> getExamPreparationSession({
    required String sessionId,
  }) async {
    loadExamCount += 1;
    loadedExamSessionId = sessionId;
    final error = loadExamError;
    if (error != null) {
      throw error;
    }
    return examLoadResponse;
  }

  @override
  Future<RevisionSessionResult> submitExamPreparationSession({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    submitExamCount += 1;
    submittedExamSessionId = sessionId;
    submittedExamAnswers = answers;
    final error = submitExamError;
    if (error != null) {
      throw error;
    }
    return submitExamResponse;
  }

  @override
  Future<RevisionSessionResult> getExamPreparationSessionResult({
    required String sessionId,
  }) async {
    loadExamResultCount += 1;
    loadedExamResultSessionId = sessionId;
    final error = loadExamResultError;
    if (error != null) {
      throw error;
    }
    return examResultResponse;
  }

  @override
  Future<RevisionSessionResult> completeRevisionSession({
    required String sessionId,
  }) async {
    completeCount += 1;
    completedSessionId = sessionId;
    final error = completeError;
    if (error != null) {
      throw error;
    }
    return completeResponse;
  }

  @override
  Future<RevisionSessionResult> getRevisionSessionResult({
    required String sessionId,
  }) async {
    loadResultCount += 1;
    loadedResultSessionId = sessionId;
    final error = loadResultError;
    if (error != null) {
      throw error;
    }
    return resultResponse;
  }

  @override
  Future<RevisionSessionResponse> saveDraftAnswer({
    required String sessionId,
    required String questionId,
    required List<String> selectedChoiceIds,
  }) async {
    saveDraftCount += 1;
    savedDraftSessionId = sessionId;
    savedDraftQuestionId = questionId;
    savedDraftChoiceIds = selectedChoiceIds;
    final error = saveDraftError;
    if (error != null) {
      throw error;
    }
    return saveDraftResponse ?? loadResponse;
  }

  @override
  Future<RevisionSessionResponse> deleteDraftAnswer({
    required String sessionId,
    required String questionId,
  }) async {
    deleteDraftCount += 1;
    deletedDraftSessionId = sessionId;
    deletedDraftQuestionId = questionId;
    final error = deleteDraftError;
    if (error != null) {
      throw error;
    }
    return deleteDraftResponse ?? loadResponse;
  }

  @override
  Future<void> flagRevisionSessionQuestion({
    required String sessionId,
    required String questionId,
    String? reason,
  }) async {
    flagCount += 1;
    flaggedSessionId = sessionId;
    flaggedQuestionId = questionId;
    flaggedReason = reason;
    final error = flagError;
    if (error != null) {
      throw error;
    }
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

RevisionSessionResponse courseQuickRevisionSessionResponse({
  String courseId = 'course-1',
}) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'revision-session-1',
      status: RevisionSessionStatus.started,
      mode: RevisionSessionMode.quick,
      subjectId: 'subject-1',
      courseId: courseId,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: null,
    ),
    currentAction: const RevisionSessionAction(
      id: 'action-quiz-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'quiz-session-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'quiz-session-1',
          title: 'Révision rapide réelle',
          subjectId: 'subject-1',
          documentId: 'document-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Quel principe organise les pouvoirs ?',
              knowledgeUnitId: 'unit-1',
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-1',
                  label: 'La séparation des pouvoirs',
                ),
                DiagnosticQuizChoice(
                  id: 'choice-2',
                  label: 'La confusion des pouvoirs',
                ),
              ],
            ),
            DiagnosticQuizQuestion(
              id: 'question-2',
              prompt: 'Quelle institution vote la loi ?',
              knowledgeUnitId: 'unit-1',
              choices: [
                DiagnosticQuizChoice(id: 'choice-3', label: 'Le Parlement'),
                DiagnosticQuizChoice(id: 'choice-4', label: 'Le Préfet'),
              ],
            ),
          ],
        ),
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-quiz-1',
        kind: RevisionSessionActionKind.diagnosticQuiz,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: 'quiz-session-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        payload: null,
      ),
    ],
  );
}

RevisionSessionResponse examRevisionSessionResponse({
  String courseId = 'course-1',
}) {
  return RevisionSessionResponse(
    session: RevisionSession(
      id: 'exam-session-1',
      status: RevisionSessionStatus.started,
      mode: RevisionSessionMode.exam,
      subjectId: 'subject-1',
      courseId: courseId,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: null,
    ),
    currentAction: const RevisionSessionAction(
      id: 'action-exam-1',
      kind: RevisionSessionActionKind.diagnosticQuiz,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: 'activity-exam-1',
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionDiagnosticQuizPayload(
        DiagnosticQuizActivity(
          sessionId: 'activity-exam-1',
          title: 'Préparation examen',
          subjectId: 'subject-1',
          documentId: 'document-1',
          questions: [
            DiagnosticQuizQuestion(
              id: 'question-1',
              prompt: 'Quel principe organise les pouvoirs ?',
              knowledgeUnitId: 'unit-1',
              choices: [
                DiagnosticQuizChoice(
                  id: 'choice-1',
                  label: 'La séparation des pouvoirs',
                ),
                DiagnosticQuizChoice(id: 'choice-2', label: 'Le hasard'),
              ],
            ),
          ],
        ),
      ),
    ),
    history: const [],
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

RevisionSessionResponse richClosedRevisionSessionResponse() {
  return RevisionSessionResponse(
    session: revisionSession(knowledgeUnitId: 'unit-1'),
    currentAction: const RevisionSessionAction(
      id: 'action-rich-1',
      kind: RevisionSessionActionKind.richClosedExercise,
      status: RevisionSessionActionStatus.ready,
      displayOrder: 0,
      activitySessionId: null,
      documentId: 'document-1',
      knowledgeUnitId: 'unit-1',
      payload: RevisionSessionRichClosedExercisePayload(
        subjectId: 'subject-1',
        documentId: 'document-1',
        knowledgeUnitId: 'unit-1',
        knowledgeUnitTitle: 'Institutions politiques',
        reason: 'Questions riches recommandées.',
        estimatedMinutes: 8,
        preferredAction: 'rich_closed_exercise',
      ),
    ),
    history: const [
      RevisionSessionAction(
        id: 'action-rich-1',
        kind: RevisionSessionActionKind.richClosedExercise,
        status: RevisionSessionActionStatus.ready,
        displayOrder: 0,
        activitySessionId: null,
        documentId: 'document-1',
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
    mode: RevisionSessionMode.quick,
    subjectId: 'subject-1',
    courseId: null,
    documentId: null,
    knowledgeUnitId: knowledgeUnitId,
    createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
    completedAt: null,
  );
}

RevisionSessionResult revisionSessionResult() {
  return RevisionSessionResult(
    session: RevisionSessionResultSession(
      id: 'revision-session-1',
      subjectId: 'subject-1',
      courseId: 'course-1',
      mode: RevisionSessionMode.quick,
      status: RevisionSessionStatus.completed,
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: DateTime.parse('2026-06-15T12:04:12.000Z'),
    ),
    summary: const RevisionSessionResultSummary(
      correctAnswers: 4,
      totalQuestions: 6,
      score: 4 / 6,
      durationSeconds: 252,
    ),
    knowledgeUnits: const [
      RevisionSessionKnowledgeUnitResult(
        knowledgeUnitId: 'unit-1',
        title: 'Séparation des pouvoirs',
        correctAnswers: 4,
        totalQuestions: 6,
        score: 4 / 6,
        state: RevisionSessionKnowledgeUnitResultState.toReview,
      ),
    ],
    corrections: const [
      RevisionSessionQuestionCorrection(
        prompt: 'Quelle institution vote la loi ?',
        isCorrect: false,
        selectedAnswers: ['Le préfet'],
        correctAnswers: ['Le Parlement'],
        explanation: 'Le Parlement vote la loi dans ce régime.',
      ),
    ],
  );
}

RevisionSessionResult examRevisionSessionResult() {
  return RevisionSessionResult(
    session: RevisionSessionResultSession(
      id: 'exam-session-1',
      subjectId: 'subject-1',
      courseId: 'course-1',
      mode: RevisionSessionMode.exam,
      status: RevisionSessionStatus.completed,
      createdAt: DateTime.parse('2026-06-15T12:00:00.000Z'),
      completedAt: DateTime.parse('2026-06-15T12:05:00.000Z'),
    ),
    summary: const RevisionSessionResultSummary(
      correctAnswers: 1,
      totalQuestions: 1,
      score: 1,
      durationSeconds: 300,
    ),
    knowledgeUnits: const [
      RevisionSessionKnowledgeUnitResult(
        knowledgeUnitId: 'unit-1',
        title: 'Séparation des pouvoirs',
        correctAnswers: 1,
        totalQuestions: 1,
        score: 1,
        state: RevisionSessionKnowledgeUnitResultState.mastered,
      ),
    ],
    corrections: const [
      RevisionSessionQuestionCorrection(
        prompt: 'Quel principe organise les pouvoirs ?',
        isCorrect: true,
        selectedAnswers: ['La séparation des pouvoirs'],
        correctAnswers: ['La séparation des pouvoirs'],
        explanation: 'La séparation des pouvoirs structure le régime.',
      ),
    ],
  );
}
