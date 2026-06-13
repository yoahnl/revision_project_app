import '../application/activity_controller.dart';
import '../domain/diagnostic_quiz_activity.dart';

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
}
