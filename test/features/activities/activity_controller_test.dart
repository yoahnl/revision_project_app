import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';

class FakeActivityApi implements ActivityApi {
  String? startedSubjectId;
  List<DiagnosticQuizAnswer>? submittedAnswers;
  String? startedOpenQuestionSubjectId;
  String? startedOpenQuestionKnowledgeUnitId;
  String? submittedOpenAnswerText;
  int submitCallCount = 0;
  int openAnswerSubmitCallCount = 0;
  Completer<DiagnosticQuizResult>? submitCompleter;
  Completer<OpenAnswerSubmissionResult>? openAnswerSubmitCompleter;
  Object? submitError;
  Object? openAnswerSubmitError;

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

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) async {
    startedOpenQuestionSubjectId = subjectId;
    startedOpenQuestionKnowledgeUnitId = knowledgeUnitId;

    return openQuestionActivity();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) async {
    openAnswerSubmitCallCount += 1;
    submittedOpenAnswerText = answerText;

    if (openAnswerSubmitError != null) {
      throw openAnswerSubmitError!;
    }

    final completer = openAnswerSubmitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return openAnswerReadyResult();
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

  test('loads an open question activity', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final activity = await controller.startOpenQuestion(
      subjectId: ' subject-1 ',
      knowledgeUnitId: ' unit-1 ',
    );

    expect(activity.sessionId, 'open-session-1');
    expect(activity.question.prompt, 'Explique la séparation des pouvoirs.');
    expect(api.startedOpenQuestionSubjectId, 'subject-1');
    expect(api.startedOpenQuestionKnowledgeUnitId, 'unit-1');
  });

  test('submits an open answer through the activity api', () async {
    final api = FakeActivityApi();
    final controller = ActivityController(api);

    final result = await controller.submitOpenAnswer(
      sessionId: 'open-session-1',
      answerText: ' La séparation des pouvoirs limite chaque autorité. ',
    );

    expect(api.submittedOpenAnswerText, 'La séparation des pouvoirs limite chaque autorité.');
    expect(result.evaluation.status, OpenAnswerEvaluationStatus.ready);
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

  test('manages open answer validation and READY correction state', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (answerText) async => openAnswerReadyResult(),
    );

    expect(controller.canSubmit, isFalse);
    expect(controller.validationMessage, 'Réponse trop courte');

    controller.updateAnswer('Réponse assez longue.');

    expect(controller.canSubmit, isTrue);
    expect(controller.answerText, 'Réponse assez longue.');

    await controller.submit();

    expect(controller.result?.evaluation.status, OpenAnswerEvaluationStatus.ready);
    expect(controller.result?.evaluation.feedback, 'Réponse solide.');
    expect(controller.canSubmit, isFalse);
  });

  test('blocks open answers that exceed max length', () {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(maxAnswerLength: 20),
      submitter: (answerText) async => openAnswerReadyResult(),
    );

    controller.updateAnswer('Une réponse beaucoup trop longue pour la limite.');

    expect(controller.canSubmit, isFalse);
    expect(controller.validationMessage, 'Réponse trop longue');
  });

  test('stores FAILED open answer evaluations', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (answerText) async => openAnswerFailedResult(),
    );

    controller.updateAnswer('Réponse assez longue.');

    await controller.submit();

    expect(controller.result?.evaluation.status, OpenAnswerEvaluationStatus.failed);
    expect(controller.submitError, isNull);
  });

  test('keeps the open answer text when submit fails', () async {
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (_) async => throw StateError('network failed'),
    );

    controller.updateAnswer('Réponse assez longue.');

    await controller.submit();

    expect(controller.result, isNull);
    expect(controller.answerText, 'Réponse assez longue.');
    expect(controller.submitError, isA<StateError>());
    expect(controller.submitErrorMessage, contains('peut-être été enregistrée'));
  });

  test('prevents duplicate open answer submit while running', () async {
    final completer = Completer<OpenAnswerSubmissionResult>();
    var submitCount = 0;
    final controller = OpenQuestionSessionController(
      activity: openQuestionActivity(),
      submitter: (_) {
        submitCount += 1;
        return completer.future;
      },
    );

    controller.updateAnswer('Réponse assez longue.');

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(submitCount, 1);

    completer.complete(openAnswerReadyResult());
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.isSubmitting, isFalse);
    expect(controller.result?.evaluation.status, OpenAnswerEvaluationStatus.ready);
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

OpenQuestionActivity openQuestionActivity({int maxAnswerLength = 4000}) {
  return OpenQuestionActivity(
    sessionId: 'open-session-1',
    type: 'open_question',
    version: 1,
    subjectId: 'subject-1',
    documentId: 'document-1',
    knowledgeUnitId: 'unit-1',
    question: OpenQuestion(
      id: 'open-question-1',
      prompt: 'Explique la séparation des pouvoirs.',
      instructions: 'Réponds en quelques phrases.',
      maxAnswerLength: maxAnswerLength,
      sources: const [
        OpenQuestionSource(chunkId: 'chunk-1', pageNumber: null, index: 0),
      ],
    ),
  );
}

OpenAnswerSubmissionResult openAnswerReadyResult() {
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
      presentPoints: ['Définition correcte'],
      missingPoints: ['Exemple attendu'],
      errors: [],
      modelAnswer: 'Réponse modèle.',
      advice: 'Ajoute un exemple.',
      sources: [
        OpenAnswerCorrectionSource(
          chunkId: 'chunk-1',
          text: 'Source post-submit.',
          pageNumber: null,
          index: 0,
        ),
      ],
    ),
  );
}

OpenAnswerSubmissionResult openAnswerFailedResult() {
  return const OpenAnswerSubmissionResult(
    sessionId: 'open-session-1',
    type: 'open_question',
    status: 'submitted',
    evaluation: OpenAnswerEvaluation(
      id: 'evaluation-1',
      status: OpenAnswerEvaluationStatus.failed,
      score: null,
      maxScore: null,
      feedback: null,
      presentPoints: [],
      missingPoints: [],
      errors: ['OPEN_ANSWER_EVALUATION_FAILED'],
      modelAnswer: null,
      advice: null,
      sources: [],
    ),
  );
}
