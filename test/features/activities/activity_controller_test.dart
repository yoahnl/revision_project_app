import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';

class FakeActivityApi implements ActivityApi {
  String? startedSubjectId;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  int submitCallCount = 0;
  Completer<DiagnosticQuizResult>? submitCompleter;
  Object? submitError;

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
    submitCallCount += 1;
    submittedAnswers = answers;

    if (submitError != null) {
      throw submitError!;
    }

    final completer = submitCompleter;
    if (completer != null) {
      return completer.future;
    }

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

  test('manages selected answers and enriched correction state', () async {
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 2),
      submitter: (answers) async {
        return DiagnosticQuizResult(
          correctAnswers: 1,
          totalQuestions: 2,
          score: 0.5,
          items: [
            DiagnosticQuizCorrectionItem(
              questionId: 'question-1',
              knowledgeUnitId: 'unit-1',
              prompt: 'Question 1',
              selectedChoiceId: 'a',
              correctChoiceId: 'b',
              isCorrect: false,
              explanation: 'Explication sourcée.',
              choiceFeedback: const [
                DiagnosticQuizChoiceFeedback(
                  choiceId: 'a',
                  feedback: 'Distracteur plausible.',
                ),
              ],
              sources: const [
                DiagnosticQuizCorrectionSource(
                  chunkId: 'chunk-1',
                  text: 'Source après submit.',
                  pageNumber: null,
                  index: 0,
                ),
              ],
            ),
          ],
        );
      },
    );

    expect(controller.result, isNull);
    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-1', choiceId: 'a');
    controller.selectChoice(questionId: 'question-1', choiceId: 'b');
    controller.selectChoice(questionId: 'question-2', choiceId: 'a');

    expect(controller.selectedChoiceIdFor('question-1'), 'b');
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(controller.result?.score, 0.5);
    expect(controller.result?.items.single.explanation, 'Explication sourcée.');
  });

  test('manages multiple selections and submits choiceIds', () async {
    List<DiagnosticQuizAnswer>? submittedAnswers;
    final controller = DiagnosticQuizSessionController(
      activity: multipleActivity(),
      submitter: (answers) async {
        submittedAnswers = answers;

        return const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1);
      },
    );

    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');
    controller.selectChoice(questionId: 'question-multiple', choiceId: 'c');
    controller.selectChoice(questionId: 'question-multiple', choiceId: 'b');

    expect(controller.selectedChoiceIdsFor('question-multiple'), ['a', 'c']);
    expect(controller.canSubmit, isTrue);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');

    expect(controller.selectedChoiceIdsFor('question-multiple'), ['c']);
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(submittedAnswers?.single.choiceId, isNull);
    expect(submittedAnswers?.single.choiceIds, ['c']);
  });

  test('requires the minimum selection count for multiple questions', () async {
    final controller = DiagnosticQuizSessionController(
      activity: multipleActivity(minSelections: 2, maxSelections: 3),
      submitter: (_) async =>
          const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1),
    );

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'a');

    expect(controller.answeredCount, 0);
    expect(controller.canSubmit, isFalse);

    controller.selectChoice(questionId: 'question-multiple', choiceId: 'c');

    expect(controller.answeredCount, 1);
    expect(controller.canSubmit, isTrue);
  });

  test('prevents duplicate submit while a submission is running', () async {
    final completer = Completer<DiagnosticQuizResult>();
    var submitCount = 0;
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 1),
      submitter: (answers) {
        submitCount += 1;
        return completer.future;
      },
    );

    controller.selectChoice(questionId: 'question-1', choiceId: 'a');

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(submitCount, 1);

    completer.complete(
      const DiagnosticQuizResult(correctAnswers: 1, totalQuestions: 1),
    );
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.isSubmitting, isFalse);
    expect(controller.result?.correctAnswers, 1);
  });

  test('keeps submit errors visible and supports long quizzes', () async {
    final controller = DiagnosticQuizSessionController(
      activity: longActivity(questionCount: 15),
      submitter: (_) async => throw StateError('Activity already completed'),
    );

    for (var index = 1; index <= 15; index += 1) {
      controller.selectChoice(questionId: 'question-$index', choiceId: 'a');
    }

    expect(controller.answeredCount, 15);
    expect(controller.canSubmit, isTrue);

    await controller.submit();

    expect(controller.result, isNull);
    expect(controller.submitError, isA<StateError>());
  });
}

DiagnosticQuizActivity multipleActivity({
  int minSelections = 1,
  int maxSelections = 2,
}) {
  return DiagnosticQuizActivity(
    sessionId: 'session-multiple',
    title: 'Diagnostic multiple',
    questions: [
      DiagnosticQuizQuestion(
        id: 'question-multiple',
        prompt: 'Quels éléments contrôlent le pouvoir ?',
        selectionMode: DiagnosticQuizSelectionMode.multiple,
        minSelections: minSelections,
        maxSelections: maxSelections,
        choices: const [
          DiagnosticQuizChoice(id: 'a', label: 'Contrôle juridictionnel'),
          DiagnosticQuizChoice(id: 'b', label: 'Pouvoir absolu'),
          DiagnosticQuizChoice(id: 'c', label: 'Séparation des pouvoirs'),
        ],
      ),
    ],
  );
}

DiagnosticQuizActivity longActivity({required int questionCount}) {
  return DiagnosticQuizActivity(
    sessionId: 'session-long',
    title: 'Diagnostic long',
    questions: [
      for (var index = 1; index <= questionCount; index += 1)
        DiagnosticQuizQuestion(
          id: 'question-$index',
          knowledgeUnitId: 'unit-$index',
          prompt: 'Question $index',
          difficulty: 'MEDIUM',
          choices: const [
            DiagnosticQuizChoice(id: 'a', label: 'Choix A'),
            DiagnosticQuizChoice(id: 'b', label: 'Choix B'),
          ],
          sources: [
            DiagnosticQuizSourceRef(
              chunkId: 'chunk-$index',
              pageNumber: null,
              index: index - 1,
            ),
          ],
        ),
    ],
  );
}
