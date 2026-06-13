import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';

class FakeActivityApi implements ActivityApi {
  String? startedSubjectId;
  List<DiagnosticQuizAnswer>? submittedAnswers;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) async {
    startedSubjectId = subjectId;

    return const DiagnosticQuizActivity(
      sessionId: 'session-1',
      title: 'Diagnostic rapide',
      questions: [
        DiagnosticQuizQuestion(
          id: 'question-1',
          prompt: 'Quelle structure contractile propulse le sang ?',
          choices: [
            DiagnosticQuizChoice(id: 'a', label: 'Myocarde'),
            DiagnosticQuizChoice(id: 'b', label: 'Pericarde'),
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
    submittedAnswers = answers;

    return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
  }
}

void main() {
  test('loads the next diagnostic activity', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final activity = await controller.startNextActivity(
      subjectId: ' subject-1 ',
    );

    expect(activity.sessionId, 'session-1');
    expect(activity.questions.single.choices, hasLength(2));
    expect(api.startedSubjectId, 'subject-1');
  });

  test('submits selected answers to the activity api', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final result = await controller.submitResult(
      sessionId: 'session-1',
      answers: const [
        DiagnosticQuizAnswer(questionId: 'question-1', choiceId: 'a'),
      ],
    );

    expect(api.submittedAnswers, hasLength(1));
    expect(api.submittedAnswers?.single.choiceId, 'a');
    expect(result.correctAnswers, 1);
  });
}
