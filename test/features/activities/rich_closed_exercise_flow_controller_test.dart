import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/application/activity_controller.dart';
import 'package:revision_app/features/activities/application/rich_closed_exercise_flow_controller.dart';
import 'package:revision_app/features/activities/domain/diagnostic_quiz_activity.dart';
import 'package:revision_app/features/activities/domain/open_question_activity.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;
  late RichClosedExerciseResult result;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
    result = RichClosedExerciseResult.fromJson(richClosedResultJson());
  });

  test('démarre un exercice rich closed avec un état ready', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(
      subjectId: ' subject-1 ',
      knowledgeUnitId: ' unit-1 ',
    );

    expect(controller.state.status, RichClosedExerciseFlowStatus.ready);
    expect(controller.state.exercise, same(exercise));
    expect(controller.state.totalQuestions, 6);
    expect(controller.state.answeredCount, 1);
    expect(controller.state.canSubmit, isFalse);
    expect(api.startedSubjectId, 'subject-1');
    expect(api.startedKnowledgeUnitId, 'unit-1');
  });

  test('charge un exercice existant par sessionId', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.load(sessionId: ' rich-session-1 ');

    expect(controller.state.status, RichClosedExerciseFlowStatus.ready);
    expect(controller.state.exercise?.sessionId, 'rich-session-1');
    expect(api.loadedSessionId, 'rich-session-1');
  });

  test('collecte une réponse par question et submit sans correction', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    _answerAllQuestions(controller);

    expect(controller.state.answeredCount, 6);
    expect(controller.state.canSubmit, isTrue);

    await controller.submit();

    expect(controller.state.status, RichClosedExerciseFlowStatus.completed);
    expect(controller.state.result, same(result));
    expect(api.submittedSessionId, 'rich-session-1');
    expect(api.submittedAnswers, hasLength(6));
    expect(api.submittedAnswers!.map((answer) => answer.questionId), [
      'single-1',
      'multiple-1',
      'matching-1',
      'ordering-1',
      'case-1',
      'error-1',
    ]);
    for (final answer in api.submittedAnswers!) {
      final json = answer.toJson().toString();
      expect(json, isNot(contains('correct')));
      expect(json, isNot(contains('score')));
      expect(json, isNot(contains('explanation')));
      expect(json, isNot(contains('feedback')));
    }
  });

  test(
    'collecte timeline et date_slider avec réponses initiales typées',
    () async {
      final v1bExercise = RichClosedExercise.fromJson(
        richClosedV1BExerciseJson(),
      );
      final v1bResult = RichClosedExerciseResult.fromJson(
        richClosedV1BResultJson(),
      );
      final api = _FakeRichClosedActivityApi(
        exercise: v1bExercise,
        result: v1bResult,
      );
      final controller = RichClosedExerciseFlowController(
        activityController: ActivityController(api),
      );

      await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');

      expect(controller.state.answeredCount, 3);
      _answerAllQuestions(controller);
      expect(controller.state.answeredCount, 8);
      expect(controller.state.canSubmit, isTrue);

      await controller.submit();

      expect(api.submittedAnswers, hasLength(8));
      expect(
        api.submittedAnswers!
            .whereType<RichClosedTimelineAnswer>()
            .single
            .orderedEventIds,
        ['event-1', 'event-2', 'event-3'],
      );
      expect(
        api.submittedAnswers!
            .whereType<RichClosedDateSliderAnswer>()
            .single
            .year,
        1958,
      );
    },
  );

  test('refuse submit si les réponses sont incomplètes', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    final single = exercise.questions
        .whereType<RichClosedSingleChoiceQuestion>()
        .single;
    controller.recordAnswer(
      single,
      const RichClosedSingleChoiceAnswer(
        questionId: 'single-1',
        choiceId: 'choice-a',
      ),
    );

    await controller.submit();

    expect(controller.state.status, RichClosedExerciseFlowStatus.ready);
    expect(api.submitCallCount, 0);
  });

  test('ignore une réponse incohérente avec la question', () async {
    final api = _FakeRichClosedActivityApi(exercise: exercise, result: result);
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    final single = exercise.questions
        .whereType<RichClosedSingleChoiceQuestion>()
        .single;

    controller.recordAnswer(
      single,
      const RichClosedSingleChoiceAnswer(
        questionId: 'other-question',
        choiceId: 'choice-a',
      ),
    );

    expect(controller.state.answeredCount, 1);
    expect(controller.state.canSubmit, isFalse);
  });

  test('empêche deux submit simultanés', () async {
    final completer = Completer<RichClosedExerciseResult>();
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      submitCompleter: completer,
    );
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    _answerAllQuestions(controller);

    final firstSubmit = controller.submit();
    final secondSubmit = controller.submit();

    expect(api.submitCallCount, 1);
    expect(controller.state.status, RichClosedExerciseFlowStatus.submitting);

    completer.complete(result);
    await Future.wait([firstSubmit, secondSubmit]);

    expect(controller.state.status, RichClosedExerciseFlowStatus.completed);
  });

  test('expose les erreurs start et submit dans un état failed', () async {
    final api = _FakeRichClosedActivityApi(
      exercise: exercise,
      result: result,
      startError: StateError('start failed'),
      submitError: StateError('submit failed'),
    );
    final controller = RichClosedExerciseFlowController(
      activityController: ActivityController(api),
    );

    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');

    expect(controller.state.status, RichClosedExerciseFlowStatus.failed);
    expect(controller.state.error, isA<StateError>());

    api.startError = null;
    await controller.start(subjectId: 'subject-1', knowledgeUnitId: 'unit-1');
    _answerAllQuestions(controller);
    await controller.submit();

    expect(controller.state.status, RichClosedExerciseFlowStatus.failed);
    expect(controller.state.exercise, same(exercise));
    expect(controller.state.result, isNull);
    expect(controller.state.error, isA<StateError>());
  });
}

void _answerAllQuestions(RichClosedExerciseFlowController controller) {
  final exercise = controller.state.exercise!;

  for (final question in exercise.questions) {
    switch (question) {
      case RichClosedSingleChoiceQuestion():
        controller.recordAnswer(
          question,
          RichClosedSingleChoiceAnswer(
            questionId: question.id,
            choiceId: 'choice-a',
          ),
        );
      case RichClosedMultipleChoiceQuestion():
        controller.recordAnswer(
          question,
          RichClosedMultipleChoiceAnswer(
            questionId: question.id,
            choiceIds: const ['choice-a', 'choice-b'],
          ),
        );
      case RichClosedMatchingQuestion():
        controller.recordAnswer(
          question,
          RichClosedMatchingAnswer(
            questionId: question.id,
            pairs: const [
              RichClosedPair(leftId: 'left-1', rightId: 'right-1'),
              RichClosedPair(leftId: 'left-2', rightId: 'right-2'),
              RichClosedPair(leftId: 'left-3', rightId: 'right-3'),
            ],
          ),
        );
      case RichClosedOrderingQuestion():
        break;
      case RichClosedTimelineQuestion():
        break;
      case RichClosedDateSliderQuestion():
        break;
      case RichClosedTrueFalseGridQuestion():
        controller.recordAnswer(
          question,
          RichClosedTrueFalseGridAnswer(
            questionId: question.id,
            values: [
              for (final row in question.rows)
                RichClosedTrueFalseGridValue(rowId: row.id, value: true),
            ],
          ),
        );
      case RichClosedCauseConsequenceQuestion():
        controller.recordAnswer(
          question,
          RichClosedCauseConsequenceAnswer(
            questionId: question.id,
            pairs: [
              for (final indexedCause in question.causes.indexed)
                RichClosedCauseConsequencePair(
                  causeId: indexedCause.$2.id,
                  consequenceId: question.consequences[indexedCause.$1].id,
                ),
            ],
          ),
        );
      case RichClosedCaseQualificationQuestion():
        controller.recordAnswer(
          question,
          RichClosedCaseQualificationAnswer(
            questionId: question.id,
            choiceId: 'choice-a',
          ),
        );
      case RichClosedErrorDetectionQuestion():
        controller.recordAnswer(
          question,
          RichClosedErrorDetectionAnswer(
            questionId: question.id,
            errorId: 'error-a',
          ),
        );
    }
  }
}

class _FakeRichClosedActivityApi implements ActivityApi {
  _FakeRichClosedActivityApi({
    required this.exercise,
    required this.result,
    this.submitCompleter,
    this.startError,
    this.submitError,
  });

  final RichClosedExercise exercise;
  final RichClosedExerciseResult result;
  final Completer<RichClosedExerciseResult>? submitCompleter;
  Object? startError;
  Object? submitError;
  String? startedSubjectId;
  String? startedKnowledgeUnitId;
  String? loadedSessionId;
  String? submittedSessionId;
  List<RichClosedAnswer>? submittedAnswers;
  int submitCallCount = 0;

  @override
  Future<DiagnosticQuizActivity> startNextActivity({
    required String subjectId,
    String? knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<DiagnosticQuizResult> submitResult({
    required String sessionId,
    required List<DiagnosticQuizAnswer> answers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenQuestionActivity> startOpenQuestion({
    required String subjectId,
    required String knowledgeUnitId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<OpenAnswerSubmissionResult> submitOpenAnswer({
    required String sessionId,
    required String answerText,
  }) {
    throw UnimplementedError();
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
    if (startError != null) {
      throw startError!;
    }

    startedSubjectId = subjectId;
    startedKnowledgeUnitId = knowledgeUnitId;
    return exercise;
  }

  @override
  Future<RichClosedExercise> getRichClosedExercise(String sessionId) async {
    loadedSessionId = sessionId;
    return exercise;
  }

  @override
  Future<RichClosedExerciseResult> submitRichClosedExercise({
    required String sessionId,
    required List<RichClosedAnswer> answers,
  }) async {
    submitCallCount += 1;
    submittedSessionId = sessionId;
    submittedAnswers = answers;

    if (submitError != null) {
      throw submitError!;
    }

    final completer = submitCompleter;
    if (completer != null) {
      return completer.future;
    }

    return result;
  }

  @override
  Future<RichClosedExerciseResult> getRichClosedExerciseResult(
    String sessionId,
  ) async {
    return result;
  }
}
