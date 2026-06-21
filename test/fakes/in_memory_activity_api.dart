import 'package:Neralune/features/activities/application/activity_controller.dart';
import 'package:Neralune/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:Neralune/features/activities/domain/open_question_activity.dart';
import 'package:Neralune/features/activities/domain/rich_closed_exercise.dart';

import '../features/activities/fixtures/rich_closed_exercise_fixtures.dart';

class InMemoryActivityApi implements ActivityApi {
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  String? startedRichClosedSubjectId;
  String? startedRichClosedKnowledgeUnitId;
  String? startedRichClosedDocumentId;
  String? loadedRichClosedSessionId;
  String? submittedRichClosedSessionId;
  int startedDiagnosticQuizCount = 0;
  int startedOpenQuestionCount = 0;
  int startedRichClosedCount = 0;
  int submittedDiagnosticQuizCount = 0;
  int submittedRichClosedCount = 0;
  String? submittedDiagnosticSessionId;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  List<RichClosedAnswer>? submittedRichClosedAnswers;
  String? submittedOpenAnswerText;
  Object? submitDiagnosticQuizError;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    startedDiagnosticQuizCount += 1;

    return const DiagnosticQuizActivity(
      sessionId: 'session-1',
      title: 'Diagnostic rapide',
      questions: [
        DiagnosticQuizQuestion(
          id: 'question-1',
          prompt: 'Question test',
          choices: [
            DiagnosticQuizChoice(id: 'a', label: 'Reponse A'),
            DiagnosticQuizChoice(id: 'b', label: 'Reponse B'),
          ],
        ),
      ],
    );
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    submittedDiagnosticQuizCount += 1;
    submittedDiagnosticSessionId = sessionId;
    submittedAnswers = answers;
    final error = submitDiagnosticQuizError;
    if (error != null) {
      throw error;
    }

    return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    startedOpenQuestionSubjectId = subjectId;
    startedOpenQuestionKnowledgeUnitId = knowledgeUnitId;
    startedOpenQuestionCount += 1;

    return const OpenQuestionActivity(
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
    );
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    submittedOpenAnswerText = answerText;

    return const OpenAnswerSubmissionResult(
      sessionId: 'open-session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: OpenAnswerEvaluation(
        id: 'evaluation-1',
        status: OpenAnswerEvaluationStatus.ready,
        score: 16,
        maxScore: 20,
        feedback: 'Réponse solide.',
        presentPoints: ['Point présent'],
        missingPoints: ['Point manquant'],
        errors: [],
        modelAnswer: 'Réponse modèle.',
        advice: 'Conseil de révision.',
        sources: [],
      ),
    );
  }

  @override
  Future<RichClosedExercise> startRichClosedExercise({
    required String subjectId,
    required String knowledgeUnitId,
    String? documentId,
    int questionCount = 6,
    RichClosedComplexityProfile complexityProfile =
        RichClosedComplexityProfile.exam,
    Map<RichClosedQuestionKind, int>? questionTypeMix,
  }) async {
    startedRichClosedSubjectId = subjectId;
    startedRichClosedKnowledgeUnitId = knowledgeUnitId;
    startedRichClosedDocumentId = documentId;
    startedRichClosedCount += 1;

    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    loadedRichClosedSessionId = sessionId;

    return RichClosedExercise.fromJson(richClosedExerciseJson());
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submittedRichClosedSessionId = sessionId;
    submittedRichClosedAnswers = answers;
    submittedRichClosedCount += 1;

    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return RichClosedExerciseResult.fromJson(richClosedResultJson());
  }
}
