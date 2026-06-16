import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/features/activities/domain/rich_closed_exercise.dart';
import 'package:revision_app/features/activities/presentation/rich_closed/rich_closed_answer_controller.dart';

import 'fixtures/rich_closed_exercise_fixtures.dart';

void main() {
  late RichClosedExercise exercise;

  setUp(() {
    exercise = RichClosedExercise.fromJson(richClosedExerciseJson());
  });

  test('single choice remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');
    controller.selectSingleChoice(question: question, choiceId: 'choice-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedSingleChoiceAnswer>());
    expect((answer! as RichClosedSingleChoiceAnswer).choiceId, 'choice-b');
  });

  test('case qualification remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedCaseQualificationQuestion>(exercise);

    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-a',
    );
    controller.selectCaseQualification(
      question: question,
      choiceId: 'choice-b',
    );

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedCaseQualificationAnswer>());
    expect((answer! as RichClosedCaseQualificationAnswer).choiceId, 'choice-b');
  });

  test('error detection remplace la sélection précédente', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectErrorDetection(question: question, errorId: 'error-a');
    controller.selectErrorDetection(question: question, errorId: 'error-b');

    final answer = controller.answerFor(question);
    expect(answer, isA<RichClosedErrorDetectionAnswer>());
    expect((answer! as RichClosedErrorDetectionAnswer).errorId, 'error-b');
  });

  test('multiple choice toggle ajoute et enlève', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    expect(controller.selectedChoiceIdsFor(question), ['choice-b']);
  });

  test('multiple choice ne dépasse pas maxSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');
    controller.toggleMultipleChoice(question: question, choiceId: 'choice-c');

    expect(controller.selectedChoiceIdsFor(question), ['choice-a', 'choice-b']);
    expect(controller.message, contains('2 réponses au maximum'));
  });

  test('multiple choice canSubmit est faux sous minSelections', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

    controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');

    expect(controller.canSubmitQuestion(question), isFalse);
    expect(controller.answerFor(question), isNull);
  });

  test(
    'multiple choice canSubmit est vrai quand les bornes sont respectées',
    () {
      final controller = RichClosedCoreAnswerController();
      final question = _question<RichClosedMultipleChoiceQuestion>(exercise);

      controller.toggleMultipleChoice(question: question, choiceId: 'choice-a');
      controller.toggleMultipleChoice(question: question, choiceId: 'choice-b');

      final answer = controller.answerFor(question);
      expect(controller.canSubmitQuestion(question), isTrue);
      expect(answer, isA<RichClosedMultipleChoiceAnswer>());
      expect((answer! as RichClosedMultipleChoiceAnswer).choiceIds, [
        'choice-a',
        'choice-b',
      ]);
    },
  );

  test('produit les quatre réponses V1-010', () {
    final controller = RichClosedCoreAnswerController();
    final single = _question<RichClosedSingleChoiceQuestion>(exercise);
    final multiple = _question<RichClosedMultipleChoiceQuestion>(exercise);
    final caseQuestion = _question<RichClosedCaseQualificationQuestion>(
      exercise,
    );
    final error = _question<RichClosedErrorDetectionQuestion>(exercise);

    controller.selectSingleChoice(question: single, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-a');
    controller.toggleMultipleChoice(question: multiple, choiceId: 'choice-b');
    controller.selectCaseQualification(
      question: caseQuestion,
      choiceId: 'choice-a',
    );
    controller.selectErrorDetection(question: error, errorId: 'error-a');

    expect(controller.answerFor(single), isA<RichClosedSingleChoiceAnswer>());
    expect(
      controller.answerFor(multiple),
      isA<RichClosedMultipleChoiceAnswer>(),
    );
    expect(
      controller.answerFor(caseQuestion),
      isA<RichClosedCaseQualificationAnswer>(),
    );
    expect(controller.answerFor(error), isA<RichClosedErrorDetectionAnswer>());
  });

  test('refuse matching et ordering dans ce lot', () {
    final controller = RichClosedCoreAnswerController();
    final matching = _question<RichClosedMatchingQuestion>(exercise);
    final ordering = _question<RichClosedOrderingQuestion>(exercise);

    expect(controller.canSubmitQuestion(matching), isFalse);
    expect(controller.answerFor(matching), isNull);
    expect(controller.canSubmitQuestion(ordering), isFalse);
    expect(controller.answerFor(ordering), isNull);
  });

  test('ne produit jamais de correction dans le JSON de réponse', () {
    final controller = RichClosedCoreAnswerController();
    final question = _question<RichClosedSingleChoiceQuestion>(exercise);

    controller.selectSingleChoice(question: question, choiceId: 'choice-a');

    final json = controller.answerFor(question)!.toJson();
    expect(json.keys.any((key) => key.startsWith('correct')), isFalse);
    expect(json.containsKey('correction'), isFalse);
    expect(json.containsKey('score'), isFalse);
    expect(json.containsKey('explanation'), isFalse);
  });
}

T _question<T extends RichClosedQuestion>(RichClosedExercise exercise) {
  return exercise.questions.whereType<T>().single;
}
