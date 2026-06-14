import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';
import '../domain/open_question_activity.dart';

class DemoActivityApi implements ActivityApi {
  static const DiagnosticQuizActivity _activity = DiagnosticQuizActivity(
    sessionId: 'demo-session-1',
    title: 'Diagnostic rapide',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-1',
        prompt:
            'Quelle structure est principalement responsable de la contraction cardiaque ?',
        choices: [
          DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
          DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
        ],
      ),
    ],
  );

  static const OpenQuestionActivity _openQuestionActivity =
      OpenQuestionActivity(
        sessionId: 'demo-open-session-1',
        type: 'open_question',
        version: 1,
        subjectId: 'demo-subject',
        documentId: null,
        knowledgeUnitId: 'demo-unit',
        question: OpenQuestion(
          id: 'demo-open-question-1',
          prompt:
              'Explique avec tes mots le point principal de cette notion.',
          instructions: 'Réponds en quelques phrases structurées.',
          maxAnswerLength: 4000,
        ),
      );

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    return _activity;
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) async {
    final correctAnswers = answers.where((answer) {
      return answer.questionId == 'question-1' && answer.choiceId == 'a';
    }).length;

    return DiagnosticQuizResult(
      correctAnswers: correctAnswers,
      totalQuestions: _activity.questions.length,
    );
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    return _openQuestionActivity;
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    return const OpenAnswerSubmissionResult(
      sessionId: 'demo-open-session-1',
      type: 'open_question',
      status: 'submitted',
      evaluation: OpenAnswerEvaluation(
        id: 'demo-open-evaluation-1',
        status: OpenAnswerEvaluationStatus.ready,
        score: 14,
        maxScore: 20,
        feedback: 'Réponse claire pour une démonstration locale.',
        presentPoints: ['Idée principale identifiée'],
        missingPoints: ['Exemple précis à ajouter'],
        errors: [],
        modelAnswer: 'Une réponse complète définit la notion et l’illustre.',
        advice: 'Ajoute un exemple issu du cours.',
        sources: [],
      ),
    );
  }
}
